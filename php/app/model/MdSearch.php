<?php

namespace App\Model;

use Nette;
use Nette\Application\UI\Control;

class MdSearch extends \BaseModel
{
    protected $sql_language_ex = '';
    protected $page_number = 1;
    protected $only_public = FALSE;
    protected $only_private = FALSE;
    protected $query_in = array();
    protected $query_out_md = array();
    protected $query_out_value = array();
    protected $query_status = TRUE;
    protected $sql_final = [0=>''];
    protected $sql_operation = '';
    protected $sql_mds = '';
    protected $sql_uuid = '';
    protected $sql_md_params = array();
    protected $sql_md = '';
    protected $sql_or = '';
    protected $search_uuid = FALSE;
    protected $sid = '';
    protected $my_edit = 0;
    protected $my_records = FALSE;
    protected $ext_header = FALSE;
    protected $hits = FALSE;
    protected $bbox = null;
    protected $sortBy = ['[title]','ASC'];
    protected $for_inspire = '';
    protected $paginator = TRUE;
    protected $startPosition = 0;
    protected $maxRecords = 50;
    public $appLang = 'cze';
    protected $type_mapping = array();


    public function __construct($db, $user, $appgParameters, $startPosition=0, $maxRecords='', $sortBy='') 
    {
        parent::__construct($db, $user, $appgParameters);

        $this->sid = session_id();
        $this->sql_final[0] = '';
        
        if ($startPosition == '') {
            $startPosition = 0;
        }
        if ($startPosition > 0) {
            $startPosition--;
        }
        $this->startPosition = $startPosition;
        $this->setMaxRecords($maxRecords);
        
        $this->sortBy = getSortBy($sortBy, $ret='array');
        $this->appLang = $this->appParameters['appLang'];
    }

    private function setQueryError($element)
    {
        $this->query_status = FALSE;
        \Tracy\Debugger::log($element, 'MDSEARCH_QUERY_ERROR');
    }

    protected function setMaxRecords($maxRecords)
    {
        if ($maxRecords === 0) {
            $this->paginator = FALSE;
        }
        if ($maxRecords == '') {
            $maxRecords = $this->appParameters['app']['maxRecords'];
        }
        elseif ($maxRecords > $this->appParameters['app']['limitMaxRecords']) {
            $maxRecords = $this->appParameters['app']['limitMaxRecords'];
        }
        $this->maxRecords = $maxRecords;
    }

    protected function setFlatParams($params)
    {
        if (is_array($params) === FALSE) {
            $params = array();
        }
        $this->sql_mds = '';
        foreach ($params as $key => $value) {
            if ($key == 'VALID') {
                $this->sql_mds .= "md.[valid] $value  AND ";
            }
            elseif ($key == 'ID') {
                $this->search_uuid = TRUE;
                $this->sql_uuid = $value;
            }
            elseif ($key == 'extHeader') {
                $this->ext_header = $value === TRUE || strtoupper($value) == 'TRUE' ? TRUE : FALSE;
            }
            elseif ($key == 'hits') {
                $this->hits = $value === TRUE || strtoupper($value) == 'TRUE' ? TRUE : FALSE;
            }
        }
    }

    protected function setMyEdit($edit)
    {
        $this->my_edit = $edit == 1 || $edit == TRUE ? 1 : 0;
    }
    
    protected function setMyRecords($create_user)
    {
        $this->my_records = strpos($create_user, "'" . $this->user->getIdentity()->username . "'") == FALSE ? FALSE : TRUE;
    }
    
    protected function setQueryIn($query)
    {
        if (is_array($query) === FALSE) {
            $query = array();
        }
        $this->query_in = $query;
        if (count($query) == 1) {
            if(isset($query[0]) && is_array($query[0]) && count($query[0]) > 0) {
                $this->query_in = $query[0];
            }
        }
    }

    protected function getRight($end_and=TRUE)
    {
        $user = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
        $group = $this->user->isLoggedIn() ? $this->user->getIdentity()->data['groups'] : ['guest'];
        $group = implode("','", array_values($group));
        $group = "'" . $group . "'";
        if ($this->my_edit == 1 || $this->my_records === TRUE) {
            $right = '';
        } elseif ($this->user->isInRole('admin')) {
            $right = '';
        } elseif ($user == 'guest') {
            $right = '(md.[data_type]>0)';
        } else {
            if ($this->only_public) {
                $right = "([create_user]='" . $user . "' OR [edit_group] IN($group) OR [view_group] IN ($group)) AND [data_type]>0";
            } elseif ($this->only_private) {
                $right = "([create_user]='" . $user . "' OR [edit_group] IN($group) OR [view_group] IN ($group)) AND [data_type]<1";
            } else {
                $right = "([create_user]='" . $user . "' OR [edit_group] IN($group) OR [view_group] IN ($group) OR [data_type]>0)";
            }
        }
        $right = $end_and === TRUE && $right != '' ? $right . ' AND ' : $right;
        return $right;
    }
    
    protected function setSqlLike ($field='', $value='', $znam='')
    {
        $sql_like = "@FIELD ILIKE @VALUE";
        $rs = '';
        $replace = FALSE;
        if ($field != '' || $value != '') {
            if ($znam != '') {
                $znam = strtoupper($znam);
                if ($znam == 'LIKE' || $znam == '=' || $znam == '<' || $znam == '>' || $znam == '<=' || $znam == '>=') {
                    $rs = "$field $znam $value";
                }
                else {
                    $replace = TRUE;
                }
            }
            else {
                $replace = TRUE;
            }
        }
        if ($replace) {
            $rs = str_replace('@FIELD', $field, $sql_like);
            $rs = str_replace('@VALUE', $value, $rs);
            $rs = str_replace('@UVALUE', mb_convert_case($value, MB_CASE_UPPER, 'UTF-8'), $rs);
        }
        return $rs;
    }

    protected function getPaginator($sql, $limit_find, $page_number=1)
    {
        $rs = array();
        $rs['records'] = 0;
        $rs['pages'] = 0;
        if ($limit_find < 10) {
            $limit_find = 20;
        }
        if ($sql != '') {
            try {
                $records = $this->db->query($sql)->fetchSingle();
            } catch (\Dibi\Exception $e) {
                \Tracy\Debugger::log($e, 'SQL_ERROR');
                return -1;
            }

            if ($records > 0) {
                $rs['records'] = $records;
                $rs['pages'] = Ceil($records/$limit_find);
            }
        }
        if ($rs['records'] > 0) {
            $rs['start_page'] = $page_number-5;
            $rs['end_page'] = $page_number+5;

            if($rs['start_page'] < 1) $rs['end_page'] += Abs($rs['start_page']) + 1;
            if($rs['end_page'] > $rs['pages']) {
                $rs['start_page'] = $rs['start_page'] - ($rs['end_page']-$rs['pages']);
                $rs['end_page'] = $rs['pages'];
            }
            if($rs['start_page'] < 1) {
                $rs['start_page'] = 1;
            }
            for($x = $rs['start_page'];$x <= $rs['end_page'];$x++) {
                $rs['view_pages'][] = $x;
            }
            if ($page_number > $rs['end_page']) {
                $rs['page_number'] = $rs['end_page'];
            }
            else {
                $rs['page_number'] = $page_number;
            }
        }
        return $rs;
    }

    protected function setSqlMd()
    {
        $this->sql_md = '';
        if (count($this->sql_md_params) > 0) {
            foreach ($this->sql_md_params as $key => $value) {
                $this->sql_md .= $value . ' AND ';
            }
        }
        $this->sql_md .= $this->getRight();
    }

