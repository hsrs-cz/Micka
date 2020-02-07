<?php

namespace App\Security;

use Nette,
    Nette\Security\Permission;

class AuthorizatorFactory
{
    use Nette\SmartObject;
    
    const ROLE_GUEST = 'guest';
    const ROLE_USER = 'user';
    const ROLE_EDITOR = 'editor';
    const ROLE_PUBLISHER = 'publisher';
    const ROLE_ADMIN = 'admin';


    public function create()
    {
        $acl = new Permission;

        $acl->addRole(self::ROLE_GUEST);
        $acl->addRole(self::ROLE_USER, self::ROLE_GUEST);
        $acl->addRole(self::ROLE_EDITOR, self::ROLE_USER);
        $acl->addRole(self::ROLE_PUBLISHER, self::ROLE_USER);
        $acl->addRole(self::ROLE_ADMIN, [self::ROLE_EDITOR, self::ROLE_PUBLISHER]);

        $acl->addResource('Guest');
        $acl->addResource('User');
        $acl->addResource('Editor');
        $acl->addResource('Publisher');
        $acl->allow(self::ROLE_GUEST, 'Guest');
        $acl->allow(self::ROLE_USER, 'User');
        $acl->allow(self::ROLE_EDITOR, 'Editor');
        $acl->allow(self::ROLE_PUBLISHER, 'Publisher');

        $acl->addResource('Admin');
        $acl->allow(self::ROLE_ADMIN, 'Admin');

        return $acl;
    }

}