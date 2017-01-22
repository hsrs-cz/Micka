<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:csw="http://www.opengis.net/cat/csw"   
  xmlns:gmd="http://schemas.opengis.net/iso19115full" 
  xmlns:srv="http://schemas.opengis.net/iso19119"
  xmlns:gco="http://metadata.dgiwg.org/smXML"
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
<xsl:output method="html" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
<xsl:template match="/">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <link rel="stylesheet" type="text/css" href="portal.css" />
  <script language="javascript" src="scripts/hs_dmap.js"></script>
  <script language="javascript" src="scripts/micka_dmap.js"></script>
  <script language="javascript" src="scripts/wz_jsgraphics.js"></script>
  <script>
    var epsg=4326;
    var wms="http://www2.demis.nl/wms/wms.asp?wms=WorldMap&amp;SERVICE=WMS&amp;VERSION=1.1.1&amp;FORMAT=image/gif&amp;layers=Bathymetry,Topography,Hillshading,Coastlines,Builtup areas,Rivers,Streams,Waterbodies,Borders,Railroads,Highways,Roads,Trails,Settlements,Cities&amp;";

  function showMap(url){
    myURL = "http://www.bnhelp.cz/mapserv/php/wms_read.php?project=wmsview&amp;mapwin=wmsview&amp;service="+url;
    window.open(myURL, "wmswin", "width=550,height=700,dependent=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,copyhist=no");
  }

  </script>
</head>
<body onLoad="focus();">

<xsl:variable name="msg" select="document('portal.xml')/portal/messages[@lang=$lang]"/>
<xsl:variable name="cl" select="document(concat('codelists_', $lang, '.xml'))/map"/>

<xsl:for-each select="//gmd:MD_Metadata">
  <div class="hlavicka">
  <xsl:if test="contains(gmd:distributionInfo/gco:MD_Distribution/gco:transferOptions/gco:MD_DigitalTransferOptions/gco:onLine/gco:CI_OnlineResource/gco:linkage,'WMS')">
    <div style='float:right;'>
       <a class='mapa' href="javascript: showMap('{gmd:distributionInfo/gco:MD_Distribution/gco:transferOptions/gco:MD_DigitalTransferOptions/gco:onLine/gco:CI_OnlineResource/gco:linkage}');"> <xsl:value-of select="$msg/map"/></a>
    </div>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="name(gmd:identificationInfo/*)='SV_ServiceIdentification'">
	  <img src="img/serv.gif" />
	</xsl:when>
	<xsl:otherwise>
	  <img src="img/lyr.gif" />
	</xsl:otherwise>
  </xsl:choose>
  <xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo/*/gco:citation/gco:CI_Citation/gco:title"/>  
  </div>

<table cellspacing='0' cellpadding='2' width='100%'>
<tr><td class="odp_rec" colspan="2"><xsl:value-of select="$msg/identification"/></td></tr>
<tr><td>
<table class='vypis'>

<tr><th><xsl:value-of select="$msg/abstract"/></th>
<td><xsl:for-each select="gmd:identificationInfo/*/gco:abstract">
  <xsl:value-of select="."/>
</xsl:for-each> 
</td></tr>

<tr><th><xsl:value-of select="$msg/date"/></th> 
<td><xsl:for-each select="gmd:identificationInfo/*/gco:citation/gco:CI_Citation/gco:date/gco:CI_Date" >
  <xsl:variable name="kod" select="gco:dateType"/>
  <xsl:value-of select="$cl/dateType/value[@name=$kod]"/><xsl:text> </xsl:text>
  <xsl:value-of select="gco:date"/><xsl:text>  </xsl:text>
</xsl:for-each> 
</td></tr>

<tr><th><xsl:value-of select="$msg/category"/></th>
<td><xsl:for-each select="//gco:topicCategory/gco:MD_TopicCategoryCode" >  
 <xsl:variable name="kod" select="@codeListValue"/>
 <xsl:value-of select="$cl/topicCategory/value[@name=$kod]"/>, 
</xsl:for-each> 
</td> </tr>

<tr><th><xsl:value-of select="$msg/keywords"/></th>
<td><xsl:for-each select="//gco:keyword" >
  <xsl:value-of select="."/>,
</xsl:for-each> 
</td></tr>

