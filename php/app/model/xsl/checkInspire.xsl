<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"   
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
>
<xsl:output method="html"/>

<xsl:variable name="msg" select="document('msg.xml')/messages/kontrola[@lang=$lang]"/>

<xsl:template match="/">


<xsl:choose>
	<xsl:when test="//csw:SearchResults/@numberOfRecordsMatched>0">
     Nalezeno: <xsl:value-of select="//csw:SearchResults/@numberOfRecordsMatched"/>
     <xsl:if test="//csw:SearchResults/@numberOfRecordsMatched>//csw:SearchResults/@numberOfRecordsReturned">
       <span style="margin-left:20px">
       <xsl:if test="$startPosition>1">
         <xsl:variable name="lastSet" select="number($startPosition)-number($maxRecords)"/>
         <a style='text-decoration:none' href="javascript:drawContainer('default','{$lastSet}');"> <b>&lt;&lt;</b> </a>
       </xsl:if> 

       (<xsl:value-of select="$startPosition"/> - <xsl:value-of select="number($startPosition)+number(//csw:SearchResults/@numberOfRecordsReturned)-1"/>)

       <xsl:if test="//csw:SearchResults/@nextRecord>0">
         <a style="text-decoration:none" href="javascript:drawContainer('default','{//csw:SearchResults/@nextRecord}');"> <b>&gt;&gt;</b> </a>
       </xsl:if> 
       
     </span>
     </xsl:if>  

  </xsl:when>
	<xsl:otherwise><span class='notFound'>Žádné záznamy nevyhovují podmínce</span></xsl:otherwise>
</xsl:choose>

