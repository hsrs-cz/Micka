<?php
/**
 * Metainformation catalogue
 * --------------------------------------------------
 *
 * Lib for MicKa
 *
 * @link       http://www.bnhelp.cz
 * @package    Micka
 * @category   Metadata
 * @version    20150225
 *
 */
// pro XSLT - dotaz na metadata
function getMetadata($s, $esn='summary'){
    $s = stripslashes($s); // FIXME - nevim, co to udela, pokud je apostrof v retezci
	$csw = new \Micka\Csw();
	$params["CONSTRAINT"] = $s;
	$params['CONSTRAINT_LANGUAGE'] = 'CQL';
	$params['TYPENAMES'] = 'gmd:MD_Metadata';
	$params['OUTPUTSCHEMA'] = "http://www.isotc211.org/2005/gmd";
	$params['SERVICE'] = 'CSW';
	$params['REQUEST'] = 'GetRecords';
	$params['VERSION'] = '2.0.2';
	$params['ISGET'] = true;
	$params['MAXRECORDS'] = 25;
	$params['ELEMENTSETNAME'] = $esn;
	$params['buffered'] = true;
	$result = $csw->run($params);
	file_put_contents(__DIR__ . "/../../log/getMetadata.txt", print_r($params, true).$result);
	$dom = new DOMDocument();
	$dom->loadXML($result);
	return $dom;
}


// pro XSLT - ceske datum
function drawDate($date, $lang){
	if($lang=='cze' && strpos($date,"-")>0){
		$pom = explode("-",$date);
		$s = "";
		foreach($pom as $token){
			$s = $token.".".$s;
		}
		$date = substr($s,0,-1);
	}
	return $date;
}

function setMickaLog($message, $level, $modul) {
	
}

/**
 * Přidání prázné hodnoty s indexem -1 na začátek pole,
 * používají SELECT Boxy ve formulářích
 *
 * @param array $arr
 * @return array
 */
function setRowZero($arr){
	if (is_array($arr)) {
		$pom[-1] = '';
		$rs = $pom + $arr;
	}
	else {
		$rs = $arr;
	}
	return $rs;
}

/**
 * Převod md_path na "pole"
 *
 * příklad
 * in: '0_0_44_0'
 * out: '[0][0][44][0]'
 *
 * @param string $md_path hodnota z tabulky md_values.md_path
 * @return string
 */
function getMdPath($md_path) {
	$rs = '';
	if (substr($md_path, strlen($md_path)-1) == '_') {
		// odstranění posledního podtržítka
		$md_path = substr($md_path, 0, strlen($md_path)-1);
	}
	$rs = str_replace("_", "][", $md_path);
	$rs = '[' . $rs . ']';
	return $rs;
}

/**
 * Určení počtu jazyků
 * 
 * @param string $langs hodnoty oddělené | (pipe)
 * @return number
 */
function getCountLang($langs) {
	return substr_count($langs,'|') + 1;
}

/**
 * pole se seznamem použitých jazyků
 *
 * @param mixed $md_langs seznam jazyků
 * @return array
 */
function getMdLangs($md_langs) {
	//setMickaLog("md_langs=$md_langs", 'DEBUG', 'micka_lib.getMdLangs.start');
	$rs = array();
	if (is_array($md_langs)) {
		$rs = $md_langs;
	}
	else {
		$rs = explode('|',$md_langs);
	}
	//setMickaLog($rs, 'DEBUG', 'micka_lib.getMdLangs.return');
	return $rs;
}

function getUniqueMdLangs($langs, $md_langs) {
	$langs = getMdLangs($langs);
	$md_langs = getMdLangs($md_langs);
	$md_langs = array_merge($md_langs, $langs);
	$md_langs = array_unique($md_langs);
	return implode('|', $md_langs);
}

function getWmsList($rs) {
	if ($rs != '') {
		if (substr_count($rs,'WMS') == 0) {
			$rs = '';
		}
	}
	return $rs;
}

function getUuid() {
	$uuid = new \Micka\UUID;
	$uuid->generate();
	return $uuid->toRFC4122String();
}

function getHsWms($micka_lang, $hs_wms) {
	return array_key_exists($micka_lang, $hs_wms) ? $hs_wms[$micka_lang] : $hs_wms['eng'];
}

