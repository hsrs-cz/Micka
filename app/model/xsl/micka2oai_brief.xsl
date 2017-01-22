<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:dct="http://purl.org/dc/terms/" 
>
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
<xsl:template match="/">

<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
<responseDate><xsl:value-of select="$timestamp"/></responseDate>
<request verb="ListIdentifiers" metadataPrefix="oai_dc" from="{$FROM}">
  <xsl:value-of select="$thisURL"/>/oai.php
</request>
<ListIdentifiers>
   	<xsl:for-each select="results">
         	<xsl:apply-templates/>
      	</xsl:for-each>
</ListIdentifiers>
   </OAI-PMH>
</xsl:template>
   
<xsl:template match="gmd:MD_Metadata" xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:gmd="http://www.isotc211.org/2005/gmd" >
    <header>
   	  <identifier>oai:mis.cenia.cz:<xsl:value-of select="gmd:fileIdentifier"/></identifier>
      <datestamp><xsl:value-of select="gmd:dateStamp"/></datestamp>
    </header>
</xsl:template>
			
			<!-- zpracovani DC -->
	<xsl:template match="csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
      <header xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:dct="http://purl.org/dc/terms/" 
      xmlns:ows="http://www.opengis.net/ows" 
      xmlns:xlink="http://www.w3.org/1999/xlink" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">         
   	  <identifier>oai:mis.cenia.cz:<xsl:value-of select="dc:identifier"/></identifier>
      <datestamp><xsl:value-of select="dc:dateStamp"/></datestamp>
  	</header>
  </xsl:template>
  

  <xsl:template match="featureCatalogue" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
  </xsl:template>
</xsl:stylesheet>
