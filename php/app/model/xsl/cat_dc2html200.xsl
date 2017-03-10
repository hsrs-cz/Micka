<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dc="http://www.purl.org/dc/elements/1.1/" 
  xmlns:dct="http://www.purl.org/dc/terms/" 
  xmlns:csw="http://www.opengis.net/cat/csw"
  xmlns:gml="http://www.opengis.net/gml"   
  xmlns:ows="http://www.opengis.net/ows" >

<xsl:output method="html" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
<xsl:variable name="msg" select="document('portal.xml')/portal/messages[@lang=$lang]"/>

<xsl:template match="/">
<xsl:for-each select="//csw:SearchResults/*">
<div class="record">
  <div class="nadpis"> <xsl:value-of select="dc:title"/> (<span class="type"><xsl:value-of select="dc:type"/> </span>)</div>
  <div class="abstract"><xsl:value-of select="dct:abstract"/></div>
  coord: <xsl:value-of select="*/ows:LowerCorner"/>,<xsl:value-of select="*/ows:UpperCorner"/>
</div>
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>
