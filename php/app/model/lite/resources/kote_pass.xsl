<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="utf-8"/>
<xsl:template match="/">

<xsl:variable name="codeLists" select="document('../../include/xsl/codelists_cze.xml')/map" />
<xsl:variable name="help" select="document('../../include/xsl/help_cze.xml')/help" />

<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <script type="text/javascript" src="../scripts/micka.js"></script>
  <script type="text/javascript" src="kote.js"></script>
  <script type="text/javascript" src="../scripts/ajax.js"></script>
  <script type="text/javascript" src="../scripts/ol/overlibmws.js"></script>
  <script type="text/javascript" src="../scripts/ol/overlibmws_iframe.js"></script>
  <script type="text/javascript" src="../scripts/calendar.js"></script>
  <link rel="stylesheet" type="text/css" href="../scripts/calendar.css"/>
  <script type="text/javascript">
  hlp=Array();
  <xsl:for-each select="$help/*">
    hlp["<xsl:value-of select="name()"/>"] = '<xsl:value-of select="."/>';  
  </xsl:for-each>
  </script>
  <style>
  td {vertical-align:top; font-family:sans-serif; font-size:12px;} 
  img {border: 0px}
  fieldset {border: 1px solid gray; margin-top:10px;}
  legend {color: gray; font-weight:bold;}
  body {background:#EEE; font-family:sans-serif;font-size:12px;}
  label {font-weight: normal}
  .xmandatory {background-color:FFF0E8; border:1px solid gray}
  .inp { width:500px; background:#F1EFE1; border:1px solid gray;}
  .inpL {width:700px}
  .inpS {width: 300px;}
  .inpSS {width:100px;}
  .date {width: 80px;}
  .num {width: 60px; text-align:center}
  select {background: #F1EFE1;border:1px solid gray;}
  textarea {width:500px; height:60px; background: #F1EFE1; border:1px solid gray;}
  span.m {color:red; font-size:18px; font-weight:bold; vertical-align:middle}
  th {text-align:right; font-size:12px; font-weight:normal; vertical-align:top; padding-right:10px}
  h1 {color:#FF6600; text-align:center;}
  </style>
</head>
<body onload="init();">

<div style="text-align:center">
<div style="width:920px; margin:auto; background:#FFFFFF; padding:0px; border:#98947B 1px solid; text-align:left; position:relative">
<div style="background-image:url(../img/hlavicka_bg.jpg); height:70px; border-bottom:#98947B 1px solid">
<div style="position:absolute; left: 283px; top:30px; font-size:36px; color:#00000; font-weight:bold; font-family: serif; font-style: italic;">l i t e</div>
<div style="position:absolute; left: 280px; top:28px; font-size:36px; color:#FFF000; font-weight:bold; font-family: serif; font-style: italic;">l i t e</div>
<div style="position:absolute; right: 20px; top:10px; font-size:15px; color:#900000; font-weight:bolder; xfont-family: serif; xfont-style: italic;">Formulář pro vyplňování pasportu UAP.</div>
<a style="position:absolute; right:10px; top:45px;" href="?action=">INSPIRE</a>
</div>
<div style="padding:5px;">
<h1>Zadání pasportu - údaje o území</h1>

<form action="" method="post" target="metaResult" onsubmit="return submitCheck();">


<input type="hidden" name="md[mdlang]" value="cze"/>

<div style="padding-left:100px">
  <label> Poskytnutý komu: </label> <input class="inp" name="md[komu]" value="" />
  <label> Číslo: </label> <input class="inp inpSS" name="md[cislo]" value="" />
  
</div>
  
<fieldset style="width:420px; float:left;">
<legend id="contactData"><span class="m">*</span> 1. Oddíl - poskytovatel údaje</legend>
<table>
  <tr><th>Organizace</th><td><input class="inp inpS" name="md[identification][contact][organisation]" /></td></tr>
  <tr><th>Osoba</th><td><input class="inp inpS" name="md[identification][contact][person]" /></td></tr>
  <tr><th>Funkce</th><td><input class="inp inpSS" name="md[identification][contact][position]" /></td></tr>
  <tr><th>IČ</th><td><input class="inp inpSS" name="md[identification][contact][ico]"/></td></tr>
  <tr><th>Ulice + číslo</th><td><input class="inp inpS" name="md[identification][contact][address]"/></td></tr>
  <tr><th>Obec</th><td><input class="inp inpS" name="md[identification][contact][city]" /></td></tr>
  <tr><th>PSČ</th><td><input  class="inp inpSS" name="md[identification][contact][postalCode]"/></td></tr>
  <tr><th>telefon</th><td><input class="inp inpSS" name="md[identification][contact][phone][]"/></td></tr>
  <tr><th>e-mail</th><td><input class="inp inpS" name="md[identification][contact][email][]" /></td></tr>
  <tr><th>www</th><td><input class="inp inpS" name="md[identification][contact][linkage]" /></td></tr>
  <tr><th>role</th><td>
  <select name="md[identification][contact][role]">
  <xsl:for-each select="$codeLists/role/value">
    <option value="{@name}"><xsl:value-of select="."/></option>
  </xsl:for-each>
  </select> 
  </td></tr>
</table>
</fieldset>

<fieldset style="width:420px; float:right;">
<legend id="contactMetadata"><span class="m">*</span> Kontakt - autor metadat</legend>
<table>
  <tr><th>Organizace</th><td><input class="inp inpS" name="md[contact][organisation]"  /></td></tr>
  <tr><th>Osoba</th><td><input class="inp inpS" name="md[contact][person]" /></td></tr>
  <tr><th>Funkce</th><td><input class="inp inpSS" name="md[contact][position]" /></td></tr>
  <tr><th>Ulice + číslo</th><td><input class="inp inpS" name="md[contact][address]" /></td></tr>
  <tr><th>Obec</th><td><input class="inp inpS" name="md[contact][city]" /></td></tr>
  <tr><th>PSČ</th><td><input class="inp inpSS" name="md[contact][postalCode]"/></td></tr>
  <tr><th>telefon</th><td><input class="inp inpSS" name="md[contact][phone][]"/></td></tr>
  <tr><th>e-mail</th><td><input class="inp inpS" name="md[contact][email][]" /></td></tr>
  <tr><th>www</th><td><input class="inp inpS" name="md[contact][linkage]" /></td></tr>
  <tr><th></th><td><a href="javascript:copyContact();">zkopírovat z kontakt - data</a></td></tr>
</table>
  <input name="md[contact][role]" type="hidden" value="author" />
</fieldset>

<fieldset style="width:660px; float:left">
<legend>2. oddíl - údaj o území</legend>
<table>
  <tr><th><label>Identifikátor</label></th><td><input readonly="true" name="md[fileIdentifier]" style="color:red; background:#FFFFFF; border:0px; width:250px"/></td></tr>
  <tr><th><label id="title"><span class="m">*</span> Název </label></th><td><input class="inp mandatory" name="md[title]" value="{//title}" /></td></tr>
  <tr><th><label id="abstract"><span class="m">*</span> Popis </label></th><td><textarea class="mandatory" name="md[abstract]"><xsl:value-of select="//MD_Metadata/identificationInfo//title"/></textarea></td></tr>
  <tr><th><label id="purpose">Právní předpis </label></th><td><input class="inp" name="md[purpose]"/></td></tr>
  <tr><th></th><td align="right">
    <label>ze dne </label><input class="inp date" name="md[purposeZeDne]"/> <a href="javascript:displayDatePicker('md[purposeZeDne]', false, 'dmy', '.');"><img src="../img/calendar.gif"/></a><xsl:text> </xsl:text>
    <label>vydal </label><input class="inp inpS" name="md[purposeVydal]" maxlength="100"/>
  </td></tr>
  <tr><th><label id="extDescription">Územní lokalizace</label></th><td><textarea name="md[extentDescription]"></textarea></td></tr>
  <tr><th><label id="date"><span class="m">*</span> Datum </label></th>
    <td align="right">
      vytvoření <input class="inp date" name="md[creationDate]" /><a href="javascript:displayDatePicker('md[creationDate]', false, 'dmy', '.');"><img src="../img/calendar.gif"/></a> 
      aktualizace <input class="inp date" name="md[publicationDate]" /><a href="javascript:displayDatePicker('md[publicationDate]', false, 'dmy', '.');"><img src="../img/calendar.gif"/></a> 
      revize <input class="inp date" name="md[revisionDate]" /> <a href="javascript:displayDatePicker('md[revisionDate]', false, 'dmy', '.');"><img src="../img/calendar.gif"/></a>
    </td></tr>

  <tr><th><label id="scale"><span class="m">*</span> Měřítko podkladu 1 :</label></th><td> <input class="inp num" name="md[scale]" /></td></tr>
  <tr><th><label id="coordSys">Souřadnicový systém </label></th><td>   <select name="md[coordSys]">
    <option value=""></option>
    <xsl:for-each select="$codeLists/coordSys/value">
      <option value="{@name}"><xsl:value-of select="."/></option>
    </xsl:for-each>
  </select>
</td></tr>
  <tr><th><label id="spatialRepr">Typ dat </label></th><td>
  <select name="md[spatialRepr]">
    <xsl:for-each select="$codeLists/spatialRepresentationType/value">
      <option value="{@name}"><xsl:value-of select="."/></option>
    </xsl:for-each>
  </select>
  </td></tr>
  <tr><th><label id="format"> Formát dat </label></th><td>
  <select name="md[format][name]">
    <option value=""></option>
    <xsl:for-each select="$codeLists/formats/value">
      <option value="{@name}"><xsl:value-of select="."/></option>
    </xsl:for-each>
  </select>
  <xsl:text> </xsl:text><label id="formatVer">verze </label><input class="inp inpSS" name="md[format][version]"/>

  </td></tr>
  <tr><th><label id="media"> Nosič </label></th><td>

  <select name="md[medium]">
    <option value=""></option>
    <xsl:for-each select="$codeLists/name/value">
      <option value="{@name}"><xsl:value-of select="."/></option>
    </xsl:for-each>
  </select>
  <label id="mediaCount"> počet </label> <input class="inp num" name="md[mediaCount]" value=""/>
  </td></tr>

  <tr><th><label id="geom">Geometrie objektů</label></th><td>
    <input type="checkbox" name="md[geom][]" value="point"/>body 
    <input type="checkbox" name="md[geom][]" value="curve"/>linie 
    <input type="checkbox" name="md[geom][]" value="surface"/>polygony  
    <input type="checkbox" name="md[geom][]" value="complex"/>komplex.objekty
  </td></tr>
  </table>
</fieldset>

<fieldset class="mandatory" style="width:195px; float:right">
<legend id="topic"><span class="m">*</span> Tématické kategorie </legend>
<div style="color:black;">
  <xsl:for-each select="$codeLists/topicCategory/value">
    <input type="checkbox" name="md[topic][]" value="{@name}" id="{@name}"/><label for="{@name}"><xsl:value-of select="."/></label><br/>
  </xsl:for-each>
 </div>  
</fieldset>






<fieldset style="clear:both;">
<legend>3. oddíl - potrvrzení správnosti</legend>
  <table>
  <tr><th><label id="lineage">Vyjádření ke správnosti </label></th><td><textarea style="width:730px" name="md[lineage]" ></textarea></td></tr>
  </table>
</fieldset>



<fieldset style="clear:both">
<legend>Další údaje</legend>
<table width="100%">
<tr><th></th>
<td><label id="spatialExt">Geografický rozsah</label>  <br/>
  <iframe src="../mickaMap.php?lang=cze" id="mapa" width="360" height="270" border="0" frameborder="no" scrolling="no"></iframe><br/>
<a href="javascript:getFindBbox(document.getElementById('mapa').contentWindow.document.mapserv.imgext.value);"><img src="../img/zmapy.gif" alt="z mapy" title="z mapy" /></a>
<input type="text" class="inp num" name="md[xmin]" value="" size="5" />
<input type="text" class="inp num" name="md[ymin]" value="" size="5" />
<input type="text" class="inp num" name="md[xmax]" value="" size="5" />
<input type="text" class="inp num" name="md[ymax]" value="" size="5" />
<input type="button" onclick="javascript:window.open('../md_gazcli.php?simple=1', 'gc', 'toolbar=no,location=no,directories=no,status=no,menubar=no,width=300,height=500,resizable=yes,scrollbars=yes'); return false;" value="Ze seznamu" />
<br/><br/>
</td></tr>

<tr><th><label id="keywords"> Klíčová slova </label></th><td><input class="inp" name="keywords" maxlength="100"/></td></tr>
<tr><th><label id="onLine"> On-line přístup </label></th><td><input class="inp inpL" name="md[linkage]" maxlength="255" /></td></tr>


</table>
</fieldset>




<div style="clear:both; height:20px;"></div>
<div style="text-align:center">
<div style="width:250px; padding: 20px; background:yellowgreen;  margin:auto; border:1px solid gray">
  <div id="heslo" style="display:none; margin-left:40px">
  <table border="1" cellspacing="0">
    <tr><th>jméno</th><td><input name="user"/></td></tr>
    <tr><th>heslo</th><td><input name="pwd" type="password"/></td></tr>
  </table>
  <br/>
  </div>
  Vyberte akci: <select name="action" id="akce">
    <option value="xml">Uložit jako XML</option>
    <option value="pasPrint">Tisk pasportu</option>
    <option value="save">Uložit do katalogu</option>
    <option value="new">Nový záznam</option>
  </select>
  <xsl:text>  </xsl:text>
  <input type="submit" value="OK"/>
</div>
</div>
  </form>
</div>
</div>
</div>
<div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>
</body>
</html>

</xsl:template>
</xsl:stylesheet>
