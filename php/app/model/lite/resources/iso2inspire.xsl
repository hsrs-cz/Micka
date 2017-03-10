<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gmi="http://www.isotc211.org/2005/gmi"
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:srv="http://www.isotc211.org/2005/srv" 
	xmlns:gml="http://www.opengis.net/gml" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
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
<xsl:variable name="codeListsLang" select="document(concat('../../include/xsl/codelists_' ,$mlang, '.xml'))/map" />
<xsl:variable name="langs" select="//gmd:locale" />

<!-- Jazyky -->

<xsl:for-each select="$langs">
	<input type="hidden" name="locale_{position()-1}" value="{*/gmd:languageCode/*/@codeListValue}"/>
</xsl:for-each>

<!-- METADATA -->

<fieldset>
	<xsl:call-template name="drawLegend">
		<xsl:with-param name="name" select="'Metadata'"/>
		<xsl:with-param name="class" select="'mand'"/>
	</xsl:call-template>	

	
	<xsl:call-template name="drawInput">
		<xsl:with-param name="values" select="//gmd:fileIdentifier"/>
	  	<xsl:with-param name="name" select="'fileIdentifier'"/>
	    <xsl:with-param name="lclass" select="'wide'"/>
	    <xsl:with-param name="class" select="'inpS mandatory'"/>
	    <!--xsl:with-param name="action" select="'getUUID(this)'"/-->
	</xsl:call-template>


	<xsl:choose>
		<xsl:when test="$serv">
			<input type="hidden" name="iso" value="19119"/>
		</xsl:when>
		<xsl:otherwise>
			<input type="hidden" name="iso" value="19115"/>
			<xsl:call-template name="drawInput">
				<xsl:with-param name="values" select="gmd:parentIdentifier"/>
			  	<xsl:with-param name="name" select="'parentIdentifier'"/>
			    <xsl:with-param name="class" select="'inpS'"/>
	   			<xsl:with-param name="lclass" select="'wide'"/>
			    <xsl:with-param name="action" select="'getParent(this)'"/>
			</xsl:call-template>
	  	</xsl:otherwise>
  	</xsl:choose>


	<div>
		<xsl:call-template name="drawLabel">
			<xsl:with-param name="name" select="'mdlang'"/>
			<xsl:with-param name="class" select="'mand wide'"/>
		</xsl:call-template>			
		
		<span class="locale">
			<input type="text" style="color:red" class="inp inpSS mandatory" name="mdlang" value="{$mlang}" readonly="readonly"/>
		</span>
	</div>
   	
	<!--  <xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'mdlang'"/>
	    <xsl:with-param name="values" select="gmd:language/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'language'"/>
	    <xsl:with-param name="multi" select="false()"/>
	    <xsl:with-param name="class" select="'mandatory'"/>
	</xsl:call-template>
-->

</fieldset>

<!-- IDENTIFIKACE -->
<fieldset>
	<xsl:call-template name="drawLegend">
		<xsl:with-param name="name" select="'Identification'"/>
		<xsl:with-param name="class" select="'mand'"/>
	</xsl:call-template>	
	<div style="xwidth:630px; float:left;">

	<xsl:call-template name="drawInput">
		<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
		<xsl:with-param name="name" select="'title'"/>
		<xsl:with-param name="class" select="'inp mandatory'"/>
		<xsl:with-param name="valid" select="'1.1'"/>
		<xsl:with-param name="langs" select="$langs"/>
	</xsl:call-template>

	<xsl:call-template name="drawInput">
		<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:abstract"/>
		<xsl:with-param name="name" select="'abstract'"/>
		<xsl:with-param name="type" select="'textarea'"/>
		<xsl:with-param name="class" select="'mandatory'"/>
		<xsl:with-param name="valid" select="'1.2'"/>
		<xsl:with-param name="langs" select="$langs"/>
	</xsl:call-template>
	
	
	<xsl:if test="not($serv)">
		<xsl:call-template name="drawInput">
			<xsl:with-param name="values" select="gmd:hierarchyLevel/*/@codeListValue"/>
			<xsl:with-param name="name" select="'hierarchyLevel'"/>
			<xsl:with-param name="codes" select="'inspireType'"/>
			<xsl:with-param name="class" select="'mandatory'"/>
			<xsl:with-param name="valid" select="'1.3'"/>
		</xsl:call-template>
		<xsl:call-template name="drawInput">
			<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/>
			<xsl:with-param name="name" select="'identifier'"/>
			<xsl:with-param name="type" select="'input'"/>
			<xsl:with-param name="class" select="'inp mandatory'"/>
			<xsl:with-param name="multi" select="2"/>
			<xsl:with-param name="valid" select="'1.5'"/>
		</xsl:call-template>
	</xsl:if>

	<xsl:if test="$serv">
		<xsl:call-template name="drawInput">
			<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/>
			<xsl:with-param name="name" select="'identifier'"/>
			<xsl:with-param name="type" select="'input'"/>
			<xsl:with-param name="class" select="'inp'"/>
			<xsl:with-param name="multi" select="2"/>
			<xsl:with-param name="valid" select="'1.5'"/>
		</xsl:call-template>
	</xsl:if>

