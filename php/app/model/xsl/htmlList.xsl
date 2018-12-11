<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:php="http://php.net/xsl" 
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml/3.2"   
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:gco="http://www.isotc211.org/2005/gco" >
<xsl:output method="html"/>
	
	<!-- obalená věta -->
	<xsl:template match="rec">
		<div class="rec" id="r-{position()}" itemscope="itemscope" itemtype="http://schema.org/GeoShape">
			<xsl:variable name="ext" select="*/gmd:identificationInfo//gmd:EX_GeographicBoundingBox"/>
			<meta itemprop="box" id="i-{position()}" content="{$ext/gmd:westBoundLongitude} {$ext/gmd:southBoundLatitude} {$ext/gmd:eastBoundLongitude} {$ext/gmd:northBoundLatitude}"/>
			<!-- ikonky vpravo -->
			<div class="icons">	  		
				<xsl:if test="*/gmd:identificationInfo/*/srv:serviceType/*='download'">
					<a href="{$mickaURL}/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;id={*/gmd:fileIdentifier}&amp;language={$LANGUAGE}&amp;outputSchema=http://www.w3.org/2005/Atom" target="_blank" data-tooltip="tooltip" data-original-title="Atom"><i class="fa fa-feed fa-fw"></i></a>
				</xsl:if>
		  		<xsl:variable name="wmsURL" select="*/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*[contains(protocol/*,'WMS') or contains(gmd:linkage/*,'WMS')]/gmd:linkage/*"/>		  		
			  	<xsl:if test="string-length($wmsURL)>0">
			  		<xsl:choose>
			  			<xsl:when test="contains($wmsURL,'?')">
			    			<a class='map' href="{$viewerURL}{substring-before($wmsURL,'?')}" data-tooltip="tooltip" target="wmsviewer" title="{$msg[@eng='map']}"><i class="fa fa-map-o fa-fw"></i></a>
			  			</xsl:when>
			  			<xsl:otherwise>
			  				<a class='map' href="{$viewerURL}{$wmsURL}" target="wmsviewer" data-tooltip="tooltip" data-original-title="{$msg[@eng='map']}"><i class="fa fa-map-o fa-fw"></i></a>
			  			</xsl:otherwise>
			  		</xsl:choose>
			  	</xsl:if>
				<!-- <a href="?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;id={@uuid}&amp;language={$lang}&amp;format=text/html" class="basic" title="{$msg[@eng='basicMetadata']}"><i class="fa fa-map fa-fw"></i></a>
				<a href="?ak=detailall&amp;language={$lang}&amp;uuid={@uuid}" class="full" title="{$msg[@eng='fullMetadata']}"></a><xsl:text> </xsl:text> -->
				<xsl:if test="@edit=1">
					<xsl:if test="@md_standard=0 or @md_standard=10">
						<a href="record/valid/{@uuid}" class="valid{@valid}" data-tooltip="tooltip" data-original-title="{$msg[@eng='validate']}" target="_blank"><xsl:choose>
						<xsl:when test="@valid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
						<xsl:when test="@valid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
						<xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
						</xsl:choose></a>
					</xsl:if>					
					<a href="record/edit/{@uuid}" class="edit" data-tooltip="tooltip" data-original-title="{$msg[@eng='edit']}"><i class="fa fa-pencil fa-fw"></i></a>				
					<a href="record/clone/{@uuid}" class="copy" data-tooltip="tooltip" data-original-title="{$msg[@eng='clone']}"><i class="fa fa-clone fa-fw"></i></a>				
					<a href="javascript: micka.confirmURL(HS.i18n('Delete record')+'?', '{$mickaURL}record/delete/{@uuid}');" class="delete" data-tooltip="tooltip" data-original-title="{$msg[@eng='delete']}"><i class="fa fa-trash fa-fw"></i></a>				
				</xsl:if>
				<xsl:if test="@md_standard=0 or @md_standard=10">
					<a href="{$mickaURL}/csw?service=CSW&amp;request=GetRecordById&amp;id={@uuid}&amp;outputschema=http://www.w3.org/ns/dcat%23" class="rdf" target="_blank" data-tooltip="tooltip" data-original-title="Geo-DCAT RDF"><i class="fa fa-cube fa-fw"></i></a>
				</xsl:if>
				
                <a href="record/xml/{@uuid}" class="xml" target="_blank" data-tooltip="tooltip" data-original-title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
		
				<xsl:if test="$CB">
					<xsl:text> </xsl:text>
					<a href="javascript:md_callBack('{$CB}', '{@uuid}');" class='callback'></a>
				</xsl:if>
			</div>		
			<xsl:apply-templates/>
		</div>	
	</xsl:template>

	<xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata">
	  	<xsl:variable name="mdlang" select="gmd:language/*/@codeListValue"/>
	    <xsl:variable name="hlevel" select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
    	<xsl:variable name="public"><xsl:if test="../@data_type=1"> public</xsl:if></xsl:variable>
		<!-- nadpis -->
		<div class="title{$public}">
			<a href="record/basic/{../@uuid}" class="t" title="{$cl/updateScope/value[@name=$hlevel]/*[name()=$lang]}">
				<xsl:call-template name="showres">
					<xsl:with-param name="r" select="$hlevel"/>
					<xsl:with-param name="class" select="'fa-lg'"/>
				</xsl:call-template>
			  	<xsl:call-template name="multi">
			    	<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
			    	<xsl:with-param name="lang" select="$lang"/>
			    	<xsl:with-param name="mdlang" select="$mdlang"/>
			  	</xsl:call-template> 
			</a> 
			 <xsl:if test="gmd:hierarchyLevelName/*='http://geoportal.gov.cz/inspire'"><span class="for-inspire" title="{$msg[@eng='forInspire']}"></span></xsl:if>
			
			<br/>
			<!-- <xsl:value-of select="$msg[@eng='Supervisor']"/>: 	
			<a href="mailto:{gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*}">
				<xsl:value-of select="gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"/>
			</a>  -->
		
		</div>	
  
		<!-- abstract -->
		<xsl:variable name="abold">
			<xsl:if test="../@data_type=1">-pub</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="abstr">
			<xsl:call-template name="multi">
		   		<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
		   		<xsl:with-param name="lang" select="$lang"/>
		   		<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>
		</xsl:variable>  	 

		<div class="abstract{$abold}">
			<xsl:copy-of select="substring($abstr,0,512)"/>
			<xsl:if test="string-length($abstr) &gt; 512">...</xsl:if>
		</div>

		<!-- metadata contact -->
		
		<div class="bbar">
			<xsl:if test="../@edit=1">
				<xsl:variable name="publ">public<xsl:value-of select="../@data_type"/></xsl:variable>
				<span class="{$publ}"><xsl:value-of select="$msg[@eng=$publ]"/><xsl:text>, </xsl:text></span>
					<!-- <b><xsl:value-of select="../@create_user"/></b> -->
				
				<!--<xsl:call-template name="multi">
			   		 <xsl:with-param name="el" select="gmd:contact[1]/*/gmd:organisationName"/>
			   		<xsl:with-param name="lang" select="$lang"/>
			   		<xsl:with-param name="mdlang" select="$mdlang"/>
			  	</xsl:call-template>-->
		  	</xsl:if>
			<xsl:if test="gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName">
				<xsl:value-of select="$msg[@eng='Metadata Contact']"/>:
				<a href="mailto:{gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*}">
					<xsl:value-of select="gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:individualName"/>
				</a>
				<xsl:text>, </xsl:text>							
			</xsl:if>
			<xsl:value-of select="$msg[@eng='Date Stamp']"/>: <xsl:value-of select="php:function('drawDate', substring-before(../@last_update_date, ' '), $lang)"/>
		</div>
	</xsl:template>

	<!-- DC -->
	<xsl:template match="csw:Record"> 
		<meta itemprop="box" id="i-{position()}" content="{ows:BoundingBox/ows:LowerCorner} {ows:BoundingBox/ows:UpperCorner}"/>		
	  	<div class="title">
            <xsl:call-template name="showres">
                <xsl:with-param name="r" select="'dc'"/>
                <xsl:with-param name="class" select="'fa-lg'"/>
            </xsl:call-template>        
			<a href="record/basic/{../@uuid}" class="t">	     
	     		<xsl:value-of select="dc:title"/>
	    	</a> 
	  	</div>
	  	<div class="abstract"><xsl:value-of select="dct:abstract" /></div>
		<div class="bbar">
			<xsl:value-of select="$msg[@eng='Date Stamp']"/>: <xsl:value-of select="substring-before(../@last_update_date, ' ')"/>			
		</div>
	</xsl:template>

	<!-- FC -->
	<xsl:template match="gfc:FC_FeatureCatalogue" xmlns:gfc="http://www.isotc211.org/2005/gfc" xmlns:gmx="http://www.isotc211.org/2005/gmx">
	 	<xsl:variable name="mdlang" select="../@lang"/>

	  	<div class="title">
			<a href="record/basic/{../@uuid}" class="t" title="{$cl/updateScope/value[@name='fc']/*[name()=$lang]}">
				<xsl:call-template name="showres">
					<xsl:with-param name="r" select="'fc'"/>
					<xsl:with-param name="class" select="'fa-lg'"/>
				</xsl:call-template>

				<xsl:call-template name="multi">
			   		<xsl:with-param name="el" select="gmx:name"/>
			   		<xsl:with-param name="lang" select="$lang"/>
			   		<xsl:with-param name="mdlang" select="$mdlang"/>
			  	</xsl:call-template> 
			</a> 
	  	</div>
	  	<div class="abstract">
			<xsl:call-template name="multi">
		   		<xsl:with-param name="el" select="gmx:scope"/>
		   		<xsl:with-param name="lang" select="$lang"/>
		   		<xsl:with-param name="mdlang" select="$mdlang"/>
		  	</xsl:call-template>
		</div>
		<div class="bbar">
			<xsl:if test="../@edit=1">
				<xsl:variable name="publ">public<xsl:value-of select="../@data_type"/></xsl:variable>
				<span class="{$publ}"><xsl:value-of select="$msg[@eng=$publ]"/><xsl:text>, </xsl:text></span>
			<xsl:value-of select="$msg[@eng='Metadata Contact']"/>:
			<a href="mailto:{gfc:producer/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/*}"><xsl:value-of select="gfc:producer/*/gmd:individualName"/></a>
			<xsl:text>, </xsl:text> 
		  	</xsl:if>
			<xsl:value-of select="$msg[@eng='Date Stamp']"/>: <xsl:value-of select="substring-before(../@last_update_date, ' ')"/>			
		</div>
	</xsl:template>

</xsl:stylesheet>