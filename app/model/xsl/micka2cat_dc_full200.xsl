<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="/">
    <csw:GetRecordsResponse 
      xmlns:csw="http://www.opengis.net/cat/csw" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:dc="http://www.purl.org/dc/elements/1.1/" 
      xmlns:dct="http://www.purl.org/dc/terms/" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      version="2.0.0">
      
	    <csw:RequestId><xsl:value-of select="$REQUESTID"/></csw:RequestId>
      <csw:SearchStatus timestamp="{$timestamp}" status="complete"/>
      <csw:SearchResults numberOfRecordsMatched="{results/@numberOfRecordsMatched}" numberOfRecordsReturned="{results/@numberOfRecordsReturned}" nextRecord="{results/@nextRecord}" elementSet="full">
      <xsl:for-each select="results">
         <xsl:apply-templates/>
      </xsl:for-each>
      </csw:SearchResults>
    </csw:GetRecordsResponse>
  </xsl:template>
   
  <xsl:template match="MD_Metadata" xmlns:csw="http://www.opengis.net/cat/csw" xmlns:dc="http://www.purl.org/dc/elements/1.1/" xmlns:dct="http://www.purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
    <csw:Record> 
      <dc:identifier><xsl:value-of select="@uuid"/></dc:identifier>        
      <!--<xsl:for-each select="MD_Distribution/transferOptions">
        <dc:identifier><xsl:value-of select="onLine/linkage"/></dc:identifier>
	    </xsl:for-each>-->
      <xsl:for-each select="identificationInfo/*/citation/title">
        <dc:title><xsl:value-of select="."/></dc:title>
      </xsl:for-each>
      <xsl:for-each select="identificationInfo/*/abstract">
        <dct:abstract><xsl:value-of select="."/></dct:abstract>
      </xsl:for-each>
      <xsl:for-each select="identificationInfo/*/descriptiveKeywords">
        <xsl:for-each select="keyword">
           <dc:subject><xsl:value-of select="."/></dc:subject>
        </xsl:for-each>
      </xsl:for-each>
      
      <!--<xsl:for-each select="identificationInfo/*/topicCategory">
        <iso19115TopicCategory><xsl:value-of select="MD_TopicCategoryCode"/></iso19115TopicCategory>
      </xsl:for-each>-->
      
      <xsl:for-each select="distributionInfo/distributor/distributorFormat">
        <dc:format> <xsl:value-of select="distributionInfo/distributor/distributorFormat/name"/> </dc:format>
      </xsl:for-each>
      <!--<xsl:for-each select="identificationInfo/*/citation/date">
        <xsl:if test="dateType/CI_DateTypeCode_CodeList='revision'">
          <dct:modified><xsl:value-of select="date"/></dct:modified>
        </xsl:if>
      </xsl:for-each>-->
      <xsl:for-each select="identificationInfo/*/pointOfContact">
	       <xsl:choose>
          	<xsl:when test="role/CI_RoleCode_CodeList='originator'">
            	<dc:creator> <xsl:value-of select="organisationName"/> </dc:creator>
          	</xsl:when>
          	<xsl:when test="role/CI_RoleCode_CodeList='publisher'">
            	<dc:publisher> <xsl:value-of select="organisationName"/> </dc:publisher>
          	</xsl:when>
         	  <xsl:when test="role/CI_RoleCode_CodeList='author'">
            	<dc:contributor> <xsl:value-of select="organisationName"/> </dc:contributor>
          	</xsl:when>
         	  <xsl:when test="role/CI_RoleCode_CodeList='contributor'">
            	<dc:contributor> <xsl:value-of select="organisationName"/> </dc:contributor>
          	</xsl:when>
	          <xsl:otherwise>
              <dc:publisher> <xsl:value-of select="organisationName"/> </dc:publisher>
	          </xsl:otherwise>
	        </xsl:choose>
      </xsl:for-each>
	        
      <dc:date><xsl:value-of select="dateStamp"/></dc:date>
      <dc:type><xsl:value-of select="hierarchyLevel/MD_ScopeCode"/></dc:type>
      
      <xsl:for-each select="MD_Distribution//distributionFormat/name">
        <dc:format><xsl:value-of select="."/></dc:format>
      </xsl:for-each>

      <xsl:for-each select="identificationInfo/*/language">
        <dc:language><xsl:value-of select="isoCode"/></dc:language>
      </xsl:for-each>

      <xsl:for-each select="MD_Distribution//transferOptions">
        <dc:source><xsl:value-of select="onLine/linkage"/></dc:source>
	    </xsl:for-each>

      <xsl:for-each select="identificationInfo/*/resourceConstraints/MD_LegalConstraints/accessConstraints">
        <dc:rights><xsl:value-of select="MD_RestrictionCode"/></dc:rights>
	    </xsl:for-each>

      <!--<dct:spatial>
        <Box projection="EPSG:4326" name="Geographic">
          <northlimit><xsl:value-of select="@y2"/></northlimit>
          <eastlimit><xsl:value-of select="@x2"/></eastlimit>
          <southlimit><xsl:value-of select="@y1"/></southlimit>
          <westlimit><xsl:value-of select="@x1"/></westlimit>
        </Box>
      </dct:spatial>
