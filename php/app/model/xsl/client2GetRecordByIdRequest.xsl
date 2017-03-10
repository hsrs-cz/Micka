<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8"/>
<xsl:template match="/">

<csw:GetRecordById 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  outputSchema="{$outputSchema}" 
  outputFormat="application/xml" 
  service="CSW" 
  xsi:schemaLocation="http://www.opengis.net/cat/csw/2.0.2 http://schemas.opengis.net/csw/2.0.2/CSW-discovery.xsd" 
  version="2.0.2"> 

  <csw:Id><xsl:value-of select="$id"/></csw:Id>
  <csw:ElementSetName>full</csw:ElementSetName>  
</csw:GetRecordById>

</xsl:template>
</xsl:stylesheet>
