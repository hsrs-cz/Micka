<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>

<!-- ATOM -->
<xsl:template match="//atom:feed"  
  xmlns:insp_com="http://inspire.ec.europa.eu/schemas/common/1.0" 
  xmlns:insp_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
  xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:ows="http://www.opengis.net/ows/1.1"
  xmlns:fes="http://www.opengis.net/fes/2.0"
  xmlns:wfs="http://www.opengis.net/wfs/2.0" 
  xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:georss="http://www.georss.org/georss"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gco="http://www.opengis.net/gco"
  xmlns:php="http://php.net/xsl">

<validationResult version="beta 3, CENIA 2016-09-13" title="Validace - INSPIRE download (ATOM)">
<!-- identifikace -->
<!-- 1.1 -->
<test code="1.1" level="m">
	<description>Název</description>
	<xpath>title</xpath>  
  	<xsl:if test="atom:title">
	    <value><xsl:value-of select="atom:title"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.2 -->
<test code="1.2" level="m">
	<description>Abstrakt</description>
	<xpath>subtitle</xpath>  
  	<xsl:if test="atom:subtitle">
	    <value><xsl:value-of select="atom:subtitle"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.3 -->
<xsl:variable name="md" select="php:function('isRunning',string(atom:link[@rel='describedby']/@href), 'gmd', 1)"/>
<test code="1.3" level="m">
	<description>Odkaz na metadata</description>
	<xpath>link[@rel="describedby"]</xpath>  
  	<xsl:if test="atom:link[@rel='describedby']/@href">
	    <value><xsl:value-of select="atom:link[@rel='describedby']/@href"/></value>
	    <pass>true</pass>
		<test code="a" level="m">
			<description>ON-LINE</description>
			<xpath><xsl:value-of select="atom:link[@rel='describedby']/@href"/></xpath>
			<xsl:choose>  
			  	<xsl:when test="$md and $md//gmd:identificationInfo">
				    <value><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/></value>
				    <pass>true</pass>
				</xsl:when>
			</xsl:choose>
		</test>
	</xsl:if>
</test>

<!-- 1.4 -->
<test code="1.4" level="m">
	<description>Lokátor</description>
	<xpath>link[@rel="self"]</xpath>  
  	<xsl:if test="atom:link[@rel='self']/@href">
	    <value><xsl:value-of select="atom:link[@rel='self']/@href"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.4a -->
<test code="1.4.a" level="m">
	<description>Jazyk metadat</description>
	<xpath>link[@rel='self']/@hreflang</xpath>  
  	<xsl:if test="atom:link[@rel='self']/@hreflang">
	    <value><xsl:value-of select="atom:link[@rel='self']/@hreflang"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>


<!-- 1.5 -->
<test code="1.5" level="m">
	<description>Open Search dokument</description>
	<xpath>link[@rel='search' and @type='application/opensearchdescription+xml']</xpath>  
  	<xsl:if test="atom:link[@rel='search' and @type='application/opensearchdescription+xml']/@href">
	    <value><xsl:value-of select="atom:link[@rel='search' and @type='application/opensearchdescription+xml']/@href"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.6 TODO jazyky -->

<!-- 1.7 -->
<test code="1.7" level="n">
	<description>Alternativní reprezentace</description>
	<xpath>link[@rel='alternate']</xpath>  
  	<xsl:if test="atom:link[@rel='alternate']">
	    <value>
	    	<xsl:for-each select="atom:link[@rel='alternate']">
	    		<xsl:value-of select="@title"/>: <xsl:value-of select="@href"/> (<xsl:value-of select="@type"/>)
				<xsl:if test="not(position()=last())">&lt;br/&gt;</xsl:if>	    	
	    	</xsl:for-each>
	    </value>	
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.8 -->
<test code="1.8" level="m">
	<description>id</description>
	<xpath>id = link[@rel='self']</xpath>
	<xsl:choose>  
	  	<xsl:when test="atom:id = atom:link[@rel='self']/@href">
		    <value><xsl:value-of select="atom:id"/></value>
		    <pass>true</pass>
		</xsl:when>
		<xsl:otherwise>
			<err><xsl:value-of select="atom:id"/> != <xsl:value-of select="atom:link[@rel='self']/@href"/></err>
		</xsl:otherwise>
	</xsl:choose>
