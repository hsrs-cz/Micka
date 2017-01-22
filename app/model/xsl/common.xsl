<?xml version='1.0' encoding='utf-8' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  		xmlns:gco="http://www.isotc211.org/2005/gco" 
  		xmlns:gmd="http://www.isotc211.org/2005/gmd"
  	  	xmlns:gmx="http://www.isotc211.org/2005/gmx"
  	  	xmlns:xlink="http://www.w3.org/1999/xlink"
  	  	xmlns:gfc="http://www.isotc211.org/2005/gfc"
>


  <xsl:template name="contact">
  <xsl:param name="org"/>
  <xsl:param name="mdLang"/>
  <xsl:for-each select="$org/CI_ResponsibleParty">
  <gmd:CI_ResponsibleParty>
    <xsl:if test="id">
      <xsl:attribute name="uuid"><xsl:value-of select="id"/></xsl:attribute>
    </xsl:if>
		<xsl:if test="individualName">
			<gmd:individualName>
				<gco:CharacterString><xsl:value-of select="individualName"/></gco:CharacterString>
		  	</gmd:individualName>
		</xsl:if>
		<xsl:if test="organisationName">
		  <xsl:call-template name="txt">
				<xsl:with-param name="s" select="."/>                      
			 	<xsl:with-param name="name" select="'organisationName'"/>                      
				<xsl:with-param name="lang" select="$mdLang"/>                      
			 </xsl:call-template>                                                              
		</xsl:if>
		<xsl:if test="positionName">
		<gmd:positionName>
			<gco:CharacterString><xsl:value-of select="positionName"/></gco:CharacterString>
		</gmd:positionName>
		</xsl:if>
		<xsl:if test="contactInfo">
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<gmd:phone>
						<gmd:CI_Telephone>
							<xsl:for-each select="contactInfo/*/phone//voice">
								<gmd:voice>
									<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
								</gmd:voice>
							</xsl:for-each>
							<xsl:for-each select="contactInfo/*/phone//facsimile">
								<gmd:facsimile>
									<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
								</gmd:facsimile>
							</xsl:for-each>
						</gmd:CI_Telephone>
					</gmd:phone>
					<xsl:for-each select="contactInfo/*/address">
						<gmd:address>
							<gmd:CI_Address>
								<xsl:for-each select="*/deliveryPoint">
									<gmd:deliveryPoint>
										<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
									</gmd:deliveryPoint>
								</xsl:for-each>
								<xsl:for-each select="*/city">
									<gmd:city>
										<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
									</gmd:city>
								</xsl:for-each>
								<xsl:for-each select="*/administrativeArea">
									<gmd:administrativeArea>
										<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
									</gmd:administrativeArea>
								</xsl:for-each>
								<xsl:for-each select="*/postalCode">
									<gmd:postalCode>
										<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
									</gmd:postalCode>
								</xsl:for-each>
								<xsl:for-each select="*/country">	
									<gmd:country>
										<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
									</gmd:country>
								</xsl:for-each>
								<xsl:for-each select="*/electronicMailAddress">
									<gmd:electronicMailAddress>
										<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
									</gmd:electronicMailAddress>
								</xsl:for-each>
							</gmd:CI_Address>
						</gmd:address>
					</xsl:for-each>
					<xsl:for-each select="contactInfo/*/onlineResource">
						<gmd:onlineResource>
							<gmd:CI_OnlineResource>
								<gmd:linkage>
									<gmd:URL><xsl:value-of select="*/linkage"/></gmd:URL>
								</gmd:linkage>
							</gmd:CI_OnlineResource>
						</gmd:onlineResource>
					</xsl:for-each>
				</gmd:CI_Contact>
			</gmd:contactInfo>
		</xsl:if>
		<gmd:role>
			<gmd:CI_RoleCode codeListValue="{role/CI_RoleCode}" codeList="./resources/codeList.xml#CI_RoleCode"><xsl:value-of select="role/CI_RoleCode"/></gmd:CI_RoleCode>
		</gmd:role>
	</gmd:CI_ResponsibleParty>
  </xsl:for-each>  
  </xsl:template>


  
