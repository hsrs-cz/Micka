<?php
namespace App\Model;

class ArrayMdXml2MdValues extends \BaseModel
{
    private $arrayXml=[];
    private $md_standard = 0;
    private $standard_schema = false;
	private $md_values = [];
	private $del_md_id = [];
	private $md = [];
    public $lang;
	
	public function startup()
	{
		parent::startup();
	}
    
	private function setMds() 
    {
		if (key($this->arrayXml) == 'MD_Metadata') {
			$this->md_standard = 0;
		}
		elseif (key($this->arrayXml) == 'metadata') {
            $this->md_standard = 1;
		}
		elseif (key($this->arrayXml) == 'featureCatalogue') {
            $this->md_standard = 2;
		}
	}
    
	private function setElementsData($data) 
    {
		return "'" . $data->md_id . '|' . $data->package_id . '|' . $data->multi_lang . '|' . $data->form_code . "'";
	}
    
	private function getElementsData($path_el) 
    {
		$rs = [];
		$data = '';
		$eval_text = '$data=isset($this->standard_schema' . $path_el . "['_p_']"
                . ') ? $this->standard_schema' . $path_el . "['_p_']" . " : '';";
		eval($eval_text);
		if ($data != '') {
			$pom = explode('|', $data);
			if (count($pom) == 4) {
				$rs['md_id'] = $pom[0];
				$rs['package_id'] = $pom[1];
				$rs['multi_lang'] = $pom[2];
				$rs['form_code'] = $pom[3];
			}
		}
		return $rs;
	}
	
	private function setReport($recno, $mode, $text) {
        $text = str_replace(
            array("['", "[0]", "']"),
            array("/","",""),
            $text 
        );
        if ($recno > -1) {
            switch ($mode) {
                case 'info':
                case 'error':
                    $this->md[$recno]['report'] = isset($this->md[$recno]['report'])
                        ? $this->md[$recno]['report'] . "$text\n"
                        : "$text\n";
                    break;
                default:
            }
        }
	}
    
