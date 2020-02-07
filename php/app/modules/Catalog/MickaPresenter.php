<?php
namespace CatalogModule;

use App\Model;

/** @resource Guest */
class MickaPresenter extends \BasePresenter
{
	public function startup()
	{
		parent::startup();
	}
    
    /** @resource Guest */
	public function renderDefault()
	{
	}

    /** @resource Guest */
	public function actionHelp()
	{
        if ($this->appLang == 'cze') {
            $this->setView('help_cze');
        } else {
            $this->setView('help_eng');
        }
	}
    
    /** @resource Guest */
	public function renderAbout()
	{
        $this->template->mickaVersion = \App\Model\Micka::getMickaVersion();
	}
    
}
