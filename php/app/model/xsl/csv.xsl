<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:ows="http://www.opengis.net/ows"
  xmlns="http://www.w3.org/2005/Atom"
  xmlns:georss="http://www.georss.org/georss" 
  xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
>
<xsl:output method="html" encoding="utf-16" omit-xml-declaration="yes"/>

<xsl:variable name="msg" select="document(concat('client/labels-',$LANGUAGE,'.xml'))/messages/msg"/>  
<xsl:variable name="auth" select="document(concat('../../cfg/cswConfig-',$LANGUAGE,'.xml'))"/>

<xsl:template match="/">UUID&#x9;Kód&#x9;Název&#x9;Název eng&#x9;Typ zdroje&#x9;Typ aplikace/služby&#x9;Kontakt&#x9;Kontakt metadata&#x9;Stav&#x9;Pro INSPIRE&#x9;Validace&#x9;Datum editace&#x9;Editoval&#x9;Datum vytvoření&#x9;Vytvořil
<xsl:for-each select="results">
	    	<xsl:apply-templates/>
</xsl:for-each>
</xsl:template>

<xsl:template match="rec/gmd:MD_Metadata|rec/gmi:MI_Metadata" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gco="http://www.isotc211.org/2005/gco">
<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"
/><xsl:variable name="dtype" select="../@data_type"
/><xsl:variable name="valid" select="../@valid"
/><xsl:variable name="inspire" select="gmd:dataQualityInfo/*/gmd:report//gmd:specification/*/gmd:title"
/><xsl:value-of select="gmd:fileIdentifier" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code" 
/><xsl:text>&#x9;</xsl:text><xsl:call-template name="multi2">
	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
	<xsl:with-param name="lang" select="'cze'"/>
	<xsl:with-param name="mdlang" select="$mdlang"/>
</xsl:call-template><xsl:text>&#x9;</xsl:text><xsl:call-template name="multi2">
	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
	<xsl:with-param name="lang" select="'eng'"/>
	<xsl:with-param name="mdlang" select="$mdlang"/>
</xsl:call-template><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:hierarchyLevel" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:identificationInfo/*/srv:serviceType" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"
/><xsl:text>&#x9;</xsl:text><xsl:choose>
	<xsl:when test="$dtype=2">portál</xsl:when>
	<xsl:when test="$dtype=1">veřejný</xsl:when>
	<xsl:when test="$dtype=0">neveřejný</xsl:when>
	<xsl:when test="$dtype=-1">rozpracovaný</xsl:when>
</xsl:choose><xsl:text>&#x9;</xsl:text><xsl:choose>
	<xsl:when test="gmd:hierarchyLevelName/gco:CharacterString='http://geoportal.gov.cz/inspire'">Ano</xsl:when>
	<xsl:otherwise>Ne</xsl:otherwise>
</xsl:choose><xsl:text>&#x9;</xsl:text><xsl:choose>
	<xsl:when test="$valid=0">Ne</xsl:when>
	<xsl:when test="$valid=1">Částečně</xsl:when>
	<xsl:when test="$valid=2">Ano</xsl:when>
</xsl:choose><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:dateStamp"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="../@last_update_user"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="substring-before(../@create_date,' ')" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="../@create_user" /><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/">
<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"
/><xsl:variable name="dtype" select="../@data_type"
/><xsl:variable name="valid" select="../@valid"
/><xsl:variable name="inspire" select="//gmd:specification"
/><xsl:value-of select="../@uuid" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="name" 
/><xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text><xsl:text>&#x9;</xsl:text>FC<xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"
/><xsl:text>&#x9;</xsl:text><xsl:choose>
	<xsl:when test="$dtype=2">portál</xsl:when>
	<xsl:when test="$dtype=1">veřejný</xsl:when>
	<xsl:when test="$dtype=0">neveřejný</xsl:when>
	<xsl:when test="$dtype=-1">rozpracovaný</xsl:when>
</xsl:choose><xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text
><xsl:value-of select="../@last_update_date"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="../@last_update_user"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="substring-before(../@create_date,' ')" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="../@create_user" /><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="rec/featureCatalogue" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gco="http://www.isotc211.org/2005/gco">
<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"
/><xsl:variable name="dtype" select="../@data_type"
/><xsl:variable name="valid" select="../@valid"
/><xsl:variable name="inspire" select="//gmd:specification"
/><xsl:value-of select="../@uuid" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="name" 
/><xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text><xsl:text>&#x9;</xsl:text>FC<xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"
/><xsl:text>&#x9;</xsl:text><xsl:choose>
	<xsl:when test="$dtype=2">portál</xsl:when>
	<xsl:when test="$dtype=1">veřejný</xsl:when>
	<xsl:when test="$dtype=0">neveřejný</xsl:when>
	<xsl:when test="$dtype=-1">rozpracovaný</xsl:when>
</xsl:choose><xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text>---<xsl:text>&#x9;</xsl:text
><xsl:value-of select="../@last_update_date"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="../@last_update_user"
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="substring-before(../@create_date,' ')" 
/><xsl:text>&#x9;</xsl:text><xsl:value-of select="../@create_user" /><xsl:text></xsl:text>
</xsl:template>

<!-- pro multiligualni nazvy -->
<xsl:template name="multi2" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
  <xsl:param name="el"/>
  <xsl:param name="lang"/>
  <xsl:param name="mdlang"/>
  <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[contains(@locale,$lang)]"/>	
  <xsl:variable name="uri" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[contains(@locale,'uri')]"/>	
  <xsl:choose>
  	<xsl:when test="string-length($txt)>0">
		<xsl:call-template name="lf2br">
   			<xsl:with-param name="str" select="$txt"/>
		</xsl:call-template>   		
  	</xsl:when>
  	<xsl:otherwise>
  		<xsl:if test="$lang=$mdlang">
			<xsl:call-template name="lf2br">
   				<xsl:with-param name="str" select="$el/gco:CharacterString"/>
			</xsl:call-template>
		</xsl:if>   		
  	</xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:include href="client/common_cli.xsl" />
  
</xsl:stylesheet>
