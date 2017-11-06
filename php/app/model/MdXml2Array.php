<?php
namespace App\Model;

class MdXml2Array
{
    private $appParameters;

	var $xml = null;
	var $kwList = array();
    var $engKw = array();
	var $debug = false;
	private $table_mode = 'md'; // if md or tmp will be used
	var $langCodes = Array(
	        "bul" => "bg",
	        "cze" => "cs",
	        "dan" => "da",
	        "ger" => "de",
	        "est" => "et",
	        "gre" => "el",
	        "eng" => "en",
	        "spa" => "es",
	        "fre" => "fr",
	        "hrv" => "hr",
	        "ita" => "it",
	        "lav" => "lv",
	        "lit" => "lt",
	        "hun" => "hu",
	        "mlt" => "mt",
	        "dut" => "nl",
	        "pol" => "pl",
	        "por" => "pt",
	        "rum" => "ro",
	        "slo" => "sk",
	        "slv" => "sl",
	        "fin" => "fi",
	        "swe" => "sv"	        
	);


    public function startup()
    {
        parent::startup();
        
        define("BACKURL", "<p> <a href=\"javascript:history.back();\">&lt;&lt; back</a> </p>");
        $this->debug = FALSE;
    }
    
    public function setAppParameters($appParameters)
    {
        $this->appParameters = $appParameters;
    }

	/**
	 * Uložení do dat nebo do tmp tabulky
	 *
	 * @param string $mode 'md'|'tmp'
	 */
	public function setTableMode($mode) {
		$this->table_mode = $mode == 'md' ? 'md' : 'tmp';
	}

  private function extractImage($xml, $imgFileName){
    $thumb = $xml->getElementsByTagName('Thumbnail');
    $obr = $thumb->item(0);
    if(!$obr) return false;
    $png = $obr->getElementsByTagName('Data')->item(0)->nodeValue;
    file_put_contents($imgFileName, base64_decode($png));
    return true;
  }

  private function recurse($array, $array1){
      foreach ($array1 as $key => $value){
        // create new key in $array, if it is empty or not an array
        if (!isset($array[$key]) || (isset($array[$key]) && !is_array($array[$key]))){
          $array[$key] = array();
        }

        // overwrite the value in the base array
        if (is_array($value)){
          $value = $this->recurse($array[$key], $value);
        }
        $array[$key] = $value;
      }
      return $array;
  }
  
  private function array_replace_recursive($array, $array1){
    // handle the arguments, merge one by one
    $args = func_get_args();
    $array = $args[0];
    if (!is_array($array)){
      return $array;
    }
    for ($i = 1; $i < count($args); $i++){
      if (is_array($args[$i])){
        $array = $this->recurse($array, $args[$i]);
      }
    }
    return $array;
  }
  
