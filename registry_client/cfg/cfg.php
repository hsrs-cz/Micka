<?php
// --- bud tam bude include nebo exclude
$config=array(
    // --- Enduse potential INSPIRE
    "https://inspire.ec.europa.eu/codelist/EndusePotentialValue"=>array(
        "adapter"=> "inspireRegistry",
        //"include"=>array()
        "exclude"=>array(
            "https://inspire.ec.europa.eu/codelist/EndusePotentialValue/abrasiveMinerals"
        )
    ),
    // --- Enduse potential INSPIRE
    "https://inspire.ec.europa.eu/theme"=>array(
        "adapter"=> "inspireThemes"
    ),
    
    // --- Exploration activity type CGI
    "http://resource.geosciml.org/classifierscheme/cgi/201401/exploration-activity-type"=>array(
            "adapter" => "cgi",
            "url" => "http://resource.geosciml.org/sparql/cgi201211",
            "sparql" => "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
                SELECT * WHERE {
                   ?id skos:inScheme <http://resource.geosciml.org/classifierscheme/cgi/201401/exploration-activity-type> .
                   ?id skos:prefLabel ?label .
                    { ?id skos:definition ?description .
                       ?id skos:broader ?broader .
                       ?broader skos:prefLabel ?broaderLabel .
                    }
                    UNION   {  
                        ?id skos:definition ?description .  
                        FILTER ( NOT EXISTS {?id skos:broader ?b .} ) 
                    } 
                }  "
    ),

    // --- EU Countries
    "https://publications.europa.eu/resource/authority/country"=>array(
        "adapter"=> "skos",
        "url" => "http://publications.europa.eu/mdr/resource/authority/country/skos/countries-skos.rdf"
    )
    
);