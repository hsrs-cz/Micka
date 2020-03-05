<?php

namespace App\Model;

use Nette,
    Nette\Security\Passwords;


class UserModel extends \BaseModel
{
	use Nette\SmartObject;

    protected function hashPassword($password)
    {
        return Passwords::hash($password);
    }

    protected function verifyPassword($password, $hash)
    {
        if (Passwords::verify($password, $hash)) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
    
    protected function findUserByName($name)
    {
        return $this->db->query("SELECT 
            [id], RTRIM([username]) AS [username], RTRIM([password]) AS [password],
            [role_editor], [role_publisher], [role_admin],
            [groups]
        FROM users WHERE [username]=%s", $name)->fetch();

    }
    
    public function getUserByName($name, $password)
    {
        $this->user = $this->findUserByName($name);
        if ($this->user && $this->verifyPassword($password, $this->user->password) === FALSE) {
            $this->user = NULL;
        }
        return $this->user;
    }
    
    public function getGroupsByUsername($name)
    {
        $rs = [$name=>$name];
        if ($this->user && $this->user->username == $name) {
            $groups = explode(',', $this->user->groups);
            foreach ($groups as $value) {
                $rs[$value] = $value;
            }
        }
        return $rs;
    }
    
}