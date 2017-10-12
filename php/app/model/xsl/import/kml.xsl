<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gco="http://www.opengis.net/gco"
  xmlns:ows="http://www.opengis.net/ows/1.1"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
  xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0"
  xmlns:ext="http://exslt.org/common" exclude-result-prefixes="ext"
  >
  
  <xsl:output method="xml" encoding="utf-8"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="kml:kml" xmlns:kml="http://www.opengis.net/kml/2.2">
  <results>
    
    <MD_Metadata>
    
    <referenceSystemInfo>
    	<MD_ReferenceSystem>
    		<referenceSystemIdentifier>
    			<RS_Identifier>
    				<code>http://www.opengis.net/def/crs/EPSG/0/4326</code>
    			</RS_Identifier>
    		</referenceSystemIdentifier>
    	</MD_ReferenceSystem>
    </referenceSystemInfo>
    
    
    <identificationInfo>
    <MD_DataIdentification>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="//kml:Document/kml:name"/></title>
      <date>
      	<CI_Date>
      		<date><xsl:value-of select="substring-before(*/@updateSequence,'T')"/></date>
      		<dateType><CI_DateTypeCode>revision</CI_DateTypeCode></dateType>
      	</CI_Date>
      </date>
    </CI_Citation>  
    </citation>
    <abstract><xsl:value-of select="//kml:Document/kml:description"/></abstract>
    <!--  >spatialRepresentationType>
    	<MD_SpatialRepresentationTypeCode>vector</MD_SpatialRepresentationTypeCode>
    </spatialRepresentationType-->
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees> 
    			<xsl:value-of select="*/ows:ServiceIdentification/ows:Fees"/>
    	  </fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <characterSet>
    	<MD_CharacterSetCode>UTF-8</MD_CharacterSetCode>
    </characterSet>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="*/ows:ServiceIdentification/ows:Keywords/ows:Keyword">
        <keyword> <xsl:value-of select="."/> </keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <pointOfContact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:Role"/></CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </pointOfContact>

	<xsl:variable name="coor">
		<xsl:for-each select="//kml:coordinates">
			<xsl:value-of select="."/><xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="//kml:Location">
			<xsl:value-of select="kml:longitude"/>,<xsl:value-of select="kml:latitude"/><xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="coor1">
		<xsl:call-template name="split">
			<xsl:with-param name="s" select="normalize-space($coor)"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="xmin">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-before(.,',')" data-type="number" order="ascending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="ymin">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-after(.,',')" data-type="number" order="ascending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-after(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="xmax">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-before(.,',')" data-type="number" order="descending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="ymax">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-after(.,',')" data-type="number" order="descending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-after(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="tmin">
  		<xsl:for-each select="//kml:TimeSpan/kml:begin|//kml:TimeStamp/kml:when">
    		<xsl:sort select="." data-type="text" order="ascending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(concat(.,'T'),'T')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="tmax">
  		<xsl:for-each select="//kml:TimeSpan/kml:end|//kml:TimeStamp/kml:when">
    		<xsl:sort select="." data-type="text" order="descending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(concat(.,'T'),'T')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

    <extent>
	    <EX_Extent>
	      <geographicElement>
	        <EX_GeographicBoundingBox>
	          <!-- prasarna - vezme prvni, kterou najde  -->
	          <westBoundLongitude><xsl:value-of select="$xmin"/></westBoundLongitude>
	          <eastBoundLongitude><xsl:copy-of select="$xmax"/></eastBoundLongitude>
	          <southBoundLatitude><xsl:value-of select="$ymin"/></southBoundLatitude>
	          <northBoundLatitude><xsl:value-of select="$ymax"/></northBoundLatitude>
	        </EX_GeographicBoundingBox>
	      </geographicElement>
	
	      <temporalElement>
	      	<EX_TemporalExtent>
	      		<extent>
	      			<TimePeriod>
	      				<beginPosition><xsl:value-of select="$tmin"/></beginPosition>
	      				<endPosition><xsl:value-of select="$tmax"/></endPosition>
	      			</TimePeriod>
	      		</extent>
	      	</EX_TemporalExtent>
	      </temporalElement>
	    </EX_Extent>  
    </extent>
	</MD_DataIdentification>
 	</identificationInfo>  	
    

    <!-- distribuce -->
    <distributionInfo>
    <MD_Distribution>
      <transferOptions>
      <MD_DigitalTransferOptions>
        <onLine>
        <CI_OnlineResource>
          <linkage><xsl:value-of select="$URL"/></linkage>
          <protocol>OGC:KML</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>      
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

	
    <metadataStandardName>ISO 19115/19119</metadataStandardName>
    <metadataStandardVersion>2003/cor.1/2006</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>dataset</MD_ScopeCode>
  	</hierarchyLevel>

	
  	
    </MD_Metadata>
 
  
  </results>  
    
  </xsl:template>

  <xsl:template match="kml:kml" xmlns:kml="http://earth.google.com/kml/2.2">
  <results>
    
    <MD_Metadata>
    
    <referenceSystemInfo>
    	<MD_ReferenceSystem>
    		<referenceSystemIdentifier>
    			<RS_Identifier>
    				<code>http://www.opengis.net/def/crs/EPSG/0/4326</code>
    			</RS_Identifier>
    		</referenceSystemIdentifier>
    	</MD_ReferenceSystem>
    </referenceSystemInfo>
    
    
    <identificationInfo>
    <MD_DataIdentification>
    <citation>
    <CI_Citation>
      <title><xsl:value-of select="//kml:Document/kml:name"/></title>
      <date>
      	<CI_Date>
      		<date><xsl:value-of select="substring-before(*/@updateSequence,'T')"/></date>
      		<dateType><CI_DateTypeCode>revision</CI_DateTypeCode></dateType>
      	</CI_Date>
      </date>
    </CI_Citation>  
    </citation>
    <abstract><xsl:value-of select="//kml:Document/kml:description"/></abstract>
    <!--  >spatialRepresentationType>
    	<MD_SpatialRepresentationTypeCode>vector</MD_SpatialRepresentationTypeCode>
    </spatialRepresentationType-->
    <accessProperties>
    	<MD_StandardOrderProcess>
    		<fees> 
    			<xsl:value-of select="*/ows:ServiceIdentification/ows:Fees"/>
    	  </fees>
    	</MD_StandardOrderProcess> 
    </accessProperties>
    <characterSet>
    	<MD_CharacterSetCode>UTF-8</MD_CharacterSetCode>
    </characterSet>
    <descriptiveKeywords>
      <MD_Keywords>
      <xsl:for-each select="*/ows:ServiceIdentification/ows:Keywords/ows:Keyword">
        <keyword> <xsl:value-of select="."/> </keyword>
      </xsl:for-each>
      </MD_Keywords>
    </descriptiveKeywords>
    <pointOfContact>
      <CI_ResponsibleParty>
	    <individualName><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:IndividualName"/></individualName>
	    <organisationName><xsl:value-of select="*/ows:ServiceProvider/ows:ProviderName"/></organisationName>
	    <positionName><xsl:value-of select="*/ows:ServiceProvider/ows:PositionName"/></positionName>
	    <contactInfo>
	    <CI_Contact>
	      <phone>
	      	<CI_Telephone>
	          <voice><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Phone/ows:Voice"/></voice>
	        </CI_Telephone>
	      </phone>
		    <address>
		      <CI_Address>
		        <deliveryPoint><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:DeliveryPoint"/></deliveryPoint>
		        <city><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:City"/></city>
		        <postalCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:PostalCode"/></postalCode>
		        <country><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:Country"/></country>
		        <electronicMailAddress><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress"/></electronicMailAddress>
		      </CI_Address>
		    </address>
		    <onlineResource>
		    	<CI_OnlineResource>
		    		<linkage>
		    			<URL><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:ContactInfo/ows:OnlineResource/@xlink:href"/></URL>
		    		</linkage>
		    	</CI_OnlineResource>
		    </onlineResource>
	      </CI_Contact>
	    </contactInfo>
	    <role>
	    	<CI_RoleCode><xsl:value-of select="*/ows:ServiceProvider/ows:ServiceContact/ows:Role"/></CI_RoleCode> 
	    </role>
      </CI_ResponsibleParty>
    </pointOfContact>

	<xsl:variable name="coor">
		<xsl:for-each select="//kml:coordinates">
			<xsl:value-of select="."/><xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="//kml:Location">
			<xsl:value-of select="kml:longitude"/>,<xsl:value-of select="kml:latitude"/><xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:for-each select="//kml:LatLonBox">
			<xsl:value-of select="kml:west"/>,<xsl:value-of select="kml:south"/><xsl:text> </xsl:text>
			<xsl:value-of select="kml:east"/>,<xsl:value-of select="kml:north"/><xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="coor1">
		<xsl:call-template name="split">
			<xsl:with-param name="s" select="normalize-space($coor)"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="xmin">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-before(.,',')" data-type="number" order="ascending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="ymin">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-after(.,',')" data-type="number" order="ascending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-after(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="xmax">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-before(.,',')" data-type="number" order="descending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="ymax">
  		<xsl:for-each select="ext:node-set($coor1)/*">
    		<xsl:sort select="substring-after(.,',')" data-type="number" order="descending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-after(.,',')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="tmin">
  		<xsl:for-each select="//kml:TimeSpan/kml:begin|//kml:TimeStamp/kml:when">
    		<xsl:sort select="." data-type="text" order="ascending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(concat(.,'T'),'T')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="tmax">
  		<xsl:for-each select="//kml:TimeSpan/kml:end|//kml:TimeStamp/kml:when">
    		<xsl:sort select="." data-type="text" order="descending"/>
    		<xsl:if test="position() = 1"><xsl:value-of select="substring-before(concat(.,'T'),'T')"/></xsl:if>
  		</xsl:for-each>
	</xsl:variable>

    <extent>
	    <EX_Extent>
	      <geographicElement>
	        <EX_GeographicBoundingBox>
	          <!-- prasarna - vezme prvni, kterou najde  -->
	          <westBoundLongitude><xsl:value-of select="$xmin"/></westBoundLongitude>
	          <eastBoundLongitude><xsl:copy-of select="$xmax"/></eastBoundLongitude>
	          <southBoundLatitude><xsl:value-of select="$ymin"/></southBoundLatitude>
	          <northBoundLatitude><xsl:value-of select="$ymax"/></northBoundLatitude>
	        </EX_GeographicBoundingBox>
	      </geographicElement>
	
	      <temporalElement>
	      	<EX_TemporalExtent>
	      		<extent>
	      			<TimePeriod>
	      				<beginPosition><xsl:value-of select="$tmin"/></beginPosition>
	      				<endPosition><xsl:value-of select="$tmax"/></endPosition>
	      			</TimePeriod>
	      		</extent>
	      	</EX_TemporalExtent>
	      </temporalElement>
	    </EX_Extent>  
    </extent>
	</MD_DataIdentification>
 	</identificationInfo>  	
    

    <!-- distribuce -->
    <distributionInfo>
    <MD_Distribution>
      <transferOptions>
      <MD_DigitalTransferOptions>
        <onLine>
        <CI_OnlineResource>
          <linkage><xsl:value-of select="$URL"/></linkage>
          <protocol>OGC:KML</protocol>
		  <function><CI_OnLineFunctionCode>download</CI_OnLineFunctionCode></function>
		</CI_OnlineResource>      
        </onLine>
      </MD_DigitalTransferOptions>  
      </transferOptions>
    </MD_Distribution>
    </distributionInfo>

	
    <metadataStandardName>ISO 19115/19119</metadataStandardName>
    <metadataStandardVersion>2003/cor.1/2006</metadataStandardVersion>
  	<hierarchyLevel>
  	  <MD_ScopeCode>dataset</MD_ScopeCode>
  	</hierarchyLevel>

	
  	
    </MD_Metadata>
 
  
  </results>  
    
  </xsl:template>
  
  <!-- rozdeleni retezce podle mezer -->
  <xsl:template match="text()" name="split">
  <xsl:param name="s" select="."/>
   <xsl:if test="string-length($s) >0">
    <item>
     <xsl:value-of select="substring-before(concat($s, ' '), ' ')"/>
    </item>

    <xsl:call-template name="split">
     <xsl:with-param name="s" select="substring-after($s, ' ')"/>
    </xsl:call-template>
   </xsl:if>
 </xsl:template>
  
</xsl:stylesheet>