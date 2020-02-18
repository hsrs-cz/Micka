<?php
use Tracy\Debugger;

abstract class BasePresenter extends Nette\Application\UI\Presenter
{
    /** @persistent */
    public $locale;

    /** @var \Kdyby\Translation\Translator @inject */
    public $translator;
    /** @var \Kdyby\Translation\LocaleResolver\SessionResolver  @inject */
    public $translatorSession;
    
    protected $layoutTheme;
    public $appLang;
    public $mickaSession;
    public $langCodes = [];

    public function startup()
	{
        parent::startup();
        //dump($this->context->parameters);
        $this->context->parameters['appDefaultLocale'] = $this->translator->getDefaultLocale();
        $this->context->parameters['appLocale'] = $this->translator->getLocale();
        $dir = dirname($this->getReflection()->getFileName());
        $this->layoutTheme = file_exists("$dir/templates/" . $this->context->parameters['app']['layoutTheme'] . "/Default/default.latte")
            ? $this->context->parameters['app']['layoutTheme']
            : 'default';
        $this->langCodes = $this->context->parameters['langCodes'];
        $this->appLang = isset($this->langCodes[$this->translator->getLocale()])
            ? $this->langCodes[$this->translator->getLocale()]
            : substr($this->context->parameters['app']['langs'],0,3);
        $this->context->parameters['appLang'] = $this->appLang;
        $this->mickaSession = $this->getSession('mickaSection');
        
        define("MICKA_LANG", $this->appLang);

        $url = $this->context->getByType('Nette\Http\Request')->getUrl();
        $locale = $this->translator->getDefaultLocale() == $this->translator->getLocale()
            ? ''
            : '/' . $this->translator->getLocale();
        define("MICKA_URL", $url->hostUrl . rtrim($url->basePath,'/') . $locale);
        define("CSW_URL", $url->hostUrl . rtrim($url->basePath,'/') . '/csw');
        if (isset($this->context->parameters['app']['proxy']) && $this->context->parameters['app']['proxy'] != '') {
            define("CONNECTION_PROXY", $this->context->parameters['app']['proxy']);
        } 

        $this->context->parameters['hostUrl'] = isset($this->context->parameters['app']['mickaUrl']) && $this->context->parameters['app']['mickaUrl'] != ''
            ? $this->context->parameters['app']['mickaUrl']
            : $url->hostUrl;
        //$this->context->parameters['basePath'] = rtrim($url->basePath,'/');
        $this->context->parameters['basePath'] = isset($this->context->parameters['app']['mickaUrl']) && $this->context->parameters['app']['mickaUrl'] != ''
            ? $this->context->parameters['app']['mickaUrl']
            : rtrim($url->basePath,'/');
        $this->context->parameters['locale'] = $locale;
        $this->context->parameters['cswUrl'] = strpos($url->path, '/filter/') === false
            ? $this->context->parameters['basePath'] . '/csw/'
            : $this->context->parameters['hostUrl'] . $url->path  . '/';
        if (isset($this->context->parameters['minUsernameLength']) === false) {
            $this->context->parameters['minUsernameLength'] = 2;    
        }
        if (isset($this->context->parameters['minPasswordLength']) === false) {
            $this->context->parameters['minPasswordLength'] = 5;    
        }

        \App\Model\Micka::setDefaultParameters(
            $this->context->getService('dibi.connection'), 
            $this->user,
            $this->context->parameters
        );

        if ($this->user->getAuthenticator()->isControlLogin) {
            $this->user->getAuthenticator()->controlLogin($this->getHttpRequest()); 
        } 
	}
    
    /**
     * Check authorization
     * @return void
     */
    public function checkRequirements($element)
    {
        if ($element instanceof Nette\Application\UI\MethodReflection) {
            // Check permissions for Action/handle methods
            $resource = Nette\Reflection\Method::from($this->presenter, $element->name)->getAnnotation('resource');
        } else {
            // Check permissions for presenter access
            $resource = Nette\Reflection\ClassType::from($this->presenter)->getAnnotation('resource');
        }
        if (!$this->user->isAllowed($resource)) {
            throw new Nette\Application\ForbiddenRequestException;
        }
    }
    
    /** @resource Guest */
    public function handleChangeLocale($locale)
    {
        $this->translatorSession->setLocale($locale);
        $this->redirect('this');
    }

	public function beforeRender()
	{
        $this->template->basePath = $this->context->parameters['basePath'];
        $this->template->baseUrl = $this->context->parameters['basePath'];
        $this->template->baseUri = $this->context->parameters['basePath'];
        $this->template->parameters = $this->context->parameters;
        $this->template->themePath = file_exists($this->context->parameters['wwwDir'] . DIRECTORY_SEPARATOR . 'layout' . DIRECTORY_SEPARATOR . $this->context->parameters['app']['layoutTheme'] . DIRECTORY_SEPARATOR . "micka.css")
            ? '/layout/' . $this->context->parameters['app']['layoutTheme']
            : '/layout/' . 'default';
        $this->template->layoutTheme = $this->layoutTheme;
        $this->template->appLang = $this->appLang;
        $this->template->appLang2 = $this->translator->getLocale();
        $this->template->action = $this->action;
        $this->template->navigation = [];
        $this->template->hs_initext = '';
        $this->template->edit_guest = isset($this->context->parameters['editGuest']) && $this->context->parameters['editGuest'] === true
            ? true
            : false;
        $this->template->langCodes = $this->langCodes;
        $this->template->pageTitle = isset($this->context->parameters['app']['pageTitle'][$this->appLang]) && $this->context->parameters['app']['pageTitle'][$this->appLang] != ''
            ? $this->context->parameters['app']['pageTitle'][$this->appLang]
            : 'openMicka';
	}

    /**
     * Formats layout template file names.
     * @return array
     */
    public function formatLayoutTemplateFiles()
    {
        $name = $this->getName();
        $presenter = substr($name, strrpos(':' . $name, ':'));
        $dir = dirname($this->getReflection()->getFileName());
        return array(
            "$dir/templates/$this->layoutTheme/$presenter/@layout.latte",
            "$dir/templates/$this->layoutTheme/@layout.latte"
        );
    }

    /**
     * Formats view template file names.
     * @return array
     */
    public function formatTemplateFiles()
    {

        $name = $this->getName();
        $presenter = substr($name, strrpos(':' . $name, ':'));
        $dir = dirname($this->getReflection()->getFileName());
        return array(
            "$dir/templates/$this->layoutTheme/$presenter/$this->view.latte"
        );

    }
}
