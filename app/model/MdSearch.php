<?php

namespace App\Model;

use Nette;
use Nette\Application\UI\Control;

class MdSearch
{

	/** @var Nette\Database\Context */
	private $db;
    /** @var Nette\Security\User */
    private $user;
    private $appParameters;
    
	private $sql_language_ex = '';
	private $page_number = 1;
	private $only_public = FALSE;
	private $only_private = FALSE;
	private $query_in = array();
	private $query_out_md = array();
	private $query_out_value = array();
	private $query_status = TRUE;
	private $sql_final = [0=>''];
	private $sql_operation = '';
	private $sql_mds = '';
	private $sql_uuid = '';
	private $sql_md_params = array();
	private $sql_md = '';
	private $sql_or = '';
	private $search_uuid = FALSE;
	private $sid = '';
	private $may_edit = 0;
	private $may_records = FALSE;
	private $ext_header = FALSE;
	private $hits = FALSE;
	private $bbox = null;
	private $useOrderByXmlPath = TRUE;
	private $sortBy = ['title','ASC'];
    private $for_inspire = '';
    private $paginator = TRUE;
    private $startPosition = 0;
    private $maxRecords = 50;
    private $appLang = 'eng';
    private $type_mapping = array();


	//public function __construct(Nette\Database\Context $db, Nette\Security\User $user, $startPosition=0, $maxRecords='', $sortBy='') 
	public function __construct($startPosition=0, $maxRecords='', $sortBy='') 
	{
        global $tmp_nbcontext, $tmp_identity, $tmp_appparameters;
        $this->db = $tmp_nbcontext;
        $this->user = $tmp_identity;
        $this->appParameters = $tmp_appparameters;
        
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
	}

    public function setAppParameters($parameters)
    {
        $this->appParameters = $parameters;
    }
    
    public function setIdentity($user)
    {
        $this->user = $user;
    }
    
