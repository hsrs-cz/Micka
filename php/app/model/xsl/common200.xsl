<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template name="contact" xmlns:gco="http://metadata.dgiwg.org/smXML">
  <xsl:param name="org"/>
  <xsl:for-each select="$org">
	<gco:CI_ResponsibleParty>
		<gco:organisationName>
			<gco:CharacterString><xsl:value-of select="organisationName"/></gco:CharacterString>
		</gco:organisationName>
		<gco:positionName>
			<gco:CharacterString><xsl:value-of select="positionName"/></gco:CharacterString>
		</gco:positionName>
		<gco:contactInfo>
			<gco:CI_Contact>
				<gco:phone>
					<gco:CI_Telephone>
						<xsl:for-each select="contactInfo/phone/voice">
						<gco:voice>
							<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
						</gco:voice>
						</xsl:for-each>
						<xsl:for-each select="contactInfo/phone/facsimile">
						<gco:facsimile>
							<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
						</gco:facsimile>
						</xsl:for-each>
					</gco:CI_Telephone>
				</gco:phone>
				<gco:address>
					<gco:CI_Address>
						<gco:deliveryPoint>
							<gco:CharacterString><xsl:value-of select="contactInfo/address/deliveryPoint"/></gco:CharacterString>
						</gco:deliveryPoint>
						<gco:city>
							<gco:CharacterString><xsl:value-of select="contactInfo/address/city"/></gco:CharacterString>
						</gco:city>
						<gco:administrativeArea>
							<gco:CharacterString><xsl:value-of select="contactInfo/address/administrativeArea"/></gco:CharacterString>
						</gco:administrativeArea>
						<gco:postalCode>
							<gco:CharacterString><xsl:value-of select="contactInfo/address/postalCode"/></gco:CharacterString>
						</gco:postalCode>
						<gco:country>
							<gco:CharacterString><xsl:value-of select="contactInfo/address/country"/></gco:CharacterString>
						</gco:country>
						<xsl:for-each select="contactInfo/address/electronicMailAddress">
						<gco:electronicMailAddress>
							<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
						</gco:electronicMailAddress>
						</xsl:for-each>
					</gco:CI_Address>
				</gco:address>
				<gco:onlineResource>
					<gco:CI_OnlineResource>
						<gco:linkage>
							<gco:URL><xsl:value-of select="contactInfo/onlineResource/linkage"/></gco:URL>
						</gco:linkage>
					</gco:CI_OnlineResource>
				</gco:onlineResource>
			</gco:CI_Contact>
		</gco:contactInfo>
		<gco:role>
			<gco:CI_RoleCode codeListValue="{pointOfContact/role/CI_RoleCode}" codeList="./resources/codeList.xml#CI_RoleCode"><xsl:value-of select="pointOfContact/role/CI_RoleCode"/></gco:CI_RoleCode>
		</gco:role>
	</gco:CI_ResponsibleParty>
  </xsl:for-each>  
  </xsl:template>

  
<!-- pro multilingualni data
	<xsl:attribute-set name="free" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	  <xsl:attribute name="xsi:type">PT_FreeText_PropertyType</xsl:attribute>
	</xsl:attribute-set>-->
  
  <xsl:template name="txt" 
    xmlns:gco="http://metadata.dgiwg.org/smXML">
		<xsl:param name="s"/>
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:element name="gco:{$name}" >
		  <gco:CharacterString><xsl:value-of select="$s/*[name()=$name]"/></gco:CharacterString>	
			<!--<PT_FreeText>
				<xsl:for-each select="$s/*[name()=$name]">
				  <xsl:if test="@lang != $lang">
						<textGroup>
							  <LocalisedCharacterString locale="locale_{@lang}"><xsl:value-of select="."/></LocalisedCharacterString>
						</textGroup>
					</xsl:if>	
				</xsl:for-each>
		  </PT_FreeText>	-->
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
