<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:csw="http://www.opengis.net/cat/csw" xmlns:gsr="http://www.isotc211.org/2005/gsr" 
  xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:srv="http://www.isotc211.org/2005/srv" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gmi="http://www.isotc211.org/2005/gmi" 
  >
<xsl:output method="xml" encoding="utf-8" />


<xsl:template match="/">
    <results>
        <xsl:for-each select="//gmd:MD_Metadata|//gmi:MI_Metadata">
            <xsl:apply-templates select="./*"/>
        </xsl:for-each>
    </results>
</xsl:template>

<xsl:include href="update4.xsl" />

</xsl:stylesheet>
