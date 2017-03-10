<?php
namespace CatalogModule;

use App\Model;

/** @resource Catalog:Guest */
class SearchPresenter extends \BasePresenter
{
	public function startup()
	{
		parent::startup();
	}
    
    /** @resource Catalog:Guest */
	public function renderDefault()
	{
        $request = $this->context->getByType('Nette\Http\Request')->getQuery();
        if (isset($request['query']) === FALSE && $this->mickaSession->searchQuery !== NULL) {
            $this->redirect(':Catalog:Search:default', $this->mickaSession->searchQuery);
        } elseif (isset($request['query'])) {
            $this->mickaSession->searchQuery = $request;
        }
        $request['service'] = 'CSW';
        $request['version'] = '2.0.2';
        $request['language'] = $this->getParameter('language') !== NULL
                ? $this->getParameter('language')
                : $this->appLang;
        $request['format'] = 'text/html';
        $request['buffered'] = 1;
        if(isset($request['query']) === FALSE) {
            $request['query'] = '';
        }
        
        $csw = new \Micka\Csw;
        $params = $csw->dirtyParams($request);
        $this->template->records = $csw->run($params);
        $this->template->urlParams = $this->context->getByType('Nette\Http\Request')->getQuery();
        
        // set values for the search form
        //$this->template->params = $params;
        
	}

}