</test>

<!-- 1.9 -->
<test code="1.9" level="m">
	<description>Omezení veřejného přístupu</description>
	<xpath>rights</xpath>  
  	<xsl:if test="atom:rights">
	    <value><xsl:value-of select="atom:rights"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.10 -->
<test code="1.10" level="m">
	<description>Datum metadat</description>
	<xpath>updated</xpath>  
  	<xsl:if test="atom:updated">
	    <value><xsl:value-of select="atom:updated"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.11 -->
<test code="1.11" level="m">
	<description>Zodpovědná organizace</description>
	<xpath>author</xpath>  
  	<xsl:if test="atom:author">
	    <value><xsl:value-of select="atom:author"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>


<!-- 1.12 -->
<test code="1.12" level="m">
	<description>Entry > 0</description>
	<xpath>entry</xpath>  
  	<xsl:if test="atom:entry">
	    <value><xsl:value-of select="count(atom:entry)"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<xsl:for-each select="atom:entry">
    <test code="1.12" level="m">
		<description>ENTRY</description>
		<xpath>entry/title</xpath>  
	  	<xsl:if test="atom:title">
    		<value><xsl:value-of select="atom:title"/></value>
    		<pass>true</pass>
	
		<!-- 1.13 -->
		<test code="1.13" level="m">
			<description>INSPIRE identifikátor datové sady</description>
			<xpath>inspire_dls:spatial_dataset_identifier_code + inspire_dls:spatial_dataset_identifier_namespace</xpath>  
		  	<xsl:choose>
			  	<xsl:when test="inspire_dls:spatial_dataset_identifier_code and inspire_dls:spatial_dataset_identifier_namespace">
				    <value><xsl:value-of select="inspire_dls:spatial_dataset_identifier_namespace"/>:<xsl:value-of select="inspire_dls:spatial_dataset_identifier_code"/></value>
				    <pass>true</pass>
				</xsl:when>
				<xsl:when test="inspire_dls:spatial_dataset_identifier_namespace">
					<err><xsl:value-of select="inspire_dls:spatial_dataset_identifier_namespace"/>: chybí kód</err>
				</xsl:when>
				<xsl:when test="inspire_dls:spatial_dataset_identifier_code">
					<err>chybí namespace: <xsl:value-of select="inspire_dls:spatial_dataset_identifier_code"/></err>
				</xsl:when>
			</xsl:choose>
		</test>
		
		<xsl:variable name="md1" select="php:function('isRunning',string(atom:link[@rel='describedby']/@href), 'gmd', 1)"/>
		<test code="1.14" level="m">
			<description>Odkaz na metadata</description>
			<xpath>link[@rel="describedby"]</xpath>  
		  	<xsl:if test="atom:link[@rel='describedby']/@href">
			    <value><xsl:value-of select="atom:link[@rel='describedby']/@href"/></value>
			    <pass>true</pass>
				<test code="a" level="m">
					<description>ON-LINE</description>
					<xpath><xsl:value-of select="atom:link[@rel='describedby']/@href"/></xpath>
					<xsl:choose>  
					  	<xsl:when test="$md1//gmd:identificationInfo">
						    <value><xsl:value-of select="$md1//gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/></value>
						    <pass>true</pass>
						</xsl:when>
					</xsl:choose>
				</test>
			</xsl:if>
		</test>
	
		<test code="1.15" level="m">
			<description>Odkaz na dataset feed</description>
			<xpath>link[@rel='alternate' and @type='application/atom+xml']</xpath>  
		  	<xsl:if test="atom:link[@rel='alternate' and @type='application/atom+xml']/@href">
			    <value><xsl:value-of select="atom:link[@rel='alternate' and @type='application/atom+xml']/@title"/>: <xsl:value-of select="atom:link[@rel='alternate' and @type='application/atom+xml']/@href"/></value>
			    <pass>true</pass>
			</xsl:if>
		</test>
	
		</xsl:if>
	</test>
	
   </xsl:for-each>


</validationResult>
  
</xsl:template>

