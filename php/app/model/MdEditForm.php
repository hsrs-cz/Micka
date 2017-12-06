<?php

namespace App\Model;

use Nette;

class MdEditForm  extends \BaseModel
{
    private $appParameters;
	private $form_values = array();
	private $form_data = array();
	private $md_first_lang = 'eng';
	private $md_langs = array();
	private $code_list_array = array();
	private $button_label = array();
	private $mds;
    private $md_id_data = array();
    private $standard_schema_model = array();
    private $form_standard_schema = array();
    public  $appLang = 'eng';
    
    public function setAppParameters($appParameters)
    {
        $this->appParameters = $appParameters;
    }

	private function setFormValuesArray($md_values) {
		$rs = array();
        foreach($md_values as $row) {
            $md_path = getMdPath($row->md_path);
            if ($this->mds == 0 || $this->mds == 10) {
                if ($row->md_id == 5527 && strlen(trim($row->md_value)) == 3) {
                    $this->md_first_lang = trim($row->md_value);
                }
            }
            $eval_text = '$rs' . $md_path . "['" . $row->lang . "']" . "=\"" . gpc_addslashes($row->md_value) . "\";";
            eval($eval_text);
        }
		$this->sortMdLangs();
		$this->form_values = $rs;
	}
	
	private function sortMdLangs() {
		if (count($this->md_langs) > 1 && $this->md_langs[0] != $this->md_first_lang) {
			$key = array_search($this->md_first_lang, $this->md_langs);
			if ($key === FALSE) {
				$this->md_first_lang = MICKA_LANG;
				$key = array_search($this->md_first_lang, $this->md_langs);
			}
			if ($key !== FALSE) {
				array_splice($this->md_langs, $key, 1);
				array_unshift($this->md_langs, $this->md_first_lang);
			}
		}
	}
	
	private function setCodeListArray($inspire=FALSE) {
		$sql = "
			SELECT codelist.el_id, label.label_text, codelist.codelist_id, codelist.codelist_domain, codelist.codelist_name
			FROM (label INNER JOIN codelist ON label.label_join = codelist.codelist_id)
				LEFT JOIN codelist_my ON codelist.codelist_id = codelist_my.codelist_id
			WHERE label.label_type='CL' AND label.lang=?  AND codelist_my.is_vis=1
		";
		if ($inspire) {
			$sql .= ' AND codelist.inspire=1';
		}
		$records = $this->db->query($sql, $this->appLang)->fetchAll();
		foreach ($records as $row) {
			$el_id = $row->el_id;
			$cl_id = $row->codelist_id;
			$this->code_list_array[$el_id][$cl_id]['t'] = $row->label_text;
			$this->code_list_array[$el_id][$cl_id]['d'] = $row->codelist_domain;
			$this->code_list_array[$el_id][$cl_id]['n'] = $row->codelist_name;
		}
	}

