<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml/3.2" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
>
<xsl:output method="html" encoding="utf-8"/>
<xsl:param name="lang"/>

<!-- GLOBAL VARIABLES -->
<xsl:variable name="codeLists" select="document(concat('../../xsl/codelists_' ,$lang, '.xml'))/map" />
<xsl:variable name="labels" select="document(concat('labels-', $lang, '.xml'))/labels" />
<!-- <xsl:variable name="validator" select="document('../../include/logs/aaa.xml')/validationResult" /> -->

<!-- vyplni select box(y) -->
<xsl:template name="sel">
	<xsl:param name="name"/>
	<xsl:param name="values"/>
	<xsl:param name="codes"/>
	<xsl:param name="title"/>
	<xsl:param name="multi"/>
	<xsl:param name="mand"/>
		
	
	<!-- prazdna hodnota -->
	<xsl:if test="not($values)">
		<div id="{$name}_0_">
			 <xsl:if test="$title">
				<label for="{$name}" class="{$mand}"><xsl:value-of select="$title"/></label>
			</xsl:if> 
			<select name="{$name}_0_">
				<option value=""> </option>
				<!-- cyklus pres ciselnik -->
				<xsl:for-each select="$codes/*">
					<option value="{@name}"><xsl:value-of select="."/></option>
		  		</xsl:for-each>
			</select>	
			<xsl:if test="$multi">
				<span class="duplicate"></span>
			</xsl:if>
		</div>
	</xsl:if>
	
	<!-- cyklus pres vsechny hodnoty XML -->
	<xsl:for-each select="$values">
		<xsl:variable name="current" select="normalize-space(.)"/>
		<div id="{concat($name,'_',(position()-1),'_')}">
			<xsl:if test="$title">          
				<label for="{$name}" class="{$mand}"><xsl:value-of select="$title"/></label>
			</xsl:if>
			<select name="{concat($name,'_',position()-1,'_')}">
				<option value=""></option>
				<!-- cyklus pres ciselnik -->
				<xsl:for-each select="$codes/*">
		  			<xsl:choose>
		  				<xsl:when test="@name=$current">
		  					<option value="{@name}" selected="selected"><xsl:value-of select="."/></option>
		  				</xsl:when>
		  				<xsl:otherwise>
		  					<option value="{@name}"><xsl:value-of select="."/></option>
		  				</xsl:otherwise>
		  			</xsl:choose>		
		  		</xsl:for-each>
			</select>
  		<xsl:if test="$multi">
  			<span class="duplicate"></span>
  		</xsl:if>
		</div>		
	</xsl:for-each>
</xsl:template>

