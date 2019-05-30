<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:gco="http://www.isotc211.org/2005/gco" 
xmlns:gml="http://www.opengis.net/gml"
xmlns:srv="http://www.isotc211.org/2005/srv"
xmlns:gmd="http://www.isotc211.org/2005/gmd"
xmlns:gmi="http://www.isotc211.org/2005/gmi"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:gmx="http://www.isotc211.org/2005/gmx"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="exsl"
xmlns:php="http://php.net/xsl">
<xsl:output method="xml"/>

<xsl:template match="//gmd:MD_Metadata[contains(gmd:metadataStandardName/*,'/INSPIRE_TG2/CZ4')]|//gmi:MI_Metadata[contains(gmd:metadataStandardName/*,'/INSPIRE_TG2/CZ4')]">

<xsl:variable name="codelists" select="document('../../../config/codelists.xml')/map" />
<xsl:variable name="labels" select="document(concat('labels-',$LANG,'.xml'))/map" />
<xsl:variable name="srv" select="gmd:identificationInfo/srv:SV_ServiceIdentification != ''"/>
<xsl:variable name="hierarchy" select="gmd:hierarchyLevel/*/@codeListValue"/>
<xsl:variable name="mdlang" select="gmd:language/*/@codeListValue"/>

<xsl:variable name="serviceType" select="gmd:identificationInfo[1]/*/srv:serviceType"/>

<!-- pomocne promennne -->
<xsl:variable name="forInspire" select="gmd:hierarchyLevelName[*='http://geoportal.gov.cz/inspire']"/>
<xsl:variable name="spec">
	<xsl:choose>
		<xsl:when test="$srv">
			<xsl:value-of select="$codelists/specifications/value[@code='Network']/@uri"/>
		</xsl:when>	
		<xsl:otherwise>
			<xsl:value-of select="$codelists/specifications/value[@code='Interoperability']/@uri"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="INSPIRE" select="$codelists/specifications/value[@code='INSPIRE']/@uri"/>
<xsl:variable name="neInspire" select="gmd:dataQualityInfo/*/gmd:report[normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/*/@xlink:href)=normalize-space($INSPIRE)]" />
 
<validationResult title="{$labels/msg/titleCR}" version="4.0.0 beta, CENIA 2017">

<!-- identifikace -->
<!-- 1.1 -->
<test code="1.1" level="m">
	<description><xsl:value-of select="$labels/test[@code='1.1']"/></description>
	<xpath>identificationInfo[1]/*/citation/*/title <xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/*"/>#
	</xpath>
	<xsl:choose>  
	  	<xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString))>0">
		    <value><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString"/></value>
		    <pass>true</pass>
		</xsl:when>
	</xsl:choose>
</test>

<!-- 1.2 -->
<test code="1.2" level="m">
	<description><xsl:value-of select="$labels/test[@code='1.2']"/></description>
	<xpath>identificationInfo[1]/*/abstract</xpath>  
    <xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:abstract))>0">
	   <value><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></value>
	   <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.3 -->
<test code="1.3" level="m">
	<description><xsl:value-of select="$labels/test[@code='1.3']"/></description>
	<xpath>hierarchyLevel</xpath>
	<xsl:if test="$hierarchy='dataset' or $hierarchy='service' or $hierarchy='series' or $hierarchy='application'">
	    <value><xsl:value-of select="$codelists/updateScope/value[@name=$hierarchy]/*[name()=$LANG]"/> (<xsl:value-of select="$hierarchy"/>)</value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.4 -->
<xsl:choose>
    <xsl:when test="string-length(normalize-space(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage))>0">
        <!-- projde vsechny linky -->
        <xsl:variable name="links"> 
            <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
                <link>
                    <test><xsl:value-of select="php:function('testConnection', string(*/gmd:linkage/gmd:URL))"/></test>
                    <URL><xsl:value-of select="normalize-space(*/gmd:linkage/gmd:URL)"/></URL>
                    <protocol><xsl:value-of select="normalize-space(*/gmd:protocol/*/@xlink:href)"/></protocol>
                </link>
            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="exsl:node-set($links)/link">
            <test code="1.4" level="c">
                <description><xsl:value-of select="$labels/test[@code='1.4']"/></description>
                <xpath>distributionInfo/*/transferOptions/*/onLine/*/linkage</xpath>
                <xsl:if test="string-length(URL)>0">
                    <value><xsl:value-of select="URL"/></value>
                    <pass>true</pass>
                    <test code="a" level="m">
                        <description><xsl:value-of select="$labels/test[@code='1.4.a']"/></description>
                        <xpath>distributionInfo/*/transferOptions/*/onLine/*/linkage/URL ON-LINE</xpath>
                        <xsl:choose>
                            <xsl:when test="substring-after(test,'|')">
                               <value><xsl:value-of select="substring-before(test,'|')"/>, <xsl:value-of select="substring-after(test,'|')"/> s</value>
                               <pass>true</pass>
                            </xsl:when>
                            <xsl:otherwise>
                                <err><xsl:value-of select="URL"/></err>
                            </xsl:otherwise>
                        </xsl:choose>
                    </test>
                    <test code="b" level="m">
                        <description><xsl:value-of select="$labels/test[@code='1.4.b']"/></description>
                        <xpath>distributionInfo/*/transferOptions/*/onLine/*/linkage/*/protocol</xpath>
                        <xsl:choose>
                            <xsl:when test="contains(protocol, 'http://services.cuzk.cz/registry/codelist/OnlineResourceProtocolValue')">
                               <value><xsl:value-of select="protocol"/></value>
                               <pass>true</pass>
                            </xsl:when>
                            <xsl:otherwise>
                                <err><xsl:value-of select="protocol"/> - <xsl:value-of select="$labels/msg/notValid"/></err>
                            </xsl:otherwise>
                        </xsl:choose>
                    </test>      
                </xsl:if>
                <!--xsl:if test="$srv and $hierarchy='service'">
                    <test code="c" level="m">
                        <description><xsl:value-of select="$labels/test[@code='1.4.c']"/></description>
                        <xpath>distributionInfo/*/transferOptions/*/onLine/*/linkage</xpath>
                        <xsl:if test="exsl:node-set($links)/link[not(substring-before(test,'|')='?')]">
                            <value><xsl:for-each select="exsl:node-set($links)/link[not(substring-before(test,'|')='?')]">
                            &lt;li&gt;<xsl:value-of select="URL"/>&lt;/li&gt;
                            </xsl:for-each></value>
                            <pass>true</pass>
                        </xsl:if>
                    </test>
                </xsl:if-->  
            </test>
        </xsl:for-each>
    </xsl:when>  
    <xsl:otherwise>
        <test code="1.4" level="c">
            <description><xsl:value-of select="$labels/test[@code='1.4']"/></description>
            <xpath>distributionInfo/*/transferOptions/*/onLine/*/linkage</xpath>
        </test>
    </xsl:otherwise>
</xsl:choose>

