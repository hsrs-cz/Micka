<!-- DWXMLSource="../../../../../../Inetpub/wwwroot/xml/midas_typo.xml" -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="utf-8"/>
  <xsl:template match="/">
  
  <xsl:variable name="mapping" select="document('midas.xml')" />
  
  <results>
    <MD_Metadata xmlns="http://metadata.dgiwg.org/smXML" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://metadata.dgiwg.org/smXML ..\smXML\metadataEntity.xsd">
      <dateStamp><xsl:value-of select="METAIS/DATASET/OBJECT_STANDARD/@META_AKT"/></dateStamp>
      <metadataStandardName>ISO 19115</metadataStandardName>
      <metadataStandardVersion>2003</metadataStandardVersion>
      <language>
    	<LanguageCode>cze</LanguageCode>
      </language>
      <xsl:if test="METAIS/DATASET/OBJECT_STANDARD/@K_TYP_OBJ='DATASET'">
        <hierarchyLevel>
	      <MD_ScopeCode>dataset</MD_ScopeCode>
	    </hierarchyLevel>
	  </xsl:if>

	  <!-- identifikace -->
      <identificationInfo>
        <MD_DataIdentification>
          <citation>
          	<CI_Citation>
              <title><xsl:value-of select="METAIS/DATASET/OBJECT_STANDARD/@NAZEV"/></title>
            </CI_Citation>	
		  </citation>
		  <abstract><xsl:value-of select="METAIS/DATASET/OBJECT_STANDARD/@POPIS"/></abstract>
  		  <spatialResolution>
  		    <MD_Resolution>
  				<equivalentScale>
  				  <MD_RepresentativeFraction>
  					<denominator>
  						<xsl:value-of select="METAIS/DATASET/@MERITKO_DO"/>
  					</denominator>
  				  </MD_RepresentativeFraction>	
  				</equivalentScale>
  			  </MD_Resolution>	
  			</spatialResolution>
  			<extent>
  			  <EX_Extent>
  			  <xsl:if test="METAIS/DATASET/OBJECT_STANDARD/@PLATN_OD">
				<temporalElement>
				  <EX_TemporalExtent>
					<extent>
						<TimePeriod>
							<beginPosition>
							  <xsl:value-of select="substring(METAIS/DATASET/OBJECT_STANDARD/@PLATN_OD,1,4)"/>-<xsl:value-of select="substring(METAIS/DATASET/OBJECT_STANDARD/@PLATN_OD,5,2)"/>-<xsl:value-of select="substring(METAIS/DATASET/OBJECT_STANDARD/@PLATN_OD,7,2)"/>
							</beginPosition>
							<endPosition>
							  <xsl:value-of select="substring(METAIS/DATASET/OBJECT_STANDARD/@PLATN_DO,1,4)"/>-<xsl:value-of select="substring(METAIS/DATASET/OBJECT_STANDARD/@PLATN_DO,5,2)"/>-<xsl:value-of select="substring(METAIS/DATASET/OBJECT_STANDARD/@PLATN_DO,7,2)"/>
							</endPosition>
						</TimePeriod>
					</extent>
				  </EX_TemporalExtent>
				</temporalElement>				
			  </xsl:if>
              </EX_Extent>
  			</extent>
			<xsl:for-each select="METAIS/DATASET/OBJECT_STANDARD/OBJECT_STANDARD_KLASIF[@K_TEZAUR='3']">
			  <xsl:for-each select="OBJECT_STANDARD_ID_TERM">
				<topicCategory>
					<MD_TopicCategoryCode>
					    <xsl:variable name="kcat" select="@ID_TERM"/>
						<xsl:value-of select="$mapping//theme[@code=$kcat]/@iso"/>
					</MD_TopicCategoryCode>
				</topicCategory>
			  </xsl:for-each>
			</xsl:for-each>

        </MD_DataIdentification>
      </identificationInfo>  
	  
	  
	  <!-- jakost dat -->
      <dataQualityInfo>
      	<DQ_DataQuality>
          <scope>
            <DQ_Scope>
          	  <level>
          	  	<MD_ScopeCode>dataset</MD_ScopeCode>
          	  </level>
          	</DQ_Scope>  
          </scope>	
        	<lineage>
        	  <LI_Lineage>
          		<statement><xsl:value-of select="METAIS/DATASET/@PUVOD"/></statement>
          	  </LI_Lineage>	
        	</lineage>
        </DQ_DataQuality>	
      </dataQualityInfo>

	  <!-- distribuce -->
	  <MD_Distribution>
        <xsl:for-each select="metadata/distInfo/distributor/distorFormat">
          <distributionFormat>
            <name><xsl:value-of select="formatName"/></name>
            <version><xsl:value-of select="formatVer"/></version>
          </distributionFormat>
        </xsl:for-each>
		<xsl:for-each select="METAIS/DATASET/OBJECT_STANDARD/OBJECT_STANDARD_ODKAZ">
          <transferOptions>
            <onLine>
              <linkage><xsl:value-of select="@ODKAZ_URL"/></linkage>
			        <description><xsl:value-of select="@ODKAZ_TXT"/></description>
            </onLine>
          </transferOptions>
		</xsl:for-each>
      </MD_Distribution>
	  
    </MD_Metadata>
  </results>

  </xsl:template>
</xsl:stylesheet>
