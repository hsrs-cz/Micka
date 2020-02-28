<?php
namespace App\AdminModel;
use Nette,
    Nette\Security\Passwords;


class IdentityModel extends \App\Model\UserModel
{
    public function getEmptyUser()
    {
        return (object) array(
            'id' => 0,
            'username' => '', 
            'role_editor' => 1,
            'role_publisher' => 0,
            'role_admin' => 0,
            'groups' => $this->appParameters['app']['defaultViewGroup']  . ',' . $this->appParameters['app']['defaultEditGroup']
        );
    }

    public function getUserById($id=0)
    {
        return $this->db->query("SELECT 
                [id], RTRIM([username]) AS [username], 
                [role_editor], [role_publisher], [role_admin],
                [groups]
            FROM users %if", $id>0, "WHERE [id]=%i", $id, "%end ORDER BY [username]")->fetchAll();
    }
    
    public function setUser($id, $post)
    {
        $id = (integer) $id;
        $values = array();
        if ($id === 0) {
            if (isset($post['username']) && mb_strlen(trim($post['username'])) < $this->appParameters['minUsernameLength']) {
                return 'username';
            } else {
                $values['username'] = trim($post['username']);
            }
            if (isset($post['passwd']) && mb_strlen(trim($post['passwd'])) < $this->appParameters['minPasswordLength']) {
                return 'password';
            } else {
                $values['password'] =  Passwords::hash(trim($post['passwd']));
            }
        }
        $values['role_editor'] = isset($post['role_editor']) ? true : false;
        $values['role_publisher'] = isset($post['role_publisher']) ? true : false;
        $values['role_admin'] = isset($post['role_admin']) ? true : false;
        $values['groups'] = $post['groups'];
        if ($id === 0 && $this->findUserByName($values['username']) !== null) {
            return 'exists';
        }
        if ($id > 0) {
            $this->updateUserById($id, $values);
        } else {
            $this->createUser($values);
        }
        return 'ok';
    }

    public function deleteUserById($id)
    {
        $user = $this->getUserById($id);
        if (count($user) === 1) {
            if ($user[0]->username !== $this->user->getIdentity()->username) {
                $this->db->query("DELETE FROM users WHERE [id]=%i", $id);
            }
        }
    }

    public function getCloneUser($id)
    {
        $user = $this->getUserById($id);
        if (count($user) === 1) {
            return (object) array(
                'id' => 0,
                'username' => '', 
                'role_editor' => $user[0]->role_editor,
                'role_publisher' => $user[0]->role_publisher,
                'role_admin' => $user[0]->role_admin,
                'groups' => $user[0]->groups
            );
        } else {
            return $this->getEmptyUser();
        }
    }
    
    public function updateUserById($id, $values)
    {
        $this->db->query('UPDATE users SET %a WHERE [id]=%i', $values, $id);
    }

    public function createUser($values)
    {
        $this->db->query("INSERT INTO users %v", $values);
    }

    public function changePassword($post)
    {
        if (isset($post['ap']) === false || isset($post['np1']) === false || isset($post['np2']) === false) {
            return 'InputDataIsNotComplete';
        }
        $post['ap'] = trim($post['ap']);
        $post['np1'] = trim($post['np1']);
        $post['np2'] = trim($post['np2']);
        if ($post['np1'] != $post['np2']) {
            return 'VerifyPassword';
        }
        if (mb_strlen($post['np1']) < $this->appParameters['minPasswordLength']) {
            return 'MinLengthPassword';
        }
        $user = $this->getUserByName($this->user->getIdentity()->username, $post['ap']);
        if ($user === null) {
            return 'CurrentPassword';
        }
        $id = $this->user->id;
        if ($id > 0 && $user->id === $id)  {
            $values = array();
            $values['password'] =  $this->hashPassword($post['np1']);
            $this->updateUserById($id, $values);
            return 'ok';
        } else {
            return 'UpdateError';
        }
    }
}