  private function writeNode($path, $node, $idx){
  	$s = "";
  	$locales = Array(
  	  "#locale-en" => "eng",
  	  "#locale-fr" => "fre",
  	  "#locale-de" => "ger",
  	  "#locale-it" => "ita",
  	  "#locale-lv" => "lav",
  	  "#locale-eng" => "eng",
  	  "#locale-cze" => "cze"
  	);
  	if($this->langCodes) $locales = $this->langCodes;
  	//atributy
    if(($node->nodeType==XML_ELEMENT_NODE)&&($node->hasAttribute('xlink:href'))){
  	  	$s .= $path."['".$node->nodeName."'][$idx]['href'][0]['@']='".$node->getAttribute('xlink:href')."';\n";
  	}
    if(($node->nodeType==XML_ELEMENT_NODE)&&($node->hasAttribute('xlink:title'))){
  	  	$s .= $path."['".$node->nodeName."'][$idx]['title'][0]['@']='".$node->getAttribute('xlink:title')."';\n";
  	}
  	if(($node->nodeType==XML_ELEMENT_NODE)&&($node->hasAttribute('uuidref'))){
  	  	$s .= $path."['".$node->nodeName."'][$idx]['uuidref'][0]['@']='".$node->getAttribute('uuidref')."';\n";    
    }
    if(($node->nodeType==XML_ELEMENT_NODE)&&($node->hasAttribute('src'))){
  	  	$s .= $path."['".$node->nodeName."'][$idx]['@']='".$node->getAttribute('src')."';\n";
  	}
  	
    // omezení na FC
    if($node->nodeType==XML_ELEMENT_NODE && $node->hasAttribute('id') && $node->nodeName=='featureCatalogue'){
    	$s .= $path."['".$node->nodeName."'][$idx]['id'][0]['@']='".trim($node->getAttribute('id'))."';\n";
    }
    
    if($node->nodeType!=XML_TEXT_NODE && $node->nodeType!=XML_COMMENT_NODE){
        //atributy TODO - zobecnit
        if($node->hasAttribute('uom')){
            $s .= $path."['".$node->nodeName."'][$idx]['uom'][0]['@']='".$node->getAttribute('uom')."';\n";
        }
        if($node->hasAttribute('xlink:href')){
            $s .= $path."['".$node->nodeName."'][$idx]['href'][0]['@']='".$node->getAttribute('xlink:href')."';\n";
        }
        if($node->hasAttribute('uuidref')){
            $s .= $path."['".$node->nodeName."'][$idx]['uuidref'][0]['@']='".$node->getAttribute('uuidref')."';\n";
        }
    }
    
    // existuje-li codeListValue, uz se dal nevyhodnocuje
    if(($node->nodeType==XML_ELEMENT_NODE)&&($node->hasAttribute('codeListValue'))){
    	$s .= $path."['".$node->nodeName."'][0]['@']='".addslashes(trim($node->getAttribute('codeListValue')))."'; \n";
    } 
    // locales - taky nejde dal
  	else if(strpos($node->nodeName, 'textGroup')!==false){
  		foreach($node->childNodes as $ch){  
	  		if($ch->nodeType == XML_ELEMENT_NODE && $ch->hasAttribute('locale')){
	  			$locale = $ch->getAttribute('locale');
	  			$path .= "['@".$locales[$locale]."']";
				  $s = $path."='".addslashes(trim($ch->nodeValue))."';\n";
	  			break;
	  		}
  		}	
  	}
    else if($node->hasChildNodes()){
  	  $nodes = $node->childNodes;
      $lastNode= "";
      $j = 0;
      for($i=0;$i<$nodes->length;$i++){
        if($nodes->item($i)->nodeType==XML_ELEMENT_NODE){
      	  if($nodes->item($i)->nodeName==$lastNode)$j++;
      	  else $j=0;
      	  $lastNode=$nodes->item($i)->nodeName;
      	}  
      	if(!$path) $s .= $this->writeNode("\$md", $nodes->item($i), $j);
        else $s .= $this->writeNode($path."['".$node->nodeName."'][$idx]", $nodes->item($i), $j);
      }
    } 
    // konec vetve - prazdny element - odmazava z databaze tam kde byly prazdne hodnoty
    else if($node->nodeType!=XML_TEXT_NODE && $node->nodeType!=XML_COMMENT_NODE){
        $s .= $path."['".$node->nodeName."'][$idx]"."['@']='';\n";
    }
    // konec vetve - text
    else if($node->nodeType==XML_TEXT_NODE && ($node->nodeValue==" " || trim($node->nodeValue))){
      if($node->parentNode->hasAttribute('locale')){ 
        $locale = $node->parentNode->getAttribute('locale');  
      	if(strpos("#", $locale) !== false){  
            $path .= "['@".$locales[$locale]."']";
		}
		// hack kvuli nemcum
		else if(in_array($locale, array_keys($this->langCodes))){
		    $path .= "['@".$locale."']";
		}		 
    }
    // pro native
    else if($node->parentNode->hasAttribute('lang')){
        $path .= "['@".$node->parentNode->getAttribute('lang')."']";
    }  
    else $path .= "['@']";  
        $s = $path."='".addslashes(trim($node->nodeValue))."';\n";
    }
    // prazdne XML elementy
    return $s;
  }
  
