<?php

namespace App\AdminModel;

use Nette;


class ContactsModel extends \BaseModel
{
    protected $selectUsers = "
        SELECT  [id], [person], [organisation], [organisation_en], [tag], [org_function], [org_function_en],
        RTRIM([phone]) AS [phone], RTRIM([fax]) AS [fax],
        [point], [city], [adminarea],
        RTRIM([postcode]) AS [postcode], RTRIM([country]) AS [country], RTRIM([email]) AS [email],
        [url],
        [view_group], [edit_group], [username]
    ";
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
            return $this->db->query($this->selectUsers . ",'w' AS [right] FROM contacts ORDER BY [tag]")->fetchAll();
        }
        $contacts = $this->db->query($this->selectUsers . ",'x' AS [right] FROM contacts ORDER BY [tag]")->fetchAll();
        foreach ($contacts as $contact) {
            if($this->isRight2MdContacts('write', $contact->username, $contact->view_group, $contact->edit_group)) {
                $contact->right = 'w';
            } elseif($this->isRight2MdContacts('read', $contact->username, $contact->view_group, $contact->edit_group)) {
                $contact->right = 'r';
            }
        }
        return $contacts;
    }
    
    public function findMdContactsByName($q='') 
    {
        $where = $q ? "WHERE [tag] ilike '%".$q."%'" : "";
        if ($this->user->isInRole('admin')) {
            $contacts = $this->db->query($this->selectUsers . ",'w' AS [right] FROM contacts $where ORDER BY [tag]")->fetchAll();
        }
        $contacts = $this->db->query($this->selectUsers . ",'x' AS [right] FROM contacts $where ORDER BY [tag]")->fetchAll();
        $result = array();
        foreach($contacts as $row){
            $row->text = $row->person;
            $row->title = $row->organisation.', '.$row->city;
            // temporary fix
            $row->organisation = array("cze"=>$row->organisation, "eng"=>$row->organisation_en);
            $row->org_function = array("cze"=>$row->org_function, "eng"=>$row->org_function_en);
            $result[] = $row;
        }
        return array("results" => $result);
    }

    public function findMdContactsById($id,$right) 
    {
        $contact = $this->db->query($this->selectUsers . " FROM contacts WHERE [id]=%i ORDER BY [tag]", $id)->fetch();
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
            $data['username'] = $this->user->getIdentity()->username;
            $this->createContacts($data);
        } else {
            $contact = $this->findMdContactsById($id, 'write');
            if ($contact) {
                $this->db->query("UPDATE contacts SET %a WHERE [id]=%i", $data, $id);
            }
        }
        return;
    }
    
    public function deleteMdContactsById($id) 
    {
        $id = (integer) $id;
        $contact = $this->findMdContactsById($id, 'write');
        if ($contact) {
            $this->db->query("DELETE FROM contacts WHERE [id]=%i", $id);
        }
        return;
    }

    public function createContacts($data)
    {
        $this->db->query("INSERT INTO contacts %v", $data);
    }

}