	private function setMaxRecords($maxRecords) {
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
    
	private function setFlatParams($params) {
		$this->sql_mds = '';
		foreach ($params as $key => $value) {
			if ($key == 'VALID') {
				$this->sql_mds .= "md.valid $value  AND ";
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

	private function setMayEdit($edit) {
		$this->may_edit = $edit == 1 || $edit == TRUE ? 1 : 0;
	}
    
	private function setQueryIn($query) {
		$this->query_in = $query;
		if (count($query) == 1) {
			if(isset($query[0]) && is_array($query[0]) && count($query[0]) > 0) {
				$this->query_in = $query[0];
			}
		}
	}

	private function getRight($end_and=TRUE) {
        $user = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
        $group = $this->user->isLoggedIn() ? $this->user->getIdentity()->data['groups'] : ['guest'];
        $group = implode("','", array_values($group));
        $group = "'" . $group . "'";
		if ($this->may_edit == 1 || $this->may_records === TRUE) {
			$right = '';
		} elseif ($this->user->isInRole('admin')) {
			$right = '';
		} elseif ($this->user == 'guest') {
			$right = '(md.data_type>0)';
		} else {
			if ($this->only_public) {
				$right = "(create_user='" . $user . "' OR edit_group IN($group) OR view_group IN ($group)) AND data_type>0";
			} elseif ($this->only_private) {
				$right = "(create_user='" . $user . "' OR edit_group IN($group) OR view_group IN ($group)) AND data_type<1";
			} else {
				$right = "(create_user='" . $user . "' OR edit_group IN($group) OR view_group IN ($group) OR data_type>0)";
			}
		}
		$right = $end_and === TRUE && $right != '' ? $right . ' AND ' : $right;
		return $right;
	}
    
    private function setSqlLike ($field='', $value='', $znam='') {
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

    private function getPaginator($sql, $limit_find, $page_number=1) {
        $rs = array();
        $rs['records'] = 0;
        $rs['pages'] = 0;
        if ($limit_find < 10) {
            $limit_find = 20;
        }
        if ($sql != '') {
            $records = $this->db->query($sql)->fetchField();
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

	private function setSqlMd() {
		$this->sql_md = '';
		if (count($this->sql_md_params) > 0) {
			foreach ($this->sql_md_params as $key => $value) {
				$this->sql_md .= $value . ' AND ';
			}
		}
		$this->sql_md .= $this->getRight();
	}

	private function setSqlEmptyIn() {
		if ($this->sql_or == '') {
			if ($this->useOrderByXmlPath === TRUE) {
				$this->sql_final[0] = 'SELECT recno, last_update_date, COALESCE((xpath(\'//gmd:identificationInfo/*/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[contains(@locale, "' . $this->appLang . '")]/text()\', pxml, ARRAY[ARRAY[\'gmd\', \'http://www.isotc211.org/2005/gmd\']]))[1]::text, title) AS title FROM md';
			} else {
				$this->sql_final[0] = 'SELECT recno, last_update_date, title FROM md';
			}
			if ($this->sql_md != '') {
				$this->sql_final[0] .= ' WHERE ' . substr($this->sql_md, 0, -4);
			}
		} else {
			$this->sql_final[0] = 'SELECT DISTINCT md.recno, md.last_update_date, md.title FROM md JOIN md_values ON md.recno=md_values.recno'; 
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

	private function getTypeMapping($mapping) {
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
					SELECT md_id, md_mapping FROM tree WHERE md_mapping IS NOT NULL ORDER BY md_mapping
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
					$rs = 'md_values.md_id=' . $this->type_mapping[$mapping] . " AND $no";
				}
				else {
					$rs = 'md_values.md_id IN (' . $this->type_mapping[$mapping] . ") AND $no";
				}
				
			}
		}
		return $rs;
	}
    
	private function parserSearchText($data, $con) {
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
                $data = $pom_b . $this->setSqlLike('md_values.md_value',$pom_like) . $pom_e;
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

	private function parserMdMapping($data, $con) {
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
			$data = str_replace("@$mapping", $type . 'md_values.md_value', $data);
			if (strpos($data, "= ''") !== FALSE || strpos($data, "=''") !== FALSE) {
				$data = "SELECT md.recno, md.last_update_date, md.title FROM md LEFT JOIN md_values ON $type md.recno=md_values.recno WHERE md_values.md_value IS NULL";
			}
		} else {
			$pos1 = strpos($data, "'", $pos0);
			$pos2 = strpos($data, "'", $pos1+1);
			$pom_like = substr($data, $pos1, ($pos2-$pos1)+1);
			$pom_b = substr($data, 0, $pos0);
			$pom_e = substr($data, $pos2+1);
			if ($pom_like == "'.%'") { // odstranit?
				$data = '(' . $pom_b . 'md_values.md_value IS NOT NULL)';
			} elseif ($pom_like != "'%'") {
				$data = $pom_b . $this->setSqlLike('md_values.md_value',$pom_like) . $pom_e;
			}
			$data = str_replace("@$mapping", $type, $data);
		}
		if ($mapping == 'denom') {
            if (stripos($data, 'null') !== FALSE) {
                $data = str_replace(" AND md_values.md_value = null", '', $data);
                $data = str_replace('=', '!=', $data);
            } else {
                $maska = '999999999';
                $pos1 = strpos($data, "'");
                $pos2 = strrpos($data, "'");
                $mapping = trim(substr($data, $pos1+1, $pos2-($pos1+1)));
                $data = str_replace("md_values.md_value", "TO_NUMBER(md_values.md_value, '$maska')", $data);
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
                $data = str_replace(" AND md_values.md_value = null", '', $data);
                $data = str_replace('=', '!=', $data);
                //$data = $mapping;
            }
            if (stripos($data, '!=') !== FALSE) {
                $data = "SELECT DISTINCT md.recno, md.last_update_date, md.title FROM md WHERE (SELECT count(*) FROM md_values WHERE md.recno=md_values.recno AND $data)=0";
    			$data = str_replace("!=", '=', $data);
            }
			$rs = array();
			$rs['con'] = $con;
			$rs['sql'] = $data;
			$this->query_out_value[] = $rs;
		}
		return $data;
	}

	private function parserXmlPath($data, $con) {
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

	private function parserMdField($data, $con) {
		$rs = array();
		$rs['con'] = $con;
        $dataExplode = explode(' ', $data);
        $dataField = $data;
        if (count($dataExplode) > 1) {
            $dataField = $dataExplode[0];
        }
		$field = ltrim(substr($data, 0, strrpos($dataField, '_') + 1));
		//echo "FIELD=$field<br>";
		switch ($field) {
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

	private function parserMdFieldLanguage($data) {
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
		$data = str_replace('_LANGUAGE_ =', 'md.lang LIKE ', $data);
		$this->sql_language_ex = $data;
		return $data;
	}
	
	private function parserMdFieldLang($data) {
		$data = str_replace('_LANG_', 'md_values.lang', $data);
		$sql_lang = "($data OR md_values.lang='xxx') AND";
		return $data;
	}
	
	private function parserMdFieldBbox($data) {
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
            $sdb = SPATIALDB == 0 ? '' : SPATIALDB;
            
			switch ($sdb) {
				case "postgis":
					// ogc:Within
					if ($inside == 1) {
						$pom_bbox = " md.the_geom @ GeomFromText('POLYGON(($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1))',-1)";
					}
					// ogc:Within - v opacnem poradi
					else if ($inside == 11) {
						$pom_bbox = " GeomFromText('POLYGON(($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1))',-1) @ md.the_geom";
					}
					// ogc:Intersects
					else {
						$pom_bbox = " md.the_geom && GeomFromText('POLYGON(($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1))',-1) AND Intersects(GeomFromText('POLYGON(($x1 $y1,$x1 $y2,$x2 $y2,$x2 $y1,$x1 $y1))',-1),md.the_geom)";
					}
					break;
				case "postgis2":
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
					break;
				// jen se sloupcu tabulky MD
				default: 
					// ogc:Within
					if ($inside == 1) {
						$pom_bbox = " $x1 <= x1 AND $x2 >= x2 AND $y1 <= y1 AND $y2 >= y2";
					}
					// ogc:Within - v opacnem poradi
					else if ($inside == 11) {
						$pom_bbox = " $x1 >= x1 AND $x2 <= x2 AND $y1 >= y1 AND $y2 <= y2";
					}
					// ogc:Intersects
					else {
						$pom_bbox = " $x2 >= x1 AND $x1 <= x2 AND $y2 >= y1 AND $y1 <= y2";
					}
					break;
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
	
	private function parserMdFieldBbspan($data) {
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
	
	private function parserMdFieldUuid($data) {
		return str_replace('_UUID_', 'md.uuid', $data);;
	}
	
	private function parserMdFieldValid($data) {
		return str_replace('_VALID_', 'md.valid', $data);;
	}
	
	private function parserMdFieldPrim($data) {
		return $in = str_replace('_PRIM_', 'md.prim', $data);;
	}
	
	private function parserMdFieldForInspire($data) {
		return $in = str_replace('_FORINSPIRE_', 'md.for_inspire', $data);;
	}
    
	private function parserMdFieldMds($data) {
		$data = str_replace('_MDS_ = 0', '_MDS_ IN(0,10)', $data);
		$data = str_replace('_MDS_', 'md.md_standard', $data);
		return $data;
	}
	
	private function parserNameContact($data, $name) {
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
            SELECT DISTINCT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,27)=substring(m.md_path, 1,27) AND md_values.recno=m.recno)
            WHERE md_values.md_id=$md_id_md AND m.md_id=1047 AND md_values.md_value='$individualName' AND m.md_value='$RoleCode'
            #WHEREMD#
            UNION
            SELECT DISTINCT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,32)=substring(m.md_path, 1,32) AND md_values.recno=m.recno)
            WHERE md_values.md_id=$md_id_sv AND m.md_id=5038 AND md_values.md_value='$individualName' AND m.md_value='$RoleCode'
        ";
		return $rs;
	}
    
	private function parserMdNameContact($data, $name) {
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
            SELECT DISTINCT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,17)=substring(m.md_path, 1,17) AND md_values.recno=m.recno)
            WHERE md_values.md_id=$md_id AND m.md_id=992 AND md_values.md_value='$individualName' AND m.md_value='$RoleCode'
            #WHEREMD#
        ";
		return $rs;
	}
    
	private function parserMdFieldMayedit($data) {
		$this->setMayEdit(1);
        $user = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
        $group = $this->user->isLoggedIn() ? $this->user->getIdentity()->data['groups'] : ['guest'];
        $group = implode("','", array_values($group));
        $group = "'" . $group . "'";
		return "(create_user='$user' OR edit_group IN($group))";
	}
	
	private function parserMdFieldGroups($data) {
		if ($data == "_GROUPS_ = '_mine'") {
            $user = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
            $group = $this->user->isLoggedIn() ? $this->user->getIdentity()->data['groups'] : ['guest'];
            $group = implode("','", array_values($group));
            $group = "'" . $group . "'";
			$rs = "(create_user='$user' OR view_group IN($group) OR edit_group IN($group))";
		} else {
			$group = str_replace('_GROUPS_ = ', '', $data);
			$group = str_replace(",", "','", $group);
			if ($this->user->isInRole('admin')) {
				$this->setMayEdit(1);
				$rs = "(view_group IN($group) OR edit_group IN($group))";
			} else {
				$rs = "
					(
					SELECT DISTINCT md.recno, md.last_update_date, md.title FROM md JOIN md_values ON md.recno=md_values.recno 
					WHERE" . $this->getRight(FALSE) . " 
					)
					INTERSECT
					(
					SELECT DISTINCT md.recno, md.last_update_date, md.title
					FROM md JOIN md_values ON md.recno=md_values.recno 
					WHERE view_group IN($group) OR edit_group IN($group)
					)
				";
			}
		}
		return $rs;
	}
	
	private function parserMdFieldDateb($data) {
		$x = 0;
		$pos0 = 0;
		$pos0 = strpos($data, '_DATEB_', $pos0);
		$pos1 = strpos($data, "'", $pos0);
		$pos2 = strpos($data, "'", $pos1+2);
		$pom_date = substr($data, $pos1+1, $pos2-($pos1+1));
		$pom_b = substr($data, 0, $pos1+1);
		$pom_e = substr($data, $pos2);
		$date = timeWindow($pom_date,'','');
		$data = $pom_b . $date[0] . $pom_e;
		$x++;
		$pos0 = $pos0+7;
		$data = str_replace('_DATEB_', 'md.range_end', $data);
		$sql_date_b = "($data)";
		return $data;
	}
	
	private function parserMdFieldDatee($data) {
			$x = 0;
			$pos0 = 0;
			$pos0 = strpos($data, '_DATEE_', $pos0);
			$pos1 = strpos($data, "'", $pos0);
			$pos2 = strpos($data, "'", $pos1+2);
			$pom_date = substr($data, $pos1+1, $pos2-($pos1+1));
			$pom_b = substr($data, 0, $pos1+1);
			$pom_e = substr($data, $pos2);
			$date = timeWindow($pom_date,'','');
			$data = $pom_b . $date[1] . $pom_e;
			$x++;
			$pos0 = $pos0+7;
			$data = str_replace('_DATEE_', 'md.range_begin', $data);
			$sql_date_e = "($data)";
		return $data;
	}
	
	private function parserMdFieldDatestamp($data) {
        $data = str_replace('_DATESTAMP_', 'md.last_update_date', $data);
		$sql_datestamp = "($data) AND";
		return $data;
	}
	
	private function parserMdFieldRdate($data) {
		$tmp = explode(' ', $data);
		$sign = $tmp[1];
		$datum = $tmp[2];
        $rs = "
            SELECT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,34) = substring(m.md_path, 1,34) AND md_values.recno = m.recno)
            WHERE md_values.md_id=5077 AND m.md_id=5090 AND md_values.md_value $sign $datum AND m.md_value = 'revision'
            UNION
            SELECT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,26) = substring(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=14 AND m.md_id=974 AND md_values.md_value $sign $datum AND m.md_value = 'revision'
        ";
		return $rs;
	}
	
	private function parserMdFieldCdate($data) {
		$tmp = explode(' ', $data);
		$sign = $tmp[1];
		$datum = $tmp[2];
        $rs = "
            SELECT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,34) = substring(m.md_path, 1,34) AND md_values.recno = m.recno)
            WHERE md_values.md_id=5077 AND m.md_id=5090 AND md_values.md_value $sign $datum AND m.md_value = 'creation'
            UNION
            SELECT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,26) = substring(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=14 AND m.md_id=974 AND md_values.md_value $sign $datum AND m.md_value = 'creation'
        ";
		return $rs;
	}
	
	private function parserMdFieldPdate($data) {
		$tmp = explode(' ', $data);
		$sign = $tmp[1];
		$datum = $tmp[2];
        $rs = "
            SELECT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,34) = substring(m.md_path, 1,34) AND md_values.recno = m.recno)
            WHERE md_values.md_id=5077 AND m.md_id=5090 AND md_values.md_value $sign $datum AND m.md_value = 'publication'
            UNION
            SELECT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,26) = substring(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=14 AND m.md_id=974 AND md_values.md_value $sign $datum AND m.md_value = 'publication'
        ";
		return $rs;
	}
	
