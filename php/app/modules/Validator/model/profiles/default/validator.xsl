<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"/>


<xsl:template match="//gmd:MD_Metadata"  
xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml/3.2"
xmlns:srv="http://www.isotc211.org/2005/srv"
xmlns:gmd="http://www.isotc211.org/2005/gmd"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:php="http://php.net/xsl">

<xsl:variable name="codeLists" select="document('../../include/xsl/codelists_cze.xml')/map" />
<xsl:variable name="srv" select="gmd:identificationInfo/srv:SV_ServiceIdentification != ''"/>

 
<validationResult>
<!-- identifikace -->

<!-- 1.1 -->
<test code="2.2.1" level="m">
	<description>Název zdroje</description>
	<xpath>identificationInfo[1]/*/citation/*/title</xpath>  
  	<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString))>0">
	    <value><xsl:value-of select="gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.2 -->
<test code="2.2.2" level="m">
	<description>Abstract zdroje</description>
	<xpath>identificationInfo[1]/*/abstract</xpath>  
    <xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:abstract))>0">
	   <value><xsl:value-of select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/></value>
	   <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.3 -->
<test code="2.2.3" level="m">
	<description>Typ zdroje</description>
	<xpath>hierarchyLevel</xpath>
	<xsl:if test="gmd:hierarchyLevel/*/@codeListValue='dataset' or gmd:hierarchyLevel/*/@codeListValue='service' or gmd:hierarchyLevel/*/@codeListValue='series'">
	    <value><xsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/></value>
	    <pass>true</pass>
	</xsl:if>
</test>

<!-- 1.4 -->
<test code="2.2.4" level="c">
	<description>Lokátor zdroje</description>
	<xpath>distributionInfo/*/transferOptions/*/onLine/*/linkage</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage))>0">
      <pass>true</pass>	    
	    <!--  <xsl:for-each select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
        <test code="a" level="c">
        	<xpath>distributionInfo/*/transferOptions/*/onLine/*/protocol</xpath>
	        <xsl:choose>
	           <xsl:when test="*/gmd:protocol/*!=''">
	             <value><xsl:value-of select="*/gmd:linkage"/> (<xsl:value-of select="*/gmd:protocol"/>)</value>
	             <pass>true</pass>
             </xsl:when>
             <xsl:otherwise>
                <err><xsl:value-of select="*/gmd:linkage"/> - Chybí protokol</err>
             </xsl:otherwise>
          </xsl:choose>  	
	      </test> 
      </xsl:for-each>   -->
	  </xsl:when>
	</xsl:choose>
</test>

<!-- 1.5 -->
<xsl:if test="not($srv)">	
	 <test code="2.2.5">
	 	<description>Jedinečný identifikátor zdroje</description>
	 	<xpath>identificationInfo[1]/*/citation/*/identifier</xpath>
		<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:citation//gmd:identifier//gmd:code))>0">
		   <value><xsl:value-of select="gmd:identificationInfo/*/gmd:citation//gmd:identifier//gmd:code"/></value>
		   <pass>true</pass>
		</xsl:if>
	</test>
</xsl:if>	
  
<!-- 1.6 -->   
<xsl:if test="$srv">
	 <test code="2.2.6" level="c">
	 	<description>Vázaný zdroj (Coupled resource)</description>
	 	<xpath>identificationInfo[1]/*/operatesOn</xpath>
  		<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/srv:operatesOn/@xlink:href))>0">
  			<value>
  				<xsl:for-each select="gmd:identificationInfo/*/srv:operatesOn/@xlink:href">
  					<xsl:value-of select="."/>
  				</xsl:for-each>
  			</value>
  			<pass>true</pass>
  		</xsl:if>
  	</test>	
</xsl:if>

<xsl:if test="not($srv)">
	<!-- 1.7 -->
	 <test code="2.2.7" level="c">
	 	<description>Jazyk zdroje</description>
	 	<xpath>identificationInfo[1]/*/language</xpath>
			<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:language))>0">
		   <value><xsl:value-of select="gmd:identificationInfo/*/gmd:language/*/@codeListValue"/></value>
		   <pass>true</pass>
		</xsl:if>
	</test>

  	<!-- 2.1 --> 	
	 <test code="2.3.1">
	 	<description>Tématické kategorie</description>
	 	<xpath>identificationInfo[1]/*/topicCategory</xpath>
			<xsl:if test="string-length(normalize-space(gmd:identificationInfo//gmd:topicCategory))>0">
		   <value><xsl:value-of select="gmd:identificationInfo//gmd:topicCategory"/></value>
		   <pass>true</pass>
		</xsl:if>
	</test>
