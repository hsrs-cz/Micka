<?php
namespace App\AdminModel;
use Nette;


class HarvestModel extends \BaseModel
{
	public function startup()
	{
		parent::startup();
	}
    
    public function getHarvest()
    {
        $records = $this->db->query("SELECT 
                name AS id, source, type, h_interval, updated, result, handlers, period, 
                filter, create_user, active
            FROM harvest")->fetchAll();
        foreach ($records as $record) {
            foreach ($record as $key => $value) {
                $record->$key = rtrim($value);
            }
        }
        return $records;
    }
    
    public function deleteHarvestById($id)
    {
        return $this->db->query("DELETE FROM harvest WHERE name=?", $id);
    }
    
    public function updateHarvestById($id, $values)
    {
        return;
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
    
    public function add2Harvest($values)
    {
        return;
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