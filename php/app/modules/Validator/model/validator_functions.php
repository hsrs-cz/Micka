<?php

function isEmail($email)
{
    //return filter_var($email, FILTER_VALIDATE_EMAIL);
    if (preg_match('~^[-a-z0-9!#$%&\'*+/=?^_`{|}\~]+(\.[-a-z0-9!#$%&\'*+/=?^_`{|}\~]+)*@([a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\.)+[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])$~i', $email)) {
        return "1";
    }
    else {
        return "";
    }
}

function getContents($url, $len=1000)
{
    $url = explode("#",$url);
    $c = curl_init(trim($url[0]));
    curl_setopt($c, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($c, CURLOPT_SSL_VERIFYPEER, 0);
    curl_setopt($c, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($c, CURLOPT_MAXREDIRS, 20);
    curl_setopt($c, CURLOPT_CONNECTTIMEOUT, 2);
    curl_setopt($c, CURLOPT_TIMEOUT, 3);
    curl_setopt($c, CURLOPT_RANGE, "0-".$len);
        if(defined('CONNECTION_PROXY')){
        $proxy = CONNECTION_PROXY;
        if(defined('CONNECTION_PORT')) $proxy .= ':'. CONNECTION_PORT;
        curl_setopt($c, CURLOPT_PROXY, $proxy);	
    }
    $result = curl_exec($c);    
    //file_put_contents(__DIR__ . "/../../include/logs/".preg_replace(array('/\s/', '/\.[\.]+/', '/[^\w_\.]/'), array('_', '.', '-'), $url).".xml", $result);
    return $result;
}

function isRunning($url, $type, $d=false)
{
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

function testConnection($url)
{
    $scheme = parse_url($url, PHP_URL_SCHEME);
    if($scheme != 'http' &&  $scheme != 'https') return "";
    $t = microtime(true);
    $s = trim(getContents($url));
    $t = microtime(true) - $t;
    //file_put_contents('/var/www/projects/tmp/'.time().'.xml',$s);
    if(!$s) return "";
    $result = '?';
    if(strpos($s, 'http://www.opengis.net/wms')!==false) $result = 'WMS-1.3.0';
    else if(strpos($s, 'http://www.opengis.net/wmts/1.0')!==false) $result = 'WMTS-1.1.0';
    else if(strpos($s, 'WMT_MS_Capabilities')!==false) $result = 'WMS-1.1.0';
    else if(strpos($s, 'http://www.opengis.net/wfs/2.0')!==false) $result = 'WFS-2.0.0';
    else if(strpos($s, 'WFS_Capabilities')!==false) $result = 'WFS-1.0.0';
    else if(strpos($s, 'feed')!==false && strpos($s, "http://inspire.ec.europa.eu/schemas/inspire_dls/1.0")!==false) $result = 'download-ATOM';
    else if(strpos($s, "SourceCRS>")!==false) $result = 'transformation - WCTS';
    else if(strpos($s, '"http://www.opengis.net/cat/csw/2.0.2"')!==false) $result = 'CSW-2.0.2';
    else if(strpos($s, "MD_Metadata>")!==false) $result = 'ISO 19139 metadata';
    else if(strpos($s, "<html")!==false) $result = 'HTML';
    //else $result=$s;
    return $result."| ".sprintf("%.3f",$t);
}

function json2array($json)
{
    $json = substr($json, strpos($json,'{')+1, strlen($json)); 
    $json = substr($json, 0, strrpos($json,'}')); 
    $json = preg_replace('/(^|,)([\\s\\t]*)([^:]*) (([\\s\\t]*)):(([\\s\\t]*))/s', '$1"$3"$4:', trim($json)); 
    return $json;
    return json_decode('{'.$json.'}', true); 
}  

function isGemet($keyword, $lang)
{
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
}

