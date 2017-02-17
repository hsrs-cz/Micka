<?php

namespace App\AdminModel;

use Nette;


class ContactsModel extends \BaseModel
{
	public function startup()
	{
		parent::startup();
	}
    
    private function isRight2MdContacts($right,$contUsername,$contViewGroup,$contEditGroup)
    {
        if ($this->user->isInRole('admin')) {
            return TRUE;
        }
        if($contUsername == $this->user->getIdentity()->username) {
            return TRUE;
        }
        switch ($right) {
            case 'read':
            case 'write':
                foreach ($this->user->getIdentity()->data['groups'] as $row) {
                    if ($right == 'read' && $row == $contViewGroup) {
                        return TRUE;
                    }
                    if ($row == $contEditGroup) {
                        return TRUE;
                    }
                }
                return FALSE;
            default:
                return FALSE;
        }
    }
    
    public function findMdContacts() 
    {
        if ($this->user->isInRole('admin')) {
            return $this->db->query("SELECT *,'w' AS right FROM contacts ORDER BY tag")->fetchAll();
        }
        $contacts = $this->db->query("SELECT *,'x' AS right FROM contacts ORDER BY tag")->fetchAll();
        foreach ($contacts as $contact) {
            if($this->isRight2MdContacts('write', $contact->username, $contact->view_group, $contact->edit_group)) {
                $contact->right = 'w';
            } elseif($this->isRight2MdContacts('read', $contact->username, $contact->view_group, $contact->edit_group)) {
                $contact->right = 'r';
            }
        }
        return $contacts;
    }
    
    public function findMdContactsById($id,$right) 
    {
        $contact = $this->db->query("SELECT * FROM contacts WHERE id=? 
                        ORDER BY tag", $id)->fetch();
        if ($contact) {
            if ($this->isRight2MdContacts(
                    $right,
                    $contact->username,
                    $contact->view_group,
                    $contact->edit_group)) {
                return $contact;
            }
        }
        return NULL;
    }
    
    public function setMdContactsById($id, $data) 
    {
        if ($id == 0) {
            $this->db->query("INSERT INTO contacts", $data);
        } else {
            $contact = $this->findMdContactsById($id, 'write');
            if ($contact) {
                $this->db->query("UPDATE contacts SET ? WHERE id=?", $data, $id);
            }
        }
        return;
    }
    
    public function deleteMdContactsById($id) 
    {
        $contact = $this->findMdContactsById($id, 'write');
        if ($contact) {
            $this->db->query("DELETE FROM contacts WHERE id=?", $id);
        }
        return;
    }
}