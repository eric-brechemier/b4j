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
  PowerPack extension for Java Custom Decoder Generator with id/ref management.
  
  Input:
    XML Schema describing (for example) Femto SVG,
    with grammar annotated by user defined actions.
  
  Output:
    A binary-for-java decoder (in Xml iso-java), with custom decoding actions.
    
  Created:
   by Eric Bréchemier
   on November 12th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:include href="../../decoder/XsdToJavaDecoder.body.xsl" />
  
  <xsl:template mode="addFields" match="/" priority="1">
    <xsl:apply-imports />
    
    <xsl:variable name="globalAppInfo" select="/xsd:schema/xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="userDefinedFields" select="$globalAppInfo/a4j:globalDef"/>
    
    <java:fieldsGroup>
      <xsl:value-of select="$userDefinedFields" />
    </java:fieldsGroup>
  </xsl:template>
  
  
  <xsl:template mode="processKeyrefConstraint" match="xsd:keyref[@name and @refer]">
    <xsl:variable name="keyrefName" select="@name" />
    <xsl:variable name="idRefResolutionActions" select="/xsd:schema/xsd:complexType/xsd:annotation/xsd:appinfo  
                                                        /a4j:topic[@keyref=$keyrefName]"
    />
    <xsl:for-each select="$idRefResolutionActions">
      <xsl:variable name="complexTypeName" select="ancestor::xsd:complexType/@name" />
      
      <java:method access="private" static="true" returnType="void" 
        name="onIdAvailable_{$keyrefName}_{$complexTypeName}"
      >
        <java:params>
          <java:param><xsl:value-of select="a4j:context/a4j:fromReferree/@object" /></java:param>
          <java:param><xsl:value-of select="a4j:context/a4j:fromReferrer/@object" /></java:param>
        </java:params>
        <java:body>
          <xsl:value-of select="a4j:onMessage" />
        </java:body>
      </java:method>
    </xsl:for-each>
  </xsl:template>
  
  
  
  <xsl:template mode="declareReferreeObject" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="attributeName" />
    <xsl:param name="referreeObjectName" />
    
    <xsl:variable name="referreeVarName" 
      select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo
              /a4j:events/a4j:context/a4j:publish[@topic=$keyrefName and @referree]" />
    
    <xsl:if test="not($referreeVarName)">
      <java:variable name="{$referreeObjectName}" type="String">
        <java:value>
          <xsl:text>"Missing Id </xsl:text>
            <xsl:value-of select="concat($keyrefName,':',$attributeName)" />
            <xsl:text> for </xsl:text><xsl:value-of select="ancestor::xsd:complexType/@name" />
          <xsl:text>"</xsl:text>
        </java:value>
      </java:variable>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="declareReferrerObject" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="attributeName" />
    <xsl:param name="referrerObjectName" />
    
    <xsl:variable name="referrerVarName" 
      select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo
              /a4j:events/a4j:context/a4j:subscribe[@topic=$keyrefName and @referrer]" />
    
    <xsl:if test="not($referrerVarName)">
      <java:variable name="{$referrerObjectName}" type="String">
        <java:value>
          <xsl:text>"Missing Ref </xsl:text>
            <xsl:value-of select="concat($keyrefName,':',$attributeName)" />
            <xsl:text> for </xsl:text><xsl:value-of select="ancestor::xsd:complexType/@name" />
          <xsl:text>"</xsl:text>
        </java:value>
      </java:variable>
    </xsl:if>
  </xsl:template>
  
  
  <xsl:template mode="referreeObjectName" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    
    <xsl:variable name="referreeVarName" 
      select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo
              /a4j:events/a4j:context/a4j:publish[@topic=$keyrefName]/@referree" />
    
    <xsl:choose>
      <xsl:when test="$referreeVarName">
        <xsl:value-of select="$referreeVarName" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('_missingRefereeNameForTopic_',$keyrefName)" />
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template mode="referrerObjectName" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    
    <xsl:variable name="referrerVarName" 
      select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo
              /a4j:events/a4j:context/a4j:subscribe[@topic=$keyrefName]/@referrer" />
    
    <xsl:choose>
      <xsl:when test="$referrerVarName">
        <xsl:value-of select="$referrerVarName" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('_missingRefererNameForTopic_',$keyrefName)" />
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  
  
  <xsl:template mode="referrerMeetingReferree" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="referree" />
    <xsl:param name="referrer" />
    
    <xsl:variable name="complexTypeName" 
      select="//a4j:topic[@keyref=$keyrefName]/ancestor::xsd:complexType/@name" 
    />
    
    <java:call method="onIdAvailable_{$keyrefName}_{$complexTypeName}">
      <java:param value="{$referree}"/>
      <java:param value="{$referrer}"/>
    </java:call>
  </xsl:template>
  
</xsl:stylesheet>