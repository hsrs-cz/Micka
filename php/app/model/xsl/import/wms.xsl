<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:wms="http://www.opengis.net/wms"
    xmlns:gco="http://www.opengis.net/gco"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
  xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
  >
  
  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="codeLists" select="document('../../../config/codelists.xml')/map"/>
  
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
          <name>WMS</name>
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
  <xsl:variable name="mdlang" select="//inspire_common:ResponseLanguage/*"/>
  <xsl:variable name="degree" select="//inspire_common:Degree"/>
  <results>
    <xsl:choose>
        <!-- copies metadata from linked metadata record -->
        <xsl:when test="//inspire_common:MetadataUrl/inspire_common:URL">
            <xsl:copy-of select="document(//inspire_common:MetadataUrl/inspire_common:URL)/*/*"/>
        </xsl:when>
        <xsl:otherwise>

        <gmd:MD_Metadata>

        <gmd:contact>
          <gmd:CI_ResponsibleParty>
            <gmd:individualName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactPerson"/></gmd:individualName>
            <gmd:organisationName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization"/></gmd:organisationName>
            <gmd:positionName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPosition"/></gmd:positionName>
            <gmd:contactInfo>
              <gmd:CI_Contact>
                <gmd:phone>
                <gmd:CI_Telephone>
                  <gmd:voice><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactVoiceTelephone"/></gmd:voice>
                </gmd:CI_Telephone>  
                </gmd:phone>
                <gmd:address>
                <gmd:CI_Address>
                  <gmd:deliveryPoint><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Address"/></gmd:deliveryPoint>
                  <gmd:city><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:City"/></gmd:city>
                  <gmd:postalCode><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:PostCode"/></gmd:postalCode>
                  <gmd:country><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Country"/></gmd:country>
                  <gmd:electronicMailAddress><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactElectronicMailAddress"/></gmd:electronicMailAddress>
                </gmd:CI_Address>
                </gmd:address>
              </gmd:CI_Contact>
            </gmd:contactInfo>
            <gmd:role>
                <gmd:CI_RoleCode codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
            </gmd:role>
          </gmd:CI_ResponsibleParty>
        </gmd:contact>
        
        <gmd:identificationInfo>
        <srv:SV_ServiceIdentification>
            <xsl:choose>
                <xsl:when test="string-length(//inspire_common:SpatialDataServiceType)>0">
                    <srv:serviceType>
                        <gco:LocalName codeSpace="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType"><xsl:value-of select="//inspire_common:SpatialDataServiceType"/></gco:LocalName>
                    </srv:serviceType>
                </xsl:when>
                <xsl:otherwise>	
                    <srv:serviceType>
                        <gco:LocalName codeSpace="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType">view</gco:LocalName>
                    </srv:serviceType>
                    <serviceTypeVersion><xsl:value-of select="@version"/> <xsl:value-of select="//inspire_vs:ExtendedCapabilities/inspire_common:Conformity/*"/></serviceTypeVersion>
                </xsl:otherwise>
            </xsl:choose>
            <gmd:citation>
              <gmd:CI_Citation>
                <gmd:title><xsl:value-of select="wms:Service/wms:Title"/></gmd:title>
                <gmd:date>
                    <gmd:CI_Date>
                        <gmd:date><xsl:value-of select="//inspire_common:TemporalReference/inspire_common:DateOfLastRevision"/></gmd:date>
                        <gmd:dateType>
                            <gmd:CI_DateTypeCode codeListValue="revision">revision</gmd:CI_DateTypeCode>
                        </gmd:dateType>
                    </gmd:CI_Date>
                </gmd:date>
                <gmd:identifier>
                    <gmd:RS_Identifier>
                        <gmd:code><xsl:if test="wms:Capability/wms:Layer/wms:Identifier/@authority"><xsl:value-of select="wms:Capability/wms:Layer/wms:Identifier/@authority"/>-</xsl:if><xsl:value-of select="wms:Capability/wms:Layer/wms:Identifier"/></gmd:code>
                    </gmd:RS_Identifier>
                </gmd:identifier>
              </gmd:CI_Citation>
            </gmd:citation>
            <gmd:abstract><xsl:value-of select="wms:Service/wms:Abstract"/></gmd:abstract>
            <gmd:accessProperties>
                <gmd:MD_StandardOrderProcess>
                    <gmd:fees> 
                        <xsl:value-of select="wms:Service/wms:Fees"/>
                    </gmd:fees>
                </gmd:MD_StandardOrderProcess> 
            </gmd:accessProperties>
            <gmd:descriptiveKeywords>
                <gmd:MD_Keywords>
                    <xsl:for-each select="*/Service/wms:KeywordList/wms:Keyword">
                        <gmd:keyword><xsl:value-of select="."/></gmd:keyword>
                    </xsl:for-each>
                </gmd:MD_Keywords>
            </gmd:descriptiveKeywords>
            
            <gmd:descriptiveKeywords>
              <gmd:MD_Keywords>
                <gmd:keyword>
                    <gmx:Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoMapAccessService">infoMapAccessService</gmx:Anchor>
                </gmd:keyword>
                <gmd:thesaurusName>
                    <gmd:CI_Citation>
                        <gmd:title>ISO 19119 geographic services taxonomy</gmd:title>
                        <gmd:date>
                            <gmd:CI_Date>
                                <gmd:date>2008</gmd:date>
                                <gmd:dateType>
                                    <gmd:CI_DateTypeCode codeListValue="publication">publication</gmd:CI_DateTypeCode> 
                                </gmd:dateType>
                            </gmd:CI_Date>
                        </gmd:date>
                    </gmd:CI_Citation>
                </gmd:thesaurusName>
              </gmd:MD_Keywords>
            </gmd:descriptiveKeywords>
        
            <gmd:descriptiveKeywords>
                <gmd:MD_Keywords>
                    <xsl:for-each select="//inspire_common:Keyword[contains(inspire_common:OriginatingControlledVocabulary/inspire_common:Title,'INSPIRE')]">
                        <gmd:keyword>
                            <xsl:variable name="t" select="inspire_common:KeywordValue"/>
                            <gmx:Anchor xlink:href="{$codeLists/inspireKeywords/value/*[translate(.,$upper,$lower)=translate($t,$upper,$lower)]/../@uri}"><xsl:value-of select="$t"/></gmx:Anchor>
                        </gmd:keyword>
                        <gmd:thesaurusName>
                          <gmd:CI_Citation>
                            <gmd:title><xsl:value-of select="inspire_common:OriginatingControlledVocabulary/inspire_common:Title"/></gmd:title>
                            <gmd:date>
                              <gmd:CI_Date>
                                <gmd:date><xsl:choose>
                                    <xsl:when test="contains(inspire_common:OriginatingControlledVocabulary/inspire_common:DateOfPublication,'T')"></xsl:when>
                                    <xsl:otherwise><xsl:value-of select="inspire_common:OriginatingControlledVocabulary/inspire_common:DateOfPublication"/></xsl:otherwise>
                                    </xsl:choose></gmd:date>
                                <gmd:dateType>
                                  <CI_DateTypeCode>publication</CI_DateTypeCode> 
                                </gmd:dateType>
                              </gmd:CI_Date>
                            </gmd:date>
                          </gmd:CI_Citation>
                        </gmd:thesaurusName>
                    </xsl:for-each>
                </gmd:MD_Keywords>
            </gmd:descriptiveKeywords>
        
            <gmd:pointOfContact>
                <gmd:CI_ResponsibleParty>
                  <gmd:individualName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactPerson"/></gmd:individualName>
                  <gmd:organisationName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization"/></gmd:organisationName>
                  <gmd:positionName><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactPosition"/></gmd:positionName>
                  <gmd:contactInfo>
                  <gmd:CI_Contact>
                    <gmd:phone>
                    <gmd:CI_Telephone>
                      <gmd:voice><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactVoiceTelephone"/></gmd:voice>
                    </gmd:CI_Telephone>  
                    </gmd:phone>
                    <gmd:address>
                    <gmd:CI_Address>
                      <gmd:deliveryPoint><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Address"/></gmd:deliveryPoint>
                      <gmd:city><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:City"/></gmd:city>
                      <gmd:postalCode><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:PostCode"/></gmd:postalCode>
                      <gmd:country><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactAddress/wms:Country"/></gmd:country>
                      <gmd:electronicMailAddress><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactElectronicMailAddress"/></gmd:electronicMailAddress>
                    </gmd:CI_Address>
                    </gmd:address>
                  </gmd:CI_Contact>
                  </gmd:contactInfo>
                  <gmd:role>
                    <gmd:CI_RoleCode codeListValue="custodian">custodian</gmd:CI_RoleCode>
                  </gmd:role>
                </gmd:CI_ResponsibleParty>
            </gmd:pointOfContact>

            <!-- Omezeni -->       
            <gmd:resourceConstraints>
                <gmd:MD_LegalConstraints>
                    <gmd:useConstraints>
                        <gmd:MD_RestrictionCode codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
                    </gmd:useConstraints>
                    <gmd:otherConstraints><xsl:value-of select="wms:Service/wms:Fees"/></gmd:otherConstraints>
                </gmd:MD_LegalConstraints>
            </gmd:resourceConstraints>
            
            <gmd:resourceConstraints>
                <gmd:MD_LegalConstraints>
                    <gmd:accessConstraints>
                        <gmd:MD_RestrictionCode codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
                    </gmd:accessConstraints>
                    <gmd:otherConstraints><xsl:value-of select="wms:Service/wms:AccessConstraints"/></gmd:otherConstraints>
                </gmd:MD_LegalConstraints>
            </gmd:resourceConstraints>
        
            <!-- operace -->
            <xsl:for-each select="wms:Capability/wms:Request/*">
                <srv:containsOperations>
                    <srv:SV_OperationMetadata>
                        <srv:operationName><xsl:value-of select="name()"/></srv:operationName>
                            <xsl:for-each select="wms:DCPType/wms:HTTP/*">
                                <gmd:connectPoint>
                                    <srv:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL><xsl:value-of select="wms:OnlineResource/@xlink:href"/></gmd:URL>
                                        </gmd:linkage>
                                        <xsl:choose>
                                            <xsl:when test="substring-after(translate(name(../../../.),$upper,$lower),'get')!=''">
                                                <gmd:protocol>OGC:WMS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(name(),$upper,$lower)" />-<xsl:value-of select="substring-after(translate(name(../../../.),$upper,$lower),'get')"/></gmd:protocol>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <gmd:protocol>OGC:WMS-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(name(),$upper,$lower)" />-<xsl:value-of select="translate(name(../../../.),$upper,$lower)"/></gmd:protocol>
                                            </xsl:otherwise>
                                        </xsl:choose>		
                                    </srv:CI_OnlineResource>
                                </gmd:connectPoint>
                            </xsl:for-each>
                        <srv:DCP><srv:DCPList codeListValue="WebServices"/></srv:DCP>
                    </srv:SV_OperationMetadata>
                </srv:containsOperations>
            </xsl:for-each>
        
        <!-- vrstvy -->
          <xsl:for-each select="wms:Capability//wms:Layer[wms:Name!='']">
            <operatesOn>
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

        <!-- rozsah -->
        <srv:extent>
            <gmd:EX_Extent>
                <gmd:geographicElement>
                    <gmd:EX_GeographicBoundingBox>
                        <gmd:westBoundLongitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:westBoundLongitude"/></gmd:westBoundLongitude>
                        <gmd:eastBoundLongitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:eastBoundLongitude"/></gmd:eastBoundLongitude>
                        <gmd:southBoundLatitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:southBoundLatitude"/></gmd:southBoundLatitude>
                        <gmd:northBoundLatitude><xsl:value-of select="wms:Capability/wms:Layer/wms:EX_GeographicBoundingBox/wms:northBoundLatitude"/></gmd:northBoundLatitude>
                    </gmd:EX_GeographicBoundingBox>
                </gmd:geographicElement>
            </gmd:EX_Extent>  
        </srv:extent>
        <srv:couplingType>
          <srv:SV_CouplingType codeListValue="tight">tight</srv:SV_CouplingType>
        </srv:couplingType>
        </srv:SV_ServiceIdentification>
        </gmd:identificationInfo>

        <!-- distribuce -->
        <gmd:distributionInfo>
            <gmd:MD_Distribution>
                <gmd:transferOptions>
                    <gmd:MD_DigitalTransferOptions>
                        <gmd:onLine>
                            <gmd:CI_OnlineResource>
                                <gmd:linkage>
                                    <gmd:URL><xsl:value-of select="wms:Capability/wms:Request/wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href"/><xsl:if test="not(contains(wms:Capability/wms:Request/wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href,'?'))">?</xsl:if>SERVICE=WMS&amp;REQUEST=GetCapabilities</gmd:URL>
                                </gmd:linkage>
                                <gmd:protocol>
                                    <gmx:Anchor xlink:href="http://services.cuzk.cz/registry/codelist/OnlineResourceProtocolValue/OGC:WMS-{@version}-http-get-capabilities">OGC:WMS-<xsl:value-of select="@version"/>-http-get-capabilities</gmx:Anchor>
                                </gmd:protocol>
                                <gmd:function>
                                    <gmd:CI_OnLineFunctionCode codeListValue="download">download</gmd:CI_OnLineFunctionCode>
                                </gmd:function>
                                <gmd:name>WMS</gmd:name>
                            </gmd:CI_OnlineResource>  
                        </gmd:onLine>
                    </gmd:MD_DigitalTransferOptions>  
                </gmd:transferOptions>
            </gmd:MD_Distribution>
        </gmd:distributionInfo>

        <!-- coordinate reference system -->
        <xsl:for-each select="wms:Capability/wms:Layer/wms:CRS">
            <xsl:if test="position() &lt; 201">
                <xsl:variable name="code"><xsl:call-template name="GetLastSegment">
                    <xsl:with-param name="value" select="."/>
                </xsl:call-template></xsl:variable>
                <xsl:variable name="codeSpace"><xsl:call-template name="GetBeforeLastSegment">
                    <xsl:with-param name="value" select="."/>
                </xsl:call-template></xsl:variable>  	  
                <gmd:referenceSystemInfo>
                  <gmd:MD_ReferenceSystem>
                  <gmd:referenceSystemIdentifier>
                    <gmd:RS_Identifier>
                        <xsl:choose>
                            <xsl:when test="contains(., 'EPSG') or contains(., 'epsg')">
                                <gmd:code>
                                    <gmx:Anchor xlink:href="http://www.opengis.net/def/crs/EPSG/0/{$code}">EPSG:<xsl:value-of select="$code"/></gmx:Anchor>
                                </gmd:code>
                            </xsl:when>
                            <xsl:otherwise>
                                <gmd:code><xsl:value-of select="$code"/></gmd:code>
                                <gmd:codeSpace><xsl:value-of select="$codeSpace"/></gmd:codeSpace>
                            </xsl:otherwise>
                        </xsl:choose>
                    </gmd:RS_Identifier>
                  </gmd:referenceSystemIdentifier>
                  </gmd:MD_ReferenceSystem>
                </gmd:referenceSystemInfo>
            </xsl:if>	 
        </xsl:for-each>

        
        <!-- Specification -->
        <xsl:if test="$degree='conformant' or $degree='notConformant' or $degree='notEvaluated'">
            <gmd:dataQualityInfo>
                <gmd:DQ_DataQuality>
                    <gmd:scope>
                        <gmd:DQ_Scope>
                            <gmd:level>
                                <gmd:MD_ScopeCode codeListValue="service">service</gmd:MD_ScopeCode>
                            </gmd:level>	
                        </gmd:DQ_Scope>
                    </gmd:scope>
                    <gmd:report>
                        <gmd:DQ_DomainConsistency>
                            <gmd:result>
                                <gmd:DQ_ConformanceResult>
                                    <gmd:specification>
                                        <gmd:CI_Citation>
                                            <xsl:variable name="t" select="normalize-space(//inspire_common:Conformity/*/inspire_common:Title)"/>
                                            <gmd:title>
                                                <gmx:Anchor xlink:href="{$codeLists/specifications/value/*[translate(@name,$upper,$lower)=translate($t,$upper,$lower)]/../@uri}"><xsl:value-of select="$t"/></gmx:Anchor>
                                            </gmd:title>
                                            <gmd:date>
                                                <gmd:CI_Date>
                                                    <gmd:date><xsl:value-of select="//inspire_common:Conformity/*/inspire_common:DateOfPublication"/></gmd:date>
                                                    <gmd:dateType>
                                                        <gmd:CI_DateTypeCode codeListValue="publication">publication</gmd:CI_DateTypeCode>
                                                    </gmd:dateType>
                                                </gmd:CI_Date>
                                            </gmd:date>
                                        </gmd:CI_Citation>
                                    </gmd:specification>
                                    <gmd:explanation>Viz odkazovanou specifikaci</gmd:explanation>
                                    <xsl:choose>
                                        <xsl:when test="$degree='conformant'">
                                            <gmd:pass>true</gmd:pass>
                                        </xsl:when>
                                        <xsl:when test="$degree='notConformant'">
                                            <gmd:pass>false</gmd:pass>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <gmd:pass></gmd:pass>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </gmd:DQ_ConformanceResult>
                            </gmd:result>
                        </gmd:DQ_DomainConsistency>
                    </gmd:report>
                </gmd:DQ_DataQuality>
            </gmd:dataQualityInfo>
        </xsl:if>
        
        <!-- metadata -->
        <gmd:metadataStandardName>ISO 19115/INSPIRE_TG2/CZ4</gmd:metadataStandardName>
        <gmd:metadataStandardVersion>2003/cor.1/2006</gmd:metadataStandardVersion>
        <hierarchyLevel>
            <gmd:MD_ScopeCode codeListValue="service">service</gmd:MD_ScopeCode>
        </hierarchyLevel>
        <xsl:choose>
            <xsl:when test="contains(//inspire_common:MetadataDate,'T')">
                <gmd:dateStamp><xsl:value-of select="substring-before(//inspire_common:MetadataDate,'T')"/></gmd:dateStamp>
            </xsl:when>
            <xsl:when test="//inspire_common:MetadataDate!=''">
                <gmd:dateStamp><xsl:value-of select="//inspire_common:MetadataDate"/></gmd:dateStamp>
            </xsl:when>
        </xsl:choose>
        <gmd:language>
            <gmd:LanguageCode codeListValue="{//inspire_common:ResponseLanguage/*}"><xsl:value-of select="//inspire_common:ResponseLanguage/*"/></gmd:LanguageCode>
        </gmd:language>
        
    </gmd:MD_Metadata>
    </xsl:otherwise>
    </xsl:choose>
    </results>  
  </xsl:template>  
  
  <xsl:template name="getID">
  	<xsl:param name="s"/>
  	<xsl:variable name="u">
  		<xsl:choose>
		  	<xsl:when test="contains($s,'id=')">
		  		<xsl:value-of select="substring-after($s,'id=')"/>
		  	</xsl:when>
		  	<xsl:when test="contains($s,'ID=')">
		  		<xsl:value-of select="substring-after($s,'ID=')"/>
		  	</xsl:when>
		</xsl:choose>
  	</xsl:variable>
  	<xsl:choose>
	  	<xsl:when test="contains($u,'&amp;')">
	  		<xsl:value-of select="substring-before($u,'&amp;')"/>
	  	</xsl:when>
	  	<xsl:otherwise>
	  		<xsl:value-of select="$u"/>
	  	</xsl:otherwise>
  	</xsl:choose>
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
