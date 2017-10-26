<?php
/******************************
* verze 20130108
******************************/

$lang = $this->appLang;
if($lang != 'cze') $lang = 'eng';

$labels = array();
$labels['cze']['unit']='Jednotka';
$labels['cze']['name']='Název';

$labels['eng']['unit']='Unit';
$labels['eng']['name']='Name';

$labels['spa']['unit']='Unidad';
$labels['spa']['name']='Nombre';

?>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="<?php echo substr($_SERVER['SCRIPT_NAME'], 0, strrpos($_SERVER['SCRIPT_NAME'], '/')) . '/layout/default'; ?>/micka.css" />
<script language="javascript" src="scripts/ajax.js"></script>
<title>MICKA - Gazeteer</title>
<script>

function gazPoly(i){
  if((!opener)||(!opener.md_gazet1)){
    alert('Main window is closed !');
    window.close();
    return;
  }
  for(var j=0;j<(coord[i]).length;j++){
    if(j==0)opener.md_gazet1(coord[i][j], true);
    else opener.md_gazet1(coord[i][j], false);
  }
}

function gazBbox(bbox){
  if(!opener){
    alert('Parent window was closed');
    return;
  }
  opener.micka.fromGaz(bbox);
  window.close();

 /* var mapFrame = opener.frames[0];
  // pro portal
  if(opener.portal){
  	opener.getGazBbox(bbox);
  }
  else if(mapFrame.epsg!=4326){
    var ajax = new HTTPRequest;
    ajax.get("/mapserv/php/transform.php?request=getProjected&mapcoords="+bbox+"&srs=EPSG:4326&srsout=EPSG:"+mapFrame.epsg, null, tBbox, true);
  }
  else{
    opener.getFindBbox(bbox);
    mapFrame.vyrez(bbox);
    //mapFrame.swapImage();
    //mapFrame.refreshmap();
  }  */
}

function tBbox(s){
  var mapFrame = opener.frames[0];
  mapFrame.document.forms.mapserv.imgext.value=s.responseText.replace(/,/, ' ');
  mapFrame.swapImage();
  //mapFrame.refreshmap();
}

</script>
</head>
<body onload="javascript:window.focus();">
<h2>Gazetteer</h2>
<form>
	<input type="hidden" name="ak" value="md_gazcli">
<table>
<tr><td><?php echo $labels[$lang]['unit']; ?>:</td>
<td>
<?php
class gazClient{
  var $url;
  var $xslName;
  var $typename;
  var $item;

  function __construct($url, $xslName, $typename, $item, $cp=""){
    if(!extension_loaded("xsl")){
      if(substr(PHP_OS,0,3)=="WIN") dl("php_xsl.dll");
      else dl("php_xsl.so");
    }
    $this->url = $url;
    $this->xslName = $xslName;
    $this->typename = $typename;
    $this->item = $item;
    $this->cp = $cp;
  }

  private function getDataByPost($params){
  // params = asociativni pole odpovidajici key=>val
    $content = http_build_query($params);
    $options = array('http'=>array(
      'method' => 'POST',
      'header' => "Content-type: application/x-www-form-urlencoded\r\n", 'content' => $content)
    );
    $context = stream_context_create($options);
    $val = file_get_contents($this->url, false, $context);
    return $val;
  }

  private function getDataByGet($params){
  	// params = asociativni pole odpovidajici key=>val
    $s = '';
  	foreach($params as $key=>$val){
  		$s .= "&".$key."=".$val;
  	}
  	$val = file_get_contents($this->url."?".substr($s,1));
  	return $val;
  }

