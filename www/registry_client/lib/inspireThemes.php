<?php

function getRemoteData($uri, $config=false, $lang='en'){
    $url = $uri . substr($uri, strrpos($uri, '/')) . '.' . $lang . '.json';
    $json = file_get_contents($url);
    if(!$json){
        die('nenalezeno: '. $url);
    }
    $data = json_decode($json, 1);
    $result = array();
    foreach($data['register']['containeditems'] as $row){ 
        $result[$row['theme']['id']] = array(
            "id" => $row['theme']['id'],
            "name"=>$row['theme']['label']['text'],
            "desc" => $row['theme']['definition']['text'],
            "parentId" =>  $row['theme']['parents'] ? $row['theme']['parents'][0]['parent']['id'] : false,
            "parentName" => $row['theme']['parents'] ? $row['theme']['parents'][0]['parent']['definition']['text'] : false  
        );   
    }
    return array(
        "id" => $data['codelist']['id'],
        "result" => $result
    );
}
