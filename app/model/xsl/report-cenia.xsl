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
	<xsl:variable name="services" select="document('../logs/heartbeat.xml')/results"/>
	<xsl:variable name="CLIENT" select="'https://geoportal.gov.cz/web/guest/catalogue-client?anytext='"/>

	<!-- obalená věta -->
	<xsl:template match="/">
		<html>
		<head>
			<link rel="stylesheet" type="text/css" href="../themes/default/micka.css" />
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.0/css/font-awesome.min.css" />
			<style>
				.report {
					border-collapse: collapse;
					border: 1px solid #CCC;
				}
				.report th, .report td {
					border: 1px solid #CCC;
					font-size:14px;
				}
				
				.report tr:hover {background: #FFF8E0; }
				
				.dole {
					padding: 10px;
					font-size: 15px;
				}
			</style>
		</head>
		<body>
		<h1>Souhrný report INSPIRE</h1>
		
		<table class="report">
		<tr>
			<th>Č</th>
			<th>Dataset</th>
            <th>Téma</th>
            <th>Poskytovatel</th>
			<th>Prohlížecí služba</th>
			<th>Stahovací služba</th>
		</tr>
		
		<xsl:for-each select="*/rec">
        
			<xsl:variable name="url0">
            	<xsl:choose>
					<xsl:when test="$REWRITE">	
						<xsl:value-of select="concat($MICKA_URL,'/records/',*/gmd:fileIdentifier)"/>
					</xsl:when>
					<xsl:otherwise>
	                	<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',*/gmd:fileIdentifier)"/>
					</xsl:otherwise>
				</xsl:choose>
            </xsl:variable>

			<xsl:variable name="mdlang" select="*/gmd:language/*/@codeListValue"/>

			<tr>
				<td><xsl:value-of select="position()"/></td>
                <!-- Nazev -->
				<td>
					<a href="{$MICKA_URL}?ak=valid&amp;uuid={@uuid}" class="valid{@valid}" target="_blank"><xsl:choose>
						<xsl:when test="@valid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
						<xsl:when test="@valid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
						<xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
						</xsl:choose>
					</a>
					<xsl:text> </xsl:text>						
					<a href="{$url0}" target="_blank">
                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                            <xsl:with-param name="mdlang" select="$mdlang"/>
                        </xsl:call-template>                        
                    </a>
				</td>
                <!-- Tema -->
                <td>
                    <xsl:for-each select="*/gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title, 'GEMET - INSPIRE')]">
                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="*/gmd:keyword"/>
                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                            <xsl:with-param name="mdlang" select="$mdlang"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </td>
                <td>
                    <xsl:call-template name="multi">
                        <xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:pointOfContact/*/gmd:organisationName"/>
                        <xsl:with-param name="lang" select="$LANGUAGE"/>
                        <xsl:with-param name="mdlang" select="$mdlang"/>
                    </xsl:call-template>
                </td>
				<!-- sluzby -->
				<xsl:variable name="vazby" select="php:function('getMetadata', concat('(uuidRef=',*/gmd:fileIdentifier/*,' or operateson like *', */gmd:fileIdentifier/*, '*)  and (serviceType=download or serviceType=view)'), 'extended')"/>
				<td>
                    <!-- view -->
					<xsl:for-each select="$vazby//rec[*/gmd:identificationInfo/*/srv:serviceType='view']">
						<xsl:variable name="mdlang1" select="*/gmd:language/*/@codeListValue"/>
					
		                <xsl:variable name="url">
		                    <xsl:choose>
								<xsl:when test="$REWRITE">	
									<xsl:value-of select="concat($CLIENT,*/gmd:fileIdentifier)"/>
								</xsl:when>
								<xsl:otherwise>
		                        	<xsl:value-of select="concat($CLIENT,*/gmd:fileIdentifier)"/>
								</xsl:otherwise>
							</xsl:choose>
		                </xsl:variable>
		
						<div>
							<a href="{$MICKA_URL}?ak=valid&amp;uuid={@uuid}" class="valid{@valid}" title="Validace metadat" target="_blank"><xsl:choose>
								<xsl:when test="@valid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
								<xsl:when test="@valid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
								<xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
								</xsl:choose>
							</a>
                            
                            <xsl:variable name="link" select="string(*/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*)"/>
                            <xsl:variable name="serviceValid" select="$services/row[@url=$link]/@valid"/>
							<a href="../validator/validator.php?type=wms&amp;url={php:function('urlencode', $link)}" class="valid{$serviceValid}" title="Validace služby" target="_blank">
                                <xsl:choose>
                                    <xsl:when test="$serviceValid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
                                    <xsl:when test="$serviceValid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
                                    <xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
                                </xsl:choose>
							</a>
							<xsl:text> </xsl:text>						

							<a href="{$url}" target="_blank"><xsl:call-template name="multi">
								<xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="mdlang" select="$mdlang1"/>
							</xsl:call-template></a>
							<xsl:text> </xsl:text>

						</div>
					</xsl:for-each>	
				</td>	
				<td>
                    <!-- download -->
					<xsl:for-each select="$vazby//gmd:MD_Metadata[gmd:identificationInfo/*/srv:serviceType='download']">
						<xsl:variable name="mdlang1" select="gmd:language/*/@codeListValue"/>
					
		                <xsl:variable name="url">
		                    <xsl:choose>
								<xsl:when test="$REWRITE">	
									<xsl:value-of select="concat($MICKA_URL,'/records/',gmd:fileIdentifier)"/>
								</xsl:when>
								<xsl:otherwise>
		                        	<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',gmd:fileIdentifier)"/>
								</xsl:otherwise>
							</xsl:choose>
		                </xsl:variable>
		
						<div>
							<a href="{$MICKA_URL}?ak=valid&amp;uuid={../@uuid}" class="valid{../@valid}" target="_blank"><xsl:choose>
								<xsl:when test="../@valid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
								<xsl:when test="../@valid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
								<xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
								</xsl:choose>
							</a>
                            
                            <xsl:variable name="link" select="string(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/gmd:URL)"/>
                            <xsl:variable name="serviceValid" select="$services/row[@url=$link]/@valid"/>
							<a href="../validator/validator.php?type=download&amp;url={php:function('urlencode', $link)}" class="valid{$serviceValid}" title="Validace služby" target="_blank">
                                <xsl:choose>
                                    <xsl:when test="$serviceValid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
                                    <xsl:when test="$serviceValid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
                                    <xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
                                </xsl:choose>
							</a>
							<xsl:text> </xsl:text>
                            
							<a href="{$url}" target="_blank"><xsl:call-template name="multi">
								<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="mdlang" select="$mdlang1"/>
							</xsl:call-template></a>
						</div>
					</xsl:for-each>	
				</td>	
			</tr>
		</xsl:for-each>
		</table>	
		<div class="dole">
			<a href="?request=GetRecords&amp;format=application/csv&amp;language=cze&amp;query=type%3Ddataset%20or%20type%3Dseries%20and%20ForInspire%3D1&amp;sortby=&amp;template=report-cenia-csv&amp;maxrecords=200">Stáhnout jako CSV</a>
		</div>
		</body>
		</html>
	</xsl:template>
			

</xsl:stylesheet>