<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>


<!-- CSW 2.0.2 -->
<xsl:template match="csw:Capabilities"  
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
  xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:ows="http://www.opengis.net/ows"
  xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
  xmlns:insp_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
  xmlns:inspire_ds="http://inspire.ec.europa.eu/schemas/inspire_ds/1.0" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:wms="http://www.opengis.net/wms"
  xmlns:gco="http://www.opengis.net/gco"
  xmlns:php="http://php.net/xsl">


 
<validationResult version="alpha 1" title="Validace - INSPIRE Discovery (CSW)">
<!-- identifikace -->

<!-- 1.2 -->
<test code="1.1" level="m">
	<description>Verze služby</description>
	<xpath>@version</xpath>  
  	<xsl:if test="@version='2.0.2'">
	    <value><xsl:value-of select="@version"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.2 -->
<test code="1.2" level="m">
	<description>Název služby</description>
	<xpath>ows:ServiceIdentification/ows:Title</xpath>  
  	<xsl:if test="string-length(normalize-space(ows:ServiceIdentification/ows:Title))>0">
	    <value><xsl:value-of select="ows:ServiceIdentification/ows:Title"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>


<!-- 1.3 -->
<test code="1.3" level="m">
	<description>Abstract služby</description>
	<xpath>Service/Abstract</xpath>  
    <xsl:if test="string-length(normalize-space(ows:ServiceIdentification/ows:Abstract))>0">
	   <value><xsl:value-of select="ows:ServiceIdentification/ows:Abstract"/></value>
	   <pass>true</pass>
	</xsl:if>
</test>


