<?php

namespace App\Model;

use Nette;


class RecordModel extends \BaseModel
{
    private $appParameters;
    private $recordMd = NULL;
    private $recordMdValues = [];
    private $typeTableMd = 'edit_md';
    private $geomMd = [];
    private $titleMd = [];
    private $langMd = NULL;
    private $profil_id = -1;
    private $package_id = -1;
    
    public function setAppParameters($appParameters)
    {
        $this->appParameters = $appParameters;
    }
    
    private function initialVariables() {
        $this->geomMd['x1'] = NULL;
        $this->geomMd['x2'] = NULL;
        $this->geomMd['y1'] = NULL;
        $this->geomMd['y2'] = NULL;
        $this->geomMd['poly'] = NULL;
        $this->geomMd['dc_geom'] = NULL;
        $this->titleMd['title'] = NULL;
        $this->titleMd['title_lang_main'] = NULL;
    }
    private function setRecordMdById($id, $typeTableMd, $right)
    {
        if ($id == '') {
            $this->recordMd = NULL;
            return;
        }
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
                "SELECT * FROM $table WHERE recno=? ORDER BY md_path", $this->recordMd->recno)->fetchAll();
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
            case 'edit':
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
        $data = [];
        $data['data_type'] = $this->recordMd->data_type; 
        $data['edit_group'] = $this->recordMd->edit_group; 
        $data['view_group'] = $this->recordMd->view_group;
        $data['last_update_user'] = $this->user->identity->username;
        $data['last_update_date'] = Date("Y-m-d");
        if ($this->langMd !== NULL) {
            $data['lang'] = $this->langMd; 
        }
        $this->setGeomMd2recordMd();    
        $data['x1'] = $this->recordMd->x1 != '' ? $this->recordMd->x1 : NULL;
        $data['x2'] = $this->recordMd->x2 != '' ? $this->recordMd->x2 : NULL;
        $data['y1'] = $this->recordMd->y1 != '' ? $this->recordMd->y1 : NULL;
        $data['y2'] = $this->recordMd->y2 != '' ? $this->recordMd->y2 : NULL;
        $this->setTitleMd2recordMd();
        $data['title'] = $this->recordMd->title != '' ? $this->recordMd->title : NULL;
        //$data['range_begin'] = $this->recordMd->range_begin != '' ? $this->recordMd->range_begin : NULL;
        //$data['range_end'] = $this->recordMd->range_end != '' ? $this->recordMd->range_end : NULL;
        //$data['md_update'] = $this->recordMd->md_update != '' ? $this->recordMd->md_update : NULL;
        //$data['valid'] = $this->recordMd->valid != '' ? $this->recordMd->valid : NULL;
        //$data['prim'] = $this->recordMd->prim != '' ? $this->recordMd->prim : NULL;
        $this->db->query('UPDATE edit_md SET ? WHERE sid=? AND recno=?', $data, session_id(), $recno);
        $x1 = $data['x1'];
        $x2 = $data['x2'];
        $y1 = $data['y1'];
        $y2 = $data['y2'];
        if ($this->recordMd->the_geom != '') {
            $this->db->query("UPDATE edit_md SET the_geom=ST_GeomFromText(?,0)
                    WHERE sid='".session_id()."' AND recno=?", $this->recordMd->the_geom, $recno);
        } elseif ($x1 != NULL && $x2 != NULL && $y1 != NULL && $y2 != NULL) {
            $this->db->query("UPDATE edit_md SET 
                    the_geom=ST_GeomFromText('MULTIPOLYGON((($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1)))',0)
                    WHERE sid='".session_id()."' AND recno=?", $recno);
        }
        $xml = $this->recordMd->pxml == '' ? NULL : str_replace("'", "&#39;", $this->recordMd->pxml);
        $this->db->query("UPDATE edit_md SET pxml=XMLPARSE(DOCUMENT ?)
                WHERE sid='".session_id()."' AND recno=?", $xml, $recno);
    }
    
    private function setEditMd2Md($editRecno, $recno)
    {
        // validate
        if ($this->appParameters['app']['validator'] === true) {
            $this->recordValidate($this->recordMd->pxml);
            $this->db->query("UPDATE edit_md SET valid=?, prim=? WHERE sid='".session_id()."' AND recno=?",
                $this->recordMd->valid, $this->recordMd->prim, $editRecno);
        }
        
        $mdRecno = NULL;
        if ($recno == 0) {
            $mdRecno = $this->getNewRecno('md');
            $this->db->query("
                INSERT INTO md (recno,uuid,md_standard,lang,data_type,create_user,create_date,last_update_user,last_update_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid)
                SELECT ?,uuid,md_standard,lang,data_type,create_user,create_date,last_update_user,last_update_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid
                FROM edit_md WHERE recno=?"
                , $mdRecno, $editRecno);
        } else {
            $sql = "UPDATE md SET 
                        last_update_user=edit.last_update_user,
                        last_update_date=edit.last_update_date,
                        pxml=edit.pxml,
                        lang=edit.lang,
                        data_type=edit.data_type,
                        edit_group=edit.edit_group, view_group=edit.view_group,
                        x1=edit.x1, y1=edit.y1, x2=edit.x2, y2=edit.y2, the_geom=edit.the_geom,
                        range_begin=edit.range_begin, range_end=edit.range_end,
                        md_update=edit.md_update,
                        title=edit.title,
                        valid=edit.valid,
                        prim=edit.prim
                    FROM edit_md edit
                    WHERE edit.recno=? AND md.recno=? AND edit.sid='".session_id()."'";
            $this->db->query($sql,$editRecno,$recno);
        }
        return $mdRecno;
    }

    private function recordValidate($xml)
    {
        $this->recordMd->valid = 0;
        $this->recordMd->prim = 0;
        require_once __DIR__ . '/validator/resources/Validator.php';
        $validator = new \Validator();
        $validator->run($xml);
        $vResult = $validator->getPass();
        if ($vResult) {
            if ($vResult['fail'] == 0) {
                $this->recordMd->valid = $vResult['warn'] > 0 ? 1 : 2;
            }
            $this->recordMd->prim = $vResult['primary'];
        }
    }
    
    private function deleteMdValues($recno) {
        $this->db->query("DELETE FROM md_values WHERE recno=?", $recno);
        return;
    }
    
    private function deleteEditMdValuesByProfil($editRecno, $mds, $profil_id, $package_id) {
        $sql = "DELETE FROM edit_md_values WHERE recno=?";
		if ($mds == 0 || $mds == 10) {
			$sql .= " AND md_id<>38";
            if ($profil_id > -1) {
                $sql .= " AND md_id IN(
                    SELECT standard_schema.md_id 
                    FROM standard_schema INNER JOIN elements ON elements.el_id = standard_schema.el_id
                    WHERE standard_schema.md_standard=0 AND elements.form_ignore=0 
                    AND standard_schema.md_id IN(SELECT md_id FROM profil WHERE profil_id=$profil_id))";
            }
		}
        if ($package_id > -1) {
            $sql .= " AND package_id=$package_id";
        }
        $this->db->query($sql, $editRecno);
        return;
    }

    private function deleteEditMdValuesByLite($editRecno, $mds, $del_md_id,$table='edit_md_values') {
		if ($mds == 0 || $mds == 10) {
            if (isset($del_md_id[38])) {
                unset($del_md_id[38]);
            }
		}
        $sql = "DELETE FROM $table WHERE recno=? AND md_id IN (?)";
        $this->db->query($sql, $editRecno, array_keys($del_md_id));
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
        $this->setRecordMdById($this->recordMd->uuid, 'md', 'edit');
        if ($this->recordMd) {
            $this->deleteMdValues($this->recordMd->recno);
            $this->setEditMdValues2MdValues($editRecno, $this->recordMd->recno);
            $this->setEditMd2Md($editRecno, $this->recordMd->recno);
        } else {
            $recno = $this->setEditMd2Md($editRecno, 0);
            $this->setEditMdValues2MdValues($editRecno, $recno);
        }
    }
    
    private function insertMdValuesBasic($md_standard, $recno, $uuid=NULL,$lang=NULL,$date=FALSE) {
		if ($md_standard == 0 || $md_standard == 10) {
            $values = [];
            if ($uuid !== NULL) {
                $values[] = [
                    'recno'=>$recno,
                    'md_value'=>$uuid,
                    'md_id'=>38,
                    'md_path'=>'0_0_38_0_',
                    'lang'=>'xxx',
                    'package_id'=>0
                ];
            }
            if ($lang !== NULL) {
                $values[] = [
                    'recno'=>$recno,
                    'md_value'=>$lang,
                    'md_id'=>5527,
                    'md_path'=>'0_0_39_0_5527_0_',
                    'lang'=>'xxx',
                    'package_id'=>0
                ];
            }
            if ($date === TRUE) {
                $values[] = [
                    'recno'=>$recno,
                    'md_value'=>Date("Y-m-d"),
                    'md_id'=>44,
                    'md_path'=>'0_0_44_0_',
                    'lang'=>'xxx',
                    'package_id'=>0
                ];
            }
            if (count($values) > 0) {
                $this->db->query("INSERT INTO edit_md_values", $values);
            }
		}
    }
    
    private function setMdFromXml($data, $log=FALSE) {
        $report = array();
        if (array_key_exists('params', $data)
            && array_key_exists('new_md', $data)
            && array_key_exists('md', $data)
            && array_key_exists('md_values', $data)
            && array_key_exists('del_md_id', $data)
        ) {
            foreach ($data['md'] as $key => $value) {
                if (isset($value['uuid'])) {
                    $report[$key]['uuid'] = $value['uuid'];
                    $report[$key]['ok'] = 0;
                    $report[$key]['title'] = '';
                    $this->setRecordMdById($value['uuid'], 'md', 'new');
                    if ($this->recordMd) {
                        $report[$key]['title'] = $this->recordMd->title;
                        //update
                        if ($this->isRight2MdRecord('edit') === FALSE) {
                            $this->recordMd = NULL;
                            if ($log) {
                                $report[$key]['report'] = 'No update rights.';
                                return $report;
                            } else {
                                throw new \Nette\Application\ApplicationException(
                                    'messages.import.notRightRecordUpdate');
                            }
                        }
                        if ($data['params']['update_type'] == 'all') {
                            $this->findMdById($this->copyMd2EditMd(),'edit_md','edit');
                            $md['recno'] = $this->recordMd->recno;
                            $md['uuid'] = rtrim($this->recordMd->uuid);
                            $this->deleteEditMdValuesByLite(
                                    $this->recordMd->recno, 
                                    $this->recordMd->md_standard, 
                                    $data['del_md_id'][$key]
                            );
                        } else {
                            // skip
                            if ($log) {
                                $report[$key]['report'] = 'Record exists, import cancelled.';
                                return $report;
                            } else {
                                throw new \Nette\Application\ApplicationException(
                                    'messages.import.recordUpdateSkip');
                            }
                        }
                    } else {
                        //new
                        $md = $data['new_md'];
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
                        if ($value['uuid'] != '') {
                            $md['uuid'] = $value['uuid'];
                        } else {
                            $this->insertMdValuesBasic($md['md_standard'], $md['recno'], $md['uuid'],NULL,TRUE);
                        }
                        $this->db->query("INSERT INTO edit_md", $md);
                    }
                    $this->seMdValues($data['md_values'][$key], $md['recno']);
                    $this->setRecordMdById($md['uuid'], 'edit_md', 'new');
                    $this->recordMd->pxml = $this->xmlFromRecordMdValues();
                    $this->applyXslTemplate2Xml('micka2one19139.xsl');
                    foreach ($data['md_values'][$key] as $row) {
                        $this->setValue2RecorMd($row);
                    }
                    $this->updateEditMD($this->recordMd->recno);
                    $report[$key]['ok'] = 1;
                    $report[$key]['title'] = $this->recordMd->title;
                }
            }
        } elseif (array_key_exists('report', $data)) {
            if ($log) {
                $report[$key]['report'] = 'incompletInputData';
                return $report;
            } else {
                throw new \Nette\Application\ApplicationException(
                    'messages.import.incompletInputData');
            }
        }
        return $report;
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
            $params['type'] = (isset($post['type']) && $post['type'] != '') ? $post['type'] : 'ISO19139';
            $params['md_rec'] = (isset($post['md_rec']) && $post['md_rec'] != '') ? $post['md_rec'] : '';
            $params['fc'] = (isset($post['fc']) && $post['fc'] != '') ? $post['fc'] : '';
            //$params['service_type'] = (isset($post['serviceType']) && $post['serviceType'] != '') ? $post['serviceType'] : 'WMS';
            $params['url'] = (isset($post['url']) && $post['url'] != '') ? $post['url'] : '';
            $params['url'] = ($params['url'] != '') ? str_replace('&amp;','&',$params['url']) : '';
            $params['update_type'] = (isset($post['updateType']) && $post['updateType'] != '') ? $post['updateType'] : 'skip';
            $files = $httpRequest->getFiles();
            if (isset($files['soubor']) &&  count($files['soubor']) > 0) {
                foreach ($files as $file) {
                    if ($file->isOk()) {
                        $fileName = __DIR__ . '/../../temp/upload/' . md5(uniqid(rand(), true)) . '.xml';
                        $file->move($fileName);
                        $mdXml2Array = new MdXml2Array();
                        $dataFromXml = $mdXml2Array->importXml(
                            file_get_contents($fileName), 
                            $params['type'],
                            $md['lang'],
                            $lang_main
                        );
                        $arrayMdXml2MdValues = new ArrayMdXml2MdValues($this->db, $this->user);
                        $arrayMdXml2MdValues->lang = $lang_main;
                        $this->setMdFromXml(['new_md' => $md]
                                + ['params' => $params]
                                + $arrayMdXml2MdValues->getMdFromArrayXml($dataFromXml)
                        );
                    } else {
                        throw new \Nette\Application\ApplicationException(
                            'messages.import.errorFile');
                    }
                }
            } elseif ($params['url'] != '') {
                $mdXml2Array = new MdXml2Array();
                $dataFromXml = $mdXml2Array->getArrayMdFromUrl(
                    $params['url'], 
                    $params['type'],
                    $md['lang'],
                    $lang_main
                );
                $arrayMdXml2MdValues = new ArrayMdXml2MdValues($this->db, $this->user);
                $arrayMdXml2MdValues->lang = $lang_main;
                $this->setMdFromXml(['new_md' => $md]
                        + ['params' => $params]
                        + $arrayMdXml2MdValues->getMdFromArrayXml($dataFromXml)
                );
            } else {
                // empty
            }
            return;
	    }
        $this->db->query("INSERT INTO edit_md", $md);
        $this->insertMdValuesBasic($md['md_standard'], $md['recno'], $md['uuid'], $lang_main,TRUE);
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
            } elseif ($this->isRight2MdRecord('edit')) {
                $id = $this->recordMd->uuid;
                $editRecno = $this->getNewRecno('edit_md');
                $this->db->query("
                    INSERT INTO edit_md (sid,recno,uuid,md_standard,lang,data_type,create_user,create_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid)
                    SELECT ?,?,uuid,md_standard,lang,data_type,create_user,create_date,edit_group,view_group,x1,y1,x2,y2,the_geom,range_begin,range_end,md_update,title,server_name,pxml,valid
                    FROM md WHERE recno=?"
                    , session_id(), $editRecno, $this->recordMd->recno
                );
                $this->db->query("
                    INSERT INTO edit_md_values (recno, md_id, md_value, md_path, lang , package_id)
                    SELECT ?, md_id, md_value, md_path, lang , package_id 
                    FROM md_values WHERE recno=?"
                    , $editRecno, $this->recordMd->recno
                );
            }
        }
        return $id;
    }
    
	public function deleteMdById($id)
	{
        $this->setRecordMdById($id, 'md', 'edit');
        if ($this->recordMd) {
            $this->db->query("DELETE FROM md_values WHERE recno =?", $this->recordMd->recno);
            $this->db->query("DELETE FROM md WHERE recno=?", $this->recordMd->recno);
        }
        return;
	}
    
    public function createNewMdRecord($httpRequest)
    {
        $this->initialVariables();
        $this->deleteEditRecords();
        return $this->setNewEditMdRecord($httpRequest);
    }
    
    private function setGeomMd2recordMd() {
        $x1 = $this->geomMd['x1'];
        $x2 = $this->geomMd['x2'];
        $y1 = $this->geomMd['y1'];
        $y2 = $this->geomMd['y2'];
        $poly = $this->geomMd['poly'];
        $dc_geom = $this->geomMd['dc_geom'];
        
        $rs = array();
        $rs['x1'] = NULL;
        $rs['x2'] = NULL;
        $rs['y1'] = NULL;
        $rs['y2'] = NULL;
        $rs['the_geom'] = NULL;
        if ($x1 != '' && $x2 != '' && $y1 != '' && $y2 !='') {
            $rs['x1'] = $x1;
            $rs['x2'] = $x2;
            $rs['y1'] = $y1;
            $rs['y2'] = $y2;
        } elseif($poly != '') {
            $pom = str_replace("MULTIPOLYGON(((", "", $poly);
            $pom = str_replace(")", "", $pom);
            $pom = str_replace("(", "", $pom);
            $apoly = explode(",", $pom);
            $pom = explode(" ", $apoly[0]);
            $x2 = $pom[0];
            $x1 = $x2;
            $y2 = $pom[1];
            $y1 = $y2;
            foreach ($apoly as $bod) {
                $pom = explode(" ", $bod);
                $x1 = min($x1, $pom[0]);
                $x2 = max($x2, $pom[0]);
                $y1 = min($y1, $pom[1]);
                $y2 = max($y2, $pom[1]);
            }
            $rs['x1'] = $x1;
            $rs['x2'] = $x2;
            $rs['y1'] = $y1;
            $rs['y2'] = $y2;
            $rs['the_geom'] = $poly;
        } elseif($dc_geom != '') {
            $pom = explode(';',$dc_geom);
            if (count($pom) == 4) {
                foreach ($pom as $value) {
                    if (strpos('a'.$value,'westlimit:') > 0) {
                        $x1 =ltrim(strstr($value,":"),":");
                    }
                    elseif (strpos('a'.$value,'eastlimit:') > 0) {
                        $x2 = ltrim(strstr($value,":"),":");
                    }
                    elseif (strpos('a'.$value,'southlimit:') > 0) {
                        $y1 = ltrim(strstr($value,":"),":");
                    }
                    elseif (strpos('a'.$value,'northlimit:') > 0) {
                        $y2 = ltrim(strstr($value,":"),":");
                    }
                    if ($x1 != '' && $x2 != '' && $y1 != '' && $y2 !='') {
                        $rs['x1'] = $x1;
                        $rs['x2'] = $x2;
                        $rs['y1'] = $y1;
                        $rs['y2'] = $y2;
                    }
                }
            }
        }
        $this->recordMd->x1 = $rs['x1'];
        $this->recordMd->x2 = $rs['x2'];
        $this->recordMd->y1 = $rs['y1'];
        $this->recordMd->y2 = $rs['y2'];
        $this->recordMd->the_geom = $rs['the_geom'];
    }
    
    private function setMdTitle($data) {
        $this->titleMd['title'] = $data['md_value'];
    }
    
    private function setTitleMd2recordMd() {
        $this->recordMd->title = $this->titleMd['title_lang_main'] 
                ? $this->titleMd['title_lang_main'] 
                : $this->titleMd['title'];
    }
    
    private function setValue2RecorMd($data) {
        switch ($this->recordMd->md_standard) {
            case 0:
                if ($data['md_id'] == 497) {
                    $this->geomMd['x1'] = $data['md_value'];
                }
                if ($data['md_id'] == 498) {
                    $this->geomMd['x2'] = $data['md_value'];
                }
                if ($data['md_id'] == 499) {
                    $this->geomMd['y1'] = $data['md_value'];
                }
                if ($data['md_id'] == 500) {
                    $this->geomMd['y2'] = $data['md_value'];
                }
                if ($data['md_id'] == 503) {
                    $this->geomMd['poly'] = $data['md_value'];
                }
                if ($data['md_id'] == 11) {
                    $this->setMdTitle($data);
                }
                break;
            case 10:
                if ($data['md_id'] == 5133) {
                    $this->geomMd['x1'] = $data['md_value'];
                }
                if ($data['md_id'] == 5134) {
                    $this->geomMd['x2'] = $data['md_value'];
                }
                if ($data['md_id'] == 5135) {
                    $this->geomMd['y1'] = $data['md_value'];
                }
                if ($data['md_id'] == 5136) {
                    $this->geomMd['y2'] = $data['md_value'];
                }
                if ($data['md_id'] == 5140) {
                    $this->geomMd['poly'] = $data['md_value'];
                }
                if ($data['md_id'] == 5063) {
                    $this->setMdTitle($data);
                }
                break;
            case 1:
                if ($data['md_id'] == 14) {
                    $this->geomMd['dc_geom'] = $data['md_value'];
                }
                if ($data['md_id'] == 11) {
                    $this->setMdTitle($data);
                }
                break;
            case 2:
                if ($data['md_id'] == 11) {
                    $this->setMdTitle($data);
                }
                break;
            default:
                break;
        }
    }
    
    private function getMdValuesFromForm($formData, $appLang)
    {
        $this->initialVariables();
        
        $editMdValues = [];
		foreach ($formData as $key => $value) {
			if ( $key == 'nextpackage' ||
				 $key == 'nextprofil' ||
				 $key == 'afterpost' ||
				 $key == 'uuid' ||
				 $key == 'ende') {
				continue;
			}
			if ($key == 'data_type') {
                $this->recordMd->data_type = $value;
				continue;
			}
			if ($key == 'edit_group') {
                $this->recordMd->edit_group = $value;
				continue;
			}
			if ($key == 'view_group') {
                $this->recordMd->view_group = $value;
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
                    $this->setValue2RecorMd($data);
                }
			}
		}
		return $editMdValues;
    }
    
    private function setLang2RecordMd($select_langs) {
        $md_langs = explode('|', $this->recordMd->lang);
        $common_langs = array_intersect($md_langs, $select_langs);
        if (count($common_langs) === 0) {
            return ['message' => '0 lang', 'type' => 'error'];
        }
        $add_langs = array_diff($select_langs, $common_langs);
        $del_langs = array_diff($md_langs, $select_langs);

        if (count($add_langs) === 0 && count($del_langs) === 0) {
            return [];
        }
        
        $report = [];
        if (count($add_langs) > 0) {
            $report = [
                'message' => 'add_langs:',
                'type' => 'info'
            ];
        }
        if (count($del_langs) > 0) {
            $report = [
                'message' => 'del_langs:',
                'type' => 'info'
            ];
        }
        $this->langMd = implode('|', $select_langs);
        return $report;
    }

    public function setXmlFromCsw($xml,$params=array()) {
        $mdXml2Array = new MdXml2Array();
        $dataFromXml = $mdXml2Array->xml2array($xml, __DIR__ ."/xsl/update2micka.xsl");
        $arrayMdXml2MdValues = new ArrayMdXml2MdValues($this->db, $this->user);
        $arrayMdXml2MdValues->lang = 'eng';
        $editMdValues = $arrayMdXml2MdValues->getMdFromArrayXml($dataFromXml);
        $md = array();
        $md['sid'] = session_id();
		$md['recno'] = $this->getNewRecno('edit_md');
		$md['data_type'] = isset($params['data_type'])
                ? $params['data_type']
                : -1;
		$md['create_user'] = $this->user->identity->username;
		$md['create_date'] = Date("Y-m-d");
        $md['edit_group'] = isset($params['edit_group'])
                ? $params['edit_group']
                : $this->user->identity->username;
        $md['view_group'] = isset($params['view_group'])
                ? $params['view_group']
                : $this->user->identity->username;
        if (isset($params['server_name']) && $params['server_name'] != '') {
            $md['server_name'] = $params['server_name'];
        }
        $report = $this->setMdFromXml(
            ['new_md' => $md] + ['params' => $params] + $editMdValues,
            TRUE
        );
        $this->setEditRecord2Md();
        $this->deleteEditRecords();
        return $report;
    }
    
    public function setFormMdValues($id, $post, $appLang)
    {
        $mdr = $this->findMdById($id, 'edit_md', 'edit');
        if (!$mdr) {
            throw new \Nette\Application\ApplicationException('messages.apperror.noRecordFound');
        }
        if (isset($post['select_langs'])) {
            $select_langs = $post['select_langs'];
            unset($post['select_langs']);
        } else {
            $select_langs = [];
        }
        if (array_key_exists('mickaLite', $post)) {
            //Micka Lite
            $this->initialVariables();
            $editMdValues = $this->setFromMickaLite($post);
            $this->deleteEditMdValuesByLite(
                    $this->recordMd->recno, 
                    $this->recordMd->md_standard, 
                    $editMdValues['del_md_id'][0]);
            $this->seMdValues($editMdValues['md_values'][0], $this->recordMd->recno);
            
        } else {
            $editMdValues = $this->getMdValuesFromForm($post, $appLang);
            $this->deleteEditMdValuesByProfil(
                    $this->recordMd->recno,
                    $this->recordMd->md_standard, 
                    $this->profil_id, 
                    $this->package_id);
            $this->seMdValues($editMdValues);
        }
        $report = $this->setLang2RecordMd($select_langs);
        $this->recordMd->pxml = $this->xmlFromRecordMdValues();
        //header('Content-Type: application/xml'); echo $this->recordMd->pxml;  exit;
        $this->applyXslTemplate2Xml('micka2one19139.xsl');
        $this->updateEditMD($this->recordMd->recno);
        return $report;
    }
    
    private function setFromMickaLite($post) {
		$cswClient = new \CswClient();
        $kote = new \Kote();
        $input = $kote->processForm(beforeSaveRecord($post));
        $params = Array(
            'datestamp'=>date('Y-m-d'), 
            'lang'=>$post['mdlang'], 
            'mickaURL'=> MICKA_URL
        );
        $mdXml2Array = new MdXml2Array();
        $xml = new \DomDocument;
        if(!$xml->loadXML($input)) die('Bad xml format');
        //header('Content-Type: application/xml'); echo $input;  exit;
        // TODO - here the lite profiles should be solved
        $dataFromXml = $mdXml2Array->xml2array($xml, __DIR__ . '/lite/profiles/kote-micka/form2iso.xsl', $params);
        //echo "<pre>"; var_dump($dataFromXml); die;
        $arrayMdXml2MdValues = new ArrayMdXml2MdValues($this->db, $this->user);
        $arrayMdXml2MdValues->lang = $post['mdlang'];
        return $arrayMdXml2MdValues->getMdFromArrayXml($dataFromXml);
    }
    
    private function getIdElements()
    {
        // Move to CodeListModel
        $data = $this->db->query("SELECT standard_schema.md_id, standard_schema.md_standard,
            (CASE WHEN standard_schema.md_right-standard_schema.md_left=1 THEN 1 ELSE 0 END) AS is_data,
            elements.el_name,
            standard_schema.is_uri
            FROM elements JOIN standard_schema ON (elements.el_id = standard_schema.el_id)")->fetchAll();
		$rs = [];
        foreach ($data as $row) {
			$rs[$row->md_standard][$row->md_id][0] = $row->el_name;
            $rs[$row->md_standard][$row->md_id][1] = $row->is_uri;
            $rs[$row->md_standard][$row->md_id]['is_data'] = $row->is_data;
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
            if ($elements_label[$mds][$row->md_id]['is_data'] === 0) {
                \Tracy\Debugger::log('md_id='.$row->md_id.', md_path='.$row->md_path, 'ERROR_MAKE_XML');
                continue;
            }
            $md_path = substr($row->md_path, strlen($row->md_path)-1, 1) != '_'
                ? substr($row->md_path . '_', 0, strlen($row->md_path . '_')-1)
                : substr($row->md_path, 0, strlen($row->md_path)-1);
            $path_arr = explode('_', $md_path);
            $eval_text_tmp = '$vysl';
            $data_error = 0;
            foreach ($path_arr as $key=>$value) {
                if ($key%2 == 0) {
                    $element_label = isset($elements_label[$mds][$value][0]) ? $elements_label[$mds][$value][0] : '';
                    if ($element_label == '') {
                        $data_error = 1;
                    }
                    $eval_text_tmp .= "['" . $element_label . "']";
                } else {
                    if ($value == '') {
                        $data_error = 1;
                    }
                    $eval_text_tmp .= '[' . $value . ']';
                }
            }
            if ($data_error === 1) {
                \Tracy\Debugger::log('(error md_path) md_id='.$row->md_id.', md_path='.$row->md_path, 'ERROR_MAKE_XML');
                continue;
            }
            $element_is_data = isset($elements_label[$mds][$row->md_id][1]) ? $elements_label[$mds][$row->md_id][1] : '';
            if ($element_is_data == 1 || $row->lang != 'xxx') {
                $eval_text_value = $eval_text_tmp . "['lang'][$i]['@value']=" . '"' . gpc_addslashes($row->md_value) . '";' . "\n";
                $eval_text_atrrib = $eval_text_tmp . "['lang'][$i]['@attributes']['code']=" . '"' . $row->lang . '";' . "\n";
                $i++;
                $eval_text_tmp = $eval_text_value . $eval_text_atrrib;
            } else {
                $eval_text_tmp .= '="' . gpc_addslashes($row->md_value) . '";' . "\n";
            }
            $eval_text .= $eval_text_tmp;
        }
        $eval_text .= getMdOtherLangs($this->recordMd->lang, 'xxx', '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['langs']");
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['@attributes']['uuid']='".rtrim($this->recordMd->uuid)."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['@attributes']['langs']='".(substr_count($this->recordMd->lang,'|')+1)."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['@attributes']['updated']='".$this->recordMd->create_date."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['@attributes']['x1']='".$this->recordMd->x1."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['@attributes']['x2']='".$this->recordMd->x2."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['@attributes']['y1']='".$this->recordMd->y1."';\n";
        $eval_text .= '$vysl' . "['".$elements_label[$mds][0][0]."'][0]['@attributes']['y2']='".$this->recordMd->y2."';\n";
        //\Tracy\Debugger::log($eval_text, 'ERROR_MAKE_XML');
        eval ($eval_text);
		$xml = \Array2XML::createXML('rec', $vysl);
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
