<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
   xmlns:isob4j="http://eric.brechemier.name/2004/bin4java/isoXml"
   xmlns="http://www.w3.org/1999/xhtml"
   
   xmlns:java="http://xml.apache.org/xalan/java"
   xmlns:xmlbin="xalan://name.brechemier.eric"
>
  <xsl:import href="../../encoder/B4JSimpleEncoder.xsl" />
  
  <!--
  PowerPack extension for B4J Encoding with id/ref management.
  
  Input :
    ISO B4J document: XML document following same structure as b4j binary file;
    corresponds to instructions for this XSLT transformation sheet.
   
  Output :
    empty file, may be used for simple descriptions or error logging in future versions.
    We use a specific java class (using MathFP for floats) to encode the binary document
    using Java writing methods. This is the 'useful' output document.
    
  Created:
    by Eric Bréchemier
    on November 12th, 2004
  
  We use Xalan for its well-documented support of Java extension:
   http://xml.apache.org/xalan-j/extensions.html
   
  Command line example (must include base path for our class in classpath)
  (moreover xalan setup needs to include some jars in classpath)
  java -cp c:\programs\xalan\xalan.jar:c:\programs\xerces\xerces.jar:c:\dev\myJavaProjetHome
      org.apache.xalan.xslt.Process 
         -IN svg.xml
         -XSL svgToBinaryEncoder.xsl
         -OUT svgBinaryDescription.txt
  e.g.
  java -classpath ./src/encoder org.apache.xalan.xslt.Process 
    -IN output/encoder/simpleSample.b4j.xml 
    -XSL src/encoder/B4jSimpleEncoder.xsl 
    -PARAM b4jFileName output/encoder/simpleEncoder.b4j 
    -OUT output/encoder/empty.txt
  
  This code inspires from [SvgEisenberg2002] J. David Eisenberg, SVG Essentials, O'Reilly, 2002
  Chapter 12, Generating SVG, Using XSLT to Convert XML Data to SVG
  for its use of Xalan Java extension.
  -->
  
  <!-- if needed later...
  <xsl:template match="isob4j:cut[@id]" />
  
  <xsl:template match="isob4j:paste[@id]">
    search for corresponding cut(s) with same id
    and paste it(them) here.
  </xsl:template>
  -->
  
  <xsl:template match="isob4j:file">
    <xsl:variable name="fileName" select="." />
    <xsl:variable name="Action_doInlineFile" select="xmlbin:PowerPackJavaEncoder.writeFile($fileName)"/>
  </xsl:template>
  
</xsl:stylesheet>