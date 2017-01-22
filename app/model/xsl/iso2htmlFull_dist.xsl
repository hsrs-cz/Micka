<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:php="http://php.net/xsl" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
	xmlns:ows="http://www.opengis.net/ows" 
	xmlns:srv="http://www.isotc211.org/2005/srv" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gmi="http://www.isotc211.org/2005/gmi" 
	xmlns:gml="http://www.opengis.net/gml/3.2" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:gco="http://www.isotc211.org/2005/gco">
	<xsl:output method="html"/>

	<xsl:variable name="msg" select="document(concat('client/labels-', $lang, '.xml'))/messages"/>
	<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
	<xsl:variable name="cl" select="document(concat('codelists_', $lang, '.xml'))/map"/>
	<xsl:variable name="MICKA_URL" select="''"/>

	<xsl:template match="/">
		<!-- ikonky vpravo -->
		<xsl:for-each select="//rec">
		<div class="icons">
		  	<xsl:if test="contains(*/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage,'WMS')">
		    	<a class='map' href="http://geoportal.gov.cz/web/guest/map?wms={substring-before(*/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage,'?')}" target="wmsviewer"> </a>
		  	</xsl:if>
			<xsl:if test="@edit=1">
				<xsl:if test="@md_standard=0 or @md_standard=10">
					<a href="{$MICKA_URL}?ak=valid&amp;uuid={@uuid}" class="valid{@valid}"> </a>
				</xsl:if>					
				<a href="{$MICKA_URL}?ak=edit&amp;recno={@recno}" class="edit"> </a>				
				<a href="{$MICKA_URL}?ak=copy&amp;recno={@recno}" class="copy"> </a>				
				<a href="javascript:md_delrec({@recno});" class="delete"> </a>				
			</xsl:if>
			<a href="{$MICKA_URL}?ak=xml&amp;uuid={@uuid}" class="xml" target="_blank"> </a>
		</div>
		</xsl:for-each>

		<xsl:apply-templates select="gmd:MD_Metadata|gmi:MI_Metadata"/>
		<xsl:apply-templates select="//csw:GetRecordByIdResponse/*"/>
	</xsl:template>
	
	<xsl:template match="gmd:MD_Metadata|gmi:MI_Metadata"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
	xmlns:ows="http://www.opengis.net/ows" 
	xmlns:srv="http://www.isotc211.org/2005/srv" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gmi="http://www.isotc211.org/2005/gmi" 
	xmlns:gml="http://www.opengis.net/gml/3.2" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:gco="http://www.isotc211.org/2005/gco">
		<xsl:variable name="mdlang" select="gmd:language/gmd:LanguageCode/@codeListValue"/>
		<xsl:variable name="rtype">
		  <xsl:choose>
		    <xsl:when test="contains(gmd:hierarchyLevelName,'spatialPlan')">sp</xsl:when>
			<xsl:otherwise><xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/></xsl:otherwise>
		  </xsl:choose>
  		</xsl:variable>
<h1>
	<div class="{$rtype}" style="padding-left: 20px;"><xsl:call-template name="multi">
		<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>
		<xsl:with-param name="lang" select="$lang"/>
		<xsl:with-param name="mdlang" select="$mdlang"/>
	</xsl:call-template></div>
