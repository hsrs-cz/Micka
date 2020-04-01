<?php

if(!function_exists('_geoeraGet')){
    function _geoeraGet($uri, $config=false, $lang='en'){
        $url = $config['url']."?query=".urlencode($config['sparql'])."&format=".$config['format'];
        //die($url);
        $json = getDataByURL($url);
        //var_dump($json);
        if(!$json){
            die('not found: '. $url);
        }
        $data = json_decode($json, 1);
        //var_dump($data); die();
        $result = array();
        foreach($data['results']['bindings'] as $row){ 
            $result[$row['Concept']['value']] = array(
                "id" => $row['Concept']['value'],
                "text"=>$row['prefLabel']['value'],
                //"title" => $row['theme']['definition']['text'],
                //"parentId" =>  $row['broader']['value'],
                "parentName" => isset($row['theme']['parents']) ? $row['theme']['parents'][0]['parent']['definition']['text'] : false  
            );   
        }
        return array(
            "id" => isset($data['codelist']['id']) ? $data['codelist']['id'] : null,
            "result" => $result
        );
    }

    function _geoeraGetTranslations($uri, $config, $id){
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
}

$getRemoteData = '_geoeraGet';
$getTranslations = '_geoeraGetTranslations';