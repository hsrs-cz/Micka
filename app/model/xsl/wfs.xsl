<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:ogc="http://www.opengis.net/ogc" 
    xmlns:ows="http://www.opengis.net/ows"
    xmlns:gco="http://www.opengis.net/gco"
  >
  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
	  <results>
	  	<xsl:apply-templates/>
	  </results>
  </xsl:template>    
  
  <!-- Version 2.0.0 -->
  <xsl:template match="wfs:WFS_Capabilities"
  	xmlns:ows="http://www.opengis.net/ows/1.1"
    xmlns:wfs="http://www.opengis.net/wfs/2.0"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:fes="http://www.opengis.net/fes/2.0" 
    xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0">

    <MD_Metadata>
    <identificationInfo>
    <SV_ServiceIdentification>
    <serviceType>
      <gco:LocalName>WFS</gco:LocalName>
      <!-- <nameNameSpace>OGC</nameNameSpace> -->
    </serviceType>
    <language><xsl:value-of select="//inspire_common:ResponseLanguage/*"/></language>
    <serviceTypeVersion><xsl:value-of select="@version"/></serviceTypeVersion>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="ows:ServiceIdentification/ows:Title"/></title>
      <identifier>
      	<RS_Identifier>
      		<code><xsl:value-of select="//inspire_common:Code"/></code>
      		<codeSpace><xsl:value-of select="//inspire_common:Namespace"/></codeSpace>
      	</RS_Identifier>
      </identifier>
    </CI_Citation>  
    </citation>
    <abstract> <xsl:value-of select="ows:ServiceIdentification/ows:Abstract"/> </abstract>
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees> 
    			<xsl:value-of select="ows:ServiceIdentification/ows:Fees"/>
    	  </fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="ows:ServiceIdentification/ows:Keywords|//ows:Keyword">
        <keyword><xsl:value-of select="."/></keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <descriptiveKeywords>
      <MD_Keywords>
        <keyword>infoFeatureAccessService</keyword>
      	<thesaurusName>
		  <CI_Citation>
			<title>ISO - 19119 geographic services taxonomy</title>
			<date>
			  <CI_Date>
				<date>2010-01-19</date>
				<dateType>
  				  <CI_DateTypeCode>publication</CI_DateTypeCode> 
  				</dateType>
  			  </CI_Date>
      		</date>
      	  </CI_Citation>
        </thesaurusName>
      </MD_Keywords>
    </descriptiveKeywords>
    <resourceConstraints>
    	<MD_Constraints>
    		<useLimitation><xsl:value-of select="ows:ServiceIdentification/ows:Fees"/></useLimitation>
    	</MD_Constraints>	
    </resourceConstraints>
    <xsl:if test="ows:ServiceIdentification/ows:AccessConstraints">
    	<resourceConstraints>
    		<MD_LegalConstraints>
    			<accessConstraints><MD_RestrictionCode>otherRestrictions</MD_RestrictionCode></accessConstraints>
    			<otherConstraints><xsl:value-of select="ows:ServiceIdentification/ows:AccessConstraints"/></otherConstraints>
    		</MD_LegalConstraints>
    	</resourceConstraints>
    </xsl:if>
    <pointOfContact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:Role"/></CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </pointOfContact>


    <!-- operace -->
    <xsl:for-each select="ows:OperationsMetadata/ows:Operation">
      <containsOperations>
        <SV_OperationMetadata>
          <operationName><xsl:value-of select="@name"/></operationName>
          <xsl:for-each select="ows:DCP/ows:HTTP/*">
            <connectPoint>
              <CI_OnlineResource>
              	<linkage><xsl:value-of select="@xlink:href"/></linkage>
              	<xsl:choose>
              		<xsl:when test="substring-after(translate(../../../@name,$upper,$lower),'get')!=''">
              			<protocol>OGC:WFS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="substring(translate(../../../@name,$upper,$lower),4)"/></protocol>
              		</xsl:when>
              		<xsl:otherwise>
               			<protocol>OGC:WFS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="translate(../../../@name,$upper,$lower)"/></protocol>             		
              		</xsl:otherwise>
              	</xsl:choose>		
              </CI_OnlineResource>
            </connectPoint>
          </xsl:for-each>
          <DCP>WebServices</DCP>
        </SV_OperationMetadata>
      </containsOperations>
    </xsl:for-each>
    
    <!--vrstvy-->
    <xsl:for-each select="//wfs:FeatureType[wfs:MetadataURL/@xlink:href!='']">
    	<operatesOn>
    		<href><xsl:value-of select="wfs:MetadataURL/@xlink:href"/></href>
    		<title><xsl:value-of select="wfs:Title"/></title>
    	</operatesOn>
   </xsl:for-each>
   
   <!--<xsl:for-each select="//wfs:FeatureType">
     <coupledResource>
	    <title><xsl:value-of select="wfs:Title"/></title>
		  <SV_CoupledResource>
		  	<xsl:if test="Identifier">
		    	<identifier><xsl:value-of select="Identifier/@authority"/>#<xsl:value-of select="Identifier"/></identifier>
		    </xsl:if>
		    <ScopedName><xsl:value-of select="wfs:Name"/></ScopedName>
		    <operationName>GetFeature</operationName>
		  </SV_CoupledResource>
		</coupledResource>
   </xsl:for-each>-->

    <extent>
    <EX_Extent>
      <geographicElement>
        <EX_GeographicBoundingBox>
          <westBoundLongitude><xsl:value-of select="substring-before(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:LowerCorner,' ')"/></westBoundLongitude>
          <eastBoundLongitude><xsl:value-of select="substring-before(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:UpperCorner,' ')"/></eastBoundLongitude>
          <southBoundLatitude><xsl:value-of select="substring-after(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:LowerCorner,' ')"/></southBoundLatitude>
          <northBoundLatitude><xsl:value-of select="substring-after(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:UpperCorner,' ')"/></northBoundLatitude>
        </EX_GeographicBoundingBox>
      </geographicElement>
    </EX_Extent>
    </extent>
    <couplingType>
      <SV_CouplingType>tight</SV_CouplingType>
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
          <linkage><xsl:value-of select="ows:OperationsMetadata/ows:Operation/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/><xsl:if test="not(contains(ows:OperationsMetadata/ows:Operation/ows:DCP/ows:HTTP/ows:Get/@xlink:href,'?'))">?</xsl:if>SERVICE=WFS&amp;REQUEST=GetCapabilities</linkage>
          <protocol>OGC:WFS-<xsl:value-of select="@version"/>-http-get-capabilities</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>      
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
      <xsl:for-each select="//wfs:OutputFormats/wfs:Format">
	      <distributionFormat>
	      		<xsl:choose>
	      			<xsl:when test="contains(., 'subType')">
	      				<name><xsl:value-of select="translate(substring-before(., 'subType'),';',' ')"/></name>
	      				<version><xsl:value-of select="substring-after(., 'subType=')"/></version>
	      			</xsl:when>
	      			<xsl:otherwise>
	      				<name><xsl:value-of select="."/></name>
	      			</xsl:otherwise>
	      		</xsl:choose>
	      </distributionFormat>
      </xsl:for-each>
    </MD_Distribution>
    </distributionInfo>

  	<!--referencni system-->
  	<xsl:for-each select="ows:OperationsMetadata/ows:Parameter[@name='srsName']/ows:AllowedValues/ows:Value">
  		<xsl:variable name="code"><xsl:call-template name="GetLastSegment">
	  	  	  	<xsl:with-param name="value" select="."/>
	  	  	  </xsl:call-template></xsl:variable>
	  	<xsl:variable name="codeSpace"><xsl:call-template name="GetBeforeLastSegment">
	  	  	  	<xsl:with-param name="value" select="."/>
	  	  	  </xsl:call-template></xsl:variable>  	  
	  	<referenceSystemInfo>
	  	  <MD_ReferenceSystem>
	  	  <referenceSystemIdentifier>
	  	  	<RS_Identifier>
	  	  		<xsl:choose>
	  	  			<xsl:when test="contains(., 'EPSG') or contains(., 'epsg')">
	  	  	  			<code>http://www.opengis.net/def/crs/EPSG/0/<xsl:value-of select="$code"/></code>
	  		  		</xsl:when>
	  		  		<xsl:otherwise>
	  	  	  			<code><xsl:value-of select="$code"/></code>
	  		  			<codeSpace><xsl:value-of select="$codeSpace"/></codeSpace>
	  		  		</xsl:otherwise>
	  		  	</xsl:choose>
	  		</RS_Identifier>
	  	  </referenceSystemIdentifier>
	  	  </MD_ReferenceSystem>
	  	</referenceSystemInfo>	 
  	</xsl:for-each>
	
	<metadataStandardName>ISO 19119</metadataStandardName>
    <metadataStandardVersion>2005</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
  	<contact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
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
  
  </xsl:template>

  <!-- Version 1.1.0 -->
  <xsl:template match="wfs:WFS_Capabilities"
      xmlns:wfs="http://www.opengis.net/wfs">

    <MD_Metadata>
    <identificationInfo>
    <SV_ServiceIdentification>
    <serviceType>
      <gco:LocalName>WFS</gco:LocalName>
      <!-- <nameNameSpace>OGC</nameNameSpace> -->
    </serviceType>
    <serviceTypeVersion><xsl:value-of select="@version"/></serviceTypeVersion>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="ows:ServiceIdentification/ows:Title"/></title>
    </CI_Citation>  
    </citation>
    <abstract> <xsl:value-of select="ows:ServiceIdentification/ows:Abstract"/> </abstract>
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees> 
    			<xsl:value-of select="ows:ServiceIdentification/ows:Fees"/>
    	  </fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="ows:ServiceIdentification/ows:Keywords/ows:Keyword">
        <keyword><xsl:value-of select="."/></keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <descriptiveKeywords>
      <MD_Keywords>
        <keyword>infoFeatureAccessService</keyword>
      	<thesaurusName>
		  <CI_Citation>
			<title>ISO - 19119 geographic services taxonomy</title>
			<date>
			  <CI_Date>
				<date>2010-01-19</date>
				<dateType>
  				  <CI_DateTypeCode>publication</CI_DateTypeCode> 
  				</dateType>
  			  </CI_Date>
      		</date>
      	  </CI_Citation>
        </thesaurusName>
      </MD_Keywords>
    </descriptiveKeywords>
    <resourceConstraints>
    	<MD_Constraints>
    		<useLimitation>XXX <xsl:value-of select="ows:ServiceIdentification/ows:Fees"/></useLimitation>
    	</MD_Constraints>	
    </resourceConstraints>
    <xsl:if test="ows:ServiceIdentification/ows:AccessConstraints">
    	<resourceConstraints>
    		<MD_LegalConstraints>
    			<otherConstraints>YYY <xsl:value-of select="ows:ServiceIdentification/AccessConstraints"/></otherConstraints>
    		</MD_LegalConstraints>
    	</resourceConstraints>
    </xsl:if>
    <pointOfContact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode>custodian</CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </pointOfContact>


    <!-- operace -->
    <xsl:for-each select="ows:OperationsMetadata/ows:Operation">
      <containsOperations>
        <SV_OperationMetadata>
          <operationName><xsl:value-of select="@name"/></operationName>
          <xsl:for-each select="ows:DCP/ows:HTTP/*">
            <connectPoint>
              <CI_OnlineResource>
              	<linkage><xsl:value-of select="@xlink:href"/></linkage>
              	<xsl:choose>
              		<xsl:when test="substring-after(translate(../../../@name,$upper,$lower),'get')!=''">
              			<protocol>OGC:WFS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="substring(translate(../../../@name,$upper,$lower),4)"/></protocol>
              		</xsl:when>
              		<xsl:otherwise>
               			<protocol>OGC:WFS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="translate(../../../@name,$upper,$lower)"/></protocol>             		
              		</xsl:otherwise>
              	</xsl:choose>		
              </CI_OnlineResource>
            </connectPoint>
          </xsl:for-each>
          <DCP>WebServices</DCP>
        </SV_OperationMetadata>
      </containsOperations>
    </xsl:for-each>
    
    <!--vrstvy-->
    <xsl:for-each select="//wfs:FeatureType[wfs:MetadataURL/@xlink:href!='']">
    	<operatesOn>
    		<href><xsl:value-of select="wfs:MetadataURL/@xlink:href"/></href>
    		<title><xsl:value-of select="wfs:Title"/></title>
    	</operatesOn>
   </xsl:for-each>
   
   <!--<xsl:for-each select="//wfs:FeatureType">
     <coupledResource>
	    <title><xsl:value-of select="wfs:Title"/></title>
		  <SV_CoupledResource>
		  	<xsl:if test="Identifier">
		    	<identifier><xsl:value-of select="Identifier/@authority"/>#<xsl:value-of select="Identifier"/></identifier>
		    </xsl:if>
		    <ScopedName><xsl:value-of select="wfs:Name"/></ScopedName>
		    <operationName>GetFeature</operationName>
		  </SV_CoupledResource>
		</coupledResource>
   </xsl:for-each>-->

    <extent>
    <EX_Extent>
      <geographicElement>
        <EX_GeographicBoundingBox>
          <westBoundLongitude><xsl:value-of select="substring-before(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:LowerCorner,' ')"/></westBoundLongitude>
          <eastBoundLongitude><xsl:value-of select="substring-before(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:UpperCorner,' ')"/></eastBoundLongitude>
          <southBoundLatitude><xsl:value-of select="substring-after(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:LowerCorner,' ')"/></southBoundLatitude>
          <northBoundLatitude><xsl:value-of select="substring-after(wfs:FeatureTypeList/wfs:FeatureType/ows:WGS84BoundingBox/ows:UpperCorner,' ')"/></northBoundLatitude>
        </EX_GeographicBoundingBox>
      </geographicElement>
    </EX_Extent>
    </extent>
    <couplingType>
      <SV_CouplingType>tight</SV_CouplingType>
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
	          <linkage><xsl:value-of select="ows:OperationsMetadata/ows:Operation/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/><xsl:if test="not(contains(ows:OperationsMetadata/ows:Operation/ows:DCP/ows:HTTP/ows:Get/@xlink:href,'?'))">?</xsl:if>SERVICE=WFS&amp;REQUEST=GetCapabilities</linkage>
	          <protocol>OGC:WFS-<xsl:value-of select="@version"/>-http-get-capabilities</protocol>
			  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
			</CI_OnlineResource>      
	        </onLine>
	      </MD_DigitalTransferOptions>  
      </transferOptions>
      <xsl:for-each select="//wfs:OutputFormats/wfs:Format">
	      <distributionFormat>
	      	<MD_Format>
	      		<xsl:choose>
	      			<xsl:when test="contains(., 'subType')">
	      				<name><xsl:value-of select="translate(substring-before(., 'subType'),';',' ')"/></name>
	      				<version><xsl:value-of select="substring-after(., 'subType=')"/></version>
	      			</xsl:when>
	      			<xsl:otherwise>
	      				<name><xsl:value-of select="."/></name>
	      			</xsl:otherwise>
	      		</xsl:choose>
	      	</MD_Format>
	      </distributionFormat>
      </xsl:for-each>
    </MD_Distribution>
    </distributionInfo>


  	<!--referencni system-->
 	<xsl:for-each select="//wfs:FeatureType/wfs:DefaultSRS|//wfs:FeatureType/wfs:OtherSRS">
  		<xsl:variable name="code"><xsl:call-template name="GetLastSegment">
	  	  	  	<xsl:with-param name="value" select="."/>
	  	  	  </xsl:call-template></xsl:variable>
	  	<xsl:variable name="codeSpace"><xsl:call-template name="GetBeforeLastSegment">
	  	  	  	<xsl:with-param name="value" select="."/>
	  	  	  </xsl:call-template></xsl:variable>  	  
	  	<referenceSystemInfo>
	  	  <MD_ReferenceSystem>
	  	  <referenceSystemIdentifier>
	  	  	<RS_Identifier>
	  	  		<xsl:choose>
	  	  			<xsl:when test="contains(., 'EPSG') or contains(., 'epsg')">
	  	  	  			<code>http://www.opengis.net/def/crs/EPSG/0/<xsl:value-of select="$code"/></code>
	  		  		</xsl:when>
	  		  		<xsl:otherwise>
	  	  	  			<code><xsl:value-of select="$code"/></code>
	  		  			<codeSpace><xsl:value-of select="$codeSpace"/></codeSpace>
	  		  		</xsl:otherwise>
	  		  	</xsl:choose>
	  		</RS_Identifier>
	  	  </referenceSystemIdentifier>
	  	  </MD_ReferenceSystem>
	  	</referenceSystemInfo>	 
	</xsl:for-each>
	
	  <metadataStandardName>ISO 19119</metadataStandardName>
    <metadataStandardVersion>2005</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
  	<contact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
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
  
  </xsl:template>

  
  <!-- Version 1.0 -->
  

	<xsl:template match="xxx">
  
    <MD_Metadata>
    <identificationInfo>
    <SV_ServiceIdentification>
    <serviceType>
      <gco:LocalName>WFS</gco:LocalName>
      <!-- <nameNameSpace>OGC</nameNameSpace> -->
    </serviceType>
    <serviceTypeVersion> <xsl:value-of select="*/@version"/> </serviceTypeVersion>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="*/wfs:Service/wfs:Title"/></title>
    </CI_Citation>  
    </citation>
    <abstract> <xsl:value-of select="*/wfs:Service/wfs:Abstract"/> </abstract>
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees><xsl:value-of select="*/wfs:Service/wfs:Fees"/></fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="*/wfs:Service/wfs:KeywordList/wfs:Keyword">
        <keyword> <xsl:value-of select="."/> </keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <descriptiveKeywords>
      <MD_Keywords>
        <keyword>infoFeatureAccessService</keyword>
      	<thesaurusName>
		  <CI_Citation>
			<title>INSPIRE Services Classification, 1.0</title>
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
    </descriptiveKeywords>
    <pointOfContact>
    <individualName> <xsl:value-of select="*/wfs:Service/wfs:ContactInformation/wfs:ContactPersonPrimary/wfs:ContactPerson"/> </individualName>
    <organisationName> <xsl:value-of select="*/wfs:Service/wfs:ContactInformation/wfs:ContactPersonPrimary/wfs:ContactOrganization"/> </organisationName>
    <contactInfo>
    <phone>
      <voice> <xsl:value-of select="*/wfs:Service/wfs:ContactInformation/wfs:ContactVoiceTelephone"/> </voice>
    </phone>
    <address>
    <deliveryPoint> <xsl:value-of select="*/wfs:Service/wfs:ContactInformation/wfs:ContactAddress/wfs:Address"/> </deliveryPoint>
    <city> <xsl:value-of select="*/wfs:Service/wfs:ContactInformation/wfs:ContactAddress/wfs:City"/> </city>
    <postalCode> <xsl:value-of select="*/wfs:Service/wfs:ContactInformation/wfs:ContactAddress/wfs:PostCode"/> </postalCode>
    <country> <xsl:value-of select="*/wfs:Service/wfs:ContactInformation/wfs:ContactAddress/wfs:Country"/> </country>
    </address>
    </contactInfo>
    </pointOfContact>


    <!-- operace -->
    <xsl:for-each select="*/wfs:Capability/wfs:Request/*">
      <containsOperations>
        <SV_OperationMetadata>
          <operationName><xsl:value-of select="name()"/></operationName>
          <xsl:for-each select="wfs:DCPType/wfs:HTTP/*">
            <connectPoint>
              <CI_OnlineResource>
              	<linkage> <xsl:value-of select="@onlineResource"/> </linkage>
              	<protocol>OGC:WFS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(name(),$upper,$lower)" />-<xsl:value-of select="substring(translate(name(../../..),$upper,$lower),4)"/></protocol>
              </CI_OnlineResource>
            </connectPoint>
          </xsl:for-each>
          <DCP>WebServices</DCP>
        </SV_OperationMetadata>
      </containsOperations>
    </xsl:for-each>
    
    <!--vrstvy-->
      <xsl:for-each select="//wfs:FeatureType">
        <operatesOn>
   	    <xsl:if test="wfs:identifier">
   	      <href><xsl:value-of select="wfs:Identifier/@authority"/>#<xsl:value-of select="wfs:Identifier"/></href>
   	    </xsl:if>  
        <MD_DataIdentification>
          <citation>
          <CI_Citation>
            <title><xsl:value-of select="wfs:Name"/></title>
          </CI_Citation>  
          </citation>
          <abstract><xsl:value-of select="wfs:Title"/></abstract>
          <extent>
            <geographicElement>
              <EX_GeographicBoundingBox>
                <westBoundLongitude><xsl:value-of select="wfs:LatLonBoundingBox/@minx"/></westBoundLongitude>
                <eastBoundLongitude><xsl:value-of select="wfs:LatLonBoundingBox/@maxx"/></eastBoundLongitude>
                <southBoundLatitude ><xsl:value-of select="wfs:LatLonBoundingBox/@miny"/></southBoundLatitude>
                <northBoundLatitude ><xsl:value-of select="wfs:LatLonBoundingBox/@maxy"/></northBoundLatitude>
              </EX_GeographicBoundingBox>
            </geographicElement>
          </extent>
        </MD_DataIdentification>
		</operatesOn>
   </xsl:for-each>
   <xsl:for-each select="//wfs:FeatureType">
     <coupledResource>
	    <title><xsl:value-of select="wfs:Title"/></title>
		  <SV_CoupledResource>
		    <xsl:if test="Identifier">
		    	<identifier><xsl:value-of select="wsf:Identifier/@authority"/>#<xsl:value-of select="wfs:Identifier"/></identifier>
		    </xsl:if>
		    <ScopedName><xsl:value-of select="wfs:Name"/></ScopedName>
		    <operationName>GetFeature</operationName>
		  </SV_CoupledResource>
		</coupledResource>
   </xsl:for-each>

    <extent>
      <geographicElement>
        <EX_GeographicBoundingBox>
          <westBoundLongitude><xsl:value-of select="*/wfs:Capability/wfs:Layer/LatLonBoundingBox/@minx"/></westBoundLongitude>
          <eastBoundLongitude><xsl:value-of select="*/wfs:Capability/wfs:Layer/LatLonBoundingBox/@maxx"/></eastBoundLongitude>
          <southBoundLatitude><xsl:value-of select="*/wfs:Capability/wfs:Layer/LatLonBoundingBox/@miny"/></southBoundLatitude>
          <northBoundLatitude><xsl:value-of select="*/wfs:Capability/wfs:Layer/LatLonBoundingBox/@maxy"/></northBoundLatitude>
        </EX_GeographicBoundingBox>
      </geographicElement>
    </extent>
    <couplingType>
      <SV_CouplingType>tight</SV_CouplingType>
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
          <linkage><xsl:value-of select="*/wfs:Capability/wfs:Request/wfs:GetCapabilities/wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource"/>?SERVICE=WFS&amp;REQUEST=GetCapabilities</linkage>
          <protocol>OGC:WFS-<xsl:value-of select="*/@version"/>-http-get-capabilities</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>      
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

  	<!--referencni system-->
  	<xsl:for-each select="*/Capability/Layer/SRS">
  	<referenceSystemInfo>
  	  <referenceSystemIdentifier>
  	  	<code><xsl:value-of select="substring-after(.,':')"/></code>
  		<codeSpace><xsl:value-of select="substring-before(.,':')"/></codeSpace>
  	  </referenceSystemIdentifier>
  	</referenceSystemInfo>	 
  	</xsl:for-each> 
	
	  <metadataStandardName>ISO 19119</metadataStandardName>
    <metadataStandardVersion>2005</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
    </MD_Metadata>
       
  </xsl:template>

  <xsl:template name="GetLastSegment">
    <xsl:param name="value" />
    <xsl:param name="separator" select="':'" />
    <xsl:choose>
      <xsl:when test="contains($value, $separator)">
        <xsl:call-template name="GetLastSegment">
          <xsl:with-param name="value" select="substring-after($value, $separator)" />
          <xsl:with-param name="separator" select="$separator" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="GetBeforeLastSegment">
    <xsl:param name="value" />
    <xsl:param name="separator" select="':'" />
    <xsl:choose>
      <xsl:when test="contains($value, $separator)">
        <xsl:value-of select="substring-before($value, $separator)"/><xsl:value-of select="$separator" />
        <xsl:call-template name="GetBeforeLastSegment">
          <xsl:with-param name="value" select="substring-after($value, $separator)" />
          <xsl:with-param name="separator" select="$separator" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
