<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:csw="http://www.opengis.net/cat/csw"   
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:gco="http://www.isotc211.org/2005/gco" >
<xsl:output method="xml"/>
<xsl:template match="/">

<xsl:variable name="msg" select="document('portal.xml')/portal/messages[@lang=$lang]"/>
<xsl:variable name="cl" select="document(concat('codelists_', $lang, '.xml'))/map"/>

<rss version="2.0">
  <channel>
    <title>Micka news</title>
    <link>http://www.bnhelp.cz</link>
    <description>Novinky v systemu Micka</description>
    <language>cs</language>
    <managingEditor>kafka@email.cz</managingEditor>
    <webMaster>kafka@email.cz</webMaster>
    <copyright>HSRS</copyright>

  <xsl:for-each select="//gmd:MD_Metadata">
    <item>
      <title><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title"/></title>
      <link>http://www.bnhelp.cz/metadata/catClient_det.php?id=<xsl:value-of select="gmd:fileIdentifier"/>&amp;lang=<xsl:value-of select="$lang"/></link>
      <description><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract"/></description>
      <pubDate><xsl:value-of select="dateStamp"/></pubDate>
    </item>
  </xsl:for-each>

  </channel>
</rss>
</xsl:template>
</xsl:stylesheet>