	private function setButtonLabelArray() {
        $this->button_label = $this->db->query("SELECT label_text, label_join
                FROM label
                WHERE lang=? AND label.label_type=?
                ORDER BY label_text
            ",$this->appLang, 'BT')->fetchAll();
	}

	private function getComboCodeList($from_codelist, $md_value) {
		$rs = '';
		if ($from_codelist == '') {
            // SET ERROR2LOG
			return $rs;
		}
		$from_codelist = (int) $from_codelist;
		$pom_from_codelist = ABS($from_codelist);
		if (array_key_exists($pom_from_codelist, $this->code_list_array)) {
			foreach ($this->code_list_array[$pom_from_codelist] as $pom_value) {
				if ($from_codelist == 1460 && $this->mds == 0 && $pom_value['d'] < 0) {
					continue;
				}
				if ($from_codelist == 1460 && $this->mds == 10 && $pom_value['d'] > 0) {
					continue;
				}
                $pom_t = $pom_value['t'];
                $pom_d = $pom_value['d'];
                $pom_n = $pom_value['n'];
				if ($from_codelist > 0) {
					if ($md_value == $pom_n) {
						$rs .= '<option value="' . $pom_n . '" selected>' . $pom_t;
					}
					else {
						$rs .= '<option value="' . $pom_n . '">' . $pom_t;
					}
				}
				elseif ($from_codelist < 0) {
					if ($md_value == $pom_d) {
						$rs .= '<option value="' . $pom_d . '" selected>' . $pom_t;
					}
					else {
						$rs .= '<option value="' . $pom_d . '">' . $pom_t;
					}
				}
			}
		}
		return $rs;
	}

	private function getMdValue($is_label, $md_path, $value_lang) {
		$rs = '';
		if ($md_path == '' || $value_lang == '') {
            // SET ERROR2LOG
		}
		else {
            if ($is_label == 0) {
                $path = getMdPath($md_path) . "['" . $value_lang . "']";
                $eval_label = '$rs=isset($this->form_values' . $path . ') ? $this->form_values' . "$path : '';";
                eval ($eval_label);
            }
		}
		return $rs;
	}

    public function getValuesUri($recno) {
		$sql = "SELECT md_path, md_value FROM edit_md_values WHERE recno=? AND lang='uri'";
        return $this->db->query($sql, $recno)->fetchPairs();
    }
    
	private function getButtonExe($button) {
		$rs = array();
		$rs['text'] = '';
		$rs['action'] = '';
		if ($button != '') {
			$pom = explode('|', $button);
			$rs['action'] = $pom[0];
			$button_id = isset($pom[1]) ? $pom[1] : '';
			$rs['text'] = isset($this->button_label[$button_id]) ? $this->button_label[$button_id]->label_text : '';
		}
		return $rs;
	}

	private function getIsData($md_path) {
		$rs = FALSE;
		$path = getMdPath($md_path);
		$eval_label = '$rs=isset($this->form_values' . $path . ') ? TRUE : FALSE;';
		eval ($eval_label);
		return $rs;
	}

	private function getMdStandardSchema($recno, $mds, $profil_id, $package_id, $md_id_start=-1) {
		if ($mds == 10) {
			$mds = 0;
		}
		$sql = "
			SELECT elements.el_id,
						 elements.el_name,
						 elements.form_code,
						 elements.form_pack,
						 elements.el_short_name,
						 elements.from_codelist,
						 elements.only_value,
						 elements.form_ignore,
						 elements.multi_lang,
						 standard_schema.md_id,
						 standard_schema.md_left,
						 standard_schema.md_right,
						 standard_schema.md_level,
						 standard_schema.mandt_code,
						 standard_schema.md_path,
						 standard_schema.max_nb,
						 standard_schema.button_exe,
						 standard_schema.package_id,
                         standard_schema.inspire_code,
                         standard_schema.is_uri,
						 label.label_text,
						 label.label_help
			FROM (label INNER JOIN elements ON label.label_join = elements.el_id) INNER JOIN standard_schema ON elements.el_id = standard_schema.el_id
            WHERE label.label_type='EL'
                AND standard_schema.md_standard=$mds
                AND label.lang='$this->appLang'
        ";
		if ($profil_id > -1) {
			$sql .= " AND standard_schema.md_id IN(SELECT md_id FROM profil WHERE profil_id=$profil_id)";
		}
		if ($md_id_start > -1) {
            $pom = $this->db->query("SELECT md_left, md_right FROM standard_schema WHERE md_standard=? AND md_id=?", $mds, $md_id_start)->fetchAll();
            foreach ($pom as $row) {
				$md_left = $row->md_left;
				$md_right  = $row->md_right;
				$sql .= " AND standard_schema.md_left>=$md_left  AND standard_schema.md_right<=$md_right";
            }
		}
		if ($profil_id == -1 && $package_id > -1 && $md_id_start == -1) {
            $pom = $this->db->query("
                SELECT md_left, md_right FROM standard_schema WHERE md_standard=? AND md_id=
                (SELECT md_id FROM packages WHERE md_standard=? AND package_id=?)
            ", $mds, $mds, $package_id)->fetchAll();
            foreach ($pom as $row) {
				$md_left = $row->md_left;
				$md_right  = $row->md_right;
				$sql .= " AND standard_schema.md_left>=$md_left  AND standard_schema.md_right<=$md_right";
            }
		}
		if ($package_id > -1) {
			$sql .=  " AND standard_schema.package_id=$package_id";
		}
		if ($mds == 1) {
			$sql .= " ORDER BY standard_schema.md_level,standard_schema.md_left";
		}
		else {
			$sql .= " ORDER BY standard_schema.md_left";
		}
		return $this->db->query($sql)->fetchAll();;
	}
    
    private function isInspirePackage($mds, $profil) {
        $rs = FALSE;
        if ($mds != '' && $profil != '') {
            $sql = "SELECT is_inspire FROM profil_names WHERE md_standard=? AND profil_id=?";
            if ($this->db->query($sql, $mds, $profil)->fetchField() === 1) {
                $rs = TRUE;
            }
        }
        return $rs;
    }
    
    public function isProfil($mds, $profil_id) {
        if ($this->db->query("SELECT profil_id FROM profil_names
            WHERE is_vis=1 AND md_standard=? AND profil_id=?", $mds, $profil_id)->fetch()
            == NULL) {
            return FALSE;
        } else {
            return TRUE;
        }
    }
    
    public function getEditLiteForm($recordModel, $profil_id, $editLiteTemplate) {
        if ($editLiteTemplate == '') {
            return '';
        }
        //TODO here the profile will be selected
		$template = __DIR__ . '/lite/profiles/' . $editLiteTemplate . '/iso2form.xsl';
		require_once __DIR__ . '/CswClient.php';
		require_once __DIR__ . '/lite/resources/Kote.php';
		$cswClient = new \CSWClient();
		$params = array();
		$params['alabel'] = 'Administrace'; // label Administrace
		$params['plabel'] = 'Veřejný'; // label Public
		$params['recno'] = $recordModel->recno;
		$params['uuid'] = $recordModel->uuid;
		$params['data_type'] = $recordModel->data_type;
		$params['publisher'] = $this->user->isInRole('publisher') ? 1 : 0;
		$params['saver'] = 1;
		$params['select_profil'] = $profil_id;
		$params['mds'] = $recordModel->md_standard;;
		$params['lang'] = MICKA_LANG;
		$params['mickaURL'] = dirname($_SERVER['SCRIPT_NAME'])== '\\' ? '' : dirname($_SERVER['SCRIPT_NAME']);
		return $cswClient->processTemplate($recordModel->pxml, $template, $params);
    }

    public function getEditForm($mds, $recno, $md_langs, $profil, $package, $md_values) {
        $this->mds = $mds;
        if ($mds == 1 || $mds == 2) {
            $profil = -1;
            $package = -1;
            $md_id_start = -1;
        }
        if ($mds == 0 || $mds == 10) {
            if ($profil > 0 && !$this->isProfil($mds, $profil)) {
                throw new \Nette\Application\ApplicationException('noProfileFound');
            }
        }
		$this->setMdLangsNew($md_langs);
		$this->setCodeListArray($this->isInspirePackage($mds, $profil));
        $this->setFormValuesArray($md_values);
        $this->setButtonLabelArray();
		$md_id_start = -1;
		if ($mds == 10 && $profil == -1 && $package == 1) {
			$md_id_start = 4752;
		}
		if ($mds == 0 && $profil == -1 && $package == 1) {
			$md_id_start = 1;
		}
        $standard_schema_source = $this->getMdStandardSchema($recno, $mds, $profil, $package, $md_id_start);
        foreach ($standard_schema_source as $row) {
            if ($row->md_left+1 == $row->md_right) {
                $md_path = getMdPath($row->md_path);
                $eval_text = '$this->standard_schema_model' . $md_path . "=1;";
                eval($eval_text);
            }
            $this->md_id_data[$row->md_id] = $row;
        }
        $this->form_standard_schema = $this->standard_schema_model[0][0];
        $this->getRepeatFormData(isset($this->form_values[0][0]) ? $this->form_values[0][0] : []);
        $this->getFormData($this->form_standard_schema);
        $rs = $this->form_data;
        return $rs;
    }
    
    private function getFormData($standard_schema, $path='') {
        foreach ($standard_schema as $key_md_id => $row) {
            $end_div_rs = 0;
            $end_div_pack = 0;
            $end_div_rb = 0;
            $path .= $key_md_id.'_';
            foreach ($row as $key_sequence => $value) {
                $path .= $key_sequence.'_';
                $md_id_data = isset($this->md_id_data[$key_md_id]) ? $this->md_id_data[$key_md_id] : array();
                if (isset($md_id_data->md_id)) {
                    if ($key_sequence > 0) {
                        $this->form_data[count($this->form_data)-1]['end_div'][] = 1;
                        if ($end_div_pack == 1) {
                            $this->form_data[count($this->form_data)-1]['end_div'][] = 1;

                        }
                    }
                    $form_row['start_div'] = 1;
                    $form_row['end_div'] = Array(); 
                    $form_row['md_id'] = $md_id_data->md_id;
                    $form_row['md_path'] = '0_0_'.$path;
                    $form_row['el_id'] = $md_id_data->el_id;
                    $form_row['package_id'] = $md_id_data->package_id;
                    if ($md_id_data->form_pack == 1) {
                        $form_row['pack'] = $this->getIsData('0_0_'.$path) ? 2 : 1;
                        $end_div_pack = 1;
                    } else {
                        $form_row['pack'] = 0;
                    }
                    $form_row['repeat'] = $key_sequence;
                    $form_row['value_lang'] = $md_id_data->multi_lang == 0 ? 'xxx' : $this->md_langs[0];
                    $form_row['next_lang'] = 0;
                    if ($md_id_data->form_code == 'R') {
                        if ($key_sequence == 0) {
                            $rb_id = $key_md_id . '_' . $key_sequence;
                        }
                        $form_row['rb'] = 1;
						$form_row['rb_id'] = $this->getRbId($path);
						$form_row['rb_checked'] = $this->getIsData('0_0_'.$path) ? 1 : 0;
                        $end_div_rb = 1;
                    } else {
                        $form_row['rb'] = 0;
                    }
					if ($md_id_data->md_left+1 != $md_id_data->md_right) {
						$form_row['form_code'] = $md_id_data->form_code == 'R' ? 'R' : 'L';
					} else {
                        $form_row['form_code'] = $md_id_data->form_code;
                    }
                    $form_row['value'] = $this->getFormValue(($md_id_data->md_left+1)-$md_id_data->md_right, $md_id_data->form_code, $md_id_data->from_codelist, $md_id_data->el_id, $form_row['value_lang'], '0_0_'.$path);
                    $form_row['mandt_code'] = $md_id_data->mandt_code;
                    $form_row['inspire_code'] = $md_id_data->inspire_code;
                    $form_row['is_uri'] = $md_id_data->is_uri;
                    $form_row['label'] = $md_id_data->label_text;
                    $form_row['help'] = $md_id_data->label_help;
                    $form_row['max_nb'] = $md_id_data->max_nb;
					$pom = $this->getButtonExe(trim($md_id_data->button_exe));
					$form_row['button_text'] = $pom['text'];
					$form_row['button_action'] = $pom['action'];
                    if ($md_id_data->only_value == 1) {
                        $this->form_data[count($this->form_data)-1]['md_path'] = $form_row['md_path'];
                        $this->form_data[count($this->form_data)-1]['value'] = $form_row['value'];
                        $this->form_data[count($this->form_data)-1]['form_code'] = $form_row['form_code'];
                        $this->form_data[count($this->form_data)-1]['value_lang'] = $form_row['value_lang'];
                        $end_div_rs = 1;
                    } elseif ($md_id_data->form_ignore == 1) {
                        $end_div_rs = 1;
                    } else {
                        array_push($this->form_data, $form_row);
                        if (count($this->md_langs) > 1 && $form_row['value_lang'] != 'xxx') {
                            foreach ($this->md_langs as $k => $lang) {
                                if ($k > 0) {
                                    $form_row['next_lang'] = 1;
                                    $form_row['value_lang'] = $lang;
                                    $form_row['value'] = $this->getFormValue(0, $md_id_data->form_code, $md_id_data->from_codelist, $md_id_data->el_id, $lang,  '0_0_'.$path);
                                    array_push($this->form_data, $form_row);
                                }
                            }
                        }
                    }
                }
                if (is_array($value)) {
                    $this->getFormData($value, $path);
                }
                // END SEQUENCE
                // -path sequence
                $path = substr($path, 0,  0-(strlen($key_sequence)+1));
            }
            // END MD_ID
            if ($end_div_rs == 0) {
                $this->form_data[count($this->form_data)-1]['end_div'][] = 1;

            }
            if ($end_div_pack == 1) {
                $this->form_data[count($this->form_data)-1]['end_div'][] = 1;

            }
            if ($end_div_rb == 1) {
                $this->form_data[count($this->form_data)-1]['end_div'][] = 1;

            }
            // -path md_id
            //$path = str_replace($key_md_id.'_', '', $path);
            $path = strrev(preg_replace(strrev("/".$key_md_id.'_'."/"),strrev(''),strrev($path),1));
        }
        
        return $end_div_rs;
    }
    
	private function getFormValue($is_label, $form_code, $from_codelist, $el_id, $value_lang, $md_path) {
		$rs = $this->getMdValue($is_label, $md_path, $value_lang);
		switch ($form_code) {
			case 'D' :
				if ($rs != '' && $this->appLang == 'cze' && strlen($rs) > 4) {
					$rs = dateIso2Cz($rs);
				}
				break;
			//case 'R' :
			//	break;
			case 'C' :
				$from_codelist = ($from_codelist != '') ? $from_codelist : $el_id;
				$rs = $this->getComboCodeList($from_codelist, $rs);
				break;
		}
		return $rs;
	}
    
	private function setMdLangsNew($md_langs) {
		$this->md_langs = getMdLangs($md_langs);
	}
    
	private function getRbId($path) {
        $rs = $path;
        $pom = explode('_', $path);
        $i = count($pom);
        $rs = $pom[$i-5] . '_' . $pom[$i-4];
		return $rs;
	}
    
    private function getRepeatFormData($data, $path='') {
        foreach ($data as $key_md_id => $row) {
            if (is_numeric($key_md_id) === FALSE) {
                continue;
            }
            $path .= $key_md_id.'_';
            foreach ($row as $key_sequence => $value) {
                $path .= $key_sequence.'_';
                if ($key_sequence > 0) {
                    $md_id_data = isset($this->md_id_data[$key_md_id]) ? $this->md_id_data[$key_md_id] : array();
                    if (count($md_id_data) > 0) {
                        $path_new = getMdPath(substr($path, 0,  0-(strlen($key_sequence)+1)));
                        if ($md_id_data->md_left+1 == $md_id_data->md_right) {
                            $eval_label = '$this->form_standard_schema' . $path_new . '['. $key_sequence . ']' . "=1;";
                        } else {
                            $eval_label = '$this->form_standard_schema' . $path_new . '['. $key_sequence . ']' . "=" . '$this->standard_schema_model[0][0]' . getMdPath(substr($md_id_data->md_path, 4)) . ";";
                        }
                        eval ($eval_label);
                    }
                }
                if (is_array($value)) {
                    $this->getRepeatFormData($value, $path);
                }
                $path = substr($path, 0,  0-(strlen($key_sequence)+1));
            }
            $path = $this->str_lreplace($key_md_id.'_', '', $path);
        }
    }
    function str_lreplace($search, $replace, $subject) {
        $pos = strrpos($subject, $search);
        if($pos !== FALSE) {
            $subject = substr($subject, 0, $pos);
        }
        return $subject;
    }    
}