<!-- datum --> 
  <xsl:for-each select="/.|gmd:identificationInfo/*/gmd:citation/*/gmd:date"> 
  	<xsl:if test="*/gmd:date!='' or (string-length(*/gmd:date)=0 and position()=1)">
		<div id="Date_{position()-1}_" class="cl">
			<div style="float: left; width:325px;">
			  	<xsl:call-template name="drawInput">
				  	<xsl:with-param name="name" select="'date'"/>
				  	<xsl:with-param name="path" select="concat('Date_',position()-1,'_date')"/>
				    <xsl:with-param name="values" select="*/gmd:date"/>
				    <xsl:with-param name="class" select="'date mandatory'"/>
					<xsl:with-param name="valid" select="'5a'"/>
				</xsl:call-template>
		 	</div>
		 	<div style="float: left; width:325px;">
		 	<xsl:call-template name="drawInput">
			  	<xsl:with-param name="name" select="'dateType'"/>
			  	<xsl:with-param name="path" select="concat('Date_',position()-1,'_type')"/>
			    <xsl:with-param name="values" select="*/gmd:dateType/*/@codeListValue"/>
			    <xsl:with-param name="codes" select="'dateType'"/>
			    <xsl:with-param name="class" select="'mandatory'"/>
			</xsl:call-template>
			</div>
	   	<span class="duplicate"></span><br/> 
	  </div>
  </xsl:if>
  </xsl:for-each>  

	<div class="cl"> </div>
 
    	<xsl:choose>
    	  <xsl:when test="$serv">
    	  	
      			<xsl:call-template name="drawInput">
      			  	<xsl:with-param name="name" select="'inspireService'"/>
      			    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,'19119')]/*/gmd:keyword/gco:CharacterString"/>
      			    <xsl:with-param name="codes" select="'serviceKeyword'"/>
      			    <xsl:with-param name="class" select="'mandatory'"/>
      			    <xsl:with-param name="valid" select="'3'"/>
      			</xsl:call-template>
			
	      		 <!-- ostatani KW-->
	          	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[not(contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'19119')) and not(contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'INSPIRE'))]">
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
    		
    	  </xsl:when>
    
    	  <xsl:otherwise>
    	  	<!--  xsl:variable name="kwins">
    		 	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[substring(gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/gmd:keyword/gco:CharacterString">
    	  	   <xsl:value-of select="."/>
    	  	   <xsl:if test="not(position()=last())"><xsl:text>
    </xsl:text>
    
    	       </xsl:if>
    	  	</xsl:for-each>
    		</xsl:variable>
    	
    			<xsl:call-template name="drawRow">
    			  	<xsl:with-param name="name" select="'inspire'"/>
    			    <xsl:with-param name="value" select="$kwins"/>
    			    <xsl:with-param name="type" select="'textarea'"/>
    			    <xsl:with-param name="action" select="concat('showThesaurus(',&quot;'&quot;,$mickaURL,&quot;'&quot;,',',$serv,')')"/>
    				<xsl:with-param name="class" select="'mandatory'"/>
    			</xsl:call-template-->
      		 <xsl:call-template name="drawInput">
      		  	<xsl:with-param name="name" select="'inspire'"/>
      		    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword/gco:CharacterString"/>
      		    <xsl:with-param name="codes" select="'inspireKeywords'"/>
      		    <xsl:with-param name="class" select="'mandatory'"/>
      		    <xsl:with-param name="codelist" select="$codeListsLang"/>
      		    <xsl:with-param name="multi" select="2"/>
      		    <xsl:with-param name="valid" select="'3.1'"/>
      		 </xsl:call-template> 
      		 
      		 <!-- ostatni KW s thesaurem-->
              <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[substring(gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) != 'GEMET - INSPIRE']">
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


	<xsl:variable name="kwg">
	 	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[substring(gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - Concept']/gmd:keyword">
  	   <xsl:value-of select="."/>
  	   <xsl:if test="not(position()=last())"><xsl:text>
</xsl:text>
       </xsl:if>
  	</xsl:for-each>
	</xsl:variable>
	
	<!--<xsl:variable name="kw">
	 	<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[string-length(gmd:thesaurusName/*/gmd:title/gco:CharacterString)=0]/gmd:keyword/gco:CharacterString">
  	   <xsl:value-of select="."/>
  	   <xsl:if test="not(position()=last())"><xsl:text>
