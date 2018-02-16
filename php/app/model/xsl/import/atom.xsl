<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:gco="http://www.opengis.net/gco"
    xmlns:ows="http://www.opengis.net/ows/1.1"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:kml="http://www.opengis.net/kml"
    xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
    xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
    xmlns:ext="http://exslt.org/common" exclude-result-prefixes="ext"
  
    xmlns:atom="http://www.w3.org/2005/Atom" 
    xmlns:georss="http://www.georss.org/georss" 
    xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0" 
    xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/"
  >
  
  <xsl:output method="xml" encoding="utf-8"/>

<!-- GLOBAL VARIABLES -->
  <xsl:variable name="codeLists" select="document('../codelists.xml')/map" />
  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="atom:feed">
  
  <xsl:variable name="l2" select="@xml:lang"/>
  <xsl:variable name="mdlang" select="$codeLists/language/value[@code2=$l2]/@name"/>
  
  <results>
    
    <MD_Metadata>
    
    <!--referenceSystemInfo>
    	<MD_ReferenceSystem>
    		<referenceSystemIdentifier>
    			<RS_Identifier>
    				<code>http://www.opengis.net/def/crs/EPSG/0/4326</code>
    			</RS_Identifier>
    		</referenceSystemIdentifier>
    	</MD_ReferenceSystem>
    </referenceSystemInfo-->
  	<hierarchyLevel>
  	  <MD_ScopeCode>service</MD_ScopeCode>
  	</hierarchyLevel>
    <language>
        <LanguageCode codeListValue="{$mdlang}"/>
    </language>

    
    <identificationInfo>
    <SV_ServiceIdentification>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="atom:title"/></title>
      <date>
      	<CI_Date>
      		<date><xsl:value-of select="substring-before(atom:updated/@updateSequence,'T')"/></date>
      		<dateType><CI_DateTypeCode>revision</CI_DateTypeCode></dateType>
      	</CI_Date>
      </date>
    </CI_Citation>  
    </citation>
    <abstract><xsl:value-of select="atom:subtitle"/></abstract>
    <characterSet>
    	<MD_CharacterSetCode>UTF-8</MD_CharacterSetCode>
    </characterSet>
    <serviceType>download</serviceType>
    <descriptiveKeywords>
      <MD_Keywords>
        <keyword>
            <Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoFeatureAccessService">infoFeatureAccessService</Anchor>
        </keyword>
      <thesaurusName>
        <CI_Citation>
            <title>ISO - 19119 geographic services taxonomy</title>
            <date><CI_Date><date><Date>2010-01-19</Date></date><dateType><CI_DateTypeCode codeListValue="publication">publication</CI_DateTypeCode></dateType></CI_Date></date>
            </CI_Citation>
         </thesaurusName>
       </MD_Keywords>
   </descriptiveKeywords>
    <pointOfContact>
      <CI_ResponsibleParty>
	    <!--individualName><xsl:value-of select="atom:author"/></individualName-->
	    <organisationName><xsl:value-of select="atom:author/atom:name"/></organisationName>
	    <!--positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></positionName-->
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
		        <electronicMailAddress><xsl:value-of select="atom:author/atom:email"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="atom:author/atom:uri"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode>custodian</CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </pointOfContact>


    <extent>
        <!-- prasarna - vezme prvni, kterou najde  
        <EX_Extent>
	      <geographicElement>
	        <EX_BoundingPolygon>
                <polygon>
                    <Polygon gml:id="poly1">
                        <exterior>
                            <LinearRing>
                                <posList><xsl:value-of select="atom:entry/georss:polygon"/></posList>
                            </LinearRing>
                        </exterior>
                    </Polygon>
                </polygon>
	        </EX_BoundingPolygon>
	      </geographicElement>
	
	      <temporalElement>
	      	<EX_TemporalExtent>
	      		<extent>
	      			<TimePeriod>
	      				<beginPosition><xsl:value-of select="tmin"/></beginPosition>
	      				<endPosition><xsl:value-of select="tmax"/></endPosition>
	      			</TimePeriod>
	      		</extent>
	      	</EX_TemporalExtent>
	      </temporalElement>
	    </EX_Extent>  -->
    </extent>
	</SV_ServiceIdentification>
 	</identificationInfo>  	
    

    <!-- distribuce -->
    <distributionInfo>
    <MD_Distribution>
      <transferOptions>
      <MD_DigitalTransferOptions>
        <onLine>
        <CI_OnlineResource>
          <linkage><xsl:value-of select="atom:link[@rel='self']/@href"/></linkage>
          <protocol>
            <Anchor xlink:href="WWW:LINK-1.0-http--atom">ATOM</Anchor>
            </protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>      
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

	
    <metadataStandardName>ISO 19119/INSPIRE_TG2/CZ4</metadataStandardName>
    <metadataStandardVersion>2003/cor.1/2006</metadataStandardVersion>

  	
    </MD_Metadata>
 
  
  </results>  
    
  </xsl:template>

  
  <!-- rozdeleni retezce podle mezer -->
  <xsl:template match="text()" name="split">
  <xsl:param name="s" select="."/>
   <xsl:if test="string-length($s) >0">
    <item>
     <xsl:value-of select="substring-before(concat($s, ' '), ' ')"/>
    </item>

    <xsl:call-template name="split">
     <xsl:with-param name="s" select="substring-after($s, ' ')"/>
    </xsl:call-template>
   </xsl:if>
 </xsl:template>
  
</xsl:stylesheet>