<xsl:for-each select="//gmd:MD_Metadata">

	<div class="rec-head">
		<xsl:value-of select="gmd:fileIdentifier"/>:
		<a href="../micka_main.php?ak=detail&amp;uuid={gmd:fileIdentifier}" target="_blank">  
		<b><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString" /></b>
		</a>
	</div>
	
	<!-- identifikace -->
	<!-- 1.1 -->
	<xsl:if test="string-length(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title)=0">
	  <div class='m'><xsl:value-of select="$msg/title"/></div>
	</xsl:if>
	
	<!-- 1.2 -->
	<xsl:if test="string-length(gmd:identificationInfo/*/gmd:abstract)=0">
	  <div class='m'><xsl:value-of select="$msg/abstract"/></div>
	</xsl:if>
	
	<!-- 1.3 -->
	<xsl:if test="gmd:hierarchyLevel!='dataset' and gmd:hierarchyLevel!='service' and gmd:hierarchyLevel!='series'">
	  <div class='m'><xsl:value-of select="$msg/hierarchyLevel"/></div>
	</xsl:if>

	<!-- 5a -->
	<xsl:if test="string-length(gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date)=0">
	  <div class='m'><xsl:value-of select="$msg/date"/></div>
	</xsl:if>
	
	<!-- 5a -->
	<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date">
		<xsl:if test="string-length(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)=0">
		  <div class='m'><xsl:value-of select="$msg/dateType"/></div>
		</xsl:if>
	</xsl:for-each>
	
    <!-- 1.4 -->
	<xsl:if test="string-length(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions//gmd:linkage)=0">
	  <div class='c'><xsl:value-of select="$msg/distribLinkage"/></div>
	</xsl:if>
	      
	<!-- TODO vylepsit test -->
	<!-- 5b -->
	<xsl:if test="string-length(gmd:identificationInfo//gmd:EX_Extent//gmd:temporalElement)=0">
	  <div class='c'><xsl:value-of select="$msg/temporalElement"/></div>
	</xsl:if>
	
	<!-- 9a -->
	<xsl:if test="string-length(gmd:identificationInfo/*/gmd:pointOfContact)=0">
	  <div class='m'><xsl:value-of select="$msg/pointOfContact"/></div>
	</xsl:if>
	
	<!-- 9b -->
	<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
		<xsl:if test="string-length(gmd:CI_ResponsibleParty/gmd:organisationName)=0 and string-length(gmd:CI_ResponsibleParty/gmd:individualName)=0">
		  <div class='m'><xsl:value-of select="$msg/organisationName"/></div>
		</xsl:if>
		<xsl:if test="string-length(gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue)=0">
		  <div class='m'><xsl:value-of select="$msg/role"/></div>
		</xsl:if>
		<xsl:if test="string-length(gmd:CI_ResponsibleParty/gmd:contactInfo)=0">
		  <div class='c'><xsl:value-of select="$msg/contactInfo"/></div>
	  </xsl:if>
	</xsl:for-each>
	
	<!-- 8.1 -->
	<xsl:if test="string-length(gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation)=0">
	  <div class='c'><xsl:value-of select="$msg/useLimitation"/></div>
	</xsl:if>
	
	<!-- 8.2 -->
	<xsl:if test="string-length(gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:accessConstraints)=0">
	  <div class='c'><xsl:value-of select="$msg/accessConstraints"/></div>
	</xsl:if>
	
	<!-- Až bude definováno v INPIRE 
	<xsl:if test="string-length(gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:pass)=0">
	  <div class='m'><xsl:value-of select="$msg/conformity_degree"/></div>
	</xsl:if>

	<xsl:if test="string-length(gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification)=0">
	  <div class='m'><xsl:value-of select="$msg/conformity_spec"/></div>
	</xsl:if>
	-->
	
	<xsl:choose>
	  <!-- data -->
	  <xsl:when test="gmd:identificationInfo/gmd:MD_DataIdentification">
	  
		<!-- 1.5 -->
		<!-- zatim neni k dispozici z INPISRE 
		<xsl:if test="string-length(results/MD_Metadata/identificationInfo/*/citation//identifier//code)=0">
		  <div class='c'>identifikace / identifikátor zdroje</div>
		</xsl:if>
		-->
	
		<!-- 1.7 -->
		<xsl:if test="string-length(gmd:identificationInfo/*/gmd:language)=0">
		  <div class='c'><xsl:value-of select="$msg/language"/></div>
		</xsl:if>
	
	  	<xsl:if test="string-length(gmd:identificationInfo//gmd:topicCategory)=0">
	  	  <div class='m'><xsl:value-of select="$msg/topicCategory"/></div>
	  	</xsl:if>
	  	
		<!-- 3 -->
		<xsl:choose>
			<xsl:when test="string-length(gmd:identificationInfo/*/gmd:descriptiveKeywords)=0">
		  		<div class='m'><xsl:value-of select="$msg/keyword"/></div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(contains(gmd:identificationInfo,'GEMET'))">
		  			<div class='m'><xsl:value-of select="$msg/gemet"/></div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	
		<!-- 4.1 -->
		<xsl:if test="string-length(gmd:identificationInfo//gmd:EX_Extent//gmd:EX_GeographicBoundingBox)=0">
		  <div class='m'><xsl:value-of select="$msg/geographicElement"/></div>
		</xsl:if>
	
	  	<!-- 6.2 -->
	  	<xsl:if test="string-length(gmd:identificationInfo//gmd:spatialResolution)=0">
	  	  <div class='m'><xsl:value-of select="$msg/spatialResolution"/></div>
	  	</xsl:if>
	  	
		<!-- 6.1 -->
		<xsl:if test="string-length(gmd:dataQualityInfo//gmd:lineage//gmd:statement)=0">
		  <div class='m'><xsl:value-of select="$msg/statement"/></div>
		</xsl:if>
	  
	  </xsl:when>
	  
	  <!-- sluzby -->
	  <xsl:otherwise>
	  
	  	<!-- 2.2 -->
	  	<xsl:if test="string-length(gmd:identificationInfo/*/srv:serviceType)=0">
	  	  <div class='m'><xsl:value-of select="$msg/serviceType"/></div>
	  	</xsl:if>
 
		<!-- 3 -->
		<xsl:choose>
			<xsl:when test="string-length(gmd:identificationInfo/*/gmd:descriptiveKeywords)=0">
		  		<div class='m'><xsl:value-of select="$msg/keyword"/></div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(contains(gmd:identificationInfo,'INSPIRE'))">
		  			<div class='m'><xsl:value-of select="$msg/serviceInspire"/></div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

	  	<!-- <xsl:if test="string-length(gmd:identificationInfo/*/srv:containsOperations)=0">
	  	  <div class='c'><xsl:value-of select="$msg/containsOperations"/></div>
	  	</xsl:if> 
	  	
	      
	  	<xsl:for-each select="gmd:identificationInfo/*/srv:containsOperations/srv:SV_OperationMetadata">
	  		<xsl:if test="string-length(.)>0">
		  		<xsl:if test="string-length(srv:operationName)=0">
		  		  <div class='m'><xsl:value-of select="$msg/operationName"/></div>
		  		</xsl:if>
		  		<xsl:if test="string-length(srv:connectPoint//gmd:linkage)=0">
		  		  <div class='m'><xsl:value-of select="$msg/operation_linkage"/></div>
		  		</xsl:if>
		  		<xsl:if test="string-length(srv:DCP/srv:DCPList/@codeListValue)=0">
		  		  <div class='m'><xsl:value-of select="$msg/DCP"/></div>
		  		</xsl:if>
	  		</xsl:if>
	    </xsl:for-each>-->
	    
		<!-- 4.1 -->
		<xsl:if test="string-length(gmd:identificationInfo//gmd:EX_Extent//gmd:EX_GeographicBoundingBox)=0">
		  <div class='c'><xsl:value-of select="$msg/geographicElement"/></div>
		</xsl:if>
	
	  	<!-- 1.6 --> 
	  	<xsl:if test="string-length(gmd:identificationInfo/*/srv:operatesOn)=0">
	  	  <div class='c'><xsl:value-of select="$msg/operatesOn"/></div>
	  	</xsl:if>
	  
	    <xsl:if test="results/MD_Metadata/hierarchyLevel/MD_ScopeCode!='service'">
	      <div class='m'><xsl:value-of select="$msg/hierarchyLevelService"/></div>
	    </xsl:if>
	  
	  </xsl:otherwise>
	</xsl:choose>
	
	<!-- metadata -->
	
	<!-- 10.1a -->
	<xsl:if test="string-length(gmd:contact)=0">
	  <div class='m'><xsl:value-of select="$msg/md_contact"/></div>
	</xsl:if>
	
	<!-- 10.1b -->
	<xsl:for-each select="gmd:contact">
		<xsl:if test="string-length(gmd:CI_ResponsibleParty/gmd:organisationName)=0 and string-length(gmd:individualName)=0">
		  <div class='m'><xsl:value-of select="$msg/md_organisationName"/></div>
		</xsl:if>
		<xsl:if test="string-length(gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue)=0">
		  <div class='m'><xsl:value-of select="$msg/md_role"/></div>
		</xsl:if>
		<xsl:if test="string-length(gmd:CI_ResponsibleParty/gmd:contactInfo)=0">
		  <div class='c'><xsl:value-of select="$msg/md_contactInfo"/></div>
		</xsl:if>
	</xsl:for-each>
	
	<!-- 10.2 -->
	<xsl:if test="string-length(gmd:dateStamp)=0">
	  <div class='m'><xsl:value-of select="$msg/dateStamp"/></div>
	</xsl:if>
	
	<!-- 10.2 -->
	<xsl:if test="string-length(gmd:language)=0">
	  <div class='m'><xsl:value-of select="$msg/md_lang"/></div>
	</xsl:if>
	
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>
