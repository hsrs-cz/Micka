<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>

<xsl:template match="/" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml"  
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

<xsl:variable name="codeLists" select="document('../../include/xsl/codelists_cze.xml')/map" />

<div id='kontrola'>
<img onclick="md_dexpand(this);" src="themes/default/img/collapse.gif"/>
<div style='display:block;'>
<div style="float:left;">
	<a  href="#" onclick="clickMenu(-19)"><img src="themes/default/img/refresh_small.png"/> </a>
</div>
<div style="float:left; width:150px; margin-left:5px;">	 
	<b> <xsl:value-of select="$msg_verification"/>:</b>
</div>	
<div style="clear: both; margin-top:5px;"></div>
<!-- <span style='font-weight:bold'><xsl:value-of select="$msg_nadpis"/></span>
(<span style='color:red'><xsl:value-of select="$msg_mandatory"/> </span> 
 / <span  style='color:#00A000'><xsl:value-of select="$msg_recommended"/> </span>)
:
<br/>-->
<!-- identifikace -->

<!-- 1.1 (2.2.1) -->
<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:citation/*/gmd:title)=0">
  <div class="mdCheckRow" onclick="md_scroll('5063_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_citation"/> / <xsl:value-of select="$msg_title"/></span></div>
</xsl:if>

<!-- 1.2 (2.2.2) -->
<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:abstract)=0">
  <div class="mdCheckRow" onclick="md_scroll('5061_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_abstract"/></span></div>
</xsl:if>

<!-- 1.3 (2.2.3) -->
<xsl:if test="string-length(*/gmd:hierarchyLevel)=0">
  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'><xsl:value-of select="$msg_hierarchyLevel"/></span></div>
</xsl:if>

<!-- 5a (2.6.2-4) --> 
<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:citation/*/gmd:date/*/gmd:date)=0">
  <div class="mdCheckRow" onclick="md_scroll('14_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_citation"/> / <xsl:value-of select="$msg_date"/></span></div>
</xsl:if>

<!-- 5a (2.6.2-4) -->
<xsl:for-each select="*/gmd:identificationInfo/*/gmd:citation/*/gmd:date">
	<xsl:if test="string-length(*/gmd:dateType/*/@codeListValue)=0">
	  <div class="mdCheckRow" onclick="md_scroll('13_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_citation"/> / <!--  <xsl:value-of select="$msg_dateType"/>--> (<xsl:value-of select="*/gmd:date"/>)</span></div>
	</xsl:if>
</xsl:for-each>

<!-- 6.2 -->
<!-- pro sluzbu neni definovana, presunul jsem do MD_DataIndetification 
<xsl:if test="string-length(results/MD_Metadata/identificationInfo//spatialResolution)=0">
  <div class="mdCheckRow" onclick="md_scroll('')"><span class='c'><xsl:value-of select="$msg_spatialResolution"/></span></div>
</xsl:if>-->

<!-- 9a -->
<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:pointOfContact)=0">
  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_pointOfContact"/></span></div>
</xsl:if>

<!-- 9b -->
<xsl:for-each select="*/gmd:identificationInfo/*/gmd:pointOfContact">
	<xsl:if test="string-length(*/gmd:organisationName)=0 and string-length(*/gmd:individualName)=0">
	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_pointOfContact"/> / <xsl:value-of select="$msg_organisationName"/></span></div>
	</xsl:if>
	<xsl:if test="string-length(*/gmd:role/*/@codeListValue)=0">
	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_pointOfContact"/> / <xsl:value-of select="$msg_role"/></span></div>
	</xsl:if>
	<xsl:if test="string-length(*/gmd:contactInfo)=0">
	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_pointOfContact"/> / <xsl:value-of select="$msg_contactInfo"/></span></div>
  </xsl:if>
</xsl:for-each>

<!-- 8.1 -->
<xsl:if test="count(*/gmd:identificationInfo/*/gmd:resourceConstraints[string-length(*/gmd:useLimitation)>0])=0">
  <div class="mdCheckRow" onclick="md_scroll('86_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_resourceConstraints"/> / <xsl:value-of select="$msg_useLimitation"/></span></div>
</xsl:if>

