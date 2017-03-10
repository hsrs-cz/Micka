<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:template match="/results" xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml/3.2" >
    <xsl:apply-templates />
  </xsl:template>
   
   <xsl:include href="micka2_19139.xsl" />   

</xsl:stylesheet>
