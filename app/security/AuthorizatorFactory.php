<?php

namespace App\Security;

use Nette,
    Nette\Security\Permission;

class AuthorizatorFactory extends Nette\Object
{

    const ROLE_GUEST = 'guest';
    const ROLE_USER = 'user';
    const ROLE_WRITER = 'writer';
    const ROLE_PUBLISHER = 'publisher';
    const ROLE_ADMIN = 'admin';
    const ROLE_ROOT = 'root';


    public function create()
    {
        $acl = new Permission;

        $acl->addRole(self::ROLE_GUEST);
        $acl->addRole(self::ROLE_USER, self::ROLE_GUEST);
        $acl->addRole(self::ROLE_WRITER, self::ROLE_USER);
        $acl->addRole(self::ROLE_PUBLISHER, self::ROLE_USER);
        $acl->addRole(self::ROLE_ADMIN, [self::ROLE_WRITER, self::ROLE_PUBLISHER]);
        $acl->addRole(self::ROLE_ROOT, self::ROLE_ADMIN);

        $acl->addResource('Front');
        $acl->addResource('Front:Homepage', 'Front');
        $acl->addResource('Front:Sign', 'Front');
        $acl->addResource('Front:Records', 'Front');
        $acl->addResource('Front:Page', 'Front');
        $acl->addResource('Front:Csw', 'Front');
        $acl->addResource('Front:Suggest', 'Front');
        
        $acl->addResource('Front:Homepage:Default', 'Front');

        $acl->allow(self::ROLE_GUEST, 'Front');

        $acl->addResource('Admin');
        $acl->addResource('Admin:Homepage', 'Admin');
        $acl->allow(self::ROLE_ADMIN, 'Admin');
        
        $acl->addResource('Front:Homepage:Edit');
        $acl->allow(self::ROLE_WRITER, 'Front:Homepage:Edit');
        $acl->addResource('Front:Records:Edit');
        $acl->allow(self::ROLE_WRITER, 'Front:Records:Edit');
        //$acl->addResource('User:Profile', 'User');


        //$acl->allow(self::ROLE_USER,  Permission::ALL, Permission::ALL);

        return $acl;
    }

}