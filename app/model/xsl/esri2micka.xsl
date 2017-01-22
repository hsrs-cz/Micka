<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8" />
<xsl:template match="/">

<results>
<MD_Metadata xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://metadata.dgiwg.org/smXML ..\smXML\metadataEntity.xsd">

	<xsl:variable name="kjazyk">
	  <xsl:choose>
		<xsl:when test="metadata/metainfo/langmeta!=''"><xsl:value-of select="metadata/metainfo/langmeta"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="metadata/@xml:lang"/></xsl:otherwise>	
	  </xsl:choose>
	</xsl:variable>

    <xsl:variable name="ser">
    		<xsl:choose>
    			<xsl:when test="string-length(metadata/Esri/Service)>0">SV_ServiceIdentification</xsl:when>
    			<xsl:otherwise>MD_DataIdentification</xsl:otherwise>
    		</xsl:choose>
    </xsl:variable>	

	<fileIdentifier>
		<xsl:value-of select="substring-before(substring-after(metadata/Esri/MetaID, '{'), '}')"/>
	</fileIdentifier>
	<language>
		<LanguageCode>
			<xsl:value-of select="document('mapping.xml')//langs/lang[@kl=$kjazyk]"/>
		</LanguageCode>
	</language>
	<hierarchyLevel>
	  <MD_ScopeCode>
    		<xsl:choose>
    			<xsl:when test="$ser='SV_ServiceIdentification'">service</xsl:when>
    			<xsl:otherwise>dataset</xsl:otherwise>
    		</xsl:choose>
    </MD_ScopeCode>
	</hierarchyLevel>
	<contact>
	  <CI_ResponsibleParty>
		<individualName>
			<xsl:value-of select="metadata/mdContact/rpIndNamee"/>
		</individualName>
		<organisationName>
			<xsl:value-of select="metadata/mdContact/rpOrgName"/>
		</organisationName>
		<positionName>
			<xsl:value-of select="metadata/mdContact/rpPosName"/>
		</positionName>
		<role>
			<CI_RoleCode_DomainCodes>
				<xsl:value-of select="metadata/mdContact/role/RoleCd/@value"/>
			</CI_RoleCode_DomainCodes>
		</role>
	  </CI_ResponsibleParty>
	</contact>
	<dateStamp>
	  <xsl:call-template name="dateParser">
	    <xsl:with-param name="d" select="metadata/Esri/CreaDate"/>
	  </xsl:call-template>  
	</dateStamp>  
	<metadataStandardName>ISO 19115/19119</metadataStandardName>
	<metadataStandardVersion>2005,2006</metadataStandardVersion>
	<identificationInfo>
		<xsl:element name="{$ser}">
  		<xsl:if test="$ser='SV_ServiceIdentification'">
  			<serviceType>
  			  <LocalName><xsl:value-of select="metadata/Esri/ServiceType"/></LocalName>
  			  <nameNameSpace>ESRI</nameNameSpace>
  			</serviceType>
  			<serviceTypeVersion><xsl:value-of select="metadata/idinfo/native"/></serviceTypeVersion>
  		</xsl:if>	
			<citation>
			  <CI_Citation>
				<title>
					<xsl:value-of select="metadata/dataIdInfo/idCitation/resTitle"/>
				</title>
				<xsl:for-each select="metadata/dataIdInfo/idCitation/resRefDate">
					<date>
					  <CI_Date>
						<date>
						  <xsl:call-template name="dateParser">
	    					<xsl:with-param name="d" select="refDate"/>
	  					  </xsl:call-template>  
						</date>
						<dateType>
							<CI_DateTypeCode_DomainCodes>
								<xsl:value-of select="refDateType/DateTypCd/@value"/>
							</CI_DateTypeCode_DomainCodes>
						</dateType>
					  </CI_Date>	
					</date>
				</xsl:for-each>
			  </CI_Citation>	
			</citation>
			<abstract>
				<xsl:value-of select="metadata/dataIdInfo/idAbs"/>
			</abstract>
			<!--
			<xsl:if test="//Binary/Thumbnail/Data/@EsriPropertyType='Picture'">
			  <graphicOverview>
			    <fileName>graphics/<xsl:value-of select="substring-before(substring-after(metadata/Esri/MetaID, '{'), '}')"/>.png</fileName>
			  </graphicOverview>
     	</xsl:if>
     	-->
			<xsl:for-each select="metadata/dataIdInfo/idCitation/citRespParty">
				<pointOfContact>
				  <CI_ResponsibleParty>
					<individualName>
						<xsl:value-of select="rpIndName"/>
					</individualName>
					<organisationName>
						<xsl:value-of select="rpOrgName"/>
					</organisationName>
					<positionName>
						<xsl:value-of select="rpPosName"/>
					</positionName>
					<contactInfo>
					  <CI_Contact>
						<phone>
						  <CI_Telephone>
							<voice>
								<xsl:value-of select="rpCntInfo/cntPhone/voiceNum"/>
							</voice>
						  </CI_Telephone>	
						</phone>
						<address>
						  <CI_Address>
							<deliveryPoint>
								<xsl:value-of select="rpCntInfo/cntAddress/delPoint"/>
							</deliveryPoint>
							<city>
								<xsl:value-of select="rpCntInfo/cntAddress/city"/>
							</city>
							<postalCode>
								<xsl:value-of select="rpCntInfo/cntAddress/postCode"/>
							</postalCode>
							<country>
								<xsl:value-of select="rpCntInfo/cntAddress/country"/>
							</country>
							<electronicMailAddress>
								<xsl:value-of select="rpCntInfo/cntAddress/eMailAdd"/>
							</electronicMailAddress>
						  </CI_Address>	
						</address>
					  </CI_Contact>
					</contactInfo>
					<role>
						<CI_RoleCode_DomainCodes>
							<xsl:value-of select="role/RoleCd/@value"/>
						</CI_RoleCode_DomainCodes>
					</role>
				  </CI_ResponsibleParty>
				</pointOfContact>
			</xsl:for-each>
			<xsl:for-each select="metadata/dataIdInfo/resConst">
				<resourceConstraints>
					<MD_LegalConstraints>
						<xsl:for-each select="Consts/useLimit">
							<useLimitation>
								<xsl:value-of select="."/>
							</useLimitation>
						</xsl:for-each>
						<xsl:for-each select="LegConsts/accessConsts">
							<accessConstraints>
								<MD_RestrictionCode_DomainCodes>
									<xsl:value-of select="RestrictCd/@value"/>
								</MD_RestrictionCode_DomainCodes>
							</accessConstraints>
						</xsl:for-each>
						<xsl:for-each select="LegConsts/useConsts">
							<useConstraints>
								<MD_RestrictionCode_DomainCodes>
									<xsl:value-of select="RestrictCd/@value"/>
								</MD_RestrictionCode_DomainCodes>
							</useConstraints>
						</xsl:for-each>
					</MD_LegalConstraints>
					<MD_SecurityConstraints>
						<!-- hrozi duplicita - vyhozeno docasne
	  <xsl:for-each select="Consts/useLimit">
		<useLimitation> <xsl:value-of select="."/> </useLimitation>
	  </xsl:for-each>
	  -->
						<classification>
							<MD_ClassificationCode_DomainCodes>
								<xsl:value-of select="SecConsts/class/ClasscationCd/@value"/>
							</MD_ClassificationCode_DomainCodes>
						</classification>
					</MD_SecurityConstraints>
				</resourceConstraints>
			</xsl:for-each>
			<resourceMaintenance>
			  <MD_MaintenanceInformation>
				<maintenanceAndUpdateFrequency>
					<MD_MaintenanceFrequencyCode_DomainCodes>
						<xsl:value-of select="metadata/dataIdInfo/resMaint/maintFreq/MaintFreqCd/@value"/>
					</MD_MaintenanceFrequencyCode_DomainCodes>
				</maintenanceAndUpdateFrequency>
			  </MD_MaintenanceInformation>
			</resourceMaintenance>
			<xsl:for-each select="metadata/dataIdInfo/descKeys">
				<descriptiveKeywords>
				  <MD_Keywords>
					<xsl:for-each select="keyword">
						<keyword>
							<xsl:value-of select="."/>
						</keyword>
					</xsl:for-each>
					<Type>
						<MD_KeywordTypeCode_DomainCodes>
							<xsl:value-of select="thesaName/resRefDate/refDateType/DateTypCd/@value"/>
						</MD_KeywordTypeCode_DomainCodes>
					</Type>
					<thesaurusName>
					  <CI_Citation>
						<title>
							<xsl:value-of select="thesaName/resTitle"/>
						</title>
						<date>
						  <CI_Date>
							<dateType>
								<CI_DateTypeCode_DomainCodes>
									<xsl:value-of select="thesaName/resRefDate/refDateType/DateTypCd/@value"/>
								</CI_DateTypeCode_DomainCodes>
							</dateType>
							<date>
							  	<xsl:call-template name="dateParser">
	    							<xsl:with-param name="d" select="refDate"/>
	  					  		</xsl:call-template>  
							</date>
						  </CI_Date>
						</date>
					  </CI_Citation>	
					</thesaurusName>
				  </MD_Keywords>
				</descriptiveKeywords>
			</xsl:for-each>
			<purpose/>
			<credit/>
			
		<xsl:if test="$ser='MD_DataIdentification'">
			<spatialRepresentationType>
				<MD_SpatialRepresentationTypeCode_DomainCodes>
					<xsl:value-of select="metadata/dataIdInfo/spatRpType/SpatRepTypCd/@value"/>
				</MD_SpatialRepresentationTypeCode_DomainCodes>
			</spatialRepresentationType>
			<spatialResolution>
			  <MD_Resolution>
				<equivalentScale>
				  <MD_RepresentativeFraction>
					<denominator>
						<xsl:value-of select="metadata/dataIdInfo/dataScale/equScale/rfDenom"/>
					</denominator>
				  </MD_RepresentativeFraction>	
				</equivalentScale>
			  </MD_Resolution>
			</spatialResolution>
			<xsl:for-each select="metadata/dataIdInfo/dataLang">
				<language>
				  <xsl:variable name="djazyk" select="languageCode/@value"/>
					<LanguageCode>
					  <xsl:value-of select="document('mapping.xml')//langs/lang[@kl=$djazyk]"/>
					</LanguageCode>
				</language>
			</xsl:for-each>
			<xsl:for-each select="metadata/dataIdInfo/tpCat">
				<topicCategory>
					<MD_TopicCategoryCode_DomainCodes>
						<xsl:value-of select="TopicCatCd/@value"/>
					</MD_TopicCategoryCode_DomainCodes>
				</topicCategory>
			</xsl:for-each>
		</xsl:if>
			
			<extent>
			  <EX_Extent>
				<verticalElement>
					<unitOfMeasure>
						<xsl:value-of select="metadata/dataIdInfo/dataExt/vertEle/vertUoM/uomName"/>
					</unitOfMeasure>
					<minimumValue>
						<xsl:value-of select="metadata/dataIdInfo/dataExt/vertEle/vertMinVal"/>
					</minimumValue>
					<maximumValue>
						<xsl:value-of select="metadata/dataIdInfo/dataExt/vertEle/vertMaxVal"/>
					</maximumValue>	
				</verticalElement>
			  	<xsl:variable name="tp" select="metadata/dataIdInfo/dataExt/tempEle/TempExtent/exTemp/TM_GeometricPrimitive/TM_Period"/>
			  	<xsl:if test="string-length($tp)>0">
				<temporalElement>
				  <EX_TemporalExtent>
					<extent>
					  <TimePeriod>
						<beginPosition>
						  <xsl:call-template name="dateParser">
	    					<xsl:with-param name="d" select="$tp/begin"/>
	  					  </xsl:call-template>  
						</beginPosition>
						<endPosition>
						  <xsl:call-template name="dateParser">
	    					<xsl:with-param name="d" select="$tp/end"/>
	  					  </xsl:call-template>  
						</endPosition>
					  </TimePeriod>
				    </extent>
  				  </EX_TemporalExtent>	
				</temporalElement>
				</xsl:if>
				<geographicElement>
					<EX_GeographicBoundingBox>
						<westBoundLongitude>
							<xsl:value-of select="translate(metadata/dataIdInfo/geoBox/westBL, ',', '.')"/>
						</westBoundLongitude>
						<eastBoundLongitude>
							<xsl:value-of select="translate(metadata/dataIdInfo/geoBox/eastBL, ',', '.')"/>
						</eastBoundLongitude>
						<southBoundLatitude>
							<xsl:value-of select="translate(metadata/dataIdInfo/geoBox/southBL, ',', '.')"/>
						</southBoundLatitude>
						<northBoundLatitude>
							<xsl:value-of select="translate(metadata/dataIdInfo/geoBox/northBL, ',', '.')"/>
						</northBoundLatitude>
					</EX_GeographicBoundingBox>
				</geographicElement>
			  </EX_Extent>
			</extent>
			
			<xsl:if test="$ser='SV_ServiceIdentification'">
  		<xsl:for-each select="//spdoinfo/ptvctinf">
      	<operatesOn xlink:href="{MetadataURL/OnlineResource/@xlink:href}">
          <MD_DataIdentification>
            <citation>
            <CI_Citation>
              <title><xsl:value-of select="esriterm/@Name"/></title>
            </CI_Citation>  
            </citation>
            <abstract><xsl:value-of select="Abstract"/></abstract>
          </MD_DataIdentification>
  		</operatesOn>
		</xsl:for-each>
    </xsl:if>
    
		</xsl:element>
	</identificationInfo>

	<!-- jakost dat -->
	<dataQualityInfo>
	  <DQ_DataQuality>
		<scope>
		  <DQ_Scope>
			<level>
				<MD_ScopeCode_DomainCodes>
					<xsl:value-of select="metadata/dqInfo/dqScope/scpLvl/ScopeCd/@value"/>
				</MD_ScopeCode_DomainCodes>
			</level>
		  </DQ_Scope>
		</scope>
		<lineage>
		  <LI_Lineage>
			<statement>
				<xsl:value-of select="metadata/dataqual/lineage/statement"/>
			</statement>
			<xsl:for-each select="metadata/dataqual/lineage/procstep">
			  <processStep>
			  	<LI_ProcessStep>
			    <description><xsl:value-of select="procdesc"/></description>
			    <dateTime>
				  <xsl:call-template name="dateParser">
   					<xsl:with-param name="d" select="procdate"/>
				  </xsl:call-template>  
				</dateTime>
			    <source>
			    	<LI_Source>
			    		<description><xsl:value-of select="srcused"/></description>
			    	</LI_Source>
			    </source>
			    </LI_ProcessStep>
			  </processStep>
			</xsl:for-each>
		  </LI_Lineage>	
		</lineage>
	  </DQ_DataQuality>	
	</dataQualityInfo>

	<!-- referencni system -->
	<referenceSystemInfo>
	  <MD_ReferenceSystem>
		<referenceSystemIdentifier>
		  <RS_Identifier>
		  <xsl:choose>
		    <xsl:when test="substring(metadata/refSysInfo/RefSystem/refSysID/identCode,1,6)='S-JTSK'">
			<code>102067</code>
			<codeSpace>EPSG</codeSpace>
			</xsl:when>
			<xsl:otherwise>
			<code>
				<xsl:value-of select="metadata/refSysInfo/RefSystem/refSysID/identCode"/>
			</code>
			<codeSpace>ESRI</codeSpace>
			</xsl:otherwise>
		  </xsl:choose>
		  </RS_Identifier>
		</referenceSystemIdentifier>
	  </MD_ReferenceSystem>
	</referenceSystemInfo>
	
	<!-- distribuce -->
	<distributionInfo>
	  <MD_Distribution>
		<xsl:for-each select="metadata/distInfo/distributor/distorFormat">
			<distributionFormat>
			  <MD_Format>
				<name>
					<xsl:value-of select="formatName"/>
				</name>
				<version>
					<xsl:value-of select="formatVer"/>
				</version>
			  </MD_Format>	
			</distributionFormat>
		</xsl:for-each>
		<xsl:for-each select="metadata/distInfo/distributor/distorTran/onLineSrc">
			<transferOptions>
			  <MD_DigitalTransferOptions>
				<onLine>
				  <CI_OnlineResource>
					<linkage>
						<xsl:value-of select="linkage"/>
					</linkage>
					<protocol>
						ESRI:AIMS--http-get-<xsl:value-of select="substring-after(linkage,'ServiceType=')"/>
					</protocol>
					<function>
						<CI_OnLineFunctionCode_DomainCodes>
							<xsl:value-of select="orFunct/OnFunctCd/@value"/>
						</CI_OnLineFunctionCode_DomainCodes>
					</function>
				  </CI_OnlineResource>
				</onLine>
			  </MD_DigitalTransferOptions>
			</transferOptions>
		</xsl:for-each>
	  </MD_Distribution>
   </distributionInfo>	
</MD_Metadata>
</results>

</xsl:template>

<xsl:template name="dateParser">
  <xsl:param name="d"/>
  <xsl:choose>
	  <xsl:when test="string-length($d)=0"></xsl:when>
	  <xsl:when test="string-length($d)=4"><xsl:value-of select="$d"/></xsl:when>
	  <xsl:when test="string-length($d)=6">
	     <xsl:value-of select="substring($d,1,4)"/>-<xsl:value-of select="substring($d,5,2)"/> 
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="substring($d,1,4)"/>-<xsl:value-of select="substring($d,5,2)"/>-<xsl:value-of select="substring($d,7,2)"/>
	  </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>
