<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:gmd="http://www.isotc211.org/2005/gmd"
xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gsr="http://www.isotc211.org/2005/gsr" 
xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gts="http://www.isotc211.org/2005/gts" 
xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

<xsl:output method="html" encoding="UTF-8"/>
<xsl:variable name="codeLists" select="document('codelists_cze.xml')/map" />

<xsl:template match="/">
 <html>
	  <head>
	    <style>
	    body {font-size:13px;}
	    td {font-size:13px;}	    
	    h1 {text-align:center; }
	    h2 {text-align:center; margin-top:40px; }
	    h3 {margin-top:25px; margin-bottom:7px; font-size:15px;}
	    .t {border: 1px solid black; padding:2px; font-weight:bold; font-size:13px;}
	    </style>
	  </head>
		<body> 
<xsl:for-each select="//gmd:MD_Metadata">
<h1>Pasport č. <xsl:value-of select="$cislo"/> údaje o území</h1>

<h3>poskytnutý krajskému úřadu / úřadu územního plánování</h3> 
<div class="t"><xsl:value-of select="$komu"/></div>

<h2>I. oddíl – poskytovatel údaje (identifikační údaje)</h2>

Kontaktní info správce

<h3>1. Jméno a příjmení / název</h3>
<div class="t">
  <xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact//gmd:organisationName"/>
</div>

<h3>2. Identifikační číslo nebo obdobný údaj</h3>
<div class="t" style="width:260px">
  <xsl:value-of select="substring-after(gmd:identificationInfo/*/gmd:pointOfContact//gmd:organisationName,'IČ:')"/>
</div>

<h3>3. Sídlo poskytovatele údaje a kontakt</h3>

<table>
  <tr><td>a) obec</td><td>b) PSČ</td></tr>
  <tr><td class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo//gmd:city"/></td><td class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo//gmd:postalCode"/></td></tr>

  <tr><td colspan="2">c) ulice (část obce) d) číslo popisné / orientační</td></tr>
  <tr><td colspan="2" class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo//gmd:deliveryPoint"/></td></tr>
  
  <tr><td colspan="2">e) jméno a příjmení a funkce oprávněné osoby</td></tr>
  <tr><td colspan="2" class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact//gmd:individualName"/><xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact//gmd:position"/></td></tr>

  <tr><td>f) číslo telefonu</td><td>g) e-mail</td></tr>
  <tr><td class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo//gmd:phone"/></td><td class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo//gmd:electronicMailAddress"/></td></tr>

</table>

<h2>II. oddíl – údaj o území</h2>

<h3>4. Název nebo popis údaje o území</h3>
<div class="t" style="font-weight:bold font-size: 16px;">
  <xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title"/>
</div>

<h3>5. Vznik údaje o území</h3>
<div>
  <table>
  <tr><td>a) právní předpis / správní rozhodnutí / jiný	b) ze dne c) vydal</td></tr>
  <tr><td class="t"><xsl:value-of select="gmd:identificationInfo//gmd:purpose"/> </td></tr>

  </table>
</div>

<h3>6. Územní lokalizace údaje o území</h3>
<div class="t">
  <xsl:value-of select="gmd:identificationInfo//gmd:EX_Extent/gmd:description"/>
</div>

<h3>7. Předání údaje o území</h3>
<div>
  <table>
  <tr><td>a) název dokumentu	</td><td> b) datum zpracování</td></tr>
  <tr><td class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title"/></td><td class="t"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date//gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='creation']/../../gmd:date"/></td></tr>

  <tr><td colspan="2">d) měřítko mapového podkladu, nad kterým byl údaj o území zobrazen</td></tr>
  <tr><td colspan="2" class="t">1 : <xsl:value-of select="gmd:identificationInfo//gmd:spatialResolution//gmd:denominator"/></td></tr>

  <tr><td colspan="2">e) souřadnicový systém zobrazení</td></tr>
  <tr><td colspan="2" class="t"><xsl:value-of select="gmd:referenceSystemInfo//gmd:RS_Identifier/gmd:codeSpace"/>:<xsl:value-of select="gmd:referenceSystemInfo//gmd:RS_Identifier/gmd:code"/></td></tr>

  <tr><td colspan="2">f) další metadata</td></tr>
  <tr><td>formát</td><td>
  <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat">
    <xsl:value-of select="gmd:MD_Format/gmd:name"/><xsl:text> </xsl:text><xsl:value-of select="gmd:MD_Format/gmd:version"/>, 
  </xsl:for-each>
  </td></tr>
  <tr><td>typ</td><td>
  <xsl:variable name="spat" select="//gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue"/>
  <xsl:value-of select="$codeLists/spatialRepresentationType/value[@name=$spat]"/><xsl:text>: </xsl:text>
  <xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation//gmd:MD_GeometricObjectTypeCode">
    <xsl:variable name="geom" select="."/>
    <xsl:value-of select="$codeLists/geometricObjectType/value[@name=$geom]"/><xsl:text>, </xsl:text>
  </xsl:for-each>
  </td></tr>
  <tr><td>nosič</td><td>
    <xsl:variable name="nosic" select="//gmd:MD_Medium/gmd:name/gmd:MD_MediumNameCode/@codeListValue"/>
    <xsl:value-of select="$codeLists/name/value[@name=$nosic]"/></td></tr>
  </table>
</div>


<h3>8. Prohlášení poskytovatele údaje</h3>

<div>
Prohlašuji, že všechny informace, uvedené v tomto pasportu a dokumentaci údaje 
o území jsou správné, úplné a aktuální k datu předání. Jsem si vědom sankčních 
důsledků v případě nesprávně či neúplně předaného údaje podle § 28 odst. 3 stavebního zákona.
</div>

<br/>
jméno a příjmení a funkce oprávněné osoby poskytovatele údaje
<!-- bere 1. kontakt - TODO na ur4. funkci !!! -->
<div class="t">
  <xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact//gmd:individualName"/><xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact//position"/>
</div>

<div style="margin-top:50px; border-top: 1px dotted black; width: 400px; text-align:center; float:right;">
  datum a podpis oprávněné osoby poskytovatele údaje
</div>
</xsl:for-each>
</body>
</html>

</xsl:template>
</xsl:stylesheet>
