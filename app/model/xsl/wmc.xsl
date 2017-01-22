<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:wms="http://www.opengis.net/wms"
  xmlns:gco="http://www.opengis.net/gco"
  xmlns:ct="http://www.opengis.net/context"
  xmlns:ol="http://openlayers.org/context"
  xmlns:hs="http://hsrs.cz/context"  
  >
  
  <xsl:output method="xml" encoding="utf-8"/>
  
  <xsl:variable name="lang">
      	<xsl:choose>
    		<xsl:when test="ct:ViewContext/ct:General/ct:Extension/hs:language">
				<xsl:value-of select="ct:ViewContext/ct:General/ct:Extension/hs:language"/>
			</xsl:when>
			<xsl:otherwise>cze</xsl:otherwise>	
		</xsl:choose>
  </xsl:variable>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="codeLists" select="document(concat('codelists_' , $lang, '.xml'))/map" />

  <xsl:template match="ct:ViewContext">
  <results>
    <MD_Metadata>
    <language>
		<LanguageCode><xsl:value-of select="$lang"/></LanguageCode>
	</language>
	<fileIdentifier><xsl:value-of select="@id"/></fileIdentifier>
    <contact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="ct:General/ct:ContactInformation/*/ct:ContactPerson"/></individualName>
	    <organisationName><xsl:value-of select="ct:General/ct:ContactInformation/*/ct:ContactOrganization"/></organisationName>
	    <contactInfo>
	      <CI_Contact>
	        <phone>
	        <CI_Telephone>
		          <voice><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactVoiceTelephone|ct:General/ct:ContactInformation/ct:ContactVoicePhone"/></voice><!-- docasne kvuli chybe ve WMC u Jachyma -->
	        </CI_Telephone>  
	        </phone>
	        <address>
	        <CI_Address>
	          <deliveryPoint><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:Address"/></deliveryPoint>
	          <city><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:City"/></city>
	          <postalCode><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:PostCode"/></postalCode>
	          <country><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:Country"/></country>
	          <electronicMailAddress><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactElectronicMailAddress"/></electronicMailAddress>
	        </CI_Address>
	        </address>
	      </CI_Contact>
	    </contactInfo>
	    <positionName><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactPosition"/></positionName>
	  	<role>
			<CI_RoleCode codeListValue="pointOfContact" codeList="">pointOfContact</CI_RoleCode>
		</role>	
	  </CI_ResponsibleParty>
    </contact>
    <identificationInfo>
    <SV_ServiceIdentification>
	    <citation>
	      <CI_Citation>
       		<title><xsl:value-of select="ct:General/ct:Title"/></title>
	        <date>
	        	<CI_Date>
	        		<date><xsl:value-of select="substring-before(ct:General/ct:Extension/hs:timeStamp,'T')"/></date>
	        		<dateType><CI_DateTypeCode codeList="" codeListValue="revision"/></dateType>
	        	</CI_Date>
	        </date>
	      </CI_Citation>	
	    </citation>
        <abstract><xsl:value-of select="ct:General/ct:Abstract"/></abstract>

	<!-- Klic. slova INSPIRE -->
    <xsl:if test="ct:General/ct:KeywordList/ct:Keyword[contains(.,'INSPIRE:')]!=''">
	    <descriptiveKeywords>
	      <MD_Keywords>
	      <xsl:for-each select="ct:General/ct:KeywordList/ct:Keyword[contains(.,'INSPIRE:')]">
	        <keyword><xsl:value-of select="substring-after(.,':')"/></keyword>
	      </xsl:for-each>
			<thesaurusName>
				<CI_Citation>
					<title>
						<gco:CharacterString>GEMET - INSPIRE themes, version 1.0</gco:CharacterString>
					</title>
					<date>
						<CI_Date>
							<date>
								<gco:Date>2008-06-01</gco:Date>
							</date>
							<dateType>
								<CI_DateTypeCode codeListValue="publication" codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode">publication</CI_DateTypeCode>
							</dateType>
						</CI_Date>
					</date>
				</CI_Citation>
			</thesaurusName>
	      </MD_Keywords>
	    </descriptiveKeywords>
    </xsl:if>    

	<!-- Klic. slova INSPIRE - služby -->
	<descriptiveKeywords>
	  <MD_Keywords>
        <keyword>humanGeographicViewer</keyword>
		<thesaurusName>
			<CI_Citation>
				<title>
					<gco:CharacterString>ISO 19119 geographic services taxonomy, 1.0</gco:CharacterString>
				</title>
				<date>
					<CI_Date>
						<date>
							<gco:Date>2010</gco:Date>
						</date>
						<dateType>publication</dateType>
					</CI_Date>
				</date>
			</CI_Citation>
		</thesaurusName>
      </MD_Keywords>
    </descriptiveKeywords>

    <!-- Klic. slova CENIA -->
    <xsl:if test="ct:General/ct:KeywordList/ct:Keyword[contains(.,'INSPIRE:')]!=''">
	    <descriptiveKeywords>
	      <MD_Keywords>
	      <xsl:for-each select="ct:General/ct:KeywordList/ct:Keyword[contains(.,'INSPIRE:')]">
	      	<xsl:variable name="kwd" select="normalize-space(substring-after(.,':'))"/>
	      	<keyword><xsl:value-of select="$codeLists/inspireKeywords/value[normalize-space(@name)=$kwd]/@cenia"/></keyword>
	      </xsl:for-each>
			<thesaurusName>
				<CI_Citation>
					<title>
						<gco:CharacterString>CENIA</gco:CharacterString>
					</title>
					<date>
						<CI_Date>
							<date>
								<gco:Date>2011</gco:Date>
							</date>
							<dateType>
								<CI_DateTypeCode codeListValue="publication" codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode">publication</CI_DateTypeCode>
							</dateType>
						</CI_Date>
					</date>
				</CI_Citation>
			</thesaurusName>
	      </MD_Keywords>
	    </descriptiveKeywords>
    </xsl:if>    
    
	<!-- Dalsi klic. slova -->
    <descriptiveKeywords>
      <MD_Keywords>
      	<xsl:for-each select="ct:General/ct:KeywordList/ct:Keyword[not(contains(.,':'))]">
       		<keyword><xsl:value-of select="."/></keyword>
      	</xsl:for-each>
	  </MD_Keywords>
    </descriptiveKeywords>
    
    <!-- <language>
       	<xsl:choose>
    		<xsl:when test="ct:General/ct:Extension/hs:language">
				<LanguageCode><xsl:value-of select="ct:General/ct:Extension/hs:language"/></LanguageCode>
			</xsl:when>
			<xsl:otherwise>cze</xsl:otherwise>	
		</xsl:choose>
    </language> -->
    
    <pointOfContact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="ct:General/ct:ContactInformation/*/ct:ContactPerson"/></individualName>
	    <organisationName><xsl:value-of select="ct:General/ct:ContactInformation/*/ct:ContactOrganization"/></organisationName>
	    <contactInfo>
	      <CI_Contact>
	        <phone>
		        <CI_Telephone>
		          <voice><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactVoiceTelephone|ct:General/ct:ContactInformation/ct:ContactVoicePhone"/></voice><!-- docasne kvuli chybe ve WMC u Jachyma -->
		        </CI_Telephone>  
	        </phone>
	        <address>
		        <CI_Address>
		          <deliveryPoint><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:Address"/></deliveryPoint>
		          <city><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:City"/></city>
		          <postalCode><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:PostCode"/></postalCode>
		          <country><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactAddress/ct:Country"/></country>
		          <electronicMailAddress><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactElectronicMailAddress"/></electronicMailAddress>
		        </CI_Address>
	        </address>
	      </CI_Contact>
	    </contactInfo>
	    <positionName><xsl:value-of select="ct:General/ct:ContactInformation/ct:ContactPosition"/></positionName>
	  	<role>
			<CI_RoleCode codeListValue="custodian" codeList="">custodian</CI_RoleCode>
		</role>	
	  </CI_ResponsibleParty>
    </pointOfContact>
    
	<!--  <xsl:for-each select="ct:General/ct:KeywordList/ct:Keyword[substring(.,1,8)='ISO19115']">
		<topicCategory>
			<MD_TopicCategoryCode>
				<xsl:value-of select="substring-after(.,':')"/>
			</MD_TopicCategoryCode>
		</topicCategory>			
	</xsl:for-each>-->
	
	<graphicOverview>
		<MD_BrowseGraphic>
			<fileName><xsl:value-of select="ct:General/ct:LogoURL/*/@xlink:href"/></fileName>
		</MD_BrowseGraphic>
	</graphicOverview>
	
    <serviceType>WMC</serviceType>
    <serviceTypeVersion><xsl:value-of select="@version"/></serviceTypeVersion>

	<couplingType>tight</couplingType>
	
	<xsl:for-each select="ct:LayerList/ct:Layer">
		<xsl:if test="ct:MetadataURL/ct:OnlineResource/@xlink:href!=''">
			<xsl:variable name="uuid">
				<xsl:value-of select="substring-after(ct:MetadataURL/ct:OnlineResource/@xlink:href,'&amp;id=')"/>
				<xsl:value-of select="substring-after(ct:MetadataURL/ct:OnlineResource/@xlink:href,'&amp;ID=')"/>
				<xsl:value-of select="substring-after(ct:MetadataURL/ct:OnlineResource/@xlink:href,'&amp;Id=')"/>
			</xsl:variable>
			<operatesOn>
				<href><xsl:value-of select="ct:MetadataURL/ct:OnlineResource/@xlink:href"/><xsl:if test="$uuid!=''">#_<xsl:value-of select="$uuid"/></xsl:if></href>
				<xsl:if test="$uuid!=''">
					<uuidref><xsl:value-of select="$uuid"/></uuidref>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="ct:Extension/hs:layer_title">
						<title><xsl:value-of select="ct:Extension/hs:layer_title"/></title>
					</xsl:when>	
					<xsl:otherwise>
						<title><xsl:value-of select="ct:Title"/></title>
					</xsl:otherwise>
				</xsl:choose>
			</operatesOn>
		</xsl:if>
	</xsl:for-each>
	
	<resourceConstraints>
		<MD_Constraints><useLimitation><xsl:value-of select="document('../dict/uselim.xml')/userValues/translation[@lang=$lang]/group/entry[@id=2]"/></useLimitation></MD_Constraints>
	</resourceConstraints>

	<resourceConstraints>
		<MD_LegalConstraints>
			<accessConstraints><MD_RestrictionCode>otherRestrictions</MD_RestrictionCode></accessConstraints>
			<otherConstraints>
				<xsl:value-of select="document('../dict/oconstraint.xml')/userValues/translation[@lang=$lang]/group/entry[@id=1]"/>
			</otherConstraints>
		</MD_LegalConstraints>
	</resourceConstraints>
	
    </SV_ServiceIdentification>
    </identificationInfo>
    

    <!-- distribuce -->
    <distributionInfo>
    <MD_Distribution>
      <transferOptions>
      <MD_DigitalTransferOptions>
        <onLine>
        <CI_OnlineResource>
          <linkage><xsl:value-of select="Capability/Request/GetCapabilities/DCPType/HTTP/Get/OnlineResource/@xlink:href"/></linkage>
          <protocol>WWW:DOWNLOAD-1.0-http--download</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>  
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

  	<!--referencni system-->
  	<xsl:for-each select="ct:General/ct:BoundingBox">
  	<referenceSystemInfo>
  	<MD_ReferenceSystem>
  	  <referenceSystemIdentifier>
  	  	<RS_Identifier>
  	  		<code><xsl:value-of select="substring-after(@SRS,':')"/></code>
  			<codeSpace>urn:ogc:def:crs:<xsl:value-of select="translate(substring-before(@SRS,':'),$lower,$upper)"/></codeSpace>
  		</RS_Identifier>
  	  </referenceSystemIdentifier>
  	</MD_ReferenceSystem>  
  	</referenceSystemInfo>	 
  	</xsl:for-each>
  	
  	<dataQualityInfo>
  		<DQ_DataQuality>
  			<scope><DQ_Scope><level>application</level></DQ_Scope></scope>
  			<lineage>
  				<LI_Lineage>
  					<statement>Generated from WMC file.</statement>
  				</LI_Lineage>
  			</lineage>
  		</DQ_DataQuality>
  	</dataQualityInfo> 
	
	<metadataStandardName>ISO 19115/19119</metadataStandardName>
    <metadataStandardVersion>2003/cor. 2006</metadataStandardVersion>
  	<hierarchyLevel>
  	  	<MD_ScopeCode>application</MD_ScopeCode>
  	</hierarchyLevel>
  	<hierarchyLevelName>MapContext</hierarchyLevelName>
  	<fileIdentifier><xsl:value-of select="@id"/></fileIdentifier>
    </MD_Metadata>
  </results>  

  </xsl:template>

</xsl:stylesheet>
