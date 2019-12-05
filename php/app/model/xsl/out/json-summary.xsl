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
<xsl:template match="gmd:MD_Metadata">
  	<xsl:variable name="mdlang" select="gmd:language/*/@codeListValue"/>
	$rec = array();
    
    $rec['id'] = "<xsl:value-of select="normalize-space(gmd:fileIdentifier)"/>";	
    <xsl:choose>
		<xsl:when test="gmd:hierarchyLevel/*/@codeListValue!=''">
           	$rec['type']="<xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/>";
       	</xsl:when>
		<xsl:otherwise>$rec['type']='dataset';</xsl:otherwise>
	  	<xsl:when test="(gmd:identificationInfo/srv:SV_ServiceIdentification)!=''">
           $rec['serviceType']="<xsl:value-of select="gmd:identificationInfo/*/srv:serviceType/*"/>";
      	</xsl:when>
	</xsl:choose>
		$rec['title'] = <xsl:call-template name="jmulti">
		    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template> 
		$rec['abstract'] = <xsl:call-template name="jmulti">
		    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
		      	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>
		$rec['links'] = array();
		<xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
			$l['url'] = "<xsl:value-of disable-output-escaping="yes" select="php:function('addslashes', normalize-space(*/gmd:linkage/gmd:URL))"/>";
			$l['protocol'] = "<xsl:value-of select="normalize-space(*/gmd:protocol)"/>";
            <xsl:if test="*/gmd:description">
                $l['description'] = <xsl:call-template name="jmulti">
		    	<xsl:with-param name="el" select="*/gmd:description"/>
		      	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>;
            </xsl:if>
            $rec['links'][] = $l;
		</xsl:for-each>
		//$rec['formats'] = array();
		<!--xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
			$rec['formats'][] = "<xsl:value-of select="*/gmd:name"/>";
		</xsl:for-each-->
		<xsl:if test="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName!=''">
			$rec['imgURL'] = "<xsl:value-of disable-output-escaping="yes" select="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName"/>";
		</xsl:if>
        <xsl:if test="string-length(gmd:identificationInfo//gmd:EX_GeographicBoundingBox)!=0">
            $rec['bbox'] = [<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:westBoundLongitude/*)"/>,<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:southBoundLatitude/*)"/>,<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:eastBoundLongitude/*)"/>,<xsl:value-of select="normalize-space(gmd:identificationInfo//gmd:northBoundLatitude/*)"/>];
        </xsl:if>
        $rec['contacts'] = [];
        <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
            $contact['organisationName'] = <xsl:call-template name="jmulti">
                    <xsl:with-param name="el" select="*/gmd:organisationName"/>
                    <xsl:with-param name="lang" select="$lang"/>
                    <xsl:with-param name="mdlang" select="$mdlang"/>
                </xsl:call-template>
            $contact['email'] = "<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/>";
            $contact['role'] = "<xsl:value-of select="*/gmd:role/*/@codeListValue"/>";
            $rec['contacts'][] = $contact;
        </xsl:for-each>
        
        $rec['dates'] = [];
         <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
            $d['date'] = "<xsl:value-of select="*/gmd:date"/>";
            $d['dateType'] = "<xsl:value-of select="*/gmd:dateType/*/@codeListValue"/>";
            $rec['dates'][] = $d;
         </xsl:for-each>
         
        $rec['keywords'] = array();
		<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*/gmd:keyword">
			$kw['title'] = <xsl:call-template name="jmulti">
		    	<xsl:with-param name="el" select="."/>
		    	<xsl:with-param name="lang" select="$lang"/>
		    	<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>
            <xsl:if test="*/@xlink:href">
                $kw['uri'] = "<xsl:value-of select="*/@xlink:href"/>";
            </xsl:if>
            $rec['keywords'][] = $kw;
		</xsl:for-each> 
		<xsl:variable name="degree" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult[contains(gmd:specification/*/gmd:title, 'INSPIRE') or contains(gmd:specification/*/gmd:title, 'Commission')]/gmd:pass/*"/>
		$rec['degree'] = 
        <xsl:choose>
			<xsl:when test="$degree!=''"><xsl:value-of select="$degree"/>;</xsl:when>
			<xsl:otherwise>null;</xsl:otherwise>
		</xsl:choose>
        <xsl:if test="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator">
            $rec['scales'] = [];
            <xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator">
                $rec['scales'][] = "<xsl:value-of select="*"/>";
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue">
            $rec['updateFrequency'] = "<xsl:value-of select="gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>";
        </xsl:if>
        $rec['dateStamp'] = "<xsl:value-of select="gmd:dateStamp"/>";
        

    $json['records'][] =$rec;
</xsl:template>	

<!-- Feature catalogue -->
<xsl:template match="gfc:FC_FeatureCatalogue" xmlns:gfc="http://www.isotc211.org/2005/gfc" xmlns:gmx="http://www.isotc211.org/2005/gmx">
    <xsl:variable name="mdlang" select="../@lang"/>
    $rec['trida']='fc';
    $rec['title'] = <xsl:call-template name="jmulti">
            <xsl:with-param name="el" select="gmx:name"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="mdlang" select="$mdlang"/>
        </xsl:call-template> 
    $rec['abstract'] = <xsl:call-template name="jmulti">
            <xsl:with-param name="el" select="gmx:scope"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="mdlang" select="$mdlang"/>
        </xsl:call-template>";
    $rec['id'] = "<xsl:value-of select="../@uuid"/>
    $f = array();
    <xsl:for-each select="gfc:featureType">    
        $f['name'] = "<xsl:value-of select="*/gfc:typeName/*"/>";
    </xsl:for-each>
    $rec['features'][] = $f;
    $json['records'][] =$rec;
</xsl:template>	


<!-- pro Dublin Core -->
<xsl:template match="csw:Record" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/">
    $rec = array();
    $rec['trida'] = "<xsl:value-of select="dc:type"/>";
    $rec['id'] = "<xsl:value-of select="dc:identifier[substring(.,1,4)!='http']"/>";
    $rec['title'] = "<xsl:value-of select="php:function('addslashes', normalize-space(dc:title))"/>";
    $rec['abstract'] = "<xsl:value-of select="php:function('addslashes', normalize-space(dct:abstract))"/>";
    if(!$rec['abstract']) $rec['abstract'] = "<xsl:value-of select="php:function('addslashes', normalize-space(dc:description))"/>";
    $rec['link'] = "<xsl:value-of select="dc:identifier[substring(.,1,4)='http']"/>";
    $rec['bbox'] = "<xsl:value-of select="ows:BoundingBox/ows:LowerCorner"/><xsl:text> </xsl:text><xsl:value-of select="ows:BoundingBox/ows:UpperCorner"/>";
    $json['records'][] =$rec;
</xsl:template> 

<!-- multilingual fields -->
<xsl:template name="jmulti">
    <xsl:param name="el"/>
    <xsl:param name="lang"/>
    <xsl:param name="mdlang"/>
  
    <xsl:choose>
        <xsl:when test="$lang">
            <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale=concat('#locale-',$lang)]"/>
            '<xsl:choose>
                <xsl:when test="string-length($txt)>0">
                  <xsl:value-of select="php:function('addslashes', normalize-space($txt))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="php:function('addslashes', normalize-space($el/gco:CharacterString))"/>
                </xsl:otherwise>
            </xsl:choose>';
        </xsl:when>
        <xsl:otherwise>[
            '<xsl:value-of select="$mdlang"/>' =<xsl:text disable-output-escaping="yes">&gt;</xsl:text> <xsl:value-of select="php:function('addslashes', normalize-space($el/gco:CharacterString))"/>
            <xsl:for-each select="$el/*/gmd:textGroup/*">
                ,'<xsl:value-of select="substring-after(@locale,'-')"/>' =<xsl:text disable-output-escaping="yes">&gt;</xsl:text> <xsl:value-of select="php:function('addslashes', normalize-space(.))"/>
            </xsl:for-each>
            ];
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
  
</xsl:stylesheet>
