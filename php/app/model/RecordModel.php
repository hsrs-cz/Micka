<?php

namespace App\Model;

use Nette;


class RecordModel extends \BaseModel
{
    private $appParameters;
    private $recordMd = NULL;
    private $recordMdValues = [];
    private $typeTableMd = 'edit_md';
    private $profil_id = -1;
    private $package_id = -1;
    
	public function startup()
	{
		parent::startup();
	}
    
    public function setAppParameters($appParameters)
    {
        $this->appParameters = $appParameters;
    }
    
    private function setRecordMdById($id, $typeTableMd, $right)
    {
        $this->typeTableMd = $typeTableMd == 'edit_md' ? 'edit_md' : 'md';
        if ($this->typeTableMd == 'edit_md') {
            $this->recordMd = $this->db->query(
                "SELECT * FROM edit_md WHERE sid=? AND uuid=?",session_id(),$id)->fetch();
        } else {
            $this->recordMd = $this->db->query(
                "SELECT * FROM md WHERE uuid=?", $id)->fetch();
        }
        if ($this->recordMd && $right != 'new') {
            if ($this->isRight2MdRecord($right) === FALSE) {
                $this->recordMd = NULL;
            }
        }
        return;
    }
    
    private function setRecordMdValues()
    {
        if ($this->recordMd && count($this->recordMdValues) == 0) {
            $table = $this->typeTableMd == 'edit_md' ? 'edit_md_values' : 'md_values';
            $this->recordMdValues = $this->db->query(
                "SELECT * FROM $table WHERE recno=?", $this->recordMd->recno)->fetchAll();
        }
        return;
    }
    
    private function isRight2MdRecord($right)
    {
        if ($this->recordMd === NULL) {
            return FALSE;
        }
        if ($this->user->isInRole('admin')) {
            return TRUE;
        }
        switch ($right) {
            case 'read':
                if($this->recordMd->data_type > 0) {
                    return TRUE;
                }
                if($this->user->isLoggedIn()) {
                    if($this->recordMd->create_user == $this->user->getIdentity()->username) {
                        return TRUE;
                    }
                    if($this->user->isLoggedIn()) {
                        foreach ($this->user->getIdentity()->data['groups'] as $row) {
                            if ($row == $this->recordMd->view_group) {
                                return TRUE;
                            }
                            if ($row == $this->recordMd->edit_group) {
                                return TRUE;
                            }
                        }
                    }
                }
                return FALSE;
            case 'write':
                if($this->user->isLoggedIn()) {
                    if($this->recordMd->create_user == $this->user->getIdentity()->username) {
                        return TRUE;
                    }
                    if($this->user->isLoggedIn()) {
                        foreach ($this->user->getIdentity()->data['groups'] as $row) {
                            if ($row == $this->recordMd->edit_group) {
                                return TRUE;
                            }
                        }
                    }
                }
                return FALSE;
            default:
                return FALSE;
        }
    }
    
    private function getUuid()
    {
        $uuid = new \UUID;
        $uuid->generate();
        return $uuid->toRFC4122String();
    }

    private function getNewRecno($typeTableMd)
    {
        $table = $typeTableMd == 'edit_md' ? 'edit_md' : 'md';
        $recno = $this->db->query("SELECT MAX(recno)+1 FROM $table")->fetchField();
        return $recno > 1 ? $recno : 1;
    }
    
    private function seMdValues($data,$recno=0)
    {
        if (count($data) > 0) {
            if ($recno > 0) {
                foreach ($data as $key=>$value) {
                    $data[$key]['recno'] = $recno;
                }
            }
            $this->db->query("INSERT INTO edit_md_values", $data);
        }
    }
    
