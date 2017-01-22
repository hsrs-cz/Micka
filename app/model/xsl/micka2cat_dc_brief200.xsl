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
    <csw:BriefRecord> 
      <dc:identifier><xsl:value-of select="@uuid"/></dc:identifier>        
      <xsl:for-each select="identificationInfo/*/citation/title">
        <dc:title><xsl:value-of select="."/></dc:title>
      </xsl:for-each>
      <dc:type><xsl:value-of select="hierarchyLevel/MD_ScopeCode"/></dc:type>
	  </csw:BriefRecord>
	</xsl:template>
			
			<!-- zpracovani DC -->
		<xsl:template match="metadata" xmlns:csw="http://www.opengis.net/cat/csw" xmlns:dc="http://www.purl.org/dc/elements/1.1/" xmlns:dct="http://www.purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
      <csw:BriefRecord>         
		  <dc:identifier><xsl:value-of select="identifier"/><xsl:value-of select="@uuid"/></dc:identifier>
			<xsl:for-each select="title">
				<dc:title><xsl:value-of select="."/></dc:title>	
			</xsl:for-each>
			<xsl:for-each select="type">
				<dc:type><xsl:value-of select="."/></dc:type>
			</xsl:for-each>
  	</csw:BriefRecord>
  </xsl:template>
  
  <!-- Feature catalog -->
  <xsl:template match="featureCatalogue" xmlns:csw="http://www.opengis.net/cat/csw" xmlns:dc="http://www.purl.org/dc/elements/1.1/" xmlns:dct="http://www.purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
		<csw:BriefRecord>
		  <dc:identifier><xsl:value-of select="identifier"/><xsl:value-of select="@uuid"/></dc:identifier>
      <xsl:for-each select="name">
		    <dc:title><xsl:value-of select="."/></dc:title>	
		 </xsl:for-each>
			<dc:type>featureCatalogue</dc:type>
    </csw:BriefRecord>   
  </xsl:template>
</xsl:stylesheet>
