<?php

function getRemoteData($uri, $config=false, $lang='en'){
    $url = $config['url'];
    $ch = curl_init ($url);
    //curl_setopt ($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
    $data= curl_exec ($ch);
    curl_close ($ch);
    echo $data; die;


    $data = getDataByURL($url);
    var_dump($data);
    if(!$json){
        die('nenalezeno: '. $url);
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
