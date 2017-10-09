<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml/3.2" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:exsl="http://exslt.org/common"
    xmlns:php="http://php.net/xsl"
    extension-element-prefixes="exsl"    
>
<xsl:output method="html" encoding="utf-8"/>
<xsl:param name="lang"/>

<!-- GLOBAL VARIABLES -->
<xsl:variable name="codeLists" select="document('../../xsl/codelists.xml')/map" />
<xsl:variable name="labels" select="document(concat('labels-', $lang, '.xml'))/labels" />

<!-- vyplni select box(y) -->
<xsl:template name="sel">
	<xsl:param name="name"/>
	<xsl:param name="value"/>
	<xsl:param name="codes"/>
	<xsl:param name="title"/>
	<xsl:param name="multi"/>
	<xsl:param name="mand"/>
	
	<!-- prazdna hodnota -->
	<xsl:if test="not($value)">
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
				<span class="duplicate"><i class="fa fa-clone fa-lg"></i></span>
			</xsl:if>
		</div>
	</xsl:if>
	
	<!-- cyklus pres vsechny hodnoty XML -->
	<xsl:for-each select="$value">
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
	<xsl:param name="title"/>
	<xsl:param name="codeLists"/>
	<xsl:param name="valid"/>
	<xsl:param name="langs"/>
	<xsl:param name="role" select="'role'"/>
	
	<!-- validace --> 

	<fieldset>
        <div class="row">
            <xsl:call-template name="drawLabel">
                <xsl:with-param name="name" select="$name"/>
                <xsl:with-param name="class" select="'mand'"/>
                <xsl:with-param name="dupl" select="1"/>
            </xsl:call-template>
        </div>        
		<xsl:variable name="getParty">
		  <xsl:if test="$publisher=1">getParty(this);</xsl:if>
		</xsl:variable>

        <!--xsl:call-template name="drawInput">
            <xsl:with-param name="path" select="concat($name,'-individualName[]')"/>
            <xsl:with-param name="name" select="'individualName'"/>
            <xsl:with-param name="value" select="$root/*/gmd:individualName"/>
            <xsl:with-param name="class" select="'inp2'"/>
            <xsl:with-param name="valid" select="$valid"/>
        </xsl:call-template-->
        
        <div class="row">
            <xsl:call-template name="drawLabel">
                <xsl:with-param name="name" select="'individualName'"/>
                <xsl:with-param name="valid" select="$valid"/>
                <xsl:with-param name="class" select="'inp2'"/>
            </xsl:call-template>
            <div class="col-xs-12 col-md-8">
                <xsl:variable name="nc">
                <xsl:choose>
                    <xsl:when test="$root/*/gmd:individualName/*/@xlink:href">
                        <xsl:value-of select="$root/*/gmd:individualName/*/@xlink:href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$root/*/gmd:individualName/*"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:variable>
                <select class="person sel2" name="{concat($name,'-individualName[]')}" data-tags="true" data-allow-clear="true" data-placeholder="zodpovědná osoba" data-ajax--url="../../suggest/mdcontacts?format=json">
                    <option value="{$nc}"><xsl:value-of select="$root/*/gmd:individualName/*"/></option>
                </select>
                <input class="hperson" type="hidden" name="{concat($name,'-individualNameTxt[]')}" value="{$root/*/gmd:individualName/*}"/>
            </div>
		</div>
        
		<xsl:choose>
            <xsl:when test="$publisher=1">
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="path" select="concat($name,'-organisationName[]')"/>
                    <xsl:with-param name="name" select="'organisationName'"/>
                    <xsl:with-param name="value" select="$root/*/gmd:organisationName"/>
                    <xsl:with-param name="class" select="'inpS mandatory inp2'"/>
                    <xsl:with-param name="action" select="'getParty(this)'"/>
                    <xsl:with-param name="langs" select="$langs"/>
                    <xsl:with-param name="valid" select="$valid"/>
                    <xsl:with-param name="req" select="1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="drawInput">
                    <xsl:with-param name="path" select="concat($name,'-organisationName[]')"/>
                    <xsl:with-param name="name" select="'organisationName'"/>
                    <xsl:with-param name="value" select="$root/*/gmd:organisationName"/>
                    <xsl:with-param name="class" select="'inpS mandatory inp2'"/>
                    <xsl:with-param name="langs" select="$langs"/>
                    <xsl:with-param name="valid" select="$valid"/>
                    <xsl:with-param name="req" select="1"/>
                </xsl:call-template>    
            </xsl:otherwise>
        </xsl:choose>	

		<!-- 

		<div><label>Osoba</label><input class="inp inpS" name="{concat($name,'_',$i,'_individualName_')}" value="{$root/*/gmd:individualName/gco:CharacterString}"/></div>
		<div><label>Funkce</label><input class="inp inpSS" name="{concat($name,'_',$i,'_positionName_')}" value="{$root/*/gmd:position/gco:CharacterString}" /></div>
	 	-->

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'-deliveryPoint[]')"/>
		  	<xsl:with-param name="name" select="'deliveryPoint'"/>
			<xsl:with-param name="value" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/>
			<xsl:with-param name="class" select="'inpS inp2'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'-city[]')"/>
		  	<xsl:with-param name="name" select="'city'"/>
			<xsl:with-param name="value" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:city"/>
			<xsl:with-param name="class" select="'inpS inp2'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'-postalCode[]')"/>
		  	<xsl:with-param name="name" select="'postalCode'"/>
			<xsl:with-param name="value" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/>
			<xsl:with-param name="class" select="'inpSS inp2'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'-country[]')"/>
		  	<xsl:with-param name="name" select="'country'"/>
			<xsl:with-param name="value" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:country"/>
			<xsl:with-param name="class" select="'inpSS inp2'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'-phone[]')"/>
		  	<xsl:with-param name="name" select="'phone'"/>
			<xsl:with-param name="value" select="$root/*/gmd:contactInfo/*/gmd:phone/*/gmd:voice"/>
			<xsl:with-param name="multi" select="2"/>
			<xsl:with-param name="class" select="'inpSS inp2'"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'-email[]')"/>
		  	<xsl:with-param name="name" select="'email'"/>
			<xsl:with-param name="value" select="$root/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/>
			<xsl:with-param name="multi" select="2"/>
            <xsl:with-param name="type" select="'email'"/>
			<xsl:with-param name="class" select="'mandatory inp2'"/>
            <xsl:with-param name="req" select="1"/>
		</xsl:call-template>

		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="path" select="concat($name,'-www[]')"/>
		  	<xsl:with-param name="name" select="'www'"/>
			<xsl:with-param name="value" select="$root/*/gmd:contactInfo/*/gmd:onlineResource/*/gmd:linkage"/>
			<xsl:with-param name="multi" select="2"/>
            <xsl:with-param name="type" select="'plain'"/>
			<xsl:with-param name="class" select="'inp2'"/>
		</xsl:call-template>
		
		<xsl:call-template name="drawInput">
		  	<xsl:with-param name="name" select="$role"/>
		  	<xsl:with-param name="path" select="concat($name,'-role[]')"/>
			<xsl:with-param name="value" select="$root/*/gmd:role/*/@codeListValue"/>
			<xsl:with-param name="codes" select="'role'"/>
			<xsl:with-param name="class" select="'short inp2'"/>
			<xsl:with-param name="req" select="1"/>
		</xsl:call-template>		  	
        
	</fieldset>

