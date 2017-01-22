<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:dct="http://purl.org/dc/terms/" 
		xmlns:dcl="http://dclite4g.xmlns.com/schema.rdf#"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:gmd="http://www.isotc211.org/2005/gmd" 
		xmlns:gco="http://www.isotc211.org/2005/gco"
		xmlns:os="http://a9.com/-/spec/opensearch/1.1/">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
<xsl:template match="/">

<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
	<responseDate><xsl:value-of select="$timestamp"/></responseDate>

	<xsl:element name="request">
		<xsl:attribute name="verb"><xsl:value-of select="$VERB"/></xsl:attribute>
		<xsl:if test="$TYPENAMES"><xsl:attribute name="metadataPrefix"><xsl:value-of select="$TYPENAMES"/></xsl:attribute></xsl:if>
		<xsl:if test="$FROM"><xsl:attribute name="from"><xsl:value-of select="$FROM"/></xsl:attribute></xsl:if>
		<xsl:if test="$UNTIL"><xsl:attribute name="until"><xsl:value-of select="$UNTIL"/></xsl:attribute></xsl:if>
		<xsl:if test="$ID"><xsl:attribute name="identifier"><xsl:value-of select="$ID"/></xsl:attribute></xsl:if>
	  	<xsl:value-of select="$thisURL"/>/oai.php
	</xsl:element>

	<xsl:element name="{$VERB}">
	   	<xsl:for-each select="results">
	       	<xsl:apply-templates/>
	    </xsl:for-each>
	    <xsl:if test="results/@numberOfRecordsMatched > results/@numberOfRecordsReturned">
			<resumptionToken completeListSize="{results/@numberOfRecordsMatched}" cursor="{$STARTPOSITION - 1}">
                <xsl:if test="results/@nextRecord>0">
                    <xsl:value-of select="concat($VERB,'|',$SET,'|',$FROM,'|',$UNTIL,'|',$TYPENAMES,'|',results/@nextRecord)"/>
                </xsl:if>
            </resumptionToken>
		</xsl:if>	
	</xsl:element>
	
   </OAI-PMH>
</xsl:template>
   
