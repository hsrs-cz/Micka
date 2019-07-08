<?php
namespace CatalogModule;

use App\Model,
    App\Security\AuthorizatorFactory;

/** @resource Catalog:Guest */
class CswPresenter extends \BasePresenter
{
	/** @var Model\CswModel */
	private $csw;

	public function __construct(Model\CswModel $csw)
	{
		$this->csw = $csw;
	}


	public function startup()
	{
		parent::startup();
        $this->csw->setIdentity($this->user);
	}

	/********************* view default *********************/

    /** @resource Catalog:Guest */
	public function actionDefault()
	{
        $csw = new \Micka\Csw;

        // pokud jsou entity
        $params=array();
        if($_SERVER['QUERY_STRING']){
            $input = explode("&", html_entity_decode($_SERVER['QUERY_STRING']));
            foreach($input as $pair){
                $kw = explode("=",$pair);
                $params[strtoupper($kw[0])] = htmlspecialchars($kw[1]);
            }
        }

        if (isset($_SERVER['PHP_AUTH_USER'])) {
            $params['user'] = $_SERVER['PHP_AUTH_USER'];
            $params['pwd']  = $_SERVER['PHP_AUTH_PW'];
            
            $usermodel = new Model\UserModel($this->context->getByType('Nette\Database\Context'));
            $user = $usermodel->getUserByName($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']);
            if (!$user) {
                \Tracy\Debugger::log('usr: '.$_SERVER['PHP_AUTH_USER'],'login_err');
            } else {
                $role = [];
                $role[] = AuthorizatorFactory::ROLE_USER;
                if ($user->role_editor) {
                    $role[] = AuthorizatorFactory::ROLE_EDITOR;
                }
                if ($user->role_publisher) {
                    $role[] = AuthorizatorFactory::ROLE_PUBLISHER;
                }
                if ($user->role_admin) {
                    $role[] = AuthorizatorFactory::ROLE_ADMIN;
                }
                if ($user->role_root) {
                    $role[] = AuthorizatorFactory::ROLE_ROOT;
                }
                $data = ['username' => rtrim($user->username)];
                $userGroups = $usermodel->getGroupsByUsername($data['username']);
                $data['groups'] = $userGroups;
                $identity = new \Nette\Security\Identity($user->id, $role, $data);
                $this->user->login($identity);
                $this->csw->setIdentity($this->user);
            }
        }

        if(isset($_REQUEST) && isset($_REQUEST['url']) && $_REQUEST['url']){
            echo $csw->getDataFromURL($_REQUEST['url']);
            exit; 
        }
        else{
            if(!isset($params['OUTPUTSCHEMA'])) $params['OUTPUTSCHEMA']="http://www.isotc211.org/2005/gmd"; //TODO docasne, pak nezavisle
            $params = $csw->dirtyParams($params);
        }


        // FIXME docany kvuli zpetne kompatibilite
        //$params['LANGUAGE'] = $params['LANG'];
        //var_dump($params); die;
        $result = $csw->run($params);
        $csw->setHeader();
        echo $result;
        $this->terminate();
	}

    /** @resource Catalog:Guest */
	public function actionAll()
	{
        $csw = new \Micka\Csw;

        $params = array();
        $params['SERVICE'] = 'CSW';
        $params['VERSION'] = '2.0.2';
        $params['CONSTRAINT_LANGUAGE'] = 'CQL_TEXT';
        $params['CONSTRAINT'] = "type=service or type=dataset or type=series";
        $params['FORMAT'] = 'text/html';
        $params['REQUEST'] = 'GetRecords';
        $params['MAXRECORDS'] = 100;
        $params['TEMPLATE'] = 'report-all';
        $params['TYPENAMES'] = 'gmd:MD_Metadata';
        $params['STARTPOSITION'] = htmlspecialchars($_GET['start']);
        $params['LANGUAGE'] = htmlspecialchars($_GET['LANG']);
        $params['DEBUG'] = 0;

        $result = $csw->run($params);
        $csw->setHeader();
        echo $result;
        $this->terminate();
	}
    
    /** @resource Catalog:Guest */
	public function actionAtomlist()
	{
        echo '<?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:georss="http://www.georss.org/georss">
            <entry>
                <id>http://dev.bnhelp.cz/projects/corine/corine2012.zip</id>
                <link rel="alternate" href="http://dev.bnhelp.cz/projects/corine/corine2012.zip" title="SHP" type="application/x-shapefile"/>
                <summary type="html"><![CDATA[KML pokus (64 MB)]]></summary>
                <title>KML</title>
                <updated>2014-11-11T00:00:00</updated>
                <georss:polygon>12.09 48.55 12.09 51.05 18.86 51.05 18.86 48.55 12.09 48.55</georss:polygon>
            </entry>
            <entry>
                <id>http://dev.bnhelp.cz/projects/corine/corine2012gml.zip</id>
                <link rel="alternate" href="http://dev.bnhelp.cz/projects/corine/corine2012gml.zip" title="GML" type="application/gml+xml"/>
                <summary type="html"><![CDATA[GML ETRS89 (100 MB)]]></summary>
                <title>Další pokus</title>
                <updated>2014-11-11T00:00:00</updated>
                <georss:polygon>12.09 48.55 12.09 51.05 18.86 51.05 18.86 48.55 12.09 48.55</georss:polygon>
            </entry>
            <entry>
                <id>http://dev.bnhelp.cz/projects/corine/corine2012gml.zip</id>
                <link rel="alternate" href="http://dev.bnhelp.cz/projects/corine/corine2012gml.zip" title="GML" type="application/gml+xml"/>
                <summary type="html"><![CDATA[GML ETRS89 (100 MB)]]></summary>
                <title>A ještě ěden</title>
                <updated>2014-11-11T00:00:00</updated>
                <georss:polygon>12.09 48.55 12.09 51.05 18.86 51.05 18.86 48.55 12.09 48.55</georss:polygon>
            </entry>
        </feed>';
        $this->terminate();
    }
    
    /** @resource Catalog:Guest */
	public function renderFilter($id)
	{
        $cswFilters = isset($this->context->parameters['csw']) ? $this->context->parameters['csw'] : array();
        if (count($cswFilters) > 0) {
            if (array_key_exists($id, $cswFilters)) {
                $params = $this->getParameters();
                $params['service'] = array_key_exists('service', $params) ? $params['service'] : 'CSW';
                $params['version'] = array_key_exists('version', $params) ? $params['version'] : '2.0.2';
                $params['language'] = array_key_exists('language', $params) ? $params['language'] : $this->appLang;
                $params['format'] = array_key_exists('format', $params) ? $params['format'] : 'text/html';
                $params['buffered'] = array_key_exists('buffered', $params) ? $params['buffered'] : 1;
                $params['query'] = array_key_exists('query', $params) ? $params['query'] : '';
                $csw = new \Micka\Csw("", $cswFilters[$id]);
                $result = $csw->run($params);
                $csw->setHeader();
                echo $result;
                $this->terminate();
            }
        }
        throw new \Nette\Application\BadRequestException(404);
        $this->terminate();
    }
    
    /** @resource Catalog:Guest */
	public function actionInspire()
	{
        $csw = new \Micka\Csw("", "_FORINSPIRE_=1"); //TODO do konfigurace

        // pokud jsou entity
        $params=array();
        if($_SERVER['QUERY_STRING']){
            $input = explode("&", html_entity_decode($_SERVER['QUERY_STRING']));
            foreach($input as $pair){
                $kw = explode("=",$pair);
                $params[$kw[0]] = htmlspecialchars($kw[1]);
            }
        }

        if (isset($_SERVER['PHP_AUTH_USER'])) {
          $_REQUEST['user'] = $_SERVER['PHP_AUTH_USER'];
          $_REQUEST['pwd']  = $_SERVER['PHP_AUTH_PW']; 
        }

        // hack kvuli primemu pristupu pro CENIA
        if($_POST['query']){ 
            $params['query'] = $_POST['query'];
            $params = $_POST;
            $params['start']++; 
            if(!$_REQUEST['user']) $_REQUEST['user'] = 'guest'; 
        }
        echo $csw->run($params);
        $this->terminate();
	}
    
    /** @resource Catalog:Guest */
	public function actionOai()
	{
        $csw = new \Micka\Csw("", "_FORINSPIRE_=1"); //TODO do konfigurace
        
        $csw->headers[] = "Content-type: application/xml";
        // --- zpracovani parametru ---
        $input = array();
        while(list($key,$val)=each($_GET)){
          $input[strtolower($key)] = htmlspecialchars(strtolower($val));
        }

        if($input['resumptiontoken']){ 
            $rt = explode("|", $input['resumptiontoken']);
            $input['verb'] = $rt[0];
            $input['set'] = $rt[1];
            $input['from'] = $rt[2];
            $input['until'] = $rt[3];
            $input['metadataprefix'] = $rt[4];
            $input['start'] = $rt[5];
        }

        if(!$input['from']) $input['from'] = "1900-01-01";

        // --- zpracovani metadataPrefix
        $csw->params['OUTPUTSCHEMA'] = $csw->schemas[$input['metadataprefix']];

        if(!$csw->params['OUTPUTSCHEMA']){
            error('cannotDisseminateFormat','he metadata format identified by the value given for the "metadataPrefix" argument is not supported by the item or by the repository');
            exit;
        }

        $csw->params['QSTR'] = array();
        $csw->params['REQUEST'] = 'GetRecords'; 

        switch ($input['verb']){
            case 'listidentifiers':
                $csw->params["VERB"] = "ListIdentifiers";
                $csw->params['QSTR'][] = "_DATESTAMP_ >= '".$input['from']."'";
                if($input['until']){ 
                    if($csw->params['QSTR']) $csw->params['QSTR'][] = "AND";
                    $csw->params['QSTR'][] = "_DATESTAMP_ <= '".$input['until']."'";
                }
                if($input['set']){
                    $csw->params['QSTR'][] = "AND";
                    $csw->params['QSTR'][] = "_SERVER_ = '".$input['set']."'";
                }
                $csw->params['ELEMENTSETNAME'] = 'brief';
                break;

            case 'listrecords':
                $csw->params["VERB"] = "ListRecords";
                $csw->params['QSTR'][] = "_DATESTAMP_ >= '".$input['from']."'";
                if($input['until']){ 
                    if($csw->params['QSTR']) $csw->params['QSTR'][] = "AND";
                    $csw->params['QSTR'][] = "_DATESTAMP_ <= '".$input['until']."'"; 
                }
                if($input['set']){
                    $csw->params['QSTR'][] = "AND";
                    $csw->params['QSTR'][] = "_SERVER_ = '".$input['set']."'";
                }
                $csw->params['ELEMENTSETNAME'] = 'summary';
                break;

            case 'getrecord':
                $csw->params["VERB"] = "GetRecord";
                $csw->params['REQUEST'] = 'GetRecords'; 
                $csw->params['ELEMENTSETNAME'] = 'summary';
                $id = explode(":", $input['identifier']);
                $id = $id[count($id)-1];
                //$csw->params['ID'] = $id;
                $csw->params['QSTR'][] = "@identifier = '".$id."'";
                break;

            case 'identify':
                $this->csw->identify();
                exit;
                break;

            case 'listsets':
                $this->csw->listSets();
                exit;
                break;


            default:
                error("badVerb", 'Value of the "verb" argument is not a legal OAI-PMH verb, the "verb" argument is missing, or the "verb" argument is repeating');
                exit;
                break;
        }

        $csw->requestType=1;
        $csw->params['SERVICE'] = 'CSW'; 
        $csw->params['TYPENAMES'] = htmlspecialchars($input['metadataprefix']); 
        $csw->params['VERSION'] = '2.0.2'; 
        //$csw->params['CONSTRAINT_LANGUAGE'] = 'Filter'; 
        $csw->params['MAXRECORDS'] = 50; 
        $csw->params['SET'] = $input['set']; 
        $csw->params['FROM'] = $input['from']; 
        $csw->params['UNTIL'] = $input['until']; 
        $csw->params['ID'] = $input['identifier']; 
        $csw->params['DEBUG'] = $_GET['debuk'];
        $csw->params['STARTPOSITION'] = $input['start'] ? $input['start'] : 1;
        $csw->from = $input['from'];

        $result = $csw->run($params, false);
        $csw->setHeader();
        echo $result;
        $this->terminate();
	}
    
    /** @resource Catalog:Guest */
	public function renderOpensearch($id)
	{
        $csw = new \Micka\Csw();
        $get = $this->context->getByType('Nette\Http\Request')->getQuery();

        // description dokument
        if (!$get['q'] && !$get['bbox'] && !$get['id']) {
            $port = ($_SERVER['SERVER_PORT'] == 80) ? '': ':'.$_SERVER['SERVER_PORT'];
            $path = "http://".$_SERVER['SERVER_NAME'] . $port . dirname($_SERVER['SCRIPT_NAME']) . "/";
            header("Content-type: application/xml");
            $lang = isset($get['language']) ? $get['language'] : "eng";
            if ($lang != 'cze'){
                $lang = 'eng';
            }
            $csw->xml->loadXML("<root></root>");
            $csw->xsl->load(dirname(__FILE__)."/../../model/xsl/openSearch.xsl");
            $csw->xp->importStyleSheet($csw->xsl);
            $params = array(
                'mickaURL' => $this->context->parameters['basePath'],
                'cswURL' => $this->context->parameters['cswUrl'],
                'LANG' => $lang,
                'MICKA_LANG' => MICKA_LANG,
                //'LANG_OTHER' => $olang,
                'org' => $this->context->parameters['contact']['org'][$lang],
                'email' => $this->context->parameters['contact']['email'],
                'title' => $this->context->parameters['contact']['title'][$lang],
                'abstract' => $this->context->parameters['contact']['abstract'][$lang]
            );
            $csw->xp->setParameter('', $params);
            echo $csw->xp->transformToXML($csw->xml);
            $this->terminate();
        }

        $params['LANGUAGE'] = isset($get['language']) ? $get['language'] : 'eng'; 
        $params['q'] = isset($get['q']) ? $_GET['q'] : '' ;
        $params['DEBUG'] = isset($get['debug']) ? $_GET['debug'] : '';
        $params['STARTPOSITION'] = isset($get['start']) ? $_GET['start'] : '';
        $params['FORMAT'] = isset($get['format']) ? trim($_GET['format']) : '';

        if($params['q'] != '') {
            $params['q'] = preg_replace('/\s+/', ' ', trim($params['q']));
            //$tokens = explode(" ", $params['q']);
            $tokens = explode(" ", $params['q']);
            foreach($tokens as $token){
                if (isset($params['CONSTRAINT']) && $params['CONSTRAINT'] != '') {
                    $params['CONSTRAINT'] .= " AND ";
                } else {
                    $params['CONSTRAINT'] = '';
                }
                $params['CONSTRAINT'] .= "anytext like '*" . $token . "*'";
            }
        }
        if (isset($get['id']) && $get['id']) {
            $params['CONSTRAINT'] = "identifier = '" . $get['id'] . "'";
        }
        if (isset($get['bbox']) && $get['bbox']) {
            if (isset($params['CONSTRAINT']) && $params['CONSTRAINT'] != '') {
                $params['CONSTRAINT'] .= " AND ";
            } else {
                $params['CONSTRAINT'] = '';
            }
            $box = str_replace(",", " ", $get['bbox']);
            $params['CONSTRAINT'] .= "_BBOX_='" . $box . "'"; 
        }
        /*if($params['LANG']){
            if($params['CONSTRAINT']) $params['CONSTRAINT'] .= " AND ";
          $params['CONSTRAINT'] .= "_LANGUAGE_='".$params['LANG']."'";  
        }*/
        $params['STARTPOSITION'] = isset($get['start']) && $get['start'] != '' ? $get['start'] : 1;
        $csw->headers = array();
        switch ($params['FORMAT']) {
            case 'rss': 
                $csw->headers[] = "Content-type: application/rss+xml";
                $params['OUTPUTSCHEMA'] = $csw->sch['rss'];
                break; 
            case 'atom': 
                $csw->headers[] = "Content-type: application/xml";
                $params['OUTPUTSCHEMA'] = $csw->sch['atom'];
                break; 
            case 'kml': 
                $csw->headers[] = "Content-Type: application/vnd.google-earth.kml+xml\n";
                $csw->headers[] = "Content-Disposition: filename=micka-open.kml";
                $params['OUTPUTSCHEMA'] = $csw->sch['kml'];
                break; 
            case 'rdf': 
                $csw->headers[] = "Content-type: application/rdf+xml";
                $params['OUTPUTSCHEMA'] = $csw->sch['rdf'];
                break;
            default: 
                $csw->headers[] = "Content-type: text/html";
                $params['OUTPUTSCHEMA'] = $csw->sch['os'];
                $params['FORMAT'] = 'html';
                break;
        }

        // constants
        $params['SERVICE'] = 'CSW'; 
        $params['VERSION'] = '2.0.2'; 
        $params['REQUEST'] = 'GetRecords'; 
        $params['CONSTRAINT_LANGUAGE'] = 'CQL_TEXT'; 
        $params['ELEMENTSETNAME'] = 'summary'; 
        $params['MAXRECORDS'] = 25;
        $params['TYPENAMES'] = 'dummy';

        $result = $csw->run($params);
        $csw->setHeader();
        echo $result;
        $this->terminate();
	}
    
    /** @resource Catalog:Guest */
	public function renderSubset()
	{
        $csw = new Csw("", '_DATA_TYPE_=2');

        // pokud jsou entity
        $params=array();
        if($_SERVER['QUERY_STRING']){
            $input = explode("&", html_entity_decode($_SERVER['QUERY_STRING']));
            foreach($input as $pair){
                $kw = explode("=",$pair);
                $params[$kw[0]] = htmlspecialchars($kw[1]);
            }
        }

        if (isset($_SERVER['PHP_AUTH_USER'])) {
          $_REQUEST['user'] = $_SERVER['PHP_AUTH_USER'];
          $_REQUEST['pwd']  = $_SERVER['PHP_AUTH_PW']; 
        }

        // hack kvuli primemu pristupu pro CENIA
        if($_POST['query']){ 
            $params['query'] = $_POST['query'];
            $params = $_POST;
            $params['start']++; 
            if(!$_REQUEST['user']) $_REQUEST['user'] = 'guest'; 
        }

        echo $csw->run($params);
        $this->terminate();
	}
    
    /** @resource Catalog:Guest */
	public function renderAtom($id)
	{
        $get = $this->context->getByType('Nette\Http\Request')->getQuery();
        $params = array();
        $params['SERVICE'] = 'CSW';
        $params['VERSION'] = '2.0.2';
        $params['CONSTRAINT_LANGUAGE'] = 'CQL';
        $params['REQUEST'] = 'GetRecorById';
        $params['ID'] = $id;
        $params['LANGUAGE'] = isset($get['language']) ? $get['language'] : 'eng'; 
        $params['OUTPUTSCHEMA'] = 'http://www.w3.org/2005/Atom';
        $csw = new \Micka\Csw;
        $result = $csw->run($params);
        $csw->setHeader();
        echo $result;
        $this->terminate();
	}
}
