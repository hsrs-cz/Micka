<?php

class Kote{

  static function is_assoc($array) {
    foreach(array_keys($array) as $key) {
      if (!is_numeric($key)) return TRUE;
    }
    return FALSE;
  }

	static function array2xml($parentNode, $a){
		$xml = '';
		while(list($name, $val) = each ($a)){
		    $numeric = is_numeric($name);
		    if($numeric) $name=$parentNode;
	    	if(is_array($val)){
	    	    if($numeric){
	    		     $val = Kote::array2xml($name, $val);
	    		     $xml .= "<$name>$val</$name>";
	    		  }   
	    		  else {
	    		     $xml .= Kote::array2xml($name, $val);
            	}   
	    	}
	    	else{
	    		if($val) $xml .= "<$name>$val</$name>";
	    		else $xml .= "<$name> </$name>";
	    	}
		}
		return $xml;
	}
	
	// vzato z Micky
	static function getMdPath($md_path) {
		$rs = '';
		if (substr($md_path, strlen($md_path)-1) == '_') {
			// odstranění posledního podtržítka
			$md_path = substr($md_path, 0, strlen($md_path)-1);
		}
		$rs = str_replace("_", "']['", $md_path);
		$rs = "['" . $rs . "']";
		$rs = str_replace("['']", "", $rs);
		return $rs;
	}
	
	// --- prevod ceskeho data na ISO
	static function date2iso($d){
	  if(!strpos($d, ".")) return $d;
	  $pom = explode(".",$d);
	  for($i=0;$i<count($pom);$i++) if(strlen($pom[$i])<2) $pom[$i]="0".$pom[$i];
	  return $pom[2]."-".$pom[1]."-".$pom[0];
	}
	
	// --- odesle multipart formular
	static function postFileForm($destination, $fileContent){
		$showXml = false; //pripraveno
		$eol = "\r\n";
		$mime_boundary=md5(time());
		$data = '--' . $mime_boundary . $eol;
		$data .= 'Content-Disposition: form-data; name="dataFile"; filename="myMetadataFile.xml"' . $eol; //zavisle na JRC portalu
	  	$data .= 'Content-Type: text/xml' . $eol . $eol;
	 	$data .= $fileContent . $eol;
	  	$data .= "--" . $mime_boundary . "--" . $eol . $eol; // finish with two eol's!!
	  	$params = array('http' => array(
	  	         'method' => 'POST',
	  	         'header' => 'Content-Type: multipart/form-data; boundary=' . $mime_boundary . $eol,
	  	         'content' => $data
	  	));		
	  	if($showXml){           
	  		$params = array('http' => array(
	  	          'method' => 'POST',
	  	          'header' => 'Content-Type: multipart/form-data; boundary=' . $mime_boundary . $eol
	  				.'Accept: application/xml' . $eol,
	  	          'content' => $data
	  	     ));
	  	}
	  	$ctx = stream_context_create($params);
	  	if($showXml){
	  		header('Content-Type: application/xml');
	  	}
	  	return file_get_contents($destination, FILE_TEXT, $ctx);  
	}
	
	static function processForm($data){
		$out = "";
		while(list($key,$val)=each($data)){
			$out .= '$'.'md'.Kote::getMdPath(htmlspecialchars($key))."='". htmlspecialchars(str_replace('\\', '\\\\', $val), ENT_QUOTES) ."';
			";
		}
		//die($out);
		eval ($out);
		//var_dump($md);
		$md["keywords"] = isset($data["keywords"]) ? explode("\n",$data["keywords"]) : '';
		$md["gemet"] = isset($data["gemet"]) ? explode("\n",$data["gemet"]) : '';
		//$md["inspire"] = isset($data["inspire"]) ? explode("\n",$data["inspire"]) : '';
		$md["x"] = '';
		$xmlString = '<?xml version="1.0" encoding="utf-8" ?'.'><md>';
		$xmlString .= Kote::array2xml('', $md)."</md>";
		//header('Content-Type: application/xml');
		//echo $xmlString;  exit;
		return $xmlString; 
	}

}