<!-- pro multilingualni data-->
	<xsl:attribute-set name="free" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		<xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
	</xsl:attribute-set>
  
  	<xsl:template name="txt">
		<xsl:param name="s"/>
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:param name="ns" select="'gmd'"/>

        <xsl:variable name="count" select="count($s/*[name()=$name]/lang)"/>
        
        <xsl:for-each select="$s/*[name()=$name]">
        	<xsl:choose>
        		<xsl:when test="lang[@code='uri'] and $count>2">
        			<xsl:element name="{$ns}:{$name}" use-attribute-sets="free">
        				<gmx:Anchor xlink:href="{lang[@code='uri']}"><xsl:value-of select="lang[@code=$lang]"/></gmx:Anchor>
	        			<gmd:PT_FreeText>
	        			<xsl:for-each select="lang[@code!=$lang and @code!='uri']">
		        			<gmd:textGroup>
		        				<gmd:LocalisedCharacterString locale="#locale-{@code}"><xsl:value-of select="."/></gmd:LocalisedCharacterString>
		        			</gmd:textGroup>
	        			</xsl:for-each>
	        			</gmd:PT_FreeText>
        			</xsl:element>
        		</xsl:when>
        		<xsl:when test="not(lang[@code='uri']) and $count>1">
        			<xsl:element name="{$ns}:{$name}" use-attribute-sets="free">
        				<gco:CharacterString><xsl:value-of select="lang[@code=$lang]"/></gco:CharacterString>
	        			<gmd:PT_FreeText>
	        			<xsl:for-each select="lang[@code!=$lang]">
		        			<gmd:textGroup>
		        				<gmd:LocalisedCharacterString locale="#locale-{@code}"><xsl:value-of select="."/></gmd:LocalisedCharacterString>
		        			</gmd:textGroup>
	        			</xsl:for-each>
	        			</gmd:PT_FreeText>
        			</xsl:element>
        		</xsl:when>
        		<xsl:when test="lang[@code='uri']">
        			<xsl:element name="{$ns}:{$name}">
        				<gmx:Anchor xlink:href="{lang[@code='uri']}"><xsl:value-of select="lang[@code=$lang]"/></gmx:Anchor>
        			</xsl:element>	
        		</xsl:when>
        		<xsl:otherwise>
        			<xsl:element name="{$ns}:{$name}" use-attribute-sets="free">
        				<gco:CharacterString><xsl:value-of select="lang[@code=$lang]"/></gco:CharacterString>
        			</xsl:element>	
        		</xsl:otherwise>
        	</xsl:choose>
        </xsl:for-each>
  	</xsl:template>
  
  	<xsl:template name="ftxt">
		<xsl:param name="s"/>
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:param name="ns" select="'gmd'"/>

        <xsl:variable name="count" select="count($s/lang)"/>
        
        <xsl:for-each select="$s">
        	<xsl:choose>
        		<xsl:when test="lang[@code='uri'] and $count>2">
        			<xsl:element name="{$ns}:{$name}" use-attribute-sets="free">
        				<gmx:Anchor xlink:href="{lang[@code='uri']}"><xsl:value-of select="lang[@code=$lang]"/></gmx:Anchor>
	        			<gmd:PT_FreeText>
	        			<xsl:for-each select="lang[@code!=$lang and @code!='uri']">
		        			<gmd:textGroup>
		        				<gmd:LocalisedCharacterString locale="#locale-{@code}"><xsl:value-of select="."/></gmd:LocalisedCharacterString>
		        			</gmd:textGroup>
	        			</xsl:for-each>
	        			</gmd:PT_FreeText>
        			</xsl:element>
        		</xsl:when>
        		<xsl:when test="not(lang[@code='uri']) and $count>1">
        			<xsl:element name="{$ns}:{$name}" use-attribute-sets="free">
        				<gco:CharacterString><xsl:value-of select="lang[@code=$lang]"/></gco:CharacterString>
	        			<gmd:PT_FreeText>
	        			<xsl:for-each select="lang[@code!=$lang]">
		        			<gmd:textGroup>
		        				<gmd:LocalisedCharacterString locale="#locale-{@code}"><xsl:value-of select="."/></gmd:LocalisedCharacterString>
		        			</gmd:textGroup>
	        			</xsl:for-each>
	        			</gmd:PT_FreeText>
        			</xsl:element>
        		</xsl:when>
        		<xsl:when test="lang[@code='uri']">
        			<xsl:element name="{$ns}:{$name}">
        				<gmx:Anchor xlink:href="{lang[@code='uri']}"><xsl:value-of select="lang[@code=$lang]"/></gmx:Anchor>
        			</xsl:element>	
        		</xsl:when>
        		<xsl:otherwise>
        			<xsl:element name="{$ns}:{$name}" use-attribute-sets="free">
        				<gco:CharacterString><xsl:value-of select="lang[@code=$lang]"/></gco:CharacterString>
        			</xsl:element>	
        		</xsl:otherwise>
        	</xsl:choose>
        </xsl:for-each>
  	</xsl:template>


	<xsl:template name="escApos">
		<xsl:param name="s"/>
		<xsl:variable name="apos" select='"&apos;"' />
		<xsl:choose>
			<xsl:when test='contains($s, $apos)'>
		  		<xsl:value-of select="substring-before($s,$apos)" />
				<xsl:text>\'</xsl:text>
				<xsl:call-template name="escape-apos">
			 		<xsl:with-param name="s" select="substring-after($s, $apos)" />
				</xsl:call-template>
		 	</xsl:when>
		 	<xsl:otherwise>
		  		<xsl:value-of select="$s" />
		 	</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
</xsl:stylesheet>
