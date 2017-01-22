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
   
<xsl:template match="rec/gmd:MD_Metadata" xmlns="http://www.openarchives.org/OAI/2.0/" >
 <record>
   <header>
   	<identifier>oai:mis.cenia.cz:<xsl:value-of select="gmd:fileIdentifier"/></identifier>
    <datestamp><xsl:value-of select="gmd:dateStamp"/></datestamp>
   </header>
   <metadata>
    <oai_marc xmlns="http://www.openarchives.org/OAI/1.1/oai_marc" xsi:schemaLocation="http://www.openarchives.org/OAI/1.1/oai_marc http://www.openarchives.org/OAI/1.1/oai_marc.xsd" type="u" level="m">      

	<fixfield id="1">"<xsl:value-of select="gmd:fileIdentifier"/>"</fixfield>
	<fixfield id="5">"<xsl:value-of select="gmd:dateStamp"/>"</fixfield>
	
      <xsl:for-each select="gmd:identificationInfo/*/gmd:citation">
        <varfield id="200" i1="1" i2="">
        	<subfield label="a"><xsl:value-of select="*/gmd:title/gco:CharacterString"/></subfield>
        	<subfield label="e"><xsl:value-of select="*/gmd:alternateTitle/gco:CharacterString"/></subfield>
        </varfield>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
        <varfield id="330" i1="3" i2="">
        	<subfield label="a"><xsl:value-of select="gco:CharacterString"/></subfield>
        </varfield>	
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:purpose">
        <varfield id="500" i1="3" i2="">
        	<subfield label="a"><xsl:value-of select="."/></subfield>
        </varfield>	
      </xsl:for-each>
      
      <varfield id="034" i1="1" i2="">
        <subfield label="d"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude"/></subfield>
		<subfield label="e"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude"/></subfield>
        <subfield label="f"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude"/></subfield>
        <subfield label="g"><xsl:value-of select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude"/></subfield>
      </varfield>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
	       <xsl:choose>
          	<xsl:when test="*/gmd:role/*/@codeListValue='originator'">
           		<varfield id="720" i1="2" i2="">
          	   		<subfield label="a"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   		<subfield label="e">originator</subfield>
          	   	</varfield>	
          	</xsl:when>
          	<xsl:when test="*/gmd:role/*/@codeListValue='publisher'">
          	   	<varfield id="260" i1="2" i2="">
          	   		<subfield label="b"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   	</varfield>	 
          	</xsl:when>
         	  <xsl:when test="*/gmd:role/*/@codeListValue='author'">
            	<varfield id="700" i1="1" i2="">
          	   		<subfield label="a"><xsl:value-of select="*/gmd:individualName/gco:CharacterString"/></subfield>
          	   	</varfield>	
            	<varfield id="710" i1="1" i2="">
          	   		<subfield label="a"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   	</varfield>	          
          	</xsl:when>
         	<xsl:when test="*/gmd:role/*/@codeListValue='contributor'">
            	<varfield id="720" i1="2" i2="">
          	   		<subfield label="a"><xsl:value-of select="*/gmd:organisationName"/></subfield>
          	   	</varfield>	
          	</xsl:when>
	          <xsl:otherwise>
                <varfield id="260" i1="2" i2="">
          	   		<subfield label="b"><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></subfield>
          	   	</varfield>	 
	          </xsl:otherwise>
	        </xsl:choose> 
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
      		<varfield id="210" i1="1" i2="">
          		<subfield label="d"><xsl:value-of select="*/gmd:date"/></subfield>
          	</varfield>	
	  </xsl:for-each>      	   	
  
      <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords">
        <xsl:for-each select="gmd:keyword">
           <varfield id="610" i1="0" i2="">
      	   		<subfield label="a"><xsl:value-of select="gco:CharacterString"/></subfield>
      	   	</varfield>	 
        </xsl:for-each>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
           <varfield id="606" i1="1" i2="">
      	   		<subfield label="a"><xsl:value-of select="gmd:MD_TopicCategoryCode"/></subfield>
      	   		<subfield label="2">ISO19115</subfield>
      	   	</varfield>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
            <varfield id="336" i1="1" i2="">
      	   		<subfield label="a"><xsl:value-of select="*/name"/></subfield>
      	   	</varfield>
      </xsl:for-each>
	        
      <varfield id="608" i1="1" i2="">
   		<subfield label="a"><xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/></subfield>
	  </varfield>    

      <xsl:for-each select="gmd:identificationInfo/*/gmd:language">
        <varfield id="546" i1="" i2="">
      		<subfield label="a"><xsl:value-of select="."/></subfield>
      	</varfield>
      </xsl:for-each>

       <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/identifier">
        <varfield id="001" i1="" i2=""><xsl:value-of select="*/code"/></varfield>
      </xsl:for-each>

       <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/ISBN">
        <varfield id="010" i1="a" i2=""><xsl:value-of select="."/></varfield>
      </xsl:for-each>

       <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/ISSN">
        <varfield id="011" i1="" i2=""><xsl:value-of select="."/></varfield>
      </xsl:for-each>

      <xsl:for-each select="gmd:distributionInfo//gmd:transferOptions">
        <varfield id="856" i1="4" i2="">
      		<subfield label="u"><xsl:value-of select="*/gmd:onLine/*/gmd:linkage"/></subfield>
      	</varfield>
	  </xsl:for-each>

      <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">
           <varfield id="506" i1="1" i2="">
      	   		<subfield label="f"><xsl:value-of select="."/></subfield>
      	   	</varfield>	       
      </xsl:for-each>


	  </oai_marc>
	  </metadata>
	</record>  
	</xsl:template>
			
<!-- zpracovani DC -->
<xsl:template match="rec/csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
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
  <xsl:template match="rec/featureCatalogue" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">  
  </xsl:template>
  
</xsl:stylesheet>
