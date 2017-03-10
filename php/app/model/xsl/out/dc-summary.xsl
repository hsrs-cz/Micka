<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

  <xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
     <csw:SummaryRecord xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">        
      <dc:identifier><xsl:value-of select="gmd:fileIdentifier"/></dc:identifier>        
      <dc:title><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString"/></dc:title>
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
	        
      <dc:date><xsl:value-of select="gmd:dateStamp"/></dc:date>    

	  </csw:SummaryRecord>
	</xsl:template>
			
	<!-- zpracovani DC -->
	<xsl:template match="csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
      <csw:SummaryRecord xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">         
      	<xsl:copy-of select="dc:identifier"/>        
     	<xsl:copy-of select="dc:title"/>        
		<xsl:for-each select="dc:description">
			<dct:abstract><xsl:value-of select="."/></dct:abstract>
		</xsl:for-each>
     	<xsl:copy-of select="dc:type"/>        
    	<xsl:copy-of select="dc:subject"/>        
    	<xsl:copy-of select="dc:format"/>        
  	</csw:SummaryRecord>
  </xsl:template>
  
  <!-- Feature catalog -->
  <xsl:template match="featureCatalogue" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
		<csw:SummaryRecord xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		  <dc:identifier><xsl:value-of select="identifier"/><xsl:value-of select="@uuid"/></dc:identifier>
      <xsl:for-each select="name">
		    <dc:title><xsl:value-of select="."/></dc:title>	
		 </xsl:for-each>
      <xsl:for-each select="scope">
		    <dc:subject><xsl:value-of select="."/></dc:subject>	
		 </xsl:for-each>
			<dc:type>featureCatalogue</dc:type>
			<xsl:for-each select="featureType">
				<dc:subject><xsl:value-of select="typeName"/></dc:subject>
			</xsl:for-each>
    </csw:SummaryRecord>   
  </xsl:template>
</xsl:stylesheet>
