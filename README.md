# Micka
Geospatial metadata catalogue and metadata editing tool. 

## Features
- OGC CSW 2.0.2 ISO AP 1.0
- ISO 19115/19119/19139
- Feature Catalogue - ISO 19110
- INSPIRE extended capabilities
- Output: ISO 19139, JSON, GeoDCAT, ATOM, KML, HTML, RDFa
- INSPIRE ATOM download service imlementation
- Support for remote registries and thesauri (e.g. INSPIRE registry)

## System requirements
- Any web server with mod_rewrite enabled
- PHP min 7.1 with xsl,pgsql and mbstring  extensions
- PostgreSQL min 10.0 & PostGIS 2.4
- Composer (https://getcomposer.org/) - for installaton some components.

## Installation
1. Download the code from github and put to any directory at your web.
2. `cd php`
3. Run `composer install` at this directory. (It will install Nette and other PHP components.)
4. Create the database at your PostgreSQL database console or client tool `CREATE DATABASE dbname WITH ENCODING='UTF8' CONNECTION LIMIT=-1;`. 
5. Create here the PostGIS extension (e.g. `CREATE EXTENSION postgis;` if not automatically created)
6. Run SQL scripts located in `php/install/` at PostgreSQL console or admin tool in numerical order 1 - 5.
7. For creating fulltext search indexes in your language edit the `php/install/*fulltext*.sql` script and run it. (English is supported by default)
8. Rename `app/config/config.local.neon.dist` to `app/config/config.local.neon` and edit it for access to your database, your contact information etc.
9. Rename `app/config/config.neon.dist` to `app/config/config.neon`.
10. Rename `app/config/codelists.xml.dist` to `app/config/codelists.xml`.
11. Crate the directories `log` and `temp` under the `php` directory and make them writable for the web server

## Updates
In new versions the database structure may sometimes change. In mostly cases the data remains unchanged but update scripts should be run to change some tables. Update scripts are named **u&lt;update-date&gt;_&lt;table-name&gt;.sql**

*Note: If updating, please delete all files under php/temp/cache directory.*

## User access
During installation these default users are created automatically:
- admin (password = admin)
- editor (password = editor)
- reader (password = reader)

After installation you should login as admin and change the passwords and/or names on Administration / Users management page.


