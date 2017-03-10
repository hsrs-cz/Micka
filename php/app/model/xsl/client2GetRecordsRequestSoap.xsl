<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="utf-8"/>
<xsl:template match="/">

<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
<soap:Body>
<csw:GetRecords 
  xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:ows="http://www.opengis.net/ows"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:apiso="http://www.opengis.net/cat/csw/apiso/1.0" 
  xsi:schemaLocation="http://www.opengis.net/cat/csw/2.0.2 http://schemas.opengis.net/csw/2.0.2/CSW-discovery.xsd" 
  outputSchema="{$outputSchema}" 
  maxRecords="{$maxRecords}" startPosition="{$startPosition}" 
  outputFormat="application/xml" 
  service="CSW" 
  resultType="results" version="2.0.2" requestId="{$id}" debug="{$debug}"> 

	<xsl:if test="$hopCount>0"><DistributedSearch hopCount="{$hopCount}"/></xsl:if>
	<!--<csw:ResponseHandler>http://www.bnhelp.cz</csw:ResponseHandler>-->
	<csw:Query typeNames="{$typeNames}">
		<csw:ElementSetName><xsl:value-of select="$ElementSetName"/></csw:ElementSetName>
		<csw:Constraint version="1.1.0">

  		<xsl:copy-of select="." />

		</csw:Constraint>
		<xsl:if test="$sortBy!=''">
		  <ogc:SortBy>
			<ogc:SortProperty>
				<ogc:PropertyName><xsl:value-of select="$sortBy"/></ogc:PropertyName>
				<ogc:SortOrder>ASC</ogc:SortOrder>
			</ogc:SortProperty>
		  </ogc:SortBy>
		</xsl:if>
		
	</csw:Query>
</csw:GetRecords>
</soap:Body>
</soap:Envelope>

</xsl:template>
</xsl:stylesheet>
