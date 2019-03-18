<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dcat="http://www.w3.org/ns/dcat#"
	>
<xsl:output method="name" standalone="no" encoding="UTF-8" omit-xml-declaration="yes"/>
   
<xsl:template match="*">
	<dcat:dataset rdf:resource="{$mickaURL}/csw?service=CSW&amp;request=GetRecordById&amp;id={@uuid}&amp;outputschema=http://www.w3.org/ns/dcat%23"/>
</xsl:template>

</xsl:stylesheet>