<!-- 1.5 -->
<test code="1.5">
    <xsl:if test="$srv">
        <xsl:attribute name="level">n</xsl:attribute>
    </xsl:if>
    <description><xsl:value-of select="$labels/test[@code='1.5']"/></description>
    <xpath>identificationInfo[1]/*/citation/*/identifier</xpath>
    <xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code))>0 or gmd:identificationInfo/*/gmd:citation/*/gmd:identifier[*/gmd:code/*/@xlink:href]/*/gmd:code/*/@xlink:href">
        <value><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier[*/gmd:code/*/@xlink:href]/*/gmd:code/*/@xlink:href"/><xsl:text> </xsl:text><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/></value>
        <pass>true</pass>
       
        <test code="a" level="c">
            <description><xsl:value-of select="$labels/test[@code='1.5.a']"/></description>
            <xpath>identificationInfo/*/citation/*/identifier/*/code/*/@xlink:href</xpath>
            <xsl:choose>
                <xsl:when test="substring(gmd:identificationInfo/*/gmd:citation/*/gmd:identifier[*/gmd:code/*/@xlink:href]/*/gmd:code/*/@xlink:href, 1,4)='http'">
                    <value><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier[*/gmd:code/*/@xlink:href]/*/gmd:code/*/@xlink:href"/></value>
                    <pass>true</pass>
                </xsl:when>
                <xsl:otherwise>
                    <err><xsl:value-of select="$labels/msg/notValid"/> URI</err>
                </xsl:otherwise>
            </xsl:choose>
        </test>
    </xsl:if>
</test>
  
<!-- 1.6 -->   
 <xsl:if test="$srv and string-length($serviceType)>0">
	 <test code="1.6" level="c">
	 	<description><xsl:value-of select="$labels/test[@code='1.6']"/></description>
	 	<xpath>identificationInfo[1]/*/operatesOn</xpath>
  		<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/srv:operatesOn/@xlink:href))>3">
  			<pass>true</pass>
  			<xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn">
  				<xsl:variable name="remote" select="php:function('isRunning',string(@xlink:href), 'gmd')"/>
   				<test code="a" level="c">
   					<description><xsl:value-of select="$labels/test[@code='1.6.a']"/></description>
		 			<xsl:choose>
						<xsl:when test="$remote">
				   			<value><xsl:value-of select="@xlink:title"/>: <xsl:value-of select="@xlink:href"/></value>
				   			<pass>true</pass>
				   		</xsl:when>
				   		<xsl:otherwise>
				   			<err><xsl:value-of select="@xlink:title"/>: <xsl:value-of select="@xlink:href"/> OFF-LINE</err>
				   		</xsl:otherwise>
		   	 		</xsl:choose>  					
  				</test>
  			</xsl:for-each>
  		</xsl:if>
  	</test>	
</xsl:if> 

<xsl:if test="not($srv)">
	<!-- 1.7 -->
	 <test code="1.7" level="m">
	 	<description><xsl:value-of select="$labels/test[@code='1.7']"/></description>
	 	<xpath>identificationInfo[1]/*/language</xpath>
	 	<xsl:variable name="k" select="gmd:identificationInfo/*/gmd:language/*/@codeListValue"/>
		<xsl:if test="string-length($k)>0">
		   	<value><xsl:value-of select="$codelists/language/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
		   	<pass>true</pass>
		</xsl:if>
	</test>

  	<!-- 2.1 -->
	 <test code="2.1">
	 	<description><xsl:value-of select="$labels/test[@code='2.1']"/></description>
	 	<xpath>identificationInfo[1]/*/topicCategory</xpath>
			<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:topicCategory))>0">
			<value>
				<xsl:for-each select="gmd:identificationInfo/*/gmd:topicCategory">
					<xsl:variable name="k" select="normalize-space(.)"/>
					<xsl:value-of select="$codelists/topicCategory/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="."/>)
					<xsl:if test="not(position()=last())">, </xsl:if>
				</xsl:for-each>	
			</value>
			<pass>true</pass>
		</xsl:if>
	</test>
</xsl:if>

<xsl:choose>
	<xsl:when test="$srv and (string-length($hierarchy)=0 or $hierarchy='service')">
	  	<!-- 2.2 -->
		 <test code="2.2">
		 	<description><xsl:value-of select="$labels/test[@code='2.2']"/></description>
		 	<xpath>identificationInfo[1]/*/srv:serviceType</xpath>
		 	<xsl:variable name="st" select="normalize-space(gmd:identificationInfo/*/srv:serviceType/*)"/>
		 	<xsl:choose>
			 	<!-- pro INSPIRE -->
				<xsl:when test="$st='view' or $st='discovery' or $st='download' or $st='transformation' or $st='other'">
				    <value><xsl:value-of select="$st"/></value>
				    <pass>true</pass>
				    <!--xsl:for-each select="gmd:identificationInfo/*/srv:serviceTypeVersion">
					    <test code="CZ-8" level="c">
						 	<description><xsl:value-of select="$labels/test[@code='2.2.a']"/></description>
						 	<xpath>identificationInfo/*/srv:serviceTypeVersion</xpath>
						 	<value><xsl:value-of select="."/></value>
					 		<xsl:choose>
					 			<xsl:when test="$st='view'">
					 			 	<xsl:choose>
					 			 		<xsl:when test="contains('2.1,3.0,3.1,3.11',normalize-space(.))">
						  					<pass>true</pass>
						  				</xsl:when>	
						  			</xsl:choose>
						  		</xsl:when>
		
								<xsl:otherwise>
						   			<value><xsl:value-of select="."/></value>
						  			<pass>true</pass>
								</xsl:otherwise>
					  		
						 	</xsl:choose>
						</test>
					</xsl:for-each--> 
				</xsl:when>
			 	<!-- pro narodni  -->
				<xsl:when test="not($forInspire) and string-length($st)>0">
				    <value><xsl:value-of select="$st"/></value>
				    <pass>true</pass>
				    <!--xsl:for-each select="gmd:identificationInfo/*/srv:serviceTypeVersion">
					    <test code="CZ-8" level="c">
						 	<description><xsl:value-of select="$labels/test[@code='2.2.a']"/></description>
						 	<xpath>identificationInfo/*/srv:serviceTypeVersion</xpath>
						 	<value><xsl:value-of select="."/></value>
					 		<xsl:choose>
					 			<xsl:when test="$st='WMS'">
					 			 	<xsl:choose>
					 			 		<xsl:when test="contains('1.3.0,1.1.1,1.1.0,1.0.0',normalize-space(.))">
						  					<pass>true</pass>
						  				</xsl:when>
						  			</xsl:choose>		
						  		</xsl:when>
						  		
					 			<xsl:when test="$st='view'">
					 			 	<xsl:choose>
					 			 		<xsl:when test="contains('2.1,3.0,3.1,3.11',normalize-space(.))">
						  					<pass>true</pass>
						  				</xsl:when>	
						  			</xsl:choose>
						  		</xsl:when>
						  		
					 			<xsl:when test="$st='CSW'">
					 			 	<xsl:choose>
					 			 		<xsl:when test="contains('2.0.2',*)">
						   					<value><xsl:value-of select="."/></value>
						  					<pass>true</pass>
						  				</xsl:when>
						  				<xsl:otherwise>
						  					<err><xsl:value-of select="."/></err>
						  				</xsl:otherwise>
						  			</xsl:choose>		
						  		</xsl:when>
		
								<xsl:otherwise>
						   			<value><xsl:value-of select="."/></value>
						  			<pass>true</pass>							
								</xsl:otherwise>
					  		
						 	</xsl:choose>
						</test>
					</xsl:for-each--> 
				</xsl:when>
				<xsl:otherwise>
				    <err><xsl:value-of select="$st"/> != view | discovery | download | transformation | other</err>
				</xsl:otherwise>
			</xsl:choose>
		</test>
	</xsl:when>
	
	<!-- aplikace -->
	<xsl:when test="$srv and $hierarchy='application'">
	  	<!-- 2.2 -->
		 <test code="2.2" level="c">
	    	<xsl:variable name="k" select="normalize-space(gmd:identificationInfo/*/srv:serviceType/*)"/>
		 	<description><xsl:value-of select="$labels/test[@code='2.2']"/></description>
		 	<xpath>identificationInfo[1]/*/srv:serviceType</xpath>
			<xsl:if test="$k">
	    		<value><xsl:value-of select="$codelists/applicationType/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
			    <pass>true</pass>
			</xsl:if>
		</test>
	</xsl:when>
