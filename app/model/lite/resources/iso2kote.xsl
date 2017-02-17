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
	    <xsl:with-param name="req" select="'1'"/>
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
			<xsl:with-param name="name" select="'inspireEU'"/>
			<xsl:with-param name="class" select="'cond wide'"/>
		</xsl:call-template>			
        <xsl:for-each select="gmd:hierarchyLevelName[not(*='http://geoportal.gov.cz/inspire')]">
            <input type="hidden" name="hlName_{position()-1}" value="{*}"/>
        </xsl:for-each>
		
		<span class="locale">
            <xsl:choose>
                <xsl:when test="string-length(gmd:hierarchyLevelName[*='http://geoportal.gov.cz/inspire'])>0">
			        <input type="checkbox" checked="checked" name="inspireEU"/>
                </xsl:when>
                <xsl:otherwise>
                    <input type="checkbox" name="inspireEU_0_"/>
                </xsl:otherwise>     
            </xsl:choose>
		</span>
	</div>

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
		<xsl:with-param name="req" select="'1'"/>
	</xsl:call-template>

	<xsl:call-template name="drawInput">
		<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:abstract"/>
		<xsl:with-param name="name" select="'abstract'"/>
		<xsl:with-param name="type" select="'textarea'"/>
		<xsl:with-param name="class" select="'mandatory'"/>
		<xsl:with-param name="valid" select="'1.2'"/>
		<xsl:with-param name="langs" select="$langs"/>
		<xsl:with-param name="req" select="'1'"/>
	</xsl:call-template>
	
	
	<xsl:if test="not($serv)">
		<xsl:call-template name="drawInput">
			<xsl:with-param name="values" select="gmd:hierarchyLevel/*/@codeListValue"/>
			<xsl:with-param name="name" select="'hierarchyLevel'"/>
			<xsl:with-param name="codes" select="'inspireType'"/>
			<xsl:with-param name="class" select="'mandatory'"/>
			<xsl:with-param name="valid" select="'1.3'"/>
			<xsl:with-param name="req" select="'1'"/>
		</xsl:call-template>
		<!-- <xsl:call-template name="drawInput">
			<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/>
			<xsl:with-param name="name" select="'identifier'"/>
			<xsl:with-param name="type" select="'input'"/>
			<xsl:with-param name="class" select="'inp mandatory'"/>
			<xsl:with-param name="multi" select="2"/>
			<xsl:with-param name="valid" select="'1.5'"/>
		</xsl:call-template> -->
	    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier|/."> 
		  	<xsl:if test="normalize-space(*/gmd:code/*)!='' or (string-length(*/gmd:code/*)=0 and position()=last())">
				<div id="identifier_{position()-1}_" class="cl">
					<div style="float: left; width:400px;">
					  	<xsl:call-template name="drawInput">
						  	<xsl:with-param name="name" select="'identifier'"/>
						  	<xsl:with-param name="path" select="concat('identifier_',position()-1,'_code')"/>
						    <xsl:with-param name="values" select="*/gmd:code"/>
						    <xsl:with-param name="class" select="'inpS2 mandatory'"/>
							<xsl:with-param name="valid" select="'1.5'"/>
							<xsl:with-param name="req" select="'1'"/>
						</xsl:call-template>
				 	</div>
				 	<div style="float: left; width:250px;">
				 	<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'codeSpace'"/>
					  	<xsl:with-param name="path" select="concat('identifier_',position()-1,'_codeSpace')"/>
					    <xsl:with-param name="values" select="*/gmd:codeSpace"/>
					    <xsl:with-param name="class" select="'inpSS mandatory'"/>
					    <xsl:with-param name="req" select="'1'"/>
					    <xsl:with-param name="lclass" select="'short'"/>
					</xsl:call-template>
					</div>
			   	<span class="duplicate"></span><br/> 
			  </div>
		  </xsl:if>
	  </xsl:for-each>  


	</xsl:if>

	<xsl:if test="$serv">
		<xsl:call-template name="drawInput">
			<xsl:with-param name="values" select="gmd:hierarchyLevel/*/@codeListValue"/>
			<xsl:with-param name="name" select="'hierarchyLevel'"/>
			<xsl:with-param name="codes" select="'inspireServiceType'"/>
			<xsl:with-param name="class" select="'mandatory'"/>
			<xsl:with-param name="valid" select="'1.3'"/>
			<xsl:with-param name="req" select="'1'"/>
		</xsl:call-template>
		
	    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier|/."> 
		  	<xsl:if test="normalize-space(*/gmd:code/*)!='' or (string-length(*/gmd:code/*)=0 and position()=last())">
				<div id="identifier_{position()-1}_" class="cl">
					<div style="float: left; width:400px;">
					  	<xsl:call-template name="drawInput">
						  	<xsl:with-param name="name" select="'identifier'"/>
						  	<xsl:with-param name="path" select="concat('identifier_',position()-1,'_code')"/>
						    <xsl:with-param name="values" select="*/gmd:code"/>
						    <xsl:with-param name="class" select="'inpS2'"/>
							<xsl:with-param name="valid" select="'1.5'"/>
						</xsl:call-template>
				 	</div>
				 	<div style="float: left; width:250px;">
				 	<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'codeSpace'"/>
					  	<xsl:with-param name="path" select="concat('identifier_',position()-1,'_codeSpace')"/>
					    <xsl:with-param name="values" select="*/gmd:codeSpace"/>
					    <xsl:with-param name="class" select="'inpSS'"/>
					    <xsl:with-param name="lclass" select="'short'"/>
					</xsl:call-template>
					</div>
			   	<span class="duplicate"></span><br/> 
			  </div>
		  </xsl:if>
	  </xsl:for-each>  
		
	</xsl:if>

