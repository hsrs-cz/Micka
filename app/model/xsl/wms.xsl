<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:wms="http://www.opengis.net/wms"
  xmlns:gco="http://www.opengis.net/gco"
  xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
  xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
  >
  
  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
  

  <xsl:template match="WMT_MS_Capabilities">
  <results>
    <MD_Metadata>
    <contact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="Service/ContactInformation/ContactPersonPrimary/ContactPerson"/></individualName>
	    <organisationName><xsl:value-of select="Service/ContactInformation/ContactPersonPrimary/ContactOrganization"/></organisationName>
	    <contactInfo>
	      <CI_Contact>
	        <phone>
	        <CI_Telephone>
	          <voice><xsl:value-of select="Service/ContactInformation/ContactVoiceTelephone"/></voice>
	        </CI_Telephone>  
	        </phone>
	        <address>
	        <CI_Address>
	          <deliveryPoint><xsl:value-of select="Service/ContactInformation/ContactAddress/Address"/></deliveryPoint>
	          <city><xsl:value-of select="Service/ContactInformation/ContactAddress/City"/></city>
	          <postalCode><xsl:value-of select="Service/ContactInformation/ContactAddress/PostCode"/></postalCode>
	          <country><xsl:value-of select="Service/ContactInformation/ContactAddress/Country"/></country>
	          <electronicMailAddress><xsl:value-of select="Service/ContactInformation/ContactElectronicMailAddress"/></electronicMailAddress>
	        </CI_Address>
	        </address>
	      </CI_Contact>
	    </contactInfo>
	    <role>
      		<CI_RoleCode>pointOfContact</CI_RoleCode>
        </role>
	  </CI_ResponsibleParty>
    </contact>
    <identificationInfo>
    <SV_ServiceIdentification>
   		<xsl:choose>
   			<xsl:when test="string-length(//inspire_common:SpatialDataServiceType)>0">
    			<serviceType>
   					<gco:LocalName><xsl:value-of select="//inspire_common:SpatialDataServiceType"/></gco:LocalName>
    			</serviceType>
   			</xsl:when>
   			<xsl:otherwise>	
   				<serviceType>
	   				<gco:LocalName>WMS</gco:LocalName>
      			</serviceType>
    			<serviceTypeVersion><xsl:value-of select="@version"/></serviceTypeVersion>
   			</xsl:otherwise>
     	</xsl:choose>
    <citation>
      <CI_Citation>
        <title><xsl:value-of select="Service/Title"/></title>
      </CI_Citation>	
    </citation>
    <abstract><xsl:value-of select="Service/Abstract"/></abstract>
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees><xsl:value-of select="Service/Fees"/></fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="Service/KeywordList/Keyword">
        <keyword><xsl:value-of select="."/></keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <descriptiveKeywords>
      <MD_Keywords>
        <keyword>infoMapAccessService</keyword>
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
    <pointOfContact>
    <CI_ResponsibleParty>
      <individualName><xsl:value-of select="Service/ContactInformation/ContactPersonPrimary/ContactPerson"/></individualName>
      <organisationName><xsl:value-of select="Service/ContactInformation/ContactPersonPrimary/ContactOrganization"/></organisationName>
      <contactInfo>
      <CI_Contact>
        <phone>
        <CI_Telephone>
          <voice><xsl:value-of select="Service/ContactInformation/ContactVoiceTelephone"/></voice>
        </CI_Telephone>  
        </phone>
        <address>
        <CI_Address>
          <deliveryPoint><xsl:value-of select="Service/ContactInformation/ContactAddress/Address"/></deliveryPoint>
          <city><xsl:value-of select="Service/ContactInformation/ContactAddress/City"/></city>
          <postalCode><xsl:value-of select="Service/ContactInformation/ContactAddress/PostCode"/></postalCode>
          <country><xsl:value-of select="Service/ContactInformation/ContactAddress/Country"/></country>
 	      <electronicMailAddress><xsl:value-of select="Service/ContactInformation/ContactElectronicMailAddress"/></electronicMailAddress>
        </CI_Address>
        </address>
      </CI_Contact>
      </contactInfo>
      <role>
      	<CI_RoleCode>custodian</CI_RoleCode>
      </role>
    </CI_ResponsibleParty>
    </pointOfContact>

	<!-- Omezeni -->
	<resourceConstraints>
		<MD_Constraints>
			<useLimitation><xsl:value-of select="Service/Fees"/></useLimitation>
		</MD_Constraints>
	</resourceConstraints>

	<resourceConstraints>
		<MD_LegalConstraints>
			<accessConstraints><MD_RestrictionCode>otherRestrictions</MD_RestrictionCode></accessConstraints>
			<otherConstraints><xsl:value-of select="Service/AccessConstraints"/></otherConstraints>
		</MD_LegalConstraints>
	</resourceConstraints>

    <!-- operace -->
    <xsl:for-each select="Capability/Request/*">
      <containsOperations>
        <SV_OperationMetadata>
          <operationName><xsl:value-of select="name()"/></operationName>
          <xsl:for-each select="DCPType/HTTP/*">
            <connectPoint>
              <CI_OnlineResource>
              	<linkage><xsl:value-of select="OnlineResource/@*"/> </linkage>
              	<xsl:choose>
              		<xsl:when test="substring-after(translate(name(../../../.),$upper,$lower),'get')!=''">
              			<protocol>OGC:WMS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(name(),$upper,$lower)" />-<xsl:value-of select="substring-after(translate(name(../../../.),$upper,$lower),'get')"/></protocol>
              		</xsl:when>
              		<xsl:otherwise>
               			<protocol>OGC:WMS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(name(),$upper,$lower)" />-<xsl:value-of select="translate(name(../../../.),$upper,$lower)"/></protocol>             		
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
      <xsl:for-each select="//Layer[Name!='']">
    	<operatesOn>
	      <MD_DataIdentification>
	        <citation>
	          <CI_Citation>
	            <title><xsl:value-of select="Title"/></title>
	            <identifier>
	            	<RS_Identifier>
	            	  <xsl:choose>
	            	  <xsl:when test="Identifier">
	            		  <code><xsl:value-of select="Identifier"/></code>
	            		  <codeSpace><xsl:value-of select="Identifier/@authority"/></codeSpace>
	            		</xsl:when>
	            		<xsl:otherwise> 
	            		  <code></code>
	            		</xsl:otherwise>
                  </xsl:choose>  
	            	</RS_Identifier>
	            </identifier>
	          </CI_Citation>
	          </citation>
	          <abstract><xsl:value-of select="Abstract"/></abstract>
	          <extent>
	          <EX_Extent>
	            <geographicElement>
	              <EX_GeographicBoundingBox>
	                <westBoundLongitude><xsl:value-of select="LatLonBoundingBox/@minx"/></westBoundLongitude>
	                <eastBoundLongitude><xsl:value-of select="LatLonBoundingBox/@maxx"/></eastBoundLongitude>
	                <southBoundLatitude ><xsl:value-of select="LatLonBoundingBox/@miny"/></southBoundLatitude >
	                <northBoundLatitude ><xsl:value-of select="LatLonBoundingBox/@maxy"/></northBoundLatitude >
	              </EX_GeographicBoundingBox>
	            </geographicElement>
	          </EX_Extent>  
	          </extent>
	        </MD_DataIdentification>
            <xsl:if test="MetadataURL/@type='TC211' and contains(MetadataURL/Format,'xml')">
              <href><xsl:value-of select="MetadataURL/OnlineResource/@xlink:href"/>#</href>
            </xsl:if>
            
         	<xsl:if test="MetadataURL/@type='TC211' and contains(MetadataURL/Format,'xml')">
		        <xsl:variable name="id"><xsl:call-template name="getID">
		        	<xsl:with-param name="s" select="MetadataURL/OnlineResource/@xlink:href"/>
		        </xsl:call-template></xsl:variable>
            	<href><xsl:value-of select="MetadataURL/OnlineResource/@xlink:href"/>#_<xsl:value-of select="$id"/></href>
            	<title><xsl:value-of select="Title/text()"/></title>
            	<uuidref><xsl:value-of select="$id"/></uuidref>
          	</xsl:if>
		  </operatesOn>
    </xsl:for-each>		
    
    <!-- coupled resource -->
    <xsl:for-each select="//Layer[Name!='']">
      <coupledResource>
 	    <title><xsl:value-of select="Title"/></title>
  		  <SV_CoupledResource>
  		    <operationName>GetMap</operationName>
	        <xsl:choose>
	          <xsl:when test="Identifier/@authority">
	            <identifier><xsl:value-of select="Identifier/@authority"/>#<xsl:value-of select="Identifier"/></identifier>
	          </xsl:when>
	          <xsl:otherwise> 
              <identifier><xsl:value-of select="Identifier"/></identifier>
	          </xsl:otherwise>
	        </xsl:choose>  
   		    <ScopedName><xsl:value-of select="Name"/></ScopedName>
  		  </SV_CoupledResource>
  		</coupledResource>
    </xsl:for-each>		

    <extent>
    <EX_Extent>
      <geographicElement>
        <EX_GeographicBoundingBox>
          <westBoundLongitude><xsl:value-of select="Capability/Layer/LatLonBoundingBox/@minx"/></westBoundLongitude>
          <eastBoundLongitude><xsl:value-of select="Capability/Layer/LatLonBoundingBox/@maxx"/></eastBoundLongitude>
          <southBoundLatitude><xsl:value-of select="Capability/Layer/LatLonBoundingBox/@miny"/></southBoundLatitude>
          <northBoundLatitude><xsl:value-of select="Capability/Layer/LatLonBoundingBox/@maxy"/></northBoundLatitude>
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
          <linkage><xsl:value-of select="Capability/Request/GetCapabilities/DCPType/HTTP/Get/OnlineResource/@xlink:href"/><xsl:if test="not(contains(Capability/Request/GetCapabilities/DCPType/HTTP/Get/OnlineResource/@xlink:href,'?'))">?</xsl:if>SERVICE=WMS&amp;REQUEST=GetCapabilities</linkage>
          <protocol>OGC:WMS-<xsl:value-of select="@version"/>-http-get-capabilities</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>  
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

  	<!--referencni system-->
  	<xsl:for-each select="Capability/Layer/SRS">
  		<xsl:if test="position() &lt; 201">
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
			</xsl:if>		 
	</xsl:for-each>
	
	<metadataStandardName>ISO 19115/19119</metadataStandardName>
    <metadataStandardVersion>2006</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
    </MD_Metadata>
  </results>  
  </xsl:template>


