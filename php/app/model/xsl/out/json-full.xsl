<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"   
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:srv="http://www.isotc211.org/2005/srv" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd"  
  xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
  xmlns:gml="http://www.opengis.net/gml/3.2" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:php="http://php.net/xsl">
<xsl:output method="html"/>

<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<!-- pro ISO 19139 zaznamy -->
<xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata">
    <xsl:variable name="apos">'</xsl:variable>
  	<xsl:variable name="mdlang" select="gmd:language/*/@codeListValue"/>
	$rec = array();
    
	$rec['id'] = '<xsl:value-of select="normalize-space(gmd:fileIdentifier)"/>';	
   	$rec['type']='<xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/>';
	<xsl:if test="gmd:identificationInfo/*/srv:serviceType">
		$rec['serviceType']='<xsl:value-of select="gmd:identificationInfo/*/srv:serviceType/*"/>';
	</xsl:if>
	$rec['title'] = '<xsl:call-template name="multi">
			<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
			<xsl:with-param name="lang" select="$lang"/>
	    	<xsl:with-param name="mdlang" select="$mdlang"/>
	  	</xsl:call-template>'; 
	$rec['abstract'] = '<xsl:call-template name="multi">
		   	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
		   	<xsl:with-param name="lang" select="$lang"/>
		   	<xsl:with-param name="mdlang" select="$mdlang"/>
		</xsl:call-template>';
	$rec['identifier']['code']='<xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*"/>';
	$rec['identifier']['codeSpace']='<xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/*"/>';
	$rec['online'] = array();
	<xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
		$l['url'] = '<xsl:value-of disable-output-escaping="yes" select="php:function('addslashes', normalize-space(*/gmd:linkage/gmd:URL))"/>';
		$l['protocol'] = '<xsl:value-of select="*/gmd:protocol/*"/>';
		<xsl:if test="*/gmd:name">
			$l['description'] = '<xsl:value-of select="*/gmd:name"/>';
		</xsl:if>
		<xsl:if test="*/gmd:description">
			$l = array();
			$l['description'] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="*/gmd:description"/>
		      	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>';
		</xsl:if>
        $rec['online'][] = $l;
	</xsl:for-each>
	<xsl:if test="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName!=''">
		$rec['imgURL'] = '<xsl:value-of select="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName"/>';
	</xsl:if>
    <xsl:if test="string-length(gmd:identificationInfo//gmd:EX_GeographicBoundingBox)!=0">
        $rec['bbox'] = [<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:westBoundLongitude/*)"/>,<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:southBoundLatitude/*)"/>,<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:eastBoundLongitude/*)"/>,<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:northBoundLatitude/*)"/>];
    </xsl:if>
	<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
		$c = array();
		$c['organisationName'] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="*/gmd:organisationName"/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>';
		$c['individualName'] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="*/gmd:individualName"/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>'; 
		$c['deliveryPoint'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint/*"/>'; 	  	
		$c['city'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:city/*"/>'; 	  	
		$c['postalCode'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode/*"/>'; 	  	
		$c['email'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*"/>'; 	  	
		$c['url'] = '<xsl:value-of disable-output-escaping="yes" select="*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*"/>'; 	  	
		$rec['contact'][] = $c;  	
	</xsl:for-each>	  	
	<xsl:for-each select="gmd:contact">
		$c = array();
		$c['organisationName'] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="*/gmd:organisationName"/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>';
		$c['individualName'] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="*/gmd:individualName"/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>'; 
		$c['deliveryPoint'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint/*"/>'; 	  	
		$c['city'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:city/*"/>'; 	  	
		$c['postalCode'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode/*"/>'; 	  	
		$c['email'] = '<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*"/>'; 	  	
		$c['url'] = '<xsl:value-of disable-output-escaping="yes" select="*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage/*"/>'; 	  	
		$rec['mdContact'][] = $c;  	
	</xsl:for-each>
	<xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
		$rec['topicCategory'][] = '<xsl:value-of select="*"/>';
	</xsl:for-each>	  	
	//$rec['inspireKeywords'] = array();
	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title/*,'INSPIRE')]/*/gmd:keyword[gco:CharacterString!='']">
		$rec['inspireKeywords'][] = '<xsl:value-of select="gco:CharacterString"/>';
	</xsl:for-each> 
	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords">
		$kw = array();
		$kw['thesaurus'] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="*/gmd:thesaurusName/*/gmd:title"/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>';
		  	<xsl:for-each select="*/gmd:keyword">
		  		$kw['keywords'][] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="."/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>';
		  	</xsl:for-each>
		$rec['keywords'][] = $kw;
	</xsl:for-each> 
	<xsl:variable name="degree" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult[contains(gmd:specification/*/gmd:title, 'INSPIRE') or contains(gmd:specification/*/gmd:title, 'Commission')]/gmd:pass/*"/>
	$rec['degree'] = <xsl:choose>
		<xsl:when test="$degree!=''"><xsl:value-of select="$degree"/>;</xsl:when>
		<xsl:otherwise>null;</xsl:otherwise>
	</xsl:choose>
	<xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
		$f = array();
		$f['name'] = '<xsl:value-of select="*/gmd:name/*"/>';
		$f['version'] = '<xsl:value-of select="*/gmd:version/*"/>';
		$rec['formats'] = $f;
	</xsl:for-each>	
	$rec['coverageKm'] = '<xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_CompletenessOmission[gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'km')]/*/gmd:value/gco:Record"/>';
	$rec['coveragePercent'] = '<xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_CompletenessOmission[gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'percent')]/*/gmd:value/gco:Record"/>';
	$rec['dateStamp'] = '<xsl:value-of select="gmd:dateStamp/*"/>';
    $json['records'][] = $rec;
</xsl:template>	

<!-- Feature catalogue -->
<xsl:template match="gfc:FC_FeatureCatalogue" xmlns:gfc="http://www.isotc211.org/2005/gfc" xmlns:gmx="http://www.isotc211.org/2005/gmx">
    <xsl:variable name="mdlang" select="gmx:language/*/@codeListValue"/>
    $rec = array();
    $rec['trida']='fc';
    $rec['title'] = '<xsl:call-template name="multi">
			   		<xsl:with-param name="el" select="gmx:name"/>
			   		<xsl:with-param name="lang" select="$lang"/>
			   		<xsl:with-param name="mdlang" select="$mdlang"/>
			  	</xsl:call-template>'; 
    $rec['titles']['<xsl:value-of select="$mdlang"/>'] = '<xsl:value-of select="gmx:name"/>';
    <xsl:for-each select="gmx:name/*/gmd:textGroup">
        $rec['titles']['<xsl:value-of select="substring-after(*/@locale,'-')"/>'] = '<xsl:value-of select="*"/>';
    </xsl:for-each>
    $rec['abstract'] = '<xsl:call-template name="multi">
		   		<xsl:with-param name="el" select="gmx:scope"/>
		   		<xsl:with-param name="lang" select="$lang"/>
		   		<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>';
    $rec['id'] = '<xsl:value-of select="../@uuid"/>';
    $rec['date'] = '<xsl:value-of select="gmx:versionDate"/>';
    $f = array();
    <xsl:for-each select="gfc:featureType">
        $f_['name'] = '<xsl:value-of select="*/gfc:typeName/*"/>';
        $f_['definition'] = '<xsl:call-template name="multi">
		    	<xsl:with-param name="el" select="*/gfc:definition"/>
		      	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>';
        $f[] = $f_;
    </xsl:for-each>
    $rec['features'] = $f;
    $json['records'][] =$rec;
</xsl:template>	
	
	<!-- pro DC zaznamy -->
  <xsl:template match="csw:Record" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/">
    <xsl:variable name="apos">'</xsl:variable>
		$rec = array();
	  	$rec['trida'] = '<xsl:value-of select="dc:type"/>';
		$rec['id'] = '<xsl:value-of select="dc:identifier[substring(.,1,4)!='http']"/>';
		$rec['title'] = '<xsl:value-of select="translate(normalize-space(dc:title), $apos, '')"/>';
		$rec['abstract'] = '<xsl:value-of select="translate(normalize-space(dct:abstract), $apos, '')"/>';
		if(!$rec['abstract']) $rec['abstract'] = '<xsl:value-of select="translate(normalize-space(dc:description), $apos, '')"/>';
		$rec['link'] = '<xsl:value-of select="dc:identifier[substring(.,1,4)='http']"/>';
		$rec['bbox'] = '<xsl:value-of select="ows:BoundingBox/ows:LowerCorner"/><xsl:text> </xsl:text><xsl:value-of select="ows:BoundingBox/ows:UpperCorner"/>';
   		$json['records'][] =$rec;
	</xsl:template> 
	

 <!-- pro multiligualni nazvy -->
  <xsl:template name="multi">
    <xsl:param name="el"/>
    <xsl:param name="lang"/>
    <xsl:param name="mdlang"/>
  
    <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale=concat('#locale-',$lang)]"/>	
     <xsl:choose>
    	<xsl:when test="string-length($txt)>0">
    	  <xsl:value-of select="php:function('addslashes', normalize-space($txt))"/>
    	</xsl:when>
    	<xsl:otherwise>
    	  <xsl:value-of select="php:function('addslashes', normalize-space($el/gco:CharacterString))"/>
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
</xsl:stylesheet>