<xsl:template match="wfs:WFS_Capabilities"  
	xmlns:wfs='http://www.opengis.net/wfs' 
	xmlns:ogc='http://www.opengis.net/ogc' 
	xmlns:gml='http://www.opengis.net/gml' 
	xmlns:ows='http://www.opengis.net/ows' 
	xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' 
	xmlns:xlink='http://www.w3.org/1999/xlink'
	xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 	 
  	xmlns:php="http://php.net/xsl">

<validationResult version="beta 2, CENIA 2016-07-26" title="Validace - INSPIRE download (WFS)">  
	<test code="1.1" level="m">
		<description>Verze služby</description>
		<xpath>@version=2.0.0</xpath>
		<err>Špataná verze = <xsl:value-of select="@version"/></err>  
	</test>
</validationResult>
   
</xsl:template>

<!-- WFS -->
<xsl:template match="wfs:WFS_Capabilities"  
  xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
  xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
  xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"  
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:ows="http://www.opengis.net/ows/1.1"
  xmlns:fes="http://www.opengis.net/fes/2.0"
  xmlns:wfs="http://www.opengis.net/wfs/2.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:php="http://php.net/xsl">

<xsl:variable name="codelists" select="document(concat('../../include/xsl/codelists_',$LANG,'.xml'))/map" />
<xsl:variable name="labels" select="document(concat('labels-',$LANG,'.xml'))/map" />
<xsl:variable name="specifications" select="document('../../include/dict/specif.xml')/userValues" />

<validationResult version="beta 2, CENIA 2016-07-26" title="Validace - INSPIRE download (WFS)">
<!-- identifikace -->

<!-- 1.1 -->
<test code="1.1" level="m">
	<description><xsl:value-of select="$labels/test[@code='1.1']"/></description>
	<xpath>ServiceIdentification/Title</xpath>  
  	<xsl:if test="string-length(normalize-space(ows:ServiceIdentification/ows:Title))>0">
	    <value><xsl:value-of select="ows:ServiceIdentification/ows:Title"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.2 -->
<test code="1.2" level="m">
	<description><xsl:value-of select="$labels/test[@code='1.2']"/></description>
	<xpath>ServiceIdentification/Abstract</xpath>  
    <xsl:if test="string-length(normalize-space(ows:ServiceIdentification/ows:Abstract))>0">
	   <value><xsl:value-of select="ows:ServiceIdentification/ows:Abstract"/></value>
	   <pass>true</pass>
	</xsl:if>
</test>

<xsl:variable name="md" select="php:function('isRunning', string(*/ows:ExtendedCapabilities/*/inspire_common:MetadataUrl/*), 'GMD', 1)"/>

<!-- 1.3 -->
<test code="1.3" level="m">
	<description><xsl:value-of select="$labels/test[@code='1.3']"/></description>
	<xpath>inspire_common:ResourceType</xpath>
	<xsl:choose>  
	    <xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:ResourceType">
		   <value><xsl:value-of select="*/ows:ExtendedCapabilities/inspire_common:ResourceType"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:hierarchyLevel/*/@codeListValue">
		   <value><xsl:value-of select="$md//gmd:hierarchyLevel/*/@codeListValue"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 1.4 DOST NESMYSLNY TOTO probrat to -->
<test code="1.4" level="c">
	<description><xsl:value-of select="$labels/test[@code='1.4']"/></description>
	<xpath>inspire_common:ResourceLocator</xpath>  
	<xsl:choose>  
	    <xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:ResourceLocator">
		   <value><xsl:value-of select="*/ows:ExtendedCapabilities/inspire_common:ResourceLocator"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage">
		   <value><xsl:value-of select="$md//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 1.5 -->
<test code="1.5" level="m">
	<description><xsl:value-of select="$labels/test[@code='1.5']"/></description>
	<xpath>inspire_dls:SpatialDataSetIdentifier/inspire_common:Code</xpath>  
	<xsl:choose>  
	    <xsl:when test="*/ows:ExtendedCapabilities/*/inspire_dls:SpatialDataSetIdentifier/inspire_common:Code">
		   <value><xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_dls:SpatialDataSetIdentifier/inspire_common:Namespace"/>:<xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_dls:SpatialDataSetIdentifier/inspire_common:Code"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code">
		   <value><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace"/>:<xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 1.6 -->
