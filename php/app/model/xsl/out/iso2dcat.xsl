<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"	 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:dcl="http://dclite4g.xmlns.com/schema.rdf#" 
	xmlns:dcat="http://www.w3.org/ns/dcat#"
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"  
  	xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmx="http://www.isotc211.org/2005/gmx"
  	xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:locn="http://w3.org/ns/locn#"
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#"   
	xmlns:schema="http://schema.org/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:prov="http://www.w3.org/ns/prov#" 
  	xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:wdrs="http://www.w3.org/2007/05/powder-s#"
	xmlns:earl="http://www.w3.org/ns/earl#" 
	xmlns:cnt="http://www.w3.org/2011/content#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:adms="http://www.w3.org/ns/adms#"
	xmlns:php="http://php.net/xsl" 
    exclude-result-prefixes="gco gmd gmx dct php"
	>
<xsl:output method="xml" indent="yes" encoding="UTF-8" />

    <xsl:variable name="clc" select="document('../codelists4dcat.xml')/codes"/>
    <xsl:variable name="cl" select="document('../codelists.xml')/map"/>
    <xsl:variable name="mdr" select="document('../inspire-themes-to-mdr-data-themes.rdf.xml')/rdf:RDF"/>
    <xsl:variable name="cURI">http://inspire.ec.europa.eu/metadata-codelist</xsl:variable>
    <xsl:variable name="xsd">http://www.w3.org/2001/XMLSchema#</xsl:variable>
	<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
	<xsl:variable name="apos">\'</xsl:variable>

<xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata">
 	<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"/>
    <xsl:variable name="ser">
    	<xsl:choose>
    		<xsl:when test="gmd:identificationInfo/srv:SV_ServiceIdentification != ''">dcat:Service</xsl:when>
    		<xsl:otherwise>dcat:Dataset</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>	

	<rdf:Description>
    	<xsl:attribute name="rdf:about">?service=CSW&amp;request=GetRecordById&amp;id=<xsl:value-of select="gmd:fileIdentifier"/></xsl:attribute>
		 
		 <!-- METADATA on Metadata -->
		 <foaf:isPrimaryTopicOf>
		 	<rdf:Description>
		 		<rdf:type rdf:resource="http://www.w3.org/ns/dcat#CatalogRecord"/>
			 	<dct:modified rdf:datatype="{$xsd}date"><xsl:value-of select="gmd:dateStamp/*"/></dct:modified>
				<dct:language rdf:resource="http://publications.europa.eu/resource/authority/language/{translate($mdlang, $lower, $upper)}"/>
		 		<xsl:for-each select="gmd:contact">
		 			<!--xsl:choose>
			 			<xsl:when test="*/gmd:role/*/@codeListValue='pointOfContact'"-->
						 	<dcat:contactPoint>		 			
						 		<xsl:call-template name="vcard">
						 			<xsl:with-param name="mdlang" select="$mdlang"/>
						 			<xsl:with-param name="c" select="gmd:CI_ResponsibleParty"/>
						 			<xsl:with-param name="uri" select="gmd:CI_ResponsibleParty/gmd:organisationName/*/@xlink:href"/>
						 		</xsl:call-template>
				          	</dcat:contactPoint>
			          	<!--/xsl:when>
			          	<xsl:otherwise-->
				          	<prov:qualifiedAttribution>
			    				<prov:Attribution>
				    				<prov:agent>
								 		<xsl:call-template name="vcard">
								 			<xsl:with-param name="mdlang" select="$mdlang"/>
								 			<xsl:with-param name="c" select="gmd:CI_ResponsibleParty"/>
								 		</xsl:call-template>
									</prov:agent>
									 <dct:type rdf:resource="{$cURI}/ResponsiblePartyRole/{*/gmd:role/*/@codeListValue}"/>
			    				</prov:Attribution>
		    				</prov:qualifiedAttribution>
			          	<!--/xsl:otherwise>
		          	</xsl:choose-->
	          	</xsl:for-each>
	          	<dct:identifier rdf:datatype="{$xsd}string"><xsl:value-of select="gmd:fileIdentifier/*"/></dct:identifier>	
				<dct:source rdf:parseType="Resource">
                    <!-- Character encoding -->
                    <xsl:for-each select="gmd:identificationInfo/*/gmd:characterSet">
                        <xsl:variable name="ch" select="*/@codeListValue"/>
                        <cnt:characterEncoding rdf:datatype="{$xsd}string"><xsl:value-of select="$clc/charSet/value[@code=$ch]"/></cnt:characterEncoding> 
                    </xsl:for-each>
					<dct:conformsTo rdf:parseType="Resource">
						<dct:title><xsl:value-of select="gmd:metadataStandardName/*"/></dct:title>
						<owl:versionInfo><xsl:value-of select="gmd:metadataStandardVersion/*"/></owl:versionInfo>
					</dct:conformsTo>
				</dct:source>
			</rdf:Description>
		</foaf:isPrimaryTopicOf>
		 
		 
	  	<!-- Resource type -->
	  	<xsl:choose>
			<!-- Service Type - not stable -->
			<xsl:when test="gmd:hierarchyLevel/*/@codeListValue='service'">
		  		<rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
				<dct:type rdf:resource="{$cURI}/ResourceType/service"/>
				<dct:type rdf:resource="{$cURI}/SpatialDataServiceType/{gmd:identificationInfo/*/srv:serviceType}"/>
			</xsl:when>
	  		<xsl:otherwise>
		  		<rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
		  		<dct:type rdf:resource="{$cURI}/ResourceType/{gmd:hierarchyLevel/*/@codeListValue}"/>
		  	</xsl:otherwise>
		</xsl:choose>		    	   

		<!-- Title -->
		<xsl:call-template name="rmulti">
   			<xsl:with-param name="l" select="$mdlang"/>
   			<xsl:with-param name="e" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
   			<xsl:with-param name="n" select="'dct:title'"/>
   		</xsl:call-template>

		<!-- Abstract -->
		<xsl:call-template name="rmulti">
   			<xsl:with-param name="l" select="$mdlang"/>
   			<xsl:with-param name="e" select="gmd:identificationInfo/*/gmd:abstract"/>
   			<xsl:with-param name="n" select="'dct:description'"/>
   		</xsl:call-template>

    	<!-- Topic category -->
    	<xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
    		<dct:subject rdf:resource="http://inspire.ec.europa.eu/metadata-codelist/TopicCategory/{*}"/>
    	</xsl:for-each>	
      
        <!-- Maintenance and update frequency -->
        <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceMaintenance">
            <xsl:variable name="ch" select="*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>
            <dct:accrualPeriodicity rdf:resource="{$cURI}/MaintenanceFrequencyCode/{$clc/maintenanceAndUpdateFrequency/value[@code=$ch]}{$ch}"/>
        </xsl:for-each>

        <!-- scale -->
        <xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator">
            <rdfs:comment xml:lang="en">Spatial resolution (equivalent scale): <xsl:value-of select="./*"/></rdfs:comment>
        </xsl:for-each>

      	<!-- Coupled resource -->
		<xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn">
			<xsl:variable name="link">
				<xsl:choose>
					<xsl:when test="contains(@xlink:href, '#')"><xsl:value-of select="substring-before(@xlink:href, '#')"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="@xlink:href"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="md" select="php:function('getData', $link)"/>
			<dct:hasPart rdf:parseType="Resource">
				<dct:identifier rdf:datatype="{$xsd}{php:function('isURI', string($md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code))}"><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*"/></dct:identifier>
				<foaf:isPrimaryTopicOf>
					<dcat:CatalogRecord rdf:about="{php:function('str_replace','=http://www.isotc211.org/2005/gmd', '=http://www.w3.org/ns/dcat%23', $link)}"/>
				</foaf:isPrimaryTopicOf>			
			</dct:hasPart>
      	</xsl:for-each>
      				      
		<!-- ADDED - parent identifier ... -->
		<xsl:if test="gmd:parentIdentifier/*!=''">
			<xsl:variable name="md" select="php:function('getData', concat('?service=CSW&amp;request=GetRecordById&amp;id=',gmd:parentIdentifier/*,'&amp;outputSchema=http://www.isotc211.org/2005/gmd'))"/>
			<dct:isPartOf rdf:parseType="Resource">
				<dct:identifier rdf:datatype="{$xsd}{php:function('isURI', string($md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code))}"><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*"/></dct:identifier>
				<foaf:isPrimaryTopicOf>
					<dcat:CatalogRecord rdf:about="{$thisPath}/csw?service=CSW&amp;request=GetRecordById&amp;id={gmd:parentIdentifier/*}&amp;outputschema=http://www.w3.org/ns/dcat%23"/>
				</foaf:isPrimaryTopicOf>			
			</dct:isPartOf>
		</xsl:if>

		<!-- ADDED - children ... -->
		<xsl:variable name="subsets" select="php:function('getMetadata', concat('ParentIdentifier=', $apos, gmd:fileIdentifier/*, $apos))"/>		
		<xsl:for-each select="$subsets//gmd:MD_Metadata">
			<dct:hasPart rdf:parseType="Resource">
				<dct:identifier rdf:datatype="{$xsd}{php:function('isURI', string(gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code))}"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*"/></dct:identifier>
				<foaf:isPrimaryTopicOf>
					<dcat:CatalogRecord rdf:about="{$thisPath}/csw?service=CSW&amp;request=GetRecordById&amp;id={gmd:fileIdentifier/*}&amp;outputschema=http://www.w3.org/ns/dcat%23"/>
				</foaf:isPrimaryTopicOf>			
			</dct:hasPart>
		</xsl:for-each>

		<!-- Resource identifier -->
		<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier">
			<dct:identifier rdf:datatype="{$xsd}{php:function('isURI',string(*/gmd:code))}"><xsl:value-of select="*/gmd:code/*"/></dct:identifier>
		</xsl:for-each>
		
		<!-- Resource language -->
		<xsl:for-each select="gmd:identificationInfo/*/gmd:language">
	    	<dct:language rdf:resource="http://publications.europa.eu/resource/authority/language/{translate(*/@codeListValue, $lower, $upper)}"/>
	    </xsl:for-each>
      
      	<!-- Geographic bounding box -->
      	<dct:spatial rdf:parseType="Resource">
            <xsl:variable name="x1" select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/*"/>
            <xsl:variable name="y1" select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/*"/>
            <xsl:variable name="x2" select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/*"/>
            <xsl:variable name="y2" select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/*"/>
			<locn:geometry rdf:datatype="http://www.opengis.net/ont/geosparql#gmlLiteral"><xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
				<gml:Envelope srsName='http://www.opengis.net/def/crs/OGC/1.3/CRS84'>
					<gml:lowerCorner><xsl:value-of select="$x1"/><xsl:text> </xsl:text><xsl:value-of select="$y1"/></gml:lowerCorner>
					<gml:upperCorner><xsl:value-of select="$x2"/><xsl:text> </xsl:text><xsl:value-of select="$y2"/></gml:upperCorner>
				</gml:Envelope><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
             </locn:geometry>
			<locn:geometry rdf:datatype="https://www.iana.org/assignments/media-types/application/vnd.geo+json">
                <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                    {"type":"Polygon","crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:OGC:1.3:CRS84"}},
                    "coordinates":[[
                        [<xsl:value-of select="$x1"/>,<xsl:value-of select="$y1"/>],
                        [<xsl:value-of select="$x1"/>,<xsl:value-of select="$y2"/>],
                        [<xsl:value-of select="$x2"/>,<xsl:value-of select="$y2"/>],
                        [<xsl:value-of select="$x2"/>,<xsl:value-of select="$y1"/>],
                        [<xsl:value-of select="$x1"/>,<xsl:value-of select="$y1"/>]
                        ]]}<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
            </locn:geometry>
 			<locn:geometry rdf:datatype="http://www.opengis.net/ont/geosparql#wktLiteral"><xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                POLYGON((<xsl:value-of select="$x1"/><xsl:text> </xsl:text><xsl:value-of select="$y1"/>,
                        <xsl:value-of select="$x1"/><xsl:text> </xsl:text><xsl:value-of select="$y2"/>,
                        <xsl:value-of select="$x2"/><xsl:text> </xsl:text><xsl:value-of select="$y2"/>,
                        <xsl:value-of select="$x2"/><xsl:text> </xsl:text><xsl:value-of select="$y1"/>,
                        <xsl:value-of select="$x1"/><xsl:text> </xsl:text><xsl:value-of select="$y1"/>))<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
            </locn:geometry>
     	</dct:spatial>
		<xsl:for-each select="gmd:identificationInfo//gmd:EX_GeographicDescription/gmd:geographicIdentifier">
			<dct:spatial rdf:resource="{*/gmd:code/*/@xlink:href}"/>
		</xsl:for-each>				
      
	  	<!-- Temporal reference -->
	  	<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
	  		<xsl:choose>
	  			<xsl:when test="*/gmd:dateType/*/@codeListValue='creation'">
	  				<dct:created rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:date/*"/></dct:created>
	  			</xsl:when>
	  			<xsl:when test="*/gmd:dateType/*/@codeListValue='publication'">
	  				<dct:issued rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:date/*"/></dct:issued>
	  			</xsl:when>
	  			<xsl:when test="*/gmd:dateType/*/@codeListValue='revision'">
	  				<dct:modified rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:date/*"/></dct:modified>
	  			</xsl:when>
	  		</xsl:choose>
	  	</xsl:for-each>
	  
	  	<!-- Temporal extent -->
	  	<xsl:for-each select="gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement">
	  		<dct:temporal>
		  		<xsl:choose>
		  			<xsl:when test="*/gmd:extent//gml:beginPosition">
		  				<dct:PeriodOfTime>
		  					<schema:startDate rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:extent//gml:beginPosition"/></schema:startDate>
		  					<schema:endDate rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:extent//gml:endPosition"/></schema:endDate>
		  				</dct:PeriodOfTime>
		  			</xsl:when>
		  			<xsl:when test="*/gmd:extent//gml:timePosition">
		  				<!--  <dct:valid rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:extent//gml:timePosition"/></dct:valid>-->
		  				<dct:PeriodOfTime>
		  					<schema:startDate rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:extent//gml:timePosition"/></schema:startDate>
		  					<schema:endDate rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:extent//gml:timePosition"/></schema:endDate>
		  				</dct:PeriodOfTime>
		  			</xsl:when>
		  		</xsl:choose>
	  		</dct:temporal>
		</xsl:for-each>
	  
      	<!-- Lineage -->
      	<xsl:if test="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement">
  	    	<dct:provenance>
  		    	<dct:ProvenanceStatement>
        			<xsl:call-template name="rmulti">
     				   <xsl:with-param name="l" select="$mdlang"/>
     				   <xsl:with-param name="e" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
     				   <xsl:with-param name="n" select="'rdfs:label'"/>
     			  	</xsl:call-template>     		
        		</dct:ProvenanceStatement>
        	</dct:provenance>
      	</xsl:if>
		
		<!-- Conformity old? -->
		<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result[contains(*/gmd:specification/*/gmd:title,'INSPIRE') or contains(translate(*/gmd:specification/*/gmd:title,$lower,$upper),'COMMISSION')]">
            <xsl:if test="*/gmd:pass/*='true'">
                <!-- try to find text and corresponding uri in the codelist -->
                <xsl:variable name="spec">
                    <xsl:call-template name="rmulti">
                        <xsl:with-param name="l" select="$mdlang"/>
                        <xsl:with-param name="e" select="*/gmd:specification/*/gmd:title"/>
                        <xsl:with-param name="n" select="'dct:title'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="spec1" select="$cl/serviceSpecifications/value[contains(normalize-space($spec),*/@name)]/@uri"/>
                <xsl:choose>
                    <xsl:when test="$spec1">
                        <dct:conformsTo rdf:resource="http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri={$spec1}:EN:NOT"/>
                    </xsl:when>
                    <!-- if not, literal value is used -->
                    <xsl:otherwise>
                        <dct:conformsTo>
                            <rdf:Description>
                                    <xsl:call-template name="rmulti">
                                        <xsl:with-param name="l" select="$mdlang"/>
                                        <xsl:with-param name="e" select="*/gmd:specification/*/gmd:title"/>
                                        <xsl:with-param name="n" select="'dct:title'"/>
                                    </xsl:call-template>
                                    <dct:issued rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:specification/*/gmd:date/*/gmd:date/*"/></dct:issued>
                            </rdf:Description>
                        </dct:conformsTo>
                    </xsl:otherwise>
                </xsl:choose>
			</xsl:if>
			<!--wdrs:describedby>
				<earl:Assertion>
					<earl:result>
						<earl:TestResult>
							<xsl:choose>
							  	<xsl:when test="*/gmd:pass/*='true'"><earl:outcome rdf:resource="http://inspire.ec.europa.eu/metadata-codelist/DegreeOfConformity/conformant"/></xsl:when>
							  	<xsl:when test="*/gmd:pass/*='false'"><earl:outcome rdf:resource="http://inspire.ec.europa.eu/metadata-codelist/DegreeOfConformity/nonConformant"/></xsl:when>
							  	<xsl:otherwise><earl:outcome rdf:resource="http://inspire.ec.europa.eu/metadata-codelist/DegreeOfConformity/notEvaluated"/></xsl:otherwise>
							</xsl:choose>
						</earl:TestResult>
					</earl:result>
					<earl:test>
						<earl:TestCase>
					    <xsl:call-template name="rmulti">
					   		<xsl:with-param name="l" select="$mdlang"/>
					   		<xsl:with-param name="e" select="*/gmd:specification/*/gmd:title"/>
					   		<xsl:with-param name="n" select="'dct:title'"/>
					   	</xsl:call-template>
						<dct:issued rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:specification/*/gmd:date/*/gmd:date"/></dct:issued>
					   	</earl:TestCase>
					</earl:test>
				</earl:Assertion>
			</wdrs:describedby-->
		</xsl:for-each>

        <!-- conformity2 -->
        <xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result[string-length(*/gmd:specification/*/gmd:title/*)>0]">
        	<prov:wasUsedBy>
               <!-- try to find text and corresponding uri in the codelist -->
                <xsl:variable name="spec">
                    <xsl:call-template name="rmulti">
                        <xsl:with-param name="l" select="$mdlang"/>
                        <xsl:with-param name="e" select="*/gmd:specification/*/gmd:title"/>
                        <xsl:with-param name="n" select="'dct:title'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="spec1" select="$cl/serviceSpecifications/value[contains(normalize-space($spec),*/@name)]/@uri"/>
                <prov:Activity>
                  <!--xsl:if test="$ResourceUri != ''">
                    <prov:used rdf:resource="{$ResourceUri}"/>
                  </xsl:if-->
                  <prov:qualifiedAssociation rdf:parseType="Resource">
                    <prov:hadPlan rdf:parseType="Resource">
                      <xsl:choose>
                        <xsl:when test="*/gmd:specification/*/gmd:title/*/@xlink:href">
                          <prov:wasDerivedFrom rdf:resource="{*/gmd:specification/*/gmd:title/*/@xlink:href}"/>
        <!--                  
                          <prov:wasDerivedFrom>
                            <rdf:Description rdf:about="{../@xlink:href}">
                              <xsl:copy-of select="$specinfo"/>
                            </rdf:Description>
                          </prov:wasDerivedFrom>
        -->                  
                        </xsl:when>
                        <xsl:when test="$spec1">
                             <prov:wasDerivedFrom rdf:resource="http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri={$spec1}:EN:NOT"/>   
                        </xsl:when>
                        <xsl:otherwise>
                          <prov:wasDerivedFrom rdf:parseType="Resource">
                                <dct:issued rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:specification/*/gmd:date/*/gmd:date"/></dct:issued>
                                <xsl:call-template name="rmulti">
                                    <xsl:with-param name="l" select="$mdlang"/>
                                    <xsl:with-param name="e" select="*/gmd:specification/*/gmd:title"/>
                                    <xsl:with-param name="n" select="'dct:title'"/>
                                </xsl:call-template>
                          </prov:wasDerivedFrom>
                        </xsl:otherwise>
                      </xsl:choose>
                    </prov:hadPlan>
                  </prov:qualifiedAssociation>
                  <prov:generated rdf:parseType="Resource">
                    <xsl:choose>
                        <xsl:when test="*/gmd:pass/*='true'"><earl:outcome rdf:resource="{$cURI}/DegreeOfConformity/conformant"/></xsl:when>
                        <xsl:when test="*/gmd:pass/*='false'"><earl:outcome rdf:resource="{$cURI}/DegreeOfConformity/nonConformant"/></xsl:when>
                        <xsl:otherwise><earl:outcome rdf:resource="{$cURI}/DegreeOfConformity/notEvaluated"/></xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="*/gmd:explanation">
                        <xsl:call-template name="rmulti">
                            <xsl:with-param name="l" select="$mdlang"/>
                            <xsl:with-param name="e" select="*/gmd:explanation"/>
                            <xsl:with-param name="n" select="'dct:description'"/>
                        </xsl:call-template>                       
                    </xsl:if>
                  </prov:generated>
                </prov:Activity>
	        </prov:wasUsedBy>
        </xsl:for-each>
        
        <xsl:variable name="ii" select="gmd:identificationInfo"/>
        
		<!-- linkage (res. locator) -->
		<xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
			<dcat:distribution>
				<dcat:Distribution>
					<xsl:for-each select="*/gmd:name">
                  		<xsl:call-template name="rmulti">
                            <xsl:with-param name="l" select="$mdlang"/>
                            <xsl:with-param name="e" select="."/>
                            <xsl:with-param name="n" select="'dct:title'"/>
                        </xsl:call-template> 
                	</xsl:for-each>
                	<xsl:for-each select="*/gmd:description">
                  		<xsl:call-template name="rmulti">
                            <xsl:with-param name="l" select="$mdlang"/>
                            <xsl:with-param name="e" select="."/>
                            <xsl:with-param name="n" select="'dct:description'"/>
                        </xsl:call-template> 
                	</xsl:for-each>
					
					<xsl:choose>
						<xsl:when test="$ser='dcat:Service'">
							 <foaf:homepage rdf:resource="{*/gmd:linkage/gmd:URL}"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="f" select="*/gmd:function/*/@codeListValue"/>
							<xsl:choose>
								<xsl:when test="$f='download' or $f='offlineAccess’ or $f='order">
									<dcat:accessURL rdf:resource="{*/gmd:linkage/gmd:URL}"/>
								</xsl:when>
								<xsl:when test="$f='information' or $f='search'">
									<foaf:page rdf:resource="{*/gmd:linkage/gmd:URL}"/>
								</xsl:when>
								<xsl:otherwise>
									<dcat:landingPage rdf:resource="{*/gmd:linkage/gmd:URL}"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					
					<!-- Conditions for access and use -->
					<xsl:for-each select="$ii/*/gmd:resourceConstraints[*/gmd:useConstraints/*/@codeListValue='otherRestrictions']">
						<xsl:choose>
							<xsl:when test="*/gmd:otherConstraints/*/@xlink:href">
								<dct:license rdf:resource="{*/gmd:otherConstraints/*/@xlink:href}"/>
							</xsl:when>
							<xsl:otherwise>
								<dct:license>
									<dct:LicenseDocument>
						     			<xsl:call-template name="rmulti">
						   					<xsl:with-param name="l" select="$mdlang"/>
						   					<xsl:with-param name="e" select="*/gmd:otherConstraints"/>
						   					<xsl:with-param name="n" select="'rdfs:label'"/>
						   				</xsl:call-template>
									</dct:LicenseDocument>
								</dct:license>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
	
					<!-- Limitations on public access  -->			
					<xsl:for-each select="$ii/*/gmd:resourceConstraints[*/gmd:accessConstraints/*/@codeListValue='otherRestrictions']">
                        <dct:accessRights>
                            <xsl:choose>
                                <xsl:when test="*/gmd:otherConstraints/*/@xlink:href">
                                    <xsl:attribute name="rdf:resource" select="*/gmd:otherConstraints/*/@xlink:href"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <dct:RightsStatement>
                                        <xsl:call-template name="rmulti">
                                            <xsl:with-param name="l" select="$mdlang"/>
                                            <xsl:with-param name="e" select="*/gmd:otherConstraints"/>
                                            <xsl:with-param name="n" select="'rdfs:label'"/>
                                        </xsl:call-template>
                                    </dct:RightsStatement>
                                </xsl:otherwise>
                            </xsl:choose>
						</dct:accessRights>
					</xsl:for-each>
				
				    <xsl:if test="$ii/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode">
				    	<adms:representationTechnique rdf:resource="{$cURI}/SpatialRepresentationTypeCode/{gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue}"/>
				    </xsl:if>
                    
                    <!-- Encoding (format) -->
                    <!-- <xsl:for-each select="gmd:distributionInfo/*/gmd:characterSet">
                        <dcat:mediaType><xsl:value-of select="*/@codeListValue"/></dcat:mediaType>
                    </xsl:for-each> -->
                    <xsl:variable name="mime" select="php:function('getMime',string(*/gmd:description/*))"/>
                    <xsl:variable name="m" select="$cl/format/value[@code=$mime]/@uri"/>
                    <xsl:choose>
                        <xsl:when test="$m">
                            <dct:format rdf:resource="{$m}"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:for-each select="../../../gmd:distributionFormat/*/gmd:name/*">
                            <xsl:choose>
                              <xsl:when test="@xlink:href and @xlink:href != ''">
                                <dct:format rdf:resource="{@xlink:href}"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <dct:format rdf:parseType="Resource">
                                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                                </dct:format>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
 				</dcat:Distribution>
			</dcat:distribution>
		</xsl:for-each>
			
	
		<!-- Responsible party -->
	    <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
	    	<xsl:choose>
	    		<xsl:when test="*/gmd:role/*/@codeListValue='pointOfContact'">
    		
	    			<dcat:contactPoint>
				 		<xsl:call-template name="vcard">
				 			<xsl:with-param name="mdlang" select="$mdlang"/>
				 			<xsl:with-param name="c" select="gmd:CI_ResponsibleParty"/>
				 		</xsl:call-template>
	    			</dcat:contactPoint>
	    		</xsl:when>
	    		<xsl:when test="*/gmd:role/*/@codeListValue='originator'">
	    			<dct:creator>
	    				<foaf:Organization>
	 			     		<xsl:call-template name="rmulti">
				   				<xsl:with-param name="l" select="$mdlang"/>
				   				<xsl:with-param name="e" select="*/gmd:organisationName"/>
				   				<xsl:with-param name="n" select="'vcard:organization-name'"/>
				   			</xsl:call-template>
	    					<vcard:hasEmail><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/></vcard:hasEmail>
                            <xsl:for-each select="*/gmd:contactInfo/*/gmd:phone/*/gmd:voice">
                                <vcard:hasTelephone rdf:parseType="Resource">
                                    <vcard:hasValue rdf:resource="tel:{*}"/>
                                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Voice"/>
                                </vcard:hasTelephone>
                            </xsl:for-each>
                            <xsl:for-each select="*/gmd:contactInfo/*/gmd:address">
                                <vcard:adr rdf:parseType="Resource">
                           	       <vcard:street-address><xsl:value-of select="*/gmd:deliveryPoint"/></vcard:street-address>
                                   <vcard:locality><xsl:value-of select="*/gmd:city"/></vcard:locality>
                           	       <vcard:postal-code><xsl:value-of select="*/gmd:postalCode"/></vcard:postal-code>
                                   <xsl:for-each select="*/gmd:country"><vcard:country-name><xsl:value-of select="*"/></vcard:country-name></xsl:for-each>
                                </vcard:adr>                                           
                            </xsl:for-each>
	    				</foaf:Organization>
	    			</dct:creator>
	    		</xsl:when>
	    		<xsl:when test="*/gmd:role/*/@codeListValue='owner'">
	    			<dct:rightsHolder>
	    				<foaf:Organization>
	 			     		<xsl:call-template name="rmulti">
				   				<xsl:with-param name="l" select="$mdlang"/>
				   				<xsl:with-param name="e" select="*/gmd:organisationName"/>
				   				<xsl:with-param name="n" select="'vcard:organization-name'"/>
				   			</xsl:call-template>
	    					<vcard:hasEmail><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/></vcard:hasEmail>
                            <xsl:for-each select="*/gmd:contactInfo/*/gmd:phone/*/gmd:voice">
                                <vcard:hasTelephone rdf:parseType="Resource">
                                    <vcard:hasValue rdf:resource="tel:{*}"/>
                                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Voice"/>
                                </vcard:hasTelephone>
                            </xsl:for-each>
                            <xsl:for-each select="*/gmd:contactInfo/*/gmd:address">
                                <vcard:adr rdf:parseType="Resource">
                           	       <vcard:street-address><xsl:value-of select="*/gmd:deliveryPoint"/></vcard:street-address>
                                   <vcard:locality><xsl:value-of select="*/gmd:city"/></vcard:locality>
                            	   <vcard:postal-code><xsl:value-of select="*/gmd:postalCode"/></vcard:postal-code>
                                   <xsl:for-each select="*/gmd:country"><vcard:country-name><xsl:value-of select="*"/></vcard:country-name></xsl:for-each>
                               </vcard:adr>                                           
                            </xsl:for-each>
	    				</foaf:Organization>
	    			</dct:rightsHolder>
	    		</xsl:when>
	    		<xsl:when test="*/gmd:role/*/@codeListValue='publisher'">
	    			<dct:publisher>
	    				<foaf:Organization>
	 			     		<xsl:call-template name="rmulti">
				   				<xsl:with-param name="l" select="$mdlang"/>
				   				<xsl:with-param name="e" select="*/gmd:organisationName"/>
				   				<xsl:with-param name="n" select="'vcard:organization-name'"/>
				   			</xsl:call-template>
	    					<vcard:hasEmail><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/></vcard:hasEmail>
                            <xsl:for-each select="*/gmd:contactInfo/*/gmd:phone/*/gmd:voice">
                                <vcard:hasTelephone rdf:parseType="Resource">
                                    <vcard:hasValue rdf:resource="tel:{*}"/>
                                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Voice"/>
                                </vcard:hasTelephone>
                            </xsl:for-each>
                            <xsl:for-each select="*/gmd:contactInfo/*/gmd:address">
                                <vcard:adr rdf:parseType="Resource">
                           	       <vcard:street-address><xsl:value-of select="*/gmd:deliveryPoint"/></vcard:street-address>
                                   <vcard:locality><xsl:value-of select="*/gmd:city"/></vcard:locality>
                           	       <vcard:postal-code><xsl:value-of select="*/gmd:postalCode"/></vcard:postal-code>
                                   <xsl:for-each select="*/gmd:country"><vcard:country-name><xsl:value-of select="*"/></vcard:country-name></xsl:for-each>
                                </vcard:adr>                                           
                            </xsl:for-each>
	    				</foaf:Organization>
	    			</dct:publisher>
	    		</xsl:when>
	    		<xsl:otherwise>
	    			<prov:qualifiedAttribution>
	    				<prov:Attribution>
		    				<prov:agent>
						 		<xsl:call-template name="vcard">
						 			<xsl:with-param name="mdlang" select="$mdlang"/>
						 			<xsl:with-param name="c" select="gmd:CI_ResponsibleParty"/>
						 		</xsl:call-template>
							</prov:agent>
							 <dct:type rdf:resource="http://inspire.ec.europa.eu/metadata-codelist/ResponsiblePartyRole/{*/gmd:role/*/@codeListValue}"/>
	    				</prov:Attribution>
	    			</prov:qualifiedAttribution>
	    		</xsl:otherwise>
	    	</xsl:choose>
		</xsl:for-each>	
	
      	<!-- INSPIRE themes - URI -->
      	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*/gmd:keyword">
            <xsl:variable name="k" select="."/>
      		<xsl:choose>
      			<!-- Anchor first -->
      			<xsl:when test="gmx:Anchor/@xlink:href">
      				<xsl:variable name="theme" select="gmx:Anchor/@xlink:href"/>
      				<dcat:theme rdf:resource="{$theme}"/>
      				<xsl:if test="$mdr/rdf:Description[@rdf:about=$theme]/skos:broadMatch/@rdf:resource">
      					<dcat:theme rdf:resource="{$mdr/rdf:Description[@rdf:about=$theme]/skos:broadMatch/@rdf:resource}"/>
      				</xsl:if>
      			</xsl:when>

      			<!-- URI takes precedence -->
      			<xsl:when test="contains(gco:CharacterString,'http')">
      				<xsl:variable name="theme" select="gco:CharacterString"/>
      				<dcat:theme rdf:resource="{$theme}"/>
      				<xsl:if test="$mdr/rdf:Description[@rdf:about=$theme]/skos:broadMatch/@rdf:resource">
      					<dcat:theme rdf:resource="{$mdr/rdf:Description[@rdf:about=$theme]/skos:broadMatch/@rdf:resource}"/>
      				</xsl:if>
      			</xsl:when>
      			
                <!-- service keywords mapping -->
                <xsl:when test="string-length($cl/serviceKeyword/value[*/@name=string($k/gco:CharacterString)])>0">
                    <dcat:theme rdf:resource="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/{$k/gco:CharacterString}"/>
                </xsl:when>                
                
      			<!-- Attempt to find INSPIRE themes -->
      			<xsl:when test="contains(../gmd:thesaurusName/*/gmd:title, 'INSPIRE')">
      				<xsl:variable name="theme">
		      			<xsl:choose>
		      				<xsl:when test="$mdlang='eng'">
	                            <xsl:variable name="kwName" select="gco:CharacterString"/>
	                            <xsl:if test="$cl/inspireKeywords/value[@code=string($kwName)]/@uri">
	               					<xsl:value-of select="$cl/inspireKeywords/value[@code=string($kwName)]/@uri"/>
	               				</xsl:if>		
	                        </xsl:when>
	                        <xsl:when test="$mdlang='cze'">
	                            <xsl:variable name="kwName" select="gco:CharacterString"/>
	                            <xsl:if test="$cl/inspireKeywords/value[@name=string($kwName)]/@uri">
	               					<xsl:value-of select="$cl/inspireKeywords/value[@name=string($kwName)]/@uri"/>
	               				</xsl:if>		
	                        </xsl:when>
			      			<xsl:otherwise>
	                            <xsl:variable name="kwName" select="gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale='#locale-eng']"/>
	                            <xsl:if test="$cl/inspireKeywords/value[@code=string($kwName)]/@uri">
	                            	<xsl:value-of select="$cl/inspireKeywords/value[@code=string($kwName)]/@uri"/>
	                            </xsl:if>
	                        </xsl:otherwise>
		      			</xsl:choose>
	      			</xsl:variable>
	      			<dcat:theme rdf:resource="{$theme}"/>
      				<xsl:if test="$mdr/rdf:Description[@rdf:about=$theme]/skos:broadMatch/@rdf:resource">
      					<dcat:theme rdf:resource="{$mdr/rdf:Description[@rdf:about=$theme]/skos:broadMatch/@rdf:resource}"/>
      				</xsl:if>
      			</xsl:when>
      			
      			<!-- Other with thesaurus -->
      			<xsl:when test="string-length(../gmd:thesaurusName/*/gmd:title)>0">
      				<dcat:theme rdf:parseType="Resource">
	        		   		<xsl:call-template name="rmulti">
	        					<xsl:with-param name="l" select="$mdlang"/>
	        					<xsl:with-param name="e" select="."/>
	        					<xsl:with-param name="n" select="'skos:prefLabel'"/>
							</xsl:call-template>
      			     		<skos:inScheme>
      			     			<skos:ConceptScheme>
		          		   			<xsl:call-template name="rmulti">
		          						<xsl:with-param name="l" select="$mdlang"/>
		          						<xsl:with-param name="e" select="../gmd:thesaurusName/*/gmd:title"/>
		          						<xsl:with-param name="n" select="'rdfs:label'"/>
		          					</xsl:call-template>
		        			     	<xsl:for-each select="../gmd:thesaurusName/*/gmd:date">
		                	  			<xsl:choose>
		                	  				<xsl:when test="*/gmd:dateType/*/@codeListValue='creation'">
		                	  					<dct:created rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:date/*"/></dct:created>
		                	  				</xsl:when>
		                	  				<xsl:when test="*/gmd:dateType/*/@codeListValue='publication'">
		                	  					<dct:issued rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:date/*"/></dct:issued>
		                	  				</xsl:when>
		                	  				<xsl:when test="*/gmd:dateType/*/@codeListValue='revision'">
		                	  					<dct:modified rdf:datatype="{$xsd}date"><xsl:value-of select="*/gmd:date/*"/></dct:modified>
		                	  				</xsl:when>
		                	  			</xsl:choose>
		                	  		</xsl:for-each>
	                	  		</skos:ConceptScheme>	
      			     		</skos:inScheme>
              		</dcat:theme>      			
      			</xsl:when>

      			<!-- Free keywords -->
      			<xsl:otherwise>
    		   		<xsl:call-template name="rmulti">
    					<xsl:with-param name="l" select="$mdlang"/>
    					<xsl:with-param name="e" select="."/>
    					<xsl:with-param name="n" select="'dcat:keyword'"/>
    				</xsl:call-template>      			
      			</xsl:otherwise>

      		</xsl:choose>
      	</xsl:for-each>
      	
      	<!-- Reference system -->	
 		<xsl:for-each select="gmd:referenceSystemInfo">
            <dct:conformsTo>
 			<xsl:choose>
 				<xsl:when test="*/gmd:referenceSystemIdentifier/*/gmd:code/*/@xlink:href">
 					<rdf:Description rdf:about="{*/gmd:referenceSystemIdentifier/*/gmd:code/*/@xlink:href}" >
                        <dct:type rdf:resource="http://inspire.ec.europa.eu/glossary/SpatialReferenceSystem"/>
                     </rdf:Description>   
 				</xsl:when>
 				<xsl:when test="substring(*/gmd:referenceSystemIdentifier/*/gmd:code/*,1,4)='http'">
 					<rdf:Description rdf:about="{*/gmd:referenceSystemIdentifier/*/gmd:code/*}" >
                        <dct:type rdf:resource="http://inspire.ec.europa.eu/glossary/SpatialReferenceSystem"/>
                     </rdf:Description>   
 				</xsl:when>
 				<xsl:when test="contains(*/gmd:referenceSystemIdentifier/*/gmd:codeSpace/*, 'EPSG')">
 					<rdf:Description rdf:about="http://www.opengis.net/def/crs/EPSG/0/{*/gmd:referenceSystemIdentifier/*/gmd:code/*}">
                        <dct:type rdf:resource="http://inspire.ec.europa.eu/glossary/SpatialReferenceSystem"/>
                    </rdf:Description>  
 				</xsl:when>
 			</xsl:choose>
            </dct:conformsTo>
        </xsl:for-each>
        

        <!-- ADDED Application schema -->
        <xsl:for-each select="gmd:applicationSchemaInfo/*/gmd:graphicsFile">
			<dcat:documentation>
			  <foaf:page rdf:resource="{*/@src}"/> 
			</dcat:documentation>	
        </xsl:for-each>

        
	</rdf:Description>
