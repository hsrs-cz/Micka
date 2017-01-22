<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:srv="http://www.isotc211.org/2005/srv">
<xsl:output method="html" encoding="UTF-8"/>

   	<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
   	<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

	<xsl:template match="/results">
   		$records = <xsl:value-of select="@numberOfRecordsMatched"/>;
        $returned = <xsl:value-of select="@numberOfRecordsReturned"/>;
        $md = array();
        <xsl:apply-templates/>
  	</xsl:template>

<xsl:template match="gmd:MD_Metadata">
  $record['id'] = '<xsl:value-of select="gmd:fileIdentifier"/>';
  $record['title'] = '<xsl:call-template name="escApos"><xsl:with-param name="s" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString"/></xsl:call-template>';
  $record['stype'] = '<xsl:value-of select="gmd:identificationInfo//srv:serviceType"/>';
  <xsl:choose>
  
    <!-- spravna adresa - getCapabilities -->
    <xsl:when test="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(translate(*/gmd:linkage/gmd:URL,$upper,$lower),'service=wms') and contains(translate(*/gmd:linkage/gmd:URL,$upper,$lower),'request=getcapabilities')]/*/gmd:linkage/gmd:URL!=''">
      $record['url'] = '<xsl:value-of select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(translate(*/gmd:linkage/gmd:URL,$upper,$lower),'service=wms') and contains(translate(*/gmd:linkage/gmd:URL,$upper,$lower),'request=getcapabilities')]/*/gmd:linkage/gmd:URL"/>';
    </xsl:when>

    <!-- test pres protocol -->
    <xsl:when test="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(translate(*/gmd:protocol,$upper,$lower),'wms')]/*/gmd:linkage/gmd:URL!=''">
      $record['url'] = '<xsl:value-of select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(translate(*/gmd:protocol,$upper,$lower),'wms')]/*/gmd:linkage/gmd:URL"/>';
    </xsl:when>

     <!-- test pres operationMetadata -->
    <xsl:when test="gmd:identificationInfo//srv:containsOperations/*[srv:operationName/*='GetCapabilities']/srv:connectPoint/*/gmd:linkage/gmd:URL!=''">
      $record['url'] = '<xsl:value-of select="gmd:identificationInfo//srv:containsOperations/*[srv:operationName/*='GetCapabilities']/srv:connectPoint/*/gmd:linkage/gmd:URL"/>';
    </xsl:when>

    <!-- jinak vezme prvni URL -->            
    <xsl:otherwise>
      $record['url'] = '<xsl:value-of select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/gmd:URL"/>';
    </xsl:otherwise>
  </xsl:choose>

  
  $md[] = $record;   
</xsl:template>

<xsl:template name="escApos">
 <xsl:param name="s"/>
<xsl:variable name="apos" select='"&apos;"' />
<xsl:choose>
 <xsl:when test='contains($s, $apos)'>
  <xsl:value-of select="substring-before($s,$apos)" />
	<xsl:text>\'</xsl:text>
	<xsl:call-template name="escape-apos">
	 <xsl:with-param name="s" select="substring-after($s, $apos)" />
	</xsl:call-template>
 </xsl:when>
 <xsl:otherwise>
  <xsl:value-of select="$s" />
 </xsl:otherwise>
</xsl:choose>
</xsl:template>
      
</xsl:stylesheet>