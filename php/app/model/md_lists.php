<?php
/**
 * version 2018-11-05
 * FIXME - add to main app
 */

$title = '';

function getList($type, $lang, $mdlang, $withValues=false, $handler=""){
    if(!$handler) $handler="formats1";
    if(in_array($type, array('coordSys','format','limitationsAccess', 'accessCond', 'protocol', 'inspireKeywords', 'hlname', 'linkageName', 'serviceType'))){
        $xml = simplexml_load_file(APP_DIR . "/config/codelists.xml");
        $title = $xml->xpath("//$type/title[@lang='".$lang."']")[0];
        echo '<div class="panel-heading">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4>'.(string) $title .'</h4>
        </div><div class="modal-body">';
        $list = $xml->xpath("//$type/value");
        foreach ($list as $row){
            if($row['uri']) echo "<a href=\"javascript:$handler({uri:'".$row['uri']."', ";
            else echo "<a href=\"javascript:$handler({value:'".$row['value']."', ";
            foreach($row as $k=>$v){
                if($k!='uri'){
                    echo "$k:'".$v."',";
                }
            }
            echo "xxx:'".(string) $row->$mdlang."'});\">".(string) $row->$lang."</a><br>";
        }
        echo "</div>";
        return;
    }
    else if(in_array($type, array('specifications'))){
        $xml = simplexml_load_file(APP_DIR . "/config/codelists.xml");
        $title = $xml->xpath("//$type/title[@lang='".$lang."']")[0];
        echo '<div class="modal-headerx panel-heading">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4>'.(string) $title .'</h4>
        </div><div class="modal-body">';
        $list = $xml->xpath("//$type/value");
        foreach ($list as $row){
            echo "<a href=\"javascript:formats1({uri:'".$row['uri']."', ";
            if($row['publication']){
                echo "publication:'".$row['publication']."', ";
            }
            foreach($row as $k=>$v){
                if($k!='uri'){
                    echo "$k:'".addslashes($v['name'])."',";
                }
            }
            echo "xxx:'".(string) $row->$mdlang."'});\">".(string) $row->$lang."</a><br>";
        }
        echo "</div>";
        return;
    }
}

function getCodeListValues($type, $lang, $filter=''){
    $xml = simplexml_load_file(APP_DIR . "/config/codelists.xml");
    $list = $xml->xpath("//$type/value");
    $result = [];
    foreach ($list as $row){
        if(!$filter || stripos($row->$lang, $filter)!==false || stripos($row['uri'], $filter)!==false){
            $result[] = [
                "id"=> (string) $row['name'],
                "uri"=> (string) $row['uri'],
                "text"=> (string) $row->$lang
            ];
        }
    }
    return ["results"=>$result];
}

function getCodeListValue($type, $filter=''){
    $xml = simplexml_load_file(APP_DIR . "/config/codelists.xml");
    $t = $xml->xpath("//$type/thesaurus");
    if($t[0]){
        $thesarus = [
            "uri" => (string) $t[0]['uri'],
            "date" => (string) $t[0]['date'],
            "dateType" => (string) $t[0]['dateType'],
            "langs"=> $t[0]->children()
        ];
    }
    $list = $xml->xpath("//$type/value");
    $result = [];
    foreach ($list as $row){
        if(!$filter || $row['name'] == $filter || $row['uri'] == $filter){
            $result[] = [
                "id"=> (string) $row['name'],
                "uri"=> (string) $row['uri'],
                "langs"=> $row->children()
            ];
        }
    }
    return [
        "thesaurus"=>$thesarus,
        "results"=>$result
    ];
}


if(isset($_REQUEST['request']) && $_REQUEST['request'] == 'getValues') {
    $type = htmlspecialchars($_REQUEST['type']);
    $code = htmlspecialchars($_REQUEST['id']);
    $lang = htmlspecialchars($_REQUEST['lang']);
    $query = isset($_REQUEST['query']) ? $_REQUEST['query'] : '';
    header("Content-type: application/json; charset=utf-8");
    echo json_encode(getCodeListValues($type, $lang, $query));
    exit;
}
else if(isset($_REQUEST['request']) && $_REQUEST['request'] == 'getValue') {
    $type = htmlspecialchars($_REQUEST['type']);
    $code = htmlspecialchars($_REQUEST['code']);
    $query = isset($_REQUEST['query']) ? $_REQUEST['query'] : '';
    header("Content-type: application/json; charset=utf-8");
    echo json_encode(getCodeListValue($type, $code));
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
    $mdlang = htmlspecialchars($_REQUEST['mdlang']);
    $handler = htmlspecialchars($_REQUEST['handler']) ? htmlspecialchars($_REQUEST['handler']) : false;
    if(!$lang) $lang='eng';
    if(!$mdlang) $mdlang='eng';
    if(isset($_REQUEST['multi']) && $_REQUEST['multi']==1) {
        $multi = true;
    } else {
        $multi = false;
    }
    echo getList(htmlspecialchars($_REQUEST['type']), $lang, $mdlang, $multi, $handler);

