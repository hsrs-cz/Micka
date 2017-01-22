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

$url = $_REQUEST['url'];
$purl = parse_url($url);
if($purl['scheme']=='http' || $purl['scheme']=='https'){
	$s = @file_get_contents($_REQUEST['url']);
	if($s){
	  $s = str_replace(array('\r','\n'), array(' ','<BR>'), $s);
	}
	else $s = "[]";  
	header("Content-type: application/json; charset=utf-8");
	echo '{"success":"true","results":'.$s.'}';
}
