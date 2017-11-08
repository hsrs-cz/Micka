<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gmi="http://www.isotc211.org/2005/gmi" 
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:gmx="http://www.isotc211.org/2005/gmx" 
>

<!-- provides conversion from old ISO 19139 metadata to Anchor-based new INSPIRE profile -->

<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no"/>
<xsl:variable name="cl" select="document('../codelists.xml')/map" />   

	<!--xsl:template match="/">
		<xsl:apply-templates select="./*"/>
  	</xsl:template-->
      
    <xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>
	
	<!-- CRS -->
	<xsl:template match="gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier[not(*/gmd:code/*/@xlink:href)]">
		<gmd:referenceSystemIdentifier>
			<gmd:RS_Identifier>
				<gmd:code>
					<xsl:choose>
						<xsl:when test="substring(*/gmd:code/*, 1, 4)='http'">
							<xsl:variable name="t" select="substring-after(*/gmd:code/*, 'EPSG/0/')"/>
							<gmx:Anchor xlink:href="{*/gmd:code/*}">EPSG:<xsl:value-of select="$t"/></gmx:Anchor>						
						</xsl:when>
						<xsl:when test="contains(*/gmd:code/*, 'EPSG:')">
							<gmx:Anchor xlink:href="http://www.opengis.net/def/crs/EPSG/0/{substring-after(*/gmd:code/*,'EPSG:')}"><xsl:value-of select="*/gmd:code/*"/></gmx:Anchor>
						</xsl:when>
						<xsl:otherwise>
							<gco:CharacterString><xsl:value-of select="*/gmd:code/*"/></gco:CharacterString>
                        </xsl:otherwise>
					</xsl:choose>
				</gmd:code>
			</gmd:RS_Identifier>
		</gmd:referenceSystemIdentifier>
	</xsl:template>

	<!-- INSPIRE kw -->
	<xsl:template match="gmd:descriptiveKeywords[contains(*/gmd:thesaurusName/*/gmd:title/*, 'INSPIRE themes')]">
		<gmd:descriptiveKeywords>
			<gmd:MD_Keywords>
				<xsl:for-each select="*/gmd:keyword">
					<xsl:choose>
						<xsl:when test="*/@xlink:href"><copy-of select="."/></xsl:when>
						<xsl:otherwise>
							<xsl:variable name="kw" select="*"/>
							<gmd:keyword>
								<gmx:Anchor xlink:href="{$cl/inspireKeywords/value[*=$kw]/@uri}"><xsl:value-of select="$kw"/></gmx:Anchor>
							</gmd:keyword>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<gmd:thesaurusName>
					<gmd:CI_Citation>
						<gmd:title>
							<gmx:Anchor xlink:href="http://www.eionet.europa.eu/gemet/inspire_themes">GEMET - INSPIRE themes, version 1.0</gmx:Anchor>
						</gmd:title>
						<xsl:copy-of select="*/gmd:thesaurusName/*/gmd:date"/>
					</gmd:CI_Citation>
				</gmd:thesaurusName>
			</gmd:MD_Keywords>
		</gmd:descriptiveKeywords>
	</xsl:template>
    
    <!-- INSPIRE services klassification-->
    <xsl:template match="gmd:keyword">
        <xsl:variable name="k" select="*"/>
        <xsl:choose>
            <xsl:when test="$cl/serviceKeyword/value[@name=$k]">
                <gmd:keyword>
                    <gmx:Anchor xlink:href="{$cl/serviceKeyword/value[@name=$k]/@uri}"><xsl:value-of select="$k"/></gmx:Anchor>
                </gmd:keyword>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
	<!-- 8.1 -->
	<xsl:template match="gmd:resourceConstraints[*/gmd:useLimitation/*!='']">
        <gmd:resourceConstraints>
            <gmd:MD_LegalConstraints>
                <gmd:useConstraints>
                    <gmd:MD_RestrictionCode codeListValue="otherRestrictions" codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode">otherRestrictions</gmd:MD_RestrictionCode>
                </gmd:useConstraints>
                <gmd:otherConstraints>
                    <xsl:choose>
                        <xsl:when test="contains(*/gmd:useLimitation/*, 'nejsou známy') or contains(*/gmd:useLimitation/*, 'unknown')">
                            <gmx:Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/noConditionsApply"><xsl:value-of select="*/gmd:useLimitation/*"/></gmx:Anchor>
                        </xsl:when>
                        <xsl:when test="contains(*/gmd:useLimitation/*, 'žádné podmínky') or contains(*/gmd:useLimitation/*, 'no conditions')">
                            <gmx:Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown"><xsl:value-of select="*/gmd:useLimitation/*"/></gmx:Anchor>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="*/gmd:useLimitation/*"/>
                        </xsl:otherwise>							
                    </xsl:choose>
                </gmd:otherConstraints>
            </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
	</xsl:template>

	<!-- 8.2 -->
	<xsl:template match="gmd:resourceConstraints[*/gmd:otherConstraints/*!='']">
        <gmd:resourceConstraints>
            <gmd:MD_LegalConstraints>
                <gmd:accessConstraints>
                    <gmd:MD_RestrictionCode codeListValue="otherRestrictions" codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_RestrictionCode">otherRestrictions</gmd:MD_RestrictionCode>
                </gmd:accessConstraints>
                <xsl:choose>
                    <xsl:when test="contains(*/gmd:otherConstraints/*, 'žádné omezení') or contains(*/gmd:otherConstraints/*, 'no limitations')">
                        <gmd:otherConstraints>
                            <gmx:Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations"><xsl:value-of select="*/gmd:otherConstraints/*"/></gmx:Anchor>
                        </gmd:otherConstraints>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="*/gmd:otherConstraints"/>
                    </xsl:otherwise>
                </xsl:choose>
            </gmd:MD_LegalConstraints>
        </gmd:resourceConstraints>
	</xsl:template>
	
	<!-- protocol -->
	<xsl:template match="gmd:protocol">
		<gmd:protocol>
            <gmx:Anchor xlink:href="http://services.cuzk.cz/registry/codelist/OnlineResourceProtocolValue/{*}"><xsl:value-of select="*"/></gmx:Anchor>
		</gmd:protocol>
	</xsl:template>
	
	<xsl:template match="gmd:metadataStandardName">
        <gmd:metadataStandardName>
            <gco:CharacterString xmlns:gco="http://www.isotc211.org/2005/gco">ISO 19115/INSPIRE_TG2/CZ4</gco:CharacterString>
        </gmd:metadataStandardName>
	</xsl:template>	
	
    <!-- extent ID -->
	<xsl:template match="gmd:extent|srv:extent">
        <xsl:variable name="mdlang" select="../../../gmd:language/*/@codeListValue"/>
		<gmd:extent>
			<gmd:EX_Extent>
				<xsl:for-each select="*/gmd:geographicElement">
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:variable name="b" select="*/gmd:geographicElement/gmd:EX_GeographicBoundingBox"/>
                <xsl:for-each select="$cl/extents/value">
                    <xsl:variable name="w" select="(@x2 - @x1) div 5"/>
                    <xsl:variable name="n" select="(@x2 - @x1) div 20"/>
                    <xsl:if test="$b/gmd:westBoundLongitude/* &gt; (@x1 - $w) and $b/gmd:westBoundLongitude/* &lt; (@x1 + $n) and $b/gmd:eastBoundLongitude/* &gt; (@x2 - $n) and $b/gmd:eastBoundLongitude/* &lt; (@x2 + $w) and $b/gmd:southBoundLatitude/* &lt; (@y1 + $n) and  $b/gmd:southBoundLatitude/* &gt; (@y1 - $w) and $b/gmd:northBoundLatitude/* &lt; (@y2 + $w) and $b/gmd:northBoundLatitude/* &gt; (@y2 - $n)">
                        <gmd:geographicElement>
                            <gmd:EX_GeographicDescription>
                                <gmd:geographicIdentifier>
                                    <gmd:MD_Identifier>
                                        <gmd:code>
                                            <gmx:Anchor xlink:href="{@uri}"><xsl:value-of select="*[name()=$mdlang]"/></gmx:Anchor>
                                        </gmd:code>
                                    </gmd:MD_Identifier>
                                </gmd:geographicIdentifier>
                            </gmd:EX_GeographicDescription>
                        </gmd:geographicElement>				
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="*/gmd:temporalElement">
                    <xsl:copy-of select="."/>
                </xsl:for-each>	
            </gmd:EX_Extent>
        </gmd:extent>
    </xsl:template>	

    <!-- INSPIRE specifications -->
    <xsl:template match="gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation">
        <gmd:CI_Citation>
            <xsl:variable name="s" select="gmd:title/gco:CharacterString"/>
            <xsl:choose>
                <xsl:when test="$s!='' and $cl/specifications/value[contains(*/@name, $s)]/@uri">
                    <gmd:title>
                        <gmx:Anchor xlink:href="{$cl/specifications/value[contains(*/@name, $s)]/@uri}"><xsl:value-of select="$s"/></gmx:Anchor>
                    </gmd:title>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="gmd:title"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="gmd:date"/>
        </gmd:CI_Citation>
    </xsl:template>
    
</xsl:stylesheet>
