<?php
namespace CatalogModule;

use Nette,
    App\Model,
    App\Security\AuthorizatorFactory;

/** @resource Catalog:Guest */
class SignPresenter extends \BasePresenter
{
	/** @var Model\UserModel */
	private $usermodel;
    
	public function __construct(Model\UserModel $usermodel)
	{
		$this->usermodel = $usermodel;
	}

	public function startup()
	{
		parent::startup();
	}

    /** @resource Catalog:Guest */
    public function actionIn()
    {
        if ($this->user->isLoggedIn()) {
            $this->redirect(':Catalog:Search:default');
        }
    }

    /** @resource Catalog:Guest */
    public function actionOut()
    {
        $this->user->logout(TRUE);
        $this->flashMessage($this->translator->translate('messages.frontend.logout'));
        $this->redirect(':Catalog:Search:default');
    }

    /** @resource Catalog:Guest */
    public function actionLogin()
    {
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        $user = $this->usermodel->getUserByName($post['username'], $post['password']);
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
            if ($user->role_root) {
                $role[] = AuthorizatorFactory::ROLE_ROOT;
            }

            $data = ['username' => rtrim($user->username)];
            $userGroups = $this->usermodel->getGroupsByUsername($data['username']);
            $data['groups'] = $userGroups;
            $identity = new Nette\Security\Identity($user->id, $role, $data);
            $this->user->login($identity);
            $this->redirect(':Catalog:Search:default');
        }
    }
}