	private function parserMdFieldCreateUser($data) {
		$this->setMayRecords($data);
		return str_replace('_CREATE_USER_', 'md.create_user', $data);
	}
	
	private function parserMdFieldServer($data) {
		return str_replace('_SERVER_', 'md.server_name', $data);
	}
	
	private function parserMdFieldDataType($data) {
		if ($data == "_DATA_TYPE_ = '0'") {
			$this->only_private = TRUE;
			$data = 'md.data_type=0';
			$this->setSqlMd();
		} elseif ($data == "_DATA_TYPE_ = '1'") {
			$data = 'md.data_type=1';
			$this->setSqlMd();
		} elseif ($data == "_DATA_TYPE_ = '-1'") {
			$data = 'md.data_type=-1';
			$this->setSqlMd();
		} else {
			$data = str_replace('_DATA_TYPE_', 'md.data_type', $data);
			$data = str_replace("'", '', $data);
			$this->setSqlMd();
		}
		return $data;
	}
	
	private function parserMdFieldDup($data) {
		$data = 'SELECT * FROM md_values WHERE md_id IN(185,5079) AND md_value IN(
			SELECT md_value FROM md_values WHERE md_id IN(185,5079) GROUP BY md_value HAVING COUNT(recno) > 1) 
			ORDER BY md_id, md_value, recno';
		return $data;
	}
	
	private function parserThesaurusKeyword($data) {
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
            SELECT DISTINCT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,24) = substring(m.md_path, 1,24) AND md_values.recno = m.recno)
            WHERE md_values.md_id=88 AND m.md_id=1755 AND md_values.md_value $keyword AND m.md_value $thesaurus
            #WHEREMD#
            UNION
            SELECT DISTINCT md.recno, md.last_update_date, md.title
            FROM (md JOIN md_values ON md.recno=md_values.recno) LEFT JOIN md_values m ON(substring(md_values.md_path, 1,24) = substring(m.md_path, 1,26) AND md_values.recno = m.recno)
            WHERE md_values.md_id=4920 AND m.md_id=4925 AND md_values.md_value $keyword AND m.md_value $thesaurus
        ";
		return $rs;
	}
    
	private function parserData($data, $con) {
		$rs = '';
		if ($data{0} == '%') {
			$rs = $this->parserSearchText($data, $con);
		} elseif ($data{0} == '@') {
			$rs = $this->parserMdMapping($data, $con);
		} elseif ($data{0} == '/') {
			$rs = $this->parserXmlPath($data, $con);
		} elseif ($data{0} == '_') {
			$rs = $this->parserMdField($data, $con);
		}
		return $rs;
	}

	private function isSimpleQuery() {
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

	private function walkQueryInSimple() {
		$con = 'AND';
		foreach ($this->query_in as $field) {
			if ($field{0} == '%' || $field{0} == '@' || $field{0} == '_' || $field{0} == '/') {
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
        $sql_smd = 'SELECT recno, last_update_date, COALESCE((xpath(\'//gmd:identificationInfo/*/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[contains(@locale, "' . $this->appLang . '")]/text()\', pxml, ARRAY[ARRAY[\'gmd\', \'http://www.isotc211.org/2005/gmd\']]))[1]::text, title) AS title FROM md';
		$sql_s = 'SELECT DISTINCT md.recno, md.last_update_date, md.title FROM md JOIN md_values ON md.recno=md_values.recno';
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

	private function walkSqlArray($in) {
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
				if ($field{0} == '%' || $field{0} == '@' || $field{0} == '_' || $field{0} == '/') {
					$sql_row = $this->parserData($field, NULL);
                    $sql_row = str_replace('#WHEREMD#', '', $sql_row);
					$grpBy = '';
					$sql_s = 'SELECT DISTINCT md.recno, md.last_update_date, md.title FROM md JOIN md_values ON md.recno=md_values.recno';
					if (strpos($sql_row, 'md_values.') === FALSE) {
                        $sql_s = 'SELECT recno, last_update_date, COALESCE((xpath(\'//gmd:identificationInfo/*/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[contains(@locale, "' . $this->appLang . '")]/text()\', pxml, ARRAY[ARRAY[\'gmd\', \'http://www.isotc211.org/2005/gmd\']]))[1]::text, title) AS title FROM md';
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

	function getSql($type, $user, $ofs=0, $orderBy='' ) {
		if ($this->bbox == NULL && is_array($orderBy) && $orderBy[0] == 'bbox') {
            //$this->sortBy = getSortBy(SORT_BY, $ret='array');
			$orderBy = '';
		}
		if ($orderBy == '') {
			$orderBy = $this->sortBy;
		}
		$sql = '';
		if ($type == '' || $user == '') {
			return $sql;
		}
		$sortBy = $orderBy[0] . ' ' . $orderBy[1];
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
        $sql_spol['md_select'] =  "SELECT recno, uuid, md_standard, lang, data_type, create_user, create_date, last_update_user, last_update_date, edit_group, view_group, valid, prim, xmldata AS pxml, server_name".$this->for_inspire;
        $sql_spol['md_from'] = " FROM md WHERE (recno IN (SELECT recno FROM(";
        $sql_spol['md_order'] = "";
        $sql_spol['md_count'] =  "
            SELECT 	count(DISTINCT recno) AS Celkem
        ";
		$sql_spol['md_in_end'] =  ")";
		$sql_spol['md_where_end'] =  ")";
		if ($type == 'count') {
			if ($this->useOrderByXmlPath === TRUE) {
                $sql_final = str_replace(
                    'SELECT DISTINCT md.recno, md.last_update_date, md.title',
                    'SELECT DISTINCT md.recno, md.last_update_date, COALESCE((xpath(\'//gmd:identificationInfo/*/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[contains(@locale, "' . $this->appLang . '")]/text()\', pxml, ARRAY[ARRAY[\'gmd\', \'http://www.isotc211.org/2005/gmd\']]))[1]::text, title) AS title',
                    $this->sql_final[0]
                );
			} else {
				$sql_final = $this->sql_final[0];
			}
			$sql = "SELECT 	count(DISTINCT recno) AS Celkem FROM md WHERE (recno IN (SELECT recno FROM("
						. $sql_final
						. ') jojo))';
		} elseif ($type == 'find') {
            $sql_final = $this->sql_final[0];
            if ($this->useOrderByXmlPath === TRUE) {
                $sql_final = str_replace(
                    'SELECT DISTINCT md.recno, md.last_update_date, md.title',
                    'SELECT DISTINCT md.recno, md.last_update_date, COALESCE((xpath(\'//gmd:identificationInfo/*/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[contains(@locale, "' . $this->appLang . '")]/text()\', pxml, ARRAY[ARRAY[\'gmd\', \'http://www.isotc211.org/2005/gmd\']]))[1]::text, title) AS title',
                    $sql_final
                );
                $sql_spol['md_select'] .= ', COALESCE((xpath(\'//gmd:identificationInfo/*/gmd:citation/*/gmd:title//gmd:LocalisedCharacterString[contains(@locale, "' . $this->appLang . '")]/text()\', pxml, ARRAY[ARRAY[\'gmd\', \'http://www.isotc211.org/2005/gmd\']]))[1]::text, title) AS title';
            }
            $sql_final = str_replace('AS title', 'AS title ' . $selectBbox, $sql_final);
            if ($this->paginator === TRUE) {
                $select_limit = " LIMIT " . $this->maxRecords . " OFFSET $ofs";
            } else {
                $select_limit = "";
            }
            $sql =  $sql_spol['md_select'] . $selectBbox
                        . $sql_spol['md_from']
                        . $sql_final
                        . ") jojo ORDER BY $sortBy $select_limit)) ORDER BY $sortBy $sortBy_mdpath";
		}
		return $sql;
	}

	private function setQuery($in) {
		$rs = array();
		$this->setSqlMd();
		if (is_array($in)) {
			if (count($in) == 0 && $this->sql_uuid == '') {
				$this->setSqlEmptyIn();
			}
			elseif (count($in) == 1 && is_array($in[0]) === TRUE &&  count($in[0]) == 0 && $this->sql_uuid == '') {
				$this->setSqlEmptyIn();
			}
			elseif (count($in) == 0 && $this->sql_uuid != '') {
				$this->sql_final[0] = 'SELECT recno, last_update_date, title FROM md WHERE uuid IN ' . $this->sql_uuid;
			}
			else {
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
		}
		else {
			return -1;
		}

		if ($sql == -1 || $sql == '') {
			return -1;
		}
		
		if ($this->search_uuid === TRUE) {
			$rs['paginator']['records'] = 1;
			$rs['sql'] = "SELECT recno, uuid, md_standard, lang, data_type, create_user, create_date, last_update_user, last_update_date, edit_group, view_group, valid, prim, server_name, xmldata AS pxml".$this->for_inspire." FROM md";
            $right = $this->appParameters['app']['directSummary'] === TRUE 
                    || $this->appParameters['app']['directDetail'] === TRUE 
                    || $this->appParameters['app']['directXml'] === TRUE
                    ? '' 
                    : $this->getRight();
			$rs['sql'] .= " WHERE " . $right . " uuid IN " . $this->sql_uuid;
			return $rs;
		}
		$founds = $this->getPaginator($sql, $this->maxRecords, $this->page_number);
		if ($founds == -1) {
            
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
    
    private function isMemberGroup($group) {
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
    
	private function getHarvestor($server_name) {
		$rs = array();
		$rs['harvest_source'] = '';
		$rs['harvest_title'] = '';
		if ($server_name != '') {
            $data = $this->db->query('SELECT harvest.source, md.title FROM harvest JOIN md ON md.uuid = harvest.name WHERE harvest.name=?', $server_name)->fetchAll();
			foreach ($data as $row) {
				$rs['harvest_source'] = $data->source;
				$rs['harvest_title'] = $data->title;
            }
		}
		return $rs;
	}
    
	private function setNumberOfRecords($startPosition, $founds) {
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

    public function getXmlRecords($in=array(), $params=array()) {
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
            $records = $this->db->query($pom['sql'])->fetchAll();
            if ($this->search_uuid === TRUE) {
                $numberOfRecods = $this->setNumberOfRecords($this->startPosition+1, count($records));
            }
            foreach ($records as $row) {
                $row->edit = 0;
                if ($this->isMemberGroup($row->edit_group) || $this->user->isInRole('admin')) {
                    $row->edit = 1;
                }
                if ($this->user->isLoggedIn() && $row->create_user == $this->user->getIdentity()->username) {
                    $row->edit = 1;
                }
                $row->read = $row->edit == 1 ? 1 : 0;
                if ($row->read == 0) {
                    if ($this->isMemberGroup($row->view_group)
                            || $row->data_type > 0) {
                        $row->read = 1;
                    }
                }
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
                        ' read="' . $row->read . '"' .
                        ' edit="' . $row->edit . '">' .
                        $row->pxml .
                        "</rec>";
            }
        }
        $result = "<results numberOfRecordsMatched=\"".$numberOfRecods['Matched']."\" numberOfRecordsReturned=\"".$numberOfRecods['Return']."\" nextRecord=\"".$numberOfRecods['Next']."\" elementSet=\"brief\">";
        return $result.$rs."</results>";
    }
    
    public function fetchXmlOpen($in=array(), $params=array()) {
		$this->setFlatParams($params);
		$this->setQueryIn($in);
		$in = $this->query_in;
		$pom = $this->setQuery($in);
        if ($pom == -1) {
			return -1;
		}
        if ($pom['paginator']['records'] > 0 && $pom['sql'] != '' && $this->hits === FALSE) {
            $this->db->query('SET transaction_read_only=true');
            $this->db->beginTransaction();
            $this->db->query('DECLARE xml_cursor NO SCROLL CURSOR FOR ('.$pom['sql'].')');
        }
        return $pom['paginator']['records'];
    }
    
    public function fetchXml($count=1) {
        $result = FALSE;
        $data = $this->db->query("FETCH $count FROM xml_cursor")->fetchAll();
        if (count($data) > 0) {
            foreach ($data as $row) {
                $row->edit = 0;
                if ($this->isMemberGroup($row->edit_group) || $this->user->isInRole('admin')) {
                    $row->edit = 1;
                }
                if ($this->user->isLoggedIn() && $row->create_user == $this->user->getIdentity()->username) {
                    $row->edit = 1;
                }
                $row->read = $row->edit == 1 ? 1 : 0;
                if ($row->read == 0) {
                    if ($this->isMemberGroup($row->view_group)
                            || $row->data_type > 0) {
                        $row->read = 1;
                    }
                }
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
                        ' read="' . $row->read . '"' .
                        ' edit="' . $row->edit . '">' .
                        $row->pxml .
                        "</rec>";
                }
            $numberOfRecods = ['Matched' => 1, 'Return' => 1, 'Next' => 0];
            $result = "<results numberOfRecordsMatched=\"".$numberOfRecods['Matched']."\" numberOfRecordsReturned=\"".$numberOfRecods['Return']."\" nextRecord=\"".$numberOfRecods['Next']."\" elementSet=\"brief\">"
                    . $rs . "</results>";
        }
        return $result;
    }
    
    public function fetchXmlClose() {
        $this->db->query('CLOSE xml_cursor');
        $this->db->commit();
    }
}