    protected function setSqlEmptyIn()
    {
        if ($this->sql_or == '') {
            $this->sql_final[0] = $this->getSqlMd_titleFromMd();
            if ($this->sql_md != '') {
                $this->sql_final[0] .= ' WHERE ' . substr($this->sql_md, 0, -4);
            }
        } else {
            $this->sql_final[0] = $this->getSqlMd_titleFromMd2();
            if ($this->sql_md == '') {
                $this->sql_final[0] .= ' WHERE ' . substr($this->sql_or, 0, -4);
            } else {
                $this->sql_final[0] .= ' WHERE ' . $this->sql_or;
            }
            if ($this->sql_md != '') {
                $this->sql_final[0] .= substr($this->sql_md, 0, -4);
            }
        }
    }

    protected function getTypeMapping($mapping)
    {
        /*
            * NOT
            * SELECT md.recno FROM md WHERE (SELECT count(*) FROM md_values WHERE md.recno=md_values.recno AND md_id=12)=0
            */
        $rs = '';
        $no = '';
        if ($this->sql_operation == 'NOT') {
            $no = 'NOT ';
        }
        if ($mapping != '') {
            if (count($this->type_mapping) == 0) {
                $sql = "
                    SELECT [md_id], [md_mapping] FROM standard_schema WHERE [md_mapping] IS NOT NULL ORDER BY [md_mapping]
                ";
                $dbres = $this->db->query($sql)->fetchAll();
                foreach ($dbres as $row) {
                    $mapp = trim($row->md_mapping);
                    if (array_key_exists($mapp, $this->type_mapping)) {
                        $this->type_mapping[$mapp] .= ',' . $row->md_id;
                    }
                    else {
                        $this->type_mapping[$mapp] = $row->md_id;
                    }
                }
                // FIXME
                if ($mapping == 'operatesonid') {
                    $this->type_mapping[$mapp] = '5906';
                }
            }
            if (isset($this->type_mapping[$mapping]) && $this->type_mapping[$mapping] != '') {
                if (strpos($this->type_mapping[$mapping], ',') === FALSE) {
                    $rs = 'md_values.[md_id]=' . $this->type_mapping[$mapping] . " AND $no";
                }
                else {
                    $rs = 'md_values.[md_id] IN (' . $this->type_mapping[$mapping] . ") AND $no";
                }
                
            }
        }
        return $rs;
    }
    
    protected function parserSearchText($data, $con)
    {
        $in = $data;
        $i = (stripos($data, '% LIKE')); // nerozlišuje velikost písmen
        if ($i === FALSE) {
            $i = (stripos($data, '% ='));
        }
        if ($i === FALSE) {
            
        }
        else {
            $pos0 = stripos($data, '% LIKE');
            $pos1 = strpos($data, "'", $pos0);
            $pos2 = strpos($data, "'", $pos1+1);
            $pom_like = substr($data, $pos1, ($pos2-$pos1)+1);
            if (str_replace(' ', '', $pom_like) == "'%'") {
                $pom_like = "'%'";
            }
            $pom_b = substr($data, 0, $pos0);
            $pom_e = substr($data, $pos2+1);
            if ($pom_like != "'%'") {
                $data = $pom_b . $this->setSqlLike('md_values.[md_value]',$pom_like) . $pom_e;
            } else {
                $data = '';
            }
        }
        if ($data != '') {
            $rs = array();
            $rs['con'] = $con;
            $rs['sql'] = $data;
            $this->query_out_value[] = $rs;
        }
        if ($data == '') {
            $this->setQueryError($in);
        }
        return $data;
    }

    protected function parserMdMapping($data, $con)
    {
        $pos1 = strpos($data, '@');
        $pos2 = strpos($data, ' ', $pos1);
        if ($pos1 === FALSE || $pos2 === FALSE) {
            $this->setQueryError($data);
            return $data;
        }
        $mapping = trim(substr($data, $pos1+1, $pos2-($pos1+1)));
        if ($mapping == 'keyword' && stripos($data, '|') !== FALSE) {
            $data = $this->parserThesaurusKeyword($data);
            if ($data != '') {
                $rs = array();
                $rs['con'] = $con;
                $rs['sql'] = $data;
                $this->query_out_value[] = $rs;
            }
            return $data;
        } elseif ($mapping == 'innaco' && stripos($data, ':') !== FALSE) {
            $data = $this->parserNameContact($data, 'individual');
            if ($data != '') {
                $rs = array();
                $rs['con'] = $con;
                $rs['sql'] = $data;
                $this->query_out_value[] = $rs;
            }
            return $data;
        } elseif ($mapping == 'mdinnaco' && stripos($data, ':') !== FALSE) {
            $data = $this->parserMdNameContact($data, 'individual');
            if ($data != '') {
                $rs = array();
                $rs['con'] = $con;
                $rs['sql'] = $data;
                $this->query_out_value[] = $rs;
            }
            return $data;
        } elseif ($mapping == 'ornaco' && stripos($data, ':') !== FALSE) {
            $data = $this->parserNameContact($data, 'organisation');
            if ($data != '') {
                $rs = array();
                $rs['con'] = $con;
                $rs['sql'] = $data;
                $this->query_out_value[] = $rs;
            }
            return $data;
        } elseif ($mapping == 'mdornaco' && stripos($data, ':') !== FALSE) {
            $data = $this->parserMdNameContact($data, 'organisation');
            if ($data != '') {
                $rs = array();
                $rs['con'] = $con;
                $rs['sql'] = $data;
                $this->query_out_value[] = $rs;
            }
            return $data;
        }
        $type = $this->getTypeMapping($mapping);
        $pos0 = stripos($data, 'LIKE');
        if ($pos0 === FALSE) {
            $data = str_replace("@$mapping", $type . 'md_values.[md_value]', $data);
            if (strpos($data, "= ''") !== FALSE || strpos($data, "=''") !== FALSE) {
                $data = "SELECT md.[recno], md.[last_update_date], md.[md_update], md.[title] FROM md LEFT JOIN md_values ON $type md.[recno]=md_values.[recno] WHERE md_values.[md_value] IS NULL";
            }
        } else {
            $pos1 = strpos($data, "'", $pos0);
            $pos2 = strpos($data, "'", $pos1+1);
            $pom_like = substr($data, $pos1, ($pos2-$pos1)+1);
            $pom_b = substr($data, 0, $pos0);
            $pom_e = substr($data, $pos2+1);
            if ($pom_like == "'.%'") { // ?
                $data = '(' . $pom_b . 'md_values.[md_value] IS NOT NULL)';
            } elseif ($pom_like != "'%'") {
                $data = $pom_b . $this->setSqlLike('md_values.[md_value]',$pom_like) . $pom_e;
            }
            $data = str_replace("@$mapping", $type, $data);
        }
        if ($mapping == 'denom') {
            if (stripos($data, 'null') !== FALSE) {
                $data = str_replace(" AND md_values.[md_value] = null", '', $data);
                $data = str_replace('=', '!=', $data);
            } else {
                $maska = '999999999';
                $pos1 = strpos($data, "'");
                $pos2 = strrpos($data, "'");
                $mapping = trim(substr($data, $pos1+1, $pos2-($pos1+1)));
                $data = str_replace("md_values.[md_value]", "TO_NUMBER(md_values.[md_value], '$maska')", $data);
            }
        }
        if (substr_count($data,"'%'") > 0) {
            $data = str_replace("=", '', $data);
            $data = str_replace("'%'", ' IS NOT NULL', $data);
        } elseif (substr_count($data,"'% '") > 0) {
            $data = str_replace("=", '', $data);
            $data = str_replace("'% '", ' IS NOT NULL', $data);
        } elseif (substr_count($data,"'%%'") > 0) {
            $data = str_replace("=", '', $data);
            $data = str_replace("'%%'", ' IS NOT NULL', $data);
        }
        if ($data != '') {
            if (stripos($data, 'null') !== FALSE) {
                $data = str_replace(" AND md_values.[md_value] = null", '', $data);
                $data = str_replace('=', '!=', $data);
                //$data = $mapping;
            }
            if (stripos($data, '!=') !== FALSE) {
                //$data = "SELECT DISTINCT md.recno, md.last_update_date, md.md_update, md.title FROM md WHERE (SELECT count(*) FROM md_values WHERE md.recno=md_values.recno AND $data)=0";
                //$data = str_replace("!=", '=', $data);
                $data = str_replace("AND md_values.[md_value] !=", 'AND NOT md_values.[md_value] =', $data);
                $data = "
                    SELECT DISTINCT md.[recno], md.[last_update_date], md.[md_update], md.[title] 
                    FROM md INNER JOIN md_values ON md.[recno]=md_values.[recno] 
                    WHERE $data
                ";
    }
            $rs = array();
            $rs['con'] = $con;
            $rs['sql'] = $data;
            $this->query_out_value[] = $rs;
        }
        return $data;
    }

