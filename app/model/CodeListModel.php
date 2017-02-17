<?php

namespace App\Model;

use Nette;


class CodeListModel extends \BaseModel
{
	public function startup()
	{
		parent::startup();
	}

    public function getStandardsLabel($appLang, $all=FALSE) 
    {
        $tbl1 = $this->db->query("
			SELECT standard.md_standard, label.label_text
			FROM standard INNER JOIN label ON standard.md_standard = label.label_join
            WHERE standard.is_vis=1 AND label.label_type='SD' AND label.lang=? 
            ORDER BY standard.md_standard_order
		", $appLang)->fetchPairs();
        $tbl2 = $all
            ? $this->db->query("SELECT 99, label_text FROM label 
                WHERE label.label_type='SD' AND label.lang=? AND label_join=99
                ", $appLang)->fetchPairs()
            : [];
        return $tbl1+$tbl2;
    }
    
    public function getLangsLabel($appLang) 
    {
        return $this->db->query("
			SELECT codelist.codelist_domain, label.label_text
			FROM (label INNER JOIN codelist ON label.label_join = codelist.codelist_id)
			LEFT JOIN codelist_my ON codelist.codelist_id = codelist_my.codelist_id
            WHERE label.label_type='CL' AND codelist.el_id=390 AND codelist_my.is_vis=1 AND label.lang=?
		", $appLang)->fetchPairs();
    }
    
    public function getMdProfils($appLang, $mds=0) 
    {
        return $this->db->query("
                SELECT profil_id, CASE WHEN label_text IS NULL THEN profil_name ELSE label_text END AS label_text
                FROM profil_names z LEFT JOIN (SELECT label_join,label_text FROM label WHERE lang=? AND label_type='PN') s
                ON z.profil_id=s.label_join
                WHERE md_standard=? AND is_vis=1
            ", $appLang, $mds)->fetchPairs('profil_id', 'label_text');
    }
    
    public function isPackageProfil($mds, $profil_id) {
        $is_packages = 0;
        if ($mds == 0 || $mds == 10) {
            $is_packages = $this->db->query("SELECT is_packages FROM profil_names
                WHERE md_standard=? AND profil_id=?", $mds, $profil_id)->fetchField();
        }
        if ($is_packages == 0 || $is_packages == NULL || $is_packages == '') {
            return FALSE;
        } else {
            return TRUE;
        }
    }
    
    public function getEditLiteTemplate($mds, $profil_id) {
        $template = '';
        if ($mds == 0 || $mds == 10) {
            $template = $this->db->query("SELECT edit_lite_template FROM profil_names
                WHERE md_standard=? AND profil_id=?", $mds, $profil_id)->fetchField();
        }
        return $template;
    }
    
    public function getMdPackages($appLang, $mds, $profil_id, $pairs=FALSE) 
    {
        if (!$this->isPackageProfil($mds, $profil_id)) {
            return [];
        }
        if ($mds == 10) {
            $mds = 0;
        }
        $sql = "
            SELECT packages.package_id, label.label_text
            FROM packages INNER JOIN label ON packages.package_id=label.label_join
            WHERE label.label_type='MB' AND packages.md_standard=? AND label.lang=?
            ORDER BY packages.package_order
        ";
        if ($pairs) {
            return $this->db->query($sql, $mds, $appLang)->fetchPairs('package_id', 'label_text');
        } else {
            return $this->db->query($sql, $mds, $appLang)->fetchAll();
        }
        return $rs;
    }
}