-->
        <ows:WGS84BoundingBox dimensions="2" crs="http://www.epsg.org#4326">
          <ows:LowerCorner><xsl:value-of select="@x1"/><xsl:text> </xsl:text><xsl:value-of select="@y1"/></ows:LowerCorner>
          <ows:UpperCorner><xsl:value-of select="@x2"/><xsl:text> </xsl:text><xsl:value-of select="@y2"/></ows:UpperCorner>
        </ows:WGS84BoundingBox>
	  </csw:Record>
	</xsl:template>
			
			<!-- zpracovani DC -->
		<xsl:template match="metadata" xmlns:csw="http://www.opengis.net/cat/csw" xmlns:dc="http://www.purl.org/dc/elements/1.1/" xmlns:dct="http://www.purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
      <csw:Record>         
		  <dc:identifier><xsl:value-of select="identifier"/><xsl:value-of select="@uuid"/></dc:identifier>
			<xsl:for-each select="title">
				<dc:title><xsl:value-of select="."/></dc:title>	
			</xsl:for-each>
			<xsl:for-each select="description">
				<dct:abstract><xsl:value-of select="."/></dct:abstract>
			</xsl:for-each>
			<xsl:for-each select="subject">
				<dc:subject><xsl:value-of select="."/></dc:subject>
			</xsl:for-each>
			<xsl:for-each select="format">
				<dc:format><xsl:value-of select="."/></dc:format>
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
			  <ows:WGS84BoundingBox>
	        <ows:LowerCorner><xsl:value-of select="@x1"/><xsl:text> </xsl:text><xsl:value-of select="@y1"/></ows:LowerCorner>
	        <ows:UpperCorner><xsl:value-of select="@x2"/><xsl:text> </xsl:text><xsl:value-of select="@y2"/></ows:UpperCorner>
        </ows:WGS84BoundingBox>
      <!--  <dct:spatial>
          <Box projection="EPSG:4326" name="Geographic">
            <northlimit><xsl:value-of select="@y2"/></northlimit>
            <eastlimit><xsl:value-of select="@x2"/></eastlimit>
            <southlimit><xsl:value-of select="@y1"/></southlimit>
            <westlimit><xsl:value-of select="@x1"/></westlimit>
          </Box>
        </dct:spatial>
        -->
      </xsl:if>    
  	</csw:Record>
  </xsl:template>
  
  <!-- Feature catalog -->
  <xsl:template match="featureCatalogue" xmlns:csw="http://www.opengis.net/cat/csw" xmlns:dc="http://www.purl.org/dc/elements/1.1/" xmlns:dct="http://www.purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
		<csw:Record>
		  <dc:identifier><xsl:value-of select="identifier"/><xsl:value-of select="@uuid"/></dc:identifier>
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
</xsl:stylesheet>
