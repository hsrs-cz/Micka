<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:ows="http://www.opengis.net/ows"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns="http://www.w3.org/2005/Atom"
  xmlns:georss="http://www.georss.org/georss" 
  xmlns:xlink="http://www.w3.org/1999/xlink"  
  xmlns:php="http://php.net/xsl"   
  xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"  
>

<xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:variable name="msg" select="document('client/portal.xml')/portal/messages[@lang=$LANGUAGE]"/>
<xsl:variable name="cl" select="document('../../config/codelists.xml')/map"/>

<xsl:template match="//gmd:MD_Metadata|//gmi:MI_Metadata"  
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"    
	>
	<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"/>
	<xsl:variable name="lang2" select="$cl/language/value[$LANGUAGE]/@code2"/>
	
	<feed xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/" xml:lang="{$lang2}">
		<xsl:choose>
			<xsl:when test="gmd:hierarchyLevel/*/@codeListValue='service'">
				<xsl:attribute name="xsi:schemaLocation">http://www.w3.org/2005/Atom http://inspire-geoportal.ec.europa.eu/schemas/inspire/atom/1.0/atom.xsd</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="xsi:schemaLocation">http://www.w3.org/2005/Atom http://inspire-geoportal.ec.europa.eu/schemas/inspire/atom/1.0/atom_subfeed.xsd</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		
      	<!-- title for pre-defined dataset -->
      	<title><xsl:call-template name="multi">
	    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
	    	<xsl:with-param name="lang" select="$LANGUAGE"/>
	    	<xsl:with-param name="mdlang" select="$mdlang"/>
	  	</xsl:call-template></title>
      	
      	<!-- subtitle -->
      	<subtitle type="html">
      		<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
      		<xsl:call-template name="multi">
	    		<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
	    		<xsl:with-param name="lang" select="$LANGUAGE"/>
	    		<xsl:with-param name="mdlang" select="$mdlang"/>
	  		</xsl:call-template>
		  	<xsl:if test="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*">
	  			<div><img src="{gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*}"/></div>
	  			<xsl:call-template name="multi">
	    			<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileDescription"/>
	    			<xsl:with-param name="lang" select="$LANGUAGE"/>
	    			<xsl:with-param name="mdlang" select="$mdlang"/>
	  			</xsl:call-template>
	  		</xsl:if>	
	  		<div>Metadata:
	  			<a href="{$mickaURL}/record/basic/{gmd:fileIdentifier}" target="_blank">HTML</a><xsl:text> </xsl:text>
	  			<a href="{$mickaURL}/record/xml/{gmd:fileIdentifier}" title="ISO 19139" target="_blank">XML</a><xsl:text> </xsl:text>
	  			<a href="{$mickaURL}/csw/?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/ns/dcat%23&amp;id={gmd:fileIdentifier}" title="INSPIRE GeoDCAT-AP RDF/XML" target="_blank">GeoDCAT</a>
	  		</div>
		  	<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
	  	</subtitle>

		<!-- link to download service ISO 19139 metadata -->
		<xsl:choose>
			<xsl:when test="gmd:hierarchyLevel/*/@codeListValue='service'">
	    		<link href="{$mickaURL}/record/xml/{gmd:fileIdentifier}" rel="describedby" type="application/xml"/>
			</xsl:when>
			<xsl:otherwise>
				<link href="{$mickaURL}/record/xml/{gmd:fileIdentifier}" rel="describedby" type="application/xml"/>
			</xsl:otherwise>
		</xsl:choose>
	  	
	  	<!-- Link to Open Search XML description -->
		<link href="{$mickaURL}/opensearch.php" hreflang="{$lang2}" rel="search" title="OpenSearch" type="application/opensearchdescription+xml"/>
		
		<!-- self-referencing link to this feed -->
	    <link href="{$mickaURL}/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/2005/Atom&amp;id={gmd:fileIdentifier}" rel="self" hreflang="{$cl/language/value[@name]/@code2}" type="application/atom+xml" title="This document"/>

	  	<!-- links to INSPIRE Spatial Object Type definitions for this pre-defined dataset -->
	  	<!-- TO BE DONE -->
	    
	    <!-- link to this feed in another language -->
	    <!-- TO BE DONE -->
	    
	    <!-- upward link to the corresponding download service feed -->
		<xsl:variable name="vazby" select="php:function('getMetadata', concat('uuidRef=',gmd:fileIdentifier/*))"/>
	    <link rel="up" href="{$mickaURL}/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/2005/Atom&amp;id={$vazby//gmd:MD_Metadata/gmd:fileIdentifier/*}" hreflang="{$cl/language/value[@name]/@code2}" type="application/atom+xml" title="This document"/>
	    
	    <!-- identifier -->
      	<id><xsl:value-of select="concat($mickaURL, '/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/2005/Atom&amp;id=',gmd:fileIdentifier)"/></id>
      	
      	<!-- rights, access restrictions -->
      	<rights type="html"><xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
      		<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation">
 		  		<xsl:call-template name="multi">
		    		<xsl:with-param name="el" select="."/>
		    		<xsl:with-param name="lang" select="$LANGUAGE"/>
		    		<xsl:with-param name="mdlang" select="$mdlang"/>
		    	</xsl:call-template><xsl:if test="not(position()=last())"> | </xsl:if>	
      		</xsl:for-each>
      		<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>      	
      	</rights>
      	

		<!-- date/time this feed was last updated --> 
		<updated><xsl:value-of select="gmd:dateStamp"/>T00:00:00</updated>	

		<!-- author contact information -->
	  	<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
		  	<author>
	        	<name><xsl:value-of select="*/gmd:organisationName/*"/></name>
	        	<email><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/></email>
	    	</author>
	  	</xsl:for-each>

		<!-- entry for a "Dataset Feed" for a pre-defined dataset -->
		<xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn">
			<xsl:variable name="md" select="php:function('getData', string(@xlink:href))"/>
			<xsl:variable name="mdlang1" select="$md//gmd:language/gmd:LanguageCode/@codeListValue"/>
			<entry>
				<!-- INSPIRE dataset identifier -->
                <xsl:choose>
                    <xsl:when test="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/@xlink:href">
                        <inspire_dls:spatial_dataset_identifier_code><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/@xlink:href"/></inspire_dls:spatial_dataset_identifier_code>
                    </xsl:when>
                    <xsl:otherwise>
                        <inspire_dls:spatial_dataset_identifier_code><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*"/></inspire_dls:spatial_dataset_identifier_code>
                    </xsl:otherwise>
                </xsl:choose>
				
				<!-- optional namespace -->
				<xsl:if test="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace">
					<inspire_dls:spatial_dataset_identifier_namespace><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace"/></inspire_dls:spatial_dataset_identifier_namespace>
				</xsl:if>

				<!-- CRSs in which the pre-defined Dataset is available --> 
				<xsl:for-each select="$md//gmd:referenceSystemInfo">
					<category term="{*/gmd:referenceSystemIdentifier/*/gmd:code/*/@xlink:href}" label="{*/gmd:referenceSystemIdentifier/*/gmd:code}"/>
				</xsl:for-each>
				
				<!--  author FIXME - only certain roles? -->
				<xsl:for-each select="$md//gmd:identificationInfo/*/gmd:pointOfContact">
				  	<author>
			        	<name><xsl:value-of select="*/gmd:organisationName/*"/></name>
			        	<email><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/></email>
			    	</author>
				</xsl:for-each>
				
				<!-- link itself -->
				<id><xsl:value-of select="concat($mickaURL, '/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/2005/Atom&amp;id=', $md//gmd:fileIdentifier, '&amp;lang=',$LANGUAGE)"/></id>
				
				<!--link to subfeed for the dataset-->
				<link rel="alternate" href="{$mickaURL}/csw/?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/2005/Atom&amp;id={$md//gmd:fileIdentifier}&amp;lang={$LANGUAGE}" type="application/atom+xml" hreflang="en" title="Feed containing the dataset in several formats"/>
				
				<!-- link to dataset metadata record -->
				<link rel="describedby" href="{@xlink:href}" type="application/xml"/>
				
				<xsl:choose>		
					<xsl:when test="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*">
						<published><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/*"/>T00:00:00</published>							
					</xsl:when>
					<xsl:when test="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*">
						<published><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:date[*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/*"/>T00:00:00</published>							
					</xsl:when>
				</xsl:choose>
				
				<rights><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:useConstraints/*/@codeListValue='otherRestrictions']/*/gmd:otherConstraints"/></rights>
				
				<summary type="html"><xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
		      		<xsl:call-template name="multi">
			    		<xsl:with-param name="el" select="$md//gmd:identificationInfo/*/gmd:abstract"/>
			    		<xsl:with-param name="lang" select="$LANGUAGE"/>
			    		<xsl:with-param name="mdlang" select="$mdlang1"/>
			  		</xsl:call-template>
			  		<xsl:if test="$md//gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*">
			  			<div><img src="{$md//gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*}" /></div>
			  			<xsl:call-template name="multi">
			    			<xsl:with-param name="el" select="$md//gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileDescription"/>
			    			<xsl:with-param name="lang" select="$LANGUAGE"/>
			    			<xsl:with-param name="mdlang" select="$mdlang"/>
			  			</xsl:call-template>
			  		</xsl:if>	
			  		<div>Metadata:
			  			<a href="{$mickaURL}/record/basic/{$md//gmd:fileIdentifier}" target="_blank">HTML</a><xsl:text> </xsl:text>
			  			<a href="{$mickaURL}/record/xml/{$md//gmd:fileIdentifier}" title="ISO 19139" target="_blank">XML</a><xsl:text> </xsl:text>
			  			<a href="{$mickaURL}/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;outputSchema=http://www.w3.org/ns/dcat%23&amp;id={$md//gmd:fileIdentifier}" title="INSPIRE GeoDCAT-AP RDF/XML" target="_blank">GeoDCAT</a>
			  		</div>
			  		<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
			  	</summary>
			  	
			  	<!-- dataset title -->
				<title>
		      		<xsl:call-template name="multi">
			    		<xsl:with-param name="el" select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
			    		<xsl:with-param name="lang" select="$LANGUAGE"/>
			    		<xsl:with-param name="mdlang" select="$mdlang1"/>
			  		</xsl:call-template>
				</title>
				
				<!-- dataset metadata update -->
				<updated><xsl:value-of select="$md//gmd:dateStamp"/>T00:00:00</updated>
				
		      	<xsl:for-each select="$md//gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
			        <georss:polygon>
				      	<xsl:value-of select="gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:southBoundLatitude"/>
				      	<xsl:text> </xsl:text>
				      	<xsl:value-of select="gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:northBoundLatitude"/>
				      	<xsl:text> </xsl:text>
				      	<xsl:value-of select="gmd:eastBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:northBoundLatitude"/>
				      	<xsl:text> </xsl:text>
				       	<xsl:value-of select="gmd:eastBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:southBoundLatitude"/>
				      	<xsl:text> </xsl:text>
				      	<xsl:value-of select="gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:southBoundLatitude"/>
			        </georss:polygon>
		      	</xsl:for-each>
				
			</entry>
		</xsl:for-each>

		<!-- dataset extent -->
		<xsl:variable name="bbox">
	      	<xsl:for-each select="gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
		        <georss:polygon>
			      	<xsl:value-of select="gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:southBoundLatitude"/>
			      	<xsl:text> </xsl:text>
			      	<xsl:value-of select="gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:northBoundLatitude"/>
			      	<xsl:text> </xsl:text>
			      	<xsl:value-of select="gmd:eastBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:northBoundLatitude"/>
			      	<xsl:text> </xsl:text>
			       	<xsl:value-of select="gmd:eastBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:southBoundLatitude"/>
			      	<xsl:text> </xsl:text>
			      	<xsl:value-of select="gmd:westBoundLongitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:southBoundLatitude"/>
		        </georss:polygon>
	      	</xsl:for-each>
		</xsl:variable> 

		<!-- dataset update date -->
		<xsl:variable name="updated">
			<xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:date/*/gmd:date/*"/>
		</xsl:variable> 
		
      	<!-- download links for pre-defined datasets -->
	    <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(*/gmd:protocol,'DOWNLOAD') or contains(*/gmd:protocol,'download')]">
	      	<xsl:variable name="desc">
				<xsl:call-template name="multi">
			   		<xsl:with-param name="el" select="*/gmd:description"/>
			   		<xsl:with-param name="lang" select="$LANGUAGE"/>
			   		<xsl:with-param name="mdlang" select="$mdlang"/>
				</xsl:call-template>
			</xsl:variable>
			<entry>
				<id><xsl:value-of select="*/gmd:linkage"/></id>
		      	<!-- descriptive summary -->
	      		<xsl:variable name="pos" select="position()"/>
	    		<!-- <xsl:variable name="f" select="//gmd:distributionInfo/*/gmd:distributionFormat[$pos]"/> -->
	    		<!-- predpoklad, ze vsechny jsou stejneho typu -->
	    		<xsl:variable name="ff" select="translate(*/gmd:name, $upper, $lower)"/>
	    		<xsl:variable name="filetype">
		    		<xsl:choose>
		    			<xsl:when test="contains($ff,'shp') or contains($ff,'shapefile')">application/x-shapefile</xsl:when>
		    			<xsl:when test="contains($ff,'tiff') or contains($ff,'tif')">image/tiff</xsl:when>
		    			<xsl:when test="contains($ff,'jpg') or contains($ff,'jpeg')">image/jpeg</xsl:when>
		    			<xsl:when test="contains($ff,'gml') and contains($ff,'zip')">application/x-gmz</xsl:when>
		    			<xsl:when test="contains($ff,'gml')">application/gml+xml</xsl:when>
		    			<xsl:when test="contains($ff,'kml')">application/vnd.google-earth.kml+xml</xsl:when>
		    			<xsl:when test="contains($ff,'kmz')">application/vnd.google-earth.kmz</xsl:when>
		    			<xsl:otherwise><xsl:value-of select="$ff"/></xsl:otherwise>
		    		</xsl:choose>
	    		</xsl:variable>
	      		<link rel="alternate" href="{*/gmd:linkage/*}" title="{$desc}" type="{$filetype}"/>
		      	<summary type="html">
		      		<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
			      	<xsl:call-template name="multi">
				    	<xsl:with-param name="el" select="*/gmd:description"/>
				    	<xsl:with-param name="lang" select="$LANGUAGE"/>
				    	<xsl:with-param name="mdlang" select="$mdlang"/>
				  	</xsl:call-template>
			  		<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
			  	</summary>
				<title>
					<xsl:choose>
						<xsl:when test="*/gmd:name">
				    		<!-- title for pre-defined dataset -->
					    	<xsl:call-template name="multi">
						   		<xsl:with-param name="el" select="*/gmd:name"/>
						   		<xsl:with-param name="lang" select="$LANGUAGE"/>
						   		<xsl:with-param name="mdlang" select="$mdlang"/>
							</xsl:call-template>
					  	</xsl:when>
						<xsl:when test="*/gmd:description">
				    		<!-- title for pre-defined dataset -->
					    	<xsl:value-of select="$desc"/>
					  	</xsl:when>
					  	<xsl:otherwise>
					  		<xsl:value-of select="*/gmd:linkage"/>
					  	</xsl:otherwise>
				  	</xsl:choose>
			  	</title>
			  	<updated><xsl:value-of select="$updated"/>T00:00:00</updated>
		  		<xsl:copy-of select="$bbox"/>
		  			
			  	<!-- rights, access restrictions 
		      	<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints">
		      		<rights><xsl:value-of select="./*"/></rights>
		      	</xsl:for-each> -->
			  			  	
	    	</entry>
	    </xsl:for-each>
	   
	    <!-- vnejsi seznam - jeste vylepsit -->
	    <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[*/gmd:function/*/@codeListValue='information']">
			<xsl:copy-of select="document(*/gmd:linkage/*)/*/*"/>
	    </xsl:for-each>

    </feed>
</xsl:template>

<xsl:template match="csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
    <item>
      <title><xsl:value-of select="dc:title"/></title>
      <guid isPermaLink="false">urn:uuid:<xsl:value-of select="dc:identifier[1]"/></guid>
      <link><xsl:value-of select="$mickaURL"/>/../micka_main.php?ak=detail&amp;lang=<xsl:value-of select="$LANGUAGE"/>&amp;uuid=<xsl:value-of select="dc:identifier[1]"/></link>
      <description><xsl:value-of select="dct:abstract"/></description>
      <pubDate><xsl:call-template name="formatDate">
          <xsl:with-param name="DateTime" select="dc:date"/>
        </xsl:call-template> 00:00:00 GMT</pubDate>
      <xsl:for-each select="ows:BoundingBox">
        <georss:polygon>
	      	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="substring-after(ows:UpperCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="substring-after(ows:UpperCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:UpperCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:UpperCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
        </georss:polygon>
      </xsl:for-each>
    </item>
</xsl:template>

<xsl:template name="formatDate">
	<xsl:param name="DateTime" />
	<!-- date format 1998-03-15[T13:00:00] -->

	<xsl:variable name="year">
		<xsl:value-of select="substring-before($DateTime,'-')" />
	</xsl:variable>
	<xsl:variable name="mo-temp">
		<xsl:value-of select="substring-after($DateTime,'-')" />
	</xsl:variable>
	<xsl:variable name="mo">
		<xsl:value-of select="substring-before($mo-temp,'-')" />
	</xsl:variable>
	<xsl:variable name="day-t">
		<xsl:value-of select="substring-after($mo-temp,'-')" />
	</xsl:variable>
	<xsl:variable name="day">
		<xsl:choose> 
		  <xsl:when test="substring-before($day-t,'T')!=''">
		  	<xsl:value-of select="substring-before($day-t,'T')" />
		  </xsl:when>
		  <xsl:otherwise>
		  	<xsl:value-of select="$day-t" />
		  </xsl:otherwise>
		</xsl:choose>  
	</xsl:variable>

	<xsl:if test="$day != '00'">
		<xsl:value-of select="$day"/>
		<xsl:value-of select="' '"/>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="$mo = '1' or $mo = '01'">Jan </xsl:when>
		<xsl:when test="$mo = '2' or $mo = '02'">Feb </xsl:when>
		<xsl:when test="$mo = '3' or $mo = '03'">Mar </xsl:when>
		<xsl:when test="$mo = '4' or $mo = '04'">Apr </xsl:when>
		<xsl:when test="$mo = '5' or $mo = '05'">May </xsl:when>
		<xsl:when test="$mo = '6' or $mo = '06'">Jun </xsl:when>
		<xsl:when test="$mo = '7' or $mo = '07'">Jul </xsl:when>
		<xsl:when test="$mo = '8' or $mo = '08'">Aug </xsl:when>
		<xsl:when test="$mo = '9' or $mo = '09'">Sep </xsl:when>
		<xsl:when test="$mo = '10'">Oct </xsl:when>
		<xsl:when test="$mo = '11'">Nov </xsl:when>
		<xsl:when test="$mo = '12'">Dec </xsl:when>
		<xsl:when test="$mo = '0' or $mo = '00'"></xsl:when><!-- do nothing -->
	</xsl:choose>
	<xsl:value-of select="$year"/>
</xsl:template> 

<xsl:include href="client/common_cli.xsl" />
  
</xsl:stylesheet>