<xsl:template match="gmd:MD_Metadata" xmlns="http://www.openarchives.org/OAI/2.0/" >
 <record>
   <header>
   	<identifier>oai:mis.cenia.cz:<xsl:value-of select="gmd:fileIdentifier"/></identifier>
    <datestamp><xsl:value-of select="gmd:dateStamp"/></datestamp>
   </header>
   <metadata>
    <record xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">      
 	<leader>01427CMM  22     1  4500</leader>
 	<!-- <leader>
 		<xsl:text>     </xsl:text>
 		<xsl:value-of select="@status"/>
 		<xsl:value-of select="@type"/>
 		<xsl:value-of select="@level"/>
 		<xsl:text>  22     </xsl:text>
 		<xsl:value-of select="@encLvl"/>
 		<xsl:value-of select="@catForm"/>
 		<xsl:text> 4500</xsl:text>
 	</leader> -->

	<controlfield tag="001"><xsl:value-of select="gmd:fileIdentifier"/></controlfield>
	<controlfield tag="005"><xsl:value-of select="translate(gmd:dateStamp,'-','')"/>000000.0</controlfield>
	
      <xsl:for-each select="gmd:identificationInfo/*/gmd:citation">
        <datafield tag="200" ind1="1" ind2=" ">
        	<subfield code="a"><xsl:value-of select="*/gmd:title/gco:CharacterString"/></subfield>
        	<subfield code="e"><xsl:value-of select="*/gmd:alternateTitle/gco:CharacterString"/></subfield>
        </datafield>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
        <datafield tag="330" ind1="3" ind2=" ">
        	<subfield code="a"><xsl:value-of select="gco:CharacterString"/></subfield>
        </datafield>	
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:purpose">
        <datafield tag="500" ind1="3" ind2=" ">
        	<subfield code="a"><xsl:value-of select="."/></subfield>
        </datafield>	
      </xsl:for-each>
      
      <datafield tag="034" ind1="1" ind2=" ">
        <subfield code="d"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude"/></subfield>
		<subfield code="e"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude"/></subfield>
        <subfield code="f"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude"/></subfield>
        <subfield code="g"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude"/></subfield>
      </datafield>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
	       <xsl:choose>
          	<xsl:when test="*/gmd:role/*/@codeListValue='originator'">
           		<datafield tag="720" ind1="2" ind2=" ">
          	   		<subfield code="a"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   		<subfield code="e">originator</subfield>
          	   	</datafield>	
          	</xsl:when>
          	<xsl:when test="*/gmd:role/*/@codeListValue='publisher'">
          	   	<datafield tag="260" ind1="2" ind2=" ">
          	   		<subfield code="b"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   	</datafield>	 
          	</xsl:when>
         	  <xsl:when test="*/gmd:role/*/@codeListValue='author'">
            	<datafield tag="700" ind1="1" ind2=" ">
          	   		<subfield code="a"><xsl:value-of select="*/gmd:individualName/gco:CharacterString"/></subfield>
          	   	</datafield>	
            	<datafield tag="710" ind1="1" ind2=" ">
          	   		<subfield code="a"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   	</datafield>	          
          	</xsl:when>
         	<xsl:when test="*/gmd:role/*/@codeListValue='contributor'">
            	<datafield tag="720" ind1="2" ind2=" ">
          	   		<subfield code="a"><xsl:value-of select="*/gmd:organisationName"/></subfield>
          	   	</datafield>	
          	</xsl:when>
	          <xsl:otherwise>
                <datafield tag="260" ind1="2" ind2=" ">
          	   		<subfield code="b"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   	</datafield>	 
	          </xsl:otherwise>
	        </xsl:choose> 
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
      		<datafield tag="210" ind1="1" ind2=" ">
          		<subfield code="d"><xsl:value-of select="*/gmd:date"/></subfield>
          	</datafield>	
	  </xsl:for-each>      	   	
  
      <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords">
        <xsl:for-each select="gmd:keyword">
           <datafield tag="610" ind1="0" ind2=" ">
      	   		<subfield code="a"><xsl:value-of select="gco:CharacterString"/></subfield>
      	   	</datafield>	 
        </xsl:for-each>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
           <datafield tag="606" ind1="1" ind2=" ">
      	   		<subfield code="a"><xsl:value-of select="gmd:MD_TopicCategoryCode"/></subfield>
      	   		<subfield code="2">ISO19115</subfield>
      	   	</datafield>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
            <datafield tag="336" ind1="1" ind2=" ">
      	   		<subfield code="a"><xsl:value-of select="*/name"/></subfield>
      	   	</datafield>
      </xsl:for-each>
	        
      <datafield tag="608" ind1="1" ind2=" ">
   		<subfield code="a"><xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/></subfield>
	  </datafield>    

      <xsl:for-each select="gmd:identificationInfo/*/gmd:language">
        <datafield tag="546" ind1=" " ind2=" ">
      		<subfield code="a"><xsl:value-of select="."/></subfield>
      	</datafield>
      </xsl:for-each>

       <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/identifier">
        <datafield tag="001" ind1="" ind2=" "><xsl:value-of select="*/code"/></datafield>
      </xsl:for-each>

       <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/ISBN">
        <datafield tag="010" ind1="a" ind2=" "><xsl:value-of select="."/></datafield>
      </xsl:for-each>

       <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/ISSN">
        <datafield tag="011" ind1="" ind2=""><xsl:value-of select="."/></datafield>
      </xsl:for-each>

      <xsl:for-each select="gmd:distributionInfo//gmd:transferOptions">
        <datafield tag="856" ind1="4" ind2=" ">
      		<subfield code="u"><xsl:value-of select="*/gmd:onLine/*/gmd:linkage"/></subfield>
      	</datafield>
	  </xsl:for-each>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">
           <datafield tag="506" ind1="1" ind2=" ">
      	   		<subfield code="f"><xsl:value-of select="."/></subfield>
      	   	</datafield>	       
      </xsl:for-each>

	  </record>
	  </metadata>
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
