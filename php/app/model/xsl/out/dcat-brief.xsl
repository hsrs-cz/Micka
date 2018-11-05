<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"	 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:dcl="http://dclite4g.xmlns.com/schema.rdf#" 
	xmlns:dcat="http://www.w3.org/ns/dcat#"
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
    xmlns:ows="http://www.opengis.net/ows"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"  
    xmlns:gmi="http://standards.iso.org/iso/19115/-2/gmi/1.0" 
	xmlns:gco="http://www.isotc211.org/2005/gco"
  	xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:locn="http://w3.org/ns/locn#"
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#"   
	xmlns:schema="http://schema.org/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
  	xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
	xmlns:prov="http://www.w3.org/ns/prov#" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:wdrs="http://www.w3.org/2007/05/powder-s#"
	xmlns:earl="http://www.w3.org/ns/earl#" 
	xmlns:cnt="http://www.w3.org/2011/content#"
	>
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
   
<xsl:template match="*">
	<dcat:dataset rdf:resource="{$mickaURL}/csw?service=CSW&amp;request=GetRecordById&amp;id={@uuid}&amp;outputschema=http://www.w3.org/ns/dcat%23"/>
</xsl:template>

</xsl:stylesheet>
