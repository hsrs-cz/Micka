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
	<xsl:variable name="cl" select="document(concat('codelists_', $lang, '.xml'))/map"/>
	<!-- <xsl:variable name="MICKA_URL" select="'..'"/>  -->
	<xsl:variable name="mdlang" select="*/gmd:language/gmd:LanguageCode/@codeListValue"/>
	<xsl:include href="client/common_cli.xsl" />

	<xsl:template match="/*">
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
		<xsl:variable name="rtype">
		  <xsl:choose>
		    <xsl:when test="contains(gmd:hierarchyLevelName,'spatialPlan')">sp</xsl:when>
			<xsl:otherwise><xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/></xsl:otherwise>
		  </xsl:choose>
  		</xsl:variable>
		<xsl:variable name="srv">
			<xsl:choose>
				<xsl:when test="name(gmd:identificationInfo/*)='srv:SV_ServiceIdentification'">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<h1 title="{$cl/updateScope/value[@name=$rtype]}">
			<div class="{$rtype}" style="padding-left: 20px;"><xsl:call-template name="multi">
				<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
				<xsl:with-param name="lang" select="$lang"/>
				<xsl:with-param name="mdlang" select="$mdlang"/>
			</xsl:call-template>
			 <xsl:if test="gmd:hierarchyLevelName/*='http://geoportal.gov.cz/inspire'"><span class="for-inspire" title="{$msg[@eng='forInspire']}"></span></xsl:if>
			</div>
		</h1>
		<!--<div class="hlevel">
			<xsl:value-of select="$cl/updateScope/value[@name=$rtype]"/>
			<xsl:if test="gmd:hierarchyLevelName != ''">
				- <xsl:value-of select="gmd:hierarchyLevelName"/>
			</xsl:if>
		</div>-->
		
		<!-- identifikace --> 
	
		<!-- <div class="row">
			<div class="l">
				<xsl:value-of select="$msg[@eng='Title']"/>
			</div>
			<div class="r title">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="."/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</div>  -->
	<h2>
		<div class="icons">
		  	<xsl:variable name="wmsURL" select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*[contains(gmd:protocol/*,'WMS') or contains(gmd:linkage/*,'WMS')]/gmd:linkage/*"/>		  		
			<!--xsl:if test="gmd:identificationInfo/*/srv:serviceType/*='download'"-->
				<a href="{$MICKA_URL}/csw/?service=CSW&amp;version=2.0.2&amp;request=GetRecordById&amp;id={gmd:fileIdentifier}&amp;language={$LANGUAGE}&amp;outputSchema=http://www.w3.org/2005/Atom" target="_blank" title="Atom"><i class="fa fa-feed fa-fw"></i></a>
			<!-- /xsl:if-->
			<xsl:if test="string-length($wmsURL)>0">
				<xsl:choose>
					<xsl:when test="contains($wmsURL,'?')">
			   			<a class='map' href="{$viewerURL}{substring-before($wmsURL,'?')}" target="wmsviewer"><i class="fa fa-map-o fa-fw"></i></a>		  				
					</xsl:when>
					<xsl:otherwise>
						<a class='map' href="{$viewerURL}{$wmsURL}" target="wmsviewer"><i class="fa fa-map-o fa-fw"></i></a>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="../@edit=1">
				<a href="{$MICKA_URL}?ak=valid&amp;uuid={../@uuid}" class="valid{../@valid}" title="{$msg[@eng='validate']}"><xsl:choose>
						<xsl:when test="../@valid=2"><i class="fa fa-check-circle fa-fw"></i></xsl:when>
						<xsl:when test="../@valid=1"><i class="fa fa-exclamation-triangle fa-fw"></i></xsl:when>
						<xsl:otherwise><i class="fa fa-ban fa-fw"></i></xsl:otherwise>
						</xsl:choose></a>
				<a href="{$MICKA_URL}?ak=edit&amp;recno={../@recno}" class="edit" title="{$msg[@eng='edit']}"><i class="fa fa-pencil fa-fw"></i></a>				
				<a href="{$MICKA_URL}?ak=copy&amp;recno={../@recno}" class="copy" title="{$msg[@eng='clone']}"><i class="fa fa-clone fa-fw"></i></a>				
				<a href="javascript:md_delrecno({../@recno});" class="delete" title="{$msg[@eng='delete']}"><i class="fa fa-trash fa-fw"></i></a>				
			</xsl:if>
			<xsl:if test="../@read=1">
				<xsl:if test="../@md_standard=0 or ../@md_standard=10">
					<a href="{$MICKA_URL}/csw/?service=CSW&amp;request=GetRecordById&amp;id={../@uuid}&amp;outputschema=http://www.w3.org/ns/dcat%23" class="rdf" target="_blank" title="Geo-DCAT RDF"><i class="fa fa-cube fa-fw"></i></a>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$REWRITE">	
							<a href="{$MICKA_URL}/records/{../@uuid}?format=application/xml" class="xml" target="_blank" title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
						</xsl:when>
					<xsl:otherwise>
							<a href="{$MICKA_URL}?ak=xml&amp;uuid={../@uuid}" class="xml" target="_blank" title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</div>			
		<xsl:if test="../@read=1">
			<span class="icons">
				<xsl:choose>
					<xsl:when test="$REWRITE">	
						<a href="{$MICKA_URL}/records/{../@uuid}?detail=full&amp;language={$lang}" class="icons" title="{$msg[@eng='fullMetadata']}"><i class="fa fa-folder-o fa-fw"></i></a>
					</xsl:when>
					<xsl:otherwise>
						<a href="{$MICKA_URL}?ak=detailall&amp;uuid={../@uuid}" class="icons" title="{$msg[@eng='fullMetadata']}"><i class="fa fa-folder-o fa-fw"></i></a>
					</xsl:otherwise>
				</xsl:choose>
			</span>		
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$msg[@eng='basicMetadata']"/>
	</h2>
	
	<table class="report">
		<tr>
			<!--  td class="subtitle">
				<xsl:call-template name="lf2br">
					<xsl:with-param name="str" select="$msg[@eng='Identification']"/>
				</xsl:call-template>
			</td -->

			<td style="width:100%">
			<table class="report-right">	
				<colgroup>
			        <col style="width: 160px;" />
			        <col style="width: 376px;" />
			    </colgroup>	
			<tr><td colspan="2">
				<div style="font-weight:bold; color:black;"><xsl:value-of select="$msg[@eng='Abstract']"/></div>
				<xsl:call-template name="multi">
					<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:abstract"/>
					<xsl:with-param name="lang" select="$lang"/>
					<xsl:with-param name="mdlang" select="$mdlang"/>
				</xsl:call-template>

			</td></tr>

		  	<xsl:if test="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*">
		  		<tr><th><xsl:value-of select="$msg[@eng='Browse Graphic']"/>
		  			<div style="font-weight:normal; color: #4e4e51;">
		  			<xsl:call-template name="multi">
	    				<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileDescription"/>
	    				<xsl:with-param name="lang" select="$LANGUAGE"/>
	    				<xsl:with-param name="mdlang" select="$mdlang"/>
	  				</xsl:call-template></div>
		  			</th>
		  			<td>
	  					<img src="{gmd:identificationInfo/*/gmd:graphicOverview/*/gmd:fileName/*}"/>
	  				</td>
	  			</tr>
	  		</xsl:if>	

			<tr>
				<th><xsl:value-of select="$msg[@eng='Type']"/></th>
				<td>
				<xsl:value-of select="$cl/updateScope/value[@name=$rtype]"/>
				<xsl:if test="gmd:hierarchyLevelName != ''">
				- <xsl:value-of select="gmd:hierarchyLevelName"/>
				</xsl:if>
				</td>
			</tr>

	
			<tr>
				<th><xsl:value-of select="$msg[@eng='Resource Locator']"/></th>
				<td>
					<xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
						<xsl:variable name="label">
                                <xsl:choose>
                                	<xsl:when test="*/gmd:description">
                                		<xsl:call-template name="multi">
                                            <xsl:with-param name="el" select="*/gmd:description"/>
                                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                                            <xsl:with-param name="mdlang" select="$mdlang"/>
                                        </xsl:call-template>
                                	</xsl:when>
                                    <xsl:when test="*/gmd:name">
                                        <xsl:call-template name="multi">
                                            <xsl:with-param name="el" select="*/gmd:name"/>
                                            <xsl:with-param name="lang" select="$LANGUAGE"/>
                                            <xsl:with-param name="mdlang" select="$mdlang"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:value-of select="*/gmd:linkage"/></xsl:otherwise>
                                </xsl:choose>
						</xsl:variable>
                        <div>
                          	<xsl:choose>
                           		<xsl:when test="contains(*/gmd:protocol, 'DOWNLOAD')">
                                	<a href="{*/gmd:linkage}"  target="_blank">
                                      	<span style="color:#070; font-size:20px;"><i class="fa fa-download"></i></span><xsl:text> </xsl:text>
                                      	<xsl:value-of select="$label"/>
                                	</a>	
                            	</xsl:when>
                           		<xsl:when test="contains(*/gmd:protocol, 'rss')">
                                	<a href="{*/gmd:linkage}"  target="_blank">
                                      	<span style="color:#ff6600; font-size:20px;"><i class="fa fa-feed"></i></span><xsl:text> </xsl:text>
                                      	<xsl:value-of select="$label"/>
                                	</a>	
                            	</xsl:when>
								<xsl:when test="contains(*/gmd:protocol/*,'WMS') or contains(*/gmd:linkage/*,'WMS')">
									<xsl:variable name="label1">
		                                <xsl:choose>
			                                	<xsl:when test="*/gmd:description">
			                                		<xsl:call-template name="multi">
			                                            <xsl:with-param name="el" select="*/gmd:description"/>
			                                            <xsl:with-param name="lang" select="$LANGUAGE"/>
			                                            <xsl:with-param name="mdlang" select="$mdlang"/>
			                                        </xsl:call-template>
			                                	</xsl:when>		                                    
			                                	<xsl:when test="*/gmd:name">
		                                        <xsl:call-template name="multi">
		                                            <xsl:with-param name="el" select="*/gmd:name"/>
		                                            <xsl:with-param name="lang" select="$LANGUAGE"/>
		                                            <xsl:with-param name="mdlang" select="$mdlang"/>
		                                        </xsl:call-template>
		                                    </xsl:when>
		                                    <xsl:otherwise><xsl:value-of select="$msg[@eng='showMap']"/></xsl:otherwise>
		                                </xsl:choose>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="contains(*/gmd:linkage/*,'?')">
							   				<a class='map' href="{$viewerURL}?wms={substring-before(*/gmd:linkage/*,'?')}" target="wmsviewer"><span style="color:#ff6600; font-size:20px;"><i class="fa fa-map"></i></span> WMS: <xsl:value-of select="$label1"/></a>		  				
										</xsl:when>
										<xsl:otherwise>
											<a class='map' href="{$viewerURL}?wms={*/gmd:linkage/*}" target="wmsviewer"><span style="color:#ff6600; font-size:20px;"><i class="fa fa-map"></i></span> WMS: <xsl:value-of select="$label1"/></a>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
                                <xsl:otherwise>
                                	<a href="{*/gmd:linkage}"  target="_blank">
                                		<span style="font-size:20px;"><i class="fa fa-external-link-square"></i></span><xsl:text> </xsl:text>
                                		<xsl:value-of select="$label"/>
                                	</a>
                                </xsl:otherwise>
                        	</xsl:choose>   
                        </div>
					</xsl:for-each>
				</td>
			</tr>


			<tr>
				<th><xsl:value-of select="$msg[@eng='Identifier']"/></th>
				<td>
					<xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/>
				</td>
			</tr>
			

		<xsl:if test="$srv!=1">
			<tr>
				<th><xsl:value-of select="$msg[@eng='Language']"/></th>
				<td>
					<xsl:for-each select="gmd:identificationInfo/*/gmd:language">
						<xsl:variable name="kod" select="*/@codeListValue"/>
						<xsl:value-of select="$cl/language/value[@code=$kod]"/>
						<xsl:if test="position()!=last()">, </xsl:if>
					</xsl:for-each>
				</td>
			</tr>
			
			<tr>
				<th><xsl:value-of select="$msg[@eng='Topic category']"/></th>
				<td>
					<xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
						<xsl:variable name="k" select="*"/>
						<xsl:value-of select="$cl/topicCategory/value[@name=$k]"/>
						<xsl:if test="position()!=last()"><br/></xsl:if>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>


		<xsl:if test="$srv=1">
			<tr>
				<th>
					<xsl:value-of select="$msg[@eng='Service Type']"/>
				</th>
				<td>
					<xsl:value-of select="gmd:identificationInfo/*/srv:serviceType"/>
					<xsl:for-each select="gmd:identificationInfo/*/srv:serviceTypeVersion">
						<xsl:text> </xsl:text>
						<xsl:value-of select="."/>
						<xsl:if test="not(position()=last())">,</xsl:if>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>

			<tr>
				<th><xsl:value-of select="$msg[@eng='Keywords']"/></th>
				<td>
					<xsl:for-each select="//gmd:descriptiveKeywords[string-length(*/gmd:thesaurusName/*/gmd:title/*)>0]">

						<xsl:choose>
							<!-- blbost kvuli CENII -->
							<xsl:when test="contains(*/gmd:thesaurusName/*/gmd:title/*,'CENIA')">
								<i><b>GEOPORTAL:</b></i>
								<xsl:for-each select="*/gmd:keyword">
							     	<div style="margin-left:20px;">
							     		<xsl:variable name="k" select="*"/>
							     		<xsl:value-of select="$cl/cenia/value[@name=$k]"/>
							     	</div>
						  		</xsl:for-each>
				  			</xsl:when>

				  			<!-- ISO 19119 -->
							<xsl:when test="contains(*/gmd:thesaurusName/*/gmd:title/*,'ISO - 19119') or contains(*/gmd:thesaurusName/*/gmd:title/*,'INSPIRE Services')">
								<i><b>ISO 19119:</b></i>
								<xsl:for-each select="*/gmd:keyword">
							     	<div style="margin-left:20px;">
							     		<xsl:variable name="k" select="*"/>
							     		<a href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/{$k}" target="_blank">
							     		<xsl:value-of select="$cl/serviceKeyword/value[@name=$k]"/></a>
							     	</div>
						  		</xsl:for-each>
				  			</xsl:when>

				  			<xsl:otherwise>
								<i><b><xsl:call-template name="multi">
						    		<xsl:with-param name="el" select="*/gmd:thesaurusName/*/gmd:title"/>
						    		<xsl:with-param name="lang" select="$lang"/>
						    		<xsl:with-param name="mdlang" select="$mdlang"/>
						  		</xsl:call-template>:</b></i>
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
								     		<xsl:when test="starts-with(*/@xlink:href, 'http://inspire.ec.europa.eu/theme')">
								     			<a href="{./*/@xlink:href}" title="{$theme}" target="_blank">
								     				<img src="{$MICKA_URL}/themes/default/img/inspire/{substring-after(./*/@xlink:href, 'theme/')}.png"/>
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
						     		<xsl:when test="starts-with(*/@xlink:href, 'http://inspire.ec.europa.eu/theme')">
						     			<a href="{./*/@xlink:href}" title="{$theme}" target="_blank">
						     				<img src="{$MICKA_URL}/themes/default/img/inspire/{substring-after(./*/@xlink:href, 'theme/')}.png"/>
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


				</td>
			</tr>

		<tr>
			<th><xsl:value-of select="$msg[@eng='Bounding box']"/></th>
			<td>

		<!--<xsl:if test="string-length(gmd:identificationInfo//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude)>0">-->
				<xsl:for-each select="gmd:identificationInfo//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
					<xsl:if test="gmd:westBoundLongitude!=''">
						<div id="r-1" itemscope="itemscope" itemtype="http://schema.org/GeoShape">
							<meta itemprop="box" id="i-1" content="{gmd:westBoundLongitude} {gmd:southBoundLatitude} {gmd:eastBoundLongitude} {gmd:northBoundLatitude}"/>
							<xsl:value-of select="gmd:westBoundLongitude"/>,
							<xsl:value-of select="gmd:southBoundLatitude"/>,
							<xsl:value-of select="gmd:eastBoundLongitude"/>,
							<xsl:value-of select="gmd:northBoundLatitude"/>
							<br/>
			                <!-- 
			                <xsl:variable name="extImage" select="php:function('drawMapExtent', 250, string(gmd:westBoundLongitude), string(gmd:southBoundLatitude), string(gmd:eastBoundLongitude), string(gmd:northBoundLatitude))"/>
			                <xsl:if test="$extImage!=''">
			                   <img class="bbox" src="{$extImage}"/>
			                </xsl:if> -->
		                </div>
	                </xsl:if>					
				</xsl:for-each>
       		</td>
		</tr>
		<!--</xsl:if>-->

		<tr>
			<th><xsl:value-of select="$msg[@eng='Date']"/></th>
			<td>
				<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
					<xsl:variable name="k" select="*/gmd:dateType/*/@codeListValue"/>
					<xsl:value-of select="$cl/dateType/value[@name=$k]"/>: <xsl:value-of select="*/gmd:date"/>
					<xsl:if test="not(position()=last())">, </xsl:if>	
				</xsl:for-each>
			</td>
		</tr>


		<xsl:if test="gmd:identificationInfo//gmd:temporalElement">
			<tr>
				<th><xsl:value-of select="$msg[@eng='Temporal extent']"/></th>
				<td>
					<xsl:for-each select="gmd:identificationInfo//gmd:temporalElement">				
						<xsl:choose>
							
							<!-- rozsah 1 --> 
							<xsl:when test="string-length(*/gmd:extent/*/gml:beginPosition|*/gmd:extent/*/gml32:beginPosition)>0">
								<xsl:choose>
									<xsl:when test="*//gml:endPosition|*//gml32:endPosition=9999">
										<xsl:value-of select="$msg[@eng='from']"/><xsl:text> </xsl:text><xsl:value-of select="php:function('drawDate', string(*//gml:beginPosition|*//gml32:beginPosition), $lang)"/>
									</xsl:when>
									<xsl:when test="*//gml:beginPosition|*//gml32:beginPosition=0001">
										<xsl:value-of select="$msg[@eng='to']"/><xsl:text> </xsl:text><xsl:value-of select="php:function('drawDate', string(*//gml:endPosition|*//gml32:endPosition), $lang)"/>								
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="php:function('drawDate', string(*//gml:beginPosition|*//gml32:beginPosition), $lang)"/> -
		      							<xsl:value-of select="php:function('drawDate', string(*//gml:endPosition|*//gml32:endPosition), $lang)"/>
									</xsl:otherwise>
								</xsl:choose>
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
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
		
		<xsl:if test="//gmd:spatialRepresentationType">
			<tr>
				<th>
					<xsl:value-of select="$msg[@eng='Spatial Representation']"/>
				</th>
				<td>
					<xsl:for-each select="//gmd:spatialRepresentationType">
						<xsl:variable name="sr" select="gmd:MD_SpatialRepresentationTypeCode"/>
						<xsl:value-of select="$cl/spatialRepresentationType/value[@name=$sr]"/>
						<xsl:if test="not(position()=last())">, </xsl:if>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>

		<tr>
			<th><xsl:value-of select="$msg[@eng='Contact Info']"/></th>
			<td>
				<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
					<xsl:apply-templates select="*"/>
					<xsl:if test="position()!=last()"><div style="margin-top:8px"></div></xsl:if>
				</xsl:for-each>
			</td>
		</tr>

	</table>
	</td>
	</tr>
	</table>
	
	<h3><xsl:value-of select="$msg[@eng='Data Quality']"/></h3>
	<table class="report">
		<tr>
		<!--  td class="subtitle">
			<xsl:call-template name="lf2br">
				<xsl:with-param name="str" select="$msg[@eng='Distribution']"/>
			</xsl:call-template>
		</td -->
		<td style="width:100%">
		<table class="report-right">				
			 <colgroup>
			   <col style="width: 160px;" />
			   <col style="width: 376px;" />
			</colgroup> 


		<xsl:if test="$srv!=1">

			<tr>
				<th>
					<xsl:value-of select="$msg[@eng='Lineage']"/>
				</th>
				<td>
					<xsl:variable name="sr" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>					
				</td>
			</tr>

			<xsl:if test="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:source">
				<tr>
					<th><xsl:value-of select="$msg[@eng='Sources']"/></th>
					<td>
					<xsl:for-each select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:source">
						<xsl:variable name="md" select="php:function('getData', string(*/gmd:sourceCitation/@xlink:href))"/>
  						<xsl:variable name="url">
				            <xsl:choose>
				  				<xsl:when test="$REWRITE">	
				  					<xsl:value-of select="concat($MICKA_URL,'/records/',$md//gmd:fileIdentifier)"/>
				  				</xsl:when>
				  				<xsl:otherwise>
				                	<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',$md//gmd:fileIdentifier)"/>
				  				</xsl:otherwise>
				  			</xsl:choose>
			            </xsl:variable>
						
						<div>
							<a href="{$url}">				
							<xsl:call-template name="multi">
								<xsl:with-param name="el" select="$md//gmd:title"/>
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="mdlang" select="$mdlang"/>
							</xsl:call-template>
							</a>
						</div>
					</xsl:for-each>
					</td>
				</tr>	
			</xsl:if>

			<tr>
			<th><xsl:value-of select="$msg[@eng='Spatial Resolution']"/></th>
			<td>
				<xsl:if test="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator!=''">
					<xsl:value-of select="$msg[@eng='Equivalent Scale']"/> =
  					<xsl:text> 1:</xsl:text>
					<xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator"/>
				</xsl:if>
				<xsl:if test="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance">
					<xsl:value-of select="$msg[@eng='Distance']"/> =
 					 <xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance/@uom"/>
				</xsl:if>
			</td>
			</tr>

		</xsl:if>
		<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_DomainConsistency]">
			<tr>
				<th><xsl:value-of select="$msg[@eng='Conformity']"/></th>
				<td>

					
					<xsl:for-each select="*/gmd:result">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:specification/*/gmd:title"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
						<hr/>
						<xsl:variable name="k" select="*/gmd:pass"/>
						<b><xsl:value-of select="$cl/compliant/value[@name=$k]"/></b>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:for-each>

	</table>
	</td>
	</tr>
	</table>
	
	<h3><xsl:value-of select="$msg[@eng='Constraints']"/></h3>
	<table class="report">
		<tr>
		<!--  td class="subtitle">
			<xsl:call-template name="lf2br">
				<xsl:with-param name="str" select="$msg[@eng='Distribution']"/>
			</xsl:call-template>
		</td -->
		<td style="width:100%">
		<table class="report-right">				
			 <colgroup>
			   <col style="width: 160px;" />
			   <col style="width: 376px;" />
			</colgroup> 
		<tr><th><xsl:value-of select="$msg[@eng='Use Limitation']"/></th>
			<td>
				<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints">
					<xsl:for-each select="*/gmd:useLimitation">
						<xsl:choose>
							<xsl:when test="contains(gmx:Anchor/@xlink:href,'://creativecommons.org')">
								<xsl:variable name="licence" select="substring-after(gmx:Anchor/@xlink:href,'creativecommons.org/licenses/')"/>							
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
			</td>
		</tr>

		<tr>
			<th><xsl:value-of select="$msg[@eng='Access Constraints']"/></th>
			<td>
				<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints">
					<xsl:for-each select="*/gmd:accessConstraints">
						<xsl:variable name="kod" select="*/@codeListValue"/>
						<div><xsl:value-of select="$cl/accessConstraints/value[@name=$kod]"/></div>
					</xsl:for-each>
					<xsl:for-each select="*/gmd:otherConstraints">
						<div>
							<xsl:call-template name="multi">
								<xsl:with-param name="el" select="."/>
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="mdlang" select="$mdlang"/>
							</xsl:call-template>
						</div>
					</xsl:for-each>
				</xsl:for-each>
			</td>
		</tr>

		<!-- <xsl:if test="gmd:distributionInfo/*/gmd:distributionFormat"> 
			<tr>
				<th><xsl:value-of select="$msg[@eng='Format']"/></th>
				<td>
					<xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
						<xsl:value-of select="*/gmd:name"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="*/gmd:version"/>
						<xsl:if test="position()!=last()">, </xsl:if>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>-->

		<!--<xsl:if test="gmd:distributionInfo//gmd:fees">
		  <tr>
		  	<th><xsl:value-of select="$msg[@eng='Fees']"/></th>
		  	<td><xsl:call-template name="multi">
					<xsl:with-param name="el" select="gmd:distributionInfo//gmd:fees"/>
					<xsl:with-param name="lang" select="$lang"/>
					<xsl:with-param name="mdlang" select="$mdlang"/>
				</xsl:call-template>
		  	</td>
		  </tr>
		</xsl:if>-->
		
		<!--<xsl:if test="gmd:distributionInfo//gmd:orderingInstructions">
		  <tr>
		  	<th><xsl:value-of select="$msg[@eng='Ordering Instructions']"/></th>
		  	<td><xsl:call-template name="multi">
					<xsl:with-param name="el" select="gmd:distributionInfo//gmd:orderingInstructions"/>
					<xsl:with-param name="lang" select="$lang"/>
					<xsl:with-param name="mdlang" select="$mdlang"/>
				</xsl:call-template>
		  	</td>
		  </tr>
		</xsl:if>-->
		<!--
		  <tr>
		  	<th><xsl:value-of select="$msg[@eng='Distributor']"/></th>
		  	<td>				
		  		<xsl:for-each select="gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorContact">
					<xsl:apply-templates select="*"/>
					<xsl:if test="position()!=last()"><div style="margin-top:8px"></div></xsl:if>
				</xsl:for-each>
			</td>
		  </tr>-->
		
	</table>
	</td>
	</tr>
	</table>
	
	<!-- metadata -->
	<h3><xsl:value-of name="str" select="$msg[@eng='Metadata Metadata']"/></h3>
	<table class="report">
		<tr><!-- td class="subtitle">
			<xsl:call-template name="lf2br">
				<xsl:with-param name="str" select="$msg[@eng='Metadata Metadata']"/>
			</xsl:call-template>
		</td-->
		<td style="width:100%"><table class="report-right">
				<colgroup>
			        <col style="width: 160px;" />
			        <col style="width: 376px;" />
			    </colgroup>	
		 <tr>	
			<th><xsl:value-of select="$msg[@eng='MDIdentifier']"/></th>
			<td><xsl:value-of select="gmd:fileIdentifier"/></td>
		</tr>
	    <xsl:if test="gmd:parentIdentifier!=''">
			<xsl:variable name="pilink" select="php:function('getMetadata', concat('identifier=', $apos, gmd:parentIdentifier/*, $apos))"/>
			<tr>
				<th><xsl:value-of select="$msg[@eng='Parent Identifier']"/></th>
				<td>
					<xsl:value-of select="gmd:parentIdentifier"/>
				</td>
			</tr>
		</xsl:if>
		 <tr>
			<th><xsl:value-of select="$msg[@eng='Metadata Contact']"/></th>
			<td>
				<xsl:for-each select="gmd:contact">
					<xsl:apply-templates select="*"/>
					<xsl:if test="position()!=last()"><div style="margin-top:8px"></div></xsl:if>
				</xsl:for-each>
			</td>
		</tr> 
		<tr>
			<th><xsl:value-of select="$msg[@eng='Date Stamp']"/></th>
			<td><xsl:value-of select="php:function('drawDate', string(gmd:dateStamp/*), $lang)"/></td>
		</tr>

		<tr>
			<th><xsl:value-of select="$msg[@eng='Language']"/></th>
			<td><xsl:value-of select="$cl/language/value[@code=$lang]"/></td>
		</tr>
	</table>
	</td></tr></table>
	
	<h3><xsl:value-of select="$msg[@eng='Coupled Resource']"/></h3>
	<table class="report">
		<tr><!-- td class="subtitle"><xsl:value-of select="$msg[@eng='Coupled Resource']"/>
		</td-->
		<td style="width:100%"><table class="report-right">
			<colgroup>
			    <col style="width: 160px;" />
				<col style="width: 376px;" />
			</colgroup>	

		<!-- ===VAZBY=== -->
		
		<!-- sluzby -->
		<xsl:variable name="vazby" select="php:function('getMetadata', concat('uuidRef=',gmd:fileIdentifier/*))"/>
		<tr><th><xsl:value-of select="$msg[@eng='Used']"/></th>
		<td>
			<xsl:for-each select="$vazby//gmd:MD_Metadata">
                <xsl:variable name="url">
                    <xsl:choose>
						<xsl:when test="$REWRITE">	
							<xsl:value-of select="concat($MICKA_URL,'/records/',gmd:fileIdentifier)"/>
						</xsl:when>
						<xsl:otherwise>
                        	<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',gmd:fileIdentifier)"/>
						</xsl:otherwise>
					</xsl:choose>
                </xsl:variable>

				<div><a href="{$url}" class="t {gmd:hierarchyLevel/*/@codeListValue}" title="{$cl/updateScope/value[@name=$vazby[position()]//gmd:hierarchyLevel/*/@codeListValue]}">
					<!-- <xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/> -->
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>
				</a></div>
			</xsl:for-each>	
		</td></tr>	
		
		<!-- parent -->
		<xsl:if test="gmd:parentIdentifier!=''">
			<xsl:variable name="pilink" select="php:function('getMetadata', concat('identifier=', $apos, gmd:parentIdentifier/*, $apos))"/>
			<tr>
				<th><xsl:value-of select="$msg[@eng='Parent']"/></th>
				<td>
					<xsl:variable name="a" select="$pilink//gmd:hierarchyLevel/*/@codeListValue"/>
	                <xsl:variable name="url">
	                    <xsl:choose>
							<xsl:when test="$REWRITE">	
								<xsl:value-of select="concat($MICKA_URL,'/records/',$pilink//gmd:fileIdentifier)"/>
							</xsl:when>
							<xsl:otherwise>
	                        	<xsl:value-of select="concat($MICKA_URL,'?ak=xml&amp;uuid=',$pilink//gmd:fileIdentifier)"/>
							</xsl:otherwise>
						</xsl:choose>
	                </xsl:variable>

					<a class="t {$a}" href="{$url}" title="{$cl/updateScope/value[@name=$a]}">
						<!-- <xsl:value-of select="$pilink//gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/> -->
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="$pilink//gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
					</a>
				</td>
			</tr>
		</xsl:if>
		
		<!-- podrizene -->
		<xsl:variable name="subsets" select="php:function('getMetadata', concat('ParentIdentifier=', $apos, gmd:fileIdentifier/*, $apos))"/>		
		<xsl:if test="$subsets//gmd:MD_Metadata">
			<tr>
				<th><xsl:value-of select="$msg[@eng='Children']"/></th>
				<td>
					<xsl:for-each select="$subsets//gmd:MD_Metadata">
						<xsl:variable name="a" select="gmd:hierarchyLevel/*/@codeListValue"/>
  						<xsl:variable name="url">
				            <xsl:choose>
				  				<xsl:when test="$REWRITE">	
				  					<xsl:value-of select="concat($MICKA_URL,'/records/',gmd:fileIdentifier)"/>
				  				</xsl:when>
				  				<xsl:otherwise>
				                	<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',gmd:fileIdentifier)"/>
				  				</xsl:otherwise>
				  			</xsl:choose>
			            </xsl:variable>

						<div><a href="{$url}" class="t {$a}" title="{$cl/updateScope/value[@name=$a]}">
							<!-- <xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/>-->
							<xsl:call-template name="multi">
								<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
								<xsl:with-param name="lang" select="$lang"/>
								<xsl:with-param name="mdlang" select="$mdlang"/>
							</xsl:call-template>							 
						</a></div>
					</xsl:for-each>
					<xsl:if test="$subsets//csw:SearchResults/@numberOfRecordsMatched &gt; 25">
						<div>
							<a href="{$MICKA_URL}?request=GetRecords&amp;format=text/html&amp;language={$lang}&amp;query=parentIdentifier={gmd:fileIdentifier/*}">See all <xsl:value-of select="$subsets//csw:SearchResults/@numberOfRecordsMatched"/> children ...</a>
						</div>
					</xsl:if>
				</td>
			</tr>	
		</xsl:if>
		
		<!-- sourozenci -->
		<xsl:if test="gmd:parentIdentifier!=''">
			<xsl:variable name="siblinks" select="php:function('getMetadata', concat('ParentIdentifier=',$apos, gmd:parentIdentifier/*,$apos))"/>
			<xsl:if test="count($siblinks) &gt; 1">
				<xsl:variable name="myid" select="gmd:fileIdentifier/*"/>
				<tr>
					<th><xsl:value-of select="$msg[@eng='Siblinks']"/></th>
					<td>
						<xsl:for-each select="$siblinks//gmd:MD_Metadata[gmd:fileIdentifier/*!=$myid]">
							<xsl:variable name="a" select="gmd:hierarchyLevel/*/@codeListValue"/>
							<xsl:variable name="url">
                				<xsl:choose>
    					  			<xsl:when test="$REWRITE">	
    									<xsl:value-of select="concat($MICKA_URL,'/records/',gmd:fileIdentifier)"/>
    								</xsl:when>
    					   			<xsl:otherwise>
                  						<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',gmd:fileIdentifier)"/>
    					   			</xsl:otherwise>
    				    		</xsl:choose>
              				</xsl:variable>

							<div><a href="{$url}" class="t {$a}"  title="{$cl/updateScope/value[@name=$a]}">
								<!-- <xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/> -->
								<xsl:call-template name="multi">
									<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
									<xsl:with-param name="lang" select="$lang"/>
									<xsl:with-param name="mdlang" select="$mdlang"/>
								</xsl:call-template>							 
							</a></div>
					</xsl:for-each>
				</td></tr>
			</xsl:if>
		</xsl:if>

		<!-- 1.6 sluzby - operatesOn NOVA VERZE -->
		<xsl:if test="gmd:identificationInfo/srv:SV_ServiceIdentification">
			<tr>
				<th><xsl:value-of select="$msg[@eng='Use']"/></th>
				<td>
					 <xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn">
						<!--xsl:variable name="siblinks" select="php:function('getMetadata', concat('identifier=',$opid))"/-->
						<xsl:variable name="siblinks" select="php:function('getData', string(@xlink:href))"/>
						<xsl:for-each select="$siblinks//gmd:MD_Metadata">
							<xsl:variable name="a" select="gmd:hierarchyLevel/*/@codeListValue"/>
							<xsl:variable name="url">
					        	<xsl:choose>
					    			<xsl:when test="$REWRITE">	
					    				<xsl:value-of select="concat($MICKA_URL,'/records/',normalize-space(gmd:fileIdentifier))"/>
					    			</xsl:when>
					    			<xsl:otherwise>
					            	  	<xsl:value-of select="concat($MICKA_URL,'?ak=detail&amp;uuid=',normalize-space(gmd:fileIdentifier))"/>
					    			</xsl:otherwise>
					    		</xsl:choose>
					        </xsl:variable>

							<div><a href="{$url}" class="t {$a}"  title="{$cl/updateScope/value[@name=$a]}">
									<xsl:call-template name="multi">
										<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
										<xsl:with-param name="lang" select="$lang"/>
										<xsl:with-param name="mdlang" select="$mdlang"/>
									</xsl:call-template>							 
								</a></div>
						</xsl:for-each>
					</xsl:for-each>
				</td>	
			</tr>
		</xsl:if>

		<!-- Citace FC -->
		<xsl:for-each select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
			<tr>
				<th>
					<xsl:value-of select="$msg[@eng='Feature catalogue']"/>
				</th>
				<td>
					<!-- <xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:title"/> -->
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="gmd:featureCatalogueCitation/*/gmd:title"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>							 

					<xsl:variable name="url">
						<xsl:if test="gmd:featureCatalogueCitation/*/gmd:identifier">
							<xsl:choose>
								<xsl:when test="$REWRITE">	
									<xsl:value-of select="concat($MICKA_URL, '/records/', gmd:featureCatalogueCitation/*/gmd:identifier, '?language=', $lang)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($MICKA_URL, '?ak=detailall&amp;uuid=', gmd:featureCatalogueCitation/*/gmd:identifier, '&amp;language=', $lang)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:variable>

					<xsl:if test="gmd:featureCatalogueCitation/*/gmd:identifier"> 
						[<a href="{$url}"><xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:identifier"/></a>]
					</xsl:if>
					
					<xsl:for-each select="gmd:featureTypes">
						<div>
						  	<xsl:choose>
  						  		<xsl:when test="$url">
  							   		<a href="{$url}#{*}" class="t fc"><xsl:value-of select="*"/></a>
  								</xsl:when>
  								<xsl:otherwise>
  							   		<a class="t fc"><xsl:value-of select="*"/></a>
  								</xsl:otherwise>
              				</xsl:choose>   
						</div>						
					</xsl:for-each>
				</td>
			</tr>
		</xsl:for-each>		
		
		</table>
		</td></tr></table>
		<xsl:if test="../@read=1">
		    <div style="text-align:center; padding:7px;">
				<xsl:choose>
					<xsl:when test="$REWRITE">	
						<a class="xfullBottom" href="{$MICKA_URL}/records/{../@uuid}?detail=full&amp;language={$lang}" title="{$msg[@eng='fullMetadata']}"><i class="fa fa-folder-open-o fa-fw icons"></i> <xsl:value-of select="$msg[@eng='fullMetadata']"/></a>
					</xsl:when>
					<xsl:otherwise>
						<a class="xfullBottom" href="{$MICKA_URL}?ak=detailall&amp;uuid={../@uuid}" title="{$msg[@eng='fullMetadata']}"><i class="fa fa-folder-open-o fa-fw"></i> <xsl:value-of select="$msg[@eng='fullMetadata']"/></a>
					</xsl:otherwise>
				</xsl:choose>
        	</div>
		</xsl:if>
	</xsl:template>
	
	<!-- Zpracovani DC -->
	<xsl:template match="csw:Record" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/">
		<h1>
		<div class="cat-{translate(dc:type,$upper,$lower)}">
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
		</div>
		</h1>
		<h2>
			Dublin Core metadata
			<div class="detail icons">
				<xsl:if test="../@edit=1">
					<a href="{$MICKA_URL}?ak=edit&amp;recno={../@recno}" class="edit" title="{$msg[@eng='edit']}"> </a>				
					<a href="{$MICKA_URL}?ak=copy&amp;recno={../@recno}" class="copy" title="{$msg[@eng='clone']}"> </a>				
					<a href="javascript:md_delrec({../@recno});" class="delete" title="{$msg[@eng='delete']}"> </a>				
				</xsl:if>
				<a href="{$MICKA_URL}?ak=xml&amp;uuid={../@uuid}" class="xml" target="_blank" title="XML"> </a>
			</div>
			<xsl:value-of select="$msg[@eng='basic']"/>
		</h2>
		
		<table class="report-right">
			<xsl:for-each select="*">
				<!-- TODO dodelat vzhled -->
				<tr>
					<td class="subtitle">
						<xsl:variable name="itemName" select="substring-after(name(),':')"/>
						<xsl:value-of select="$msg[translate(@eng,$upper,$lower)=$itemName]"/>
					</td>
					<td>
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
					</td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select="ows:BoundingBox">
				<tr>
					<th/>
					<td>
						<div id="extMap" style="position:relative"/>
						<span class="geo">
							<xsl:value-of select="$msg[@eng=west]"/>:
      							<span id="westBoundLongitude" class="longitude">
								<xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
							</span>,
      <xsl:value-of select="$msg/south"/>:
      <span id="southBoundLatitude" class="latitude">
								<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/>
							</span>,
    </span>
						<span class="geo">
							<xsl:value-of select="$msg/east"/>:
      <span id="eastBoundLongitude" class="longitude">
								<xsl:value-of select="substring-before(ows:UpperCorner,' ')"/>
							</span>,
      <xsl:value-of select="$msg/north"/>:
      <span id="northBoundLatitude" class="latitude">
								<xsl:value-of select="substring-after(ows:UpperCorner,' ')"/>
							</span>
						</span>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<!-- Zpracovani FC -->
	<xsl:template match="gfc:FC_FeatureCatalogue">
		<xsl:variable name="mdLang" select="*/gmx:language/*/@codeListValue"/>
		<h1>
			<xsl:call-template name="multi">
				<xsl:with-param name="el" select="gmx:name"/>
				<xsl:with-param name="lang" select="$lang"/>
				<xsl:with-param name="mdlang" select="$mdLang"/>
			</xsl:call-template>
		</h1>
		<h2 style="height:32px;">
			<div class="icons">
				<xsl:if test="../@edit=1">
					<a href="{$MICKA_URL}?ak=edit&amp;recno={../@recno}" class="edit" title="{$msg[@eng='edit']}"><i class="fa fa-pencil fa-fw"></i></a>				
					<a href="{$MICKA_URL}?ak=copy&amp;recno={../@recno}" class="copy" title="{$msg[@eng='clone']}"><i class="fa fa-clone fa-fw"></i></a>				
					<a href="javascript:md_delrec({../@recno});" class="delete" title="{$msg[@eng='delete']}"><i class="fa fa-trash fa-fw"></i></a>				
				</xsl:if>
				<a href="{$MICKA_URL}?ak=xml&amp;uuid={../@uuid}" class="xml" target="_blank" title="XML"></a>
				<xsl:choose>
					<xsl:when test="$REWRITE">	
						<a href="{$MICKA_URL}/records/{../@uuid}?format=application/xml" class="xml" target="_blank" title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
					</xsl:when>
					<xsl:otherwise>
						<a href="{$MICKA_URL}?ak=xml&amp;uuid={../@uuid}" class="xml" target="_blank" title="XML"><i class="fa fa-file-code-o fa-fw"></i></a>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<xsl:value-of select="$msg[@eng='Feature catalogue']"/>
		</h2>

	<table class="report-right">
		
		<tr>
			<th>
				<xsl:value-of select="$msg[@eng='Contact Info']"/>
			</th>
			<td>
				<xsl:for-each select="gfc:producer">
					<xsl:if test="position() > 1"><div class="row"> </div></xsl:if>
					<xsl:if test="*/gmd:organisationName">
						<b><xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:organisationName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdLang"/>
						</xsl:call-template></b>
						<br/>
					</xsl:if>
					<xsl:if test="*/gmd:individualName">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:individualName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdLang"/>
						</xsl:call-template>
						<br/>
					</xsl:if>
					<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/>,
  	  				<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:city"/>,
      				<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/>
					<br/>
					<xsl:for-each select="*/gmd:contactInfo/*/gmd:onlineResource">
      					<a href="{*/gmd:linkage}" target="_blank"><xsl:value-of select="*/gmd:linkage"/></a><br/>
      				</xsl:for-each>
      				tel: <xsl:value-of select="*/gmd:contactInfo/*/gmd:phone/*/gmd:voice"/>,
      				email: <xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/>
					<xsl:variable name="kod" select="*/gmd:role/*/@codeListValue"/>
					<br/>
					<xsl:value-of select="$msg[@eng='role']"/>: <xsl:value-of select="$cl/role/value[@name=$kod]"/>
				</xsl:for-each>
			</td>
		</tr>
		
		<xsl:variable name="vazby" select="php:function('getMetadata', concat('FcIdentifier=',$ID))"/>
		<xsl:if test="$vazby//gmd:MD_Metadata">
			<tr>
				<th>
					<xsl:value-of select="$msg[@eng='Coupled Resource']"/>
				</th>
				<td>
					<xsl:for-each select="$vazby//gmd:MD_Metadata">
						<div>
							<xsl:choose>
								<xsl:when test="$REWRITE">	
										<a href="{$MICKA_URL}/records/{gmd:fileIdentifier}?language={$lang}" title="Metadata">
											<xsl:call-template name="multi">
												<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
												<xsl:with-param name="lang" select="$lang"/>
												<xsl:with-param name="mdlang" select="$mdLang"/>
											</xsl:call-template>							 											
										</a>
									</xsl:when>
								<xsl:otherwise>
										<a href="{$MICKA_URL}?request=GetRecordById&amp;id={gmd:fileIdentifier}&amp;format=text/html&amp;language={$lang}" title="Metadata">
											<xsl:call-template name="multi">
												<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
												<xsl:with-param name="lang" select="$lang"/>
												<xsl:with-param name="mdlang" select="$mdLang"/>
											</xsl:call-template>							 											
										</a>
								</xsl:otherwise>
							</xsl:choose>


						</div>	
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
	</table>
		
		<xsl:for-each select="gfc:featureType">
			<a name="{*/gfc:typeName}"/>
			<br/><br/>
			<h3><xsl:value-of select="*/gfc:typeName"/></h3>
			<table class="report-right">
				<colgroup>
					<col style="width:10%"/>
					<col style="width:30%"/>
					<col style="width:10%"/>
					<col style="width:5%"/>
					<col style="width:15%"/>
					<col style="width:30%"/>
			    </colgroup>	
				<xsl:if test="code">
					<tr>
						<th>Název</th>
						<td colspan="5"><xsl:value-of select="gco:LocalName"/></td>
					</tr>
				</xsl:if>
				<tr><th>Definice</th>
				<td colspan="5">
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="*/gfc:definition"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="*/gmd:language/gmd:LanguageCode/@codeListValue"/>
					</xsl:call-template>				
				
				<xsl:value-of select="*/gfc:definition"/></td></tr>
				 <tr><th colspan="6" style="background: #F8F8F8">Atributy:</th></tr>
					
					<!-- atributy --> 
					
					<tr>
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
							<td><xsl:value-of select="*/gfc:valueMeasurementUnit/*/gml32:identifier"/></td>
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
		</xsl:for-each>
	</xsl:template>


	<!-- pro kontakty -->
	<xsl:template match="gmd:CI_ResponsibleParty">
		<div>
		<xsl:if test="gmd:organisationName">
			<xsl:call-template name="multi">
				<xsl:with-param name="el" select="gmd:organisationName"/>
				<xsl:with-param name="lang" select="$lang"/>
				<xsl:with-param name="mdlang" select="$mdlang"/>
			</xsl:call-template>
			<br/>
		</xsl:if>
		<xsl:if test="gmd:individualName">
			<xsl:call-template name="multi">
				<xsl:with-param name="el" select="gmd:individualName"/>
				<xsl:with-param name="lang" select="$lang"/>
				<xsl:with-param name="mdlang" select="$mdlang"/>
			</xsl:call-template>
		</xsl:if>
		<div>
			<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint">
				<xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/>,
			</xsl:if>
	  		<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:city">
	  			<xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:city"/> 
	  		</xsl:if>
	  		<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:postalCode">,
	    		<xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/>
	    	</xsl:if>
	  		<xsl:if test="gmd:contactInfo/*/gmd:address/*/gmd:country">, 
   				<xsl:value-of select="gmd:contactInfo/*/gmd:address/*/gmd:country"/>
   			</xsl:if>		
		</div>
		<xsl:for-each select="gmd:contactInfo/*/gmd:onlineResource[gmd:URL!='']">
      		<div><a href="{gmd:linkage}" target="_blank">><xsl:value-of select="gmd:linkage"/></a></div>
      	</xsl:for-each>
      	<xsl:for-each select="gmd:contactInfo/*/gmd:phone/*/gmd:voice">
      		<div>tel: <xsl:value-of select="."/></div>
      	</xsl:for-each>
      	<xsl:for-each select="gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress">
      		<div>email: <xsl:value-of select="."/></div>
    		</xsl:for-each>
		<xsl:variable name="kod" select="gmd:role/*/@codeListValue"/>
		 <xsl:value-of select="$msg[@eng='role']"/>: <b><xsl:value-of select="$cl/role/value[@name=$kod]"/></b>
		 </div> 
	</xsl:template>
	

</xsl:stylesheet>