<xsl:for-each select="gco:identificationInfo/*/gco:pointOfContact/gco:CI_ResponsibleParty">
<tr><th><xsl:value-of select="$msg/contact"/></th>
  <td>  	
    <a href="{gco:contactInfo/gco:CI_Contact/gco:onlineResource}"><xsl:value-of select="gco:organisationName"/></a>, 
    <xsl:value-of select="gco:contactInfo/gco:CI_Contact/gco:address/gco:CI_Address/gco:deliveryPoint"/>,
	  <xsl:value-of select="gco:contactInfo/gco:CI_Contact/gco:address/gco:CI_Address/gco:city"/>,
    <xsl:value-of select="gco:contactInfo/gco:CI_Contact/gco:address/gco:CI_Address/gco:postalCode"/><br/>
    tel: <xsl:value-of select="gco:contactInfo/gco:CI_Contact//gco:voice"/><br/>
    email: <a href="mailto:{gco:contactInfo/gco:CI_Contact//gco:electronicMailAddress}"><xsl:value-of select="gco:contactInfo/gco:CI_Contact//gco:electronicMailAddress"/></a><br/>
    <xsl:variable name="kod" select="gco:role/gco:CI_RoleCode/@codeListValue"/>
    role: <xsl:value-of select="$cl/role/value[@name=$kod]"/>
    <br/>
    
  </td></tr>
</xsl:for-each>

<tr><th><xsl:value-of select="$msg/spatial"/></th>
<td>  
  <xsl:variable name="kod" select="//gco:spatialRepresentationType/gco:MD_SpatialRepresentationType/@codeListValue"/>
  <xsl:value-of select="$cl/spatialRepresentationType/value[@name=$kod]"/>
</td></tr>

<tr><th><xsl:value-of select="$msg/scale"/></th>
<td><xsl:text> 1:</xsl:text> <xsl:value-of select="gmd:identificationInfo/*/gco:spatialResolution/gco:MD_Resolution/gco:equivalentScale/gco:MD_RepresentativeFraction/gco:denominator"/>
</td></tr>

<tr><th><xsl:value-of select="$msg/temp"/></th>
<td> 
<xsl:choose>
  <xsl:when test="string-length(gmd:identificationInfo//gco:temporalElement//gco:beginPosition)>0">
    <xsl:value-of select="gmd:identificationInfo//gco:temporalElement//gco:beginPosition"/> - 
    <xsl:value-of select="gmd:identificationInfo//gco:temporalElement//gco:endPosition"/>
	</xsl:when>
  <xsl:when test="string-length(gmd:identificationInfo//gco:temporalElement//gco:begin)>0">
    <xsl:value-of select="gmd:identificationInfo//gco:temporalElement//gco:begin"/> - 
    <xsl:value-of select="gmd:identificationInfo//gco:temporalElement//gco:end"/>
	</xsl:when>
  <xsl:when test="string-length(gmd:identificationInfo//gco:temporalElement//gco:timeInstant)>0">
    <xsl:value-of select="gmd:identificationInfo//gco:temporalElement//gco:timeInstant"/> - 
	</xsl:when>
</xsl:choose>
</td></tr>

<xsl:if test="string-length(//srv:serviceType)>0">
<tr>
  <th><xsl:value-of select="$msg/service"/></th>
  <td><xsl:value-of select="//srv:serviceType"/></td>
</tr>  
</xsl:if>

<tr><th><xsl:value-of select="$msg/coorSys"/></th>
<td><xsl:for-each select="//gco:RS_Identifier" >
  <xsl:value-of select="gco:codeSpace"/>:<xsl:value-of select="gco:code"/>, 
