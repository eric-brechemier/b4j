<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:config="http://eric.brechemier.name/2004/generation/encoder-decoder/config"
  exclude-result-prefixes="xsd config"
>
  <xsl:include href="../utils/xmlSchemaFunctions.xsl" />

  <!-- reference encoder/decoder version (short number with 1352 corresponding to v. 1.3.5.2 ) -->
  <xsl:param name="formatVersion" select="'DISABLED'" />
  
  <!-- input data namespace prefix (has no influence on transformation sheet behavior) -->
  <xsl:variable name="inPrefix">
    <xsl:call-template name="targetNamespacePrefix" />
  </xsl:variable>
  
  <!-- namespace prefix used in xml schema base types strings -->
  <xsl:variable name="xsPrefix">
    <xsl:call-template name="xmlSchemaNamespacePrefix" />
  </xsl:variable>
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
  
  <!--
  Input:
    Basic XML Schema describing (for example) Femto SVG.
   
  Output (Abstract):
    This stylesheet is to be imported by another one.
    Following Gang of 4 Template Method design pattern, it defines browsing algorithm with abstract actions,
    and delegates concrete actions implementation to importing stylesheets.
    
  Created:
    by Eric Bréchemier
    on October 18th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:template match="/">
    <xsl:apply-templates mode="processDocument" select="/"/>
  </xsl:template>
  
  <xsl:template mode="processDocument" match="/">
    <xsl:apply-templates mode="processDocumentContent" select="xsd:schema"/>
    <xsl:apply-templates mode="processElement" select="xsd:schema/xsd:element"/>
  </xsl:template>
  
  <xsl:template mode="processDocumentContent" match="xsd:schema">
    <xsl:if test="$formatVersion != 'DISABLED'">
      <xsl:apply-templates mode="processVersionNumber" select="." />
    </xsl:if>
    <xsl:apply-templates mode="processRootElement" select="." />
  </xsl:template>
  
  <xsl:template mode="processRootElement" match="xsd:schema">
    <xsl:variable name="appInfo" select="xsd:annotation/xsd:appinfo"/>
    <xsl:variable name="rootElementNameInConfig" select="$appInfo/config:root/@element" />
    <!-- when config info is missing, first element is used as root -->
    
    <xsl:variable name="rootElementName">
      <xsl:choose>
        <xsl:when test="$rootElementNameInConfig">
          <xsl:value-of select="$rootElementNameInConfig"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="firstElementName" select="/xsd:schema/xsd:element[1]/@name" />
          <xsl:message>*** XSLT BROWSING WARNING: ***</xsl:message>
          <xsl:message>
            <xsl:value-of 
              select="concat('Missing root element config, first element (',$firstElementName,') is considered root.')"/>
          </xsl:message>
          <xsl:message>*** Warning End ***</xsl:message>
          <xsl:value-of select="$firstElementName" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates mode="searchForElementToProcess" select=".">
      <xsl:with-param name="elementName" select="$rootElementName" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="searchForElementToProcess" match="xsd:schema | xsd:complexType[@name]">
    <xsl:param name="elementName" />
    
    <xsl:variable name="element" select="/xsd:schema/xsd:element[@name=$elementName]" />
    <xsl:variable name="fullTypeName" select="$element/@type" />
    <xsl:variable name="typeName" select="substring-after($fullTypeName,':')" />
    
    <xsl:apply-templates mode="launchElementProcessing" select=".">
      <xsl:with-param name="childTypeName" select="$typeName" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processElement" match="xsd:element[@type]">
    <xsl:variable name="fullTypeName" select="@type" />
    <!-- TODO: handle external type definitions here -->
    <xsl:variable name="typeName" select="substring-after($fullTypeName,':')" />
    <xsl:variable name="elementType" select="/xsd:schema/xsd:complexType[@name=$typeName]" />
    
    <xsl:apply-templates mode="processElementContent" select="$elementType" />
  </xsl:template>
  
  <xsl:template mode="processElementContent" match="xsd:complexType[xsd:simpleContent/xsd:extension]">
    <xsl:apply-templates mode="processAttributes" select="xsd:simpleContent/xsd:extension" />
    <xsl:apply-templates mode="processTextValue" select="xsd:simpleContent" />
    <xsl:apply-templates mode="returnElementProcessingResult" select="." />
  </xsl:template>
  
  <xsl:template mode="processElementContent" match="xsd:complexType">
    <xsl:apply-templates mode="processAttributes" select="." />
    <xsl:apply-templates mode="processChildrenElements" />
    <xsl:apply-templates mode="returnElementProcessingResult" select="." />
  </xsl:template>
  
  <xsl:template mode="processAttributes" match="xsd:*[xsd:attribute]">
    <xsl:apply-templates mode="processAttributesPresence" select="." />
    <xsl:apply-templates mode="processAttribute" select="xsd:attribute" />
  </xsl:template>
  
  <xsl:template mode="processAttributesPresence" match="xsd:*[ xsd:attribute[not(@use='required')] ]">
    <xsl:for-each select="xsd:attribute[not(@use='required')]">
      <xsl:variable name="firstOfPresenceMask" select="position() mod 8 = 1"/>
      <xsl:if test="$firstOfPresenceMask">
        <xsl:apply-templates mode="processAttributesPresenceMask" select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template mode="processAttributesPresenceMask" match="xsd:attribute[not(@use='required')]">
    <xsl:for-each select="self::xsd:attribute | following-sibling::xsd:attribute[position() &lt; 8] ">
      <xsl:apply-templates mode="processAttributesPresenceMaskFlag" select=".">
        <xsl:with-param name="positionInMask" select="position()" />
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template mode="processAttribute" match="xsd:attribute">
    <xsl:apply-templates mode="processAttributeValue" select="." />
  </xsl:template>
  
  <xsl:template mode="processAttributeValue" match="xsd:attribute[@type]">
    <xsl:apply-templates mode="processTypedValue" select=".">
      <xsl:with-param name="typeRef" select="@type"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processTextValue" match="xsd:simpleContent[xsd:extension/@base]">
    <xsl:apply-templates mode="processTypedValue" select=".">
      <xsl:with-param name="typeRef" select="xsd:extension/@base"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processTypedValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:param name="typeRef" />
    
    <xsl:variable name="xsdURI" select="'http://www.w3.org/2001/XMLSchema'" />
    <xsl:variable name="fpURI" select="'http://eric.brechemier.name/2004/fp/'" />
    <xsl:variable name="includeIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/includeValues/'" />
    <xsl:variable name="ignoreIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/ignoreValues/'" />
    <xsl:variable name="targetNamespaceURI">
      <xsl:call-template name="targetNamespaceURI" />
    </xsl:variable>
    
    <xsl:variable name="typeName" select="substring-after($typeRef,':')"/>
    <xsl:variable name="typePrefix" select="substring-before($typeRef,':')"/>
    <xsl:variable name="typeNamespaceURI">
      <xsl:call-template name="namespaceURI">
        <xsl:with-param name="prefix" select="$typePrefix" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$typeNamespaceURI = $xsdURI">
        <xsl:choose>
          <xsl:when test="$typeName = 'boolean'">
            <xsl:apply-templates mode="processBooleanValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'byte'">
            <xsl:apply-templates mode="processByteValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'short'">
            <xsl:apply-templates mode="processShortValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'int'">
            <xsl:apply-templates mode="processIntValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'unsignedInt'">
            <xsl:apply-templates mode="processUnsignedIntValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'long'">
            <xsl:apply-templates mode="processLongValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'float'">
            <xsl:apply-templates mode="processFloatValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'double'">
            <xsl:apply-templates mode="processDoubleValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'string'">
            <xsl:apply-templates mode="processStringValue" select="." />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="processUnknownTypeValue" select="." />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$typeNamespaceURI = $fpURI">
        <xsl:choose>
          <xsl:when test="$typeName = 'float'">
            <xsl:apply-templates mode="processFloatValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'radAngle'">
            <xsl:apply-templates mode="processRadAngleValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'cosRadAngle'">
            <xsl:apply-templates mode="processCosRadAngleValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'sinRadAngle'">
            <xsl:apply-templates mode="processSinRadAngleValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'minusCosRadAngle'">
            <xsl:apply-templates mode="processCosRadAngleValue" select="." />
          </xsl:when>
          <xsl:when test="$typeName = 'minusSinRadAngle'">
            <xsl:apply-templates mode="processSinRadAngleValue" select="." />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="processUnknownTypeValue" select="." />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$typeNamespaceURI = $targetNamespaceURI">
        <xsl:variable name="typeDef" select="/xsd:schema/xsd:simpleType[@name=$typeName]" />
        <xsl:variable name="typeRestriction" select="$typeDef/xsd:restriction" />
        
        <xsl:choose>
          <xsl:when test="$typeRestriction/xsd:enumeration">
            <!-- WORK IN PROGRESS HERE: TESTING -->
            <xsl:apply-templates mode="processEnumerationValue" select=".">
              <xsl:with-param name="enumeration" select="$typeRestriction/xsd:enumeration" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="processTypedValue" select=".">
              <xsl:with-param name="typeRef" select="$typeRestriction/@base"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        
        <!-- TODO: REMOVE
        <xsl:apply-templates mode="processTypedValue" select=".">
          <xsl:with-param name="typeRef" select="$baseTypeRef"/>
        </xsl:apply-templates>
        -->
      </xsl:when>
      <!--
      <xsl:when test="imported namespace URI?">
        <!++  NOTA import is not transitive. every namespace used corresponds either to targetNamespace
        or to some import. ++>
        <!++ TODO: handle external declarations through import here ++>
      </xsl:when>
      -->
      
      <xsl:otherwise>
        <xsl:apply-templates mode="processUnknownTypeValue" select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="processEnumerationValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:apply-templates mode="processByteValue" select="." />
  </xsl:template>
  
  <xsl:template mode="processChildrenElements" match="xsd:sequence[xsd:element] | xsd:choice[xsd:element]">
    <xsl:apply-templates mode="processChildCount" select="." />
    <xsl:apply-templates mode="processChildItems" select="." />
  </xsl:template>
  
  <xsl:template mode="processChildCount" match="xsd:sequence">
    <xsl:apply-templates mode="processSequenceItemCount" select="xsd:element[@ref]" />
  </xsl:template>
  
  <xsl:template mode="processSequenceItemCount" match="xsd:element[@ref]">
    <!-- place to handle cardinalities; beware: decoding needs number of items,
    if difference to minimal cardinality was encoded, should add param to indicate this minimal cardinality -->
    <xsl:choose>
      <xsl:when test="(not(@minOccurs) or @minOccurs='1') and (not(@maxOccurs) or @maxOccurs='1') 
                      or (@minOccurs=@maxOccurs)"
      >
        <xsl:apply-templates mode="processSequenceItemFixedCount" select="." />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="processSequenceItemVariableCount" select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="processChildCount" match="xsd:choice">
    <!-- place to handle cardinalities; beware: decoding needs number of items,
    if difference to minimal cardinality was encoded, should add param to indicate this minimal cardinality -->
    <xsl:choose>
      <xsl:when test="(not(@minOccurs) or @minOccurs='1') and (not(@maxOccurs) or @maxOccurs='1') 
                      or (@minOccurs=@maxOccurs)"
      >
        <xsl:apply-templates mode="processChoiceFixedCount" select="." />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="processChoiceVariableCount" select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template mode="processChildItems" match="xsd:sequence">
    <xsl:apply-templates mode="processEachSequenceItem" select="xsd:element[@ref]"/>
  </xsl:template>
  
  <xsl:template mode="processEachSequenceItem" match="xsd:element[@ref]">
    <xsl:apply-templates mode="processChildReference" select="." />
  </xsl:template>
  
  <xsl:template mode="processChildReference" match="xsd:element[@ref]">
    <xsl:variable name="elementFullName" select="@ref" />
    <!-- TODO: handle external elements here -->
    <xsl:variable name="elementName" select="substring-after(@ref,':')" />
    
    <xsl:apply-templates mode="searchForElementToProcess" select="ancestor::xsd:complexType">
      <xsl:with-param name="elementName" select="$elementName" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processChildItems" match="xsd:choice">
    <xsl:apply-templates mode="processEachChoiceItem" select="."/>
  </xsl:template>
  
  <xsl:template mode="processEachChoiceItem" match="xsd:choice">
    <xsl:apply-templates mode="processChoiceElementType" select="."/>
    <xsl:apply-templates mode="selectChildReference" select="."/>
  </xsl:template>
  
  <xsl:template mode="selectChildReference" match="xsd:choice">
    <xsl:apply-templates mode="processChildReference" select="xsd:element[@ref]"/>
  </xsl:template>
  
  <xsl:template mode="processDocument" match="node()" />
  <xsl:template mode="processDocumentContent" match="node()" />
  <xsl:template mode="processVersionNumber" match="node()" />
  <xsl:template mode="processIdRefResolutionStacks" match="node()" />
  <xsl:template mode="processRootElement" match="node()" />
  <xsl:template mode="processElement" match="node()" />
  <xsl:template mode="processElementContent" match="node()" />
  
  <xsl:template mode="processAttributes" match="node()" />
  <xsl:template mode="processAttributesPresence" match="node()" />
  <xsl:template mode="processAttributesPresenceMask" match="node()" />
  <xsl:template mode="processAttributesPresenceMaskFlag" match="node()" />
  
  <xsl:template mode="processAttribute" match="node()" />
  <xsl:template mode="processAttributeValue" match="node()" />
  <xsl:template mode="processTextValue" match="node()" />
  
  <xsl:template mode="processTypedValue" match="node()" />
  <xsl:template mode="processUnknownTypeValue" match="node()" />
  
  <xsl:template mode="processBooleanValue" match="node()" />
  <xsl:template mode="processByteValue" match="node()" />
  <xsl:template mode="processShortValue" match="node()" />
  <xsl:template mode="processIntValue" match="node()" />
  <xsl:template mode="processUnsignedIntValue" match="node()" />
  <xsl:template mode="processLongValue" match="node()" />
  
  <xsl:template mode="processFloatValue" match="node()" />
  <xsl:template mode="processDoubleValue" match="node()" />
  <xsl:template mode="processStringValue" match="node()" />
  
  <xsl:template mode="processRadAngleValue" match="node()" />
  <xsl:template mode="processCosRadAngleValue" match="node()" />
  <xsl:template mode="processSinRadAngleValue" match="node()" />
  <xsl:template mode="processMinusRadCosAngleValue" match="node()" />
  <xsl:template mode="processMinusSinRadAngleValue" match="node()" />
  
  <xsl:template mode="processChildrenElements" match="node()" />
  <xsl:template mode="processChildCount" match="node()" />
  <xsl:template mode="processChildItems" match="node()" />
  
  <xsl:template mode="processSequenceItemVariableCount" match="node()" />
  <xsl:template mode="processSequenceItemFixedCount" match="node()" />
  
  <xsl:template mode="processChoiceFixedCount" match="node()" />
  <xsl:template mode="processChoiceVariableCount" match="node()" />
  
  <xsl:template mode="processEachSequenceItem" match="node()" />
  <xsl:template mode="processEachChoiceItem" match="node()" />
  <xsl:template mode="processChoiceElementType" match="node()" />
  
  <xsl:template mode="selectChildReference" match="node()" />
  <xsl:template mode="processChildReference" match="node()" />
  <xsl:template mode="searchForElementToProcess" match="node()" />
  <xsl:template mode="launchElementProcessing" match="node()" />
  
  <xsl:template mode="returnElementProcessingResult" match="node()" />
  
  <xsl:template match="text()"/>
  
</xsl:stylesheet>