<?php


namespace ErrorModule;

use Nette;


class AppErrorPresenter extends Nette\Application\UI\Presenter
{

	public function startup()
	{
		parent::startup();
		if (!$this->getRequest()->isMethod(Nette\Application\Request::FORWARD)) {
			$this->error();
		}
	}


	public function renderDefault(Nette\Application\ApplicationException $exception)
	{
        $this->template->errorMessage = $exception->getMessage();
        $this->template->setFile(__DIR__ . "/templates/Error/appError.latte");
	}

}
