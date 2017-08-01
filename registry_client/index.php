<?php
require_once('lib/RegistryReader.php');

$uri = htmlspecialchars($_GET['uri']);
$lang = htmlspecialchars($_GET['lang']);
$r = new RegistryReader($lang);
$r->getData($uri);

if(isset($_GET['id'])){
       $data = $r->queryById(htmlspecialchars($_GET['id']));
}
else {
    $query = isset($_GET['q']) ? htmlspecialchars($_GET['q']) : '';
    $data = $r->query($query, true);
}

$json = json_encode(array(
    "query"=>$query, 
    "cached"=>$r->cached ,
    "results"=>$data)
);
header('Content-Type: application/json;charset=utf-8');
echo $json;
