<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:gsr="http://www.isotc211.org/2005/gsr" 
  xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
  >
<xsl:output method="xml" encoding="utf-8" />
<xsl:template match="/">
	<results>
	  	<xsl:for-each select="//csw:Transaction/csw:Update">
	        <xsl:apply-templates />
	  	</xsl:for-each>
	  	<xsl:for-each select="//csw:Transaction/csw:Insert">
	        <xsl:apply-templates />
	  	</xsl:for-each>
	  	<xsl:for-each select="//csw:SearchResults">
	        <xsl:apply-templates />
	  	</xsl:for-each>
	  	<xsl:for-each select="//csw:GetRecordByIdResponse">
	        <xsl:apply-templates />
	  	</xsl:for-each>
	</results>
</xsl:template>

<xsl:template match="gmd:MD_Metadata">
    <gmd:MD_Metadata>
        <xsl:apply-templates select="./*"/>
    </gmd:MD_Metadata>
</xsl:template>

<xsl:template match="MI_Metadata">
    <gmd:MD_Metadata>
        <xsl:apply-templates select="./*"/>
    </gmd:MD_Metadata>
</xsl:template>

<xsl:template match="featureCatalogue">
</xsl:template>

<xsl:include href="import/update4.xsl" />

</xsl:stylesheet>