</xsl:if>

<xsl:if test="$srv">
  	<!-- 2.2 -->
	 <test code="2.3.2">
	 	<description>Typ služby založené na prostorových datech</description>
	 	<xpath>identificationInfo[1]/*/srv:serviceType</xpath>
		<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/srv:serviceType))>0">
		   <value><xsl:value-of select="gmd:identificationInfo/*/srv:serviceType"/></value>
		   <pass>true</pass>
		</xsl:if>
	</test>
</xsl:if>

<!-- 3 -->
<xsl:choose>
	<xsl:when test="$srv">
		<test code="2.4.1-2">
		 	<description>Klíčové slovo INSPRE services</description>
		 	<xpath>identificationInfo/*/descriptiveKeywords/MD_Keywords[contains(thesaurusName/*/title,'INSPIRE Services')]/keyword</xpath>
		 	<xsl:if test="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'INSPIRE Services')]/gmd:keyword/gco:CharacterString">
				<value>
					<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'INSPIRE Services')]/gmd:keyword">
						<xsl:value-of select="gco:CharacterString"/>
						<xsl:if test="not(position()=last())">, </xsl:if>
					</xsl:for-each>
				</value>	
				<pass>true</pass>
			</xsl:if>
		</test>	
	</xsl:when>
	<xsl:otherwise>
		<test code="2.4.1">
		 	<description>Klíčová slova INSPIRE</description>
		 	<xpath>identificationInfo/*/descriptiveKeywords/MD_Keywords[contains(thesaurusName/*/title,'GEMET - INSPIRE themes')]/keyword</xpath>
		 	<xsl:if test="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'GEMET - INSPIRE themes')]/gmd:keyword/gco:CharacterString">
				<value><xsl:value-of select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'GEMET - INSPIRE themes')]/gmd:thesaurusName/*/gmd:title/gco:CharacterString"/></value>
				<pass>true</pass>
				<xsl:for-each select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[contains(gmd:thesaurusName/*/gmd:title/gco:CharacterString,'GEMET - INSPIRE themes')]/gmd:keyword">
						<xsl:variable name="kw" select="normalize-space(gco:CharacterString)"/>
						<test code="2.4.2">
							<description>Klíčové slovo</description>
							<xsl:choose>
								<xsl:when test="$codeLists/specifications/value[.=$kw]!=''">
									<value><xsl:value-of select="$kw"/></value>
									<pass>true</pass>
								</xsl:when>
								<xsl:otherwise>
									<err><xsl:value-of select="$kw"/> neodpovídá INSPIRE</err>
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
	  	<xsl:for-each select="gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement">

			<test code="2.5.1">
				<description>Geografické ohraničení (Geographic bounding box)</description>
				<xpath>identificationInfo/*/extent/*/geographicElement[<xsl:value-of select="position()"/>]</xpath>
			  	<xsl:choose>
			  		<xsl:when test="*/gmd:westBoundLongitude &lt; */gmd:eastBoundLongitude and */gmd:southBoundLatitude &lt; */gmd:northBoundLatitude and */gmd:westBoundLongitude &gt; -180 and */gmd:eastBoundLongitude &lt; 180 and */gmd:southBoundLatitude &gt; -90 and */gmd:northBoundLatitude &lt; 90">
				    	<value>
				    		<xsl:value-of select="*/gmd:westBoundLongitude"/>,
				    		<xsl:value-of select="*/gmd:southBoundLatitude"/>,
				    		<xsl:value-of select="*/gmd:eastBoundLongitude"/>, 
				    		<xsl:value-of select="*/gmd:northBoundLatitude"/>
				    	</value>
				    	<pass>true</pass>
			    	</xsl:when>
			    	<xsl:otherwise>
						<err>Chybný rozsah:
				    		<xsl:value-of select="*/gmd:westBoundLongitude"/>,
				    		<xsl:value-of select="*/gmd:southBoundLatitude"/>,
				    		<xsl:value-of select="*/gmd:eastBoundLongitude"/>, 
				    		<xsl:value-of select="*/gmd:northBoundLatitude"/>
			    		</err>
			    	</xsl:otherwise>
			    </xsl:choose>
			</test>
	    </xsl:for-each>

	</xsl:when>
	<xsl:otherwise>
		<test code="2.5.1">
			<description>Geografické ohraničení (Geographic bounding box)</description>
			<xpath>identificationInfo/*/extent/*/geographicElement</xpath>
		</test>	
	</xsl:otherwise>