    private function updateEditMD($recno)
    {
        /*
		'data_type';
		'edit_group';
		'view_group';
        'last_update_user';
        'last_update_date';
        'x1';
        'y1';
        'x2';
        'y2';
        'the_geom geometry';
        'range_begin';
        'range_end';
        'md_update';
        'title';
        'valid';
        'prim';
        */
        $xml = $this->recordMd->pxml == '' ? NULL : str_replace("'", "&#39;", $this->recordMd->pxml);
        $this->db->query("UPDATE edit_md SET pxml=XMLPARSE(DOCUMENT ?) 
                WHERE sid='".session_id()."' AND recno=?", $xml, $recno);
    }
    
    private function setEditMd2Md($editRecno, $recno)
    {
        $mdRecno = NULL;
        if ($recno == 0) {
            $mdRecno = $this->getNewRecno('md');
            $this->db->query("
                INSERT INTO md (recno,uuid,md_standard,lang,data_type,create_user,create_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid)
                SELECT ?,uuid,md_standard,lang,data_type,create_user,create_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid
                FROM edit_md WHERE recno=?"
                , $mdRecno, $editRecno);
        } else {
            $sql = "UPDATE md SET pxml=edit.pxml FROM edit_md edit
                    WHERE edit.recno=? AND md.recno=? AND edit.sid='".session_id()."'";
            $this->db->query($sql,$editRecno,$recno);
        }
        return $mdRecno;
    }
    
    private function deleteMdValues($recno) {
        $this->db->query("DELETE FROM md_values WHERE recno=?", $recno);
        return;
    }
    
    private function deleteEditMdValuesByProfil($editRecno, $mds, $profil_id, $package_id) {
        $sql = "DELETE FROM edit_md_values WHERE recno=?";
        if ($profil_id > -1) {
            $sql .= " AND md_id IN(SELECT md_id FROM profil WHERE profil_id=$profil_id)";
        }
        if ($package_id > -1) {
            $sql .= " AND package_id=$package_id";
        }
		if ($mds == 0 || $mds == 10) {
			$sql .= " AND md_id<>38";
		}
        $this->db->query($sql, $editRecno);
        return;
    }

    private function setEditMdValues2MdValues($editRecno, $recno)
    {
        $this->db->query("
            INSERT INTO md_values (recno, md_id, md_value, md_path, lang , package_id)
            SELECT ?, md_id, md_value, md_path, lang , package_id 
            FROM edit_md_values WHERE recno=?"
            , $recno, $editRecno);
        return;
    }

    public function setEditRecord2Md()
    {
        if (!$this->recordMd || $this->typeTableMd != 'edit_md') {
            // error
        }
        $editRecno = $this->recordMd->recno;
        $this->setRecordMdById($this->recordMd->uuid, 'md', 'write');
        if ($this->recordMd) {
            $this->deleteMdValues($this->recordMd->recno);
            $this->setEditMdValues2MdValues($editRecno, $this->recordMd->recno);
            $this->setEditMd2Md($editRecno, $this->recordMd->recno);
        } else {
            $recno = $this->setEditMd2Md($editRecno, 0);
            $this->setEditMdValues2MdValues($editRecno, $recno);
        }
    }
    
    private function setMdFromXml($data) {
        if (array_key_exists('params', $data)
            && array_key_exists('md', $data)
            && array_key_exists('md_values', $data)
            && array_key_exists('del_md_id', $data)
        ) {
            foreach ($data['md'] as $key => $value) {
                if (isset($value['uuid']) && $value['uuid'] != '') {
                    $this->setRecordMdById($value['uuid'], 'md', 'new');
                    if ($this->recordMd) {
                        //update
                        if ($this->isRight2MdRecord('write') === FALSE) {
                            $this->recordMd = NULL;
                            throw new \Nette\Application\ApplicationException(
                                'messages.import.notRightRecordUpdate');
                        }
                        if ($data['params']['update_type'] == 'all') {
                            $this->findMdById($this->copyMd2EditMd(),'edit_md','write');
                            $md['recno'] = $this->recordMd->recno;
                            $md['uuid'] = rtrim($this->recordMd->uuid);
                        } else {
                            // skip
                            throw new \Nette\Application\ApplicationException(
                                'messages.import.recordUpdateSkip');
                        }
                    } else {
                        //new
                        $md = $data['params'];
                        $md['uuid'] = $value['uuid'];
                        $md['lang'] = $value['langs'];
                        switch ($value['iso']) {
                            case 'MD':
                                $md['md_standard'] = 0;
                                break;
                            case 'MS':
                            case 'MC':
                                $md['md_standard'] = 10;
                                break;
                            case 'DC':
                                $md['md_standard'] = 1;
                                break;
                            case 'FC':
                                $md['md_standard'] = 2;
                                break;
                            default :
                                // error
                        }
                        $this->db->query("INSERT INTO edit_md", $md);
                    }
                    $this->seMdValues($data['md_values'][$key], $md['recno']);
                    $this->setRecordMdById($md['uuid'], 'edit_md', 'new');
                    $this->recordMd->pxml = $this->xmlFromRecordMdValues();
                    $this->applyXslTemplate2Xml('micka2one19139.xsl');
                    $this->updateEditMD($this->recordMd->recno);
                }
            }
        } elseif (array_key_exists('report', $data)) {
            throw new \Nette\Application\ApplicationException(
                'messages.import.incompletInputData');
        }
    }

    private function setNewEditMdRecord($httpRequest)
    {
        $post = $httpRequest->getPost();
        $md = [];
        $md['sid'] = session_id();
		$md['recno'] = $this->getNewRecno('edit_md');
        $md['uuid'] = $this->getUuid();
		$md['md_standard'] = isset($post['standard']) ? $post['standard'] : 0;
        $md['lang'] = isset($post['standard']) ? $post['standard'] : 0;
		$md['data_type'] = -1;
		$md['create_user'] = $this->user->identity->username;
		$md['create_date'] = Date("Y-m-d");
        $md['edit_group'] = isset($post['group_e']) ? $post['group_e'] : $this->user->identity->username;
        $md['view_group'] = isset($post['group_v']) ? $post['group_v'] : $this->user->identity->username;
        $lang_main = (isset($post['lang_main']) && $post['lang_main'] != '') ? $post['lang_main'] : 'eng';
        $md['lang'] = isset($post['languages']) ? implode($post['languages'],"|") : '';
        if ($md['lang'] == '' && $lang_main != '') {
            $md['lang'] = $lang_main;
        }
        if ($md['md_standard'] == 99) {
            $params = [];
            $params['file_type'] = (isset($post['fileType']) && $post['fileType'] != '') ? $post['fileType'] : 'ISO19139';
            $params['md_rec'] = (isset($post['md_rec']) && $post['md_rec'] != '') ? $post['md_rec'] : '';
            $params['fc'] = (isset($post['fc']) && $post['fc'] != '') ? $post['fc'] : '';
            $params['service_type'] = (isset($post['serviceType']) && $post['serviceType'] != '') ? $post['serviceType'] : 'WMS';
            $params['url'] = (isset($post['url']) && $post['url'] != '') ? $post['url'] : '';
            $params['url'] = ($params['url'] != '') ? str_replace('&amp;','&',$params['url']) : '';
            $params['update_type'] = (isset($post['updateType']) && $post['updateType'] != '') ? $post['updateType'] : 'skip';
            $files = $httpRequest->getFiles();
            if (isset($files['soubor']) &&  count($files['soubor']) > 1) {
                foreach ($files as $file) {
                    if ($file->isOk()) {
                        $fileName = __DIR__ . '/../../temp/upload/' . md5(uniqid(rand(), true)) . '.xml';
                        $file->move($fileName);
                        $mdXml2Array = new MdXml2Array();
                        $dataFromXml = $mdXml2Array->getArrayMdFromXml(
                            file_get_contents($fileName), 
                            $params['file_type'],
                            $md['lang'],
                            $lang_main
                        );
                        $arrayMdXml2MdValues = new ArrayMdXml2MdValues($this->db, $this->user);
                        $arrayMdXml2MdValues->lang = $lang_main;
                        $this->setMdFromXml(['params'=>$md+$params]+$arrayMdXml2MdValues->getMdFromArrayXml($dataFromXml));
                    } else {
                        throw new \Nette\Application\ApplicationException(
                            'messages.import.errorFile');
                    }
                }
            } elseif ($params['url'] != '') {
                $mdXml2Array = new MdXml2Array();
                $dataFromXml = $mdXml2Array->getArrayMdFromUrl(
                    $params['url'], 
                    $params['service_type'],
                    $md['lang'],
                    $lang_main
                );
                $arrayMdXml2MdValues = new ArrayMdXml2MdValues($this->db, $this->user);
                $arrayMdXml2MdValues->lang = $lang_main;
                $this->setMdFromXml(['params'=>$md+$params]+$arrayMdXml2MdValues->getMdFromArrayXml($dataFromXml));
            } else {
                // empty
            }
             exit;
            return;
	    }
        $this->db->query("INSERT INTO edit_md", $md);
		if ($md['md_standard'] == 0 || $md['md_standard'] == 10) {
            $this->db->query("INSERT INTO edit_md_values", [
                [
                'recno'=>$md['recno'],
                'md_value'=>$md['uuid'],
                'md_id'=>38,
                'md_path'=>'0_0_38_0',
                'lang'=>'xxx',
                'package_id'=>0
                ], [
                'recno'=>$md['recno'],
                'md_value'=>$lang_main,
                'md_id'=>5527,
                'md_path'=>'0_0_39_0_5527_0',
                'lang'=>'xxx',
                'package_id'=>0
                ], [
                'recno'=>$md['recno'],
                'md_value'=>Date("Y-m-d"),
                'md_id'=>44,
                'md_path'=>'0_0_44_0',
                'lang'=>'xxx',
                'package_id'=>0
                ]
            ]);
		}
        $this->setRecordMdById($md['uuid'], 'edit_md','new');
        $this->recordMd->pxml = $this->xmlFromRecordMdValues();
        $this->applyXslTemplate2Xml('micka2one19139.xsl');
        $this->updateEditMD($this->recordMd->recno);
        return;
    }
    
    public function findMdById($id, $typeTableMd, $right)
    {
        $this->setRecordMdById($id, $typeTableMd, $right);
        return $this->recordMd;
    }
    
    public function getRecordMd()
    {
        return $this->recordMd;
    }
    
    public function getRecordMdValues()
    {
        $this->setRecordMdValues();
        return $this->recordMdValues;
    }
    
	public function deleteEditRecords()
	{
        $this->db->query('DELETE FROM edit_md_values WHERE recno IN(SELECT recno FROM edit_md WHERE sid=?)', session_id());
        $this->db->query('DELETE FROM edit_md WHERE sid=?', session_id());
        return;
	}
    
    public function getMdTitle($lang)
    {
        if ($this->recordMd === NULL) {
            return '';
        }
        $title_app = '';
        $title_eng = '';
        $title_other = '';
        foreach ($this->recordMdValues as $row) {
            if ($row->md_id == 11) {
                $title_other = $row->md_value;
                if ($row->lang == $lang) {
                    $title_app = $row->md_value;
                }
                if ($row->lang == 'eng') {
                    $title_eng = $row->md_value;
                }
            }
        }
        if ($title_app != '') {
            $rs = $title_app;
        } elseif ($title_eng != '') {
            $rs = $title_eng;
        } else {
            $rs = $title_other;
        }
        return $rs;
    }

    public function copyMd2EditMd($mode='edit')
    {
        $this->deleteEditRecords();
        $id = '';
        if ($this->recordMd) {
            if ($mode == 'clone') {
                if ($this->isRight2MdRecord('read')) {
                    $id = $this->getUuid();
                    $editRecno = $this->getNewRecno('edit_md');
                    $this->db->query("
                        INSERT INTO edit_md (sid,recno,uuid,md_standard,lang,data_type,create_user,create_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid)
                        SELECT ?,?,?,md_standard,lang,-1,?,?,?,?,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid
                        FROM md WHERE recno=?"
                        , session_id(), $editRecno, $id, $this->user->identity->username, Date("Y-m-d"),
                            $this->user->identity->username, $this->user->identity->username, $this->recordMd->recno);
                    $this->db->query("
                        INSERT INTO edit_md_values (recno, md_id, md_value, md_path, lang , package_id)
                        SELECT ?, md_id, md_value, md_path, lang , package_id 
                        FROM md_values WHERE recno=?"
                        , $editRecno, $this->recordMd->recno);
                }
            } elseif ($this->isRight2MdRecord('write')) {
                $id = $this->recordMd->uuid;
                $editRecno = $this->getNewRecno('edit_md');
                $this->db->query("
                    INSERT INTO edit_md (sid,recno,uuid,md_standard,lang,data_type,create_user,create_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid)
                    SELECT ?,?,uuid,md_standard,lang,data_type,create_user,create_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid
                    FROM md WHERE recno=?"
                    , session_id(), $editRecno, $this->recordMd->recno);
                $this->db->query("
                    INSERT INTO edit_md_values (recno, md_id, md_value, md_path, lang , package_id)
                    SELECT ?, md_id, md_value, md_path, lang , package_id 
                    FROM md_values WHERE recno=?"
                    , $editRecno, $this->recordMd->recno);
            }
        }
        return $id;
    }
    
	public function deleteMdById($id)
	{
        $this->setRecordMdById($id, 'md', 'write');
        if ($this->recordMd) {
            $this->db->query("DELETE FROM md_values WHERE recno =?", $this->recordMd->recno);
            $this->db->query("DELETE FROM md WHERE recno=?", $this->recordMd->recno);
        }
        return;
	}
    
    public function createNewMdRecord($httpRequest)
    {
        $this->deleteEditRecords();
        return $this->setNewEditMdRecord($httpRequest);
    }
    
    private function getMdValuesFromForm($formData, $appLang)
    {
        $editMdValues = [];
		foreach ($formData as $key => $value) {
			if ( $key == 'nextpackage' ||
				 $key == 'nextprofil' ||
				 $key == 'afterpost' ||
				 $key == 'data_type' ||
				 $key == 'edit_group' ||
				 $key == 'view_group' ||
				 $key == 'uuid' ||
				 $key == 'ende') {
				continue;
			}
			if ($key == 'package') {
                $this->package_id = is_numeric($value) ? (int)$value : -1;
				continue;
			}
			if ($key == 'profil') {
                $this->profil_id =  is_numeric($value) ? (int) $value : -1;
				continue;
			}
			if ($value != '') {
				if (strpos($key, 'RB_') !== FALSE) {
					continue;
				}
				$pom = explode('|', $key);
				//form_code|lang|package_id|md_path
				if (count($pom) != 4) {
					continue;
				}
                if ($pom[0] == 'R') {
                    continue;
                }
                if ($pom[0] == 'D' && $appLang == 'cze') {
                    // ISO date
                    $value = dateCz2Iso($value);
                }
                $data = array();
                $data['recno'] = $this->recordMd->recno;
                $data['md_value'] = trim($value);
                $data['md_id'] = getMdIdFromMdPath($pom[3]);
                $data['md_path'] = $pom[3];
                $data['lang'] = $pom[1];
                $data['package_id'] = $pom[2];
                if ($data['recno'] != '' &&
                        $data['md_value'] != '' &&
                        $data['md_id'] != '' &&
                        $data['md_path'] != '' &&
                        $data['lang'] != '' &&
                        $data['package_id'] != '') {
                    array_push($editMdValues, $data);
                }
			}
		}
		return $editMdValues;
    }


    public function setFormMdValues($id, $post, $appLang)
    {
        $mdr = $this->findMdById($id, 'edit_md', 'edit');
        if (!$mdr) {
            // Error
        }
        if (array_key_exists('fileIdentifier_0_TXT', $post)) {
            // Micka Lite
    		require(__DIR__ . '/CswClient.php');
        	require(__DIR__ . '/lite/resources/Kote.php');
            require(__DIR__ . '/micka_lib_php5.php');
            $cswClient = new CSWClient();
            $input = Kote::processForm(beforeSaveRecord($post));
            $params = Array('datestamp'=>date('Y-m-d'), 'lang'=>'cze');
            $xmlstring = $cswClient->processTemplate($input, WWW_DIR . '/lite/resources/kote2iso.xsl', $params);
            $importer = new MetadataImport();
            $importer->setTableMode('tmp');
            $md = array();
            $md['file_type'] = 'WMS';
            $md['edit_group'] = MICKA_USER;
            $md['view_group'] = MICKA_USER;
            $md['mds'] = 0;
            $md['lang'] = 'cze';
            $lang_main = 'cze';
            $md['update_type'] = 'lite';
            $report = $importer->import(
                            $xmlstring,
                            'WMS',
                            MICKA_USER,
                            $md['edit_group'],
                            $md['view_group'],
                            $md['mds']=0, // co to je?
                            $md['lang'], // co to je?
                            $lang_main,
                            $params=false,
                            $md['update_type']
            );
        } else {
            $editMdValues = $this->getMdValuesFromForm($post, $appLang);
            $this->deleteEditMdValuesByProfil(
                    $this->recordMd->recno,
                    $this->recordMd->md_standard, 
                    $this->profil_id, 
                    $this->package_id);
            $this->seMdValues($editMdValues);
            $this->recordMd->pxml = $this->xmlFromRecordMdValues();
            $this->applyXslTemplate2Xml('micka2one19139.xsl');
            $this->updateEditMD($this->recordMd->recno);
        }
        return;
    }
    
	private function getIdElements()
    {
        // Move to CodeListModel
        $data = $this->db->query("SELECT standard_schema.md_id, standard_schema.md_standard, elements.el_name
            FROM elements JOIN standard_schema ON (elements.el_id = standard_schema.el_id)")->fetchAll();
		$rs = [];
        foreach ($data as $row) {
			$mds = $row->md_standard;
			$id = $row->md_id;
			$rs[$mds][$id] = $row->el_name;
		}
		return $rs;
	}
    
    private function xmlFromRecordMdValues()
    {
        if (!$this->recordMd) {
            return '';
        }
        $this->setRecordMdValues();
        $elements_label = $this->getIdElements();
		$eval_text = '';
        $i = 0;
        $mds = $this->recordMd->md_standard == 10 ? 0 : $this->recordMd->md_standard;
		foreach ($this->recordMdValues as $row) {
            $path_arr = explode('_', substr($row->md_path, 0, strlen($row->md_path) - 1));
            $eval_text_tmp = '$vysl';
            foreach ($path_arr as $key=>$value) {
                if ($key%2 == 0) {
                    $eval_text_tmp .= "['" . $elements_label[$mds][$value] . "']";
                }
                else {
                    $eval_text_tmp .= '[' . $value . ']';
                }
            }
            if ($row->md_id == 4742) {
                $eval_text_value = $eval_text_tmp . "['lang'][$i]['@value']=" . '"' . gpc_addslashes($row->md_value) . '";' . "\n";
                $eval_text_atrrib = $eval_text_tmp . "['lang'][$i]['@attributes']['code']=" . '"' . $row->lang . '";' . "\n";
                $i++;
                $eval_text_tmp = $eval_text_value . $eval_text_atrrib;
            } elseif ($row->lang != 'xxx') {
                $eval_text_value = $eval_text_tmp . "['lang'][$i]['@value']=" . '"' . gpc_addslashes($row->md_value) . '";' . "\n";
                $eval_text_atrrib = $eval_text_tmp . "['lang'][$i]['@attributes']['code']=" . '"' . $row->lang . '";' . "\n";
                $i++;
                $eval_text_tmp = $eval_text_value . $eval_text_atrrib;
            } else {
                $eval_text_tmp .= '="' . gpc_addslashes($row->md_value) . '";' . "\n";
            }
            $eval_text .= $eval_text_tmp;
        }
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0]."'][0]['@attributes']['uuid']='".rtrim($this->recordMd->uuid)."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0]."'][0]['@attributes']['langs']='".(substr_count($this->recordMd->lang,'|')+1)."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0]."'][0]['@attributes']['updated']='".$this->recordMd->create_date."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0]."'][0]['@attributes']['x1']='".$this->recordMd->x1."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0]."'][0]['@attributes']['x2']='".$this->recordMd->x2."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0]."'][0]['@attributes']['y1']='".$this->recordMd->y1."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0]."'][0]['@attributes']['y2']='".$this->recordMd->y2."';\n";
        eval ($eval_text);
		$xml = \Array2XML::createXML('rec', $vysl);
        //echo $xml->saveXML(); die;
        return $xml->saveXML();
    }
    
    private function applyXslTemplate2Xml($xsltemplate)
    {
        $xml = $this->recordMd->pxml;
        if ($xsltemplate != '' && $xml != '') {
            $xml = applyTemplate($xml, $xsltemplate, $this->user->identity->username);
            if ($xml != '') {
                $this->recordMd->pxml = $xml;
            }
        }
		return;
    }
}