<!-- ZOBRAZENI ORGANIZACE -->
<xsl:template name="party">
	<xsl:param name="root"/>
	<xsl:param name="name"/>
	<xsl:param name="i"/>
	<xsl:param name="title"/>
	<xsl:param name="codeLists"/>
	<xsl:param name="valid"/>
	<xsl:param name="langs"/>
	<xsl:param name="role" select="'role'"/>
	
	<!-- validace --> 

	<!-- <xsl:choose>
		<xsl:when test="$validator/test[@code=$valid and @level='c']//err">
			<div style="color:#00A000;margin-left:105px">
				<xsl:value-of select="$validator/test[@code=$valid]//err/.."/>
				<xsl:value-of select="$validator/test[@code=$valid]//err"/>
			</div>
		</xsl:when> 
		<xsl:when test="$validator/test[@code=$valid]//err!=''">
			<div style="background:#FF5050;margin-left:105px">
				<xsl:value-of select="$validator/test[@code=$valid]//err"/>
				<xsl:value-of select="$validator/test[@code=$valid]//err"/>
			</div>
		</xsl:when>  
	</xsl:choose> -->


	<fieldset id="{concat($name, '_',$i,'_')}">

		<xsl:call-template name="drawLegend">
			<xsl:with-param name="name" select="$name"/>
			<xsl:with-param name="class" select="'mand'"/>
		</xsl:call-template>
		
		<xsl:variable name="getParty">
		  <xsl:if test="$publisher=1">getParty(this);</xsl:if>
		</xsl:variable>
		
		<xsl:choose>
		<xsl:when test="$publisher=1">
  		<xsl:call-template name="drawInput">
  		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_organisationName')"/>
  		  	<xsl:with-param name="name" select="'organisationName'"/>
  			  <xsl:with-param name="values" select="$root/*/gmd:organisationName"/>
  			  <xsl:with-param name="class" select="'inpS mandatory'"/>
  			  <xsl:with-param name="action" select="'getParty(this)'"/>
  			  <xsl:with-param name="langs" select="$langs"/>
  			  <xsl:with-param name="valid" select="$valid"/>
  		</xsl:call-template>
  	</xsl:when>
    <xsl:otherwise>
  		<xsl:call-template name="drawInput">
  		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_organisationName')"/>
  		  	<xsl:with-param name="name" select="'organisationName'"/>
  			  <xsl:with-param name="values" select="$root/*/gmd:organisationName"/>
  			  <xsl:with-param name="class" select="'inpS mandatory'"/>
  			  <xsl:with-param name="langs" select="$langs"/>
  			  <xsl:with-param name="valid" select="$valid"/>
  			</xsl:call-template>    
    </xsl:otherwise>
    </xsl:choose>	

		<!-- 

		<div><label>Osoba</label><input class="inp inpS" name="{concat($name,'_',$i,'_individualName_')}" value="{$root/*/gmd:individualName/gco:CharacterString}"/></div>
		<div><label>Funkce</label><input class="inp inpSS" name="{concat($name,'_',$i,'_positionName_')}" value="{$root/*/gmd:position/gco:CharacterString}" /></div>
	 	-->

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_deliveryPoint')"/>
		  	<xsl:with-param name="name" select="'deliveryPoint'"/>
			<xsl:with-param name="values" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/>
			<xsl:with-param name="class" select="'inpS'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_city')"/>
		  	<xsl:with-param name="name" select="'city'"/>
			<xsl:with-param name="values" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:city"/>
			<xsl:with-param name="class" select="'inpS'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_postalCode')"/>
		  	<xsl:with-param name="name" select="'postalCode'"/>
			<xsl:with-param name="values" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/>
			<xsl:with-param name="class" select="'inpSS'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_country')"/>
		  	<xsl:with-param name="name" select="'country'"/>
			<xsl:with-param name="values" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:country"/>
			<xsl:with-param name="class" select="'inpSS'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_phone')"/>
		  	<xsl:with-param name="name" select="'phone'"/>
			<xsl:with-param name="values" select="$root/*/gmd:contactInfo/*/gmd:phone/*/gmd:voice"/>
			<xsl:with-param name="multi" select="2"/>
			<xsl:with-param name="class" select="'inpSS'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_email')"/>
		  	<xsl:with-param name="name" select="'email'"/>
			<xsl:with-param name="values" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/>
			<xsl:with-param name="multi" select="2"/>
			<xsl:with-param name="class" select="'inpS mandatory'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_www')"/>
		  	<xsl:with-param name="name" select="'www'"/>
			<xsl:with-param name="values" select="$root/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage"/>
			<xsl:with-param name="multi" select="2"/>
			<xsl:with-param name="class" select="'inpS'"/>
		</xsl:call-template>
		
		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="name" select="$role"/>
		  	<xsl:with-param name="path" select="concat($name,'_',$i,'_role')"/>
			<xsl:with-param name="values" select="$root/*/gmd:role/*/@codeListValue"/>
			<xsl:with-param name="codes" select="'role'"/>
			<xsl:with-param name="class" select="'mandatory'"/>
			<xsl:with-param name="req" select="'1'"/>
		</xsl:call-template>		  	
		<span class="duplicate"></span>
	</fieldset>
	
</xsl:template>

