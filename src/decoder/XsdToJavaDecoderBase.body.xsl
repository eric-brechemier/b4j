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
  <xsl:include href="../utils/stringFunctions.xsl" />
  
  <!--
  Code body for Java Decoder Base Generator (all code but imports)
  
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
  
  <xsl:template mode="processDocument" match="/">
    <java:unit>
      <xsl:apply-templates mode="declarePackage" select="/"/>
      <java:imports>
        <java:import package="java.io" class="DataInputStream" />
        <java:import package="java.io" class="IOException" />
        <xsl:apply-templates mode="addImports" select="/"/>
      </java:imports>
      <java:class name="JavaDecoder">
        <xsl:apply-templates mode="changeClassName" select="/"/>
        <javadoc:comment>
          <xsl:apply-templates mode="addJavadocLinesForClass" select="/"/>
          <javadoc:author>Generated by an XSLT transformation sheet (c) 2004 Eric Bréchemier, ExpWay, Pastagames</javadoc:author>
          <javadoc:version>1.0</javadoc:version>
        </javadoc:comment>
        <xsl:apply-templates mode="addFields" select="/"/>
        
        <xsl:apply-imports />
      </java:class>
    </java:unit>
  </xsl:template>
  
  <xsl:template mode="processDocumentContent" match="xsd:schema">
    <java:method access="public" static="true" returnType="void" name="decodeDocument">
      <xsl:apply-templates mode="changeDecodingReturnType" select="."/>
      <java:params>
        <java:param type="DataInputStream" name="data" />
        <xsl:apply-templates mode="addParamsToDecoding" select="."/>
      </java:params>
      
      <java:body>
        <java:try>
          <xsl:apply-imports />
        </java:try>
        <xsl:variable name="exceptionName">
          <xsl:apply-templates mode="exceptionName" select="/" />
        </xsl:variable>
        <java:catchException name="{$exceptionName}">
          <xsl:apply-templates mode="onError" select="/"/>
        </java:catchException>
        <java:finally>
          <xsl:apply-templates mode="finalClean" select="/"/>
        </java:finally>
      </java:body>
    </java:method>
  </xsl:template>
  
  <xsl:template mode="processVersionNumber" match="xsd:schema">
    <java:variable name="EXPECTED_ENCODER_VERSION" final="true" type="short">
      <xsl:value-of select="$formatVersion" />
    </java:variable>
    
    <java:variable name="encoderVersion" type="short">
      <java:call object="data" method="readShort" />
    </java:variable>
    
    <java:if test="encoderVersion != EXPECTED_ENCODER_VERSION">
      <java:variable name="message" type="String">
        <java:sum>
          <java:value>"Incorrect encoder version: expected "</java:value>
          <java:value variable="EXPECTED_ENCODER_VERSION"/>
          <java:value>" found "</java:value>
          <java:value variable="encoderVersion"/>
        </java:sum>
      </java:variable>
      <java:throwException variable="message" />
    </java:if>
  </xsl:template>
  
  <xsl:template mode="processRootElement" match="xsd:schema">
    <xsl:apply-templates mode="onDocumentStart" select="/"/>
    <xsl:apply-imports />
    <xsl:apply-templates mode="onDocumentEnd" select="/"/>
  </xsl:template>
  
  <xsl:template mode="launchElementProcessing" match="xsd:schema | xsd:complexType[@name]">
    <xsl:param name="childTypeName" />
    
    <java:instruction>
      <xsl:apply-templates mode="storeElementDecodingResult" select="." />
      <java:call method="decode{$childTypeName}">
        <java:param value="data"/>
        <xsl:apply-templates mode="addContinuationValues" select="."/>
      </java:call>
    </java:instruction>
    
    <xsl:apply-templates mode="onElementDecoded" select="."/>
  </xsl:template>
  
  <xsl:template mode="processElementContent" match="xsd:complexType[@name]">
    <java:method access="private" static="true" returnType="void" name="decode{@name}">
      <xsl:apply-templates mode="changeDecodingReturnType" select="."/>
      <java:params>
        <java:param type="DataInputStream" name="data" />
        <xsl:apply-templates mode="addParamsToDecoding" select="."/>
      </java:params>
      <java:throws>
        <java:exception name="IOException" />
      </java:throws>
      <java:body>
        <xsl:apply-templates mode="onElementStart" select="."/>
        <xsl:apply-imports />
      </java:body>
    </java:method>
  </xsl:template>
  
  <xsl:template mode="returnElementProcessingResult" match="xsd:complexType[@name]">
    <xsl:apply-templates mode="onElementEnd" select="."/>
    <xsl:apply-imports />
  </xsl:template>
  
  <xsl:template mode="processAttributes" match="xsd:*[xsd:attribute]">
    <xsl:apply-imports />
    <xsl:apply-templates mode="onAttributesEnd" select="."/>
  </xsl:template>
  
  <xsl:template mode="processAttributesPresenceMask" match="xsd:attribute[@name and not(@use='required')]">
    <xsl:variable name="capitalAttributeName">
      <xsl:call-template name="capitalizeFirstLetter">
        <xsl:with-param name="string" select="@name" />
      </xsl:call-template>
    </xsl:variable>
    
    <java:variable type="byte" name="presenceMaskFrom{$capitalAttributeName}">
      <java:call object="data" method="readByte" />
    </java:variable>
    <xsl:apply-imports />
  </xsl:template>
  
  <xsl:template mode="processAttributesPresenceMaskFlag" match="xsd:attribute[@name and not(@use='required')]">
    <xsl:param name="positionInMask" />
    
    <xsl:variable name="capitalAttributeName">
      <xsl:call-template name="formatAttributeNameForJava">
        <xsl:with-param name="attributeName" select="@name" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fistInDocumentOrder" select="1" />
    <xsl:variable name="firstAttributeInMask" 
      select="(   self::xsd:attribute 
                | preceding-sibling::xsd:attribute[not(@use='required')][position() &lt; $positionInMask] 
              )[$fistInDocumentOrder]" />
    <xsl:variable name="firstAttributeInMaskName" select="$firstAttributeInMask/@name" />
    <xsl:variable name="capitalFirstAttributeInMaskName">
      <xsl:call-template name="formatAttributeNameForJava">
        <xsl:with-param name="attributeName" select="$firstAttributeInMaskName" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="maskName" select="concat('presenceMaskFrom',$capitalFirstAttributeInMaskName)" />
    
    <xsl:variable name="flagVariableName" select="concat('isAt',$capitalAttributeName,'Present')" />
    <java:variable type="boolean" name="{$flagVariableName}">
      <xsl:text>(  </xsl:text>
        <xsl:text>( </xsl:text>
        <xsl:value-of select="$maskName" />
        <xsl:text>&amp;</xsl:text>
        <xsl:call-template name="maskFlag">
          <xsl:with-param name="position" select="$positionInMask"/>
        </xsl:call-template>
        <xsl:text> )!=0</xsl:text>
      <xsl:text>  )</xsl:text>
    </java:variable>
    <xsl:apply-templates mode="onPresenceMaskFlagRead" select=".">
      <xsl:with-param name="positionInMask" select="$positionInMask" />
      <xsl:with-param name="flagVariableName" select="$flagVariableName" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processBooleanValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'boolean'" />
      <xsl:with-param name="readMethod" select="'readBoolean'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processByteValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'byte'" />
      <xsl:with-param name="readMethod" select="'readByte'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processShortValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'short'" />
      <xsl:with-param name="readMethod" select="'readShort'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processIntValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processUnsignedIntValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processLongValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'long'" />
      <xsl:with-param name="readMethod" select="'readLong'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <!-- int for FP -->
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processCosRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <!-- int for FP -->
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processSinRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <!-- int for FP -->
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processMinusRadCosAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <!-- int for FP -->
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processMinusSinRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <!-- int for FP -->
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- WORK IN PROGRESS HERE: differenciate xsd:float/double from fp:float/double processing -->
  
  <xsl:template mode="processFloatValue" match=" xsd:attribute | xsd:simpleContent ">
    <!-- int for FP -->
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processDoubleValue" match=" xsd:attribute | xsd:simpleContent ">
    <!-- int for FP -->
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'int'" />
      <xsl:with-param name="readMethod" select="'readInt'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processStringValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="decodeTypedValue" select=".">
      <xsl:with-param name="type" select="'String'" />
      <xsl:with-param name="readMethod" select="'readUTF'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="decodeTypedValue" match="xsd:attribute[@name]">
    <xsl:param name="type" />
    <xsl:param name="readMethod" />
    
    <xsl:variable name="capitalAttributeName">
      <xsl:call-template name="formatAttributeNameForJava">
        <xsl:with-param name="attributeName" select="@name" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="variableName">
      <xsl:value-of select="concat('at',$capitalAttributeName)" />
    </xsl:variable>
    
    <xsl:apply-templates mode="initValueRead" select=".">
      <xsl:with-param name="type" select="$type" />
      <xsl:with-param name="readMethod" select="$readMethod"/>
      <xsl:with-param name="variableName" select="$variableName"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="decodeTypedValue" match="xsd:simpleContent">
    <xsl:param name="type" />
    <xsl:param name="readMethod" />
    
    <xsl:variable name="appInfo" select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo" />
    <xsl:variable name="valueAlias" select="$appInfo/a4j:events/a4j:onValueEnd/@alias" />
    <xsl:variable name="variableName">
      <xsl:choose>
        <xsl:when test="$valueAlias">
          <xsl:value-of select="$valueAlias" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'__value'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:apply-templates mode="initValueRead" select=".">
      <xsl:with-param name="type" select="$type" />
      <xsl:with-param name="readMethod" select="$readMethod"/>
      <xsl:with-param name="variableName" select="$variableName"/>
    </xsl:apply-templates>
    <xsl:apply-templates mode="onValueEnd" select="." />
  </xsl:template>
  
  <xsl:template mode="initValueRead" match=" xsd:attribute[@use='required'] | xsd:simpleContent ">
    <xsl:param name="type" />
    <xsl:param name="readMethod" />
    <xsl:param name="variableName" />
    
    <java:variable type="{$type}" name="{$variableName}">
      <java:call object="data" method="{$readMethod}" />
    </java:variable>
    <xsl:apply-templates mode="onValueRead" select=".">
      <xsl:with-param name="type" select="$type" />
      <xsl:with-param name="readMethod" select="$readMethod"/>
      <xsl:with-param name="variableName" select="$variableName"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="initValueRead" match=" xsd:attribute[not(@use='required')] ">
    <xsl:param name="type" />
    <xsl:param name="readMethod" />
    <xsl:param name="variableName" />
    
    <java:variable type="{$type}" name="{$variableName}">
      <xsl:apply-templates mode="javaDefaultValueFor" select=".">
        <xsl:with-param name="type" select="$type" />
      </xsl:apply-templates>
    </java:variable>
    <java:if test="isAt{substring-after($variableName,'at')}Present">
      <java:init name="{$variableName}">
        <java:call object="data" method="{$readMethod}" />
      </java:init>
      <xsl:apply-templates mode="onValueRead" select=".">
        <xsl:with-param name="type" select="$type" />
        <xsl:with-param name="readMethod" select="$readMethod"/>
        <xsl:with-param name="variableName" select="$variableName"/>
      </xsl:apply-templates>
    </java:if>
  </xsl:template>
  
  
  <xsl:template mode="processChildCount" match="xsd:sequence">
    <xsl:apply-imports />
    
    <xsl:variable name="countVariableName">
      <xsl:apply-templates mode="countVariableName" select="." />
    </xsl:variable>
    <java:variable type="short" name="{$countVariableName}">
      <java:cast type="short">
        <java:sum>
          <xsl:for-each select="xsd:element[@ref]">
            <xsl:variable name="sequenceItemVariableName">
              <xsl:apply-templates mode="countVariableName" select=".">
                <xsl:with-param name="position" select="position()" />
              </xsl:apply-templates>
            </xsl:variable>
            <java:value variable="{$sequenceItemVariableName}" />
          </xsl:for-each>
        </java:sum>
      </java:cast>
    </java:variable>
    
    <xsl:apply-templates mode="onChildrenCount" select="." />
  </xsl:template>
  
  <xsl:template mode="processSequenceItemVariableCount" match="xsd:element[@ref]">
    <xsl:variable name="sequenceItemCountVariableName">
      <xsl:apply-templates mode="countVariableName" select="."/>
    </xsl:variable>
    
    <java:variable type="short" name="{$sequenceItemCountVariableName}">
      <java:call object="data" method="readShort" />
    </java:variable>
    
    <xsl:apply-templates mode="onValueRead" select=".">
      <xsl:with-param name="type" select="'short'"/>
      <xsl:with-param name="readMethod" select="'readShort'"/>
      <xsl:with-param name="variableName" select="$sequenceItemCountVariableName" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processSequenceItemFixedCount" match="xsd:element[@ref]">
    <xsl:variable name="sequenceItemCountVariableName">
      <xsl:apply-templates mode="countVariableName" select="."/>
    </xsl:variable>
    <xsl:variable name="fixedCount">
      <xsl:choose>
        <xsl:when test="not(@minOccurs)">
          <xsl:value-of select="1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@minOccurs" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <java:variable type="short" name="{$sequenceItemCountVariableName}">
      <java:value><xsl:value-of select="$fixedCount" /></java:value>
    </java:variable>
  </xsl:template>
  
  
  <xsl:template mode="processEachSequenceItem" match="xsd:element[@ref]">
    <xsl:variable name="indexName" select="'__i'" />
    <xsl:variable name="sequenceItemCountVariableName">
      <xsl:apply-templates mode="countVariableName" select="."/>
    </xsl:variable>
    
    <!-- TODO: given cardinality (0..1, 1, 0..*, 1..*) use if, nothing, for(0,count), '', respectively -->
    <java:for type="short" index="{$indexName}" start="0" length="{$sequenceItemCountVariableName}">
      <xsl:apply-imports />
    </java:for>
  </xsl:template>
  
  <xsl:template mode="processChoiceVariableCount" match="xsd:choice">
    <xsl:variable name="countVariableName">
      <xsl:apply-templates mode="countVariableName" select="." />
    </xsl:variable>
    <java:variable type="short" name="{$countVariableName}">
      <java:call object="data" method="readShort" />
    </java:variable>
    <xsl:apply-templates mode="onValueRead" select=".">
      <xsl:with-param name="type" select="'short'"/>
      <xsl:with-param name="readMethod" select="'readShort'"/>
      <xsl:with-param name="variableName" select="$countVariableName" />
    </xsl:apply-templates>
    
    <xsl:apply-imports />
    <xsl:apply-templates mode="onChildrenCount" select="." />
  </xsl:template>
  
  <xsl:template mode="processChoiceFixedCount" match="xsd:choice">
    <xsl:variable name="countVariableName">
      <xsl:apply-templates mode="countVariableName" select="." />
    </xsl:variable>
    <!-- could refactor with sequenceItemFixedCount... -->
    <xsl:variable name="fixedCount">
      <xsl:choose>
        <xsl:when test="not(@minOccurs)">
          <xsl:value-of select="1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@minOccurs" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <java:variable type="short" name="{$countVariableName}">
      <java:value>
        <xsl:value-of select="$fixedCount" />
      </java:value>
    </java:variable>
    
    <xsl:apply-imports />
    <xsl:apply-templates mode="onChildrenCount" select="." />
  </xsl:template>
  
  
  <xsl:template mode="processEachChoiceItem" match="xsd:choice">
    <!-- similar to processEachSequenceItem, but different modes are hard to refactor -->
    
    <xsl:variable name="indexName" select="'__i'" />
    <xsl:variable name="choiceCountVariableName">
      <xsl:apply-templates mode="countVariableName" select="."/>
    </xsl:variable>
    
    <!-- TODO: given cardinality (0..0, 0..1, 1, 0..*, 1..*) 
        use nothing and stop, if, nothing, for(0,count), idem, respectively -->
    <java:for type="short" index="{$indexName}" start="0" length="{$choiceCountVariableName}">
      <xsl:apply-imports />
    </java:for>
  </xsl:template>
  
  <xsl:template mode="processChoiceElementType" match="xsd:choice">
    <xsl:variable name="elementTypeName" select="'__elementType'"/>
    <java:variable type="byte" name="{$elementTypeName}">
      <java:call object="data" method="readByte" />
    </java:variable>
    <xsl:apply-templates mode="onValueRead" select=".">
      <xsl:with-param name="type" select="'byte'"/>
      <xsl:with-param name="readMethod" select="'readByte'"/>
      <xsl:with-param name="variableName" select="$elementTypeName" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="selectChildReference" match="xsd:choice">
    <xsl:variable name="elementTypeName" select="'__elementType'"/>
    
    <java:switch variable="{$elementTypeName}">
      <xsl:apply-imports />
    </java:switch>
  </xsl:template>
  
  <xsl:template mode="processChildReference" match="xsd:choice/xsd:element[@ref]">
    <java:case value="{position()}" break="true">
      <xsl:apply-imports />      
    </java:case>
  </xsl:template>
  
  <!-- Utils -->
  
  <xsl:template name="presenceVariableName">
    <xsl:param name="attributeName" select="@name"/>
    
    <xsl:variable name="capitalAttributeName">
      <xsl:call-template name="formatAttributeNameForJava">
        <xsl:with-param name="attributeName" select="$attributeName" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat('isAt',$capitalAttributeName,'Present')" />
  </xsl:template>
  
  <xsl:template name="dataVariableName">
    <xsl:param name="attributeName" select="@name"/>
    
    <xsl:variable name="capitalAttributeName">
      <xsl:call-template name="formatAttributeNameForJava">
        <xsl:with-param name="attributeName" select="$attributeName" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat('at',$capitalAttributeName)" />
  </xsl:template>
  
  <xsl:template name="formatAttributeNameForJava">
    <xsl:param name="attributeName" />
    <xsl:variable name="capitalAttributeName">
      <xsl:call-template name="capitalizeFirstLetter">
        <xsl:with-param name="string" select="$attributeName" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="translate($capitalAttributeName,'-','_')" />
  </xsl:template>
  
  <xsl:template mode="javaDefaultValueFor" match="xsd:attribute">
    <xsl:param name="type" />
    
    <xsl:choose>
      <xsl:when test="$type='boolean'">
        <xsl:value-of select="'false'" />
      </xsl:when>
      <xsl:when test="$type='byte' or $type='short' or $type='int' or $type='long' or $type='float' or $type='double'">
        <xsl:value-of select="'0'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'null'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="maskFlag">
    <xsl:param name="position" />
    
    <xsl:choose>
      <xsl:when test="$position=1">
        <xsl:value-of select="'0x1'" />
      </xsl:when>
      <xsl:when test="$position=2">
        <xsl:value-of select="'0x2'" />
      </xsl:when>
      <xsl:when test="$position=3">
        <xsl:value-of select="'0x4'" />
      </xsl:when>
      <xsl:when test="$position=4">
        <xsl:value-of select="'0x8'" />
      </xsl:when>
      <xsl:when test="$position=5">
        <xsl:value-of select="'0x10'" />
      </xsl:when>
      <xsl:when test="$position=6">
        <xsl:value-of select="'0x20'" />
      </xsl:when>
      <xsl:when test="$position=7">
        <xsl:value-of select="'0x40'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0x80'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- default implementations and templates for names -->
  <xsl:template mode="exceptionName" match="/">e</xsl:template>
  
  <xsl:template mode="onError" match="/">
    <java:call object="System.out" method="println">
      <java:param>
        <java:sum>
          <java:value>"Decoding failed: "</java:value>
          <java:value>
            <xsl:apply-templates mode="exceptionName" select="/"/>
          </java:value>
        </java:sum>
      </java:param>
    </java:call>
    <!-- System.out.println("Decoding failed: "+e); -->
  </xsl:template>
  
  <xsl:template mode="countVariableName" match="xsd:sequence | xsd:choice">
    <xsl:variable name="appInfo" select="ancestor::xsd:complexType/xsd:annotation/xsd:appinfo" />
    <xsl:variable name="countAlias" select="$appInfo/a4j:events/a4j:onChildrenCount/@alias" />
    
    <xsl:choose>
      <xsl:when test="$countAlias">
        <xsl:value-of select="$countAlias" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'__childrenCount'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="countVariableName" match="xsd:element[@ref]">
    <xsl:variable name="position" select="count(preceding-sibling::xsd:element[@ref])+1" />
    <xsl:value-of select="concat( '__sequenceCount',$position )" />
  </xsl:template>
  
  <!-- override default templates (text and elements) -->
  <xsl:template mode="finalClean" match="node()"/>
  
  <xsl:template mode="declarePackage" match="node()"/>
  <xsl:template mode="addImports" match="node()"/>
  
  <xsl:template mode="changeClassName" match="node()"/>
  <xsl:template mode="addJavadocLinesForClass" match="node()"/>
  <xsl:template mode="addFields" match="node()"/>
  
  <xsl:template mode="changeDecodingReturnType" match="node()"/>
  <xsl:template mode="addParamsToDecoding" match="node()"/>
  <xsl:template mode="addContinuationValues" match="node()"/>
  
  <xsl:template mode="onDocumentStart" match="node()"/>
  <xsl:template mode="onDocumentEnd" match="node()"/>
  
  <xsl:template mode="storeElementDecodingResult" match="node()"/>
  <xsl:template mode="onChildrenCount" match="node()"/>
  <xsl:template mode="onElementDecoded" match="node()"/> <!-- same as onEachChildEnd -->
  
  <xsl:template mode="exceptionName" match="node()"/>
  <xsl:template mode="onError" match="node()"/>
  
  <xsl:template mode="onElementStart" match="node()"/>
  <xsl:template mode="onElementEnd" match="node()"/>
  
  <xsl:template mode="onAttributesEnd" match="node()"/>
  <xsl:template mode="onValueEnd" match="node()"/>
  
  <xsl:template mode="onIdAvailable" match="node()"/>
  
  <xsl:template mode="xpathToJavaName" match="node()"/>
  <xsl:template mode="decodeTypedValue" match="node()"/>
  <xsl:template mode="initValueRead" match="node()"/>
  <xsl:template mode="onValueRead" match="node()"/>
  <xsl:template mode="onPresenceMaskFlagRead" match="node()"/>
  <xsl:template mode="javaDefaultValueFor" match="node()"/>
  
  <xsl:template mode="countVariableName" match="node()"/>
  
</xsl:stylesheet>