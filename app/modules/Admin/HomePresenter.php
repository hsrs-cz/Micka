<?php
namespace Micka\Module\Admin\Presenters;

use App\Model;

/** @resource Admin:Homepage */
class HomepagePresenter extends \Micka\Module\Base\Presenters\BasePresenter
{
	/** @var Model\MdRepository */
	private $md;




	public function startup()
	{
		parent::startup();

	}


	/********************* view default *********************/

    /** @resource Admin:Homepage */
	public function renderDefault()
	{
	
	}

}
