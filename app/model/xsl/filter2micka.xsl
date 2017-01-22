<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" 
  xmlns:ogc="http://www.opengis.net/ogc" 
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:gml="http://www.opengis.net/gml" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:apiso="http://www.opengis.net/cat/csw/apiso/1.0" 

  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:dct="http://purl.org/dc/terms/" 
  xmlns:ows="http://www.opengis.net/ows" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
  xmlns:hs="http://www.hsrs.cz/micka"
  >

  <xsl:output encoding="utf-8"/> 
  <xsl:output method="html"/>

  	<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
   	<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
     <xsl:apply-templates /> 
  </xsl:template>
  
  <!-- SOAP -->
  <xsl:template match="soap:Envelope">
      $params['SOAP'] = true;
      <xsl:apply-templates />
  </xsl:template>  
  <xsl:template match="soap:Body">
      <xsl:apply-templates />
  </xsl:template>  

  <xsl:template match="soap:Header">
      <!-- proprietarni hlavicka -->
      <xsl:if test="hs:Token">
	  	$params['TOKEN'] = "<xsl:value-of select="hs:Token" />";
	  </xsl:if>
      <xsl:if test="hs:User">
	  	$params['USER'] = "<xsl:value-of select="hs:User" />";
	  </xsl:if>
	  $params['GROUP_EDIT'] = "<xsl:value-of select="hs:Edit" />";
   	  $params['GROUP_READ'] = "<xsl:value-of select="hs:Read" />";
   	  $params['IS_PUBLIC'] = "<xsl:value-of select="hs:Public" />";
  </xsl:template>
  	  
  <!-- GET RECORDS -->
  <xsl:template match="csw:GetRecords">
	  $params['SERVICE'] = "<xsl:value-of select="@service" />";
	  $params['REQUEST'] = "getrecords";
	  $params['VERSION'] = "<xsl:value-of select="@version" />";
	  $params['REQUESTID'] = "<xsl:value-of select="@requestId" />";
	  $params['RESULTTYPE'] = "<xsl:value-of select="@resultType" />";
	  $params['MAXRECORDS'] = intval("0<xsl:value-of select="@maxRecords" />");
	  $params['HOPCOUNT'] = 0<xsl:value-of select="//csw:DistributedSearch/@hopCount" />;
	  $params['OUTPUTSCHEMA'] = "<xsl:value-of select="@outputSchema" />";
	  $params['STARTPOSITION'] = intval("0<xsl:value-of select="@startPosition" />");
	  $params['OUTPUTFORMAT'] = "<xsl:value-of select="@outputFormat" />";
	  $params['ELEMENTSETNAME'] = "<xsl:value-of select="//csw:ElementSetName" />";
	  $params['TYPENAMES'] = "<xsl:value-of select="//csw:Query/@typeNames" />";
	  $params['DEBUG'] = "<xsl:value-of select="@debug" />";
	
	  <xsl:for-each select="./*">$params['REQTYPE'] = "<xsl:value-of select="local-name()" />"; </xsl:for-each>  

	  	$params['QSTR'] = "";
	  	<xsl:if test="//ogc:Filter!=''">
	  		$params['QSTR'] = array(<xsl:call-template name="rek">
	  	<xsl:with-param name="nod" select="//ogc:Filter"/>       
	  </xsl:call-template>);
		</xsl:if>
	  
	  <xsl:variable name="s" select="translate(//ogc:SortBy/ogc:SortProperty/ogc:PropertyName,$upper,$lower)"/>
	  <xsl:variable name="sort">
		  <xsl:choose>
		  	<xsl:when test="contains($s,'modified') or contains($s,'date')">date</xsl:when>
		  	<xsl:when test="contains($s,'title')">title</xsl:when>
		  	<xsl:when test="contains($s,'bbox')">bbox</xsl:when>
		  </xsl:choose>	  
	  </xsl:variable>
		
	$params['SORTBY'] = "<xsl:value-of select="$sort"/>";
	<xsl:if test="$sort and //ogc:SortBy/ogc:SortProperty/ogc:SortOrder">
	  	$params['SORTBY'] .= "|<xsl:value-of select="//ogc:SortBy/ogc:SortProperty/ogc:SortOrder"/>";
	</xsl:if>	
  </xsl:template>

  <!-- GET RECORD BY ID -->
  <xsl:template match="csw:GetRecordById">
    $params['SERVICE'] = "<xsl:value-of select="@service" />";
    $params['REQUEST'] = "getrecordbyid";
    $params['VERSION'] = "<xsl:value-of select="@version" />";
    $params['TYPENAMES'] = "<xsl:value-of select="//csw:Query/@typeNames" />";
    $params['ELEMENTSETNAME'] = "<xsl:value-of select="//csw:ElementSetName" />";
    $params['OUTPUTSCHEMA'] = "<xsl:value-of select="@outputSchema" />";
    $params['DEBUG'] = "<xsl:value-of select="@debug" />";
    <xsl:for-each select="//csw:Id">
      $params['ID'] .= "<xsl:value-of select="." />
      <xsl:if test="not(position()=last())">,</xsl:if> 
    </xsl:for-each>";   
  </xsl:template>

  <!-- GET CAPABILITIES -->
  <xsl:template match="csw:GetCapabilities">
    $params['SERVICE'] = "<xsl:value-of select="@service" />";
    $params['REQUEST'] = "getcapabilities";
    <xsl:for-each select="ows:AcceptVersions/ows:Version">$params['ACCEPTVERSIONS'] .= "<xsl:value-of select="." />,"; </xsl:for-each>
    $params['DEBUG'] = "<xsl:value-of select="@debug" />";
  </xsl:template>

  <!-- DESCRIBE RECORD -->
  <xsl:template match="csw:DescribeRecord">
    $params['SERVICE'] = "<xsl:value-of select="@service" />";
    $params['REQUEST'] = "describerecord";
    $params['VERSION'] = "<xsl:value-of select="@version" />";
    $params['DEBUG'] = "<xsl:value-of select="@debug" />";
  </xsl:template>

 <!-- HARVEST -->
  <xsl:template match="csw:Harvest">
    $params['SERVICE'] = "<xsl:value-of select="@service" />";
    $params['REQUEST'] = "harvest";
    $params['VERSION'] = "<xsl:value-of select="@version" />";
  	$params['SOURCE'] = "<xsl:value-of select="csw:Source" />";
 	$params['RESOURCETYPE'] = "<xsl:value-of select="csw:ResourceType" />";
 	$params['RESOURCEFORMAT'] = "<xsl:value-of select="csw:ResourceFormat" />";
 	$params['HARVESTINTERVAL'] = "<xsl:value-of select="csw:HarvestInterval" />";
 	$params['HANDLERS'] = "<xsl:for-each select="csw:ResponseHandler"><xsl:value-of select="." />|</xsl:for-each>";
  </xsl:template>

 <!-- TRANSACTION -->
  <xsl:template match="csw:Transaction">
    $params['SERVICE'] = "<xsl:value-of select="@service" />";
    $params['REQUEST'] = "transaction";
    $params['VERSION'] = "<xsl:value-of select="@version" />";
    $params['DEBUG'] = "<xsl:value-of select="@debug" />";
    <xsl:for-each select="./*">$params['REQTYPE'] = "<xsl:value-of select="local-name()" />";</xsl:for-each>

	$params['QSTR'] = "";
	<xsl:if test="//ogc:Filter!=''">
		$params['QSTR'] = <xsl:call-template name="rek">
	  <xsl:with-param name="nod" select="//ogc:Filter"/>       
	  </xsl:call-template>; 
	</xsl:if>
  </xsl:template>

  <!-- rekurzivni processing-->
  <xsl:template name="rek">
    <xsl:param name="nod"/>
    <xsl:variable name="n" select="./ogc:PropertyName"/><xsl:choose>
	
	  <!-- and/or -->
      <xsl:when test="local-name()='Or' or local-name()='And'">array(
        <xsl:variable name="OrAnd" select="local-name()"/> 
        <xsl:for-each select="$nod">
          <xsl:call-template name="rek">
            <xsl:with-param name="nod" select="*"/>
		  </xsl:call-template>
          <xsl:if test="not(position()=last())">
            ,"<xsl:value-of select="$OrAnd"/>",
          </xsl:if>
        </xsl:for-each>)
      </xsl:when>
	  
      <xsl:when test="local-name()='Not'">array("Not", <xsl:for-each select="$nod">
      		<xsl:call-template name="rek">
      			<xsl:with-param name="nod" select="*"/>
      		</xsl:call-template>
      	</xsl:for-each>)
      </xsl:when>
      
      <xsl:when test="local-name()='PropertyIsEqualTo'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template> = '<xsl:value-of select="./ogc:Literal"/>'"</xsl:when>
      <xsl:when test="local-name()='PropertyIsNotEqualTo'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template> != '<xsl:value-of select="./ogc:Literal"/>'"</xsl:when>
      <xsl:when test="local-name()='PropertyIsLike'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template> LIKE '<xsl:value-of select="translate(./ogc:Literal,@wildCard,'%')"/>'"</xsl:when>
      <xsl:when test="local-name()='PropertyIsLessThan'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template> &lt; '<xsl:value-of select="./ogc:Literal"/>'"</xsl:when>
      <xsl:when test="local-name()='PropertyIsGreaterThan'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template> &gt; '<xsl:value-of select="./ogc:Literal"/>'"</xsl:when>
      <xsl:when test="local-name()='PropertyIsLessThanOrEqualTo'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template> &lt;= '<xsl:value-of select="./ogc:Literal"/>'"</xsl:when>
      <xsl:when test="local-name()='PropertyIsGreaterThanOrEqualTo'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template> &gt;= '<xsl:value-of select="./ogc:Literal"/>'"</xsl:when>
      <xsl:when test="local-name()='Intersects'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template>"</xsl:when>
      <xsl:when test="local-name()='Within'"><xsl:call-template name="elm"><xsl:with-param name="name" select="$n"/></xsl:call-template>"</xsl:when>
      <xsl:when test="local-name()='BBOX'">"_BBOX_='<xsl:value-of select="gml:Envelope/gml:lowerCorner"/><xsl:text> </xsl:text><xsl:value-of select="gml:Envelope/gml:upperCorner"/>'"</xsl:when>
	  
	  <!-- ostatni -->
      <xsl:otherwise>
        <xsl:for-each select="$nod">
          <xsl:call-template name="rek">
            <xsl:with-param name="nod" select="*"/></xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose></xsl:template>
	
	<xsl:template name="elm">
    	<xsl:param name="name"/>
    	
    	<xsl:variable name="n" select="translate($name,$upper,$lower)"/>
    	
		<xsl:choose>
		  <!-- 2.0.2 core -->
			<xsl:when test="contains($n,'any')">"%</xsl:when> <!-- zobecneni anytext -->
			<xsl:when test="contains($n,'subject')">"@keyword</xsl:when>
			<xsl:when test="contains($n,'specificationtitle')">"@sp.title</xsl:when>
			<xsl:when test="contains($n,'specificationdatetype')">"@sp.dtype</xsl:when>
			<xsl:when test="contains($n,'specificationdate')">"@sp.date</xsl:when>
			<xsl:when test="contains($n,'degree')">"@sp.degree</xsl:when>
			<xsl:when test="contains($n,'title') and $fulltext='ORACLE-CONTEXT'">"//gmd:identificationInfo/*/gmd:citation/*/gmd:title</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'title')">"@title</xsl:when> <!-- OK -->
			<xsl:when test="contains($n,'abstract') and $fulltext='ORACLE-CONTEXT'">"//gmd:identificationInfo/*/gmd:abstract</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'abstract')">"@abstract</xsl:when> <!-- OK -->
			<xsl:when test="contains($n,'format')">"@format</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'parentidentifier')">"@parent</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'resourceidentifier')">"@resourceid</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'operatesonidentifier')">"@operateson</xsl:when><!-- OK -->
			<xsl:when test="contains($n,':identifier') or $n='identifier'">"_UUID_</xsl:when>
			<!-- kvuli harvestingu byl tanecek ale v MSSQL nechodi - vybrat - do MD nebo dat -->
			<xsl:when test="contains($n,'modified')">"@datestamp</xsl:when>
			<!-- <xsl:when test="contains($n,'modified')">"_DATESTAMP_</xsl:when>  -->
      		<xsl:when test="contains($n,'servicetype')">"@stype</xsl:when>
			<xsl:when test="contains($n,'couplingtype')">"@coupling</xsl:when>
			<!-- <xsl:when test="contains($n,'type')">"#//hierarchyLevel/@codeListValue</xsl:when> -->
			<xsl:when test="contains($n,'type')">"@type</xsl:when>

		<!-- jeste dodat CRS -->
			<xsl:when test="contains($n, 'boundingbox')">"_BBOX_='<xsl:value-of select="gml:Envelope/gml:lowerCorner"/><xsl:text> </xsl:text><xsl:value-of select="gml:Envelope/gml:upperCorner"/>
			<!-- opacne -->
			<xsl:if test="local-name()='Within'"> 1</xsl:if><xsl:if test="contains(local-name(*),'Envelope')">1</xsl:if>'</xsl:when>
			
      	<!-- additional ISO queryables -->
			<xsl:when test="contains($n,'alternatetitle')">"@atitle</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'revisiondate')">"_RDATE_</xsl:when>
			<xsl:when test="contains($n,'creationdate')">"_CDATE_</xsl:when>
			<xsl:when test="contains($n,'publicationdate')">"_PDATE_</xsl:when>
			<xsl:when test="contains($n,'organisationname')">"@contact</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'metadatacontact')">"@md_contact</xsl:when><!-- otestovat -->
			<xsl:when test="contains($n,'resourcelanguage')">"@rlanguage</xsl:when><!-- DOPLNIT -->
			<xsl:when test="contains($n,'language')">"_LANGUAGE_</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'operatesonname')">"@operatesn</xsl:when> <!-- DIVNE - doladit -->
			<xsl:when test="contains($n,'operateson')">"@operateson</xsl:when> <!-- DIVNE - doladit -->
			<xsl:when test="contains($n,'topiccategory')">"@topic</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'denominator')">"@denom</xsl:when><!-- OK -->     			
			<xsl:when test="contains($n,'hierarchylevelname')">"@hlname</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'tempextent_begin')">"_DATEB_</xsl:when><!-- OK -->
			<xsl:when test="contains($n,'tempextent_end')">"_DATEE_</xsl:when><!-- OK -->
 			<xsl:when test="contains($n,'responsiblepartyrole')">"@role</xsl:when>
 			<xsl:when test="contains($n,'metadatarole')">"@mdrole</xsl:when>
 			<xsl:when test="contains($n,'role')">"@role</xsl:when>
 			<xsl:when test="contains($n,'protocol')">"@protocol</xsl:when>
 			<!-- TODO - implementovat !!! -->
 			<xsl:when test="contains($n,'distance')">"@distance</xsl:when>
 			<xsl:when test="contains($n,'distanceuom')">"@distuom</xsl:when>
 			<xsl:when test="contains($n,'geographicdescriptioncode')">"@geocode</xsl:when>

      	<!-- additional INSPIRE/1GE queryables -->
      		<!-- Limitation on public access -->
      		<!-- identificationInfo[1]/*/resourceConstraints/*/accessConstraints -->
  			<xsl:when test="contains($n, 'accessconstraints')">"@accessc</xsl:when>
 			<!-- identificationInfo[1]/*/resourceConstraints/*/otherConstraints -->
 			<xsl:when test="contains($n, 'otherconstraints')">"@otherc</xsl:when>
 			<!-- identificationInfo[1]/*/resourceConstraints/*/classification -->
 			<xsl:when test="contains($n, 'classification')">"@classif</xsl:when>

      		<!-- Conditions applying to access and use -->
 			<xsl:when test="contains($n, 'conditionapplyingtoaccessanduse')">"@ausec</xsl:when>	
 					
 			<xsl:when test="contains($n, 'lineage') and $fulltext='ORACLE-CONTEXT'">"//gmd:lineage/*/gmd:statement</xsl:when>
 			<xsl:when test="contains($n, 'lineage')">@lineage</xsl:when>
 			<!-- dataQualityInfo/*/lineage/*/statement -->
			
		<!-- 2.0.1 different sw vendors -->
			<xsl:when test="$name='Contact'">"@contact</xsl:when>
			<xsl:when test="$name='Online'">@linkage</xsl:when>
			<xsl:when test="$name='keyword'">"@keyword</xsl:when>
			<xsl:when test="$name='FileIdentifier'">"_UUID_</xsl:when>
			<xsl:when test="contains($n, 'hierarchylevel')">"@type</xsl:when>

		<!-- our specific -->
			<!-- kdo harvestoval -->
			<xsl:when test="contains($n, 'creator')">"_CREATE_USER_</xsl:when>
			<xsl:when test="contains($n, 'mayedit')">"_MAYEDIT_</xsl:when>
			<xsl:when test="contains($n, 'linkage')">"@linkage</xsl:when>
			<xsl:when test="contains($n, 'uuidref')">"@uuidref</xsl:when>
			<xsl:when test="contains($n, 'isprimary')">"_PRIM_</xsl:when>
			<xsl:when test="contains($n, 'groups')">"_GROUPS_</xsl:when>
			<!-- kdy bylo harvestovano - pro CSW -->
			<xsl:when test="contains($n,'sysdate')">"_DATESTAMP_</xsl:when>
			<xsl:when test="contains($n,'bbspan')">"_BBSPAN_</xsl:when>
			<xsl:when test="contains($n,'thesaurusname')">"@thesaurus</xsl:when>
			<xsl:when test="contains($n,'forinspire')">"_FORINSPIRE_</xsl:when>

			<xsl:otherwise>"@<xsl:value-of select="$name"/></xsl:otherwise>

		 </xsl:choose> 
	</xsl:template>


</xsl:stylesheet>
