<?php

function getRemoteData($uri, $config=false, $lang='en'){
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
                "title" => $row['value']['definition']['text'],
                "parentId" =>  $row['value']['parents'] ? $row['value']['parents'][0]['parent']['id'] : false,
                "parentName" => $row['value']['parents'] ? $row['value']['parents'][0]['parent']['definition']['text'] : false  
            );   
        }
        return array(
            "id" => $data['id'],
            "result" => $result
        );
    }
}
