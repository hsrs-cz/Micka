<?php

namespace App;

use Nette;
use Nette\Application\Routers\RouteList;
use Nette\Application\Routers\Route;

class RouterFactory
{
	use Nette\StaticClass;

	/**
	 * @return Nette\Application\IRouter
	 */
	public static function createRouter()
	{
        $router = new RouteList;
        $router[] = $validatorRouter = new RouteList('Validator');
        $validatorRouter[] = new Route('validator/form', 'Default:form');
        $validatorRouter[] = new Route('validator/result', 'Default:result');
        $validatorRouter[] = new Route('validator/<presenter>/<action>', 'Default:form');
        
        $router[] = $adminRouter = new RouteList('Admin');
        $adminRouter[] = new Route('admin/<presenter>/<action>', 'Homepage:default');

        $router[] = new Route('index.php', 'Catalog:Search:default', Route::ONE_WAY);
        $router[] = new Route('[<locale=cs cs|en>/]sign/in', ['module' => 'Catalog', 'presenter' => 'Sign', 'action' => 'in']);
        $router[] = new Route('[<locale=cs cs|en>/]sign/out', ['module' => 'Catalog', 'presenter' => 'Sign', 'action' => 'out']);
        $router[] = new Route('[<locale=cs cs|en>/]record/basic[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'basic']);
        $router[] = new Route('[<locale=cs cs|en>/]record/full[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'full']);
        $router[] = new Route('[<locale=cs cs|en>/]record/xml[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'xml']);
        $router[] = new Route('[<locale=cs cs|en>/]record/new', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'new']);
        $router[] = new Route('[<locale=cs cs|en>/]record/edit[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'edit']);
        $router[] = new Route('[<locale=cs cs|en>/]record/save[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'save']);
        $router[] = new Route('[<locale=cs cs|en>/]record/valid[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'valid']);
        $router[] = new Route('[<locale=cs cs|en>/]record/clone[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'clone']);
        $router[] = new Route('[<locale=cs cs|en>/]record/delete[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'delete']);
        $router[] = new Route('[<locale=cs cs|en>/]page[/<id>]', ['module' => 'Catalog', 'presenter' => 'Page', 'action' => 'default']);
        $router[] = new Route('[<locale=cs cs|en>/]suggest/mdcontacts', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdContacts']);
        $router[] = new Route('[<locale=cs cs|en>/]suggest/mdlists', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdLists']);
        $router[] = new Route('[<locale=cs cs|en>/]suggest/metadata', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'Metadata']);
        $router[] = new Route('[<locale=cs cs|en>/]suggest/mdupload', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdUpload']);
        $router[] = new Route('[<locale=cs cs|en>/]suggest/mdgazcli', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdGazcli']);
        $router[] = new Route('[<locale=cs cs|en>/]suggest', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'default']);
        $router[] = new Route('[<locale=cs cs|en>/]csw', ['module' => 'Catalog', 'presenter' => 'Csw', 'action' => 'default']);
        $router[] = new Route('[<locale=cs cs|en>/]about', ['module' => 'Catalog', 'presenter' => 'Micka', 'action' => 'about']);
        $router[] = new Route('[<locale=cs cs|en>/]help', ['module' => 'Catalog', 'presenter' => 'Micka', 'action' => 'help']);
        $router[] = new Route('record[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'old']);
        $router[] = new Route('[<locale=cs cs|en>/]<module=Catalog>/<presenter=Search>/<action=default>', 'Catalog:Search:default');

		return $router;
	}

}
