<?php
namespace Micka;
/*******************************************************
 * OGC Catalog service server - CS-W 2.0.2
 * Help Service Remote Sensing
 * verze 6.0.20
 * 2018-10-25
 *******************************************************/

/**
 * OGC Catalogue service implementation
 *
 */
class Csw{
    private $user;
    private $appParameters;
    private $dbContext;
    var $xp  = null;
    var $xml = null;
    var $xsl = null;
    var $logText = "";
    var $logFile = "";
    var $params = null;
    var $requestType = null;
    var $input = "";
    var $subset = null;
    var $headers = array(HTTP_XML);
    var $isXML = true;
    var $error = null;

    var $sch = array(
        "csw" => array(
                "NS" => "http://www.opengis.net/cat/csw/2.0.2",
                "httpHdr" => array(
                    "Content-Type: application/xml"
                ),
                "header" => '<csw:GetRecordsResponse xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" version="2.0.2">
                <csw:RequestId>[id]</csw:RequestId>
                <csw:SearchStatus timestamp="[timestamp]"/>
                <csw:SearchResults numberOfRecordsMatched="[matched]" numberOfRecordsReturned="[returned]" nextRecord="[next]" elementSet="[elementset]">',
                "footer" => '</csw:SearchResults></csw:GetRecordsResponse>',
                "template" => "dc",
                "typeNames" => "csw:record"

            ),
        "gmi" => array(
                "NS" => "http://standards.iso.org/iso/19115/-2/gmi/1.0",
                "httpHdr" => array(
                        "Content-Type: application/xml"
                ),
                "header" => '<csw:GetRecordsResponse xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" version="2.0.2">
                    <csw:RequestId>[id]</csw:RequestId>
                    <csw:SearchStatus timestamp="[timestamp]"/>
                    <csw:SearchResults numberOfRecordsMatched="[matched]" numberOfRecordsReturned="[returned]" nextRecord="[next]" elementSet="[elementset]">',
                "footer" => '</csw:SearchResults></csw:GetRecordsResponse>',
                "template" => "iso-2",
                "typeNames" => "gmi:md_metadata"
            ),
        "gmd" => array(
                "NS" => "http://www.isotc211.org/2005/gmd",
                "httpHdr" => array(
                        "Content-Type: application/xml"
                ),
                "header" => '<csw:GetRecordsResponse xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" version="2.0.2">
                    <csw:RequestId>[id]</csw:RequestId>
                    <csw:SearchStatus timestamp="[timestamp]"/>
                    <csw:SearchResults numberOfRecordsMatched="[matched]" numberOfRecordsReturned="[returned]" nextRecord="[next]" elementSet="[elementset]">',
                "footer" => '</csw:SearchResults></csw:GetRecordsResponse>',
                "template" => "iso",
                "typeNames" => "gmd:md_metadata"
            ),
        "dcat" =>array(
                "NS" => "http://www.w3.org/ns/dcat#",
                "httpHdr" => array(
                    "Content-Type: application/rdf+xml\n",
                    "Content-Disposition: attachment; filename=micka.rdf"
               ),
                "header" => '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                <dcat:Catalog xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:dct="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" rdf:about="[mickaURL]">
                <dct:title>[title]</dct:title>
                <dct:description>[subtitle]</dct:description>
                <dct:language>en</dct:language>
                <dct:language>cs</dct:language>
                <foaf:homepage rdf:resource="[mickaURL]"/>
                <dct:publisher>
                    <foaf:Organization>
                        <foaf:name>[authName]</foaf:name>
                        <foaf:mbox>[authEmail]</foaf:mbox>
                    </foaf:Organization>
                </dct:publisher>',
                "footer" => "</dcat:Catalog></rdf:RDF>",
                "template" => "dcat"
            ),
        "Atom" => array(
                "NS" => "http://www.w3.org/2005/Atom",
                "httpHdr" => array(
                    "Content-Type: application/atom+xml",
                ),
                "header" => '<feed xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/" xmlns="http://www.w3.org/2005/Atom" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2005/Atom http://inspire-geoportal.ec.europa.eu/schemas/inspire/atom/1.0/atom.xsd">
                    <title>[title]</title>
                    <subtitle>[subtitle]</subtitle>
	                <link href="[mickaURL]/csw?SERVICE=CSW&amp;REQUEST=GetCapabilities" rel="describedby" type="application/xml"/>
                    <link href="[mickaURL]" rel="via"/>
                    <id>[mickaURL]</id>
                    <updated>[timestamp]</updated>
            	    <author>
            	    	<name>[authName]</name>
            	    	<email>[authEmail]</email>
            	    </author>',
                "footer" => "</feed>",
                "template" => "atom"

            ),
        "kml" => array(
                "NS" => "http://www.opengis.net/kml/2.2",
                "httpHdr" => array(
                    "Content-Type: application/vnd.google-earth.kml+xml\n",
                    "Content-Disposition: filename=micka.kml"
               ),
               "header" => '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
                  <Document>
                     <name>micka.kml</name>
                     <description>MICKA Metadata catalogue search result</description>
                     <open>1</open>
                  <Style id="bx">
                    <PolyStyle>
                      <colorMode>random</colorMode>
                      <fill>1</fill>
                      <outline>1</outline>
                    </PolyStyle>
                    <LineStyle>
                      <colorMode>random</colorMode>
                      <width>3</width>
                    </LineStyle>
                  </Style>',
                "footer" => "</Document></kml>",
                "template" => "kml"
            ),
            "georss" => array(
                "NS" => "http://www.georss.org/georss",
                "header" => '<feed xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/" xmlns="http://www.w3.org/2005/Atom">
                <title>[title]</title>
                <subtitle>[subtitle]</subtitle>
                <link href="[path]" rel="via"/>
                <author>
                <name>[authName]</name>
                <email>[authEmail]</email>
                </author>',
                "footer" => "</feed>",
                "template" => "atom"
            ),
            "json" => array(
                "NS" => 'json',
                "httpHdr" => array(
                    "Content-Type: application/json\n"
                ),
                "header" => '{
                "title":"[title]","subtitle":"[subtitle]",
                "matched": [matched],
                "returned": [returned],
                "next": [next],
                "records":[',
                "footer" => "]}",
                "template" => "json"
            ),
            "sitemap" => array(
                "NS" => "http://www.sitemaps.org/schemas/sitemap/0.9",
                "httpHdr" => array(
                        "Content-Type: application/xml"
                ),
                "header" => '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
                "footer" => "</urlset>",
                "template" => "sitemap"
            ),
            "os"	=> array(
                    "NS"=>"http://a9.com/-/spec/opensearch/1.1/"
                    )
            //"rdf"	=> "http://www.w3.org/1999/02/22-rdf-syntax-ns",
            //"oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/",
            //"oai_marc" => "http://www.openarchives.org/OAI/1.1/oai_marc",
            //"marc21" => "http://www.openarchives.org/OAI/2.0/"
    );


  /**
   * CSW constructor
   *
   * @param string $logpath log file name with path (optional)
   */
    function __construct($logpath="", $subset=false){
        //FIXME - remove this temporary parameters
        global $tmp_nbcontext,$tmp_identity, $tmp_appparameters;
        $this->user = $tmp_identity;
        $this->appParameters = $tmp_appparameters;
        $this->dbContext = $tmp_nbcontext;
        $this->mickaURL = $this->appParameters['hostUrl'] . $this->appParameters['basePath'] . $this->appParameters['locale'];

        $this->xml = new \DomDocument;
        $this->xsl = new \DomDocument;
        $this->xp = new \XsltProcessor();
        $this->xp->registerPhpFunctions();
        $this->subset = $subset;
    	$logpath = CSW_LOG;
        if($logpath) $this->logFile = $logpath."/cswlog";
        foreach($this->sch as $k => $v){
            $this->schemas[$v['NS']] = $v;
        }
    }

    function __destruct(){
        unset($this->xml); $this->xml=null;
        unset($this->xsl); $this->xsl=null;
        unset($this->xp);  $this->xp=null;
    }

  	private function validip($ip) {
		if (!empty($ip) && ip2long($ip)!=-1) {
			$reserved_ips = array (
	 			array('0.0.0.0','2.255.255.255'),
	 			array('10.0.0.0','10.255.255.255'),
	 			array('127.0.0.0','127.255.255.255'),
	 			array('169.254.0.0','169.254.255.255'),
	 			array('172.16.0.0','172.31.255.255'),
	 			array('192.0.2.0','192.0.2.255'),
	 			array('192.168.0.0','192.168.255.255'),
	 			array('255.255.255.0','255.255.255.255')
	 		);
			foreach ($reserved_ips as $r) {
				$min = ip2long($r[0]);
				$max = ip2long($r[1]);
				if ((ip2long($ip) >= $min) && (ip2long($ip) <= $max)) return false;
			}
			return true;
			}
		else {
			return false;
		}
	}

	private function getIP() {
		if (isset($_SERVER["HTTP_CLIENT_IP"]) && $this->validip($_SERVER["HTTP_CLIENT_IP"])) {
 			return $_SERVER["HTTP_CLIENT_IP"];
 		}
		if(isset($_SERVER["HTTP_X_FORWARDED_FOR"])) foreach (explode(",",$_SERVER["HTTP_X_FORWARDED_FOR"]) as $ip) {
			if ($this->validip(trim($ip))) {
				return $ip;
			}
		}
		if (isset($_SERVER["HTTP_X_FORWARDED"]) && $this->validip($_SERVER["HTTP_X_FORWARDED"])) {
			return $_SERVER["HTTP_X_FORWARDED"];
		}
		elseif (isset($_SERVER["HTTP_FORWARDED_FOR"]) && $this->validip($_SERVER["HTTP_FORWARDED_FOR"])) {
			return $_SERVER["HTTP_FORWARDED_FOR"];
		}
		elseif (isset($_SERVER["HTTP_FORWARDED"]) && $this->validip($_SERVER["HTTP_FORWARDED"])) {
			return $_SERVER["HTTP_FORWARDED"];
		}
		else {
			return $_SERVER["REMOTE_ADDR"];
		}
	}


    function exception($code, $locator, $text, $return=false){
        $errCode[0] = "NoApplicableCode";
        $errCode[1] = "OperationNotSupported";
        $errCode[2] = "MissingParameterValue";
        $errCode[3] = "InvalidParameterValue";
        $errCode[4] = "InvalidParameterName";
        $errCode[5] = "NonexistentType";
        $errCode[6] = "TransactionFailed";

        $h = '<ows:ExceptionReport
        xmlns:ows="http://www.opengis.net/ows/1.1" version="1.1.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.opengis.net/ows/1.1 http://schemas.opengis.net/ows/1.1.0/owsExceptionReport.xsd">';
        if($locator) $locator = ' locator="'.$locator.'"';
        $s = '<ows:Exception exceptionCode="'.$errCode[$code].'"'.$locator.'>';
        if($text) $s .= "<ows:ExceptionText>$text</ows:ExceptionText>";
        if(isset($this->params['SOAP'])&& $this->params['SOAP']){
        	$message = XML_HEADER.SOAP_HEADER."
        	<soap:Fault>
             <soap:Code>
                <soap:Value>soap:Server</soap:Value>
             </soap:Code>
             <soap:Reason>
                <soap:Text xml:lang=\"en\">A server exception was encountered.</soap:Text>
             </soap:Reason>
             <soap:Detail>
        	".$h.$s."</ows:Exception></ows:ExceptionReport></soap:Detail></soap:Fault>".SOAP_FOOTER;
        }
        else $message = XML_HEADER.$h.$s."</ows:Exception></ows:ExceptionReport>";
        $this->logText .= $s."\n";
        $this->saveLog();
        if($return){
            return $message;
        }
        else {
            header(HTTP_XML);
            die($message);
        }
    }


  	// hack kvuli primemu pristupu pro CENIA pres POST
  	function dirtyParams($params){
  		while(list($key,$val) = each($params)){
  			$params[strtoupper($key)]=html_entity_decode($val);
  		}
	  	$params['SERVICE'] = 'CSW';
	  	$params['VERSION'] = '2.0.2';
	  	$params['CONSTRAINT_LANGUAGE'] = 'CQL';

	  	if(isset($params['QUERY'])){
	  		$params['CONSTRAINT'] = $params['QUERY'];
	  		unset($params['QUERY']);
	  		$params['REQUEST'] = 'GetRecords';
	  		$params['TYPENAMES'] = 'gmd:MD_Metadata';
	  		if(!isset($params['OUTPUTSCHEMA'])) $params['OUTPUTSCHEMA'] = $this->sch['gmd']['NS'];
	  		$params['ISGET'] = true;
	  		if(!isset($params['FORMAT']) || strpos($params['FORMAT'],'json')!==false){
	  			$params['FORMAT'] = "application/json";
	  			//$params['ELEMENTSETNAME'] = 'full';
	  		}
	  		if(!isset($params['USER'])) $params['USER'] = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
	  		if(isset($params['START'])){
	  			$params['STARTPOSITION'] = intval($params['START']);
	  			if($params['FORMAT']=='application/json'){
	  				$params['STARTPOSITION']++;
	  			}
	  		}
	  		if(isset($params['LIMIT'])){
	  			$params['MAXRECORDS'] = intval($params['LIMIT']);
	  		}
	  	}
	  	// rss kanál
	  	/*else if(isset($params['REQUEST']) && $params['REQUEST']=='rss'){
	  		$dni = intval($params['DAYS']);
	  		unset($params['DAYS']);
	  		$params['REQUEST'] = 'GetRecords';
	  		$params['CONSTRAINT'] = "modified >= '".date("Y-m-d", time()-($dni*3600*24))."'";
	  		$params['TYPENAMES'] = 'gmd:MD_Metadata';
	  		$params['OUTPUTSCHEMA'] = 'http://www.georss.org/georss';
	  		if(isset($params['START'])){
	  			$params['STARTPOSITION'] = intval($params['START']);
	  		}
	  		if(isset($params['LIMIT'])){
	  			$params['MAXRECORDS'] = intval($params['LIMIT']);
	  		}
	  		if(!isset($params['SORTBY'])){
	  		    $params['SORTBY'] = "date:D";
	  		}
	  		if(!$params['USER']) $params['USER'] = 'dummy';
	  	}*/
	  	else if(isset($params['ID']) && isset($params['FORMAT'])){
	  		$params['TYPENAMES'] = 'gmd:MD_Metadata';
	  		$params['REQUEST'] = 'GetRecordById';
	  	}
        $q1 = '';
        if(isset($params['RESID']) && isset($params['RESID'])){
            $q1 = " and resourceidentifier=".$params['RESID'];
        }
        if(isset($params['BBOX']) && isset($params['BBOX'])){
            $q1 = " and BBOX=".$params['BBOX'];
        }
        if(isset($params['RESNS']) && isset($params['RESNS'])){
            //TODO dodelat
            //$q1 = " and BBOX=".$params['BBOX'];
        }
	  	//echo "<pre>"; var_dump($params); die();
        if(isset($params['Q']) && isset($params['Q'])){
            $params['CONSTRAINT'] = "FullText=".$params['Q'];
        }
        if($q1){
            $params['CONSTRAINT'] = $params['CONSTRAINT'] ? "(".$params['CONSTRAINT'].") and ".$q1: $q1;
        }
  		return $params;
  	}

  	function getDataFromURL($url, $language='eng'){
  		$s = file_get_contents($url); //TODO kontrola url
  		$this->params['LANGUAGE'] = $language;
  		if($s){
  			$this->xml->loadXML($s);
  			//echo $s;
  			//$s = $this->asHTML($this->xml, CATCLIENT_PATH."/xsl/iso2htmlFull.xsl");  // TODO - podle konfigurace
  			$s = $this->asHTML($this->xml, __DIR__ ."/xsl/iso2htmlFull_.xsl");  // TODO - podle konfigurace
  		}
  		if($s) return $s;
  		return "Metadata document not found!";
  	}

  function processParams($params){
  	if(!isset($params["ISGET"]) || !$params["ISGET"]){
   		$this->input = file_get_contents('php://input', false, null, null, CSW_MAXFILESIZE); //TODO obslouzit chybu
  	}

    // POST
    if($this->input){
		$this->input = stripslashes($this->input);
		$this->xml->loadXML($this->input);
		$this->xsl->load(__DIR__ . "/xsl/filter2micka.xsl");
		$this->xp->importStyleSheet($this->xsl);
		$this->xp->setParameter("", "fulltext", DB_FULLTEXT);
		$processed = $this->xp->transformToXML($this->xml);
		$IDs = Array();
		$processed = html_entity_decode($processed);
		//$processed = str_replace("&amp;", "&", $processed);
		//echo $processed; die;
		eval($processed);
		$this->params = $params;
		$this->requestType=1;
    }

    // GET
	else if(count($params) > 0){
        // odstranění ošetření dat způsobeného direktivou magic_quotes_gpc
        if (get_magic_quotes_gpc()) {
    		$process = array(&$params);
    		while (list($key, $val) = each($process)) {
    			foreach ($val as $k => $v) {
    				unset($process[$key][$k]);
    				if (is_array($v)) {
    					$process[$key][($key < 5 ? $k : stripslashes($k))] = $v;
    					$process[] =& $process[$key][($key < 5 ? $k : stripslashes($k))];
    				}
    				else {
    					$process[$key][stripslashes($k)] = stripslashes($v);
    				}
    			}
    		}
    	}
    	foreach($params as $k => $v){
    		$params[$k] = urldecode($v);
    	}
      	$this->params = array_change_key_case($params, CASE_UPPER);
      	$this->params['CONSTRAINT'] = isset($this->params['CONSTRAINT']) ? html_entity_decode($this->params['CONSTRAINT']) : "";
      	$this->requestType=0;
    }
    // prazdny dotaz
    else{
       	$this->exception(0, "", "Missing request");
    }
    if(!isset($this->params['Q'])) $this->params['Q'] = "";
  }

  function getParamL($name){
      if(!isset($this->params[$name])) return "";
	  return str_replace("csw:", "", strtolower($this->params[$name]));
  }


  /**
   * Main Run method - runs the CSW server
   *
   */
  function run($params, $processParams = true){
    $this->startTime = microtime(true);
    if($processParams) $this->processParams($params);
    $ip = $this->getIP();
    if(isset($params['user']) || isset($this->params['USER']) || isset($this->params['TOKEN'])){ //TODO taky vyresit dvoucestnost params
        // kontrola IP adresy
        // zde je umozneno pro urcite adresy editovat bez prihlaseni jako ADMIN
        if(strpos(MICKA_ADMIN_IP, $ip)!==false && isset($this->params['USER'])){
            $_SESSION['u'] = $this->params['USER'];
            $_SESSION['ms_groups'] = $this->params['USER'];
            $mickaProj['users'][$_SESSION['u']] = 'rw*';
            $currProj['micka'] = $mickaProj;
            $_SESSION['maplist'] = $currProj;
        }
    	else {
    	    //prihlaseni(htmlspecialchars($params['user']), htmlspecialchars($params['pwd']), $this->params['TOKEN']);
    	    //getProj();
        }
    }
    $this->params['timestamp'] = gmdate("Y-m-d\TH:i:s");
    $this->params['mickaURL'] = $this->mickaURL;
    $this->params['buffered'] = isset($params['buffered']) ? $params['buffered'] : '';
    //$this->params['LANG2'] = ($this->appParameters['appDefaultLocale'] != $this->appParameters['appLocale']) ? $this->appParameters['appLocale'].'/' : '';
    $this->params['viewerURL'] = isset($this->appParameters['map']['viewerURL'])
        ? $this->appParameters['map']['viewerURL']
        : '';
    if(!isset($this->params['CB'])) {
        $this->params['CB'] = "";
        if(isset($_SESSION["micka"]["cb"])) $this->params['CB'] .= $_SESSION["micka"]["cb"];
    }
    if(!isset($this->params['LANGUAGE'])) $this->params['LANGUAGE'] = MICKA_LANG;
    if(!isset($this->params['DEBUG'])) $this->params['DEBUG'] = 0;
    if(!isset($this->params['SOAP'])) $this->params['SOAP'] = false;
    if(!isset($this->params['SORTBY'])) $this->params['SORTBY'] = "";
    if($this->params['DEBUG']>0){
      	var_dump($this->params);
      	echo "<hr>";
    }
    else{
        if($this->params['SOAP']) $this->header = HTTP_SOAP;
    }
    //$remoteIP = $this->getIP();
    $this->logText = date("Y-m-d\TH:i:s")."|". ($this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest' ) ."|".$_SERVER['REQUEST_METHOD']."|".$ip."| |";
    //reset($this->params);
    //if($this->params['ID']) $this->logText .= "[ID=".$this->params['ID']."]";
    //else if($this->params['QSTR']) $this->logText .= @json_encode($this->params['QSTR']); //TODO zmenit
    $request = $this->getParamL('REQUEST');
    /*if($request=="rss") {
    	return $this->rss();
    }*/
    if(!$this->params['SERVICE']) $this->exception(2, "SERVICE", "Missing 'SERVICE' parameter");
    if($this->getParamL('SERVICE')!='csw') $this->exception(3, "service", "Service MUST be CSW");
    if(!$request) $this->exception(2, "REQUEST", "Missing 'REQUEST' parameter");
    if($request!='getcapabilities'){
      if(!$this->params['VERSION']) $this->exception(2, "VERSION", "Missing 'VERSION' parameter");
      if($this->params['VERSION']!="2.0.2") $this->exception(3, "VERSION", "Only 2.0.2 version currently supported");
    }
    // trideni podle request
    switch ($request) {
      case 'getcapabilities': $result = $this->getCapabilities(); break;
      case 'describerecord': $result = $this->describeRecord(); break;
      case 'getrecords': $result = $this->getRecords(); break;
      case 'getrecordbyid': $result = $this->getRecordById(); break;
      case 'transaction': $result = $this->transaction(); break;
      case 'harvest':
        //prihlaseni(null, null); //TODO - change
        //getProj();
        if($this->user->isInRole('editor')) $result = $this->harvest(true); break;
      case 'getharvest': $result = $this->harvest(false); break;
      default: $this->exception(3, "request", $this->params['REQUEST']." is not supported request value.");
    	break;
    }
    if($this->error){
        return $this->exception($this->error[0], $this->error[1], $this->error[2], (strpos($this->params['FORMAT'], 'html')!==false)); //TODO nejak lepe osetrit html
    }
    if($this->params['SOAP']) $result = SOAP_HEADER.$result.SOAP_FOOTER;
    if($this->isXML) $result = XML_HEADER.$result;
    $this->logText .= "|500|".(microtime(true)-$this->startTime);
    $this->saveLog();
    return $result;
  }


    function asJSON($xml, $head, $ext=false){
        $this->xsl->load(__DIR__ ."/xsl/iso2json.xsl");
        $this->xp->importStyleSheet($this->xsl);
        $this->xp->setParameter('', 'lang', $this->params['LANGUAGE']);
        $output = $this->xp->transformtoXML($xml);
        //echo $output;
        eval($output);
        for($i=0; $i<count($json['records']); $i++){
        	$json['records'][$i]['abstract'] = html_entity_decode($json['records'][$i]['abstract']);
            if($ext){
            	$json['records'][$i]['public'] = intval($head[$i]['DATA_TYPE']);
            	$json['records'][$i]['creator'] = $head[$i]['CREATE_USER'];
            	$json['records'][$i]['updator'] = $head[$i]['LAST_UPDATE_USER'];
            	$json['records'][$i]['updated'] = $head[$i]['LAST_UPDATE_DATE'];
            	$json['records'][$i]['edit_group'] = $head[$i]['EDIT_GROUP'];
            	$json['records'][$i]['view_group'] = $head[$i]['VIEW_GROUP'];
            	$json['records'][$i]['valid'] = intval($head[$i]['VALID']);
            	$json['records'][$i]['mayedit'] = $head[$i]['edit'];
            	$json['records'][$i]['harvest_source']  = $head[$i]['harvest_source'];
            	$json['records'][$i]['harvest_title']  = $head[$i]['harvest_title'];
            	$json['records'][$i]['inspire']  = $head[$i]['FOR_INSPIRE'];
            }
        }
		if($json['next']>0) $json['next']--; // v json je index od 0
    	return json_encode($json);
    }

    function asHTML($xml, $template){
    	//die($xml->saveXML());
        $u = parse_url($template);
        if(isset($u['scheme']) && ($u['scheme']=='http' || $u['scheme']=='https')){
            $ch = curl_init($template);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 5 );
			if(defined('CONNECTION_PROXY')){
			    $proxy = CONNECTION_PROXY;
				if(defined('CONNECTION_PORT')) $proxy .= ':'. CONNECTION_PORT;
				curl_setopt($ch, CURLOPT_PROXY, $proxy);
			}
            $result = curl_exec ($ch);
            curl_close ($ch);
			if(!$result) die("html template $template not loaded.");
            if(!$this->xsl->loadXML($result)) die("Malformed xsl template ".$template);
    	}
        else {
            if(!$this->xsl->load(__DIR__ ."/xsl/$template.xsl")) die("html template $template not loaded.");
        }
        $this->xp->importStyleSheet($this->xsl);
        if(!$this->params['LANGUAGE']) $this->params['LANGUAGE'] = MICKA_LANG;
        $this->xp->setParameter('', 'LANGUAGE', $this->params['LANGUAGE']);
        $this->xp->setParameter('', 'lang', $this->params['LANGUAGE']);
        $this->xp->setParameter('', 'user', $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest');
        $this->xp->setParameter('', 'theName', "default");
        $this->xp->setParameter('', 'server', $_SERVER['HTTP_HOST']);
        $this->xp->setParameter('', 'REWRITE', REWRITE_MODE);
        //die($this->xsl->saveXML());
        //die($template);
        //echo " pred-transf ";
        $output = $this->xp->transformToXML($xml);
        //echo ('za-transf ');
        $output = str_replace("&amp;", "&", $output);
        //$this->headers[] = HTTP_HTML;
     	return $output;
    }

    function setHeader(){
        if(!$this->params['DEBUG']){
        	foreach($this->headers as $header) header($header);
        }
    }

    function setHeaders($schema){
        if(!$this->params['DEBUG']){
            //TODO CORS configuration
            header("Access-Control-Allow-Origin: *");
            foreach($this->schemas[$schema]['httpHdr'] as $header) header($header);
        }
    }


    function getCapabilities(){
        $langs = array("cze", "eng", "spa"); //TODO nejak obecneji
        $accept = $this->getParamL('ACCEPTVERSIONS');
        if($accept && !strpos(".".$accept,"2.0.2")){
            $this->exception(3, "ACCEPTVERSIONS", "Only version 2.0.2 is supported now.");
        }
        $lang = $this->getParamL('LANGUAGE');
        if(!$lang || !in_array($lang, $langs)){
            $lang='eng';
        }
        //dump($this->appParameters); exit;
        if(MICKA_LANG == 'cze') $olang = 'eng'; else $olang = 'cze';
        $this->xml->loadXML('<root></root>');
        $this->xsl->load(__DIR__ ."/xsl/getCapabilities.xsl");
        $this->xp->importStyleSheet($this->xsl);
        $params = array(
            'mickaURL' => $this->appParameters['basePath'],
            'cswURL' => $this->appParameters['cswUrl'],
            'LANG' => $lang,
            'MICKA_LANG' => MICKA_LANG,
            'LANG_OTHER' => $olang,
            'org' => $this->appParameters['contact']['org'][$lang],
            'position' => $this->appParameters['contact']['position'][$lang],
            'title' => $this->appParameters['contact']['title'][$lang],
            'abstract' => $this->appParameters['contact']['abstract'][$lang]
        );
        unset($this->appParameters['contact']['org']);
        unset($this->appParameters['contact']['position']);
        unset($this->appParameters['contact']['title']);
        unset($this->appParameters['contact']['abstract']);
        $params = array_merge($params,  $this->appParameters['contact']);
        $this->setXSLParams($params);
        $processed = $this->xp->transformToXML($this->xml);
        return $processed;
    }

    function describeRecord(){
        $this->xml->loadXML("<root/>");
        $this->xsl->load(__DIR__ . "/xsl/describeRecord.xsl");
        $this->xp->importStyleSheet($this->xsl);
        $processed = $this->xp->transformToXML($this->xml);
        //header("Content-type: application/xml");
        //$processed = file_get_contents(PHPPRG_DIR."/../xsl/describeRecord.xml");
        return $processed;
    }

  function getRecords(){
    //echo "getrecords";
    if(!$this->params['TYPENAMES']) $this->exception(2, "TYPENAMES", "Missing 'TYPENAMES' parameter");
    if(!$this->requestType){
      	if($this->params['CONSTRAINT']){
        	if(!$this->params['CONSTRAINT_LANGUAGE']) $this->exception(2, "CONSTRAINT_LANGUAGE", "Missing 'CONSTRAINT_LANGUAGE' parameter");
      	}
      	$qstr = $this->cql2sql($this->params['CONSTRAINT']);
      	$qstr = $qstr[0];
    }
    else $qstr=$this->params['QSTR'];
    $this->logText .= @json_encode($qstr);
    if($this->error){
        return false;
    }
    $typeNames = $this->getParamL('TYPENAMES');

    if($this->params['OUTPUTSCHEMA']){
      	if(!in_array($this->params['OUTPUTSCHEMA'], array_keys($this->schemas))){
        	  $this->exception(3, "OUTPUTSCHEMA", $this->params['OUTPUTSCHEMA']." is not valid value.");
      	}
        //if($this->params['OUTPUTSCHEMA']==$this->schemas['csw']) $typeNames = "csw:record";
        //else if($this->params['OUTPUTSCHEMA']==$this->schemas['gmd']) $typeNames = "gmd:md_metadata";
    }
    else {
        $this->params['OUTPUTSCHEMA'] = "http://www.isotc211.org/2005/gmd";
    }

    //FIXME - dodelat zpracovani
    //if(!$qstr) $this->exception(2, "Constraint", "Empty request.");

    $flatParams = array();
    if(strpos($typeNames,"md_metadata")!==false){
    	$flatParams['MDS'] = 0;
    }
    $flatParams["hits"] = ($this->getParamL('RESULTTYPE')=='hits');
    $flatParams['extHeader'] = ($this->getParamL('EXTLIST')==1);

    // filtering for alternative output
    if($this->subset){
    	if($qstr) $qstr[] = "And";
    	$qstr[] = array($this->subset);
    }
    if($this->params['DEBUG']){
    	var_dump($qstr);
    }

    $format = isset($this->params['FORMAT']) ? $this->params['FORMAT'] : '';
    if(!isset($this->params['STARTPOSITION'])) $this->params['STARTPOSITION']=1;
    $this->params['SORTORDER'] = "ASC";
    if(!isset($this->params['SORTBY'])){
        $this->params['SORTBY']="";
    }
    else {
        $sortby = $this->params['SORTBY'];
        if(strpos($this->params['SORTBY'], ':')){
          $pom = explode(":", $this->params['SORTBY']);
          if($pom[1]=='D') $this->params['SORTORDER'] = "DESC";
          $sortby = $pom[0].",".$this->params['SORTORDER'];
        }
    }
    if(!isset($this->params['MAXRECORDS'])) $this->params['MAXRECORDS']= MAXRECORDS;
    if($this->params['MAXRECORDS']>LIMITMAXRECORDS) $this->params['MAXRECORDS'] = $this->params['MAXRECORDS']= LIMITMAXRECORDS;
    if(!$this->params['STARTPOSITION'] || $this->params['STARTPOSITION']==0) $this->params['STARTPOSITION'] = 1;
    $resultType = $this->getParamL('RESULTTYPE');
    if(!$resultType) $resultType = 'results';
    // TODO nějak uspořadat
    if(strpos($format, 'json')!==false){
        $this->params['OUTPUTSCHEMA'] = 'json';
    }

    switch($resultType){
      case 'hits': $sablona='micka2cat_hits'; break;
      case 'validate': $sablona='micka2cat_hits'; break;
      case 'results':
        /*switch ($this->params['OUTPUTSCHEMA']){
          case $this->schemas['csw']:
              $sablona="micka2cat_dc";
              break;
          case $this->schemas['gmd']:
              $sablona = "out-iso";
              break;
          case $this->schemas['native']: $sablona = "micka2native"; break;
          case $this->schemas['rss']: $sablona="micka2osrss"; $format=""; break;
          case $this->schemas['atom']: $sablona="micka2atom"; $format=""; break;
          case $this->schemas['kml']: $sablona="micka2kml"; $format="kml"; break;
          case $this->schemas['os']: $sablona="micka2os"; $format=""; break;
          case $this->schemas['rdf']: $sablona="micka2rdf"; $format=""; break;
          case $this->schemas['dcat']: $sablona="micka2dcat"; $format=""; break;
          case $this->schemas['oai_dc']: $sablona="micka2oai_dc"; $format=""; break;
          case $this->schemas['oai_marc']: $sablona="micka2oai_marc"; $format=""; break;
          case $this->schemas['marc21']: $sablona="micka2marc21"; $format=""; break;
          default: $this->exception(3, "OUTPUTSCHEMA", $this->params['OUTPUTSCHEMA']); break;
        }*/
          $schema = $this->schemas[$this->params['OUTPUTSCHEMA']];
          $sablona = 'out/' . $schema['template'];
          $typeNames = (isset($schema['typeNames'])) ? $schema['typeNames']: ''; //TODO - jeste udleat, pokud neni outputschema
          break;
      default:
          $this->exception(3, "RESULTTYPE", $this->params['RESULTTYPE']); break;
    }

    //---vyber brief / summary / full
  if($sablona && $resultType=='results' ){
    switch ($this->getParamL('ELEMENTSETNAME')){
      case 'brief': $sablona .= '-brief'; break;
      case 'summary': $sablona .= '-summary'; break;
      case 'full': $sablona .= '-full'; break;
      case 'extended': $sablona .= '-extended'; break;
      default:
      	$sablona .= '-summary';
      	$this->params['ELEMENTSETNAME'] = 'summary';
      break;
    }
    $version = $this->params['VERSION'];
    if($version=="2.0.0") $sablona .= "200";
  }
  $this->params['CATCLIENT_PATH'] = CATCLIENT_PATH;
  $this->params['lang'] = $this->params['LANGUAGE'] ? $this->params['LANGUAGE'] : MICKA_LANG;

  //echo $this->params['FORMAT']; exit;
  if(strpos($format, 'html')!==false){
  		$this->headers[0] = HTTP_HTML;
  		$this->isXML = false;
  		$sablona = 'micka2htmlList_';
  		$isHTML = true;
  }
  else if(strpos($format, 'csv')!==false){
      $this->headers[0] = HTTP_CSV;
      $this->isXML = false;
      $isHTML = true;
  }
  /*else if(strpos($format, 'kml')!==false){
		$this->headers[0] = "Content-Type: application/vnd.google-earth.kml+xml\n";
		$this->headers[1] = "Content-Disposition: filename=micka.kml";
  }*/

  if(isset($this->params['TEMPLATE'])){
  		$sablona = $this->params['TEMPLATE'];
  }


  $this->xsl->load(__DIR__ . "/xsl/$sablona.xsl");
  $this->xp->importStyleSheet($this->xsl);
  $this->params['root'] = "csw:GetRecordsResponse";
  if(!isset($this->params['REQUESTID'])) $this->params['REQUESTID'] = "";
  $this->params['REWRITE'] = REWRITE_MODE;
  $this->params['CONSTRAINT'] = urlencode($this->params['CONSTRAINT']);
  $this->params['USER'] = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';

  $this->setXSLParams($this->params);

  //---- dotaz do Micky po starem pro HTML -----------------------------------
  if(isset($isHTML) || strpos($format, 'csv')!==false){
      //$export = new MdExport(MICKA_USER, $this->params['STARTPOSITION'], $this->params['MAXRECORDS'], $sortby);
      //$xmlstr = $export->getXML($qstr, $flatParams, true, true);
      $export = new \App\Model\MdSearch($this->params['STARTPOSITION'], $this->params['MAXRECORDS'], $sortby);
      $xmlstr = $export->getXmlRecords($qstr, $flatParams);
      $this->xml->loadXML($xmlstr);
      $this->isXML = false;
      if(strpos($format, 'json')!==false){
          $output = $this->asJSON($this->xml, $head, $flatParams['extHeader']);
      }
      else {
          $output =$this->xp->transformToXML($this->xml);
          $output = str_replace("&amp;", "&", $output);
      }
      return $output;
  }


  //---- dotaz do Micky cursor -----------------------------------------------
  // na vstupu index od 1
  //$export = new MdExport(MICKA_USER, $this->params['STARTPOSITION'], $this->params['MAXRECORDS'], $sortby);
  $export = new \App\Model\MdSearch($this->params['STARTPOSITION'], $this->params['MAXRECORDS'], $sortby);
  $count = $export->fetchXMLOpen($qstr, $flatParams);
    if ($count == -1) {
        $this->exception(3, "Filter", "Invalid filter: ".$qstr);
    }
  $returned = min(array($this->params['MAXRECORDS'], $count - $this->params['STARTPOSITION']+1));
  if($returned < 0) $returned = 0;
  $next = $this->params['STARTPOSITION'] + $this->params['MAXRECORDS'];
  if($this->params['OUTPUTSCHEMA']=='json'){
      $next--;
  }
  if($next > $count) $next = 0;

  $result = str_replace(
    array('[id]', '[timestamp]', '[matched]',
        '[returned]','[next]','[elementset]',
        '[authName]', '[authEmail]', '[title]', 
        '[subtitle]', '[path]', '[mickaURL]'),
    array($this->params['REQUESTID'], 
        gmdate("Y-m-d\TH:i:s"), 
        $count, 
        $returned, 
        $next,  
        $this->getParamL('ELEMENTSETNAME'),
        $this->appParameters['contact']['org'][$this->params['LANGUAGE']], 
        $this->appParameters['contact']['email'], 
        $this->appParameters['contact']['title'][$this->params['LANGUAGE']], 
        $this->appParameters['contact']['abstract'][$this->params['LANGUAGE']], 
        $this->appParameters['contact']['www'],
        $this->mickaURL),
    $schema['header']
  );
  if(!$this->params['buffered']) {
      $this->setHeaders($this->params['OUTPUTSCHEMA']);
      if($this->params['OUTPUTSCHEMA']!='json')echo XML_HEADER;
      echo $result;
  }
  if($count) {
      $i = 0;
      while (($xml = $export->fetchXML()) != FALSE) {
          $this->xml->loadXML($xml);
          $output = $this->xp->transformToXML($this->xml);
          //echo($output); die();

          if($this->params['OUTPUTSCHEMA']=='json'){
              eval($output);
              $output = json_encode($rec);
              if($i>0) $output = ",".$output;
          }
          if($this->params['buffered']) $result .= $output;
          else {
              echo $output;
              ob_flush();
              flush();
          }
          $i++;
      }
      $export->fetchXMLClose();
  }

  if($this->params['buffered']){
      return $result . $schema['footer'];
  }
  else {
      echo $schema['footer']; die;
  }
  //--------------------------------------------------------------------------
  //die('konce');
  if($xml==-1) $this->exception(3, "Filter", "Invalid filter: ".$qstr);

  //---cekani na vzdalene servery - zatim vyrazeno
  /*if(isset($this->params['HOPCOUNT']) && $this->params['HOPCOUNT']>0){
    file_put_contents(CSW_TMP."/$cascadeID-local.xml" ,$xmlstr);
    $status = false;
    $timestop = time()+CSW_TIMEOUT; // za jak dlouho to ma chcipnout
    if(!class_exists('CswClient')){
    	include(PHPPRG_DIR.'/CswClient.php');
    }
	$client = new CswClient();
    while(!$status){
      $status = true;
      reset($cswlist);
      while(list($name, $csw) = each ($cswlist)){
      	// TODO - tady dodelat
        $result = CSW_TMP."/$cascadeID-$name.xml";
        if(!file_exists($result)) $status = false;
        if($timestop<time()) $status = true; // aby to neviselo
      }
      sleep(1);
    }
    $this->xml->load(PHPINC_DIR.'/csw/cservers.xml');
    $this->xsl->load(PHPINC_DIR."/../xsl/cascade.xsl");
    $this->xp->importStyleSheet($this->xsl);
    $this->xp->setParameter('', 'cascadeId', CSW_TMP."/".$cascadeID);

    if($status>0){
      while(list($key, $val) = each ($_SESSION["cswlist"])){
        @unlink(CSW_TMP."/$id-$key.htm");
      }
    }
  }*/
  //---prevod XML do katalogu
  /*  else{
      	$this->xml->loadXML($xmlstr);
     	$this->xsl->load(PHPPRG_DIR."/../xsl/$sablona.xsl");
      	$this->xp->importStyleSheet($this->xsl);
    }    */


    // --- JSON ---
    if(strpos($format, 'json')!==false){
        $processed = $this->xp->transformToDoc($this->xml);
        $output = $this->asJSON($processed, $head, $flatParams['extHeader']);
        $this->isXML = false;
    }
    // --- HTML ---
    else if(strpos($format, 'html')!==false){
        $output =$this->xp->transformToXML($this->xml);
        //$output = htmlspecialchars_decode($output);
        $output = str_replace("&amp;", "&", $output);
    }
    // --- XML ---
    else {
        $output =$this->xp->transformToXML($this->xml);
    }

    //return $output;
  }


  function getRecordById(){
        $qstr = "";
        if(!$this->params['ID']) $this->exception(2, "ID", "");
        $ids = explode(",", $this->params['ID']);
        foreach($ids as $id) if($id){
        	if($qstr) $qstr .= ",";
        	$qstr .= "'".urldecode($id)."'";
        }
        if($this->params['DEBUG']==1) var_dump($qstr);

        //---- dotaz do Micky ------------------------------------------------------
    	//$export = new MdExport($_SESSION['u'], 0, 25, $this->params['SORTBY']);
    	//echo "<hr>".$qstr."<hr>";
   		//$xmlstr = $export->getXML(array(), array("ID" =>"($qstr)"), true, true);
        $export = new \App\Model\MdSearch(0, 25, $this->params['SORTBY']);
   		$xmlstr = $export->getXmlRecords(array(), array("ID" =>"($qstr)"));
        //--------------------------------------------------------------------------
        if($xmlstr==-1) $this->exception(3, "Filter", "Invalid filter: ".$xmlstr);
        //die($this->params['FORMAT']);
        $sablona = "micka2cat_19139";
        if(isset($this->params['OUTPUTSCHEMA']) && $this->params['OUTPUTSCHEMA']){
            if(!in_array($this->params['OUTPUTSCHEMA'], array_keys($this->schemas))){
                $this->exception(3, "OUTPUTSCHEMA", $this->params['OUTPUTSCHEMA']." is not valid value.");
            }
            switch ($this->params['OUTPUTSCHEMA']){
                case "http://www.isotc211.org/2005/gmd":
                    $sablona = "micka2cat_19139";
                    break;
                case "http://www.w3.org/2005/Atom":
                    $sablona = "micka2atom";
                    break;
                case "http://www.w3.org/ns/dcat":
                case "http://www.w3.org/ns/dcat#":
                    $sablona = "micka2dcat";
                    break;
                default:
                    $sablona = "micka2cat_dc";
                    break;
            }
        }
        if(isset($this->params['FORMAT']) && strpos($this->params['FORMAT'],'json')!==false){
            $sablona = "out/json";
        }
        switch ($this->getParamL('ELEMENTSETNAME')){ //TODO - nefunguje v sablone
          case 'brief':
              $sablona .= '-brief'; break;
          case 'summary':
              $sablona .= '-summary'; break;
          case 'full':
          default:
          	$sablona .= '-full'; // podle standardu summary
          	$this->params['ELEMENTSETNAME'] = "full";
          	break;
        }

        $this->logText .= "[ID=".$qstr."]";

        //TODO - kaskadovani
        //---prevod XML do katalogu
        $this->xml->loadXML($xmlstr);
        $this->xsl->load(__DIR__ . "/xsl/$sablona.xsl");
        $this->xp->importStyleSheet($this->xsl);

        //$this->params['requestId'] = $this->params['REQUESTID'];
        $this->params['root'] = "csw:GetRecordByIdResponse";
        $this->params['elementSet'] = $this->getParamL('ELEMENTSETNAME');
        $this->params['user'] = $this->user->isLoggedIn() ? $this->user->getIdentity()->username : 'guest';
        $this->params['USER'] = $this->params['user']; //FIXME
        $this->params['REWRITE'] = REWRITE_MODE;
        $this->params['THEME'] = MICKA_THEME;
        $this->params['lang'] = $this->getParamL('LANGUAGE');
        if(!isset($this->params['MAXRECORDS'])) $this->params['MAXRECORDS']= MAXRECORDS;
        if(!isset($this->params['SORTORDER'])) $this->params['SORTORDER']= "ASC";
        $this->setXSLParams($this->params);

        // --- HTML ---
        if(isset($this->params['FORMAT']) && $this->params['FORMAT']=='text/html'){
            if(isset($this->params['TEMPLATE']) && $this->params['TEMPLATE']) $sablona = $this->params['TEMPLATE'];
            else $sablona = "iso2htmlFull_";
            $output = $this->asHTML($this->xml, $sablona);
            $this->isXML = false;
        }
        else if(isset($this->params['FORMAT']) && strpos($this->params['FORMAT'],'json')!==false){
            $output = $this->xp->transformToXML($this->xml);
            //die($output);
            eval($output);
            $output = json_encode($rec);
            $this->isXML = false;
        }
        // --- XML ---
        else {
            $output = $this->xp->transformToXML($this->xml);
        }
        return $output;
    }

    
    // returns title from last XML
    function getTitle(){
        $this->xsl->load(__DIR__ . "/xsl/out/json-brief.xsl");
        $this->xp->importStyleSheet($this->xsl);
        $output = $this->xp->transformToXML($this->xml);
        eval($output);
        return isset($rec['title']) ? $rec['title'] : '';
    }
    
    
  function harvest($io = true){
    //var_dump($this->params);
    include(PHPPRG_DIR.'/Harvest.php');
    include(PHPPRG_DIR.'/CswClient.php');
    $cswFrom = new CSWClient();
    $harvestor = new Harvest($this, $cswFrom);
    // jen vrati hodnoty - nad ramec standardu
    if($io == false){
        $result = $harvestor->getParameters($this->params['ID']);
        header("Content-type: application/json");
        echo json_encode($result);
        exit;
    }
    // implicitni hodnota
    if(!$this->params['RESOURCETYPE']){
        $this->params['RESOURCETYPE'] = "csw/2.0.2";
    }
    //--- save to database ---
    if($this->params['HANDLERS']){
      if(!$this->params['ID']) $this->params['ID'] = $this->params['SOURCE'];
      if($this->params['HARVESTINTERVAL']!=''){
	      $result = $harvestor->setParameters(
	      	$this->params['ID'],
	      	$this->params['SOURCE'],
	      	$this->params['RESOURCETYPE'],
	      	$this->params['HANDLERS'],
	      	$this->params['HARVESTINTERVAL'],
	      	"" // TODO tam muze byt filter
	      );
      }
	  else{
	  	//TODO poslat hned uzivateli
       	$result = $harvestor->runResource(array(
       	  	'source'=>$this->params['SOURCE'],
       	  	'name'=>'instant',
       		'type'=>$this->params['RESOURCETYPE']
       	));
        $result =  $this->updateResponse($result, "Update");
        $h = explode("|", $this->params['HANDLERS']);
	    file_put_contents($h[0],$result); //FIXME - toto je docasne
	  }
	  $this->logText .= "HARVEST";
	  // XML verze
	  if(count($_GET)==0){ // quick and dirty
      	$this->xsl->load(__DIR__ . "/xsl/HarvestResponse.xsl");
      	$this->xp->importStyleSheet($this->xsl);
      	$this->xp->setParameter('', 'timestamp', gmdate("Y-m-d\TH:i:s")); // svetovy cas
      	$processed = $this->xp->transformToXML($this->xml);
	  }
	  // navic - JSON
	  else {
	    header("Content-type: application/json");
	  	echo json_encode($result);
	  	exit;
	  }
      return $processed;
    }

    //--- runs immediately ---
    else{
       $result = $harvestor->runResource(array(
       	  	'source'=>$this->params['SOURCE'],
       	  	'name'=>'blee',
       		'type'=>$this->params['RESOURCETYPE']
       ));
       return $this->updateResponse($result, "Update");
	}
  }

  	private function setXSLParams($params){
    	$this->xp->setParameter('', $params);
    }

  private function setRssParams($dni){
    if(!$this->params['LANGUAGE']) $this->params['LANGUAGE'] = 'cze';
    $this->xp->setParameter('', 'lang', $this->params['LANGUAGE']);
    $this->xp->setParameter('', 'days', $dni);
    //$this->xp->setParameter('', 'url', "http://".$_SERVER['SERVER_NAME'].dirname($_SERVER['SCRIPT_NAME']));
  }


  function saveLog(){
    if(!$this->logFile) return;
    $logfile = fopen($this->logFile.gmdate("-Y-m"), "a");
    fwrite($logfile, $this->logText."\n");
    fclose($logfile);
  }

  function updateResponse($result, $action){
  	$success = "";
  	$numSuccess = 0;
  	$errIds = array();
  	$errReport = "";
  	if($result['error']) $this->exception($result['error'][0], $result['error'][1], $result['error'][2]);
  	foreach($result as $record){
 	  if($record['ok']){
 	  	$numSuccess++;
  		$success .= "<csw:BriefRecord><dc:identifier>$record[uuid]</dc:identifier><dc:title>$record[title]</dc:title></csw:BriefRecord>";
 	  }
  	  else{
  		$errIds[] = $record['uuid'];
  		$errReport .= $record['report']."\n\n";
      }
  	}
  	if($numSuccess==0){
  	  $this->exception(6, "records IDs: ".implode(",", $errIds), $errReport);
  	}
  	if($action=='Insert') $action = "Inserte";
   $s ='<csw:TransactionResponse
   xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:gml="http://www.opengis.net/gml"
   xmlns:ogc="http://www.opengis.net/ogc"
   xmlns:ows="http://www.opengis.net/ows"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
   <csw:TransactionSummary>
  		<csw:total'.$action.'d>'.$numSuccess.'</csw:total'.$action.'d>
   </csw:TransactionSummary>';
   if($action!='Delete'){
   		$s .= '<csw:InsertResult>'.$success.'</csw:InsertResult>';
   }
   return $s.'</csw:TransactionResponse>';
  }

  /**
   * Performs Trasaction (save/update data in underlying database)
   *
   */
  function transaction(){
    if(!$this->user->isInRole('editor')) $this->exception(1, "Transaction", "You don't have permission to transaction.");
    $this->logText .= $this->params['REQTYPE'];
    switch(strtolower($this->params['REQTYPE'])){
      case "delete":
          return $this->updateResponse($this->delete(), "Delete");
          break;
      case "update":
          return $this->updateResponse(
              $this->update('',
                  $this->params['GROUP_EDIT'],
                  $this->params['GROUP_READ'],
                  $this->params['IS_PUBLIC'],
                  false, 'all'),
              "Update");
          break;
      case "insert":
          return $this->updateResponse(
              $this->update('',
                  $this->params['GROUP_EDIT'],
                  $this->params['GROUP_READ'],
                  $this->params['IS_PUBLIC'],
                  false, 'insert'),
              "Insert");
          break;
      default:
          $this->exception(3, $this->params['REQTYPE'], "Not supported transaction type.");
          break;
    }
    return false;
  }

  /**
   * Inserts or updates record in the underlying database
   *
   * @param string $nodeName Identifier of server which data comes from (used for harvesting)
   * @param string $viewGroup Name of the group for viewing (used for CENIA filters)
   * @param boolean $stopOnError If set true, insert no record if error occurs. Otherwise attempts to insert at least valid elements.
   * @return array Associative array with update results (both successful and failed records)
   */
  function update($nodeName='', $editGroup='', $viewGroup='', $public=0, $stopOnError=true, $overwrite='all') {
    $recordModel = new \App\Model\RecordModel($this->dbContext, $this->user);
    $recordModel->setAppParameters($this->appParameters);
    /*
    $importer = new MetadataImport($this->params['DEBUG']);
    $md = $importer->xml2array($this->xml, __DIR__ ."/xsl/update2micka.xsl");
    if($this->params['DEBUG']==2) var_dump($md);
    $c = new MdImport();
    $c->setDataType($public); // nastavení veřejného záznamu
    if($editGroup){
        $c->group_e = $editGroup;
    }
    if($viewGroup){
        $c->group_v = $viewGroup;
    }
    $c->stop_error = $stopOnError; // pokud dojde k chybě při importu pokračuje
    $c->server_name = $nodeName; // jméno serveru ze kterého se importuje
    $c->setReportValidType('array', true); // formát validace
    $result = $c->dataToMd($md, $overwrite);
     */
    $params = array();
    $params['data_type'] = $public;  // nastavení veřejného záznamu
    if($editGroup){
        $params['edit_group'] = $editGroup;
    }
    if($viewGroup){
        $params['view_group'] = $viewGroup;
    }
    $params['stop_error'] = $stopOnError; // pokud dojde k chybě při importu pokračuje
    $params['server_name'] = $nodeName; // jméno serveru ze kterého se importuje
    $params['valid_type'] = array('type' => 'array', 'short' => TRUE); // formát validace
    $params['update_type'] = $overwrite;
    $result = $recordModel->setXmlFromCsw($this->xml, $params);
    if($this->params['DEBUG']==1) var_dump($result);
    return $result;
  }

  private function delete(){
  	$export = new MdExport($usr);
  	$data = $export->getData(array($this->params['QSTR'])); //TODO zaznamy apod ...
    $c = new MdImport();
    $result = $c->dataToMd($data,'delete');
    if($this->params['DEBUG']==1) var_dump($result);
    return $result;
  }

  //--- vypujceno z importMetadata class - uz nekompatibilni !!!
  function writeNode($path, $node, $idx){
  	$s = "";
  	//atributy
    if(($node->nodeType!=XML_TEXT_NODE)&&($node->hasAttribute('codeListValue'))&&(trim($node->getAttribute('codeListValue'))!="")){
    	$s = $path."['".$node->nodeName."'][0]['@']='".addslashes(trim($node->getAttribute('codeListValue')))."';\n";
    }
  	else if($node->hasChildNodes()){
      $nodes = $node->childNodes;
      $lastNode = '';
      $lastLangs = Array();
      $j = 0;
      for($i=0;$i<$nodes->length;$i++){
        if($nodes->item($i)->nodeName!="#text"){
          $lang = '';
          if($nodes->item($i)->hasAttribute('lang')) $lang = $nodes->item($i)->getAttribute('lang');
          if($nodes->item($i)->nodeName==$lastNode){
            // pro nativni data ++ opicarny kvuli keywords
    	    if($lang){
    	      if(in_array($lang, $lastLangs)){
 			  	$j++;
   			  	$lastLangs = Array();
    	      }
   			}
      	  	else $j++;
      	  }
      	  else $j=0;
      	  if($lang) $lastLangs[] = $lang;
      	  $lastNode=$nodes->item($i)->nodeName;
      	}
      	if(!$path) $s .= $this->writeNode( "\$md", $nodes->item($i), $j);
        else $s .= $this->writeNode( $path."['".$node->nodeName."'][$idx]", $nodes->item($i), $j);
      }
    }
    // konec vetve - text
    else if(trim($node->nodeValue)!=""){
   	  if($node->parentNode->hasAttribute('lang')){
   		$lang = $node->parentNode->getAttribute('lang');
   		$path .= "['@".$lang."']";
   	  }
      else if($node->parentNode->hasAttribute('locale'))
       	$path .= "['@".substr($node->parentNode->getAttribute('locale'),7)."']"; //FIXME - preklad do kodu jazyka
      else $path .= "['@']";
      $s = $path."='".addslashes(trim($node->nodeValue))."';\n";
    }
    return $s;
  }


    /*
    * Tokenization of CQL - recursive
    *
    * @param $cql - query string
    * @return     - micka query array part
    */

    private function parseCQL($cql){
        $result = array();
        $aon = array("AND", "OR", "NOT");
        //preg_match_all("/\((?:[^()]|(?R))+\)|'([\\][']|[^'])*'|[^(),\s']+/", $cql, $t, PREG_PATTERN_ORDER);
        preg_match_all("/\([^)]+\)|'(?:\\\\'|[^'])*'|\S+/", $cql, $t, PREG_PATTERN_ORDER);
        $tokens = $t[0];
        $i = 0;
        foreach($tokens as $t){
            // sub
            if($t[0]=="("){
                $i++;
                $result[$i] = $this->parseCQL(substr($t,1, strlen($t)-2));
                $i++;
            }
            // operator AND/OR/NOT
            else if(in_array(strtoupper($t), $aon)){
                $i++;
                $result[$i] = strtoupper($t);
                $i++;
            }
            //
            else {
                if(isset($result[$i])){
                    // operator
                    if($first){
                        $result[$i] .=  " ". $t;
                        $first = false;
                    }
                    //value
                    else {
                        if($t[0]!="'") $t = "'".$t."'";
                        $result[$i] .=  " ". str_replace($this->w_in, $this->w_out, $t);
                        $result[$i] = array_key_exists($result[$i], $this->exceptions) ? $this->exceptions[$result[$i]] : $result[$i];
                    }
                }
                // queryable name
                else {
                    $result[$i] = $this->map[strtolower($t)];
                    if(!$result[$i]){
                        //die("ERROR!! $t queryable is not available!");  //TODO throw exception
                        $this->error = array(4,$t, "queryable is not available");
                        $result[$i] = $t;
                    }
                    $first=true;
                }
            }
        }
        return $result;
    }

    /*
    * Conversion from CQL inner MICKA query
    *
    * @param $cql - query string
    * @return     - micka query array
    */
    function cql2sql($cql){
        //spaces around operators
        $cql = preg_replace('/[!=><][=><]*/', ' ${0} ', $cql);
        $cql = str_replace(array('csw:', 'gmd:', '"'), '', $cql);

        //mapping to inner queryables
        $this->map = array('anytext'=>'%', 'fulltext'=>'_FULL_',
        	'modified'=>'_DATESTAMP_', 'language'=>'_LANGUAGE_', 'tempextent_begin'=>'_DATEB_',
            'tempextent_end'=>'_DATEE_', 'hierarchylevelname'=>'@hlname', "type='featureCatalogue'"=>'_MDS_=2',
          	'type'=>'@type', 'hierarchylevel'=>'@type', 'servicetype'=>'@stype', 'identifier'=>'_UUID_',
            'topiccategory'=>'@topic', 'title'=>'@title', 'abstract'=>'@abstract',
          	'revisiondate'=>'@date', 'creator'=>'_CREATE_USER_', 'mayedit'=>'_MAYEDIT_', 'groups'=>'_GROUPS_',
            'organisationname'=>'@contact', 'subject'=>'@keyword',
        	'degree'=>'@sp.degree', 'specificationtitle'=>"@sp.title", 'server'=>"_SERVER_",
            'resourcelanguage'=>'@rlanguage', "uuidref"=>'@uuidref', "operateson"=>"@operateson",
            "parentidentifier"=>"@parent", "forinspire"=>"_FORINSPIRE_",
            "resourceidentifier"=>"@resourceid",
        	"ispublic"=>"_DATA_TYPE_", "mdcreator"=>"_CREATE_USER_", "denominator"=>"@denom",
            "mdindividualname"=>"@mdinnaco", "individualname"=>"@innaco",
        	"fcidentifier"=>"@fcid", "otherconstraints"=>"@otherc", "conditionapplyingtoaccessanduse"=>"@ausec",
            "fees"=>"@fees", "protocol"=>"@protocol",
        	"bbox"=>"_BBOX_", "boundingbox"=>"_BBOX_",
            "thesaurusname"=>"@thesaurus", "bbspan"=>"_BBSPAN_", "linkname"=>"@lname",
            "responsiblepartyrole"=>"@role", "linkage"=>"@linkage", "metadatarole"=>"@mdrole",
            "metadatacontact"=>"@md_contact", "contactcountry"=>"@country",
            "metadatacountry"=>"@mdcountry", "format"=>"@format",
            "geographicdescriptioncode"=>"@geocode"
        );

        // wildcards
        $this->w_in = array("*", "\'");
        $this->w_out = array("%", "''");

        // fultext in ORACLE XML
        if(DB_DRIVER == 'oracle' && DB_FULLTEXT == 'ORACLE-CONTEXT'){
            $this->map['title'] = "//gmd:identificationInfo/*/gmd:citation/*/gmd:title";
            $this->map['abstract'] = "//gmd:identificationInfo/*/gmd:abstract";
        }

        //feature catalogue // TODO remove special queries
        $this->exceptions = array("@type = 'featureCatalogue'" => '_MDS_ = 2');

        $result = $this->parseCQL($cql);
        //echo "<pre>"; var_dump($result); die;

        return array($result);
    }


} // class
