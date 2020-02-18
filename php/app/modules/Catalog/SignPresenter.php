<?php
namespace CatalogModule;

use Nette,
    App\Model,
    App\Security\AuthorizatorFactory;

/** @resource Guest */
class SignPresenter extends \BasePresenter
{
	private $userModel;
    
	public function startup()
	{
        parent::startup();
        //$contactsModel = $this->context->getService('authenticator');
        /*
        $this->userModel = new \App\Model\UserModel(
            $this->context->getService('dibi.connection'), 
            $this->user,
            $this->context->parameters
        );
        */
	}

    /** @resource Guest */
    public function actionIn()
    {
        if ($this->user->isLoggedIn()) {
            $this->redirect(':Catalog:Default:default');
        }
    }

    /** @resource Guest */
    public function actionOut()
    {
        $this->user->logout(TRUE);
        $this->flashMessage($this->translator->translate('messages.frontend.logout'));
        $this->redirect(':Catalog:Default:default');
    }

    /** @resource Guest */
    public function actionLogin()
    {
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        if (isset($post['username']) === false || isset($post['password']) === false) {
            $this->flashMessage($this->translator->translate('default.flash.login_error'), 'info');
            $this->redirect(':Catalog:Sign:in');
        }
        $this->getUser()->login($post['username'], $post['password']);
        if ($this->user->getId() === null) {
            $this->user->logout(true);
            $this->flashMessage($this->translator->translate('default.flash.login_error'), 'info');
            $this->redirect(':Catalog:Sign:in');
        } else {
            $this->redirect(':Catalog:Default:default');
        }
    }
}