	private function setStandardSchema() 
    {
		$eval_text = '';
		$result = $this->db->query("
			SELECT	standard_schema.md_id, standard_schema.md_path_el, 
                standard_schema.package_id, standard_schema.md_left, 
                standard_schema.md_right, elements.multi_lang, elements.form_code
            FROM standard_schema INNER JOIN elements ON standard_schema.el_id = elements.el_id
            WHERE standard_schema.md_standard=?
		", $this->md_standard);
		if (count($result) < 1) {
			$this->standard_schema = false;
		}
		foreach ($result as $row) {
			$el_path = $row->md_path_el;
			$el_path = str_replace("/","']['",$el_path);
			$el_path = substr($el_path,2) . "']";
			$eval_text = '$this->standard_schema' . $el_path . "['_p_']=" . $this->setElementsData($row) . ";";
			eval($eval_text);
	  }
	}
    
	private function setArayMdValues($md_id, $md_path, $package_id, $md_value, $recno, $md_lang, $multi_lang, $form_code) {
		$rs = [];
		$rs['ok'] = FALSE;
		$rs['type'] = 'error';
		$rs['report'] = '?';

		if ($md_id == '') {
			$rs['report'] = 'ERROR(elements2mdid)';
			return $rs;
		}
		
		if ($md_value !== '') {
			$record = array();
			$record['md_id'] = $md_id;
			if ($form_code == 'N') {
				if (is_numeric($md_value) === FALSE) {
					$rs['type'] = 'error';
					$rs['report'] = 'bad format number';
					return $rs;
				}
			}
            $md_value = str_replace('\"', '"', $md_value);
			$record['md_value'] = $md_value;
			$record['md_path'] = '0_' . $md_path;
			if ($multi_lang == 0) {
				$record['lang'] = 'xxx';
			}
			elseif ($multi_lang == 1 && $md_lang != 'xxx') {
				$record['lang'] = $md_lang;
			}
			else {
				$record['lang'] = $this->md[$recno]['lang'];
			}
			$record['package_id'] = $package_id;
			$this->md_values[$recno][]=$record;
		}
		$this->del_md_id[$recno][$md_id] = 1;
		$rs['ok'] = TRUE;
		return $rs;
	}
    
	private function setLangMd($recno) {
        switch ($this->md_standard) {
            case 0:
                $this->md[$recno]['lang'] = 
                    isset($this->arrayXml['MD_Metadata'][$recno]['language'][0]['LanguageCode'][0]['@'])
                    ? $this->arrayXml['MD_Metadata'][$recno]['language'][0]['LanguageCode'][0]['@']
                    : '';
                break;
            case 1:
                $this->md[$recno]['lang'] = 
                    isset($this->arrayXml['metadata'][$recno]['language'][0]['@'])
                    ? $this->arrayXml['metadata'][$recno]['language'][0]['@']
                    : '';
                break;
            default:
        }
        if ($this->md[$recno]['lang'] == '') {
            $this->md[$recno]['lang'] = $this->lang;
        }
        switch ($this->md[$recno]['lang']) {
            case 'en':
                $this->md[$recno]['lang'] = 'eng';
                break;
            case 'fra':
                $this->md[$recno]['lang'] = 'fre';
                break;
            default:
        }
	}

	private function setLangsMd($recno, $iso_lang) {
		$lang_change = FALSE;
		$md_lang = array();
		switch ($iso_lang) {
		case 'MD':
			if(isset($this->arrayXml['MD_Metadata'][$recno]['locale']) && is_array($this->arrayXml['MD_Metadata'][$recno]['locale'])) {
				foreach ($this->arrayXml['MD_Metadata'][$recno]['locale'] as $value) {
                    $l = $value['PT_Locale'][0]['languageCode'][0]['LanguageCode'][0]['@'];
                    if ($lang_change && $l != '') {
                        // změna výchozího jazyka
                        $this->md[$recno]['lang'] = $l;
                        $this->arrayXml['MD_Metadata'][$recno]['language'][0]['LanguageCode'][0]['@'] = $l;
                    }
                    switch ($l) {
                        case 'en':
                            $l = 'eng';
                            break;
                        case 'fra':
                            $l = 'fre';
                            break;
                        default:
                    }
                    if ($l != '') {
                        $md_lang[] = $l;
                    }
				}
                unset($this->arrayXml['MD_Metadata'][$recno]['locale']);
			} elseif(isset($this->arrayXml['MD_Metadata'][$recno]['identificationInfo'][0]['MD_DataIdentification'][0]['citation'][0]['CI_Citation'][0]['title'][0])
				&& is_array($this->arrayXml['MD_Metadata'][$recno]['identificationInfo'][0]['MD_DataIdentification'][0]['citation'][0]['CI_Citation'][0]['title'][0])) {
				foreach ($this->arrayXml['MD_Metadata'][$recno]['identificationInfo'][0]['MD_DataIdentification'][0]['citation'][0]['CI_Citation'][0]['title'][0] as $key=>$value) {
					if (substr($key,0,1) == '@') {
						$l = substr($key,1);
						if ($lang_change && $l != '') {
							$this->md[$recno]['lang'] = $l;
							$this->arrayXml['MD_Metadata'][$recno]['language'][0]['LanguageCode'][0]['@'] = $l;
						}
						switch ($l) {
							case '':
								if ($value != '') {
									$l = $this->md[$recno]['lang'];
								}
								else {
                                    $l = '';
                                    $lang_change = TRUE;
								}
								break;
							case 'en':
								$l = 'eng';
								break;
							case 'fra':
								$l = 'fre';
								break;
							default:
						}
						if ($l != '') {
							$md_lang[] = $l;
						}
					}
				}
			}
		case 'MS':
		case 'MC':
			if(isset($this->arrayXml['MD_Metadata'][$recno]['locale']) && is_array($this->arrayXml['MD_Metadata'][$recno]['locale'])) {
				foreach ($this->arrayXml['MD_Metadata'][$recno]['locale'] as $value) {
                    $l = $value['PT_Locale'][0]['languageCode'][0]['LanguageCode'][0]['@'];
                    if ($lang_change && $l != '') {
                        $this->md[$recno]['lang'] = $l;
                        $this->arrayXml['MD_Metadata'][$recno]['language'][0]['LanguageCode'][0]['@'] = $l;
                    }
                    switch ($l) {
                        case 'en':
                            $l = 'eng';
                            break;
                        case 'fra':
                            $l = 'fre';
                            break;
                        default:
                    }
                    if ($l != '') {
                        $md_lang[] = $l;
                    }
				}
                unset($this->arrayXml['MD_Metadata'][$recno]['locale']);
			} elseif(isset($this->arrayXml['MD_Metadata'][$recno]['identificationInfo'][0]['SV_ServiceIdentification'][0]['citation'][0]['CI_Citation'][0]['title'][0])
				&& is_array($this->arrayXml['MD_Metadata'][$recno]['identificationInfo'][0]['SV_ServiceIdentification'][0]['citation'][0]['CI_Citation'][0]['title'][0])) {
				foreach ($this->arrayXml['MD_Metadata'][$recno]['identificationInfo'][0]['SV_ServiceIdentification'][0]['citation'][0]['CI_Citation'][0]['title'][0] as $key=>$value) {
					if (substr($key,0,1) == '@') {
						$l = substr($key,1);
						if ($lang_change && $l != '') {
							$this->md[$recno]['lang'] = $l;
							$this->arrayXml['MD_Metadata'][$recno]['language'][0]['LanguageCode'][0]['@'] = $l;
						}
						switch ($l) {
							case '':
								if ($value != '') {
									$l = $this->md[$recno]['lang'];
								}
								else {
                                    $l = '';
                                    $lang_change = TRUE;
								}
								break;
							case 'en':
								$l = 'eng';
								break;
							case 'fra':
								$l = 'fre';
								break;
							default:
						}
						if ($l != '') {
							$md_lang[] = $l;
						}
					}
				}
			} 
			break;
		case 'DC':
			break;
		case 'FC':
			break;
		default:
		}
        
		$md_lang[] = $this->md[$recno]['lang'];
		$md_lang = array_unique($md_lang);
		$this->md[$recno]['langs'] = implode($md_lang, '|');
	}
    
	private function processArrayMd($md, $level=0, $elements='', $path_el='', $recno_in='', $path_md='', $md_lang='xxx')
    {
        $level++;
        $el_pom = '';
        foreach ($md as $key => $item) {
            if ($level == 2) {
                $recno_in = $key;
            }
            if ($level != 2) {
                $el_pom = $elements;
                $path_pom = $path_el;
                $path_md_pom = $path_md;
            }
            if (is_array($item)) {
                if ($level != 2) {
                    if(is_numeric($key)) {
                        $elements .= "[" . $key . "]";
                        $path_md .= $key . "_";
                    } else {
                        $elements .= "['" . $key . "']";
                        $path_el .= "['" . $key . "']";
                        $pom = $this->getElementsData($path_el);
                        $path_md .= $pom['md_id'] . "_";
                    }
                }
                $this->processArrayMd($item, $level, $elements, $path_el, $recno_in, $path_md, $md_lang);
            } else {
                if(is_numeric($key)) {
                    $elements .= "[" . $key . "]";
                    $path_md .= $key . "_";
                } else {
                    if ($key{0} == '@') { // lang
                        if (strlen($key) > 1) {
                            $md_lang = substr($key,1);
                        }
                    } else {
                        $elements .= "['" . $key . "']";
                        $path_el .= "['" . $key . "']";
                        $pom = $this->getElementsData($path_el);
                        $path_md .= $pom['md_id'] . "_0_";
                    }
                }
                if(substr_count($elements,"']['") > 1) {
                    $this->setReport($recno_in, 'error', labelTranslation(MICKA_LANG, 'ERROR (path)') . " $elements = $item");
                    $this->addLogImport('processArrayMd', labelTranslation(MICKA_LANG, 'ERROR (path)') . " $elements = $item");
                } else { // OK
					$pom = $this->getElementsData($path_el);
					if (count($pom) == 0) {
                        $md_id = '';
                        $md_package_id = '';
                        $multi_lang = '';
                        $form_code = '';
					} else {
                        $md_id = $pom['md_id'];
                        $md_package_id = $pom['package_id'];
                        $multi_lang = $pom['multi_lang'];
                        $form_code = $pom['form_code'];
					}
					$save = $this->setArayMdValues($md_id,$path_md,$md_package_id,$item,$recno_in,$md_lang,$multi_lang, $form_code);
					if ($save['ok'] !== TRUE) {
                        $this->setReport($recno_in, $save['type'], $save['report'] . " $elements = $item");
					} 
                }
                $md_lang = 'xxx';
            }
            if ($level == 2) {
                $path_pom = $path_el;
                $path_md_pom = $path_md;
            }
            $elements = $el_pom;
            $path_el  = $path_pom;
            $path_md  = $path_md_pom;
        } //end foreach
        $level--;
	}
    
	private function setMd() {
		if (array_key_exists('MD_Metadata', $this->arrayXml)) {
			foreach ($this->arrayXml['MD_Metadata'] as $x=>$md) {
				$this->md[$x]['iso'] = isset($md['identificationInfo'][0]['SV_ServiceIdentification']) ? 'MS' : 'MD';
				if ($this->md[$x]['iso'] == 'MS' 
                    && isset($this->arrayXml['MD_Metadata'][$x]['hierarchyLevelName'][0]['@'])
                    && $this->arrayXml['MD_Metadata'][$x]['hierarchyLevelName'][0]['@'] == 'MapContext') {
					//   /MD_Metadata/hierarchyLevelName
					$this->md[$x]['iso'] = 'MC';
				}
				// uuid
				$this->md[$x]['uuid'] = '';
				if (isset($this->arrayXml['MD_Metadata'][$x]['fileIdentifier'][0]['@']) && $this->arrayXml['MD_Metadata'][$x]['fileIdentifier'][0]['@'] != '') {
					$this->md[$x]['uuid'] = $this->arrayXml['MD_Metadata'][$x]['fileIdentifier'][0]['@'];
				}
				$this->setLangMd($x, $this->md[$x]['iso']);
				$this->setLangsMd($x, $this->md[$x]['iso']);
			}
		}
		if (array_key_exists('metadata', $this->arrayXml)) {
			foreach ($this->arrayXml['metadata'] as $x=>$md) {
				$this->md[$x]['iso'] = 'DC';
				// uuid
				$this->md[$x]['uuid'] = '';
				if (isset($this->arrayXml['metadata'][$x]['identifier']) && is_array($this->arrayXml['metadata'][$x]['identifier'])) {
					$z = -1;
					for ($y = 0; $y < count($this->arrayXml['metadata'][$x]['identifier']); $y++) {
						if (isset($this->arrayXml['metadata'][$x]['identifier'][$y]['@']) && $this->arrayXml['metadata'][$x]['identifier'][$y]['@'] != '') {
							$pom = $this->getDcUuid($this->arrayXml['metadata'][$x]['identifier'][$y]['@']);
							if ($pom != -1) {
								$this->md[$x]['uuid'] = $pom;
								$z = $y;
								break;
							}
						}
					}
					if ($z > -1) {
						//odstarnění uuid z pole
						array_splice($this->arrayXml['metadata'][$x]['identifier'],$z,1);
					}
				}
				$this->setLangMd($x, $this->md[$x]['iso']);
				$this->setLangsMd($x, $this->md[$x]['iso']);
			}
		}
		if (array_key_exists('featureCatalogue', $this->arrayXml)) {
			foreach ($this->arrayXml['featureCatalogue'] as $x=>$md) {
				$this->md[$x]['iso'] = 'FC';
				// uuid
				$this->md[$x]['uuid'] = '';
				$z = -1;
				for ($y = 0; $y < count($this->arrayXml['featureCatalogue'][$x]['id']); $y++) {
					if (isset($this->arrayXml['featureCatalogue'][$x]['id'][$y]['@']) && $this->arrayXml['featureCatalogue'][$x]['id'][$y]['@'] != '') {
						$this->md[$x]['uuid'] = $this->arrayXml['featureCatalogue'][$x]['id'][$y]['@'];
					}
				}
				if ($z > -1) {
					//odstarnění uuid z pole
					array_splice($this->arrayXml['featureCatalogue'][$x]['id'],$z,1);
				}
				$this->setLangMd($x, $this->md[$x]['iso']);
				$this->setLangsMd($x, $this->md[$x]['iso']);
			}
		}
	}
    
	public function getMdFromArrayXml($arrayXml) {
        $rs = [];
		if (is_array($arrayXml) === FALSE) {
			$rs['report'] = 'input data is not array';
			return $rs;
		}
		if (count($arrayXml) == 0) {
			$rs['report'] = 'input data is empty';
			return $rs;
		}
		$this->arrayXml = $arrayXml;
        $this->setMds();
        $this->setStandardSchema();
        $this->setMd();
        $this->processArrayMd($this->arrayXml);
        $rs = ['report' => 'ok', 
            'md' => $this->md, 
            'md_values' =>  $this->md_values,
            'del_md_id' => $this->del_md_id];
		return $rs;
	}
}

