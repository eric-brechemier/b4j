<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:config="http://eric.brechemier.name/2004/generation/encoder-decoder/config"
  
  xmlns:gxslt="http://www.w3.org/1999/XSL/Transform/Generated"
  xmlns:isob4j="http://eric.brechemier.name/2004/bin4java/isoXml"
  xmlns:stack="http://eric.brechemier.name/2004/bin4java/stacks"
  exclude-result-prefixes="xsd config"
>
  <xsl:include href="../utils/xmlSchemaFunctions.xsl" />
  
  <xsl:namespace-alias stylesheet-prefix="gxslt" result-prefix="xsl" />
  
  <!--
  Code body for XsdToXsltEncoder.xsl (everything but imports).
  
  Input :
    Basic XML Schema describing (for example) Femto SVG.
    (user defined actions are ignored).
   
  Output :
    XSLT Transformation sheet from Xml data conforming to given input schema,
    to Xml data iso bin 4 java.
    
  Created:
    by Eric Bréchemier
    on November 12th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:template mode="processDocument" match="/">
    <gxslt:stylesheet version="1.0" xml:lang="en" exclude-result-prefixes="{$inPrefix}">
      <!--
      potential problem here, as I use a dummy attribute to declare targetNamespace
      associated with prefix in. But as stated below, XSLT processor may choose to output 
      another prefix than in.
      
      (from XSLT 1.0 spec )
      "XSLT processors may make use of the prefix of the QName specified in the name attribute 
      when selecting the prefix used for outputting the created attribute as XML; 
      however, they are not required to do so and, if the prefix is xmlns, they must not do so."
      
      See XSLT Q&A in XSL Faq for other ways to 'declare' namespaces,
      especially http://www.dpawson.co.uk/xsl/sect2/N5536.html#d6286e1429
      which provides a more generic solution.
      -->
      <xsl:attribute name="{$inPrefix}:namespaceDeclarationForInput" namespace="{xsd:schema/@targetNamespace}">ignore</xsl:attribute>
      <gxslt:output method="xml" indent="yes" encoding="ISO-8859-1" />
      
      <xsl:apply-imports />
      
      <xsl:call-template name="declareUtils" />
      
      <gxslt:template match="text()" />
      
    </gxslt:stylesheet>
  </xsl:template>
  
  <xsl:template mode="processDocumentContent" match="xsd:schema">  
    <gxslt:template match="/">
      <isob4j:document>
        <xsl:apply-imports />
      </isob4j:document>
    </gxslt:template>
  </xsl:template>
  
  <xsl:template mode="processVersionNumber" match="xsd:schema">
    <isob4j:short description="version number"><xsl:value-of select="$formatVersion"/></isob4j:short>
  </xsl:template>
  
  <xsl:template mode="processRootElement" match="xsd:schema">
    <gxslt:apply-templates />
  </xsl:template>
  
  <xsl:template mode="processElement" match="xsd:element[@name and @type]">
    <gxslt:template match="{$inPrefix}:{@name}">
      <isob4j:element description="{@name}">
        <xsl:apply-imports />
      </isob4j:element>
    </gxslt:template>
  </xsl:template>
  
  <xsl:template mode="processAttributesPresenceMask" match="xsd:attribute[not(@use='required')]">
    <isob4j:mask>
      <xsl:apply-imports />
    </isob4j:mask>
  </xsl:template>
  
  <xsl:template mode="processAttributesPresenceMaskFlag" match="xsd:attribute[not(@use='required')]">
    <xsl:param name="positionInMask" />
    <gxslt:attribute name="bit{$positionInMask}">
      <gxslt:call-template name="bitIsPresent">
        <gxslt:with-param name="node" select="@{@name}" />
      </gxslt:call-template>
    </gxslt:attribute>
    <gxslt:attribute name="bit{$positionInMask}Description">
      <xsl:value-of select="concat('is ', @name, ' present')" />
    </gxslt:attribute>
  </xsl:template>
  
  <xsl:template mode="processAttribute" match="xsd:attribute[not(@use='required')]">
    <gxslt:if test="@{@name}">
      <xsl:apply-imports />
    </gxslt:if>
  </xsl:template>
  
  <xsl:template mode="processEnumerationValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:param name="enumeration" />
    
    <xsl:variable name="xpathValue" select="concat('@',@name)" />
    <isob4j:enumeration>
      <xsl:for-each select="$enumeration">
        <gxslt:attribute name="_{position()-1}">
          <xsl:value-of select="@value" />
        </gxslt:attribute>
      </xsl:for-each>
      <gxslt:choose>
        <xsl:for-each select="$enumeration">
          <gxslt:when test="{$xpathValue}='{@value}'">
            <isob4j:byte description="{@name}">
              <gxslt:value-of select="{position()-1}" />
            </isob4j:byte>
          </gxslt:when>
        </xsl:for-each>
      </gxslt:choose>
    </isob4j:enumeration>
  </xsl:template>
  
  <xsl:template mode="processBooleanValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:boolean>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:boolean>
  </xsl:template>
  
  <xsl:template mode="processByteValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:byte>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:byte>
  </xsl:template>
  
  <xsl:template mode="processShortValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:short>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:short>
  </xsl:template>
  
  <xsl:template mode="processIntValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:int>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:int>
  </xsl:template>
  
  <xsl:template mode="processUnsignedIntValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:unsignedInt>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:unsignedInt>
  </xsl:template>
  
  <xsl:template mode="processLongValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:long>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:long>
  </xsl:template>
  
  <!-- WORK IN PROGRESS HERE: differenciate xsd:float/double from fp:float/double -->
  
  <xsl:template mode="processFloatValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:float>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:float>
  </xsl:template>
  
  <xsl:template mode="processDoubleValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:double>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:double>
  </xsl:template>
  
  <xsl:template mode="processStringValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:string>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:string>
  </xsl:template>
  
  <xsl:template mode="processRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:radAngle>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:radAngle>
  </xsl:template>
  
  <xsl:template mode="processCosRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:cosRadAngle>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:cosRadAngle>
  </xsl:template>
  
  <xsl:template mode="processSinRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:sinRadAngle>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:sinRadAngle>
  </xsl:template>
  
  <xsl:template mode="processMinusCosRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:minusCosRadAngle>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:minusCosRadAngle>
  </xsl:template>
  
  <xsl:template mode="processMinusSinRadAngleValue" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:minusSinRadAngle>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:minusSinRadAngle>
  </xsl:template>
  
  <xsl:template mode="processUnknownTypeValue" match=" xsd:attribute | xsd:simpleContent ">
    <gxslt:message>Unknown type for <xsl:copy-of select="."/></gxslt:message>
  </xsl:template>
  
  <xsl:template mode="encodeValue" match="xsd:attribute[@name]">
    <gxslt:attribute name="description">
      <xsl:value-of select="@name" />
    </gxslt:attribute>
    <gxslt:value-of select="{concat('@',@name)}" />
  </xsl:template>
  
  <xsl:template mode="encodeValue" match="xsd:simpleContent">
    <gxslt:attribute name="description">
      <xsl:value-of select="'text value'" />
    </gxslt:attribute>
    <gxslt:value-of select="." />
  </xsl:template>
  
  <xsl:template mode="processSequenceItemVariableCount" match="xsd:element[@ref]">
    <!-- 
    PRE: same element doesn't appear twice at different positions in same sequence definition
    TODO: to handle above case, for each sequence item count elements of its type from current position,
    and update current position to first element after end of this elements.
    -->
    <xsl:variable name="localName" select="substring-after(@ref,':')" />
    <isob4j:short description="{$localName} count">
      <gxslt:value-of select="count({$inPrefix}:{$localName})" />
    </isob4j:short>
  </xsl:template>
  
  <xsl:template mode="processChildItems" match="xsd:sequence">
    <gxslt:apply-templates />
  </xsl:template>
  
  <xsl:template mode="processChoiceVariableCount" match="xsd:choice">
    <isob4j:short description="child count">
      <gxslt:value-of select="count(*)" />
    </isob4j:short>
  </xsl:template>
  
  <xsl:template mode="processEachChoiceItem" match="xsd:choice">
    <gxslt:for-each select="*">
      <xsl:apply-imports />
    </gxslt:for-each>
  </xsl:template>
  
  <xsl:template mode="processChoiceElementType" match="xsd:choice">
    <isob4j:byte>
      <gxslt:choose>
        <xsl:for-each select="xsd:element[@ref]">
          <xsl:variable name="localName" select="substring-after(@ref,':')" />
          <gxslt:when test="self::{$inPrefix}:{$localName}">
            <gxslt:attribute name="description"><xsl:value-of select="concat($localName, ' type')"/></gxslt:attribute>
            <gxslt:value-of select="{position()}" />
          </gxslt:when>
        </xsl:for-each>
      </gxslt:choose>
    </isob4j:byte>
  </xsl:template>
  
  <xsl:template mode="selectChildReference" match="xsd:choice">
    <gxslt:apply-templates select="."/>
  </xsl:template>
  
  <!-- utils -->
  
  <xsl:template name="declareUtils">
    <xsl:call-template name="bitIsPresentTemplate" />
  </xsl:template>
  
  <xsl:template name="bitIsPresentTemplate">
    <gxslt:template name="bitIsPresent">
      <gxslt:param name="node" />
      <gxslt:choose>
        <gxslt:when test="$node">
          <gxslt:value-of select="'1'"/>
        </gxslt:when>
        <gxslt:otherwise>
          <gxslt:value-of select="'0'"/>
        </gxslt:otherwise>
      </gxslt:choose>
    </gxslt:template>
  </xsl:template>
  
</xsl:stylesheet>