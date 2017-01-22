<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"   
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:srv="http://www.isotc211.org/2005/srv" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd"  
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
>

<xsl:variable name="cl" select="document(concat('codelists_', $lang, '.xml'))/map"/>

  <xsl:output method="html" 
    media-type="text/html"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="DTD/xhtml1-strict.dtd"
    cdata-section-elements="script style"
    indent="yes"
    omit-xml-declaration="yes"
    encoding="UTF-8"/>

<xsl:variable name="msg" select="document('client/portal.xml')/portal/messages[@lang=$lang]"/>  
<xsl:variable name="MICKA_URL" select="'..'"/>

<xsl:template match="results">
	<html lang="en">
	<head profile="http://a9.com/-/spec/opensearch/1.1/">
	  <title>Micka OpenSearch response</title>
	  <link rel="stylesheet" type="text/css" href="../themes/default/micka.css" />
	  <link rel="search"
	           type="application/opensearchdescription+xml" 
	           href="{$thisPath}/opensearch.php"
	           title="Micka search" />
	  <meta name="totalResults" content="{results/@numberOfRecordsMatched}"/>
	  <meta name="startIndex" content="1"/>
	  <meta name="itemsPerPage" content="{results/@numberOfRecordsReturned}"/>
	  <link rel="stylesheet" type="text/css" href="portal.css" />
	  <link rel="shortcut icon" href="../favicon.ico" />
	  <script type="text/javascript">
	  var showMap=function(url){
	    this.location="http://geoportal.bnhelp.cz/map?ows="+escape(url);
	  }
	  </script>
	</head> 
	<body>      
      <form>
      	<br/>
        <div style="float:right">
        <a href="{$thisPath}/opensearch.php?q={$Q}&amp;language={$lang}&amp;start={$STARTPOSITION}&amp;format=rss"><img src="../themes/default/img/rss.png" alt="GeoRSS" title="GeoRSS"/> </a>
        <xsl:text> </xsl:text>
        <a href="{$thisPath}/opensearch.php?q={$Q}&amp;language={$lang}&amp;start={$STARTPOSITION}&amp;format=atom"><img src="../themes/default/img/atom.png" alt="GeoRSS" title="GeoRSS"/> </a>
        <xsl:text> </xsl:text>
        <a href="{$thisPath}/opensearch.php?q={$Q}&amp;language={$lang}&amp;start={$STARTPOSITION}&amp;format=rdf"><img src="../themes/default/img/rdf.gif" alt="RDF" title="RDF"/> </a>
        <xsl:text> </xsl:text>
        <a href="{$thisPath}/opensearch.php?q={$Q}&amp;language={$lang}&amp;start={$STARTPOSITION}&amp;format=kml"><img src="../themes/default/img/kml.gif" alt="KML" title="KML"/> </a>
        </div>
        <p>
          <a href="../index.php"><img src="themes/default/img/favicon.gif"/></a>
          <span class="hlavicka">Micka OpenSearch</span>
          <span style="width:60px; display: inline-block"></span>
          <input name="q" value="{$Q}" style="width:250px;" /> <input type="submit" value="OK" />
          <span style="width:20px; display: inline-block"></span>
          <a href="index.php">rozšířené vyhledávání</a>
        </p>
        <br/>
      </form>
			<h2>
				<xsl:choose>
					<xsl:when test="@numberOfRecordsMatched>0">
			     		<xsl:value-of select="$msg/found"/>: <xsl:value-of select="@numberOfRecordsMatched"/>
			  		</xsl:when>
					<xsl:otherwise><span class='notFound'><xsl:value-of select="$msg/notFound"/></span></xsl:otherwise>
				</xsl:choose>
			</h2>
       
			<xsl:for-each select=".">
				<xsl:apply-templates/>
			</xsl:for-each>
		
			<xsl:call-template name="paginator">
				<xsl:with-param name="matched" select="@numberOfRecordsMatched"/>
				<xsl:with-param name="returned" select="@numberOfRecordsReturned"/>
				<xsl:with-param name="next" select="@nextRecord"/>
				<xsl:with-param name="url" select="concat('?q=',$Q,'&amp;language=',$lang,'&amp;start')"/>
			</xsl:call-template>  		
      
</body>
</html>   
</xsl:template>
   
 
  <!-- Feature catalog TOTO prejinacit -->
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

  <xsl:include href="client/common_cli.xsl" />
  <xsl:include href="htmlList.xsl" />

</xsl:stylesheet>
