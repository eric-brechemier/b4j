<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
>
  <xsl:import href="xmlToIndent.xsl" />
  
  <xsl:output method="xml" indent="no" encoding="ISO-8859-1" />
  
  <!-- Design Pattern : Same but Different ([Drix 2002] copie non conforme, p.443 )
  
  Indent input and remove helper attributes used to declare namespaces with a given prefix.
  -->
  
  <xsl:template match="xsd:schema">
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" /><xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='declareNamespace' and .='ignore')] | namespace::*" />
      <xsl:apply-templates />
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" /></xsl:copy>
  </xsl:template>
	
</xsl:stylesheet>