<?php

if(!function_exists('_inspireGet')){
    function _inspireGet($uri, $config=false, $lang='en'){
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
        foreach($data as $key=>$data){
            // only one item
            foreach($data['containeditems'] as $row){ 
                $result[$row['value']['id']] = array(
                    "id" => $row['value']['id'],
                    "text"=>$row['value']['label']['text'],
                    "title" =>  isset($row['value']['definition']) ? $row['value']['definition']['text']: false,
                    "parentId" =>  isset($row['value']['parents']) ? $row['value']['parents'][0]['parent']['id'] : false,
                    "parentName" => isset($row['value']['parents']) ? $row['value']['parents'][0]['parent']['label']['text'] : false  
                );   
            }
            return array(
                "id" => $data['id'],
                "result" => $result
            );
        }
    }

    function _inspireGetTranslations($uri, $config, $id){
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

$getRemoteData = '_inspireGet';
$getTranslations = '_inspireGetTranslations';