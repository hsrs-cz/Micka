<?php

function getDataByURL($url){
  $ch = curl_init ($url);
  curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
  curl_setopt($ch, CURLOPT_TIMEOUT, 20);
  curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0); // potlačena kontrola certifikátu
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

class RegistryReader{

    var $lang = null;
    var $dir;

    /*************************************************************
    * Constructor
    * 
    * @param  uri of the resource
    *************************************************************/
    function __construct($lang){
        $this->lang = $lang;
        $this->cached = 0;
        $this->dir = __DIR__ . '/..' ;
    }
    
    function getData($uri, $qstr='', $id=''){
        $lang = $this->lang;
        $_uri = str_replace(array("/", ":"), array("_", "_"), $uri . '.' . $this->lang . '.json');
        $data = null;
        require_once(__DIR__ ."/../cfg/cfg.php");
        // 1. snazi se ze session
        /*if($_SESSION['regreader'][$_uri]){
            $data = $_SESSION['regreader'][$_uri];
            $this->cached=2;
        }
        // 2. snazi se z cache
        else*/
        if(!isset($config[$uri]['nocache']) || $config[$uri]['nocache']!=true){
            $data = @file_get_contents($this->dir .'/cache/' . $_uri);
            if($data){
                $data = json_decode($data,1)['result'];
                $_SESSION['regreader'][$_uri] = $data;
                $this->cached = 1;
            }
        }
     
        // 3. nacte z URL
        if(!$data){
            $adapter = isset($config[$uri]["adapter"]) ? $config[$uri]["adapter"].".php" : "inspireRegistry.php";
            require_once($this->dir ."/lib/".$adapter);
            $data = $getRemoteData($uri, $config[$uri], $this->lang, $qstr);

            // vyfiltruje podle konfigurace
            $d = array();
            $id = $data['id'];
            foreach($data['result'] as $key => $row){
                if(isset($config[$id]) && isset($config[$id]['include'])){
                    if(in_array($key, $config[$id]['include'])) $d[$key] = $row;
                }    
                elseif(isset($config[$id]) && isset($config[$id]['exclude'])){
                    if(!in_array($key, $config[$id]['exclude'])) $d[$key] = $row;
                }
                else $d[$key] = $row;
            }
            $data = $d;
           
            // vytvoreni hierarchie
            $d = array();
            foreach ($data as $key=>$row){
                if(isset($row['parentId']) && $row['parentId']){
                    $parentId = $row['parentId'];
                    if(!isset($d[$parentId])){
                        $d[$parentId] = array("id"=>false);
                    }
                    $d[$parentId]['children'][$key] = $row;
                }
                else {
                    if(isset($d[$key])){
                        $d[$key] = $row;
                        if(isset($row['children'])){
                            $ch = $row['children'];
                            $d['children'] = $ch;
                        }
                    }
                    else $d[$key] = $row;
                }
            }
            $data  = array();
            foreach ($d as $key=>$row){
                if($row['id']) $data[$key] = $row;
            }
            //echo "<pre>";var_dump($data); die();
            if(!isset($config[$uri]['nocache']) || $config[$uri]['nocache']!=true){
                file_put_contents($this->dir .'/cache/' . $_uri, json_encode(array("id"=>$uri, "result"=>$data)));
                $_SESSION['regreader'][$_uri] = $data;
            }
        }
        $this->data = $data;    
    }

    function flatData($data){
        $result = array();
        foreach($data as $key=>$row){
            $result [] = $row;
            if(isset($row['children'])){
                $children = $row['children'];
                $row['level'] = 0;
                unset($row['children']);
                foreach ($children as $ch){
                   $ch['parentName'] = $row['text'];
                   $ch['level'] = 1;
                   $result [] = $ch;
                }
            }
        }
        return $result;    
    }

    function query($q, $deep=false){
       if($deep) {
            if($q){
                $data = $this->data;
                $q = strtolower($q);
                $d = array();
                foreach($data as $key=>$row){
                    if(strpos(strtolower($row['text']), $q)!==false){
                        $d[] = $row;
                    }
                    // hleda v podrizenych
                    else {
                        $pom = false;
                        $first = true;
                        if(isset($row['children'])) foreach($row['children'] as $ch){
                            if(strpos(strtolower($ch['text']), $q)!==false){
                                if($first){
                                    $pom = $row;
                                    unset($pom['children']);
                                    $first = false;
                                }
                                $pom['children'][] = $ch;
                            }    
                        }
                        if($pom) $d[] = $pom;
                    }
                }
                //return $d;
                return $this->flatData($d);
            }
            return $this->flatData($this->data);
        }
        else {
            $data = $this->data;
             if($q){
                $q = strtolower($q);
                $d = array();
                foreach($data as $row){
                    if(strpos(strtolower($row['text']), $q)!==false){
                        $d[] = $row;
                    }
                }
                return $d;
            }
            return $data;
        }
    } // end query
    
     function queryById($id, $deep=false){
        if($deep) {
            if($id){
                $data = $this->data;
                //$q = strtolower($q);
                $d = array();
                foreach($data as $key=>$row){
                    if($key == $id){
                        $d[] = $row;
                        // prida vsechny podrizene
                        if($row['children']) foreach($row['children'] as $ch) $d[] = $ch;
                    }
                    // hleda v podrizenych
                    else {
                        $first = true;
                        if($row['children']) foreach($row['children'] as $ch){
                           if($ch[$id]){
                               if($first) $d[] = $row;
                               $d[] = $ch;
                           }    
                        }
                    }
                }
                return $d;
            }
            return $this->flatData($this->data);
        }
        else {
            $data = $this->flatData($this->data);
            //var_dump($data);
            if($id){
                //$q = strtolower($q);
                $d = array();
                foreach($data as $row){
                    if($row['id'] == $id){
                        $d[] = $row;
                    }
                }
                return $d;
            }
            return $data;
        }        
    }
    
   function getTranslations($uri, $id){
        $qstr= ''; $lang='';
        require(__DIR__ ."/../cfg/cfg.php");
        $adapter = isset($config[$uri]["adapter"]) ? $config[$uri]["adapter"].".php" : "inspireRegistry.php";
        require($this->dir ."/lib/".$adapter);
        $data = $getTranslations($uri, $config[$uri], $this->lang, $qstr, $id);
        return $data;
    }
    
}
