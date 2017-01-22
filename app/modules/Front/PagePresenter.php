<?php
namespace Micka\Module\Front\Presenters;

use App\Model;

/** @resource Front:Page */
class PagePresenter extends \Micka\Module\Base\Presenters\BasePresenter
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

	public function renderDefault()
	{
		
	}

}
