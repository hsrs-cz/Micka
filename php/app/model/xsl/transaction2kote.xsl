<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xsi:schemaLocation="http://www.opengis.net/cat/csw/2.0.2
c:\dokumentace\ogc\catalog\csw\2.0.2\CATALO~1.2SC\csw\2.0.2\CSW-publication.xsd">
<xsl:output method="html" encoding="utf-8"/>
<xsl:template match="/">

<html>
<head>
</head>
<body>

  Vloženo: <xsl:value-of select="//csw:TransactionSummary/csw:totalUpdated"/><br/>


<xsl:for-each select="//csw:BriefRecord">
  identifikátor: <xsl:value-of select="dc:identifier"/>  <br/>
  název: <xsl:value-of select="dc:title"/>  <br/>  
</xsl:for-each>

</body>
</html>

</xsl:template>
</xsl:stylesheet>