function getLabelCodeList($value, $el_id) {
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

function getHyperLink($hle) {
	$hle = trim($hle);
	$rs = $hle;
	return $rs;
}

function isUuidExist($uuid, $harvest=TRUE) {
	if ($harvest === FALSE) {
		return FALSE;
	}
	$rs = FALSE;
	$sql = array();
	if ($uuid != '') {
		array_push($sql, "SELECT COUNT(recno) AS soucet FROM md WHERE uuid=%s", $uuid);
		$result = _executeSql('select', $sql, array('single'));
		if ($result > 0) {
			$rs = TRUE;
		}
	}
	return $rs;
}

function getMdProfils($micka_lang, $mds=0) {
	$sql = array();
	array_push($sql, "
		SELECT profil_id, CASE WHEN label_text IS NULL THEN profil_name ELSE label_text END AS label_text
		FROM profil_names z LEFT JOIN (SELECT label_join,label_text FROM label WHERE lang=%s AND label_type='PN') s
		ON z.profil_id=s.label_join
		WHERE md_standard=%i AND is_vis=1
	", $micka_lang, $mds);
	array_push($sql, "ORDER BY profil_order");
	return _executeSql('select', $sql, array('pairs', 'profil_id', 'label_text'));
}

function getMdPackages($micka_lang, $mds, $profil, $pairs=FALSE) {
	$rs = array();
	if ($micka_lang === '' || $mds === '' || $profil === '') {
		Debugger::log('[micka_lib.getMdPackages] ' . "LANG=$micka_lang, MDS=$mds, PROFIL=$profil", 'ERROR');
		return $rs;
	}
	$is_packages = 0;
	$sql = array();
	if ($mds == 0 || $mds == 10) {
		array_push($sql, '
			SELECT is_packages FROM profil_names WHERE md_standard=%i AND profil_id=%i
		', $mds, $profil);
		$is_packages = _executeSql('select', $sql, array('single'));
	} else {
		return $rs;
	}
	if ($is_packages == 0) {
		return $rs;
	}
	if ($mds == 10) {
		$mds = 0;
	}
	$sql = array();
	array_push($sql, "
		SELECT packages.package_id, label.label_text
        FROM packages INNER JOIN label ON packages.package_id=label.label_join
		WHERE label.label_type='MB' AND packages.md_standard=%i AND label.lang=%s
		ORDER BY packages.package_order
	", $mds, $micka_lang);
	if ($pairs) {
		$rs = _executeSql('select', $sql, array('pairs', 'package_id', 'label_text'));
	} else {
		$rs = _executeSql('select', $sql, array('all'));
	}
	return $rs;
}

function getProfilExists($mds, $profil) {
	$rs = array();
	$rs['akce'] = 'micka';
	$rs['template'] = '';

	if ($profil < 0 || $profil === '') {
		$profil = START_PROFIL;
	}
	if ($mds == 10 && $profil < 100) {
		$profil = $profil + 100;
	}
	$rs['profil'] = $profil;
	$sql = array();
	array_push($sql, "
		SELECT profil_id, edit_lite_template FROM profil_names
		WHERE md_standard=%i AND profil_id=%i AND is_vis=1
	", $mds, $profil);
	$rs_profil = _executeSql('select', $sql, array('all'));
	if (is_array($rs_profil) && count($rs_profil) > 0) {
		if ($rs_profil[0]['EDIT_LITE_TEMPLATE'] == '') {
			$rs['profil'] = $profil;
		}
		if ($rs_profil[0]['EDIT_LITE_TEMPLATE'] != '') {
			$rs['profil'] = $profil;
			$rs['akce'] = 'lite';
			$rs['template'] = $rs_profil[0]['EDIT_LITE_TEMPLATE'];
		}
	} else {
        $profil = START_PROFIL;
        if ($mds == 10 && $profil < 100) {
            $profil = $profil + 100;
        }
        $rs['profil'] = $profil;
        $sql = array();
        array_push($sql, "
            SELECT profil_id, edit_lite_template FROM profil_names
            WHERE md_standard=%i AND profil_id=%i AND is_vis=1
        ", $mds, $profil);
        $rs_profil = _executeSql('select', $sql, array('all'));
        if (is_array($rs_profil) && count($rs_profil) > 0) {
            if ($rs_profil[0]['EDIT_LITE_TEMPLATE'] == '') {
                $rs['profil'] = $profil;
            }
            if ($rs_profil[0]['EDIT_LITE_TEMPLATE'] != '') {
                $rs['profil'] = $profil;
                $rs['akce'] = 'lite';
                $rs['template'] = $rs_profil[0]['EDIT_LITE_TEMPLATE'];
            }
        }
    }
    return $rs;
}

function getProfilPackages($mds, $profil, $block) {
	$rs = array();
	$rs['profil'] = -1;
	$rs['package'] = -1;
	$yes_profil = FALSE;
	switch ($mds) {
		case 0:
			if ($profil > 0 && $profil < 100) {
				$yes_profil = TRUE;
			}
		case 10:
			if ($mds == 10 && $profil < 100) {
				$profil = $profil + 100;
			}
			if ($mds == 10 && $profil > 100) {
				$yes_profil = TRUE;
			}
			$packages = getMdPackages(MICKA_LANG, $mds, $profil);
			if (count($packages) > 0 && $block > -1) {
				if ($yes_profil === TRUE) {
					$rs['profil'] = $profil;
					$rs['package'] = $block;
				}
				else {
					$rs['package'] = $block;
				}
			}
			else {
					$rs['profil'] = $profil;
			}
			break;
	}
	return $rs;
}

function getMdIdFromMdPath($md_path) {
	$rs = '';
	$md_path = substr($md_path,0,strlen($md_path)-1);
	$pom = explode('_',$md_path);
	if (count($pom) > 1) {
		$idx = count($pom) - 2;
		$rs = $pom[$idx];
	}
	if ($rs == '') {
        
	}
	return $rs;
}

function gpc_addslashes($str) {
	$str = addslashes($str);
	$str = str_replace('\\\'',"'", $str);
	$str = str_replace('$','\$', $str);
	return $str;
}

function beforeSaveRecord($data) {
	if (is_array($data)) {
		if (array_key_exists('ak', $data)) unset($data['ak']);
		if (array_key_exists('w', $data)) unset($data['w']);
		if (array_key_exists('iframe', $data)) unset($data['iframe']);
		if (array_key_exists('block', $data)) unset($data['block']);
		if (array_key_exists('nextblock', $data)) unset($data['nextblock']);
		if (array_key_exists('profil', $data)) unset($data['profil']);
		if (array_key_exists('nextprofil', $data)) unset($data['nextprofil']);
		if (array_key_exists('recno', $data)) unset($data['recno']);
		if (array_key_exists('uuid', $data)) unset($data['uuid']);
		if (array_key_exists('mds', $data)) unset($data['mds']);
		if (array_key_exists('public', $data)) unset($data['public']);
		if (array_key_exists('ende', $data)) unset($data['ende']);
	}
	return $data;
}

function getSortBy($in='', $ret='array') {
	if ($in != '') {
		$sort_by = $in;
	}
	else {
		$sort_by = isset($_SESSION['micka']['search']['sort_by']) && $_SESSION['micka']['search']['sort_by'] != ''
			? $sort_by = $_SESSION['micka']['search']['sort_by']
			: $sort_by = 'title,ASC';
	}
	$pom = explode(',', trim($sort_by));
	$pom0 = isset($pom[0]) && $pom[0] != '' ? $pom[0] : 'recno';
	$pom1 = isset($pom[1]) && $pom[1] != '' ? $pom[1] : 'ASC';
	$rs = array();
	if ($pom0 == 'date') {
		$pom0 = 'last_update_date';
	}
	switch ($pom0) {
		case 'recno':
		case 'title':
		case 'last_update_date':
		case 'bbox':
			$rs[0] = $pom0;
			break;
		default:
			$pom0 = 'recno';
			break;
	}
	$rs[1] = $pom1 == 'ASC' || $pom1 == 'DESC' ? $pom1 : 'ASC';
	if ($ret == 'string') {
		return $rs[0] . ',' . $rs[1];
	}
	return $rs;
}

function dateIso2Cz($datum) {
	$pom = explode('-', $datum);
	if (count($pom) == 2) {
		$m = (int)$pom[1];
		$datum = $m . '.' . $pom[0];
	}
	if (count($pom) == 3) {
		$d = (int)$pom[2];
		$m = (int)$pom[1];
		$datum = $d . '.' . $m . '.' . $pom[0];
	}
	return $datum;
}
