<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:gmd="http://www.isotc211.org/2005/gmd" 
xmlns:sch="http://www.ascc.net/xml/schematron" 
xmlns:gco="http://www.isotc211.org/2005/gco" 
xmlns:srv="http://www.isotc211.org/2005/srv"
xmlns:gsr="http://www.isotc211.org/2005/gsr" 
xmlns:gss="http://www.isotc211.org/2005/gss" 
xmlns:gts="http://www.isotc211.org/2005/gts" 
xmlns:gml="http://www.opengis.net/gml" 
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:xs="http://www.w3.org/2001/XMLSchema"  
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:gmx="http://www.isotc211.org/2005/gmx"
xmlns:php="http://php.net/xsl"
xsi:schemaLocation="http://www.isotc211.org/2005/gmd
http://www.bnhelp.cz/metadata/schemas/gmd/metadataEntity.xsd">
	<xsl:output method="xml" encoding="UTF-8"/>
    <xsl:include href="kote-common.xsl" />

    <xsl:variable name="cl">http://standards.iso.org/iso/19139/resources/gmxCodelists.xml</xsl:variable>

	<xsl:template match="/md">

	<xsl:variable name="serv"><xsl:choose>
        <xsl:when test="iso='19119'">srv</xsl:when>
        <xsl:otherwise>gmd</xsl:otherwise></xsl:choose>
    </xsl:variable>
	
    <xsl:variable name="ser">
    	<xsl:choose>
    		<xsl:when test="iso='19119'">srv:SV_ServiceIdentification</xsl:when>
    		<xsl:otherwise>gmd:MD_DataIdentification</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>	
	
	<xsl:variable name="mdlang" select="mdlang"/>
	<xsl:variable name="codes" select="document('../../xsl/codelists.xml')/map" />
	