</xsl:template>


<!-- VYPISE JEDEN RADEK - INPUT -->
<xsl:template name="drawInput">
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
	<xsl:param name="langs" select="0"/>
	<xsl:param name="req" select="''"/>
	<xsl:param name="tags" select="0"/>
    <xsl:param name="placeholder" select="''"/>
    <xsl:param name="attr" select="'uri'"/>
	
	<!-- class pro label -->
	<xsl:variable name="lclassI">
		<xsl:choose>
			<xsl:when test="contains($class,'mandatory') or $req=1"> mand</xsl:when>
			<xsl:when test="contains($class,'cond')"> cond</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$lclass!=''"><xsl:text> </xsl:text><xsl:value-of select="$lclass"/></xsl:if>
	</xsl:variable>

    <xsl:variable name="flag"><xsl:if test="$langs">txt <xsl:value-of select="/*/gmd:language/*/@codeListValue"/></xsl:if></xsl:variable>
    
	<div id="{$path}" class="row">
		<xsl:if test="$labels/msg[@name=$name]/label!=''">
            <div class="col-xs-12 col-md-4">
                <label for="{$name}" class="{$class}{$lclassI}" id="V-{$valid}" data-tooltip="tooltip" data-original-title="{$labels/msg[@name=$name]/help}">
                    <xsl:value-of select="$labels/msg[@name=$name]/label"/>
                </label>
            </div>
		</xsl:if>
		
		<xsl:variable name="cl"><xsl:choose>
			<xsl:when test="$langs">lang-<xsl:value-of select="$mlang"/></xsl:when>
		</xsl:choose></xsl:variable>

		<xsl:variable name="TXT"><xsl:choose>
			<xsl:when test="$langs">[TXT]</xsl:when>
		</xsl:choose></xsl:variable>
        
        <xsl:variable name="pth"><xsl:value-of select="$path"/><xsl:if test="$multi &gt; 1">[]</xsl:if></xsl:variable>
        
		<div class="col-xs-12 col-md-8 {$cl}">
			<xsl:choose>

			<!-- TEXAREA -->
			<xsl:when test="$type='textarea'">
                <textarea name="{$path}{$TXT}" class="form-control {$flag} {$class}">
                    <xsl:if test="$req">
                        <xsl:attribute name="required">required</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="normalize-space($value/*)"/>
                </textarea>
			</xsl:when>

			<!-- INPUT - BOOELAN -->
			<xsl:when test="$type='boolean'">
				<xsl:choose>
					<xsl:when test="$value='1' or value='true'">
						<input type="checkbox" name="{$pth}" checked="true">
						<xsl:if test="$req">
							<xsl:attribute name="required">required</xsl:attribute>
						</xsl:if>
						</input>
					</xsl:when>
					<xsl:otherwise>
						<input type="checkbox" name="{$pth}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<!-- INPUT - plain -->
			<xsl:when test="$type='plain'">
				<input name="{$pth}" class="form-control {$class}" value="{$value}">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- INPUT - email -->
			<xsl:when test="$type='email'">
				<input name="{$pth}" class="form-control {$class}" value="{$value}" type="email">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- DATE  -->
			<xsl:when test="$type='date'">
				<input name="{$pth}" class="form-control D {$class}" value="{php:function('iso2date', string($value),$lang)}" data-provide="datepicker" xpattern="^(19|20)\d\d([-](0[1-9]|1[012]))?([-](0[1-9]|[12][0-9]|3[01]))?$">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- REAL -->
			<xsl:when test="$type='real'">
				<input name="{$pth}" class="form-control num short {$class}" value="{$value}" pattern="[-+]?[0-9]*\.?[0-9]*">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- INTEGER -->
			<xsl:when test="$type='integer'">
				<input name="{$pth}" class="form-control num short {$class}" value="{$value}" pattern="[-+]?[0-9]*">
					<xsl:if test="$req">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</input>			
			</xsl:when>

			<!-- SELECT pres code -->
			<xsl:when test="$type='cselect'">
				<select id="{$name}-sel" name="{$pth}" class="sel2 {$class}">
                   <xsl:if test="$req">
                        <xsl:attribute name="required">required</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$multi &gt; 1">
                        <xsl:attribute name="multiple">true</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$multi=0">
                        <xsl:attribute name="data-allow-clear">true</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$tags=1">
                        <xsl:attribute name="data-tags">true</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="data-placeholder">
                        <xsl:choose>
                        <xsl:when test="$placeholder">
                            <xsl:value-of select="$placeholder"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="$labels/msg[@name='sel']/*"/> ...</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="string-length($value)=0"><option></option></xsl:if>
					<!-- cyklus pres ciselnik -->
					<xsl:for-each select="$codelist/*[name()=$codes]/value">
			  			<xsl:choose>
			  				<xsl:when test="@code=normalize-space($value)">
			  					<option value="{@code}" title="{*[name()=$lang]/@qtip}" selected="selected"><xsl:value-of select="*[name()=$lang]"/></option>
			  				</xsl:when>
			  				<xsl:otherwise>
			  					<option value="{@code}" title="{*[name()=$lang]/@qtip}"><xsl:value-of select="*[name()=$lang]"/></option>
			  				</xsl:otherwise>
			  			</xsl:choose>		
			  		</xsl:for-each>
				</select>		
			</xsl:when>
			
			<!-- SELECT -->
			<xsl:when test="$codes!=''">
                
                <select id="{$name}-sel" name="{$pth}" class="sel2 {$class}">
                    <xsl:if test="$req">
                        <xsl:attribute name="required">required</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$multi &gt; 1">
                        <xsl:attribute name="multiple">true</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$multi=0">
                        <xsl:attribute name="data-allow-clear">true</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$tags=1">
                        <xsl:attribute name="data-tags">true</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="data-placeholder">
                        <xsl:choose>
                        <xsl:when test="$placeholder">
                            <xsl:value-of select="$placeholder"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="$labels/msg[@name='sel']/*"/> ...</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <!-- blank value -->
                    <xsl:if test="string-length($value)=0"><option></option></xsl:if>
                    <!-- codelist loop -->
                    <xsl:for-each select="$codeLists/*[name()=$codes]/value">
                        <xsl:variable name="r" select="."/>
                        <xsl:variable name="c">            
                            <xsl:choose>
                                <xsl:when test="$r/@*[name()=$attr]"><xsl:value-of select="$r/@*[name()=$attr]"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="$r/@name"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="exsl:node-set($value)[(*/@xlink:href and */@xlink:href=$c) or normalize-space(.)=$c]">
                                <option value="{$c}" title="{$r/*[name()=$lang]/@qtip}" selected="'selected'"><xsl:value-of select="$r/*[name()=$lang]"/></option>
                            </xsl:when>
                            <xsl:otherwise>
                                <option value="{$c}" title="{$r/*[name()=$lang]/@qtip}"><xsl:value-of select="$r/*[name()=$lang]"/></option>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </select>		
            </xsl:when>

			<!-- INPUT - TEXT -->
			<xsl:otherwise>
                <input name="{$pth}{$TXT}" class="form-control {$flag} {$class}" value="{normalize-space($value/gco:CharacterString|$value/gmx:Anchor)}">
                    <xsl:if test="$req">
                        <xsl:attribute name="required">required</xsl:attribute>
                    </xsl:if>
                </input>
			</xsl:otherwise>
				
		</xsl:choose>

		
		<!-- akcni tlacitka -->
		<xsl:if test="$action">
			<span class="open" title="{$labels/msg[@name='fromList']/label}" onclick="{$action};"></span>
		</xsl:if>	
		<xsl:if test="$multi &gt; 2">
			<span class="duplicate"><i class="fa fa-clone fa-lg"></i></span>
		</xsl:if>	

		<xsl:choose>
			<xsl:when test="$langs and $type='textarea'">
				<xsl:for-each select="$langs">
					<xsl:variable name="pos" select="position()"/>
                    <textarea class="form-control txt {*/gmd:languageCode/*/@codeListValue} {$class}" name="{$pth}[{*/gmd:languageCode/*/@codeListValue}]">
                        <xsl:if test="$value"><xsl:value-of select="$value/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',$langs[$pos]/*/@id)]"/></xsl:if>
                    </textarea>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$langs">
				<xsl:for-each select="$langs">
					<xsl:variable name="pos" select="position()"/>
                    <xsl:choose>
                        <xsl:when test="$value">
                            <input name="{$pth}[{*/gmd:languageCode/*/@codeListValue}]" class="form-control txt {*/gmd:languageCode/*/@codeListValue} {$class}X" value="{$value/gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=concat('#',$langs[$pos]/*/@id)]}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <input name="{$pth}[{*/gmd:languageCode/*/@codeListValue}]" class="form-control txt {*/gmd:languageCode/*/@codeListValue} {$class}X" value=""/>
                        </xsl:otherwise>
                    </xsl:choose>	
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
		</div>
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
		<legend id="{$id}" class="{$class}" data-tooltip="tooltip" data-original-title="{$labels/msg[@name=$name]/help}">
			<xsl:value-of select="$labels/msg[@name=$name]/label"/>	
		</legend>
	</xsl:if>
</xsl:template>

<xsl:template name="drawLabel">
	<xsl:param name="name"/>
	<xsl:param name="class" select="''"/>
	<xsl:param name="valid"/>
    <xsl:param name="dupl" select="0"/>
	<xsl:if test="$labels/msg[@name=$name]/label">
        <div class="col-xs-12 col-md-4">
            <label for="{$name}" class="{$class}" id="V-{$valid}" data-tooltip="tooltip" data-original-title="{$labels/msg[@name=$name]/help}">
                <xsl:value-of select="$labels/msg[@name=$name]/label"/>
            </label>
            <xsl:if test="$dupl=1">
                <span class="duplicate"></span>
            </xsl:if>
        </div>
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

<!-- zobrazeni multilingualiniho textu -->
<xsl:template name="multiText">
    <xsl:param name="el"/>
    <xsl:param name="lang"/>
    <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[contains(@locale,$lang)]"/>		
    <xsl:choose>
        <xsl:when test="string-length($txt)>0">
            <xsl:value-of select="$txt"/>
         </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$el/*"/>
        </xsl:otherwise>
    </xsl:choose>
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
		<xsl:when test="count($t/*)=0">
			<xsl:element name="gmd:{$name}">
				<gco:CharacterString><xsl:value-of select="$t"/></gco:CharacterString>
			</xsl:element>	
		</xsl:when>
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
		      			<gmd:textGroup>
		        			<gmd:LocalisedCharacterString locale="#locale-{name()}"><xsl:value-of select="."/></gmd:LocalisedCharacterString>
		      			</gmd:textGroup>
		    		</xsl:for-each>
				</gmd:PT_FreeText>
			</xsl:element>		
		</xsl:otherwise>	
	</xsl:choose>
</xsl:template>

<xsl:template name="uriOut">
	<xsl:param name="name"/>
	<xsl:param name="codes"/>
	<xsl:param name="t"/>
    <xsl:param name="attrib" select="''"/>
    <xsl:param name="lattrib" select="''"/>
	
    <xsl:variable name="row" select="$codes/value[@uri=normalize-space($t)]"/>
    <xsl:variable name="n">
        <xsl:choose>
            <xsl:when test="contains($name, ':')"><xsl:value-of select="$name"/></xsl:when>
            <xsl:otherwise>gmd:<xsl:value-of select="$name"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$n}">
        <xsl:choose>
            <xsl:when test="$row">               
                <gmx:Anchor xlink:href="{$t}">
                    <xsl:choose>
                        <xsl:when test="$attrib">
                            <xsl:value-of select="$row/@*[name()=$attrib]"/>
                        </xsl:when>
                        <xsl:when test="$lattrib">
                            <xsl:value-of select="$row/*[name()=$lang]/@*[name()=$lattrib]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$row/*[name()=$lang]"><xsl:value-of select="$row/*[name()=$lang]"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="$row/*[name()='eng']"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmx:Anchor>
            </xsl:when>
            <xsl:otherwise>
                <gco:CharacterString><xsl:value-of select="$t"/></gco:CharacterString>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:element>
</xsl:template>

</xsl:stylesheet>
