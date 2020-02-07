<?php

namespace App\Model;

use Nette;


class CswModel extends \BaseModel
{
	use Nette\SmartObject;

    public function oaiHeader($verb)
    {
        $datestamp = date("Y-m-d\TH:i:s"); 
        return '<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
        <responseDate>'.$datestamp.'</responseDate>
        <request verb="'.$verb.'">http://'.$_SERVER['SERVER_NAME'].$_SERVER['SCRIPT_NAME'].'</request>';	
    }

    public function error($code, $message)
    {
        $datestamp = date("Y-m-d\TH:i:s"); 
        header("Content-type: application/xml");
        echo oaiHeader($_GET['verb']).'<error code="'.$code.'">'.$message.'</error></OAI-PMH>';
    }

    public function identify()
    {
        header("Content-type: application/xml");
        echo oaiHeader($_GET['verb']);
        echo '<Identify>
            <repositoryName>MICKA</repositoryName>
            <baseURL>http://'.$_SERVER['SERVER_NAME'].$_SERVER['SCRIPT_NAME'].'</baseURL>
            <protocolVersion>2.0</protocolVersion>
            <adminEmail>kafka@email.cz</adminEmail>
            <earliestDatestamp>2004-10-30</earliestDatestamp>
            <deletedRecord>no</deletedRecord>
            <granularity>YYYY-MM-DD</granularity>
            </Identify></OAI-PMH>';
    }

    public function listSets()
    {
        $sets = getSets(); 
        header("Content-type: application/xml");
        echo oaiHeader($_GET['verb']);
        echo "<ListSets>";
        foreach($sets as $set){
            echo "<set><setSpec>$set[id]</setSpec><setName>$set[source]</setName></set>";
        }
        echo "</ListSets></OAI-PMH>";
    }

    public function getSets()
    {
        $sql[] = 'SELECT * FROM harvest';
        array_push($sql, 'ORDER BY name');
        try {
            $rs = $this->db->query($sql)->fetchAll();
            foreach($rs as $row) {
                $result[] =  Array(
                    "id" => $row->name,
                    "source" => $row->source,
                    "type" => $row->type,
                    "h_interval" => $row->h_interval,
                    "HarvestInterval" => $row->period,
                    "handlers" => $row->handlers
                ); 
            }

        }
        catch (Exception $e) {
            var_dump($e);
            $result = false;
        }
        return $result;   
    }
    
    
    
}