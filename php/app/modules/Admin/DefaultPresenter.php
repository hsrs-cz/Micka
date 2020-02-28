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
            $i = 0;
            foreach($this->context->parameters['addModules']['admin'] as $key => $row) {
                $module = explode(':', $row);
                if (isset($module[4]) && $this->user->isInRole(strtolower($module[4]))) {
                    $this->template->addModules[$i]['module'] = ucfirst($module[0]);
                    $this->template->addModules[$i]['presenter'] = isset($module[1]) ? ucfirst($module[1]) : 'Default';
                    $this->template->addModules[$i]['action'] = isset($module[2]) ? strtolower($module[2]) : 'default';
                    $this->template->addModules[$i]['label'] = isset($module[3]) ? $module[3] : 'label';
                    $this->template->addModules[$i]['role'] = strtolower($module[4]);
                    $i++;
                }
            }
        }
    }
    
}