  function xml2array($xml, $template, $params=array()){
    if($template){  
        $xp  = new \XsltProcessor();
        $xsl = new \DomDocument;
        $xsl->load($template);
        $xp->importStyleSheet($xsl);
        foreach($params as $key=>$val){
            $xp->setParameter("", $key, $val);
        }
        $dom = $xp->transformToDoc($xml);
    }    
    else {
        $dom = $xml;
    }
        //--- ladeni ---
        //header('Content-type: application/xml'); echo $dom->saveXML(); exit;
        // ---
  	$this->xml = $xml;
  	//--- vyreseni locales ---
  	$locales = $this->xml->getElementsByTagNameNS("http://www.isotc211.org/2005/gmd", "PT_Locale");

  	foreach($locales as $locale){
  		if($locale->hasAttributes()){
  			$langCode = $locale->getElementsByTagNameNS("http://www.isotc211.org/2005/gmd", "LanguageCode");
  			$this->langCodes['#'.$locale->getAttribute('id')] = $langCode->item(0)->getAttribute('codeListValue');
  			$this->langCodes[$locale->getAttribute('id')] = $langCode->item(0)->getAttribute('codeListValue'); // DOCASNE kvuli ruznym chybam ve starych XML
  		}	
  	}
  	$this->langCodes['#locale-uri'] = 'uri';
  	if($dom->documentElement){
  	    $data = $this->writeNode("", $dom->documentElement, 0);
  	}   
    if(substr($data,0,3)!='$md') return array(); // pokud jsou prazdne
    // DEBUG
    //echo "<pre>$data</pre>"; exit;  
    $data = str_replace(
      array("['language'][0]['gco:CharacterString']", "['MD_Identifier']", "ns1:" ) , 
      array("['language'][0]['LanguageCode']", "['RS_Identifier']", "gco:" ), 
      $data); //kvuli portalu INSPIRE

    // quick and dirty patch for distance
    $data = str_replace(
       Array("['gco:Distance'][0]['uom']", "['gco:Distance']"),
       Array("['uom'][0]['uomName']", "['value']"), 
       $data
    );
    // DEBUG
    //echo "<pre>$data</pre>"; exit;  
      
    $data = str_replace(array("gmd:","gmi:", "gem:"), "", $data); //FIXME udelat pres sablony
    //$data = str_replace("csw:", "", $data); //FIXME udelat pres sablony
    $data = str_replace("'false'", "0", $data);
    $data = str_replace("['language'][0]['gco:CharacterString']" , "['language'][0]['LanguageCode']", $data); //kvuli portalu INSPIRE
    $elim = Array("'gco:CharacterString'", "'gco:Date'", "'gco:DateTime'", "'gco:Decimal'", "'gco:Integer'", "'gco:Boolean'",    
     "'gco:LocalName'", "'URL'", "'gco:Real'", "'gco:Record'", "'gco:RecordType'", "'LocalisedCharacterString'", "gml:", "srv:",  "gco:", //"'gmx:Anchor'",
    "['PT_FreeText'][0]", "[][0]", "'DCPList'", "['gts:TM_PeriodDuration'][0]", "['Polygon'][0]['exterior'][0]['LinearRing'][0]['posList'][0]",
            "['Polygon'][0]['exterior'][0]['Ring'][0]['curveMember'][0]['LineString'][0]['coordinates'][0]",
            "'gmx:MimeFileType'");
    $data= str_replace($elim , "", $data);
    $data= str_replace("['serviceType'][0]" , "['serviceType'][0]['LocalName'][0]", $data);  
    $data= str_replace(
      array(	
        "['begin'][0]['TimeInstant'][0]['timePosition'][0]", 
        "['end'][0]['TimeInstant'][0]['timePosition'][0]",
      	"['MD_Identifier']",
      	"'false'", "'true'", // predpokladam, ze jde o boolean
      	"MI_Metadata",
        "['gmx:Anchor'][0]['href'][0]['@']",
        "['gmx:Anchor'][0]",
        "[graphicOverview][0][href]", // TODO pro vice
        "[graphicOverview][0][title]"
      ),
      array(
        "['beginPosition'][0]", 
        "['endPosition'][0]",
      	"['RS_Identifier']",
      	"0", "1",
      	"MD_Metadata",
        "['@uri']",
        "",
        "[graphicOverview][0][MD_BrowseGraphic][0][fileName]",
        "[graphicOverview][0][MD_BrowseGraphic][0][fileDescription]"
      ), 
      $data
    );    
    //$data= str_replace("['gmx:Anchor'][0]['href'][0]['@']" , "['@uri']", $data);  
    
    //*** pro DC
    $data = str_replace(
      	Array("csw:Record","dc:","dct:abstract", "[][0]"),
      	Array("metadata","","description",""), 
      	$data
    );
    
    /*if($this->debug)  echo "<pre>". $data . "</pre>"; */
    
    //---------------------------------------
  	/*
  	if (MICKA_CHARSET != 'UTF-8') {
  	  $data = iconv('UTF-8', MICKA_CHARSET . '//TRANSLIT', $data);
  	}
    */
  	//echo "<pre>".$data; exit;
    eval($data);
    // odstraneni Locale a dateTime
    for($i=0; $i<count($md['MD_Metadata']); $i++){
    	unset($md['MD_Metadata'][$i]['locale']);
    	if(isset($md['MD_Metadata'][$i]['dateStamp'][0]['@']) && strpos($md['MD_Metadata'][$i]['dateStamp'][0]['@'], 'T')){
            $pom = explode('T',$md['MD_Metadata'][$i]['dateStamp'][0]['@']); // FIXME quick hack
            $md['MD_Metadata'][$i]['dateStamp'][0]['@'] = $pom[0]; 
        }

        // zpracovani polygonu
        for($j=0; $j< isset($md['MD_Metadata'][$i]['identificationInfo'][0]['MD_DataIdentification'][0]['extent'][0]['EX_Extent'][0]['geographicElement']) ? count($md['MD_Metadata'][$i]['identificationInfo'][0]['MD_DataIdentification'][0]['extent'][0]['EX_Extent'][0]['geographicElement']) : 0; $j++){
      	    if(isset($md['MD_Metadata'][$i]['identificationInfo'][0]['MD_DataIdentification'][0]['extent'][0]['EX_Extent'][0]['geographicElement'][$j]['EX_BoundingPolygon'][0]['polygon'][0]['@'])){
      		    $geom = explode(" ",$md['MD_Metadata'][$i]['identificationInfo'][0]['MD_DataIdentification'][0]['extent'][0]['EX_Extent'][0]['geographicElement'][$j]['EX_BoundingPolygon'][0]['polygon'][0]['@']);
      		    $result="";
      		    for($k=0; $k<count($geom); $k=$k+2){
      			    if($result) $result .=",";
      			    $result .= $geom[$k]." ".$geom[$k+1];
      		    }
      		    $md['MD_Metadata'][$i]['identificationInfo'][0]['MD_DataIdentification'][0]['extent'][0]['EX_Extent'][0]['geographicElement'][$j]['EX_BoundingPolygon'][0]['polygon'][0]['@'] = "MULTIPOLYGON(((".$result.")))";
      	    }
        }
        // doplnění překladu INSPIRE
        // --- multiligvalni klic. slova
        $lang = isset($md['MD_Metadata'][$i]["language"][0]["LanguageCode"][0]['@'])
                ? $md['MD_Metadata'][$i]["language"][0]["LanguageCode"][0]['@']
                : '';
        if(!$lang) $lang='eng';
        /*if(isset($md['MD_Metadata'][$i]['identificationInfo'][0]['SV_ServiceIdentification'])){
            $this->multiKeywords($md['MD_Metadata'][$i]['identificationInfo'][0]['SV_ServiceIdentification'][0]['descriptiveKeywords'], $lang);
        }
        else {
            $this->multiKeywords($md['MD_Metadata'][$i]['identificationInfo'][0]['MD_DataIdentification'][0]['descriptiveKeywords'], $lang);
        }*/
                
    }
    //var_dump($md); exit;
    return $md;
  }

