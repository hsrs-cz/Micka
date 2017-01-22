<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"	 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:dcl="http://dclite4g.xmlns.com/schema.rdf#" 
	xmlns:dcat="http://www.w3.org/ns/dcat#"
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"  
	xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gml="http://www.opengis.net/gml/3.2"   
	
	>
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:variable name="cl" select="document(concat('codelists_', $lang, '.xml'))/map"/>


<xsl:template match="/">

   <rdf:RDF> 
		<rdf:Description rdf:about="{$thisPath}/opensearch.php"> 
			<os:totalResults><xsl:value-of select="results/@numberOfRecordsMatched"/></os:totalResults> 
			<os:startIndex>1</os:startIndex> 
			<os:itemsPerPage><xsl:value-of select="results/@numberOfRecordsReturned"/></os:itemsPerPage> 
		</rdf:Description> 
      
      	<xsl:for-each select="results">
         	<xsl:apply-templates/>
      	</xsl:for-each>

    </rdf:RDF>
</xsl:template>
   
<xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata"   
xmlns:gmi="http://www.isotc211.org/2005/gmi" >
 	<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"/>

    <rdf:Description rdf:about="{$thisPath}/../micka_main.php?ak=detail&amp;uuid={gmd:fileIdentifier}"> 
      <!-- nove -->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:language">
          <dct:language rdf:resource="http://publications.europa.eu/resource/authority/language/{.}"/>
      </xsl:for-each>
      
		<xsl:call-template name="rmulti">
   			<xsl:with-param name="l" select="$mdlang"/>
   			<xsl:with-param name="e" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
   			<xsl:with-param name="n" select="'dc:title'"/>
   		</xsl:call-template>

		<xsl:call-template name="rmulti">
   			<xsl:with-param name="l" select="$mdlang"/>
   			<xsl:with-param name="e" select="gmd:identificationInfo/*/gmd:abstract"/>
   			<xsl:with-param name="n" select="'dct:description'"/>
   		</xsl:call-template>

	  	<!-- Resource type -->
	  	<xsl:choose>
			<!-- Service Type - not stable -->
			<xsl:when test="gmd:hierarchyLevel/*/@codeListValue='service'">
				<rdf:type rdf:resource="http://inspire.ec.europa.eu/codelist/SpatialDataServiceType/{gmd:identificationInfo/*/srv:serviceType}"/>
			</xsl:when>
	  		<xsl:otherwise>
		  		<rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
		  		<dct:type rdf:resource="http://inspire.ec.europa.eu/codelist/resource-type/{gmd:hierarchyLevel/*/@codeListValue}"/>
		  	</xsl:otherwise>
		</xsl:choose>		    	   
      <dct:spatial>
        <dct:Location>
			<locn:geometry rdf:datatype="http://www.opengis.net/rdf#GMLLiteral">
				<gml:Envelope srsName="http://www.opengis.net/def/crs/OGC/1.3/CRS84">
					<gml:lowerCorner><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude"/></gml:lowerCorner>
					<gml:upperCorner><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude"/></gml:upperCorner>
				</gml:Envelope>
			</locn:geometry>
			<!-- <rdfs:seeAlso rdf:resource="http://sws.geonames.org/3067695/"/> -->				
		</dct:Location>
      </dct:spatial>
      
	  <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
	  	<xsl:choose>
	  		<xsl:when test="*/gmd:dateType/*/@codeListValue='creation'"><dct:created rdf:datatype="http://www.w3.org/2001/XMLSchema-datatypes#date"><xsl:value-of select="*/gmd:date"/></dct:created></xsl:when>
	  		<xsl:when test="*/gmd:dateType/*/@codeListValue='publication'"><dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema-datatypes#date"><xsl:value-of select="*/gmd:date"/></dct:issued></xsl:when>
	  		<xsl:when test="*/gmd:dateType/*/@codeListValue='revision'"><dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema-datatypes#date"><xsl:value-of select="*/gmd:date"/></dct:modified></xsl:when>
	  	</xsl:choose>
	  </xsl:for-each>
	  
	  <xsl:for-each select="gmd:identificationInfo/*/gmd:temporalElement">
	  	<dct:temporal><xsl:value-of select="*/gmd:extent"/></dct:temporal>
	  </xsl:for-each>

      <!-- Topic category -->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
      	<dct:subject rdf:resource="http://inspire.ec.europa.eu/codelist/topic-category/{.}"/>
      </xsl:for-each>	
      
      <!-- INSPIRE temata - URI -->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title, 'INSPIRE')]/*/gmd:keyword">
      		<xsl:variable name="kwName">
      			<xsl:choose>
      				<xsl:when test="$mdlang='eng'"><xsl:value-of select="gco:CharacterString"/></xsl:when>
      				<xsl:otherwise><xsl:value-of select="gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale='#locale-eng']"/></xsl:otherwise>
      			</xsl:choose>
      		</xsl:variable>
      		<dct:subject rdf:resource="{$cl/inspireKeywords/value[@code=string($kwName)]/@uri}"/>
      </xsl:for-each>	
      
      <!-- Lineage -->
	  <dct:provenance>
		<dct:ProvenanceStatement>
      		<xsl:call-template name="rmulti">
   				<xsl:with-param name="l" select="$mdlang"/>
   				<xsl:with-param name="e" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
   				<xsl:with-param name="n" select="'rdfs:label'"/>
   			</xsl:call-template>     		
      	</dct:ProvenanceStatement>
      </dct:provenance>

	<!-- Conditions for access and use -->
	<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints[string-length(*/gmd:useLimitation/*)>0]">
		<dcat:distribution>
			<dcat:Distribution>
				<dct:rights>
					<dct:RightsStatement>
			     		<xsl:call-template name="rmulti">
			   				<xsl:with-param name="l" select="$mdlang"/>
			   				<xsl:with-param name="e" select="*/gmd:useLimitation"/>
			   				<xsl:with-param name="n" select="'rdfs:label'"/>
			   			</xsl:call-template>
					</dct:RightsStatement>
				</dct:rights>
			</dcat:Distribution>
		</dcat:distribution>
	</xsl:for-each>
	
	<!-- Limitations on public access -->
	<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints[string-length(*/gmd:otherConstraints/*)>0]">
		<dct:accessRights>
			<dct:RightsStatement>
			    <xsl:call-template name="rmulti">
			   		<xsl:with-param name="l" select="$mdlang"/>
			   		<xsl:with-param name="e" select="*/gmd:otherConstraints"/>
			   		<xsl:with-param name="n" select="'rdfs:label'"/>
			   	</xsl:call-template>
			</dct:RightsStatement>
		</dct:accessRights>
	</xsl:for-each>
							      
      <!-- stare  
      <dc:identifier><xsl:value-of select="gmd:fileIdentifier"/></dc:identifier>        
      <xsl:for-each select="gmd:MD_Distribution/gmd:transferOptions">
        <dc:identifier><xsl:value-of select="gmd:onLine/gmd:linkage"/></dc:identifier>
	    </xsl:for-each>
      <dc:title><xsl:call-template name="multi">
	    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
	    	<xsl:with-param name="lang" select="$lang"/>
	    	<xsl:with-param name="mdlang" select="$mdlang"/>
	  	</xsl:call-template></dc:title> 
        <dct:abstract><xsl:call-template name="multi">
	    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
	    	<xsl:with-param name="lang" select="$lang"/>
	    	<xsl:with-param name="mdlang" select="$mdlang"/>
	  	</xsl:call-template></dct:abstract>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords">
        <xsl:for-each select="gmd:keyword">
           <dc:subject><xsl:value-of select="."/></dc:subject>
        </xsl:for-each>
      </xsl:for-each> -->
      
      <!--<xsl:for-each select="identificationInfo/*/topicCategory">
        <iso19115TopicCategory><xsl:value-of select="MD_TopicCategoryCode"/></iso19115TopicCategory>
      </xsl:for-each>-->
      
      <!-- <xsl:for-each select="gmd:distributionInfo/gmd:distributor/gmd:distributorFormat">
        <dc:format> <xsl:value-of select="gmd:distributionInfo/gmd:distributor/gmd:distributorFormat/gmd:name"/> </dc:format>
      </xsl:for-each>  -->
      <!--<xsl:for-each select="identificationInfo/*/citation/date">
        <xsl:if test="dateType/CI_DateTypeCode_CodeList='revision'">
          <dct:modified><xsl:value-of select="date"/></dct:modified>
        </xsl:if>
      </xsl:for-each>-->
      <!-- <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
	       <xsl:choose>
          	<xsl:when test="gmd:role/gmd:CI_RoleCode_CodeList='originator'">
            	<dc:creator> <xsl:value-of select="gmd:organisationName"/> </dc:creator>
          	</xsl:when>
          	<xsl:when test="gmd:role/gmd:CI_RoleCode_CodeList='publisher'">
            	<dc:publisher> <xsl:value-of select="organisationName"/> </dc:publisher>
          	</xsl:when>
         	  <xsl:when test="gmd:role/gmd:CI_RoleCode_CodeList='author'">
            	<dc:contributor> <xsl:value-of select="organisationName"/> </dc:contributor>
          	</xsl:when>
         	  <xsl:when test="gmd:role/gmd:CI_RoleCode_CodeList='contributor'">
            	<dc:contributor> <xsl:value-of select="organisationName"/> </dc:contributor>
          	</xsl:when>
	          <xsl:otherwise>
              <dc:publisher> <xsl:value-of select="gmd:organisationName"/> </dc:publisher>
	          </xsl:otherwise>
	        </xsl:choose>
      </xsl:for-each> 
	        
      <dc:date><xsl:value-of select="gmd:dateStamp"/></dc:date>
      <dc:type><xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/></dc:type>
      
      <xsl:for-each select="gmd:distributionInfo//gmd:distributionFormat/*/gmd:name">
        <dc:format><xsl:value-of select="."/></dc:format>
      </xsl:for-each>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:language">
        <dc:language><xsl:value-of select="."/></dc:language>
      </xsl:for-each>

      <xsl:for-each select="gmd:distributionInfo//gmd:transferOptions">
        <dc:source><xsl:value-of select="*/onLine/*/linkage"/></dc:source>
	    </xsl:for-each>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">
        <dc:rights><xsl:value-of select="gmd:MD_RestrictionCode"/></dc:rights>
	    </xsl:for-each>

      <dct:spatial>
        <Box projection="EPSG:4326" name="Geographic">
          <northlimit><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude"/></northlimit>
          <eastlimit><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude"/></eastlimit>
          <southlimit><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude"/></southlimit>
          <westlimit><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude"/></westlimit>
        </Box>
      </dct:spatial>-->

	  </rdf:Description>
	</xsl:template>
			
			<!-- zpracovani DC -->
<!-- 	<xsl:template match="metadata" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
      <csw:Record xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">         
		  <dc:identifier><xsl:value-of select="@uuid"/></dc:identifier>
		  <dc:identifier><xsl:value-of select="identifier"/></dc:identifier>
			<xsl:for-each select="title">
				<dc:title lang="{@lang}"><xsl:value-of select="."/></dc:title>	
			</xsl:for-each>
			<xsl:for-each select="description">
				<dct:abstract lang="{@lang}"><xsl:value-of select="."/></dct:abstract>
			</xsl:for-each>
			<xsl:for-each select="subject">
				<dc:subject lang="{@lang}"><xsl:value-of select="."/></dc:subject>
			</xsl:for-each>
			<xsl:for-each select="format">
				<dc:format><xsl:value-of select="."/></dc:format>
			</xsl:for-each>
			<xsl:for-each select="date">
				<dc:date><xsl:value-of select="."/></dc:date>
			</xsl:for-each>
			<xsl:for-each select="creator">
				<dc:creator><xsl:value-of select="."/></dc:creator>
			</xsl:for-each>
			<xsl:for-each select="publisher">
				<dc:publisher><xsl:value-of select="."/></dc:publisher>
			</xsl:for-each>
			<xsl:for-each select="contributor">
				<dc:contributor><xsl:value-of select="."/></dc:contributor>
			</xsl:for-each>
			<xsl:for-each select="source">
				<dc:source><xsl:value-of select="."/></dc:source>
			</xsl:for-each>
			<xsl:for-each select="relation">
				<dc:relation><xsl:value-of select="."/></dc:relation>
			</xsl:for-each>
			<xsl:for-each select="rights">
				<dc:rights><xsl:value-of select="."/></dc:rights>
			</xsl:for-each>
			<xsl:for-each select="type">
				<dc:type><xsl:value-of select="."/></dc:type>
			</xsl:for-each>
			<xsl:if test="string-length(@x1)>0">
			  <ows:BoundingBox>
	        	<ows:LowerCorner><xsl:value-of select="@x1"/><xsl:text> </xsl:text><xsl:value-of select="@y1"/></ows:LowerCorner>
	        	<ows:UpperCorner><xsl:value-of select="@x2"/><xsl:text> </xsl:text><xsl:value-of select="@y2"/></ows:UpperCorner>
        	</ows:BoundingBox>
        <dct:spatial>
          <Box projection="EPSG:4326" name="Geographic">
            <northlimit><xsl:value-of select="@y2"/></northlimit>
            <eastlimit><xsl:value-of select="@x2"/></eastlimit>
            <southlimit><xsl:value-of select="@y1"/></southlimit>
            <westlimit><xsl:value-of select="@x1"/></westlimit>
          </Box>
        </dct:spatial>
       
      </xsl:if>   
  	</csw:Record>
  </xsl:template>
-->  
  <!-- Feature catalog -->
  <xsl:template match="featureCatalogue" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
		<csw:Record xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		  <dc:identifier><xsl:value-of select="@uuid"/></dc:identifier>
      <xsl:for-each select="name">
		    <dc:title><xsl:value-of select="."/></dc:title>	
		 </xsl:for-each>
      <xsl:for-each select="scope">
		    <dc:subject><xsl:value-of select="."/></dc:subject>	
		 </xsl:for-each>
			<xsl:for-each select="producer">
				<dc:creator><xsl:value-of select="organisationName"/></dc:creator>
			</xsl:for-each>
			<dc:type>featureCatalogue</dc:type>
			<xsl:for-each select="featureType">
				<dc:subject><xsl:value-of select="typeName"/></dc:subject>
			</xsl:for-each>
    </csw:Record>   
  </xsl:template>
  
  <xsl:template name="rmulti">
  	<xsl:param name="l"/>
  	<xsl:param name="e"/>
  	<xsl:param name="n"/>
  	<xsl:element name="{$n}">
  		<xsl:attribute name="xml:lang"><xsl:value-of select="$cl/language/value[@code=$l]/@code2"/></xsl:attribute>
  		<xsl:value-of select="$e/gco:CharacterString"/>
  	</xsl:element>
  		<xsl:for-each select="$e/gmd:PT_FreeText/*/gmd:LocalisedCharacterString">
  			<xsl:variable name="l2" select="substring-after(@locale,'-')"/>
		  	<xsl:element name="{$n}">
		  		<xsl:attribute name="xml:lang"><xsl:value-of select="$cl/language/value[@code=$l2]/@code2"/></xsl:attribute>
		  		<xsl:value-of select="."/>
		  	</xsl:element>
  		</xsl:for-each>
  </xsl:template>

<xsl:template name="XXXmulti" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
  <xsl:param name="el"/>
  <xsl:param name="lang"/>
  <xsl:param name="mdlang"/>
  <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[contains(@locale,$lang)]"/>	
   <xsl:choose>
  	<xsl:when test="string-length($txt)>0">
  	  <xsl:call-template name="lf2br">
  	    <xsl:with-param name="str" select="$txt"/>
      </xsl:call-template>   		
  	</xsl:when>
  	<xsl:otherwise>
  	   <xsl:call-template name="lf2br">
  	     <xsl:with-param name="str" select="$el/gco:CharacterString"/>
       </xsl:call-template>   		
  	</xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
  <xsl:include href="client/common_cli.xsl" />
  
</xsl:stylesheet>
