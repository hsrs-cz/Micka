<?php
namespace CatalogModule;

use App\Model;

/** @resource Catalog:Guest */
class SuggestPresenter extends \BasePresenter
{
	/** @var Model\SuggestModel */
	private $suggestModel;


	public function __construct(Model\SuggestModel $sm)
	{
		$this->suggestModel = $sm;
	}


	public function startup()
	{
		parent::startup();
        $this->suggestModel->setIdentity($this->user);
	}

    /** @resource Catalog:Guest */
	public function renderDefault()
	{
        $params = [];
        $params['lang'] = $this->getParameter('lang');
        $params['creator'] = $this->getParameter('creator');
        $params['query'] = $this->getParameter('q');
        $params['type'] = $this->getParameter('type');
        $params['role'] = $this->getParameter('role');
        $params['id'] = $this->getParameter('id');
        
        $this->sendResponse( new \Nette\Application\Responses\JsonResponse(
            $this->suggestModel->getAnswer($params), 
            "application/json;charset=utf-8"
        ));
	}
    
    /** @resource Catalog:Editor */
	public function renderMdLists()
	{
        $httpRequest =$this->context->getByType('Nette\Http\Request');
        $uri = $httpRequest->getUrl();
        define("APP_DIR", $this->context->parameters['appDir']);
        define("WEB_SCRIPTPATH", $uri->scriptPath);
        require $this->context->parameters['appDir'] . '/model/md_lists.php';
        $this->terminate();
    }
    
    /** @resource Catalog:Editor */
	public function renderMdGazcli()
	{
        define("APP_DIR", $this->context->parameters['appDir']);
        require $this->context->parameters['appDir'] . '/model/md_gazcli.php';
        $this->terminate();
    }
    
    /** @resource Catalog:Editor */
	public function renderMdUpload()
	{
        require $this->context->parameters['appDir'] . '/model/md_upload.php';
        $this->terminate();
    }
    
    /** @resource Catalog:Editor */
	public function renderMetadata()
	{
        // direct accesss
        $params = [];
        $params['lang'] = $this->getParameter('lang');
        $params['query'] = $this->getParameter('q');
        $params['id'] = $this->getParameter('id');
        $params['res'] = $this->getParameter('res');
        $params['type'] = 'title';
        
        $this->sendResponse( new \Nette\Application\Responses\JsonResponse(
            $this->suggestModel->getAnswer($params), 
            "application/json;charset=utf-8"
        ));
        // using catalogue service 
        /*$params = array('OUTPUTSCHEMA' => 'json', 'QUERY' => '', 'ELEMENTSETNAME' => 'brief');
        if ($this->getParameter('id') != '') {
            $params['ID'] = $this->getParameter('id');
        } else {
            if ($this->getParameter('type') == 'featureCatalogue') {
                $params['QUERY'] = "type='featureCatalogue'";
            }
            if($this->getParameter('q')){
                if($params['QUERY'] !='') $params['QUERY'] .= ' AND ';
                $params['QUERY'] = "Title like '".$this->getParameter('q')."*'";
            }
        }
        $csw = new \Micka\Csw;
        $params = $csw->dirtyParams($params);
        //$this->template->records = 
        $csw->run($params);*/
    }
    
    /** @resource Catalog:Editor */
	public function renderMdContacts()
	{
        $this->template->mds = 'MD';
        $contactsModel = new \App\AdminModel\ContactsModel($this->context->getByType('Nette\Database\Context'), $this->user);
        if($this->getParameter('format')=='json'){
            $this->sendResponse( new \Nette\Application\Responses\JsonResponse(
                $contactsModel->findMdContactsByName($this->getParameter('q')), 
                "application/json;charset=utf-8"
            ));
        }
        else {
            $this->template->contacts = $contactsModel->findMdContacts();
        }
    }
    
}
