<?php
namespace ValidatorModule;

use App\Model;

/** @resource Catalog:Guest */
class DefaultPresenter extends \BasePresenter
{
	public function startup()
	{
		parent::startup();
	}
    
    /** @resource Catalog:Guest */
	public function renderForm()
	{
        
    }
    /** @resource Catalog:Guest */
	public function actionResult()
	{
        require_once $this->context->parameters['appDir'] . '/model/validator/resources/Validator.php';
        $data = $this->getHttpRequest()->getPost('xml');
        $url = $this->getHttpRequest()->getPost('url');
        $type = $this->getHttpRequest()->getPost('type');
        $short = $this->getHttpRequest()->getPost('short') == 'on';
        $reqLang = $this->getHttpRequest()->getCookie('GUEST_LANGUAGE_ID');

        if($this->getHttpRequest()->getPost('validator') == "jrc"){
            include($this->context->parameters['appDir'] . '/model/lite/resources/Kote.php');
            define("JRC_VALIDATOR","http://inspire-geoportal.ec.europa.eu/GeoportalProxyWebServices/resources/INSPIREResourceTester");
            echo Kote::postFileForm(JRC_VALIDATOR, $xml);
            $this->terminate();
        }

        switch ($reqLang){
            case "cs_CZ": $language = "cze"; break;
            default: $language = "eng";
        }

        // --- main ---
        $validator = new \Validator($type, $language);

        if(!$data){
            if($_FILES['dataFile']['tmp_name']){ 
                $data = file_get_contents($_FILES['dataFile']['tmp_name']);
            }  
        }

        if(!$data){
            $purl = parse_url($url);
            if($purl['scheme']!='http' && $purl['scheme']!='https'){
                $url = "http://".$url;
            }
            if($type!='gmd'){
                if(!$purl['query']) $url .= "?";
                if(!strpos(strtolower($url), "service=")) $url .= "&SERVICE=" . strtoupper($type);
                if(!strpos(strtolower($url), "request=")) $url .= "&REQUEST=GetCapabilities";
                //echo $url; exit;
            }

            try {
                $data = file_get_contents($url);
            } 
            catch(Exception $e){
                echo "source not found.";
                $this->terminate();
            }    
        }

        if(!$data){
            echo "Data not entered";
            echo '<br><br>';
            echo '<a href="'.$this->link(':Validator:Default:form').'">Validator</a>';
            $this->terminate();
        }
        $validator->run($data);
        switch ($this->getHttpRequest()->getPost('format')) {
            case "application/json":
                header("Content-type: application/json charset=\"utf-8\"");
                echo $validator->asJSON();
                $this->terminate();
                break;
            case "application/xml":
                header("Content-type: application/xml charset=\"utf-8\""); 
                echo $validator->result;
                $this->terminate();
                break;
            case "array":
                echo '<xmp>';
                var_dump($validator->asArray($short)); 
                echo '</xmp>';
                echo '<br><br>';
                echo '<a href="'.$this->link(':Validator:Default:form').'">Validator</a>';
                $this->terminate();
                break;
            default:
                if($this->getHttpRequest()->getPost('head') != 'false'){
                    $this->template->vypis = $validator->asHTML($short);
                }	
                else {
                    $this->template->vypis = $validator->asHTML();		
                }
                break;		
        }
	}

}
