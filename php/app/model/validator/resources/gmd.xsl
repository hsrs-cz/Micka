<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml"
xmlns:srv="http://www.isotc211.org/2005/srv"
xmlns:gmd="http://www.isotc211.org/2005/gmd"
xmlns:gmi="http://www.isotc211.org/2005/gmi"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:gmx="http://www.isotc211.org/2005/gmx"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="exsl"
xmlns:php="http://php.net/xsl">
<xsl:output method="xml"/>

<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:include href="gmd-2.xsl"/>
<xsl:include href="gmd-1.xsl"/>

<!-- kontrola tvaru data -->
<xsl:template name="chd">
	<xsl:param name="d"/>
	<xsl:choose>
		<!-- jen rok -->
		<xsl:when test="string-length($d)=4 and $d &lt; 10000">true</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="y" select="substring-before($d, '-')"/>
			<xsl:variable name="rest" select="substring-after($d, '-')"/>
			<xsl:choose>
				<!-- rok a mesic -->
				<xsl:when test="string-length($rest)=2 and $rest &gt; 0 and $rest &lt; 13">true</xsl:when>
				<!-- rok, mesic a den -->
				<xsl:otherwise>
					<xsl:variable name="m" select="substring-before($rest, '-')"/>
					<xsl:variable name="day">
						<xsl:choose>
								<xsl:when test="contains($rest, 'T')"><xsl:value-of select="substring-before(substring-after($rest, '-'),'T')"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="substring-after($rest, '-')"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="string-length($y)=4 and $y &lt; 10000">
						<xsl:if test="string-length($m)=2 and $m &gt; 0 and $m &lt; 13">
							<xsl:if test="string-length($day)=2 and $day &gt; 0 and $day &lt; 32">true</xsl:if>
						</xsl:if>
					</xsl:if>				
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>

