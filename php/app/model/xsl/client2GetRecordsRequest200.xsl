<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8"/>
<xsl:template match="/">

<xsl:variable name="os">
  <xsl:choose>
    <xsl:when test="$typeNames='gmd:MD_Metadata'">csw:profile</xsl:when>
    <xsl:otherwise>csw:ogccore</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<csw:GetRecords 
  xmlns:csw="http://www.opengis.net/cat/csw" 
  xmlns:dc="http://www.purl.org/dc/elements/1.1/" 
  xmlns:dct="http://www.purl.org/dc/terms/" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  outputSchema="{$os}" 
  maxRecords="{$maxRecords}" startPosition="{$startPosition}" 
  outputFormat="application/xml" 
  service="CSW" 
  resultType="RESULTS" version="2.0.0" requestId="{$id}" debug="{$debug}"> 

	<xsl:if test="$hopCount>0"><csw:DistributedSearch hopCount="{$hopCount}" /></xsl:if>
	<csw:Query typeNames="csw:Record">
		<csw:ElementSetName>full</csw:ElementSetName>
		<csw:Constraint version="1.1.0">

  		<xsl:copy-of select="." />

		</csw:Constraint>
	</csw:Query>
</csw:GetRecords>

</xsl:template>
</xsl:stylesheet>
