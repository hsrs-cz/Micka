<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" encoding="utf-8"/>
<xsl:template match="/">

<xsl:variable name="codeLists" select="document('../../xsl/codelists_cze.xml')/map" />
<xsl:variable name="help" select="document('../../xsl/help_cze.xml')/help" />

  <script type="text/javascript" src="lite/kote.js"></script>
  <script type="text/javascript" src="scripts/ol/overlibmws.js"></script>
  <script type="text/javascript" src="scripts/ol/overlibmws_iframe.js"></script>
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
	<div style="text-align:center;">
		<div style="margin:auto; background:#FFFFFF; padding:0px; text-align:left; position:relative">
			<div style="padding:5px;">
                <xsl:apply-templates />
			</div>
		</div>
	</div>
  

</xsl:template>

<xsl:include href="iso2kote.xsl"/> 

</xsl:stylesheet>
