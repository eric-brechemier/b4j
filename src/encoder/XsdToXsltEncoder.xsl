<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:config="http://eric.brechemier.name/2004/generation/encoder-decoder/config"
  
  xmlns:gxslt="http://www.w3.org/1999/XSL/Transform/Generated"
  xmlns:isob4j="http://eric.brechemier.name/2004/bin4java/isoXml"
  xmlns:stack="http://eric.brechemier.name/2004/bin4java/stacks"
  exclude-result-prefixes="xsd config"
>
  <xsl:import href="../browsing/XsdBrowsingTemplateMethod.xsl" />
  
  <!--
  Input :
    Basic XML Schema describing (for example) Femto SVG.
    (user defined actions are ignored).
   
  Output :
    XSLT Transformation sheet from Xml data conforming to given input schema,
    to Xml data iso bin 4 java.
    
  Created:
    by Eric Bréchemier
    on October 14th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:include href="XsdToXsltEncoder.body.xsl" />
  
</xsl:stylesheet>