</xsl:text>
       </xsl:if>
  	</xsl:for-each>
	</xsl:variable>
	
	<xsl:call-template name="drawRow">
	  	<xsl:with-param name="name" select="'gemet'"/>
	    <xsl:with-param name="value" select="$kwg"/>
	    <xsl:with-param name="type" select="'textarea'"/>
	    <xsl:with-param name="action" select="concat('showThesaurus(',&quot;'&quot;,$mickaURL,&quot;'&quot;,',',$serv,')')"/>
	</xsl:call-template>
	<input type="hidden" id="gemetCit" name="gemetCit" value="{gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[substring(gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - Concept']/gmd:thesaurusName/*/gmd:title/gco:CharacterString}"/>
	<input type="hidden" id="gemetDate" name="gemetDate" value="{gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[substring(gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - Concept']/gmd:thesaurusName/*/gmd:date/*/gmd:date}"/>

	   <xsl:call-template name="drawRow">
	  	<xsl:with-param name="name" select="'keywords'"/>
	    <xsl:with-param name="value" select="$kw"/>
	    <xsl:with-param name="type" select="'textarea'"/>
	  </xsl:call-template> -->

	  <xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'uselim'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation[1]"/>
	    <xsl:with-param name="class" select="'mandatory'"/> 
	    <xsl:with-param name="type" select="'textarea'"/>
	    <xsl:with-param name="action" select="'getUseLim(this)'"/>
	    <xsl:with-param name="langs" select="$langs"/>
	    <xsl:with-param name="valid" select="'8.1'"/>
	  </xsl:call-template>

	  <xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'access'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints[1]"/>
	    <xsl:with-param name="class" select="'mandatory'"/> 
	    <xsl:with-param name="type" select="'textarea'"/>
	    <xsl:with-param name="action" select="'getAccess(this)'"/>
	    <xsl:with-param name="langs" select="$langs"/>
	    <xsl:with-param name="valid" select="'8.2'"/>
	  </xsl:call-template>   

<xsl:if test="$serv">
	  <xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'serviceType'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/srv:serviceType"/>
	    <xsl:with-param name="codes" select="'serviceType'"/>
	    <xsl:with-param name="multi" select="2"/> 
	    <xsl:with-param name="class" select="'mandatory'"/>
	    <xsl:with-param name="valid" select="'2.2'"/>   
	  </xsl:call-template>

</xsl:if>