<xsl:for-each select="wfs:FeatureTypeList/wfs:FeatureType">
	<test code="1.6" level="m">
		<description><xsl:value-of select="$labels/test[@code='1.6']"/> metadata (<xsl:value-of select="wfs:Title"/>)</description>
		<xpath>wfs:FeatureTypeList/wfs:FeatureType/wfs:MetadataURL/@xlink:href</xpath>  
	    <xsl:if test="wfs:MetadataURL">
			<value><xsl:value-of select="wfs:MetadataURL/@xlink:href"/></value>
			<pass>true</pass>
			<xsl:variable name="ol" select="php:function('isRunning', string(wfs:MetadataURL/@xlink:href), 'GMD', 1)"/> 
		    <test code="a" level="m">
				<description><xsl:value-of select="$labels/test[@code='1.4.a']"/></description>
				<xpath><xsl:value-of select="wfs:MetadataURL/@xlink:href"/></xpath> 
		   		<xsl:if test="$ol">
	   				<value>OK</value>
		   			<pass>true</pass>
		   		</xsl:if>
		    </test>
		    <test code="b" level="m">
				<description><xsl:value-of select="$labels/test[@code='1.3']"/></description>
				<xpath>hierarchyLevel='dataset' or hierarchyLevel='series'</xpath> 
		   		<xsl:if test="$ol//gmd:hierarchyLevel/*/@codeListValue='dataset' or $ol//gmd:hierarchyLevel/*/@codeListValue='series'">
	   				<value><xsl:value-of select="$ol//gmd:hierarchyLevel/*/@codeListValue"/></value>
		   			<pass>true</pass>
		   		</xsl:if>
		    </test>
		</xsl:if>
	</test>
</xsl:for-each>

<!-- 2.2 -->
<test code="2.2" level="m">
	<description><xsl:value-of select="$labels/test[@code='2.2']"/></description>
	<xpath>inspire_common:SpatialDataServiceType='download'</xpath>  
	<xsl:choose>  
	    <xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:SpatialDataServiceType and */ows:ExtendedCapabilities/*/inspire_common:SpatialDataServiceType='download'">
		   <value><xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:SpatialDataServiceType"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:identificationInfo/*/srv:serviceType/*='download'">
		   <value><xsl:value-of select="$md//gmd:identificationInfo/*/srv:serviceType"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 2.2.a -->
<test code="2.2.a" level="m">
	<description><xsl:value-of select="$labels/test[@code='2.2.a']"/></description>
	<xpath>@version</xpath>  
  	<xsl:if test="@version='2.0.0'">
	    <value><xsl:value-of select="@version"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 3.0 -->
<test code="3">
 	<description><xsl:value-of select="$labels/test[@code='3']"/></description>
 	<xpath>inspire_common:MandatoryKeyword</xpath>
 	<xsl:choose>
	 	<xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:MandatoryKeyword/*='infoFeatureAccessService'">
			<value>
				<xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:MandatoryKeyword/*"/>
			</value>	
			<pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:keyword,'infoFeatureAccessService')]">
		   <value>infoFeatureAccessService</value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 4.1 -->
<xsl:for-each select="wfs:FeatureTypeList/wfs:FeatureType">
	<test code="4.1" level="c">
		<description><xsl:value-of select="$labels/test[@code='4.1']"/> (<xsl:value-of select="wfs:Title"/>)</description>
		<xpath>ows:WGS84BoundingBox</xpath>  
		<xsl:choose>  
		    <xsl:when test="ows:WGS84BoundingBox">
			   <value><xsl:value-of select="ows:WGS84BoundingBox"/></value>
			   <pass>true</pass>
			</xsl:when>
		</xsl:choose>
	</test>
</xsl:for-each>

<!-- 5.a TODO - vylepsit VALIDACI -->
<test code="5a">
 	<description><xsl:value-of select="$labels/test[@code='5a']"/></description>
 	<xpath>inspire_common:TemporalReference</xpath>
 	<xsl:choose>
	 	<xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:TemporalReference">
			<value>
				<xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:TemporalReference"/>
			</value>	
			<pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:identificationInfo/*/gmd:citation/*/gmd:date">
		   <value><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:citation/*/gmd:date"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 7 TODO - vylepsit VALIDACI -->
