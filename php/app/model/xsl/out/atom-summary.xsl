<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:ows="http://www.opengis.net/ows"
  xmlns="http://www.w3.org/2005/Atom"
  xmlns:georss="http://www.georss.org/georss" 
  xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
>
<xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:variable name="msg" select="document(concat('../client/labels-',$LANGUAGE,'.xml'))/messages/msg"/>  

<!--xsl:template match="/ccc">
	<feed version="2.0" xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/">
	    <title><xsl:value-of select="$auth//ows:Title"/></title>
	    <subtitle><xsl:value-of select="$msg[@eng='AtomSubtitle']"/></subtitle>
	    <link href="" rel="via"/>
    	<openSearch:totalResults><xsl:value-of select="/results/@numberOfRecordsMatched"/></openSearch:totalResults>
    	<openSearch:startIndex><xsl:value-of select="results/@nextRecord - /results/@numberOfRecordsReturned - 1"/></openSearch:startIndex>
    	<openSearch:itemsPerPage><xsl:value-of select="/results/@numberOfRecordsReturned"/></openSearch:itemsPerPage>
	    <link rel="search" href="opensearch.php" type="application/opensearchdescription+xml" title="Open Search Description"/>
	    <author>
	    	<name><xsl:value-of select="$auth//ows:IndividualName"/></name>
	    	<email><xsl:value-of select="$auth//ows:ElectronicMailAddress"/></email>
	    </author>
	  	<xsl:for-each select="results">
	    	<xsl:apply-templates/>
	  	</xsl:for-each>
	</feed>
</xsl:template-->

