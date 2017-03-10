<!-- DWXMLSource="file:///C|/Inetpub/wwwroot/xml/okresy.shp.xml" -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="utf-8"/>
  <xsl:template match="/">
  <results>
    <featureCatalogue>
      <xsl:for-each select="metadata/eainfo/detailed">
        <featureType>
          <typeName><xsl:value-of select="enttyp/enttypl"/></typeName>
          <xsl:for-each select="attr">
            <featureAttribute>
              <memberName><xsl:value-of select="attrlabl"/></memberName>
              <definition><xsl:value-of select="attrdef"/></definition>
              <valueType><xsl:value-of select="attrtype"/>
                <xsl:if test="attwidth>'0'">(<xsl:value-of select="attwidth"/><xsl:if test="atnumdec">.<xsl:value-of select="atnumdec"/></xsl:if>)</xsl:if>
              </valueType>
            </featureAttribute>
          </xsl:for-each>
          <xsl:value-of select="attrlabl"/> </featureType>
      </xsl:for-each>
    </featureCatalogue>
  </results>  
  </xsl:template>
</xsl:stylesheet>
