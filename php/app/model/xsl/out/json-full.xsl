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
<xsl:output method="text"/>

<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<!-- pro ISO 19139 zaznamy -->
    <xsl:template match="rec/*">
        <xsl:text>$rec=[</xsl:text>
        <xsl:apply-templates select="." mode="detect" />
        <xsl:text>];
        </xsl:text>
    </xsl:template>
 
    <xsl:template match="*" mode="detect">
        <xsl:choose>
            <xsl:when test="name(preceding-sibling::*[1]) = name(current()) and name(following-sibling::*[1]) != name(current())">
                    <xsl:apply-templates select="." mode="obj-content" />
                <xsl:text>]</xsl:text>
                <xsl:if test="count(following-sibling::*[name() != name(current())]) &gt; 0">, </xsl:if>
            </xsl:when>
            <xsl:when test="name(preceding-sibling::*[1]) = name(current())">
                    <xsl:apply-templates select="." mode="obj-content" />
                    <xsl:if test="name(following-sibling::*) = name(current())">, </xsl:if>
            </xsl:when>
            <xsl:when test="following-sibling::*[1][name() = name(current())]">
                <xsl:text>'</xsl:text><xsl:value-of select="local-name()"/><xsl:text>' => [</xsl:text>
                    <xsl:apply-templates select="." mode="obj-content" /><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="count(./child::*) > 0 or count(@*) > 0">
                <xsl:text>'</xsl:text><xsl:value-of select="local-name()"/>' => <xsl:apply-templates select="." mode="obj-content" />
                <xsl:if test="count(following-sibling::*) &gt; 0">, </xsl:if>
            </xsl:when>
            <xsl:when test="count(./child::*) = 0">
                <xsl:text>'</xsl:text><xsl:value-of select="local-name()"/>' => '<xsl:apply-templates select="."/><xsl:text>'</xsl:text>
                <xsl:if test="count(following-sibling::*) &gt; 0">, </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
 
    <xsl:template match="*" mode="obj-content">
        <xsl:text>[</xsl:text>
            <xsl:apply-templates select="@*" mode="attr" />
            <xsl:if test="count(@*) &gt; 0 and (count(child::*) &gt; 0 or text())">, </xsl:if>
            <xsl:apply-templates select="./*" mode="detect" />
            <xsl:if test="count(child::*) = 0 and text() and not(@*)">
                <xsl:text>'</xsl:text><xsl:value-of select="name()"/>' => '<xsl:value-of select="php:function('addslashes', string(text()))"/><xsl:text>'</xsl:text>
            </xsl:if>
            <xsl:if test="count(child::*) = 0 and text() and @*">
                <xsl:text>'text' => '</xsl:text><xsl:value-of select="php:function('addslashes', string(text()))"/><xsl:text>'</xsl:text>
            </xsl:if>
        <xsl:text>]</xsl:text>
        <xsl:if test="position() &lt; last()">, </xsl:if>
    </xsl:template>
 
    <xsl:template match="@*" mode="attr">
        <xsl:text>'</xsl:text><xsl:value-of select="local-name()"/>' => '<xsl:value-of select="php:function('addslashes', string(.))"/><xsl:text>'</xsl:text>
        <xsl:if test="position() &lt; last()">,</xsl:if>
    </xsl:template>
 
    <xsl:template match="node/@TEXT | text()" name="removeBreaks">
        <xsl:param name="pText" select="php:function('addslashes', string(.))"/>
        <xsl:choose>
            <xsl:when test="not(contains($pText, '&#xA;'))"><xsl:copy-of select="$pText"/></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(substring-before($pText, '&#xD;&#xA;'), ' ')"/>
                <xsl:call-template name="removeBreaks">
                    <xsl:with-param name="pText" select="substring-after($pText, '&#xD;&#xA;')"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
</xsl:template>
	

 <!-- pro multiligualni nazvy -->
  <xsl:template name="multi">
    <xsl:param name="el"/>
    <xsl:param name="lang"/>
    <xsl:param name="mdlang"/>
  
    <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale=concat('#locale-',$lang)]"/>	
    <xsl:choose>
    	<xsl:when test="string-length($txt)>0">
    	  <xsl:value-of select="php:function('addslashes', normalize-space($txt))"/>
    	</xsl:when>
    	<xsl:otherwise>
    	  <xsl:value-of select="php:function('addslashes', normalize-space($el/gco:CharacterString))"/>
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
</xsl:stylesheet>
