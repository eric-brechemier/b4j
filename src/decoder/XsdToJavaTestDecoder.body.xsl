<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  
  xmlns:java="http://eric.brechemier.name/2004/xml/iso-java"
  xmlns:javadoc="http://eric.brechemier.name/2004/xml/iso-javadoc"
  
  exclude-result-prefixes="xsd"
>
  <!--
  Code body for Java Test Decoder Generator (all code but imports).
  
  Input:
    XML Schema describing (for example) Femto SVG,
    with grammar annotated by user defined actions.
  
  Output:
    A binary-for-java test decoder (in Xml iso-java).
    
  Created:
   by Eric Bréchemier
   on November 12th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:template mode="addImports" match="/">
    <java:import package="java.io" class="FileInputStream" />
    <java:import package="java.io" class="FileNotFoundException" />
    <java:import package="java.io" class="FileOutputStream" />
    <java:import package="java.io" class="OutputStreamWriter" />
    <java:import package="java.io" class="Writer" />
  </xsl:template>
  
  <xsl:template mode="addJavadocLinesForClass" match="/">
    <javadoc:line>Binary for Java (.b4j) file Test Decoder <br /></javadoc:line>
  </xsl:template>
  
  <xsl:template mode="changeClassName" match="/">
    <xsl:attribute name="name">B4JTestDecoder</xsl:attribute>
  </xsl:template>
  
  <xsl:template mode="addFields" match="/">
    <java:method access="private" static="true" returnType="byte" name="booleanToByte">
      <java:params>
        <java:param type="boolean" name="value" />
      </java:params>
      <java:body>
        <java:if test="value">
          <java:return>1</java:return>
        </java:if>
        <java:return>0</java:return>
      </java:body>
    </java:method>
  </xsl:template>
  
  <xsl:template mode="processDocumentContent" match="xsd:schema">
    <java:method access="public" static="true" returnType="void" name="main">
      <java:params>
        <java:param type="String[]" name="args" />
      </java:params>
      <java:body>
<xsl:text>
if (args.length != 2) {
  System.out.println("Expected params: xbiFileName outputFileName");
  return;
}
String xbiFileName = args[0];
String outputFileName = args[1];

DataInputStream data;
try {
  data = new DataInputStream(new FileInputStream(xbiFileName));
} catch(FileNotFoundException e) {
  System.out.println( xbiFileName+" Decoding Failed "+e );
  return;
}

Writer outWriter;
try {
  FileOutputStream fileOutputStream = new FileOutputStream(outputFileName);
  outWriter = new OutputStreamWriter(fileOutputStream, "ISO-8859-1");
  outWriter.write("&lt;?xml version='1.0' encoding='ISO-8859-1'?&gt;\n");
  outWriter.write("&lt;isob4j:document xmlns:isob4j='http://eric.brechemier.name/2004/bin4java/isoXml'&gt;\n");
  
} catch(IOException e) {
  System.out.println( outputFileName+" Creation Failed "+e );
  return;
}

decodeDocument(data,outWriter);

try {
  data.close();
  
  outWriter.write("&lt;/isob4j:document&gt;");
  outWriter.close();
} catch(IOException e) {
  System.out.println( "Error after decoding: couldn't close files. "+e );
  return;
}

System.out.println( xbiFileName+" Decoding End." );
</xsl:text>
      </java:body>
    </java:method>
    
    <xsl:apply-imports />
  </xsl:template>
  
  <xsl:template mode="addParamsToDecoding" match="xsd:schema | xsd:complexType[@name]">
    <java:param type="Writer" name="outWriter" />
  </xsl:template>
  
  <xsl:template mode="addContinuationValues" match="xsd:schema | xsd:complexType[@name]">
    <java:param value="outWriter" />
  </xsl:template>
  
  <xsl:template mode="processVersionNumber" match="xsd:schema">
    <xsl:apply-imports />
    <xsl:variable name="xmlText">"&lt;isob4j:short description='version number'&gt;"+encoderVersion+"&lt;/isob4j:short&gt;\n"</xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$xmlText}"/>
    </java:call>
  </xsl:template>
  
  <xsl:template mode="onElementStart" match="xsd:complexType[@name]">
    <xsl:variable name="elementOpen">
      <xsl:text>"&lt;isob4j:element description='</xsl:text><xsl:value-of select="@name"/><xsl:text>'&gt;\n"</xsl:text>
    </xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$elementOpen}"/>
    </java:call>
  </xsl:template>
    
    
  <xsl:template mode="returnElementProcessingResult" match="xsd:complexType[@name]">
    <xsl:apply-imports />
    <xsl:variable name="elementClose">
      <xsl:text>"&lt;/isob4j:element&gt;\n"</xsl:text>
    </xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$elementClose}"/>
    </java:call>
  </xsl:template>
  
  <xsl:template mode="onValueRead" match=" xsd:attribute | xsd:simpleContent | xsd:element[@ref] | xsd:choice">
    <xsl:param name="type" />
    <xsl:param name="variableName" />
    
    <xsl:variable name="text">
      <xsl:text>"&lt;isob4j:</xsl:text><xsl:value-of select="$type"/>
        <xsl:text> description='</xsl:text><xsl:value-of select="$variableName"/><xsl:text>'</xsl:text>
      <xsl:text>&gt;"+</xsl:text>
        <xsl:value-of select="$variableName"/>
      <xsl:text>+"&lt;/isob4j:</xsl:text><xsl:value-of select="$type"/><xsl:text>&gt;\n"</xsl:text>
    </xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$text}"/>
    </java:call>
  </xsl:template>
  
  <xsl:template mode="processAttributesPresenceMask" match="xsd:attribute[not(@use='required')]">
    <xsl:variable name="emptyElementOpen">
      <xsl:text>"&lt;isob4j:mask "</xsl:text>
    </xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$emptyElementOpen}"/>
    </java:call>
      <xsl:apply-imports />
    <xsl:variable name="emptyElementClose">
      <xsl:text>"/&gt;\n"</xsl:text>
    </xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$emptyElementClose}"/>
    </java:call>
  </xsl:template>
  
  <xsl:template mode="onPresenceMaskFlagRead" match="xsd:attribute">
    <xsl:param name="positionInMask" />
    <xsl:param name="flagVariableName" />
    
    <java:call object="outWriter" method="write">
      <java:param>
        <java:sum>
          <java:string>bit<xsl:value-of select="$positionInMask" />='</java:string>
          <java:call method="booleanToByte">
            <java:param>
              <java:value variable="{$flagVariableName}"/>
            </java:param>
          </java:call>
          <java:string>' </java:string>
        </java:sum>
      </java:param>
    </java:call>
  </xsl:template>
  
  <xsl:template mode="processEnumerationValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:param name="enumeration" />
    
    <java:call object="outWriter" method="write">
      <java:param>
        <xsl:text>"&lt;isob4j:enumeration</xsl:text>
        <xsl:for-each select="$enumeration">
          <xsl:value-of select="concat(' _',position()-1)" />
          <xsl:text>='</xsl:text>
          <xsl:value-of select="@value" />
          <xsl:text>'</xsl:text>
        </xsl:for-each>
        <xsl:text>&gt;"</xsl:text>
      </java:param>
    </java:call>
      <xsl:apply-imports />
    <java:call object="outWriter" method="write">
      <java:param>"&lt;/isob4j:enumeration&gt;"</java:param>
    </java:call>
  </xsl:template>
  
</xsl:stylesheet>