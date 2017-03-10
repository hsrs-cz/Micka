<?php

$lang = $_REQUEST['language'];
if(!$lang) $lang = 'en';
$xml = simplexml_load_file("srvlist_$lang.xml");

/************** COMBO BOX ************************/
if($_REQUEST['mode']=='combo'){
  foreach($xml->xpath("/items/value/value".$q) as $value){
    if((!$_REQUEST['query'])||(strpos (strtolower(".".$value), strtolower($_REQUEST['query'])))){ 
      if($s) $s .= ",";
      $s .= sprintf('{id:"%s",name:"%s",text:"%s",qtip:"%s",leaf:true,cls:"thes-link"}', 
          $value['id'],$value['name'],$value,$value['qtip']);      
    }        
  }  
  echo "{items:[".$s."]}";
  exit;
}

/***************** Tree ******************************/
// podrizene zaznamy
if($_REQUEST['node']){
  foreach($xml->xpath("/items/value[@id=$_REQUEST[node]]/*") as $value){
    if($s) $s .= ",";
    $s .= sprintf('{id:"%s",name:"%s",text:"%s: %s",qtip:"%s",leaf:true,cls:"thes-link"}', 
          $value['id'],$value['name'],$value['id'],$value,$value['qtip']);
  }  
}

// skupiny
else foreach($xml->value as $value){
  if($s) $s .= ",";
  $s .= sprintf('{id:"%s",text:"%s",qtip:"%s",singleClickExpand:true}', 
        $value['id'],$value['text'],$value['qtip']);
}
echo "[".$s."]";
?>