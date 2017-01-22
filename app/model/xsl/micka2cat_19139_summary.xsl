<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"  omit-xml-declaration="yes"/>

  <xsl:include href="micka2cat.xsl" />

  <xsl:template match="/results" 
  	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  	xmlns:gmi="http://www.isotc211.org/2005/gmi"
  	xmlns:gco="http://www.isotc211.org/2005/gco"
  	xmlns:srv="http://www.isotc211.org/2005/srv">
  <xsl:variable name="cl">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml</xsl:variable>

  <xsl:for-each select="rec/*">

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

		<gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd"
		xmlns:gmi="http://www.isotc211.org/2005/gmi" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >

	<xsl:copy-of select="gmd:fileIdentifier"/>
	<xsl:copy-of select="gmd:language"/>
	<xsl:copy-of select="gmd:characterSet"/>
	<xsl:copy-of select="gmd:parentIdentifier"/>
	<xsl:copy-of select="gmd:hierarchyLevel"/>
	<xsl:copy-of select="gmd:hierarchyLevelName"/>	
	<xsl:copy-of select="gmd:contact"/>
	<xsl:copy-of select="gmd:dateStamp"/>
	<xsl:copy-of select="gmd:metadataStandardName"/>
	<xsl:copy-of select="gmd:metadataStandardVersion"/>
	<xsl:copy-of select="gmd:locale"/>

			
	<!-- ================================ ref. system ===============================-->
	<xsl:copy-of select="gmd:referenceSystemInfo" />

	<!-- ================================ Identifikace =============================== -->
	<gmd:identificationInfo>
	  <xsl:element name="{$ser}">
		<gmd:citation>
			<gmd:CI_Citation>
				<xsl:copy-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
				<xsl:copy-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:date"/>
	 			<xsl:copy-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier"/>
			</gmd:CI_Citation>
		</gmd:citation>
		<xsl:copy-of select="gmd:identificationInfo/*/gmd:abstract"/>				
		<xsl:copy-of select="gmd:identificationInfo/*/gmd:pointOfContact"/>		
		<xsl:copy-of select="gmd:identificationInfo/*/gmd:graphicOverview"/>
        <xsl:copy-of select="gmd:identificationInfo/*/gmd:resourceConstraints"/>
        <xsl:copy-of select="gmd:identificationInfo/*/gmd:spatialRepresentationType"/>
        <xsl:copy-of select="gmd:identificationInfo/*/gmd:spatialResolution"/>
        <xsl:copy-of select="gmd:identificationInfo/*/gmd:language"/>
        <xsl:copy-of select="gmd:identificationInfo/*/gmd:topicCategory"/>
					
        <xsl:if test="gmd:identificationInfo/srv:SV_ServiceIdentification!=''">
        	<xsl:copy-of select="gmd:identificationInfo/*/srv:serviceType"/>
        	<xsl:copy-of select="gmd:identificationInfo/*/srv:serviceTypeVersion"/>
        	<xsl:copy-of select="gmd:identificationInfo/*/srv:containsOperations"/>
        </xsl:if>
		
		<xsl:element name="{$ext}">
			<gmd:EX_Extent>
			    <xsl:copy-of select="gmd:identificationInfo/*/gmd:extent/*/gmd:description"/>
			    <xsl:copy-of select="gmd:identificationInfo/*/srv:extent/*/gmd:description"/>
				<gmd:geographicElement>
			    	<xsl:copy-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox"/>
				</gmd:geographicElement>
			</gmd:EX_Extent>
		</xsl:element>
					
	  	<xsl:for-each select="gmd:identificationInfo/*/srv:couplingType">
        	<srv:couplingType>
		  		<srv:SV_CouplingType codeList="{$cl}#SV_CouplingType" codeListValue="{.}"/>
        	</srv:couplingType>
      	</xsl:for-each>

	  </xsl:element>   
	</gmd:identificationInfo>			
		
	<!-- ================================ Distribuce ===============================-->
	<xsl:for-each select="gmd:distributionInfo">
		<gmd:distributionInfo>
			<gmd:MD_Distribution>
				<xsl:copy-of select="*/gmd:distributionFormat" />				
				<gmd:transferOptions>
					<gmd:MD_DigitalTransferOptions>
  				  <!-- specifické pro CGS -->
  				  <xsl:choose>
  				    <xsl:when test="$USER='guest' or $USER=''">
  					     <xsl:copy-of select="*/gmd:transferOptions/*/gmd:onLine[*/gmd:name/*!='OUT' and */gmd:name/*!='INT']" />
  					  </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="*/gmd:transferOptions/*/gmd:onLine" />
              </xsl:otherwise>
            </xsl:choose>     
					</gmd:MD_DigitalTransferOptions>
				</gmd:transferOptions>							
			</gmd:MD_Distribution>
	  	</gmd:distributionInfo>
	</xsl:for-each>

	<!-- ================================ Jakost ===============================-->
	<xsl:for-each select="gmd:dataQualityInfo">
	  <dataQualityInfo>
		<DQ_DataQuality>
			<xsl:copy-of select="*/gmd:scope" />
			<lineage>
			  <LI_Lineage>
			    <xsl:copy-of select="*/gmd:lineage/*/gmd:statement" />
			  </LI_Lineage>
			</lineage>
		</DQ_DataQuality>
	  </dataQualityInfo>
	</xsl:for-each>

</gmd:MD_Metadata>
		
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
