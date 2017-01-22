<?php
namespace Micka\Module\Front\Presenters;

use App\Model;

/** @resource Front:Homepage */
class HomepagePresenter extends \Micka\Module\Base\Presenters\BasePresenter
{
	/** @var Model\MdRepository */
	private $md;
    
	public function __construct(Model\MdRepository $md)
	{
		$this->md = $md;
	}


	public function startup()
	{
		parent::startup();
	}
    
    /** @resource Front:Homepage:Default */
	public function actionHelp()
	{
        if ($this->appLang == 'cze') {
            $this->setView('help_cze');
        } else {
            $this->setView('help_eng');
        }
        
	}
    
    /** @resource Front:Homepage:Default */
	public function renderDefault()
	{   
        $request = $_REQUEST;
        $request['service'] = 'CSW';
        //$request['request'] = 'GetRecords';
        $request['version'] = '2.0.2';
        //$request['id'] = '';
        $request['language'] = $this->getParameter('language') !== NULL
                ? $this->getParameter('language')
                : $this->appLang;
        $request['format'] = 'text/html';
        $request['buffered'] = 1;
        if(isset($request['query']) === FALSE) {
            $request['query'] = '';
        }
        
        $csw = new \Micka\Csw;
        $this->template->records = $csw->run($csw->dirtyParams($request));
        $this->template->urlParams = $this->context->getByType('Nette\Http\Request')->getQuery();
        
	}

    /** @resource Front:Homepage:Default */
	public function renderAbout()
	{
	}
    
}
