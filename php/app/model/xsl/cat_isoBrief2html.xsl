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

<xsl:choose>
	<xsl:when test="//csw:SearchResults/@numberOfRecordsMatched>0">
     <span class='recFound'><a href="javascript:otevriZavri('{$theName}')" style='text-decoration:none'><xsl:value-of select="$msg/found"/></a>: <xsl:value-of select="//csw:SearchResults/@numberOfRecordsMatched"/>
     <xsl:if test="//csw:SearchResults/@numberOfRecordsMatched>//csw:SearchResults/@numberOfRecordsReturned">
       <span style="margin-left:20px">
       <xsl:if test="$startPosition>1">
         <xsl:variable name="lastSet" select="number($startPosition)-number($maxRecords)"/>
         <a style='text-decoration:none' href="javascript:drawContainer('{$theName}','{$lang}','{$lastSet}');"> &lt; </a>
       </xsl:if> 

       (<xsl:value-of select="$startPosition"/> - <xsl:value-of select="number($startPosition)+number(//csw:SearchResults/@numberOfRecordsReturned)-1"/>)

       <xsl:if test="//csw:SearchResults/@nextRecord>0">
         <a style="text-decoration:none" href="javascript:drawContainer('{$theName}','{$lang}','{//csw:SearchResults/@nextRecord}');"> &gt; </a>
       </xsl:if> 
       
       </span>
     </xsl:if>  
     </span>
  </xsl:when>
	<xsl:otherwise><span class='notFound'><xsl:value-of select="$msg/notFound"/></span></xsl:otherwise>
</xsl:choose>

<div style="display:none;">
<xsl:for-each select="//gmd:MD_Metadata">
  <table class='odpx' width="100%">
  <tr><td>
    <xsl:variable name="trida">
    <xsl:choose>
			<xsl:when test="string-length(gmd:identificationInfo/gmd:MD_ServiceIdentification)>0">service</xsl:when>
			<xsl:when test="string-length(gmd:identificationInfo/gmd:SV_ServiceIdentification)>0">service</xsl:when>
			<xsl:when test="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='application'">sw</xsl:when>
			<xsl:otherwise>data</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
  <a href="catClient_det.php?serviceName={$theName}&amp;id={normalize-space(gmd:fileIdentifier)}&amp;lang={$lang}" class="{$trida}" target="csw_detail">
		<xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
	</a>	
  <xsl:text> </xsl:text> 
  <xsl:if test="contains(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage,'WMS')">
    <a class='mapa' href="javascript:showMap('{gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage}');"><xsl:value-of select="$msg/map"/></a>
  </xsl:if>
  </td></tr>
  <tr><td colspan='2'>
  <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString">
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
