<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:a4j="http://eric.brechemier.name/2004/generation/encoder-decoder/semanticActionsForJava"
  
  xmlns:java="http://eric.brechemier.name/2004/xml/iso-java"
  xmlns:javadoc="http://eric.brechemier.name/2004/xml/iso-javadoc"
  
  exclude-result-prefixes="xsd a4j"
>
  <xsl:import href="../browsing/XsdBrowsingTemplateMethod.xsl" />
  
  <!--
  Input:
    XML Schema describing (for example) Femto SVG,
    with grammar annotated by user defined actions.
  
  Output:
    A binary-for-java test decoder (in Xml iso-java).
    
  Created:
   by Eric Bréchemier
   on October 19th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:include href="XsdToJavaDecoderBase.body.xsl" />
  
</xsl:stylesheet>