	/**
 	* Nacteni klic slov z thesauru XML 
 	*  
 	* @param string - jazyk, ze ktereho se preklada
 	* @param string - cesta v XML
 	* 
 	*/
  function readCodelists($lang, $class){
		$xml = simplexml_load_file( __DIR__ . "/xsl/codelists.xml");
		if($xml) {
    		foreach($xml->$class->value as $keyword){
    			$k = (string) $keyword['name']; // misto labelu hodnota
    		    if($k != ''){
    				$this->kwList[$lang][$class][$k] = (string) $keyword['uri'];
    			}	
    		}		
		}
		// attempts to serach in INSPIRE registry 
		else if($class='inspireKeywords'){
		    $url = "https://inspire.ec.europa.eu/theme/theme.".$this->langCodes[$lang].".xml";
		    if(defined('CONNECTION_PROXY')){
			    $c = curl_init($url);
			    curl_setopt($c, CURLOPT_RETURNTRANSFER, TRUE);
			    curl_setopt($c, CURLOPT_SSL_VERIFYPEER, 0);
			    curl_setopt($c, CURLOPT_FOLLOWLOCATION, 1);
			    curl_setopt($c, CURLOPT_MAXREDIRS, 20);
		        $proxy = CONNECTION_PROXY;
		        if(defined('CONNECTION_PORT')) $proxy .= ':'. CONNECTION_PORT;
						curl_setopt($c, CURLOPT_PROXY, $proxy);	
		    		$data = curl_exec($c);    
		        if(!$data) die("Data not found...");
		        $xml = simplexml_load_string($data);
		    }
			else $xml = simplexml_load_file($url);
			foreach($xml->containeditems->theme as $theme){
			    $k = (string) $theme->label;
			    $this->kwList[$lang][$class][$k] = (string) $theme["id"];
			}
		}
	}
	
