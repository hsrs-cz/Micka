<?php
namespace App\Model;
use Nette;

class MdFull  extends \BaseModel
{
	private $labels = array();
	private $values = array();
	private $detail = array();
	private $pidi;
	private $plab;
	private $plabh;
	private $plev;
	private $pshn;
	private $pmbid;
	private $pmb;
	private $smaz;
	private $hierarchy = '';
    private $mark_http = FALSE;
    private $appLang = 'eng';

	public function startup()
	{
		parent::startup();
	}
    
	private function getFullMdValues($recno, $appLang)
	{
        return $this->db->query("
        	SELECT md_values.md_value, md_values.md_id, md_values.md_path,  md_values.lang, md_values.package_id, elements.form_code, elements.el_id, elements.from_codelist
			FROM (elements RIGHT JOIN standard_schema ON elements.el_id = standard_schema.el_id) RIGHT JOIN md_values ON standard_schema.md_id = md_values.md_id
			WHERE md_values.recno=? AND (md_values.lang='xxx' OR md_values.lang='uri' OR md_values.lang=?)
            ORDER BY standard_schema.md_left, md_values.md_path
            ", $recno,$appLang)->fetchAll();
	}

	private function getElementsLabel($mds,$appLang)
	{
        $standard_schema = $this->db->query('SELECT md_left, md_right FROM standard_schema WHERE md_id=0 AND md_standard=?', 
                $mds == 10 ? 0 : $mds)->fetch();
        $result = $this->db->query("
			SELECT elements.el_id, elements.el_name, elements.el_short_name, elements.only_value, standard_schema.md_id,
				standard_schema.md_level, standard_schema.package_id, label.label_text, label.label_help
			FROM (label INNER JOIN elements ON label.label_join = elements.el_id) INNER JOIN standard_schema ON elements.el_id = standard_schema.el_id
			WHERE standard_schema.md_left>=?  AND standard_schema.md_right<=? AND label.lang=? AND label.label_type='EL' AND standard_schema.md_standard=?
            ORDER BY standard_schema.md_left
		", $standard_schema->md_left, $standard_schema->md_right, $appLang, $mds == 10 ? 0 : $mds)->fetchAll();
        return $result;
    }
    
    private function getCodeListLabel($appLang)
    {
        return $this->db->query("
            SELECT label.label_text
            FROM codelist INNER JOIN label ON codelist.codelist_id = label.label_join
            WHERE label.label_type='CL' AND label.lang=?
		", $appLang)->fetchAll();
    }
    
	private function print_array($values, $level, $min_id, $level_inc=FALSE, $lang='xxx')
    {
		foreach ($values as $key => $item) {
			if (is_array($item)) {
				if ($key{0} != 'P' && $key > $min_id) {
					$zaznam = array();
					$zaznam['hodnota'] = '';
					$zaznam['id'] = $key;
					$zaznam['label'] = $this->labels[$key]['label'];
					$zaznam['label_help'] = $this->labels[$key]['label_help'];
					$zaznam['level'] = array_key_exists('level', $this->labels[$key]) ? $this->labels[$key]['level'] : '';
					$zaznam['short_name'] = array_key_exists('short_name', $this->labels[$key]) ? $this->labels[$key]['short_name'] : '';
					$zaznam['package_id'] = array_key_exists('package_id', $this->labels[$key]) ? $this->labels[$key]['package_id'] : '';
					$zaznam['lang'] = '';
					$zaznam['data'] = 0;
					if ($this->labels[$key]['only_value'] != 1) {
						$this->pidi  = $zaznam['id'];
						$this->plab  = $zaznam['label'];
						$this->plabh = $zaznam['label'];
						$this->plev  = $zaznam['level'];
						$this->pshn  = $zaznam['short_name'];
						$this->pmbid = $zaznam['package_id'];
						if ($level_inc === TRUE) {
							$zaznam['level'] = $zaznam['level'] + 1;
						}
						array_push($this->detail, $zaznam);
						$this->smaz=1;
					}
				}
				$this->print_array($item, $level + 1, 0, $level_inc, $lang);
			} else {
                if ($key{0} == 'L') {
                    $lang = substr($key, 1);
                }
				if ($this->smaz == 1) array_splice($this->detail,-1,1);
				$zaznam = array();
				$zaznam['hodnota'] = html_entity_decode($item, ENT_QUOTES);
				$zaznam['id'] = $this->pidi;
				$zaznam['label'] = $this->plab;
				$zaznam['label_help'] = $this->plabh;
				$zaznam['level'] = $this->plev;
				$zaznam['short_name'] = $this->pshn;
				$zaznam['package_id'] = $this->pmbid;
				$zaznam['mb'] = $this->pmb;
				$zaznam['data'] = 1;
                $zaznam['lang'] = $lang;
				$this->smaz=0;
				if ($level_inc === TRUE) {
					$zaznam['level'] = $zaznam['level'] + 1;
				}
				array_push($this->detail, $zaznam);
			}
		}
	}

	private function getRecordValueArray($record)
    {
		$rs = array();
		foreach($record as $neco){
			foreach($neco as $zaseneco){
				foreach($zaseneco as $nazev=>$hodnota){
					if ($nazev == 'value') {
						$value = htmlentities($hodnota, ENT_QUOTES);
                        if ($this->mark_http === TRUE && strtolower(substr($value, 0, 4)) == 'http') {
                            $value = $value = "<a href=\"$value\">$value</a>";
                        }
					}
					if ($nazev == 'path') {
						$label = $hodnota;
					}
					if ($nazev == 'lang') {
						$lang = 'L' . $hodnota;
					}
				}
				$label = '$rs' . $label . '[\'' . $lang . '\']' . '=\'' . $value . '\';';
				eval($label);
			}
		}
		return $rs;
	}

	private function getMdLabels($label, $pid = -1)
    {
		$rs = array();
		$package_id = -1;
		foreach($label as $n=>$row) {
			$md_id = $row->md_id;
			$rs[$md_id]['label'] = $row->label_text;
			$rs[$md_id]['label_help'] = $row->label_help;
			$rs[$md_id]['level'] = $row->md_level;
			$rs[$md_id]['short_name'] = $row->el_short_name;
			$rs[$md_id]['only_value'] = $row->only_value;
			$rs[$md_id]['package_id'] = $package_id != $row->package_id ? $row->package_id : '';
			$package_id = $row['package_id'];
		}
		return $rs;
	}

	private function getMdValuesAll($values, $mds, $pid = -1, $hyper = -1)
    {
		$rs = array();
		foreach($values as $row) {
            if ($mds == 0 && $pid != 0 && $row->package_id == 0) {
                continue;
            }
            if ($mds == 0 && $pid == 0 && $row->package_id > 0) {
                continue;
            }
			$sanit = true;
			$hle = $row->md_value;
			if ($row->form_code == 'D' && $this->appLang == 'cze') {
				$hle = DateIso2Cz($hle);
			}
			if ($row->form_code == 'C') {
				if (!$row->from_codelist == '') {
					$eid = $row->from_codelist;
				}
				else {
					$eid = $row->el_id;
				}
                // hierarchy
                if ($mds == 0 && $row->md_id == 623) {
                    $this->hierarchy = $hle;
                }
				//$hle = $this->getLabelCodeList($hle, $eid);
			}
			else {
				if ($hyper == 1) {
					if ($row->form_code == 'T') {
						$hle_link = trim($hle);
						if ($hle != $hle_link) {
							$sanit = false;
						}
					}
				}
			}
			$hodnoty = array();
			$md_id = $row->md_id;
			if($sanit) {
				$hle = htmlspecialchars($hle);
			}
			$hodnoty[$md_id]['value'] = str_replace('\\', '\\\\', $hle);
			$hodnoty[$md_id]['lang'] = $row->lang;;
			$retez = $row->md_path;
			$ret = substr($retez,0,strlen($retez)-1);
			$pom = explode('_',$ret);
			$c = sizeof(explode('_',$ret));
			$retez2 = "";
			for ($i=0;$i<$c;) {
				$id1 = $pom[$i];
				$i++;
				$id2 = $pom[$i];
				$i++;
				if ($retez2 == '') $retez2 = $id1 . "_'P" . $id2 . "'";
				else $retez2 = $retez2."_".$id1 . "_'P" . $id2 . "'";
			}
			$retez2 = str_replace("_","][",$retez2);
			$hodnoty[$md_id]['path'] = '['.$retez2.']';
			array_push($rs, $hodnoty);
		}
		return $rs;
	}

	public function getMdFullView($recno, $mds, $appLang)
    {
        $this->appLang = $appLang;
        $values = $this->getFullMdValues($recno, $appLang);
        $labelEl = $this->getElementsLabel($mds, $appLang);
        $labelCl = $this->getCodeListLabel($appLang);
        
		$this->labels  = $this->getMdLabels($labelEl, -2);
		// outside MD_Metadata
		$this->values = $this->getRecordValueArray($this->getMdValuesAll($values, $mds, -1, 1));
		$this->print_array($this->values, 0, 0);
		// MD_Metadata
		$this->values = $this->getRecordValueArray($this->getMdValuesAll($values, $mds, 0, 1));
		$this->print_array($this->values, 0, -1, TRUE);
		return $this->detail;
	}

}