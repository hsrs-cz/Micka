<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

  <xsl:template match="/rec/*">
  <xsl:variable name="cl">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml</xsl:variable>

    <xsl:variable name="ser">
    		<xsl:choose>
    			<xsl:when test="string-length(gmd:identificationInfo/srv:SV_ServiceIdentification)>0">srv:SV_ServiceIdentification</xsl:when>
    			<xsl:otherwise>gmd:MD_DataIdentification</xsl:otherwise>
    		</xsl:choose>
    </xsl:variable>	

    <xsl:variable name="ext">
    	<xsl:choose>
    		<xsl:when test="gmd:identificationInfo/srv:SV_ServiceIdentification != ''">srv:extent</xsl:when>
    		<xsl:otherwise>extent</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>	

    <xsl:variable name="mdLang">
    	<xsl:choose>
    		<xsl:when test="string-length(gmd:language)>0"><xsl:value-of select="gmd:language"/></xsl:when>
    		<xsl:when test="string-length(gmd:identificationInfo/*/gmd:citation/*/gmd:title/@lang)>0"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/@lang"/></xsl:when>
    		<xsl:otherwise>cze</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>		

<gmd:MD_Metadata>
	<xsl:copy-of select="gmd:fileIdentifier"/>
	<xsl:copy-of select="gmd:hierarchyLevel"/>
	<xsl:copy-of select="gmd:locale"/>
			
	<!-- ================================ Identifikace =============================== -->
	<gmd:identificationInfo>
		<xsl:element name="{$ser}">
			<gmd:citation>
				<gmd:CI_Citation>
					<xsl:copy-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
		    	</gmd:CI_Citation>
		    </gmd:citation>  
					
	    	<!-- neni v brief, ale pridal jsem -->
			<xsl:copy-of select="gmd:identificationInfo/*/gmd:abstract"/>
			      							
			<xsl:copy-of select="gmd:identificationInfo/*/gmd:graphicOverview"/>
				
	        <xsl:if test="string-length(gmd:identificationInfo/gmd:SV_ServiceIdentification)>0">
	 			<xsl:copy-of select="gmd:identificationInfo/*/srv:serviceType"/>
	 			<xsl:copy-of select="gmd:identificationInfo/*/srv:serviceTypeVersion"/>
	        </xsl:if>
			
			<xsl:element name="{$ext}">
				<gmd:EX_Extent>
				    <xsl:copy-of select="gmd:identificationInfo/*/gmd:extent/*/gmd:description|gmd:identificationInfo/*/srv:extent/*/gmd:description"/>
					<gmd:geographicElement>
				    	<xsl:copy-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox"/>
					</gmd:geographicElement>
				</gmd:EX_Extent>
			</xsl:element>
					
		</xsl:element>
				
        
	</gmd:identificationInfo>	
    </gmd:MD_Metadata>	
	
</xsl:template>

</xsl:stylesheet>
