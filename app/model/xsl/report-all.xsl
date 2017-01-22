<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:php="http://php.net/xsl" 
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml/3.2"   
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gmi="http://www.isotc211.org/2005/gmi" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:gco="http://www.isotc211.org/2005/gco" >
    <xsl:output method="html"/>
	<xsl:include href="client/common_cli.xsl" />

	<!-- obalená věta -->
	<xsl:template match="/">
		<html>
		<head>
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.0/css/font-awesome.min.css" />
			<style>
				body {
					font-family: "Helvetica Neue",Helvetica,Arial,sans-serif; font-size:13px;
				}
				h1 {
					color: #ff6600;
					padding: 20px 0 10px 5px;
					text-align:center;
				}
				.container {
					display: flex;
					flex-flow: row wrap;
					justify-content: center;
				}
				#footer {
					padding: 10px 0 35px 10px;					
				}
				a {
					color: #1377a8;
					text-decoration: none; 
				}
				a:hover {
					color: #037;
				}
				.rec {
					width: 260px;
					border: 1px solid #EEE;
					margin: 5px;
					padding: 7px;
					color: #444;
					background: white;
				}
				.rec:hover {
					box-shadow: 3px 3px 3px grey;
					background: #F0FAFF;
					border-color: #4E98BD;
					color: #000;
				}
				.rec h2 {
					font-size: 14px;
					border: 0px;
					background: none;
					font-weight: normal;
					padding:0px;
					margin: 0 0 10px 0;
				}
				.paginator {
					width: 100%;
					background: #555;
					color: white;
					left: 0px;
					text-align: center;
					font-size: 15px;
					margin: 0px;
					position: fixed;
					bottom: 0px;
					padding: 5px;					
				}
				.paginator a {
					color: #FFF;
				}
				.paginator a:hover {color: #8DF;}
			</style>
		</head>
		<body style="background:#F8F8F8;">
		<h1>GEOPORTÁL INSPIRE České republiky - katalog metadat</h1>
		<div class="container">
			<xsl:for-each select="*/rec">
				<xsl:variable name="mdlang" select="*/gmd:language/*/@codeListValue"/>
				<div class="rec">
					<h2>
						<a href="{concat('../page/',*/gmd:fileIdentifier)}" target="_blank">
	                        <xsl:call-template name="multi">
	                            <xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
	                            <xsl:with-param name="lang" select="$LANGUAGE"/>
	                            <xsl:with-param name="mdlang" select="$mdlang"/>
	                        </xsl:call-template>                        
	                    </a>
                    </h2>
                    <div>
                    	<xsl:variable name="ab">
	                     <xsl:call-template name="multi">
	                         <xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:abstract"/>
	                         <xsl:with-param name="lang" select="$LANGUAGE"/>
	                         <xsl:with-param name="mdlang" select="$mdlang"/>
	                     </xsl:call-template>
	                    </xsl:variable>
	                    <xsl:value-of select="substring($ab,1,150)"/>...                         
                    </div>
				</div>
			</xsl:for-each>		
		</div>
		<div id="footer">
			<a href="http://www.cenia.cz" target="_blank">CENIA 2016</a>
		</div>
		<xsl:call-template name="paginator">
			<xsl:with-param name="matched" select="*/@numberOfRecordsMatched"/>
			<xsl:with-param name="returned" select="*/@numberOfRecordsReturned"/>
			<xsl:with-param name="next" select="*/@nextRecord"/>
			<xsl:with-param name="url" select="'all.php?start'"/>
		</xsl:call-template> 
			
		</body>
		</html>
	</xsl:template>
			

</xsl:stylesheet>