<!-- datum --> 
  <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date|/."> 
  	<xsl:if test="normalize-space(*/gmd:date)!='' or (normalize-space(*/gmd:date)='' and position()=last())">
		<div id="Date_{position()-1}_" class="cl">
			<div style="float: left; width:325px;">
			  	<xsl:call-template name="drawInput">
				  	<xsl:with-param name="name" select="'date'"/>
				  	<xsl:with-param name="path" select="concat('Date_',position()-1,'_date')"/>
				    <xsl:with-param name="values" select="*/gmd:date"/>
				    <xsl:with-param name="class" select="'date mandatory'"/>
				    <xsl:with-param name="type" select="'date'"/>
					<xsl:with-param name="valid" select="'5a'"/>
					<xsl:with-param name="req" select="'1'"/>
				</xsl:call-template>
		 	</div>
		 	<div style="float: left; width:325px;">
		 	<xsl:call-template name="drawInput">
			  	<xsl:with-param name="name" select="'dateType'"/>
			  	<xsl:with-param name="path" select="concat('Date_',position()-1,'_type')"/>
			    <xsl:with-param name="values" select="*/gmd:dateType/*/@codeListValue"/>
			    <xsl:with-param name="codes" select="'dateType'"/>
			    <xsl:with-param name="class" select="'mandatory'"/>
			    <xsl:with-param name="lclass" select="'short'"/>
			    <xsl:with-param name="req" select="'1'"/>
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

          		 <xsl:call-template name="drawInput">
          		  	<xsl:with-param name="name" select="'inspire'"/>
          		    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword/gco:CharacterString|gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword/gmx:Anchor"/>
          		    <xsl:with-param name="codes" select="'inspireKeywords'"/>
          		    <xsl:with-param name="codelist" select="$codeListsLang"/>
          		    <xsl:with-param name="multi" select="2"/>
          		    <xsl:with-param name="valid" select="'3.1'"/>
          		 </xsl:call-template> 
				
	      		 <!-- ostatani KW-->
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
      		 <!-- ostatni KW volna -->

        	<xsl:call-template name="drawInput">
        		<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[string-length(gmd:thesaurusName/*/gmd:title)=0]/gmd:keyword"/>
        		<xsl:with-param name="name" select="'fkw'"/>
        		<xsl:with-param name="class" select="'inp'"/>
        		<xsl:with-param name="langs" select="$langs"/>
                <xsl:with-param name="multi" select="2"/>
        	</xsl:call-template>
    		
    	  </xsl:when>
    
    	  <xsl:otherwise>
 
		 	<xsl:call-template name="drawInput">
				<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:purpose"/>
				<xsl:with-param name="name" select="'purpose'"/>
				<xsl:with-param name="type" select="'textarea'"/>
				<xsl:with-param name="langs" select="$langs"/>
				<xsl:with-param name="valid" select="'CZ-7'"/>
			</xsl:call-template> 
  
 
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
      		    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword/gco:CharacterString|gmd:identificationInfo/*/gmd:descriptiveKeywords[substring(*/gmd:thesaurusName/*/gmd:title/gco:CharacterString,1,15) = 'GEMET - INSPIRE']/*/gmd:keyword/gmx:Anchor"/>
      		    <xsl:with-param name="codes" select="'inspireKeywords'"/>
      		    <xsl:with-param name="class" select="'mandatory'"/>
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
        		<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/*[string-length(gmd:thesaurusName/*/gmd:title)=0]/gmd:keyword"/>
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
	    <xsl:with-param name="multi" select="1"/> 
	    <xsl:with-param name="class" select="'mandatory'"/>
	    <xsl:with-param name="valid" select="'2.2'"/>   
	  </xsl:call-template>

	  <xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'serviceTypeVersion'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/srv:serviceTypeVersion"/>
	    <xsl:with-param name="multi" select="2"/> 
	    <xsl:with-param name="class" select="'inpS'"/>
	    <xsl:with-param name="valid" select="'CZ-8'"/>   
	  </xsl:call-template>

	  <xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'couplingType'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/srv:couplingType/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'couplingType'"/>
	    <xsl:with-param name="multi" select="2"/> 
	    <xsl:with-param name="class" select="'mandatory'"/>
	    <xsl:with-param name="valid" select="'CZ-11'"/>   
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
	    <xsl:with-param name="req" select="'1'"/>   
	</xsl:call-template>


	<!-- prostorova reprezentace -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'spatial'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:spatialRepresentationType/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'spatialRepresentationType'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="valid" select="'IO-6'"/>
	</xsl:call-template>
	
	<!-- projekce -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'coorSys'"/>
	    <xsl:with-param name="values" select="gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier/*/gmd:code"/>
	    <xsl:with-param name="codes" select="'coordSys'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="class" select="'mandatory'"/>
	    <xsl:with-param name="valid" select="'IO-1'"/>
	</xsl:call-template>

	<!-- jazyk zdroje -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'language'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:language/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'language'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="class" select="'mandatory'"/>
	    <xsl:with-param name="valid" select="'1.7'"/>
	    <xsl:with-param name="req" select="'1'"/>
	</xsl:call-template>

	<!-- znak. sada zdroje -->
	<xsl:call-template name="drawInput">
	  	<xsl:with-param name="name" select="'characterSet'"/>
	    <xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue"/>
	    <xsl:with-param name="codes" select="'characterSet'"/>
	    <xsl:with-param name="multi" select="2"/>
	    <xsl:with-param name="valid" select="'IO-5'"/>
	    <!-- <xsl:with-param name="class" select="'mandatory'"/>  -->
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
 			
			<div id="operatesOn_{position()-1}_" style="clear:both">
	 			<fieldset>
	  				<xsl:call-template name="drawLegend">
						<xsl:with-param name="name" select="'operatesOn'"/>
						<xsl:with-param name="class" select="'cond'"/>
						<xsl:with-param name="valid" select="'1.6'"/>
					</xsl:call-template>
					
					<xsl:call-template name="drawRow">
						<xsl:with-param name="name" select="'operatesOn_href'"/>
				  		<xsl:with-param name="path" select="concat('operatesOn_',position()-1,'_href')"/>
				    	<xsl:with-param name="value" select="$url"/> 
				    	<xsl:with-param name="class" select="''"/> 
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

<xsl:if test="not($serv)">
<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceMaintenance|/.">
	<xsl:if test="string-length(*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue)>0 or(string-length(*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue)=0 and position()=last())">
		<xsl:variable name="row" select="position()-1"/>
		<fieldset style="clear:both" class="cl" id="maintenance_{$row}_">
			<xsl:call-template name="drawLegend">
				<xsl:with-param name="name" select="'Maintenance'"/>
				<xsl:with-param name="class" select="'mand'"/>
			</xsl:call-template>
		
				<!-- aktualizace -->
			<xsl:call-template name="drawInput">
			  	<xsl:with-param name="name" select="'maintenanceFrequency'"/>
			    <xsl:with-param name="values" select="*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>
			    <xsl:with-param name="codes" select="'maintenanceAndUpdateFrequency'"/>
				<xsl:with-param name="path" select="concat('maintenance_',$row,'_frequency')"/>	    
			    <xsl:with-param name="mand" select="''"/>
			    <xsl:with-param name="class" select="'cond'"/>
			    <xsl:with-param name="valid" select="'CZ-4'"/>
			</xsl:call-template>
		  
			<xsl:call-template name="drawInput">
			  	<xsl:with-param name="name" select="'maintenanceUser'"/>
			    <xsl:with-param name="values" select="*/gmd:userDefinedMaintenanceFrequency"/>
				<xsl:with-param name="path" select="concat('maintenance_',$row,'_user')"/>	    
			    <xsl:with-param name="class" select="'inpSS cond'"/>
			    <xsl:with-param name="valid" select="'CZ-4'"/>
			</xsl:call-template>
		  
			<!-- dalsi prvky maintenance -->
			<xsl:call-template name="drawInput">
			  	<xsl:with-param name="name" select="'maintenanceScope'"/>
			    <xsl:with-param name="values" select="*/gmd:updateScope/*/@codeListValue"/>
			    <xsl:with-param name="codes" select="'updateScope'"/>
				<xsl:with-param name="path" select="concat('maintenance_',$row,'_scope')"/>	    
			    <xsl:with-param name="multi" select="2"/>
			    <xsl:with-param name="mand" select="''"/>
			    <xsl:with-param name="valid" select="'CZ-4'"/>
			</xsl:call-template>
		  
			<xsl:call-template name="drawInput">
			  	<xsl:with-param name="name" select="'maintenanceNote'"/>
			    <xsl:with-param name="values" select="*/gmd:maintenanceNote"/>
				<xsl:with-param name="path" select="concat('maintenance_',$row,'_note')"/>	    
			    <xsl:with-param name="multi" select="1"/> <!-- TODO zatim ... -->
			    <xsl:with-param name="valid" select="'CZ-6'"/>
			</xsl:call-template>
			<span class="duplicate"></span> 	
			
		</fieldset>
	</xsl:if>
</xsl:for-each>
</xsl:if>

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
	<span title="{$labels/msg[@name='fromList']/label}" class="open" onclick="fromGaz();">.</span>


</div>

<div style="width:250px; float:left;">
	<fieldset>
 		<xsl:call-template name="drawLegend">
			<xsl:with-param name="name" select="'timeExtent'"/>
			<xsl:with-param name="class" select="'cond'"/>
			<xsl:with-param name="valid" select="'5b'"/>
		</xsl:call-template>	
	
		<xsl:for-each select="gmd:identificationInfo/*/*/*/gmd:temporalElement|/.">
			<xsl:if test="string-length(*/gmd:extent)>0 or(string-length(*/gmd:extent)=0 and position()=last())">
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

<!-- pokrytí -->
<xsl:if test="not($serv)">
    <fieldset>
    	<xsl:call-template name="drawLegend">
    		<xsl:with-param name="name" select="'Coverage'"/>
    		<xsl:with-param name="class" select="''"/>
            <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>	
    	
    	<!-- plocha -->
    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coverageArea'"/>
    	    <xsl:with-param name="values" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/*/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'#km2')]/*/gmd:value"/>
    	    <xsl:with-param name="multi" select="1"/>
    	    <xsl:with-param name="class" select="'inpSS cond'"/>
    	    <!--  xsl:with-param name="action" select="'cover(this)'"/-->
    	</xsl:call-template>
    
    	<!-- % -->
    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coveragePercent'"/>
    	    <xsl:with-param name="values" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code/*='CZ-COVERAGE']/*/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'#percent')]/*/gmd:value"/>
    	    <xsl:with-param name="multi" select="1"/>
    	    <xsl:with-param name="class" select="'inpSS cond'"/>
    	    <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>
    
    	<!-- uzemi -->
    	<xsl:call-template name="drawInput">
    	  	<xsl:with-param name="name" select="'coverageDesc'"/>
    	    <xsl:with-param name="values" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_CompletenessOmission/gmd:measureIdentification/*/gmd:code='CZ-COVERAGE']/*/gmd:measureDescription"/>
    	    <xsl:with-param name="multi" select="1"/>
    	    <xsl:with-param name="class" select="'inp'"/>
    	    <xsl:with-param name="valid" select="'CZ-10'"/>
    	</xsl:call-template>
    </fieldset>
</xsl:if>

<fieldset>
	<xsl:call-template name="drawLegend">
		<xsl:with-param name="name" select="'Distribution'"/>
		<xsl:with-param name="class" select="'mand'"/>
	</xsl:call-template>	
 	<xsl:call-template name="drawInput">
	 	<xsl:with-param name="name" select="'linkage'"/>
	    <xsl:with-param name="values" select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage"/>
	    <xsl:with-param name="multi" select="2"/> 
	    <xsl:with-param name="class" select="'cond inp'"/>   
		<xsl:with-param name="valid" select="'1.4'"/>
	</xsl:call-template>
 	<xsl:if test="not($serv)">
    	<xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat|/.">
    		<xsl:if test="*/gmd:name/*!='' or (string-length(*/gmd:name/*)=0 and position()=last())">
    		      <div id="{concat('format_',(position()-1),'_')}" style="margin:0px;" class="cl">
    				<hr/>
    	 	 		<xsl:call-template name="drawInput">
    				  	<xsl:with-param name="name" select="'format'"/>
    				  	<xsl:with-param name="path" select="concat('format_',(position()-1),'_name')"/>
    				    <xsl:with-param name="values" select="*/gmd:name"/>
    				    <xsl:with-param name="class" select="'inpSS mandatory'"/>
    				    <xsl:with-param name="action" select="'getFormats(this)'"/> 
    				    <xsl:with-param name="valid" select="'IO-3'"/>  
    			  	</xsl:call-template>
    		 		<xsl:call-template name="drawInput">
    				  	<xsl:with-param name="name" select="'format_version'"/>
    				  	<xsl:with-param name="path" select="concat('format_',(position()-1),'_version')"/>
    				    <xsl:with-param name="values" select="*/gmd:version"/>
    				    <xsl:with-param name="class" select="'inpSS mandatory'"/>  
    			  	</xsl:call-template>
    		 		<xsl:call-template name="drawInput">
    				  	<xsl:with-param name="name" select="'format_specification'"/>
    				  	<xsl:with-param name="path" select="concat('format_',(position()-1),'_specification')"/>
    				    <xsl:with-param name="values" select="*/gmd:specification"/>
    				    <xsl:with-param name="class" select="'inp'"/>
    				    <xsl:with-param name="action" select="'fspec(this)'"/>  
    			  	</xsl:call-template>
    		        <span class="duplicate"></span>
    		    </div>
    		</xsl:if>
    	</xsl:for-each>	    
    </xsl:if>
  	<div class="cl"></div>
   
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

	<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result|/.">
		<xsl:if test="string-length(*/gmd:specification)>0 or (string-length(*/gmd:specification)=0 and position()=last())">
			<div class="cl" id="specification_{position()-1}_">
				
				<xsl:variable name="spec" select="normalize-space(*/gmd:specification/*/gmd:title/gco:CharacterString)"/>
				<xsl:variable name="spec1" select="$codeLists/serviceSpecifications/value[contains($spec, @name)]/@name"/>
				<xsl:variable name="kspec" select="$codeLists/serviceSpecifications/value[contains($spec, @name)]/@code"/>
                <hr/>

			    <div>
				 	<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'specification'"/>
					  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_title')"/>
					    <xsl:with-param name="values" select="*/gmd:specification/*/gmd:title"/>
					    <xsl:with-param name="class" select="'mandatory'"/>
					    <xsl:with-param name="type" select="'textarea'"/> 
					    <xsl:with-param name="langs" select="$langs"/>
					    <xsl:with-param name="action" select="'specif(this)'"/>
					    <xsl:with-param name="valid" select="'7.1'"/>    
					</xsl:call-template>
				 	<!-- <xsl:choose>
						<xsl:when test="$serv">
							<xsl:call-template name="drawInput">
								<xsl:with-param name="name" select="'specification'"/>
							  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_code')"/>
							    <xsl:with-param name="values" select="$kspec"/>
							    <xsl:with-param name="codes" select="'serviceSpecifications'"/>
							    <xsl:with-param name="class" select="'mandatory'"/>
							    <xsl:with-param name="type" select="'cselect'"/>
					            <xsl:with-param name="valid" select="'7.1'"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="drawInput">
								<xsl:with-param name="name" select="'specification'"/>
							  	<xsl:with-param name="path" select="concat('specification_',position()-1,'_code')"/>
							    <xsl:with-param name="values" select="$kspec"/>
                                <xsl:with-param name="type" select="'cselect'"/>
							    <xsl:with-param name="codes" select="'serviceSpecifications'"/>
							    <xsl:with-param name="class" select="'mandatory'"/>
					            <xsl:with-param name="valid" select="'7.1'"/>
							</xsl:call-template>			
						</xsl:otherwise>
					</xsl:choose> -->
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

