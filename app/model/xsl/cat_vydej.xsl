<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:gml="http://www.opengis.net/gml"   
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:gco="http://www.isotc211.org/2005/gco" >
<xsl:output method="html"/>

<xsl:variable name="msg" select="document('portal.xml')/portal/messages[@lang=$lang]"/>

<xsl:template match="/">

<xsl:for-each select="//gmd:MD_Metadata">
  <!-- pouze data -->
  <xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification!=''">
    <xsl:variable name="id" select="gmd:fileIdentifier"/>
    $result['<xsl:value-of select="$id"/>']['title'] = '<xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title"/>';
    <xsl:for-each select="gmd:distributionInfo//gmd:MD_DigitalTransferOptions//gmd:URL">
      <xsl:if test="substring(.,1,4)='file'">
        $result['<xsl:value-of select="$id"/>']['data']  = '<xsl:value-of select="."/>';
      </xsl:if>  
    </xsl:for-each>
  </xsl:if>
</xsl:for-each>
  

</xsl:template>
</xsl:stylesheet>
