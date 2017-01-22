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

	<xsl:variable name="services" select="document('../logs/heartbeat.xml')/results"/>

	<!-- obalená věta -->
	<xsl:template match="/"><xsl:text>"Č";"Val";"Dataset";"Téma";"Poskytovatel";"Prohlížecí služba";"Stahovací služba"
</xsl:text>
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

            <xsl:value-of select="position()"/>;<xsl:value-of select="@valid"/>
											
					<xsl:text>;"</xsl:text>
                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                            <xsl:with-param name="mdlang" select="$mdlang"/>
                        </xsl:call-template>                        
                    <xsl:text>";</xsl:text>
				
                    <xsl:text>"</xsl:text>
                    <xsl:for-each select="*/gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title, 'GEMET - INSPIRE')]">
                        <xsl:if test="position() &gt; 1">|</xsl:if>
                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="*/gmd:keyword"/>
                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                            <xsl:with-param name="mdlang" select="$mdlang"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:text>";</xsl:text>

                    <xsl:text>"</xsl:text>
                    <xsl:call-template name="multi">
                        <xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:pointOfContact/*/gmd:organisationName"/>
                        <xsl:with-param name="lang" select="$LANGUAGE"/>
                        <xsl:with-param name="mdlang" select="$mdlang"/>
                    </xsl:call-template>
                    <xsl:text>";</xsl:text>
                    
                    <!-- sluzby -->
                    <xsl:variable name="vazby" select="php:function('getMetadata', concat('(uuidRef=',*/gmd:fileIdentifier/*,' or operateson like *', */gmd:fileIdentifier/*, '*)  and (serviceType=download or serviceType=view)'), 'extended')"/>
                    
                    <!-- view -->
					<xsl:text>"</xsl:text>
                    <xsl:for-each select="$vazby//rec[*/gmd:identificationInfo/*/srv:serviceType='view']">
						<xsl:variable name="mdlang1" select="*/gmd:language/*/@codeListValue"/>
					
		                <xsl:variable name="url">
		                    <xsl:choose>
								<xsl:when test="$REWRITE">	
									<xsl:value-of select="concat($MICKA_URL,'/records/',*/gmd:fileIdentifier)"/>
								</xsl:when>
								<xsl:otherwise>
		                        	<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',*/gmd:fileIdentifier)"/>
								</xsl:otherwise>
							</xsl:choose>
		                </xsl:variable>
                        
                        <xsl:if test="position() &gt; 1">|</xsl:if>
                        <xsl:value-of select="@valid"/><xsl:text>,</xsl:text>
                            
                        <xsl:variable name="link" select="string(*/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*)"/>
                        <xsl:variable name="serviceValid" select="$services/row[@url=$link]/@valid"/>
                        <xsl:value-of select="$serviceValid"/><xsl:text>,</xsl:text>

                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="*/gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="mdlang" select="$mdlang1"/>
                        </xsl:call-template>
                  
					</xsl:for-each>
                    <xsl:text>";</xsl:text>                    
                    
                    <!-- download -->
					<xsl:text>"</xsl:text>
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
		
                        <xsl:if test="position() &gt; 1">|</xsl:if>
						<xsl:value-of select="../@valid"/><xsl:text>,</xsl:text>
                         
                        <xsl:variable name="link" select="string(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/gmd:URL)"/>
                        <xsl:variable name="serviceValid" select="$services/row[@url=$link]/@valid"/>
                        
                        <xsl:value-of select="$serviceValid"/><xsl:text>,</xsl:text>
  
                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="mdlang" select="$mdlang1"/>
                        </xsl:call-template>
					</xsl:for-each>
                    <xsl:text>"</xsl:text>
            <xsl:text>
</xsl:text>
		</xsl:for-each>
	</xsl:template>
			
<!-- pro multiligualni nazvy -->
<xsl:template name="multi" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:param name="el"/>
  <xsl:param name="lang"/>
  <xsl:param name="mdlang"/>
  <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[contains(@locale,$lang)]"/>	
  <xsl:variable name="uri" select="$el/*/@xlink:href"/>	
  <xsl:choose>
  	<xsl:when test="string-length($txt)>0">
        <xsl:value-of select="$txt"/>
   	</xsl:when>
  	<xsl:when test="string-length($el/*)>0">
        <xsl:value-of select="$el/*"/>
   	</xsl:when>
  	<xsl:otherwise>
        <xsl:value-of select="$uri"/>	
  	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>