	/* naglicka slova - opacna struktura */
	function getEngKeywords($class){
	    $xml = simplexml_load_file( __DIR__ . "/xsl/codelists.xml");
	    $this->engKw = array();
        foreach($xml->$class->value as $keyword){
            $this->engKw[(string) $keyword['uri']] = (string) $keyword['name'];
	    }
	}
	
	/**
 	* Preklad klicoveho slova podle thesauru
 	*  
 	* @param string - klicove slovo
 	* @param string - jazyk, ze ktereho se preklada
 	* @param string - cesta v XML
 	* 
 	* @return string - preklad klic. slova
 	*/
	function translateKeyword($keyword, $lang, $xpath="inspireKeywords"){
		//if(!$this->kwList[$lang][$xpath]){
        if(!isset($this->kwList[$lang][$xpath])){
			$this->readCodelists($lang, $xpath);
		}
		$uri = $this->kwList[$lang][$xpath][$keyword];
		if(!$uri) return false;
		$kw = $this->engKw[$uri];
		return array($uri, $kw);		
	}
	
	function multiKeywords(&$keywords, $lang){
		//var_dump($keywords);
		//kdyz anglictina, nic se nedeje
	    $this->getEngKeywords("inspireKeywords");
		//if($lang=='eng') return;
		// --- cyklus pres thesaury
		for($i=0; $i<count($keywords); $i++){
		    for($j=0; $j< isset($keywords[$i]['MD_Keywords'][0]['keyword']) ? count($keywords[$i]['MD_Keywords'][0]['keyword']) : 0; $j++){
		        if(isset($keywords[$i]['MD_Keywords'][0]['keyword'][$j]['gmx:Anchor'])){
		            $keywords[$i]['MD_Keywords'][0]['keyword'][$j]['@uri'] = $keywords[$i]['MD_Keywords'][0]['keyword'][$j]['gmx:Anchor'][0]['href'][0]['@'];
		            $keywords[$i]['MD_Keywords'][0]['keyword'][$j]['@'] = $keywords[$i]['MD_Keywords'][0]['keyword'][$j]['gmx:Anchor'][0]['@'];
		            unset($keywords[$i]['MD_Keywords'][0]['keyword'][$j]['gmx:Anchor']);
		        }
		    }
			$thesaurusName = 
                    isset($keywords[$i]['MD_Keywords'][0]['thesaurusName'][0]['CI_Citation'][0]['title'][0]['@'])
                    ? $keywords[$i]['MD_Keywords'][0]['thesaurusName'][0]['CI_Citation'][0]['title'][0]['@']
                    : '';
			// --- jen INSPIRE zatím 
			if(strpos($thesaurusName, 'INSPIRE')!==false){
				// --- cyklus pres klíčová slova
				for($j=0; $j<count($keywords[$i]['MD_Keywords'][0]['keyword']); $j++){
					$kwpair = $this->translateKeyword($keywords[$i]['MD_Keywords'][0]['keyword'][$j]['@'], $lang);
					if($kwpair){
					    $keywords[$i]['MD_Keywords'][0]['keyword'][$j]['@uri'] = $kwpair[0];
					    $keywords[$i]['MD_Keywords'][0]['keyword'][$j]['@eng'] = $kwpair[1];
					}
				}
			}
		}
	}
  