<gmd:MD_Metadata>
	<gmd:fileIdentifier>
		<gco:CharacterString><xsl:value-of select="fileIdentifier"/></gco:CharacterString>
	</gmd:fileIdentifier>
	<gmd:language>
		<gmd:LanguageCode codeList="{$cl}#CI_LanguageCode" codeListValue="{mdlang}"><xsl:value-of select="mdlang"/></gmd:LanguageCode>
	</gmd:language>
	<xsl:if test="parentIdentifier">
		<gmd:parentIdentifier>
			<gco:CharacterString><xsl:value-of select="parentIdentifier"/></gco:CharacterString>
		</gmd:parentIdentifier>
	</xsl:if>
	<gmd:hierarchyLevel>
		<xsl:choose>
			<xsl:when test="string-length(hierarchyLevel)>0">
				<gmd:MD_ScopeCode codeList="{$cl}#MD_ScopeCode" codeListValue="{hierarchyLevel}"><xsl:value-of select="hierarchyLevel"/></gmd:MD_ScopeCode>
			</xsl:when>
			<xsl:when test="iso='19119'">
				<gmd:MD_ScopeCode codeList="{$cl}#MD_ScopeCode" codeListValue="service">service</gmd:MD_ScopeCode>
			</xsl:when>
			<xsl:otherwise>
				<gmd:MD_ScopeCode codeList="{$cl}#MD_ScopeCode" codeListValue="dataset">dataset</gmd:MD_ScopeCode>
			</xsl:otherwise>
		</xsl:choose>		
	</gmd:hierarchyLevel>
    <xsl:for-each select="hlName/item">
        <gmd:hierarchyLevelName>
            <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
        </gmd:hierarchyLevelName>     
    </xsl:for-each>
    <xsl:choose>
	    <xsl:when test="inspireEU='on'">
	        <gmd:hierarchyLevelName>
	            <gco:CharacterString>http://geoportal.gov.cz/inspire</gco:CharacterString>
	        </gmd:hierarchyLevelName>    
	    </xsl:when>
	    <xsl:when test="not(hlName)">
	    	<gmd:hierarchyLevelName><gco:CharacterString></gco:CharacterString></gmd:hierarchyLevelName>
	    </xsl:when>
    </xsl:choose>
	<xsl:for-each select="contact/item">
		<gmd:contact>
			<xsl:call-template name="contact">
				<xsl:with-param name="party" select="."/>
			</xsl:call-template>
		</gmd:contact>
	</xsl:for-each>
	<gmd:dateStamp>
		<gco:Date><xsl:value-of select="$datestamp"/></gco:Date>
	</gmd:dateStamp>
	<gmd:metadataStandardName>
        <xsl:choose>
            <xsl:when test="metadataStandardName!=''">
                <gco:CharacterString><xsl:value-of select="metadataStandardName"/></gco:CharacterString>
            </xsl:when>    
            <xsl:otherwise>    
		          <gco:CharacterString>ISO 19115/INSPIRE_TG2/CZ4</gco:CharacterString>
            </xsl:otherwise>
         </xsl:choose>         
	</gmd:metadataStandardName>
	<gmd:metadataStandardVersion>
        <xsl:choose>
            <xsl:when test="metadataStandardVersion!=''">
                <gco:CharacterString><xsl:value-of select="metadataStandardVersion"/></gco:CharacterString>
            </xsl:when>    
            <xsl:otherwise>    
		          <gco:CharacterString>2003/cor.1/2006</gco:CharacterString>
            </xsl:otherwise>
         </xsl:choose>         
	</gmd:metadataStandardVersion>

	<xsl:for-each select="locale">
		<gmd:locale>
			<gmd:PT_Locale id="locale-{.}">
				<gmd:languageCode>
  					<gmd:LanguageCode codeList="{$cl}#LanguageCode" codeListValue="{.}" /> 
  				</gmd:languageCode>
				<gmd:characterEncoding>
  					<gmd:MD_CharacterSetCode codeList="{$cl}#MD_CharacterSetCode" codeListValue="utf8" /> 
  				</gmd:characterEncoding>
  			</gmd:PT_Locale>
  		</gmd:locale>
	</xsl:for-each>
	<!-- ================================ prostor. reprezentace =============================== 
      
      <xsl:if test="spatialRepr='vector'">
		<spatialRepresentationInfo>
    		<MD_VectorSpatialRepresentation>
    		<xsl:for-each select="geom/geom">
    			<geometricObjects>
    				<MD_GeometricObjects>
    					<geometricObjectType>
    						<MD_GeometricObjectTypeCode codeListValue="{.}" codeList="{$cl}#MD_GeometricObjectTypeCode"><xsl:value-of select="."/></MD_GeometricObjectTypeCode>
    					</geometricObjectType>
    				</MD_GeometricObjects>
    			</geometricObjects>
    		</xsl:for-each>
    		</MD_VectorSpatialRepresentation>
    	</spatialRepresentationInfo>
     </xsl:if>
	-->
	<!-- ================================ ref. system =============================== -->
	<xsl:for-each select="coorSys/item">
		<gmd:referenceSystemInfo>
			<gmd:MD_ReferenceSystem>
				<gmd:referenceSystemIdentifier>
					<gmd:RS_Identifier>
                        <xsl:call-template name="uriOut">
                            <xsl:with-param name="name" select="'code'"/>
                            <xsl:with-param name="codes" select="$codes/coordSys"/>
                            <xsl:with-param name="t" select="."/>
                        </xsl:call-template>
					</gmd:RS_Identifier>
				</gmd:referenceSystemIdentifier>
			</gmd:MD_ReferenceSystem>
		</gmd:referenceSystemInfo>
	</xsl:for-each>

			<!-- ================================ Identifikace =============================== -->
			<gmd:identificationInfo>
				<xsl:element name="{$ser}">
    				<xsl:attribute name="id">_<xsl:value-of select="fileIdentifier"/></xsl:attribute>
    				<xsl:attribute name="uuid"><xsl:value-of select="fileIdentifier"/></xsl:attribute>
					<gmd:citation>
						<gmd:CI_Citation>
							<xsl:call-template name="txtOut">
								<xsl:with-param name="name" select="'title'"/>
								<xsl:with-param name="t" select="title"/>
							</xsl:call-template>
							<xsl:for-each select="date/item">
								<gmd:date>
									<gmd:CI_Date>
										<gmd:date>
											<gco:Date>
												<xsl:value-of select="php:function('date2iso', string(date))"/>
											</gco:Date>
										</gmd:date>
										<gmd:dateType>
											<gmd:CI_DateTypeCode codeList="{$cl}#CI_DateTypeCode" codeListValue="{type}"></gmd:CI_DateTypeCode>
										</gmd:dateType>
									</gmd:CI_Date>
								</gmd:date>
							</xsl:for-each>
							<xsl:for-each select="identifier/item">
								<gmd:identifier>
									<gmd:RS_Identifier>
										<gmd:code>
                                            <xsl:choose>
                                                <xsl:when test="substring(.,1,4)='http'">
                                                    <gmx:Anchor xlink:href="{.}"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                                                </xsl:otherwise>
                                            </xsl:choose>
										</gmd:code>
                                        <gmd:codeSpace></gmd:codeSpace>
									</gmd:RS_Identifier>
								</gmd:identifier>
							</xsl:for-each>
                            <gmd:otherCitationDetails>
                                <gco:CharacterString><xsl:value-of select="obligatory"/></gco:CharacterString>
                            </gmd:otherCitationDetails>
						</gmd:CI_Citation>
					</gmd:citation>
					<xsl:call-template name="txtOut">
						<xsl:with-param name="name" select="'abstract'"/>
						<xsl:with-param name="t" select="abstract"/>
					</xsl:call-template>					
					<xsl:call-template name="txtOut">
						<xsl:with-param name="name" select="'purpose'"/>
						<xsl:with-param name="t" select="purpose"/>
					</xsl:call-template>					
					<!--<xsl:for-each select="resourceSpecificUsage">
                        <resourceSpecificUsage>
                            <MD_Usage>
                                <specificUsage>
    						      <gco:CharacterString>
    							     <xsl:value-of select="."/>
    						      </gco:CharacterString>
                                </specificUsage>
                            </MD_Usage>
    					</resourceSpecificUsage>
                    </xsl:for-each>
					
					 <xsl:for-each select="status">
						<status>
							<MD_ProgressCode codeListValue="{.}" codeList="{$cl}#MD_ProgressCode">
								<xsl:value-of select="."/>
							</MD_ProgressCode>
						</status>
					</xsl:for-each>  -->
					<xsl:for-each select="dataContact/item">
						<gmd:pointOfContact>
							<xsl:call-template name="contact">
								<xsl:with-param name="party" select="."/>
							</xsl:call-template>
						</gmd:pointOfContact>
					</xsl:for-each>
					<xsl:for-each select="maintenance/item">
						<gmd:resourceMaintenance>
							<gmd:MD_MaintenanceInformation>
								<gmd:maintenanceAndUpdateFrequency>
 								   <gmd:MD_MaintenanceFrequencyCode codeList="{$cl}#MD_MD_MaintenanceFrequencyCode" codeListValue="{frequency}"><xsl:value-of select="frequency"/></gmd:MD_MaintenanceFrequencyCode>
 								</gmd:maintenanceAndUpdateFrequency>
 								<xsl:if test="user">
	                                <gmd:userDefinedMaintenanceFrequency>
	                                    <gts:TM_PeriodDuration xmlns:gts="http://www.isotc211.org/2005/gts"><xsl:value-of select="user"/></gts:TM_PeriodDuration> 
	                                </gmd:userDefinedMaintenanceFrequency>
 								</xsl:if>
 								<xsl:for-each select="scope">
 									<gmd:updateScope><gmd:MD_ScopeCode codeList="{$cl}#MD_ScopeCode" codeListValue='{.}'/></gmd:updateScope>
 								</xsl:for-each>
                                <xsl:call-template name="txtOut">
                                    <xsl:with-param name="name" select="'maintenanceNote'"/>
                                    <xsl:with-param name="t" select="note"/>
                                </xsl:call-template>
							</gmd:MD_MaintenanceInformation>
						</gmd:resourceMaintenance>
					</xsl:for-each>				
					<!--  xsl:for-each select="maintenanceUser">
						<gmd:resourceMaintenance>
							<gmd:MD_MaintenanceInformation>
								<gmd:maintenanceAndUpdateFrequency>
                                    <xsl:if test="normalize-space(.) != ''">
 								       <gmd:MD_MaintenanceFrequencyCode codeList="{$cl}#MD_MD_MaintenanceFrequencyCode" codeListValue="unknown">unknown</gmd:MD_MaintenanceFrequencyCode>
  								    </xsl:if>
                                  </gmd:maintenanceAndUpdateFrequency>
                                <gmd:userDefinedMaintenanceFrequency>
                                    <gts:TM_PeriodDuration xmlns:gts="http://www.isotc211.org/2005/gts"><xsl:value-of select="."/></gts:TM_PeriodDuration> 
                                </gmd:userDefinedMaintenanceFrequency>
							</gmd:MD_MaintenanceInformation>
						</gmd:resourceMaintenance>
					</xsl:for-each-->
                    <xsl:choose>
                        <xsl:when test="normalize-space(inspireTheme)!=''">
                            <gmd:descriptiveKeywords>
                                <gmd:MD_Keywords>
                                    <xsl:for-each select="inspireTheme/item">
                                        <xsl:call-template name="uriOut">
                                            <xsl:with-param name="name" select="'keyword'"/>
                                            <xsl:with-param name="codes" select="$codes/inspireKeywords"/>
                                            <xsl:with-param name="t" select="."/>
                                            <xsl:with-param name="attrib" select="'name'"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                    <gmd:thesaurusName>
                                        <gmd:CI_Citation>
                                            <gmd:title>
                                                <gmx:Anchor xlink:href="https://www.eionet.europa.eu/gemet/inspire_themes">GEMET - INSPIRE themes, version 1.0</gmx:Anchor>
                                            </gmd:title>
                                            <gmd:date><gmd:CI_Date>
                                                <gmd:date><gco:Date>2008-06-01</gco:Date></gmd:date>
                                                <gmd:dateType><gmd:CI_DateTypeCode codeListValue="publication" codeList="{$cl}#CI_DateTypeCode">publication</gmd:CI_DateTypeCode></gmd:dateType>
                                            </gmd:CI_Date></gmd:date>
                                        </gmd:CI_Citation>
                                    </gmd:thesaurusName>
                                </gmd:MD_Keywords>	
                            </gmd:descriptiveKeywords>
                        </xsl:when>
                        <xsl:otherwise>
                            <gmd:descriptiveKeywords>
                                <gmd:MD_Keywords>
                                    <gmd:keyword></gmd:keyword>
                                    <gmd:thesaurusName>
                                        <gmd:CI_Citation>
                                            <gmd:title></gmd:title>
                                            <gmd:date>
                                                <gmd:CI_Date>
                                                    <gmd:date></gmd:date>
                                                    <gmd:dateType></gmd:dateType>
                                                </gmd:CI_Date>
                                            </gmd:date>
                                        </gmd:CI_Citation>
                                    </gmd:thesaurusName>
                                </gmd:MD_Keywords>
                            </gmd:descriptiveKeywords>
                        </xsl:otherwise>
                    </xsl:choose>
					<xsl:if test="inspireService">
						<gmd:descriptiveKeywords>
							<gmd:MD_Keywords>						
	              				<xsl:for-each select="inspireService">
                                    <xsl:call-template name="uriOut">
                                        <xsl:with-param name="name" select="'keyword'"/>
                                        <xsl:with-param name="codes" select="$codes/serviceKeyword"/>
                                        <xsl:with-param name="t" select="."/>
                                        <xsl:with-param name="attrib" select="'name'"/>
                                    </xsl:call-template>
	  							</xsl:for-each>
	  							<gmd:thesaurusName>
	  								<gmd:CI_Citation>
	  									<gmd:title>
	  										<gco:CharacterString>ISO - 19119 geographic services taxonomy</gco:CharacterString>
	  									</gmd:title>
	  									<gmd:date><gmd:CI_Date>
	  										<gmd:date><gco:Date>2010-01-19</gco:Date></gmd:date>
	  										<gmd:dateType><gmd:CI_DateTypeCode codeListValue="publication" codeList="{$cl}#CI_DateTypeCode">publication</gmd:CI_DateTypeCode></gmd:dateType>
	  									</gmd:CI_Date></gmd:date>
	  								</gmd:CI_Citation>
	  							</gmd:thesaurusName>
							</gmd:MD_Keywords>	
						</gmd:descriptiveKeywords>						
					</xsl:if>
					<!-- <xsl:if test="gemet">
					<descriptiveKeywords>
						<MD_Keywords>						
              				<xsl:for-each select="gemet">
    							<keyword>
  							  		<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
  						  		</keyword>
  							</xsl:for-each>
  							<thesaurusName>
  								<CI_Citation>
  									<title>
  										<gco:CharacterString><xsl:value-of select="gemetCit"/></gco:CharacterString>
  									</title>
  									<date><CI_Date>
  										<date><gco:Date><xsl:value-of select="gemetDate"/></gco:Date></date>
  										<dateType><CI_DateTypeCode codeListValue="revision" codeList="{$cl}#CI_DateTypeCode">revision</CI_DateTypeCode></dateType>
  									</CI_Date></date>
  								</CI_Citation>
  							</thesaurusName>
						</MD_Keywords>	
					</descriptiveKeywords>
					</xsl:if> -->
					
					<!-- other kw -->
					<xsl:for-each select="othes">
					   <gmd:descriptiveKeywords>
					     <gmd:MD_Keywords>	
    					   <xsl:for-each select="kw">
    					   		<xsl:call-template name="txtOut">
    					   			<xsl:with-param name="name" select="'keyword'"/>
    					   			<xsl:with-param name="t" select="."/>
    					   		</xsl:call-template>
    					   </xsl:for-each>
  							<gmd:thesaurusName>
  								<gmd:CI_Citation>
  									<gmd:title>
  										<gco:CharacterString><xsl:value-of select="title"/></gco:CharacterString>
  									</gmd:title>
  									<gmd:date><gmd:CI_Date>
  										<gmd:date><gco:Date><xsl:value-of select="php:function('date2iso', string(date))"/></gco:Date></gmd:date>
  										<gmd:dateType><gmd:CI_DateTypeCode codeListValue="{dateType}" codeList="{$cl}#CI_DateTypeCode"><xsl:value-of select="dateType"/></gmd:CI_DateTypeCode></gmd:dateType>
  									</gmd:CI_Date></gmd:date>
  								</gmd:CI_Citation>
  							</gmd:thesaurusName>
					     </gmd:MD_Keywords>	
					   </gmd:descriptiveKeywords>
					</xsl:for-each>

					<xsl:if test="normalize-space(fkw/item)!=''">
                        <gmd:descriptiveKeywords>
    						<gmd:MD_Keywords>
                  				<xsl:for-each select="fkw/item">
                                    <xsl:call-template name="txtOut">
    						          <xsl:with-param name="name" select="'keyword'"/>
    						          <xsl:with-param name="t" select="keyword"/>
    					           </xsl:call-template>					
      							</xsl:for-each>
    						</gmd:MD_Keywords>	
    					</gmd:descriptiveKeywords>
                    </xsl:if>

					<!-- 8.1 Conditions Access and use -->
                    <xsl:if test="accessCond">
                        <gmd:resourceConstraints>
                            <gmd:MD_LegalConstraints>
                                <gmd:useConstraints>
                                    <gmd:MD_RestrictionCode codeList="{$cl}#MD_RestrictionCode" codeListValue="otherRestrictions"/>
                                </gmd:useConstraints>	
                                <xsl:for-each select="accessCond/item">
                                    <xsl:call-template name="uriOut">
                                        <xsl:with-param name="name" select="'otherConstraints'"/>
                                        <xsl:with-param name="codes" select="$codes/accessCond"/>
                                        <xsl:with-param name="t" select="."/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </gmd:MD_LegalConstraints>
                        </gmd:resourceConstraints>
					</xsl:if>

                    <!-- 8.2 Limitations -->
                    <xsl:if test="limitationsAccess">
                        <gmd:resourceConstraints>
                            <gmd:MD_LegalConstraints>
                                <gmd:accessConstraints>
                                    <gmd:MD_RestrictionCode codeList="{$cl}#MD_RestrictionCode" codeListValue="otherRestrictions"/>
                                </gmd:accessConstraints>	
                                <xsl:for-each select="limitationsAccess/item">
                                    <xsl:call-template name="uriOut">
                                        <xsl:with-param name="name" select="'otherConstraints'"/>
                                        <xsl:with-param name="codes" select="$codes/limitationsAccess"/>
                                        <xsl:with-param name="t" select="."/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </gmd:MD_LegalConstraints>
                        </gmd:resourceConstraints>
					</xsl:if>
                    
                    <xsl:if test="$serv='gmd'">
                        <gmd:spatialRepresentationType>
                            <gmd:MD_SpatialRepresentationTypeCode codeListValue="{spatial}" codeList="{$cl}#MD_SpatialRepresentationTypeCode">
                                <xsl:value-of select="spatial"/>
                            </gmd:MD_SpatialRepresentationTypeCode>
                        </gmd:spatialRepresentationType>
                    
					
                        <xsl:for-each select="denominator">
                            <gmd:spatialResolution>
                                <gmd:MD_Resolution>
                                    <gmd:equivalentScale>
                                        <gmd:MD_RepresentativeFraction>
                                            <gmd:denominator>
                                                <gco:Integer>
                                                    <xsl:value-of select="."/>
                                                </gco:Integer>
                                            </gmd:denominator>
                                        </gmd:MD_RepresentativeFraction>
                                    </gmd:equivalentScale>
                                </gmd:MD_Resolution>
                            </gmd:spatialResolution>
                        </xsl:for-each>
                    
                    
                        <gmd:spatialResolution>
                            <gmd:MD_Resolution>
                                <gmd:equivalentScale>
                                    <gmd:MD_RepresentativeFraction>
                                        <gmd:denominator><gco:Integer></gco:Integer></gmd:denominator>
                                    </gmd:MD_RepresentativeFraction>
                                </gmd:equivalentScale>
                            </gmd:MD_Resolution>
                        </gmd:spatialResolution>
                        
                        <xsl:for-each select="distance/item">
                            <gmd:spatialResolution>
                                <gmd:MD_Resolution>
                                    <gmd:distance>
                                        <gco:Distance uom="m"><xsl:value-of select="."/></gco:Distance>
                                    </gmd:distance>	
                                </gmd:MD_Resolution>
                            </gmd:spatialResolution>
                        </xsl:for-each>
                        <gmd:spatialResolution>
                            <gmd:MD_Resolution>
                                <gmd:distance>
                                    <gco:Distance uom=""></gco:Distance>
                                </gmd:distance>	
                            </gmd:MD_Resolution>
                        </gmd:spatialResolution>
                    </xsl:if>

					<xsl:for-each select="language/item">
		  				<gmd:language>
	 					  <gmd:LanguageCode codeListValue="{.}" codeList=""><xsl:value-of select="."/></gmd:LanguageCode>
	          			</gmd:language>
          			</xsl:for-each>
					<xsl:for-each select="characterSet">
		  				<gmd:characterSet>
	 					  <gmd:MD_CharacterSetCode codeListValue="{.}" codeList=""><xsl:value-of select="."/></gmd:MD_CharacterSetCode>
	          			</gmd:characterSet>
          			</xsl:for-each>
					<xsl:for-each select="topicCategory/item">
						<gmd:topicCategory>
							<gmd:MD_TopicCategoryCode><xsl:value-of select="."/></gmd:MD_TopicCategoryCode>
						</gmd:topicCategory>
					</xsl:for-each>
					<xsl:if test="$serv='srv'">
                        <srv:serviceType>
                            <gco:LocalName><xsl:value-of select="serviceType"/></gco:LocalName>
                        </srv:serviceType>
					</xsl:if>
					<xsl:for-each select="serviceTypeVersion">
						<srv:serviceTypeVersion><xsl:value-of select="."/></srv:serviceTypeVersion>
					</xsl:for-each>
					<!--  rozsah -->
					<xsl:element name="{$serv}:extent">
						<gmd:EX_Extent>
							<xsl:if test="string-length(extentDescription)>0">
								<gmd:description>
									<gco:CharacterString>
										<xsl:value-of select="extentDescription"/>
									</gco:CharacterString>
								</gmd:description>
							</xsl:if>
                            <!-- geographic identifier -->
                            <xsl:choose>
                                <xsl:when test="normalize-space(extentId)!=''">
                                    <xsl:variable name="code" select="extentId"/>
                                    <xsl:variable name="row" select="$codes/extents/value[@uri=$code]"/>
                                    <gmd:geographicElement>
                                        <gmd:EX_GeographicDescription>
                                            <gmd:geographicIdentifier>
                                                <gmd:MD_Identifier>
                                                    <gmd:code>
                                                        <gmx:Anchor xlink:href="{$code}"><xsl:value-of select="$row/*[name()=$lang]"/></gmx:Anchor>
                                                    </gmd:code>
                                                </gmd:MD_Identifier>
                                            </gmd:geographicIdentifier>
                                        </gmd:EX_GeographicDescription>
                                    </gmd:geographicElement>
                                    <gmd:geographicElement>
                                        <gmd:EX_GeographicBoundingBox>
                                            <gmd:westBoundLongitude>
                                                <gco:Decimal><xsl:value-of select="$row/@x1"/></gco:Decimal>
                                            </gmd:westBoundLongitude>
                                            <gmd:eastBoundLongitude>
                                                <gco:Decimal><xsl:value-of select="$row/@x2"/></gco:Decimal>
                                            </gmd:eastBoundLongitude>
                                            <gmd:southBoundLatitude>
                                                <gco:Decimal><xsl:value-of select="$row/@y1"/></gco:Decimal>
                                            </gmd:southBoundLatitude>
                                            <gmd:northBoundLatitude>
                                                <gco:Decimal><xsl:value-of select="$row/@y2"/></gco:Decimal>
                                            </gmd:northBoundLatitude>
                                        </gmd:EX_GeographicBoundingBox>
                                    </gmd:geographicElement>
                                </xsl:when>
                                
                                <!-- BBOX -->
                                <xsl:otherwise>
                                    <gmd:geographicElement>
                                        <gmd:EX_GeographicDescription>
                                            <gmd:geographicIdentifier>
                                                <gmd:MD_Identifier>
                                                    <gmd:code><gmx:Anchor xlink:href=""></gmx:Anchor></gmd:code>
                                                </gmd:MD_Identifier>
                                            </gmd:geographicIdentifier>
                                        </gmd:EX_GeographicDescription>
                                    </gmd:geographicElement>
                                    <gmd:geographicElement>
                                        <gmd:EX_GeographicBoundingBox>
                                            <gmd:westBoundLongitude>
                                                <gco:Decimal><xsl:value-of select="xmin"/></gco:Decimal>
                                            </gmd:westBoundLongitude>
                                            <gmd:eastBoundLongitude>
                                                <gco:Decimal><xsl:value-of select="xmax"/></gco:Decimal>
                                            </gmd:eastBoundLongitude>
                                            <gmd:southBoundLatitude>
                                                <gco:Decimal><xsl:value-of select="ymin"/></gco:Decimal>
                                            </gmd:southBoundLatitude>
                                            <gmd:northBoundLatitude>
                                                <gco:Decimal><xsl:value-of select="ymax"/></gco:Decimal>
                                            </gmd:northBoundLatitude>
                                        </gmd:EX_GeographicBoundingBox>
                                    </gmd:geographicElement>
                                </xsl:otherwise>
                            </xsl:choose>
                            
							<xsl:for-each select="tempExt/item">
								<gmd:temporalElement>
									<gmd:EX_TemporalExtent>
										<gmd:extent>
											<xsl:choose>
                                                <!-- jen prvni nebo oba stejne -->
    											<xsl:when test="from=to or string-length(normalize-space(to))=0">
    												<gml:TimeInstant gml:id="TI{position()}">
    													<gml:timePosition>
                                                            <xsl:value-of select="php:function('date2iso', string(from))"/>
                                                        </gml:timePosition>
    												</gml:TimeInstant>
    											</xsl:when>
                                                <!-- oba casove udaje -->
    											<xsl:otherwise>
    												<gml:TimeInstant>
    													<gml:timePosition></gml:timePosition>
    												</gml:TimeInstant>
    												<gml:TimePeriod gml:id="TP{position()}">
    													<gml:beginPosition>
    														<xsl:value-of select="php:function('date2iso', string(from))"/>
    													</gml:beginPosition>
    													<gml:endPosition>
    														<xsl:value-of select="php:function('date2iso', string(to))"/>
    													</gml:endPosition>
    												</gml:TimePeriod>
    											</xsl:otherwise>
											</xsl:choose>
										</gmd:extent>
									</gmd:EX_TemporalExtent>
								</gmd:temporalElement>
							</xsl:for-each>
						</gmd:EX_Extent>
					</xsl:element>
					<xsl:if test="$serv='srv'">
						<srv:couplingType>
							<srv:SV_CouplingType codeListValue="{couplingType}" codeList="{$cl}#SV_CouplingType"/>
						</srv:couplingType>
                        <xsl:for-each select="operation/item">
                            <srv:containsOperations>
                                <srv:SV_OperationMetadata>
                                    <srv:operationName>
                                        <gco:CharacterString><xsl:value-of select="name"/></gco:CharacterString>
                                    </srv:operationName>
                                    <srv:DCP>
                                        <xsl:choose>
                                            <xsl:when test="name">
                                                <srv:DCPList codeList="*/DCPList" codeListValue="WebServices"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <srv:DCPList codeList="" codeListValue=""/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </srv:DCP>
                                    <srv:connectPoint>
                                        <gmd:CI_OnlineResource>
                                            <gmd:linkage>
                                                <gmd:URL><xsl:value-of select="url"/></gmd:URL>
                                            </gmd:linkage>
                                            <xsl:call-template name="uriOut">
                                                <xsl:with-param name="name" select="'protocol'"/>
                                                <xsl:with-param name="codes" select="$codes/protocol"/>
                                                <xsl:with-param name="t" select="protocol"/>
                                            </xsl:call-template>
                                        </gmd:CI_OnlineResource>
                                    </srv:connectPoint>
                                </srv:SV_OperationMetadata>
                            </srv:containsOperations>
                        </xsl:for-each>                        
						<xsl:for-each select="operatesOn/item">
							<srv:operatesOn xlink:title="{title}" uuidref="{uuid}" xlink:href="{href}#_{uuid}"/>
						</xsl:for-each>
					</xsl:if>
				</xsl:element>
			</gmd:identificationInfo>
			
            <!-- ================================ Content ====================================-->
            <xsl:choose>
                <xsl:when test="fcat">
                    <gmd:contentInfo>
                        <gmd:MD_FeatureCatalogueDescription>
                            <xsl:for-each select="featureTypes/item">
                                <gmd:featureTypes><gco:LocalName><xsl:value-of select="."/></gco:LocalName></gmd:featureTypes>
                            </xsl:for-each>
                            <xsl:variable name="fcRecord" select="php:function('getMetadataById', string(fcat))"/>
                            <gmd:featureCatalogueCitation>
                                <gmd:CI_Citation>
                                    <gmd:title>
                                        <xsl:copy-of select="$fcRecord//gmx:name/*"/>
                                    </gmd:title>
                                    <gmd:date>
                                        <gmd:CI_Date>
                                            <gmd:date>
                                                <gco:Date><xsl:value-of select="$fcRecord//gmx:versionDate/*"/></gco:Date>
                                            </gmd:date>
                                            <gmd:dateType>
                                                <gmd:CI_DateTypeCode codeListValue="revision" codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode">revision</gmd:CI_DateTypeCode>
                                            </gmd:dateType>
                                        </gmd:CI_Date>
                                    </gmd:date>
                                    <gmd:identifier>
                                        <gmd:MD_Identifier>
                                            <gmd:code>
                                                <gco:CharacterString><xsl:value-of select="fcat"/></gco:CharacterString>
                                            </gmd:code>
                                        </gmd:MD_Identifier>
                                    </gmd:identifier>
                                </gmd:CI_Citation>
                            </gmd:featureCatalogueCitation>
                        </gmd:MD_FeatureCatalogueDescription>
                    </gmd:contentInfo>
                </xsl:when>
                <xsl:otherwise>
                    <gmd:contentInfo>
                        <gmd:MD_FeatureCatalogueDescription>
                            <gmd:featureTypes><gco:LocalName></gco:LocalName></gmd:featureTypes>
                            <gmd:featureCatalogueCitation>
                                <gmd:CI_Citation>
                                    <gmd:title></gmd:title>
                                    <gmd:date>
                                        <gmd:CI_Date>
                                            <gmd:date></gmd:date>
                                            <gmd:dateType>
                                                <gmd:CI_DateTypeCode codeListValue=""></gmd:CI_DateTypeCode>
                                            </gmd:dateType>
                                        </gmd:CI_Date>
                                    </gmd:date>
                                    <gmd:identifier>
                                        <gmd:MD_Identifier>
                                            <gmd:code></gmd:code>
                                        </gmd:MD_Identifier>
                                    </gmd:identifier>
                                </gmd:CI_Citation>
                            </gmd:featureCatalogueCitation>
                        </gmd:MD_FeatureCatalogueDescription>
                    </gmd:contentInfo>
                </xsl:otherwise>
            </xsl:choose>
            
			<!-- ================================ Distribution ===============================-->
			<gmd:distributionInfo>
				<gmd:MD_Distribution>
					<xsl:for-each select="format/item">
						<gmd:distributionFormat>
							<gmd:MD_Format>
                                <xsl:call-template name="uriOut">
                                    <xsl:with-param name="name" select="'name'"/>
                                    <xsl:with-param name="codes" select="$codes/format"/>
                                    <xsl:with-param name="t" select="name"/>
                                </xsl:call-template>
								<gmd:version>
									<gco:CharacterString>
										<xsl:value-of select="version"/>
                                    </gco:CharacterString>
								</gmd:version>
								<gmd:specification>
                                    <xsl:variable name="u" select="specification"/>
                                    <xsl:variable name="sp" select="$codes/inspireKeywords/value[@spec=$u]"/>
                                    <xsl:choose>
                                        <xsl:when test="$sp">
                                            <gmx:Anchor xlink:href="{specification}">INSPIRE Data Specification on <xsl:value-of select="$sp/eng"/> - Guidelines</gmx:Anchor>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <gco:CharacterString>
                                                <xsl:value-of select="specification"/>
                                            </gco:CharacterString>
                                        </xsl:otherwise>
                                    </xsl:choose>
								</gmd:specification>
							</gmd:MD_Format>
						</gmd:distributionFormat>
					</xsl:for-each>
					<xsl:for-each select="distributor">
                        <gmd:distributor>
                            <gmd:MD_Distributor>
                                <gmd:distributorContact>
                                    <gmd:CI_ResponsibleParty>
                                        <gmd:organisationName>
                                            <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                                        </gmd:organisationName>
                                        <gmd:role>
                                            <CI_RoleCode codeListValue="distributor" codeList="{$cl}#CI_RoleCode"/>
                                        </gmd:role>
                                    </gmd:CI_ResponsibleParty>
                                </gmd:distributorContact>
                            </gmd:MD_Distributor>
                        </gmd:distributor>					 
					</xsl:for-each>
					<gmd:transferOptions>
						<gmd:MD_DigitalTransferOptions>
  						  <xsl:for-each select="linkage/item">
  							<gmd:onLine>
  								<gmd:CI_OnlineResource>
  									<gmd:linkage>
  										<gmd:URL>
  											<xsl:value-of select="url"/>
  										</gmd:URL>
  									</gmd:linkage>
                                    <xsl:call-template name="uriOut">
                                        <xsl:with-param name="name" select="'protocol'"/>
                                        <xsl:with-param name="codes" select="$codes/protocol"/>
                                        <xsl:with-param name="t" select="protocol"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="txtOut">
                                        <xsl:with-param name="name" select="'name'"/>
                                        <xsl:with-param name="t" select="name"/>
                                    </xsl:call-template>
                                    <gmd:description>
                                        <xsl:choose>
                                            <xsl:when test="accessPoint">
                                                <xsl:variable name="v">
                                                    <xsl:value-of select="description/TXT"/>
                                                    <xsl:if test="normalize-space(mime)"> mimeType="<xsl:value-of select="mime"/>"</xsl:if>
                                                </xsl:variable>
                                                <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/OnLineDescriptionCode/accessPoint">
                                                    <xsl:choose>
                                                        <xsl:when test="($v)"><xsl:value-of select="$v"/></xsl:when>
                                                        <xsl:otherwise>accessPoint</xsl:otherwise>
                                                    </xsl:choose>
                                                </gmx:Anchor>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <gco:CharacterString>
                                                    <xsl:value-of select="description/TXT"/>
                                                    <xsl:if test="normalize-space(mime)"> mimeType="<xsl:value-of select="mime"/>"</xsl:if>
                                                </gco:CharacterString>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="description/*[name()!='TXT']">
                                            <gmd:PT_FreeText> 
                                                <gmd:textGroup>
                                                    <xsl:for-each select="description/*[name()!='TXT']">		
                                                        <gmd:LocalisedCharacterString locale="#locale-{name()}"><xsl:value-of select="."/></gmd:LocalisedCharacterString>
                                                    </xsl:for-each>
                                                </gmd:textGroup>
                                            </gmd:PT_FreeText>
                                        </xsl:if>
                                    </gmd:description>
                                    
  									<gmd:function>
  										<gmd:CI_OnLineFunctionCode codeListValue="{function}" codeList="{$cl}#CI_OnLineFunctionCode">
  											<xsl:value-of select="function"/>
  										</gmd:CI_OnLineFunctionCode>
  									</gmd:function>
  								</gmd:CI_OnlineResource>
  							</gmd:onLine>
  						</xsl:for-each>
  						<xsl:for-each select="offline">	
						<gmd:offLine>
					      <gmd:MD_Medium>
					        <gmd:name>
                    			<gmd:MD_MediumNameCode codeListValue="{medium}" codeList="{$cl}#MD_MediumNameCode"><xsl:value-of select="medium"/></gmd:MD_MediumNameCode>
                  			</gmd:name>
					      </gmd:MD_Medium>
					    </gmd:offLine>
					    </xsl:for-each>
						</gmd:MD_DigitalTransferOptions>
					</gmd:transferOptions>
				</gmd:MD_Distribution>
			</gmd:distributionInfo>

			<!-- ================================ Quality ===============================-->
			<gmd:dataQualityInfo>
				<gmd:DQ_DataQuality>
					<gmd:scope>
						<gmd:DQ_Scope>
							<gmd:level>
								<gmd:MD_ScopeCode codeListValue="{hierarchyLevel}" codeList="{$cl}#MD_ScopeCode"><xsl:value-of select="hierarchyLevel"/></gmd:MD_ScopeCode>
							</gmd:level>
						</gmd:DQ_Scope>
					</gmd:scope>

					<xsl:for-each select="specification/item">
						<xsl:variable name="spec" select="."/>
	  					<gmd:report>
	  						<gmd:DQ_DomainConsistency xsi:type="DQ_DomainConsistency_Type">
	  							<gmd:result>
	  								<gmd:DQ_ConformanceResult xsi:type="DQ_ConformanceResult_Type">
	  									<gmd:specification>
	  										<gmd:CI_Citation>
                                                <xsl:call-template name="uriOut">
                                                    <xsl:with-param name="name" select="'title'"/>
                                                    <xsl:with-param name="codes" select="$codes/specifications"/>
                                                    <xsl:with-param name="t" select="uri"/>
                                                    <xsl:with-param name="lattrib" select="'name'"/>
                                                </xsl:call-template>
	  											<gmd:date>
	  												<gmd:CI_Date>
                       							        <gmd:date>
                                                            <gco:Date><xsl:value-of select="$codes/specifications/value[@uri=$spec/uri]/@publication"/></gco:Date>
                                                        </gmd:date>
                                                        <gmd:dateType>
	  														<gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
	  													</gmd:dateType>
	  												</gmd:CI_Date>
	  											</gmd:date>
	  										</gmd:CI_Citation>
	  									</gmd:specification>
                                        <gmd:explanation>
	  										<xsl:choose>
		  										<xsl:when test="$mdlang='cze'">
		  											<gco:CharacterString>Viz odkazovanou specifikaci</gco:CharacterString>
		  											<xsl:if test="$spec/title/TXTeng!=''">
		  												<gmd:PT_FreeText>
												      		<textGroup>
												        		<LocalisedCharacterString locale="#locale-eng">See the referenced specification</LocalisedCharacterString>
												      		</textGroup>
														</gmd:PT_FreeText>
		  											</xsl:if>
		  										</xsl:when>	
		  										<xsl:otherwise>
		  											<gco:CharacterString>See the referenced specification</gco:CharacterString>
		  											<xsl:if test="$spec/title/TXTcze!=''">
		  												<gmd:PT_FreeText>
												      		<textGroup>
												        		<LocalisedCharacterString locale="#locale-cze">Viz odkazovanou specifikaci</LocalisedCharacterString>
												      		</textGroup>
														</gmd:PT_FreeText>
		  											</xsl:if>
		  										</xsl:otherwise>
	  										</xsl:choose>
	  									</gmd:explanation>
	  									<gmd:pass>
											<gco:Boolean><xsl:if test="$spec/compliant='true' or $spec/compliant='false'"><xsl:value-of select="$spec/compliant"/></xsl:if></gco:Boolean>
	  									</gmd:pass>
	  								</gmd:DQ_ConformanceResult>
	  							</gmd:result>
	  						</gmd:DQ_DomainConsistency>
	  					</gmd:report>
	  				</xsl:for-each>
                    
                    <xsl:for-each select="sds">
	  					<gmd:report>
	  						<gmd:DQ_DomainConsistency xsi:type="DQ_DomainConsistency_Type">
	  							<gmd:result>
	  								<gmd:DQ_ConformanceResult xsi:type="DQ_ConformanceResult_Type">
	  									<gmd:specification>
	  										<gmd:CI_Citation>
                                                <xsl:call-template name="uriOut">
                                                    <xsl:with-param name="name" select="'title'"/>
                                                    <xsl:with-param name="codes" select="$codes/sds"/>
                                                    <xsl:with-param name="t" select="."/>
                                                </xsl:call-template>
	  											<gmd:date>
	  												<gmd:CI_Date>
                       							        <gmd:date>
                                                            <gco:Date><xsl:value-of select="$codes/sds/value[@uri=.]/@publication"/></gco:Date>
                                                        </gmd:date>
                                                        <gmd:dateType>
	  														<gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
	  													</gmd:dateType>
	  												</gmd:CI_Date>
	  											</gmd:date>
	  										</gmd:CI_Citation>
	  									</gmd:specification>
                                        <gmd:explanation>
 											<gco:CharacterString>This Spatial Data Service set is conformant with the INSPIRE requirements for Invocable Spatial Data Services</gco:CharacterString>
	  									</gmd:explanation>
	  									<gmd:pass>
											<gco:Boolean>true</gco:Boolean>
	  									</gmd:pass>
	  								</gmd:DQ_ConformanceResult>
	  							</gmd:result>
	  						</gmd:DQ_DomainConsistency>
	  					</gmd:report>
                    </xsl:for-each>
                    
                    <gmd:report>
                        <gmd:DQ_DomainConsistency>
                            <gmd:result>
                                <gmd:DQ_ConformanceResult>
                                    <gmd:specification>
                                        <gmd:CI_Citation>
                                            <gmd:title>
                                                <gco:CharacterString></gco:CharacterString>
                                            </gmd:title>
                                            <gmd:date>
                                                <gmd:CI_Date>
                                                    <gmd:date>
                                                        <gco:Date></gco:Date>
                                                    </gmd:date>
                                                    <gmd:dateType>
                                                        <gmd:CI_DateTypeCode codeList="" codeListValue=""/>
                                                    </gmd:dateType>
                                                </gmd:CI_Date>
                                            </gmd:date>
                                        </gmd:CI_Citation>
                                    </gmd:specification>
                                    <gmd:explanation>
                                        <gco:CharacterString></gco:CharacterString>
                                    </gmd:explanation>
                                    <gmd:pass>
                                        <gco:Boolean></gco:Boolean>
                                    </gmd:pass>
                                </gmd:DQ_ConformanceResult>
                            </gmd:result>
                        </gmd:DQ_DomainConsistency>
                    </gmd:report>
	  					

					<!-- CZ-7 Pokrytí -->
                    <xsl:choose>
                        <xsl:when test="coveragePercent">
                            <gmd:report>
                                <gmd:DQ_CompletenessOmission>
                                    <gmd:nameOfMeasure>
                                        <gco:CharacterString>Pokrytí</gco:CharacterString>
                                    </gmd:nameOfMeasure>
                                    <gmd:measureIdentification>
                                        <gmd:RS_Identifier>
                                            <gmd:code>
                                                <gco:CharacterString>CZ-COVERAGE</gco:CharacterString>
                                            </gmd:code>
                                        </gmd:RS_Identifier>
                                    </gmd:measureIdentification>
                                    <xsl:call-template name="uriOut">
                                        <xsl:with-param name="name" select="'measureDescription'"/>
                                        <xsl:with-param name="codes" select="$codes/extents"/>
                                        <xsl:with-param name="t" select="extentId"/>
                                    </xsl:call-template>
                                    <!--  <gmd:dateTime>
                                        <gco:DateTime>2012-05-03T00:00:00</gco:DateTime>
                                    </gmd:dateTime>-->
                                    <xsl:variable name="c" select="normalize-space(extentId)"/>
                                    <xsl:variable name="area" select="$codes/extents/value[@uri=$c]/@area"/>
                                    <gmd:result>
                                        <gmd:DQ_QuantitativeResult>
                                            <gmd:valueUnit xlink:href="http://geoportal.gov.cz/res/units.xml#percent"/>
                                            <gmd:value>
                                                <gco:Record><xsl:value-of select="coveragePercent"/></gco:Record>
                                            </gmd:value>
                                        </gmd:DQ_QuantitativeResult>
                                    </gmd:result>
                                    <gmd:result>
                                        <gmd:DQ_QuantitativeResult>
                                            <gmd:valueUnit xlink:href="http://geoportal.gov.cz/res/units.xml#km2"/>
                                            <gmd:value>
                                                <gco:Record><xsl:value-of select="$area * coveragePercent div 100"/></gco:Record>
                                            </gmd:value>
                                        </gmd:DQ_QuantitativeResult>
                                    </gmd:result>
                                </gmd:DQ_CompletenessOmission>
                            </gmd:report>
                        </xsl:when>
                        <xsl:otherwise>
                            <gmd:report>
                                <gmd:DQ_CompletenessOmission>
                                    <gmd:nameOfMeasure>
                                        <gco:CharacterString></gco:CharacterString>
                                    </gmd:nameOfMeasure>
                                    <gmd:measureIdentification>
                                        <gmd:RS_Identifier>
                                            <gmd:code>
                                                <gco:CharacterString></gco:CharacterString>
                                            </gmd:code>
                                        </gmd:RS_Identifier>
                                    </gmd:measureIdentification>
                                    <gmd:measureDescription><gmx:Anchor xlink:href=""></gmx:Anchor></gmd:measureDescription>
                                    <gmd:result>
                                        <gmd:DQ_QuantitativeResult>
                                            <gmd:valueUnit xlink:href=""/>
                                            <gmd:value>
                                                <gco:Record></gco:Record>
                                            </gmd:value>
                                        </gmd:DQ_QuantitativeResult>
                                    </gmd:result>
                                    <gmd:result>
                                        <gmd:DQ_QuantitativeResult>
                                            <gmd:valueUnit xlink:href=""/>
                                            <gmd:value>
                                                <gco:Record></gco:Record>
                                            </gmd:value>
                                        </gmd:DQ_QuantitativeResult>
                                    </gmd:result>
                                </gmd:DQ_CompletenessOmission>
                            </gmd:report>
                        </xsl:otherwise>
	  				</xsl:choose>
                    
					<!-- IOD-4 Topological consistency -->
					<xsl:for-each select="topological/item[string-length(normalize-space(name))>0]">
						<xsl:variable name="topol" select="."/>
	  					<gmd:report>
	  						<gmd:DQ_TopologicalConsistency xsi:type="gmd:DQ_TopologicalConsistency_Type">
                                <gmd:nameOfMeasure>
                                    <gco:CharacterString><xsl:value-of select="name"/></gco:CharacterString> 
                                </gmd:nameOfMeasure>                               
	  							<gmd:measureIdentification>
	  								<gmd:RS_Identifier>
	  									<gmd:code>
	  										<gco:CharacterString><xsl:value-of select="code"/></gco:CharacterString>
	  									</gmd:code>
	  								</gmd:RS_Identifier>
	  							</gmd:measureIdentification>
                                <gmd:evaluationMethodType>
                                    <gmd:DQ_EvaluationMethodTypeCode codeList="{$cl}#DQ_EvaluationMethodTypeCode" codeListValue="{mtype}"><xsl:value-of select="mtype"/></gmd:DQ_EvaluationMethodTypeCode>
                                </gmd:evaluationMethodType>
                                <xsl:call-template name="txtOut">
						              <xsl:with-param name="name" select="'evaluationMethodDescription'"/>
						          <xsl:with-param name="t" select="descr"/>
					            </xsl:call-template>					
                                <gmd:dateTime>
                                    <gco:DateTime><xsl:value-of select="php:function('date2iso', string(date))"/>T00:00:00</gco:DateTime> 
                                </gmd:dateTime>
                                <gmd:result>
                                    <gmd:DQ_QuantitativeResult>
                                        <gmd:valueUnit xlink:href="http://geoportal.gov.cz/res/units.xml#{unit}" /> 
                                        <gmd:value>
                                        	<gco:Record><xsl:value-of select="value"/></gco:Record> 
                                    	</gmd:value>
                                	</gmd:DQ_QuantitativeResult>
                            		<!--gmd:DQ_ConformanceResult>
                            			<gmd:specification>
                            				<gmd:CI_Citation>
                            					<gmd:title>
                            						<gco:CharacterString><xsl:value-of select="specification"/></gco:CharacterString>
                            					</gmd:title>
                            					<gmd:date>
                            						<gmd:CI_Date>
                            							<gmd:date><xsl:value-of select="specDate"/></gmd:date>
                            							<gmd:dateType><xsl:value-of select="specDateType"/></gmd:dateType>
                            						</gmd:CI_Date>
                            					</gmd:date>
                            				</gmd:CI_Citation>	
                            			</gmd:specification>
                            			<gmd:explanation>
                            				<gco:CharacterString><xsl:value-of select="explanation"/></gco:CharacterString>
                            			</gmd:explanation>
                            			<gmd:pass>
                            				<gco:Boolean><xsl:value-of select="pass"/></gco:Boolean>
                            			</gmd:pass>
                            		</gmd:DQ_ConformanceResult-->
                            	</gmd:result>
	  						</gmd:DQ_TopologicalConsistency>
	  					</gmd:report>
	  				</xsl:for-each>
	  				<xsl:if test="string-length(normalize-space(topological/item/name))=0">
	  					<gmd:report>
	  						<gmd:DQ_TopologicalConsistency> 
	  						</gmd:DQ_TopologicalConsistency>
	  					</gmd:report>
	  				</xsl:if>
                    
					<!-- IO-2 - services -->
                    <xsl:if test="availability">
                        <xsl:variable name="topol" select="."/>
                        <gmd:report>
                            <gmd:DQ_ConceptualConsistency xsi:type="DQ_ConceptualConsistency_Type">
                                <gmd:nameOfMeasure>
                                    <gmx:Anchor xlink:href="{$codes/serviceQuality/value[1]/@uri}"><xsl:value-of select="$codes/serviceQuality/value[1]/*[name()=$lang]"/></gmx:Anchor>
                                </gmd:nameOfMeasure>
                                <gmd:measureDescription>
                                    <gco:CharacterString><xsl:value-of select="$codes/serviceQuality/value[1]/*[name()=$lang]/@qtip"/></gco:CharacterString>
                                </gmd:measureDescription>
                                <gmd:result>
                                    <gmd:DQ_QuantitativeResult>
                                        <gmd:valueUnit xlink:href="http://geoportal.gov.cz/res/units.xml#percent"/> 
                                        <gmd:value>
                                            <gco:Record xsi:type="xs:double"><xsl:value-of select="availability"/></gco:Record> 
                                        </gmd:value>
                                    </gmd:DQ_QuantitativeResult>
                                </gmd:result>
                            </gmd:DQ_ConceptualConsistency>
                        </gmd:report>
                    </xsl:if>
                    
					<!-- IO-2 pro služby -->
                    <xsl:if test="normalize-space(performance)">
                        <xsl:variable name="topol" select="."/>
                        <gmd:report>
                            <gmd:DQ_ConceptualConsistency xsi:type="DQ_ConceptualConsistency_Type">
                                <gmd:nameOfMeasure>
                                    <gmx:Anchor xlink:href="{$codes/serviceQuality/value[2]/@uri}"><xsl:value-of select="$codes/serviceQuality/value[2]/*[name()=$lang]"/></gmx:Anchor>
                                </gmd:nameOfMeasure>
                                <gmd:measureDescription>
                                    <gco:CharacterString><xsl:value-of select="$codes/serviceQuality/value[2]/*[name()=$lang]/@qtip"/></gco:CharacterString>
                                </gmd:measureDescription>
                                <gmd:result>
                                    <gmd:DQ_QuantitativeResult>
                                        <gmd:valueUnit xlink:href="http://geoportal.gov.cz/res/units.xml#second"/> 
                                        <gmd:value>
                                            <gco:Record xsi:type="xs:double"><xsl:value-of select="performance"/></gco:Record> 
                                        </gmd:value>
                                    </gmd:DQ_QuantitativeResult>
                                </gmd:result>
                            </gmd:DQ_ConceptualConsistency>
                        </gmd:report>
                    </xsl:if>
                    
					<!-- IO-2 pro služby -->
                    <xsl:if test="normalize-space(capacity)">
                        <xsl:variable name="topol" select="."/>
                        <gmd:report>
                            <gmd:DQ_ConceptualConsistency xsi:type="DQ_ConceptualConsistency_Type">
                                <gmd:nameOfMeasure>
                                    <gmx:Anchor xlink:href="{$codes/serviceQuality/value[3]/@uri}"><xsl:value-of select="$codes/serviceQuality/value[3]/*[name()=$lang]"/></gmx:Anchor>
                                </gmd:nameOfMeasure>
                                <gmd:measureDescription>
                                    <gco:CharacterString><xsl:value-of select="$codes/serviceQuality/value[3]/*[name()=$lang]/@qtip"/></gco:CharacterString>
                                </gmd:measureDescription>
                                <gmd:result>
                                    <gmd:DQ_QuantitativeResult>
                                        <gmd:valueUnit xlink:href="http://geoportal.gov.cz/res/units.xml#count"/> 
                                        <gmd:value>
                                            <gco:Record xsi:type="xs:double"><xsl:value-of select="capacity"/></gco:Record> 
                                        </gmd:value>
                                    </gmd:DQ_QuantitativeResult>
                                </gmd:result>
                            </gmd:DQ_ConceptualConsistency>
                        </gmd:report>
                    </xsl:if>
                    
                    <!--gmd:report>
                        <gmd:DQ_ConceptualConsistency xsi:type="DQ_ConceptualConsistency_Type">
                            <gmd:nameOfMeasure>
                                <gmx:Anchor xlink:href=""></gmx:Anchor>
                            </gmd:nameOfMeasure>
                            <gmd:measureDescription>
                                <gco:CharacterString></gco:CharacterString>
                            </gmd:measureDescription>
                            <gmd:result>
                                <gmd:DQ_QuantitativeResult>
                                    <gmd:valueUnit xlink:href=""/> 
                                    <gmd:value>
                                        <gco:Record></gco:Record> 
                                    </gmd:value>
                                </gmd:DQ_QuantitativeResult>
                            </gmd:result>
                        </gmd:DQ_ConceptualConsistency>
                    </gmd:report-->
                    
                    <gmd:lineage>
                        <gmd:LI_Lineage>
                            <xsl:call-template name="txtOut">
                              <xsl:with-param name="name" select="'statement'"/>
                              <xsl:with-param name="t" select="lineage"/>
                           </xsl:call-template>					
                        </gmd:LI_Lineage>
                    </gmd:lineage>
					
				</gmd:DQ_DataQuality>
			</gmd:dataQualityInfo>


		</gmd:MD_Metadata>
	</xsl:template>

	<!-- sablona na kontakty -->
	<xsl:template name="contact">
		<xsl:param name="party"/>

		<gmd:CI_ResponsibleParty>
            <gmd:individualName>
                <xsl:choose>
                    <xsl:when test="$party/individualName=$party/individualNameTxt or $party/individualName=''">
                        <gco:CharacterString><xsl:value-of select="$party/individualName"/></gco:CharacterString>
                    </xsl:when>
                    <xsl:otherwise>
                        <gmx:Anchor xlink:href="{$party/individualName}">
                            <xsl:value-of select="$party/individualNameTxt"/>
                        </gmx:Anchor>
                    </xsl:otherwise>
                </xsl:choose>
            </gmd:individualName>
			<xsl:call-template name="txtOut">
				<xsl:with-param name="name" select="'organisationName'"/>
				<xsl:with-param name="t" select="$party/organisationName"/>
			</xsl:call-template>										
			<!-- <positionName>
				<gco:CharacterString>
					<xsl:value-of select="$party/positionName"/>
				</gco:CharacterString>
			</positionName> -->
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<gmd:phone>
						<gmd:CI_Telephone>
							<xsl:for-each select="$party/phone">
								<gmd:voice>
									<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
								</gmd:voice>
							</xsl:for-each>
						</gmd:CI_Telephone>
					</gmd:phone>
					<gmd:address>
						<gmd:CI_Address>
							<gmd:deliveryPoint>
								<gco:CharacterString>
									<xsl:value-of select="$party/deliveryPoint"/>
								</gco:CharacterString>
							</gmd:deliveryPoint>
							<gmd:city>
								<gco:CharacterString>
									<xsl:value-of select="$party/city"/>
								</gco:CharacterString>
							</gmd:city>
							<!-- <administrativeArea>
								<gco:CharacterString>
									<xsl:value-of select="$party/administrativeArea"/>
								</gco:CharacterString>
							</administrativeArea>  -->
							<gmd:postalCode>
								<gco:CharacterString>
									<xsl:value-of select="$party/postalCode"/>
								</gco:CharacterString>
							</gmd:postalCode>
							<gmd:country>
								<gco:CharacterString>
									<xsl:value-of select="$party/country"/>
								</gco:CharacterString>
							</gmd:country>
							<xsl:for-each select="$party/email">
								<gmd:electronicMailAddress>
									<gco:CharacterString>
										<xsl:value-of select="."/>
									</gco:CharacterString>
								</gmd:electronicMailAddress>
							</xsl:for-each>
						</gmd:CI_Address>
					</gmd:address>
					<xsl:for-each select="$party/www">
						<gmd:onlineResource>
							<gmd:CI_OnlineResource>
								<gmd:linkage>
									<gmd:URL>
										<xsl:value-of select="."/>
									</gmd:URL>
								</gmd:linkage>
							</gmd:CI_OnlineResource>
						</gmd:onlineResource>
					</xsl:for-each>
				</gmd:CI_Contact>
			</gmd:contactInfo>
			<gmd:role>
				<gmd:CI_RoleCode codeListValue="{$party/role}" codeList="{$cl}#CI_RoleCode"><xsl:value-of select="$party/role"/></gmd:CI_RoleCode>
			</gmd:role>
		</gmd:CI_ResponsibleParty>
	</xsl:template>
	
</xsl:stylesheet>
