<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gco="http://www.opengis.net/gco"
  xmlns:ows="http://www.opengis.net/ows/1.1"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
  xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
  xmlns:wps="http://www.opengis.net/wps/1.0.0"
  >
  
  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/">
  <results>
    
    <MD_Metadata>
    <identificationInfo>
    <SV_ServiceIdentification>
    <serviceType>
      <gco:LocalName>WPS</gco:LocalName>
      <!-- <nameNameSpace>OGC</nameNameSpace> -->
    </serviceType>
    <serviceTypeVersion><xsl:value-of select="*/@version"/></serviceTypeVersion>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="*/ows:ServiceIdentification/ows:Title"/></title>
      <date>
      	<CI_Date>
      		<date><xsl:value-of select="substring-before(*/@updateSequence,'T')"/></date>
      		<dateType><CI_DateTypeCode>revision</CI_DateTypeCode></dateType>
      	</CI_Date>
      </date>
    </CI_Citation>  
    </citation>
    <abstract> <xsl:value-of select="*/ows:ServiceIdentification/ows:Abstract"/> </abstract>
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees> 
    			<xsl:value-of select="*/ows:ServiceIdentification/ows:Fees"/>
    	  </fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <xsl:for-each select="*/ows:ServiceIdentification/ows:Keywords">
	    <descriptiveKeywords>
	      <MD_Keywords>
		      <xsl:for-each select="ows:Keyword">
		        <keyword><xsl:value-of select="."/></keyword>
		      </xsl:for-each>
		      <xsl:if test="ows:Type/@codeSpace='http://www.isotc211.org/2005/srv'">
			    <thesaurusName>
				  <CI_Citation>
					<title>ISO 19119 geographic services taxonomy, 1.0</title>
					<date>
					  <CI_Date>
						<date>2008</date>
						<dateType>
		  				  <CI_DateTypeCode>publication</CI_DateTypeCode> 
		  				</dateType>
		  			  </CI_Date>
		      		</date>
		      	  </CI_Citation>
		        </thesaurusName>
		      </xsl:if>
	      </MD_Keywords>
	    </descriptiveKeywords>
	</xsl:for-each>    
    <!-- <descriptiveKeywords>
      <MD_Keywords>
        <keyword>infoSensorDescriptionService</keyword>
      	<thesaurusName>
		  <CI_Citation>
			<title>ISO 19119 geographic services taxonomy</title>
			<date>
			  <CI_Date>
				<date>2008</date>
				<dateType>
  				  <CI_DateTypeCode>publication</CI_DateTypeCode> 
  				</dateType>
  			  </CI_Date>
      		</date>
      	  </CI_Citation>
        </thesaurusName>
      </MD_Keywords>
    </descriptiveKeywords> -->
    <pointOfContact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:Role"/></CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </pointOfContact>
	<resourceConstraints>
		<MD_LegalConstraints>
			<accessConstraints><MD_RestrictionCode>otherRestrictions</MD_RestrictionCode></accessConstraints>
			<otherConstraints><xsl:value-of select="*/ows:ServiceIdentification/ows:AccessConstraints"/></otherConstraints>
		</MD_LegalConstraints>
	</resourceConstraints>


    <!-- operace -->
    <xsl:for-each select="*/ows:OperationsMetadata/ows:Operation">
      <containsOperations>
        <SV_OperationMetadata>
          <operationName><xsl:value-of select="@name"/></operationName>
          <xsl:for-each select="ows:DCP/ows:HTTP/*">
            <connectPoint>
              <CI_OnlineResource>
              	<linkage> <xsl:value-of select="@xlink:href"/> </linkage>
              	<xsl:choose>
              		<xsl:when test="substring-after(translate(../../../@name,$upper,$lower),'get')!=''">
              			<protocol>OGC:WPS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="substring(translate(../../../@name,$upper,$lower),4)"/></protocol>
              		</xsl:when>
              		<xsl:otherwise>
               			<protocol>OGC:WPS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="translate(../../../@name,$upper,$lower)"/></protocol>             		
              		</xsl:otherwise>
              	</xsl:choose>		
              </CI_OnlineResource>
            </connectPoint>
          </xsl:for-each>
          <DCP>WebServices</DCP>
        </SV_OperationMetadata>
      </containsOperations>
    </xsl:for-each>

    <extent>
    <EX_Extent>
      <geographicElement>
        <EX_GeographicBoundingBox>
          <!-- prasarna - vezme prvni, kterou najde  -->
          <westBoundLongitude><xsl:value-of select="substring-before(//gml:Envelope/gml:lowerCorner,' ')"/></westBoundLongitude>
          <eastBoundLongitude><xsl:value-of select="substring-before(//gml:Envelope/gml:upperCorner,' ')"/></eastBoundLongitude>
          <southBoundLatitude><xsl:value-of select="substring-after(//gml:Envelope/gml:lowerCorner,' ')"/></southBoundLatitude>
          <northBoundLatitude><xsl:value-of select="substring-after(//gml:Envelope/gml:upperCorner,' ')"/></northBoundLatitude>
        </EX_GeographicBoundingBox>
      </geographicElement>
      
      <temporalElement>
      	<EX_TemporalExtent>
      		<extent>
      			<!-- taky prasarna - vezme prvni, kterou najde  -->
      			<TimePeriod>
      				<beginPosition><xsl:value-of select="substring-before(//gml:TimePeriod/gml:beginPosition,'T')"/></beginPosition>
      				<endPosition><xsl:value-of select="substring-before(//gml:TimePeriod/gml:endPosition,'T')"/></endPosition>
      			</TimePeriod>
      		</extent>
      	</EX_TemporalExtent>
      </temporalElement>
    </EX_Extent>  
    </extent>
    
    <couplingType>
      <SV_CouplingType>mixed</SV_CouplingType>
    </couplingType>
    </SV_ServiceIdentification>
    </identificationInfo>

    <!-- distribuce -->
    <distributionInfo>
    <MD_Distribution>
      <transferOptions>
      <MD_DigitalTransferOptions>
        <onLine>
        <CI_OnlineResource>
          <linkage><xsl:value-of select="*/ows:OperationsMetadata/ows:Operation[@name='GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/>?SERVICE=WPS&amp;REQUEST=GetCapabilities</linkage>
          <protocol>OGC:WPS-<xsl:value-of select="*/@version"/>-http-get-capabilities</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>      
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

	
    <metadataStandardName>ISO 19119</metadataStandardName>
    <metadataStandardVersion>2005</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
  	<contact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode>pointOfContact</CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </contact>
  	
  	
    </MD_Metadata>
 
  
  </results>  
    
  </xsl:template>
</xsl:stylesheet>