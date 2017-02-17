<?php
namespace AdminModule;

use App\AdminModel;
use Ublaboo\DataGrid\DataGrid;

/** @resource Admin */
class RecordsPresenter extends \BasePresenter
{
	public function startup()
	{
		parent::startup();

	}

    /** @resource Admin */
	public function renderDefault()
	{
	
	}
    
    /** @resource Admin */
	public function handleMact()
	{
	
	}
    
    /** @resource Admin */
	public function createComponentMdGrid($name)
	{
        $grid = new DataGrid($this, $name);
        
        $recordsModel = new \App\AdminModel\RecordsModel($this->context->getByType('Nette\Database\Context'), $this->user);

        $grid->setDataSource($recordsModel->getMdRecords());
        $grid->setDefaultSort(['id' => 'ASC'], FALSE);
        $grid->setDefaultPerPage(10);
        $grid->setRefreshUrl(FALSE);
        
        $grid->addColumnText('id', 'RecNo');
        $grid->addColumnText('uuid', 'UUID');
        $grid->addColumnText('md_standard', 'Standard')
            ->setReplacement([0 => 'MD', 1 => 'DC', 2 => 'FC', 10 => 'MS']);
        $grid->addColumnText('data_type', 'State')
            ->setReplacement([-1 => 'Semifinished', 0 => 'Private', 1 => 'Public', 2 => 'Portal']);
        $grid->addColumnText('lang', 'Langs');
        $grid->addColumnText('title', 'Title');
        $grid->addColumnText('create_date', 'Create date');
        $grid->addColumnText('create_user', 'Create user');
        $grid->addColumnText('view_group', 'Read group');
        $grid->addColumnText('edit_group', 'Edit group');
        $grid->addColumnText('last_update_date', 'Last update');
        $grid->addColumnText('last_update_user', 'Last update');
        $grid->addColumnText('server_name', 'Server name');
        $grid->addColumnText('valid', 'Valid');
        $grid->addColumnText('prim', 'Primary');
        $grid->addMultiAction('multi_action', 'Action')
            ->addAction('xml', 'XML', 'mact!', ['uuid'])
            ->addAction('basic', 'Basic MD', 'mact!', ['uuid'])
            ->addAction('full', 'Full MD', 'mact!', ['uuid'])
            ->addAction('valid', 'Valid', 'mact!', ['uuid'])
            ->addAction('edit', 'Edit', 'mact!', ['uuid'])
            ->addAction('delete', 'Delete', 'mact!', ['uuid']);
        $grid->getAction('multi_action')->getAction('delete')
            ->setConfirm('Do you really want to delete example %s?', 'uuid');
	}

}
