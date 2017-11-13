<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8" />

<xsl:template match="/">
  <results>
  	<xsl:for-each select="*">
        <FC_FeatureCatalogue>
            <id><xsl:value-of select="@uuid"/></id>
            <xsl:copy-of select="*"/>
        </FC_FeatureCatalogue>
    </xsl:for-each>	
  </results>   
</xsl:template>

</xsl:stylesheet>