<test code="7.1">
 	<description><xsl:value-of select="$labels/test[@code='7.1']"/></description>
 	<xpath>inspire_common:Conformity</xpath>
 	<xsl:choose>
	 	<xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:Conformity">
			<value>
				<xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:Conformity"/>
			</value>	
			<pass>true</pass>
		</xsl:when>
		<xsl:when test="$md">
			<xsl:variable name="mdlang" select="$md//gmd:language/*/@codeListValue"/>			
			<xsl:variable name="spec" select="normalize-space($specifications/translation[@lang=$mdlang]//entry[@id='Network']/@name)"/>
			<xsl:variable name="INSPIRE" select="normalize-space($specifications/translation[@lang=$mdlang]//entry[@id='INSPIRE']/@name)"/>	
			<xsl:variable name="neInspire" select="$md//gmd:dataQualityInfo/*/gmd:report[normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString)=normalize-space($INSPIRE)]" />
	        <xsl:choose>
	        	<!-- NE INSPIRE zaznamy -->
	        	<xsl:when test="string-length($neInspire//gmd:title)>0 and $neInspire//gmd:pass/*='false'">
	        		<value><xsl:value-of select="$INSPIRE"/></value>
	    			<pass>true</pass>
	    			<!-- 7.2 -->
				   	<test code="7.2">
				   		<description><xsl:value-of select="$labels/test[@code='7.2']"/></description>
				   		<xpath>dataQualityInfo/*/report/DQ_DomainConsistency/result/*/pass</xpath>
				   		<value>false</value>
				   		<pass>true</pass>
				    </test>	
	       	    </xsl:when>
				<!-- INSPIRE zaznamy -->        	
	        	<xsl:when test="string-length($md//gmd:dataQualityInfo/*/gmd:report[php:function('mb_strtoupper', normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString))=php:function('mb_strtoupper', $spec)]//gmd:title)>0">
	        		<value><xsl:value-of select="$spec"/></value>
	    			<pass>true</pass>
	    			<!-- 7.2 -->
				   	<test code="7.2">
				   		<description><xsl:value-of select="$labels/test[@code='7.2']"/></description>
				   		<xpath>dataQualityInfo/*/report/DQ_DomainConsistency/result/*/pass</xpath>
				       	<xsl:choose>
				          	<xsl:when test="string-length($md//gmd:dataQualityInfo/*/gmd:report[php:function('mb_strtoupper', normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString))=php:function('mb_strtoupper', $spec)]//gmd:pass)>0">
				      			<value><xsl:value-of select="$md//gmd:dataQualityInfo/*/gmd:report[php:function('mb_strtoupper', normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString))=php:function('mb_strtoupper', $spec)]//gmd:pass"/></value>
				      		  	<pass>true</pass>
				      	  	</xsl:when>
				           	<xsl:when test="string-length($md//gmd:dataQualityInfo/*/gmd:report[php:function('mb_strtoupper', normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString))=php:function('mb_strtoupper', $spec)]//gmd:pass/@gco:nilReason)>0">
				      			<value>not evaluated</value>
				      		  	<pass>true</pass>
				      	  	</xsl:when>
				      	</xsl:choose>
				    </test>	
	       	    </xsl:when>
	            <xsl:otherwise>
	                <err>"<xsl:value-of select="$md//gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString"/>" != "<xsl:value-of select="$spec"/>"</err>
	            </xsl:otherwise>
	        </xsl:choose>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 8.1 -->
