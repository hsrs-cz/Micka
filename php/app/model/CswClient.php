<?php
define("OS_DC", "http://www.opengis.net/cat/csw/2.0.2");
define("OS_GMD", "http://www.isotc211.org/2005/gmd");

class CswClient
{ 
  var $xml; 
  var $xsl;
  var $xp;
  var $debug = false;
  var $reqData = "";
  var $ElementSetName = "summary";
  var $typeNames = "gmd:MD_Metadata";
  var $maxRecords = 50;
  var $startPosition = 1;
  var $xmlHead = "";
  var $lang='cze';
  var $method="";
  var $resultType = "results";
  public $sw = '';
  public $hopCount;
  public $sortBy;
  
  function __construct()
  {
    if(!extension_loaded("xsl")){
    		die("xsl extension must be loaded in php.ini");

    }
    $this->xmlHead = "<"."?xml version=\"1.0\" encoding=\"UTF-8\"?".">";
    $this->xp = new XsltProcessor();
    $this->xp->registerPhpFunctions();
    $this->xml = new DomDocument;
    $this->xsl = new DomDocument;    
    //$this->xsl->substituteEntities = true;
  }  
  
  function setParams($params){
    if(!$params) return;
    $paramList = explode("|", $params);
    foreach($paramList as $param){
      $pom = explode("=",$param);
      eval("\$this->".$pom[0]."='".$pom[1]."';");
    }  
  }

  function getDataByGet($url, $name, $id, $template){	
    $url = $url."?service=CSW&version=2.0.2&request=GetRecordById&ID=".$id."&TypeNames=gmd:MD_Metadata&OutputSchema=http://www.isotc211.org/2005/gmd&elementSetName=full";
	$s=  $this->getDataByURL($url);
	$par = Array("theName"=>$name, "lang"=>$this->lang);
	if($params) $par = array_merge($par, $params);
	if($template) return $this->processTemplate($s, $template, $par);
	else return($s);
  }

