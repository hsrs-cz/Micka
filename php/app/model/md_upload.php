<?php 

foreach ($_FILES as $key=>$f){ 
    echo MICKA_URL.$f['name'];
    break;
}
