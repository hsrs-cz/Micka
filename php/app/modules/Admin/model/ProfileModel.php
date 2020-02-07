<?php

namespace App\AdminModel;

use Nette;

class ProfileModel  extends \BaseModel
{
    private $mdSchema;
    
	public function startup()
	{
		parent::startup();
	}
    
    public function setAppParameters($appParameters)
    {
        $this->appParameters = $appParameters;
    }
    
    public function setMpttModel($mdSchema)
    {
        $this->mdSchema = $mdSchema;
    }
    
    public function getProfiles($id)
    {
        $sql = "
            SELECT
                profil_names.[profil_id],
                profil_names.[profil_name],
                profil.[profil_id]
            WHERE 
                profil_names.[md_standard]=%i
                AND profil_names.[is_vis]=1
        ";
        $this->db->query($sql, $md_standard)->fetchPairs('profil_id','md_id');
        
    }
    
    public function getProfilNames($md_standard)
    {
        $sql = "SELECT [profil_id], [profil_name], [is_vis]
                FROM profil_names
                WHERE [md_standard]=%i
                ORDER BY [profil_id]
        ";
        return $this->db->query($sql, $md_standard)->fetchAll();
    }
    
    public function getProfil($md_standard, $elements)
    {
        $md_id = [];
        foreach ($elements as $row) {
            $md_id[] = $row->md_id;
        }
        $profil_names = $this->getProfilNames($md_standard);
        $profil_id = [];
        $rs = [];
        foreach ($profil_names as $row) {
            $profil_id[] = $row->profil_id;
            $rs[$row->profil_id]['name'] = rtrim($row->profil_name);
            $rs[$row->profil_id]['is_vis'] = $row->is_vis;
        }
        if (count($profil_id) === 0) {
            return $profil_id;
        }
        $sql = "SELECT [profil_id], [md_id] 
            FROM profil 
            WHERE [profil_id] IN %in AND [md_id] IN %in
        ";
        $pom = $this->db->query($sql, $profil_id, $md_id)->fetchAll();
        foreach ($pom as $row) {
            $rs[$row->profil_id]['profil'][$row->md_id] = 1;
        }
        return $rs;
    }
    
    public function setProfil($param)
    {
        list($md_standard,$profil_id, $md_id) = explode(',', $param);
        $rs = '';
        if ($profil_id > 0 && $md_id > 0) {
            $this->mdSchema->setMdStandard($md_standard);
            $change_node = $this->mdSchema->getNode((integer) $md_id);
            if (count($change_node) === 1) {
                $this->setMdId2Profil((integer) $profil_id, (integer) $md_id);
                $rs = $md_standard.','.$change_node[0]->parent_md_id;
            }
        }
        return $rs;
    }
    
    public function unsetProfil($param)
    {
        list($md_standard,$profil_id, $md_id) = explode(',', $param);
        $rs = '';
        if ($profil_id > 0 && $md_id > 0) {
            $this->mdSchema->setMdStandard($md_standard);
            $change_node = $this->mdSchema->getNode((integer) $md_id);
            if (count($change_node) === 1) {
                $this->unsetMdId2Profil($profil_id, (integer) $md_id);
                $rs = $md_standard.','.$change_node[0]->parent_md_id;
            }
        }
        return $rs;
    }

