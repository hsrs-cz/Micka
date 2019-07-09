<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>

<xsl:template match="/"  xmlns:ows="http://www.opengis.net/ows" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:php="http://php.net/xsl"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
>

<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/"
    xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
    xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/">
    <ShortName><xsl:value-of select="$title"/></ShortName>
    <Description><xsl:value-of select="$abstract"/></Description>
    <!--URL of this document--> 
    <Url rel="self" type="application/opensearchdescription+xml" template="{substring-before($cswURL, 'csw')}opensearch"/>

    <Url rel="results" template="{$cswURL}?format=application/xml&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}&amp;outputSchema=http://www.w3.org/2005/Atom" type="application/atom+xml"/>
    <Url rel="results" template="{$cswURL}?format=rdf&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}" type="application/rdf+xml"/>
    <Url rel="results" template="{$cswURL}?format=kml&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}" type="application/vnd.google-earth.kml+xml"/>

    <Url rel="results" template="{$cswURL}..?request=GetRecords&amp;format=text/html&amp;query=Fulltext='{{searchTerms}}'" type="text/html"/>
    
    <!--Describe Spatial Data Set Operation request URL template to be used in order to retrieve the description of Spatial Object Types in a Spatial Dataset-->
    <Url rel="results" type="application/atom+xml" template="{$cswURL}?RESID={{inspire_dls:spatial_dataset_identifier_code?}}&amp;RESNS={{inspire_dls:spatial_dataset_identifier_namespace?}}&amp;CRS={{inspire_dls:crs?}}&amp;language={{language?}}&amp;format=application/xml&amp;q={{searchTerms?}}"/>
    <Url rel="desribedby" type="application/atom+xml" template="{$cswURL}?RESID={{inspire_dls:spatial_dataset_identifier_code?}}&amp;RESNS={{inspire_dls:spatial_dataset_identifier_namespace?}}&amp;CRS={{inspire_dls:crs?}}&amp;language={{language?}}&amp;format=application/xml&amp;q={{searchTerms?}}"/>
    <!--Get Spatial Data Set Operation request URL template to be used in order to retrieve a Spatial Dataset-->
    <Url rel="results" type="application/x-filegdb" template="{$cswURL}?RESID={{inspire_dls:spatial_dataset_identifier_code?}}&amp;RESNS={{inspire_dls:spatial_dataset_identifier_namespace?}}&amp;CRS={{inspire_dls:crs?}}&amp;language={{language?}}&amp;format=application/xml&amp;q={{searchTerms?}}"/>
   
    <Contact><xsl:value-of select="$email"/></Contact>
    <Tags>metadata catalogue</Tags>
    <Image type="image/png" width="16" height="16"><xsl:value-of select="$cswURL"/>../layout/default/img/favicon.png</Image>
    <Developer><xsl:value-of select="$org"/></Developer>
    <Language>*</Language>
    <OutputEncoding>UTF-8</OutputEncoding>
    <InputEncoding>UTF-8</InputEncoding>
    <xsl:if test="$ID">
        <xsl:variable name="mds" select="php:function('getMetadataById', string($ID))"/>
        <xsl:for-each select="$mds//srv:operatesOn">
            <xsl:variable name="md" select="php:function('getData', string(@xlink:href))"/>
            <Query role="example"
                inspire_dls:spatial_dataset_identifier_namespace="{$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/*}"
                inspire_dls:spatial_dataset_identifier_code="{$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/@xlink:href}"
                inspire_dls:crs="http://www.opengis.net/def/crs/EPSG/0/4326"
                title="{$md//gmd:identificationInfo/*/gmd:citation/*/gmd:title/*}"
                language="{$md//gmd:identificationInfo/*/gmd:language/*/@codeListValue}"
            />
        </xsl:for-each>
    </xsl:if>
</OpenSearchDescription>

</xsl:template>

</xsl:stylesheet>