</h1>

		<!-- identifikace --> 
		<h2>
			<xsl:value-of select="$msg/msg[@eng='Identification']"/>
		</h2>
		<!-- <div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Title']"/>
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
		<xsl:if test="gmd:identificationInfo/*/gmd:citation/*/gmd:alternateTitle!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Alternate Title']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:alternateTitle">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="."/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</div>		
		</xsl:if>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Abstract']"/>
			</div>
			<div class="r" style="text-align: justify">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="."/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Resource type']"/>
			</div>
			<div class="r">
				<xsl:variable name="hl" select="gmd:hierarchyLevel/*/@codeListValue"/>
				<xsl:value-of select="$cl/updateScope/value[@name=$hl]"/>
				<xsl:if test="gmd:hierarchyLevelName != ''">
					- <xsl:value-of select="gmd:hierarchyLevelName"/>
				</xsl:if>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Resource Locator']"/>
			</div>
			<div class="r">
				<xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
					<a href="{*/gmd:linkage}"><xsl:value-of select="*/gmd:linkage"/></a>
					<xsl:if test="position()!=last()">
						<br/>
					</xsl:if>
				</xsl:for-each>
			</div>
		</div>
		<div class="row">
			<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Identifier']"/>
				</div>
				<div class="r">
					<xsl:if test="*/gmd:codeSpace!=''">
						<xsl:value-of select="*/gmd:codeSpace"/>#</xsl:if>
					<xsl:value-of select="*/gmd:code"/>
				</div>
			</xsl:for-each>
		</div>
		
		<xsl:if test="gmd:identificationInfo/*/gmd:language/*/@codeListValue">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Language']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:identificationInfo/*/gmd:language">
						<xsl:variable name="kod" select="*/@codeListValue"/>
						<xsl:value-of select="$cl/language/value[@code=$kod]"/>
						<xsl:if test="position()!=last()">, </xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		
		<xsl:if test="gmd:identificationInfo/*/gmd:topicCategory/gmd:MD_TopicCategoryCode!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Topic category']"/>
				</div>
				<div class="r">
					<xsl:for-each select="//gmd:topicCategory">
						<xsl:variable name="kod" select="gmd:MD_TopicCategoryCode"/>
						<xsl:value-of select="$cl/topicCategory/value[@name=$kod]"/>
						<xsl:if test="position()!=last()">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="//gmd:descriptiveKeywords!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Keywords']"/>
				</div>
				<div class="r">
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
							<xsl:when test="contains(*/gmd:thesaurusName/*/gmd:title/*,'ISO 19119')">
								<i><b>ISO 19119:</b></i>
								<xsl:for-each select="*/gmd:keyword">
							     	<div style="margin-left:20px;">
							     		<xsl:variable name="k" select="*"/>
							     		<xsl:value-of select="$cl/serviceKeyword/value[@name=$k]"/>
							     	</div>
						  		</xsl:for-each>
				  			</xsl:when>

				  			<xsl:otherwise>
								<i><b><xsl:call-template name="multi">
						    		<xsl:with-param name="el" select="*/gmd:thesaurusName/*/gmd:title"/>
						    		<xsl:with-param name="lang" select="$lang"/>
						    		<xsl:with-param name="mdlang" select="$mdlang"/>
						  		</xsl:call-template>:</b></i>
								<xsl:for-each select="*/gmd:keyword">
							     	<div style="margin-left:20px;"><xsl:call-template name="multi">
							    		<xsl:with-param name="el" select="."/>
							    		<xsl:with-param name="lang" select="$lang"/>
							    		<xsl:with-param name="mdlang" select="$mdlang"/>
							  		</xsl:call-template></div>
						  		</xsl:for-each>
				  			</xsl:otherwise>
				  		</xsl:choose>
					</xsl:for-each>

					<xsl:for-each select="//gmd:descriptiveKeywords[string-length(*/gmd:thesaurusName/*/gmd:title/*)=0]">
						<div>
							<i><b><xsl:value-of select="$msg/msg[@eng='Free']"/></b></i>
							<xsl:for-each select="*/gmd:keyword">
						     	<div style="margin-left:20px;"><xsl:call-template name="multi">
						    		<xsl:with-param name="el" select="."/>
						    		<xsl:with-param name="lang" select="$lang"/>
						    		<xsl:with-param name="mdlang" select="$mdlang"/>
						  		</xsl:call-template></div>
					  		</xsl:for-each>
					  	</div>
					</xsl:for-each>


				</div>
			</div>
		</xsl:if>
		<xsl:if test="string-length(gmd:identificationInfo//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude)>0">
			<xsl:for-each select="gmd:identificationInfo//gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
				<div class="row">
					<div class="l">
						<xsl:value-of select="$msg/msg[@eng='Bounding box']"/>
					</div>
					<div class="r">
						<xsl:value-of select="gmd:westBoundLongitude"/>,
					    <xsl:value-of select="gmd:southBoundLatitude"/>,
					    <xsl:value-of select="gmd:eastBoundLongitude"/>,
					    <xsl:value-of select="gmd:northBoundLatitude"/>
						<br/>
                        <xsl:variable name="extImage" select="php:function('drawMapExtent', 250, string(gmd:westBoundLongitude), string(gmd:southBoundLatitude), string(gmd:eastBoundLongitude), string(gmd:northBoundLatitude))"/>
                        <xsl:if test="$extImage!=''">
                            <img class="bbox" src="{$extImage}"/>
                        </xsl:if>					
       				</div>
				</div>
			</xsl:for-each>
		</xsl:if>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Temporal extent']"/>
			</div>
			<div class="r">
				<xsl:choose>
					<xsl:when test="string-length(gmd:identificationInfo//gmd:temporalElement//gml:beginPosition)>0">
						<xsl:value-of select="gmd:identificationInfo//gmd:temporalElement//gml:beginPosition"/> -
      <xsl:value-of select="gmd:identificationInfo//gmd:temporalElement//gml:endPosition"/>
					</xsl:when>
					<xsl:when test="string-length(gmd:identificationInfo//gmd:temporalElement//gml:begin)>0">
						<xsl:value-of select="gmd:identificationInfo//gmd:temporalElement//gml:begin"/> -
      <xsl:value-of select="gmd:identificationInfo//gmd:temporalElement//gml:end"/>
					</xsl:when>
					<xsl:when test="gmd:identificationInfo//gmd:temporalElement//gml:TimeInstant!=''">
						<xsl:for-each select="gmd:identificationInfo//gmd:temporalElement//gml:TimeInstant">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">, </xsl:if>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Date']"/>
			</div>
			<div class="r">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">
					<xsl:variable name="kod" select="*/gmd:dateType"/>
					<xsl:value-of select="$cl/dateType/value[@name=$kod]"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="*/gmd:date"/>
					<xsl:text>  </xsl:text>
				</xsl:for-each>
			</div>
		</div>

		<!-- 6.1 -->
		<xsl:if test="$rtype!='service'">
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Lineage']"/>
			</div>
			<div class="r">
				<xsl:call-template name="multi">
					<xsl:with-param name="el" select="//gmd:lineage/*/gmd:statement"/>
					<xsl:with-param name="lang" select="$lang"/>
					<xsl:with-param name="mdlang" select="$mdlang"/>
				</xsl:call-template>
			</div>
		</div>
		</xsl:if>

		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Spatial Resolution']"/>
			</div>
			<div class="r">
				<xsl:if test="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator!=''">
					<xsl:value-of select="$msg/msg[@eng='Equivalent Scale']"/> =
  <xsl:text> 1:</xsl:text>
					<xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator"/>
				</xsl:if>
				<xsl:if test="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance">
					<xsl:value-of select="$msg/msg[@eng='Distance']"/> =
  <xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance/@uom"/>
				</xsl:if>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Use Limitation']"/>
			</div>
			<div class="r">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints">
					<xsl:for-each select="*/gmd:useLimitation">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="."/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
						<xsl:if test="position()!=last()">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Access Constraints']"/>
			</div>
			<div class="r">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:resourceConstraints">
					<xsl:for-each select="*/gmd:accessConstraints">
						<xsl:variable name="kod" select="*/@codeListValue"/>
						<xsl:value-of select="$cl/accessConstraints/value[@name=$kod]"/>
					</xsl:for-each>
					<xsl:if test="*/gmd:accessConstraints!='' and */gmd:otherConstraints!=''">
						<br/>
					</xsl:if>
					<xsl:for-each select="*/gmd:otherConstraints">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="."/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
						<xsl:if test="position()!=last()">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Contact Info']"/>
			</div>
			<div class="r">
				<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
					<xsl:if test="position() > 1"><div class="row"> </div></xsl:if>
					<xsl:if test="*/gmd:organisationName">
						<b><xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:organisationName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template></b>
						<br/>
					</xsl:if>
					<xsl:if test="*/gmd:individualName">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:individualName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
						<br/>
					</xsl:if>
					<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/>,
  	  				<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:city"/>,
      				<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/>
					<br/>
					<xsl:for-each select="*/gmd:contactInfo/*/gmd:onlineResource">
      					<a href="*/gmd:linkage"><xsl:value-of select="*/gmd:linkage"/></a><br/>
      				</xsl:for-each>
      				tel: <xsl:value-of select="*/gmd:contactInfo/*/gmd:phone/*/gmd:voice"/>,
      				email: <xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/>
					<br/>
					<xsl:variable name="kod" select="*/gmd:role/*/@codeListValue"/>
					<xsl:value-of select="$msg/msg[@eng='role']"/>: <xsl:value-of select="$cl/role/value[@name=$kod]"/>
				</xsl:for-each>
			</div>
		</div>
		<xsl:if test="//gmd:spatialRepresentationType!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Spatial Representation']"/>
				</div>
				<div class="r">
					<xsl:variable name="sr" select="//gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode"/>
					<xsl:value-of select="$cl/spatialRepresentationType/value[@name=$sr]"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="//srv:serviceType!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Service Type']"/>
				</div>
				<div class="r">
					<xsl:value-of select="//srv:serviceType"/>
					<xsl:for-each select="//srv:serviceTypeVersion">
						<xsl:text> </xsl:text>
						<xsl:value-of select="//srv:serviceTypeVersion"/>
						<xsl:if test="not(position()=last())">,</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="string-length(gmd:identificationInfo//gmd:graphicOverview/gmd:fileName)>0">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Browse Graphic']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:identificationInfo//gmd:graphicOverview">
	  					<xsl:if test="string-length(gmd:identificationInfo//gmd:graphicOverview/*/gmd:fileDescription)>0">
	  						<div><xsl:value-of select="gmd:identificationInfo//gmd:graphicOverview/*/gmd:fileDescription"/></div>
	  					</xsl:if>
						<img src="{normalize-space(*/gmd:fileName)}" style="border: gray 1px solid"/>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		<!--
		<xsl:if test="gmd:identificationInfo/*/srv:coupledResource!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Coupled Resource']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:identificationInfo/*/srv:coupledResource">
						<xsl:value-of select="*/gco:ScopedName"/>
      						(<xsl:value-of select="*/srv:identifier"/>)
    						<xsl:if test="position()!=last()"><br/></xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if> -->


		<!-- 1.6 -->
		<xsl:if test="gmd:identificationInfo/*/srv:operatesOn[substring(@xlink:href,1,4)!='']">
		<div class="row">
		  <div class="l">
		  	<xsl:value-of select="$msg/msg[@eng='Coupled Resource']"/>
		  </div>
		  <div class="r">
		    <xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn">
		    	
		    	<xsl:choose>
		    		<xsl:when test="@xlink:title!=''">
		    			<xsl:choose>
		    				<!-- docasne - pokud neexistuje odkaz -->
		    				<xsl:when test="string-length(@xlink:href)>3">
		   		      			<!-- <a href="javascript:app.showCoupledResource('{$theName}','{@xlink:href}');"><xsl:value-of select="@xlink:title"/></a><br/> -->
		   		      			<a href="?request=GetRecordById&amp;url={php:function('urlencode',string(@xlink:href))}"><xsl:value-of select="@xlink:title"/></a><br/>
		   		      		</xsl:when>
		   		      		<xsl:otherwise>
		   		      			<xsl:value-of select="@xlink:title"/><br/>
		   		      		</xsl:otherwise>
		   		      	</xsl:choose>
		    		</xsl:when>
		    		<xsl:otherwise>
		    			<xsl:if test="string-length(@xlink:href)>3">
		   		      		<a href="javascript:app.showCoupledResource('{$theName}','{@xlink:href}');">resource <xsl:value-of select="position()"/></a><br/>
		   		      	</xsl:if>
		    		</xsl:otherwise>
		    	</xsl:choose>
		    </xsl:for-each>
		    <xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification!=''"><div id="coupledResources"></div></xsl:if>
		  </div>
		</div>
		</xsl:if>

		<!-- vazby -->
		<xsl:variable name="vazby" select="php:function('getMetadata', concat('uuidRef=',gmd:fileIdentifier/*))"/>
		<xsl:variable name="subsets" select="php:function('getMetadata', concat('ParentIdentifier=',gmd:fileIdentifier/*))"/>


		<xsl:if test="$vazby//gmd:MD_Metadata or $subsets//gmd:MD_Metadata">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Coupled Resource']"/>
				</div>
				<div class="r">
					<xsl:for-each select="$vazby//gmd:MD_Metadata">
						<div>
							<a href="?request=GetRecordById&amp;id={gmd:fileIdentifier}&amp;format=text/html&amp;template=iso2htmlFull.xsl"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/></a>
						</div>	
					</xsl:for-each>
					<xsl:for-each select="$subsets//gmd:MD_Metadata">
						<div>
							<a href="?request=GetRecordById&amp;id={gmd:fileIdentifier}&amp;format=text/html&amp;template=iso2htmlFull.xsl"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/></a>
						</div>	
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>

		
		<xsl:if test="gmd:identificationInfo/*/gmd:environmentDescription!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Environment Description']"/>
				</div>
				<div class="r">
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:environmentDescription"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="gmd:identificationInfo/*/gmd:resourceMaintenance!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Resource Maintenance']"/>
				</div>
				<div class="r">
					<xsl:variable name="mt" select="gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>
					<xsl:value-of select="$cl/maintenanceAndUpdateFrequency/value[@name=$mt]"/>
					<xsl:if test="gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceNote!=''">
						<br/>
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceNote"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
					</xsl:if>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="gmd:distributionInfo//gmd:fees">
		  <div class="row">
		  	<div class="l"><xsl:value-of select="$msg/msg[@eng='Fees']"/></div>
		  	<div class="r"><xsl:value-of select="gmd:distributionInfo//gmd:fees"/></div>
		  </div>
		</xsl:if>
		
		
		<xsl:if test="gmd:distributionInfo//gmd:orderingInstructions">
		  <div class="row">
		  	<div class="l"><xsl:value-of select="$msg/msg[@eng='Ordering Instructions']"/></div>
		  	<div class="r"><xsl:value-of select="gmd:distributionInfo//gmd:orderingInstructions"/></div>
		  </div>
		</xsl:if>

		<xsl:if test="gmd:referenceSystemInfo!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Reference System']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier">
						<xsl:value-of select="*/gmd:codeSpace"/>:<xsl:value-of select="*/gmd:code"/>
						<xsl:if test="not (position()=last())">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		
		<!-- Citace FC -->
		<xsl:for-each select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Feature catalogue']"/>
				</div>
				<div class="r">
					<xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:title"/>
					<xsl:if test="gmd:featureCatalogueCitation/*/gmd:identifier"> 
						[<a href="?request=GetRecordById&amp;format=text/html&amp;id={gmd:featureCatalogueCitation/*/gmd:identifier}"><xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:identifier/*/gmd:code"/></a>]
					</xsl:if>
					
					<xsl:for-each select="gmd:FeatureTypes">
						<div>
							<a href="?request=GetRecordById&amp;format=text/html&amp;id={../gmd:featureCatalogueCitation/*/gmd:identifier}#{.}"><xsl:value-of select="./*"/></a>
						</div>
					</xsl:for-each>
				</div>
			</div>
		</xsl:for-each>		

		<xsl:if test="gmi:acquitisionInfo!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Reference System']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier">
						<xsl:value-of select="*/gmd:codeSpace"/>:<xsl:value-of select="*/gmd:code"/>
						<xsl:if test="not (position()=last())">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>

		<!-- dalkovy pruzkum ... -->
		<xsl:if test="gmi:acquisitionInformation">
		<h2>
			Imagery information
		</h2>
		<xsl:for-each select="gmi:acquisitionInformation/*/gmi:platform">
			<div class="row">
		  		<div class="l"><xsl:value-of select="$msg/msg[@eng='Platform']"/></div>
		  		<div class="r">
					<xsl:value-of select="*/gmi:identifier/*/gmd:code"/>: 
					<xsl:value-of select="*/gmi:description"/>
				</div>
			</div>
			<div class="row">	
			  	<div class="l"><xsl:value-of select="$msg/msg[@eng='Instrument']"/></div>
			  	<div class="r">
		  			<xsl:for-each select="*/gmi:instrument">
			      		<xsl:value-of select="*/gmi:identifier/*/gmd:code"/><xsl:text> </xsl:text> 
			     		<xsl:value-of select="*/gmi:type"/>
			     	</xsl:for-each>	
			  	</div>
		  	</div>
		</xsl:for-each>
		
		<xsl:for-each select="*/gmd:MD_ImageDescription|*/gmi:MI_ImageDescription">
			<div class="row">
				<div class="l">Attribute Description</div>
				<div class="r"><xsl:value-of select="gmd:attributeDescription"/></div>
			</div>
			<div class="row">
				<div class="l">Content Type</div>
				<div class="r"><xsl:value-of select="gmd:contentType/*/@codeListValue"/></div>
			</div>
			<div class="row">
				<div class="l">Bands</div>
				<div class="r">
					<xsl:for-each select="gmd:dimension">
						<div><a href="{@xlink:href}" target="_blank"><xsl:value-of select="@xlink:title"/></a></div>
					</xsl:for-each>
				</div>
			</div>
			<div class="row">
				<div class="l">Výška osvětlení</div>
				<div class="r"><xsl:value-of select="gmd:illuminationElevationAngle"/></div>
			</div>
			<div class="row">
				<div class="l">Azimut osvětlení</div>
				<div class="r"><xsl:value-of select="gmd:illuminationAzimuthAngle"/></div>
			</div>
			<div class="row">
				<div class="l">Podmínky při snímání</div>
				<div class="r"><xsl:value-of select="gmd:imagingCondition/*/@codeListValue"/></div>
			</div>
			<div class="row">
				<div class="l">Pokrytí mraky</div>
				<div class="r"><xsl:value-of select="gmd:cloudCoverPercentage"/>%</div>
			</div>
			<div class="row">
				<div class="l">Kód kvality</div>
				<div class="r">
					<xsl:value-of select="gmd:imageQualityCode/*/gmd:code"/>
					(<xsl:value-of select="gmd:imageQualityCode/*/gmd:authority/*/gmd:title"/>, 
					<xsl:value-of select="gmd:imageQualityCode/*/gmd:authority/*/gmd:date/*/gmd:dateType/*/@codeListValue"/> 
					<xsl:value-of select="gmd:imageQualityCode/*/gmd:authority/*/gmd:date/*/gmd:date"/>)
				</div>
			</div>
		</xsl:for-each>
		</xsl:if>

		<!-- distribuce -->
		<!--
		<xsl:if test="gmd:distributionInfo!=''">
			<h2>
				<xsl:value-of select="$msg/msg[@eng='Distribution']"/>
			</h2>
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='On-line']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
						<a href="{*/gmd:linkage}"><xsl:value-of select="*/gmd:linkage"/></a>
						<xsl:if test="*/gmd:protocol!=''">
							<br/>
							<xsl:value-of select="$msg/msg[@eng='Protocol']"/>:  <xsl:value-of select="*/gmd:protocol"/>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
			<xsl:if test="gmd:distributionInfo//gmd:MD_StandardOrderProcess/gmd:fees">
				<div class="row">
					<div class="l">
						<xsl:value-of select="$msg/msg[@eng='Fees']"/>
					</div>
					<div class="r">
						<xsl:value-of select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:MD_StandardOrderProcess/gmd:fees"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="gmd:distributionInfo/*/gmd:distributionFormat">
				<div class="row">
					<div class="l">
						<xsl:value-of select="$msg/msg[@eng='Format']"/>
					</div>
					<div class="r">
						<xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
							<xsl:value-of select="*/gmd:name"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="*/gmd:version"/>
							<xsl:if test="position()!=last()">
								<br/>
							</xsl:if>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="gmd:distributionInfo//gmd:MD_StandardOrderProcess/gmd:orderingInstructions">
				<div class="row">
					<div class="l">
						<xsl:value-of select="$msg/msg[@eng='Ordering Instructions']"/>
					</div>
					<div class="r">
						<xsl:value-of select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:MD_StandardOrderProcess/gmd:orderingInstructions"/>
					</div>
				</div>
			</xsl:if>
		</xsl:if>
		-->

		<!-- kvalita -->
		<xsl:if test="gmd:dataQualityInfo/*/gmd:report!='' or //gmd:lineage/*/gmd:processStep !=''">
		<h2>
			<xsl:value-of select="$msg/msg[@eng='Data Quality']"/>
		</h2> 
		<xsl:for-each select="//gmd:lineage/*/gmd:processStep">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Process Step']"/>
				</div>
				<div class="r">
					<xsl:call-template name="multi">
						<xsl:with-param name="el" select="*/gmd:description"/>
						<xsl:with-param name="lang" select="$lang"/>
						<xsl:with-param name="mdlang" select="$mdlang"/>
					</xsl:call-template>
					<xsl:if test="*/gmd:dateTime!=''">
						<div class="row">
							<div class="l2">
								<xsl:value-of select="$msg/msg[@eng='Date']"/>
							</div>
							<div class="r2">
								<xsl:value-of select="translate(*/gmd:dateTime,'T',' ')"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="*/gmd:rationale!=''">
						<div class="row">
							<div class="l2">
								<xsl:value-of select="$msg/msg[@eng='Rationale']"/>
							</div>
							<div class="r2">
								<xsl:value-of select="*/gmd:rationale"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="*/gmd:source!=''">
						<xsl:for-each select="*/gmd:source">
							<div class="row">
								<div class="l2">
									<xsl:value-of select="$msg/msg[@eng='Source']"/>
								</div>
						  	</div>
              				<div class="row">
								<div class="l3">
									<xsl:value-of select="$msg/msg[@eng='Description']"/>
								</div>
                    			<div class="r3">
                      				<xsl:call-template name="multi">
  										<xsl:with-param name="el" select="*/gmd:description"/>
  										<xsl:with-param name="lang" select="$lang"/>
  										<xsl:with-param name="mdlang" select="$mdlang"/>
								    </xsl:call-template>
								</div>
							</div>
							<div class="row">
								<div class="l3">
									<xsl:value-of select="$msg/msg[@eng='Title']"/>
								</div>
								<div class="r3">
									<xsl:call-template name="multi">
										<xsl:with-param name="el" select="*/gmd:sourceCitation/*/gmd:title"/>
										<xsl:with-param name="lang" select="$lang"/>
										<xsl:with-param name="mdlang" select="$mdlang"/>
									</xsl:call-template>
								</div>
							</div>
							<div class="row">
								<div class="l3">
									<xsl:value-of select="$msg/msg[@eng='Date']"/>
								</div>
								<div class="r3">
									<!-- <xsl:variable name="kod" select="*/gmd:sourceCitation/*/gmd:date/*/gmd:dateType"/>
									<xsl:value-of select="$cl/dateType/value[@name=$kod]"/>
									<xsl:text>: </xsl:text>
									 -->
									<xsl:value-of select="*/gmd:dateTime"/>
								</div>
							</div>
							<div class="row">
										<div class="l3">
											<xsl:value-of select="$msg/msg[@eng='Equivalent Scale']"/>
										</div>
										<div class="r3">
											<xsl:value-of select="*/gmd:scaleDenominator/*/gmd:denominator"/>
										</div>
							</div>
							<div class="row">
										<div class="l3">
											<xsl:value-of select="$msg/msg[@eng='Reference System']"/>
										</div>
										<div class="r3">
											<xsl:for-each select="*/gmd:sourceReferenceSystem/*/gmd:referenceSystemIdentifier">
												<xsl:value-of select="*/gmd:codeSpace"/>:<xsl:value-of select="*/gmd:code"/>
											</xsl:for-each>
										</div>
							</div>
							<div class="row">
										<div class="l3">
											<xsl:value-of select="$msg/msg[@eng='Temporal extent']"/>
										</div>
										<div class="r3">
											<xsl:for-each select="*/gmd:sourceExtent/*/gmd:temporalElement">
												<xsl:choose>
													<xsl:when test="*/gmd:extent/gml:TimePeriod!=''">
														<xsl:value-of select="*/gmd:extent/*/gml:beginPosition"/> -
                            <xsl:value-of select="*/gmd:extent/*/gml:endPosition"/>
													</xsl:when>
													<xsl:when test="*/gmd:extent/gml:TimeInstant!=''">
														<xsl:for-each select="*/gmd:extent/*/gml:TimeInstant">
															<xsl:value-of select="."/>,
                            </xsl:for-each>
													</xsl:when>
												</xsl:choose>
											</xsl:for-each>
										</div>
							</div>
							<xsl:for-each select="*/gmd:sourceStep">
								<div class="row">
									<div class="l3">
										<xsl:value-of select="$msg/msg[@eng='Process Step']"/>
									</div>
								</div>
								<div class="row">
									<div class="l4">
										<xsl:value-of select="$msg/msg[@eng='Description']"/>
									</div>
									<div class="r4">
  									<xsl:call-template name="multi">
  										<xsl:with-param name="el" select="*/gmd:description"/>
  										<xsl:with-param name="lang" select="$lang"/>
  										<xsl:with-param name="mdlang" select="$mdlang"/>
  									</xsl:call-template>
									</div>
								</div>
								<xsl:if test="*/gmd:source!=''">
                  <xsl:for-each select="*/gmd:source">
                    <div class="row">
							<div class="l4"><xsl:value-of select="$msg/msg[@eng='Source']"/></div>
					</div>
                    <div class="row">
							<div class="l5"><xsl:value-of select="$msg/msg[@eng='Source']"/></div>
                      <div class="r5">
                        <xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:description"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
                      </div>
                    </div>
                    <div class="row">
						 <div class="l5"><xsl:value-of select="$msg/msg[@eng='Title']"/></div>
                     <div class="r5">
            		  	     <xsl:call-template name="multi">
															<xsl:with-param name="el" select="*/gmd:sourceCitation/*/gmd:title"/>
															<xsl:with-param name="lang" select="$lang"/>
															<xsl:with-param name="mdlang" select="$mdlang"/>
														</xsl:call-template>
											</div>
                    </div>
        		        <div class="row">
										  <div class="l5"><xsl:value-of select="$msg/msg[@eng='Date']"/></div>
                      <div class="r5">
        		            <xsl:variable name="dt" select="*/gmd:sourceCitation/*/gmd:date/*/gmd:dateType"/>
														<xsl:value-of select="$cl/dateType/value[@name=$dt]"/>
														<xsl:text>: </xsl:text>
														<xsl:value-of select="*/gmd:sourceCitation/*/gmd:date/*/gmd:date"/>
											</div>
                    </div>
        		      <div class="row">
										  <div class="l5"><xsl:value-of select="$msg/msg[@eng='Equivalent Scale']"/></div>
            		    	<div class="r5">1 : <xsl:value-of select="*/gmd:scaleDenominator/*/gmd:denominator"/></div>
            		  </div>
        		      <div class="row">
										  <div class="l5"><xsl:value-of select="$msg/msg[@eng='Reference System']"/></div>
                      <div class="r5">
            		    	   <xsl:for-each select="*/gmd:sourceReferenceSystem/*/gmd:referenceSystemIdentifier">
														<xsl:value-of select="*/gmd:codeSpace"/>:<xsl:value-of select="*/gmd:code"/>
												 </xsl:for-each>
											</div>
                  </div>
        		      <div class="row">
										  <div class="l5"><xsl:value-of select="$msg/msg[@eng='Temporal extent']"/></div>
                      <div class="r5">
          		    	     <xsl:for-each select="*/gmd:sourceExtent/*/gmd:temporalElement">
															<xsl:choose>
																<xsl:when test="*/gmd:extent/gml:TimePeriod!=''">
																	<xsl:value-of select="*/gmd:extent/*/gml:beginPosition"/> -
                                  <xsl:value-of select="*/gmd:extent/*/gml:endPosition"/>
																</xsl:when>
																<xsl:when test="*/gmd:extent/gml:TimeInstant!=''">
																	<xsl:for-each select="*/gmd:extent/*/gml:TimeInstant">
																		<xsl:value-of select="."/>,
                                  </xsl:for-each>
																</xsl:when>
															</xsl:choose>
													</xsl:for-each>
        		          </div>
        		        </div>
                </xsl:for-each> 	<!-- source -->
						  </xsl:if>
							</xsl:for-each> <!-- source step -->
						</xsl:for-each>	<!-- source -->
					</xsl:if>
				</div> <!-- r -->
			</div> <!-- row -->
		</xsl:for-each> <!-- process step -->

		<!-- process step -->
		<xsl:if test="gmd:dataQualityInfo/*/gmd:report!=''">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Conformity']"/>
				</div>
				<div class="r">
					<xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result">
						<div class="row">
							<div class="l2">
								<xsl:value-of select="$msg/msg[@eng='Title']"/>
							</div>
							<div class="r2">
								<xsl:value-of select="*/gmd:specification/*/gmd:title"/>
							</div>
						</div>
						<div class="row">
							<div class="l2">
								<xsl:value-of select="$msg/msg[@eng='Explanation']"/>
							</div>
							<div class="r2">
								<xsl:value-of select="*/gmd:explanation"/>
							</div>
						</div>
						<div class="row">
							<div class="l2">
								<xsl:value-of select="$msg/msg[@eng='Pass']"/>
							</div>
							<div class="r2">
								<xsl:value-of select="*/gmd:pass"/>
							</div>
						</div>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		</xsl:if>

		<!-- metadata -->
		<h2><xsl:value-of select="$msg/msg[@eng='Metadata']"/></h2>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='MDIdentifier']"/>
			</div>
			<div class="r">
				<xsl:value-of select="gmd:fileIdentifier"/>
			</div>
		</div>
		<xsl:if test="gmd:parentIdentifier!=''">
			<xsl:variable name="pilink" select="php:function('getMetadata', concat('identifier=',gmd:parentIdentifier/*))"/>
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Parent Identifier']"/>
				</div>
				<div class="r">
					<xsl:value-of select="gmd:parentIdentifier"/>
					<div>
						<a href="?request=GetRecordById&amp;id={$pilink//gmd:fileIdentifier}&amp;format=text/html&amp;template=iso2htmlFull.xsl"><xsl:value-of select="$pilink//gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/></a>
					</div>
				</div>
			</div>
		</xsl:if>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Metadata Contact']"/>
			</div>
			<div class="r">
				<xsl:for-each select="gmd:contact">
					<xsl:if test="position() > 1"><div class="row"> </div></xsl:if>
					<xsl:if test="*/gmd:organisationName">
						<b><xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:organisationName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template></b>
						<br/>
					</xsl:if>
					<xsl:if test="*/gmd:individualName">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:individualName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$mdlang"/>
						</xsl:call-template>
						<br/>
					</xsl:if>
					<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:deliveryPoint"/>,
  	  				<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:city"/>,
      				<xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:postalCode"/>
					<br/>
					<xsl:for-each select="*/gmd:contactInfo/*/gmd:onlineResource">
      					<a href="{*/gmd:linkage}"><xsl:value-of select="*/gmd:linkage"/></a><br/>
      				</xsl:for-each>
      				tel: <xsl:value-of select="*/gmd:contactInfo/*/gmd:phone/*/gmd:voice"/>,
      				email: <xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress"/>
					<xsl:variable name="kod" select="*/gmd:role/*/@codeListValue"/>
					<br/>
					<xsl:value-of select="$msg/msg[@eng='role']"/>: <xsl:value-of select="$cl/role/value[@name=$kod]"/>
				</xsl:for-each>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Date Stamp']"/>
			</div>
			<div class="r">
				<xsl:value-of select="gmd:dateStamp"/>
			</div>
		</div>
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Language']"/>
			</div>
			<div class="r">
				<xsl:value-of select="$cl/language/value[@code=$lang]"/>
			</div>
		</div>
	</xsl:template>
	
	<!-- Zpracovani DC -->
	<xsl:template match="csw:Record" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dct="http://purl.org/dc/terms/">
		<div class="rec-title hlavicka cat-{translate(dc:type,$upper,$lower)}">
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
		<table class="vypis">
			<xsl:for-each select="*">
				<!-- TODO dodelat vzhled -->
				<tr>
					<th>
						<xsl:variable name="itemName" select="substring-after(name(),':')"/>
						<xsl:value-of select="$msg/msg[translate(@eng,$upper,$lower)=$itemName]"/>
					</th>
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
							<xsl:value-of select="$msg/msg[@eng=west]"/>:
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
	<xsl:template match="featureCatalogue">
		<h1><xsl:value-of select="$msg/msg[@eng='Contact']"/></h1>

		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Title']"/>
			</div>
			<div class="r title"><xsl:value-of select="name"/></div>
		</div>
		
		<div class="row">
			<div class="l">
				<xsl:value-of select="$msg/msg[@eng='Contact Info']"/>
			</div>
			<div class="r">
				<xsl:for-each select="producer">
					<xsl:if test="position() > 1"><div class="row"> </div></xsl:if>
					<xsl:if test="*/gmd:organisationName">
						<b><xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:organisationName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$lang"/>
						</xsl:call-template></b>
						<br/>
					</xsl:if>
					<xsl:if test="*/gmd:individualName">
						<xsl:call-template name="multi">
							<xsl:with-param name="el" select="*/gmd:individualName"/>
							<xsl:with-param name="lang" select="$lang"/>
							<xsl:with-param name="mdlang" select="$lang"/>
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
					<xsl:value-of select="$msg/msg[@eng='role']"/>: <xsl:value-of select="$cl/role/value[@name=$kod]"/>
				</xsl:for-each>
			</div>
		</div>

		<xsl:variable name="vazby" select="php:function('getMetadata', concat('FcIdentifier=',$ID))"/>
		<xsl:if test="$vazby//gmd:MD_Metadata">
			<div class="row">
				<div class="l">
					<xsl:value-of select="$msg/msg[@eng='Coupled Resource']"/>
				</div>
				<div class="r">
					<xsl:for-each select="$vazby//gmd:MD_Metadata">
						<div>
							<a href="?request=GetRecordById&amp;id={gmd:fileIdentifier}&amp;format=text/html&amp;template=iso2htmlFull.xsl"><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/*"/></a>
						</div>	
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		
		
		<xsl:for-each select="featureType">
			<a name="{typeName}"/>
			<h2><xsl:value-of select="typeName"/></h2>
			<div class="row">
				<xsl:if test="code">
					<div class="l">Kód</div>
					<div class="r"><xsl:value-of select="code"/></div>
				</xsl:if>
				<div class="l">Definice</div>
				<div class="r"><xsl:value-of select="definition"/></div>
				<div class="l">Atributy:</div>
				<div class="row">	
					
					<!-- atributy -->
					<table class="feature">
					<tr>
						<th style="width:3cm">Název</th>
						<th style="width:1.7cm">Typ</th>
						<th style="width:1.3cm">Jednotky</th>
						<th style="width:1.3cm">Kód</th>
						<th style="width:8cm">Popis</th>
						<th>Hodnoty</th>
					</tr>
					<xsl:for-each select="featureAttribute">
						<tr>
						<th><xsl:value-of select="memberName"/></th>
							<td><xsl:value-of select="valueType"/></td>
							<td><xsl:value-of select="valueMeasureUnit"/></td>
							<td><xsl:value-of select="code"/></td>
							<td><xsl:value-of select="definition"/></td>
						
						<!-- domeny -->
						<td style="margin-left:1cm">
							<xsl:for-each select="listedValue">
								<div>
									<xsl:value-of select="valueLabel"/>
									<xsl:if test="valueCode"> [<xsl:value-of select="valueCode"/>]</xsl:if>
									<xsl:if test="definition">: <xsl:value-of select="definition"/></xsl:if>
								</div>
							</xsl:for-each>
						</td>	
						</tr>
					</xsl:for-each>
					</table>
				</div>
			</div>
		</xsl:for-each>
	</xsl:template>
	
	<!-- pro multiligualni nazvy -->
	<xsl:template name="multi">
		<xsl:param name="el"/>
		<xsl:param name="lang"/>
		<xsl:param name="mdlang"/>
		<xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[@locale=concat('#locale-',$lang)]"/>
		<xsl:choose>
			<xsl:when test="string-length($txt)>0">
				<xsl:call-template name="lf2br">
					<xsl:with-param name="str" select="$txt"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="lf2br">
					<xsl:with-param name="str" select="$el/gco:CharacterString"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- prevod radku na <br/> -->
	<xsl:template name="lf2br">
		<xsl:param name="str"/>
		<xsl:choose>
			<xsl:when test="contains($str,'&#xA;')">
				<xsl:if test="normalize-space(substring-before($str,'&#xA;'))!=''">
					<xsl:value-of select="substring-before($str,'&#xA;')"/>
					<br/>
				</xsl:if>
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
	
	<!-- prevod & na  \&  neni pouzito -->
	<xsl:template name="amp2amp">
		<xsl:param name="str"/>
		<xsl:choose>
			<xsl:when test="contains($str,'&amp;')">
				<xsl:value-of select="substring-before($str,'&amp;')"/>\&amp;<xsl:call-template name="amp2amp">
					<xsl:with-param name="str">
						<xsl:value-of select="substring-after($str,'&amp;')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