    public function cloneProfil($md_standard, $profil_id, $post)
    {
        $name = isset($post['name']) ? $post['name'] : '';
        $packages = isset($post['packages']) ? 1 : 0;
        $inspire = isset($post['inspire']) ? 1 : 0;
        $id_md = NULL;
        $id_sv = NULL;
        $profil_id_md = NULL;
        $profil_id_sv = NULL;
        if ($name == '') {
            return 'Name is NULL'; // TODO: report
        }
        if ($this->db->query('SELECT count(*) FROM profil_names WHERE [profil_name]=%s', $name)->fetchSingle() > 0) {
            return 'Name is exists'; // TODO: report profil exists
        }
        $id = $this->db->query('SELECT MAX([profil_id]) FROM profil_names WHERE [md_standard]=%i', $md_standard)->fetchSingle();
        if ($md_standard == 0) {
            $profil_id_md = $profil_id;
            $profil_id_sv = $profil_id + 100;
            $id_md = $id < 10 ? 11 : ++$id;
            $id_sv = $id_md + 100;
            if ($id_md > 99) {
                return 'Profil is FULL, max 90'; // TODO: report max 99
            }
        }
        if ($md_standard == 10) {
            $profil_id_md = $profil_id - 100;
            $profil_id_sv = $profil_id;
            $id_sv = $id < 110 ? 111 : ++$id;
            $id_md = $id_sv - 100;
            if ($id_md > 99) {
                return 'Profil is FULL, max 90'; // TODO: report max 99
            }
        }
        $values = array();
        $values['profil_id'] = $id_md;
        $values['profil_order'] = $id_md;
        $values['profil_name'] = $name;
        $values['md_standard'] = 0;
        $values['is_vis'] = 1;
        $values['is_packages'] = $packages;
        $values['is_inspire'] = $inspire;
        $this->db->query('INSERT INTO profil_names %v', $values);
        $values = array();
        $values['profil_id'] = $id_sv;
        $values['profil_order'] = $id_md;
        $values['profil_name'] = $name;
        $values['md_standard'] = 10;
        $values['is_vis'] = 1;
        $values['is_packages'] = $packages;
        $values['is_inspire'] = $inspire;
        //dump($values);
        $this->db->query('INSERT INTO profil_names %v', $values);
        $this->db->query('INSERT INTO profil ([profil_id], [md_id], [mandt_code]) SELECT %i, [md_id], [mandt_code] FROM profil WHERE [profil_id]=?', $id_md, $profil_id_md);
        $this->db->query('INSERT INTO profil ([profil_id], [md_id], [mandt_code]) SELECT %i, [md_id], [mandt_code] FROM profil WHERE [profil_id]=?', $id_sv, $profil_id_sv);
        return '';
    }
    
    public function deleteProfil($md_standard, $profil_id)
    {
        $profil = array();
        $profil[] = $profil_id;
        if ($md_standard == 0 && $profil_id > 10 && $profil_id < 100) {
            $profil[] = $profil_id + 100;
        }
        if ($md_standard == 10 && $profil_id > 110) {
            $profil[] = $profil_id - 100;
        }
        if (count($profil) === 2) {
            $this->db->query('DELETE FROM profil WHERE [profil_id] IN %in', $profil);
            $this->db->query('DELETE FROM profil_names WHERE [profil_id] IN %in', $profil);
        }
    }

    public function setVisProfil($param)
    {
        list($md_standard, $profil_id, $md_id) = explode(',', $param);
        if ($md_standard == 0 || $md_standard == 10) {
            $profil = array();
            $profil[] = $profil_id;
            if ($profil_id < 100) {
                $profil[] = $profil_id + 100;
            } else {
                $profil[] = $profil_id - 100;
            }
            if (count($profil) === 2) {
                $this->db->query('UPDATE profil_names SET [is_vis]=1 WHERE [profil_id] IN %in ', $profil);
            }
        }
        return $md_standard . ',' . $md_id;
    }

    public function unsetVisProfil($param)
    {
        list($md_standard, $profil_id, $md_id) = explode(',', $param);
        if ($md_standard == 0 || $md_standard == 10) {
            $profil = array();
            $profil[] = $profil_id;
            if ($profil_id < 100) {
                $profil[] = $profil_id + 100;
            } else {
                $profil[] = $profil_id - 100;
            }
            if (count($profil) === 2) {
                $this->db->query('UPDATE profil_names SET [is_vis]=0 WHERE [profil_id] IN %in ', $profil);
            }
        }
        return $md_standard . ',' . $md_id;
    }

    private function setMdId2Profil($profil_id, $id)
    {
        $nodes = $this->mdSchema->getParentNodes($id);
        $values = [];
        foreach ($nodes as $node) {
            if ($node->md_id > 0) {
                $values[] = array('profil_id' => $profil_id, 'md_id' => $node->md_id);
                $del_md_id[] = $node->md_id;
            }
        }
        if (count($values) > 0) {
            $this->db->query('DELETE FROM profil WHERE [profil_id]=? AND [md_id] IN %in',
                $profil_id, $del_md_id);
            foreach ($values as $value) {
                $this->db->query('INSERT INTO profil %v', $value);
            }
        }
        return;
    }
    
    private function unsetMdId2Profil($profil_id, $id)
    {
        $nodes = $this->mdSchema->getChildNodes($id);
        $del_md_id = array();
        foreach ($nodes as $node) {
            if ($node->md_id > 0) {
                $del_md_id[] = $node->md_id;
            }
        }
        if (count($del_md_id)) {
            $this->db->query('DELETE FROM profil WHERE [profil_id]=%i AND [md_id] IN %in', $profil_id, $del_md_id);
        }
        return;
    }
}
