<?php

namespace App\Model;

use App\Model;
use Nette\Utils\Finder;

class FilesModel extends \BaseModel
{
    
    public function getFiles($filter=''){
        foreach (Finder::findFiles($filter)->in(__DIR__ . '/../../data') as $key => $file) {
            $files[] = ['name'=>$file->getFileName(), 'size'=>$file->getSize()]; 
        }
        return $files;
    }
    
    public function putFile(){
        
    }
}