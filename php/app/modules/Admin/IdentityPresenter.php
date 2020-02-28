<?php
namespace AdminModule;

/** @resource User */
class IdentityPresenter extends \BaseAdminPresenter
{
    private $identityModel;
    
	public function startup()
	{
        parent::startup();
        if (isset($this->context->parameters['minUsernameLength']) === false) {
            $this->context->parameters['minUsernameLength'] = 2;    
        }
        if (isset($this->context->parameters['minPasswordLength']) === false) {
            $this->context->parameters['minPasswordLength'] = 5;    
        }
        $class = \App\Model\Micka::getClassName("App\\AdminModel\\IdentityModel");
        $this->identityModel = new $class(
            $this->context->getService('dibi.connection'), 
            $this->user,
            $this->context->parameters
        );
    }
    
    /** @resource Admin */
    public function renderDefault()
    {
        $this->template->users = $this->identityModel->getUserById();
    }

    /** @resource Admin */
	public function actionNew()
	{
        $id = 0;
        $this->redirect(':Admin:Identity:edit', $id);
    }

    /** @resource Admin */
    public function renderEdit($id)
    {
        if ($id > 0) {
            $user = $this->identityModel->getUserById($id);
            if (count($user) === 1) {
                $this->template->editUser = $user[0];        
            } else {
                $id = -1;
            }
        } 
        if ($id == 0) {
            if ($this->getParameter('clone') != NULL) {
                $this->template->editUser = $this->identityModel->getCloneUser($this->getParameter('clone'));
            } else {
                $this->template->editUser = $this->identityModel->getEmptyUser();
            }
        } elseif ($id < 0) {
            $this->flashMessage($this->translator->translate('messages.apperror.noRecordFound'), 'info');
            $this->redirect(':Admin:Identity:default');
        }
    }

    /** @resource Admin */
    public function actionSave($id)
    {
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        $status = $this->identityModel->setUser($id, $post);
        switch ($status) {
            case 'username':
            case 'password':
            case 'exists':
                $this->flashMessage($this->translator->translate('messages.apperror.cantSaveNew')." ($status)", 'info');
                $this->redirect(':Admin:Identity:edit', $id);
            default:
                $this->redirect(':Admin:Identity:default');
                break;
        }
    }

    /** @resource Admin */
	public function actionClone($id)
	{
        $this->redirect(':Admin:Identity:edit', [0, 'clone'=>$id]);
    }

    /** @resource Admin */
    public function actionDelete($id)
    {
        $this->identityModel->deleteUserById($id);
        $this->redirect(':Admin:Identity:default');
    }

    /** @resource User */
    public function actionChangep()
    {
        $this->setView('changepasswd');
    }

    /** @resource User */
    public function actionSetp()
    {
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        $status = $this->identityModel->changePassword($post);
        switch ($status) {
            case 'ok':
                $this->flashMessage($this->translator->translate('messages.management.changePasswd') . " - OK", 'info');
                $this->redirect(':Admin:Default:default');
                break;
            default:
                $this->flashMessage($this->translator->translate('messages.apperror.cantSaveNew') . " ($status)", 'info');
                $this->redirect(':Admin:Identity:changep');
                break;
        }
        $this->redirect(':Admin:Default:default');
    }
}
