<?php
namespace AdminModule;

use App\Model;

/** @resource Admin */
class DefaultPresenter extends \BasePresenter
{
	public function startup()
	{
		parent::startup();
	}

    /** @resource Admin */
	public function renderDefault()
	{
        $this->template->addModules = array();
        if (isset($this->context->parameters['addModules']['admin']) && is_array($this->context->parameters['addModules']['admin'])) {
            foreach($this->context->parameters['addModules']['admin'] as $key => $row) {
                $module = explode(':', $row);
                $this->template->addModules[$key]['module'] = ucfirst($module[0]);
                $this->template->addModules[$key]['presenter'] = isset($module[1]) ? ucfirst($module[1]) : 'Default';
                $this->template->addModules[$key]['action'] = isset($module[2]) ? strtolower($module[2]) : 'default';
            }
        }
    }
}
