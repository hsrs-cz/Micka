<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>


<!-- for multiligual elements -->
<xsl:template name="multi" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:param name="el"/>
  <xsl:param name="lang"/>
  <xsl:param name="mdlang"/>
  <xsl:variable name="txt" select="$el/gmd:PT_FreeText/*/gmd:LocalisedCharacterString[contains(@locale,$lang)]"/>	
  <xsl:variable name="uri" select="$el/*/@xlink:href"/>	
  <xsl:choose>
  	<xsl:when test="string-length($txt)>0">
  		<xsl:choose>
  			<xsl:when test="$uri">
  				<a href="{$uri}" target="_blank">
  	  			<xsl:call-template name="lf2br">
  	    			<xsl:with-param name="str" select="$txt"/>
      			</xsl:call-template>   		
  				</a>
  			</xsl:when>		
  			<xsl:otherwise>
  	  			<xsl:call-template name="lf2br">
  	    			<xsl:with-param name="str" select="$txt"/>
      			</xsl:call-template>   		
      		</xsl:otherwise>	
  		</xsl:choose>
  	</xsl:when>
  	<xsl:otherwise>
  		<xsl:choose>
  			<xsl:when test="$uri">
  				<a href="{$uri}" target="_blank">
  	  			<xsl:call-template name="lf2br">
  	    			<xsl:with-param name="str" select="$el/*"/>
      			</xsl:call-template>   		
  				</a>
  			</xsl:when>		
  			<xsl:otherwise>
  	  			<xsl:call-template name="lf2br">
  	    			<xsl:with-param name="str" select="$el/*"/>
      			</xsl:call-template>   		
      		</xsl:otherwise>	
  		</xsl:choose>		
  	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- conversion of page breaks to br -->
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
				<xsl:call-template name="showURL">
					<xsl:with-param name="val" select="$str"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

<!-- PAGINATOR -->
<xsl:template name="paginator">
	<xsl:param name="matched"/>
	<xsl:param name="returned"/>
	<xsl:param name="next"/>
	<xsl:param name="url"/>
		
	<xsl:if test="$matched>$returned">
		<div class="paginator">
			<xsl:variable name="pages" select="ceiling(number($matched) div number($MAXRECORDS))"/>
			<xsl:variable name="page" select="(($STARTPOSITION - 1) div $MAXRECORDS) + 1"/>
	
	       	<xsl:if test="$STARTPOSITION>1">
	       		<xsl:variable name="lastSet" select="number($STARTPOSITION)-number($MAXRECORDS)"/>
	         	<a href="{$url}=1"><i class="fa fa-fast-backward fa-fw"></i></a>
	         	<a href="{$url}={$lastSet}"><i class="fa fa-backward fa-fw"></i></a>
	       	</xsl:if> 
	
	       <span>&#160;<xsl:value-of select="$page"/> / <xsl:value-of select="$pages"/>&#160;</span>
	
	       	<xsl:if test="$next>0">
	         	<a href="{$url}={$next}"><i class="fa fa-forward fa-fw"></i></a>
	         	<a href="{$url}={$MAXRECORDS * ($pages - 1) + 1}"><i class="fa fa-fast-forward fa-fw"></i></a>
	       	</xsl:if>
       </div>      
	</xsl:if> 
</xsl:template>

	<!-- creation of anchor from url -->
	<xsl:template name="showURL">
		<xsl:param name="val"/>
		<xsl:choose>
			<xsl:when test="substring($val,1,4)='http'">
				<a href="{$val}"><xsl:value-of select="$val"/></a>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$val"/></xsl:otherwise>  	
		</xsl:choose>
	</xsl:template>

	<!-- conversion & to  \&  - not used -->
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
	
	<!-- resource type icons -->
	<xsl:template name="showres">
		<xsl:param name="r"/>
		<xsl:param name="class" select="''"/>
		<span class="res-type {$r}">
			<xsl:choose>
				<xsl:when test="$r='service'"><i class="fa fa-gears fa-fw {$class}"></i></xsl:when>
				<xsl:when test="$r='dataset'"><i class="fa fa-map fa-fw {$class}"></i></xsl:when>
				<xsl:when test="$r='series'"><i class="fa fa-th fa-fw {$class}"></i></xsl:when>
				<xsl:when test="$r='tile'"><i class="fa fa-box fa-fw {$class}"></i></xsl:when>
				<xsl:when test="$r='nonGeographicDataset'"><i class="fa fa-database fa-fw {$class}"></i></xsl:when>
				<xsl:when test="$r='application'"><i class="fa fa-desktop fa-fw {$class}"></i></xsl:when>
				<xsl:when test="$r='fc'"><i class="fa fa-sitemap fa-fw {$class}"></i></xsl:when>
				<xsl:when test="$r='dc'"><i class="fa fa-sun fa-fw {$class}"></i></xsl:when>
				<xsl:otherwise><i class="fa fa-question fa-fw {$class}"></i></xsl:otherwise>
			</xsl:choose>
		</span>		
	</xsl:template>
	

</xsl:stylesheet>