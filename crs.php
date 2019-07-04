<?php
function getCRS($s){
    if(!$s) return '';
    $p = '/CRS=EPSG:(.+?)(\s|$|\.|\,)/';
    preg_match_all($p, $s, $m);
    if(!$m) return '';
    $data = '';
    echo "<pre>"; var_dump($m);
    foreach($m[1] as $item){
        $data .= "<item>$item</item>";
    }
    $xml = new DomDocument;
    $xml->loadXML('<root>'.$data.'</root>');
    return $xml;
}

//echo "<hr>";
echo getCRS('aaa dddd CRS=EPSG:4326 sdk slk CRS=EPSG:5514, sd fs f')->saveXML();