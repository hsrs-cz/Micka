<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"   
  xmlns:ows="http://www.opengis.net/ows" >

<xsl:output method="html" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
<xsl:variable name="msg" select="document('portal.xml')/portal/messages[@lang=$lang]"/>

<xsl:template match="/">
<xsl:for-each select="//csw:SearchResults/*">
<div class="record">
<table>
<xsl:for-each select="dc:identifier">
  <tr>
    <th>Identifikátor</th>
    <td>
      <xsl:choose>
        <xsl:when test="substring(.,1,4)='http'">
          <a href="{.}"><xsl:value-of select="."/></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>  
        </xsl:otherwise>  
      </xsl:choose>    
    </td>
  </tr>
</xsl:for-each>

<xsl:for-each select="dc:title">
  <tr>
    <th>Název</th>
    <td><xsl:value-of select="."/></td>
  </tr>
</xsl:for-each>

<xsl:for-each select="dc:type">
  <tr>
    <th>Typ</th>
    <td><xsl:value-of select="."/></td>
  </tr>
</xsl:for-each>

<xsl:for-each select="dc:date">
  <tr>
    <th>Datum</th>
    <td><xsl:value-of select="."/></td>
  </tr>
</xsl:for-each>

<xsl:for-each select="dct:abstract">
  <tr>
    <th>Abstrakt</th>
    <td><xsl:value-of select="."/></td>
  </tr>
</xsl:for-each>

<xsl:if test="dc:subject!=''">
  <tr>
    <th>Subjekt (klíč. slova)</th>
    <td><xsl:for-each select="dc:subject"><xsl:value-of select="."/>, </xsl:for-each></td>
  </tr>
</xsl:if>

<xsl:for-each select="dc:creator">
  <tr>
    <th>Vytvořil</th>
    <td><xsl:value-of select="."/></td>
  </tr>
</xsl:for-each>

<xsl:for-each select="dc:contributor">
  <tr>
    <th>Přispěl</th>
    <td><xsl:value-of select="."/></td>
  </tr>
</xsl:for-each>

<xsl:for-each select="dc:publisher">
  <tr>
    <th>Publikoval</th>
    <td><xsl:value-of select="."/></td>
  </tr>
</xsl:for-each>

  <xsl:if test="*/ows:LowerCorner!=''">
    <tr>
      <th>Souřadnice</th>
      <td><xsl:value-of select="*/ows:LowerCorner"/>,<xsl:value-of select="*/ows:UpperCorner"/></td>
    </tr>  
  </xsl:if>
  
</table>    
</div>
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>