    protected function parserXmlPath($data, $con)
    {
        $ftext_path = trim(substr($data, 0, strpos($data, ' ', 0)));
        $pos1 = strpos($data, "'", 0);
        $pos2 = strpos($data, "'", $pos1+1);
        $ftext_value = substr($data, $pos1+1, ($pos2-$pos1)-1);
        $ftext_value = str_replace("-", '\-', $ftext_value);
        $ftext_value = str_replace("_", '\_', $ftext_value);
        if ($data != '') {
            $rs = array();
            $rs['con'] = $con;
            $rs['sql'] = $data;
            $this->query_out_value[] = $rs;
        }
        return $data;
    }
    
    protected function parserFullText($data)
    {
        $data = trim(str_replace("'","",explode('=', $data)[1])); //TODO - enhance parsing
        $data = preg_replace('/[\s]+/mu', ' & ', $data);
        $pgLangs = ['cs'=>'cs', "en"=>"english", "es"=>"spanish", "fr"=>"french", "ge"=>"german"]; //TODO - to config
        $lang = $pgLangs[$this->appParameters["appLocale"]] ? $pgLangs[$this->appParameters["appLocale"]] : 'english';
        if (substr_count($data, ' ') === 0) {
            $data = $data . ' & ' . $data;
        }
        $data = "to_tsvector('".$lang."'::regconfig, pxml::character varying::text) @@ to_tsquery('".$lang."','".$data."')";
        return $data;
    }

