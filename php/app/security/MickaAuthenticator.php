<?php

namespace App\Security;

use Nette,
    Nette\Security\Passwords;


class MickaAuthenticator implements Nette\Security\IAuthenticator
{
	use Nette\SmartObject;

	private $db;
    private $user = NULL;
    
	//public function __construct(\Dibi\Connection $db) 
	public function __construct($db) 
	{
		$this->db = $db;
    }
    
    public function authenticate(array $credentials)
    {
        list($username, $password) = $credentials;
        $this->user = $this->findUserByName($username);
        if ($this->user === NULL || $this->verifyPassword($password, $this->user->password) === FALSE) {
            return;
        }
        $role = [];
        $role[] = AuthorizatorFactory::ROLE_USER;
        if ($this->user->role_editor) {
            $role[] = AuthorizatorFactory::ROLE_EDITOR;
        }
        if ($this->user->role_publisher) {
            $role[] = AuthorizatorFactory::ROLE_PUBLISHER;
        }
        if ($this->user->role_admin) {
            $role[] = AuthorizatorFactory::ROLE_ADMIN;
        }
        $data = ['username' => $this->user->username];
        $userGroups = $this->getGroupsByUsername($data['username']);
        $data['groups'] = $userGroups;
        return new Nette\Security\Identity($this->user->id, $role, $data);
    }

    
    private function hashPassword($password)
    {
        return Passwords::hash($password);
    }

    private function verifyPassword($password, $hash)
    {
        return Passwords::verify($password, $hash) ? true : false;
    }
    
    private function findUserByName($username)
    {
        return $this->db->query("
            SELECT [id], RTRIM([username]) AS [username], RTRIM([password]) AS [password], [role_editor], [role_publisher], [role_admin], [groups]
            FROM users 
            WHERE [username]=%s", $username)->fetch();
    }
    
    public function getGroupsByUsername($username)
    {
        $rs = [$username => $username];
        if ($this->user && $this->user->username === $username) {
            $groups = explode(',', $this->user->groups);
            foreach ($groups as $value) {
                $rs[$value] = $value;
            }
        }
        return $rs;
    }
    
}