<?php

class BaseModel
{
	use Nette\SmartObject;

	/** @var \Dibi\Connection */
	protected $db;
    /** @var Nette\Security\User */
    protected $user;
    protected $appParameters;

	public function __construct(\Dibi\Connection $db, Nette\Security\User $user, $appParameters) 
	{
		$this->db = $db;
        $this->user = $user;
        $this->appParameters = $appParameters;
	}
}