<xsl:template match="gmd:MD_Metadata|rec/gmi:MI_Metadata"  
	xmlns:gmd="http://www.isotc211.org/2005/gmd"   
	xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
 	xmlns:gco="http://www.isotc211.org/2005/gco">
	<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"/>

    <entry>
    	<!--Spatial Data Set Unique Resource Identifier-->
		<inspire_dls:spatial_dataset_identifier_code><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/@xlink:href"/></inspire_dls:spatial_dataset_identifier_code>
    	<xsl:choose>
            <xsl:when test="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace">
                <inspire_dls:spatial_dataset_identifier_namespace><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace"/></inspire_dls:spatial_dataset_identifier_namespace>
            </xsl:when>
            <xsl:when test="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*">
                <inspire_dls:spatial_dataset_identifier_namespace><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*"/></inspire_dls:spatial_dataset_identifier_namespace>
            </xsl:when>
        </xsl:choose>

        <!-- SOURADNICOVE SYSTEMY -->
        <xsl:for-each select="gmd:referenceSystemInfo">
					<category term="{*/gmd:referenceSystemIdentifier/*/gmd:code/*/@xlink:href}" label="{*/gmd:referenceSystemIdentifier/*/gmd:code}"/>
        </xsl:for-each>
 
        <!-- author info -->
	  	<xsl:for-each select="gmd:contact">
		  	<author>
	        	<name><xsl:value-of select="*/gmd:organisationName/*"/></name>
	        	<email><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/></email>
	    	</author>
	  	</xsl:for-each>

        <!-- link itself -->
        <id><xsl:value-of select="concat($mickaURL, '/record/atom/', gmd:fileIdentifier)"/></id>

      	<!-- links to detail Atom description -->
      	<link rel="alternate" type="application/atom+xml" href="{$mickaURL}/record/atom/{gmd:fileIdentifier}"/>
      	
	  	<!-- links to ISO metadata and alternative representations -->
      	<link rel="describedby" type="application/xml" href="{$mickaURL}/record/xml/{gmd:fileIdentifier}"/>
      	
      	<!-- download link for pre-defined dataset -->
      	<xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage">
      		<link rel="alternate" href="{gmd:URL}" type="{../../../../../gmd:distributionFormat/*/gmd:name};{../../../../../gmd:distributionFormat/*/gmd:version}"/>
      	</xsl:for-each>

      	<!-- date/time of last update of feed
      	<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue!='publication']">
      		<published><xsl:value-of select="*/gmd:date"/>T00:00:00</published>
      	</xsl:for-each>-->

        <xsl:choose>
            <xsl:when test="gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*">
                <published><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*"/>T00:00:00</published>							
            </xsl:when>
            <xsl:when test="gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*">
                <published><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*"/>T00:00:00</published>							
            </xsl:when>
        </xsl:choose>

      	<!-- rights, access restrictions -->
      	<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints[*/useConstraints/*/@codeListValue='otherRestrictions']">
      		<rights><xsl:value-of select="./*"/></rights>
      	</xsl:for-each>
      	
     	<!-- descriptive summary -->
      	<summary type="html">
      		<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
      		<xsl:call-template name="multi">
	    		<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
	    		<xsl:with-param name="lang" select="$LANGUAGE"/>
	    		<xsl:with-param name="mdlang" select="$mdlang"/>
	  		</xsl:call-template>

	  		<xsl:if test="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*">
	  			<div><img src="{gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*}"/></div>
	  			<xsl:call-template name="multi">
	    			<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileDescription"/>
	    			<xsl:with-param name="lang" select="$LANGUAGE"/>
	    			<xsl:with-param name="mdlang" select="$mdlang"/>
	  			</xsl:call-template>
	  		</xsl:if>
            <div>Metadata:
                <a href="{$mickaURL}/record/basic/{gmd:fileIdentifier}" target="_blank">HTML</a><xsl:text> </xsl:text>
                <a href="{$mickaURL}/record/xml/{gmd:fileIdentifier}" title="ISO 19139" target="_blank">XML</a><xsl:text> </xsl:text>
                <a href="{$mickaURL}/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/ns/dcat%23&amp;id={gmd:fileIdentifier}" title="INSPIRE GeoDCAT-AP RDF/XML" target="_blank">GeoDCAT</a>
            </div>
	  		<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
	  	</summary>

    	<!-- title for pre-defined dataset -->
      	<title><xsl:call-template name="multi">
	    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
	    	<xsl:with-param name="lang" select="$LANGUAGE"/>
	    	<xsl:with-param name="mdlang" select="$mdlang"/>
	  	</xsl:call-template></title>
		
		<!-- identifier for pre-defined dataset 
      	<id><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/></id>-->
      	
	  	<!-- aktualizace -->
	  	<updated><xsl:value-of select="gmd:dateStamp"/>T00:00:00</updated>	
        <!-- optional GeoRSS bounding box of the pre-defined dataset. Must be lat lon -->	
        <xsl:for-each select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox">
      		<georss:polygon>
		      	<xsl:value-of select="gmd:southBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:westBoundLongitude"/>
		      	<xsl:text> </xsl:text>
		      	<xsl:value-of select="gmd:northBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:westBoundLongitude"/>
		      	<xsl:text> </xsl:text>
		      	<xsl:value-of select="gmd:northBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:eastBoundLongitude"/>
		      	<xsl:text> </xsl:text>
		      	<xsl:value-of select="gmd:southBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:eastBoundLongitude"/>
		      	<xsl:text> </xsl:text>
		      	<xsl:value-of select="gmd:southBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:westBoundLongitude"/>
	    	</georss:polygon>
	  </xsl:for-each>
	  
	  <!-- KLASIFIKACE -->
	  <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[contains(gmd:thesaurusName/*/gmd:title/*,'Feature')]/gmd:keyword">
	    	<category term="{*}"
            scheme="http://inspire-registry.jrc.ec.europa.eu/registers/FCD/"
            label="{gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale='#locale-eng']}" xml:lang="en"/>

      </xsl:for-each>

    </entry>
</xsl:template>

<xsl:template match="rec/csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
    <item>
      <title><xsl:value-of select="dc:title"/></title>
      <guid isPermaLink="false">urn:uuid:<xsl:value-of select="dc:identifier[1]"/></guid>
      <link>../reords/basic/<xsl:value-of select="dc:identifier[1]"/></link>
      <description><xsl:value-of select="dct:abstract"/></description>
      <pubDate><xsl:call-template name="formatDate">
          <xsl:with-param name="DateTime" select="dc:date"/>
        </xsl:call-template> 00:00:00 GMT</pubDate>
      <xsl:for-each select="ows:BoundingBox">
        <georss:polygon>
	      	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="substring-after(ows:UpperCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="substring-after(ows:UpperCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:UpperCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:UpperCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
        </georss:polygon>
      </xsl:for-each>
    </item>
</xsl:template>

<xsl:template match="rec/gfc:FC_FeatureCatalogue" xmlns:gfc="http://www.isotc211.org/2005/gfc">
</xsl:template>

<xsl:template name="formatDate">
	<xsl:param name="DateTime" />
	<!-- date format 1998-03-15[T13:00:00] -->

	<xsl:variable name="year">
		<xsl:value-of select="substring-before($DateTime,'-')" />
	</xsl:variable>
	<xsl:variable name="mo-temp">
		<xsl:value-of select="substring-after($DateTime,'-')" />
	</xsl:variable>
	<xsl:variable name="mo">
		<xsl:value-of select="substring-before($mo-temp,'-')" />
	</xsl:variable>
	<xsl:variable name="day-t">
		<xsl:value-of select="substring-after($mo-temp,'-')" />
	</xsl:variable>
	<xsl:variable name="day">
		<xsl:choose> 
		  <xsl:when test="substring-before($day-t,'T')!=''">
		  	<xsl:value-of select="substring-before($day-t,'T')" />
		  </xsl:when>
		  <xsl:otherwise>
		  	<xsl:value-of select="$day-t" />
		  </xsl:otherwise>
		</xsl:choose>  
	</xsl:variable>

	<xsl:if test="$day != '00'">
		<xsl:value-of select="$day"/>
		<xsl:value-of select="' '"/>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="$mo = '1' or $mo = '01'">Jan </xsl:when>
		<xsl:when test="$mo = '2' or $mo = '02'">Feb </xsl:when>
		<xsl:when test="$mo = '3' or $mo = '03'">Mar </xsl:when>
		<xsl:when test="$mo = '4' or $mo = '04'">Apr </xsl:when>
		<xsl:when test="$mo = '5' or $mo = '05'">May </xsl:when>
		<xsl:when test="$mo = '6' or $mo = '06'">Jun </xsl:when>
		<xsl:when test="$mo = '7' or $mo = '07'">Jul </xsl:when>
		<xsl:when test="$mo = '8' or $mo = '08'">Aug </xsl:when>
		<xsl:when test="$mo = '9' or $mo = '09'">Sep </xsl:when>
		<xsl:when test="$mo = '10'">Oct </xsl:when>
		<xsl:when test="$mo = '11'">Nov </xsl:when>
		<xsl:when test="$mo = '12'">Dec </xsl:when>
		<xsl:when test="$mo = '0' or $mo = '00'"></xsl:when><!-- do nothing -->
	</xsl:choose>
	<xsl:value-of select="$year"/>
</xsl:template> 

<xsl:include href="../client/common_cli.xsl" />
  
</xsl:stylesheet>
