<?php

/** @resource Admin */
class BaseAdminPresenter extends \BasePresenter
{
    public function startup()
	{
        parent::startup();
    }
    
    /**
     * Formats layout template file names.
     * @return array
     */
    public function formatLayoutTemplateFiles()
    {
        $formatLayout = $this->context->parameters['appDir']
            . DIRECTORY_SEPARATOR . 'Modules'
            . DIRECTORY_SEPARATOR . 'Catalog'
            . DIRECTORY_SEPARATOR . 'templates'
            . DIRECTORY_SEPARATOR . $this->context->parameters['app']['layoutTheme']
            . DIRECTORY_SEPARATOR . '@layout.latte';
        if (file_exists($formatLayout) === false) {
            $formatLayout = $this->context->parameters['appDir']
                . DIRECTORY_SEPARATOR . 'Modules'
                . DIRECTORY_SEPARATOR . 'Catalog'
                . DIRECTORY_SEPARATOR . 'templates'
                . DIRECTORY_SEPARATOR . 'default'
                . DIRECTORY_SEPARATOR . '@layout.latte';
        }
        return array($formatLayout);
    }

}