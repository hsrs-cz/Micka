<?php


namespace App\Model;

use Nette;


class Micka
{
    protected static $db;
    protected static $user;
    protected static $appParameters;
    protected static $dbDriver;
    protected static $mickaVersion = [
        'name' => 'Micka',
        'version' => '2020.007',
        'version_id' => 2020007,
        'revision' => '2020-02-07.01'
    ];

    public static function getMickaVersion()
    {
        return self::$mickaVersion;
    }

    public static function setDefaultParameters($db, $user, $appParameters)
    {
        self::$db = $db;
        self::$user = $user;
        self::$appParameters = $appParameters;
        self::$dbDriver = $db->config['driver'] != 'postgre'
            ? ucfirst($db->config['driver'])
            : '';
        if (self::$dbDriver != '' && isset($appParameters['initDbSession'][$db->config['driver']])) {
            foreach($appParameters['initDbSession'][$db->config['driver']] as $row) {
                self::$db->query($row);
            }
        }
    }

    /**
     * for XSLT - query to metadata
     * 
     */
    public static function getMetadata($s, $esn='summary')
    {
        $s = stripslashes($s); // FIXME - nevim, co to udela, pokud je apostrof v retezci
        $csw = new \App\Model\Csw(
            self::$db, 
            self::$user,
            self::$appParameters
        );
        $params["CONSTRAINT"] = $s;
        $params['CONSTRAINT_LANGUAGE'] = 'CQL';
        $params['TYPENAMES'] = 'gmd:MD_Metadata';
        $params['OUTPUTSCHEMA'] = "http://www.isotc211.org/2005/gmd";
        $params['SERVICE'] = 'CSW';
        $params['REQUEST'] = 'GetRecords';
        $params['VERSION'] = '2.0.2';
        $params['ISGET'] = true;
        $params['MAXRECORDS'] = 25;
        $params['ELEMENTSETNAME'] = $esn;
        $params['buffered'] = true;
        $result = $csw->run($params);
        //file_put_contents(__DIR__ . "/../../log/getMetadata".uniqid().".txt", print_r($params, true).$result);
        $dom = new \DOMDocument();
        $dom->loadXML($result);
        return $dom;
    }

    public static function getMetadataById($id, $esn='full')
    {
        if ($id == '') {
            return '';
        }
        $class = self::getClassName('App\\Model\\MdSearch');
        $export = new $class(
            self::$db, 
            self::$user,
            self::$appParameters,
            0,
            25,
            ''
        );
        $xmlstr = $export->getXmlRecords(array(), array("ID" =>"('".$id."')"));
        //file_put_contents(__DIR__ . "/../../log/getMetadataById".uniqid().".txt", print_r($params, true).$xmlstr);
        $dom = new \DOMDocument();
        $dom->loadXML($xmlstr);
        return $dom;
    }

    public static function getClassName($class)
    {
        return $class .= self::$dbDriver;
    }

}