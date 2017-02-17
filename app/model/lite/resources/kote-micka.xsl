<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:srv="http://www.isotc211.org/2005/srv" 
	xmlns:gml="http://www.opengis.net/gml/3.2" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
>

<xsl:output method="xml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
  doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="yes" encoding="utf-8"/>
<xsl:template match="/">

<xsl:variable name="codeLists" select="document('../../include/xsl/codelists_cze.xml')/map" />
<xsl:variable name="help" select="document('../../include/xsl/help_cze.xml')/help" />

<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <script type="text/javascript" src="scripts/micka.js"></script>
  <script type="text/javascript" src="lite/kote.js"></script>
  <script type="text/javascript" src="scripts/ajax.js"></script>
  <script type="text/javascript" src="scripts/ol/overlibmws.js"></script>
  <script type="text/javascript" src="scripts/ol/overlibmws_iframe.js"></script>
  <script type="text/javascript" src="scripts/calendar.js"></script>
  <style type="text/css">
  	@import url("lite/style/lite.css");
  	@import url("scripts/calendar.css");
  	@import url(validator/style/validator.css); 
  </style> 
  <script type="text/javascript">
  md_menu('edit',<xsl:value-of select="$recno"/>,<xsl:value-of select="$select_profil"/>);
  mickaURL = '<xsl:value-of select="$mickaURL"/>';
  //var lang='cze';
  hlp=Array();
  <xsl:for-each select="$help/*">
    hlp["<xsl:value-of select="name()"/>"] = '<xsl:value-of select="."/>';  
  </xsl:for-each>
  </script>
 </head>
<body onload="init();">
	<div id="valid"></div>
	<div style="text-align:center;">
		<div style="margin:auto; background:#FFFFFF; padding:0px; text-align:left; position:relative">

		<div style="padding:0px 7px; 0px; 7px;">
			<a href="micka" style="float:right; background: url('img/settings.png') no-repeat; padding-left:20px;" onclick="window.open('micka_main.php?ak=rec_admin&amp;recno={$recno}', '_blank', 'width=400,height=600,resizable=yes'); return false"><xsl:value-of select="$alabel"/></a>
		</div>

			<div style="padding:5px;">
				<form action="metadata.php" method="post" onsubmit="return submitCheck();">
					<xsl:if test="$publisher=1">
						<div style="margin-bottom:3px; font-weight: bold;">
							<xsl:if test="$data_type='0'">
								<input type="checkbox" name="public"/>
							</xsl:if>
							<xsl:if test="$data_type='1'">
								<input type="checkbox" name="public" checked="Y"/>
							</xsl:if>
							<xsl:value-of select="$plabel"/>
						</div>
					</xsl:if>
					<input type="hidden" name="ak" value="save"/>
					<input type="hidden" name="recno" value="{$recno}"/>
					<input type="hidden" name="uuid" value="{$uuid}"/>
					<input type="hidden" name="block" value="1"/>
					<input type="hidden" name="nextblock" value=""/>
					<input type="hidden" name="profil" value="{$select_profil}"/>
					<input type="hidden" name="nextprofil" value=""/>
					<input type="hidden" name="mds" value="{$mds}"/>

					<xsl:apply-templates />

					<input type="hidden" name="ende" value="1"/>
  			</form>
			</div>
		</div>
	</div>
  
</body>
</html>

</xsl:template>

<xsl:include href="iso2kote.xsl"/> 

</xsl:stylesheet>