<xsl:if test="not($serv)">
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'topicCategory'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:topicCategory/gmd:MD_TopicCategoryCode"/>
	    <xsl:with-param name="codes" select="'topicCategory'"/>
	    <xsl:with-param name="class" select="'mandatory'"/>
	    <xsl:with-param name="multi" select="2"/> 
	    <xsl:with-param name="valid" select="'2.1'"/>   
	</xsl:call-template>


	<!-- jazyk zdroje -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'language'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:language/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'language'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="class" select="'mandatory'"/>
	    <xsl:with-param name="valid" select="'1.7'"/>
	</xsl:call-template>
  
  	<!-- meritko -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'scale'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="class" select="'num cond'"/>
	    <xsl:with-param name="valid" select="'6.2'"/>
	</xsl:call-template>
  	 
  	<!-- vzdalenost --> 	
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'distance'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:distance"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="class" select="'num cond'"/>
	    <xsl:with-param name="valid" select="'6.2a'"/>
	</xsl:call-template>

</xsl:if> 

</div>
  <xsl:if test="$serv">
  	<xsl:for-each select="/.|gmd:identificationInfo/*/srv:operatesOn">
  		<xsl:if test="string-length(@xlink:href)>0 or (string-length(@xlink:href)=0 and position()=1 and position()=last())">
 
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
 			
			<div id="operatesOn_{position()-1}_" style="clear:both">
	 			<fieldset>
	  				<xsl:call-template name="drawLegend">
						<xsl:with-param name="name" select="'operatesOn'"/>
						<xsl:with-param name="class" select="'cond'"/>
					</xsl:call-template>
					
					<xsl:call-template name="drawRow">
						<xsl:with-param name="name" select="'operatesOn_href'"/>
				  		<xsl:with-param name="path" select="concat('operatesOn_',position()-1,'_href')"/>
				    	<xsl:with-param name="value" select="$url"/> 
				    	<xsl:with-param name="class" select="'inpL'"/> 
				    	<xsl:with-param name="action" select="'getParent(this)'"/>
				    	<xsl:with-param name="type" select="'plain'"/>  
				  	</xsl:call-template>
				  	
					<xsl:call-template name="drawRow">
						<xsl:with-param name="name" select="'operatesOn_uuid'"/>
				  		<xsl:with-param name="path" select="concat('operatesOn_',position()-1,'_uuid')"/>
				    	<xsl:with-param name="value" select="substring-after(@xlink:href,'#_')"/> 
				    	<xsl:with-param name="class" select="''"/>
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

					<xsl:call-template name="drawRow">
						<xsl:with-param name="name" select="'operatesOn_title'"/>
				  		<xsl:with-param name="path" select="concat('operatesOn_',position()-1,'_title')"/>
				    	<xsl:with-param name="value" select="$ootitle"/>
				    	<xsl:with-param name="type" select="'plain'"/>   
				  	</xsl:call-template>
	  		
			  	</fieldset>
			  	<span class="duplicate"></span>
		  	</div>
	  	</xsl:if>
  	</xsl:for-each>
  </xsl:if> 

</fieldset>

<fieldset style="clear:both">
	<xsl:call-template name="drawLegend">
		<xsl:with-param name="name" select="'Extent'"/>
		<xsl:with-param name="class" select="'mand'"/>
	</xsl:call-template>	

