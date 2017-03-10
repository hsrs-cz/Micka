<?php

$container = require __DIR__ . '/php/app/bootstrap.php';

$container->getByType(Nette\Application\Application::class)
	->run();
