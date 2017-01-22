<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   
  xmlns:georss="http://www.georss.org/georss"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  >
<xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes"/>
<xsl:template match="/" xmlns:ows="http://www.opengis.net/ows">

<xsl:variable name="msg" select="document('portal.xml')/portal/messages[@lang=$LANG]"/>
<xsl:variable name="auth" select="document(concat('../../cfg/cswConfig-',$LANG,'.xml'))"/>

<rss version="2.0">
  <channel>
    <title><xsl:value-of select="$auth//ows:Title"/></title>
    <link><xsl:value-of select="$thisPath"/>/../metadata</link>
    <image>
      <title><xsl:value-of select="$msg/changes"/></title>
      <url><xsl:value-of select="$thisPath"/>/../img/favicon.gif</url>
      <link><xsl:value-of select="$thisPath"/>/opensearch.php</link>
    </image>
    <description>
      <xsl:value-of select="$msg/dchanges"/>
      <xsl:text> </xsl:text><xsl:value-of select="$DAYS"/>
      <xsl:text> </xsl:text><xsl:value-of select="$msg/days"/>
      <xsl:text> </xsl:text>-
      <xsl:text> </xsl:text><xsl:value-of select="$auth//ows:ServiceProvider/ows:ProviderName"/>, 
      	<xsl:value-of select="$auth//ows:ServiceProvider//ows:OnlineResource/@xlink:href"/>.
    </description>
    <language><xsl:value-of select="$LANG"/></language>
    <managingEditor><xsl:value-of select="$auth//ows:ElectronicMailAddress"/> (<xsl:value-of select="$auth//ows:IndividualName"/>)</managingEditor>
    <webMaster><xsl:value-of select="$auth//ows:ElectronicMailAddress"/>  (<xsl:value-of select="$auth//ows:IndividualName"/>)</webMaster>
    <copyright>http://www.hsrs.cz</copyright>

  <xsl:for-each select="results">
    <xsl:apply-templates/>
  </xsl:for-each>

  </channel>
</rss>
</xsl:template>

<xsl:template match="gmd:MD_Metadata"  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
    <item>
      <title><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString"/></title>
      <guid isPermaLink="false">urn:uuid:<xsl:value-of select="gmd:fileIdentifier"/></guid>
      <link><xsl:value-of select="$thisPath"/>/../micka_main.php?ak=detail&amp;lang=<xsl:value-of select="$LANG"/>&amp;uuid=<xsl:value-of select="gmd:fileIdentifier"/></link>
      <description><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></description>
      <pubDate><xsl:call-template name="formatDate">
          <xsl:with-param name="gmd:DateTime" select="@updated"/>
      </xsl:call-template>  00:00:00 GMT</pubDate>
      <xsl:for-each select="gmd:identificationInfo//gmd:EX_GeographicBoundingBox">
        <georss:polygon>
	      	<xsl:value-of select="gmd:southBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:westBoundLongitude"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="gmd:northBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:westBoundLongitude"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="gmd:northBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:eastBoundLongitude"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="gmd:southBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:eastBoundLongitude"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="gmd:southBoundLatitude"/><xsl:text> </xsl:text><xsl:value-of select="gmd:westBoundLongitude"/>
      	</georss:polygon>
      	</xsl:for-each>
    </item>
</xsl:template>

<xsl:template match="csw:Record" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:dct="http://purl.org/dc/terms/" xmlns:ows="http://www.opengis.net/ows">
    <item>
      <title><xsl:value-of select="dc:title"/></title>
      <guid isPermaLink="false">urn:uuid:<xsl:value-of select="dc:identifier[1]"/></guid>
      <link><xsl:value-of select="$thisURL"/>/../micka_main.php?ak=detail&amp;lang=<xsl:value-of select="$LANG"/>&amp;uuid=<xsl:value-of select="dc:identifier[1]"/></link>
      <description><xsl:value-of select="dct:abstract"/></description>
      <pubDate><xsl:call-template name="formatDate">
          <xsl:with-param name="DateTime" select="dc:date"/>
        </xsl:call-template> 00:00:00 GMT</pubDate>
      <xsl:for-each select="ows:BoundingBox">
        <georss:polygon>
	      	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="substring-after(ows:UpperCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	      	<xsl:value-of select="substring-after(ows:UpperCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:UpperCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:UpperCorner,' ')"/>
	      	<xsl:text> </xsl:text>
	       	<xsl:value-of select="substring-after(ows:LowerCorner,' ')"/><xsl:text> </xsl:text><xsl:value-of select="substring-before(ows:LowerCorner,' ')"/>
        </georss:polygon>
      </xsl:for-each>
    </item>
</xsl:template>

<xsl:template match="featureCatalogue">
</xsl:template>

<xsl:template name="formatDate">
	<xsl:param name="DateTime" />
	<!-- date format 1998-03-15[T13:00:00] -->

	<xsl:variable name="year">
		<xsl:value-of select="substring-before($DateTime,'-')" />
	</xsl:variable>
	<xsl:variable name="mo-temp">
		<xsl:value-of select="substring-after($DateTime,'-')" />
	</xsl:variable>
	<xsl:variable name="mo">
		<xsl:value-of select="substring-before($mo-temp,'-')" />
	</xsl:variable>
	<xsl:variable name="day-t">
		<xsl:value-of select="substring-after($mo-temp,'-')" />
	</xsl:variable>
	<xsl:variable name="day">
		<xsl:choose> 
		  <xsl:when test="substring-before($day-t,'T')!=''">
		  	<xsl:value-of select="substring-before($day-t,'T')" />
		  </xsl:when>
		  <xsl:otherwise>
		  	<xsl:value-of select="$day-t" />
		  </xsl:otherwise>
		</xsl:choose>  
	</xsl:variable>

	<xsl:if test="$day != '00'">
		<xsl:value-of select="$day"/>
		<xsl:value-of select="' '"/>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="$mo = '1' or $mo = '01'">Jan </xsl:when>
		<xsl:when test="$mo = '2' or $mo = '02'">Feb </xsl:when>
		<xsl:when test="$mo = '3' or $mo = '03'">Mar </xsl:when>
		<xsl:when test="$mo = '4' or $mo = '04'">Apr </xsl:when>
		<xsl:when test="$mo = '5' or $mo = '05'">May </xsl:when>
		<xsl:when test="$mo = '6' or $mo = '06'">Jun </xsl:when>
		<xsl:when test="$mo = '7' or $mo = '07'">Jul </xsl:when>
		<xsl:when test="$mo = '8' or $mo = '08'">Aug </xsl:when>
		<xsl:when test="$mo = '9' or $mo = '09'">Sep </xsl:when>
		<xsl:when test="$mo = '10'">Oct </xsl:when>
		<xsl:when test="$mo = '11'">Nov </xsl:when>
		<xsl:when test="$mo = '12'">Dec </xsl:when>
		<xsl:when test="$mo = '0' or $mo = '00'"></xsl:when><!-- do nothing -->
	</xsl:choose>
	<xsl:value-of select="$year"/>
</xsl:template> 

</xsl:stylesheet>
