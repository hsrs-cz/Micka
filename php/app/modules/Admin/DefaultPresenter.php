<?php
namespace AdminModule;

use App\Model,
    Nette\Utils\Finder;

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
                
                // add Module/lang/*.neon to translator
                $dir = __DIR__ . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . ucfirst($module[0]) . DIRECTORY_SEPARATOR . 'lang'. DIRECTORY_SEPARATOR;
                if (is_dir($dir)) {
                    foreach (Finder::findFiles('*.neon')->in($dir) as $key => $file) {
                        list($domain,$locale,$format) = explode('.', $file->getFilename());
                        $this->translator->addResource($format, $key, $locale, $domain); 
                    }
                }
            }
        }
    }
}
