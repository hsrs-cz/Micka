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
        $langCodes = array_flip($container->parameters['langCodes']);
        $appLangs = explode(',', $container->parameters['app']['langs']);
        $translation = 'en';
        $moreTranslation = '';
        foreach ($appLangs as $key => $lang) {
            if ($key === 0) {
                $translation = $langCodes[$lang];
            } else {
                $moreTranslation .= '|' . $langCodes[$lang];
            }
        }
        $locale = $translation. ' '  . $translation . $moreTranslation;
        
        if ($container->parameters['consoleMode']) {
            $router[] = new CliRouter(array('action' => 'Cli:Cli:default'));
        } else {
            $router[] = $validatorRouter = new RouteList('Validator');
            $validatorRouter[] = new Route('validator/form', 'Default:form');
            $validatorRouter[] = new Route('validator/result', 'Default:result');
            $validatorRouter[] = new Route('validator/<presenter>/<action>', 'Default:form');

            $router[] = $adminRouter = new RouteList('Admin');
            $adminRouter[] = new Route('[<locale=' . $locale . '>/]admin/<presenter>/<action>[/<id>]', 'Default:default');

            $router[] = new Route('index.php', 'Catalog:Search:default', Route::ONE_WAY);
            $router[] = new Route('[<locale=' . $locale . '>/]sign/in', ['module' => 'Catalog', 'presenter' => 'Sign', 'action' => 'in']);
            $router[] = new Route('[<locale=' . $locale . '>/]sign/out', ['module' => 'Catalog', 'presenter' => 'Sign', 'action' => 'out']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/basic[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'basic']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/full[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'full']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/xml[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'xml']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/new', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'new']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/edit[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'edit']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/save[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'save']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/valid[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'valid']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/clone[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'clone']);
            $router[] = new Route('[<locale=' . $locale . '>/]record/delete[/<id>]', ['module' => 'Catalog', 'presenter' => 'Record', 'action' => 'delete']);
            $router[] = new Route('[<locale=' . $locale . '>/]page[/<id>]', ['module' => 'Catalog', 'presenter' => 'Page', 'action' => 'default']);
            $router[] = new Route('[<locale=' . $locale . '>/]suggest/mdcontacts', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdContacts']);
            $router[] = new Route('[<locale=' . $locale . '>/]suggest/mdlists', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdLists']);
            $router[] = new Route('[<locale=' . $locale . '>/]suggest/metadata', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'Metadata']);
            $router[] = new Route('[<locale=' . $locale . '>/]suggest/mdupload', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdUpload']);
            $router[] = new Route('[<locale=' . $locale . '>/]suggest/mdgazcli', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'MdGazcli']);
            $router[] = new Route('[<locale=' . $locale . '>/]suggest', ['module' => 'Catalog', 'presenter' => 'Suggest', 'action' => 'default']);
            $router[] = new Route('[<locale=' . $locale . '>/]csw', ['module' => 'Catalog', 'presenter' => 'Csw', 'action' => 'default']);
            $router[] = new Route('[<locale=' . $locale . '>/]csw/filter[/<id>]', ['module' => 'Catalog', 'presenter' => 'Csw', 'action' => 'filter']);
            $router[] = new Route('[<locale=' . $locale . '>/]about', ['module' => 'Catalog', 'presenter' => 'Micka', 'action' => 'about']);
            $router[] = new Route('[<locale=' . $locale . '>/]help', ['module' => 'Catalog', 'presenter' => 'Micka', 'action' => 'help']);
            $router[] = new Route('[<locale=' . $locale . '>/]<module=Catalog>/<presenter=Default>/<action=default>', 'Catalog:Default:default');
        }
		return $router;
	}

}
