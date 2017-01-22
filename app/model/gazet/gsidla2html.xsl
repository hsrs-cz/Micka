<?xml version="1.0" ?><!-- DWXMLSource="../wfs_okresy.xml" -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gml="http://www.opengis.net/gml" xmlns:ms="http://mapserver.gis.umn.edu/mapserver" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wfs="http://www.opengis.net/wfs">
<xsl:output method="html" encoding="utf-8" />

<xsl:template match="/">

<xsl:for-each select="wfs:FeatureCollection/gml:featureMember/ms:sidla">
  <li><a href="javascript:gazPoly('{translate(translate(translate(normalize-space(ms:msGeometry/gml:Point/gml:coordinates),',',';'),' ',','),';',' ')}');"><xsl:value-of select="ms:NAZOB"/></a> (<xsl:value-of select="ms:NAZOK"/>)</li>
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>
