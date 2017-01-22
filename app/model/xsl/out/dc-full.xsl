<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
   
  <xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
    <csw:Record xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
 		
 		<xsl:variable name="lang" select="gmd:identificationInfo/*/gmd:language"/>
 		<xsl:variable name="mdlang" select="gmd:language"/>
 		<xsl:variable name="cl" select="document(concat('../codelists_', 'cze', '.xml'))/map"/>
 		
       <dc:identifier><xsl:value-of select="gmd:fileIdentifier"/></dc:identifier>        
       <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions">
        	<dc:identifier xsi:type="dcterms:URI"><xsl:value-of select="*/gmd:onLine/*/gmd:linkage"/></dc:identifier>
	   </xsl:for-each>     
	  <dc:title xml:lang="{$cl/language/value[@code=$mdlang]/@code2}"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString"/></dc:title>
      <dct:abstract><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></dct:abstract>
      <dc:type><xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode"/></dc:type>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords">
        <xsl:for-each select="gmd:keyword">
           <dc:subject><xsl:value-of select="."/></dc:subject>
        </xsl:for-each>
      </xsl:for-each>
         
      <xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
        <dc:format><xsl:value-of select="*/gmd:name"/></dc:format>
      </xsl:for-each>

       <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(*/gmd:protocol/*, 'WMS') or contains(*/gmd:linkage, 'WMS')]">
        	<dct:references scheme="OGC:WMS"><xsl:value-of select="*/gmd:linkage"/></dct:references>
	   </xsl:for-each>     
	        
      <dc:date><xsl:value-of select="gmd:dateStamp"/></dc:date>    
 
     <!--<xsl:for-each select="identificationInfo/*/topicCategory">
        <iso19115TopicCategory><xsl:value-of select="MD_TopicCategoryCode"/></iso19115TopicCategory>
      </xsl:for-each>-->
      
      <!--<xsl:for-each select="identificationInfo/*/citation/date">
        <xsl:if test="dateType/CI_DateTypeCode_CodeList='revision'">
          <dct:modified><xsl:value-of select="date"/></dct:modified>
        </xsl:if>
      </xsl:for-each>-->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
	       <xsl:choose>
          	<xsl:when test="gmd:role/*/codeListValue='originator'">
            	<dc:creator> <xsl:value-of select="*/gmd:organisationName"/> </dc:creator>
          	</xsl:when>
          	<xsl:when test="*/gmd:role/*/codeListValue='publisher'">
            	<dc:publisher> <xsl:value-of select="*/gmd:organisationName"/> </dc:publisher>
          	</xsl:when>
         	  <xsl:when test="*/gmd:role/*/codeListValue='author'">
            	<dc:contributor> <xsl:value-of select="*/gmd:organisationName"/> </dc:contributor>
          	</xsl:when>
         	  <xsl:when test="*/gmd:role/*/codeListValue='contributor'">
            	<dc:contributor> <xsl:value-of select="*/gmd:organisationName"/> </dc:contributor>
          	</xsl:when>
	          <xsl:otherwise>
              <dc:publisher> <xsl:value-of select="*/gmd:organisationName"/> </dc:publisher>
	          </xsl:otherwise>
	        </xsl:choose>
      </xsl:for-each>
	        
      
      <xsl:for-each select="gmd:distributionInfo//gmd:distributionFormat">
        <dc:format><xsl:value-of select="*/gmd:name"/></dc:format>
      </xsl:for-each>
	
      <dc:language xsi:type="dcterms:ISO639-1"><xsl:value-of select="$cl/language/value[@code=$lang]/@code2"/></dc:language>

      <xsl:for-each select="MD_Distribution//transferOptions">
        <dc:source xsi:type="dcterms:URI"><xsl:value-of select="*/onLine/*/linkage"/></dc:source>
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
        <ows:BoundingBox dimensions="2" crs="http://www.epsg.org#4326">
          <ows:LowerCorner><xsl:value-of select="gmd:identificationInfo/*/*/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo/*/*/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude"/></ows:LowerCorner>
          <ows:UpperCorner><xsl:value-of select="gmd:identificationInfo/*/*/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo/*/*/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude"/></ows:UpperCorner>
        </ows:BoundingBox>

    </csw:Record>
	  
	</xsl:template>
			
			<!-- zpracovani DC -->
  <xsl:template match="csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
	<xsl:copy-of select="."/>
  </xsl:template>

  
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
</xsl:stylesheet>
