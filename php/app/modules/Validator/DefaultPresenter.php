<?php
namespace ValidatorModule;

use App\Validator\Model,
    Nette\Utils\Finder,
    Nette\DI\Config;

/** @resource Catalog:Guest */
class DefaultPresenter extends \BasePresenter
{
    public function startup()
    {
        parent::startup();

        // add lang/*.neon to translator
        $dir = __DIR__ . DIRECTORY_SEPARATOR  . 'lang'. DIRECTORY_SEPARATOR;
        if (is_dir($dir)) {
            foreach (Finder::findFiles('*.neon')->in($dir) as $key => $file) {
                list($domain,$locale,$format) = explode('.', $file->getFilename());
                $this->translator->addResource($format, $key, $locale, $domain); 
            }
        
        }
        // load config.validator.neon
        if (file_exists(__DIR__ . '/config/config.validator.neon')) {
            $tmpConfig = new \Nette\DI\Config\Loader();
            $validator_config = $tmpConfig->load(__DIR__ . '/config/config.validator.neon');
            $this->context->parameters = $this->context->parameters + $validator_config['parameters'];
        } else {
            $this->flashMessage($this->translator->translate('validator.frontend.configError'));
        }
    }
    
    /** @resource Catalog:Guest */
	public function renderDefault()
    {
        $this->template->formDefaultUrl = $this->context->parameters['moduleValidator']['defaultUrl'];
        $this->template->pageTitle .= ': ' . $this->translator->translate('validator.frontend.title');
    }

    /** @resource Catalog:Guest */
	public function renderResult()
    {
        $data = $this->getHttpRequest()->getPost('xml');
        $url = $this->getHttpRequest()->getPost('url');
        $type = $this->getHttpRequest()->getPost('type');
        $short = $this->getHttpRequest()->getPost('short') == 'on';
        $reqLang = $this->getHttpRequest()->getCookie('GUEST_LANGUAGE_ID');
        $files = $this->getHttpRequest()->getFiles();

        if ($reqLang !== null) {
            switch ($reqLang) {
                case "cs_CZ":
                    $language = "cze";
                    break;
                default:
                    $language = "eng";
            }
        } else {
            $language = $this->appLang == 'cze' ? 'cze' : 'eng';
        }

        if (!$data) {
            if ($files['dataFile'] !== null) {
                $data = $files['dataFile']->getContents();
            }
        }

        if (!$data) {
            if ($url != '') {
                $purl = parse_url($url);
                if ($purl['scheme'] != 'http' && $purl['scheme'] != 'https') {
                    $url = "http://" . $url;
                }
                if ($type != 'gmd') {
                    if (!$purl['query']) $url .= "?";
                    if (!strpos(strtolower($url), "service=")) $url .= "&SERVICE=" . strtoupper($type);
                    if (!strpos(strtolower($url), "request=")) $url .= "&REQUEST=GetCapabilities";
                }
                try {
                    $data = file_get_contents($url);
                } catch(Exception $e){
                    $this->flashMessage($this->translator->translate('validator.frontend.urlError'));
                    $this->redirect(':Validator:Default:default');
                }    
            }
        }

        if (!$data) {
            $this->flashMessage($this->translator->translate('validator.frontend.dataError'));
            $this->redirect(':Validator:Default:default');
        }

        if ($this->getHttpRequest()->getPost('validator') == "jrc") {
            include($this->context->parameters['appDir'] . DIRECTORY_SEPARATOR . $this->context->parameters['moduleValidator']['kotePath']);
            define("JRC_VALIDATOR", $this->context->parameters['moduleValidator']['jrcValidatorPath']);
            $kote = new \Kote();
            $this->template->vypis = $kote->postFileForm(JRC_VALIDATOR, $data);
            if ($this->template->vypis === false) {
                $this->flashMessage($this->translator->translate('validator.frontend.jrcError'));
                $this->redirect(':Validator:Default:default');
            }
        } else {
            $validator = new Validator($type, $language);
            $validator->run($data);
            switch ($this->getHttpRequest()->getPost('format')) {
                case "application/json":
                    header("Content-type: application/json charset=\"utf-8\"");
                    echo $validator->asJSON();
                    $this->terminate();
                    break;
                case "application/xml":
                    header("Content-type: application/xml charset=\"utf-8\""); 
                    echo $validator->result;
                    $this->terminate();
                    break;
                case "array":
                    echo '<xmp>';
                    var_dump($validator->asArray($short)); 
                    echo '</xmp>';
                    echo '<br><br>';
                    echo '<a href="'.$this->link(':Validator:Default:form').'">Validator</a>';
                    $this->terminate();
                    break;
                default:
                    if($this->getHttpRequest()->getPost('head') != 'false'){
                        $this->template->vypis = $validator->asHTML($short);
                    }	
                    else {
                        $this->template->vypis = $validator->asHTML();		
                    }
                    break;		
            }
        }
        $this->template->pageTitle .= ': ' . $this->translator->translate('validator.frontend.title');
    }

    /**
     * Formats layout template file names.
     * @return array
     */
    public function formatLayoutTemplateFiles()
    {
        return array(
            __DIR__ . "/../Catalog/templates/$this->layoutTheme/@layout.latte"
        );
    }
}
