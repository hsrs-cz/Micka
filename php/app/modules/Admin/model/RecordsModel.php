<?php
namespace App\AdminModel;
use Nette;


class RecordsModel extends \BaseModel
{
	public function startup()
	{
		parent::startup();
	}
    
    public function getMdRecords() 
    {
        return $this->db->query('SELECT 
                recno AS id, uuid, md_standard, lang, data_type, create_user, 
                create_date, last_update_user, last_update_date, edit_group,
                view_group, md_update, title, server_name, valid, prim
            FROM md')->fetchAll();
                
    }
}