  function getArrayMdFromXml($xmlString, $langs, $lang_main, $params=false,$updateType="", $md_rec="", $fc=""){
    /*---------------------------------------------------------------------
      Import jednoho XML dokumentu

		  $xmlString    obsah xml souboru
		  $format       format souboru ()
		  $user         prihlaseny uzivatel
		  $group_e   	  skupina pro editaci
		  $group_v      skupina pro prohlizeni
		  $mds  		  standard metadat
		  $langs 	  	  seznam pouzitych jazyku
			$public		  zda bude zaznam verejny
    ---------------------------------------------------------------------*/
		$mod = 'all'; // mod pro import, all importuje vse, neco jineho preskakuji uuid
		$id = "1";          // identifikator DS - pouze jedna
		$rs = -1;
		//---------------------------------------------------------------------
    $xp  = new \XsltProcessor();
    $xml = new \DomDocument;
    $xsl = new \DomDocument;
    $OK = false;
	$esri = FALSE;

    if(!$xml->loadXML($xmlString)) die('Bad xml format');
    
    //--- import kote etc (19139)
    if(!$OK){
      $root = $xml->getElementsByTagNameNS("http://www.isotc211.org/2005/gmd", "MD_Metadata");
      if($root->item(0)){
        $xslName = __DIR__ . "/xsl/import/iso.xsl";
        $OK=true;
      }
    }
   
    //--- import kote etc (19139) - ISO 19115-2
    if(!$OK){
      $root = $xml->getElementsByTagNameNS("http://www.isotc211.org/2005/gmi", "MI_Metadata");
      if($root->item(0)){
        $xslName = PHPINC_DIR ."/xsl/import/iso.xsl";
        $OK=true;
      }
    }
    
    //--- kontrola, zda je ESRI
    if(!$OK){
	    $root = $xml->getElementsByTagName("Esri");
	    if($root->item(0)){
	      if($fc != '') {
		      $xslName = __DIR__ ."/xsl/import/esri2fc.xsl";
		      $lang_fc = $langs;
	      }
	      else $xslName = __DIR__ ."/xsl/import/esri.xsl";
	      $OK = true;
	      $esri = true;
	    }
    }    
    
    //--- import WMC
    if(!$OK){
      $root = $xml->getElementsByTagNameNS("http://www.opengis.net/context", "ViewContext");
      if($root->item(0)){
        $xslName = __DIR__ ."/xsl/import/wmc.xsl";
        $OK=true; 
      }
    }
    
    //--- other import types
    if(!$OK) {
      $rs = array();
      $rs[0]['ok'] = 0;
      $rs[0]['report'] = "Bad metadata document format!";
      return $rs;
    }
    
    $md = $this->xml2array($xml, $xslName);
    //echo "<pre>"; var_dump($md); exit;
    $lang=$md['MD_Metadata'][0]["language"][0]["LanguageCode"][0]['@'];
    if($lang=='fra') $lang="fre"; // kvuli 1GE
    if (!$lang && $lang_main != '') $lang = $lang_main;
    $md['MD_Metadata'][0]["language"][0]["LanguageCode"][0]['@'] = $lang;
    if (strpos($langs,$lang) === false && !$lang) $langs = $lang . "|" . $langs; // kontrola, zda je jazyk zaznamu v seznamu pouzitych jazyku

    if($params){
      	$md = $this->array_replace_recursive($md,$params);
    }
    //die($lang);       
    if($fc != '') {
    	$updateType = 'fc|' . $fc;
    }
    else {
      $uuid = $md['MD_Metadata'][0]['fileIdentifier'][0]['@'];
      // import obrazku z ESRI dokumentu
      if($esri){
        if($this->extractImage($xml, "graphics/$uuid.png")){
          if($ser) $pom = 'SV_ServiceIdentification'; else $pom = 'MD_DataIdentification';
          $md['MD_Metadata'][0]['identificationInfo'][0][$pom][0]['graphicOverview'][0]['MD_BrowseGraphic'][0]['fileName'][0] = "http://".$_SERVER['SERVER_NAME'].dirname($_SERVER['PHP_SELF'])."/graphics/$uuid.png";        
          $md['MD_Metadata'][0]['identificationInfo'][0][$pom][0]['graphicOverview'][0]['MD_BrowseGraphic'][0]['fileDescription'][0] = "náhled";        
        }
      }
		}
   	if ($md_rec != '') {
    	$updateType = 'update|' . $md_rec;
   	}

    //return ['md'=>$md, 'updateType'=>$updateType];
    return $md;
  }

