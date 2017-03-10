<?php
include_once("../include/library/Uuid/Uuid.php");
$uuid = new UUID();
$uuid->generate();
echo $uuid->toRFC4122String();
