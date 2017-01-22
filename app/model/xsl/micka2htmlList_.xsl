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

<xsl:variable name="msg" select="document(concat('client/labels-',$lang,'.xml'))/messages/msg"/>  
<xsl:variable name="cl" select="document(concat('codelists_', $lang, '.xml'))/map"/>
<xsl:variable name="MICKA_URL" select="''"/>

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
		<xsl:with-param name="url" select="concat($MICKA_URL, '?service=CSW&amp;request=GetRecords&amp;query=',$CONSTRAINT,'&amp;format=text/html&amp;language=',$lang,'&amp;maxrecords=',$MAXRECORDS,'&amp;sortby=',$SORTBY,'&amp;startposition')"/>
	</xsl:call-template>  	
	
</xsl:template>

<xsl:include href="client/common_cli.xsl" />
<xsl:include href="htmlList.xsl" />

<xsl:template name="sorter">
	<xsl:value-of select="$msg[@eng='sortby']"/>: <br/>
	<xsl:variable name="url"></xsl:variable> 
	<select id="sort-select" class="x-form-field x-form-text" style="height:21px; font-size:11px; padding-right:0px;" onchange="changeSort('sort-select','sortdir-select','{$CONSTRAINT}','{$lang}','{$MAXRECORDS}');">
		<option value="title">
  		    <xsl:if test="$SORTBY='title'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="$msg[@eng='title2']"/>
        </option>
		<option value="date"><xsl:if test="contains($SORTBY,'date')">
            <xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="$msg[@eng='update2']"/>
        </option>
		<option value="bbox">
            <xsl:if test="contains($SORTBY,'bbox')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
            <xsl:value-of select="$msg[@eng='sbbox']"/>
        </option>
	</select> 
	<select id="sortdir-select" class="x-form-field x-form-text" style="height:21px; font-size:11px; padding-right:0px;" onchange="changeSort('sort-select','sortdir-select','{$CONSTRAINT}','{$lang}','{$MAXRECORDS}');">
		<option value="A">
			<xsl:if test="$SORTORDER='ASC'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="$msg[@eng='ASC']"/></option>
		<option value="D"><xsl:if test="$SORTORDER='DESC'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="$msg[@eng='DESC']"/></option>
	</select>
</xsl:template>


</xsl:stylesheet>
