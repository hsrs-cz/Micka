<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8"/>
<xsl:template match="/">

<csw:Transaction
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  outputSchema="{$outputSchema}" 
  maxRecords="10" startPosition="1" 
  outputFormat="application/xml" 
  service="CSW" 
  resultType="results" version="2.0.2" requestId="micka2" debug='{$debug}'>

  <csw:Update> 
	  <xsl:copy-of select="//gmd:MD_Metadata" />
  </csw:Update>

</csw:Transaction>

</xsl:template>
</xsl:stylesheet>
