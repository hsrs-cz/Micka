<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:dct="http://purl.org/dc/terms/" 
		xmlns:dcl="http://dclite4g.xmlns.com/schema.rdf#" 
		xmlns:os="http://a9.com/-/spec/opensearch/1.1/">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
<xsl:template match="/">

<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
<responseDate><xsl:value-of select="$timestamp"/></responseDate>

<xsl:element name="request">
	<xsl:attribute name="verb"><xsl:value-of select="$VERB"/></xsl:attribute>
	<xsl:if test="$FROM"><xsl:attribute name="from"><xsl:value-of select="$FROM"/></xsl:attribute></xsl:if>
	<xsl:if test="$UNTIL"><xsl:attribute name="until"><xsl:value-of select="$UNTIL"/></xsl:attribute></xsl:if>
	<xsl:if test="$ID"><xsl:attribute name="identifier"><xsl:value-of select="$ID"/></xsl:attribute></xsl:if>
  	<xsl:value-of select="$thisURL"/>/oai.php
</xsl:element>
<!-- 
<request verb="{$VERB}" metadataPrefix="oai_dc" from="{$FROM}">
  <xsl:value-of select="$thisURL"/>/oai.php
</request>
 -->
	<xsl:element name="{$VERB}">
	   	<xsl:for-each select="results">
	       	<xsl:apply-templates/>
	    </xsl:for-each>
    	<xsl:if test="results/@nextRecord > 0">
			<resumptionToken completeListSize="{results/@numberOfRecordsMatched}" cursor="{$STARTPOSITION - 1}">
                <xsl:if test="results/@nextRecord>0">
                    <xsl:value-of select="concat($VERB,'|',$SET,'|',$FROM,'|',$UNTIL,'|',$TYPENAMES,'|',results/@nextRecord)"/>
                </xsl:if>
            </resumptionToken>
		</xsl:if>	
	</xsl:element>
   </OAI-PMH>
</xsl:template>
   
<xsl:template match="gmd:MD_Metadata" xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
 <record>
   <header>
   	<identifier>oai:mis.cenia.cz:<xsl:value-of select="gmd:fileIdentifier"/></identifier>
   <datestamp><xsl:value-of select="gmd:dateStamp"/></datestamp>
   </header>
   
    <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"> 
       
      <dc:identifier><xsl:value-of select="gmd:fileIdentifier"/></dc:identifier>        
      <xsl:for-each select="gmd:MD_Distribution/gmd:transferOptions">
        <dc:identifier><xsl:value-of select="gmd:onLine/gmd:linkage"/></dc:identifier>
	    </xsl:for-each>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
        <dc:title><xsl:value-of select="."/></dc:title>
      </xsl:for-each>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
        <dc:description><xsl:value-of select="."/></dc:description>
      </xsl:for-each>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords">
        <xsl:for-each select="gmd:keyword">
           <dc:subject><xsl:value-of select="."/></dc:subject>
        </xsl:for-each>
      </xsl:for-each>
      
      <!--<xsl:for-each select="identificationInfo/*/topicCategory">
        <iso19115TopicCategory><xsl:value-of select="MD_TopicCategoryCode"/></iso19115TopicCategory>
      </xsl:for-each>-->
      
      <xsl:for-each select="gmd:distributionInfo/gmd:distributor/gmd:distributorFormat">
        <dc:format> <xsl:value-of select="gmd:distributionInfo/gmd:distributor/gmd:distributorFormat/gmd:name"/> </dc:format>
      </xsl:for-each>
      <!--<xsl:for-each select="identificationInfo/*/citation/date">
        <xsl:if test="dateType/CI_DateTypeCode_CodeList='revision'">
          <dct:modified><xsl:value-of select="date"/></dct:modified>
        </xsl:if>
      </xsl:for-each>-->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
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
      <dc:type><xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@gmd:codeListValue"/></dc:type>
      
      <xsl:for-each select="gmd:distributionInfo//gmd:distributionFormat/*/gmd:name">
        <dc:format><xsl:value-of select="."/></dc:format>
      </xsl:for-each>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:language">
        <dc:language><xsl:value-of select="."/></dc:language>
      </xsl:for-each>

      <xsl:for-each select="gmd:distributionInfo//gmd:transferOptions">
        <dc:source><xsl:value-of select="*/gmd:onLine/*/gmd:linkage"/></dc:source>
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
      </dct:spatial>

	  </oai_dc:dc>
	</record>  
	</xsl:template>
			
<!-- zpracovani DC -->
<xsl:template match="csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
 <record>
     <header xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">         
   	  <identifier>oai:mis.cenia.cz:<xsl:value-of select="dc:identifier"/></identifier>
      <datestamp><xsl:value-of select="dc:dateStamp"/></datestamp>
  	</header>
    
    <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"> 
		  <dc:identifier><xsl:value-of select="identifier"/></dc:identifier>
			<xsl:for-each select="dc:title">
				<dc:title><xsl:value-of select="."/></dc:title>	
			</xsl:for-each>
			<xsl:for-each select="dc:description">
				<dc:description><xsl:value-of select="."/></dc:description>
			</xsl:for-each>
			<xsl:for-each select="dc:subject">
				<dc:subject><xsl:value-of select="."/></dc:subject>
			</xsl:for-each>
			<xsl:for-each select="dc:format">
				<dc:format><xsl:value-of select="."/></dc:format>
			</xsl:for-each>
			<xsl:for-each select="dc:date">
				<dc:date><xsl:value-of select="."/></dc:date>
			</xsl:for-each>
			<xsl:for-each select="dc:creator">
				<dc:creator><xsl:value-of select="."/></dc:creator>
			</xsl:for-each>
			<xsl:for-each select="dc:publisher">
				<dc:publisher><xsl:value-of select="."/></dc:publisher>
			</xsl:for-each>
			<xsl:for-each select="dc:contributor">
				<dc:contributor><xsl:value-of select="."/></dc:contributor>
			</xsl:for-each>
			<xsl:for-each select="dc:source">
				<dc:source><xsl:value-of select="."/></dc:source>
			</xsl:for-each>
			<xsl:for-each select="dc:relation">
				<dc:relation><xsl:value-of select="."/></dc:relation>
			</xsl:for-each>
			<xsl:for-each select="dc:rights">
				<dc:rights><xsl:value-of select="."/></dc:rights>
			</xsl:for-each>
			<xsl:for-each select="dc:type">
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
      </oai_dc:dc>  
  	</record>
  </xsl:template>
 
  <!-- Feature catalog -->
  <xsl:template match="featureCatalogue" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">  
  </xsl:template>
  
</xsl:stylesheet>