</xsl:choose>

<!-- 3 -->
<xsl:choose>

	<xsl:when test="$srv">
        <xsl:if test="$hierarchy='service'">
            <test code="3">
                <description><xsl:value-of select="$labels/test[@code='3']"/></description>
                <xpath>identificationInfo/*/descriptiveKeywords/MD_Keywords[contains(thesaurusName/*/title,'19119')]/keyword</xpath>
                <xsl:if test="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/*,'19119')]/gmd:keyword/*">
                    <value>
                        <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'19119')]/gmd:keyword">
                            <xsl:value-of select="*"/>
                            <xsl:if test="not(position()=last())">, </xsl:if>
                        </xsl:for-each>
                    </value>
                    <pass>true</pass>
                </xsl:if>

                <xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords[string-length(*/gmd:thesaurusName/*/gmd:title/*)>0]">
                    <test code="a">
                        <description><xsl:value-of select="$labels/test[@code='3a']"/></description>
                        <xpath>identificationInfo/*/descriptiveKeywords/*/keyword</xpath>
                        <xsl:choose>
                            <xsl:when test="string-length(*/gmd:keyword)>0">
                                <value><xsl:value-of select="*/gmd:thesaurusName/*/gmd:title/gco:CharacterString"/> = <xsl:value-of select="count(*/gmd:keyword)"/>
                                    (<xsl:for-each select="*/gmd:keyword"><xsl:value-of select="gco:CharacterString"/><xsl:if test="position() != last()">, </xsl:if></xsl:for-each>)
                                </value>
                                <pass>true</pass>
                            </xsl:when>
                            <xsl:otherwise>
                                <err><xsl:value-of select="*/gmd:thesaurusName/*/gmd:title/gco:CharacterString"/></err>
                            </xsl:otherwise>
                        </xsl:choose>
                    </test>
                </xsl:for-each>
            </test>	
        </xsl:if>
	</xsl:when>


	<xsl:otherwise>
		<test code="3">
		 	<description><xsl:value-of select="$labels/test[@code='3']"/></description>
		 	<xpath>identificationInfo/*/descriptiveKeywords/MD_Keywords[contains(thesaurusName/*/title,'GEMET - INSPIRE themes')]/keyword</xpath>
		 	<xsl:if test="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/*,'GEMET - INSPIRE themes')]/gmd:keyword">
				<value><xsl:value-of select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/*,'GEMET - INSPIRE themes')]/gmd:thesaurusName/*/gmd:title/gco:CharacterString"/></value>
				<pass>true</pass>
				<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/*,'GEMET - INSPIRE themes')]/gmd:keyword">
					<test code="3.1">
						<description><xsl:value-of select="$labels/test[@code='3.2']"/></description>
                        <xsl:variable name="kw" select="."/>
						<xsl:choose>
							<xsl:when test="$codelists/inspireKeywords/value[@uri=$kw/gmx:Anchor/@xlink:href]">
								<value><xsl:value-of select="gmx:Anchor/@xlink:href"/> (<xsl:value-of select="gmx:Anchor"/>)</value>
								<pass>true</pass>
							</xsl:when>
							<xsl:otherwise>
								<err><xsl:value-of select="*"/> - <xsl:value-of select="$labels/msg/notValid"/></err>
							</xsl:otherwise>
						</xsl:choose>
					</test>
				</xsl:for-each>
			</xsl:if>
		</test>	
	</xsl:otherwise>
</xsl:choose>

<!-- 4.1 -->
<xsl:if test="not($srv)">
    <xsl:choose>
        <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox))>0 ">
            <xsl:for-each select="gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox">

                <test code="4.1">
                    <description><xsl:value-of select="$labels/test[@code='4.1']"/></description>
                    <xpath>identificationInfo/*/extent/*/geographicElement/EX_GeographicBoundingBox</xpath>
                    <xsl:choose>
                        <xsl:when test="gmd:westBoundLongitude &lt; gmd:eastBoundLongitude and gmd:southBoundLatitude &lt; gmd:northBoundLatitude and gmd:westBoundLongitude &gt;= -180 and gmd:eastBoundLongitude &lt;= 180 and gmd:southBoundLatitude &gt;= -90 and gmd:northBoundLatitude &lt;= 90">
                            <value>
                                <xsl:value-of select="gmd:westBoundLongitude"/>,
                                <xsl:value-of select="gmd:southBoundLatitude"/>,
                                <xsl:value-of select="gmd:eastBoundLongitude"/>, 
                                <xsl:value-of select="gmd:northBoundLatitude"/>
                            </value>
                            <pass>true</pass>
                        </xsl:when>
                        <xsl:otherwise>
                            <err>
                                <xsl:value-of select="gmd:westBoundLongitude"/>,
                                <xsl:value-of select="gmd:southBoundLatitude"/>,
                                <xsl:value-of select="gmd:eastBoundLongitude"/>, 
                                <xsl:value-of select="gmd:northBoundLatitude"/> - 
                                <xsl:value-of select="$labels/msg/notValid"/>
                            </err>
                        </xsl:otherwise>
                    </xsl:choose>
                </test>
            </xsl:for-each>
        </xsl:when>

        <xsl:otherwise>
            <test code="4.1">
                <description><xsl:value-of select="$labels/test[@code='4.1']"/></description>
                <xpath>identificationInfo/*/extent/*/geographicElement/EX_GeographicBoundingBox</xpath>
            </test>	
        </xsl:otherwise>
    </xsl:choose>
</xsl:if>

<xsl:if test="$srv">
    <xsl:choose>
        <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox))>0 ">
            <xsl:for-each select="gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox">

                    <test code="4.1">
                        <description><xsl:value-of select="$labels/test[@code='4.1']"/></description>
                        <xpath>identificationInfo/*/extent/*/geographicElement/EX_GeographicBoundingBox"/>]</xpath>
                        <xsl:choose>
                            <xsl:when test="gmd:westBoundLongitude &lt; gmd:eastBoundLongitude and gmd:southBoundLatitude &lt; gmd:northBoundLatitude and gmd:westBoundLongitude &gt;= -180 and gmd:eastBoundLongitude &lt;= 180 and gmd:southBoundLatitude &gt;= -90 and gmd:northBoundLatitude &lt;= 90">
                                <value>
                                    <xsl:value-of select="gmd:westBoundLongitude"/>,
                                    <xsl:value-of select="gmd:southBoundLatitude"/>,
                                    <xsl:value-of select="gmd:eastBoundLongitude"/>, 
                                    <xsl:value-of select="gmd:northBoundLatitude"/>
                                </value>
                                <pass>true</pass>
                            </xsl:when>
                            <xsl:otherwise>
                                <err>
                                    <xsl:value-of select="gmd:westBoundLongitude"/>,
                                    <xsl:value-of select="gmd:southBoundLatitude"/>,
                                    <xsl:value-of select="gmd:eastBoundLongitude"/>, 
                                    <xsl:value-of select="gmd:northBoundLatitude"/> - 
                                    <xsl:value-of select="$labels/msg/notValid"/>
                                </err>
                            </xsl:otherwise>
                        </xsl:choose>
                    </test>
            </xsl:for-each>
        </xsl:when>

        <xsl:otherwise>
            <test code="4.1">
                <description><xsl:value-of select="$labels/test[@code='4.1']"/></description>
                <xpath>identificationInfo/*/extent/*/geographicElement/EX_GeographicBoundingBox</xpath>
            </test>	
        </xsl:otherwise>
    </xsl:choose>
</xsl:if>
  
<!-- 5.2 -->
<test code="5a">
	<description><xsl:value-of select="$labels/test[@code='5a']"/></description>
	<xpath>identificationInfo/*/citation/*/date</xpath>	
	<xsl:choose>
	  	<xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:citation/*/gmd:date/*/gmd:date))>0">
			<pass>true</pass>
			<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">	 	
				<test code="a">
					<description><xsl:value-of select="$labels/test[@code='5a.a']"/></description>
					<xsl:variable name="validDate"><xsl:call-template name="chd">
						<xsl:with-param name="d" select="*/gmd:date/*"/>
					</xsl:call-template></xsl:variable>
					<xpath>identificationInfo/*/citation/*/date/*/date</xpath>	
			 		<xsl:choose>
				  		<xsl:when test="$validDate='true'">
				    		<value><xsl:value-of select="*/gmd:date/*"/></value>
				    		<pass>true</pass>
				  		</xsl:when>
			    		<xsl:otherwise>
							<err>
								<xsl:value-of select="*/gmd:date/*"/> <xsl:value-of select="$validDate"/> - 
								<xsl:value-of select="$labels/msg/notValid"/>
			    			</err>
			    		</xsl:otherwise>
					</xsl:choose>
				</test>
				<test code="b">
					<description><xsl:value-of select="$labels/test[@code='5a.b']"/></description>
					<xpath>identificationInfo/*/citation/*/date/*/dateType</xpath>	
	 				<xsl:variable name="k" select="*/gmd:dateType/*/@codeListValue"/>
			 		<xsl:choose>
				  		<xsl:when test="string-length($k)>0">
				    		<value><xsl:value-of select="$codelists/dateType/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
				    		<pass>true</pass>
				  		</xsl:when>
			    		<xsl:otherwise>
							<err><xsl:value-of select="$labels/msg/notValid"/>: 
				    			<xsl:value-of select="$codelists/dateType/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)
			    			</err>
			    		</xsl:otherwise>
					</xsl:choose>
				</test>
			</xsl:for-each>
	  	</xsl:when>
	  	<xsl:otherwise>
	  	</xsl:otherwise>
	</xsl:choose>
</test>	

<xsl:if test="not($srv)">

	<!-- 5.1 -->
	<test code="5b" level="n">	
		<description><xsl:value-of select="$labels/test[@code='5b']"/></description>
		<xpath>identificationInfo/*/extent/*/temporalElement</xpath>	
		<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:extent//gmd:temporalElement))>0">
	     	<value>
                <xsl:for-each select="gmd:identificationInfo/*/gmd:extent//gmd:temporalElement">
                    <xsl:choose>
                        <xsl:when test="*/gmd:extent/*/gml:timePosition">
                            <xsl:value-of select="*/gmd:extent/*/gml:timePosition"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="*/gmd:extent/*/gml:beginPosition"/>
                            <xsl:value-of select="*/gmd:extent/*/gml:beginPosition/@indeterminatePosition"/>
                            - 
                            <xsl:value-of select="*/gmd:extent/*/gml:endPosition"/>
                            <xsl:value-of select="*/gmd:extent/*/gml:endPosition/@indeterminatePosition"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="not(position()=last())">, </xsl:if>
                </xsl:for-each>
            </value>
			<pass>true</pass>
		</xsl:if>
	</test>


	<!-- 6.1 -->
	<test code="6.1">
		<description><xsl:value-of select="$labels/test[@code='6.1']"/></description>
		<xpath>dataQualityInfo/*/lineage/*/statement</xpath>	
		<xsl:if test="string-length(normalize-space(gmd:dataQualityInfo//gmd:lineage//gmd:statement))>0">
		  <value><xsl:value-of select="gmd:dataQualityInfo//gmd:lineage//gmd:statement/gco:CharacterString"/></value>
		  <pass>true</pass>
		</xsl:if>
	</test>	

	<!-- 6.2 -->
	<test code="6.2" level="c">
		<description><xsl:value-of select="$labels/test[@code='6.2']"/></description>
		<xpath>identificationInfo/*/gmd:spatialResolution</xpath>	
		<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:spatialResolution))>0">
			<pass>true</pass>
			<xsl:for-each select="gmd:identificationInfo/*/gmd:spatialResolution">
				<xsl:choose>
					<!-- test meritka -->
					<xsl:when test="string-length(*/gmd:equivalentScale/*/gmd:denominator)>0">
						<test code="a" level="m">
							<description><xsl:value-of select="$labels/test[@code='6.2.a']"/></description>
							<xsl:if test="*/gmd:equivalentScale/*/gmd:denominator>0">
								<value><xsl:value-of select="*/gmd:equivalentScale/*/gmd:denominator"/></value>
								<pass>true</pass>
							</xsl:if>
						</test>
					</xsl:when>	
					<!-- test vzdalenosti -->		
					<xsl:when test="string-length(*/gmd:distance)>0">
						<test code="b" level="m">
							<description><xsl:value-of select="$labels/test[@code='6.2.b']"/></description>
							<xsl:if test="*/gmd:distance>0">
								<value><xsl:value-of select="*/gmd:distance"/></value>
								<pass>true</pass>
							</xsl:if>	
						</test>	
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>
	</test>	