<div style="xmargin-left:96px; width:380px; float:left;">

	<xsl:call-template name="drawLabel">
		<xsl:with-param name="name" select="'spatialExt'"/>
		<xsl:with-param name="class" select="'mand wide'"/>
		<xsl:with-param name="valid" select="'4.1'"/>
	</xsl:call-template>	
	
  	<iframe src="{$mickaURL}/mickaMap.php?lang={$lang}" id="mapa" width="360" height="270" border="0" frameborder="no" scrolling="no"></iframe><br/>
	<a href="javascript:getFindBbox(document.getElementById('mapa').contentWindow.document.mapserv.imgext.value);"><img src="{$mickaURL}/img/zmapy.gif" alt="{$labels/msg[@name='fromMap']/label}" title="{$labels/msg[@name='fromMap']/label}" /></a>
	<input type="text" class="inp num mandatory" name="xmin" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:westBoundLongitude/*}" size="5" />
	<input type="text" class="inp num mandatory" name="ymin" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:southBoundLatitude/*}" size="5" />
	<input type="text" class="inp num mandatory" name="xmax" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:eastBoundLongitude/*}" size="5" />
	<input type="text" class="inp num mandatory" name="ymax" value="{//gmd:identificationInfo//gmd:geographicElement/*/gmd:northBoundLatitude/*}" size="5" />
	<span title="{$labels/msg[@name='fromList']/label}" class="open" onclick="window.open('{$mickaURL}/md_gazcli.php?simple=1', 'gc', 'toolbar=no,location=no,directories=no,status=no,menubar=no,width=300,height=500,resizable=yes,scrollbars=yes'); return false;">.</span>


</div>

<div style="width:250px; float:left;">
	<fieldset>
 		<xsl:call-template name="drawLegend">
			<xsl:with-param name="name" select="'timeExtent'"/>
			<xsl:with-param name="class" select="'cond'"/>
			<xsl:with-param name="valid" select="'5b'"/>
		</xsl:call-template>	
	
		<xsl:for-each select="/.|gmd:identificationInfo/*/*/*/gmd:temporalElement">
			<xsl:if test="string-length(*/gmd:extent)>0 or(string-length(*/gmd:extent)=0 and position()=1)">
				<div id="tempExt_{position()-1}_">
				   <input class="inp date" name="tempExt_{position()-1}_from" size="15" value="{*/gmd:extent/*/*[1]}"/> 
				  - <input class="inp date" name="tempExt_{position()-1}_to" size="15" value="{*/gmd:extent/*/*[2]}"/> 
				    <span class="duplicate"></span>
				</div>
			</xsl:if>
		</xsl:for-each>	
	</fieldset>
</div>

</fieldset>


<fieldset>
	<xsl:call-template name="drawLegend">
		<xsl:with-param name="name" select="'Distribution'"/>
		<xsl:with-param name="class" select="'mand'"/>
	</xsl:call-template>	
  	<div class="cl"></div>
 	<xsl:call-template name="drawInput">
	 	<xsl:with-param name="name" select="'linkage'"/>
	    <xsl:with-param name="values" select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage"/>
	    <xsl:with-param name="multi" select="2"/> 
	    <xsl:with-param name="class" select="'cond inp'"/>   
		<xsl:with-param name="valid" select="'1.4'"/>
	</xsl:call-template>
   
 	<!-- <xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'distributor'"/>
	    <xsl:with-param name="values" select="gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorContact/*/gmd:organisationName"/>
	    <xsl:with-param name="multi" select="2"/> 
	    <xsl:with-param name="class" select="'cond'"/>   
	</xsl:call-template>
  -->
  
</fieldset>