<xsl:template name="drawInput">
	<xsl:param name="name"/>
	<xsl:param name="path" select="$name"/>
	<xsl:param name="values"/>
	<xsl:param name="class"/>
	<xsl:param name="lclass"/>
	<xsl:param name="type"/>
	<xsl:param name="codes"/>
	<xsl:param name="multi"/>
	<xsl:param name="action"/>
	<xsl:param name="codelist" select="$codeLists"/>
	<xsl:param name="valid" select="''"/>
	<xsl:param name="langs"/>
	<xsl:param name="req" select="''"/>
	
	<!-- validace --> 
	<!-- <xsl:choose>
		<xsl:when test="$validator/test[@code=$valid]/@level='m'">
			<div style="background:#FF5050;margin-left:105px"><xsl:value-of select="$validator/test[@code=$valid]/err"/></div>
		</xsl:when>  
		<xsl:when test="$validator/test[@code=$valid]/@level='c'">
			<div style="color:#00A000;margin-left:105px"><xsl:value-of select="$validator/test[@code=$valid]/err"/></div>
		</xsl:when> 
	</xsl:choose> -->

	<xsl:if test="not($values)">
		<xsl:call-template name="drawRow">
		  	<xsl:with-param name="name" select="$name"/>
		  	<xsl:with-param name="path" select="concat($path,'_0_')"/>
		    <xsl:with-param name="value"></xsl:with-param>
		    <xsl:with-param name="codes" select="$codes"/>
		    <xsl:with-param name="multi" select="$multi"/>
		    <xsl:with-param name="type" select="$type"/>
		    <xsl:with-param name="class" select="$class"/>	
		    <xsl:with-param name="lclass" select="$lclass"/>	
		    <xsl:with-param name="action" select="$action"/>
		    <xsl:with-param name="codelist" select="$codelist"/>	
		    <xsl:with-param name="valid" select="$valid"/>
		    <xsl:with-param name="langs" select="$langs"/>
		    <xsl:with-param name="req" select="$req"/>
		</xsl:call-template>
	</xsl:if>
	
	
	<xsl:for-each select="$values">
		<xsl:call-template name="drawRow">
		  	<xsl:with-param name="name" select="$name"/>
		  	<xsl:with-param name="path" select="concat($path,'_',position()-1,'_')"/>
		    <xsl:with-param name="value" select="."/>
		    <xsl:with-param name="codes" select="$codes"/>
		    <xsl:with-param name="multi" select="$multi"/>
		    <xsl:with-param name="type" select="$type"/>
		    <xsl:with-param name="class" select="$class"/>
		    <xsl:with-param name="lclass" select="$lclass"/>	
		   	<xsl:with-param name="action" select="$action"/>
		   	<xsl:with-param name="codelist" select="$codelist"/>
		    <xsl:with-param name="valid" select="$valid"/>
		    <xsl:with-param name="langs" select="$langs"/>
		    <xsl:with-param name="req" select="$req"/>		   			
		</xsl:call-template>	
	</xsl:for-each>
	

</xsl:template>


