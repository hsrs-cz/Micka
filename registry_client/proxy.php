<?php
/**
 * Purpose: Proxy for Ajax calls to remote servers
 * Author: Stepan Kafka <kafka email cz>
 * Copyright: Help Service - Remote Sensing s.r.o 2011
 * URL: http://bnhelp.cz
 * Licence: GNU/LGPL v3
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
define('CONNECTION_PROXY', "cache.cgu.cz:8080"); 

  function getDataByURL($url){
      $ch = curl_init ($url);
      curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
      curl_setopt($ch, CURLOPT_TIMEOUT, 20);
      curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0); // potlaèena kontrola certifikátu
      if(defined('CONNECTION_PROXY')){
          $proxy = CONNECTION_PROXY;
          if(defined('CONNECTION_PORT')) $proxy .= ':'. CONNECTION_PORT;
          curl_setopt($ch, CURLOPT_PROXY, $proxy);
      }
      curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
      $data = curl_exec ($ch);
      //var_dump(curl_getinfo($ch));
      curl_close ($ch);
      return $data;
  }

$url = $_REQUEST['url'];
$purl = parse_url($url);
if($purl['scheme']=='http' || $purl['scheme']=='https'){
    foreach($_GET as $key => $val){
        if($key != 'url'){
            if(strpos($url, '?')===false) $url .= '?'; else $url .= '&';
            $url .= $key.'='.$val;
        }
    }
	$s = getDataByURL($url);
	if($s){
	  $s = str_replace(array('\r','\n'), array(' ','<BR>'), $s);
      $success = "true";
	}
	else {
        $s = "[]";
        $success = "false";
    }      
	header("Content-type: application/json; charset=utf-8");
	//echo '{"success":'.$success.',"results":'.$s.'}';
    echo $s;
}