<test code="8.1" level="m">
	<description><xsl:value-of select="$labels/test[@code='8.1']"/></description>
	<xpath>ServiceIdentification/Fees</xpath>  
	<xsl:choose>  
	    <xsl:when test="ows:ServiceIdentification/ows:Fees!=''">
		   <value><xsl:value-of select="ows:ServiceIdentification/ows:Fees"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation/*">
		   <value><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation/*"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 8.2 -->
<test code="8.2" level="m">
	<description><xsl:value-of select="$labels/test[@code='8.2']"/></description>
	<xpath>ServiceIdentification/AccessConstraints</xpath>  
	<xsl:choose>  
	    <xsl:when test="ows:ServiceIdentification/ows:AccessConstraints!=''">
		   <value><xsl:value-of select="ows:ServiceIdentification/ows:AccessConstraints!=''"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints/*">
		   <value><xsl:value-of select="$md//gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints/*"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 9.1 TODO vylepsit -->
<test code="9.1" level="m">
	<description><xsl:value-of select="$labels/test[@code='9.1']"/></description>
	<xpath>ows:ServiceProvider/ows:ProviderName</xpath>  
	<xsl:choose>  
	    <xsl:when test="ows:ServiceProvider/ows:ProviderName">
		   <value><xsl:value-of select="ows:ServiceProvider/ows:ProviderName"/></value>
		   <pass>true</pass>
		   
			<test code="a" level="m">
				<description>E-mail</description>
				<xpath>ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress</xpath>  
				<xsl:choose>  
				    <xsl:when test="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress">
					   <value><xsl:value-of select="ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></value>
					   <pass>true</pass>
					</xsl:when>
				</xsl:choose>
			</test>
		   
		</xsl:when>
	</xsl:choose>
</test>

<!-- 10.1 -->   
<xsl:choose>
	<xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:MetadataPointOfContact">
		<test code="5b" level="c">
			<description><xsl:value-of select="$labels/test[@code='10.1']"/></description>
			<xpath>inspire_common:MetadataPointOfContact</xpath>  
			<value><xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:MetadataPointOfContact"/></value>
			<pass>true</pass>
		</test>
	</xsl:when>
	<xsl:when test="$md and string-length(normalize-space($md//gmd:contact))>0">
		<xsl:for-each select="$md//gmd:contact">
			<test code="10.1" level="m">
				<description><xsl:value-of select="$labels/test[@code='10.1']"/></description>
				<xpath>contactInfo</xpath>
		  		<pass>true</pass>  		
	  			<test code="a">
					<description><xsl:value-of select="$labels/test[@code='Name']"/></description>
					<xpath>organisationName</xpath>			  	
					<xsl:if test="string-length(normalize-space(*/gmd:organisationName/gco:CharacterString))>0">
				    	<value><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></value>
				    	<pass>true</pass>
				    </xsl:if>
		    	</test>
	  			<test code="b">
					<description>e-mail</description>
					<xpath>contactInfo/*/address/*/electronicMailAddress</xpath>			  	
				    <value><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/></value>
					<xsl:choose>
					<xsl:when test="php:function('isEmail',string(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString))">
				    	<pass>true</pass>
				    </xsl:when>
				    </xsl:choose>
		    	</test>

				<xsl:variable name="k1" select="*/gmd:role/*/@codeListValue"/>
		  		<test code="c" level="m">
					<description>Role (role)</description>
					<xpath>role/*/@codeListValue</xpath>
					<xsl:choose>	  	
						<xsl:when test="$codelists/role/value[@name=$k1]!=''">
				    		<value><xsl:value-of select="$codelists/role/value[@name=$k1]"/> (<xsl:value-of select="$k1"/>)</value>
				    		<pass>true</pass>
				    	</xsl:when>
				    </xsl:choose>
			    </test>
			   	
			   	<xsl:if test="position()=1 and $codelists/role/value[@name=$k1]!=''">
		  			<test code="d">
						<description>Role = <xsl:value-of select="$codelists/role/value[@name='pointOfContact']"/></description>
						<xpath>role/*/@codeListValue and //contact[*/role/*/@codeListValue='pointOfContact']</xpath>
						<xsl:choose>			  	
							<xsl:when test="$md and string-length($md//gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact'])>0">
						    	<value><xsl:value-of select="$md//gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:organisationName/gco:CharacterString"/></value>
						    	<pass>true</pass>
						    </xsl:when>
					    </xsl:choose>
			    	</test>
		    	</xsl:if>
			</test>
		</xsl:for-each>	
		
	</xsl:when>
	<xsl:otherwise>
		<test code="10.1" level="m">
			<description><xsl:value-of select="$labels/test[@code='10.1']"/></description>
			<xpath>contactInfo</xpath>
		</test>	
	</xsl:otherwise>
</xsl:choose>

