<?php

namespace App\Security;

use Nette,
    Nette\Security\Permission;

class AuthorizatorFactory extends Nette\Object
{

    const ROLE_GUEST = 'guest';
    const ROLE_USER = 'user';
    const ROLE_EDITOR = 'editor';
    const ROLE_PUBLISHER = 'publisher';
    const ROLE_ADMIN = 'admin';
    const ROLE_ROOT = 'root';


    public function create()
    {
        $acl = new Permission;

        $acl->addRole(self::ROLE_GUEST);
        $acl->addRole(self::ROLE_USER, self::ROLE_GUEST);
        $acl->addRole(self::ROLE_EDITOR, self::ROLE_USER);
        $acl->addRole(self::ROLE_PUBLISHER, self::ROLE_USER);
        $acl->addRole(self::ROLE_ADMIN, [self::ROLE_EDITOR, self::ROLE_PUBLISHER]);
        $acl->addRole(self::ROLE_ROOT, self::ROLE_ADMIN);

        $acl->addResource('Catalog:Guest');
        $acl->addResource('Catalog:Editor');
        $acl->allow(self::ROLE_GUEST, 'Catalog:Guest');
        $acl->allow(self::ROLE_EDITOR, 'Catalog:Editor');

        $acl->addResource('Admin');
        $acl->allow(self::ROLE_ADMIN, 'Admin');
        
        $acl->addResource('Root');
        $acl->allow(self::ROLE_ROOT, 'Root');
        return $acl;
    }

}