<!-- 1.3 -->
<test code="2" level="m">
	<description>Rozšíření INSPIRE</description>
	<xpath>inspire_ds:ExtendedCapabilities</xpath>  
    <xsl:if test="string-length(//inspire_ds:ExtendedCapabilities)>0">
	   <value>csw:Capabilities/ows:OperationsMetadata/inspire_ds:ExtendedCapabilities</value>
	   <pass>true</pass>

	<xsl:choose>
	  <!-- Jen odkaz na metadata -->
	  <xsl:when test="string-length(//insp_vs:ExtendedCapabilities/inspire_common:MetadataUrl)>0">
	    <test code="2.1.1" level="m">
	    	<description>Metadata URL</description>
	    	<xpath>Capability/inspire_vs:ExtendedCapabilities/inspire_common::MetadataUrl/inspire_common::URL</xpath>
	    	<xsl:if test="string-length(//insp_vs:ExtendedCapabilities/inspire_common:MetadataUrl/inspire_common:URL)>0">
	    	    <value><xsl:value-of select="//insp_vs:ExtendedCapabilities/inspire_common:MetadataUrl/inspire_common:URL"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	    <test code="2.1.2" level="m">
	    	<description>Výchozí jazyk</description>
	    	<xpath>Capability/inspire_vs:ExtendedCapabilities/inspire_common::SupportedLanguages/inspire_vs:DefaultLanguage/insp_common:Language</xpath>
	    	<xsl:if test="string-length(//insp_vs:ExtendedCapabilities/inspire_common:SupportedLanguages/inspire_common:DefaultLanguage/inspire_common:Language)>0">
	    	    <value><xsl:value-of select="//insp_vs:ExtendedCapabilities/inspire_common:SupportedLanguages/inspire_common:DefaultLanguage/inspire_common:Language"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	    <test code="2.1.3" level="m">
	    	<description>Jazyk odpovědi</description>
	    	<xpath>Capability/inspire_vs:ExtendedCapabilities/inspire_common::ResponseLanguage/insp_common:Language</xpath>
	    	<xsl:if test="string-length(//insp_vs:ExtendedCapabilities/inspire_common:ResponseLanguage/inspire_common:Language)>0">
	    	    <value><xsl:value-of select="//insp_vs:ExtendedCapabilities/inspire_common:ResponseLanguage/inspire_common:Language"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	  </xsl:when>
	
	  <!-- Vypsani metadat zde -->
	  <xsl:otherwise>
	
	    <test code="2.2.1" level="m">
	    	<description>Adresa služby</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::ResourceLocator/inspire_common::URL</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:ResourceLocator/inspire_common:URL)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:ResourceLocator/inspire_common:URL"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.2" level="m">
	    	<description>Typ zdroje</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::ResourceType</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:ResourceType)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:ResourceType"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.3" level="m">
	    	<description>Časové reference</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::TemporalReference</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:TemporalReference)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:TemporalReference"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.4" level="m">
	    	<description>Stupeň souladu</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::Conformity</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:Conformity)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:Conformity"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.5" level="m">
	    	<description>Kontaktní místo</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::MetadataPointOfContact</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:MetadataPointOfContact)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:MetadataPointOfContact"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.6" level="m">
	    	<description>Datum metadat</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::MetadataDate</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:MetadataDate)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:MetadataDate"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.7" level="m">
	    	<description>Typ služby</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::SpatialDataServiceType</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:SpatialDataServiceType)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:SpatialDataServiceType"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.8" level="m">
	    	<description>Povinné klíčové slovo</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::MandatoryKeyword</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:MandatoryKeyword)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:MandatoryKeyword"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.9" level="m">
	    	<description>Výchozí jazyk Metadat</description>
	    	<xpath>Capability/inspire_ds::ExtendedCapabilities/inspire_common::SupportedLanguages/inspire_common::DefaultLanguage/insp_common:Language</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:SupportedLanguages/inspire_common:DefaultLanguage/inspire_common:Language)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:SupportedLanguages/inspire_common:DefaultLanguage/inspire_common:Language"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	
	    <test code="2.2.10" level="m">
	    	<description>Vrácený jazyk Metadat</description>
	    	<xpath>Capability/inspire_ds:ExtendedCapabilities/inspire_common::ResponseLanguage/inspire_common::Language</xpath>
	    	<xsl:if test="string-length(//inspire_ds:ExtendedCapabilities/inspire_common:ResponseLanguage/inspire_common:Language)>0">
	    	    <value><xsl:value-of select="//inspire_ds:ExtendedCapabilities/inspire_common:ResponseLanguage/inspire_common:Language"/></value>
	    	    <pass>true</pass>
	    	</xsl:if>
	    </test>
	  	</xsl:otherwise>
		</xsl:choose>
	  </xsl:if>
  </test>

    <test code="3" level="m">
    	<description>Aplikační profil ISO</description>
    	<xpath>ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:Parameter[@name='outputSchema']/ows:Value[.='http://www.isotc211.org/2005/gmd']</xpath>  
      	<xsl:if test="string-length(normalize-space(ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:Parameter[@name='outputSchema']/ows:Value[.='http://www.isotc211.org/2005/gmd']))>0">
    	    <value><xsl:value-of select="ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:Parameter[@name='outputSchema']/ows:Value[.='http://www.isotc211.org/2005/gmd']"/></value>
    	    <pass>true</pass>
    	</xsl:if>
    </test>      

    <test code="3" level="m">
    	<description>Rozšířené dotazy INSPIRE</description>
    	<xpath>ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:Constraint[@name='AdditionalQueryables']</xpath>  
      	<xsl:if test="string-length(normalize-space(ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:Constraint[@name='AdditionalQueryables']))>0">
    	    <value>AdditionalQueryables</value>
    	    <pass>true</pass>

            <test code="3" level="m">
            	<description>Degree</description>
            	<xpath>ows:Value['Degree']</xpath>  
              	<xsl:if test="string-length(normalize-space(//ows:Constraint[@name='AdditionalQueryables']/ows:Value[.='Degree']))>0">
            	    <value><xsl:value-of select="//ows:Constraint[@name='AdditionalQueryables']/ows:Value[.='Degree']"/></value>
            	    <pass>true</pass>
            	</xsl:if>
            </test>      

    	</xsl:if>
    </test>      

</validationResult>

</xsl:template>




</xsl:stylesheet>