<!-- Verze 1.3 -->  
  <xsl:template match="wms:WMS_Capabilities">
  <xsl:variable name="degree" select="//inspire_common:Degree"/>
  <results>
    <MD_Metadata>
    <contact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactPerson"/></individualName>
	    <organisationName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization"/></organisationName>
	    <positionName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPosition"/></positionName>
	    <contactInfo>
	      <CI_Contact>
	        <phone>
	        <CI_Telephone>
	          <voice><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactVoiceTelephone"/></voice>
	        </CI_Telephone>  
	        </phone>
	        <address>
	        <CI_Address>
	          <deliveryPoint><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Address"/></deliveryPoint>
	          <city><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:City"/></city>
	          <postalCode><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:PostCode"/></postalCode>
	          <country><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Country"/></country>
	          <electronicMailAddress><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactElectronicMailAddress"/></electronicMailAddress>
	        </CI_Address>
	        </address>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode>pointOfContact</CI_RoleCode>
	    </role>
	  </CI_ResponsibleParty>
    </contact>
    
    <identificationInfo>
    <SV_ServiceIdentification>
  		<xsl:choose>
   			<xsl:when test="string-length(//inspire_common:SpatialDataServiceType)>0">
    			<serviceType>
   					<gco:LocalName><xsl:value-of select="//inspire_common:SpatialDataServiceType"/></gco:LocalName>
    			</serviceType>
   			</xsl:when>
   			<xsl:otherwise>	
   				<serviceType>
	   				<gco:LocalName>WMS</gco:LocalName>
      			</serviceType>
    			<serviceTypeVersion><xsl:value-of select="@version"/> <xsl:value-of select="//inspire_vs:ExtendedCapabilities/inspire_common:Conformity/*"/></serviceTypeVersion>
   			</xsl:otherwise>
     	</xsl:choose>
    <citation>
      <CI_Citation>
        <title><xsl:value-of select="wms:Service/wms:Title"/></title>
        <date>
        	<CI_Date>
        		<date><xsl:value-of select="//inspire_common:TemporalReference/inspire_common:DateOfLastRevision"/></date>
        		<dateType>
					<CI_DateTypeCode>revision</CI_DateTypeCode>
				</dateType>
        	</CI_Date>
        </date>
        <identifier>
        	<RS_Identifier>
        		<code><xsl:if test="wms:Capability/wms:Layer/wms:Identifier/@authority"><xsl:value-of select="wms:Capability/wms:Layer/wms:Identifier/@authority"/>-</xsl:if><xsl:value-of select="wms:Capability/wms:Layer/wms:Identifier"/></code>
        	</RS_Identifier>
        </identifier>
      </CI_Citation>	
    </citation>
    <abstract><xsl:value-of select="wms:Service/wms:Abstract"/></abstract>
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees> 
    			<xsl:value-of select="wms:Service/wms:Fees"/>
    	  	</fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="//wms:KeywordList/wms:Keyword">
        <keyword><xsl:value-of select="."/></keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <descriptiveKeywords>
      <MD_Keywords>
        <keyword>infoMapAccessService</keyword>
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
    </descriptiveKeywords>
    
    <descriptiveKeywords>
    	<MD_Keywords>
		    <xsl:for-each select="//inspire_common:Keyword[contains(inspire_common:OriginatingControlledVocabulary/inspire_common:Title,'INSPIRE')]">
		    	<keyword><xsl:value-of select="inspire_common:KeywordValue"/></keyword>
		     	<thesaurusName>
				  <CI_Citation>
					<title><xsl:value-of select="inspire_common:OriginatingControlledVocabulary/inspire_common:Title"/></title>
					<date>
					  <CI_Date>
						<date><xsl:choose>
							<xsl:when test="contains(inspire_common:OriginatingControlledVocabulary/inspire_common:DateOfPublication,'T')"></xsl:when>
							<xsl:otherwise><xsl:value-of select="inspire_common:OriginatingControlledVocabulary/inspire_common:DateOfPublication"/></xsl:otherwise>
							</xsl:choose></date>
						<dateType>
		  				  <CI_DateTypeCode>publication</CI_DateTypeCode> 
		  				</dateType>
		  			  </CI_Date>
		      		</date>
		      	  </CI_Citation>
		        </thesaurusName>
	        </xsl:for-each>
	    </MD_Keywords>
    </descriptiveKeywords>
    
    <pointOfContact>

    <CI_ResponsibleParty>
      <individualName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactPerson"/></individualName>
      <organisationName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization"/></organisationName>
	  <positionName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPosition"/></positionName>
      <contactInfo>
      <CI_Contact>
        <phone>
        <CI_Telephone>
          <voice><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactVoiceTelephone"/></voice>
        </CI_Telephone>  
        </phone>
        <address>
        <CI_Address>
          <deliveryPoint><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Address"/></deliveryPoint>
          <city><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:City"/></city>
          <postalCode><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:PostCode"/></postalCode>
          <country><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Country"/></country>
	      <electronicMailAddress><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactElectronicMailAddress"/></electronicMailAddress>
        </CI_Address>
        </address>
      </CI_Contact>
      </contactInfo>
      <role>
	   	<CI_RoleCode>custodian</CI_RoleCode>
	  </role>
    </CI_ResponsibleParty>
    </pointOfContact>

	<!-- Omezeni -->
	<resourceConstraints>
		<MD_Constraints>
			<useLimitation><xsl:value-of select="wms:Service/wms:Fees"/></useLimitation>
		</MD_Constraints>
	</resourceConstraints>

	<resourceConstraints>
		<MD_LegalConstraints>
			<accessConstraints><MD_RestrictionCode>otherRestrictions</MD_RestrictionCode></accessConstraints>
			<otherConstraints><xsl:value-of select="wms:Service/wms:AccessConstraints"/></otherConstraints>
		</MD_LegalConstraints>
	</resourceConstraints>
	
    <!-- operace -->
    <xsl:for-each select="wms:Capability/wms:Request/*">
      <containsOperations>
        <SV_OperationMetadata>
          <operationName><xsl:value-of select="name()"/></operationName>
          <xsl:for-each select="wms:DCPType/wms:HTTP/*">
            <connectPoint>
              <CI_OnlineResource>
              	<linkage><xsl:value-of select="wms:OnlineResource/@xlink:href"/> </linkage>
              	<xsl:choose>
              		<xsl:when test="substring-after(translate(name(../../../.),$upper,$lower),'get')!=''">
              			<protocol>OGC:WMS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(name(),$upper,$lower)" />-<xsl:value-of select="substring-after(translate(name(../../../.),$upper,$lower),'get')"/></protocol>
              		</xsl:when>
              		<xsl:otherwise>
               			<protocol>OGC:WMS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(name(),$upper,$lower)" />-<xsl:value-of select="translate(name(../../../.),$upper,$lower)"/></protocol>             		
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
      <xsl:for-each select="wms:Capability//wms:Layer[wms:Name!='']">
    	<operatesOn>
	        <MD_DataIdentification>
	          <citation>
	          <CI_Citation>
	            <title><xsl:value-of select="wms:Title"/></title>
	            <identifier>
	            	<RS_Identifier>
	            	  <xsl:choose>
	            	  <xsl:when test="wms:Identifier">
	            		  <code><xsl:value-of select="wms:Identifier"/></code>
	            		  <codeSpace><xsl:value-of select="wms:Identifier/@authority"/></codeSpace>	            		
	                  </xsl:when>
		            		<xsl:otherwise> 
		            		  <code></code>
		            		</xsl:otherwise>
	                  </xsl:choose>  	            		
	            	</RS_Identifier>
	            </identifier>
	          </CI_Citation>
	          </citation>
	          <abstract><xsl:value-of select="wms:Abstract"/></abstract>
	          <extent>
	          <EX_Extent>
	            <geographicElement>
	              <EX_GeographicBoundingBox>
	                <westBoundLongitude><xsl:value-of select="wms:EX_GeographicBoundingBox/wms:westBoundLongitude"/></westBoundLongitude>
	                <eastBoundLongitude><xsl:value-of select="wms:EX_GeographicBoundingBox/wms:eastBoundLongitude"/></eastBoundLongitude>
	                <southBoundLatitude><xsl:value-of select="wms:EX_GeographicBoundingBox/wms:southBoundLatitude"/></southBoundLatitude>
	                <northBoundLatitude><xsl:value-of select="wms:EX_GeographicBoundingBox/wms:northBoundLatitude"/></northBoundLatitude>
	              </EX_GeographicBoundingBox>
	            </geographicElement>
	          </EX_Extent>  
	          </extent>
	        </MD_DataIdentification>
          	<xsl:if test="wms:MetadataURL/@type='ISO19115:2003' and contains(wms:MetadataURL/wms:Format,'xml')">
		        <xsl:variable name="id"><xsl:call-template name="getID">
		        	<xsl:with-param name="s" select="wms:MetadataURL/wms:OnlineResource/@xlink:href"/>
		        </xsl:call-template></xsl:variable>
            	<href><xsl:value-of select="wms:MetadataURL/wms:OnlineResource/@xlink:href"/>#_<xsl:value-of select="$id"/></href>
            	<title><xsl:value-of select="wms:Title/text()"/></title>
            	<uuidref><xsl:value-of select="$id"/></uuidref>
          	</xsl:if>
   		</operatesOn>
    </xsl:for-each>

    <xsl:for-each select="//wms:Layer[wms:Name!='']">
      <coupledResource>
	      <title><xsl:value-of select="wms:Title"/></title>
  		  <SV_CoupledResource>
 		      <operationName>GetMap</operationName>
  		    <xsl:if test="wms:Identifier">
  		      <identifier><xsl:value-of select="wms:Identifier/@authority"/>#<xsl:value-of select="wms:Identifier"/></identifier>
  		    </xsl:if>
          <ScopedName><xsl:value-of select="wms:Name"/></ScopedName>
  		  </SV_CoupledResource>
  		</coupledResource>
    </xsl:for-each>		

    <extent>
    <EX_Extent>
      <geographicElement>
        <EX_GeographicBoundingBox>
          <westBoundLongitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:westBoundLongitude"/></westBoundLongitude>
          <eastBoundLongitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:eastBoundLongitude"/></eastBoundLongitude>
          <southBoundLatitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:southBoundLatitude"/></southBoundLatitude>
          <northBoundLatitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:northBoundLatitude"/></northBoundLatitude>
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
          <linkage><xsl:value-of select="wms:Capability/wms:Request/wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href"/><xsl:if test="not(contains(wms:Capability/wms:Request/wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href,'?'))">?</xsl:if>SERVICE=WMS&amp;REQUEST=GetCapabilities</linkage>
          <protocol>OGC:WMS-<xsl:value-of select="@version"/>-http-get-capabilities</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>  
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

  	<!-- referencni system -->
  	<xsl:for-each select="wms:Capability/wms:Layer/wms:CRS">
  		<xsl:if test="position() &lt; 201">
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
		</xsl:if>	 
	</xsl:for-each>

	
	<!-- Soulad se specifikacĂ­ -->
	<xsl:if test="$degree='conformant' or $degree='notConformant'">
		<dataQualityInfo>
			<DQ_DataQuality>
				<scope>
					<DQ_Scope>
						<level>
							<MD_ScopeCode>service</MD_ScopeCode>
						</level>	
					</DQ_Scope>
				</scope>
				<report>
					<DQ_DomainConsistency>
						<result>
							<DQ_ConformanceResult>
								<specification>
									<CI_Citation>
										<title><xsl:value-of select="//inspire_common:Conformity/*/inspire_common:Title"/></title>
										<date>
											<CI_Date>
												<date><xsl:value-of select="//inspire_common:Conformity/*/inspire_common:DateOfPublication"/></date>
												<dateType>
													<CI_DateTypeCode>publication</CI_DateTypeCode>
												</dateType>
											</CI_Date>
										</date>
									</CI_Citation>
								</specification>
								<explanation>Viz odkazovanou specifikaci</explanation>
								<xsl:choose>
									<xsl:when test="$degree='conformant'">
										<pass>true</pass>
									</xsl:when>
									<xsl:otherwise>
										<pass>false</pass>
									</xsl:otherwise>
								</xsl:choose>								
							</DQ_ConformanceResult>
						</result>
					</DQ_DomainConsistency>					
				</report>
			</DQ_DataQuality>
		</dataQualityInfo>
	</xsl:if>
	
	<!-- metadata -->
	<metadataStandardName>ISO 19115/19119</metadataStandardName>
    <metadataStandardVersion>2003, cor. 2006</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
  	<xsl:choose>
	    <xsl:when test="contains(//inspire_common:MetadataDate,'T')">
			<dateStamp><xsl:value-of select="substring-before(//inspire_common:MetadataDate,'T')"/></dateStamp>
	  	</xsl:when>
	    <xsl:when test="//inspire_common:MetadataDate!=''">
			<dateStamp><xsl:value-of select="//inspire_common:MetadataDate"/></dateStamp>
	  	</xsl:when>
  	</xsl:choose>
  	
    </MD_Metadata>
  </results>  
  </xsl:template>  
  
  <xsl:template name="getID">
  	<xsl:param name="s"/>
  	<xsl:if test="contains($s,'&amp;')">
	  	<xsl:variable name="vysl" select="substring-after($s,'&amp;')"/>
	  	<xsl:choose>
		  	<xsl:when test="translate(substring($vysl,1,3),'ID','id')='id='">
		  		<xsl:choose>
		  			<xsl:when test="contains($vysl,'&amp;')">
		  				<xsl:value-of select="substring-before(substring-after($vysl,'='),'&amp;')"/>
		  			</xsl:when>
		  			<xsl:otherwise>	
		  				<xsl:value-of select="substring-after($vysl,'=')"/>
		  			</xsl:otherwise>	
		  		</xsl:choose>	
		  	</xsl:when>
		  	<xsl:otherwise>
		  		<xsl:call-template name="getID">
		  			<xsl:with-param name="s" select="$vysl"/>
		  		</xsl:call-template>
		  	</xsl:otherwise>
	  	</xsl:choose>
  	</xsl:if>
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
