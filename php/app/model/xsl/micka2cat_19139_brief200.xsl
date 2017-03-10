<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="/">

<csw:GetRecordsResponse 
  xmlns:csw="http://www.opengis.net/cat/csw" 
  xmlns="http://schemas.opengis.net/iso19115brief" 
  xmlns:srv="http://schemas.opengis.net/iso19119"
  xmlns:gco="http://metadata.dgiwg.org/smXML"
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  version="2.0.0">
	<csw:RequestId><xsl:value-of select="$REQUESTID"/></csw:RequestId>
	<csw:SearchStatus timestamp="{$timestamp}" status="complete"/>
      <csw:SearchResults numberOfRecordsMatched="{results/@numberOfRecordsMatched}" numberOfRecordsReturned="{results/@numberOfRecordsReturned}" nextRecord="{results/@nextRecord}" elementSet="brief">

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
			<hierarchyLevel>
			  <MD_ScopeCode codeList="./resources/codeList.xml#MD_ScopeCode" codeListValue="{hierarchyLevel/MD_ScopeCode}"><xsl:value-of select="hierarchyLevel/MD_ScopeCode"/></MD_ScopeCode>
			</hierarchyLevel>			
			
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

					
          <xsl:if test="string-length(//serviceType)>0">
            <srv:serviceType>
              <gco:CharacterString><xsl:value-of select="//serviceType/nameValue"/></gco:CharacterString> 
            </srv:serviceType>
            <srv:serviceTypeVersion>
              <gco:CharacterString><xsl:value-of select="//serviceTypeVersion"/></gco:CharacterString> 
            </srv:serviceTypeVersion>
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
						</gco:EX_Extent>
					</extent>
					
				</xsl:element>
				
				<xsl:for-each select="//couplingType">
        <srv:couplingType>
				  <srv:SV_CouplingType codeList="./resources/codeList.xml#SV_CouplingType" codeListValue="{.}"/>
        </srv:couplingType>
        </xsl:for-each>
        
			</identificationInfo>	

		</MD_Metadata>
		

        </xsl:for-each>
      </csw:SearchResults>
    </csw:GetRecordsResponse>
  </xsl:template>

  <xsl:include href="common200.xsl" />
   
</xsl:stylesheet>
