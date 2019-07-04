<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>

<xsl:template match="/"  xmlns:ows="http://www.opengis.net/ows" xmlns:xlink="http://www.w3.org/1999/xlink">

<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/"
    xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
    xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/">
    <ShortName><xsl:value-of select="$title"/></ShortName>
    <Description><xsl:value-of select="$abstract"/></Description>
    <!--URL of this document--> 
    <Url type="application/opensearchdescription+xml" rel="self" template="{$cswURL}/../opensearch/"/>

    <Url template="{$cswURL}?format=application/xml&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}&amp;outputSchema=http://www.w3.org/2005/Atom" type="application/atom+xml"/>
    <Url template="{$cswURL}?format=rdf&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}" type="application/rdf+xml"/>
    <Url template="{$cswURL}?format=kml&amp;q={{searchTerms?}}&amp;id={{geo:uid?}}&amp;bbox={{geo:bbox?}}&amp;start={{startIndex?}}&amp;language={{language?}}" type="application/vnd.google-earth.kml+xml"/>

    <Url template="{$cswURL}..?request=GetRecords&amp;format=text/html&amp;query=Fulltext='{{searchTerms}}'" type="text/html"/>
    
    <Contact><xsl:value-of select="$email"/></Contact>
    <Tags>metadata catalogue</Tags>
    <Image type="image/png" width="16" height="16"><xsl:value-of select="$cswURL"/>../layout/default/img/favicon.png</Image>
    <Developer><xsl:value-of select="$org"/></Developer>
    <Language>*</Language>
    <OutputEncoding>UTF-8</OutputEncoding>
    <InputEncoding>UTF-8</InputEncoding>
</OpenSearchDescription>

</xsl:template>

</xsl:stylesheet>