<!-- 8.2 -->
<xsl:if test="count(*/gmd:identificationInfo/*/gmd:resourceConstraints[string-length(*/gmd:accessConstraints/*/@codeListValue)>0 or string-length(*/gmd:otherConstraints)>0])=0">
  <xsl:value-of select="*/gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:accessConstraints/*/@codeListValue"/>
  <div class="mdCheckRow" onclick="md_scroll('86_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_resourceConstraints"/> / <xsl:value-of select="$msg_accessConstraints"/></span></div>
</xsl:if>

<!-- 1.4 (2.2.4) -->
<xsl:if test="string-length(*/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine//gmd:linkage)=0">
  <div class="mdCheckRow" onclick="md_scroll('')"><span class='c'><xsl:value-of select="$msg_distributionInfo"/> / <xsl:value-of select="$msg_transferOptions"/> / <xsl:value-of select="$msg_onLine"/></span></div>
</xsl:if>

<xsl:choose>
  <!-- data -->
  <xsl:when test="string-length(*/gmd:identificationInfo/gmd:MD_DataIdentification)>0">

	<!-- 1.5 (2.2.5) -->
	<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:citation//gmd:identifier//gmd:code)=0">
	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='c'>identifikace / identifikátor zdroje</span></div>
	</xsl:if> 

	<!-- 6.2 -->
	<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:spatialResolution)=0">
	  <div class="mdCheckRow" onclick="md_scroll('96_0_')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_spatialResolution"/></span></div>
	</xsl:if>

	<!-- 1.7 (2.2.7) -->
	<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:language)=0">
	  <div class="mdCheckRow" onclick="md_scroll('5_0_')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_language"/></span></div>
	</xsl:if>
 
  	<!-- 2.1 (2.3.1) -->
  	<xsl:if test="string-length(*/gmd:identificationInfo//gmd:topicCategory)=0">
  	  <div class="mdCheckRow" onclick="md_scroll('361_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_topicCategory"/></span></div>
  	</xsl:if>

	<!-- 4.1 (2.5)-->
	<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement)=0">
	  <div class="mdCheckRow" onclick="md_scroll('489_0')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_extent"/> / <xsl:value-of select="$msg_geographicElement"/></span></div>
	</xsl:if>
  

	<!-- 5b -->
	<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:extent//gmd:temporalElement)=0">
	  <div class="mdCheckRow" onclick="md_scroll('490_0_')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_extent"/> / <xsl:value-of select="$msg_temporalElement"/></span></div>
	</xsl:if> 
  
	<!-- 3 (2.4.1-2) -->
	<xsl:choose>
		<xsl:when test="string-length(normalize-space(*/gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,'GEMET - INSPIRE themes')]/*/gmd:keyword/gco:CharacterString))=0">
	  		<div class="mdCheckRow" onclick="md_scroll('84_0_')"><span class='c'><xsl:value-of select="$msg_keyword"/> INSPIRE</span></div>
		</xsl:when>
	</xsl:choose>

	<!-- 6.1 -->
	<xsl:if test="string-length(*/gmd:dataQualityInfo//gmd:lineage//gmd:statement)=0">
	  <div class="mdCheckRow" onclick="md_scroll(51_0_'')"><span class='m'><xsl:value-of select="$msg_dataQualityInfo"/> / <xsl:value-of select="$msg_lineage"/></span></div>
	</xsl:if>
  
  </xsl:when>
  
  <!-- sluzby -->
  <xsl:otherwise>

	<!-- 4.1 -->
	<xsl:if test="string-length(*/gmd:identificationInfo/*/srv:extent//gmd:geographicElement)=0">
	  <div class="mdCheckRow" onclick="md_scroll('489_0')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_geographicElement"/></span></div>
	</xsl:if>
  
  	<!-- 2.2 (2.3.2) -->

  	<xsl:if test="string-length(*/gmd:identificationInfo/*/srv:serviceType/*)=0">
  	  <div class="mdCheckRow" onclick="md_scroll('5115_0_')"><span class='m'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_serviceType"/></span></div>
  	</xsl:if>
   
	<!-- 3 (2.4.1-2) -->
	<xsl:choose>
		<xsl:when test="string-length(normalize-space(*/gmd:identificationInfo/*/gmd:descriptiveKeywords/*[contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'19119')]/gmd:keyword/gco:CharacterString))=0">
	  		<div class="mdCheckRow" onclick="md_scroll('4919_0_')"><span class='c'><xsl:value-of select="$msg_keyword"/> ISO 19119 ...</span></div>
		</xsl:when>
	</xsl:choose>

	<!-- 6.2 -->
	<!--<xsl:if test="string-length(*/gmd:identificationInfo/*/gmd:spatialResolution)=0">
	  <div class="mdCheckRow" onclick="md_scroll('96_0_')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_spatialResolution"/></span></div>
	</xsl:if>


  	 <xsl:if test="string-length(results/MD_Metadata/identificationInfo/SV_ServiceIdentification//containsOperations)=0">
  	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='c'><xsl:value-of select="$msg_containsOperations"/></span></div>
  	</xsl:if>
    -->
       
  	<!-- <xsl:for-each select="results/MD_Metadata/identificationInfo/SV_ServiceIdentification//containsOperations/*">
  		<xsl:if test="string-length(//operationName)=0">
  		  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'><xsl:value-of select="$msg_operationName"/></span></div>
  		</xsl:if>
  		<xsl:if test="string-length(//linkage)=0">
  		  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'><xsl:value-of select="$msg_operation_linkage"/></span></div>
  		</xsl:if>
  		<xsl:if test="string-length(//DCP)=0">
  		  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'><xsl:value-of select="$msg_DCP"/></span></div>
  		</xsl:if>
    </xsl:for-each>-->
    
    <!-- 1.6 (2.2.6) -->   
  	<xsl:if test="string-length(*/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn/@xlink:href)=0">
  	  <div class="mdCheckRow" onclick="md_scroll('5120_0_')"><span class='c'><xsl:value-of select="$msg_identificationInfo"/> / <xsl:value-of select="$msg_operatesOn"/></span></div>
  	</xsl:if>

    <xsl:if test="*/gmd:hierarchyLevel/gmd:MD_ScopeCode!='service'">
      <div class="mdCheckRow" onclick="md_scroll('122_0_')"><span class='m'><xsl:value-of select="$msg_hierarchyLevel"/>!=service</span></div>
    </xsl:if>
  
  </xsl:otherwise>
