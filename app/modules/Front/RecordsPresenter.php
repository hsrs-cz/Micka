<?php
namespace Micka\Module\Front\Presenters;

use App\Model;

/** @resource Front:Records */
class RecordsPresenter extends \Micka\Module\Base\Presenters\BasePresenter
{
	/** @var Model\MdRepository */
	private $md;
    

	public function __construct(Model\MdRepository $md)
	{
		$this->md = $md;
	}


	public function startup()
	{
		parent::startup();
	}
    
    /** @resource Front:Records */
	public function actionDefault($id)
	{
        if ($this->getParameter('format') == 'application/xml') {
            $this->setView('MdXml');
        } else {
            if ($this->getParameter('detail') == 'full') {
                $this->setView('MdFull');
            } else {
                $this->setView('MdBasic');
            }
        }
	}

    /** @resource Front:Records */
	public function renderMdBasic($id)
	{
        $appLang = $this->getParameter('language') !== NULL
                ? $this->getParameter('language')
                : $this->appLang;
        $langCode = array_search($appLang, $this->langCodes);
        if ($langCode) {
            $this->translator->setLocale($langCode);
        }
        $request = $_REQUEST;
        $request['service'] = 'CSW';
        $request['request'] = 'GetRecordById';
        $request['version'] = '2.0.2';
        $request['id'] = $id;
        $request['language'] = $appLang;
        $request['format'] = 'text/html';
        $csw = new \Micka\Csw;
        $this->template->record = $csw->run($csw->dirtyParams($request));
        $this->template->urlParams = $this->context->getByType('Nette\Http\Request')->getQuery();
        $this->template->appLang = $appLang;
	}
    
    /** @resource Front:Records */
	public function renderMdFull($id)
	{
        $appLang = $this->getParameter('language') !== NULL
                ? $this->getParameter('language')
                : $this->appLang;
        $langCode = array_search($appLang, $this->langCodes);
        if ($langCode) {
            $this->translator->setLocale($langCode);
        }
        $md = $this->md->findMdById($id);
        if (count($md) === 0 || !$this->md->isRight2MdRecord($md[0], 'read')) {
             throw new \Nette\Application\BadRequestException;
        }
        $values = $this->md->getFullMdValues($md[0], $appLang);
        $labelEl = $this->md->getElementsLabel($md[0]->md_standard, $appLang);
        $labelCl = $this->md->getCodeListLabel($appLang);
        $data = new \App\Model\MdFull();
        $this->template->values = $data->getMdFullView($values, $labelEl, $labelCl);
        $this->template->rec = $md[0];
        $this->template->appLang = $appLang;
	}
    
    /** @resource Front:Records */
    public function renderMdXml($id)
    {
        $md = $this->md->getXmlById($id);
        if (!$md) {
            throw new \Nette\Application\BadRequestException;
        } else {
            $httpResponse = $this->context->getService('httpResponse');
            $httpResponse->setContentType('application/xml');
            echo $md->xml;
            $this->terminate();
        }
        
    }
    
    /** @resource Front:Records:Edit */
    public function renderNew() 
    {
        $this->template->mdStandard = $this->md->getStandardsLabel($this->appLang, TRUE);
        $this->template->groups = $this->user->getIdentity()->data['groups'];
        $this->template->edit_group = $this->context->parameters['app']['defaultEditGroup'];
        $this->template->view_group = $this->context->parameters['app']['defaultViewGroup'];;
        $this->template->mdLangs = $this->md->getLangsLabel($this->appLang);
    }
    
    /** @resource Front:Records:Edit */
    public function actionCancelEdit() 
    {
        $this->md->deleteEditMd();
        $this->redirect(':Front:Homepage:default');
    }
    
    /** @resource Front:Records:Edit */
    public function actionSave() 
    {
        /**
         * $post['nextblock']
         * -1: save->end edit
         * -2: save->edit
         * -19: save->validate->edit
         * -20: save->xml->edit
         * -21: save->validate->edit
         * -22: save->xml save->edit
         */
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        if (!array_key_exists('ende', $post) || $post['ende'] !== 1) {
            throw new \Nette\Application\AbortException;
        }
        $this->md->setEditMdValues($post);
        switch ($post['nextblock']) {
            case -1:
                $this->redirect(':Front:Homepage:default');
                break;
            case -2:
            case -19:
            case -20:
            case -21:
            case -22:
                $this->setView('Edit');
                break;
            default:
                break;
        }
    }
    
