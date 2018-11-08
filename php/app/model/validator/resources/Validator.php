<?php
//require_once dirname(__FILE__).'/../../include/application/micka_config.php';

function isEmail($email){
	//return filter_var($email, FILTER_VALIDATE_EMAIL);
	if (preg_match('~^[-a-z0-9!#$%&\'*+/=?^_`{|}\~]+(\.[-a-z0-9!#$%&\'*+/=?^_`{|}\~]+)*@([a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\.)+[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])$~i', $email)) {
		return "1";
	}
	else {
		return "";
	}
	/*
	// verze rozšířená o kontrolu existenci domény
	//
	// preg pattern for user name
	// http://tools.ietf.org/html/rfc2822#section-3.2.4
	$atext = "[a-z0-9\!\#\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]";
	$atom = "$atext+(\.$atext+)*";

	// preg pattern for domain
	// http://tools.ietf.org/html/rfc1034#section-3.5
	$dtext = "[a-z0-9]";
	$dpart = "$dtext+(-$dtext+)*";
	$domain = "$dpart+(\.$dpart+)+";

	if(preg_match("/^$atom@$domain$/i", $addres)) {
			list($username, $host)=split('@', $addres);
			if(checkdnsrr($host,'MX')) {
				return "1";
			}
	}
	return "";
	*/
}

