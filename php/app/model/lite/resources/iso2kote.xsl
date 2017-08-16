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
    <xsl:variable name="codeListsLang" select="document(concat('../../xsl/codelists_' ,$mlang, '.xml'))/map" />
    <xsl:variable name="langs" select="//gmd:locale" />

    <!-- Jazyky -->

    <xsl:for-each select="$langs">
        <input type="hidden" name="locale_{position()-1}" value="{*/gmd:languageCode/*/@codeListValue}"/>
    </xsl:for-each>


<!-- IDENTIFIKACE -->

	<xsl:call-template name="drawInput">
		<xsl:with-param name="value" select="//gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
		<xsl:with-param name="name" select="'title'"/>
		<xsl:with-param name="valid" select="'1.1'"/>
		<xsl:with-param name="langs" select="$langs"/>
		<xsl:with-param name="req" select="1"/>
	</xsl:call-template>

	<xsl:call-template name="drawInput">
		<xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:abstract"/>
		<xsl:with-param name="name" select="'abstract'"/>
		<xsl:with-param name="type" select="'textarea'"/>
		<xsl:with-param name="valid" select="'1.2'"/>
		<xsl:with-param name="langs" select="$langs"/>
		<xsl:with-param name="req" select="1"/>
	</xsl:call-template>
	
    <!-- 1.3 hierarchy level -->	
	<xsl:choose>
        <xsl:when test="$serv">
            <xsl:call-template name="drawInput">
                <xsl:with-param name="value" select="gmd:hierarchyLevel/*/@codeListValue"/>
                <xsl:with-param name="name" select="'hierarchyLevel'"/>
                <xsl:with-param name="codes" select="'inspireServiceType'"/>
                <xsl:with-param name="valid" select="'1.3'"/>
                <xsl:with-param name="req" select="1"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="drawInput">
                <xsl:with-param name="value" select="gmd:hierarchyLevel/*/@codeListValue"/>
                <xsl:with-param name="name" select="'hierarchyLevel'"/>
                <xsl:with-param name="codes" select="'inspireType'"/>
                <xsl:with-param name="valid" select="'1.3'"/>
                <xsl:with-param name="req" select="1"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
    
    <!-- 1.4 linkage -->
    <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
        <fieldset>
            <div class="row">
                <xsl:call-template name="drawLabel">
                    <xsl:with-param name="name" select="'linkage'"/>
                    <xsl:with-param name="class" select="'cond'"/>
                    <xsl:with-param name="valid" select="'1.6'"/>
                    <xsl:with-param name="dupl" select="1"/>
                </xsl:call-template>
            </div>           
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'url'"/>
                <xsl:with-param name="value" select="*/gmd:linkage"/> 
                <xsl:with-param name="class" select="'cond inp2'"/>   
                <xsl:with-param name="valid" select="'1.4'"/>
            </xsl:call-template>
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'function'"/>
                <xsl:with-param name="value" select="*/gmd:function/*/@codeListValue"/> 
                <xsl:with-param name="codes" select="'function'"/>
                <xsl:with-param name="class" select="'cond inp2 short'"/>
                <xsl:with-param name="valid" select="'1.4'"/>
           </xsl:call-template>
           <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'protocol'"/>
                <xsl:with-param name="value" select="*/gmd:protocol"/>
                <xsl:with-param name="codes" select="'protocol'"/>
                <xsl:with-param name="class" select="'cond inp2 short'"/>   
                <xsl:with-param name="valid" select="'1.4'"/>
            </xsl:call-template>
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'description'"/>
                <xsl:with-param name="value" select="*/gmd:description"/>
                <xsl:with-param name="class" select="'cond inp2'"/>   
                <xsl:with-param name="valid" select="'1.4'"/>
            </xsl:call-template>
        </fieldset>
    </xsl:for-each>  
     
    <!-- 1.5 identifier -->
    <div class="row">
        <xsl:call-template name="drawLabel">
            <xsl:with-param name="name" select="'identifier'"/>
            <xsl:with-param name="class" select="'mand wide'"/>
        </xsl:call-template>			

        
        <div class="col-xs-12 col-md-8">
            <select class="sel2" multiple="multiple" data-tags="true" data-allow-clear="true">
                <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code">
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
                
                <fieldset id="operatesOn_{position()-1}_" style="clear:both">
                        <div class="row">
                            <xsl:call-template name="drawLabel">
                                <xsl:with-param name="name" select="'operatesOn'"/>
                                <xsl:with-param name="class" select="'cond'"/>
                                <xsl:with-param name="valid" select="'1.6'"/>
                                <xsl:with-param name="dupl" select="1"/>
                            </xsl:call-template>
                        </div>    
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'operatesOn_href'"/>
                            <xsl:with-param name="path" select="concat('operatesOn_',position()-1,'_href')"/>
                            <xsl:with-param name="value" select="$url"/> 
                            <xsl:with-param name="class" select="'inp2'"/> 
                            <xsl:with-param name="action" select="'getParent(this)'"/>
                            <xsl:with-param name="type" select="'plain'"/>  
                        </xsl:call-template>
                        
                        <xsl:call-template name="drawInput">
                            <xsl:with-param name="name" select="'operatesOn_uuid'"/>
                            <xsl:with-param name="path" select="concat('operatesOn_',position()-1,'_uuid')"/>
                            <xsl:with-param name="value" select="substring-after(@xlink:href,'#_')"/> 
                            <xsl:with-param name="class" select="'inp2'"/>
                            <xsl:with-param name="type" select="'plain'"/>   
                        </xsl:call-template>
                        
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
                            <xsl:with-param name="name" select="'operatesOn_title'"/>
                            <xsl:with-param name="path" select="concat('operatesOn_',position()-1,'_title')"/>
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
            <xsl:with-param name="class" select="'mandatory'"/>
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
                <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,'19119')]/*/gmd:keyword"/>
                <xsl:with-param name="codes" select="'serviceKeyword'"/>
                <xsl:with-param name="class" select="'mandatory'"/>
                <xsl:with-param name="valid" select="'3'"/>
            </xsl:call-template>

            <!-- INPSPIRE themes -->
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'inspire'"/>
                <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword"/>
                <xsl:with-param name="codes" select="'inspireKeywords'"/>
                <xsl:with-param name="codelist" select="$codeListsLang"/>
                <xsl:with-param name="multi" select="2"/>
                <xsl:with-param name="valid" select="'3.1'"/>
            </xsl:call-template> 
            
            <!-- other KW with thesaurus -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'19119')) and not(contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'INSPIRE')) and string-length(gmd:thesaurusName/*/gmd:title)>0]">
                <xsl:variable name="i" select="position()-1"/>
                <input type="hidden" name="othes_{$i}_title_TXT" value="{gmd:thesaurusName/*/gmd:title}"/>
                <input type="hidden" name="othes_{$i}_date" value="{gmd:thesaurusName/*/gmd:date/*/gmd:date/*}"/>
                <input type="hidden" name="othes_{$i}_dateType" value="{gmd:thesaurusName/*/gmd:date/*/gmd:dateType/*/@codeListValue}"/>
            
                <xsl:for-each select="gmd:keyword">
                    <input type="hidden" name="othes_{$i}_kw_{position()-1}_TXT" value="{gco:CharacterString}"/>
                    <xsl:for-each select="gmd:PT_FreeText/gmd:textGroup">
                        <input type="hidden" name="othes_{$i}_kw_{position()-1}_TXT{substring-after(gmd:LocalisedCharacterString/@locale,'-')}" value="{gmd:LocalisedCharacterString}"/>
                    </xsl:for-each>
                </xsl:for-each>  
            </xsl:for-each>
            
      		<!-- other free KW -->
        	<xsl:call-template name="drawInput">
        		<xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[string-length(gmd:thesaurusName/*/gmd:title)=0]/gmd:keyword"/>
        		<xsl:with-param name="name" select="'fkw'"/>
        		<xsl:with-param name="class" select="'inp'"/>
        		<xsl:with-param name="langs" select="$langs"/>
                <xsl:with-param name="multi" select="2"/>
        	</xsl:call-template>
    		
    	</xsl:when>
    
    	<xsl:otherwise>
        
            <!-- INPSIRE themes -->
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'inspire'"/>
                <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword"/>
                <xsl:with-param name="codes" select="'inspireKeywords'"/>
                <xsl:with-param name="codelist" select="$codeListsLang"/>
                <xsl:with-param name="multi" select="2"/>
                <xsl:with-param name="valid" select="'3.1'"/>
            </xsl:call-template> 

                
       		<!-- ostatni KW s thesaurem-->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[substring(gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) != 'GEMET - INSPIRE' and string-length(gmd:thesaurusName/*/gmd:title)>0]">
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
		
      		<!-- ostatni KW volna -->
        	<xsl:call-template name="drawInput">
        		<xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[string-length(gmd:thesaurusName/*/gmd:title)=0]/gmd:keyword"/>
        		<xsl:with-param name="name" select="'fkw'"/>
        		<xsl:with-param name="class" select="'inp'"/>
        		<xsl:with-param name="langs" select="$langs"/>
                <xsl:with-param name="multi" select="2"/>
        	</xsl:call-template>

        </xsl:otherwise>
    </xsl:choose>


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
            <xsl:with-param name="class" select="'mand wide'"/>
            <xsl:with-param name="valid" select="'4.1'"/>
        </xsl:call-template>	
	
        <div class="col-xs-12 col-md-8">
            <div id="overmap" style="width:100%; height:400px;"></div>
            <input type="text" class="inp num mandatory" id="xmin" name="xmin" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:westBoundLongitude/*}" size="5" />
            <input type="text" class="inp num mandatory" id="ymin" name="ymin" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:southBoundLatitude/*}" size="5" />
            <input type="text" class="inp num mandatory" id="xmax" name="xmax" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:eastBoundLongitude/*}" size="5" />
            <input type="text" class="inp num mandatory" id="ymax" name="ymax" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:northBoundLatitude/*}" size="5" />
        </div>
    </div>
    <!-- 4.1a geographic identifier -->
    <xsl:call-template name="drawInput">
        <xsl:with-param name="name" select="'extentId'"/>
        <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:code"/>
        <xsl:with-param name="codes" select="'extents'"/>
        <xsl:with-param name="multi" select="2"/>
        <xsl:with-param name="valid" select="'4.1'"/>
    </xsl:call-template> 
    
  <!-- datum --> 
  <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date|/."> 
  	<xsl:if test="normalize-space(*/gmd:date)!='' or (normalize-space(*/gmd:date)='' and position()=last())">

		<fieldset id="Date_{position()-1}_" class="cl">
            <div class="row">
                <xsl:call-template name="drawLabel">
                    <xsl:with-param name="name" select="'date'"/>
                    <xsl:with-param name="class" select="'mand wide'"/>
                    <xsl:with-param name="dupl" select="1"/>
                </xsl:call-template>			
            </div>
            <xsl:call-template name="drawInput">
                <xsl:with-param name="name" select="'date'"/>
                <xsl:with-param name="path" select="concat('Date_',position()-1,'_date')"/>
                <xsl:with-param name="value" select="*/gmd:date"/>
                <xsl:with-param name="type" select="'date'"/>
                <xsl:with-param name="valid" select="'5a'"/>
                <xsl:with-param name="class" select="'mandatory inp2'"/>
                <xsl:with-param name="req" select="'1'"/>
            </xsl:call-template>
		 	<xsl:call-template name="drawInput">
			  	<xsl:with-param name="name" select="'dateType'"/>
			  	<xsl:with-param name="path" select="concat('Date_',position()-1,'_type')"/>
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
                    <div id="tempExt_{position()-1}_">
                       <input class="D" data-provide="datepicker" name="tempExt_{position()-1}_from" value="{*/gmd:extent/*/*[1]}"/> 
                      - <input class="D" data-provide="datepicker" name="tempExt_{position()-1}_to"  value="{*/gmd:extent/*/*[2]}"/> 
                        <span class="duplicate"></span>
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
		    <xsl:with-param name="class" select="'mandatory'"/>
            <xsl:with-param name="langs" select="$langs"/>
		    <xsl:with-param name="type" select="'textarea'"/> 
		</xsl:call-template>
        <!-- 12 data quality scope -->
	 	<xsl:call-template name="drawInput">
		  	<xsl:with-param name="name" select="'dqScope'"/>
		    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:scope/*/gmd:level/*/@codeListValue"/>
		    <xsl:with-param name="class" select="'mandatory'"/>
		    <xsl:with-param name="codes" select="'updateScope'"/> 
		</xsl:call-template>
	</xsl:if>

  	<!-- 6.2 denominator -->
    <div class="row">
        <xsl:call-template name="drawLabel">
            <xsl:with-param name="name" select="'scale'"/>
            <xsl:with-param name="class" select="'mand wide'"/>
            <xsl:with-param name="valid" select="'6.2'"/>
        </xsl:call-template>			
        
        <div class="col-xs-12 col-md-8">
            <select class="sel2" multiple="multiple" data-tags="true" data-allow-clear="true">
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
            <xsl:with-param name="class" select="'mand wide'"/>
        </xsl:call-template>			
        
        <div class="col-xs-12 col-md-8">
            <select class="sel2" multiple="multiple" data-tags="true" data-allow-clear="true">
                <xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:distance">
                    <option value="{.}" selected="selected"><xsl:value-of select="."/></option>
                </xsl:for-each>
            </select>
        </div>
    </div>
 
 
    <!-- 7 -->
	<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result|/.">
		<xsl:if test="string-length(*/gmd:specification)>0 or (string-length(*/gmd:specification)=0 and position()=last())">
			<fieldset id="specification_{position()-1}_">
                <div class="row">
                    <xsl:call-template name="drawLabel">
                        <xsl:with-param name="name" select="'Conformity'"/>
                        <xsl:with-param name="class" select="'mand'"/>
                        <xsl:with-param name="dupl" select="1"/>
                    </xsl:call-template>		
                </div>
				
				<xsl:variable name="spec" select="normalize-space(*/gmd:specification/*/gmd:title/gco:CharacterString)"/>
				<xsl:variable name="spec1" select="$codeLists/serviceSpecifications/value[contains($spec, @name)]/@name"/>
				<xsl:variable name="kspec" select="$codeLists/serviceSpecifications/value[contains($spec, @name)]/@code"/>

				 	<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'specification'"/>
					  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_title')"/>
					    <xsl:with-param name="value" select="*/gmd:specification/*/gmd:title"/>
					    <xsl:with-param name="class" select="'mandatory inp2'"/>
                        <xsl:with-param name="codes" select="'specifications'"/> 
					    <xsl:with-param name="valid" select="'7.1'"/>
					</xsl:call-template>

					<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'compliant'"/>
					  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_compliant')"/>
					    <xsl:with-param name="value" select="*/gmd:pass/gco:Boolean"/>
					    <xsl:with-param name="codes" select="'compliant'"/>
					    <xsl:with-param name="class" select="'short inp2'"/>
					    <xsl:with-param name="valid" select="'7.2'"/>
					</xsl:call-template>
			</fieldset>
		</xsl:if>
	</xsl:for-each>

  	<!-- Conditions applying to access and use --> 
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'uselim'"/>
	    <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints"/>
	    <xsl:with-param name="codes" select="'accessCond'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="valid" select="'8.1'"/>
	    <!-- <xsl:with-param name="class" select="'mandatory'"/>  -->
	</xsl:call-template>
    
  	<!-- Conditions applying to access and use --> 
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'access'"/>
	    <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints"/>
	    <xsl:with-param name="codes" select="'limitationsAccess'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="valid" select="'8.2'"/>
	    <!-- <xsl:with-param name="class" select="'mandatory'"/>  -->
	</xsl:call-template>    

	<!-- 9. Responsible party -->
    <xsl:if test="string-length(//gmd:identificationInfo/*/gmd:pointOfContact)=0">
		<xsl:call-template name="party">
			<xsl:with-param name="root" select="."/>
			<xsl:with-param name="name" select="'dataContact'"/>
			<xsl:with-param name="i" select="(position()-1)"/>
			<xsl:with-param name="valid" select="'9.1'"/>
			<xsl:with-param name="langs" select="$langs"/>
		</xsl:call-template>
	</xsl:if>

	<xsl:for-each select="//gmd:identificationInfo/*/gmd:pointOfContact">
		<xsl:call-template name="party">
			<xsl:with-param name="root" select="."/>
			<xsl:with-param name="name" select="'dataContact'"/>
			<xsl:with-param name="i" select="(position()-1)"/>
			<xsl:with-param name="valid" select="'9.1'"/>
			<xsl:with-param name="langs" select="$langs"/>
		</xsl:call-template>
	</xsl:for-each>

	<!-- 10. Metadata contact -->
	<xsl:if test="string-length(//gmd:contact)=0">
		<xsl:call-template name="party">
			<xsl:with-param name="root" select="."/>
			<xsl:with-param name="name" select="'contact'"/>
			<xsl:with-param name="i" select="(position()-1)"/>
			<xsl:with-param name="langs" select="$langs"/>
			<xsl:with-param name="valid" select="'10.1'"/>
            <xsl:with-param name="role" select="'mdrole'"/>
		</xsl:call-template>
	</xsl:if>

	<xsl:for-each select="//gmd:contact">
		<xsl:call-template name="party">
			<xsl:with-param name="root" select="."/>
			<xsl:with-param name="name" select="'contact'"/>
			<xsl:with-param name="i" select="(position()-1)"/>
			<xsl:with-param name="langs" select="$langs"/>
			<xsl:with-param name="valid" select="'10.1'"/>
            <xsl:with-param name="role" select="'mdrole'"/>
		</xsl:call-template>
	</xsl:for-each>

    <!-- 10.3 metadata language -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'mdlang'"/>
	    <xsl:with-param name="value" select="gmd:language/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'language'"/>
	    <xsl:with-param name="multi" select="1"/>
	    <xsl:with-param name="class" select="'mandatory'"/>
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
    <xsl:if test="not($serv)">
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'coorSys'"/>
            <xsl:with-param name="value" select="gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier/*/gmd:code"/>
            <xsl:with-param name="codes" select="'coordSys'"/>
            <xsl:with-param name="class" select="'mandatory'"/>
            <xsl:with-param name="multi" select="2"/> 
            <xsl:with-param name="valid" select="'IO-1'"/>
            <xsl:with-param name="req" select="'1'"/>   
        </xsl:call-template>

        <!-- IOD-3 encoding (distribution format) 
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'format'"/>
            <xsl:with-param name="value" select="gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:name"/>
            <xsl:with-param name="codes" select="'format'"/>
            <xsl:with-param name="class" select="'mandatory'"/>
            <xsl:with-param name="multi" select="2"/> 
            <xsl:with-param name="valid" select="'IO-1'"/>
            <xsl:with-param name="req" select="'1'"/> 
            <xsl:with-param name="tags" select="1"/>            
        </xsl:call-template>-->

        <fieldset>
            <xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat|/.">
                <xsl:if test="*/gmd:name/*!='' or (string-length(*/gmd:name/*)=0 and position()=last())">
                     <div class="row">
                        <xsl:call-template name="drawLabel">
                            <xsl:with-param name="name" select="'format'"/>
                            <xsl:with-param name="dupl" select="1"/>
                        </xsl:call-template>	
                    </div>
                        
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'format'"/>
                        <xsl:with-param name="path" select="concat('format_',(position()-1),'_name')"/>
                        <xsl:with-param name="value" select="*/gmd:name"/>
                        <xsl:with-param name="codes" select="'format'"/>
                        <xsl:with-param name="class" select="'inp2 mandatory'"/>
                        <xsl:with-param name="action" select="'getFormats(this)'"/> 
                        <xsl:with-param name="valid" select="'IO-3'"/>  
                    </xsl:call-template>
                    <xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'format_version'"/>
                        <xsl:with-param name="path" select="concat('format_',(position()-1),'_version')"/>
                        <xsl:with-param name="value" select="*/gmd:version"/>
                        <xsl:with-param name="class" select="'inp2 mandatory'"/>  
                    </xsl:call-template>
                    <!--xsl:call-template name="drawInput">
                        <xsl:with-param name="name" select="'format_specification'"/>
                        <xsl:with-param name="path" select="concat('format_',(position()-1),'_specification')"/>
                        <xsl:with-param name="value" select="*/gmd:specification"/>
                        <xsl:with-param name="class" select="'inp2'"/>
                        <xsl:with-param name="action" select="'fspec(this)'"/>  
                    </xsl:call-template-->

                </xsl:if>
            </xsl:for-each>	    
        </fieldset>
        
        <!-- IOD-6 spatial representation type -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'spatial'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:spatialRepresentationType/*/@codeListValue"/>
            <xsl:with-param name="codes" select="'spatialRepresentationType'"/>
            <xsl:with-param name="multi" select="2"/>
            <xsl:with-param name="valid" select="'IO-6'"/>
        </xsl:call-template>

        <!-- codepage -->
        <xsl:call-template name="drawInput">
            <xsl:with-param name="name" select="'characterSet'"/>
            <xsl:with-param name="value" select="gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue"/>
            <xsl:with-param name="codes" select="'characterSet'"/>
            <xsl:with-param name="multi" select="2"/>
            <xsl:with-param name="valid" select="'IO-5'"/>
            <!-- <xsl:with-param name="class" select="'mandatory'"/>  -->
        </xsl:call-template>
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
                    <xsl:with-param name="class" select="'cond wide'"/>
                </xsl:call-template>			
                <div class="col-xs-12 col-md-8">
                    <select id="parent-identifier" data-val="{gmd:parentIdentifier}" data-placeholder="vyberte"></select>
                </div>
            </div>
	  	</xsl:otherwise>
  	</xsl:choose>


    
<xsl:if test="not($serv)">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceMaintenance|/.">
        <xsl:if test="string-length(*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue)>0 or(string-length(*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue)=0 and position()=last())">
            <xsl:variable name="row" select="position()-1"/>
            <fieldset class="cl" id="maintenance_{$row}_">
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
                    <xsl:with-param name="path" select="concat('maintenance_',$row,'_frequency')"/>	    
                    <xsl:with-param name="mand" select="''"/>
                    <xsl:with-param name="class" select="'cond inp2'"/>
                    <xsl:with-param name="valid" select="'CZ-4'"/>
                </xsl:call-template>
              
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'maintenanceUser'"/>
                    <xsl:with-param name="value" select="*/gmd:userDefinedMaintenanceFrequency"/>
                    <xsl:with-param name="path" select="concat('maintenance_',$row,'_user')"/>	    
                    <xsl:with-param name="class" select="'inpSS cond inp2'"/>
                    <xsl:with-param name="valid" select="'CZ-4'"/>
                </xsl:call-template>
              
                <!-- dalsi prvky maintenance -->
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'maintenanceScope'"/>
                    <xsl:with-param name="value" select="*/gmd:updateScope/*/@codeListValue"/>
                    <xsl:with-param name="codes" select="'updateScope'"/>
                    <xsl:with-param name="path" select="concat('maintenance_',$row,'_scope')"/>	    
                    <xsl:with-param name="multi" select="2"/>
                    <xsl:with-param name="mand" select="''"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="valid" select="'CZ-4'"/>
                </xsl:call-template>
              
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'maintenanceNote'"/>
                    <xsl:with-param name="value" select="*/gmd:maintenanceNote"/>
                    <xsl:with-param name="path" select="concat('maintenance_',$row,'_note')"/>	    
                    <xsl:with-param name="multi" select="1"/> <!-- TODO zatim ... -->
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="valid" select="'CZ-6'"/>
                </xsl:call-template>
            </fieldset>
        </xsl:if>
    </xsl:for-each>

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
            <xsl:with-param name="multi" select="2"/> 
            <xsl:with-param name="class" select="'mandatory'"/>
            <xsl:with-param name="valid" select="'CZ-11'"/>   
        </xsl:call-template>
    </xsl:if>



<!-- pokrytí -->
<xsl:if test="not($serv)">
    <fieldset>
        <div class="row">
            <xsl:call-template name="drawLabel">
                <xsl:with-param name="name" select="'Coverage'"/>
                <xsl:with-param name="class" select="''"/>
                <xsl:with-param name="valid" select="'CZ-10'"/>
            </xsl:call-template>	
    	</div>
        
    	<!-- plocha -->
    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coverageArea'"/>
    	    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/*/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'#km2')]/*/gmd:value"/>
    	    <xsl:with-param name="multi" select="1"/>
    	    <xsl:with-param name="class" select="'inpSS cond inp2'"/>
    	    <!--  xsl:with-param name="action" select="'cover(this)'"/-->
    	</xsl:call-template>
    
    	<!-- % -->
    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coveragePercent'"/>
    	    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/*/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'#percent')]/*/gmd:value"/>
    	    <xsl:with-param name="multi" select="1"/>
    	    <xsl:with-param name="class" select="'inpSS cond inp2'"/>
    	    <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>
    
    	<!-- uzemi -->
    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coverageDesc'"/>
    	    <xsl:with-param name="value" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code='CZ-COVERAGE']/*/gmd:measureDescription"/>
    	    <xsl:with-param name="multi" select="1"/>
    	    <xsl:with-param name="class" select="'inp inp2'"/>
    	    <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>
    </fieldset>
</xsl:if>


<xsl:if test="not($serv)">

	<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_TopologicalConsistency|.">
		<xsl:if test="string-length(gmd:nameOfMeasure)>0 or(string-length(gmd:nameOfMeasure)=0 and position()=1)">
            <xsl:variable name="pos" select="position()-1"/>
			<fieldset class="cl" id="topological_{$pos}_">
                <div class="row">
                    <xsl:call-template name="drawLabel">
                        <xsl:with-param name="name" select="'Topological'"/>
                        <xsl:with-param name="class" select="'info'"/>
                    </xsl:call-template>		
                </div>
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalName'"/>
                    <xsl:with-param name="path" select="concat('topological_',$pos,'_name')"/>
                    <xsl:with-param name="value" select="gmd:nameOfMeasure"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="valid" select="'IO-4'"/>
                </xsl:call-template>

                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalCode'"/>
                    <xsl:with-param name="path" select="concat('topological_',$pos,'_code')"/>
                    <xsl:with-param name="value" select="gmd:measureIdentification/*/gmd:code"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="valid" select="'IO-4'"/>
                </xsl:call-template>

                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalDesr'"/>
                    <xsl:with-param name="path" select="concat('topological_',$pos,'_descr')"/>
                    <xsl:with-param name="value" select="gmd:measureDescription"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="langs" select="$langs"/>
                    <xsl:with-param name="valid" select="'IO-4'"/>
                    <xsl:with-param name="type" select="'textarea'"/>
                </xsl:call-template>

                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalDate'"/>
                    <xsl:with-param name="path" select="concat('topological_',$pos,'_date')"/>
                    <xsl:with-param name="value" select="substring-before(gmd:dateTime,'T')"/>
                    <xsl:with-param name="class" select="'date inp2'"/>
                    <xsl:with-param name="type" select="'date'"/>
                    <xsl:with-param name="valid" select="'IO-4'"/>
                </xsl:call-template>

                <div class="row">
                    <xsl:call-template name="drawLabel">
                        <xsl:with-param name="name" select="'topologicalResult'"/>
                        <xsl:with-param name="class" select="'info'"/>
                    </xsl:call-template>		
                </div>
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalValue'"/>
                    <xsl:with-param name="path" select="concat('topological_',$pos,'_value')"/>
                    <xsl:with-param name="value" select="gmd:result/*/gmd:value"/>
                    <xsl:with-param name="class" select="'num inp2'"/>
                    <xsl:with-param name="valid" select="'IO-4'"/>
                </xsl:call-template>
                    
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalUnit'"/>
                    <xsl:with-param name="path" select="concat('topological_',$pos,'_unit')"/>
                    <xsl:with-param name="value" select="substring-after(gmd:result/*/gmd:valueUnit/@xlink:href,'#')"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="valid" select="'IO-4'"/>
                    <xsl:with-param name="type" select="'cselect'"/>
                    <xsl:with-param name="codes" select="'units'"/>
                </xsl:call-template>
                
                <div class="row">
                    <xsl:call-template name="drawLabel">
                        <xsl:with-param name="name" select="'topologicalKResult'"/>
                        <xsl:with-param name="class" select="'info'"/>
                    </xsl:call-template>
                </div>
                        
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalKTitle'"/>
                    <xsl:with-param name="path" select="concat('topological_',(position()-1),'_specification')"/>
                    <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:title"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="action" select="'fspec(this)'"/>  
                </xsl:call-template>

				<!-- datum --> 
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalSpecDate'"/>
                    <xsl:with-param name="path" select="concat('topological_',(position()-1),'_specDate')"/>
                    <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:date"/>
                    <xsl:with-param name="class" select="'date inp2'"/>
                    <xsl:with-param name="type" select="'date'"/>
                </xsl:call-template>

                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalSpecDateType'"/>
                    <xsl:with-param name="path" select="concat('topological_',(position()-1),'_specDateType')"/>
                    <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>
                    <xsl:with-param name="codes" select="'dateType'"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="lclass" select="'short'"/>
                </xsl:call-template>

                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalExpl'"/>
                    <xsl:with-param name="path" select="concat('topological_',(position()-1),'_explanation')"/>
                    <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:explanation"/>
                    <xsl:with-param name="class" select="'inp inp2'"/>  
                </xsl:call-template>

                <xsl:call-template name="drawInput">
                    <xsl:with-param name="name" select="'topologicalPass'"/>
                    <xsl:with-param name="path" select="concat('topological_',position()-1,'_pass')"/>
                    <xsl:with-param name="value" select="gmd:result/gmd:DQ_ConformanceResult/gmd:pass/gco:Boolean"/>
                    <xsl:with-param name="class" select="'inp2'"/>
                    <xsl:with-param name="codes" select="'compliant'"/>
                </xsl:call-template>
					
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
	
</xsl:if>







<!-- METADATA -->   	
    


	



	<div class="row">
        <xsl:call-template name="drawLabel">
            <xsl:with-param name="name" select="'inspireEU'"/>
            <xsl:with-param name="class" select="'cond wide'"/>
        </xsl:call-template>
        
        <xsl:for-each select="gmd:hierarchyLevelName[not(*='http://geoportal.gov.cz/inspire')]">
            <input type="hidden" name="hlName_{position()-1}" value="{*}"/>
        </xsl:for-each>
		
		<div class="col-xs-12 col-md-8">
            <xsl:choose>
                <xsl:when test="string-length(gmd:hierarchyLevelName[*='http://geoportal.gov.cz/inspire'])>0">
			        <input type="checkbox" checked="checked" name="inspireEU"/>
                </xsl:when>
                <xsl:otherwise>
                    <input type="checkbox" name="inspireEU_0_"/>
                </xsl:otherwise>     
            </xsl:choose>
		</div>
	</div>



<div style="clear:both; height:20px;"></div>
<div style="display:none" id="ask-uuid"><xsl:value-of select="$labels/msg[@name='ask-uuid']/label"/></div>
</xsl:template>

</xsl:stylesheet>
