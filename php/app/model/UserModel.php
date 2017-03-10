<?php

namespace App\Model;

use Nette,
    Nette\Security\Passwords;


class UserModel
{
	use Nette\SmartObject;

	/** @var Nette\Database\Context */
	private $db;
    private $user = NULL;
    
	public function __construct(Nette\Database\Context $db) 
	{
		$this->db = $db;
	}
    
    private function hashPassword($password) {
        return Passwords::hash($password);
    }
    private function verifyPassword($password, $hash) {
        if (Passwords::verify($password, $hash)) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
    
    private function findUserByName($name) {
        return $this->db->query("SELECT * FROM users WHERE username=?", $name)->fetch();
    }
    
    public function getUserByName($name, $password) {
        $this->user = $this->findUserByName($name);
        if ($this->user && $this->verifyPassword($password, rtrim($this->user->password)) === FALSE) {
            $this->user = NULL;
        }
        return $this->user;
    }
    
    public function getGroupsByUsername($name) {
        $rs = [$name=>$name];
        if ($this->user && rtrim($this->user->username) == $name) {
            $groups = explode(',', $this->user->groups);
            foreach ($groups as $value) {
                $rs[$value] = $value;
            }
        }
        return $rs;
    }
    
}