<?php
include(dirname(__FILE__)."/resources/Validator.php");
$data = $_REQUEST['xml'];
$url = $_REQUEST['url'];
$type = htmlspecialchars($_REQUEST['type']);
$short = ($_REQUEST['short']=='on');
$reqLang = htmlspecialchars($_COOKIE['GUEST_LANGUAGE_ID']);

if($_REQUEST['validator']=="jrc"){
	include("/../lite/resources/Kote.php");
	define("JRC_VALIDATOR","http://inspire-geoportal.ec.europa.eu/GeoportalProxyWebServices/resources/INSPIREResourceTester");
	echo Kote::postFileForm(JRC_VALIDATOR, $xml);
	exit;
}

switch ($reqLang){
	case "cs_CZ": $language = "cze"; break;
	default: $language = "eng";
}

// --- main ---
$validator = new Validator($type, $language);

if(!$data){
  if($_FILES['dataFile']['tmp_name']){ 
    $data = file_get_contents($_FILES['dataFile']['tmp_name']);
  }  
}

if(!$data){
  $purl = parse_url($url);
  if($purl['scheme']!='http' && $purl['scheme']!='https'){
      $url = "http://".$url;
  }
  if($type!='gmd'){
      if(!$purl['query']) $url .= "?";
      if(!strpos(strtolower($url), "service=")) $url .= "&SERVICE=" . strtoupper($type);
      if(!strpos(strtolower($url), "request=")) $url .= "&REQUEST=GetCapabilities";
      //echo $url; exit;
  }

  try{
      $data = file_get_contents($url);
  } 
  catch(Exception $e){
      die ("source not found.");
  }    
}

if(!$data) die("Data not entered");
	
$validator->run($data);
switch (htmlspecialchars($_REQUEST['format'])){
	case "application/json":
		header("Content-type: application/json charset=\"utf-8\"");
		echo $validator->asJSON();	
		break;
	case "application/xml":
		header("Content-type: application/xml charset=\"utf-8\""); 
		echo $validator->result;
		break;
	case "array":
		var_dump($validator->asArray($short));
		break;
	default:
		if($_REQUEST['head']!='false'){
			?>
			<html>
			<head>
				<meta http-equiv="content-type" content="text/html; charset=utf-8" />
				<title>CENIA - INSPIRE validator</title>
				<meta name="DC.title" lang="en" content="Metadata validator - CS" />
  				<meta name="DC.description" lang="en"  content="Spatial data and services metadata validator according to INSPRE / Czech profile"/>
  				<meta name="DC.Type" content="Service" />  	
  				<meta name="DC.creator" content="Help Service Remote Sensing" />
 				<meta name="DC.date" scheme="W3CDTF" content="2010-12-23"> 
				<style type="text/css">
					@import url(style/validator.css);
				</style>
			</head>
			<body> <?php echo $validator->asHTML($short); ?> </body>
			</html>
			<?php
		}	
		else {
			echo $validator->asHTML();		
		}
		break;		
}
