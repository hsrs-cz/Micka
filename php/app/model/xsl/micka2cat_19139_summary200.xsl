<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="/">

<csw:GetRecordsResponse 
  xmlns:csw="http://www.opengis.net/cat/csw" 
  xmlns="http://schemas.opengis.net/iso19115full" 
  xmlns:srv="http://schemas.opengis.net/iso19119"
  xmlns:gco="http://metadata.dgiwg.org/smXML"
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  version="2.0.0">
	<csw:RequestId><xsl:value-of select="$REQUESTID"/></csw:RequestId>
	<csw:SearchStatus timestamp="{$timestamp}" status="complete"/>
      <csw:SearchResults numberOfRecordsMatched="{results/@numberOfRecordsMatched}" numberOfRecordsReturned="{results/@numberOfRecordsReturned}" nextRecord="{results/@nextRecord}" elementSet="full">

  <xsl:for-each select="results/MD_Metadata">

    <xsl:variable name="ser">
    		<xsl:choose>
    			<xsl:when test="string-length(identificationInfo/SV_ServiceIdentification)>0">srv:CSW_ServiceIdentification</xsl:when>
    			<xsl:otherwise>MD_DataIdentification</xsl:otherwise>
    		</xsl:choose>
    </xsl:variable>	

    <xsl:variable name="mdLang" select="language/isoCode"/>

		<MD_Metadata>
			<fileIdentifier>
				<gco:CharacterString><xsl:value-of select="@uuid"/></gco:CharacterString>
			</fileIdentifier>
			<language>
			  <LanguageCode codeList="./resources/codeList.xml#CI_LanguageCode" codeListValue="{$mdLang}"><xsl:value-of select="$mdLang"/></LanguageCode>
			</language>
			<characterSet>
			  <MD_CharacterSetCode codeList="./resources/codeList.xml#MD_CharacterSetCode" codeListValue="utf8">utf-8</MD_CharacterSetCode>
			</characterSet>
			<parentIdentifier>
				<gco:CharacterString><xsl:value-of select="parentIdentifier"/></gco:CharacterString>
			</parentIdentifier>
			<hierarchyLevel>
			  <MD_ScopeCode codeList="./resources/codeList.xml#MD_ScopeCode" codeListValue="{hierarchyLevel/MD_ScopeCode}"><xsl:value-of select="hierarchyLevel/MD_ScopeCode"/></MD_ScopeCode>
			</hierarchyLevel>			
			<!--<xsl:for-each select="contact">-->
			<contact>
			<xsl:call-template name="contact">
        <xsl:with-param name="org" select="contact"/>
      </xsl:call-template>
			</contact>
			<!--</xsl:for-each>-->
			<dateStamp>
				<gco:Date><xsl:value-of select="dateStamp"/></gco:Date>
			</dateStamp>
			<metadataStandardName>
				<CharacterString>ISO 19115/19119</CharacterString>
			</metadataStandardName>
			<metadataStandardVersion>
				<gco:CharacterString>2003/cor.1/2006</gco:CharacterString>
			</metadataStandardVersion>
			
			<!-- ================================ locale ===============================
			<locale>
			  <PT_Locale id="locale-eng">
          <languageCode>
            <LanguageCode codeList=".resources/gmxcodelists.xml#LanguageCode" codeListValue="eng"/>
          </languageCode>
          <characterEncoding>
            <MD_CharacterSetCode codeList=".resources/gmxcodelists.xml#MD_CharacterSetCode" codeListValue="utf8"/>
          </characterEncoding>
         </PT_Locale> 
      </locale>
			-->
			<!-- ================================ ref. system ===============================-->
			<xsl:for-each select="referenceSystemInfo">
			  <referenceSystemInfo>
				<gco:MD_ReferenceSystem>
					<gco:referenceSystemIdentifier>
						<gco:RS_Identifier>
							<gco:code>
								<gco:CharacterString><xsl:value-of select="referenceSystemIdentifier/code"/></gco:CharacterString>
							</gco:code>
							<gco:codeSpace>
								<gco:CharacterString><xsl:value-of select="referenceSystemIdentifier/codeSpace"/></gco:CharacterString>
							</gco:codeSpace>
						</gco:RS_Identifier>
					</gco:referenceSystemIdentifier>
				</gco:MD_ReferenceSystem>
			</referenceSystemInfo>
			</xsl:for-each>

			<!-- ================================ Identifikace =============================== -->
			<identificationInfo>
		    <xsl:element name="{$ser}">
					<gco:citation>
						<gco:CI_Citation>
						<xsl:call-template name="txt">
						  <xsl:with-param name="s" select="identificationInfo/*/citation"/>                      
						  <xsl:with-param name="name" select="'title'"/>                      
						  <xsl:with-param name="lang" select="$mdLang"/>  <!-- docasne kvuli chybe !!! -->                    
			      </xsl:call-template>
						<xsl:call-template name="txt">
						  <xsl:with-param name="s" select="identificationInfo/*/citation"/>                      
						  <xsl:with-param name="name" select="'alternateTitle'"/>                      
						  <xsl:with-param name="lang" select="$mdLang"/>  <!-- docasne kvuli chybe !!! -->                    
			      </xsl:call-template>
						<xsl:for-each select="identificationInfo/*/citation/date">
							<gco:date>
								<gco:CI_Date>
									<gco:date>
										<gco:Date><xsl:value-of select="date"/></gco:Date>
									</gco:date>
									<gco:dateType>
										<CI_DateTypeCode codeListValue="{dateType/CI_DateTypeCode}" codeList="./resources/codeList.xml#CI_DateTypeCode"><xsl:value-of select="dateType/CI_DateTypeCode"/></CI_DateTypeCode>
									</gco:dateType>
								</gco:CI_Date>
							</gco:date>
							</xsl:for-each>
							<gco:presentationForm>
								<gco:CI_PresentationFormCode codeListValue="{identificationInfo/*/citation/presentationForm/CI_PresentationFormCode}" codeList=""><xsl:value-of select="identificationInfo/*/citation/presentationForm/CI_PresentationFormCode"/></gco:CI_PresentationFormCode>
							</gco:presentationForm>
						</gco:CI_Citation>
					</gco:citation>
					
					<xsl:call-template name="txt">
					  <xsl:with-param name="s" select="identificationInfo/*"/>                      
					  <xsl:with-param name="name" select="'abstract'"/>                      
					  <xsl:with-param name="lang" select="$mdLang"/>                    
		      </xsl:call-template>
		      
					<xsl:call-template name="txt">
					  <xsl:with-param name="s" select="identificationInfo/*"/>                      
					  <xsl:with-param name="name" select="'purpose'"/>                      
					  <xsl:with-param name="lang" select="$mdLang"/>                   
		      </xsl:call-template>
				
          <gco:status>
            <gco:MD_ProgressCode codeListValue="{identificationInfo/*/status/MD_ProgressCode}" codeList="./resources/codeList.xml#MD_ProgressCode"><xsl:value-of select="identificationInfo/*/status/MD_ProgressCode"/></gco:MD_ProgressCode>
			    </gco:status>

					<xsl:for-each select="identificationInfo/*/pointOfContact">
            <gco:pointOfContact>
       		  	<xsl:call-template name="contact">
    		  		  <xsl:with-param name="org" select="."/>       
    			    </xsl:call-template>
            </gco:pointOfContact>
					</xsl:for-each>
					
		      <xsl:for-each select="identificationInfo/*/graphicOverview">
          <gco:graphicOverview>
				    <gco:MD_BrowseGraphic>
					     <gco:fileName>
						      <gco:CharacterString><xsl:value-of select="fileName"/></gco:CharacterString>
					     </gco:fileName>
					     <xsl:call-template name="txt">
					       <xsl:with-param name="s" select="."/>                      
					       <xsl:with-param name="name" select="'fileDescription'"/>                      
					       <xsl:with-param name="lang" select="$mdLang"/>  <!-- docasne kvuli chybe !!! -->                    
		           </xsl:call-template>
					     <gco:fileType>
						      <gco:CharacterString><xsl:value-of select="fileType"/></gco:CharacterString>
					     </gco:fileType>
				    </gco:MD_BrowseGraphic>
			    </gco:graphicOverview>
			    </xsl:for-each>

					<xsl:for-each select="identificationInfo/*/descriptiveKeywords">
					<gco:descriptiveKeywords>
					  <xsl:for-each select="keyword">
					    <gco:keyword><gco:CharacterString><xsl:value-of select="."/></gco:CharacterString></gco:keyword>
					  </xsl:for-each>
          </gco:descriptiveKeywords>
					</xsl:for-each>
					
					<xsl:for-each select="identificationInfo/*/resourceConstraints">
					<gco:resourceConstraints>
					<xsl:choose>
  				  <xsl:when test="MD_SecurityConstraints!=''">
              <gco:MD_SecurityConstraints>
    	           <gco:classification>
                    <gco:MD_ClassificationCode codeListValue="{MD_SecurityConstraints/classification/MD_ClassificationCode}" codeList="./resources/codeList.xml#MD_ClassificationCode"></gco:MD_ClassificationCode>	
    	           </gco:classification>
              </gco:MD_SecurityConstraints>			
  			    </xsl:when>
              
            <xsl:otherwise>			      
    					<gco:MD_LegalConstraints>
  						<xsl:call-template name="txt">
  						  <xsl:with-param name="s" select="MD_LegalConstraints"/>                      
  						  <xsl:with-param name="name" select="'useLimitation'"/>                      
  						  <xsl:with-param name="lang" select="$mdLang"/>                   
  			      </xsl:call-template>

              <gco:accessConstraints><gco:MD_RestrictionCode codeListValue="{MD_LegalConstraints/accessConstraints/MD_RestrictionCode}" codeList="./resources/codeList.xml#MD_RestrictionCode"></gco:MD_RestrictionCode></gco:accessConstraints>	
              <gco:useConstraints><gco:MD_RestrictionCode codeListValue="{MD_LegalConstraints/useConstraints/MD_RestrictionCode}" codeList="./resources/codeList.xml#MD_RestrictionCode"></gco:MD_RestrictionCode></gco:useConstraints>
  						<xsl:call-template name="txt">
  						  <xsl:with-param name="s" select="MD_LegalConstraints"/>                      
  						  <xsl:with-param name="name" select="'otherConstraints'"/>                      
  						  <xsl:with-param name="lang" select="$mdLang"/>                   
  			      </xsl:call-template>
        		  </gco:MD_LegalConstraints>
  			    </xsl:otherwise>
  			  </xsl:choose>
  		  	</gco:resourceConstraints>
          </xsl:for-each>

					<xsl:for-each select="identificationInfo/*/spatialRepresentationType">
          <gco:spatialRepresentationType>
						<gco:MD_SpatialRepresentationTypeCode codeListValue="{MD_SpatialRepresentationTypeCode}" codeList="./resources/codeList.xml#MD_SpatialRepresentationTypeCode"><xsl:value-of select="MD_SpatialRepresentationTypeCode"/></gco:MD_SpatialRepresentationTypeCode>
					</gco:spatialRepresentationType>
					</xsl:for-each>
          
					<xsl:for-each select="identificationInfo/*/spatialResolution">
          <gco:spatialResolution>
						<gco:MD_Resolution>
							<gco:equivalentScale>
								<gco:MD_RepresentativeFraction>
									<gco:denominator>
										<gco:Integer><xsl:value-of select="equivalentScale/denominator"/></gco:Integer>
									</gco:denominator>
								</gco:MD_RepresentativeFraction>
							</gco:equivalentScale>
						</gco:MD_Resolution>
					</gco:spatialResolution>
					</xsl:for-each>
					
					<xsl:for-each select="identificationInfo/*/language">
          <gco:language>
			      <gco:LanguageCode codeList="./resources/codeList.xml#CI_LanguageCode" codeListValue="{isoCode}"><xsl:value-of select="isoCode"/></gco:LanguageCode>
					</gco:language>
					</xsl:for-each>
					
					<xsl:for-each select="identificationInfo/*/topicCategory/MD_TopicCategoryCode">
					<gco:topicCategory><gco:MD_TopicCategoryCode codeList="./resources/codeList.xml#MD_TopicCategoryCode" codeListValue="{.}"/><xsl:value-of select="."/></gco:topicCategory>
					</xsl:for-each>

          <xsl:if test="string-length(//serviceType)>0">
            <srv:serviceType>
              <gco:CharacterString><xsl:value-of select="//serviceType/nameValue"/></gco:CharacterString> 
            </srv:serviceType>
            <srv:serviceTypeVersion>
              <gco:CharacterString><xsl:value-of select="//serviceTypeVersion"/></gco:CharacterString> 
            </srv:serviceTypeVersion>
            <srv:containsOperations>
            <xsl:for-each select="//OperationMetadata">
              <srv:SV_OperationMetadata>
                <srv:operationName>
                   <gco:CharacterString><xsl:value-of select="operationName/nameValue"/></gco:CharacterString>
                 </srv:operationName>
                 <srv:DCP>
                   <srv:DCPList codeList="DCPList" codeListValue="{DCP}" />
                 </srv:DCP>
                 <srv:connectPoint>
                   <CI_OnlineResource>
                     <linkage>
                       <URL><xsl:value-of select="connectPoint/linkage"/></URL>
                     </linkage>
                   </CI_OnlineResource>
                 </srv:connectPoint>
              </srv:SV_OperationMetadata>            
            </xsl:for-each>  
            </srv:containsOperations>
          </xsl:if>

					<extent>
						<gco:EX_Extent>
						  <xsl:if test="string-length(identificationInfo//extent/description)>0">
						    <gco:description><gco:CharacterString><xsl:value-of select="identificationInfo//extent/description"/></gco:CharacterString></gco:description>
						  </xsl:if>  
							<gco:geographicElement>
								<gco:EX_GeographicBoundingBox>
									<gco:westBoundLongitude>
										<gco:Decimal><xsl:value-of select="@x1"/></gco:Decimal>
									</gco:westBoundLongitude>
									<gco:eastBoundLongitude>
										<gco:Decimal><xsl:value-of select="@x2"/></gco:Decimal>
									</gco:eastBoundLongitude>
									<gco:southBoundLatitude>
										<gco:Decimal><xsl:value-of select="@y1"/></gco:Decimal>
									</gco:southBoundLatitude>
									<gco:northBoundLatitude>
										<gco:Decimal><xsl:value-of select="@y2"/></gco:Decimal>
									</gco:northBoundLatitude>
								</gco:EX_GeographicBoundingBox>
							</gco:geographicElement>
            <xsl:for-each select="identificationInfo/*/extent/temporalElement/extent/beginEnd">
							<gco:temporalElement>
							  <gco:EX_TemporalExtent>
                  <gco:extent>
                    <gml:TimePeriod>
                      <gml:beginPosition><xsl:value-of select="begin" /></gml:beginPosition>
                      <gml:endPosition><xsl:value-of select="end" /></gml:endPosition>
                    </gml:TimePeriod>
                  </gco:extent>
							  </gco:EX_TemporalExtent>
							</gco:temporalElement>							
            </xsl:for-each>  
            <xsl:for-each select="identificationInfo/*/extent/temporalElement/extent/instant">
							<gco:temporalElement>
							  <gco:EX_TemporalExtent>
                  <gco:extent>
                    <gml:TimeInstant>
                      <gml:timePosition><xsl:value-of select="." /></gml:timePosition>
                    </gml:TimeInstant>
                  </gco:extent>
							  </gco:EX_TemporalExtent>
							</gco:temporalElement>							
            </xsl:for-each> 
            
            <xsl:for-each select="identificationInfo/*/extent/verticalElement">
							<gco:verticalElement>
      					<gco:EX_VerticalExtent>
      						<gco:minimumValue><gco:Real><xsl:value-of select="minimumValue" /></gco:Real></gco:minimumValue>
      						<gco:maximumValue><gco:Real><xsl:value-of select="maximumValue" /></gco:Real></gco:maximumValue>
      						<gco:verticalCRS>
        						<gml:VerticalCRS>
        							<gml:identifier codeSpace="{verticalDatum/datumID/title}"><xsl:value-of select="verticalDatum/datumID/code" /></gml:identifier>
        						</gml:VerticalCRS>
                  </gco:verticalCRS>
      					</gco:EX_VerticalExtent>
							</gco:verticalElement>							
            </xsl:for-each>  
 
						</gco:EX_Extent>
					</extent>
					
				</xsl:element>
				
				<xsl:for-each select="//couplingType">
        <srv:couplingType>
				  <srv:SV_CouplingType codeList="./resources/codeList.xml#SV_CouplingType" codeListValue="{.}"/>
        </srv:couplingType>
        </xsl:for-each>
        
			</identificationInfo>
			
			
			<!-- ================================ Distribuce ===============================-->
			<distributionInfo>
				<gco:MD_Distribution>
				  <xsl:for-each select="MD_Distribution/distributionFormat">
					<gco:distributionFormat>
						<gco:MD_Format>
							<gco:name>
								<gco:CharacterString><xsl:value-of select="name"/></gco:CharacterString>
							</gco:name>
							<gco:version>
								<gco:CharacterString><xsl:value-of select="version"/></gco:CharacterString>
							</gco:version>
						</gco:MD_Format>
					</gco:distributionFormat>
					</xsl:for-each>
					
					<gco:transferOptions>
						<gco:MD_DigitalTransferOptions>
				    <xsl:for-each select="MD_Distribution/transferOptions/onLine">
							<gco:onLine>
								<gco:CI_OnlineResource>
									<gco:linkage>
										<gco:URL><xsl:value-of select="linkage"/></gco:URL>
									</gco:linkage>								
									<gco:protocol>
										<gco:CharacterString><xsl:value-of select="protocol"/></gco:CharacterString>
									</gco:protocol>
									<gco:name>
										<gco:CharacterString><xsl:value-of select="name"/></gco:CharacterString>
									</gco:name>
									<gco:function>
										<CI_OnLineFunctionCode codeListValue="{function/CI_OnLineFunctionCode}" codeList=""><xsl:value-of select="function/CI_OnLineFunctionCode"/></CI_OnLineFunctionCode>
									</gco:function>							
								</gco:CI_OnlineResource>
							</gco:onLine>
						</xsl:for-each>
						</gco:MD_DigitalTransferOptions>
					</gco:transferOptions>
				</gco:MD_Distribution>
			</distributionInfo>

			<!-- ================================ Jakost ===============================-->
			<dataQualityInfo>
				<gco:DQ_DataQuality>
					<gco:scope>
						<gco:DQ_Scope>
							<gco:level>
								<gco:MD_ScopeCode codeListValue="{dataQualityInfo/scope/MD_ScopeCode}" codeList="./resources/codeList.xml#MD_ScopeCode"><xsl:value-of select="dataQualityInfo/scope/MD_ScopeCode"/></gco:MD_ScopeCode>
							</gco:level>
						</gco:DQ_Scope>
					</gco:scope>
					<gco:lineage>
						<gco:LI_Lineage>
  						<xsl:call-template name="txt">
  						  <xsl:with-param name="s" select="dataQualityInfo/lineage"/>                      
  						  <xsl:with-param name="name" select="'statement'"/>                      
  						  <xsl:with-param name="lang" select="$mdLang"/>                    
  			      </xsl:call-template>
						</gco:LI_Lineage>
					</gco:lineage>
				</gco:DQ_DataQuality>
			</dataQualityInfo>

		</MD_Metadata>
		

        </xsl:for-each>
      </csw:SearchResults>
    </csw:GetRecordsResponse>
  </xsl:template>

  <xsl:include href="common200.xsl" />
   
</xsl:stylesheet>
