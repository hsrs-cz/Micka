<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns="http://www.isotc211.org/2005/gmd" xmlns:sch="http://www.ascc.net/xml/schematron" 
xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gsr="http://www.isotc211.org/2005/gsr" 
xmlns:gss="http://www.isotc211.org/2005/gss" xmlns:gts="http://www.isotc211.org/2005/gts" 
xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="html" encoding="UTF-8"/>

<xsl:variable name="codeLists" select="document('include/xsl/codelists_cze.xml')/map" />


	<xsl:template match="/md">
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
<h1>Pasport č. <xsl:value-of select="cislo"/> údaje o území</h1>

<h3>poskytnutý krajskému úřadu / úřadu územního plánování</h3> 
<div class="t"><xsl:value-of select="komu"/></div>

<h2>I. oddíl – poskytovatel údaje (identifikační údaje)</h2>

Kontaktní info správce

<h3>1. Jméno a příjmení / název</h3>
<div class="t">
  <xsl:value-of select="identification/contact/organisation"/>
</div>

<h3>2. Identifikační číslo nebo obdobný údaj</h3>
<div class="t" style="width:260px">
  <xsl:value-of select="ICO"/>
</div>

<h3>3. Sídlo poskytovatele údaje a kontakt</h3>
<table>
  <tr><td>a) obec</td><td>b) PSČ</td></tr>
  <tr><td class="t"><xsl:value-of select="identification/contact/city"/></td><td class="t"><xsl:value-of select="identification/contact/postalCode"/></td></tr>

  <tr><td colspan="2">c) ulice (část obce) d) číslo popisné / orientační</td></tr>
  <tr><td colspan="2" class="t"><xsl:value-of select="identification/contact/address"/></td></tr>
  
  <tr><td colspan="2">e) jméno a příjmení a funkce oprávněné osoby</td></tr>
  <tr><td colspan="2" class="t"><xsl:value-of select="identification/contact/person"/><xsl:text> </xsl:text><xsl:value-of select="identification/contact/position"/></td></tr>

  <tr><td>f) číslo telefonu</td><td>g) e-mail</td></tr>
  <tr><td class="t"><xsl:value-of select="identification/contact/phone"/></td><td class="t"><xsl:value-of select="identification/contact/email"/></td></tr>

</table>

<h2>II. oddíl – údaj o území</h2>

<h3>4. Název nebo popis údaje o území</h3>
<div class="t" style="font-weight:bold font-size: 16px;">
  <xsl:value-of select="title"/>
</div>

<h3>5. Vznik údaje o území</h3>
<div>
  <table>
  <tr><td>a) právní předpis / správní rozhodnutí / jiný	</td><td>b) ze dne</td></tr>
  <tr><td class="t"><xsl:value-of select="purpose"/> </td><td class="t"><xsl:value-of select="purposeZeDne"/> </td></tr>

  <tr><td>c) vydal</td></tr>
  <tr><td class="t"><xsl:value-of select="purposeVydal"/></td></tr>

  </table>
</div>

<h3>6. Územní lokalizace údaje o území</h3>
<div class="t">
  <xsl:value-of select="extentDescription"/>
</div>

<h3>7. Předání údaje o území</h3>
<div>
  <table>
  <tr><td>a) název dokumentu	</td><td> b) datum zpracování</td></tr>
  <tr><td class="t"><xsl:value-of select="title"/></td><td class="t"><xsl:value-of select="creationDate"/></td></tr>

  <tr><td colspan="2">d) měřítko mapového podkladu, nad kterým byl údaj o území zobrazen</td></tr>
  <tr><td colspan="2" class="t">1 : <xsl:value-of select="scale"/></td></tr>

  <tr><td colspan="2">e) souřadnicový systém zobrazení</td></tr>
  <xsl:variable name="theCoords" select="coordSys"/>
  <tr><td colspan="2" class="t"><xsl:value-of select="$codeLists/coordSys/value[@name=$theCoords]"/></td></tr>

  <tr><td colspan="2">f) další metadata</td></tr>
  <tr><td>formát</td><td><xsl:value-of select="format/name"/><xsl:text> </xsl:text><xsl:value-of select="format/version"/></td></tr>
  <tr><td>typ</td><td>
  <xsl:for-each select="geom/*">
    <xsl:value-of select="."/><xsl:text> </xsl:text>
  </xsl:for-each>  
  </td></tr>
  <tr><td>medium</td><td>
  <xsl:variable name="theMedium" select="medium"/>
    <xsl:value-of select="$codeLists/name/value[@name=$theMedium]"/></td></tr>
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
<div class="t">
  <xsl:value-of select="identification/contact/person"/><xsl:text> </xsl:text><xsl:value-of select="identification/contact/position"/>
</div>

<div style="margin-top:50px; border-top: 1px dotted black; width: 400px; text-align:center; float:right;">
  datum a podpis oprávněné osoby poskytovatele údaje
</div>

</body>
</html>

</xsl:template>
</xsl:stylesheet>