<!-- VYPISE JEDEN RADEK - INPUT -->
<xsl:template name="drawRow">
	<xsl:param name="name"/>
	<xsl:param name="path" select="$name"/>
	<xsl:param name="value"/>
	<xsl:param name="class"/>
	<xsl:param name="lclass"/>
	<xsl:param name="type"/>
	<xsl:param name="codes"/>
	<xsl:param name="multi"/>
	<xsl:param name="action"/>
	<xsl:param name="codelist" select="$codeLists"/>
	<xsl:param name="valid"/>
	<xsl:param name="langs"/>
	<xsl:param name="req" select="''"/>
	
	
	<!-- class pro label -->
	<xsl:variable name="lclassI">
		<xsl:choose>
			<xsl:when test="contains($class,'mandatory')">mand</xsl:when>
			<xsl:when test="contains($class,'cond')">cond</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$lclass!=''"><xsl:text> </xsl:text><xsl:value-of select="$lclass"/></xsl:if>
	</xsl:variable>

			
	<div id="{$path}">
		<xsl:if test="$labels/msg[@name=$name]/label!=''">
			<label for="{$name}" class="{$lclassI}" id="V-{$valid}">
				<xsl:value-of select="$labels/msg[@name=$name]/label"/>
				<xsl:call-template name="drawHelp">
					<xsl:with-param name="h" select="$labels/msg[@name=$name]/help"/>
				</xsl:call-template>
			</label>
			
			<!-- validace  
			<xsl:choose>
				<xsl:when test="$validator/test[@code=$valid]/pass='true'">
					<img src="img/pass.png"/>
				</xsl:when>
				<xsl:when test="$validator/test[@code=$valid]/@level='m'">
					<img src="validator/style/fail.png" title="{$validator/test[@code=$valid]/err}"/>
				</xsl:when> 
				<xsl:when test="$validator/test[@code=$valid]/@level='c'">
					<img src="validator/style/warning.gif" title="{$validator/test[@code=$valid]/err}"/>
				</xsl:when> 
			</xsl:choose> -->
			
		</xsl:if>
		
		<xsl:variable name="cl"><xsl:choose>
			<xsl:when test="$langs">lang-<xsl:value-of select="$mlang"/></xsl:when>
		</xsl:choose></xsl:variable>
		<span class="locale {$cl}">
			<xsl:choose>

			<!-- TEXAREA -->
			<xsl:when test="$type='textarea'">
				<textarea class="{$class}" name="{$path}TXT">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
					<xsl:if test="$value!=''"><xsl:value-of select="$value/*"/></xsl:if>					
				</textarea>
			</xsl:when>

			<!-- INPUT - BOOELAN -->
			<xsl:when test="$type='boolean'">
				<xsl:choose>
					<xsl:when test="$value='1' or value='true'">
						<input type="checkbox" name="{$path}" checked="true">
						<xsl:if test="$req">
							<xsl:attribute name="required">required</xsl:attribute>
						</xsl:if>
						</input>
					</xsl:when>
					<xsl:otherwise>
						<input type="checkbox" name="{$path}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<!-- INPUT - plain -->
			<xsl:when test="$type='plain'">
				<input name="{$path}TXT" class="inp {$class}" value="{$value}">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- DATE  -->
			<xsl:when test="$type='date'">
				<input name="{$path}" class="inp date {$class}" value="{$value}" pattern="^(19|20)\d\d([-](0[1-9]|1[012]))?([-](0[1-9]|[12][0-9]|3[01]))?$">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- REAL -->
			<xsl:when test="$type='real'">
				<input name="{$path}TXT" class="inp num {$class}" value="{$value}" pattern="[-+]?[0-9]*\.?[0-9]*">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- INTEGER -->
			<xsl:when test="$type='integer'">
				<input name="{$path}TXT" class="inp num {$class}" value="{$value}" pattern="[-+]?[0-9]*">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- SELECT pres code -->
			<xsl:when test="$type='cselect'">
				<select name="{$path}" class="{$class}">
					<option value=""></option>
					<!-- cyklus pres ciselnik -->
					<xsl:for-each select="$codelist/*[name()=$codes]/value">
			  			<xsl:choose>
			  				<xsl:when test="@code=normalize-space($value)">
			  					<option value="{@code}" selected="selected"><xsl:value-of select="."/></option>
			  				</xsl:when>
			  				<xsl:otherwise>
			  					<option value="{@code}"><xsl:value-of select="."/></option>
			  				</xsl:otherwise>
			  			</xsl:choose>		
			  		</xsl:for-each>
				</select>		
			</xsl:when>
			
			<!-- SELECT -->
			<xsl:when test="$codes!=''">
				<select name="{$path}" class="{$class}">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
					<option value=""></option>
					<!-- cyklus pres ciselnik -->
					<xsl:for-each select="$codelist/*[name()=$codes]/value">
			  			<xsl:choose>
			  				<xsl:when test="@name=normalize-space($value) or @uri=normalize-space($value)">
			  					<option value="{@name}" selected="selected"><xsl:value-of select="."/></option>
			  				</xsl:when>
			  				<xsl:otherwise>
			  					<option value="{@name}"><xsl:value-of select="."/></option>
			  				</xsl:otherwise>
			  			</xsl:choose>		
			  		</xsl:for-each>
				</select>		
			</xsl:when>

			<!-- INPUT - TEXT -->
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$value!=''">
						<input name="{$path}TXT" class="inp {$class}" value="{$value/*}">
							<xsl:if test="$req">
								<xsl:attribute name="required">required</xsl:attribute>
							</xsl:if>
						</input>
					</xsl:when>
					<xsl:otherwise>
						<input name="{$path}TXT" class="inp {$class}">
							<xsl:if test="$req">
								<xsl:attribute name="required">required</xsl:attribute>
							</xsl:if>
						</input>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>

				
		</xsl:choose>
		</span>
		
		<!-- akcni tlacitka -->
		<xsl:if test="$action">
			<span class="open" title="{$labels/msg[@name='fromList']/label}" onclick="{$action};"></span>
		</xsl:if>	
		<xsl:if test="$multi &gt; 1">
			<span class="duplicate"></span>
		</xsl:if>	

		<xsl:choose>
			<xsl:when test="$langs and $type='textarea'">
				<xsl:for-each select="$langs">
					<xsl:variable name="pos" select="position()"/>
					<div>
						<label></label>
						<span class="locale lang-{*/gmd:languageCode/*/@codeListValue}">
							<textarea class="{$class}X" name="{$path}TXT{*/gmd:languageCode/*/@codeListValue}">
								<xsl:if test="$value"><xsl:value-of select="$value/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',$langs[$pos]/*/@id)]"/></xsl:if>
							</textarea>
						</span>
					</div>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$langs">
				<xsl:for-each select="$langs">
					<xsl:variable name="pos" select="position()"/>
					<div>
					<label></label>
					<span class="locale lang-{*/gmd:languageCode/*/@codeListValue}">
						<xsl:choose>
							<xsl:when test="$value">
								<input name="{$path}TXT{*/gmd:languageCode/*/@codeListValue}" class="inp {$class}X" value="{$value/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',$langs[$pos]/*/@id)]}"/>
							</xsl:when>
							<xsl:otherwise>
								<input name="{$path}TXT{*/gmd:languageCode/*/@codeListValue}" class="inp {$class}X" value=""/>
							</xsl:otherwise>
						</xsl:choose>	
					</span>
					</div>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
		
	</div>
	
	<!-- <xsl:if test="name($value/following-sibling::*)=name($value) and name($value)">
		<xsl:call-template name="drawRow">
		  	<xsl:with-param name="name" select="$name"/>
		    <xsl:with-param name="value" select="$value/following-sibling::*"/>
		    <xsl:with-param name="codes" select="$codes"/>
		    <xsl:with-param name="multi" select="$multi"/>
		    <xsl:with-param name="type" select="$type"/>
		    <xsl:with-param name="class" select="$class"/>		
		</xsl:call-template>	
	</xsl:if>  -->
	
