<?php
namespace Micka\Module\Front\Presenters;

use Nette,
    App\Security\AuthorizatorFactory;

/** @resource Front:Sign */
class SignPresenter extends \Micka\Module\Base\Presenters\BasePresenter
{
    public $db;
    private $row;

    function __construct(Nette\Database\Context $db)
    {
        $this->db = $db;
    }

    /** @resource Front:Sign */
    public function actionIn()
    {
        if ($this->user->isLoggedIn()) {
            $this->redirect(':Front:Homepage:default');
        }
    }

    /** @resource Front:Sign */
    public function actionOut()
    {
        $this->user->logout(TRUE);
        $this->flashMessage($this->translator->translate('messages.frontend.logout'));
        $this->redirect(':Front:Homepage:default');
    }


    public function createComponentSignInForm()
    {
        $form = new Nette\Application\UI\Form;
        $form->addText('username', $this->translator->translate('messages.frontend.name').':');
        $form->addPassword('password', $this->translator->translate('messages.frontend.passwd').':');
        $form->addSubmit('submit', 'OK');

        $form->onValidate[] = [$this, 'validateCreditians'];
        $form->onSuccess[] = [$this, 'signInFormSucceeded'];

        return $form;
    }


    public function validateCreditians($form, $values)
    {
       $this->row = $this->db->table('users')->where('username', $values->username)->fetch();

        if (!$this->row) {
            //throw new Nette\Security\AuthenticationException('User not found.');
            $form->addError($this->translator->translate('messages.frontend.error'));
        }
        if (!Nette\Security\Passwords::verify($values->password, trim($this->row->password))) {
            //throw new Nette\Security\AuthenticationException('Invalid password.');
            $form->addError($this->translator->translate('messages.frontend.error'));
        }
    }


    public function signInFormSucceeded($form, $values)
    {
        $role = array();
        $role[] = AuthorizatorFactory::ROLE_USER;
        if ($this->row->role_writer) {
            $role[] = AuthorizatorFactory::ROLE_WRITER;
        }
        if ($this->row->role_publisher) {
            $role[] = AuthorizatorFactory::ROLE_PUBLISHER;
        }
        if ($this->row->role_admin) {
            $role[] = AuthorizatorFactory::ROLE_ADMIN;
        }
        if ($this->row->role_root) {
            $role[] = AuthorizatorFactory::ROLE_ROOT;
        }
        
        $data = ['username' => $this->row->username];
        $row = $this->db->table('users_group')->where('users_id', $this->row->id)->fetchAll();
        $groups = array();
        foreach ($row as $value) {
            $groups[] = rtrim($value->group);
        }
        $data['groups'] = $groups;
        $identity = new Nette\Security\Identity($this->row->id, $role, $data);

        $this->user->login($identity);
        $this->redirect(':Front:Homepage:default');
    }

}