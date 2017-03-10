<?php
require_once('lib/RegistryReader.php');

$uri = htmlspecialchars($_GET['uri']);
$lang = htmlspecialchars($_GET['lang']);
$query = isset($_GET['q']) ? htmlspecialchars($_GET['q']) : '';

$r = new RegistryReader($lang);
$r->getData($uri);
$data = $r->query($query, true);

$json = json_encode(array("query"=>$query, "suggestions"=>$data));
header('Content-Type: application/json;charset=utf-8');
echo $json;
