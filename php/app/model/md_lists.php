<?php
/**
 * version 20121119
 */

$title = '';

function getList($type, $lang, $withValues=false){
    if($type=='fspec'){
        @$xml = simplexml_load_file(APP_DIR . "/model/xsl/codelists_$lang.xml");
        if(!$xml) $xml = simplexml_load_file(APP_DIR . "/model/xsl/codelists_eng.xml");
        echo '<div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4>'.(string) $xml->inspireKeywords['title'].'</h4>
        </div><div class="modal-body">';
        $list = $xml->xpath("//inspireKeywords/value");
        foreach ($list as $entry){
            echo "<a href=\"javascript:fspec1('D.2.8.".$entry['n']." INSPIRE Data Specification on ".$entry['code']." - Guidelines', '".$entry['publication']."'); window.close();\">".(string) $entry."</a><br>";
        }
        echo "</div>";
        return;
    }
	@$xml = simplexml_load_file(APP_DIR . "/model/dict/$type.xml");
	if(!$xml) die("list <b>$type</b> does not exist");
	// test jazyka
	$langBranch = $xml->xpath("//translation[@lang='".$lang."']");
	if(isset($langBranch[0]) === FALSE) $lang='eng';
	$pageTitle = $xml->xpath("//translation[@lang='".$lang."']/title");
    echo '<div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4>'. $pageTitle[0].'</h4>
        </div><div class="modal-body">';
	foreach ($xml->xpath("//translation[@lang='".$lang."']/group") as $list) {
    	echo "<h3>".$list->title.'</h3>';
    	foreach ($list->entry as $entry){
    		// pouzije primarne label, kdyz neni, tak hodnotu
    		$value = $entry['label'];
    		if(!$value) $value = (string) $entry;
            $f = (isset($_REQUEST['handler']) && $_REQUEST['handler']) ? $_REQUEST['handler'] : 'false';
    		if($withValues) echo "<a href=\"javascript:micka.fillValues('".$type."','".$entry['id']."', ".$f.");\">".$value."</a><br>";
    		else echo "<a href=\"javascript:kw('".$entry['code']."');\">".(string) $entry."</a><br>";
    	}
	}
    echo "</div>";
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
<script>
function kw(f){
<?php 
    if(isset($_REQUEST['handler']) && $_REQUEST['handler']) echo htmlspecialchars($_REQUEST['handler'])."(f);";
    else echo "formats1(f);";
?>
}
</script>
       

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


