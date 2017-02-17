<?php
namespace AdminModule;

use App\Model,
    Ublaboo\DataGrid\DataGrid;

/** @resource Admin */
class HarvestPresenter extends \BasePresenter
{
    private $harvestModel;
    
	public function startup()
	{
		parent::startup();
        $this->harvestModel = new \App\AdminModel\HarvestModel($this->context->getByType('Nette\Database\Context'), $this->user);
	}

    /** @resource Admin */
	public function handleDelete($id)
	{
        $this->harvestModel->deleteHarvestById($id);
        $this->flashMessage("Record $id deleted","success");
        $this->redirect(':Admin:Harvest:default');
        /*
        if ($this->isAjax()) {
            $this->redrawControl('flashes');
        } else {
            $this->redirect(':Admin:Identity:default');
        }
         */
	}

    /** @resource Admin */
	public function createComponentHarvestGrid($name)
	{
        $grid = new DataGrid($this, $name);
        $grid->setDataSource($this->harvestModel->getHarvest());
        $grid->setDefaultSort(['id' => 'ASC'], FALSE);
        $grid->setDefaultPerPage(10);
        $grid->setRefreshUrl(FALSE);
        
        $p = $this;
        // edit
        $grid->addInlineEdit()
            ->onControlAdd[] = function($container) {
                $container->addText('source', '');
                $container->addText('type', '');
                $container->addText('h_interval', '');
                $container->addText('updated', '');
                $container->addText('result', '');
                $container->addText('handlers', '');
                $container->addText('period', '');
                $container->addText('filter', '');
                $container->addText('create_user', '');
                $container->addText('active', '');
            };
        $grid->getInlineEdit()->onSetDefaults[] = function($container, $item) {
            $container->setDefaults([
                'source' => $item->source,
                'type' => $item->type,
                'h_interval' => $item->h_interval,
                'updated' => $item->updated,
                'result' => $item->result,
                'handlers' => $item->handlers,
                'period' => $item->period,
                'filter' => $item->filter,
                'create_user' => $item->create_user,
                'active' => $item->active,
            ]);
        };
        $grid->getInlineEdit()->onSubmit[] = function($id, $values) use ($p){
            $report = $this->identityModel->updateHarvestById($id, $values);
            if ($report != '') {
                $p->flashMessage($report);
                $p->redrawControl('flashes');
            } else {
                $p->flashMessage("Record was updated", 'success');
                $p->redrawControl('flashes');
                $p->redirect(':Admin:Harvest:default');
            }
        };
        // add
        $grid->addInlineAdd()
            ->onControlAdd[] = function($container) {
                $container->addText('id', 'name');
                $container->addText('source', 'source');
                $container->addText('type', 'type');
                $container->addText('h_interval', 'h_interval');
                $container->addText('updated', 'updated');
                $container->addText('result', 'result');
                $container->addText('handlers', 'handlers');
                $container->addText('period', 'period');
                $container->addText('filter', 'filter');
                $container->addText('create_user', 'create_user');
                $container->addText('active', 'active');
            };
        $grid->getInlineAdd()->onSetDefaults[] = function($container) {
            $container->setDefaults([
                'id' => '',
                'source' => '',
                'type' => '',
                'h_interval' => '',
                'updated' => '',
                'result' => '',
                'handlers' => '',
                'period' => '',
                'filter' => '',
                'create_user' => '',
                'active' => '',
            ]);
        };
        $grid->getInlineAdd()->onSubmit[] = function($values) use ($p) {
            $report = $this->identityModel->add2Harvest($values);
            if ($report != '') {
                $p->flashMessage($report);
                $p->redrawControl('flashes');
            } else {
                $p->flashMessage("Record was added", 'success');
                $p->redrawControl('flashes');
                $p->redirect(':Admin:Harvest:default');
            }
            //$p->redrawControl('grid');
        };

        $grid->addColumnText('id', 'name');
        $grid->addColumnText('source', 'source');
        $grid->addColumnText('type', 'type');
        $grid->addColumnText('h_interval', 'h_interval');
        $grid->addColumnText('updated', 'updated');
        $grid->addColumnText('result', 'result');
        $grid->addColumnText('handlers', 'handlers');
        $grid->addColumnText('period', 'period');
        $grid->addColumnText('filter', 'filter');
        $grid->addColumnText('create_user', 'create_user');
        $grid->addColumnText('active', 'active');
        $grid->addAction('delete', '', 'delete!')
            ->setIcon('trash')
            ->setTitle('Delete')
            ->setClass('btn btn-xs btn-danger ajax')
            ->setConfirm('Do you really want to delete %s?', 'id');

	}


}
