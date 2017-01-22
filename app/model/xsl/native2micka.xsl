<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8" />
<!--<xsl:template match="//MD_Metadata">
  <MD_Metadata>
    <pokus>
      <fileIdentifier><xsl:value-of select="@fileIdentifier"/></fileIdentifier>
      <xsl:copy-of select='/.' />
    </pokus>
  </MD_Metadata>
</xsl:template>
-->


<xsl:template match="/">
   <xsl:copy-of select='.'/>
</xsl:template>

</xsl:stylesheet>