</xsl:choose>


</xsl:if>

<xsl:if test="$srv">
<xsl:choose>
	<xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox))>0 ">
	  	<xsl:for-each select="gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement">

			<test code="2.5.1">
				<description>Geografické ohraničení (Geographic bounding box)</description>
				<xpath>identificationInfo/*/extent/*/geographicElement[<xsl:value-of select="position()"/>]</xpath>
			  	<xsl:choose>
			  		<xsl:when test="*/gmd:westBoundLongitude &lt; */gmd:eastBoundLongitude and */gmd:southBoundLatitude &lt; */gmd:northBoundLatitude and */gmd:westBoundLongitude &gt; -180 and */gmd:eastBoundLongitude &lt; 180 and */gmd:southBoundLatitude &gt; -90 and */gmd:northBoundLatitude &lt; 90">
				    	<value>
				    		<xsl:value-of select="*/gmd:westBoundLongitude"/>,
				    		<xsl:value-of select="*/gmd:southBoundLatitude"/>,
				    		<xsl:value-of select="*/gmd:eastBoundLongitude"/>, 
				    		<xsl:value-of select="*/gmd:northBoundLatitude"/>
				    	</value>
				    	<pass>true</pass>
			    	</xsl:when>
			    	<xsl:otherwise>
						<err>Chybný rozsah:
				    		<xsl:value-of select="*/gmd:westBoundLongitude"/>,
				    		<xsl:value-of select="*/gmd:southBoundLatitude"/>,
				    		<xsl:value-of select="*/gmd:eastBoundLongitude"/>, 
				    		<xsl:value-of select="*/gmd:northBoundLatitude"/>
			    		</err>
			    	</xsl:otherwise>
			    </xsl:choose>
			</test>
	    </xsl:for-each>

	</xsl:when>
	<xsl:otherwise>
		<test code="2.5.1">
			<description>Geografické ohraničení (Geographic bounding box)</description>
			<xpath>identificationInfo/*/extent/*/geographicElement</xpath>
		</test>	
	</xsl:otherwise>
</xsl:choose>
</xsl:if>

<!-- 5.1 -->
<test code="2.6.1" level="c">	
	<description>Časový rozsah (Temporal extent)</description>
	<xpath>identificationInfo/*/extent/*/temporalElement</xpath>	
	<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:extent//gmd:temporalElement))>0">
     	<value><xsl:value-of select="gmd:identificationInfo/*/gmd:extent//gmd:temporalElement"/></value>
		<pass>true</pass>
	</xsl:if>
</test>  

  
<!-- 5.2 -->
<test code="2.6.2-4">
	<description>Datum (vytvoření/zveřejnění/revize)</description>
	<xpath>identificationInfo/*/citation/*/date</xpath>	
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:citation/*/gmd:date/*/gmd:date))>0">
		<pass>true</pass>
			<xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date">	 	
				<test code="a">
				<description>Datum + typ</description>
				<xpath>identificationInfo/*/citation/*/date/*/dateType</xpath>	
			 	<xsl:choose>
				  <xsl:when test="string-length(normalize-space(*/gmd:dateType/*/@codeListValue))>0">
				    <value><xsl:value-of select="*/gmd:dateType/*/@codeListValue"/>:<xsl:value-of select="*/gmd:date/*"/></value>
				    <pass>true</pass>
				  </xsl:when>
				  <xsl:otherwise>
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
	<!-- 6.1 -->
	<test code="2.7.1">
		<description>Původ (Lineage)</description>
		<xpath>dataQualityInfo/*/lineage/*/statement</xpath>	
		<xsl:if test="string-length(normalize-space(gmd:dataQualityInfo//gmd:lineage//gmd:statement))>0">
		  <value><xsl:value-of select="gmd:dataQualityInfo//gmd:lineage//gmd:statement/gco:CharacterString"/></value>
		  <pass>true</pass>
		</xsl:if>
	</test>	

	<!-- 6.2 -->
	<test code="2.7.2">
		<description>Prostorové rozlišení (Spatial resolution)</description>
		<xpath>identificationInfo/*/gmd:spatialResolution</xpath>	
		<xsl:if test="string-length(normalize-space(gmd:identificationInfo/*/gmd:spatialResolution))>0">
	   		<value><xsl:value-of select="gmd:identificationInfo/*/gmd:spatialResolution"/></value>
			<pass>true</pass>
		</xsl:if>
	</test>	

	<!-- 7.2 -->
	<test code="2.8.1" level="c">
		<description>Míra souladu (Degree)</description>
		<xpath>dataQualityInfo/*/report/*/result/*/pass</xpath>
    	<xsl:choose>
      		<xsl:when test="string-length(normalize-space(gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:pass))>0">
	   			<value><xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:pass"/></value>
			  	<pass>true</pass>
		  	</xsl:when>
		  	<xsl:otherwise>
		    	<err>Nehodnoceno</err>
		  	</xsl:otherwise>
		</xsl:choose>
	</test>	

	<!-- 7.1 -->
	<test code="2.8.2" level="c">
		<description>Specifikace (Specification)</description>
		<xpath>dataQualityInfo/*/report/*/result/*/specification</xpath>
    	<xsl:choose>
    		<xsl:when test="contains(gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification, 'INSPIRE Data Specification')">
	   	 		<value><xsl:value-of select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification"/></value>
			 	<pass>true</pass>
		  	</xsl:when>
		  	<xsl:otherwise>
		    	<err>Nehodnoceno</err>
		  	</xsl:otherwise>
		</xsl:choose>  
	</test>	


