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
  <!-- name (with or without path) of encoded file, with extension -->
  <xsl:param name="b4jFileName" select="'./output/defaultOutput.b4j'"/>
  
  <xsl:output method="text" encoding="ISO-8859-1" />
  <!--
  Input :
    ISO B4J document: XML document following same structure as b4j binary file;
    corresponds to instructions for this XSLT transformation sheet.
   
  Output :
    empty file, may be used for simple descriptions or error logging in future versions.
    We use a specific java class (using MathFP for floats) to encode the binary document
    using Java writing methods. This is the 'useful' output document.
    
  Created:
    by Eric Bréchemier
    on October 14th, 2004
  
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
  <xsl:template match="/">
    <xsl:call-template name="openBinaryDocument" />
      <xsl:call-template name="writeBinaryDocument" /> 
    <xsl:call-template name="closeBinaryDocument" />
  </xsl:template>
   
  <xsl:template name="openBinaryDocument">
    <xsl:variable name="Action_doOpenBinaryDocument" select="xmlbin:JavaEncoder.openBinaryOutput($b4jFileName)"/>
  </xsl:template>
  
  <xsl:template name="writeBinaryDocument">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template name="closeBinaryDocument">
    <xsl:variable name="Action_doCloseBinaryDocument" select="xmlbin:JavaEncoder.closeBinaryOutput()"/>
  </xsl:template>
  
  <!-- default template used...
  <xsl:template match="isob4j:element">
    <xsl:apply-templates />
  </xsl:template>
  -->
  
  <!-- one rule for each encoding method in Java encoding class -->
  <xsl:template match="isob4j:boolean">
    <xsl:variable name="Action_doEncode_boolean" select="xmlbin:JavaEncoder.writeBoolean(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:byte">
    <xsl:variable name="Action_doEncode_byte" select="xmlbin:JavaEncoder.writeByte(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:mask">
    <xsl:variable name="Action_doEncode_mask" 
      select="xmlbin:JavaEncoder.writeMaskByte(
            @bit1,@bit2,@bit3,@bit4,
            @bit5,@bit6,@bit7,@bit8)"
    />
  </xsl:template>
  
  <xsl:template match="isob4j:short">
    <xsl:variable name="Action_doEncode_short" select="xmlbin:JavaEncoder.writeShort(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:int">
    <xsl:variable name="Action_doEncode_int" select="xmlbin:JavaEncoder.writeInt(.)"/>
  </xsl:template>
  
  <!-- for alpha colors use unsignedInt -->
  <xsl:template match="isob4j:unsignedInt">
    <xsl:variable name="Action_doEncode_unsignedInt" select="xmlbin:JavaEncoder.writeUnsignedIntFromLong(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:long">
    <xsl:variable name="Action_doEncode_long" select="xmlbin:JavaEncoder.writeLong(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:radAngle">
    <xsl:variable name="Action_doEncode_radAngle" select="xmlbin:JavaEncoder.writeRadAngleString(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:cosRadAngle">
    <xsl:variable name="Action_doEncode_" select="xmlbin:JavaEncoder.writeCosAngleString(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:sinRadAngle">
    <xsl:variable name="Action_doEncode_" select="xmlbin:JavaEncoder.writeSinAngleString(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:minusCosRadAngle">
    <xsl:variable name="Action_doEncode_" select="xmlbin:JavaEncoder.writeMinusCosAngleString(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:minusSinRadAngle">
    <xsl:variable name="Action_doEncode_" select="xmlbin:JavaEncoder.writeMinusSinAngleString(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:float">
    <xsl:variable name="Action_doEncode_float" select="xmlbin:JavaEncoder.writeFloatString(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:double">
    <xsl:variable name="Action_doEncode_double" select="xmlbin:JavaEncoder.writeDouble(.)"/>
  </xsl:template>
  
  <xsl:template match="isob4j:string">
    <xsl:variable name="Action_doEncode_string" select="xmlbin:JavaEncoder.writeStringUTF(.)"/>
  </xsl:template>
  
  <xsl:template match="text()" />
  
</xsl:stylesheet>