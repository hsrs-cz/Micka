<?php

namespace RegistryclientModule;

/** @resource Guest */
class DefaultPresenter extends \BasePresenter
{
	public function startup()
	{
        parent::startup();
    }

    private function getDataByURL($url)
    {
        $ch = curl_init ($url);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 20);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0); // potlacena kontorla certifikatu
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
  

    /** @resource Guest */
    public function renderDefault()
    {
        $httpRequest = $this->getHttpRequest();
        $uri = $httpRequest->getQuery('uri') !== null ? $httpRequest->getQuery('uri') : "http://inspire.ec.europa.eu/theme";
        $lang = $httpRequest->getQuery('lang') !== null ? $httpRequest->getQuery('lang') : 'en';
        $query = $httpRequest->getQuery('q') !== null ? $httpRequest->getQuery('q') : '';
        $translations = $httpRequest->getQuery('translations');
        $id = $httpRequest->getQuery('id');
        $r = new \RegistryReader($lang);
        $r->tempDir = realpath($this->context->parameters['tempDir']) . DIRECTORY_SEPARATOR . 'registry_client';

        if($translations !== null) {
            $data = $r->getTranslations($uri, $translations);
        } else {
            if ($id !== null) {
                $r->getData($uri);
                $data = $r->queryById($id);
            } else {
                $r->getData($uri, $query); 
                $data = $r->query($query, true);
            }
        }
        
        $rs = array(
            "query" => $query, 
            "cached" => $r->cached,
            "results" => $data
        );
        
        $this->sendResponse(new \Nette\Application\Responses\JsonResponse(
            $rs, 
            "application/json;charset=utf-8"
        ));
    }

    /** @resource Guest */
    public function renderProxy()
    {
        $httpRequest = $this->getHttpRequest();
        $url = $httpRequest->getQuery('url');
        $urle = $httpRequest->getQuery('urle');
        $query = $httpRequest->getQuery('query');
        $format = $httpRequest->getQuery('format');
        $encode = $urle !== null ? true : false;
        $purl = parse_url($url);
        $rs = "";
        $success = "false";
        if ($purl['scheme'] == 'http' || $purl['scheme'] == 'https') {
            foreach ($httpRequest->getQuery() as $key => $val) {
                if ($key != 'url' && $key != 'urle') {
                    if (strpos($url, '?') === false) {
                        $url .= '?';
                    } else {
                        $url .= '&';
                    }
                    if ($encode) {
                        $url .= $key . '=' . urlencode($val);
                    } else {
                        $url .= $key . '=' . $val;
                    }
                }
            }
            $rs = $this->getDataByURL($url);
            if ($rs) {
                $rs = str_replace(array('\r','\n'), array(' ','<BR>'), $rs);
                $success = "true";
            }
        }
        header("Content-type: application/json; charset=utf-8");
        //echo '{"success":'.$success.',"results":'.$rs.'}';
        echo $rs;
        $this->terminate();
    }
}