function getContents($url){
    $c = curl_init($url);
    curl_setopt($c, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($c, CURLOPT_SSL_VERIFYPEER, 0);
    curl_setopt($c, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($c, CURLOPT_MAXREDIRS, 20);
 	if(defined('CONNECTION_PROXY')){
        $proxy = CONNECTION_PROXY;
        if(defined('CONNECTION_PORT')) $proxy .= ':'. CONNECTION_PORT;
		curl_setopt($c, CURLOPT_PROXY, $proxy);	
	}
    $result = curl_exec($c);    
    //file_put_contents(__DIR__ . "/../../../../log/a.xml", $result);
    return $result;
}

function isRunning($url, $type, $d=false){
	// TODO jednoduche - vylepsit
	if(!trim($url)) return false;
	$type = strtoupper($type);
    $s = trim(getContents($url));
    $result = false;
	if(substr($type,0,2)=='WM' && strpos($s, "Capability>")!==false) $result = true;
	else if($type=='CSW' && strpos($s, "ServiceType>")!==false) $result = true;
	else if($type=='WFS' && strpos($s, "http://www.opengis.net/wfs")!==false) $result = true;
	else if($type=='WCTS' && strpos($s, "SourceCRS>")!==false) $result = true;
	else if($type=='GMD' && strpos($s, "MD_Metadata>")!==false) $result = true;
	if($d && $result){
	    $dom = new DOMDocument();
	    if(!$dom->loadXML($s)){
	        $dom->loadXML("<err>XML error</err>");
	    }
	    return $dom;
	}
	return $result;
}

function testConnection($url){
    // TODO jednoduche - vylepsit
    //$type = strtoupper($type);
    $t = microtime(true);
    $opts = array('timeout' => 3 );
    if(defined('CONNECTION_PROXY') && CONNECTION_PROXY != ""){
        $opts['proxy'] = CONNECTION_PROXY;
        $opts['request_fulluri'] = true;
    }
    $context = stream_context_create(array('http' => array($opts) ));
    @$s = file_get_contents($url, false, $context, 0, 1000);
    $t = microtime(true) - $t;
    //file_put_contents('/var/www/projects/tmp/'.time().'.xml',$s);
    if(!$s) return "";
    $result = '?';
    if(strpos($s, 'http://www.opengis.net/wms')!==false) $result = 'WMS-1.3.0';
    else if(strpos($s, 'http://www.opengis.net/wmts/1.0')!==false) $result = 'WMTS-1.1.0';
    else if(strpos($s, 'WMT_MS_Capabilities')!==false) $result = 'WMS-1.1.0';
    else if(strpos($s, 'http://www.opengis.net/wfs/2.0')!==false) $result = 'WFS-2.0.0';
    else if(strpos($s, 'WFS_Capabilities')!==false) $result = 'WFS-1.0.0';
    else if(strpos($s, "http://inspire.ec.europa.eu/schemas/inspire_dls/1.0")!==false) $result = 'download - ATOM';
    else if(strpos($s, "SourceCRS>")!==false) $result = 'transformation - WCTS';
    else if(strpos($s, '"http://www.opengis.net/cat/csw/2.0.2"')!==false) $result = 'CSW-2.0.2';
    else if( strpos($s, "MD_Metadata>")!==false) $result = 'ISO 19139 metadata';
    return $result."| ".sprintf("%.3f",$t);
}


function json2array($json) {  
  $json = substr($json, strpos($json,'{')+1, strlen($json)); 
  $json = substr($json, 0, strrpos($json,'}')); 
  $json = preg_replace('/(^|,)([\\s\\t]*)([^:]*) (([\\s\\t]*)):(([\\s\\t]*))/s', '$1"$3"$4:', trim($json)); 
  return $json;
  return json_decode('{'.$json.'}', true); 
}  

function isGemet($keyword, $lang){
    $lcodes = array(
            "cze"=>"cs",
            "dan"=>"da",
            "eng"=>"en",
            "fin"=>"fi",
            "fre"=>"fr",
            "ger"=>"de",
            "hun"=>"hu",
            "ita"=>"it",
            "lav"=>"lv",
            "nor"=>"no",
            "pol"=>"pl",
            "por"=>"pt",
            "slo"=>"sk",
            "slv"=>"sl",
            "spa"=>"es",
            "swe"=>"sv"          
    );
	$s = getContents("http://www.eionet.europa.eu/gemet/getConceptsMatchingRegexByThesaurus?thesaurus_uri=http://inspire.ec.europa.eu/theme/&language=".$lcodes[$lang]."&regex=".urlencode($keyword));
	if(trim($s)!='[]') {
	    return $keyword;
	}
	return "";
	/*$s = str_replace(array('\r\n', '"', 'string'), array(' ','\"', 'name'), $s);
	eval('$s="{results:'.$s.'}";');
	$s = json2array($s);
	return $s;
	return var_export($s,true);*/
}

class Validator{

    var $xp  = null;
    var $xml = null;
    var $xsl = null;
    var $type = null;
    var $schemas = array(
        //"gmd" => "http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd", // FIXME - uvest do validace
        "wms" => 'http://inspire.ec.europa.eu/schemas/inspire_vs/1.0/inspire_vs.xsd'
    );
    var $icons = array(
        "pass" => "check-circle",
        "warning" => "exclamation-triangle",
        "fail" => "ban",
        "notice" => "info-circle"
        
    );
    
    function __construct($type="gmd", $lang='eng'){
        if(!in_array($type, array("gmd", "gmd_inspire", "wms", "csw", "download"))) $type="gmd";
        libxml_use_internal_errors(true);
        $this->type = $type;
        $this->xml = new DomDocument;
        $this->xsl = new DomDocument;
        $this->xsl->load(dirname(__FILE__).'/'.$type.'.xsl');
        $this->xp = new XsltProcessor();
        $this->xp->registerPHPFunctions();
        $this->xp->importStyleSheet($this->xsl);
        $this->xp->setParameter("", "LANG", $lang);
        $this->msg = simplexml_load_file(dirname(__FILE__).'/labels-'.$lang.'.xml');
        $this->result = null;
        $this->XMLResult = null;
        $this->pass = 0;
        $this->fail = 0;
        $this->warn = 0;
        $this->notice = 0;
    }  
  
	function __destruct(){
		unset($this->xml); $this->xml=null; 
		unset($this->xsl); $this->xsl=null; 
		unset($this->xp);  $this->xp=null; 
	}

	function run($xmlString){
	    //echo $xmlString; die;
		$valid = @$this->xml->loadXML($xmlString);
		//die($valid);
		if($valid) {
		    //$schema = $this->schemas[$this->type];
		    //die('-----------> ' . $schema);
		    if(isset($this->schemas[$this->type])){
		        if(!$this->xml->schemaValidate($this->schemas[$this->type])){
		            $this->xsdErrors = $this->getXsdErrors();
		            //var_dump($this->xsdErrors); die;
		        }
		    }    
    	    $this->result = $this->xp->transformToXML($this->xml);         
		}
		else{
			$this->result = "<errList><error>".(string)$this->msg->msg->notLoad."</error></errList>";
		}
	}
  
	/*function displayXmlErrors() {
	    $errors = libxml_get_errors();
	    $err = "";
        // echo  LIBXML_ERR_WARNING ." ". LIBXML_ERR_ERROR ." ". LIBXML_ERR_FATAL;
	    foreach ($errors as $error) {
	        $err .= "<error>
                <code>" . $error->level . "</code>
                <line>" . $error->file . "  line ". $error->line."</line>
                <message>" . $error->message . "</message>
            </error>";
	    }
	    libxml_clear_errors();
	    return "<errList>".$err."</errList>";
	}*/
	
	function getXsdErrors() {
	    $errors = libxml_get_errors();
	    $err = array();
	    // echo  LIBXML_ERR_WARNING ." ". LIBXML_ERR_ERROR ." ". LIBXML_ERR_FATAL;
	    foreach ($errors as $error) {
	        $err[] = array(
	            "code" => "XML",
	            "value" => $error->file . "  line ". $error->line, 
	            "err" => $error->message,
	            "pass" => false
	        );        
	               /* . $error->level . "</code>
	        <line>" . $error->file . "  line ". $error->line."</line>
	        <message>" . $error->message . "</message>
	        </error>";*/
	    }
	    libxml_clear_errors();
	    return $err;
	}
	
	function asXML(){
		return $this->result;
	} 
	
	private function ar($xml, $root=true){
		$tests = array();
		if($xml->error) {
		    foreach ($xml->error as $err){
    			$tests[] = array(
    				'code' => $err->code,
    				"value" => $err->line,
    				'err' => (string) $err->message
    			); 
		    } 
		}
        if($root){
            //$tests = array_merge($tests, $this->xsdErrors);
            if(isset($this->xsdErrors)) foreach($this->xsdErrors as $t){
                $tests[] = $t;
                if( $t['level'] != 'i'){
                    if($t['pass']) $this->pass++;
                    else {
                        if($t['level']=='c') $this->warn++;
                        elseif($t['level']=='n') $this->notice++;
                        else $this->fail++;
                    }
                }               
            }
        }
		$passAll = true;
 		foreach ($xml->test as $t){
		  	$test = array();
			$test['code'] = (string) $t['code'];
			$test['level'] = (string) $t['level'];
			$test['description'] = (string) $t->description;
			$test['xpath'] = (string) $t->xpath;
			$test['value'] = trim((string) $t->value);
			$test['pass'] = (boolean) $t->pass;
			$test['deepPass'] = $test['pass'];
			$test['err'] = trim((string) $t->err);
			if($t->test){
				$test['tests'] = $this->ar($t, false);
				// hledani neproslych podtestu
				if($test['deepPass']){
					foreach($test['tests'] as $t){
						if(!$t['deepPass']){
							$test['deepPass'] = false;
							break;
						}
					}
				}
			}
			$tests[] = $test;
			if( $test['level'] != 'i'){
				if($test['pass']) $this->pass++; 
				else {
	        		if($test['level']=='c') $this->warn++;
	        		elseif($test['level']=='n') $this->notice++;
	        		else $this->fail++;          
	      		}
			}
  		}
  		return $tests;
  	}
  
    private function createHTML($result){
  	    $output = "";
		foreach($result as $row){
			// vyhodi informativni vety
			if($row['level']=='i') continue;
			if($row['pass']){ 
				$class = "pass"; 
			}
			else {
				if($row['level']=='c'){ 
					$class="warning";
					$warnings++;
				}	 
				else if($row['level']=='n'){
				    $class="notice";
				    $notices++;				    
				}
				else {
					$class = "fail";
					$fails++;
				}
				if(!$row['err']) $row['err'] = (string)$this->msg->msg->mv;
				if($row['xpath']) $row['err'] .= " (" . $row['xpath'] . ")";
			}
			$output .= '<div class="row"><div class="hd"><span class="'.$class.'"><i class="fa fa-'.$this->icons[$class].' fa-fw fa-lg"></i></span> (' . $row['code'] . ')</div>';
			$output .= "<div class='msgs'><div class='title' id='VAL-".$row['code']."'>" . $row['description'] . "</div>";
			if($row['value']) $output .= "<div class='value'>" . $row['value'] . "</div>";
			if($row['err']) $output .= "<div class='msg-".$class."'>" . $row['err'] . "</div>";
			$output .= "</div></div>";
			if(isset($row['tests']) && $row['tests']) {
				$output .= "<div class='row' style='margin-left:20px;'>"; 
				$output .= $this->createHTML($row['tests']);
				$output .= "</div>";
			}
		}
		return $output;
	} 	 
  	 	
  	function asHTML($short=false){
  		$result = $this->asArray($short);
		$output = '<div id="owsValidator"><h2><a class="go-back" style="float:right;" href="javascript:history.go(-1);" title="'.(string)$this->msg->msg->back.'"></a>'.$this->title.'</h2>';
  		if($short && $this->fail==0 && $this->warn==0) $output .= '<div class="msg-ok">'.(string) $this->msg->msg->ok.'</div>';
		$output .= $this->createHTML($result);
		$output .= "<div style='clear:both; border-bottom:1px solid #909090; margin: 10px 0px 8px 0px;'></div>
		  <div class='row valid-legend' style='height:16px;'>
		  	<div style='float:right'>".(string)$this->msg->msg->version. 
		  	": ".$this->version."</div>
		  	<span class='pass'>".(string)$this->msg->msg->pass. 
		  	": <b>".$this->pass."</b> </span> 
		  	<span class='fail'>".(string)$this->msg->msg->fail.
		  	": <b>".$this->fail."</b> </span> 
		  	<span class='warning'> ".(string)$this->msg->msg->warning.
		  	": <b>".$this->warn."</b> </span>
		  	<span class='notice'> ".(string)$this->msg->msg->notice.
		  	": <b>".$this->notice."</b> </span>
		  	</div></div>";  		
		return $output;
  	}

  	function asHTMLSmall($short=false, $showTitle=true){
  		$result = $this->asArray($short);
  		$output = '<div id="owsValidator">';
  		if($showTitle) $output .= '<h2>'.$this->title.'</h2>';
  		if($short && $this->fail==0 && $this->warn==0) $output .= '<div class="msg-ok">'.(string) $this->msg->msg->ok.'</div>';
  		$output .= $this->createHTML($result) . "</div>";	
		return $output;
  	}

  	function asArray($short=false){
  		try{
  			@$xml = new SimpleXMLElement($this->result);
  			$this->title = $xml['title'];
  			$this->version = $xml['version'];
  			$tests = $this->ar($xml);
  		}
  		catch (Exception $e){
			$tests[] = array(
				'code' => "XML",
				"value" => "XML formát dat je nekompatibilní se schématem.",
				'err' => "STOP"
			);   				
  		}
  		if($short){
  			$t1 = array();
  			foreach($tests as $test){
  				if(!$test['deepPass']) $t1[] = $test;
  			}
  			return $t1;
  		}
   		return $tests;
  	}
  	
    function getPass(){
        $result = $this->asArray();
        $primary = 0;
        foreach($result as $row){
        	if($row['code']=='primary'){
        		if($row['pass']) $primary=1;
        		break;
        	}
        }
        return array(
            "pass" => $this->pass,
            "fail" => $this->fail,
            "warn" => $this->warn,
            "notice" => $this->notice,
            "primary" => $primary
        );
    }
    
	function asJSON(){
		return json_encode($this->asArray());
	}
  
} // class