    protected function parserMdField($data, $con)
    {
        $rs = array();
        $rs['con'] = $con;
        $dataExplode = explode(' ', $data);
        $dataField = $data;
        if (count($dataExplode) > 1) {
            $dataField = $dataExplode[0];
        }
        $field = ltrim(substr($data, 0, strrpos($dataField, '_') + 1));
        switch ($field) {
            case '_FULL_':
                $rs['sql'] = $this->parserFullText($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_LANGUAGE_':
                $rs['sql'] = $this->parserMdFieldLanguage($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_LANG_':
                $rs['sql'] = $this->parserMdFieldLang($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_BBOX_':
                $rs['sql'] = $this->parserMdFieldBbox($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_BBSPAN_':
                $rs['sql'] = $this->parserMdFieldBbspan($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_VALID_':
                $rs['sql'] = $this->parserMdFieldValid($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_PRIM_':
                $rs['sql'] = $this->parserMdFieldPrim($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_FORINSPIRE_':
                $rs['sql'] = $this->parserMdFieldForInspire($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_MDS_':
                $rs['sql'] = $this->parserMdFieldMds($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_UUID_':
                $rs['sql'] = $this->parserMdFieldUuid($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_MAYEDIT_':
                $rs['sql'] = $this->parserMdFieldMayedit($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_GROUPS_':
                $rs['sql'] = $this->parserMdFieldGroups($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_CREATE_USER_':
                $rs['sql'] = $this->parserMdFieldCreateUser($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_DATEB_':
                $rs['sql'] = $this->parserMdFieldDateb($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_DATEE_':
                $rs['sql'] = $this->parserMdFieldDatee($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_DATESTAMP_':
                $rs['sql'] = $this->parserMdFieldDatestamp($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_RDATE_':
                $rs['sql'] = $this->parserMdFieldRdate($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_CDATE_':
                $rs['sql'] = $this->parserMdFieldCdate($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_PDATE_':
                $rs['sql'] = $this->parserMdFieldPdate($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_SERVER_':
                $rs['sql'] = $this->parserMdFieldServer($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            case '_DATA_TYPE_':
                $rs['sql'] = $this->parserMdFieldDataType($data);
                if ($rs['sql'] != '') {
                    $this->query_out_md[] = $rs;
                }
                break;
            case '_DUP_':
                $rs['sql'] = $this->parserMdFieldDup($data);
                if ($rs['sql'] != '') {
                    $this->query_out_value[] = $rs;
                }
                break;
            default:
                $this->setQueryError($data);
                $rs['sql'] = '';
                break;
        }
        return $rs['sql'];
    }

    protected function parserMdFieldLanguage($data)
    {
        $x = 0;
        $pos0 = 0;
        $pos0 = strpos($data, '_LANGUAGE_', $pos0);
        $pos1 = strpos($data, "'", $pos0);
        $pos2 = strpos($data, "'", $pos1+2);
        $pom_l = substr($data, $pos1+1, $pos2-($pos1+1));
        $pom_b = substr($data, 0, $pos1+1);
        $pom_e = substr($data, $pos2);
        $data = $pom_b . "%$pom_l%" . $pom_e;
        $x++;
        $pos0 = $pos0+12;
        $data = str_replace('_LANGUAGE_ =', 'md.[lang] LIKE ', $data);
        $this->sql_language_ex = $data;
        return $data;
    }
	
    protected function parserMdFieldLang($data)
    {
        $data = str_replace('_LANG_', 'md_values.[lang]', $data);
        $sql_lang = "($data OR md_values.[lang]='xxx') AND";
        return $data;
    }
	
    protected function parserMdFieldBbox($data)
    {
        $inside = 0; // Zatím jen uvnitř
        
        $pos0 = strpos($data, '_BBOX_');
        $pos1 = strpos($data, "'", $pos0);
        $pos2 = strpos($data, "'", $pos1+2);
        if ($pos0 === FALSE || $pos1 === FALSE || $pos2 === FALSE) {
            $box = array();
        } else {
            $pom_box = substr($data, $pos1+1, $pos2-($pos1+1));
            $box = explode(' ',$pom_box);
        }
        if (count($box) > 3) {
            $x1 = $box[0];
            $y1 = $box[1];
            $x2 = $box[2];
            $y2 = $box[3];
            $this->bbox = array($x1, $y1, $x2, $y2); // pro dalsi dotazy
            if (isset($box[4])) {
                $inside = $box[4];
            };
            // ogc:Within
            if ($inside == 1) {
                $pom_bbox = " md.the_geom @ ST_GeomFromText('MULTIPOLYGON((($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1)))',0)";
            }
            // ogc:Within - v opacnem poradi
            else if ($inside == 11) {
                $pom_bbox = " ST_GeomFromText('MULTIPOLYGON((($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1)))',0) @ md.the_geom";
            }
            // ogc:Intersects
            else {
                $pom_bbox = " md.the_geom && ST_GeomFromText('MULTIPOLYGON((($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1)))',0) AND ST_Intersects(ST_GeomFromText('MULTIPOLYGON((($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1)))',0),md.the_geom)";
            }
        } else {
            $this->setQueryError($data);
            return $data;
        }
        $pom_b = substr($data, 0, $pos0);
        $pom_e = substr($data, $pos2+1);
        $data = $pom_b . $pom_bbox . $pom_e;
        return $data;
    }

    protected function parserMdFieldBbspan($data)
    {
        $rs = "";
        if($this->bbox) {
            $dx = $this->bbox[2] - $this->bbox[0];
            $bbspan = explode("=", $data);
            $bbspan = explode(",", trim(str_replace("'", "", $bbspan[1])));
            if($dx > 0){
                $rs = "(x2-x1)/$dx > $bbspan[0] AND (x2-x1)/$dx < $bbspan[1]";
            }
        }
        return $rs;
    }

    protected function parserMdFieldUuid($data)
    {
        return str_replace('_UUID_', 'md.[uuid]', $data);;
    }

    protected function parserMdFieldValid($data)
    {
        return str_replace('_VALID_', 'md.[valid]', $data);;
    }

    protected function parserMdFieldPrim($data)
    {
        return $in = str_replace('_PRIM_', 'md.[prim]', $data);;
    }

    protected function parserMdFieldForInspire($data)
    {
        return $in = str_replace('_FORINSPIRE_', 'md.[for_inspire]', $data);;
    }
    
    protected function parserMdFieldMds($data)
    {
        $data = str_replace('_MDS_ = 0', '_MDS_ IN(0,10)', $data);
        $data = str_replace('_MDS_', 'md.[md_standard]', $data);
        return $data;
    }

    protected function parserNameContact($data, $name)
    {
        $pom = explode("'", $data);
        if (is_array($pom) && count($pom) > 1) {
            $iname = explode(':', trim($pom[1]));
        } else {
            return '';
        }
        if (is_array($iname) && count($iname) == 2) {
            $individualName = trim($iname[0]);
            $RoleCode = trim($iname[1]);
        } else {
            return '';
        }
        $md_id_md = $name == 'organisation' ? 187 : 186;
        $md_id_sv = $name == 'organisation' ? 5029 : 5028;
        $rs = "
            SELECT DISTINCT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,27)=SUBSTR(m.md_path, 1,27) AND md_values.recno=m.recno)
            WHERE md_values.md_id=$md_id_md AND m.md_id=1047 AND md_values.md_value='$individualName' AND m.md_value='$RoleCode'
            #WHEREMD#
            UNION
            SELECT DISTINCT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,32)=SUBSTR(m.md_path, 1,32) AND md_values.recno=m.recno)
            WHERE md_values.md_id=$md_id_sv AND m.md_id=5038 AND md_values.md_value='$individualName' AND m.md_value='$RoleCode'
        ";
        return $rs;
    }
    
    protected function parserMdNameContact($data, $name)
    {
        $pom = explode("'", $data);
        if (is_array($pom) && count($pom) > 1) {
            $iname = explode(':', trim($pom[1]));
        } else {
            return '';
        }
        if (is_array($iname) && count($iname) == 2) {
            $individualName = trim($iname[0]);
            $RoleCode = trim($iname[1]);
        } else {
            return '';
        }
        $md_id = $name == 'organisation' ? 153: 152;
        $rs = "
            SELECT DISTINCT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,17)=SUBSTR(m.md_path, 1,17) AND md_values.recno=m.recno)
            WHERE md_values.md_id=$md_id AND m.md_id=992 AND md_values.md_value='$individualName' AND m.md_value='$RoleCode'
            #WHEREMD#
        ";
        return $rs;
    }
    
    protected function parserMdFieldMayedit($data)
    {
        $this->setMyEdit(1);
        $user = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
        $group = $this->user->isLoggedIn() ? $this->user->getIdentity()->data['groups'] : ['guest'];
        $group = implode("','", array_values($group));
        $group = "'" . $group . "'";
        return "([create_user]='$user' OR [edit_group] IN($group))";
    }

    protected function parserMdFieldGroups($data)
    {
        if ($data == "_GROUPS_ = '_mine'") {
            $user = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
            $group = $this->user->isLoggedIn() ? $this->user->getIdentity()->data['groups'] : ['guest'];
            $group = implode("','", array_values($group));
            $group = "'" . $group . "'";
            $rs = "([create_user]='$user' OR [view_group] IN($group) OR [edit_group] IN($group))";
        } else {
            $group = str_replace('_GROUPS_ = ', '', $data);
            $group = str_replace(",", "','", $group);
            if ($this->user->isInRole('admin')) {
                $this->setMyEdit(1);
                $rs = "([view_group] IN($group) OR [edit_group] IN($group))";
            } else {
                $rs = "
                    (
                    SELECT DISTINCT md.[recno], md.[last_update_date], md.[md_update], md.[title] FROM md JOIN md_values ON md.[recno]=md_values.[recno] 
                    WHERE" . $this->getRight(FALSE) . " 
                    )
                    INTERSECT
                    (
                    SELECT DISTINCT md.[recno], md.[last_update_date], md.[md_update], md.[title]
                    FROM md JOIN md_values ON md.[recno]=md_values.[recno] 
                    WHERE [view_group] IN($group) OR [edit_group] IN($group)
                    )
                ";
            }
        }
        return $rs;
    }

    protected function parserMdFieldDateb($data)
    {
        $x = 0;
        $pos0 = 0;
        $pos0 = strpos($data, '_DATEB_', $pos0);
        $pos1 = strpos($data, "'", $pos0);
        $pos2 = strpos($data, "'", $pos1+2);
        $pom_date = substr($data, $pos1+1, $pos2-($pos1+1));
        $pom_b = substr($data, 0, $pos1+1);
        $pom_e = substr($data, $pos2);
        $date = $this->timeWindow($pom_date,'','');
        $data = $pom_b . $date[0] . $pom_e;
        $x++;
        $pos0 = $pos0+7;
        $data = str_replace('_DATEB_', 'md.[range_end]', $data);
        $sql_date_b = "($data)";
        return $data;
    }

    protected function parserMdFieldDatee($data)
    {
            $x = 0;
            $pos0 = 0;
            $pos0 = strpos($data, '_DATEE_', $pos0);
            $pos1 = strpos($data, "'", $pos0);
            $pos2 = strpos($data, "'", $pos1+2);
            $pom_date = substr($data, $pos1+1, $pos2-($pos1+1));
            $pom_b = substr($data, 0, $pos1+1);
            $pom_e = substr($data, $pos2);
            $date = $this->timeWindow($pom_date,'','');
            $data = $pom_b . $date[1] . $pom_e;
            $x++;
            $pos0 = $pos0+7;
            $data = str_replace('_DATEE_', 'md.[range_begin]', $data);
            $sql_date_e = "($data)";
        return $data;
    }

    protected function parserMdFieldDatestamp($data)
    {
        $data = str_replace('_DATESTAMP_', 'md.[last_update_date]', $data);
        $sql_datestamp = "($data) AND";
        return $data;
    }

    protected function parserMdFieldRdate($data)
    {
        $tmp = explode(' ', $data);
        $sign = $tmp[1];
        $datum = $tmp[2];
        $rs = "
            SELECT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,34) = SUBSTR(m.md_path, 1,34) AND md_values.recno = m.recno)
            WHERE md_values.md_id=5077 AND m.md_id=5090 AND md_values.md_value $sign $datum AND m.md_value = 'revision'
            UNION
            SELECT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,26) = SUBSTR(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=14 AND m.md_id=974 AND md_values.md_value $sign $datum AND m.md_value = 'revision'
        ";
        return $rs;
    }

    protected function parserMdFieldCdate($data)
    {
        $tmp = explode(' ', $data);
        $sign = $tmp[1];
        $datum = $tmp[2];
        $rs = "
            SELECT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,34) = SUBSTR(m.md_path, 1,34) AND md_values.recno = m.recno)
            WHERE md_values.md_id=5077 AND m.md_id=5090 AND md_values.md_value $sign $datum AND m.md_value = 'creation'
            UNION
            SELECT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,26) = SUBSTR(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=14 AND m.md_id=974 AND md_values.md_value $sign $datum AND m.md_value = 'creation'
        ";
        return $rs;
    }

    protected function parserMdFieldPdate($data)
    {
        $tmp = explode(' ', $data);
        $sign = $tmp[1];
        $datum = $tmp[2];
        $rs = "
            SELECT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,34) = SUBSTR(m.md_path, 1,34) AND md_values.recno = m.recno)
            WHERE md_values.md_id=5077 AND m.md_id=5090 AND md_values.md_value $sign $datum AND m.md_value = 'publication'
            UNION
            SELECT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,26) = SUBSTR(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=14 AND m.md_id=974 AND md_values.md_value $sign $datum AND m.md_value = 'publication'
        ";
        return $rs;
    }
	
    protected function parserMdFieldCreateUser($data)
    {
        $this->setMyRecords($data);
        return str_replace('_CREATE_USER_', 'md.[create_user]', $data);
    }

    protected function parserMdFieldServer($data)
    {
        return str_replace('_SERVER_', 'md.[server_name]', $data);
    }

    protected function parserMdFieldDataType($data)
    {
        if ($data == "_DATA_TYPE_ = '0'") {
            $this->only_private = TRUE;
            $data = 'md.[data_type]=0';
            $this->setSqlMd();
        } elseif ($data == "_DATA_TYPE_ = '1'") {
            $data = 'md.[data_type]=1';
            $this->setSqlMd();
        } elseif ($data == "_DATA_TYPE_ = '-1'") {
            $data = 'md.[data_type]=-1';
            $this->setSqlMd();
        } else {
            $data = str_replace('_DATA_TYPE_', 'md.[data_type]', $data);
            $data = str_replace("'", '', $data);
            $this->setSqlMd();
        }
        return $data;
    }

    protected function parserMdFieldDup($data)
    {
        $data = 'SELECT [*] FROM md_values WHERE [md_id] IN(185,5079) AND [md_value] IN(
            SELECT [md_value] FROM md_values WHERE [md_id] IN(185,5079) GROUP BY md_v[alue HAVING COUNT([recno]) > 1) 
            ORDER BY [md_id], [md_value], [recno]';
        return $data;
    }

    protected function parserThesaurusKeyword($data)
    {
        $pom = explode("'", $data);
        if (is_array($pom) && count($pom) > 1) {
            $key_the = explode('|', trim($pom[1]));
        } else {
            return '';
        }
        if (is_array($key_the) && count($key_the) == 2) {
            $keyword = "'" . trim($key_the[1]) . "'";
            $thesaurus = "'" . trim($key_the[0]) . "'";
        } else {
            return '';
        }
        if (stripos($pom[0], 'LIKE') === FALSE) {
            $keyword = '= ' . $keyword;
            $thesaurus = '= ' . $thesaurus;
        } else {
            $keyword = ' ILIKE ' . $keyword;
            $thesaurus = ' ILIKE ' . $thesaurus;
        }
        $rs = "
            SELECT DISTINCT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,24) = SUBSTR(m.md_path, 1,24) AND md_values.recno = m.recno)
            WHERE md_values.md_id=88 AND m.md_id=1755 AND md_values.md_value $keyword AND m.md_value $thesaurus
            #WHEREMD#
            UNION
            SELECT DISTINCT md.recno, md.last_update_date, md.md_update, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(SUBSTR(md_values.md_path, 1,24) = SUBSTR(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=4920 AND m.md_id=4925 AND md_values.md_value $keyword AND m.md_value $thesaurus
        ";
        return $rs;
    }

    protected function parserData($data, $con)
    {
        $rs = '';
        if ($data[0] == '%') {
            $rs = $this->parserSearchText($data, $con);
        } elseif ($data[0] == '@') {
            $rs = $this->parserMdMapping($data, $con);
        } elseif ($data[0] == '/') {
            $rs = $this->parserXmlPath($data, $con);
        } elseif ($data[0] == '_') {
            $rs = $this->parserMdField($data, $con);
        }
        return $rs;
    }

    protected function isSimpleQuery()
    {
        $rs = TRUE;
        $con_and = 0;
        $con_or = 0;
        
        foreach ($this->query_in as $value) {
            if (is_array($value)) {
                $rs = FALSE;
                break;
            } else {
                if (strtoupper($value) == 'AND') {
                    $con_and++;
                } elseif (strtoupper($value) == 'OR') {
                    $con_or++;
                }
            }
        }
        if ($con_and > 0 && $con_or > 0) {
            $rs = FALSE;
        }
        return $rs;
    }

    protected function walkQueryInSimple()
    {
        $con = 'AND';
        foreach ($this->query_in as $field) {
            if ($field[0] == '%' || $field[0] == '@' || $field[0] == '_' || $field[0] == '/') {
                $this->parserData($field, $con);
            } else {
                $con = strtoupper($field);
                if ($con == 'AND' || $con == 'OR' || $con == 'NOT') {
                } else {
                    $this->setQueryError($con);
                }
            }
        }
        if (count($this->query_out_md) > 0) {
            foreach ($this->query_out_md as $key => $value) {
                if ($key == 0) {
                    $this->sql_md .= $value['sql'];
                } else {
                    $this->sql_md .= ' ' . $value['con'] . ' (' . $value['sql'] . ')';
                }
            }
            $this->sql_md .= ' AND ';
        }
        $sql_smd = "@sql_basic1";
        $sql_s = 'SELECT DISTINCT md.[recno], md.[last_update_date], md.[md_update], md.[title] FROM md JOIN md_values ON md.[recno]=md_values.[recno]';
        $this->sql_final[0] = '';
        if (count($this->query_out_value) > 0) {
            foreach ($this->query_out_value as $key => $value) {
                if ($key > 0) {
                    if ($value['con'] == 'AND') {
                        $this->sql_final[0] .= ' INTERSECT ';
                    } elseif ($value['con'] == 'OR') {
                        $this->sql_final[0] .= ' UNION ';
                    } 
                }
                $this->sql_final[0] .= '(';
                if (strpos($value['sql'], 'SELECT') === FALSE) {
                    if (strpos($value['sql'], 'md_values.') === FALSE) {
                        $this->sql_final[0] .=  $sql_smd;
                    } else {
                        $this->sql_final[0] .= $sql_s;
                    }
                    $this->sql_final[0] .= ' WHERE ' . $this->sql_md . $value['sql'];
                } else {
                    $this->sql_final[0] .= $value['sql'];
                    if ($this->sql_md != '') {
                        $this->sql_final[0] .= ' AND ' . substr($this->sql_md, 0, -4);
                    }
                }
                $this->sql_final[0] .= ')';
            }
        } else {
            $this->sql_final[0] .= $sql_smd . ' WHERE ' . substr($this->sql_md, 0, -4);
        }
        $repMd = $this->sql_md != '' ? ' AND ' . substr($this->sql_md, 0, -4) : '';
        $this->sql_final = str_replace('#WHEREMD#', $repMd, $this->sql_final);
    }

    protected function walkSqlArray($in)
    {
        foreach ($in as $field) {
            if (is_array($field)) {
                $bar = FALSE;
                $pom = is_array($field[0]) === TRUE || $field[0] == '' ? '' : strtoupper($field[0]);
                if ($pom == 'AND' || $pom == 'OR' || $pom == 'NOT') {
                }
                else {
                    $this->sql_final[0] .= '(';
                    $bar = TRUE;
                }
                $this->walkSqlArray($field);
                if ($bar) {
                    $this->sql_final[0] .= ')';
                }
            } else {
                if ($field[0] == '%' || $field[0] == '@' || $field[0] == '_' || $field[0] == '/') {
                    $sql_row = $this->parserData($field, NULL);
                    $sql_row = str_replace('#WHEREMD#', '', $sql_row);
                    $grpBy = '';
                    $sql_s = 'SELECT DISTINCT md.[recno], md.[last_update_date], md.[md_update], md.[title] FROM md JOIN md_values ON md.[recno]=md_values.[recno]';
                    if (strpos($sql_row, 'md_values.') === FALSE) {
                        //$sql_s = 'SELECT recno, last_update_date, md.md_update, COALESCE((xpath(\'//gmd:identificationInfo/*/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[contains(@locale, "' . $this->appLang . '")]/text()\', pxml, ARRAY[ARRAY[\'gmd\', \'http://www.isotc211.org/2005/gmd\']]))[1]::text, title) AS title FROM md';
                        $sql_s = "    
                            SELECT md.[recno], md.[last_update_date], md.[md_update], COALESCE(m1.[md_value], m2.[md_value]) AS [title] 
                            FROM md left join md_values m1 on (md.[recno]=m1.[recno] AND m1.[md_id] IN (11,5063) AND m1.[lang]='$this->appLang')
                            left join md_values m2 on (md.[recno]=m2.[recno] AND m2.[md_id] IN (11,5063) AND m2.[lang]=SUBSTR(md.[lang],1,3))
                        ";
                    }
                    $sql_row = strpos($sql_row, 'SELECT') === FALSE ? $sql_s . ' WHERE ' . $this->sql_md . $sql_row . $grpBy : $sql_row;
                    if ($sql_row != '') {
                        $this->sql_final[0] .= '(';
                        $this->sql_final[0] .= $sql_row;
                        $this->sql_final[0] .= ')';
                    } else {
                        $this->sql_final[0] .= ')';
                    }
                } elseif (strtoupper($field) == 'AND') {
                    $this->sql_operation = '';
                    $this->sql_final[0] .= " INTERSECT ";
                } elseif (strtoupper($field) == 'OR') {
                    $this->sql_operation = '';
                    $this->sql_final[0] .= " UNION ";
                } elseif (strtoupper($field) == 'NOT') {
                    $this->sql_operation = 'NOT';
                    //$this->sql_final[0] .= " $field ";
                } else {
                    $this->setQueryError($field);
                }
            }
        }
    }

    public function getSql($type, $user, $ofs=0, $orderBy='' )
    {
        if ($this->bbox == NULL && is_array($orderBy) && $orderBy[0] == 'bbox') {
            $this->sortBy = getSortBy($this->appParameters['app']['sortBy'], $ret='array');
            $orderBy = '';
        }
        if ($orderBy == '') {
            $orderBy = $this->sortBy;
        }
        $sql = '';
        if ($type == '' || $user == '') {
            return $sql;
        }
        $sortBy = '['.$orderBy[0].']' . ' ' . $orderBy[1];
        $selectBbox = '';
        if (is_array($this->bbox) && count($this->bbox) == 4 && is_array($orderBy) && $orderBy[0] == 'bbox') {
            list($x1, $y1, $x2, $y2) = $this->bbox;
            $a = ($x2-$x1)*($y2-$y1);
            if ($a == 0) {
                $a = 0.000000001;
            }
            $selectBbox = "sqrt(pow((x1 + x2 - $x1 - $x2)/2, 2) + pow((y1 + y2 - $y1 - $y2)/2, 2))*5 + greatest((x2-x1)*(y2-y1),$a)/least(greatest((x2-x1)*(y2-y1),0.00000000000001),$a)";
            $selectBbox = ", " . $selectBbox . " AS bbox";
        }
        $sortBy_mdpath = '';
        $sql_spol['md_select'] = $this->getSelectMd();
        $sql_spol['md_from'] = " FROM md m WHERE ([recno] IN (SELECT [recno] FROM(";
        $sql_spol['md_order'] = "";
        $sql_spol['md_count'] =  "
            SELECT count(DISTINCT [recno]) AS [Celkem]
        ";
        $sql_spol['md_in_end'] =  ")";
        $sql_spol['md_where_end'] =  ")";
        if ($type == 'count') {
            $sql = $this->getSqlCount($this->sql_final[0]);
        } elseif ($type == 'find') {
            $sql = $this->getSqlFind($sql_spol, $selectBbox, $ofs, $sortBy, $sortBy_mdpath);
        }
        return $sql;
    }

    protected function setQuery($in)
    {
        $rs = array();
        $this->setSqlMd();
        if (is_array($in)) {
            $key = key($in);
            if (count($in) == 0 && $this->sql_uuid == '') {
                $this->setSqlEmptyIn();
            } elseif (count($in) == 1 && is_array($in[$key]) === TRUE &&  count($in[$key]) == 0 && $this->sql_uuid == '') {
                $this->setSqlEmptyIn();
            } elseif (count($in) == 0 && $this->sql_uuid != '') {
                $this->sql_final[0] = 'SELECT [recno], [last_update_date], [md_update], [title] FROM md WHERE [uuid] IN ' . $this->sql_uuid;
            } else {
                if ($this->isSimpleQuery() === TRUE) {
                    $this->walkQueryInSimple();
                } else {
                    $this->walkSqlArray($in);
                }
            }
            $sql = $this->getSql('count', $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest', 0, $this->sortBy);
            if ($this->query_status === FALSE) {
                return -1;
            }
        } else {
            return -1;
        }

        if ($sql == -1 || $sql == '') {
            return -1;
        }
        
        if ($this->search_uuid === TRUE) {
            $rs['paginator']['records'] = 1;
            $rs['sql'] = $this->getSelectMd() . "FROM md m";
            $right = $this->appParameters['app']['directSummary'] === TRUE 
                    || $this->appParameters['app']['directDetail'] === TRUE 
                    || $this->appParameters['app']['directXml'] === TRUE
                    ? '' 
                    : $this->getRight();
            $rs['sql'] .= " WHERE " . $right . " [uuid] IN " . $this->sql_uuid;
            return $rs;
        }
        $founds = $this->getPaginator($sql, $this->maxRecords, $this->page_number);
        if ($founds == -1) {
            return -1;
        }
        else {
            $rs['paginator'] = $founds;
        }
        $sql = '';
        if ($founds['records'] > 0) {
            if ($founds['end_page'] < $this->page_number) {
                if ( ($this->startPosition - $this->maxRecords) > 0) {
                    $this->startPosition = $this->startPosition - $this->maxRecords;
                }
            }
            $sql = $this->getSql('find', $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest', $this->startPosition, $this->sortBy);
        }
        
        if ($sql == -1) {
            return -1;
        }
        $rs['sql'] = $sql;
        return $rs;
    }

    protected function isMemberGroup($group)
    {
        $rs = FALSE;
        if ($this->user->isLoggedIn()) {
            foreach ($this->user->getIdentity()->data['groups'] as $row) {
                if ($row == $group) {
                    $rs = TRUE;
                    break;
                }
            }
        }
        return $rs;
    }

    protected function getHarvestor($server_name)
    {
        $rs = array();
        $rs['harvest_source'] = '';
        $rs['harvest_title'] = '';
        if ($server_name != '') {
            $data = $this->db->query('SELECT harvest.[source], md.[title] FROM harvest JOIN md ON md.[uuid] = harvest.[name] WHERE harvest.[name]=%s', $server_name)->fetchAll();
            foreach ($data as $row) {
                $rs['harvest_source'] = $data->source;
                $rs['harvest_title'] = $data->title;
            }
        }
        return $rs;
    }

    protected function setNumberOfRecords($startPosition, $founds)
    {
        $rs['Matched'] = 0;
        $rs['Return'] = 0;
        $rs['Next'] = 0;
        if ($founds > 0) {
            $rs['Matched'] = $founds;
        }
        if ($founds >= $this->maxRecords) {
            $rs['Return'] = $this->maxRecords;
            if (($startPosition -1) + $this->maxRecords >= $founds) {
                $rs['Return'] = $founds - ($startPosition - 1);
            }
            else {
                $rs['Next'] = $startPosition + $this->maxRecords;
            }
        }
        else {
            $rs['Return'] = $founds;
        }
        return $rs;
    }

    protected function getRecordRights($create_user, $view_group, $edit_group, $data_type)
    {
        $rights = array('read' => 0, 'edit' => 0);
        if ($this->user->isInRole('admin')) {
            return array('read' => 1, 'edit' => 1);
        }
        if ($this->isMemberGroup($edit_group) && $this->user->isInRole('editor')) {
            $rights['edit'] = 1;
        }
        if ($this->user->isLoggedIn() && $create_user == $this->user->getIdentity()->username) {
            $rights['edit'] = 1;
        }
        if ($rights['edit'] == 1) {
            $rights['read'] = 1;
        }
        if ($rights['read'] == 0) {
            if ($this->isMemberGroup($view_group) || $data_type > 0) {
                $rights['read'] = 1;
            }
        }
        return $rights;
    }

    public function getXmlRecords($in=array(), $params=array())
    {
        $this->setFlatParams($params);
        $this->setQueryIn($in);
        $in = $this->query_in;
        $pom = $this->setQuery($in);
        
        if ($pom == -1) {
            return -1;
        }
        if ($this->search_uuid === FALSE) { 
            $numberOfRecods = $this->setNumberOfRecords($this->startPosition+1, $pom['paginator']['records']);
        }
        $rs = '';
        if ($pom['paginator']['records'] > 0 && $pom['sql'] != '' && $this->hits === FALSE) {
            try {
                $db_rs = $this->db->query($pom['sql']);
                $records = $db_rs->fetchAll();
            } catch (\Dibi\Exception $e) {
                \Tracy\Debugger::log($e, 'SQL_ERROR');
                return -1;
            }
            if ($this->search_uuid === TRUE) {
                $numberOfRecods = $this->setNumberOfRecords($this->startPosition+1, count($records));
            }
            foreach ($records as $row) {
                $record_rights = $this->getRecordRights($row->create_user, $row->view_group, $row->edit_group, $row->data_type);
                if ($this->ext_header === TRUE) {
                    $row = $row + $this->getHarvestor($row->server_name);
                } else {
                    $row->harvest_source = '';
                    $row->harvest_title = '';
                }
                $rs .= '<rec recno="' . $row->recno . '"' .
                        ' uuid="' . rtrim($row->uuid) . '"' .
                        ' md_standard="' . $row->md_standard . '"' .
                        ' lang="' . $row->lang . '"' .
                        ' data_type="' . $row->data_type . '"' .
                        ' create_user="' . $row->create_user . '"' .
                        ' create_date="' . $row->create_date . '"' .
                        ' last_update_user="' . $row->last_update_user . '"' .
                        ' last_update_date="' . $row->last_update_date . '"' .
                        ' edit_group="' . $row->edit_group . '"' .
                        ' view_group="' . $row->view_group . '"' .
                        ' valid="' . $row->valid . '"' .
                        ' prim="' . $row->prim . '"' .
                        ' server_name="' . $row->server_name . '"' .
                        ' harvest_source="' . $row->harvest_source . '"' .
                        ' harvest_title="' . $row->harvest_title . '"' .
                        ' read="' .  $record_rights['read'] . '"' .
                        ' edit="' .  $record_rights['edit'] . '">' .
                        $this->getPxml($row->pxml) .
                        "</rec>";
            }
            if (count($records) > 0) {
                $db_rs->free();
            }
            unset($records);
        }
        $result = "<results numberOfRecordsMatched=\"".$numberOfRecods['Matched']."\" numberOfRecordsReturned=\"".$numberOfRecods['Return']."\" nextRecord=\"".$numberOfRecods['Next']."\" elementSet=\"brief\">";
        return $result.$rs."</results>";
    }

    public function fetchXmlOpen($in=array(), $params=array())
    {
        $this->setFlatParams($params);
        $this->setQueryIn($in);
        $in = $this->query_in;
        $pom = $this->setQuery($in);
        if ($pom == -1) {
            return -1;
        }
        if ($pom['paginator']['records'] > 0 && $pom['sql'] != '' && $this->hits === FALSE) {
            $this->db->query('SET transaction_read_only=true');
            $this->db->begin();
            $this->db->query('DECLARE xml_cursor NO SCROLL CURSOR FOR ('.$pom['sql'].')');
        }
        return $pom['paginator']['records'];
    }

    public function fetchXml($count=1)
    {
        $result = FALSE;
        $data = $this->db->query("FETCH $count FROM xml_cursor")->fetchAll();
        if (count($data) > 0) {
            foreach ($data as $row) {
                $record_rights = $this->getRecordRights($row->create_user, $row->view_group, $row->edit_group, $row->data_type);
                if ($this->ext_header === TRUE) {
                    $row = $row + $this->getHarvestor($row->server_name);
                } else {
                    $row->harvest_source = '';
                    $row->harvest_title = '';
                }
                $rs = '<rec recno="' . $row->recno . '"' .
                        ' uuid="' . rtrim($row->uuid) . '"' .
                        ' md_standard="' . $row->md_standard . '"' .
                        ' lang="' . $row->lang . '"' .
                        ' data_type="' . $row->data_type . '"' .
                        ' create_user="' . $row->create_user . '"' .
                        ' create_date="' . $row->create_date . '"' .
                        ' last_update_user="' . $row->last_update_user . '"' .
                        ' last_update_date="' . $row->last_update_date . '"' .
                        ' edit_group="' . $row->edit_group . '"' .
                        ' view_group="' . $row->view_group . '"' .
                        ' valid="' . $row->valid . '"' .
                        ' prim="' . $row->prim . '"' .
                        ' server_name="' . $row->server_name . '"' .
                        ' harvest_source="' . $row->harvest_source . '"' .
                        ' harvest_title="' . $row->harvest_title . '"' .
                        ' read="' . $record_rights['read'] . '"' .
                        ' edit="' . $record_rights['edit'] . '">' .
                        $this->getPxml($row->pxml) .
                        "</rec>";
                }
            $result = $rs;
        }
        return $result;
    }
    
    public function fetchXmlClose()
    {
        $this->db->query('CLOSE xml_cursor');
        $this->db->commit();
    }

    // date
    protected function isBissextile($year)
    {
        if (($year % 4 == 0) && ($year % 100 != 0) && ($year % 1000 != 0)) {
            return true;
        } elseif ($year % 400 == 0) {
            return true;
        } elseif (( $year % 1000 == 0) && ($year % 4000 != 0)) {
            return true;
        } else {
            return false;
        }
    }

    protected function extendDate($date, $mode)
    {
        $months = array( 1 => 31,
        2 => 28,
        3 => 31,
        4 => 30,
        5 => 31,
        6 => 30,
        7 => 31,
        8 => 31,
        9 => 30,
        10 => 31,
        11 => 30,
        12 => 31);
        //bissextile
        $monthsBis = array( 1 => 31,
        2 => 29,
        3 => 31,
        4 => 30,
        5 => 31,
        6 => 30,
        7 => 31,
        8 => 31,
        9 => 30,
        10 => 31,
        11 => 30,
        12 => 31) ;

        if (strpos($date, ' ')) {
            $date = substr($date,0,strpos($date, ' '));
        }
        $year = '';
        $month = '';
        $day = '';
        if (strpos($date, '-')) {
            list($year, $month, $day) = explode("-", $date);
            $day = ($day < 10 && strlen($day) == 1) ? "0$day" : $day ;
            $month = ($month < 10  && strlen($month) == 1) ? "0$month" : $month ;
        } else {
            $dateLen = strlen($date);
            switch ($dateLen) {
                case 8: // YYYYMMDD
                    $month = substr($date,4,2);
                    $day = substr($date,6,2);
                case 4: // YYYY
                    $year = substr($date,0,4);
                    break;
                default:
                    return $date;
                    break;
            }
        }
        if (!$month) {
            if ($mode) {
                $month='12';
             } else {
                 $month='01';
             }
        }
        if (!$day) {
            if($mode) {
                if ($this->isBissextile($year)) {
                    $day=$monthsBis[(int)$month];
                } else {
                    $day=$months[(int)$month];
                }
            } else {
                $day='01';
            }
        }
        return "$year-$month-$day";
    }

    protected function timeWindow($date, $date1, $date2)
    {
        if (!$date && !$date1 && !$date2) {
            return array('0000-00-00','0000-00-00');
        }
        if (($date1)||($date2)) {
            if($date1) {
                $date1 = $this->extendDate($date1, false);
            } else {
                $date1 = $this->extendDate('0001', false);
            }
            if($date2) {
                $date2 = $this->extendDate($date2, true);
            } else {
                $date2 = $this->extendDate('9999', true);
            }
        } else {
            $date1 = $this->extendDate($date, false);
            $date2 = $this->extendDate($date, true);
        }
        if (!$this->isValidDateIso($date1) || !$this->isValidDateIso($date2)) {
            $date1 = '0000-00-00';
            $date2 = '0000-00-00';
        }
        return Array($date1, $date2);

    }

    /*
    * http://en.wikipedia.org/wiki/ISO_8601
    * YYYY
    * YYYY-MM
    * YYYY-MM-DD
    */
    protected function isValidDateIso($date)
    {
        $dateLen = strlen($date);
        switch ($dateLen) {
            case 4: //YYYY
                if (preg_match('/[0-9]{4}/', $date)) {
                    return true;
                } else {
                    return false;
                }
            case 7: //YYYY-MM
                if (preg_match('/[0-9]{4}\-[0-9]{2}/', $date)) {
                    if (substr($date,5,2) < 13) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            case 10: // YYYY-MM-DD
                if (preg_match('/[0-9]{4}\-[0-9]{2}\-[0-9]{2}/', $date)) {
                    list($year, $month, $day) = explode("-", $date);
                    if (checkDate($month, $day, $year)) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            default:
                return false;
        }
    }
    
    protected function getSqlCount($sql_final)
    {
        $sql_final = str_replace(
            "@sql_basic1",
            $this->getSqlMd_titleFromMd(),
            $sql_final
        );
        $sql = "SELECT 	count(DISTINCT [recno]) AS Celkem FROM md WHERE ([recno] IN (SELECT [recno] FROM("
                    . $sql_final
                    . ') jojo))';
        return $sql;

    }

    protected function getSqlFind($sql_spol, $selectBbox, $ofs, $sortBy, $sortBy_mdpath)
    {
        $sql_final = $this->sql_final[0];
        if ($this->sortBy[0] == 'bbox') {
            $sql_final = str_replace(
                "@sql_basic1",
                $this->getSqlMd_bboxFromMd($selectBbox),
                $sql_final
            );
        } else {
            $sql_final = str_replace(
                "@sql_basic1",
                $this->getSqlMd_titleFromMd(),
                $sql_final
            );
        }
        $sql_final = str_replace('AS title', 'AS title ' . $selectBbox, $sql_final);
        if ($this->paginator === TRUE) {
            $select_limit = " LIMIT " . $this->maxRecords . " OFFSET $ofs";
            } else {
            $select_limit = "";
        }
        return  $sql_spol['md_select'] . $selectBbox
                    . $sql_spol['md_from']
                    . $sql_final
                    . ") jojo ORDER BY $sortBy $select_limit)) ORDER BY $sortBy $sortBy_mdpath";
    }

    protected function getSqlMd_titleFromMd()
    {
        return "
            SELECT md.recno, md.last_update_date, md.md_update, COALESCE(m1.md_value, m2.md_value) AS title 
            FROM md LEFT JOIN md_values m1 ON (md.recno=m1.recno AND m1.md_id IN (11,5063) AND m1.lang='$this->appLang')
            LEFT JOIN md_values m2 ON (md.recno=m2.recno AND m2.md_id IN (11,5063) AND m2.lang=SUBSTR(md.lang,1,3))
        ";
    }

    protected function getSqlMd_titleFromMd2()
    {
        return $this->getSqlMd_titleFromMd . "JOIN md_values ON md.recno=md_values.recno";
    }

    protected function getSqlMd_bboxFromMd($selectBbox)
    {
        return "
            SELECT DISTINCT md.recno, md.last_update_date, md.md_update, md.title $selectBbox FROM md
        ";
    }

    protected function getPxml($pxml)
    {
        return $pxml;
    }

    protected function getSelectMd()
    {
        return "
            SELECT 
                m.[recno], 
                m.[uuid], 
                m.[md_standard], 
                m.[lang], 
                m.[data_type], 
                m.[create_user], 
                m.[create_date], 
                m.[last_update_user], 
                m.[md_update], 
                m.[last_update_date], 
                m.[edit_group], 
                m.[view_group], 
                m.[valid], 
                m.[prim], 
                m.[pxml], 
                m.[server_name]
        ".$this->for_inspire;
    }

}

