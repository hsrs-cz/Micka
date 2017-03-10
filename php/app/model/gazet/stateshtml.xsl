<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gml="http://www.opengis.net/gml" xmlns:ms="http://mapserver.gis.umn.edu/mapserver" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wfs="http://www.opengis.net/wfs">
<xsl:output method="html" encoding="utf-8" />

<xsl:template match="/">

<xsl:for-each select="wfs:FeatureCollection/gml:featureMember/ms:states">
	<xsl:value-of select="ms:NAME"/>
	<xsl:for-each select="ms:msGeometry/gml:Polygon">
  		:MULTIPOLYGON(((<xsl:value-of select="translate(translate(translate(normalize-space(gml:outerBoundaryIs/gml:LinearRing/gml:coordinates),',',';'),' ',','),';',' ')" />)<xsl:for-each select="gml:innerBoundaryIs">,(<xsl:value-of select="translate(translate(translate(normalize-space(gml:LinearRing/gml:coordinates),',',';'),' ',','),';',' ')" />)</xsl:for-each>))|
  	</xsl:for-each>
	<xsl:for-each select="ms:msGeometry/gml:MultiPolygon">
  		:MULTIPOLYGON(<xsl:for-each select="gml:polygonMember/gml:Polygon"><xsl:if test="position()!=1">,</xsl:if>((<xsl:value-of select="translate(translate(translate(normalize-space(gml:outerBoundaryIs/gml:LinearRing/gml:coordinates),',',';'),' ',','),';',' ')" />)<xsl:for-each select="gml:innerBoundaryIs">,(<xsl:value-of select="translate(translate(translate(normalize-space(gml:LinearRing/gml:coordinates),',',';'),' ',','),';',' ')" />)</xsl:for-each>)</xsl:for-each>)|
  	</xsl:for-each>	
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>