</xsl:if>


<!-- 8.2 -->
<test code="2.9.1">
	<description>Omezení veřejného přístupu (Limitations on public access)</description>
	<xpath>identificationInfo/*/resourceConstraints/*/accessConstraints</xpath>
	<xsl:choose>
	  <xsl:when test="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:accessConstraints/*/@codeListValue='otherRestrictions' and gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints/*!=''">
	    <value>otherRestrictions: <xsl:value-of select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints/*"/></value>
	    <pass>true</pass>
	  </xsl:when>
	  <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:accessConstraints/*/@codeListValue))>0 and gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:accessConstraints/*/@codeListValue!='otherRestrictions'">
	    <value><xsl:value-of select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:accessConstraints/*/@codeListValue"/></value>
	    <pass>true</pass>
	  </xsl:when>
	  <xsl:otherwise>
	  </xsl:otherwise>
	</xsl:choose>
</test>

<!-- 8.1 -->
<test code="2.9.2">
	<description>Podmínky vztahující se k přístupu a použití (Conditions applying to access and use)</description>
	<xpath>identificationInfo/*/resourceConstraints/*/useLimitation</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation))>0">
	    <value><xsl:value-of select="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation"/></value>
	    <pass>true</pass>
	  </xsl:when>
	  <xsl:otherwise>
	  </xsl:otherwise>
	</xsl:choose>
</test>


<!-- 9.1 -->
<xsl:choose>
<xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/gmd:pointOfContact))>0">
	<xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact">
		<test code="2.10.1">
			<description>Odpovědná osoba nebo organizace (Responsible party)</description>
			<xpath>identificationInfo/*/pointOfContact</xpath>
	  		<pass>true</pass>  		
	  			<test code="a">
					<description>Název</description>
					<xpath>organisationName</xpath>			  	
					<xsl:if test="*/gmd:organisationName/gco:CharacterString!=''">
				    	<value><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></value>
				    	<pass>true</pass>
				    </xsl:if>
		    	</test>
	  			<test code="b">
					<description>e-mail</description>
					<xpath>contactInfo/*/address/*/electronicMailAddress</xpath>			  	
					<xsl:choose>
					<xsl:when test="php:function('isEmail',string(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString))">
				    	<value><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/></value>
				    	<pass>true</pass>
				    </xsl:when>
				    <xsl:otherwise>
				    	<err><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/> - není validní</err>
				    </xsl:otherwise>
				    </xsl:choose>
		    	</test>
	  			<test code="c">
					<description>Role (role)</description>
					<xpath>role/*/@codeListValue</xpath>			  	
					<xsl:if test="*/gmd:role/*/@codeListValue!=''">
				    	<value><xsl:value-of select="*/gmd:role/*/@codeListValue"/></value>
				    	<pass>true</pass>
				    </xsl:if>
		    	</test>
		</test>
	</xsl:for-each>	
</xsl:when>
<xsl:otherwise>
	<test code="2.10.1">
		<description>Odpovědná osoba nebo organizace (Responsible party)</description>
		<xpath>identificationInfo/*/pointOfContact</xpath>
	</test>	
