<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  
  xmlns:java="http://eric.brechemier.name/2004/xml/iso-java"
  xmlns:javadoc="http://eric.brechemier.name/2004/xml/iso-javadoc"
  
  xmlns:config="http://eric.brechemier.name/2004/generation/encoder-decoder/config"
  xmlns:a4j="http://eric.brechemier.name/2004/generation/encoder-decoder/semanticActionsForJava"
  
  exclude-result-prefixes="xsd config a4j"
>
  <xsl:import href="XsdToJavaDecoderBase.xsl" />
  
  <!--
  Input:
    XML Schema describing (for example) Femto SVG,
    with grammar annotated by user defined actions.
  
  Output:
    A binary-for-java decoder (in Xml iso-java), with custom decoding actions.
    
  Created (version 1.0):
   by Eric Bréchemier
   on October 7th, 2004
  
  Created (version 2.0):
   by Eric Bréchemier
   on October 20th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:include href="XsdToJavaDecoder.body.xsl" />
  
</xsl:stylesheet>