    /** @resource Front:Records:Edit */
    public function actionEdit($id) 
    {
        $continueAction = TRUE;
        if ($this->getParameter('ak') == 'md_lists') {
            $httpRequest =$this->context->getByType('Nette\Http\Request');
            $uri = $httpRequest->getUrl();
            define("APP_DIR", $this->context->parameters['appDir']);
            define("WEB_SCRIPTPATH", $uri->scriptPath);
            require $this->context->parameters['appDir'] . '/model/md_lists.php';
            $this->terminate();
        }
        if ($this->getParameter('ak') == 'md_gazcli') {
            define("APP_DIR", $this->context->parameters['appDir']);
            require $this->context->parameters['appDir'] . '/model/md_gazcli.php';
            $this->terminate();
        }
        if ($this->getParameter('ak') == 'md_upload') {
            require $this->context->parameters['appDir'] . '/model/md_upload.php';
            $this->terminate();
        }
        if ($this->getParameter('ak') == 'md_contacts') {
            $this->setView('Contacts');
            $continueAction = FALSE;
        }
        if ($this->getParameter('ak') == 'md_search') {
            $this->terminate();
        }
        if ($this->getParameter('ak') == 'md_fc') {
            $this->terminate();
        }
        
        if ($continueAction) {
            if($id == 'new') {
                $post = $this->context->getByType('Nette\Http\Request')->getPost();
                $id = $this->md->createNewMdRecord($post);
                $this->mickaSession->editing = rtrim($id);
                $this->redirect(':Front:Records:edit', $id);
            } else {
                if ($this->mickaSession->editing !== $id) {
                    $this->md->copyMd2EditMdById($id);
                    $this->mickaSession->editing = rtrim($id);
                }
            }
        }
    }

    /** @resource Front:Records:Edit */
    public function renderEdit($id) 
    {
        $md = $this->md->findEditMdById($id);
        if (count($md) === 1) {
            $mds = $md[0]->md_standard;
            $recno = $md[0]->recno;
            $md_langs = $md[0]->lang;
            $profil = 7;
            $package=-1;
            $md_values = $this->md->findEditMdValuesById($id);
            
            $data = new \App\Model\MdEditForm($this->context->getByType('Nette\Database\Context'));
            $data->setIdentity($this->user);
            $data->setAppParameters($this->context->parameters);
            $data->appLang = $this->appLang;
            
            $mdDataType = [];
            if ($this->context->parameters['app']['mdDataType'] != '') {
                eval('$tmp=['.$this->context->parameters['app']['mdDataType'].'];');
                foreach ($tmp as $key => $value) {
                    $mdDataType[$key] = $this->translator->translate('messages.frontend.'.$value);
                }
            }
            $this->template->record = [
                'recno'=>$recno,
                'uuid'=>$id,
                'mds'=>$mds,
                'langs'=>$md_langs,
                'hierarchy'=>'application',
                'title'=>$this->md->getMdTitle($md_values,$this->appLang)
                ];
            $this->template->dataBox = '';
            $this->template->formData = $data->getEditForm($mds, $recno, $md_langs, $profil, $package, $md_values);
            $this->template->selectPackage = $package;
            $this->template->selectProfil = $profil;
            $this->template->MdDataTypes = $mdDataType;
            $this->template->dataType = $md[0]->data_type;
            $this->template->view_group = $md[0]->view_group;
            $this->template->edit_group = $md[0]->edit_group;
            $this->template->groups = $this->user->getIdentity()->data['groups'];
            $this->template->mdControl = ($mds == 0 || $mds = 10) 
                    ? $this->md->mdControl($md[0]->pxml, $this->appLang)
                    : [];
            $this->template->profils = $this->md->getMdProfils($this->appLang,$mds);
            $this->template->packages = $this->md->getMdPackages($this->appLang, $mds, $profil);
        } else {
            throw new \Nette\Application\BadRequestException;
        }
    }
        
    /** @resource Front:Records:Edit */
    public function renderValid($id)
    {
        $md = $this->md->findMdById($id);
        if (count($md) === 0 || !$this->md->isRight2MdRecord($md[0], 'read')) {
             throw new \Nette\Application\BadRequestException;
        }
        require_once $this->context->parameters['appDir'] . '/model/validator/resources/Validator.php';
        $validator = new \Validator('gmd', $this->appLang == 'cze' ? 'cze' : 'eng');
        $validator->run($md[0]->pxml);
        $this->template->record = $validator->asHTML();
    }
    
    /** @resource Front:Records:Edit */
    public function renderClone($id)
    {
        $id = $this->md->copyMd2EditMdById($id, 'clone');
        $this->mickaSession->editing = rtrim($id);
        $this->redirect(':Front:Records:edit', $id);
    }
    
    /** @resource Front:Records:Edit */
    public function renderDelete($id)
    {
        $this->md->deleteMdById($id);
        $this->redirect(':Front:Homepage:default');
    }
    
    /** @resource Front:Records:Edit */
	public function renderContacts()
	{
        $this->md->findContacts();
        $this->template->mds = 'MD';
        $this->template->contacts = $this->md->findContacts();;
	}
    
    /** @resource Front:Records:Edit */
	public function renderContactsEdit()
	{
	}
}