<!-- 10.2 -->
<test code="10.2" level="m">
	<description><xsl:value-of select="$labels/test[@code='10.2']"/></description>
	<xpath>inspire_common:MetadataDate</xpath>  
	<xsl:choose>  
	    <xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:MetadataDate">
		   <value><xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:MetadataDate"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:dateStamp">
		   <value><xsl:value-of select="$md//gmd:dateStamp"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 10.3 -->
<test code="10.3" level="m">
	<description><xsl:value-of select="$labels/test[@code='10.3']"/></description>
	<xpath>inspire_common:SupportedLanguages</xpath>  
	<xsl:choose>  
	    <xsl:when test="*/ows:ExtendedCapabilities/*/inspire_common:SupportedLanguages">
		   <value><xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:SupportedLanguages"/></value>
		   <pass>true</pass>
		</xsl:when>
	    <xsl:when test="$md and $md//gmd:language/*/@codeListValue">
		   <value><xsl:value-of select="$md//gmd:language/*/@codeListValue"/></value>
		   <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>
<!-- 11 -->
<test code="11" level="c">
	<description>Podpora stored queries</description>
	<xpath>ows:OperationsMetadata/ows:Operation[@name='DescribeStoredQueries']/@name</xpath>  
	<xsl:if test="ows:OperationsMetadata/ows:Operation[@name='DescribeStoredQueries']/@name">
	   <xsl:variable name="q" select="php:function('isRunning', concat(ows:OperationsMetadata/ows:Operation[@name='DescribeStoredQueries']/ows:DCP/ows:HTTP/ows:Get/@xlink:href, 'service=WFS&amp;version=2.0.0&amp;request=DescribeStoredQueries'), 'WFS', 1)"/>

	   <xsl:if test="$q and $q//wfs:StoredQueryDescription">
			<pass>true</pass>
			<value>OK</value>
		   
			<test code="a" level="c">
				<description>Id dotazu podle INSPIRE</description>
				<xpath>wfs:StoredQueryDescription[@id='http://inspire.ec.europa.eu/operation/download/GetSpatialDataSet']</xpath>  
				<xsl:if test="$q and $q//wfs:StoredQueryDescription[@id='http://inspire.ec.europa.eu/operation/download/GetSpatialDataSet']">
					<value><xsl:value-of select="$q//wfs:StoredQueryDescription[@id='http://inspire.ec.europa.eu/operation/download/GetSpatialDataSet']/@id"/> =
					<xsl:value-of select="$q//wfs:StoredQueryDescription[@id='http://inspire.ec.europa.eu/operation/download/GetSpatialDataSet']/wfs:Title"/></value>
					<pass>true</pass>
				</xsl:if>
			</test>
		   <xsl:for-each select="$q//wfs:StoredQueryDescription">	   
				<test code="b" level="c">
					<description>
						<xsl:choose>
							<xsl:when test="wfs:Title"><xsl:value-of select="wfs:Title"/></xsl:when>
							<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
							<xsl:when test="wfs:Abstract"><xsl:value-of select="wfs:Abstract"/></xsl:when>							
						</xsl:choose>
						 - povinné parametry</description>
					<xpath>wfs:StoredQueryDescription/wfs:Parameter/@name = CRS / DataSetIdCode / DataSetIdNamespace / Language</xpath>
					<xsl:if test="wfs:Parameter/@name='CRS' and wfs:Parameter/@name='DataSetIdCode' and wfs:Parameter/@name='DataSetIdNamespace' and wfs:Parameter/@name='Language'">
						<value>CRS + DataSetIdCode + DataSetIdNamespace + Language: OK</value>
						<pass>true</pass>
					</xsl:if>
				</test>
			</xsl:for-each>
		</xsl:if>
	</xsl:if>
</test>



<!-- 3.0 
<test code="3.0" level="c">
	<description>Metadata</description>
	<xpath>inspire_common:MetadataUrl</xpath>  
    <xsl:if test="*/ows:ExtendedCapabilities/*/inspire_common:MetadataUrl/*">
	   <value><xsl:value-of select="*/ows:ExtendedCapabilities/*/inspire_common:MetadataUrl/*"/></value>
	   <pass>true</pass>
	</xsl:if>
</test-->



</validationResult>
  
</xsl:template>



</xsl:stylesheet>