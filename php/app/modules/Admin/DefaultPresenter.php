<?php
namespace AdminModule;

use App\Model,
    Nette\Utils\Finder;

/** @resource User */
class DefaultPresenter extends \BaseAdminPresenter
{
	public function startup()
	{
		parent::startup();
	}

    /** @resource User */
	public function renderDefault()
	{
        $this->template->addModules = array();
        if (isset($this->context->parameters['addModules']['admin']) && is_array($this->context->parameters['addModules']['admin'])) {
            foreach($this->context->parameters['addModules']['admin'] as $key => $row) {
                $module = explode(':', $row);
                $this->template->addModules[$key]['module'] = ucfirst($module[0]);
                $this->template->addModules[$key]['presenter'] = isset($module[1]) ? ucfirst($module[1]) : 'Default';
                $this->template->addModules[$key]['action'] = isset($module[2]) ? strtolower($module[2]) : 'default';
                $this->template->addModules[$key]['label'] = isset($module[3]) ? strtolower($module[3]) : 'label';
                $this->template->addModules[$key]['role'] = isset($module[4]) ? strtolower($module[4]) : 'admin';
            }
        }
    }
    
}
