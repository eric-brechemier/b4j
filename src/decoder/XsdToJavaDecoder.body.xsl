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
  <xsl:param name="packageName" select="'#default'" />
  
  <!--
  Code body for Custom Java Decoder Generator (all code but imports).
  
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
   on November 12th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:template mode="declarePackage" match="/">
    <xsl:if test=" $packageName!='#default' ">
      <xsl:attribute name="package"><xsl:value-of select="$packageName"/></xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="addImports" match="/">
    <xsl:variable name="globalAppInfo" select="/xsd:schema/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="userImports" select="$globalAppInfo/a4j:packages"/>
    
    <xsl:value-of select="$userImports"/>
  </xsl:template>
  
  <xsl:template mode="changeClassName" match="/">
    <xsl:attribute name="name">B4JDecoder</xsl:attribute>
  </xsl:template>
  
  <xsl:template mode="addParamsToDecoding" match="xsd:schema | xsd:complexType[@name]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="decodingParams" select="$appInfo/a4j:events/a4j:context/a4j:fromParent"/>
    
    <xsl:if test="$decodingParams">
      <xsl:value-of select="$decodingParams"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="addContinuationValues" match="xsd:schema | xsd:complexType[@name]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="continuationValues" select="$appInfo/a4j:events/a4j:context/a4j:childContinuation"/>
    
    <xsl:if test="$continuationValues">
      <xsl:value-of select="$continuationValues"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="changeDecodingReturnType" match="xsd:schema | xsd:complexType[@name]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    
    <xsl:variable name="out" select="$appInfo/a4j:events/a4j:context/a4j:parentContinuation" />
    <xsl:if test="$out">
      <xsl:attribute name="returnType"><xsl:value-of select="$out/@returnType"/></xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="addJavadocLinesForClass" match="/">
    <javadoc:line>Binary for Java (.b4j) file Decoder <br /></javadoc:line>
    <javadoc:line>Intended use in Java J2ME MIDlets.</javadoc:line>
  </xsl:template>
  
  <xsl:template mode="addFields" match="/">
    <xsl:variable name="globalAppInfo" select="/xsd:schema/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="userDefinedFields" select="$globalAppInfo/a4j:globalDef"/>
    
    <java:fieldsGroup>
      <xsl:value-of select="$userDefinedFields" />
    </java:fieldsGroup>
  </xsl:template>
  
  <xsl:template mode="exceptionName" match="/">
    <xsl:variable name="globalAppInfo" select="/xsd:schema/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onError" select="$globalAppInfo/a4j:events/a4j:onError" />
    
    <xsl:choose>
      <xsl:when test="$onError/@name">
        <xsl:value-of select="$onError/@name" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="onError" match="/">
    <xsl:variable name="globalAppInfo" select="/xsd:schema/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onError" select="$globalAppInfo/a4j:events/a4j:onError" />
    
    <xsl:choose>
      <xsl:when test="$onError">
        <xsl:value-of select="$onError" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="onDocumentStart" match="/">
    <xsl:variable name="globalAppInfo" select="/xsd:schema/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onDocumentStart" select="$globalAppInfo/a4j:events/a4j:onDocumentStart" />
    
    <xsl:apply-templates mode="declareOutVariable" select="/xsd:schema" />
    <xsl:value-of select="$onDocumentStart"/>
  </xsl:template>
  
  <xsl:template mode="onDocumentEnd" match="/">
    <xsl:variable name="globalAppInfo" select="/xsd:schema/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onDocumentEnd" select="$globalAppInfo/a4j:events/a4j:onDocumentEnd" />
    
    <xsl:value-of select="$onDocumentEnd"/>
    <xsl:apply-templates mode="returnOutVariable" select="/xsd:schema" />
  </xsl:template>
  
  <xsl:template mode="onElementStart" match="xsd:complexType[@name]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onElementStart" select="$appInfo/a4j:events/a4j:onElementStart" />
    
    <xsl:apply-templates mode="declareOutVariable" select="." />
    <xsl:value-of select="$onElementStart" />
  </xsl:template>
  
  <xsl:template mode="onElementEnd" match="xsd:complexType[@name]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onElementEnd" select="$appInfo/a4j:events/a4j:onElementEnd" />
    
    <xsl:value-of select="$onElementEnd" />
  </xsl:template>
  
  <xsl:template mode="returnElementProcessingResult" match="xsd:complexType[@name]">
    <xsl:apply-imports />
    <xsl:apply-templates mode="returnOutVariable" select="." />
  </xsl:template>
  
  
  
  
  <xsl:template mode="declareOutVariable" match="*[xsd:annotation/xsd:appinfo]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    
    <xsl:variable name="out" select="$appInfo/a4j:events/a4j:context/a4j:parentContinuation" />
    <xsl:if test="$out">
      <java:variable type="{$out/@returnType}" name="{$out/@returnVariable}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="returnOutVariable" match="*[xsd:annotation/xsd:appinfo]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    
    <xsl:variable name="out" select="$appInfo/a4j:events/a4j:context/a4j:parentContinuation" />
    <xsl:if test="$out">
      <java:return value="{$out/@returnVariable}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="storeElementDecodingResult" match="xsd:schema | xsd:complexType[@name]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onElementDecoded" select="$appInfo/a4j:events/a4j:onEachChildEnd" />
    <xsl:variable name="resultAlias" select="$onElementDecoded/@fromChild" />
    
    <xsl:if test="$resultAlias">
      <xsl:value-of select="concat($resultAlias,' = ')" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="onElementDecoded" match="xsd:schema | xsd:complexType[@name]">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onEachChildEnd" select="$appInfo/a4j:events/a4j:onEachChildEnd" />
    <xsl:variable name="indexVariable" select="$onEachChildEnd/@position" />
    
    <xsl:value-of select="$onEachChildEnd" />
    <xsl:if test="$indexVariable">
      <java:increment variable="{$indexVariable}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="processChildItems" match="xsd:sequence | xsd:choice">
    <xsl:variable name="appInfo" select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onEachChildEnd" select="$appInfo/a4j:events/a4j:onEachChildEnd" />
    <xsl:variable name="indexVariable" select="$onEachChildEnd/@position" />
    
    <java:block>
      <xsl:if test="$indexVariable">
        <java:variable type="short" name="{$indexVariable}">0</java:variable>
      </xsl:if>
      <xsl:apply-imports />
    </java:block>
  </xsl:template>
  
  
  
  
  <xsl:template mode="onAttributesEnd" match="xsd:*[xsd:attribute]">
    <xsl:variable name="appInfo" select="ancestor-or-self::xsd:complexType/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onAttributesEnd" select="$appInfo/a4j:events/a4j:onAttributesEnd" />
    
    <xsl:value-of select="$onAttributesEnd" />
  </xsl:template>
  
  <xsl:template mode="onValueEnd" match="xsd:simpleContent">
    <xsl:variable name="appInfo" select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onValueEnd" select="$appInfo/a4j:events/a4j:onValueEnd" />
    
    <xsl:value-of select="$onValueEnd" />
  </xsl:template>
  
  <xsl:template mode="onChildrenCount" match="xsd:sequence | xsd:choice">
    <xsl:variable name="appInfo" select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="onChildrenCount" select="$appInfo/a4j:events/a4j:onChildrenCount" />
    
    <xsl:value-of select="$onChildrenCount" />
  </xsl:template>
  
  
  
  <xsl:template mode="declareOutVariable" match="node()" />
  <xsl:template mode="returnOutVariable" match="node()" />
  
</xsl:stylesheet>