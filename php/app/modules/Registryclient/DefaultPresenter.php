<?php

namespace RegistryclientModule;

/** @resource Guest */
class DefaultPresenter extends \BasePresenter
{
	public function startup()
	{
        parent::startup();
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
        
        $this->sendResponse( new \Nette\Application\Responses\JsonResponse(
            $rs, 
            "application/json;charset=utf-8"
        ));
    }
}