<xsl:if test="not($serv)">

	<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_TopologicalConsistency|.">
		<xsl:if test="string-length(gmd:nameOfMeasure)>0 or(string-length(gmd:nameOfMeasure)=0 and position()=1)">
            <xsl:variable name="pos" select="position()-1"/>
			<fieldset class="cl" id="topological_{$pos}_">
		       	<xsl:call-template name="drawLegend">
		       		<xsl:with-param name="name" select="'Topological'"/>
		       		<xsl:with-param name="class" select="'info'"/>
		       	</xsl:call-template>		
		
					<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'topologicalName'"/>
					  	<xsl:with-param name="path" select="concat('topological_',$pos,'_name')"/>
					    <xsl:with-param name="values" select="gmd:nameOfMeasure"/>
					    <xsl:with-param name="class" select="''"/>
					    <xsl:with-param name="valid" select="'IO-4'"/>
					</xsl:call-template>

					<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'topologicalCode'"/>
					  	<xsl:with-param name="path" select="concat('topological_',$pos,'_code')"/>
					    <xsl:with-param name="values" select="gmd:measureIdentification/*/gmd:code"/>
					    <xsl:with-param name="class" select="''"/>
					    <xsl:with-param name="valid" select="'IO-4'"/>
					</xsl:call-template>

					<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'topologicalDesr'"/>
					  	<xsl:with-param name="path" select="concat('topological_',$pos,'_descr')"/>
					    <xsl:with-param name="values" select="gmd:measureDescription"/>
					    <xsl:with-param name="class" select="''"/>
					    <xsl:with-param name="langs" select="$langs"/>
					    <xsl:with-param name="valid" select="'IO-4'"/>
                        <xsl:with-param name="type" select="'textarea'"/>
					</xsl:call-template>

					<xsl:call-template name="drawRow">
					  	<xsl:with-param name="name" select="'topologicalDate'"/>
					  	<xsl:with-param name="path" select="concat('topological_',$pos,'_date')"/>
					    <xsl:with-param name="value" select="substring-before(gmd:dateTime,'T')"/>
					    <xsl:with-param name="class" select="'date'"/>
                        <xsl:with-param name="type" select="'date'"/>
					    <xsl:with-param name="valid" select="'IO-4'"/>
					</xsl:call-template>

					<fieldset class="cl">
				       	<xsl:call-template name="drawLegend">
				       		<xsl:with-param name="name" select="'topologicalResult'"/>
				       		<xsl:with-param name="class" select="'info'"/>
				       	</xsl:call-template>		

                    <div style="float: left; width:300px;">
        				<xsl:call-template name="drawInput">
        				  	<xsl:with-param name="name" select="'topologicalValue'"/>
        				  	<xsl:with-param name="path" select="concat('topological_',$pos,'_value')"/>
        				    <xsl:with-param name="values" select="gmd:result/*/gmd:value"/>
	                        <xsl:with-param name="class" select="'num'"/>
        				    <xsl:with-param name="valid" select="'IO-4'"/>
        				</xsl:call-template>
                    </div>
                            
                    <div style="float: left; width:325px;">
        				<xsl:call-template name="drawRow">
        				  	<xsl:with-param name="name" select="'topologicalUnit'"/>
        				  	<xsl:with-param name="path" select="concat('topological_',$pos,'_unit')"/>
        				    <xsl:with-param name="value" select="substring-after(gmd:result/*/gmd:valueUnit/@xlink:href,'#')"/>
        				    <xsl:with-param name="class" select="''"/>
        				    <xsl:with-param name="valid" select="'IO-4'"/>
                            <xsl:with-param name="type" select="'cselect'"/>
    		      		    <xsl:with-param name="codes" select="'units'"/>
               			</xsl:call-template>
                    </div>
					</fieldset>
					
					<fieldset class="cl">
				       	<xsl:call-template name="drawLegend">
				       		<xsl:with-param name="name" select="'topologicalKResult'"/>
				       		<xsl:with-param name="class" select="'info'"/>
				       	</xsl:call-template>
				       		
    		 		<xsl:call-template name="drawInput">
    				  	<xsl:with-param name="name" select="'topologicalKTitle'"/>
    				  	<xsl:with-param name="path" select="concat('topological_',(position()-1),'_specification')"/>
    				    <xsl:with-param name="values" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:title"/>
    				    <xsl:with-param name="class" select="'inp'"/>
    				    <xsl:with-param name="action" select="'fspec(this)'"/>  
    			  	</xsl:call-template>

					<!-- datum --> 
					<div style="float: left; width:325px;">
						<xsl:call-template name="drawInput">
							<xsl:with-param name="name" select="'topologicalSpecDate'"/>
						  	<xsl:with-param name="path" select="concat('topological_',(position()-1),'_specDate')"/>
						    <xsl:with-param name="values" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:date"/>
						    <xsl:with-param name="class" select="'date'"/>
						    <xsl:with-param name="type" select="'date'"/>
						</xsl:call-template>
					</div>
					<div style="float: left; width:325px;">
						<xsl:call-template name="drawInput">
							<xsl:with-param name="name" select="'topologicalSpecDateType'"/>
							<xsl:with-param name="path" select="concat('topological_',(position()-1),'_specDateType')"/>
							<xsl:with-param name="values" select="gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>
							<xsl:with-param name="codes" select="'dateType'"/>
							<xsl:with-param name="lclass" select="'short'"/>
						</xsl:call-template>
					</div>
					<div style="clear:both"></div>
					
    		 		<xsl:call-template name="drawInput">
    				  	<xsl:with-param name="name" select="'topologicalExpl'"/>
    				  	<xsl:with-param name="path" select="concat('topological_',(position()-1),'_explanation')"/>
    				    <xsl:with-param name="values" select="gmd:result/gmd:DQ_ConformanceResult/gmd:explanation"/>
    				    <xsl:with-param name="class" select="'inp'"/>  
    			  	</xsl:call-template>

					<xsl:call-template name="drawInput">
					  	<xsl:with-param name="name" select="'topologicalPass'"/>
					  	<xsl:with-param name="path" select="concat('topological_',position()-1,'_pass')"/>
					    <xsl:with-param name="values" select="gmd:result/gmd:DQ_ConformanceResult/gmd:pass/gco:Boolean"/>
					    <xsl:with-param name="codes" select="'compliant'"/>
					</xsl:call-template>
					
					</fieldset>
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
				<span class="duplicate"></span>			
			</fieldset>
		</xsl:if>
	</xsl:for-each>
	
</xsl:if>

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
</div>

<div style="clear:both; height:20px;"></div>
<div style="display:none" id="ask-uuid"><xsl:value-of select="$labels/msg[@name='ask-uuid']/label"/></div>
</xsl:template>

</xsl:stylesheet>
