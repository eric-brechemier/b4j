<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
   <xsl:output method="xml" indent="no" encoding="ISO-8859-1" />
   
   <!-- Design Pattern : Same but Different ([Drix 2002] copie non conforme, p.443 )
   
   Recursive copy rule which may be overridden by importing transforms 
   at any step to introduce atomic modifications.
   
   Nota: unused namespace declarations are not matched and may not be copied.
   -->
  
	<xsl:template match="child::node() | attribute::* " mode="copy" priority="1">
		<xsl:copy>
			<xsl:call-template name="continueCopy" />
		</xsl:copy>
	</xsl:template>
  
  <xsl:template name="continueCopy">
    <xsl:apply-templates mode="copy"
      select=" child::processing-instruction() | child::node() | attribute::* | namespace::* " />
  </xsl:template>
  
  <xsl:template name="continueCopyAttributesAndNamespaces">
    <xsl:apply-templates mode="copy" select=" attribute::* | namespace::* " />
  </xsl:template>
  
  <xsl:template name="continueCopyChildren">
    <xsl:apply-templates mode="copy" select=" child::processing-instruction() | child::node() " />
  </xsl:template>
  
</xsl:stylesheet>