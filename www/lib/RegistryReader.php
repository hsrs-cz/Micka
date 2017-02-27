<?php
session_start();

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
        $this->dir = __DIR__ . '/..' ;
    }
    
    function getData($uri){
        $_uri = str_replace(array("/", ":"), array("_", "_"), $uri . '.' . $this->lang . '.json');
        $data = null;
        // 1. snazi se ze session
        if($_SESSION['regreader'][$_uri]){
            $data = $_SESSION['regreader'][$_uri];
        }
        // 2. snazi se z cache
        else{
            $data = @file_get_contents($this->dir .'/cache/' . $_uri);
            if($data){
                $data = json_decode($data,1)['result'];
                $_SESSION['regreader'][$_uri] = $data;
            }
        }
     
        // 3. nacte z URL
        if(!$data){
            require_once("cfg/cfg.php");
            $adapter = $config[$uri]["adapter"] ? $config[$uri]["adapter"].".php" : "inspireRegistry.php";
            require_once($this->dir ."/lib/".$adapter);
            $data = getRemoteData($uri, $config[$uri], $this->lang);
            
            // vyfiltruje podle konfigurace
            $d = array();
            $uri = $data['id'];
            foreach($data['result'] as $key => $row){
                if($config[$uri] && $config[$uri]['include']){
                     if(in_array($key, $config[$uri]['exclude'])) $d[$key] = $row;
                }    
                elseif($config[$uri] && $config[$uri]['exclude']){
                    if(!in_array($key, $config[$uri]['exclude'])) $d[$key] = $row;
                }
                else $d[$key] = $row;
            }
            $data = $d;
            
            // vytvoreni hierarchie
            $d = array();
            foreach ($data as $key=>$row){
                if($row['parentId']){
                    $parentId = $row['parentId'];
                    if(!$d[$parentId]){
                        $d[$parentId] = array("id"=>false);
                    }
                    $d[$parentId]['children'][$key] = $row;
                }
                else {
                    if($d[$key]){
                        $ch = $row['children'];
                        $d[$key] = $row;
                        $d['children'] = $ch;
                    }
                    else $d[$key] = $row;
                }
            }
            $data  = array();
            foreach ($d as $key=>$row){
                if($row['id']) $data[$key] = $row;
            }
            file_put_contents($this->dir .'/cache/' . $_uri, json_encode(array("id"=>$uri, "result"=>$data)));
            $_SESSION['regreader'][$_uri] = $data;
        }
        $this->data = $data;    
    }

    function flatData(){
        $result = array();
        foreach($this->data as $key=>$row){
           $result [] = $row;
           if(isset($row['children'])){
               foreach ($row['children'] as $ch){
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
                    if(strpos(strtolower($row['name']), $q)!==false){
                        $d[] = $row;
                        // prida vsechny podrizene
                        if($row['children']) foreach($row['children'] as $ch) $d[] = $ch;
                    }
                    // hleda v podrizenych
                    else {
                        $first = true;
                        if($row['children']) foreach($row['children'] as $ch){
                           if(strpos(strtolower($ch['name']), $q)!==false){
                               if($first) $d[] = $row;
                               $d[] = $ch;
                           }    
                        }
                    }
                }
                return $d;
            }
            return $this->flatData();            
        }
        else {
            $data = $this->flatData();
            if($q){
                $q = strtolower($q);
                $d = array();
                foreach($data as $row){
                    if(strpos(strtolower($row['name']), $q)!==false){
                        $d[] = $row;
                    }
                }
                return $d;
            }
            return $data;
        }
    } // end query
    
 
}
