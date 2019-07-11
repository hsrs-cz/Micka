<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:php="http://php.net/xsl" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
	xmlns:ows="http://www.opengis.net/ows" 
	xmlns:srv="http://www.isotc211.org/2005/srv" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  	xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0"    
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:gml32="http://www.opengis.net/gml/3.2" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:gfc="http://www.isotc211.org/2005/gfc" 
	xmlns:gco="http://www.isotc211.org/2005/gco"> 
	<xsl:output method="html"/>
	
	<xsl:variable name="apos">\'</xsl:variable>
	<xsl:variable name="msg" select="document(concat('client/labels-', $lang, '.xml'))/messages/msg"/>
	<xsl:variable name="cl" select="document('../../config/codelists.xml')/map"/>
	<xsl:variable name="mdlang" select="*/gmd:language/gmd:LanguageCode/@codeListValue"/>
	<xsl:include href="client/common_cli.xsl" />

	<xsl:template match="/*">
		<div class="container panel panel-default" vocab="http://www.w3.org/ns/dcat#" typeof="http://www.w3.org/2000/01/rdf-schema#Resource">
			<div class="row content">

                <div id="sidebar" class="container col-xs-12 col-md-4">
                    <div class="panel-body" style="padding:3px;">
                        <div  id="overmap"></div>
                    </div>	
                </div>
                
                <div id="results" class="container col-xs-12 col-md-8">
                    <xsl:if test="count(*)=0">
                        <h1><xsl:value-of select="$msg[@eng='Bad']"/></h1>
                    </xsl:if>
                    <xsl:apply-templates select="rec/gmd:MD_Metadata|rec/gmi:MI_Metadata"/>
                    <xsl:apply-templates select="rec/gfc:FC_FeatureCatalogue"/>
                    <xsl:apply-templates select="rec/csw:Record"/>
                    <xsl:apply-templates select="//csw:GetRecordByIdResponse/*"/>
                    <xsl:if test="@read=1">
                        <a class="go-back" href="javascript:history.back();" title="{$msg[@eng='Back']}"/>
                    </xsl:if>
                </div>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
	xmlns:ows="http://www.opengis.net/ows" 
	xmlns:srv="http://www.isotc211.org/2005/srv" 
    xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0"  
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:gco="http://www.isotc211.org/2005/gco">
		<xsl:variable name="hlevel" select="gmd:hierarchyLevel/*/@codeListValue"/>
        <xsl:variable name="fid" select="gmd:fileIdentifier/*"/>
		<xsl:variable name="srv">
			<xsl:choose>
				<xsl:when test="name(gmd:identificationInfo/*)='srv:SV_ServiceIdentification'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

	<!--h2 class="noprint"-->
	<ol class="breadcrumb">
		<li class="active"><a href="{$mickaURL}/" tooltip="tooltip" data-tooltip="tooltip" data-original-title="{$msg[@eng='List']}" data-container="body" data-placement="bottom"><i class="fa fa-arrow-left fa-lg"></i></a></li>
		<li><xsl:value-of select="$msg[@eng='basicMetadata']"/></li>
		<li>		
			<xsl:if test="../@read=1">
				<a href="../full/{../@uuid}" class="icons" data-tooltip="tooltip" data-original-title="{$msg[@eng='fullMetadata']}">
					<xsl:value-of select="$msg[@eng='fullMetadata']"/></a>
			</xsl:if>
		</li>
		<div class="icons">
		  	<xsl:variable name="wmsURL" select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*[contains(gmd:protocol/*,'WMS') or contains(gmd:linkage/*,'WMS')]/gmd:linkage/*"/>		  		
			<xsl:if test="gmd:identificationInfo/*/srv:serviceType/*='download'">
				<a href="{$mickaURL}/csw?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;id={$fid}&amp;language={$LANGUAGE}&amp;outputSchema=http://www.w3.org/2005/Atom" target="_blank" data-tooltip="tooltip" data-original-title="Atom"><i class="fa fa-feed fa-fw"></i></a>
			</xsl:if>
			<xsl:if test="string-length($wmsURL)>0">
				<xsl:choose>
					<xsl:when test="contains($wmsURL,'?')">
			   			<a class='map' href="{$viewerURL}{substring-before($wmsURL,'?')}" target="wmsviewer" data-tooltip="tooltip" data-original-title="{$msg[@eng='map']}"><i class="fa fa-map-o fa-fw"></i></a>		  				
					</xsl:when>
					<xsl:otherwise>
						<a class='map' href="{$viewerURL}{$wmsURL}" target="wmsviewer" data-tooltip="tooltip" data-original-title="{$msg[@eng='map']}"><i class="fa fa-map-o fa-fw"></i></a>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="../@edit=1">
				<a href="../valid/{../@uuid}" class="valid{../@valid}" data-tooltip="tooltip" data-original-title="{$msg[@eng='validate']}" target="_blank"><xsl:choose>
						<xsl:when test="../@valid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
						<xsl:when test="../@valid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
						<xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
					</xsl:choose></a>
				<a href="../edit/{../@uuid}?f=basic" class="edit" data-tooltip="tooltip" data-original-title="{$msg[@eng='edit']}"><i class="fa fa-pencil fa-fw"></i></a>				
				<a href="../clone/{../@uuid}" class="copy" data-tooltip="tooltip" data-original-title="{$msg[@eng='clone']}"><i class="fa fa-clone fa-fw"></i></a>				
				<a href="javascript: micka.confirmURL(HS.i18n('Delete record')+'?', '../delete/{../@uuid}');" class="delete" data-tooltip="tooltip" data-original-title="{$msg[@eng='delete']}"><i class="fa fa-trash fa-fw"></i></a>				
			</xsl:if>
			<xsl:if test="../@read=1">
				<xsl:if test="../@md_standard=0 or ../@md_standard=10">
					<a href="{$mickaURL}/csw?service=CSW&amp;request=GetRecordById&amp;id={../@uuid}&amp;outputschema=http://www.w3.org/ns/dcat%23" class="rdf" target="_blank" data-tooltip="tooltip" data-original-title="Geo-DCAT RDF"><i class="fa fa-cube fa-fw"></i></a>
				</xsl:if>
				<a href="../xml/{../@uuid}" class="xml" target="_blank" data-tooltip="tooltip" data-original-title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
			</xsl:if>
		</div>			
	</ol>

	<h1 title="{$cl/updateScope/value[@name=$hlevel]/*[name()=$lang]}" property="http://purl.org/dc/terms/title">
		<xsl:call-template name="showres">
			<xsl:with-param name="r" select="$hlevel"/>
		</xsl:call-template>

		<xsl:call-template name="multi">
			<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
			<xsl:with-param name="lang" select="$lang"/>
			<xsl:with-param name="mdlang" select="$mdlang"/>
		</xsl:call-template>
		<xsl:if test="gmd:hierarchyLevelName/*='http://geoportal.gov.cz/inspire'"><span class="for-inspire" title="{$msg[@eng='forInspire']}"></span></xsl:if>
	</h1>
	
	<div class="report">
		<div class="micka-row content">
			<label><xsl:value-of select="$msg[@eng='Abstract']"/></label>
			<div class="c" property="http://purl.org/dc/terms/description">
				<xsl:call-template name="multi">
					<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
					<xsl:with-param name="lang" select="$lang"/>
					<xsl:with-param name="mdlang" select="$mdlang"/>
				</xsl:call-template>
			</div>
		</div>

        <xsl:if test="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*">
            <div class="micka-row">
                <label><xsl:value-of select="$msg[@eng='Browse Graphic']"/></label>
                <div class="c">
                    <div><img src="{gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*}"/></div>
                    <div>
                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileDescription"/>
                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                            <xsl:with-param name="mdlang" select="$mdlang"/>
                        </xsl:call-template>
                    </div>
                </div>
            </div>
        </xsl:if>	
        
        <div class="micka-row" rel="http://www.w3.org/1999/02/22-rdf-syntax-ns#type">
            <label><xsl:value-of select="$msg[@eng='Type']"/></label>
            <xsl:variable name="res">
                <xsl:choose>
                    <xsl:when test="$hlevel='service'">Catalog</xsl:when>
                    <xsl:otherwise>Dataset</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <div class="c" resource="http://www.w3.org/ns/dcat#{$res}">
                <xsl:value-of select="$cl/updateScope/value[@name=$hlevel]/*[name()=$lang]"/>
                <xsl:if test="gmd:hierarchyLevelName != ''">
                - <xsl:value-of select="gmd:hierarchyLevelName"/>
                </xsl:if>
            </div>
        </div>


        <div class="micka-row" rel="http://www.w3.org/ns/dcat#distribution">
            <label><xsl:value-of select="$msg[@eng='Resource Locator']"/></label>
            <div class="c" typeof="http://www.w3.org/ns/dcat#Distribution">
                <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
                    <!-- temporal solution -->
                    <xsl:variable name="d0">
                        <xsl:call-template name="multi">
                            <xsl:with-param name="el" select="*/gmd:description"/>
                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                            <xsl:with-param name="mdlang" select="$mdlang"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="d" select="php:function('noMime',normalize-space($d0))"/>
                    <xsl:variable name="n" select="*/gmd:name/*/@xlink:href"/>
                    <xsl:variable name="c" select="$cl/linkageName/value[@uri=$n]/*[name()=$lang]"/>
                    <xsl:variable name="label">
                        <xsl:choose>
                            <xsl:when test="$c">
                                <xsl:value-of select="$c"/>
                            </xsl:when>
                            <xsl:when test="*/gmd:name">
                                <xsl:call-template name="multi">
                                    <xsl:with-param name="el" select="*/gmd:name"/>
                                    <xsl:with-param name="lang" select="$LANGUAGE"/>
                                    <xsl:with-param name="mdlang" select="$mdlang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$d">
                                <xsl:value-of select="$d"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="*/gmd:linkage"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <div rel="http://www.w3.org/ns/dcat#accessURL">
                        <xsl:choose>
                            <xsl:when test="contains(*/gmd:protocol, 'DOWNLOAD')">
                                <a href="{*/gmd:linkage}"  target="_blank">
                                    <span style="color:#070; font-size:18px;"><i class="fa fa-download"></i></span><xsl:text> </xsl:text>
                                    <xsl:value-of select="$label"/>
                                </a>	
                            </xsl:when>
                            <xsl:when test="contains(*/gmd:protocol, 'rss')">
                                <a href="{*/gmd:linkage}"  target="_blank">
                                    <span style="color:#ff6600; font-size:18px;"><i class="fa fa-feed"></i></span><xsl:text> </xsl:text>
                                    <xsl:value-of select="$label"/>
                                </a>	
                            </xsl:when>
                            <xsl:when test="contains(*/gmd:protocol/*,'WMS') or contains(*/gmd:linkage/*,'WMS')">
                                <xsl:variable name="label1">
                                    <xsl:choose>
                                        <xsl:when test="*/gmd:name"><xsl:value-of select="$label"/></xsl:when>
                                        <xsl:otherwise><xsl:value-of select="$msg[@eng='showMap']"/></xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="contains(*/gmd:linkage/*,'?')">
                                        <a class='map' resource="{*/gmd:linkage}" href="{$viewerURL}{substring-before(*/gmd:linkage/*,'?')}" target="wmsviewer">
                                            <span style="color:#ff6600; font-size:18px;"><i class="fa fa-map"></i></span><xsl:text> </xsl:text>
                                            <xsl:value-of select="$label1"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a class='map' resource="{*/gmd:linkage}" href="{$viewerURL}{*/gmd:linkage/*}" target="wmsviewer">
                                            <span style="color:#ff6600; font-size:18px;"><i class="fa fa-map"></i></span><xsl:text> </xsl:text>
                                            <xsl:value-of select="$label1"/>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <a resource="{*/gmd:linkage}" href="{*/gmd:linkage}"  target="_blank">
                                    <span style="font-size:18px;"><i class="fa fa-external-link-square"></i></span><xsl:text> </xsl:text>
                                    <xsl:value-of select="$label"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$d and $label != $d">
                            - <xsl:value-of select="$d"/>
                        </xsl:if>
                    </div>
                </xsl:for-each>
            </div>
        </div>

        <div class="micka-row">
            <label><xsl:value-of select="$msg[@eng='Identifier']"/></label>
            <div class="c" property="http://purl.org/dc/terms/identifier">
                <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier">
                    <xsl:choose>
                        <xsl:when test="*/gmd:code/*/@xlink:href">
                            <xsl:value-of select="*/gmd:code/*/@xlink:href"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="*/gmd:codeSpace"/>:<xsl:value-of select="*/gmd:code"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </div>
        </div>

		<xsl:if test="$srv!=1">
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Language']"/></label>
				<div class="c">
					<xsl:for-each select="gmd:identificationInfo/*/gmd:language">
						<xsl:variable name="kod" select="*/@codeListValue"/>
						<xsl:value-of select="$cl/language/value[@code=$kod]/*[name()=$lang]"/>
						<xsl:if test="position()!=last()">, </xsl:if>
					</xsl:for-each>
				</div>
			</div>
			
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Topic category']"/></label>
				<div class="c">
					<xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
						<xsl:variable name="k" select="*"/>
						<xsl:value-of select="$cl/topicCategory/value[@name=$k]/*[name()=$lang]"/>
						<xsl:if test="position()!=last()"><br/></xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="$srv=1">
			<div class="micka-row">
				<label>
					<xsl:value-of select="$msg[@eng='Service Type']"/>
				</label>
				<div class="c">
					<xsl:value-of select="gmd:identificationInfo/*/srv:serviceType"/>
					<xsl:for-each select="gmd:identificationInfo/*/srv:serviceTypeVersion">
						<xsl:text> </xsl:text>
						<xsl:value-of select="."/>
						<xsl:if test="not(position()=last())">,</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>

        <div class="micka-row">
            <label><xsl:value-of select="$msg[@eng='Keywords']"/></label>
            <div class="c">
                <xsl:for-each select="//gmd:descriptiveKeywords[string-length(*/gmd:thesaurusName/*/gmd:title/*)>0]">

                    <xsl:choose>
                        <!-- blbost kvuli CENII -->
                        <xsl:when test="contains(*/gmd:thesaurusName/*/gmd:title/*,'CENIA')">
                            <i><b>GEOPORTAL:</b></i>
                            <xsl:for-each select="*/gmd:keyword">
                                <div style="margin-left:20px;">
                                    <xsl:variable name="k" select="*"/>
                                    <xsl:value-of select="$cl/cenia/value[@name=$k]/*[name()=$lang]"/>
                                </div>
                            </xsl:for-each>
                        </xsl:when>

                        <!-- ISO 19119 -->
                        <xsl:when test="contains(*/gmd:thesaurusName/*/gmd:title/*,'ISO - 19119') or contains(*/gmd:thesaurusName/*/gmd:title/*,'INSPIRE Services')">
                            <i><b>ISO 19119:</b></i>
                            <xsl:for-each select="*/gmd:keyword">
                                <div style="margin-left:20px;">
                                    <xsl:variable name="k" select="*"/>
                                    <a property="http://www.w3.org/ns/dcat#theme" typeof="http://www.w3.org/2000/01/rdf-schema#Resource" resource="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/{$k}" href="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/{$k}" target="_blank">
                                    <xsl:value-of select="$cl/serviceKeyword/value[@name=$k]/*[name()=$lang]"/></a>
                                </div>
                            </xsl:for-each>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:variable name="thesaurus">
                                <xsl:call-template name="multi">
                                    <xsl:with-param name="el" select="*/gmd:thesaurusName/*/gmd:title"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="mdlang" select="$mdlang"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <i><b><xsl:value-of select="$thesaurus"/>:</b></i>
                            <div style="margin-left:20px;">
                            <xsl:for-each select="*/gmd:keyword">
                                    <xsl:variable name="theme">
                                        <xsl:call-template name="multi">
                                            <xsl:with-param name="el" select="."/>
                                            <xsl:with-param name="lang" select="$lang"/>
                                            <xsl:with-param name="mdlang" select="$mdlang"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <xsl:when test="contains(*/@xlink:href, 'inspire.ec.europa.eu/theme')">
                                            <a property="http://www.w3.org/ns/dcat#theme"  typeof="http://www.w3.org/2000/01/rdf-schema#Resource" resource="{./*/@xlink:href}" href="{./*/@xlink:href}" title="{$theme}" target="_blank">
                                                <img src="{$mickaURL}/layout/default/img/inspire/{substring-after(./*/@xlink:href, 'theme/')}.png"/>
                                            </a>
                                            <xsl:text> </xsl:text>
                                        </xsl:when>
                                        <xsl:when test="./*/@xlink:href">
                                            <div>
                                                <a property="http://www.w3.org/ns/dcat#theme" resource="{./*/@xlink:href}" href="{./*/@xlink:href}" title="registry" target="_blank">
                                                    <xsl:choose>
                                                        <xsl:when test="normalize-space($theme)">
                                                            <xsl:value-of select="$theme"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="./*/@xlink:href"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </a>
                                            </div>	
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <div rel="http://www.w3.org/ns/dcat#theme" typeof="http://www.w3.org/2000/01/rdf-schema#Resource">
                                                <span property="http://www.w3.org/2004/02/skos/core#prefLabel"><xsl:value-of select="$theme"/></span>
                                                <span rel="http://www.w3.org/2004/02/skos/core#inScheme" typeof="http://www.w3.org/2004/02/skos/core#ConceptScheme">
                                                    <span content="{$thesaurus}" property="http://purl.org/dc/terms/title"></span>
                                                    <span content="{../../*/gmd:thesaurusName/*/gmd:date/*/gmd:date/*}" property="http://purl.org/dc/terms/issued"></span>
                                                </span>
                                            </div>	
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>

                <xsl:for-each select="//gmd:descriptiveKeywords[string-length(*/gmd:thesaurusName/*/gmd:title/*)=0]">
                    <div>
                        <i><b><xsl:value-of select="$msg[@eng='Free']"/>: </b></i>
                        <div style="margin-left:20px;">
                        <xsl:for-each select="*/gmd:keyword">
                            <xsl:variable name="theme">
                                <xsl:call-template name="multi">
                                    <xsl:with-param name="el" select="."/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="mdlang" select="$mdlang"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="contains(*/@xlink:href, 'inspire.ec.europa.eu/theme')">
                                    <a href="{./*/@xlink:href}" title="{$theme}" target="_blank">
                                        <img src="{$mickaURL}/layout/default/img/inspire/{substring-after(./*/@xlink:href, 'theme/')}.png"/>
                                    </a>
                                    <xsl:text> </xsl:text>
                                </xsl:when>
                                <xsl:when test="./*/@xlink:href">
                                    <div>
                                        <a href="{./*/@xlink:href}" title="registry" target="_blank">
                                            <xsl:choose>
                                                <xsl:when test="normalize-space($theme)">
                                                    <xsl:value-of select="$theme"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="./*/@xlink:href"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                    </div>	
                                </xsl:when>
                                <xsl:otherwise>
                                    <div>
                                        <xsl:value-of select="$theme"/>
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>


            </div>
        </div>

		<div class="micka-row">
			<label><xsl:value-of select="$msg[@eng='Bounding box']"/></label>
			<div class="c" rel="http://purl.org/dc/terms/spatial" typeof="http://www.w3.org/2000/01/rdf-schema#Resource">

				<xsl:for-each select="gmd:identificationInfo/*/*/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
				    <xsl:variable name="x1" select="gmd:westBoundLongitude/*"/>
					<xsl:variable name="y1" select="gmd:southBoundLatitude/*"/>
					<xsl:variable name="x2" select="gmd:eastBoundLongitude/*"/>
					<xsl:variable name="y2" select="gmd:northBoundLatitude/*"/>
				
					<xsl:if test="gmd:westBoundLongitude!=''">
						<span property="http://www.w3.org/ns/locn#geometry" datatype="http://www.opengis.net/ont/geosparql#wktLiteral" content="POLYGON(({$x1} {$y1} {$x1} {$y2} {$x2} {$y2} {$x2} {$y1} {$x1} {$y1}"></span>
						<div id="r-{position()}" itemscope="itemscope" itemtype="http://schema.org/GeoShape">
							<meta itemprop="box" id="i-{position()}" content="{gmd:westBoundLongitude} {gmd:southBoundLatitude} {gmd:eastBoundLongitude} {gmd:northBoundLatitude}"/>
							<xsl:value-of select="gmd:westBoundLongitude/*"/>,
							<xsl:value-of select="gmd:southBoundLatitude/*"/>,
							<xsl:value-of select="gmd:eastBoundLongitude/*"/>,
							<xsl:value-of select="gmd:northBoundLatitude/*"/>
		                </div>
	                </xsl:if>
				</xsl:for-each>
       		</div>
        </div>

        <xsl:if test="gmd:identificationInfo/*/*/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicDescription">
			<div class="micka-row">
                <label><xsl:value-of select="$msg[@eng='Region']"/></label>
                <div class="c" rel="http://purl.org/dc/terms/spatial" typeof="http://www.w3.org/2000/01/rdf-schema#Resource">
                    <xsl:for-each select="gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicDescription">
                        <a href="{gmd:geographicIdentifier/*/gmd:code/*/@xlink:href}" target="_blank"><xsl:value-of select="gmd:geographicIdentifier/*/gmd:code/*"/></a>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
		
        <div class="micka-row">
			<label><xsl:value-of select="$msg[@eng='Date']"/></label>
			<div class="c">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
					<xsl:variable name="k" select="*/gmd:dateType/*/@codeListValue"/>
					<span property="http://purl.org/dc/terms/{$cl/dateType/value[@name=$k]/@dc}" content="{*/gmd:date}" datatype="http://www.w3.org/2001/XMLSchema#date">
						<xsl:value-of select="$cl/dateType/value[@name=$k]/*[name()=$lang]"/>: <xsl:value-of select="php:function('drawDate', string(*/gmd:date), $lang)"/>
					</span>
					<xsl:if test="not(position()=last())">, </xsl:if>
				</xsl:for-each>
			</div>
		</div>

		<xsl:if test="gmd:identificationInfo//gmd:temporalElement">
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Temporal extent']"/></label>
				<div class="c">
					<xsl:for-each select="gmd:identificationInfo//gmd:temporalElement">	
						<div rel="http://purl.org/dc/terms/temporal">
							<xsl:choose>
							<!-- rozsah 1 --> 
							<xsl:when test="string-length(*/gmd:extent/*/gml:beginPosition|*/gmd:extent/*/gml32:beginPosition)>0">
								<div typeof="http://purl.org/dc/terms/PeriodOfTime">
									<span property="http://schema.org/startDate" content="{*//gml:beginPosition|*//gml32:beginPosition}" datatype="http://www.w3.org/2001/XMLSchema#date"></span>
									<span property="http://schema.org/endDate" content="{*//gml:endPosition|*//gml32:endPosition}" datatype="http://www.w3.org/2001/XMLSchema#date"></span>
									<xsl:choose>
										<xsl:when test="*//gml:endPosition|*//gml32:endPosition=9999">
											<xsl:value-of select="$msg[@eng='from']"/><xsl:text> </xsl:text><xsl:value-of select="php:function('drawDate', string(*//gml:beginPosition|*//gml32:beginPosition), $lang)"/>
										</xsl:when>
										<xsl:when test="*//gml:beginPosition|*//gml32:beginPosition=0001">
											<xsl:value-of select="$msg[@eng='to']"/><xsl:text> </xsl:text><xsl:value-of select="php:function('drawDate', string(*//gml:endPosition|*//gml32:endPosition), $lang)"/>								
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="php:function('drawDate', string(*//gml:beginPosition|*//gml32:beginPosition), $lang)"/>
												-
											<xsl:value-of select="php:function('drawDate', string(*//gml:endPosition|*//gml32:endPosition), $lang)"/>
										</xsl:otherwise>
									</xsl:choose>
								</div>
							</xsl:when>
							
							<!-- rozsah 2 stary -->
							<xsl:when test="string-length(*//gml:begin)>0">
								<xsl:value-of select="php:function('drawDate', string(*//gml:begin), $lang)"/> -
		      					<xsl:value-of select="php:function('drawDate', string(*//gml:end), $lang)"/>
							</xsl:when>
							
							<!-- instant -->
							<xsl:when test="string-length(*//gml:timePosition|*//gml32:timePosition)>0">
								<xsl:value-of select="php:function('drawDate', string(*//gml:timePosition|*//gml32:timePosition), $lang)"/>
							</xsl:when>
						</xsl:choose>
						<xsl:if test="not(position()=last())">, </xsl:if>
						</div>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		
		<xsl:if test="gmd:identificationInfo/*/gmd:spatialRepresentationType">
			<div class="micka-row">
				<label>
					<xsl:value-of select="$msg[@eng='Spatial Representation']"/>
				</label>
				<div class="c">
					<xsl:for-each select="gmd:identificationInfo/*/gmd:spatialRepresentationType">
						<xsl:variable name="sr" select="gmd:MD_SpatialRepresentationTypeCode"/>
						<xsl:value-of select="$cl/spatialRepresentationType/value[@name=$sr]/*[name()=$lang]"/>
						<xsl:if test="not(position()=last())">, </xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>

        <xsl:if test="gmd:identificationInfo/*/gmd:purpose">
			<div class="micka-row">
				<label>
					<xsl:value-of select="$msg[@eng='Purpose']"/>
				</label>
				<div class="c">
                    <xsl:call-template name="multi">
                        <xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:purpose"/>
                        <xsl:with-param name="lang" select="$lang"/>
                        <xsl:with-param name="mdlang" select="$mdlang"/>
                    </xsl:call-template>
				</div>
			</div>
        </xsl:if>
        
        <div class="micka-row">
			<label><xsl:value-of select="$msg[@eng='Contact Info']"/></label>
			<div class="c">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
					<div rel="http://www.w3.org/ns/dcat#contactPoint">
						<xsl:apply-templates select="*"/>
						<xsl:if test="position()!=last()">
                            <div style="margin:5px 0 5px 0; border-bottom: 1px solid #EEE;"></div>
                        </xsl:if>
					</div>
				</xsl:for-each>
			</div>
		</div>

		<h3><xsl:value-of select="$msg[@eng='Data Quality']"/></h3>

		<div class="micka-row">

		<xsl:if test="$srv!=1">
			<div class="micka-row" rel="http://purl.org/dc/terms/provenance" typeof="http://purl.org/dc/terms/ProvenanceStatement">
				<label>
					<xsl:value-of select="$msg[@eng='Lineage']"/>
				</label>
				<div class="c" property="http://www.w3.org/2000/01/rdf-schema#label">
					<xsl:variable name="sr" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>
				</div>
			</div>

			<xsl:if test="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:source">
				<div class="micka-row">
					<label><xsl:value-of select="$msg[@eng='Sources']"/></label>
					<div class="c">
						<xsl:for-each select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:source">
							<xsl:variable name="md" select="php:function('getData', string(*/gmd:sourceCitation/@xlink:href))"/>
	  						<xsl:variable name="url"><xsl:value-of select="concat($mickaURL,'/record/basic/',$md//gmd:fileIdentifier)"/></xsl:variable>
							<div>
								<a href="{$url}">
									<xsl:call-template name="multi">
										<xsl:with-param name="el" select="$md//gmd:title"/>
										<xsl:with-param name="lang" select="$lang"/>
										<xsl:with-param name="mdlang" select="$mdlang"/>
									</xsl:call-template>
								</a>
                                <xsl:if test="*/gmd:description">
                                    (<xsl:call-template name="multi">
                                        <xsl:with-param name="el" select="*/gmd:description"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                        <xsl:with-param name="mdlang" select="$mdlang"/>
                                    </xsl:call-template>)
                                </xsl:if>
                            </div>
						</xsl:for-each>
					</div>
				</div>	
			</xsl:if>

			<div class="micka-row">
			<label><xsl:value-of select="$msg[@eng='Spatial Resolution']"/></label>
			<div class="c">
				<xsl:if test="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator!=''">
					<div>
                    <xsl:value-of select="$msg[@eng='Equivalent Scale']"/>:
                    <xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale">
                        <xsl:text> 1:</xsl:text>
                        <xsl:value-of select="*/gmd:denominator"/>
                        <xsl:if test="not(position()=last())">,</xsl:if>
                    </xsl:for-each>
                    </div>
				</xsl:if>
				<xsl:if test="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance">
					<xsl:value-of select="$msg[@eng='Distance']"/>:
 					 <xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance/@uom"/>
				</xsl:if>
			</div>
			</div>

		</xsl:if>
		<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_DomainConsistency]">
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Conformity']"/></label>
				<div class="c">
					<xsl:for-each select="*/gmd:result">
						<xsl:variable name="k" select="*/gmd:pass"/>
						<span class="res-type result-{$k}">
							<xsl:choose>
								<xsl:when test="$k='true'"><i class="fa fa-check-square fa-lg" style="color:green"></i></xsl:when>
								<xsl:when test="$k='false'"><i class="fa fa-minus-circle  fa-lg" style="color:red"></i></xsl:when>
								<xsl:otherwise><i class="fa fa-question"></i></xsl:otherwise>
							</xsl:choose>
						</span>
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:specification/*/gmd:title"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
						<!--b><xsl:value-of select="$cl/compliant/value[@name=$k]"/></b-->
					</xsl:for-each>
				</div>
			</div>
		</xsl:for-each>
	</div>

	<h3><xsl:value-of select="$msg[@eng='Constraints']"/></h3>

    <div class="micka-row">
        <label><xsl:value-of select="$msg[@eng='Use Limitation']"/></label>
        <div class="c" rel="http://purl.org/dc/terms/license">
            <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:useConstraints/*/@codeListValue]">
                <xsl:for-each select="*/gmd:otherConstraints">
                    <xsl:choose>
                        <xsl:when test="contains(*/@xlink:href,'://creativecommons.org')">
                            <xsl:variable name="licence" select="substring-after(*/@xlink:href,'creativecommons.org/licenses/')"/>							
                            <a href="{gmx:Anchor/@xlink:href}" target="_blank">
                                <img src="http://licensebuttons.net/l/{$licence}/88x31.png"/><br/>
                                <xsl:call-template name="multi">
                                    <xsl:with-param name="el" select="."/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="mdlang" select="$mdlang"/>
                                </xsl:call-template>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <div>
                                <xsl:call-template name="multi">
                                    <xsl:with-param name="el" select="."/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="mdlang" select="$mdlang"/>
                                </xsl:call-template>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </div>
    </div>

    <div class="micka-row">
        <label><xsl:value-of select="$msg[@eng='Access Constraints']"/></label>
        <div class="c">
            <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:accessConstraints/*/@codeListValue]">
                <!--xsl:for-each select="*/gmd:accessConstraints">
                    <xsl:variable name="kod" select="*/@codeListValue"/>
                    <div><xsl:value-of select="$cl/accessConstraints/value[@name=$kod]/*[name()=$lang]"/></div>
                </xsl:for-each-->
                <xsl:for-each select="*/gmd:otherConstraints">
                    <div>
                        <xsl:choose>
                            <xsl:when test="contains(*/@xlink:href,'://opendata.gov.cz')">
                                <a href="{*/@xlink:href}" target="_blank">
                                    <img src="https://opendata.gov.cz/_media/wiki:logo.png" style="height:24px"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                            <xsl:call-template name="multi">
                                <xsl:with-param name="el" select="."/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="mdlang" select="$mdlang"/>
                            </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:for-each>
            </xsl:for-each>
        </div>
    </div>	

	<!-- metadata -->
	<h3><xsl:value-of name="str" select="$msg[@eng='Metadata Metadata']"/></h3>
		<div rel="http://xmlns.com/foaf/0.1/isPrimaryTopicOf" typeof="http://www.w3.org/2000/01/rdf-schema#Resource">
			 <div class="micka-row">	
				<label><xsl:value-of select="$msg[@eng='MDIdentifier']"/></label>
				<div class="c" id="file-identifier"><xsl:value-of select="$fid"/></div>
			</div>
			<!--xsl:if test="gmd:parentIdentifier!=''">
				<xsl:variable name="pilink" select="php:function('getMetadata', concat('identifier=', $apos, gmd:parentIdentifier/*, $apos))"/>
				<div class="micka-row">
					<label><xsl:value-of select="$msg[@eng='Parent Identifier']"/></label>
					<div class="c">
						<xsl:value-of select="gmd:parentIdentifier"/>
					</div>
				</div>
			</xsl:if-->
			 <div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Metadata Contact']"/></label>
				<div class="c">
					<xsl:for-each select="gmd:contact">
						<div  rel="http://www.w3.org/ns/dcat#contactPoint">
							<xsl:apply-templates select="*"/>
							<xsl:if test="position()!=last()">
                                <div style="margin:5px 0 5px 0; border-bottom: 1px solid #EEE;"></div>
                            </xsl:if>
						</div>
					</xsl:for-each>
				</div>
			</div> 
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Date Stamp']"/></label>
				<div class="c" property="http://purl.org/dc/terms/modified"  datatype="http://www.w3.org/2001/XMLSchema#date" content="{gmd:dateStamp/*}"><xsl:value-of select="php:function('drawDate', string(gmd:dateStamp/*), $lang)"/></div>
			</div>

			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Language']"/></label>
				<div class="c" rel="http://purl.org/dc/terms/language" resource="http://publications.europa.eu/resource/authority/language/{translate($lang,$lower,$upper)}"><xsl:value-of select="$cl/language/value[@code=$lang]/*[name()=$lang]"/></div>
			</div>
		</div>
	
		<h3><xsl:value-of select="$msg[@eng='Coupled Resource']"/></h3>

		<!-- ===LINKS=== -->
		
		<!-- services -->
		<xsl:variable name="vazby" select="php:function('getMetadata', concat('uuidRef=',$fid))"/>
		<div class="micka-row">
			<label><xsl:value-of select="$msg[@eng='Used']"/></label>
			<div class="c">
				<xsl:for-each select="$vazby//gmd:MD_Metadata">
	                <xsl:variable name="url"><xsl:value-of select="gmd:fileIdentifier"/></xsl:variable>
					<div><a href="{$url}" class="t" title="{$cl/updateScope/value[@name=$vazby[position()]//gmd:hierarchyLevel/*/@codeListValue]/*[name()=$lang]}">
						<xsl:call-template name="showres">
							<xsl:with-param name="r" select="gmd:hierarchyLevel/*/@codeListValue"/>
						</xsl:call-template>
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
					</a></div>
				</xsl:for-each>	
			</div>
		</div>	
		
		<!-- parent -->
		<xsl:if test="gmd:parentIdentifier!=''">
			<xsl:variable name="pilink" select="php:function('getMetadata', concat('identifier=', $apos, gmd:parentIdentifier/*, $apos))"/>
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Parent']"/></label>
				<div class="c">
					<xsl:variable name="a" select="$pilink//gmd:hierarchyLevel/*/@codeListValue"/>
	                <xsl:variable name="url"><xsl:value-of select="concat('',$pilink//gmd:fileIdentifier)"/></xsl:variable>

					<a class="t" href="{$url}" title="{$cl/updateScope/value[@name=$a]/*[name()=$lang]}">
						<xsl:call-template name="showres">
							<xsl:with-param name="r" select="$a"/>
						</xsl:call-template>
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="$pilink//gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
					</a>
				</div>
			</div>
		</xsl:if>
		
        <!-- children - on client 
        <div class="micka-row">
            <label><xsl:value-of select="$msg[@eng='Children']"/></label>
        </div> -->
		<!-- children -->
		<xsl:variable name="subsets" select="php:function('getMetadata', concat('ParentIdentifier=', $apos, $fid, $apos))"/>		
		<xsl:if test="$subsets//gmd:MD_Metadata">
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Children']"/></label>
				<div class="c">
					<xsl:for-each select="$subsets//gmd:MD_Metadata">
						<xsl:variable name="a" select="gmd:hierarchyLevel/*/@codeListValue"/>
                        <xsl:variable name="url" select="concat($mickaURL,'/record/basic/',gmd:fileIdentifier)"/>
						<div>
                            <a href="{$url}" class="t" title="{$cl/updateScope/value[@name=$a]/*[name()=$lang]}">
                                <xsl:call-template name="showres">
                                    <xsl:with-param name="r" select="$a"/>
                                </xsl:call-template>
                                <xsl:call-template name="multi">
                                    <xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="mdlang" select="$mdlang"/>
                                </xsl:call-template>							 
                            </a>
							<xsl:call-template name="subsets">
								<xsl:with-param name="fid" select="gmd:fileIdentifier"/>
								<xsl:with-param name="level" select="1"/>
							</xsl:call-template>
                        </div>
					</xsl:for-each>
					<xsl:if test="$subsets//csw:SearchResults/@numberOfRecordsMatched &gt; 25">
                        <div>
                            <a href="{$mickaURL}?request=GetRecords&amp;format=text/html&amp;language={$lang}&amp;query=parentIdentifier={gmd:fileIdentifier/*}">
                                <xsl:value-of select="concat($msg[@eng='ShowAll'], ' (', $subsets//csw:SearchResults/@numberOfRecordsMatched, ') ...')"/>
                            </a>
                        </div>
					</xsl:if>
				</div>
			</div>	
		</xsl:if>
		
		<!-- siblinks 
		<xsl:if test="gmd:parentIdentifier!=''">
			<xsl:variable name="siblinks" select="php:function('getMetadata', concat('ParentIdentifier=',$apos, gmd:parentIdentifier/*,$apos))"/>
			<xsl:if test="count($siblinks) &gt; 1">
				<xsl:variable name="myid" select="gmd:fileIdentifier/*"/>
				<div class="micka-row">
					<label><xsl:value-of select="$msg[@eng='Siblinks']"/></label>
					<div class="c">
						<xsl:for-each select="$siblinks//gmd:MD_Metadata[gmd:fileIdentifier/*!=$myid]">
							<xsl:variable name="a" select="gmd:hierarchyLevel/*/@codeListValue"/>
							<xsl:variable name="url"><xsl:value-of select="concat('',gmd:fileIdentifier)"/></xsl:variable>

							<div><a href="{$url}" class="t"  title="{$cl/updateScope/value[@name=$a]}">
								<xsl:call-template name="showres">
									<xsl:with-param name="r" select="$a"/>
								</xsl:call-template>
								<xsl:call-template name="multi">
									<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
									<xsl:with-param name="lang" select="$lang"/>
									<xsl:with-param name="mdlang" select="$mdlang"/>
								</xsl:call-template>
							</a></div>
					</xsl:for-each>
				</div></div>
			</xsl:if>
		</xsl:if>-->

		<!-- 1.6 services - operatesOn -->
		<xsl:if test="gmd:identificationInfo/srv:SV_ServiceIdentification">
			<div class="micka-row">
				<label><xsl:value-of select="$msg[@eng='Use']"/></label>
				<div class="c">
					 <xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn">
						<!--xsl:variable name="siblinks" select="php:function('getMetadata', concat('identifier=',$opid))"/-->
						<xsl:variable name="siblinks" select="php:function('getData', string(@xlink:href))"/>
						<xsl:for-each select="$siblinks//gmd:MD_Metadata">
							<xsl:variable name="a" select="gmd:hierarchyLevel/*/@codeListValue"/>
							<xsl:variable name="url"><xsl:value-of select="concat('',normalize-space(gmd:fileIdentifier))"/></xsl:variable>
							<div><a href="{$url}" class="t"  title="{$cl/updateScope/value[@name=$a]/*[name=$lang]}">
								<xsl:call-template name="showres">
									<xsl:with-param name="r" select="$a"/>
								</xsl:call-template>
									<xsl:call-template name="multi">
										<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
										<xsl:with-param name="lang" select="$lang"/>
										<xsl:with-param name="mdlang" select="$mdlang"/>
									</xsl:call-template>
								</a></div>
						</xsl:for-each>
					</xsl:for-each>
				</div>	
			</div>
		</xsl:if>

		<!-- FC citation -->
		<xsl:for-each select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
			<div class="micka-row">
				<label>
					<xsl:value-of select="$msg[@eng='Feature catalogue']"/>
				</label>
				<div class="c">
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="gmd:featureCatalogueCitation/*/gmd:title"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>

					<xsl:variable name="url">
						<xsl:if test="gmd:featureCatalogueCitation/*/gmd:identifier">	
							<xsl:value-of select="concat(gmd:featureCatalogueCitation/*/gmd:identifier, '?language=', $lang)"/>								
						</xsl:if>
					</xsl:variable>

					<xsl:if test="gmd:featureCatalogueCitation/*/gmd:identifier"> 
						[<a href="{$url}"><xsl:call-template name="showres">
							<xsl:with-param name="r" select="'fc'"/>
						</xsl:call-template><xsl:value-of select="*"/><xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:identifier"/></a>]
					</xsl:if>
					
					<xsl:for-each select="gmd:featureTypes">
						<div>
						  	<xsl:choose>
  						  		<xsl:when test="$url">
  							   		<a href="{$url}#{*}" class="t">
                                        <xsl:call-template name="showres">
                                            <xsl:with-param name="r" select="'fc'"/>
                                        </xsl:call-template>
                                        <xsl:value-of select="*"/> 
                                    </a>
  								</xsl:when>
  								<xsl:otherwise>
  							   		<a class="t">
                                        <xsl:call-template name="showres">
                                            <xsl:with-param name="r" select="'fc'"/>
                                        </xsl:call-template>
                                        <xsl:value-of select="*"/>
                                    </a>
  								</xsl:otherwise>
              				</xsl:choose>   
						</div>
					</xsl:for-each>
				</div>
			</div>
		</xsl:for-each>

		</div>
	</xsl:template>
	
	<!-- Dublin Core -->
	<xsl:template match="csw:Record" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/">

	<ol class="breadcrumb">
		<li class="active"><a href="{$mickaURL}" tooltip="tooltip" title="{$msg[@eng='List']}" data-container="body" data-placement="bottom"><i class="fa fa-arrow-left fa-lg"></i></a></li>
		<li><xsl:value-of select="$msg[@eng='fullMetadata']"/></li>
				
		<div class="icons">
			<xsl:if test="../@edit=1">
				<a href="../edit/{../@uuid}" class="edit" title="{$msg[@eng='edit']}"><i class="fa fa-pencil fa-fw"></i></a>				
				<a href="../clone/{../@uuid}" class="copy" title="{$msg[@eng='clone']}"><i class="fa fa-clone fa-fw"></i></a>				
				<a href="javascript: omicka.confirm(HS.i18n('Delete record')+'?', '../delete/{../@uuid}');" class="delete" title="{$msg[@eng='delete']}"><i class="fa fa-trash fa-fw"></i></a>				
			</xsl:if>
			<xsl:if test="../@read=1">
				<xsl:if test="../@md_standard=0 or ../@md_standard=10">
					<a href="{$mickaURL}/csw?service=CSW&amp;request=GetRecordById&amp;id={../@uuid}&amp;outputschema=http://www.w3.org/ns/dcat%23" class="rdf" target="_blank" title="Geo-DCAT RDF"><i class="fa fa-cube fa-fw"></i></a>
				</xsl:if>
				<a href="../xml/{../@uuid}" class="xml" target="_blank" title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
			</xsl:if>
		</div>			
	</ol>

        <h1>
            <xsl:call-template name="showres">
                <xsl:with-param name="r" select="'dc'"/>
            </xsl:call-template>        
			<xsl:value-of select="dc:title"/>
			<xsl:for-each select="dc:identifier">
				<xsl:if test="substring(.,1,4)='http'">
					<div style="float:right; font-size:13px;">
						<a class="open" href="{.}" target="_blank">
							<xsl:value-of select="$msg/open"/>
						</a>
					</div>
				</xsl:if>
			</xsl:for-each>
		</h1>

			<xsl:for-each select="*">
				<!-- TODO dodelat vzhled -->
				<div class="micka-row">
					<label>
						<xsl:variable name="itemName" select="substring-after(name(),':')"/>
						<xsl:value-of select="$msg[translate(@eng,$upper,$lower)=$itemName]"/>
					</label>
					<div class="c">
						<xsl:choose>
							<xsl:when test="substring(.,1,4)='http'">
								<a href="{.}" target="_blank">
									<xsl:value-of select="."/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:for-each>
			<xsl:for-each select="ows:BoundingBox">
				<meta id="i-{position()}" itemprop="box" content="{substring-before(ows:LowerCorner,' ')} {substring-after(ows:LowerCorner,' ')} {substring-before(ows:UpperCorner,' ')} {substring-after(ows:UpperCorner,' ')}" />					
			</xsl:for-each>

	</xsl:template>


	<!-- Feature catalogue -->
	<xsl:template match="gfc:FC_FeatureCatalogue">
	<ol class="breadcrumb">
		<li class="active"><a href="{$mickaURL}" tooltip="tooltip" title="{$msg[@eng='List']}" data-container="body" data-placement="bottom"><i class="fa fa-arrow-left fa-lg"></i></a></li>
		<li><xsl:value-of select="$msg[@eng='Feature catalogue']"/></li>
		<div class="icons">
			<xsl:if test="../@edit=1">
				<a href="../edit/{../@uuid}" class="edit" title="{$msg[@eng='edit']}"><i class="fa fa-pencil fa-fw"></i></a>				
				<a href="../clone/{../@uuid}" class="copy" title="{$msg[@eng='clone']}"><i class="fa fa-clone fa-fw"></i></a>				
				<a href="javascript: omicka.confirm(HS.i18n('Delete record')+'?', '{$mickaURL}/record/delete/{../@uuid}');" class="delete" title="{$msg[@eng='delete']}"><i class="fa fa-trash fa-fw"></i></a>				
			</xsl:if>
			<xsl:if test="../@read=1">
				<xsl:if test="../@md_standard=0 or ../@md_standard=10">
					<a href="{$mickaURL}/csw?service=CSW&amp;request=GetRecordById&amp;id={../@uuid}&amp;outputschema=http://www.w3.org/ns/dcat%23" class="rdf" target="_blank" title="Geo-DCAT RDF"><i class="fa fa-cube fa-fw"></i></a>
				</xsl:if>
				<a href="../xml/{../@uuid}" class="xml" target="_blank" title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
			</xsl:if>
		</div>			
	</ol>

    <xsl:variable name="mdLang" select="*/gmx:language/*/@codeListValue"/>
    <h1>
        <xsl:call-template name="showres">
            <xsl:with-param name="r" select="'fc'"/>
        </xsl:call-template>

        <xsl:call-template name="multi">
            <xsl:with-param name="el" select="gmx:name"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="mdlang" select="$mdLang"/>
        </xsl:call-template>
    </h1>

    <div class="report">
        <div class="micka-row">
            <label><xsl:value-of select="$msg[@eng='Contact Info']"/></label>
            <div class="c">
                <xsl:for-each select="gfc:producer">
                    <div rel="http://www.w3.org/ns/dcat#contactPoint">
                        <div typeof="http://www.w3.org/2000/01/rdf-schema#Resource">
                            <xsl:if test="*/gmd:organisationName">
                                <div property="http://www.w3.org/2006/vcard/ns#fn">
                                    <xsl:call-template name="multi">
                                        <xsl:with-param name="el" select="*/gmd:organisationName"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                        <xsl:with-param name="mdlang" select="$mdlang"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:if>
                            <xsl:if test="*/gmd:individualName">
                                <xsl:call-template name="multi">
                                    <xsl:with-param name="el" select="*/gmd:individualName"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="mdlang" select="$mdlang"/>
                                </xsl:call-template>
                            </xsl:if>
                        </div>
                        <div rel="http://www.w3.org/2006/vcard/ns#hasAddress" vocab="http://www.w3.org/2006/vcard/ns#" typeof="http://www.w3.org/2006/vcard/ns#Address" >
                            <xsl:if test="*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint">
                                <span property="street-address"><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/></span>,
                            </xsl:if>
                            <xsl:if test="*/gmd:contactInfo/*/gmd:address/*/gmd:city">
                                <span property="locality"><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:city"/></span> 
                            </xsl:if>
                            <xsl:if test="*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode">,
                                <span property="postal-code"><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/></span>
                            </xsl:if>
                            <xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:country">, 
                                <span property="country-name"><xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:country"/></span>
                            </xsl:if>		
                        </div>
                        <xsl:for-each select="*/gmd:contactInfo/*/gmd:onlineResource[*/gmd:linkage/gmd:URL!='']">
                            <div rel="http://www.w3.org/2006/vcard/ns#hasURL"><a href="{*/gmd:linkage}" resource="{*/gmd:linkage}" target="_blank"><xsl:value-of select="*/gmd:linkage"/></a></div>
                        </xsl:for-each>
                        <xsl:for-each select="*/gmd:contactInfo/*/gmd:phone/*/gmd:voice">
                            <div>tel: <xsl:value-of select="."/></div>
                        </xsl:for-each>
                        <xsl:for-each select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress">
                            <div rel="http://www.w3.org/2006/vcard/ns#hasEmail" resource="mailto:{.}">email: <xsl:value-of select="."/></div>
                        </xsl:for-each>
                        <xsl:variable name="kod" select="*/gmd:role/*/@codeListValue"/>
                        <xsl:value-of select="$msg[@eng='role']"/>: <b><xsl:value-of select="$cl/role/value[@name=$kod]/*[name()=$lang]"/></b> 

                        <xsl:if test="position()!=last()"><div style="margin-top:8px"></div></xsl:if>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </div>

    <xsl:variable name="vazby" select="php:function('getMetadata', concat('FcIdentifier=',$ID))"/>
    <xsl:if test="$vazby//gmd:MD_Metadata">
        <div class="micka-row">
            <label><xsl:value-of select="$msg[@eng='Coupled Resource']"/></label>
            <div class="c">
                <xsl:for-each select="$vazby//gmd:MD_Metadata">
                    <div>
                        <a href="{$mickaURL}/record/basic/{gmd:fileIdentifier}?language={$lang}" title="Metadata">
                            <xsl:call-template name="showres">
                                <xsl:with-param name="r" select="gmd:hierarchyLevel/*/@codeListValue"/>
                            </xsl:call-template>
                            <xsl:call-template name="multi">
                                <xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="mdlang" select="$mdLang"/>
                            </xsl:call-template>
                        </a>
                     </div>	
                </xsl:for-each>
            </div>
        </div>
    </xsl:if>
    
	<xsl:for-each select="gfc:featureType">
		<a name="{*/gfc:typeName/*}"/>
			<h2><xsl:value-of select="*/gfc:typeName/*"/></h2>
            <xsl:if test="*/gfc:definition">
                <div class="micka-row">
                    <xsl:call-template name="multi">
                        <xsl:with-param name="el" select="*/gfc:definition"/>
                        <xsl:with-param name="lang" select="$lang"/>
                        <xsl:with-param name="mdlang" select="*/gmd:language/gmd:LanguageCode/@codeListValue"/>
                    </xsl:call-template>
                </div>
            </xsl:if>

            <div class="table-responsive">
                <table class="table table-bordered table-condensed table-hover">
                    <colgroup>
                        <col style="width:10%"/>
                        <col style="width:30%"/>
                        <col style="width:10%"/>
                        <col style="width:5%"/>
                        <col style="width:15%"/>
                        <col style="width:30%"/>
                    </colgroup>	
                        
                        <!-- atributy --> 
                        
                        <tr class="info">
                            <th>Název</th>
                            <th>Popis</th>
                            <th>Typ</th>
                            <th>Jedn.</th>
                            <th>Kód</th>
                            <th>Hodnoty</th>
                        </tr>
                        <xsl:for-each select="*/gfc:carrierOfCharacteristics">
                            <tr>
                            <th><xsl:value-of select="*/gfc:memberName"/></th>
                                <td>
                                    <xsl:call-template name="multi">
                                        <xsl:with-param name="el" select="*/gfc:definition"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                        <xsl:with-param name="mdlang" select="$mdLang"/>
                                    </xsl:call-template>
                                </td> 
                                <td><xsl:value-of select="*/gfc:valueType"/></td>
                                <td><xsl:value-of select="*/gfc:valueMeasurementUnit/*/gml:identifier"/></td>
                                <td><xsl:value-of select="*/gfc:code"/></td>
                            
                            <!-- domeny -->
                                <td style="margin-left:1cm">
                                    <xsl:for-each select="*/gfc:listedValue">
                                        <div>
                                            <b><xsl:value-of select="*/gfc:code"/></b>:
                                            <xsl:call-template name="multi">
                                                <xsl:with-param name="el" select="*/gfc:label"/>
                                                <xsl:with-param name="lang" select="$lang"/>
                                                <xsl:with-param name="mdlang" select="$mdLang"/>
                                            </xsl:call-template>
                                            <xsl:if test="*/gfc:definition"> 
                                                (<xsl:call-template name="multi">
                                                    <xsl:with-param name="el" select="*/gfc:definition"/>
                                                    <xsl:with-param name="lang" select="$lang"/>
                                                    <xsl:with-param name="mdlang" select="$mdLang"/>
                                                </xsl:call-template>)
                                            </xsl:if>
                                        </div>
                                    </xsl:for-each>
                                </td>	
                            </tr>
                        </xsl:for-each> 
                </table>
            </div>
		</xsl:for-each>
	</xsl:template>

	<!-- for contacts -->
	<xsl:template match="gmd:CI_ResponsibleParty">
		<div typeof="http://www.w3.org/2000/01/rdf-schema#Resource">
			<xsl:if test="gmd:organisationName">
				<div property="http://www.w3.org/2006/vcard/ns#fn">
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="gmd:organisationName"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>
				</div>
			</xsl:if>
			<xsl:if test="gmd:individualName">
                <xsl:value-of select="gmd:individualName"/>
			</xsl:if>
			<div rel="http://www.w3.org/2006/vcard/ns#hasAddress" vocab="http://www.w3.org/2006/vcard/ns#" typeof="http://www.w3.org/2006/vcard/ns#Address" >
				<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint">
					<span property="street-address"><xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/></span>,
				</xsl:if>
				<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:city">
					<span property="locality"><xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:city"/></span> 
				</xsl:if>
				<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:postalCode">,
					<span property="postal-code"><xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/></span>
				</xsl:if>
				<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:country">, 
					<span property="country-name"><xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:country"/></span>
				</xsl:if>		
			</div>
			<xsl:for-each select="gmd:contactInfo/*/gmd:onlineResource[*/gmd:linkage/gmd:URL!='']">
				<div rel="http://www.w3.org/2006/vcard/ns#hasURL"><a href="{*/gmd:linkage}" resource="{*/gmd:linkage}" target="_blank"><xsl:value-of select="*/gmd:linkage"/></a></div>
			</xsl:for-each>
			<xsl:for-each select="gmd:contactInfo/*/gmd:phone/*/gmd:voice">
				<div>tel: <xsl:value-of select="."/></div>
			</xsl:for-each>
			<xsl:for-each select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress">
				<div rel="http://www.w3.org/2006/vcard/ns#hasEmail" resource="mailto:{.}">email: <xsl:value-of select="."/></div>
				</xsl:for-each>
			<xsl:variable name="kod" select="gmd:role/*/@codeListValue"/>
            <xsl:value-of select="$msg[@eng='role']"/>: <b><xsl:value-of select="$cl/role/value[@name=$kod]/*[name()=$lang]"/></b>
		 </div> 
	</xsl:template>

	<xsl:template name="subsets">
		<xsl:param name="fid"/>
		<xsl:param name="level"/>
		<xsl:variable name="subsets" select="php:function('getMetadata', concat('ParentIdentifier=', $apos, $fid, $apos))"/>		
		<xsl:if test="$subsets//gmd:MD_Metadata">
			<div style="margin-left:20px;">
                <xsl:for-each select="$subsets//gmd:MD_Metadata">
                    <xsl:variable name="a" select="gmd:hierarchyLevel/*/@codeListValue"/>
                    <xsl:variable name="url" select="concat($mickaURL,'/record/basic/',gmd:fileIdentifier)"/>
                    <div>
                        <a href="{$url}" class="t" title="{$cl/updateScope/value[@name=$a]/*[name()=$lang]}">
                            <xsl:call-template name="showres">
                                <xsl:with-param name="r" select="$a"/>
                            </xsl:call-template>

                            <xsl:call-template name="multi">
                                <xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="mdlang" select="$mdlang"/>
                            </xsl:call-template>							 
                        </a>
                        <xsl:choose>
                            <xsl:when test="$level &lt; 6">
                                <xsl:call-template name="subsets">
                                    <xsl:with-param name="fid" select="gmd:fileIdentifier"/>
                                    <xsl:with-param name="level" select="$level+1"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise><div>Many nesting levels! Stopped.</div></xsl:otherwise>	
                        </xsl:choose>
                    </div>
                </xsl:for-each>
                <xsl:if test="$subsets//csw:SearchResults/@numberOfRecordsMatched &gt; 25">
                    <div>
                        <a href="{$mickaURL}?request=GetRecords&amp;format=text/html&amp;language={$lang}&amp;query=parentIdentifier={gmd:fileIdentifier/*}"><xsl:value-of select="concat($msg[@eng='ShowAll'], ' (', $subsets//csw:SearchResults/@numberOfRecordsMatched, ') ...')"/> </a>
                    </div>
                </xsl:if>
            </div>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
