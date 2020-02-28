<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:gmd="http://www.isotc211.org/2005/gmd"
xmlns:gco="http://www.isotc211.org/2005/gco"
xmlns:gmx="http://www.isotc211.org/2005/gmx"
>
<xsl:output method="xml" encoding="utf-8" />

<xsl:template match="/">
  <results>
    <xsl:apply-templates select="*"/>
  </results>   
</xsl:template>

<xsl:template match="gfc:FC_FeatureCatalogue" xmlns:gfc="http://www.isotc211.org/2005/gfc">
    <FC_FeatureCatalogue>
        <id><xsl:value-of select="@uuid"/></id>
        <xsl:copy-of select="*"/>
    </FC_FeatureCatalogue>
</xsl:template>

<!-- old proprietary version -->
<xsl:template match="featureCatalogue" xmlns:gfc="http://www.isotc211.org/2005/gfc">
    <xsl:variable name="lang" select="name[1]/@lang"/>
    <FC_FeatureCatalogue>
        <name>
            <xsl:for-each select="name">
                <xsl:choose>
                    <xsl:when test="position()=1">
                        <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
                    </xsl:when>
                    <xsl:otherwise>
                        <gmd:PT_FreeText>
                            <gmd:textGroup>
                                <gmd:LocalisedCharacterString locale="#locale-{@lang}"><xsl:value-of select="."/></gmd:LocalisedCharacterString>
                            </gmd:textGroup>
                        </gmd:PT_FreeText>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:for-each>
        </name>
        <xsl:for-each select="scope">
            <xsl:if test="@lang=$lang">
                <scope><xsl:value-of select="."/></scope>
            </xsl:if>
        </xsl:for-each>
        <xsl:copy-of select="fieldOfApplication"/>
        <xsl:copy-of select="versionNumber"/>
        <xsl:copy-of select="versionDate"/>
        <language>
            <LanguageCode>
                <xsl:choose>
                    <xsl:when test="language/*/@codeListValue"><xsl:copy-of select="language"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="name[1]/@lang"/></xsl:otherwise>
                </xsl:choose>
            </LanguageCode>
        </language>
        <xsl:for-each select="name[@lang != $lang]">
            <gmx:locale>
              <gmd:PT_Locale id="locale-{@lang}">
                <gmd:languageCode>
                    <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="{@lang}"/>
                </gmd:languageCode>
                <gmd:characterEncoding>
                    <gmd:MD_CharacterSetCode codeListValue="utf8"/>
                </gmd:characterEncoding>
              </gmd:PT_Locale> 
            </gmx:locale>
         </xsl:for-each>
        
        <xsl:copy-of select="producer"/>
        <xsl:for-each select="featureType">
            <featureType>
                <FC_FeatureType>
                    <xsl:copy-of select="typeName"/>
                    <xsl:copy-of select="definition"/>
                    <xsl:copy-of select="code"/>
                    <xsl:for-each select="featureAttribute">
                        <carrierOfCharacteristics>
                            <FC_FeatureAttribute>
                                <xsl:copy-of select="memberName"/>
                                <xsl:copy-of select="definition"/>
                                <xsl:copy-of select="code"/>
                                <valueType>
                                    <typeName>
                                        <aName><xsl:value-of select="valueType"/></aName>
                                    </typeName>
                                </valueType>
                                <xsl:for-each select="listedValue">
                                    <listedValue>
                                        <FC_ListedValue>
                                            <label><xsl:value-of select="valueLabel"/></label>
                                            <code><xsl:value-of select="valueCode"/></code>
                                            <definition><xsl:value-of select="valueDefinition"/></definition>
                                        </FC_ListedValue>
                                    </listedValue>
                                </xsl:for-each>
                            </FC_FeatureAttribute>                            
                        </carrierOfCharacteristics>
                    </xsl:for-each>
                </FC_FeatureType>
            </featureType>
        </xsl:for-each>
    </FC_FeatureCatalogue>
</xsl:template>

</xsl:stylesheet>