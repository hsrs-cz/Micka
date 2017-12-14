<?php

namespace App;

use Nette;
use Nette\Application\Routers\RouteList;
use Nette\Application\Routers\Route;
use Nette\Application\Routers\CliRouter;

class RouterFactory
{
	use Nette\StaticClass;

	/**
	 * @return Nette\Application\IRouter
	 */
	public static function createRouter(Nette\DI\Container $container)
	{
        $router = new RouteList;

        if ($container->parameters['consoleMode']) {
            $router[] = new CliRouter(array('action' => 'Cli:Cli:default'));
        } else {
            $router[] = $validatorRouter = new RouteList('Validator');
            $validatorRouter[] = new Route('validator/form', 'Default:form');
            $validatorRouter[] = new Route('validator/result', 'Default:result');
            $validatorRouter[] = new Route('validator/<presenter>/<action>', 'Default:form');

            $router[] = $adminRouter = new RouteList('Admin');
            $adminRouter[] = new Route('[<locale=cs cs|en|es>/]admin/<presenter>/<action>[/<id>]', 'Default:default');

            $router[] = new Route('index.php', 'Catalog:Search:default', Route::ONE_WAY);
            $router[] = new Route('[<locale=cs cs|en|es>/]sign/in', ['module' => 'Catalog', 'presenter' => 'Sign', 'action' => 'in']);
            $router[] = new Route('[<locale=cs cs|en|es>/]sign/out', ['module' => 'Catalog', 'presenter' => 'Sign', 'action' => 'out']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/basic[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'basic']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/full[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'full']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/xml[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'xml']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/new', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'new']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/edit[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'edit']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/save[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'save']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/valid[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'valid']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/clone[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'clone']);
            $router[] = new Route('[<locale=cs cs|en|es>/]record/delete[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'delete']);
            $router[] = new Route('[<locale=cs cs|en|es>/]page[/<id>]', ['module' => 'Catalog', 'presenter' => 'Page', 'action' => 'default']);
            $router[] = new Route('[<locale=cs cs|en|es>/]suggest/mdcontacts', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdContacts']);
            $router[] = new Route('[<locale=cs cs|en|es>/]suggest/mdlists', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdLists']);
            $router[] = new Route('[<locale=cs cs|en|es>/]suggest/metadata', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'Metadata']);
            $router[] = new Route('[<locale=cs cs|en|es>/]suggest/mdupload', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdUpload']);
            $router[] = new Route('[<locale=cs cs|en|es>/]suggest/mdgazcli', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdGazcli']);
            $router[] = new Route('[<locale=cs cs|en|es>/]suggest', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'default']);
            $router[] = new Route('[<locale=cs cs|en|es>/]csw', ['module' => 'Catalog', 'presenter' => 'Csw', 'action' => 'default']);
            $router[] = new Route('[<locale=cs cs|en|es>/]about', ['module' => 'Catalog', 'presenter' => 'Micka', 'action' => 'about']);
            $router[] = new Route('[<locale=cs cs|en|es>/]help', ['module' => 'Catalog', 'presenter' => 'Micka', 'action' => 'help']);
            $router[] = new Route('record[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'old']);
            $router[] = new Route('[<locale=cs cs|en|es>/]<module=Catalog>/<presenter=Default>/<action=default>', 'Catalog:Default:default');
        }
        
		return $router;
	}

}
