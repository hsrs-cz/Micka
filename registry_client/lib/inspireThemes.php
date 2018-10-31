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
    foreach($data['register']['containeditems'] as $row){ 
        $result[$row['theme']['id']] = array(
            "id" => $row['theme']['id'],
            "text"=>$row['theme']['label']['text'],
            "title" => $row['theme']['definition']['text'],
            "parentId" =>  $row['theme']['parents'] ? $row['theme']['parents'][0]['parent']['id'] : false,
            "parentName" => $row['theme']['parents'] ? $row['theme']['parents'][0]['parent']['definition']['text'] : false  
        );   
    }
    return array(
        "id" => $data['codelist']['id'],
        "result" => $result
    );
}
