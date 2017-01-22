<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:csw="http://www.opengis.net/cat/csw" 
  xmlns:gmd="http://schemas.opengis.net/iso19115full" 
  xmlns:srv="http://schemas.opengis.net/iso19119"
  xmlns:gco="http://metadata.dgiwg.org/smXML"
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
>

<xsl:output method="html"/>

<xsl:variable name="msg" select="document('portal.xml')/portal/messages[@lang=$lang]"/>

<xsl:template match="/">

<xsl:choose>
	<xsl:when test="//csw:SearchResults/@numberOfRecordsMatched>0">
     <span class='recFound'><a href="javascript:otevriZavri('{$theName}')" style='text-decoration:none'><xsl:value-of select="$msg/found"/></a>: <xsl:value-of select="//csw:SearchResults/@numberOfRecordsMatched"/></span>
  </xsl:when>
	<xsl:otherwise><span class='notFound'><xsl:value-of select="$msg/notFound"/></span></xsl:otherwise>
</xsl:choose>
<div style="display:none;">
<xsl:for-each select="//gmd:MD_Metadata">
  <table class='odpx' width="100%">
  <tr><td>
    <xsl:variable name="trida">
    <xsl:choose>
			<xsl:when test="gmd:hierarchyLevel/gco:MD_ScopeCode/@codeListValue='service'">service</xsl:when>
			<xsl:when test="string-length(gmd:identificationInfo/gmd:SV_ServiceIdentification)>0">service</xsl:when>
			<xsl:when test="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='software'">sw</xsl:when>
			<xsl:otherwise>data</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
  <a href="/metadata/catClient_det.php?serviceName={$theName}&amp;id={normalize-space(gmd:fileIdentifier)}&amp;lang={$lang}" class="{$trida}" target="csw_detail">
		<xsl:value-of select="gmd:identificationInfo/*/gco:citation/gco:CI_Citation/gco:title"/>
	</a>	
  <xsl:text> </xsl:text> 
  <xsl:if test="contains(gmd:identificationInfo//srv:serviceType,'WMS')">
    <a class='mapa' href="javascript:showMap('{gmd:distributionInfo/gco:MD_Distribution/gco:transferOptions/gco:MD_DigitalTransferOptions/gco:onLine/gco:CI_OnlineResource/gco:linkage}');"><xsl:value-of select="$msg/map"/></a>
  </xsl:if>
  </td></tr>
  <tr><td colspan='2'>
  <xsl:for-each select="gmd:identificationInfo/*/gco:abstract">
    <xsl:value-of select="substring(.,0,400)"/>...  
  </xsl:for-each>
  <xsl:for-each select="gmd:identificationInfo/gmd:MD_ServiceIdentification/gmd:containsOperations">
    <xsl:value-of select="."/> |
  </xsl:for-each>
  </td></tr>
  </table>
</xsl:for-each>
</div>

</xsl:template>
</xsl:stylesheet>
