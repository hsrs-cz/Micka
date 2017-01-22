<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:gts="http://www.isotc211.org/2005/gts"
>
  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

  	<xsl:template match="/rec">
  		<gmd:MD_Metadata>
			<xsl:choose>
				<xsl:when test="$USER = 'guest' or $USER =''">
	   				<xsl:apply-templates select="*/*[name()!='gmi:acquisitionInformation']"/>
	   			</xsl:when>
	   			<xsl:otherwise>
	   				<xsl:copy-of select="*/*[name()!='gmi:acquisitionInformation']" />
	   			</xsl:otherwise>
	   		</xsl:choose>
   		</gmd:MD_Metadata>
  	</xsl:template>
      
    <xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>
	
	<!-- elements excluded from output -->
	<xsl:template match="gmd:onLine[*/gmd:name/*='OUT' or */gmd:name/*='INT']">
    	<!--  xsl:copy-of select="*[not(self::thisElement)]"/-->
	</xsl:template>

</xsl:stylesheet>
