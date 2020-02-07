<?php
namespace CatalogModule;

use App\Model;

/** @resource Guest */
class SuggestPresenter extends \BasePresenter
{
	private $suggestModel;

	public function startup()
	{
		parent::startup();
        $this->suggestModel = new \App\Model\SuggestModel(
            $this->context->getByType('\Dibi\Connection'), 
            $this->user,
            $this->context->parameters
        );

	}

    /** @resource Guest */
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
    
    /** @resource Guest */
	public function renderMdLists()
	{
        $httpRequest =$this->context->getByType('Nette\Http\Request');
        $uri = $httpRequest->getUrl();
        define("APP_DIR", $this->context->parameters['appDir']);
        define("WEB_SCRIPTPATH", $uri->scriptPath);
        require $this->context->parameters['appDir'] . '/model/md_lists.php';
        $this->terminate();
    }
    
    /** @resource Editor */
	public function renderMdGazcli()
	{
        define("APP_DIR", $this->context->parameters['appDir']);
        require $this->context->parameters['appDir'] . '/model/md_gazcli.php';
        $this->terminate();
    }
    
    /** @resource Editor */
	public function renderMdUpload()
	{
        require $this->context->parameters['appDir'] . '/model/md_upload.php';
        $this->terminate();
    }
    
    /** @resource Editor */
	public function renderMetadata()
	{
        // direct accesss
        $params = [];
        $params['lang'] = $this->getParameter('lang');
        $params['query'] = $this->getParameter('q');
        $params['id'] = $this->getParameter('id');
        $params['res'] = $this->getParameter('res');
        $params['f'] = $this->getParameter('f');
        $params['type'] = 'title';
        
        $this->sendResponse( new \Nette\Application\Responses\JsonResponse(
            $this->suggestModel->getAnswer($params), 
            "application/json;charset=utf-8"
        ));
    }
    
    /** @resource Editor */
	public function renderMdContacts()
	{
        $this->template->mds = 'MD';
        $contactsModel = new \App\AdminModel\ContactsModel(
            $this->context->getByType('\Dibi\Connection'), 
            $this->user,
            $this->context->parameters
        );
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

    /** @resource Editor */
	public function renderFiles()
	{
        $filesModel = new \App\Model\FilesModel(
            $this->context->getByType('\Dibi\Connection'), 
            $this->user,
            $this->context->parameters
        );
        $this->sendResponse( new \Nette\Application\Responses\JsonResponse(
                $filesModel->getFiles(), 
                "application/json;charset=utf-8"
            ));
    }
    
}
