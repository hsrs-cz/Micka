<?php

namespace App\Model;

use Nette;


class SuggestModel
{
	use Nette\SmartObject;

	/** @var Nette\Database\Context */
	private $db;
    
    private $user;

	public function __construct(Nette\Database\Context $db) 
	{
		$this->db = $db;
	}
    
    public function setIdentity($user)
    {
        $this->user = $user;
    }
    
    public function getAnswer($params) {
        $rs = [];
        $org = array();
        $md_id = array();
        $recno = '';
        $orderBy = TRUE;

        $query_lang = isset($params['lang']) && $params['lang'] !== NULL ? $params['lang'] : '';
        $creator = isset($params['creator']) && $params['creator'] !== NULL ? $params['creator'] : '';
        $query = isset($params['query']) && $params['query'] !== NULL ? $params['query'] : '';
        $contact_type = isset($params['type']) && $params['type'] !== NULL ? $params['type'] : 'org';
        $contact_role = isset($params['role']) && $params['role'] !== NULL ? $params['role'] : '';

        $user = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
        $admin = $this->user->isInRole('admin');
        $group = $this->user->isLoggedIn() ? $this->user->getIdentity()->data['groups'] : ['guest'];
        $group = implode("','", array_values($group));
        $group = "'" . $group . "'";
        if ($admin === TRUE) {
            $right = 'md.data_type IS NOT NULL';
        } else {
            $right = $user == 'guest' 
                    ? 'md.data_type>0'
                    : "(md.create_user='$user' OR md.view_group IN($group) OR md.edit_group IN($group) OR md.data_type>0)";
        }

        switch ($contact_type) {
            case 'mdperson':
                $query_lang = '';
                $sql = "
                    SELECT md_values.recno, md_values.md_path, md_values.md_value, md_values.lang
                    FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTRING(md_values.md_path, 1,17)=SUBSTRING(m.md_path, 1,17) AND md_values.recno=m.recno)
                    WHERE 
                ";
                if($creator != '') {
                    if ($creator == $user) {
                        $sql .=  " md.create_user='$creator'";
                    } else {
                        $sql .= " md.create_user='$creator' AND (md.view_group IN($group) OR md.edit_group IN($group) OR md.data_type>0))";
                    }
                } else {
                    $sql .= " $right";
                }
                if($query != '') {
                    $sql .= " AND md_values.md_value ILIKE '%" . $query . "%'";
                }
                if($contact_role != '') {
                    $sql .=  " AND md_values.md_id=152 AND m.md_id=992 AND m.md_value='$contact_role'";
                } else {
                    $sql .=  " AND md_values.md_id=152 AND m.md_id=992 AND m.md_value IS NOT NULL";
                }
                $result = $this->db->query($sql)->fetchAll();
                break;
            case 'mdorg':
                $md_id = 153;
                $sql = "
                    SELECT md_values.recno, md_values.md_path, md_values.md_value, md_values.lang
                    FROM md INNER JOIN md_values ON md.recno = md_values.recno
                    WHERE md_values.md_id IN ($md_id) AND data_type>0
                ";
                if($query_lang != '') {
                    $sql .= " AND md_values.lang='$query_lang'";
                }
                if($creator != '') {
                    if ($creator == $user) {
                        $sql .= " AND md.create_user='$creator'";
                    } else {
                        $sql .= " AND md.create_user='$creator' AND (md.view_group IN($group) OR md.edit_group IN($group) OR md.data_type>0))";
                    }
                } else {
                    $sql .= " AND $right";
                }
                if($query != '') {
                    $sql .= " AND md_values.md_value ILIKE'%" . $query . "%'";
                }
                $sql .= "ORDER BY md_values.md_value";
                $result = $this->db->query($sql)->fetchAll();
                break;
            case 'denom':
                $creator = '';
                $orderBy = FALSE;
                $query_lang = '';
                $mask = ", '999999999'";
                $sql = "
                    SELECT md_values.md_value 
                    FROM md JOIN md_values ON md.recno=md_values.recno 
                    WHERE md_values.md_id=99 AND $right ";
                    if($query) $sql .= " AND md_values.md_value ILIKE '" . $query . "%' ";
                    $sql .= "GROUP BY md_values.md_value 
                    ORDER BY TO_NUMBER(md_value $mask)
                ";
                $result = $this->db->query($sql)->fetchAll();
                break;
            case 'country':
            case 'mdcountry':
                $creator = '';
                $orderBy = FALSE;
                $md_id = $contact_type == 'country' ? '202,5046' : '168';
                $sql = "SELECT md_values.md_value 
                    FROM md JOIN md_values ON md.recno=md_values.recno 
                    WHERE md_values.md_id IN ($md_id) AND $right";
                if($query) $sql .= " AND md_values.md_value ILIKE '%" . $query . "%' ";
                $sql .= " GROUP BY md_values.md_value ORDER BY md_value;";
                $result = $this->db->query($sql)->fetchAll();
                break;
            case 'keyword':
                $orderBy = FALSE;
                $sql = "
                    SELECT COUNT(*) AS count, md_values.md_value AS keyword 
                    FROM md INNER JOIN md_values ON md.recno = md_values.recno
                    WHERE md_values.md_id IN (88,4920) AND md.data_type=1 AND NOT md_values.lang = 'uri'
                ";
                if($query_lang != '') {
                    $sql .= " AND md_values.lang='$query_lang'";
                }
                if($creator != '') {
                    $sql .= " AND md.create_user='$creator'";
                }
                if($query != '') {
                    $sql .= " AND md_values.md_value ILIKE '%" . $query . "%'";
                }
                $sql .= "
                    GROUP BY md_values.md_value
                    ORDER BY count DESC, keyword        
                ";
                $result = $this->db->query($sql)->fetchAll();
                break;
            case 'topics':
                $sql = "
                    SELECT codelist_name as recno, label_text as md_value, lang
                    FROM codelist LEFT JOIN label ON codelist.codelist_id = label.label_join
                    WHERE el_id=410 AND label_type='CL' AND lang=?
                    ";
                if($query == '') {
                    $result = $this->db->query($sql, $query_lang)->fetchAll();
                } else {
                    $result = $this->db->query($sql . " AND label_text ILIKE ?", 
                            $query_lang,'%'. $query.'%')->fetchAll();
                }
                $rs = array();
                foreach($result as $row) {
                    $rs[] = array('id'=>$row->recno,"title"=>$row->md_value);
                }
                $rs = array('numresults'=>count($rs),'records'=>$rs);
                return $rs;

                break;
            case 'title':
                $l = ''; $l1='';
                if($query_lang != ''){
                    $l = " AND md_values.lang='$query_lang'";
                    $l1 = " AND abstr.lang='$query_lang'";
                }                  
                $sql = "
                    SELECT trim(uuid) as id, md_values.md_value, abstr.md_value as abstract 
                    FROM md 
                    JOIN md_values ON (md.recno=md_values.recno $l) 
                    LEFT JOIN md_values as abstr ON (md.recno=abstr.recno AND abstr.md_id IN (4,5061) AND md_standard != 2 $l1)
                    WHERE md_values.md_id IN (11,5063) AND $right
                ";
                if($creator != '') {
                    $sql .= " AND md.create_user='$creator'";
                }
                if($params['res']=='fc'){
                    $sql .= " AND md_standard=2";
                }
                if(isset($params['id'])){
                    $sql .= " AND uuid='".$params['id']."'";
                }
                elseif($query != '') {
                    $sql .= " AND md_values.md_value ILIKE '". $query . "%'";
                }
                $sql .= "
                ORDER BY md_value
                LIMIT 25";
                $result = $this->db->query($sql)->fetchAll();
                if($params['f']==1){
                    foreach($result as $row) {
                        $rs[] = array('id'=>$row->id,"text"=>$row->md_value,"title"=>$row->abstract);
                    }
                    $rs = array('numresults'=>count($rs),'results'=>$rs);
                    return $rs;
                }
                else {
                    foreach($result as $row) {
                        $rs[] = array('id'=>$row->id,"title"=>$row->md_value,"abstract"=>$row->abstract);
                    }
                    $rs = array('numresults'=>count($rs),'records'=>$rs);
                    return $rs;
                }
                break;
            case 'featureType':
                $result = $this->db->query("SELECT md_value FROM md_values LEFT JOIN md USING (recno) 
                WHERE md_id=13 AND uuid=?", $params['id'])->fetchAll();
                foreach($result as $row) {
                    $rs[] = array('id'=>$row->md_value,"title"=>$row->md_value);
                }
                $rs = array('numresults'=>count($rs),'records'=>$rs);
                return $rs;
                break;
            case 'serviceType':
                $sql = "SELECT  count(*) as count, md_value
                    FROM md_values
                    WHERE md_id = 5124 
                    ";
                 if($query == '') {
                    $result = $this->db->query($sql . ' GROUP by md_value ORDER by md_value')->fetchAll();
                } else {
                    $result = $this->db->query($sql . " AND md_value ILIKE ?",'%'. $query.'%', ' GROUP by md_value ORDER by md_value')->fetchAll();
                }
                $rs = array();
                $i = 0;
                foreach($result as $row) {
                    $rs[] = array('id'=>++$i,"name"=>$row->md_value);
                }
                $rs = array('numresults'=>count($rs),'records'=>$rs);
                return $rs;
              
                break;
            case 'person':
            case 'org':
            default:
                $md_id_cont_md = $contact_type == 'person' ? 186 : 187;
                $md_id_cont_ms = $contact_type == 'person' ? 5028 : 5029;
                if($contact_type != 'org') {
                    $query_lang = '';
                }
                $sql = "
                    SELECT md_values.recno, md_values.md_path, md_values.md_value, md_values.lang
                    FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTRING(md_values.md_path, 1,27)=SUBSTRING(m.md_path, 1,27) AND md_values.recno=m.recno)
                    WHERE md_values.md_id=$md_id_cont_md AND md.data_type>0
                ";
                if($creator != '') {
                    if ($creator == $user) {
                        $sql .= " AND md.create_user='$creator'";
                    } else {
                        $sql .= " AND md.create_user='$creator' AND (md.view_group IN($group) OR md.edit_group IN($group) OR md.data_type>0))";
                    }
                } else {
                    $sql .= " AND $right";
                }
                if($query_lang != '') {
                    $sql .= " AND md_values.lang='$query_lang'";
                }
                if($contact_role == 'custodian' && $contact_type == 'org') {
                    $sql .= " AND md.prim=1";
                }
                if($query != '') {
                    $sql .= " AND md_values.md_value ILIKE '%" . $query . "%'";
                }
                if($contact_role != '') {
                    $sql .= " AND m.md_id=1047 AND m.md_value='$contact_role'";
                } else {
                    $sql .= " AND m.md_id=1047 AND m.md_value IS NOT NULL";
                }
                $sql .= "
                    UNION
                    SELECT md_values.recno, md_values.md_path, md_values.md_value, md_values.lang
                    FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTRING(md_values.md_path, 1,32)=SUBSTRING(m.md_path, 1,32) AND md_values.recno=m.recno)
                    WHERE md_values.md_id=$md_id_cont_ms AND md.data_type>0
                ";
                if($creator != '') {
                    if ($creator == $user) {
                        $sql .= " AND md.create_user='$creator'";
                    } else {
                        $sql .= " AND md.create_user='$creator' AND (md.view_group IN($group) OR md.edit_group IN($group) OR md.data_type>0))";
                    }
                } else {
                    $sql .= " AND $right";
                }
                if($query_lang != '') {
                    $sql .= " AND md_values.lang='$query_lang'";
                }
                if($contact_role == 'custodian' && $contact_type == 'org') {
                    $sql .= " AND md.prim=1";
                }
                if($query != '') {
                    $sql .= " AND md_values.md_value ILIKE '%" . $query . "%'";
                }
                if($contact_role != '') {
                    $sql .= " AND m.md_id=5038 AND m.md_value='$contact_role' ";
                } else {
                    $sql .= " AND m.md_id=5038 AND m.md_value IS NOT NULL";
                }
                $result = $this->db->query($sql)->fetchAll();
                break;
        }

        if ($orderBy === FALSE) {
            foreach ($result as $key => $value) {
                if ($contact_type == 'keyword') {
                    $rs[] = array('id'=>($key+1), "count"=>$value->count, "value"=>$value->keyword);
                } else {
                    $rs[] = array('id'=>($key+1),"value"=>$value->md_value);
                }
            }
            return array('numresults'=>count($rs),'records'=>$rs);
        }

        $firs_record = TRUE;
        $org_lang = '';
        $org_eng = '';
        $org_ost = '';
        if ($query_lang == '') {
            $query_lang = 'eng';
        }

        if ($result) {
            foreach ($result as $row) {
                if ($recno != $row->recno && $firs_record === FALSE) {
                    if ($org_lang != '') {
                        $org_name = $org_lang;
                    }
                    elseif ($org_eng != '') {
                        $org_name = $org_eng;
                    }
                    else {
                        $org_name = $org_ost;
                    }
                    $org[]=$org_name;
                    $org_lang = '';
                    $org_eng = '';
                    $org_ost = '';
                }
                $org_ost = $row->md_value;
                if ($query_lang == $row->lang) {
                    $org_lang = $row->md_value;
                }
                if ($row->lang == 'eng') {
                    $org_eng = $row->md_value;
                }
                $firs_record = FALSE;
                $recno = $row->recno;
            }
            if ($org_lang != '') {
                $org_name = $org_lang;
            }
            elseif ($org_eng != '') {
                $org_name = $org_eng;
            }
            else {
                $org_name = $org_ost;
            }
            $org[]=$org_name;
            $org_lang = '';
            $org_eng = '';
            $org_ost = '';
        }

        if ($org_lang != '' && $org_eng != '' && $org_ost != '') {
            if ($org_lang != '') {
                $org_name = $org_lang;
            }
            elseif ($org_eng != '') {
                $org_name = $org_eng;
            }
            else {
                $org_name = $org_ost;
            }
            $org[]= $org_name;
        }

        if (count($org) > 0) {
            $org = array_unique($org);

            setlocale(LC_ALL, 'cs_CZ.utf8');
            sort($org, SORT_LOCALE_STRING);

            for($i=0;$i<count($org);$i++) {
                $rs[] = array('id'=>($i+1),"name"=>$org[$i]);
            }
        }
        $rs = array('numresults'=>count($org),'records'=>$rs);
        return $rs;
    }
}