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
	
    public function __construct($db, $user, $appParameters)
    {
        parent::__construct($db, $user, $appParameters);
        $this->lang = $appParameters['appLang'];
    }

	private function setMds() 
    {
		if (key($this->arrayXml) == 'MD_Metadata') {
			$this->md_standard = 0;
		}
		elseif (key($this->arrayXml) == 'metadata') {
            $this->md_standard = 1;
		}
		elseif (key($this->arrayXml) == 'FC_FeatureCatalogue') {
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
            array("['", "[00]", "']"),
            array("/","",""),
            $text 
        );
        if (strlen($recno) === 2 && $recno[0] === '0') {
            $recno = $recno[1];
        }
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
			SELECT	standard_schema.[md_id], standard_schema.[md_path_el], 
                standard_schema.[package_id], standard_schema.[md_left], 
                standard_schema.[md_right], elements.[multi_lang], elements.[form_code]
            FROM standard_schema INNER JOIN elements ON standard_schema.[el_id] = elements.[el_id]
            WHERE standard_schema.[md_standard]=%i
        ", $this->md_standard)->fetchAll();
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
			$record['md_path'] = $md_path;
			if ($md_lang == 'uri') {
				$record['lang'] = $md_lang;
			} elseif ($multi_lang == 0) {
				$record['lang'] = 'xxx';
			} elseif ($multi_lang == 1 && $md_lang != 'xxx') {
				$record['lang'] = $md_lang;
			} else {
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
        $idx = strlen($recno) === 1 ? "0$recno" : $recno;
        if (strlen($recno) === 2 && $recno[0] === '0') {
            $recno = $recno[1];
        }
        switch ($this->md_standard) {
            case 0:
                $this->md[$recno]['lang'] = 
                    isset($this->arrayXml['MD_Metadata'][$idx]['language']['00']['LanguageCode']['00']['@'])
                    ? $this->arrayXml['MD_Metadata'][$idx]['language']['00']['LanguageCode']['00']['@']
                    : '';
                break;
            case 1:
                $this->md[$recno]['lang'] = 
                    isset($this->arrayXml['metadata'][$idx]['language']['00']['@'])
                    ? $this->arrayXml['metadata'][$idx]['language']['00']['@']
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
        $idx = strlen($recno) === 1 ? "0$recno" : $recno;
        if (strlen($recno) === 2 && $recno[0] === '0') {
            $recno = $recno[1];
        }
		$lang_change = FALSE;
		$md_lang = array();
		switch ($iso_lang) {
		case 'MD':
			if(isset($this->arrayXml['MD_Metadata'][$idx]['locale']) && is_array($this->arrayXml['MD_Metadata'][$idx]['locale'])) {
				foreach ($this->arrayXml['MD_Metadata'][$idx]['locale'] as $value) {
                    $l = $value['PT_Locale']['00']['languageCode']['00']['LanguageCode']['00']['@'];
                    if ($lang_change && $l != '') {
                        // změna výchozího jazyka
                        $this->md[$recno]['lang'] = $l;
                        $this->arrayXml['MD_Metadata'][$idx]['language']['00']['LanguageCode']['00']['@'] = $l;
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
                unset($this->arrayXml['MD_Metadata'][$idx]['locale']);
			} elseif(isset($this->arrayXml['MD_Metadata'][$idx]['identificationInfo']['00']['MD_DataIdentification']['00']['citation']['00']['CI_Citation']['00']['title']['00'])
				&& is_array($this->arrayXml['MD_Metadata'][$idx]['identificationInfo']['00']['MD_DataIdentification']['00']['citation']['00']['CI_Citation']['00']['title']['00'])) {
				foreach ($this->arrayXml['MD_Metadata'][$idx]['identificationInfo']['00']['MD_DataIdentification']['00']['citation']['00']['CI_Citation']['00']['title']['00'] as $key=>$value) {
					if (substr($key,0,1) == '@') {
						$l = substr($key,1);
						if ($lang_change && $l != '') {
							$this->md[$recno]['lang'] = $l;
							$this->arrayXml['MD_Metadata'][$idx]['language']['00']['LanguageCode']['00']['@'] = $l;
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
			if(isset($this->arrayXml['MD_Metadata'][$idx]['locale']) && is_array($this->arrayXml['MD_Metadata'][$idx]['locale'])) {
				foreach ($this->arrayXml['MD_Metadata'][$idx]['locale'] as $value) {
                    $l = $value['PT_Locale']['00']['languageCode']['00']['LanguageCode']['00']['@'];
                    if ($lang_change && $l != '') {
                        $this->md[$recno]['lang'] = $l;
                        $this->arrayXml['MD_Metadata'][$idx]['language']['00']['LanguageCode']['00']['@'] = $l;
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
                unset($this->arrayXml['MD_Metadata'][$idx]['locale']);
			} elseif(isset($this->arrayXml['MD_Metadata'][$idx]['identificationInfo']['00']['SV_ServiceIdentification']['00']['citation']['00']['CI_Citation']['00']['title']['00'])
				&& is_array($this->arrayXml['MD_Metadata'][$idx]['identificationInfo']['00']['SV_ServiceIdentification']['00']['citation']['00']['CI_Citation']['00']['title']['00'])) {
				foreach ($this->arrayXml['MD_Metadata'][$idx]['identificationInfo']['00']['SV_ServiceIdentification']['00']['citation']['00']['CI_Citation']['00']['title']['00'] as $key=>$value) {
					if (substr($key,0,1) == '@') {
						$l = substr($key,1);
						if ($lang_change && $l != '') {
							$this->md[$recno]['lang'] = $l;
							$this->arrayXml['MD_Metadata'][$idx]['language']['00']['LanguageCode']['00']['@'] = $l;
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
		$this->md[$recno]['langs'] = implode('|', $md_lang);
	}
    
	private function processArrayMd($md, $level=0, $elements='', $path_el='', $recno_in='', $path_md='', $md_lang='xxx')
    {
        $level++;
        $el_pom = '';
        foreach ($md as $key => $item) {
            $key2 = strlen($key) === 1 ? "0$key" : $key;
            if (strlen($key) === 2 && $key[0] === '0') {
                $key = $key[1];
            }
            if ($level == 2) {
                $recno_in = $key;
            }
            if ($level != 2) {
                $el_pom = $elements;
                $path_pom = $path_el;
                $path_md_pom = $path_md;
            }
            if (is_array($item)) {
                if ($level === 2) {
                    $path_md .= "00_";
                }  else {
                    if(is_numeric($key)) {
                        $elements .= "[" . $key . "]";
                        $path_md .= $key2 . "_";
                    } else {
                        $elements .= "['" . $key . "']";
                        $path_el .= "['" . $key . "']";
                        $pom = $this->getElementsData($path_el);
                        if (count($pom) === 0) {
                            \Tracy\Debugger::log('Standard schema - not found: ' . $path_el, 'IMPORT');
                            //throw new \Nette\Application\ApplicationException('messages.import.errorFile');
                        } else {
                            $path_md .= $pom['md_id'] . "_";
                        }
                    }
                }
                $this->processArrayMd($item, $level, $elements, $path_el, $recno_in, $path_md, $md_lang);
            } else {
                if(is_numeric($key)) {
                    $elements .= "[" . $key . "]";
                    $path_md .= $key2 . "_";
                } else {
                    if ($key[0] == '@') { // lang
                        if (strlen($key) > 1) {
                            $md_lang = substr($key,1);
                        }
                    } else {
                        $elements .= "['" . $key . "']";
                        $path_el .= "['" . $key . "']";
                        $pom = $this->getElementsData($path_el);
                        $path_md .= $pom['md_id'] . "_00_";
                    }
                }
                if(substr_count($elements,"']['") > 1) {
                    \Tracy\Debugger::log('ERROR (path) ' . "$elements = $item", 'IMPORT');
                    $this->setReport($recno_in, 'error', labelTranslation($this->lang, 'ERROR (path)') . " $elements = $item");
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
			foreach ($this->arrayXml['MD_Metadata'] as $idx=>$md) {
                $recno = $idx;
                if (strlen($recno) === 2 && $recno[0] === '0') {
                    $recno = $recno[1];
                }
				$this->md[$recno]['iso'] = isset($md['identificationInfo']['00']['SV_ServiceIdentification']) ? 'MS' : 'MD';
				if ($this->md[$recno]['iso'] == 'MS' 
                    && isset($this->arrayXml['MD_Metadata'][$idx]['hierarchyLevelName']['00']['@'])
                    && $this->arrayXml['MD_Metadata'][$idx]['hierarchyLevelName']['00']['@'] == 'MapContext') {
					//   /MD_Metadata/hierarchyLevelName
					$this->md[$recno]['iso'] = 'MC';
				}
				// uuid
				$this->md[$recno]['uuid'] = '';
				if (isset($this->arrayXml['MD_Metadata'][$idx]['fileIdentifier']['00']['@']) && $this->arrayXml['MD_Metadata'][$idx]['fileIdentifier']['00']['@'] != '') {
					$this->md[$recno]['uuid'] = $this->arrayXml['MD_Metadata'][$idx]['fileIdentifier']['00']['@'];
				}
				$this->setLangMd($recno, $this->md[$recno]['iso']);
				$this->setLangsMd($recno, $this->md[$recno]['iso']);
			}
		}
		if (array_key_exists('metadata', $this->arrayXml)) {
			foreach ($this->arrayXml['metadata'] as $idx=>$md) {
                $recno = $idx;
                if (strlen($recno) === 2 && $recno[0] === '0') {
                    $recno = $recno[1];
                }
				$this->md[$recno]['iso'] = 'DC';
				// uuid
				$this->md[$recno]['uuid'] = '';
				if (isset($this->arrayXml['metadata'][$idx]['identifier']) && is_array($this->arrayXml['metadata'][$idx]['identifier'])) {
					$z = '';
					for ($y = 0; $y < count($this->arrayXml['metadata'][$idx]['identifier']); $y++) {
                        $y2 = strlen($y) === 1 ? "0$y" : $y;
						if (isset($this->arrayXml['metadata'][$idx]['identifier'][$y2]['@']) && $this->arrayXml['metadata'][$idx]['identifier'][$y2]['@'] != '') {
							$pom = $this->getDcUuid($this->arrayXml['metadata'][$idx]['identifier'][$y2]['@']);
							if ($pom != -1) {
								$this->md[$recno]['uuid'] = $pom;
								$z = $y2;
								break;
							}
						}
					}
					if ($z != '') {
						//odstarnění uuid z pole
						array_splice($this->arrayXml['metadata'][$idx]['identifier'], $z ,1);
					}
				}
				$this->setLangMd($recno, $this->md[$recno]['iso']);
				$this->setLangsMd($recno, $this->md[$recno]['iso']);
			}
		}
		if (array_key_exists('FC_FeatureCatalogue', $this->arrayXml)) {
			foreach ($this->arrayXml['FC_FeatureCatalogue'] as $idx=>$md) {
                $recno = $idx;
                if (strlen($recno) === 2 && $recno[0] === '0') {
                    $recno = $recno[1];
                }
				$this->md[$recno]['iso'] = 'FC';
				// uuid
				$this->md[$recno]['uuid'] = '';
				$z = '';
				for ($y = 0; $y < count($this->arrayXml['FC_FeatureCatalogue'][$idx]['id']); $y++) {
                    $y2 = strlen($y) === 1 ? "0$y" : $y;
                    if (isset($this->arrayXml['FC_FeatureCatalogue'][$idx]['id'][$y2]['@']) && $this->arrayXml['FC_FeatureCatalogue'][$idx]['id'][$y2]['@'] != '') {
						$this->md[$recno]['uuid'] = $this->arrayXml['FC_FeatureCatalogue'][$idx]['id'][$y2]['@'];
						$z = $y;
					}
				}
				if ($z != '') {
					//odstarnění uuid z pole
					unset($this->arrayXml['FC_FeatureCatalogue'][$idx]['id']);
				}
				$this->setLangMd($recno, $this->md[$recno]['iso']);
				$this->setLangsMd($recno, $this->md[$recno]['iso']);
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

