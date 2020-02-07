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
        $this->userModel = new \App\Model\UserModel(
            $this->context->getByType('\Dibi\Connection'), 
            $this->user,
            $this->context->parameters
        );
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
        $user = $this->userModel->getUserByName($post['username'], $post['password']);
        if (!$user) {
            $this->flashMessage($this->translator->translate('messages.frontend.error'), 'info');
            $this->redirect(':Catalog:Sign:in');
        } else {
            $role = [];
            $role[] = AuthorizatorFactory::ROLE_USER;
            if ($user->role_editor) {
                $role[] = AuthorizatorFactory::ROLE_EDITOR;
            }
            if ($user->role_publisher) {
                $role[] = AuthorizatorFactory::ROLE_PUBLISHER;
            }
            if ($user->role_admin) {
                $role[] = AuthorizatorFactory::ROLE_ADMIN;
            }

            $data = ['username' => rtrim($user->username)];
            $userGroups = $this->userModel->getGroupsByUsername($data['username']);
            $data['groups'] = $userGroups;
            $identity = new Nette\Security\Identity($user->id, $role, $data);
            $this->user->login($identity);
            $this->redirect(':Catalog:Default:default');
        }
    }
}