</xsl:for-each> 
</td></tr>
</table>
</td>
<td valign='top'>
<xsl:if test="string-length(//gco:EX_Extent/gco:geographicElement/gco:EX_GeographicBoundingBox/gco:westBoundLongitude)>0">
<xsl:for-each select="//gco:EX_Extent/gco:geographicElement/gco:EX_GeographicBoundingBox">
  <table class='vypis'>
  <tr><th><xsl:value-of select="$msg/extent"/></th></tr>
  <tr><td>  
     <script>
        drawExtent('nahled', wms, [250, 180], [<xsl:value-of select="//gco:EX_Extent/gco:geographicElement/gco:EX_GeographicBoundingBox/gco:westBoundLongitude" />,<xsl:value-of select="//gco:EX_Extent/gco:geographicElement/gco:EX_GeographicBoundingBox/gco:southBoundLatitude" />,<xsl:value-of select="//gco:EX_Extent/gco:geographicElement/gco:EX_GeographicBoundingBox/gco:eastBoundLongitude" />,<xsl:value-of select="//gco:EX_Extent/gco:geographicElement/gco:EX_GeographicBoundingBox/gco:northBoundLatitude" />], 5);
     </script>
  </td></tr>
  <tr><td>
  <table>
  <tr>
    <td><xsl:value-of select="$msg/west"/>:</td>
    <td><xsl:value-of select="gco:westBoundLongitude" /></td>
  </tr>
  <tr>
    <td><xsl:value-of select="$msg/south"/>:</td>
    <td><xsl:value-of select="gco:southBoundLatitude" /></td>
  </tr>
  <tr>
    <td><xsl:value-of select="$msg/east"/>:</td>
    <td><xsl:value-of select="gco:eastBoundLongitude" /></td>
  </tr>
  <tr>
    <td><xsl:value-of select="$msg/north"/>:</td>
    <td><xsl:value-of select="gco:northBoundLatitude" /></td>
  </tr>
  </table>
  </td></tr>
  </table>
</xsl:for-each>
</xsl:if>

</td>
</tr>

<tr><td class="odp_rec" colspan="2"><xsl:value-of select="$msg/quality"/></td></tr>
<tr><td colspan="2">
<table class='vypis'>
<tr><th><xsl:value-of select="$msg/lineage"/></th>
<td>  <xsl:value-of select="//gco:lineage/gco:LI_Lineage/gco:statement"/></td>
</tr>
</table></td></tr>
<tr><td class="odp_rec" colspan="2"><xsl:value-of select="$msg/distrib"/></td></tr>
<tr><td colspan="2">
<table class='vypis'>
<tr><th>On-line:</th>
<td><xsl:for-each select="gmd:distributionInfo/gco:MD_Distribution/gco:transferOptions/gco:MD_DigitalTransferOptions/gco:onLine" >
  <xsl:value-of select="gco:CI_OnlineResource/gco:protocol"/><xsl:text> </xsl:text>
  <a href="{gco:CI_OnlineResource/gco:linkage}">
    <xsl:value-of select="gco:CI_OnlineResource/gco:linkage"/>
  </a>
  <xsl:value-of select="gco:CI_OnlineResource/gco:description"/><br />
</xsl:for-each> 
</td></tr>
</table>
</td>
</tr>
<tr><td class="odp_rec" colspan="2">Metadata</td></tr>
<tr><td colspan="2">
<table class='vypis'>
<tr><th><xsl:value-of select="$msg/ident"/></th><td> <xsl:value-of select="gmd:fileIdentifier"/> </td></tr>
<tr><th><xsl:value-of select="$msg/hierarchy"/></th><td> 
  <xsl:variable name="kod" select="gmd:hierarchyLevel/gco:MD_ScopeCode/@codeListValue"/>
  <!--<xsl:value-of select="$cl/updateScope/value[@name=$kod]"/>-->
  <xsl:value-of select="gmd:hierarchyLevel/gco:MD_ScopeCode/@codeListValue"/>
</td></tr>
  <!--po zmene struktury poradnou cestu -->  
<xsl:for-each select="gmd:contact/CI_ResponsibleParty">
<tr><th><xsl:value-of select="$msg/contact"/></th>
  <td>  	
    <a href="{contactInfo/CI_Contact/onlineResource}"><xsl:value-of select="organisationName"/></a>, 
    <xsl:value-of select="contactInfo/CI_Contact//deliveryPoint"/>,
	  <xsl:value-of select="contactInfo/CI_Contact/address/CI_Address/city"/>,
    <xsl:value-of select="contactInfo/CI_Contact/address/CI_Address/postalCode"/><br/>
    tel: <xsl:value-of select="contactInfo//voice"/><br/>
    email: <a href="mailto:{contactInfo//electronicMailAddress}"><xsl:value-of select="contactInfo//electronicMailAddress"/></a><br/>
    role: <xsl:value-of select="//role"/>
    <br/>
    
  </td></tr>
</xsl:for-each>

<tr><th>Standard</th><td><xsl:value-of select="gmd:metadataStandardName"/></td></tr>
<tr><th><xsl:value-of select="$msg/dateStamp"/></th><td><xsl:value-of select="gmd:dateStamp"/></td></tr>
</table>
</td></tr>
</table>

  
</xsl:for-each>

</body>
</html>

</xsl:template>
</xsl:stylesheet>
