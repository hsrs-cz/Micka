<?php

function _inspireThemeGet($uri, $config=false, $lang='en'){
    $url = $uri . substr($uri, strrpos($uri, '/')) . '.' . $lang . '.json';
    $json = getDataByURL($url);
    if(!$json){
        return array(
            "id" => 'error',
            "result" => []
        );
    }
    $data = json_decode($json, 1);
    $result = array();
    foreach($data['register']['containeditems'] as $row){ 
        $result[$row['theme']['id']] = array(
            "id" => $row['theme']['id'],
            "text"=>$row['theme']['label']['text'],
            "title" => $row['theme']['definition']['text'],
            "parentId" =>  isset($row['theme']['parents']) ? $row['theme']['parents'][0]['parent']['id'] : false,
            "parentName" => isset($row['theme']['parents']) ? $row['theme']['parents'][0]['parent']['definition']['text'] : false  
        );  
    }
    return array(
        "id" => isset($data['codelist']['id']) ? $data['codelist']['id']: null ,
        "result" => $result
    );
}

function _inspireThemeGetTranslations($uri, $config, $id){
    $url = $config['url']."?query=".urlencode($config['translations'])."&format=".$config['format'];
    $json = getDataByURL($url);
    if(!$json){
        die('not found: '. $url);
    }
    $data = json_decode($json,1);
    $result = array();
    foreach ($data['results']['bindings'] as $row){
        $result[$row['prefLabel']["xml:lang"]] = $row['prefLabel']['value'];
    }
    return $result;
}


$getRemoteData = '_inspireThemeGet';
$getTranslations = '_inspireThemeGetTranslations';
