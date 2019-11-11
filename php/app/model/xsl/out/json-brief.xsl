<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"   
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:srv="http://www.isotc211.org/2005/srv" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd"  
  xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
  xmlns:gml="http://www.opengis.net/gml/3.2" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:php="http://php.net/xsl">
<xsl:output method="html"/>

<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <!-- pro ISO 19139 zaznamy -->
<xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata">
  	<xsl:variable name="mdlang" select="gmd:language/*/@codeListValue"/>
    $rec = array();
	$rec['id'] = "<xsl:value-of select="normalize-space(gmd:fileIdentifier)"/>";	
   	$rec['type']="<xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/>";

	$rec['title'] = <xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template> 
	$rec['abstract'] = <xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
		      	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>
    $json['records'][] =$rec;
</xsl:template>	

<!-- Feature catalogue -->
<xsl:template match="gfc:FC_FeatureCatalogue" xmlns:gfc="http://www.isotc211.org/2005/gfc" xmlns:gmx="http://www.isotc211.org/2005/gmx">
    <xsl:variable name="mdlang" select="../@lang"/>
    $rec['trida']='fc';
    $rec['title'] = <xsl:call-template name="multi">
			   		<xsl:with-param name="el" select="gmx:name"/>
			   		<xsl:with-param name="lang" select="$lang"/>
			   		<xsl:with-param name="mdlang" select="$mdlang"/>
			  	</xsl:call-template> 
    $rec['abstract'] = <xsl:call-template name="multi">
		   		<xsl:with-param name="el" select="gmx:scope"/>
		   		<xsl:with-param name="lang" select="$lang"/>
		   		<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>
    $rec['id'] = "<xsl:value-of select="../@uuid"/>";
    $json['records'][] =$rec;
</xsl:template>	
	
	<!-- pro DC zaznamy -->
  <xsl:template match="csw:Record" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/">
		$rec = array();
	  	$rec['trida'] = "<xsl:value-of select="dc:type"/>";
		$rec['id'] = "<xsl:value-of select="dc:identifier[substring(.,1,4)!='http']"/>";
		$rec['title'] = "<xsl:value-of select="php:function('addslashes', normalize-space(dc:title))"/>";
		$rec['abstract'] = "<xsl:value-of select="php:function('addslashes', normalize-space(dct:abstract))"/>";
		if(!$rec['abstract']) $rec['abstract'] = "<xsl:value-of select="php:function('addslashes', normalize-space(dc:description))"/>";
		$rec['link'] = "<xsl:value-of select="dc:identifier[substring(.,1,4)='http']"/>";
		$rec['bbox'] = "<xsl:value-of select="ows:BoundingBox/ows:LowerCorner"/><xsl:text> </xsl:text><xsl:value-of select="ows:BoundingBox/ows:UpperCorner"/>";
   		$json['records'][] =$rec;
	</xsl:template> 
	

 <!-- multilingual fields -->
<xsl:template name="multi">
    <xsl:param name="el"/>
    <xsl:param name="lang"/>
    <xsl:param name="mdlang"/>
  
    <xsl:choose>
        <xsl:when test="$lang">
            <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale=concat('#locale-',$lang)]"/>	
            "<xsl:choose>
                <xsl:when test="string-length($txt)>0">
                  <xsl:value-of select="php:function('addslashes', normalize-space($txt))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="php:function('addslashes', normalize-space($el/gco:CharacterString))"/>
                </xsl:otherwise>
            </xsl:choose>";
        </xsl:when>
        <xsl:otherwise>[
            '<xsl:value-of select="$mdlang"/>' =<xsl:text disable-output-escaping="yes">&gt;</xsl:text> "<xsl:value-of select="php:function('addslashes', normalize-space($el/gco:CharacterString))"/>"
            <xsl:for-each select="$el/*/gmd:textGroup/*">
                ,'<xsl:value-of select="substring-after(@locale,'-')"/>' =<xsl:text disable-output-escaping="yes">&gt;</xsl:text> "<xsl:value-of select="php:function('addslashes', normalize-space(.))"/>"
            </xsl:for-each>
            ];
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

  
</xsl:stylesheet>