  function getDataByURL($url){
      $ch = curl_init ($url);
      curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
      curl_setopt($ch, CURLOPT_TIMEOUT, 20);
      curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0); // potlačena kontrola certifikátu
      if(defined('CONNECTION_PROXY')){
          $proxy = CONNECTION_PROXY;
          if(defined('CONNECTION_PORT')) $proxy .= ':'. CONNECTION_PORT;
          curl_setopt($ch, CURLOPT_PROXY, $proxy);
      }
      curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
      $data = curl_exec ($ch);
      if($this->debug>1){
          var_dump(curl_getinfo($ch));
      }
      curl_close ($ch);
      return $data;
  }
  
  function pos($s, $left, $right, $start=0){
  	$count = 0;
  	$pos = 0;
  	$out = true;
  	for($i=$start;$i<strlen($s);$i++){
  		$ch = substr($s,$i,1);
  		if($ch=="'") $out = !$out;
  		else if($out){
  			if($ch==$left) $count++;
  			if($ch==$right){
  				$count--;
  				if($count<1){
  					return $i;
  				}
  			}
  		}
  	}
  	return false;
  }
  
  private function getDataByPost($url, $content, $usr, $pwd){
	$arURL = parse_url($url);
	$host = $arURL["host"];
	$port = isset($arURL["port"]) ? $arURL["port"] : ''; 
	if($port == '') $port = 80;
	$path = $arURL["path"];
	$method = "POST";
	if ($this->method=="Soap") {
		$headers = array(
            "POST ".$path." HTTP/1.1",
			"Content-type: application/soap+xml; charset=\"utf-8\"",
            "Cache-Control: no-cache",
            "Pragma: no-cache",
            "SOAPAction: \"run\"",
            "Content-length: ".strlen($content)
        ); 
	}
	else{
		$headers = array(
            "POST ".$path." HTTP/1.1",
            "Content-type: text/xml; charset=\"utf-8\"",
		    "Cache-Control: no-cache",
            "Pragma: no-cache",
            "Content-length: ".strlen($content)
        ); 
	
	}
	if($usr) $headers[] = "Authorization: Basic ".base64_encode($usr.":".$pwd);
	//var_dump($headers);
	//do curl connection and request 
	//$out = $this->getCURL($url,$content,$headers);
	$ch = curl_init ($url); 
	curl_setopt($ch, CURLOPT_HTTPHEADER,$headers); 
	//curl_setopt($ch, CURLOPT_COOKIE, session_name().'='.session_id() );
	//or with own headers
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $content);
	curl_setopt($ch, CURLOPT_TIMEOUT, 20);
    //curl_setopt($ch, CURLOPT_HTTPHEADER, array('Expect:')); // kvuli VUMOP
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0); // potlačena kontrola certifikátu
   	if(defined('CONNECTION_PROXY')){
        $proxy = CONNECTION_PROXY;
        if(defined('CONNECTION_PORT')) $proxy .= ':'. CONNECTION_PORT;
		curl_setopt($ch, CURLOPT_PROXY, $proxy);	
	}
    if(defined('CONNECTION_PASSWORD') && CONNECTION_PASSWORD != ""){
        curl_setopt ($ch, CURLOPT_PROXYUSERPWD, CONNECTION_USER.':'.CONNECTION_PASSWORD);
    }
	curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
	//$useragent='HSRS CSW Client'; 
	//curl_setopt ($ch,CURLOPT_USERAGENT,$useragent);
	$file = curl_exec ($ch);
	if($this->debug>1){
		var_dump(curl_getinfo($ch));
	}
	curl_close ($ch);
	return $file;	
  }
  
  function formatXML1($s){
    $s = str_replace("<", "\n<", $s);
    $s = str_replace("\n</", "</", $s);
    $s = str_replace("></", ">\n</", $s);
    return highlight_string(htmlentities($s), true);
  }

  function formatXML($xml) {  
	  // add marker linefeeds to aid the pretty-tokeniser (adds a linefeed between all tag-end boundaries)
	  $xml = preg_replace('/(>)(<)(\/*)/', "$1\n$2$3", $xml);
	  
	  // now indent the tags
	  $token      = strtok($xml, "\n");
	  $result     = ''; // holds formatted version as it is built
	  $pad        = 0; // initial indent
	  $matches    = array(); // returns from preg_matches()
	  
	  // scan each line and adjust indent based on opening/closing tags
	  while ($token !== false) : 
	  
	    // test for the various tag states
	    
	    // 1. open and closing tags on same line - no change
	    if (preg_match('/.+<\/\w[^>]*>$/', $token, $matches)) : 
	      $indent=0;
	    // 2. closing tag - outdent now
	    elseif (preg_match('/^<\/\w/', $token, $matches)) :
	      $pad--;
	    // 3. opening tag - don't pad this one, only subsequent tags
	    elseif (preg_match('/^<\w[^>]*[^\/]>.*$/', $token, $matches)) :
	      $indent=1;
	    // 4. no indentation needed
	    else :
	      $indent = 0; 
	    endif;
	    
	    // pad the line with the required number of leading spaces
	    $line    = str_pad($token, strlen($token)+$pad, ' ', STR_PAD_LEFT);
	    $result .= $line . "\n"; // add to the cumulative result, with linefeed
	    $token   = strtok("\n"); // get the next token
	    $pad    += $indent; // update the pad size for subsequent lines    
	  endwhile; 
	  
	  return highlight_string(htmlentities($result), true);
  }
	  
  private function cql2filter_($s, $prefix=""){
  $i = 0; 
  $tokens = array();
  $tnum = 0;
  $in = false;

  while($i<strlen($s)){
    $ch = substr($s,$i,1);
    switch($ch){
      case  ' ': $tnum++; break;
      case  '(':  
        $pos = $this->pos($s, "(", ")", $i+1);
        $tokens[$tnum]="(".$this->cql2filter_(substr($s,$i+1,$pos-$i-1),$prefix); 
        $i=$pos;
        break;
      case  "'": 
        $pos = strpos($s, "'", $i+1); 
        $tokens[$tnum] = substr($s,$i+1,$pos-$i-1);
        $i=$pos;
        //$tnum++;
        //var_dump($tokens); 
        
        break;
      case ">":
      case "<":
      case "!": 
      case "=":
        $ch1 = substr($s,$i-1,1);
        if(!strpos(". !<>=",$ch1)) $tnum++; 
        // POZOR, break tam neni schvalne !!!
      default: 
        if (!isset($tokens[$tnum])) $tokens[$tnum]="";
        $tokens[$tnum] .= $ch;
        if(strpos(". !<>=",$ch)){
          $ch1 = substr($s,$i+1,1);
          if(!strpos(". =",$ch1)) $tnum++;
        }
        break;
    }	
    $i++;
  }
  
  $tpos = 0;
  $resh = "";
  $result = '';
  while($tpos < (count($tokens))){
    switch(strtoupper($tokens[$tpos])){
      case 'AND': $resh = "ogc:And"; $tpos++; break;
      case 'OR': $resh = "ogc:Or"; $tpos++; break;
      case 'BBOX': 
        $pom = explode(" ", str_replace(',', ' ', $tokens[$tpos+2]));
        $result .= "<ogc:Intersects><ogc:PropertyName>".$prefix."BoundingBox</ogc:PropertyName>
        <gml:Envelope><gml:lowerCorner>$pom[0] $pom[1]"
           ."</gml:lowerCorner><gml:upperCorner>$pom[2] $pom[3]"
           ."</gml:upperCorner></gml:Envelope></ogc:Intersects>";
        $tpos +=3;
        break;
      case 'IBBOX': 
        $pom = explode(" ", str_replace(',', ' ', $tokens[$tpos+2]));
        $result .= "<ogc:Within><ogc:PropertyName>".$prefix."BoundingBox</ogc:PropertyName>
        <gml:Envelope><gml:lowerCorner>$pom[0] $pom[1]"
           ."</gml:lowerCorner><gml:upperCorner>$pom[2] $pom[3]"
           ."</gml:upperCorner></gml:Envelope></ogc:Within>";
        $tpos +=3;
        break;
      case 'OBBOX': 
        $pom = explode(" ", str_replace(',', ' ', $tokens[$tpos+2]));
        $result .= "<ogc:Within><gml:Envelope><gml:lowerCorner>$pom[0] $pom[1]"
           ."</gml:lowerCorner><gml:upperCorner>$pom[2] $pom[3]"
           ."</gml:upperCorner></gml:Envelope>"
           ."<ogc:PropertyName>".$prefix."BoundingBox</ogc:PropertyName></ogc:Within>";
        $tpos +=3;
        break;
      default: 
        if(substr($tokens[$tpos],0,1)=="("){
          $result .= substr($tokens[$tpos],1); $tpos++;
        }  
        else{
          $par = "";
          switch($tokens[$tpos+1]){
            case '=': $operator = "ogc:PropertyIsEqualTo"; break;
            case '!=': 
            case '<>': $operator = "ogc:PropertyIsNotEqualTo"; break;
            case 'like': $operator = "ogc:PropertyIsLike"; $par=" wildCard=\"*\" singleChar=\"@\" escapeChar=\"\\\""; break;
            case '>': $operator = "ogc:PropertyIsGreaterThan"; break;
            case '>=': $operator = "ogc:PropertyIsGreaterThanOrEqualTo"; break;
            case '<': $operator = "ogc:PropertyIsLessThan"; break;
            case '<=': $operator = "ogc:PropertyIsLessThanOrEqualTo"; break;
           case 'gt': $operator = "ogc:GreaterThan"; break;
            default: $operator = "err-".$tokens[$tpos+1]; break; // kvuli chybam
          }
          if($this->sw == "gn") $name = $tokens[$tpos]; // hack kvuli geonetwork
          else $name = $prefix.$tokens[$tpos];
          if($prefix=='dc:'){
            if($tokens[$tpos]=='AnyText') $name = "csw:".$tokens[$tpos];
            else if($tokens[$tpos]=='modified') $name = "dct:".$tokens[$tpos]; 
          }
          $result .= "<$operator$par><ogc:PropertyName>".$name."</ogc:PropertyName><ogc:Literal>".$tokens[$tpos+2]."</ogc:Literal></$operator>";
          $tpos += 3;        
        }   
        break;
    }
  }
  if($resh) $result = "<$resh>
  $result</$resh>";
  return $result;
}
  
  function readServerList($listFile){
    $xml = new DomDocument;
    $xml->load($listFile); 
    $servers = $xml->getElementsByTagName("server");
    foreach($servers as $server){
      $attribs = $server->attributes;
      $name = $server->getAttribute("name");
      foreach($attribs as $attrib){ 
      	$cswlist[$name][$attrib->name] = $attrib->value;
      }
    }
    return $cswlist;
  }  
  
  function cql2filter($s, $prefix){
    return $this->xmlHead
    	. '<ogc:Filter xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">'
       	. $this->cql2filter_($s, $prefix) 
       	. '</ogc:Filter>';   
  }
 

  /***********************************************
   * vytvori XML pro dotaz pomoci getRecordById 
   *   
   * @ids      - seznam identifikatoru oddelenych carkou
   * @schema   - output schema 
   * @version  - verze sluzby (nepovinne)
   ***********************************************/     
  function prepareRequestById($ids, $schema, $version=""){
    $id_array = explode(",",$ids);
    $s = "";
    foreach($id_array as $id) $s .= "<id>".trim($id)."</id>";   
    $this->xml->loadXML($this->xmlHead."<query>$s</query>");
    if($this->sw=="gn"){
      	$pom = file_get_contents(CSW_XSL."/client2GetRecordByIdRequest$version".$this->method.".xsl");
      	$pom = str_replace("outputSchema=","OutputSchema=",$pom); // to je to ono
      	$this->xsl->loadXML($pom);
    }
    else{
    	$this->xsl->load(CSW_XSL."/client2GetRecordByIdRequest$version".$this->method.".xsl");
    }	
    $this->xp->importStyleSheet($this->xsl);
    $this->xp->setParameter("", "ElementSetName", $this->ElementSetName);
    if($this->debug) $this->xp->setParameter("", "debug", $this->debug);
    $this->xp->setParameter("", "outputSchema", $schema);
    $this->xp->setParameter("", "id", $id_array[0]); //TODO pro vice Id
     //if(substr($this->ElementSetName,0,2)=="dc") $outputSchema = OS_DC; else $outputSchema = OS_GMD;
    //$this->xp->setParameter("", "outputSchema", $outputSchema);
    $this->reqData = $this->xp->transformToXML($this->xml); // vrazi retezec s XML dotazem 
  }
  
  /***********************************************
   * vytvori XML pro dotaz pomoci getRecords
   *   
   * cql - dotaz
   * version - verze - podle toho se zvoli patricne xsl   
   ***********************************************/     
  function prepareRequest($cql, $version=""){
    if(substr($this->typeNames,0,3)=="csw"){
    	$prefix = "dc:"; 
    	$outputSchema = OS_DC; 
    	//$prefix = "csw:"; $outputSchema = OS_DC; // quli Intergrafu
    }
    else {
    	$prefix = "apiso:"; 
    	$outputSchema = OS_GMD;
    }
    if($cql) $this->xml->loadXML($this->cql2filter($cql, $prefix));
    // hack - Geonetwork
    if($this->sw=="gn"){
      	$pom = file_get_contents(CSW_XSL."/client2GetRecordsRequest$version".$this->method.".xsl");
      	$pom = str_replace("outputSchema=","OutputSchema=",$pom);
      	$this->xsl->loadXML($pom);
    }
    else {
    	$this->xsl->load(CSW_XSL."/client2GetRecordsRequest$version".$this->method.".xsl"); // verze 2 s kopirovanim stromu
    }
    $this->xp->importStyleSheet($this->xsl);
    //if($this->debug) $this->xp->setParameter("", "debug", $this->debug);
    $this->xp->setParameter("", "debug", $this->debug ? $this->debug : '');
    $this->xp->setParameter("", "ElementSetName", $this->ElementSetName);
    $this->xp->setParameter("", "resultType", $this->resultType);
    $this->xp->setParameter("", "typeNames", $this->typeNames);
    $this->xp->setParameter("", "outputSchema", $outputSchema);
    $this->xp->setParameter("", "startPosition", $this->startPosition);
    $this->xp->setParameter("", "maxRecords", $this->maxRecords);
    $this->xp->setParameter("", "hopCount", $this->hopCount);
    $this->xp->setParameter("", "sortBy", $this->sortBy);
    $this->xp->setParameter("", "id", "req-123");
    $this->reqData = $this->xp->transformToXML($this->xml); // vrazi retezec s XML dotazem 
  }
  
  /***********************************************
   * vytvori XML pro dotaz pomoci Update
   *   
   * data - XML s daty
   *    
   ***********************************************/     
  function prepareUpdate($data){
    $this->xml->loadXML($data);
    $this->xsl->load(CSW_XSL."/client2update.xsl"); // verze 2 s kopirovanim stromu
    $this->xp->importStyleSheet($this->xsl);
    $this->xp->setParameter("", "debug", $this->debug);
    $this->xp->setParameter("", "ElementSetName", $this->ElementSetName);
    $this->xp->setParameter("", "outputSchema", $this->outputSchema);
    $this->xp->setParameter("", "hopCount", $this->hopCount);
    $this->reqData = $this->xp->transformToXML($this->xml); // vrazi retezec s XML dotazem 
  }
  
  function saveRequest($name){
    if(!$this->reqData) return false;
    return file_put_contents(CSW_TMP."/".$name, $this->reqData);
  }
  
  function loadRequest($name){
    $s = file_get_contents(CSW_TMP."/".$name);
    if(!$s) return false;
    $this->reqData = $s;
    //obnova parametru
    $this->xml->loadXML($s);
    $this->xsl->load(CSW_XSL."/filter2micka.xsl");
    $this->xp->importStyleSheet($this->xsl);
    $s = explode("|",$this->xp->transformToXML($this->xml));
    eval($s[1]);
    $this->debug = $params["DEBUG"];
    return true;
  }
  
  function setXMLParam($name, $value){
    $root = $this->xml->getElementsByTagName('GetRecords')->item(0);
    $root->setAttribute($name, $value);
    $this->reqData = $this->xml->saveXML();
  }
  
  function getRequest(){
    return $this->reqData;
  }
  
  /******************************************
   * Odesle a zpracuje dotaz - synchronne
   *    
   * url - adresa csw serveru
   * sablona - XSL sablona pro zpracovani vysledku
   * 
   *****************************************/     
  function runRequest($url, $name, $template='', $user='', $password='', $params=Array()){
  
    if(!$this->reqData) exit('No query data available, run prepareRequest first!');   
    $s = $this->getDataByPost($url, $this->reqData, $user, $password);
    // --- ladici hlaska ---  
    if($this->debug){     
      return "request: ".$this->formatXML($this->reqData)." <hr> response: <br>". $this->formatXML($s)." <hr>";
    }
    if(!$s) return -1;
    //if(!$s) $s = $this->xmlHead."<err></err>";
    // --- transformace do HTML apod
    $par = Array("theName"=>$name, "lang"=>$this->lang);
    if($params) $par = array_merge($par, $params);
    if($template) return $this->processTemplate($s, $template, $par);
    else return($s);
  }

  function processTemplate($xmlString, $template, $params=Array()){
    if($xmlString) @$this->xml->loadXML($xmlString);
    if(!$this->xml) {
        return "";
    }
    $this->xsl->load($template);
    $this->xp->importStyleSheet($this->xsl);
    if(count($params) > 0){
        $this->xp->setParameter("", $params);
    }   
    return $this->xp->transformToXML($this->xml);
  }
  
  function processTemplateFile($xmlName, $template, $params=Array()){
    if($xmlName) $this->xml->load($xmlName);
    $this->xsl->load($template);
    $this->xp->importStyleSheet($this->xsl);
    if(count($params) > 0){
      reset($params);
      while(list($name, $value) = each($params)){
        $this->xp->setParameter("", $name, $value);      
      }
    }   
    return $this->xp->transformToXML($this->xml);
  }

} // konec tridy

