<?php
/**
 * version 20121119
 */

$title = '';

function getList($type, $lang, $withValues=false){
    if($type=='fspec'){
        @$xml = simplexml_load_file(APP_DIR . "/model/xsl/codelists_$lang.xml");
        if(!$xml) $xml = simplexml_load_file(APP_DIR . "/model/xsl/codelists_eng.xml");
        echo "<h1>".(string) $xml->inspireKeywords['title']."</h1>";
        $list = $xml->xpath("//inspireKeywords/value");
        foreach ($list as $entry){
            echo "<a href=\"javascript:opener.fspec1('D.2.8.".$entry['n']." INSPIRE Data Specification on ".$entry['code']." - Guidelines', '".$entry['publication']."'); window.close();\">".(string) $entry."</a><br>";
        }
        /*echo "<br><h1>".(string) $xml->serviceSpecifications['title']."</h1>";
        $list = $xml->xpath("//serviceSpecifications/value");
        foreach ($list as $entry){
            echo "<a href=\"javascript:opener.fspec1('".$entry['name']."'); window.close();\">".(string) $entry."</a> *<br>";
        }*/
        return;
    }
	@$xml = simplexml_load_file(APP_DIR . "/model/dict/$type.xml");
	if(!$xml) die("list <b>$type</b> does not exist");
	// test jazyka
	$langBranch = $xml->xpath("//translation[@lang='".$lang."']");
	if(isset($langBranch[0]) === FALSE) $lang='eng';
	$pageTitle = $xml->xpath("//translation[@lang='".$lang."']/title");
	echo "<h2>".$pageTitle[0]."</h2>";
	foreach ($xml->xpath("//translation[@lang='".$lang."']/group") as $list) {
    	echo "<h3>".$list->title.'</h3>';
    	foreach ($list->entry as $entry){
    		// pouzije primarne label, kdyz neni, tak hodnotu
    		$value = $entry['label'];
    		if(!$value) $value = (string) $entry;
    		if($withValues) echo "<a href=\"javascript:micka.fillValues('".$type."','".$entry['id']."');\">".$value."</a><br>";
    		else echo "<a href=\"javascript:kw('".$entry['code']."');\">".(string) $entry."</a><br>";
    	}
	}
}

function getValues($type, $filter){
	$xml = simplexml_load_file(APP_DIR . "/model/dict/$type.xml");
	$result = array();
	foreach ($xml->xpath($filter) as $entry) {
		$lang = $entry->xpath("../../@lang");
		$parent =  $entry->xpath("..");
		$parent = $parent[0];
		$prefix = (string) $parent->prefix;
		//var_dump($parent);
		foreach($parent->attributes() as $k => $v) {
		    $result[(string) $lang[0]][(string) $k] = (string) $v;
		}
		if (isset($prefix)) {
			$result[(string) $lang[0]]['value'] = (string) $prefix . (string) $entry;
		} else {
			$result[(string) $lang[0]]['value'] = (string) $entry;
		}
		foreach($entry->attributes() as $k => $v) {
		    $result[(string) $lang[0]][(string) $k] = (string) $v; 
		}
		
	}
	return $result;
}

// vraci JSON multilingualni seznam
if(isset($_REQUEST['request']) && $_REQUEST['request'] == 'getValues') {
	$type = htmlspecialchars($_REQUEST['type']);
	$code = htmlspecialchars($_REQUEST['id']);
	$filter = "//entry[@id='".$code."']";
	$q = htmlspecialchars($_REQUEST['q']);
	if($q) {
	    $filter = "//entry[contains(.,'".$q."')]";
	}
    header("Content-type: application/json; charset=utf-8");
	echo json_encode(getValues($type, $filter));
	exit;
}
?>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" type="text/css" href="<?php echo substr($_SERVER['SCRIPT_NAME'], 0, strrpos($_SERVER['SCRIPT_NAME'], '/')) . '/layout/default'; ?>/micka.css" />
<title>MICKA - <?php echo $title; ?></title>
<script language="javascript" src="<?php echo WEB_SCRIPTPATH; ?>/scripts/ajax.js"></script>
<script>
function fillValues(listType,code){
    var ajax = new HTTPRequest;
    ajax.get("index.php?ak=md_lists&request=getValues&type="+listType+"&id="+code, "", fillValuesResponse, false);
}

var micka = {};
micka.fillValues = function(listType,code){
    var ajax = new HTTPRequest;
    ajax.get("index.php?ak=md_lists&request=getValues&type="+listType+"&id="+code, "", fillValuesResponse, false);
}

function fillValuesResponse(r){
	if(r.readyState == 4){
		eval("var k="+r.responseText);
		kw(k);
	}
}

function kw(f){
	<?php 
	    if(isset($_REQUEST['handler']) && $_REQUEST['handler']) echo "opener.".htmlspecialchars($_REQUEST['handler'])."(f);";
	    else echo "opener.formats1(f);";
	?>
  window.close();
}
</script>
</head>
<body onload="javascript:focus();">
<?php
    $lang = htmlspecialchars($_REQUEST['lang']);
    if(!$lang) $lang='eng';
    if(isset($_REQUEST['multi']) && $_REQUEST['multi']==1) {
        $multi = true;
    } else {
        $multi = false;
    }
    echo getList(htmlspecialchars($_REQUEST['type']), $lang, $multi);
?>
</body>
</html>
