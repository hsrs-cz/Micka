<?php

function getRemoteData($uri, $config, $lang){
    $headers=array( "Accept: application/sparql-results+json" );
    $url = $config['url'] . "?query=" . rawurlencode($config['sparql']);    
    $ch = curl_init ($url);
    curl_setopt ($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
    $data= curl_exec ($ch);
    curl_close ($ch);
   // echo $data; die;
    
    $data = json_decode($data, 1);
    $result = array();
    foreach($data['results']['bindings'] as $row){ 
        $result[$row['id']['value']] = array(
            "id" => $row['id']['value'],
            "name"=>$row['label']['value'],
            "desc" => $row['description']['value'],
            "parentId" =>  $row['broader']['value'] ? $row['broader']['value'] : false,
            "parentName" => $row['broader']['value'] ? $row['broaderLabel']['value'] : false   
        );   
    }
    return array(
        "id" => $data['codelist']['id'],
        "result" => $result
    );
}

