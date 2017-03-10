<!-- DWXMLSource="../../../../../Inetpub/wwwroot/xml/export2.xml" --><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="/">

<csw:GetRecordsResponse xmlns:csw="http://www.opengis.net/cat/csw" xmlns="http://metadata.dgiwg.org/smXML" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:ows="http://www.opengis.net/ows" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/cat/csw
C:\dokumentace\ogc\catalog\csw\2.0.1\CSW-discovery_139.xsd" version="2.0.1">
	<csw:RequestId><xsl:value-of select="$REQUESTID"/></csw:RequestId>
	<csw:SearchStatus timestamp="{$timestamp}" status="complete"/>
      <csw:SearchResults numberOfRecordsMatched="{results/@numberOfRecordsMatched}" numberOfRecordsReturned="{results/@numberOfRecordsReturned}" nextRecord="{results/@nextRecord}" elementSet="brief">

<xsl:variable name="ser">
		<xsl:choose>
			<xsl:when test="string-length(results/MD_Metadata/identificationInfo/MD_ServiceIdentification)>0">MD_ServiceIdentification</xsl:when>
			<xsl:otherwise>MD_DataIdentification</xsl:otherwise>
		</xsl:choose>
</xsl:variable>	


  <xsl:for-each select="results/*">
		<csw:isoRecord>
			<fileIdentifier>
				<CharacterString><xsl:value-of select="fileIdentifier"/></CharacterString>
			</fileIdentifier>
			<language>
				<CharacterString><xsl:value-of select="characterSet/MD_CharacterSetCode_CodeList"/></CharacterString>
			</language>
			<xsl:for-each select="contact">
			<contact>
				<CI_ResponsibleParty>
					<organisationName>
						<CharacterString><xsl:value-of select="organisationName"/></CharacterString>
					</organisationName>
					<role>
						<CI_RoleCode codeList="" codeListValue="{role/CI_RoleCode_CodeList}"><xsl:value-of select="role/CI_RoleCode_CodeList"/></CI_RoleCode>
					</role>
				</CI_ResponsibleParty>
			</contact>
			</xsl:for-each>
			<dateStamp>
				<Date><xsl:value-of select="dateStamp"/></Date>
			</dateStamp>
			<metadataStandardName>
				<CharacterString>ISO 19139 DIS</CharacterString>
			</metadataStandardName>
			<metadataStandardVersion>
				<CharacterString>0.4</CharacterString>
			</metadataStandardVersion>
			
			<!-- ================================ Identifikace ===============================-->
			<identificationInfo>
		    <xsl:element name="{$ser}">
					<citation>
						<CI_Citation>
							<title xsi:type="PT_FreeText_PropertyType">
							<PT_FreeText>
							<xsl:for-each select="identificationInfo/*/citation/title">
							  <textGroup>
							  <LocalisedCharacterString locale="locale_{@lang}"><xsl:value-of select="."/></LocalisedCharacterString>
								</textGroup>
							</xsl:for-each>
							</PT_FreeText>
							</title>
							<xsl:for-each select="identificationInfo/*/citation/alternateTitle">
							<alternateTitle>
								<CharacterString><xsl:value-of select="."/></CharacterString>
							</alternateTitle>
							</xsl:for-each>
							<xsl:for-each select="identificationInfo/*/citation/date">
							<date>
								<CI_Date>
									<date>
										<Date><xsl:value-of select="date"/></Date>
									</date>
									<dateType>
										<CI_DateTypeCode codeListValue="{dateType/CI_DateTypeCode_CodeList}" codeList=""><xsl:value-of select="dateType/CI_DateTypeCode_CodeList"/></CI_DateTypeCode>
									</dateType>
								</CI_Date>
							</date>
							</xsl:for-each>
							<presentationForm>
								<CI_PresentationFormCode codeListValue="{identificationInfo/*/citation/presentationForm/CI_PresentationFormCode_CodeList}" codeList=""><xsl:value-of select="identificationInfo/*/citation/presentationForm/CI_PresentationFormCode_CodeList"/></CI_PresentationFormCode>
							</presentationForm>
						</CI_Citation>
					</citation>
					<abstract xsi:type="PT_FreeText_PropertyType">
						<PT_FreeText>
					  <xsl:for-each select="identificationInfo/*/abstract">
						  <textGroup>
							  <LocalisedCharacterString locale="locale_{@lang}"><xsl:value-of select="."/></LocalisedCharacterString>
							</textGroup>
						</xsl:for-each>
						</PT_FreeText>
					</abstract>
					
					<xsl:for-each select="identificationInfo/*/pointOfContact">
          <pointOfContact>
						<CI_ResponsibleParty>
							<organisationName>
								<CharacterString><xsl:value-of select="organisationName"/></CharacterString>
							</organisationName>
							<positionName>
								<CharacterString><xsl:value-of select="positionName"/></CharacterString>
							</positionName>
							<contactInfo>
								<CI_Contact>
									<phone>
										<CI_Telephone>
											<xsl:for-each select="contactInfo/phone/voice">
											<voice>
												<CharacterString><xsl:value-of select="."/></CharacterString>
											</voice>
											</xsl:for-each>
											<xsl:for-each select="contactInfo/phone/facsimile">
											<facsimile>
												<CharacterString><xsl:value-of select="."/></CharacterString>
											</facsimile>
											</xsl:for-each>
										</CI_Telephone>
									</phone>
									<address>
										<CI_Address>
											<deliveryPoint>
												<CharacterString><xsl:value-of select="contactInfo/address/deliveryPoint"/></CharacterString>
											</deliveryPoint>
											<city>
												<CharacterString><xsl:value-of select="contactInfo/address/city"/></CharacterString>
											</city>
											<administrativeArea>
												<CharacterString><xsl:value-of select="contactInfo/address/administrativeArea"/></CharacterString>
											</administrativeArea>
											<postalCode>
												<CharacterString><xsl:value-of select="contactInfo/address/postalCode"/></CharacterString>
											</postalCode>
											<country>
												<CharacterString><xsl:value-of select="contactInfo/address/country"/></CharacterString>
											</country>
											<xsl:for-each select="contactInfo/address/electronicMailAddress">
											<electronicMailAddress>
												<CharacterString><xsl:value-of select="."/></CharacterString>
											</electronicMailAddress>
											</xsl:for-each>
										</CI_Address>
									</address>
									<onlineResource>
										<CI_OnlineResource>
											<linkage>
												<URL><xsl:value-of select="contactInfo/onlineResource/linkage"/></URL>
											</linkage>
										</CI_OnlineResource>
									</onlineResource>
								</CI_Contact>
							</contactInfo>
							<role>
								<CI_RoleCode codeListValue="{pointOfContact/role/CI_RoleCode_CodeList}" codeList="./resources/codeList.xml#CI_RoleCode"><xsl:value-of select="pointOfContact/role/CI_RoleCode_CodeList"/></CI_RoleCode>
							</role>
						</CI_ResponsibleParty>
					</pointOfContact>
					</xsl:for-each>
					
					<xsl:for-each select="identificationInfo/*/spatialRepresentationType">
          <spatialRepresentationType>
						<MD_SpatialRepresentationTypeCode codeListValue="{MD_SpatialRepresentationTypeCode_CodeList}" codeList="./resources/codeList.xml#MD_SpatialRepresentationTypeCode"><xsl:value-of select="MD_SpatialRepresentationTypeCode_CodeList"/></MD_SpatialRepresentationTypeCode>
					</spatialRepresentationType>
					</xsl:for-each>
          
					<xsl:for-each select="identificationInfo/*/spatialResolution">
          <spatialResolution>
						<MD_Resolution>
							<equivalentScale>
								<MD_RepresentativeFraction>
									<denominator>
										<positiveInteger><xsl:value-of select="equivalentScale/denominator"/></positiveInteger>
									</denominator>
								</MD_RepresentativeFraction>
							</equivalentScale>
						</MD_Resolution>
					</spatialResolution>
					</xsl:for-each>
					
					<xsl:for-each select="identificationInfo/*/language">
          <language>
						<CharacterString><xsl:value-of select="isoCode"/></CharacterString>
					</language>
					</xsl:for-each>
					
					<xsl:for-each select="identificationInfo/*/topicCategory">
					<topicCategory>
						<MD_TopicCategoryCode><xsl:value-of select="MD_TopicCategoryCode_CodeList"/></MD_TopicCategoryCode>
					</topicCategory>
					</xsl:for-each>

					<extent>
						<EX_Extent>
							<geographicElement>
								<EX_GeographicBoundingBox>
									<westBoundLongitude>
										<approximateLongitude><xsl:value-of select="@x1"/></approximateLongitude>
									</westBoundLongitude>
									<eastBoundLongitude>
										<approximateLongitude><xsl:value-of select="@x2"/></approximateLongitude>
									</eastBoundLongitude>
									<southBoundLatitude>
										<approximateLatitude><xsl:value-of select="@y1"/></approximateLatitude>
									</southBoundLatitude>
									<northBoundLatitude>
										<approximateLatitude><xsl:value-of select="@y1"/></approximateLatitude>
									</northBoundLatitude>
								</EX_GeographicBoundingBox>
							</geographicElement>
						</EX_Extent>
					</extent>
				</xsl:element>
			</identificationInfo>
			
			<!-- ================================ Jakost ===============================-->
			<dataQualityInfo>
				<DQ_DataQuality>
					<scope>
						<DQ_Scope>
							<level>
								<MD_ScopeCode codeListValue="{dataQualityInfo/scope/MD_ScopeCode_CodeList}" codeList="./resources/codeList.xml#MD_ScopeCode"><xsl:value-of select="dataQualityInfo/scope/MD_ScopeCode_CodeList"/></MD_ScopeCode>
							</level>
						</DQ_Scope>
					</scope>
					<lineage>
						<LI_Lineage>
    					<statement xsi:type="PT_FreeText_PropertyType">
    						<PT_FreeText>
    					  <xsl:for-each select="dataQualityInfo/lineage/statement">
    						  <textGroup>
    							  <LocalisedCharacterString locale="locale_{@lang}"><xsl:value-of select="."/></LocalisedCharacterString>
    							</textGroup>
    						</xsl:for-each>
    						</PT_FreeText>
    					</statement>
						</LI_Lineage>
					</lineage>
				</DQ_DataQuality>
			</dataQualityInfo>
			
			<!-- ================================ ref. system ===============================-->
			<xsl:for-each select="referenceSystemInfo">
      <referenceSystemInfo>
				<MD_ReferenceSystem>
					<referenceSystemIdentifier>
						<RS_Identifier>
							<code>
								<CharacterString><xsl:value-of select="referenceSystemIdentifier/code"/></CharacterString>
							</code>
							<codeSpace>
								<CharacterString><xsl:value-of select="referenceSystemIdentifier/codeSpace"/></CharacterString>
							</codeSpace>
						</RS_Identifier>
					</referenceSystemIdentifier>
				</MD_ReferenceSystem>
			</referenceSystemInfo>
			</xsl:for-each>
			
			<!-- ================================ Distribuce ===============================-->
			<distributionInfo>
				<MD_Distribution>
				  <xsl:for-each select="MD_Distribution/distributionFormat">
					<distributionFormat>
						<MD_Format>
							<name>
								<CharacterString><xsl:value-of select="name"/></CharacterString>
							</name>
							<version>
								<CharacterString><xsl:value-of select="version"/></CharacterString>
							</version>
						</MD_Format>
					</distributionFormat>
					</xsl:for-each>
					
					<transferOptions>
						<MD_DigitalTransferOptions>
				    <xsl:for-each select="MD_Distribution/transferOptions/onLine">
							<onLine>
								<CI_OnlineResource>
									<linkage>
										<URL><xsl:value-of select="linkage"/></URL>
									</linkage>								
									<protocol>
										<CharacterString><xsl:value-of select="protocol"/></CharacterString>
									</protocol>
									<name>
										<CharacterString><xsl:value-of select="name"/></CharacterString>
									</name>
									<function>
										<CI_OnLineFunctionCode codeListValue="{function/CI_OnLineFunctionCode_CodeList}" codeList=""><xsl:value-of select="function/CI_OnLineFunctionCode_CodeList"/></CI_OnLineFunctionCode>
									</function>							
								</CI_OnlineResource>
							</onLine>
						</xsl:for-each>
						</MD_DigitalTransferOptions>
					</transferOptions>
				</MD_Distribution>
			</distributionInfo>
		</csw:isoRecord>
		

        </xsl:for-each>
      </csw:SearchResults>
    </csw:GetRecordsResponse>
  </xsl:template>
</xsl:stylesheet>