<!-- KVALITA -->
<fieldset>
	<xsl:call-template name="drawLegend">
		<xsl:with-param name="name" select="'Quality'"/>
		<xsl:with-param name="class" select="'mand'"/>
	</xsl:call-template>		
	<xsl:if test="not($serv)">
	 	<xsl:call-template name="drawInput">
		  	<xsl:with-param name="name" select="'lineage'"/>
		    <xsl:with-param name="values" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
		    <xsl:with-param name="class" select="'mandatory'"/>
		    <xsl:with-param name="type" select="'textarea'"/> 
		    <xsl:with-param name="langs" select="$langs"/>
		    <xsl:with-param name="valid" select="'6.1'"/>    
		</xsl:call-template>
	</xsl:if>

	<xsl:for-each select="/.|gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result">
		<xsl:if test="string-length(*/gmd:specification)>0 or(string-length(*/gmd:specification)=0 and position()=1)">
			<div class="cl" id="specification_{position()-1}_">
				
				<xsl:variable name="spec" select="normalize-space(*/gmd:specification/*/gmd:title/gco:CharacterString)"/>
				<xsl:variable name="spec1" select="$codeLists/serviceSpecifications/value[contains($spec, @name)]/@name"/>
                
			    <div>
				 	<xsl:choose>
						<xsl:when test="$serv">
							<xsl:call-template name="drawInput">
								<xsl:with-param name="name" select="'specification'"/>
							  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_title')"/>
							    <xsl:with-param name="values" select="*/gmd:specification/*/gmd:title/gco:CharacterString"/>
							    <xsl:with-param name="codes" select="'serviceSpecifications'"/>
							    <xsl:with-param name="class" select="'mandatory'"/>
					            <xsl:with-param name="valid" select="'7.1'"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="drawInput">
								<xsl:with-param name="name" select="'specification'"/>
							  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_title')"/>
							    <xsl:with-param name="values" select="$spec1"/>
                                <xsl:with-param name="type" select="'select'"/>
							    <xsl:with-param name="codes" select="'serviceSpecifications'"/>
							    <xsl:with-param name="class" select="'mandatory'"/>
					            <xsl:with-param name="valid" select="'7.1'"/>
							</xsl:call-template>			
						</xsl:otherwise>
					</xsl:choose>
				</div>
                
   				<div>
					<!-- <xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'compliant'"/>
					  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_compliant')"/>
					    <xsl:with-param name="values" select="*/gmd:pass/gco:Boolean"/>
					    <xsl:with-param name="type" select="'boolean'"/>
					    <xsl:with-param name="class" select="'cond'"/>
					</xsl:call-template> -->

					<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'compliant'"/>
					  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_compliant')"/>
					    <xsl:with-param name="values" select="*/gmd:pass/gco:Boolean"/>
					    <xsl:with-param name="codes" select="'compliant'"/>
					    <xsl:with-param name="class" select="'cond'"/>
					    <xsl:with-param name="valid" select="'7.2'"/>
					</xsl:call-template>
				</div>

				<span class="duplicate"></span>
			</div>
		</xsl:if>
	</xsl:for-each>


	<!-- PRIPRAVERNO NA OBECNE DATA QUALITY  
	<xsl:for-each select="/.|gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result[not(contains(*/gmd:specification/*/gmd:title/gco:CharacterString,'INSPIRE')) and not(contains(*/gmd:specification/*/gmd:title/gco:CharacterString,'COMMISSION REGULATION'))]">
		<xsl:if test="string-length(*/gmd:specification)>0 or(string-length(*/gmd:specification)=0 and position()=1)">
			<div class="cl" id="specification_{position()-1}_">


				<span class="duplicate"></span>
			</div>
		</xsl:if>
	</xsl:for-each>  -->       

</fieldset>


<div>
	<xsl:if test="string-length(//gmd:identificationInfo/*/gmd:pointOfContact)=0">
		<xsl:call-template name="party">
			<xsl:with-param name="root" select="."/>
			<xsl:with-param name="name" select="'dataContact'"/>
			<xsl:with-param name="i" select="(position()-1)"/>
			<xsl:with-param name="valid" select="'9.1'"/>
			<xsl:with-param name="langs" select="$langs"/>
			<xsl:with-param name="valid" select="'9.1'"/>
		</xsl:call-template>
	</xsl:if>

	<xsl:for-each select="//gmd:identificationInfo/*/gmd:pointOfContact">
		<xsl:call-template name="party">
			<xsl:with-param name="root" select="."/>
			<xsl:with-param name="name" select="'dataContact'"/>
			<xsl:with-param name="i" select="(position()-1)"/>
			<xsl:with-param name="valid" select="'9.1'"/>
			<xsl:with-param name="langs" select="$langs"/>
			<xsl:with-param name="valid" select="'9.1'"/>
		</xsl:call-template>
	</xsl:for-each>
</div>

<div>
	<xsl:if test="string-length(//gmd:contact)=0">
		<xsl:call-template name="party">
			<xsl:with-param name="root" select="."/>
			<xsl:with-param name="name" select="'contact'"/>
			<xsl:with-param name="i" select="(position()-1)"/>
			<xsl:with-param name="langs" select="$langs"/>
			<xsl:with-param name="valid" select="'10.1'"/>
            <xsl:with-param name="role" select="'md'"/>
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
</div>

<div style="clear:both; height:20px;"></div>
<div style="display:none" id="ask-uuid"><xsl:value-of select="$labels/msg[@name='ask-uuid']/label"/></div>
</xsl:template>

</xsl:stylesheet>
