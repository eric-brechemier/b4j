<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
>
  <xsl:import href="../utils/sameButDifferent.xsl" />
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
  
  <!-- Based on Design Pattern : Same but Different ([Drix 2002] copie non conforme, p.443 )
  
  Remove Annotations for Semantic Actions from given Xml Schema.
  Input:
  Xml Schema file.
  Output: 
  Same file without annotations for actions definitions.
  -->
  <xsl:template match="/">
    <xsl:apply-templates mode="copy" />
  </xsl:template>
  
  <xsl:template mode="copy" match="xsd:annotation[not(xsd:documentation)]" />
  <xsl:template mode="copy" match="xsd:appinfo"/>
  
</xsl:stylesheet>