</xsl:template>

<xsl:template name="vcard">
	<xsl:param name="mdlang"/>
	<xsl:param name="c"/>
	<rdf:Description>
		<xsl:if test="$c/gmd:organisationName/*/@xlink:href">
			<xsl:attribute name="rdf:resource"><xsl:value-of select="$c/gmd:organisationName/*/@xlink:href"/></xsl:attribute>
		</xsl:if>
		<rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Organization"/>
		<xsl:call-template name="rmulti">
   			<xsl:with-param name="l" select="$mdlang"/>
   			<xsl:with-param name="e" select="$c/gmd:organisationName"/>
   			<xsl:with-param name="n" select="'vcard:fn'"/>
   		</xsl:call-template>
        <xsl:for-each select="$c/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress">
 			<vcard:hasEmail rdf:resource="mailto:{*}"/>
        </xsl:for-each>
        <xsl:for-each select="$c/gmd:contactInfo/*/gmd:phone/*/gmd:voice">
            <vcard:hasTelephone rdf:parseType="Resource">
                <vcard:hasValue rdf:resource="tel:{*}"/>
                <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Voice"/>
            </vcard:hasTelephone>
        </xsl:for-each>
        <xsl:for-each select="$c/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage">        
  			<vcard:hasURL rdf:resource="{*}"/>
		</xsl:for-each>
        <xsl:for-each select="$c/gmd:contactInfo/*/gmd:address">
        	<vcard:hasAddress>
	        	<xsl:if test="*/gmd:deliveryPoint/*/@xlink:href">
					<xsl:attribute name="rdf:resource"><xsl:value-of select="*/gmd:deliveryPoint/*/@xlink:href"/></xsl:attribute>
	        	</xsl:if>
        		<vcard:Address>
	            	<vcard:street-address><xsl:value-of select="*/gmd:deliveryPoint/*"/></vcard:street-address>
	                <vcard:locality><xsl:value-of select="*/gmd:city/*"/></vcard:locality>
	                <vcard:postal-code><xsl:value-of select="*/gmd:postalCode/*"/></vcard:postal-code>
                    <xsl:for-each select="*/gmd:country"><vcard:country-name><xsl:value-of select="*"/></vcard:country-name></xsl:for-each>
                </vcard:Address>
            </vcard:hasAddress>                                           
      	</xsl:for-each>
     </rdf:Description>
</xsl:template> 


<xsl:template name="rmulti">
  	<xsl:param name="l"/>
  	<xsl:param name="e"/>
  	<xsl:param name="n"/>
  	<xsl:element name="{$n}"><xsl:attribute name="xml:lang"><xsl:value-of select="$cl/language/value[@code=$l]/@code2"/></xsl:attribute><xsl:value-of select="$e/*"/></xsl:element>
	<xsl:for-each select="$e/gmd:PT_FreeText/*/gmd:LocalisedCharacterString">
		<xsl:variable name="l2" select="substring-after(@locale,'-')"/>
 		<xsl:element name="{$n}"><xsl:attribute name="xml:lang"><xsl:value-of select="$cl/language/value[@code=$l2]/@code2"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
	</xsl:for-each>
</xsl:template>

</xsl:stylesheet>	
