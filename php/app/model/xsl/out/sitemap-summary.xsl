<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:gmd="http://www.isotc211.org/2005/gmd" 
xmlns:gmi="http://www.isotc211.org/2005/gmi" 
xmlns:gco="http://www.isotc211.org/2005/gco" 
xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
xmlns:dc="http://purl.org/dc/elements/1.1/" 
xmlns:dct="http://purl.org/dc/terms/" 
xmlns:ows="http://www.opengis.net/ows"
>
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template match="*/*">
<xsl:if test="gmd:fileIdentifier">
    <url> 
      <loc><xsl:value-of select="$mickaURL"/>/record/basic/<xsl:value-of select="gmd:fileIdentifier"/></loc>
      <lastmod><xsl:value-of select="substring(gmd:dateStamp,1,10)"/></lastmod>
      <changefreq>weekly</changefreq>
    </url>
</xsl:if>
</xsl:template>

</xsl:stylesheet>