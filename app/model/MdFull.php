<?php
namespace App\Model;

class MdFull {
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
	private $mds = '';
    private $mark_http = FALSE;
    private $appLang = 'eng';

	/**
	 *  Určení jazyka, který se použije pro výběr dat.
	 *  Priorita: 1. MICKA_LANG, 2. ENG, 3. první v pořadí
	 *
	 * @param string $langs seznam jazyků z tabulky MD.langs
	 * @return string
	 */
	private function getLangValue($langs) {
		if (substr_count($langs, MICKA_LANG) > 0) {
			return MICKA_LANG;
		}
		if (getCountLang($langs) == 1) {
			return $langs;
		}
		else {
			$md_langs = getMdLangs($langs);
			if (array_search('eng', $md_langs) === FALSE) {
					return $md_langs[0];
			}
			else {
				return 'eng';
			}
		}
	}

	function getMdMaster($uuid) {
		$rs = array();
		if ($uuid == '') {
			return $rs;
		}
		$sql = array();
		array_push($sql, "
			SELECT md.recno, md.uuid, md.title, " . setNtext2Text('md_values.', 'md_value') . ", md_values.lang
			FROM  md INNER JOIN md_values ON (md.recno = md_values.recno)
				INNER JOIN tree ON (md_values.md_id = tree.md_id)
				AND (md.md_standard = tree.md_standard)
			WHERE tree.md_mapping = 'title' AND uuid=%s
			ORDER BY recno
		",$uuid);
		$result = _executeSql('select', $sql, array('all'));
		if (is_array($result) && count($result) > 0) {
			$pom = array();
			foreach ($result as $row) {
				$pom['uuid'] = $row['UUID'];
				$pom['text'] = $row['TITLE'];
				if ($row['LANG'] == MICKA_LANG) {
					$pom['text'] = $row['MD_VALUE'];
					break;
				}
			}
			array_push($rs, $pom);
		}
		return $rs;
	}

	function getMdSlave($uuid) {
		$rs = array();
		if ($uuid == '') {
			return $rs;
		}
		$sql = array();
		array_push($sql, "
			SELECT md.recno, md.uuid
			FROM (md INNER JOIN md_values ON md.recno = md_values.recno) INNER JOIN standard ON md.md_standard = standard.md_standard
		");
		if (DB_DRIVER == 'mssql') {
			array_push($sql, "
				WHERE md.md_standard=0 AND md_values.md_id=121 AND md_values.md_value like %s
			", $uuid);
		}
		else {
			array_push($sql, "
				WHERE md.md_standard=0 AND md_values.md_id=121 AND md_values.md_value=%s
			", $uuid);
		}
		array_push($sql, "
			ORDER BY md_values.recno
		");
		$result = _executeSql('select', $sql, array('all'));
		if (is_array($result) && count($result) > 0) {
			foreach ($result as $row) {
				$pom['uuid'] = $row['UUID'];
				$pom['text'] = '';
				$sql2 = array();
				array_push($sql2, "
					SELECT " . setNtext2Text('', 'md_value') . ",lang FROM md_values WHERE md_id=11 AND recno=%i
				", $row['RECNO']);
				$result2 = _executeSql('select', $sql2, array('all'));
				foreach ($result2 as $row2) {
					$pom['text'] = $row2['MD_VALUE'];
					if ($row2['LANG'] == MICKA_LANG) {
						$pom['text'] = $row2['MD_VALUE'];
						break;
					}
				}
				array_push($rs, $pom);
			}
		}
		return $rs;
	}

	function getSpatialRep($recno) {
		$rs = array();
		$sql = array();
		$param = '/MD_Metadata/spatialRepresentationInfo/MD_GridSpatialRepresentation%';

		$sql[] = "
			SELECT " . setNtext2Text('md_values.', 'md_value') . "
			FROM (md_values INNER JOIN md ON md_values.recno = md.recno) INNER JOIN tree ON (md.md_standard = tree.md_standard) AND (md_values.md_id = tree.md_id)
			WHERE md_values.recno=$recno AND tree.md_path_el like '$param'
		";
		$result = _executeSql('select', $sql, array('single'));
		if ($result != '') {
			$rs[0] = 'grid';
		}
		else {
			$param = '/MD_Metadata/spatialRepresentationInfo/MD_VectorSpatialRepresentation/geometricObjects/geometricObjectType%';
			$sql = array();
			$sql[] = "
				SELECT md_values.md_id," . setNtext2Text('md_values.', 'md_value') . "
				FROM (md_values INNER JOIN md ON md_values.recno = md.recno) INNER JOIN tree ON (md.md_standard = tree.md_standard) AND (md_values.md_id = tree.md_id)
				WHERE md_values.recno=$recno AND tree.md_path_el like '$param'";
			$result = _executeSql('select', $sql, array('all'));
			if (is_array($result) && count($result) > 0) {
				foreach ($result as $row) {
					$rs[] = $row['MD_VALUE'];
				}
			}
		}
		return $rs;
	}

	private function print_array($values, $level, $min_id, $level_inc=FALSE, $lang='xxx') {
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

	private function getMdValuesMdId($recno, $mds, $lang_data) {
		$rs = FALSE;
		$sql = array();
		$value = '';
		if ($mds == 10) {
			$mds = 0;
		}
		array_push($sql, "
			SELECT " . setNtext2Text('md_values.', 'md_value') . ", md_values.md_path, md_values.lang, md_values.md_id, md_values.package_id, elements.form_code, elements.from_codelist
			FROM md INNER JOIN md_values ON (md.recno=md_values.recno) AND (md_values.recno=md.recno)
				INNER JOIN tree ON (md_values.md_id=tree.md_id)
				INNER JOIN elements ON (tree.el_id=elements.el_id)
			WHERE md_values.md_id>-1 AND tree.md_standard=%i AND md_values.recno=%i
				AND (md_values.lang='xxx' OR md_values.lang=%s)
			ORDER BY md_values.md_path, md_values.lang
		", $mds, $recno, $lang_data);
		$result = _executeSql('select', $sql, array('all'));
		foreach ($result as $row) {
			$md_id = $row['MD_ID'];
			$value = $row['MD_VALUE'];
			switch ($row['FORM_CODE']) {
				case 'D':
					if (MICKA_LANG == 'cze') {
						$value = dateIso2Cz($value);
					}
					break;
				case 'C':
					if (!$row['FROM_CODELIST'] == '') {
						$el_id = $row['FROM_CODELIST'];
					}
					else {
						$el_id = $row['EL_ID'];
					}
					// hierarchy
					if ($mds == 0 && $md_id == 623) {
						$this->hierarchy = $value;
					}
					$value = getLabelCodeList($value, $el_id);
					break;
				default:
			}
			if ($row['PACKAGE_ID'] == 7) {
						$label = '$rs'. getMdPath($row['MD_PATH']) . "='" . $value . "';";
						eval($label);
			}
			$rs[$md_id][] = $value;
		}
		return $rs;
	}
    
    private function getLabelCodeList($value, $el_id) {
        $rs = $value;
        if ($value != '' && $el_id != '') {
            $sql = array();
            array_push($sql, "
                SELECT label.label_text
                FROM codelist INNER JOIN label ON codelist.codelist_id = label.label_join
                WHERE codelist.el_id=%i AND label.label_type='CL' AND label.lang=%s AND codelist.codelist_name=%s
            ", $el_id, MICKA_LANG, $value);
            $result = _executeSql('select', $sql, array('single'));
            if ($result != '') {
                $rs = $result;
            }
        }
        return $rs;
    }

	private function getRecordValueArray($record) {
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

	private function getMdLabels($label, $pid = -1) {
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

	private function getMdValuesAll($values, $mds, $pid = -1, $hyper = -1) {
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

	public function getMdFullView($values, $labelEl, $labelCl) {
        $mds = 0;
		$this->labels  = $this->getMdLabels($labelEl, -2);
		// všechny packages kromě MD_Metadata
		$this->values = $this->getRecordValueArray($this->getMdValuesAll($values, $mds, -1, 1));
		$this->print_array($this->values, 0, 0);
		// package MD_Metadata
		$this->values = $this->getRecordValueArray($this->getMdValuesAll($values, $mds, 0, 1));
		$this->print_array($this->values, 0, -1, TRUE);
		return $this->detail;
	}

}
?>