  function getData($qstr){
  	if($this->cp) $qstr = iconv("UTF-8", $this->cp, $qstr);
    $xp = new XsltProcessor();
    $xml = new DomDocument;
    $xsl = new DomDocument;
    $query["SERVICE"]="WFS";
    $query["VERSION"]="1.0.0";
    $query["REQUEST"] = "GetFeature";
    $query["TYPENAME"] = $this->typename;
    $query["Filter"]="<ogc:Filter><ogc:PropertyIsLike wildCard=\"*\" singleChar=\"@\" escape=\"\\\" matchCase=\"false\"><ogc:PropertyName>".$this->item."</ogc:PropertyName><ogc:Literal>$qstr</ogc:Literal></ogc:PropertyIsLike></ogc:Filter>";
    $query["Filter"]=urlencode("<Filter><PropertyIsLike wildCard=\"*\" singleChar=\"@\" escape=\"\\\" matchCase=\"false\"><PropertyName>".$this->item."</PropertyName><Literal>$qstr</Literal></PropertyIsLike></Filter>");
    //highlight_string($query["Filter"]); echo "<hr>";
    $s = $this->getDataByGet($query);
    //highlight_string($s);
    // exit;
    $xml->loadXML($s);
    $xsl->load($this->xslName);
    //echo $this->xslName;
    //highlight_string($xsl->saveXML());
    $xp->importStyleSheet($xsl);
    return $xp->transformToXML($xml);
  }
} // end of class gazClient

//--- precte seznam serveru do select
$query = isset($_REQUEST["query"]) ? htmlspecialchars($_REQUEST["query"]) : '';
$simple = isset($_REQUEST["simple"]) ? htmlspecialchars($_REQUEST["simple"]) : '';

$wfsList = new DomDocument;
$wfsList->load(APP_DIR ."/model/gazet/wfs_servers.xml");
$servers = $wfsList->getElementsByTagName("server");
echo "<select name='wfs'>";
foreach($servers as $server){
  if(isset($_REQUEST["wfs"]) && $server->getAttribute("name")==$_REQUEST["wfs"]) $sel=" selected"; else $sel="";
  echo "<option value=".$server->getAttribute("name").$sel.">".$server->getAttribute("label")."</option>";
}
echo "</select>";
?>
</td></tr>
	<tr><td><?php echo $labels[$lang]['name'];?>:</td><td><input name='query' value="<?php echo isset($_REQUEST["query"]) ? $_REQUEST["query"] : ''; ?>">
<input type="hidden" name="simple" value="<?php echo isset($_REQUEST["simple"]) ? $_REQUEST["simple"] : ''; ?>">
<input type='submit' value='OK'></td></tr></table>
</form>
<?php
//--- vlastni zpracovani dotazu ---
if(isset($query) && $query){
  echo "<br><table class='odp'>";
  if($simple){
    foreach($servers as $server){
      if($server->getAttribute("name")==$_REQUEST["wfs"]){
        $gazet = new gazClient($server->getAttribute("href"), APP_DIR."/model/gazet/".$server->getAttribute("xslb"), $server->getAttribute("typeName"), $server->getAttribute("propertyName"), $server->getAttribute("cp"));
        break;
      }
    }
    $s = $gazet->getData("*".$query."*");
    if(!trim($s)) echo "not found";
  }
  else {
    foreach($servers as $server){
      if($server->getAttribute("name")==$_REQUEST["wfs"]){
        $gazet = new gazClient($server->getAttribute("href"), APP_DIR."/model/gazet/".$server->getAttribute("xsl"), $server->getAttribute("typeName"), $server->getAttribute("propertyName"), $server->getAttribute("cp"));
        break;
      }
    }

  //zpracovani gazeteeru
    $s = $gazet->getData("*".$query."*");
    $rows = explode ("|", $s);
    $s = "";
    $sour = "";
    for($i=0;$i<(count($rows)-1); $i++){
      $pom = explode(":", $rows[$i]);
      $s .= "<a href=\"javascript:gazPoly($i);\">$pom[0]</a><br>";
      $j = 0;
      $sour .= "coord[$i] = new Array();";
      while(strlen($pom[1])>1024){
        $sour .= "coord[$i][$j]='".substr($pom[1],0,1024)."';";
        $pom[1]=substr($pom[1],1024,999999);
        $j++;
      }
      $sour .= "coord[$i][$j]='".$pom[1]."';";
    }


  echo "<script>
  var coord =new Array();
  $sour
  </script>";
  }
  echo $s;

  echo "</table>";
}
else {
?>
    <br><table class="odp"><tr><td><a href="javascript:gazBbox('12.09 48.55 18.86 51.06');">Česká republika</a></td></tr></table>
<?php
}
?>

</body>
</html>
