<?php
session_start();
require_once('lib/RegistryReader.php');

$uri = htmlspecialchars($_GET['uri']);
$lang = isset($_GET['lang']) ? htmlspecialchars($_GET['lang']): 'en';
$query = isset($_GET['q']) ? htmlspecialchars($_GET['q']) : '';

if(!$lang) $lang = 'en';
$r = new RegistryReader($lang);

if(isset($_GET['translations']) && $_GET['translations']){
    $data = $r->getTranslations($uri, htmlspecialchars($_GET['translations']));
}
else if(isset($_GET['id']) && $_GET['id']){
    $r->getData($uri);
    $data = $r->queryById(htmlspecialchars($_GET['id']));
}
else {
    $r->getData($uri, $query); 
    $data = $r->query($query, true);
}

$json = json_encode(array(
    "query"=>$query, 
    "cached"=>$r->cached,
    "results"=>$data)
);
header('Content-Type: application/json;charset=utf-8');
echo $json;
