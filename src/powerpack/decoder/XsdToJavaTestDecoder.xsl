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
  <xsl:import href="XsdToJavaDecoderBase.xsl" />
   
  <!--
  PowerPack extension for Java Test Decoder Generator with id/ref management.
  
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
  
  <xsl:include href="../../decoder/XsdToJavaTestDecoder.body.xsl" />
  
  <xsl:template mode="addFields" match="/" priority="1">
    <xsl:apply-imports />
    
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
  
  <xsl:template mode="processIdRefResolutionStacks" match="xsd:schema">
    <xsl:apply-imports />
    <xsl:variable name="xmlTextBackWard">"&lt;isob4j:short description='stack backwardIds size'&gt;"+__backwardIdsCount+"&lt;/isob4j:short&gt;\n"</xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$xmlTextBackWard}"/>
    </java:call>
    <xsl:variable name="xmlTextForward">"&lt;isob4j:short description='stack forwardRefs size'&gt;"+__forwardRefsCount+"&lt;/isob4j:short&gt;\n"</xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$xmlTextForward}"/>
    </java:call>
  </xsl:template>
  
  
  <xsl:template mode="declareReferreeObject" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="attributeName" />
    <xsl:param name="referreeObjectName" />
    
    <java:variable name="{$referreeObjectName}" type="String">
      <java:value>
        <xsl:text>"</xsl:text>
          <xsl:text>Id </xsl:text><xsl:value-of select="concat($keyrefName,':',$attributeName)" />
          <xsl:text> for </xsl:text><xsl:value-of select="ancestor::xsd:complexType/@name" />
        <xsl:text>"</xsl:text>
      </java:value>
    </java:variable>
  </xsl:template>
  
  <xsl:template mode="declareReferrerObject" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="attributeName" />
    <xsl:param name="referrerObjectName" />
    
    <java:variable name="{$referrerObjectName}" type="String">
      <java:value>
        <xsl:text>"</xsl:text>
          <xsl:text>Ref </xsl:text><xsl:value-of select="concat($keyrefName,':',$attributeName)" />
          <xsl:text> for </xsl:text><xsl:value-of select="ancestor::xsd:complexType/@name" />
        <xsl:text>"</xsl:text>
      </java:value>
    </java:variable>
  </xsl:template>
  
  <xsl:template mode="referrerMeetingReferree" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="referree" />
    <xsl:param name="referrer" />
    
    <xsl:variable name="text">
      <xsl:text>"&lt;!-- </xsl:text>
        <xsl:text>Message: on topic=</xsl:text><xsl:value-of select="$keyrefName"/>
        <xsl:text> Referree=("+</xsl:text><xsl:value-of select="$referree"/>
        <xsl:text>+") Referrer=("+</xsl:text><xsl:value-of select="$referrer"/>
      <xsl:text>+") --&gt;\n"</xsl:text>
    </xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$text}"/>
    </java:call>
  </xsl:template>
  
  <xsl:template mode="onArrayRead" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:param name="type" />
    <xsl:param name="variableName" />
    
    <xsl:variable name="text">
      <xsl:text>"&lt;isob4j:file</xsl:text>
        <xsl:text> description='</xsl:text><xsl:value-of select="$variableName"/><xsl:text>'</xsl:text>
      <xsl:text>&gt;"+</xsl:text>
        <xsl:text>"(... "+</xsl:text><xsl:value-of select="$variableName"/><xsl:text>.length+" bytes of data ...)"</xsl:text>
      <xsl:text>+"&lt;/isob4j:file</xsl:text><xsl:text>&gt;\n"</xsl:text>
    </xsl:variable>
    <java:call object="outWriter" method="write">
      <java:param value="{$text}"/>
    </java:call>
  </xsl:template>
  
</xsl:stylesheet>