</xsl:if>

<xsl:variable name="specRec" select="gmd:dataQualityInfo/*/gmd:report[gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/*/@xlink:href=$spec]"/>

<xsl:if test="not($hierarchy) or $hierarchy!='application'">
	<!-- 7.1 -->
	<test code="7.1" level="m">
        <description><xsl:value-of select="$labels/test[@code='7.1']"/></description>
        <xpath>dataQualityInfo/*/report/DQ_DomainConsistency/result/</xpath>
        
        <xsl:choose>
            <!-- NE INSPIRE zaznamy -->
            <xsl:when test="string-length($neInspire//gmd:title)>0 and $neInspire//gmd:pass/*='false'">
        		<value><xsl:value-of select="$INSPIRE"/></value>
    			<pass>true</pass>
    			<!-- 7.2 -->
			   	<test code="7.2">
			   		<description><xsl:value-of select="$labels/test[@code='7.2']"/></description>
			   		<xpath>dataQualityInfo/*/report/DQ_DomainConsistency/result/*/pass</xpath>
			   		<value>false</value>
			   		<pass>true</pass>
			    </test>	
       	    </xsl:when>
			<!-- INSPIRE zaznamy -->
        	<xsl:when test="$specRec//gmd:title/*/@xlink:href">
        		<value><xsl:value-of select="$specRec/*/gmd:result/*/gmd:specification/*/gmd:title/*/@xlink:href"/> (<xsl:value-of select="$specRec//gmd:title/*"/>)</value>
    			<pass>true</pass>
    			<!-- 7.2 -->
			   	<test code="7.2">
			   		<description><xsl:value-of select="$labels/test[@code='7.2']"/></description>
			   		<xpath>dataQualityInfo/*/report/DQ_DomainConsistency/result/*/pass</xpath>
			       	<xsl:choose>
			          	<xsl:when test="$specRec//gmd:pass/gco:Boolean">
			      			<value><xsl:value-of select="$specRec//gmd:pass"/></value>
			      		  	<pass>true</pass>
			      	  	</xsl:when>
			           	<xsl:when test="$specRec//gmd:pass/@gco:nilReason">
			      			<value>not evaluated</value>
			      		  	<pass>true</pass>
			      	  	</xsl:when>
			      	</xsl:choose>
			    </test>	
       	    </xsl:when>
            <xsl:otherwise>
                <err>"<xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString"/>" != "<xsl:value-of select="$spec"/>"</err>
            </xsl:otherwise>
        </xsl:choose>
	</test>
