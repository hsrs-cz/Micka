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
        $params['query'] = $this->getParameter('query');
        $params['type'] = $this->getParameter('type');
        $params['role'] = $this->getParameter('role');
        
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
	public function renderMdSearch()
	{
        $params = array('TEMPLATE' => 'micka2htmlList_', 'FORMAT' => 'text/html');
        if ($this->getParameter('type') == 'featureCatalogue') {
            $params['QUERY'] = "type='featureCatalogue'";
        } elseif ($this->getParameter('id') != '') {
            $params['ID'] = $this->getParameter('id');
        } else {
            $params['QUERY'] = "";
        }
        $csw = new \Micka\Csw;
        $this->template->records = $csw->run($csw->dirtyParams($params));
    }
    
    /** @resource Catalog:Editor */
	public function renderMdContacts()
	{
        $this->template->mds = 'MD';
        $contactsModel = new \App\AdminModel\ContactsModel($this->context->getByType('Nette\Database\Context'), $this->user);
        $this->template->contacts = $contactsModel->findMdContacts();
    }
    
}
