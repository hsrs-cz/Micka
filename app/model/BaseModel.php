<?php

class BaseModel
{
	use Nette\SmartObject;

	/** @var Nette\Database\Context */
	protected $db;
    /** @var Nette\Security\User */
    protected $user;

	public function __construct(Nette\Database\Context $db, Nette\Security\User $user) 
	{
		$this->db = $db;
        $this->user = $user;
	}
}