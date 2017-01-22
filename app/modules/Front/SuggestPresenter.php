<?php
namespace Micka\Module\Front\Presenters;

use App\Model;

/** @resource Front:Suggest */
class SuggestPresenter extends \Micka\Module\Base\Presenters\BasePresenter
{
	/** @var Model\MdSuggest */
	private $md;


	public function __construct(Model\MdSuggest $md)
	{
		$this->md = $md;
	}


	public function startup()
	{
		parent::startup();
        $this->md->setIdentity($this->user);
	}

	/********************* view default *********************/

    /** @resource Front:Suggest */
	public function renderDefault()
	{
        $params = [];
        $params['lang'] = $this->getParameter('lang');
        $params['creator'] = $this->getParameter('creator');
        $params['query'] = $this->getParameter('query');
        $params['type'] = $this->getParameter('type');
        $params['role'] = $this->getParameter('role');
        
        $this->sendResponse( new \Nette\Application\Responses\JsonResponse(
            $this->md->getAnswer($params), 
            "application/json;charset=utf-8"
        ));
        
	}

}
