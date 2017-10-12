<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gmi="http://www.isotc211.org/2005/gmi"
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" 
	xmlns:gml="http://www.opengis.net/gml" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:exsl="http://exslt.org/common"
    xmlns:php="http://php.net/xsl"
    extension-element-prefixes="exsl"
>
<xsl:output method="html" encoding="utf-8"/>

<xsl:param name="mds" select="0" />

<xsl:include href="kote-common.xsl" />

<xsl:variable name="mlang">
	<xsl:choose>
		<xsl:when test="*/gmd:language/*/@codeListValue!=''"><xsl:value-of select="*/gmd:language/*/@codeListValue"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$lang"/></xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:template match="*">


    <xsl:variable name="serv" select="string-length(gmd:identificationInfo/srv:SV_ServiceIdentification)>0 or $mds=10"/>
    <xsl:variable name="langs" select="//gmd:locale" />
    <xsl:variable name="typeList">inspire<xsl:if test="$serv">Service</xsl:if>Type</xsl:variable>
    <xsl:variable name="m"><xsl:if test="not($serv)">mand </xsl:if></xsl:variable>
    
    <!-- langs -->
    <xsl:for-each select="$langs">
        <input type="hidden" name="locale[]" value="{*/gmd:languageCode/*/@codeListValue}"/>
    </xsl:for-each>

    <!-- 1.1 Title -->
	<xsl:call-template name="drawInput">
		<xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
		<xsl:with-param name="name" select="'title'"/>
		<xsl:with-param name="valid" select="'1.1'"/>
		<xsl:with-param name="langs" select="$langs"/>
		<xsl:with-param name="req" select="1"/>
	</xsl:call-template>

    <!-- 1.2 Abstract -->
	<xsl:call-template name="drawInput">
		<xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:abstract"/>
		<xsl:with-param name="name" select="'abstract'"/>
		<xsl:with-param name="type" select="'textarea'"/>
		<xsl:with-param name="valid" select="'1.2'"/>
		<xsl:with-param name="langs" select="$langs"/>
		<xsl:with-param name="req" select="1"/>
	</xsl:call-template>
	
    <!-- 1.3 Resource type -->	
    <xsl:call-template name="drawInput">
        <xsl:with-param name="value" select="gmd:hierarchyLevel/*/@codeListValue"/>
        <xsl:with-param name="name" select="'hierarchyLevel'"/>
        <xsl:with-param name="codes" select="$typeList"/>
        <xsl:with-param name="valid" select="'1.3'"/>
        <xsl:with-param name="class" select="'short'"/>
        <xsl:with-param name="req" select="1"/>
    </xsl:call-template>
    
    <!-- 1.4 linkage -->
    <div>
        <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine|.">
            <xsl:if test="normalize-space(*/gmd:linkage)!='' or (normalize-space(*/gmd:linkage)='' and position()=last())">
                <fieldset>
                    <div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'linkage'"/>
                            <xsl:with-param name="class" select="'cond'"/>
                            <xsl:with-param name="valid" select="'1.4'"/>
                            <xsl:with-param name="dupl" select="1"/>
                        </xsl:call-template>
                    </div>           
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'url'"/>
                        <xsl:with-param name="path" select="'linkage-url[]'"/>
                        <xsl:with-param name="value" select="*/gmd:linkage"/> 
                        <xsl:with-param name="class" select="'cond inp2'"/>
                        <xsl:with-param name="type" select="'plain'"/> 
                    </xsl:call-template>
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'function'"/>
                        <xsl:with-param name="path" select="'linkage-function[]'"/>
                        <xsl:with-param name="value" select="*/gmd:function/*/@codeListValue"/> 
                        <xsl:with-param name="codes" select="'function'"/>
                        <xsl:with-param name="class" select="'cond inp2 short'"/>
                   </xsl:call-template>
                   <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'protocol'"/>
                        <xsl:with-param name="path" select="'linkage-protocol[]'"/>
                        <xsl:with-param name="value" select="*/gmd:protocol"/>
                        <xsl:with-param name="codes" select="'protocol'"/>
                        <xsl:with-param name="class" select="'cond inp2 short'"/>   
                    </xsl:call-template>
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'name'"/>
                        <xsl:with-param name="path" select="'linkage-name[]'"/>
                        <xsl:with-param name="value" select="*/gmd:name"/>
                        <xsl:with-param name="class" select="'inp2'"/>
                        <xsl:with-param name="langs" select="$langs"/>
                    </xsl:call-template>
                    <div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'description'"/>
                            <xsl:with-param name="path" select="'linkage-description[]'"/>
                            <xsl:with-param name="class" select="'inp2'"/>
                            <xsl:with-param name="valid" select="'1.4'"/>
                        </xsl:call-template>
                        <div class="col-xs-12 col-md-8">
                            <xsl:variable name="value" select="*/gmd:description"/>
                            <input name="linkage-description[][TXT]" class="form-control txt {/*/gmd:language/*/@codeListValue} inp2" value="{php:function('noMime',string(*/gmd:description/*))}"/>
                            <xsl:for-each select="$langs">
                                <xsl:variable name="pos" select="position()"/>
                                <xsl:choose>
                                    <xsl:when test="$value">
                                        <input name="linkage-description[][{*/gmd:languageCode/*/@codeListValue}]" class="form-control txt {*/gmd:languageCode/*/@codeListValue}" value="{$value/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',$langs[$pos]/*/@id)]}"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <input name="linkage-description[][{*/gmd:languageCode/*/@codeListValue}]" class="form-control txt {*/gmd:languageCode/*/@codeListValue}" value=""/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            
                            </xsl:for-each>
                        </div>
                    </div>
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'mime'"/>
                        <xsl:with-param name="path" select="'linkage-mime[]'"/>
                        <xsl:with-param name="value" select="php:function('getMime',string(*/gmd:description/*))"/>
                        <xsl:with-param name="class" select="'inp2 short'"/>
                        <xsl:with-param name="attr" select="'code'"/>
                        <xsl:with-param name="multi" select="0"/>
                        <xsl:with-param name="codes" select="'format'"/>
                        <xsl:with-param name="valid" select="'CZ-15'"/>
                    </xsl:call-template>
                    <xsl:variable name="ap">
                        <xsl:if test="*/gmd:description/*/@xlink:href">1</xsl:if>
                    </xsl:variable>
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'accessPoint'"/>
                        <xsl:with-param name="path" select="'linkage-accessPoint[]'"/>
                        <xsl:with-param name="value" select="$ap"/>
                        <xsl:with-param name="codes" select="'compliant'"/>
                        <xsl:with-param name="class" select="'short inp2'"/>
                        <xsl:with-param name="type" select="'boolean'"/>
                    </xsl:call-template>
                </fieldset>
            </xsl:if>
        </xsl:for-each>  
    </div>
    
    <!-- 1.5 identifier -->
    <div class="row">
        <xsl:call-template name="drawLabel">
            <xsl:with-param name="name" select="'identifier'"/>
            <xsl:with-param name="class" select="$m"/>
            <xsl:with-param name="valid" select="'1.5'"/>
        </xsl:call-template>			

        
        <div class="col-xs-12 col-md-8">
            <select name="identifier[]" class="sel2" multiple="multiple" data-tags="true" data-allow-clear="true">
                <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/*/@xlink:href">
                    <option value="{.}" selected="selected"><xsl:value-of select="."/></option>
                </xsl:for-each>
            </select>
        </div>       
    </div>

    <!-- 1.6 operatesOn -->
    <xsl:if test="$serv">
        <xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn|/.">
            <xsl:if test="string-length(@xlink:href)>0 or (string-length(@xlink:href)=0 and position()=last())">
     
                <xsl:variable name="url">
                    <xsl:choose>
                    <xsl:when test="contains(@xlink:href,'#')">
                        <xsl:value-of select="substring-before(@xlink:href,'#')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@xlink:href"/>
                    </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <fieldset>
                    <div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'operatesOn'"/>
                            <xsl:with-param name="class" select="'cond'"/>
                            <xsl:with-param name="valid" select="'1.6'"/>
                            <xsl:with-param name="dupl" select="1"/>
                        </xsl:call-template>
                    </div>    
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'operatesOn-href'"/>
                        <xsl:with-param name="value" select="$url"/> 
                        <xsl:with-param name="class" select="'inp2'"/> 
                        <xsl:with-param name="action" select="'getParent(this)'"/>
                        <xsl:with-param name="type" select="'plain'"/>  
                    </xsl:call-template>
                    
                    <!--xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'operatesOn-uuid'"/>
                        <xsl:with-param name="value" select="substring-after(@xlink:href,'#_')"/> 
                        <xsl:with-param name="class" select="'inp2'"/>
                        <xsl:with-param name="type" select="'plain'"/>   
                    </xsl:call-template-->
                    
                    <xsl:variable name="ootitle">
                        <xsl:choose>
                            <xsl:when test="@xlink:title!=''">
                                <xsl:value-of select="@xlink:title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="*/gmd:citation/*/gmd:title"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'operatesOn-title'"/>
                        <xsl:with-param name="value" select="$ootitle"/>
                        <xsl:with-param name="class" select="'inp2'"/> 
                        <xsl:with-param name="type" select="'plain'"/>   
                    </xsl:call-template>
                
                </fieldset>
            </xsl:if>
        </xsl:for-each>
    </xsl:if> 
    
    <xsl:if test="not($serv)">
        <!-- 1.7 resource language -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'language'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:language/*/@codeListValue"/>
            <xsl:with-param name="codes" select="'language'"/>
            <xsl:with-param name="multi" select="2"/>
            <xsl:with-param name="valid" select="'1.7'"/>
            <xsl:with-param name="req" select="'1'"/>
        </xsl:call-template>

        <!-- 2.1 topic category -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'topicCategory'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:topicCategory/gmd:MD_TopicCategoryCode"/>
            <xsl:with-param name="codes" select="'topicCategory'"/>
            <xsl:with-param name="class" select="'mandatory'"/>
            <xsl:with-param name="multi" select="2"/> 
            <xsl:with-param name="valid" select="'2.1'"/>
            <xsl:with-param name="req" select="'1'"/>   
        </xsl:call-template>
    </xsl:if>

    <xsl:if test="$serv">
        <!-- 2.2 service type -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'serviceType'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/srv:serviceType"/>
            <xsl:with-param name="codes" select="'serviceType'"/>
            <xsl:with-param name="multi" select="1"/> 
            <xsl:with-param name="class" select="'mandatory'"/>
            <xsl:with-param name="valid" select="'2.2'"/>   
        </xsl:call-template>

        <!-- CZ-8 service type version -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'serviceTypeVersion'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/srv:serviceTypeVersion"/>
            <xsl:with-param name="multi" select="2"/> 
            <xsl:with-param name="class" select="'inpS'"/>
            <xsl:with-param name="valid" select="'CZ-8'"/>   
        </xsl:call-template>
    </xsl:if>
    
    <!-- 3.1 keywords -->
    <xsl:choose>
        <xsl:when test="$serv">
   	  	
            <!-- services taxonomy -->
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'inspireService'"/>
                <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title/*,'19119')]/*/gmd:keyword"/>
                <xsl:with-param name="codes" select="'serviceKeyword'"/>
                <xsl:with-param name="req" select="1"/>
                <xsl:with-param name="multi" select="0"/>
                <xsl:with-param name="valid" select="'3'"/>
            </xsl:call-template>

            <!-- INSPIRE themes -->
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'inspireTheme'"/>
                <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/*,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword"/>
                <xsl:with-param name="codes" select="'inspireKeywords'"/>
                <xsl:with-param name="multi" select="2"/>
                <xsl:with-param name="valid" select="'3.1'"/>
            </xsl:call-template> 
            
            <!-- other KW with thesaurus -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(contains(gmd:thesaurusName/*/gmd:title/*,'19119')) and not(contains(gmd:thesaurusName/*/gmd:title/*,'INSPIRE')) and string-length(gmd:thesaurusName/*/gmd:title)>0]">
                <xsl:variable name="i" select="position()-1"/>
                <input type="hidden" name="othes-title" value="{gmd:thesaurusName/*/gmd:title}"/>
                <input type="hidden" name="othes-date" value="{gmd:thesaurusName/*/gmd:date/*/gmd:date/*}"/>
                <input type="hidden" name="othes-dateType" value="{gmd:thesaurusName/*/gmd:date/*/gmd:dateType/*/@codeListValue}"/>
            
                <xsl:for-each select="gmd:keyword">
                    <input type="hidden" name="othes_{$i}_kw_{position()-1}_TXT" value="{gco:CharacterString}"/>
                    <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup">
                        <input type="hidden" name="othes_{$i}_kw_{position()-1}_TXT{substring-after(gmd:LocalisedCharacterString/@locale,'-')}" value="{gmd:LocalisedCharacterString}"/>
                    </xsl:for-each>
                </xsl:for-each>  
            </xsl:for-each>
            
    	</xsl:when>
    
    	<xsl:otherwise>
        
            <!-- INSPIRE themes -->
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'inspireTheme'"/>
                <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title/*, 'GEMET - INSPIRE')]/*/gmd:keyword"/>
                <xsl:with-param name="codes" select="'inspireKeywords'"/>
                <xsl:with-param name="multi" select="2"/>
                <xsl:with-param name="valid" select="'3'"/>
            </xsl:call-template> 
                
       		<!-- ostatni KW s thesaurem-->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[substring(gmd:thesaurusName/*/gmd:title/*,1,15) != 'GEMET - INSPIRE' and string-length(gmd:thesaurusName/*/gmd:title/*)>0]">
                <xsl:variable name="i" select="position()-1"/>
                <input type="hidden" name="othes_{$i}_title" value="{gmd:thesaurusName/*/gmd:title/gco:CharacterString}"/>
                <input type="hidden" name="othes_{$i}_date" value="{gmd:thesaurusName/*/gmd:date/*/gmd:date/*}"/>
                <input type="hidden" name="othes_{$i}_dateType" value="{gmd:thesaurusName/*/gmd:date/*/gmd:dateType/*/@codeListValue}"/>
                
                <xsl:for-each select="gmd:keyword">
               		<xsl:variable name="p" select="position()-1"/>
                  	<input type="hidden" name="othes_{$i}_kw_{$p}_TXT" value="{gco:CharacterString}"/>
                  	<xsl:for-each select="gmd:PT_FreeText/gmd:textGroup">
                  		<input type="hidden" name="othes_{$i}_kw_{$p}_TXT{substring-after(gmd:LocalisedCharacterString/@locale,'-')}" value="{gmd:LocalisedCharacterString}"/>
                  	</xsl:for-each>
                </xsl:for-each>  
            </xsl:for-each>
		

        </xsl:otherwise>
    </xsl:choose>

    <!-- other free KW -->
    <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords[string-length(*/gmd:thesaurusName/*/gmd:title/*)=0]/*/gmd:keyword|/."> 
        <xsl:if test="gco:CharacterString|gmx:Anchor!='' or (gco:CharacterString|gmx:Anchor='' and position()=last())">

            <fieldset>
                <div class="row">
                    <xsl:call-template name="drawLabel">
                        <xsl:with-param name="name" select="'fkw'"/>
                        <xsl:with-param name="class" select="'mand wide'"/>
                        <xsl:with-param name="dupl" select="1"/>
                    </xsl:call-template>			
                </div>
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="value" select="."/>
                    <xsl:with-param name="name" select="'fkw'"/>
                    <xsl:with-param name="path" select="'fkw-keyword[]'"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="langs" select="$langs"/>
                </xsl:call-template>
            </fieldset>
        </xsl:if>
    </xsl:for-each>


	<xsl:variable name="kwg">
	 	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[substring(gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - Concept']/gmd:keyword">
  	   <xsl:value-of select="."/>
  	   <xsl:if test="not(position()=last())"><xsl:text>
</xsl:text>
       </xsl:if>
  	</xsl:for-each>
	</xsl:variable>
       
    <!-- 4.1 spatial extent -->
    <div class="row">
        <xsl:call-template name="drawLabel">
            <xsl:with-param name="name" select="'spatialExt'"/>
            <xsl:with-param name="class" select="concat('cond ',$m)"/>
            <xsl:with-param name="valid" select="'4.1'"/>
        </xsl:call-template>	
	
        <div class="col-xs-12 col-md-8">
            <div id="overmap" style="width:100%; height:400px;"></div>
            <input type="text" class="form-control tiny " id="xmin" name="xmin" pattern="[-+]?[0-9]*\.?[0-9]*" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:westBoundLongitude/*}" size="5" />
            <input type="text" class="form-control tiny " id="ymin" name="ymin" pattern="[-+]?[0-9]*\.?[0-9]*" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:southBoundLatitude/*}" size="5" />
            <input type="text" class="form-control tiny " id="xmax" name="xmax" pattern="[-+]?[0-9]*\.?[0-9]*" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:eastBoundLongitude/*}" size="5" />
            <input type="text" class="form-control tiny " id="ymax" name="ymax" pattern="[-+]?[0-9]*\.?[0-9]*" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:northBoundLatitude/*}" size="5" />
        </div>
    </div>
    <!-- CZ-14 geographic identifier -->
    <xsl:call-template name="drawInput">
        <xsl:with-param name="name" select="'extentId'"/>
        <xsl:with-param name="value" select="gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:code"/>
        <xsl:with-param name="codes" select="'extents'"/>
        <xsl:with-param name="multi" select="0"/>
        <xsl:with-param name="valid" select="'4.1'"/>
    </xsl:call-template>
    
    <xsl:if test="not($serv)">
    	<!-- CZ-10 % -->
    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coveragePercent'"/>
    	    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/*/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'#percent')]/*/gmd:value"/>
    	    <xsl:with-param name="type" select="'real'"/>
    	    <xsl:with-param name="class" select="'short'"/>
    	    <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>
    </xsl:if>
    
    <!-- datum --> 
    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date|/."> 
        <xsl:if test="normalize-space(*/gmd:date)!='' or (normalize-space(*/gmd:date)='' and position()=last())">

            <fieldset>
                <div class="row">
                    <xsl:call-template name="drawLabel">
                        <xsl:with-param name="name" select="'date'"/>
                        <xsl:with-param name="class" select="'mand wide'"/>
                        <xsl:with-param name="dupl" select="1"/>
                    </xsl:call-template>			
                </div>
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'date'"/>
                    <xsl:with-param name="path" select="'date-date[]'"/>
                    <xsl:with-param name="value" select="*/gmd:date"/>
                    <xsl:with-param name="type" select="'date'"/>
                    <xsl:with-param name="valid" select="'5a'"/>
                    <xsl:with-param name="class" select="'mandatory inp2'"/>
                    <xsl:with-param name="req" select="'1'"/>
                </xsl:call-template>
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'dateType'"/>
                    <xsl:with-param name="path" select="'date-type[]'"/>
                    <xsl:with-param name="value" select="*/gmd:dateType/*/@codeListValue"/>
                    <xsl:with-param name="codes" select="'dateType'"/>
                    <xsl:with-param name="class" select="'inp2 short'"/>
                    <xsl:with-param name="req" select="1"/>
                </xsl:call-template>
            </fieldset>
        </xsl:if>
    </xsl:for-each>  

	<div class="row">
 		<xsl:call-template name="drawLabel">
			<xsl:with-param name="name" select="'timeExtent'"/>
			<xsl:with-param name="class" select="'cond'"/>
			<xsl:with-param name="valid" select="'5b'"/>
		</xsl:call-template>	
	
        <div class="col-xs-12 col-md-8">
            <xsl:for-each select="gmd:identificationInfo/*/*/*/gmd:temporalElement|/.">
                <xsl:if test="string-length(*/gmd:extent)>0 or(string-length(*/gmd:extent)=0 and position()=last())">
                    <div>
                       <input class="D form-control" style="display:inline-block" data-provide="datepicker" name="tempExt-from[]" value="{php:function('iso2date', string(*/gmd:extent/*/*[1]),$mlang)}"/> 
                      - <input class="D form-control" style="display:inline-block" data-provide="datepicker" name="tempExt-to[]"  value="{php:function('iso2date', string(*/gmd:extent/*/*[2]),$mlang)}"/> 
                        <xsl:text> </xsl:text><span class="duplicate"></span>
                    </div>
                </xsl:if>
            </xsl:for-each>
        </div>        
	</div>
 
    <!-- 6.1 lineage -->
	<xsl:if test="not($serv)">
	 	<xsl:call-template name="drawInput">
		  	<xsl:with-param name="name" select="'lineage'"/>
		    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
            <xsl:with-param name="langs" select="$langs"/>
		    <xsl:with-param name="type" select="'textarea'"/> 
            <xsl:with-param name="req" select="1"/>
            <xsl:with-param name="valid" select="'6.1'"/>
		</xsl:call-template>

        <!-- 12 data quality scope -->
	 	<xsl:call-template name="drawInput">
		  	<xsl:with-param name="name" select="'dqScope'"/>
		    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:scope/*/gmd:level/*/@codeListValue"/>
		    <xsl:with-param name="class" select="'short'"/>
		    <xsl:with-param name="codes" select="$typeList"/> 
            <xsl:with-param name="req" select="1"/>
            <xsl:with-param name="valid" select="'6.1'"/>
		</xsl:call-template>
    
        <!-- 6.2 denominator -->
        <div class="row">
            <xsl:call-template name="drawLabel">
                <xsl:with-param name="name" select="'scale'"/>
                <xsl:with-param name="class" select="'cond '"/>
                <xsl:with-param name="valid" select="'6.2'"/>
            </xsl:call-template>			
            
            <div class="col-xs-12 col-md-8">
                <select name="denominator[]" class="sel2" multiple="multiple" data-tags="true" data-allow-clear="true">
                    <xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator">
                        <option value="{.}" selected="selected"><xsl:value-of select="."/></option>
                    </xsl:for-each>
                </select>
            </div>
        </div>

        <!-- 6.2 distance --> 	
        <div class="row">
            <xsl:call-template name="drawLabel">
                <xsl:with-param name="name" select="'distance'"/>
                <xsl:with-param name="class" select="'cond '"/>
            </xsl:call-template>			
            
            <div class="col-xs-12 col-md-8">
                <select name="distance[]" class="sel2" multiple="multiple" data-tags="true" data-allow-clear="true">
                    <xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:distance">
                        <option value="{.}" selected="selected"><xsl:value-of select="."/></option>
                    </xsl:for-each>
                </select>
            </div>
        </div>
    </xsl:if>
    
    <!-- 7 -->
    <div>
        <xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result[contains(*/gmd:specification/*/gmd:title/*/@xlink:href,'https://data.europa.eu/eli/')]|/.">
            <xsl:if test="string-length(*/gmd:specification)>0 or (string-length(*/gmd:specification)=0 and position()=last())">
                <fieldset>
                    <div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'Conformity'"/>
                            <xsl:with-param name="class" select="'mand'"/>
                            <xsl:with-param name="dupl" select="1"/>
                            <xsl:with-param name="valid" select="'7.1'"/>
                        </xsl:call-template>		
                    </div>
                    
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'specification'"/>
                        <xsl:with-param name="path" select="'specification-uri[]'"/>
                        <xsl:with-param name="value" select="*/gmd:specification/*/gmd:title"/>
                        <xsl:with-param name="class" select="'inp2'"/>
                        <xsl:with-param name="req" select="1"/>
                        <xsl:with-param name="codes" select="'specifications'"/> 
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'compliant'"/>
                        <xsl:with-param name="path" select="'specification-compliant[]'"/>
                        <xsl:with-param name="value" select="*/gmd:pass/gco:Boolean|*/gmd:pass/@gco:nilReason"/>
                        <xsl:with-param name="codes" select="'compliant'"/>
                        <xsl:with-param name="req" select="1"/>
                        <xsl:with-param name="class" select="'short inp2'"/>
                    </xsl:call-template>
                </fieldset>
            </xsl:if>
        </xsl:for-each>
    </div>
    
  	<!-- Conditions applying to access and use --> 
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'accessCond'"/>
	    <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints"/>
	    <xsl:with-param name="codes" select="'accessCond'"/>
	    <xsl:with-param name="multi" select="2"/>
        <xsl:with-param name="req" select="1"/>
	    <xsl:with-param name="valid" select="'8.1'"/>
        <xsl:with-param name="tags" select="1"/>
	    <!-- <xsl:with-param name="class" select="'mandatory'"/>  -->
	</xsl:call-template>    
    
  	<!-- Limitation on public access --> 
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'limitationsAccess'"/>
	    <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints"/>
	    <xsl:with-param name="codes" select="'limitationsAccess'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="valid" select="'8.2'"/>
        <xsl:with-param name="req" select="1"/>
        <xsl:with-param name="tags" select="1"/>
	    <!-- <xsl:with-param name="class" select="'mandatory'"/>  -->
	</xsl:call-template>

	<!-- 9. Responsible party -->
    <div>
        <xsl:if test="string-length(gmd:identificationInfo/*/gmd:pointOfContact)=0">
            <xsl:call-template name="party">
                <xsl:with-param name="root" select="."/>
                <xsl:with-param name="name" select="'dataContact'"/>
                <xsl:with-param name="valid" select="'9.1'"/>
                <xsl:with-param name="langs" select="$langs"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
            <xsl:call-template name="party">
                <xsl:with-param name="root" select="."/>
                <xsl:with-param name="name" select="'dataContact'"/>
                <xsl:with-param name="valid" select="'9.1'"/>
                <xsl:with-param name="langs" select="$langs"/>
            </xsl:call-template>
        </xsl:for-each>
    </div>
    
	<!-- 10. Metadata contact -->
	<div>
        <xsl:if test="string-length(gmd:contact)=0">
            <xsl:call-template name="party">
                <xsl:with-param name="root" select="."/>
                <xsl:with-param name="name" select="'contact'"/>
                <xsl:with-param name="langs" select="$langs"/>
                <xsl:with-param name="valid" select="'10.1'"/>
                <xsl:with-param name="role" select="'mdrole'"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:for-each select="gmd:contact">
            <xsl:call-template name="party">
                <xsl:with-param name="root" select="."/>
                <xsl:with-param name="name" select="'contact'"/>
                <xsl:with-param name="langs" select="$langs"/>
                <xsl:with-param name="valid" select="'10.1'"/>
                <xsl:with-param name="role" select="'mdrole'"/>
            </xsl:call-template>
        </xsl:for-each>
    </div>
    
    <!-- 10.3 metadata language -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'mdlang'"/>
	    <xsl:with-param name="value" select="gmd:language/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'language'"/>
	    <xsl:with-param name="multi" select="1"/>
	    <xsl:with-param name="class" select="'mandatory short'"/>
	</xsl:call-template>

	<!-- 11 file identifier -->
    <xsl:call-template name="drawInput">
		<xsl:with-param name="value" select="gmd:fileIdentifier"/>
	  	<xsl:with-param name="name" select="'fileIdentifier'"/>
	    <xsl:with-param name="lclass" select="'wide'"/>
	    <xsl:with-param name="class" select="'T'"/>
	    <xsl:with-param name="req" select="'1'"/>
	    <!--xsl:with-param name="action" select="'getUUID(this)'"/-->
	</xsl:call-template>
    
    <!-- Interoperability elements -->
    
    <!-- IOD-1 spatial reference system  -->
    <xsl:if test="not($serv)">
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'coorSys'"/>
            <xsl:with-param name="value" select="gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier/*/gmd:code"/>
            <xsl:with-param name="codes" select="'coordSys'"/>
            <xsl:with-param name="class" select="'mandatory'"/>
            <xsl:with-param name="multi" select="2"/> 
            <xsl:with-param name="valid" select="'IOD-1'"/>
            <xsl:with-param name="req" select="'1'"/>   
        </xsl:call-template>

        <!-- IOD-3 encoding (distribution format)  -->
        <div>
            <xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat|/.">
                <xsl:if test="*/gmd:name/*!='' or (string-length(*/gmd:name/*)=0 and position()=last())">
                    <fieldset>
                        <div class="row">
                            <xsl:call-template name="drawLabel">
                                <xsl:with-param name="name" select="'encoding'"/>
                                <xsl:with-param name="dupl" select="1"/>
                                <xsl:with-param name="class" select="'mand'"/>
                            </xsl:call-template>	
                        </div>
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'format'"/>
                            <xsl:with-param name="path" select="'format-name[]'"/>
                            <xsl:with-param name="value" select="*/gmd:name"/>
                            <xsl:with-param name="codes" select="'format'"/>
                            <xsl:with-param name="class" select="'inp2 short'"/>
                            <xsl:with-param name="valid" select="'IOD-3'"/>
                            <xsl:with-param name="tags" select="1"/>                        
                        </xsl:call-template>
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'format_version'"/>
                            <xsl:with-param name="path" select="'format-version[]'"/>
                            <xsl:with-param name="value" select="*/gmd:version"/>
                            <xsl:with-param name="type" select="'real'"/> 
                            <xsl:with-param name="class" select="'inp2 short'"/>  
                        </xsl:call-template>
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'format_specification'"/>
                            <xsl:with-param name="path" select="'format-specification[]'"/>
                            <xsl:with-param name="value" select="*/gmd:specification"/>
                            <xsl:with-param name="class" select="'inp2'"/>
                            <xsl:with-param name="codes" select="'inspireKeywords'"/> 
                            <xsl:with-param name="tags" select="1"/>
                            <xsl:with-param name="multi" select="0"/>
                            <xsl:with-param name="attr" select="'spec'"/>
                        </xsl:call-template>
                    </fieldset>
                </xsl:if>
            </xsl:for-each>	    
        </div>
        
        <!-- IOD-4 topological consistency -->
        <div>
        <xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_TopologicalConsistency|.">
            <xsl:if test="string-length(gmd:nameOfMeasure)>0 or(string-length(gmd:nameOfMeasure)=0 and position()=last())">

                <fieldset>
                    <div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'Topological'"/>
                            <xsl:with-param name="class" select="'info'"/>
                            <xsl:with-param name="valid" select="'IOD-4'"/>
                            <xsl:with-param name="dupl" select="1"/>
                        </xsl:call-template>		
                    </div>
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalName'"/>
                        <xsl:with-param name="path" select="'topological-name[]'"/>
                        <xsl:with-param name="value" select="gmd:nameOfMeasure"/>
                        <xsl:with-param name="class" select="'inp2'"/>
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalCode'"/>
                        <xsl:with-param name="path" select="'topological-code[]'"/>
                        <xsl:with-param name="value" select="gmd:measureIdentification/*/gmd:code"/>
                        <xsl:with-param name="class" select="'inp2'"/>
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalMethodType'"/>
                        <xsl:with-param name="path" select="'topological-mtype[]'"/>
                        <xsl:with-param name="value" select="gmd:evaluationMethodType/*"/>
                        <xsl:with-param name="codes" select="'evaluationMethodType'"/>
                        <xsl:with-param name="class" select="'inp2 short'"/>
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalDesr'"/>
                        <xsl:with-param name="path" select="'topological-descr[]'"/>
                        <xsl:with-param name="value" select="gmd:evaluationMethodDescription"/>
                        <xsl:with-param name="class" select="'inp2'"/>
                        <xsl:with-param name="langs" select="$langs"/>
                        <xsl:with-param name="type" select="'textarea'"/>
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalDate'"/>
                        <xsl:with-param name="path" select="'topological-date[]'"/>
                        <xsl:with-param name="value" select="substring-before(gmd:dateTime,'T')"/>
                        <xsl:with-param name="class" select="'date inp2'"/>
                        <xsl:with-param name="type" select="'date'"/>
                    </xsl:call-template>

                    <div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'topologicalResult'"/>
                            <xsl:with-param name="class" select="'info inp2'"/>
                        </xsl:call-template>		
                    </div>
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalValue'"/>
                        <xsl:with-param name="path" select="'topological-value[]'"/>
                        <xsl:with-param name="value" select="gmd:result/*/gmd:value"/>
                        <xsl:with-param name="class" select="'short inp3'"/>
                        <xsl:with-param name="type" select="'real'"/>
                    </xsl:call-template>
                        
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalUnit'"/>
                        <xsl:with-param name="path" select="'topological-unit[]'"/>
                        <xsl:with-param name="value" select="substring-after(gmd:result/*/gmd:valueUnit/@xlink:href,'#')"/>
                        <xsl:with-param name="class" select="'inp3 short'"/>
                        <xsl:with-param name="codes" select="'units'"/>
                    </xsl:call-template>
                    
                    <!--div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'topologicalKResult'"/>
                            <xsl:with-param name="class" select="'info inp2'"/>
                        </xsl:call-template>
                    </div>
                            
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalKTitle'"/>
                        <xsl:with-param name="path" select="'topological-specification[]'"/>
                        <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:title"/>
                        <xsl:with-param name="class" select="'inp3'"/>
                        <xsl:with-param name="action" select="'fspec(this)'"/>  
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalSpecDate'"/>
                        <xsl:with-param name="path" select="'topological-specDate[]'"/>
                        <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:date"/>
                        <xsl:with-param name="class" select="'date inp3'"/>
                        <xsl:with-param name="type" select="'date'"/>
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalSpecDateType'"/>
                        <xsl:with-param name="path" select="'topological-specDateType[]'"/>
                        <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>
                        <xsl:with-param name="codes" select="'dateType'"/>
                        <xsl:with-param name="class" select="'short inp3'"/>
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalExpl'"/>
                        <xsl:with-param name="path" select="'topological-explanation[]'"/>
                        <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:explanation"/>
                        <xsl:with-param name="class" select="'inp inp3'"/>  
                    </xsl:call-template>

                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'topologicalPass'"/>
                        <xsl:with-param name="path" select="'topological-pass[]'"/>
                        <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:pass/gco:Boolean"/>
                        <xsl:with-param name="class" select="'short inp3'"/>
                        <xsl:with-param name="codes" select="'compliant'"/>
                    </xsl:call-template-->
                        
                        <!-- <xsl:for-each select="gmd:result|/.">
                            <xsl:if test="string-length(*/gmd:value)>0 or(position()=1)">
                            <div class="cl" id="topological_{$pos}_result_{position()-1}">
                                <div style="float: left; width:300px;">
                                <xsl:call-template name="drawInput">
                                    <xsl:with-param name="name" select="'topologicalResult'"/>
                                    <xsl:with-param name="path" select="concat('topological_',$pos,'_result_', position()-1, '_value')"/>
                                    <xsl:with-param name="values" select="*/gmd:value"/>
                                    <xsl:with-param name="class" select="'num'"/>
                                    <xsl:with-param name="valid" select="'IO-4'"/>
                                </xsl:call-template>
                                </div>
                                
                                <div style="float: left; width:325px;">
                                <xsl:call-template name="drawRow">
                                    <xsl:with-param name="name" select="'topologicalUnit'"/>
                                    <xsl:with-param name="path" select="concat('topological_',$pos,'_result_', position()-1, '_unit')"/>
                                    <xsl:with-param name="value" select="substring-after(*/gmd:valueUnit/@xlink:href,'#')"/>
                                    <xsl:with-param name="class" select="''"/>
                                    <xsl:with-param name="valid" select="'IO-4'"/>
                                    <xsl:with-param name="type" select="'cselect'"/>
                                    <xsl:with-param name="codes" select="'units'"/>
                                </xsl:call-template>
                                </div>
                                <span class="duplicate"></span>
                            </div>
                            </xsl:if>                         
                        </xsl:for-each>--> 

                </fieldset>
            </xsl:if>
        </xsl:for-each>
        </div>
        
        <!-- IO-5 codepage -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'characterSet'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue"/>
            <xsl:with-param name="codes" select="'characterSet'"/>
            <xsl:with-param name="multi" select="2"/>
            <xsl:with-param name="valid" select="'IOD-5'"/>
            <xsl:with-param name="class" select="'cond'"/>
        </xsl:call-template>

        <!-- IOD-6 spatial representation type -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'spatial'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:spatialRepresentationType/*/@codeListValue"/>
            <xsl:with-param name="codes" select="'spatialRepresentationType'"/>
            <xsl:with-param name="multi" select="2"/>
            <xsl:with-param name="req" select="1"/>
            <xsl:with-param name="valid" select="'IOD-6'"/>
        </xsl:call-template>

    </xsl:if> 

    <xsl:if test="$serv">
        <!-- IOS-1 - Invocable  --> 
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'sds'"/>
            <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:title"/>
            <xsl:with-param name="codes" select="'sds'"/>
            <xsl:with-param name="valid" select="'IOS-1'"/>
            <xsl:with-param name="multi" select="0"/>
            <xsl:with-param name="class" select="'short'"/>
        </xsl:call-template>
        
        <!-- IOS-2 - quality  --> 
        <div class="row">
            <xsl:call-template name="drawLabel">
                <xsl:with-param name="name" select="'serviceQuality'"/>
                <xsl:with-param name="class" select="'mand'"/>
                <xsl:with-param name="valid" select="'IOS-2'"/>
            </xsl:call-template>		
        </div>
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'availability'"/>
            <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$codeLists/serviceQuality/value[1]/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value/gco:Record"/>
            <xsl:with-param name="valid" select="'IOS-2'"/>
            <xsl:with-param name="class" select="'inp2'"/>
            <xsl:with-param name="type" select="'real'"/>
        </xsl:call-template>
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'performance'"/>
            <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$codeLists/serviceQuality/value[2]/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value/gco:Record"/>
            <xsl:with-param name="valid" select="'IOS-2'"/>
            <xsl:with-param name="class" select="'inp2'"/>
            <xsl:with-param name="type" select="'real'"/>
        </xsl:call-template>
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'capacity'"/>
            <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$codeLists/serviceQuality/value[3]/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value/gco:Record"/>
            <xsl:with-param name="valid" select="'IOS-2'"/>
            <xsl:with-param name="class" select="'inp2'"/>
            <xsl:with-param name="type" select="'real'"/>
        </xsl:call-template>

        <!-- IOS-3 opeartion metadata -->
        <div>
            <xsl:for-each select="gmd:identificationInfo/*/srv:containsOperations|.">
                <xsl:if test="normalize-space(*/srv:operationName/*) or (string-length(*/srv:operationName/*)=0 and position()=last())">
                    <fieldset>
                        <div class="row">
                            <xsl:call-template name="drawLabel">
                                <xsl:with-param name="name" select="'operation'"/>
                                <xsl:with-param name="class" select="'info'"/>
                                <xsl:with-param name="valid" select="'IOS-3'"/>
                                <xsl:with-param name="dupl" select="1"/>
                            </xsl:call-template>		
                        </div>
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'operationName'"/>
                            <xsl:with-param name="path" select="'operation-name[]'"/>
                            <xsl:with-param name="value" select="*/srv:operationName"/>
                            <xsl:with-param name="class" select="'inp2'"/>
                        </xsl:call-template>
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'url'"/>
                            <xsl:with-param name="path" select="'operation-url[]'"/>
                            <xsl:with-param name="value" select="*/srv:connectPoint/*/gmd:linkage/gmd:URL"/>
                            <xsl:with-param name="type" select="'plain'"/>
                            <xsl:with-param name="class" select="'inp2'"/>
                        </xsl:call-template>
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'protocol'"/>
                            <xsl:with-param name="path" select="'operation-protocol[]'"/>
                            <xsl:with-param name="value" select="*/srv:connectPoint/*/gmd:protocol"/>
                            <xsl:with-param name="class" select="'inp2'"/>
                        </xsl:call-template>
                    </fieldset>    
                </xsl:if>
            </xsl:for-each>
        </div>
        
    </xsl:if>
    
    <!-- CZECH additional elements -->
	<xsl:choose>
		<xsl:when test="$serv">
			<input type="hidden" name="iso" value="19119"/>
		</xsl:when>
		<xsl:otherwise>
			<input type="hidden" name="iso" value="19115"/>
            <div class="row">
                <xsl:call-template name="drawLabel">
                    <xsl:with-param name="name" select="'parentIdentifier'"/>
                </xsl:call-template>			
                <div class="col-xs-12 col-md-8">
                    <select name="parentIdentifier" id="parent-identifier" data-val="{gmd:parentIdentifier}"></select>
                </div>
            </div>
	  	</xsl:otherwise>
  	</xsl:choose>


    
<xsl:if test="not($serv)">
    <div>
    <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceMaintenance|/.">
        <xsl:if test="string-length(*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue)>0 or(string-length(*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue)=0 and position()=last())">

            <fieldset>
                <div class="row">
                <xsl:call-template name="drawLabel">
                    <xsl:with-param name="name" select="'Maintenance'"/>
                    <xsl:with-param name="class" select="'mand'"/>
                    <xsl:with-param name="dupl" select="1"/>
                </xsl:call-template>
                </div>
            
                <!-- aktualizace -->
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'maintenanceFrequency'"/>
                    <xsl:with-param name="value" select="*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>
                    <xsl:with-param name="codes" select="'maintenanceAndUpdateFrequency'"/>
                    <xsl:with-param name="path" select="'maintenance-frequency[]'"/>	    
                    <xsl:with-param name="mand" select="''"/>
                    <xsl:with-param name="class" select="'short inp2'"/>
                    <xsl:with-param name="valid" select="'CZ-4'"/>
                </xsl:call-template>
              
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'maintenanceUser'"/>
                    <xsl:with-param name="value" select="*/gmd:userDefinedMaintenanceFrequency/*"/>
                    <xsl:with-param name="path" select="'maintenance-user[]'"/>	    
                    <xsl:with-param name="class" select="'short inp2'"/>
                    <xsl:with-param name="type" select="'plain'"/>
                    <xsl:with-param name="valid" select="'CZ-4'"/>
                </xsl:call-template>
              
                <!-- other maintenance fields -->
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'maintenanceScope'"/>
                    <xsl:with-param name="value" select="*/gmd:updateScope/*/@codeListValue"/>
                    <xsl:with-param name="codes" select="$typeList"/>
                    <xsl:with-param name="path" select="'maintenance-scope[]'"/>	    
                    <xsl:with-param name="multi" select="1"/>
                    <xsl:with-param name="class" select="'inp2 short'"/>
                    <xsl:with-param name="valid" select="'CZ-4'"/>
                </xsl:call-template>
              
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'maintenanceNote'"/>
                    <xsl:with-param name="value" select="*/gmd:maintenanceNote"/>
                    <xsl:with-param name="path" select="'maintenance-note[]'"/>	    
                    <xsl:with-param name="multi" select="1"/> <!-- TODO zatim ... -->
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="valid" select="'CZ-6'"/>
                </xsl:call-template>
            </fieldset>
        </xsl:if>
    </xsl:for-each>
    </div>
    
    <xsl:call-template name="drawInput">
        <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:purpose"/>
        <xsl:with-param name="name" select="'purpose'"/>
        <xsl:with-param name="type" select="'textarea'"/>
        <xsl:with-param name="langs" select="$langs"/>
        <xsl:with-param name="valid" select="'CZ-7'"/>
    </xsl:call-template> 

</xsl:if>

    <!-- CZ-9 coupling type -->
    <xsl:if test="$serv">
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'couplingType'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/srv:couplingType/*/@codeListValue"/>
            <xsl:with-param name="codes" select="'couplingType'"/>
            <xsl:with-param name="class" select="'short'"/>
            <xsl:with-param name="valid" select="'CZ-9'"/>   
        </xsl:call-template>
    </xsl:if>



<!-- pokrytí 
<xsl:if test="not($serv)">
    <fieldset>
        <div class="row">
            <xsl:call-template name="drawLabel">
                <xsl:with-param name="name" select="'Coverage'"/>
                <xsl:with-param name="class" select="'cond'"/>
                <xsl:with-param name="valid" select="'CZ-10'"/>
            </xsl:call-template>	
    	</div>
        

    

    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coverageDesc'"/>
    	    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code='CZ-COVERAGE']/*/gmd:measureDescription"/>
    	    <xsl:with-param name="codes" select="'extents'"/>
            <xsl:with-param name="multi" select="0"/>
    	    <xsl:with-param name="class" select="'inp2'"/>
    	    <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>

    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coveragePercent'"/>
    	    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/*/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'#percent')]/*/gmd:value"/>
    	    <xsl:with-param name="type" select="'real'"/>
    	    <xsl:with-param name="class" select="'inp2 short'"/>
    	    <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>
    
    </fieldset> 
</xsl:if>-->

	<div class="row">
        <xsl:call-template name="drawLabel">
            <xsl:with-param name="name" select="'inspireEU'"/>
            <xsl:with-param name="class" select="'cond wide'"/>
        </xsl:call-template>
        
        <xsl:for-each select="gmd:hierarchyLevelName[not(*='http://geoportal.gov.cz/inspire')]">
            <input type="hidden" name="hlName[]" value="{*}"/>
        </xsl:for-each>
		
		<div class="col-xs-12 col-md-8">
            <xsl:choose>
                <xsl:when test="string-length(gmd:hierarchyLevelName[*='http://geoportal.gov.cz/inspire'])>0">
			        <input type="checkbox" checked="checked" name="inspireEU"/>
                </xsl:when>
                <xsl:otherwise>
                    <input type="checkbox" name="inspireEU"/>
                </xsl:otherwise>     
            </xsl:choose>
		</div>
	</div>
    
   
    <xsl:call-template name="drawInput">
        <xsl:with-param name="name" select="'obligatory'"/>
        <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:citation/*/gmd:otherCitationDetails"/>
        <xsl:with-param name="codes" select="'obligatory'"/>
        <xsl:with-param name="class" select="'short'"/>
        <xsl:with-param name="multi" select="0"/>
        <xsl:with-param name="valid" select="'CZ-13'"/>
    </xsl:call-template>


<div style="clear:both; height:20px;"></div>
<div style="display:none" id="ask-uuid"><xsl:value-of select="$labels/msg[@name='ask-uuid']/label"/></div>
</xsl:template>

</xsl:stylesheet>
