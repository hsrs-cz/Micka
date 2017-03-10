<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>

<xsl:template match="/"  xmlns:ows="http://www.opengis.net/ows" xmlns:xlink="http://www.w3.org/1999/xlink">

<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
    xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/">
    <ShortName><xsl:value-of select="//ows:ServiceIdentification/ows:Title"/></ShortName>
    <Description><xsl:value-of select="//ows:ServiceIdentification/ows:Abstract"/></Description>
    <!--URL of this document--> 
    <Url type="application/opensearchdescription+xml" rel="self" template="{$path}opensearch.php"/>

    <Url template="{$path}opensearch.php?format=atom&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}" type="application/atom+xml"/>
    <Url template="{$path}opensearch.php?format=rdf&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}" type="application/rdf+xml"/>
    <Url template="{$path}opensearch.php?format=kml&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}" type="application/vnd.google-earth.kml+xml"/>

    <Url template="{$path}../?request=GetRecords&amp;format=text/html&amp;query=Anytext like '{{searchTerms}}*'" type="text/html"/>
    
    <Contact><xsl:value-of select="//ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/> (<xsl:value-of select="//ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/>)</Contact>
    <Tags><xsl:for-each select="//ows:Keywords"><xsl:value-of select="."/> </xsl:for-each></Tags>
    <Image type="image/gif" width="16" height="16"><xsl:value-of select="$path"/>../img/favicon.gif</Image>
    <Image type="image/vnd.microsoft.icon" width="16" height="16"><xsl:value-of select="$path"/>../favicon.ico</Image>
    <Developer><xsl:value-of select="//ows:ServiceProvider/ows:ProviderName"/></Developer>
    <Language>*</Language>
    <OutputEncoding>UTF-8</OutputEncoding>
    <InputEncoding>UTF-8</InputEncoding>
</OpenSearchDescription>

</xsl:template>

</xsl:stylesheet>