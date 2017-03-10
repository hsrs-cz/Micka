<?php
// micka - lite ver. 2.0
date_default_timezone_set('Europe/Prague');
require(dirname(__FILE__)."/../include/application/CswClient.php");
require(dirname(__FILE__)."/resources/kote_cfg.php");
require(dirname(__FILE__)."/resources/Kote.php");
$cswClient = new CSWClient();
session_start();
// *************************** MAIN *****************************

//---uprava vstupu
$lang = $_REQUEST['lang'] ? $_REQUEST['lang'] : 'cze';
if($_REQUEST["action"]!='pasPrint'){
  $_REQUEST["creationDate"] = Kote::date2iso($_REQUEST["creationDate"]);
  $_REQUEST["publicationDate"] = Kote::date2iso($_REQUEST["publicationDate"]);
  $_REQUEST["revisionDate"] = Kote::date2iso($_REQUEST["revisionDate"]);
}

$input = Kote::processForm($_REQUEST);
$params = Array('datestamp'=>date('Y-m-d'), 'lang'=>$lang, 'mickaURL'=>MICKA_URL);

if($_REQUEST["action-save"]){
    // --- ulozeni do CSW
    $s = $cswClient->processTemplate($input,dirname(__FILE__).'/resources/kote2iso.xsl',$params);
    $cswClient->prepareUpdate($s);
    $cswClient->setParams("debug=1");
    $s = $cswClient->runRequest(KOTE_SERVICE, "kote", dirname(__FILE__).'/resources/transaction2kote.xsl', 'SID@'.$_COOKIE[CSW_TOKEN], '');
    echo $s;
}

// --- vytvoreni XML 19139
else if($_REQUEST["action-xml"]){	
    header("Content-type: application/xml");
    //echo $input; exit;
    reset ($_REQUEST);
    //header("Pragma: no-cache");
    //header('Content-Disposition: attachment; filename="metadata_'.$_REQUEST['md']['fileIdentifier'].'.xml"');
    echo $cswClient->processTemplate($input,dirname(__FILE__).'/resources/kote2iso.xsl', $params);  
}

// --- validace EU
else if($_REQUEST["action-eu"]){    
    $xml = $cswClient->processTemplate($input,'resources/kote2iso.xsl', $params);  
	echo Kote::postFileForm(JRC_VALIDATOR, $xml);
}	  	

// --- validace CR  		
else if($_REQUEST["action-cr"]){
  	echo '<html><head><meta http-equiv="content-type" content="text/html; charset=utf-8" />
  	<link rel="stylesheet" type="text/css" href="../validator/style/validator.css"/></head><body>';
    $xml = $cswClient->processTemplate($input,dirname(__FILE__).'/resources/kote2iso.xsl', $params);  
	include(dirname(__FILE__)."/../validator/resources/Validator.php");
	$validator = new Validator();
	$validator->run($xml);
	echo $validator->asHTML();
}
	
// --- jen HTML výpis
else if($_REQUEST["action-html"]){	  	
    echo "comming soon...";
    //$s = $cswClient->processTemplate($input,'resources/kote2iso.xsl', $params);
    //echo $cswClient->processTemplate($s,'../include/xsl/iso2html.xsl', $params);  
}

// --- tisk pasportu
else if($_REQUEST["action-paspprint"]){	  	
	$s = $cswClient->processTemplate($input,dirname(__FILE__).'resources/kote2iso.xsl',$params);
	$par['komu'] = $_REQUEST['md']['komu'];
	$par['cislo'] = $_REQUEST['md']['cislo'];
	echo $cswClient->processTemplate($s,PHPPRG_DIR.'/../xsl/iso2pasport.xsl', $par);  
}	

else if($_REQUEST["action-pasport"]){	  	
    echo $cswClient->processTemplateFile('', dirname(__FILE__).'/resources/kote_pass.xsl');
}
	    
// --- zpracovani formulare
else{
	if($_REQUEST['metadataURL']){ 
		$s = file_get_contents('http://www.bnhelp.cz/projects/metadata/trunk/micka_main.php?ak=xml&uuid=4969bc07-148c-4ce3-a4d7-39e9d49e8056'); //TODO - zabezpecit
		//echo $s; exit;
	}
	else if($_REQUEST['id']){
		if(KOTE_MODE_LOCAL){
			include ('../include/application/micka_main_lib.php');
			require '../include/application/MdRecord.php';
			echo main_xml('md', htmlspecialchars($_REQUEST['id']), '');
			//$url = '../micka_main.php?ak=xml&uuid='.htmlspecialchars($_REQUEST['id']);
		}
		else {
			$url = KOTE_SERVICE.'?SERVICE=CSW&version=2.0.2&REQUEST=GetRecordById&debug=0&ID='.htmlspecialchars($_REQUEST['id'])."&user=SID@".$_COOKIE[CSW_TOKEN]; //TODO na javu
		}
		$s = file_get_contents($url); //TODO - zabezpecit
	}
	else {
		$s = '<gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd" />'; 
	}
	$params = array('mickaURL'=>MICKA_URL, 'mds'=>0, 'lang'=>$lang, "publisher"=>1, 'langs'=>'eng');
	echo $cswClient->processTemplate($s, dirname(__FILE__).'/resources/kote.xsl', $params);
}

