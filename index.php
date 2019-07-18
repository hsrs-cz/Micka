<?php

if (file_exists(__DIR__ . '/php/app/config/index.include.php')) {
    require __DIR__ . '/php/app/config/index.include.php';
}

$container = require __DIR__ . '/php/app/bootstrap.php';
$container->getByType(Nette\Application\Application::class)
	->run();
