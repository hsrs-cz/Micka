<?php

namespace App\Model;

use Nette;


class CodeListModel extends \BaseModel
{
    private $liteProfiles = array();

    public function getStandardsLabel($appLang, $all=FALSE) 
    {
        $tbl1 = $this->db->query("
			SELECT standard.[md_standard], label.[label_text]
			FROM standard INNER JOIN label ON standard.[md_standard] = label.[label_join]
            WHERE standard.[is_vis]=1 AND label.[label_type]='SD' AND label.[lang]=%s 
            ORDER BY standard.[md_standard_order]
		", $appLang)->fetchPairs();
        $tbl2 = $all
            ? $this->db->query("SELECT 99, [label_text] FROM label 
                WHERE label.[label_type]='SD' AND label.[lang]=%s AND [label_join]=99
                ", $appLang)->fetchPairs()
            : [];
        return $tbl1+$tbl2;
    }
    
    public function getLangsLabel($appLang) 
    {
        return $this->db->query("
			SELECT codelist.[codelist_domain], label.[label_text]
			FROM (label INNER JOIN codelist ON label.[label_join] = codelist.[codelist_id])
			LEFT JOIN codelist_my ON codelist.[codelist_id] = codelist_my.[codelist_id]
            WHERE label.[label_type]='CL' AND codelist.[el_id]=390 AND codelist_my.[is_vis]=1 AND label.[lang]=%s
            ORDER BY label.[label_text]
		", $appLang)->fetchPairs();
    }
    
    public function getMdProfils($appLang, $mds=0) 
    {
        $rs = array();
        $rs = $this->db->query("
                SELECT [profil_id], CASE WHEN [label_text] IS NULL THEN [profil_name] ELSE [label_text] END AS [label_text]
                FROM profil_names z LEFT JOIN (SELECT [label_join],[label_text] FROM label WHERE [lang]=%s AND [label_type]='PN') s
                ON z.[profil_id]=s.[label_join]
                WHERE [md_standard]=%i AND [is_vis]=1
            ", $appLang, $mds)->fetchPairs('profil_id', 'label_text');
        return $rs + $this->liteProfiles['titles'];
    }
    
    public function setLiteProfiles($appLang, $mds, $layoutTheme)
    {
        $dir = __DIR__ . '/lite/profiles/';
        $i = $mds == 10 ? 150 : 50;
        $tmpConfig = new Nette\DI\Config\Loader();
        /*
        $files = scandir($dir, 0);
        foreach ($files as $file) {
            if ($file == '.' || $file == '..') {
                continue;
            }
            if (file_exists($dir . $file . '/config.liteprofile.neon')) {
                $config = $tmpConfig->load($dir . $file . '/config.liteprofile.neon');
                $title = isset($config['title'][$appLang]) ? $config['title'][$appLang] : $file;
            } else {
                $title = $file;
            }
            $this->liteProfiles['profiles'][$i] =  $file;
            $this->liteProfiles['titles'][$i] =  $title;
            $i++;
        }
        */
        $file = 'default';
        if (file_exists($dir . $layoutTheme)) {
            $file = $layoutTheme;
        }
        if (file_exists($dir . $file . '/config.liteprofile.neon')) {
            $config = $tmpConfig->load($dir . $file . '/config.liteprofile.neon');
            $title = isset($config['title'][$appLang]) ? $config['title'][$appLang] : $file;
        } else {
            $title = $file;
        }
        $this->liteProfiles['profiles'][$i] =  $file;
        $this->liteProfiles['titles'][$i] =  $title;
    }

    public function isPackageProfil($mds, $profil_id)
    {
        $is_packages = 0;
        if ($mds == 0 || $mds == 10) {
            $is_packages = $this->db->query("SELECT [is_packages] FROM profil_names
                WHERE [md_standard]=%i AND [profil_id]=%i", $mds, $profil_id)->fetchSingle();
        }
        if ($is_packages == 0 || $is_packages == NULL || $is_packages == '') {
            return FALSE;
        } else {
            return TRUE;
        }
    }
    
    public function getEditLiteTemplate($mds, $profil_id)
    {
        $template = '';
        if ($mds == 0 || $mds == 10) {
            $template = $this->db->query("SELECT edit_lite_template FROM profil_names
                WHERE md_standard=? AND profil_id=?", $mds, $profil_id)->fetchSingle();
        }
        return $template;
    }
    
    public function getEditLiteProfile($profil_id)
    {
        return isset($this->liteProfiles['profiles'][$profil_id]) ? $this->liteProfiles['profiles'][$profil_id] : '';
    }

    public function getLiteProfileById($profil_id, $appLang, $layoutTheme)
    {
        $mds = $profil_id < 100 ? 0 : 10;
        $this->setLiteProfiles($appLang, $mds, $layoutTheme);
        return isset($this->liteProfiles['profiles'][$profil_id]) ? $this->liteProfiles['profiles'][$profil_id] : '';
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
            SELECT packages.[package_id], label.[label_text]
            FROM packages INNER JOIN label ON packages.[package_id]=label.[label_join]
            WHERE label.[label_type]='MB' AND packages.[md_standard]=%i AND label.[lang]=%s
            ORDER BY packages.[package_order]
        ";
        if ($pairs) {
            return $this->db->query($sql, $mds, $appLang)->fetchPairs('package_id', 'label_text');
        } else {
            return $this->db->query($sql, $mds, $appLang)->fetchAll();
        }
        return $rs;
    }

    public function getMandatory() 
    {
        return $this->db->query("SELECT * FROM mandatory ORDER BY [mandt_code]")->fetchAll();
    }

    public function getElements($md_standard)
    {
        if ($md_standard == 10) {
            $md_standard = 0;
        }
        return $this->db->query("SELECT * FROM elements WHERE [md_standard]=? ORDER BY [el_name]", $md_standard)->fetchAll();
    }

    public function getElementName($md_standard, $el_id)
    {
        if ($md_standard == 10) {
            $md_standard = 0;
        }
        return $this->db->query("SELECT el_name FROM elements WHERE [md_standard]=? AND [el_id]=?", $md_standard, $el_id)->fetchSingle();
    }
}