</xsl:template>

<xsl:template name="drawLegend">
	<xsl:param name="name"/>
	<xsl:param name="class"/>
    <xsl:param name="valid"/>
	<xsl:if test="$labels/msg[@name=$name]/label!=''">
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="$valid">V-<xsl:value-of select="$valid"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$name"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
		<legend id="{$id}" class="{$class}">
			<xsl:value-of select="$labels/msg[@name=$name]/label"/>
			<xsl:call-template name="drawHelp">
				<xsl:with-param name="h" select="$labels/msg[@name=$name]/help"/>
			</xsl:call-template>	
		</legend>
	</xsl:if>
</xsl:template>

<xsl:template name="drawLabel">
	<xsl:param name="name"/>
	<xsl:param name="class"/>
	<xsl:param name="valid"/>
	<xsl:if test="$labels/msg[@name=$name]/label!=''">
		<label for="{$name}" class="{$class}" id="V-{$valid}">
			<xsl:value-of select="$labels/msg[@name=$name]/label"/>
			<xsl:call-template name="drawHelp">
				<xsl:with-param name="h" select="$labels/msg[@name=$name]/help"/>
			</xsl:call-template>	
		</label>
	</xsl:if>
</xsl:template>

<xsl:template name="drawHelp">
	<xsl:param name="h"/>
	<xsl:if test="$h!=''">
		<span class="help"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span>
		<div class="tooltip" id="t-{name($h/..)}">
			<!-- <h3><xsl:value-of select="$h/../label"/></h3> -->
			<xsl:copy-of select="$h/node()"/>
		</div>
	</xsl:if>	
</xsl:template>

<!-- prevod radku na <br/> -->
<xsl:template name="lf2br">
		<xsl:param name="str"/>
		<xsl:choose>
			<xsl:when test="contains($str,'&#xA;')">
				<xsl:value-of select="substring-before($str,'&#xA;')"/>
				<br/>
				<xsl:call-template name="lf2br">
					<xsl:with-param name="str">
						<xsl:value-of select="substring-after($str,'&#xA;')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

	<xsl:attribute-set name="free" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		<xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
	</xsl:attribute-set>

<xsl:template name="txtOut">
	<xsl:param name="name"/>
	<xsl:param name="t"/>
	
	<xsl:choose>
		<xsl:when test="count($t/*)=1">
			<xsl:element name="gmd:{$name}">
				<gco:CharacterString><xsl:value-of select="$t/TXT"/></gco:CharacterString>
			</xsl:element>	
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="gmd:{$name}" use-attribute-sets="free">
				<gco:CharacterString><xsl:value-of select="$t/TXT"/></gco:CharacterString>
				<gmd:PT_FreeText>
					<xsl:for-each select="$t/*[name()!='TXT']">		
		      			<textGroup>
		        			<LocalisedCharacterString locale="#locale-{substring(name(),4)}"><xsl:value-of select="."/></LocalisedCharacterString>
		      			</textGroup>
		    		</xsl:for-each>
				</gmd:PT_FreeText>
			</xsl:element>		
		</xsl:otherwise>	
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>
