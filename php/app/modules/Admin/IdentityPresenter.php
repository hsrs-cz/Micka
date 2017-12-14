<?php
namespace AdminModule;

use App\Model,
    Ublaboo\DataGrid\DataGrid;

/** @resource Admin */
class IdentityPresenter extends \BasePresenter
{
    private $identityModel;
    
	public function startup()
	{
		parent::startup();
        $this->identityModel = new \App\AdminModel\IdentityModel($this->context->getByType('Nette\Database\Context'), $this->user);
	}

    /** @resource Admin */
	public function handleDelete($id)
	{
        $this->identityModel->deleteUsersById($id);
        $this->flashMessage("Record $id deleted","success");
        $this->redirect(':Admin:Identity:default');
        /*
        if ($this->isAjax()) {
            $this->redrawControl('flashes');
        } else {
            $this->redirect(':Admin:Identity:default');
        }
         */
	}

    /** @resource Admin */
	public function createComponentUsersGrid($name)
	{
        $grid = new DataGrid($this, $name);
        $grid->setDataSource($this->identityModel->getUsers());
        $grid->setDefaultSort(['id' => 'ASC'], FALSE);
        $grid->setDefaultPerPage(10);
        $grid->setRefreshUrl(FALSE);
        
        $p = $this;
        // edit
        $grid->addInlineEdit()
            ->onControlAdd[] = function($container) {
                $container->addText('password', '');
                $container->addText('role_editor', '');
                $container->addText('role_publisher', '');
                $container->addText('role_admin', '');
                $container->addText('role_root', '');
                $container->addText('groups', '');
            };
        $grid->getInlineEdit()->onSetDefaults[] = function($container, $item) {
            $container->setDefaults([
                'password' => '',
                'role_editor' => $item->role_editor,
                'role_publisher' => $item->role_publisher,
                'role_admin' => $item->role_admin,
                'role_root' => $item->role_root,
                'groups' => $item->groups,
            ]);
        };
        $grid->getInlineEdit()->onSubmit[] = function($id, $values) use ($p){
            $report = $this->identityModel->updateUsersById($id, $values);
            if ($report != '') {
                $p->flashMessage($report);
                $p->redrawControl('flashes');
            } else {
                $p->flashMessage("Record was updated", 'success');
                $p->redrawControl('flashes');
                $p->redirect(':Admin:Identity:default');
            }
        };
        // add
        $grid->addInlineAdd()
            ->onControlAdd[] = function($container) {
                $container->addText('username', '');
                $container->addText('password', '');
                $container->addText('role_editor', '');
                $container->addText('role_publisher', '');
                $container->addText('role_admin', '');
                $container->addText('role_root', '');
                $container->addText('groups', '');
            };
        $grid->getInlineAdd()->onSetDefaults[] = function($container)  use ($p) {
            $container->setDefaults([
                'username' => '',
                'password' => '',
                'role_editor' => '',
                'role_publisher' => '',
                'role_admin' => '',
                'role_root' => '',
                'groups' => $p->context->parameters['app']['defaultViewGroup'],
            ]);
        };
        $grid->getInlineAdd()->onSubmit[] = function($values) use ($p) {
            $report = $this->identityModel->add2Users($values);
            if ($report != '') {
                $p->flashMessage($report);
                $p->redrawControl('flashes');
            } else {
                $p->flashMessage("Record was added", 'success');
                $p->redrawControl('flashes');
                $p->redirect(':Admin:Identity:default');
            }
            //$p->redrawControl('grid');
        };

        $grid->addColumnText('id', 'ID')
            ->setAlign('right');
        $grid->addColumnText('username', 'Username');
        $grid->addColumnText('password', 'Password');
        $grid->addColumnText('role_editor', 'Role editor');
        $grid->addColumnText('role_publisher', 'Role publisher');
        $grid->addColumnText('role_admin', 'Role admin');
        $grid->addColumnText('role_root', 'Role root');
        $grid->addColumnText('groups', 'Group');
        $grid->addAction('delete', '', 'delete!')
            ->setIcon('trash')
            ->setTitle('Delete')
            ->setClass('btn btn-xs btn-danger ajax')
            ->setConfirm('Do you really want to delete %s?', 'username');

	}


}