</xsl:if>

<!-- 8.1 -->
<test code="8.1">
    <description><xsl:value-of select="$labels/test[@code='8.1']"/></description>
    <xpath>identificationInfo/*/resourceConstraints/*/accessConstraints</xpath>
    <xsl:variable name="k" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useConstraints/*/@codeListValue"/>
    <xsl:if test="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:useConstraints/*/@codeListValue='otherRestrictions']/*/gmd:otherConstraints/*!=''">
            <value> 
                <xsl:value-of select="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:useConstraints/*/@codeListValue='otherRestrictions']/*/gmd:otherConstraints/*/@xlink:href"/>
               - <xsl:value-of select="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:useConstraints/*/@codeListValue='otherRestrictions']/*/gmd:otherConstraints/*"/>
            </value>
            <pass>true</pass>
    </xsl:if>
</test>

<!-- 8.2 -->
<test code="8.2">
    <description><xsl:value-of select="$labels/test[@code='8.2']"/></description>
    <xpath>identificationInfo/*/resourceConstraints/*/accessConstraints</xpath>
    <xsl:variable name="k" select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:accessConstraints/*/@codeListValue"/>
    <xsl:if test="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:accessConstraints/*/@codeListValue='otherRestrictions']/*/gmd:otherConstraints/*!=''">
            <value> 
                <xsl:value-of select="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:accessConstraints/*/@codeListValue='otherRestrictions']/*/gmd:otherConstraints/*/@xlink:href"/>
               - <xsl:value-of select="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:accessConstraints/*/@codeListValue='otherRestrictions']/*/gmd:otherConstraints/*"/>
            </value>
            <pass>true</pass>
    </xsl:if>
</test>