</xsl:choose>

<!-- metadata -->

<!-- 10.1a -->
<xsl:if test="string-length(*/gmd:contact)=0">
  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'>metadata <xsl:value-of select="$msg_contact"/></span></div>
</xsl:if>

<!-- 10.1b -->
<xsl:for-each select="*/gmd:contact">
	<xsl:if test="string-length(*/gmd:organisationName)=0 and string-length(*/gmd:individualName)=0">
	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'>metadata <xsl:value-of select="$msg_contact"/> / <xsl:value-of select="$msg_organisationName"/></span></div>
	</xsl:if>
	<xsl:if test="string-length(*/gmd:role/*/@codeListValue)=0">
	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'>metadata <xsl:value-of select="$msg_contact"/> / <xsl:value-of select="$msg_role"/></span></div>
	</xsl:if>
	<xsl:if test="string-length(*/gmd:contactInfo)=0">
	  <div class="mdCheckRow" onclick="md_scroll('')"><span class='c'>metadata <xsl:value-of select="$msg_contact"/> / <xsl:value-of select="$msg_contactInfo"/></span></div>
	</xsl:if>
</xsl:for-each>

<!-- 10.2 -->
<xsl:if test="string-length(*/gmd:dateStamp)=0">
  <div class="mdCheckRow" onclick="md_scroll('')"><span class='m'>metadata <xsl:value-of select="$msg_dateStamp"/></span></div>
</xsl:if>

<!-- 10.2 -->
<xsl:if test="string-length(*/gmd:language)=0">
  <div class="mdCheckRow" onclick="md_scroll('39_0_')"><span class='m'>metadata <xsl:value-of select="$msg_language"/></span></div>
</xsl:if>

</div>
</div>

<script>
  //window.onscroll=function(){
  //  if(document.all) document.all['kontrola'].style.pixelTop = document.body.scrollTop + 10;
  //}
</script>

</xsl:template>
</xsl:stylesheet>
