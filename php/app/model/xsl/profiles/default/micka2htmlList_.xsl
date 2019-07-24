<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml/3.2"   
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:gco="http://www.isotc211.org/2005/gco" >
<xsl:output method="html"/>

<xsl:variable name="msg" select="document(concat('../../client/labels-',$lang,'.xml'))/messages/msg"/>  
<xsl:variable name="cl" select="document('../../config/codelists.xml')/map"/>

<xsl:template match="results">
	<h1>
		<xsl:choose>
			<xsl:when test="@numberOfRecordsMatched>0">
	     		Metadata <span class="badge"> <xsl:value-of select="@numberOfRecordsMatched"/> </span>
	  		</xsl:when>
			<xsl:otherwise><span class='notFound'><xsl:value-of select="$msg[@eng='not found']"/></span></xsl:otherwise>
		</xsl:choose>
	</h1>
				
	<xsl:apply-templates/>
		
	<xsl:call-template name="paginator">
		<xsl:with-param name="matched" select="@numberOfRecordsMatched"/>
		<xsl:with-param name="returned" select="@numberOfRecordsReturned"/>
		<xsl:with-param name="next" select="@nextRecord"/>
		<xsl:with-param name="url" select="concat($mickaURL, '/?service=CSW&amp;request=GetRecords&amp;query=',$CONSTRAINT,'&amp;format=text/html&amp;language=',$lang,'&amp;maxrecords=',$MAXRECORDS,'&amp;sortby=',$SORTBY,'&amp;startposition')"/>
	</xsl:call-template>  	
	
</xsl:template>

<xsl:include href="../../client/common_cli.xsl" />
<xsl:include href="htmlList.xsl" />


</xsl:stylesheet>
