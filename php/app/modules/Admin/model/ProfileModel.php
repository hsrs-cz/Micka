<?php

namespace App\AdminModel;

use Nette;

class ProfileModel  extends \BaseModel
{
    private $appParameters;
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
                profil_names.profil_id,
                profil_names.profil_name,
                profil.profil_id
            WHERE 
                profil_names.md_standard=?
                AND profil_names.is_vis=1
                AND profil_names.edit_lite_template = ''
        ";
        $this->db->query($sql, $md_standard)->fetchPairs('profil_id','md_id');
        
    }
    
    public function getProfilNames($md_standard)
    {
        $sql = "SELECT profil_id, profil_name
                FROM profil_names
                WHERE md_standard=? AND is_vis=1 AND edit_lite_template IS NULL
                ORDER BY profil_id
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
        }
        if (count($profil_id) === 0) {
            return $profil_id;
        }
        $sql = "SELECT profil_id, md_id 
            FROM profil 
            WHERE profil_id IN (?) AND md_id IN (?)
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
        if ($this->db->fetchField('SELECT count(*) FROM profil_names WHERE profil_name=?', $name) > 0) {
            return 'Name is exists'; // TODO: report profil exists
        }
        $id = $this->db->fetchField('SELECT MAX(profil_id) FROM profil_names WHERE md_standard=?', $md_standard);
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
        $values[0]['profil_id'] = $id_md;
        $values[0]['profil_order'] = $id_md;
        $values[0]['profil_name'] = $name;
        $values[0]['md_standard'] = 0;
        $values[0]['is_vis'] = 1;
        $values[0]['is_packages'] = $packages;
        $values[0]['is_inspire'] = $inspire;
        $values[1]['profil_id'] = $id_sv;
        $values[1]['profil_order'] = $id_md;
        $values[1]['profil_name'] = $name;
        $values[1]['md_standard'] = 10;
        $values[1]['is_vis'] = 1;
        $values[1]['is_packages'] = $packages;
        $values[1]['is_inspire'] = $inspire;
        //dump($values);
        $this->db->query('INSERT INTO profil_names ?', $values);
        $this->db->query('INSERT INTO profil (profil_id, md_id, mandt_code) SELECT ?, md_id, mandt_code FROM profil WHERE profil_id=?', $id_md, $profil_id_md);
        $this->db->query('INSERT INTO profil (profil_id, md_id, mandt_code) SELECT ?, md_id, mandt_code FROM profil WHERE profil_id=?', $id_sv, $profil_id_sv);
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
            $this->db->query('DELETE FROM profil WHERE profil_id IN (?)', $profil);
            $this->db->query('DELETE FROM profil_names WHERE profil_id IN (?)', $profil);
        }
        return;
    }

    private function setMdId2Profil($profil_id, $id)
    {
        $nodes = $this->mdSchema->getParentNodes($id);
        $values = [];
        foreach ($nodes as $node) {
            if ($node->md_id > 0) {
                $value = [];
                $value['profil_id'] = $profil_id;
                $value['md_id'] = $node->md_id;
                $values[] = $value;
                $del_md_id[] = $node->md_id;
                $this->db->query('DELETE FROM profil WHERE profil_id=? AND md_id IN (?)',
                    $profil_id, $del_md_id);
                $this->db->query('INSERT INTO profil ?', $values);
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
            $this->db->query('DELETE FROM profil WHERE profil_id=? AND md_id IN (?)', 
            $profil_id, $del_md_id);
        }
        return;
    }
}
