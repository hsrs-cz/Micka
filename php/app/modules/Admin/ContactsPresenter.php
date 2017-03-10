<?php
namespace AdminModule;

use App\AdminModel;

/** @resource Catalog:Editor */
class ContactsPresenter extends \BasePresenter
{
	private $contactsModel;

	public function startup()
	{
		parent::startup();
		$this->contactsModel =  new \App\AdminModel\ContactsModel($this->context->getByType('Nette\Database\Context'), $this->user);
	}

    /** @resource Catalog:Editor */
	public function renderDefault()
	{
        $this->template->mds = 'MD';
        $this->template->contacts = $this->contactsModel->findMdContacts();
	}
    
    /** @resource Catalog:Editor */
	public function actionClone($id)
	{
        $this->redirect(':Admin:Contacts:edit', [0, 'clone'=>$id]);
    }
    
    /** @resource Catalog:Editor */
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
    
    /** @resource Catalog:Editor */
	public function actionNew()
	{
        $id = 0;
        $this->redirect(':Admin:Contacts:edit', $id);
    }
    
    /** @resource Catalog:Editor */
	public function actionSave($id)
	{
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        $this->contactsModel->setMdContactsById($id, $post);
        $this->redirect(':Admin:Contacts:default');
    }
    
    /** @resource Catalog:Editor */
	public function actionDelete($id)
	{
        //$this->terminate();
        $this->contactsModel->deleteMdContactsById($id);
        $this->redirect(':Admin:Contacts:default');
    }
}