</xsl:otherwise>
</xsl:choose>

<!-- metadata -->
    
<xsl:choose>
<xsl:when test="string-length(normalize-space(gmd:contact))>0">
	<xsl:for-each select="gmd:contact">
		<test code="2.11.1">
			<description>Kontaktní místo pro metadata (Metadata point of contact)</description>
			<xpath>contactInfo</xpath>
	  		<pass>true</pass>  		
	  			<test code="a">
					<description>Název</description>
					<xpath>organisationName</xpath>			  	
					<xsl:if test="*/gmd:organisationName/gco:CharacterString!=''">
				    	<value><xsl:value-of select="*/gmd:organisationName/gco:CharacterString"/></value>
				    	<pass>true</pass>
				    </xsl:if>
		    	</test>
	  			<test code="b">
					<description>e-mail</description>
					<xpath>contactInfo/*/address/*/electronicMailAddress</xpath>			  	
					<xsl:choose>
					<xsl:when test="php:function('isEmail',string(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString))">
				    	<value><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/></value>
				    	<pass>true</pass>
				    </xsl:when>
				    <xsl:otherwise>
				    	<err><xsl:value-of select="*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/> - není validní</err>
				    </xsl:otherwise>
				    </xsl:choose>
		    	</test>
	  			<test code="c">
					<description>Role (role)</description>
					<xpath>role/*/@codeListValue</xpath>			  	
					<xsl:if test="*/gmd:role/*/@codeListValue!=''">
				    	<value><xsl:value-of select="*/gmd:role/*/@codeListValue"/></value>
				    	<pass>true</pass>
				    </xsl:if>
		    	</test>
		</test>
	</xsl:for-each>	
</xsl:when>
<xsl:otherwise>
	<test code="2.10.1">
		<description>Odpovědná osoba nebo organizace (Responsible party)</description>
		<xpath>identificationInfo/*/pointOfContact</xpath>
	</test>	
</xsl:otherwise>
</xsl:choose>
	
<!-- 10.2 -->
<test code="2.11.2">
	<description>Datum metadat (Metadata date)</description>
	<xpath>dateStamp</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:dateStamp))>0">
	    <value><xsl:value-of select="gmd:dateStamp"/></value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>


<!-- 10.3 -->
<test code="2.11.3">
	<description>Jazyk metadat (Metadata language)</description>
	<xpath>language</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:language))>0">
	    <value><xsl:value-of select="gmd:language"/></value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>

<test code="CZ-0" level="m">
	<description>fileIdentifier</description>
	<xpath>fileIdentifier</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:fileIdentifier))>0">
	    <value><xsl:value-of select="gmd:fileIdentifier"/></value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>

<!-- CZ -->
<xsl:if test="not($srv)">
<test code="CZ-1" level="c">
	<description>Distributor</description>
	<xpath>distributionInfo/*/distributor/*/distributorContact/*/organisationName/*</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorContact/*/gmd:organisationName/*))>0">
	    <value><xsl:value-of select="gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorContact/*/gmd:organisationName/*"/></value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>
<test code="CZ-2" level="m">
	<description>Oblast působnosti - jakost</description>
	<xpath>dataQualityInfo/*/scope/*/level/*/@codeListValue</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:dataQualityInfo/*/gmd:scope/*/gmd:level/*/@codeListValue))>0">
	    <value><xsl:value-of select="gmd:dataQualityInfo/*/gmd:scope/*/gmd:level/*/@codeListValue"/></value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>
</xsl:if>
 
 <xsl:if test="$srv">
<test code="CZ-3" level="m">
	<description>Typ vazby</description>
	<xpath>identificationInfo/*/couplingType/*/@codeListValue</xpath>
	<xsl:choose>
	  <xsl:when test="string-length(normalize-space(gmd:identificationInfo/*/srv:couplingType/*/@codeListValue))>0">
	    <value><xsl:value-of select="gmd:identificationInfo/*/srv:couplingType/*/@codeListValue"/></value>
	    <pass>true</pass>
	  </xsl:when>
	</xsl:choose>
</test>
</xsl:if>
    
</validationResult>

</xsl:template>


</xsl:stylesheet>
