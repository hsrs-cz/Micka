<?php
namespace App\AdminModel;
use Nette,
    Nette\Security\Passwords;


class IdentityModel extends \BaseModel
{
    private $minPasswordLength = 4;
    private $minUsernameLength = 2;
    
	public function startup()
	{
		parent::startup();
	}
    
    public function getUsers()
    {
        $records = $this->db->query("SELECT 
                id, username, '********' AS password,
                role_editor, role_publisher, role_admin, role_root,
                groups
            FROM users")->fetchAll();
        foreach ($records as $record) {
            foreach ($record as $key => $value) {
                $record->$key = rtrim($value);
            }
        }
        return $records;
    }
    
    public function deleteUsersById($id)
    {
        return $this->db->query("DELETE FROM users WHERE id=?", $id);
    }
    
    public function updateUsersById($id, $values)
    {
        foreach($values as $key => $value) {
            $value = trim($value);
            switch ($key) {
                case 'username':
                    if (mb_strlen($value) < $this->minPasswordLength) {
                        return 'error username';
                    }
                    break;
                case 'password':
                    if (mb_strlen($value) ==  0) {
                        unset($values[$key]);
                        break;
                    } elseif (mb_strlen($value) < $this->minPasswordLength) {
                        return 'error password';
                    }
                    $value = Passwords::hash($value);
                    break;
                case 'role_editor':
                case 'role_publisher':
                case 'role_admin':
                case 'role_root':
                    $value = $value == 1 ? TRUE : FALSE;
                    break;
                case 'groups':
                    if ($value == '') {
                        $value = NULL;
                    }
                    break;
                default:
                    return 'error key';
            }
            $values[$key] = $value;
        }
        $this->db->query('UPDATE users SET ? WHERE id=?', $values, $id);
        return '';
    }
    
    public function add2Users($values)
    {
        foreach($values as $key => $value) {
            $value = trim($value);
            switch ($key) {
                case 'username':
                    if (mb_strlen($value) < $this->minUsernameLength) {
                        return 'error username';
                    }
                    break;
                case 'password':
                    if (mb_strlen($value) < $this->minPasswordLength) {
                        return 'error password';
                    }
                    $value = Passwords::hash($value);
                    break;
                case 'role_editor':
                case 'role_publisher':
                case 'role_admin':
                case 'role_root':
                    $value = $value == 1 ? TRUE : FALSE;
                    break;
                case 'groups':
                    if ($value == '') {
                        $value = NULL;
                    }
                    break;
                default:
                    return 'error key';
            }
            $values[$key] = $value;
        }
        $this->db->query("INSERT INTO users", $values);
        return '';
    }
}