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
  PowerPack extension for Java Decoder Generator Base with id/ref management.
  
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
  
  <xsl:include href="../../decoder/XsdToJavaDecoderBase.body.xsl" />
  
  <xsl:template mode="addFields" match="/">
    <xsl:if test="//xsd:keyref">
      <java:attribute access="private" static="true" type="Object[]" name="__backwardIdsStack"/>
      <java:attribute access="private" static="true" type="Object[]" name="__forwardRefsStack"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="finalClean" match="/">
    <xsl:if test="//xsd:keyref">
      <java:delete name="__backwardIdsStack"/>
      <java:delete name="__forwardRefsStack"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="processIdRefResolutionStacks" match="xsd:schema">
    <java:variable type="short" name="__backwardIdsCount">
      <java:call object="data" method="readShort" />
    </java:variable>
    <java:variable type="short" name="__forwardRefsCount">
      <java:call object="data" method="readShort" />
    </java:variable>
    
    <java:init name="__backwardIdsStack">
      <java:new type="Object" arraySize="__backwardIdsCount" />
    </java:init>
    <java:init name="__forwardRefsStack">
      <java:new type="Object" arraySize="__forwardRefsCount" />
    </java:init>
    
  </xsl:template>
  
  <xsl:template mode="processReferree" match="xsd:attribute[@name and not(@use='required')]">
    <xsl:variable name="presenceVarName">
      <xsl:call-template name="presenceVariableName">
        <xsl:with-param name="attributeName" select="@name" />
      </xsl:call-template>
    </xsl:variable>
    <java:if test="{$presenceVarName}">
      <xsl:apply-imports />
    </java:if>
  </xsl:template>
  
  <xsl:template mode="processReferrer" match="xsd:attribute[@name and not(@use='required')]">
    <xsl:variable name="presenceVarName">
      <xsl:call-template name="presenceVariableName">
        <xsl:with-param name="attributeName" select="@name" />
      </xsl:call-template>
    </xsl:variable>
    <java:if test="{$presenceVarName}">
      <xsl:apply-imports />
    </java:if>
  </xsl:template>
  
  
  <xsl:template mode="processReferreeActions" match="xsd:attribute[@name]">
    <xsl:param name="keyref" />
    <xsl:param name="keyrefName" />
    
    <xsl:variable name="attributeName" select="@name"/>
    
    <xsl:variable name="referreeObject">
      <xsl:apply-templates mode="referreeObjectName" select=".">
        <xsl:with-param name="keyrefName" select="$keyrefName" />
        <xsl:with-param name="attributeName" select="$attributeName" />
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:apply-templates mode="declareReferreeObject" select=".">
      <xsl:with-param name="keyrefName" select="$keyrefName" />
      <xsl:with-param name="attributeName" select="$attributeName" />
      <xsl:with-param name="referreeObjectName" select="$referreeObject" />
    </xsl:apply-templates>
    
    <xsl:variable name="varAction" select="concat('__decodingActionForTopic_',$keyrefName,'_Id_',$attributeName)" />
    <java:variable type="short" name="{$varAction}">
      <java:call object="data" method="readShort"/>
    </java:variable>
    <xsl:apply-templates mode="onValueRead" select=".">
      <xsl:with-param name="type" select="'short'"/>
      <xsl:with-param name="readMethod" select="'readShort'"/>
      <xsl:with-param name="variableName" select="$varAction" />
    </xsl:apply-templates>
    
    <java:while test="{$varAction} &gt; 0">
      <xsl:variable name="referrerObject">
        <xsl:apply-templates mode="referrerObjectNameFromStack" select=".">
          <xsl:with-param name="keyrefName" select="$keyrefName" />
        </xsl:apply-templates>
      </xsl:variable>
      
      <java:variable type="Object" name="{$referrerObject}">
        <java:value variable="__forwardRefsStack" arrayPosition="{$varAction}-1" />
      </java:variable>
      
      <xsl:apply-templates mode="referrerMeetingReferree" select=".">
        <xsl:with-param name="keyrefName" select="$keyrefName"/>
        <xsl:with-param name="referree" select="$referreeObject" />
        <xsl:with-param name="referrer" select="$referrerObject" />
      </xsl:apply-templates>
      
      <java:init name="{$varAction}">
        <java:call object="data" method="readShort"/>
      </java:init>
      <xsl:apply-templates mode="onValueRead" select=".">
        <xsl:with-param name="type" select="'short'"/>
        <xsl:with-param name="readMethod" select="'readShort'"/>
        <xsl:with-param name="variableName" select="$varAction" />
      </xsl:apply-templates>
    </java:while>
    <java:if test="{$varAction} &lt; 0">
      <java:init name="__backwardIdsStack" arrayPosition="-{$varAction}-1">
        <java:value variable="{$referreeObject}" />
      </java:init>
    </java:if>
  </xsl:template>
  
  
  
  <xsl:template mode="processReferrerActions" match="xsd:attribute[@name]">
    <xsl:param name="keyrefName" />
    
    <xsl:variable name="attributeName" select="@name"/>
    
    <xsl:variable name="referrerObject">
      <xsl:apply-templates mode="referrerObjectName" select=".">
        <xsl:with-param name="keyrefName" select="$keyrefName" />
        <xsl:with-param name="attributeName" select="$attributeName" />
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:apply-templates mode="declareReferrerObject" select=".">
      <xsl:with-param name="keyrefName" select="$keyrefName" />
      <xsl:with-param name="attributeName" select="$attributeName" />
      <xsl:with-param name="referrerObjectName" select="$referrerObject" />
    </xsl:apply-templates>
    
    <xsl:variable name="varAction" select="concat('__decodingActionForForTopic_',$keyrefName,'_Ref_',$attributeName)" />
    <java:variable type="short" name="{$varAction}">
      <java:call object="data" method="readShort"/>
    </java:variable>
    <xsl:apply-templates mode="onValueRead" select=".">
      <xsl:with-param name="type" select="'short'"/>
      <xsl:with-param name="readMethod" select="'readShort'"/>
      <xsl:with-param name="variableName" select="$varAction" />
    </xsl:apply-templates>
    
    <java:if test="{$varAction} &lt; 0">
      <xsl:variable name="referreeObject">
        <xsl:apply-templates mode="referreeObjectNameFromStack" select=".">
          <xsl:with-param name="keyrefName" select="$keyrefName" />
        </xsl:apply-templates>
      </xsl:variable>
      
      <java:variable type="Object" name="{$referreeObject}">
        <java:value variable="__backwardIdsStack" arrayPosition="-{$varAction}-1" />
      </java:variable>
      
      <xsl:apply-templates mode="referrerMeetingReferree" select=".">
        <xsl:with-param name="keyrefName" select="$keyrefName"/>
        <xsl:with-param name="referree" select="$referreeObject" />
        <xsl:with-param name="referrer" select="$referrerObject" />
      </xsl:apply-templates>
    </java:if>
    <java:else>
      <java:init name="__forwardRefsStack" arrayPosition="{$varAction}-1">
        <java:value variable="{$referrerObject}" />
      </java:init>
    </java:else>
    
  </xsl:template>
  
  <xsl:template mode="referreeObjectName" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="attributeName" />
    
    <xsl:value-of select="concat('__referreeObjectForTopic_',$keyrefName,'_Id_',$attributeName)" />
  </xsl:template>
  
  <xsl:template mode="referrerObjectName" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    <xsl:param name="attributeName" />
    
    <xsl:value-of select="concat('__referrerObjectForTopic_',$keyrefName,'_Ref_',$attributeName)" />
  </xsl:template>
  
  <xsl:template mode="referreeObjectNameFromStack" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    
    <xsl:value-of select="concat('__referreeObjectForTopic_',$keyrefName,'_IdLoadedFromBackwardIds')" />
  </xsl:template>
  
  <xsl:template mode="referrerObjectNameFromStack" match="xsd:attribute">
    <xsl:param name="keyrefName" />
    
    <xsl:value-of select="concat('__referrerObjectForTopic_',$keyrefName,'_RefLoadedFromForwardRefs')" />
  </xsl:template>
  
  
  
  
  <xsl:template mode="processInlineFile" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeByteArray" select="." />
  </xsl:template>
  
  <xsl:template mode="decodeByteArray" match="xsd:attribute[@name and not(@use='required')]">
    <xsl:variable name="variableName">
      <xsl:call-template name="dataVariableName"/>
    </xsl:variable>
    <xsl:variable name="presenceVariableName">
      <xsl:call-template name="presenceVariableName"/>
    </xsl:variable>
    
    <java:variable type="byte[]" name="{$variableName}">
      <java:value>null</java:value>
    </java:variable>
    <java:if test="{$presenceVariableName}">
      <java:init name="{$variableName}">
        <java:new type="byte" arraySize="data.readInt()" />
      </java:init>
      <java:call object="data" method="read">
        <java:param value="{$variableName}" />
      </java:call>
      <xsl:apply-templates mode="onArrayRead" select=".">
        <xsl:with-param name="type" select="'byte[]'" />
        <xsl:with-param name="variableName" select="$variableName"/>
      </xsl:apply-templates>
    </java:if>
  </xsl:template>
  
  <xsl:template mode="decodeByteArray" match="xsd:attribute[@name and @use='required']">
    <xsl:variable name="variableName">
      <xsl:call-template name="dataVariableName"/>
    </xsl:variable>
    
    <java:variable type="byte[]" name="{$variableName}">
      <java:new type="byte" arraySize="data.readInt()" />
    </java:variable>
    <java:call object="data" method="read">
      <java:param value="{$variableName}" />
    </java:call>
    <xsl:apply-templates mode="onArrayRead" select=".">
      <xsl:with-param name="type" select="'byte[]'" />
      <xsl:with-param name="variableName" select="$variableName"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
  
  
  <xsl:template mode="referrerMeetingReferree" match="node()" />
  <xsl:template mode="referreeObjectName" match="node()" />
  <xsl:template mode="referrerObjectName" match="node()" />  
  
  <xsl:template mode="declareReferreeObject" match="node()" />
  <xsl:template mode="declareReferrerObject" match="node()" />
  
  <xsl:template mode="onArrayRead" match="node()" />
  
</xsl:stylesheet>