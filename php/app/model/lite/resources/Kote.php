<?php

// --- Czech date to ISO
function date2iso($d){
  if(!strpos($d, ".")) return $d;
  $pom = explode(".",$d);
  for($i=0;$i<count($pom);$i++) if(strlen($pom[$i])<2) $pom[$i]="0".$pom[$i];
  return implode('-', array_reverse($pom));
}
	
// --- Czech date to ISO
function iso2date($d, $lang=''){
  if(!strpos($d, "-") or $lang!='cze') return $d;
  $pom = explode("-",$d);
  return implode('.', array_reverse($pom));
}

// --- mime type string
function getMime($s){
    if(!$s) return '';
    $p = '/mime=(.+?)(\s|$)/';
    preg_match($p, $s, $m);
    if(!$m) return '';
    return str_replace('"','',$m[1]);
}
// --- string without mime
function noMime($s){
    if(!$s) return '';
    $p = '/mime=(.+?)(\s|$)/';
    $r = '';
    return trim(preg_replace($p, $r, $s));
}

class Kote{
    public function __construct(){
        
    }
    
    function is_assoc($array) {
        foreach(array_keys($array) as $key) {
          if (!is_numeric($key)) return TRUE;
        }
        return FALSE;
    }

	function array2xml($parentNode, $node){
		$xml = '';
		foreach($node as $name=>$val){
		    $numeric = is_numeric($name);
		    if($numeric) $name='item';
	    	if(is_array($val)){
    		    $val = $this->array2xml($name, $val);
	    	}
            if($val) $xml .= "<$name>$val</$name>";
            else $xml .= "<$name> </$name>";
		}
		return $xml;
	}
	
	// vzato z Micky
	function getMdPath($md_path) {
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
	
	// --- odesle multipart formular
	function postFileForm($destination, $fileContent){
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
	
	function processForm($data){
		$out = array();
		while(list($key,$val)=each($data)){
            // process the compound elements
            if(strpos($key,'-')) {               
                $k = explode('-', $key);
                $lastLang = '';
                $j=-1;
                for($i=0; $i<count($val); $i++){                    
                    if(is_array($val[$i])){
                        foreach($val[$i] as $k2=>$v2){
                            if($k2 && (in_array($k2, $data['locale'])||$k2='TXT')) {
                                if($k2=='TXT') $j++;
                                $out[$k[0]][$j][$k[1]][$k2] = htmlspecialchars(str_replace('\\', '\\\\', $v2));
                            }
                            else $out[$k[0]][$i][$k[1]][$k2] = htmlspecialchars(str_replace('\\', '\\\\', $v2));
                        }
                    }
                    else $out[$k[0]][$i][$k[1]] = htmlspecialchars(str_replace('\\', '\\\\', $val[$i]));
                }
            } 
            else $out[$key]=$val;
		}
        
        //echo "<pre>"; var_dump($out); die();
        
		//eval ($out);
		//var_dump($md);
		//$md["keywords"] = isset($data["keywords"]) ? explode("\n",$data["keywords"]) : '';
		//$md["gemet"] = isset($data["gemet"]) ? explode("\n",$data["gemet"]) : '';
		//$md["inspire"] = isset($data["inspire"]) ? explode("\n",$data["inspire"]) : '';
		//$md["x"] = '';
		$xmlString = '<?xml version="1.0" encoding="utf-8" ?'.'><md>';
		$xmlString .= $this->array2xml('md', $out)."</md>";
		//header('Content-Type: application/xml'); echo $xmlString;  exit;
		return $xmlString; 
	}

}