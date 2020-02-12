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
        $themeLayoutFile = $this->context->parameters['appDir']
            . DIRECTORY_SEPARATOR . 'modules'
            . DIRECTORY_SEPARATOR . 'Catalog'
            . DIRECTORY_SEPARATOR . 'templates'
            . DIRECTORY_SEPARATOR . $this->context->parameters['app']['layoutTheme']
            . DIRECTORY_SEPARATOR . '@layout.latte';
        $defaultLayoutFile = $this->context->parameters['appDir']
            . DIRECTORY_SEPARATOR . 'modules'
            . DIRECTORY_SEPARATOR . 'Catalog'
            . DIRECTORY_SEPARATOR . 'templates'
            . DIRECTORY_SEPARATOR . 'default'
            . DIRECTORY_SEPARATOR . '@layout.latte';
        if (file_exists($themeLayoutFile)) {
            return array($themeLayoutFile);
        } elseif (file_exists($defaultLayoutFile)) {
            return array($defaultLayoutFile);
        } else {
            echo "<pre>theme: $themeLayoutFile" . PHP_EOL;
            echo "default: $defaultLayoutFile</pre>";
            throw new \Nette\Application\ApplicationException("defaultLayoutFile");
        }
    }

}