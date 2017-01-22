<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8" />

<xsl:template match="/">
  <results>
  	<xsl:for-each select=".">
  		<identifier><xsl:value-of select="@uuid"/></identifier>
  		<xsl:for-each select=".">
   			<xsl:copy-of select='.'/>
   		</xsl:for-each>	
  	</xsl:for-each>
  </results>   
</xsl:template>

</xsl:stylesheet>