<!-- 9.1 -->
<xsl:choose>
	<xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:pointOfContact))>0">
		<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
			<test code="9.1">
				<description><xsl:value-of select="$labels/test[@code='9.1']"/></description>
				<xpath>identificationInfo/*/pointOfContact</xpath>
		  		<pass>true</pass>  		
		  			<test code="a" level="m">
						<description><xsl:value-of select="$labels/test[@code='Name']"/></description>
						<xpath>organisationName</xpath>			  	
						<xsl:if test="*/gmd:organisationName/*!=''">
					    	<value><xsl:value-of select="*/gmd:organisationName/*"/></value>
					    	<pass>true</pass>
					    </xsl:if>
			    	</test>
		  			<test code="b">
						<description>e-mail</description>
						<xpath>contactInfo/*/address/*/electronicMailAddress</xpath>			  	
				    	<value><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/></value>
						<xsl:choose>
						<xsl:when test="php:function('isEmail',string(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString))">
					    	<pass>true</pass>
					    </xsl:when>
					    </xsl:choose>
			    	</test>
					
					<xsl:variable name="k" select="*/gmd:role/*/@codeListValue"/>
		  			<test code="c" level="m">
						<description>Role (role)</description>
						<xpath>role/*/@codeListValue</xpath>
						<xsl:choose>	  	
							<xsl:when test="$codelists/role/value[@name=$k]!=''">
					    		<value><xsl:value-of select="$codelists/role/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
					    		<pass>true</pass>
					    	</xsl:when>
					    </xsl:choose>
			    	</test>
			</test>
		</xsl:for-each>	
		
	</xsl:when>
	<xsl:otherwise>
		<test code="9.1" level="m">
			<description><xsl:value-of select="$labels/test[@code='9.1']"/></description>
			<xpath>identificationInfo/*/pointOfContact</xpath>
		</test>	
	</xsl:otherwise>
</xsl:choose>

<!-- 9.1.d -->
<test code="9.1 d" level="c">
    <description><xsl:value-of select="$labels/test[@code='9.1.d']"/> = <xsl:value-of select="$codelists/role/value[@name='custodian']/*[name()=$LANG]"/></description>
    <xpath>identificationInfo[1]/*/pointOfContact/[*/role/*/@codeListValue='custodian']</xpath>
    <xsl:if test="string-length(//gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='custodian']/*/gmd:organisationName/*)>0">
        <value>
            <xsl:value-of select="//gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='custodian']/*/gmd:organisationName/*"/>
        </value>
        <pass>true</pass>
    </xsl:if>
</test>

<!-- 10.1 -->
<xsl:choose>
	<xsl:when test="string-length(normalize-space(gmd:contact))>0">
		<xsl:for-each select="gmd:contact">
			<test code="10.1" level="m">
				<description><xsl:value-of select="$labels/test[@code='10.1']"/></description>
				<xpath>contactInfo</xpath>
		  		<pass>true</pass>  		
	  			<test code="a">
					<description><xsl:value-of select="$labels/test[@code='Name']"/></description>
					<xpath>organisationName</xpath>			  	
					<xsl:if test="string-length(normalize-space(*/gmd:organisationName/*))>0">
				    	<value><xsl:value-of select="*/gmd:organisationName/*"/></value>
				    	<pass>true</pass>
				    </xsl:if>
		    	</test>
	  			<test code="b">
					<description>e-mail</description>
					<xpath>contactInfo/*/address/*/electronicMailAddress</xpath>			  	
				    <value><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/></value>
					<xsl:choose>
					<xsl:when test="php:function('isEmail',string(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString))">
				    	<pass>true</pass>
				    </xsl:when>
				    </xsl:choose>
		    	</test>

				<xsl:variable name="k1" select="*/gmd:role/*/@codeListValue"/>
		  		<test code="c" level="m">
					<description>Role (role)</description>
					<xpath>role/*/@codeListValue</xpath>
					<xsl:choose>	  	
						<xsl:when test="$codelists/role/value[@name=$k1]!=''">
				    		<value><xsl:value-of select="$codelists/role/value[@name=$k1]/*[name()=$LANG]"/> (<xsl:value-of select="$k1"/>)</value>
				    		<pass>true</pass>
				    	</xsl:when>
				    </xsl:choose>
			    </test>
			   	
			   	<xsl:if test="position()=1 and $codelists/role/value[@name=$k1]!=''">
		  			<test code="d">
						<description>Role = <xsl:value-of select="$codelists/role/value[@name='pointOfContact']/*[name()=$LANG]"/></description>
						<xpath>role/*/@codeListValue and //contact[*/role/*/@codeListValue='pointOfContact']</xpath>
						<xsl:choose>			  	
							<xsl:when test="string-length(//gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact'])>0">
						    	<value><xsl:value-of select="//gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:organisationName/gco:CharacterString"/></value>
						    	<pass>true</pass>
						    </xsl:when>
					    </xsl:choose>
			    	</test>
		    	</xsl:if>
			</test>
		</xsl:for-each>	
		
	</xsl:when>
	<xsl:otherwise>
		<test code="10.1" level="m">
			<description><xsl:value-of select="$labels/test[@code='10.1']"/></description>
			<xpath>contactInfo</xpath>
		</test>	
	</xsl:otherwise>
</xsl:choose>

<!-- 10.1.d -->
<test code="10.1 d" level="c">
    <description><xsl:value-of select="$labels/test[@code='10.1.d']"/> = <xsl:value-of select="$codelists/role/value[@name='pointOfContact']/*[name()=$LANG]"/></description>
    <xpath>identificationInfo[1]/*/pointOfContact/[*/role/*/@codeListValue='custodian']</xpath>
    <xsl:if test="string-length(//gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:organisationName/*)>0">
        <value>
            <xsl:value-of select="//gmd:contact[*/gmd:role/*/@codeListValue='pointOfContact']/*/gmd:organisationName/*"/>
        </value>
        <pass>true</pass>
    </xsl:if>
</test>

<!-- 10.2 -->
<test code="10.2">
	<description><xsl:value-of select="$labels/test[@code='10.2']"/></description>
	<xpath>dateStamp</xpath>
	<xsl:variable name="validDate"><xsl:call-template name="chd">
		<xsl:with-param name="d" select="gmd:dateStamp/*"/>
	</xsl:call-template></xsl:variable>	
	<xsl:choose>
	  	<xsl:when test="string-length(normalize-space(gmd:dateStamp))>0 and $validDate='true'">
	    	<value><xsl:value-of select="gmd:dateStamp"/></value>
	    	<pass>true</pass>
	  	</xsl:when>
	  	<xsl:otherwise>
	  		<err><xsl:value-of select="gmd:dateStamp"/></err>
	  	</xsl:otherwise>
	</xsl:choose>
</test>


<!-- 10.3 -->
<test code="10.3">
	<description><xsl:value-of select="$labels/test[@code='10.3']"/></description>
	<xpath>language</xpath>

	<xsl:choose>
	  <xsl:when test="string-length($mdlang)>0">
	    <value><xsl:value-of select="$codelists/language/value[@name=$mdlang]/*[name()=$LANG]"/> (<xsl:value-of select="$mdlang"/>)</value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>

<!-- 11 -->
<test code="11" level="m">
	<description><xsl:value-of select="$labels/test[@code='11']"/></description>
	<xpath>fileIdentifier</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:fileIdentifier))>0">
	    <value><xsl:value-of select="gmd:fileIdentifier"/></value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>

<xsl:if test="not($srv)">
    <test code="12" level="m">
    	<description><xsl:value-of select="$labels/test[@code='12']"/></description>
    	<xpath>dataQualityInfo/*/scope/*/level/*/@codeListValue</xpath>
    	<xsl:choose>
    	  <xsl:when test="string-length(normalize-space(gmd:dataQualityInfo/*/gmd:scope/*/gmd:level/*/@codeListValue))>0">
	    	<xsl:variable name="k" select="gmd:dataQualityInfo/*/gmd:scope/*/gmd:level/*/@codeListValue"/>
	    	<value><xsl:value-of select="$codelists/updateScope/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
    	    <pass>true</pass>
    	  </xsl:when>
    	</xsl:choose>
    </test>
</xsl:if>
 
<xsl:if test="$srv">
    <xsl:if test="$serviceType='other'">
        <test code="IOS-1" level="m">
            <xsl:variable name="k" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/*/gmd:title/*/@xlink:href"/>
            <description><xsl:value-of select="$labels/test[@code='IOS-1']"/></description>
            <xpath>dataQualityInfo/*/report/DQ_DomainConsistency/result/DQ_ConformanceResult/specification/*/title = invocable|interoperable|harmonised</xpath>
            <xsl:choose>
                <xsl:when test="$k">
                    <value><xsl:value-of select="$codelists/sds/value[@uri=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
                    <pass>true</pass>
                </xsl:when>
            </xsl:choose>
        </test>

        <test code="IOS-2" level="m">
            <description><xsl:value-of select="$labels/test[@code='IOS-2']"/></description>
            <xpath>dataQualityInfo/*/report/DQ_ConceptualConsistency/result/DQ_QuantitativeResult</xpath>
            <xsl:if test="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency/gmd:result/gmd:DQ_QuantitativeResult/gmd:value">
                <value></value>
                <pass>true</pass>

                <test code="a" level="m">
                    <xsl:variable name="k" select="$codelists/serviceQuality/value[1]"/>
                    <description><xsl:value-of select="$k/*[name()=$LANG]"/></description>
                    <xpath>dataQualityInfo/*/report/DQ_ConceptualConsistency/result/DQ_QuantitativeResult</xpath>
                    <xsl:choose>
                        <xsl:when test="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$k/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value">
                            <value>
                                <xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$k/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value"/> % 
                            </value>
                            <pass>true</pass>
                        </xsl:when>
                    </xsl:choose>
                </test>

               <test code="b" level="m">
                    <xsl:variable name="k" select="$codelists/serviceQuality/value[2]"/>
                    <description><xsl:value-of select="$k/*[name()=$LANG]"/></description>
                    <xpath>dataQualityInfo/*/report/DQ_ConceptualConsistency/result/DQ_QuantitativeResult</xpath>
                    <xsl:choose>
                        <xsl:when test="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$k/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value">
                            <value>
                                <xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$k/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value"/> s 
                            </value>
                            <pass>true</pass>
                        </xsl:when>
                    </xsl:choose>
                </test>

                <test code="c" level="m">
                    <xsl:variable name="k" select="$codelists/serviceQuality/value[3]"/>
                    <description><xsl:value-of select="$k/*[name()=$LANG]"/></description>
                    <xpath>dataQualityInfo/*/report/DQ_ConceptualConsistency/result/DQ_QuantitativeResult</xpath>
                    <xsl:choose>
                        <xsl:when test="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$k/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value">
                            <value>
                                <xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$k/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value"/>  
                            </value>
                            <pass>true</pass>
                        </xsl:when>
                    </xsl:choose>
                </test>

            </xsl:if>
        </test>
    </xsl:if>

    <xsl:variable name="k3" select="$codelists/serviceQuality/value[3]"/>
    <xsl:if test="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_ConceptualConsistency[gmd:nameOfMeasure/*/@xlink:href=$k3/@uri]/gmd:result/gmd:DQ_QuantitativeResult/gmd:value">
        <test code="IOS-3" level="m">
            <description><xsl:value-of select="$labels/test[@code='IOS-3']"/></description>
            <xpath>identificationInfo/*/couplingType/*/@codeListValue</xpath>
            <xsl:if test="gmd:identificationInfo/*/srv:containsOperations/*/srv:operationName/*">
                <value>
                    <xsl:for-each select="gmd:identificationInfo/*/srv:containsOperations">
                        <xsl:value-of select="*/srv:operationName/*"/>
                        <xsl:if test="position() != last()">, </xsl:if>
                    </xsl:for-each>
                </value>
                <pass>true</pass>
            </xsl:if>
        </test>
    </xsl:if>
</xsl:if>


<xsl:if test="not($srv)">
    <!--  xsl:variable name="rep" select="gmd:dataQualityInfo/*/gmd:report[php:function('mb_strtoupper', normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString))=php:function('mb_strtoupper', $spec)]"/-->
    <test code="IOD-1" level="c">
    	<description><xsl:value-of select="$labels/test[@code='IOD-1']"/></description>
    	<xpath>referenceSystemInfo/*/referenceSystemIdentifier/*/code</xpath>
    	<xsl:if test="string-length(normalize-space(gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier/*/gmd:code))>0">
    	    <value></value>
    	    <pass>true</pass>
             <xsl:for-each select="gmd:referenceSystemInfo">
             	<test code="a" level="m">
             		<description><xsl:value-of select="$labels/test[@code='IOD-1a']"/></description>
  				<xpath>http://www.opengis.net/def/crs/*</xpath>
  				<xsl:if test="contains(*/gmd:referenceSystemIdentifier/*/gmd:code/*/@xlink:href,'http://www.opengis.net/def/crs/')">
                    <value>
                        <xsl:value-of select="*/gmd:referenceSystemIdentifier/*/gmd:code/*/@xlink:href"/>
                  		- <xsl:value-of select="*/gmd:referenceSystemIdentifier/*/gmd:code"/>
                  	</value>
                  	<pass>true</pass>
                 	</xsl:if>
                 </test>
             </xsl:for-each>    
    	    <xsl:if test="gmd:dataQualityInfo/*/gmd:report[php:function('mb_strtoupper', normalize-space(gmd:DQ_DomainConsistency/gmd:result/*/gmd:specification/*/gmd:title/gco:CharacterString))=php:function('mb_strtoupper', $spec)]//gmd:pass='true'">
	    	    <test code="b" level="m">
	    			<description><xsl:value-of select="$labels/test[@code='IOD-1b']"/></description>
	    			<xpath>http://www.opengis.net/def/crs/EPSG/x/[4258|3034|3035|3045|3046]</xpath>
	    			<xsl:if test="gmd:referenceSystemInfo[contains(*//gmd:code,'http://www.opengis.net/def/crs/EPSG/') and (contains(*//gmd:code, '4258') or contains(*//gmd:code, '3034') or contains(*//gmd:code, '3035') or contains(*//gmd:code, '3045') or contains(*//gmd:code, '3046'))]">
	    	    		<value>
	                		<xsl:for-each select="gmd:referenceSystemInfo[contains(*//gmd:code,'http://www.opengis.net/def/crs/EPSG/') and (contains(*//gmd:code, '4258') or contains(*//gmd:code, '3034') or contains(*//gmd:code, '3035') or contains(*//gmd:code, '3045') or contains(*//gmd:code, '3046'))]">                    
	                    		<xsl:value-of select="*/gmd:referenceSystemIdentifier/*/gmd:code"/>
	                    		<xsl:if test="not(position()=last())">&lt;br/&gt;</xsl:if>
	                		</xsl:for-each>    
	            		</value>
			    	    <pass>true</pass>
			    	</xsl:if>
			    </test>    	    
		    </xsl:if>
    	</xsl:if>	
    </test>

    <test code="IOD-3" level="m">
    	<description><xsl:value-of select="$labels/test[@code='IOD-3']"/></description>
    	<xpath>distributionInfo/*/distributionFormat/*/name</xpath>
    	<xsl:choose>
    	  	<xsl:when test="string-length(normalize-space(gmd:distributionInfo/*/gmd:distributionFormat))>0">
    	    	<pass>true</pass>
    	    	<value></value>
                <xsl:for-each select="gmd:distributionInfo/*/gmd:distributionFormat">
                	<test code="a">
                		<description><xsl:value-of select="$labels/test[@code='IOD-3a']"/></description>
                		<xsl:if test="string-length(*/gmd:name/*)>0">
                			<pass>true</pass>
                    		<value><xsl:value-of select="*/gmd:name/*"/></value>
                    	</xsl:if>
                    </test>	
                	<test code="b">
                		<description><xsl:value-of select="$labels/test[@code='IOD-3b']"/></description>
                		<xsl:if test="string-length(*/gmd:version/*)>0">
                			<pass>true</pass>
                    		<value><xsl:value-of select="*/gmd:version/*"/></value>
                    	</xsl:if>
                    </test>	
                	<!-- <test code="c" level="c">
                		<description><xsl:value-of select="$labels/test[@code='IO-3c']"/></description>
                		<xsl:if test="string-length(*/gmd:specification/*)>0">
                			<pass>true</pass>
                    		<value><xsl:value-of select="*/gmd:specification/*"/></value>
                    	</xsl:if>
                    </test> -->	
                </xsl:for-each>    
            </xsl:when>
    	</xsl:choose>
    </test>

    <test code="IOD-4" level="n"> <!-- TODO vylepsit -->
    	<description><xsl:value-of select="$labels/test[@code='IOD-4']"/></description>
    	<xpath>dataQualityInfo/*/report/DQ_TopologicalConsistency/result</xpath>
    	<xsl:choose>
    	  <xsl:when test="string-length(normalize-space(gmd:dataQualityInfo/*/gmd:report/gmd:DQ_TopologicalConsistency/gmd:result))>0">
    	    <value>
    			<xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_TopologicalConsistency/gmd:nameOfMeasure"/>
    			(<xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_TopologicalConsistency/gmd:measureDescription"/>)
            </value>
    	    <pass>true</pass>
    	    <!--  <xsl:for-each select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_TopologicalConsistency/gmd:result">
    	    	<test code="a" level="n">
    	    		<xsl:if test="*/gmd:value and contains(*/gmd:valueUnit/@xlink:href, 'http://geoportal.gov.cz/res/units.xml#')">
    	    			<description><xsl:value-of select="$labels/test[@code='IO-4a']"/></description>
    	    			<value><xsl:value-of select="*/gmd:value"/> / <xsl:value-of select="*/gmd:valueUnit/@xlink:href"/></value>
    	    			<pass>true</pass>
    	    		</xsl:if>
    	    	</test>
    	    </xsl:for-each>-->
    	  </xsl:when>
    	</xsl:choose>
    </test>

    <test code="IOD-5" level="c">
    	<description><xsl:value-of select="$labels/test[@code='IOD-5']"/></description>
    	<xpath>identificationInfo/*/characterSet</xpath>
    	<xsl:choose>
    	  <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:characterSet/*/@codeListValue))>0">
    	    <value>
                <xsl:for-each select="gmd:identificationInfo/*/gmd:characterSet">
                    <xsl:value-of select="*/@codeListValue"/>
                    <xsl:if test="not(position()=last())">&lt;br/&gt;</xsl:if>
                </xsl:for-each>    
            </value>
    	    <pass>true</pass>
    	  </xsl:when>
    	</xsl:choose>
    </test>

    <test code="IOD-6" level="m">
    	<description><xsl:value-of select="$labels/test[@code='IOD-6']"/></description>
    	<xpath>identificationInfo[1]/*/spatialRepresentationType/*/@codeListValue</xpath>
    	<xsl:variable name="k" select="gmd:identificationInfo[1]/*/gmd:spatialRepresentationType/*/@codeListValue"/>
    	<xsl:choose>
    	  <xsl:when test="$k!=''">
    	    <value><xsl:value-of select="$codelists/spatialRepresentationType/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
    	    <pass>true</pass>
    	  </xsl:when>
    	</xsl:choose>
    </test>
