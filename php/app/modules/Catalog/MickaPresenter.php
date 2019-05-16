<?php
namespace CatalogModule;

use App\Model;

/** @resource Catalog:Guest */
class MickaPresenter extends \BasePresenter
{
	public function startup()
	{
		parent::startup();
	}
    
    /** @resource Catalog:Guest */
	public function renderDefault()
	{
	}

    /** @resource Catalog:Guest */
	public function actionHelp()
	{
        if ($this->appLang == 'cze') {
            $this->setView('help_cze');
        } else {
            $this->setView('help_eng');
        }
	}
    
    /** @resource Catalog:Guest */
	public function renderAbout()
	{
        $micka = new \Micka\Micka;
        $this->template->mickaVersion = $micka->getMickaVersion();
	}
    
}
