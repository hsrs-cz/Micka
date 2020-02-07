<?php
namespace AdminModule;

use App\AdminModel;

/** @resource Editor */
class ContactsPresenter extends \BaseAdminPresenter
{
	private $contactsModel;

	public function startup()
	{
		parent::startup();
        $class = \App\Model\Micka::getClassName("App\\AdminModel\\ContactsModel");
        $this->contactsModel = new $class(
            $this->context->getByType('\Dibi\Connection'), 
            $this->user,
            $this->context->parameters
        );
	}

    /** @resource Editor */
	public function renderDefault()
	{
        $this->template->mds = 'MD';
        $this->template->contacts = $this->contactsModel->findMdContacts();
	}
    
    /** @resource Editor */
	public function actionClone($id)
	{
        $this->redirect(':Admin:Contacts:edit', [0, 'clone'=>$id]);
    }
    
    /** @resource Editor */
	public function renderEdit($id)
	{
        if ($this->getParameter('clone') != NULL) {
            $this->template->contact = $this->contactsModel->findMdContactsById($this->getParameter('clone'),'read');
        } else {
            $this->template->contact = $id == 0
                    ? ''
                    : $this->contactsModel->findMdContactsById($id,'write');
        }
        $this->template->groups = $this->user->getIdentity()->data['groups'];
        $this->template->id = $id;
    }
    
    /** @resource Editor */
	public function actionNew()
	{
        $id = 0;
        $this->redirect(':Admin:Contacts:edit', $id);
    }
    
    /** @resource Editor */
	public function actionSave($id)
	{
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        $this->contactsModel->setMdContactsById($id, $post);
        $this->redirect(':Admin:Contacts:default');
    }
    
    /** @resource Editor */
	public function actionDelete()
	{
        $httpRequest = $this->getHttpRequest();
        $this->contactsModel->deleteMdContactsById($httpRequest->getQuery('id'));
        $this->redirect(':Admin:Contacts:default');
    }
}