  function getArrayMdFromUrl($url, $service, $langs, $lang='eng', $updateType=''){
    /*---------------------------------------------------------------------
	Import metadat ze sluzby

      		$filename   nazev xml souboru
		  	$service    nazev typu sluzby (WMS, WFS, WCS, CSW, ...) podporovano zatim WMS
			$user       prihlaseny uzivatel
			$group_e   	skupina pro editaci
			$$group_v   skupina pro prohlizeni
			$mds  		standard metadat
			$langs    	seznam pouzitych jazyku
    		$lang		jazyk zaznamu
			$public		zda bude zaznam verejny
    ---------------------------------------------------------------------*/
    //$mod = 'all'; // mod pro import, all importuje vse, neco jineho preskakuji uuid
    $id = "1";                // identifikator zaznamu
    $rs = -1;
    //-----------------------------------------------

    $url = trim(htmlspecialchars_decode($url));
  	if (strpos($langs,$lang) === false) $langs = $lang . "|" . $langs; // kontrola, zda je jazyk zaznamu v seznamu pouzitych jazyku

    if(!strpos(strtolower(".".$url), "http")) $url = "http://".$url;
    if($service != 'KML' && $service != 'XML'){
        if(!strpos(strtolower($url), "service=")){
          if(!strpos($url, "?")) $url .= "?"; else $url .= "&";
          $url .= "SERVICE=".$service;
        }
        if(!strpos(strtolower($url), "getcapabilities")) $url .= "&REQUEST=GetCapabilities";
    }    
    //echo "input url= <a href='$url'>$url</a>"; //TODO potom dat do reportu
    $xp  = new \XsltProcessor();
    $xml = new \DomDocument;
    $xsl = new \DomDocument;
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
	$s = curl_exec($c); 
    curl_close($c);
    //die ($service);
    if(strpos($url,'.kmz')!==false){
        $tmp = __DIR__ .'/../../logs/'.time().'.zip';
        file_put_contents($tmp, $s);
        $zip = zip_open($tmp);
        $s = '';
        while ($res = zip_read($zip)){ 
            if(strpos(zip_entry_name($res),'.kml')!==false){
                $s = zip_entry_read($res, zip_entry_filesize($res));
                break;
            }    
        }
        zip_close($zip);
        unlink($tmp);
    }
    if(!$s) exit("<br>No data/connection! " . $url );
    //TODO QUICK HACK - udleat pres sablony nebo DOM 
    if(strpos($s,'exception')) exit("<br><br>Exception: ". $s ." " . $url);
    if(strpos($s,'NetworkLink>')) exit("<br><br>Network links in KML are not supported yet.");
    if(!@$xml->loadXML($s)) exit("<br><br>Not valid service!  " . $url);
    if($service == 'XML'){
        $tmp_md = $this->xml2array($xml, __DIR__."/xsl/import/iso.xsl" , array("URL"=>$url));
        if (array_key_exists('MD_Metadata', $tmp_md)) {
            $md = $tmp_md;
        } else {
            $md = [];
            $md["MD_Metadata"][0] = $tmp_md;
        }
    }
    else {
        $xslName = __DIR__."/xsl/import/".strtolower($service).".xsl"; // vyber sablony
        $md = $this->xml2array($xml, $xslName, array("URL"=>$url));
    }
    if(!isset($md['MD_Metadata'][0]["language"][0]["LanguageCode"][0]['@'])) {
    	$md['MD_Metadata'][0]["language"][0]["LanguageCode"][0]['@'] = $lang;
    }
    $url1 = isset($md["MD_Metadata"][0]["distributionInfo"][0]["MD_Distribution"][0]["transferOptions"][0]["MD_DigitalTransferOptions"][0]["onLine"][0]["CI_OnlineResource"][0]["linkage"][0]["@"])
            ? $md["MD_Metadata"][0]["distributionInfo"][0]["MD_Distribution"][0]["transferOptions"][0]["MD_DigitalTransferOptions"][0]["onLine"][0]["CI_OnlineResource"][0]["linkage"][0]["@"]
            : '';
	//var_dump($md); exit;
    // --- vyhledani duplicitniho zaznamu ---
    if($updateType == "all"){
    	require PHPPRG_DIR . '/MdExport.php';
    	$export = new MdExport($_SESSION['u'], 1, 10, null); 
    	$ddata = $export->getdata(array(
    		"@linkage = '".$url1."'",
    		"And",
    		"@type = 'service'"
    			
    	));
		// nalezen záznam
		if(count($ddata["data"]) > 0){
			if(count($ddata["data"]) > 1){ 
				echo 'More records found with this URL.';
				foreach ($ddata["data"] as $row) echo "<br>". $row['uuid'].": ". $row['title'];
				echo '<br>The record will be added as new.';
			}
			else{
				echo "found record: <b>".$ddata["data"][0]['uuid']."</b> ".$ddata["data"][0]['title'] ;
				$md['MD_Metadata'][0]["fileIdentifier"][0]['@'] = $ddata["data"][0]['uuid'];
			}
		}
    }
     return $md;
  } // konec funkce importService

} // konec class MetadataImport