</xsl:if>


<xsl:if test="not($srv)">
    <test code="CZ-4" level="m">
    	<description><xsl:value-of select="$labels/test[@code='CZ-4']"/></description>
    	<xpath>identificationInfo/*/resourceMaintenance/*/maintenanceAndUpdateFrequency/*/@codeListValue</xpath>
   		<xsl:variable name="k" select="gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency/*/@codeListValue"/>

    	<xsl:choose>
    		<!-- for user defined -->
    		<xsl:when test="$k='unknown'">
    			<xsl:if test="substring(gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:userDefinedMaintenanceFrequency/*,1,1)='P'">
    	    		<value>          
            			<xsl:value-of select="$codelists/maintenanceAndUpdateFrequency/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>): <xsl:value-of select="gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:userDefinedMaintenanceFrequency"/>
            		</value>
    	    		<pass>true</pass>
            	</xsl:if>
    		</xsl:when>
    	  	<xsl:when test="string-length($k)>0">
    	    	<value>          
            		<xsl:value-of select="$codelists/maintenanceAndUpdateFrequency/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)
            	</value>
    	    	<pass>true</pass>
    	  	</xsl:when>
    	</xsl:choose>
    </test>

	<test code="CZ-7" level="c">
		<description><xsl:value-of select="$labels/test[@code='CZ-7']"/></description>
		<xpath>gmd:identificationInfo/*/gmd:purpose</xpath>
		<xsl:choose>
            <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:purpose))>0">
                <value><xsl:value-of select="gmd:identificationInfo/*/gmd:purpose/gco:CharacterString"/></value>
                <pass>true</pass>
            </xsl:when>
		</xsl:choose>
	</test>
