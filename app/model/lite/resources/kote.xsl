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

<!-- <xsl:variable name="codeLists" select="document('../../include/xsl/codelists_cze.xml')/map" />
<xsl:variable name="help" select="document('../../include/xsl/help_cze.xml')/help" /> -->
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <script type="text/javascript" src="kote.js"></script>
  <script type="text/javascript" src="../scripts/ajax.js"></script>
  <script type="text/javascript" src="../scripts/calendar.js"></script>
  <style type="text/css">
  	@import url("style/lite.css");
  	@import url("../scripts/calendar.css");  
  </style> 
  <script type="text/javascript">
  mickaURL = '<xsl:value-of select="$mickaURL"/>';
  var lang='cze';
  </script>
 </head>
<body onload="init();">

	<div style="text-align:center;">
		<div style="xwidth:950px; margin:auto; background:#FFFFFF; padding:0px; border:#98947B 0px solid; text-align:left; xposition:relative">
			<div style="padding:5px;">
				<form action="" method="post" target="metaResult" onsubmit="return submitCheck();">
					<xsl:apply-templates />
					<div style="text-align:center">
  						<input type="submit" name="action-xml" value="Stáhnout XML"/>
   						<input type="submit" name="action-cr" value="Validace ČR"/>
  						<input type="submit" name="action-eu" value="Validace EU"/>
  						<input type="submit" name="action-save" value="Uložit na portál"/> 
  					</div>
  				</form>
			</div>
		</div>
	</div>
</body>
</html>

</xsl:template>

<xsl:include href="iso2kote.xsl"/> 

</xsl:stylesheet>
