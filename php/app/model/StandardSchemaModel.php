<?php

namespace App\Model;

use Nette;
use Tracy\Debugger;


class StandardSchemaModel
{
    protected $db;
    protected $md_standard = NULL;
    protected $dataNode = NULL;

    private $sqlSelectTree = "
        SELECT 
            standard_schema.md_standard, standard_schema.md_id, standard_schema.parent_md_id, standard_schema.md_left, standard_schema.md_right, md_level, 
            standard_schema.mandt_code, standard_schema.min_nb, standard_schema.max_nb, standard_schema.button_exe, standard_schema.package_id, standard_schema.md_path, 
            standard_schema.md_path_el, standard_schema.md_mapping, standard_schema.inspire_code, standard_schema.is_uri,
            elements.el_id, elements.el_name, elements.el_short_name, elements.form_code, elements.from_codelist, 
            elements.only_value, elements.form_ignore, elements.form_pack, elements.multi_lang, elements.choice, elements.is_atrib
        FROM standard_schema INNER JOIN elements ON standard_schema.el_id=elements.el_id
    ";
    private $sqlWhereTree = '
        WHERE standard_schema.md_standard=?
            AND standard_schema.md_id=?
            AND standard_schema.md_left>=?
            AND standard_schema.md_right<=?
    ';
    private $sqlWhereTreeChilds = '
        WHERE standard_schema.md_standard=?
            AND standard_schema.md_left>=?
            AND standard_schema.md_right<=?
    ';
    private $sqlWhereTreeParents = '
        WHERE standard_schema.md_standard=?
            AND standard_schema.md_left<=?
            AND standard_schema.md_right>=?
    ';
    private $sqlWhereChilds = '
        WHERE standard_schema.md_standard=?
            AND standard_schema.parent_md_id=?
    ';
    private $sqlGetNode = '
        SELECT md_standard,md_id,parent_md_id,md_left,md_right,md_level,el_id FROM standard_schema
        WHERE md_standard=? AND md_id=?
    ';
    
    private $sqlOrder = '
        ORDER BY standard_schema.md_standard,standard_schema.md_left
    ';
    
    public function __construct($db)
    {
        $this->db = $db;
    }
    
    public function setMdStandard($md_standard)
    {
        $this->md_standard = $md_standard == 10 ? 0 : $md_standard;
    }

    public function getMdStandard($md_standard) {
        return $this->db->query('SELECT * FROM standard WHERE md_standard=?', $md_standard)->fetch();
    }

    public function getMdStandards() {
        return $this->db->query('SELECT * FROM standard ORDER BY md_standard_order')->fetchAll();
    }

    public function getTree($node)
    {
        //Debugger::log('getTree node='.$node, 'TREE');
        $rs = [];
        if ($node === NULL) {
            $rs = $this->db->query(
                $this->sqlSelectTree
                . '
                WHERE standard_schema.parent_md_id IS NULL
                ORDER BY standard_schema.md_standard
            ')->fetchAll();
        } else {
            $nodeData = $this->getNode($node);
            foreach ($nodeData as $row) {
                $rs = $this->db->query(
                        $this->sqlSelectTree
                        . $this->sqlWhereChilds 
                        . ' AND standard_schema.md_id>0'
                        . $this->sqlOrder,
                    $row->md_standard, $row->md_id
                )->fetchAll();
            }
        }
        return $rs; 
    }

    public function getNode($node) {
        if (isset($this->dataNode[$node]) === FALSE) {
            $this->dataNode[$node] = $this->db->query($this->sqlGetNode,$this->md_standard,$node)->fetchAll();
        }
        //dump($this->dataNode); exit;
        return $this->dataNode[$node];
    }

    public function getNodeFull($node) {
        return $this->db->query($this->sqlSelectTree.' WHERE standard_schema.id=?',$node)->fetchAll();
    }

    /*
    public function getIdNodeByMdid($md_standard,$md_id) {
        return $this->db->fetchField('
            SELECT id FROM standard_schema WHERE md_standard=? AND md_id=?
        ',$md_standard, $md_id);
        
    }
    */
    
    public function getParentNodes($node)
    {
        $rs = [];
        $nodeData = $this->getNode($node);
        foreach ($nodeData as $row) {
            $rs = $this->db->query(
                $this->sqlSelectTree.$this->sqlWhereTreeParents.$this->sqlOrder,
                $row->md_standard, $row->md_left, $row->md_right
            )->fetchAll();
        }
        //dump($rs); exit;
        return $rs; 
    }
    
    public function getChildNodes($node)
    {
        $rs = [];
        if ($node === NULL) {
            return $rs;
        }
        $nodeData = $this->getNode($node);
        //dump($nodeData); exit;
        foreach ($nodeData as $row) {
            $rs = $this->db->query(
                $this->sqlSelectTree.$this->sqlWhereTreeChilds,
                $row->md_standard, $row->md_left, $row->md_right
            )->fetchAll();
        }
        return $rs; 
    }
    
}