</xsl:if>

<xsl:if test="$srv">
    <test code="CZ-9" level="m">
        <description><xsl:value-of select="$labels/test[@code='CZ-9']"/></description>
        <xpath>identificationInfo/*/couplingType/*/@codeListValue</xpath>
        <xsl:variable name="k" select="gmd:identificationInfo/*/srv:couplingType/*/@codeListValue"/>
        <xsl:choose>
            <xsl:when test="string-length($k)>0">
                <value><xsl:value-of select="$codelists/couplingType/value[@name=$k]/*[name()=$LANG]"/> (<xsl:value-of select="$k"/>)</value>
                <pass>true</pass>
            </xsl:when>
        </xsl:choose>
    </test>
</xsl:if>

<!-- CZ-10 - vyhozeno z profilu
<xsl:if test="not($srv)">
    <test code="CZ-10" level="n"> 
    	<description><xsl:value-of select="$labels/test[@code='CZ-10']"/></description>
    	<xpath>dataQualityInfo/*/report/DQ_CompletenessOmission[contains(measureIdentification/*/code/*,'CZ-COVERAGE')]/result</xpath>
		<xsl:variable name="k" select="gmd:dataQualityInfo/*/gmd:report/gmd:DQ_CompletenessOmission[contains(gmd:measureIdentification/*/gmd:code/*,'CZ-COVERAGE')]"/>
   	    <xsl:if test="$k/gmd:result/*/gmd:value!=''">
   	       	<pass>true</pass>
    	    <test code="a" level="m">
   	    		<description>%</description>
   	    		<xsl:if test="string(number($k/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'percent')]/*/gmd:value)) != 'NaN'">
   	    			<value>
   	    				<xsl:value-of select="$k/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'percent')]/*/gmd:value"/> 
   	    				(<xsl:value-of select="$k/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'percent')]/*/gmd:valueUnit/@xlink:href"/>)   	    			
 	    	    	</value>
 	    	    	<pass>true</pass>
   	    		</xsl:if>
    	    </test>
    	    <test code="b" level="m">
   	    		<description>km2</description>
   	    		<xsl:if test="string(number($k/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'km2')]/*/gmd:value)) != 'NaN'">
   	    			<value>
   	    				<xsl:value-of select="$k/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'km2')]/*/gmd:value"/> 
   	    				(<xsl:value-of select="$k/gmd:result[contains(*/gmd:valueUnit/@xlink:href,'km2')]/*/gmd:valueUnit/@xlink:href"/>)   	    			
 	    	    	</value>
 	    	    	<pass>true</pass>
   	    		</xsl:if>
    	    </test>
   	    </xsl:if>
    </test>
</xsl:if>
-->

<!-- CZ-12 -->
<test code="CZ-12" level="m">
    <description><xsl:value-of select="$labels/test[@code='CZ-12']"/></description>
    <xpath>metadataStandardName</xpath>
    <xsl:choose>
        <xsl:when test="gmd:metadataStandardName/*">
            <value><xsl:value-of select="gmd:metadataStandardName"/></value>
            <pass>true</pass>
        </xsl:when>
    </xsl:choose>
</test>

<!-- CZ-13 -->
<xsl:if test="not($srv) and gmd:hierarchyLevelName/*='http://geoportal.gov.cz/inspire'">
    <test code="CZ-13" level="c">
        <description><xsl:value-of select="$labels/test[@code='CZ-13']"/></description>
        <xpath>identificationInfo/*/citation/*/otherCitationDetails</xpath>
        <xsl:choose>
            <xsl:when test="gmd:identificationInfo/*/gmd:citation/*/gmd:otherCitationDetails/*">
                <value><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:otherCitationDetails/*"/></value>
                <pass>true</pass>
            </xsl:when>
        </xsl:choose>
    </test>
</xsl:if>

<xsl:if test="gmd:identificationInfo/*/gmd:resourceConstraints[*/gmd:otherConstraints/*/@xlink:href='http://opendata.gov.cz/definition/opendata']">
	<test code="CZ-15" level="m">
		<description><xsl:value-of select="$labels/test[@code='CZ-15']"/></description>
		<xpath>distributionInfo/*/transferOptions/*/onLine/*/description contains mimeType</xpath>
		<xsl:choose>
            <xsl:when test="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(*/gmd:description/*,'mimeType')]/*/gmd:description/*">
                <value><xsl:value-of select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine[contains(*/gmd:description/*,'mimeType')]/*/gmd:description/*"/></value>
                <pass>true</pass>
            </xsl:when>
		</xsl:choose>
	</test>
</xsl:if>
 
<xsl:for-each select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
	<test code="XML" level="m">
		<description>FC featureTypes</description>
		<xpath>contentInfo/MD_FeatureCatalogueDescription/featureTypes</xpath>
   	    <xsl:if test="gmd:featureTypes">
   	    	<value>
   	    		<xsl:for-each select="gmd:featureTypes">
   	    			<xsl:value-of select="."/>
   	    			<xsl:if test="not(position()=last())">, </xsl:if>
   	    		</xsl:for-each>
   	    	</value>
   	    	<pass>true</pass>
			<test code="a" level="m">
				<description>Feature Catalogue title</description>
				<xpath>contentInfo/MD_FeatureCatalogueDescription/featureCatalogueCitation/*/title</xpath>
		   	    <xsl:if test="gmd:featureCatalogueCitation/*/gmd:title">
		   	    	<value><xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:title/*"/></value>
		   	    	<pass>true</pass>
				</xsl:if>		
			</test>
			<test code="b" level="m">
				<description>Feature Catalogue date + dateType</description>
				<xpath>contentInfo/MD_FeatureCatalogueDescription/featureCatalogueCitation/*/date/*/date + dateType</xpath>
		   	    <xsl:if test="gmd:featureCatalogueCitation/*/gmd:date/*/gmd:date and gmd:featureCatalogueCitation/*/gmd:date/*/gmd:dateType/*/@codeListValue">
		   	    	<value><xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:date/*/gmd:dateType/*/@codeListValue"/>: <xsl:value-of select="gmd:featureCatalogueCitation/*/gmd:date/*/gmd:date"/></value>
		   	    	<pass>true</pass>
				</xsl:if>		
			</test>  	    	
		</xsl:if>		
	</test>
</xsl:for-each>

<!-- informative elements -->
	<test code="primary" level="i">
		<description>isPrimary</description>
		<xpath>xxx</xpath>
		<xsl:choose>
            <xsl:when test="string-length(normalize-space(gmd:contact/*/gmd:organisationName/gco:CharacterString))>0 and normalize-space(gmd:contact/*/gmd:organisationName/gco:CharacterString)=normalize-space(gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue='custodian']/*/gmd:organisationName/gco:CharacterString)">
                <value>1</value>
                <pass>true</pass>
            </xsl:when>
		  <!-- <xsl:when test="count(gmd:identificationInfo/*/gmd:pointOfContact)=1 and string-length(normalize-space(gmd:contact/*/gmd:organisationName/gco:CharacterString))>0 and normalize-space(gmd:contact/*/gmd:organisationName/gco:CharacterString)=normalize-space(gmd:identificationInfo/*/gmd:pointOfContact/*/gmd:organisationName/gco:CharacterString)">
		    <value>2</value>
		    <pass>true</pass>
		  </xsl:when> -->
		</xsl:choose>
	</test>

    
</validationResult>

</xsl:template>



</xsl:stylesheet>

