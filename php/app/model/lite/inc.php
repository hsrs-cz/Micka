<?php
// priklad nacteni formulare
require(dirname(__FILE__)."/../include/application/CswClient.php");
require(dirname(__FILE__)."/resources/Kote.php");
$cswClient = new CSWClient();

// zobrazeni XML
if($_REQUEST['action']){
	$input = Kote::processForm($_REQUEST);
	$params = Array('datestamp'=>date('Y-m-d'), 'lang'=>'cze');	
	header("Content-type: application/xml");
	echo $cswClient->processTemplate($input,dirname(__FILE__).'/resources/kote2iso.xsl', $params);
}
// prvni nacteni
else {
	$params = array('recno'=>1,'select_profil'=>5);
	$s = file_get_contents("resources/priklad_inspire.xml");
	echo $cswClient->processTemplate($s, dirname(__FILE__).'/resources/kote-micka.xsl',$params);
}	 