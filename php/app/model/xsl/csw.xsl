<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:ogc="http://www.opengis.net/ogc" 
    xmlns:ows="http://www.opengis.net/ows"
    xmlns:gco="http://www.opengis.net/gco"
	xmlns:csw="http://www.opengis.net/cat/csw/2.0.2">
  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
  <results>
    
    <MD_Metadata>
    <identificationInfo>
    <SV_ServiceIdentification>
    <serviceType>
      <gco:LocalName>CSW</gco:LocalName>
      <!-- <nameNameSpace>OGC</nameNameSpace> -->
    </serviceType>
    <serviceTypeVersion><xsl:value-of select="*/@version"/></serviceTypeVersion>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="*/ows:ServiceIdentification/ows:Title"/></title>
    </CI_Citation>  
    </citation>
    <abstract> <xsl:value-of select="*/ows:ServiceIdentification/ows:Abstract"/> </abstract>
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees> 
    			<xsl:value-of select="*/ows:ServiceIdentification/ows:Fees"/>
    	  </fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="*/ows:ServiceIdentification/ows:Keywords/ows:Keyword">
        <keyword> <xsl:value-of select="."/> </keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <descriptiveKeywords>
      <MD_Keywords>
        <keyword>infoCatalogueService</keyword>
      	<thesaurusName>
		  <CI_Citation>
			<title>ISO 19119 geographic services taxonomy</title>
			<date>
			  <CI_Date>
				<date>2008</date>
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
	    <individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:Role"/></CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </pointOfContact>


    <!-- operace -->
    <xsl:for-each select="*/ows:OperationsMetadata/ows:Operation">
      <containsOperations>
        <SV_OperationMetadata>
          <operationName><xsl:value-of select="@name"/></operationName>
          <xsl:for-each select="ows:DCP/ows:HTTP/*">
            <connectPoint>
              <CI_OnlineResource>
              	<linkage> <xsl:value-of select="@xlink:href"/> </linkage>
              	<xsl:choose>
              		<xsl:when test="substring-after(translate(../../../@name,$upper,$lower),'get')!=''">
              			<protocol>OGC:CSW-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="substring(translate(../../../@name,$upper,$lower),4)"/></protocol>
              		</xsl:when>
              		<xsl:otherwise>
               			<protocol>OGC:CSW-<xsl:value-of select="//@version"/>-http-<xsl:value-of select="translate(substring-after(name(),':'),$upper,$lower)" />-<xsl:value-of select="translate(../../../@name,$upper,$lower)"/></protocol>             		
              		</xsl:otherwise>
              	</xsl:choose>		
              </CI_OnlineResource>
            </connectPoint>
          </xsl:for-each>
          <DCP>WebServices</DCP>
        </SV_OperationMetadata>
      </containsOperations>
    </xsl:for-each>
    
    <couplingType>
      <SV_CouplingType>loose</SV_CouplingType>
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
          <linkage><xsl:value-of select="*/ows:OperationsMetadata/ows:Operation[@name='GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/>?SERVICE=CSW&amp;REQUEST=GetCapabilities</linkage>
          <protocol>OGC:CSW-<xsl:value-of select="*/@version"/>-http-get-capabilities</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>      
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

	
    <metadataStandardName>ISO 19119</metadataStandardName>
    <metadataStandardVersion>2005</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
  	<contact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode>pointOfContact</CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </contact>
  	
  	
    </MD_Metadata>
 
  
  </results>  
    
  </xsl:template>


</xsl:stylesheet>
