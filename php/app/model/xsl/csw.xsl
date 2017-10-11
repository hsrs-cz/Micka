<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:ogc="http://www.opengis.net/ogc" 
    xmlns:ows="http://www.opengis.net/ows"
    xmlns:gco="http://www.opengis.net/gco"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0"
    xmlns:inspire_ds="http://inspire.ec.europa.eu/schemas/inspire_ds/1.0" 
    xmlns:inspire_com="http://inspire.ec.europa.eu/schemas/common/1.0"
	xmlns:csw="http://www.opengis.net/cat/csw/2.0.2">
  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<xsl:template match="/">
<results>
    
    <gmd:MD_Metadata>
    <gmd:identificationInfo>
    <srv:SV_ServiceIdentification>
    <gmd:serviceType>
        <gco:LocalName codeSpace="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType">discovery</gco:LocalName>
    </gmd:serviceType>
    <gmd:serviceTypeVersion><xsl:value-of select="*/@version"/></gmd:serviceTypeVersion>
    <gmd:citation>
    <gmd:CI_Citation>
        <gmd:title><xsl:value-of select="*/ows:ServiceIdentification/ows:Title"/></gmd:title>
        <gmd:date>
            <gmd:CI_Date>
                <gmd:date>
                    <gco:Date><xsl:value-of select="//inspire_com:MetadataDate"/></gco:Date>
                </gmd:date>
                <gmd:dateType>
                    <gmd:CI_DateTypeCode codeListValue="publication" codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode">publication</gmd:CI_DateTypeCode>
                </gmd:dateType>
            </gmd:CI_Date>
        </gmd:date>
    </gmd:CI_Citation>  
    </gmd:citation>
    <gmd:abstract><xsl:value-of select="*/ows:ServiceIdentification/ows:Abstract"/></gmd:abstract>
    <gmd:accessProperties>
    	<gmd:MD_StandardOrderProcess>
    		<gmd:fees> 
    			<xsl:value-of select="*/ows:ServiceIdentification/ows:Fees"/>
    	  </gmd:fees>
    	</gmd:MD_StandardOrderProcess> 
    </gmd:accessProperties>
    <gmd:descriptiveKeywords>
      <gmd:MD_Keywords>
      <xsl:for-each select="*/ows:ServiceIdentification/ows:Keywords/ows:Keyword">
        <gmd:keyword><xsl:value-of select="."/></gmd:keyword>
      </xsl:for-each>
      </gmd:MD_Keywords>
    </gmd:descriptiveKeywords>
    <gmd:descriptiveKeywords>
      <gmd:MD_Keywords>
        <gmd:keyword>
            <gmx:Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoCatalogueService">infoCatalogueService</gmx:Anchor>
        </gmd:keyword>
      	<gmd:thesaurusName>
		  <gmd:CI_Citation>
			<gmd:title>ISO 19119 geographic services taxonomy</gmd:title>
			<gmd:date>
			  <gmd:CI_Date>
				<gmd:date>2008</gmd:date>
				<gmd:dateType>
  				  <gmd:CI_DateTypeCode>publication</gmd:CI_DateTypeCode> 
  				</gmd:dateType>
  			  </gmd:CI_Date>
      		</gmd:date>
      	  </gmd:CI_Citation>
        </gmd:thesaurusName>
      </gmd:MD_Keywords>
    </gmd:descriptiveKeywords>
    <gmd:pointOfContact>
      <gmd:CI_ResponsibleParty>
	    <gmd:individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></gmd:individualName>
	    <gmd:organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></gmd:organisationName>
	    <gmd:positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></gmd:positionName>
	    <gmd:contactInfo>
	    <gmd:CI_Contact>
	      <gmd:phone>
	      	<gmd:CI_Telephone>
	          <gmd:voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></gmd:voice>
	        </gmd:CI_Telephone>
	      </gmd:phone>
		    <gmd:address>
		      <gmd:CI_Address>
		        <gmd:deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></gmd:deliveryPoint>
		        <gmd:city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></gmd:city>
		        <gmd:postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></gmd:postalCode>
		        <gmd:country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></gmd:country>
		        <gmd:electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></gmd:electronicMailAddress>
		      </gmd:CI_Address>
		    </gmd:address>
		    <gmd:onlineResource>
		    	<gmd:CI_OnlineResource>
		    		<gmd:linkage>
		    			<gmd:URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></gmd:URL>
		    		</gmd:linkage>
		    	</gmd:CI_OnlineResource>
		    </gmd:onlineResource>
	      </gmd:CI_Contact>
	    </gmd:contactInfo>
	    <gmd:role>
	    	<gmd:CI_RoleCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:Role"/></gmd:CI_RoleCode> 
	    </gmd:role>
      </gmd:CI_ResponsibleParty>
    </gmd:pointOfContact>

        <!-- Omezeni -->       
        <gmd:resourceConstraints>
            <gmd:MD_LegalConstraints>
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
                </gmd:useConstraints>
                <gmd:otherConstraints><xsl:value-of select="*/ows:ServiceIdentification/ows:Fees"/></gmd:otherConstraints>
            </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
        
        <gmd:resourceConstraints>
            <gmd:MD_LegalConstraints>
                <gmd:accessConstraints>
                    <gmd:MD_RestrictionCode codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
                </gmd:accessConstraints>
                <gmd:otherConstraints><xsl:value-of select="*/ows:ServiceIdentification/ows:AccessConstraints"/></gmd:otherConstraints>
            </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>

    <!-- operace -->
    <xsl:for-each select="*/ows:OperationsMetadata/ows:Operation">
      <srv:containsOperations>
        <srv:SV_OperationMetadata>
          <srv:operationName><xsl:value-of select="@name"/></srv:operationName>
          <xsl:for-each select="ows:DCP/ows:HTTP/*">
            <srv:connectPoint>
              <gmd:CI_OnlineResource>
              	<gmd:linkage>
                    <gmd:URL><xsl:value-of select="@xlink:href"/></gmd:URL>
                </gmd:linkage>
              	<xsl:choose>
              		<xsl:when test="substring-after(translate(../../../@name,$upper,$lower),'get')!=''">
              			<gmd:protocol>OGC:CSW-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="substring(translate(../../../@name,$upper,$lower),4)"/></gmd:protocol>
              		</xsl:when>
              		<xsl:otherwise>
               			<gmd:protocol>OGC:CSW-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="translate(../../../@name,$upper,$lower)"/></gmd:protocol>
              		</xsl:otherwise>
              	</xsl:choose>		
              </gmd:CI_OnlineResource>
            </srv:connectPoint>
          </xsl:for-each>
          <srv:DCP><srv:DCPList codeListValue="WebServices"/></srv:DCP>
        </srv:SV_OperationMetadata>
      </srv:containsOperations>
    </xsl:for-each>
    
    <srv:couplingType>
        <srv:SV_CouplingType codeListValue="loose">loose</srv:SV_CouplingType>
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
                                <gmd:URL><xsl:value-of select="*/ows:OperationsMetadata/ows:Operation[@name='GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/>?SERVICE=CSW&amp;REQUEST=GetCapabilities</gmd:URL>
                            </gmd:linkage>
                            <gmd:protocol>
                                <gmx:Anchor xlink:href="http://services.cuzk.cz/registry/codelist/OnlineResourceProtocolValue/OGC:CSW-{*/@version}-http-get-capabilities">OGC:CSW-<xsl:value-of select="*/@version"/>-http-get-capabilities</gmx:Anchor>
                            </gmd:protocol>
                            <gmd:function>
                                <gmd:CI_OnLineFunctionCode codeListValue="download">download</gmd:CI_OnLineFunctionCode>
                            </gmd:function>
                        </gmd:CI_OnlineResource>      
                    </gmd:onLine>
                </gmd:MD_DigitalTransferOptions>  
            </gmd:transferOptions>
        </gmd:MD_Distribution>
    </gmd:distributionInfo>

	
    <gmd:metadataStandardName>ISO 19115/INSPIRE_TG2/CZ4</gmd:metadataStandardName>
    <gmd:metadataStandardVersion>2003/cor.1/2006</gmd:metadataStandardVersion>
  	<gmd:hierarchyLevel>
  	  <gmd:MD_ScopeCode codeListValue="service">service</gmd:MD_ScopeCode>
  	</gmd:hierarchyLevel>
  	<gmd:contact>
      <gmd:CI_ResponsibleParty>
	    <gmd:individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></gmd:individualName>
	    <gmd:organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></gmd:organisationName>
	    <gmd:positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></gmd:positionName>
	    <gmd:contactInfo>
	    <gmd:CI_Contact>
	      <gmd:phone>
	      	<gmd:CI_Telephone>
	          <gmd:voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></gmd:voice>
	        </gmd:CI_Telephone>
	      </gmd:phone>
		    <gmd:address>
		      <gmd:CI_Address>
		        <gmd:deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></gmd:deliveryPoint>
		        <gmd:city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></gmd:city>
		        <gmd:postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></gmd:postalCode>
		        <gmd:country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></gmd:country>
		        <gmd:electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></gmd:electronicMailAddress>
		      </gmd:CI_Address>
		    </gmd:address>
		    <gmd:onlineResource>
		    	<gmd:CI_OnlineResource>
		    		<gmd:linkage>
		    			<gmd:URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></gmd:URL>
		    		</gmd:linkage>
		    	</gmd:CI_OnlineResource>
		    </gmd:onlineResource>
	      </gmd:CI_Contact>
	    </gmd:contactInfo>
	    <gmd:role>
	    	<gmd:CI_RoleCode codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode> 
	    </gmd:role>
      </gmd:CI_ResponsibleParty>
    </gmd:contact>
    </gmd:MD_Metadata>

</results>  
    
</xsl:template>


</xsl:stylesheet>
