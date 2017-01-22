<?php

namespace App;

use Nette;
use Nette\Application\Routers\RouteList;
use Nette\Application\Routers\Route;
//use Nette\Application\Routers\SimpleRouter;

class RouterFactory
{
	use Nette\StaticClass;

	/**
	 * @return Nette\Application\IRouter
	 */
	public static function createRouter()
	{
	$router = new RouteList;
    //if (function_exists('apache_get_modules') && in_array('mod_rewrite', apache_get_modules())) {
        //$router[] = new Route('index.php', 'Front:Homepage:default', Route::ONE_WAY);
        $router[] = new Route('[<locale=cs cs|en>/]sign/in', ['module' => 'Front', 'presenter' => 'Sign', 'action' => 'in']);
        $router[] = new Route('[<locale=cs cs|en>/]sign/out', ['module' => 'Front', 'presenter' => 'Sign', 'action' => 'out']);
        $router[] = new Route('[<locale=cs cs|en>/]records/new', ['module' => 'Front', 'presenter' => 'Records', 'action' => 'new']);
        $router[] = new Route('[<locale=cs cs|en>/]records/edit[/<id>]', ['module' => 'Front', 'presenter' => 'Records', 'action' => 'edit']);
        $router[] = new Route('[<locale=cs cs|en>/]records/valid[/<id>]', ['module' => 'Front', 'presenter' => 'Records', 'action' => 'valid']);
        $router[] = new Route('[<locale=cs cs|en>/]records/clone[/<id>]', ['module' => 'Front', 'presenter' => 'Records', 'action' => 'clone']);
        $router[] = new Route('[<locale=cs cs|en>/]records/delete[/<id>]', ['module' => 'Front', 'presenter' => 'Records', 'action' => 'delete']);
        $router[] = new Route('[<locale=cs cs|en>/]records[/<id>]', ['module' => 'Front', 'presenter' => 'Records', 'action' => 'default']);
        $router[] = new Route('[<locale=cs cs|en>/]page[/<id>]', ['module' => 'Front', 'presenter' => 'Page', 'action' => 'default']);
        $router[] = new Route('[<locale=cs cs|en>/]suggest', ['module' => 'Front', 'presenter' => 'Suggest', 'action' => 'default']);
        $router[] = new Route('[<locale=cs cs|en>/]csw', ['module' => 'Front', 'presenter' => 'Csw', 'action' => 'default']);
        $router[] = new Route('[<locale=cs cs|en>/]about', ['module' => 'Front', 'presenter' => 'Homepage', 'action' => 'about']);
        $router[] = new Route('[<locale=cs cs|en>/]help', ['module' => 'Front', 'presenter' => 'Homepage', 'action' => 'help']);
        $router[] = new Route('[<locale=cs cs|en>/]<module=Front>/<presenter=Homepage>/<action=default>', 'Front:Homepage:default');

        $router[] = $adminRouter = new RouteList('Admin');
        $adminRouter[] = new Route('admin/<presenter>/<action>', 'Homepage:default');

        //$router[] = $frontRouter = new RouteList('Front');
        //$frontRouter[] = new Route('sign', 'Front:Sign:in');
        //$frontRouter[] = new Route('records', 'Records:default');

        // $router[] = $filesRouter = new RouteList('Files');
        // $filesRouter[] = new Route('files/<presenter>/<action>[/<id>]', 'Default:default');
    //} else {
    //    $container->addService('router', new SimpleRouter('Front:Default:default'));
    //}
    
		//$router = new RouteList;
		//$router[] = new Route('<presenter>/<action>[/<id>]', 'Homepage:default');
		return $router;
	}

}
