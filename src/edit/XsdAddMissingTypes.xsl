<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
>
  <xsl:import href="../utils/sameButDifferent.xsl" />
  
  <xsl:include href="../utils/stringFunctions.xsl" />
  <xsl:include href="../utils/xmlSchemaFunctions.xsl" />
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
  
  <!-- Based on Design Pattern : Same but Different ([Drix 2002] copie non conforme, p.443 )
  
  Add Missing Types definitions in Xml Schema file.
  Input:
  Xml Schema file.
  Output: 
  Same file with new complexTypes elements corresponding to elements with missing types:
  
  a simple content complex type when type="t" or type="text"
      e.g. <xsd:element name="USERelement" type="text" />
  a complex type with no children when type attribute is missing
      e.g. <xsd:element name="USERelement" />
  a complex type with sequence when type="seq" or type="sequence"
      e.g. <xsd:element name="USERelement" type="seq"/>
  a complex type with sequence when type="ch" or type="choice"
      e.g. <xsd:element name="USERelement" type="choice"/>
  a complex type with no children when type attribute is missing
      e.g. <xsd:element name="USERelement" />    
  a complex type with name after ':' when a qualified name is provided
      e.g. <xsd:element name="USERelement" type="USERPrefix:TypeName" />
  -->
	
  <xsl:template match="xsd:schema">
		<xsl:copy>
      <xsl:call-template name="continueCopy" />
      <xsl:apply-templates mode="elementWithMissingType" select="xsd:element"/>
    </xsl:copy>
	</xsl:template>
  
  <xsl:template mode="copy" match="xsd:element[@name and not(@type)]">
    <xsl:variable name="userPrefix">
      <xsl:call-template name="targetNamespacePrefix" />
    </xsl:variable>
    <xsl:variable name="typeName">
      <xsl:call-template name="createTypeName">
        <xsl:with-param name="elementName" select="@name" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy>
      <!-- output name first with saxon -->
      <xsl:attribute name="name">
        <xsl:value-of select="@name" />
      </xsl:attribute>
      <xsl:attribute name="type">
        <xsl:value-of select="concat($userPrefix,':',$typeName)" />
      </xsl:attribute>
      <xsl:call-template name="continueCopy" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="copy" match="xsd:element/@type[.='t' or .='text' or .='seq' or .='sequence' or .='ch' or .='choice']">
    <xsl:variable name="userPrefix">
      <xsl:call-template name="targetNamespacePrefix" />
    </xsl:variable>
    <xsl:variable name="typeName">
      <xsl:call-template name="createTypeName">
        <xsl:with-param name="elementName" select="../@name" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:attribute name="type">
      <xsl:value-of select="concat($userPrefix,':',$typeName)" />
    </xsl:attribute>
  </xsl:template>
  
  
  <xsl:template mode="elementWithMissingType" match="xsd:element[@type='t' or @type='text']">
    <xsl:variable name="typeName">
      <xsl:call-template name="createTypeName">
        <xsl:with-param name="elementName" select="@name" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsd:complexType name="{$typeName}">
      <xsd:simpleContent>
        <xsd:extension base="xsd:string">
          <xsl:comment> &lt;xsd:attribute name="id" type="xsd:byte" use="optional" /&gt; </xsl:comment>
        </xsd:extension>
      </xsd:simpleContent>
    </xsd:complexType>
  </xsl:template>
  
  <xsl:template mode="elementWithMissingType" match="xsd:element[@name and not(@type)]">
    <xsl:call-template name="newComplexType">
      <xsl:with-param name="elementName" select="@name" />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="elementWithMissingType" match="xsd:element[@type='seq' or @type='sequence']">
    <xsl:call-template name="newComplexType">
      <xsl:with-param name="elementName" select="@name" />
      <xsl:with-param name="contentType" select="'sequence'" />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="elementWithMissingType" match="xsd:element[@type='ch' or @type='choice']">
    <xsl:call-template name="newComplexType">
      <xsl:with-param name="elementName" select="@name" />
      <xsl:with-param name="contentType" select="'choice'" />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="elementWithMissingType" match="xsd:element[@type]" priority="-1">
    <xsl:variable name="typeName" select="substring-after(@type,':')" />
    <xsl:if test="not(/xsd:schema/xsd:complexType[@name=$typeName])">
      <xsl:call-template name="newComplexType">
        <xsl:with-param name="typeName" select="$typeName" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="newComplexType">
    <xsl:param name="elementName" />
    <xsl:param name="contentType" select="'empty'" /> <!-- or 'sequence' or 'choice' -->
    <xsl:param name="typeName">
      <xsl:call-template name="createTypeName">
        <xsl:with-param name="elementName" select="$elementName" />
      </xsl:call-template>
    </xsl:param>
    
    <xsd:complexType name="{$typeName}">
      <xsl:choose>
        <xsl:when test="$contentType='choice'">
          <xsd:choice minOccurs="0" maxOccurs="unbounded">
            <xsl:comment> &lt;xsd:element ref="usr:Type" /&gt; </xsl:comment>
          </xsd:choice>
        </xsl:when>
        <xsl:when test="$contentType='sequence'">
          <xsd:sequence>
            <xsl:comment> &lt;xsd:element ref="usr:Type" minOccurs="0" maxOccurs="unbounded" /&gt; </xsl:comment>
          </xsd:sequence>
        </xsl:when>
      </xsl:choose>
      <xsl:comment> &lt;xsd:attribute name="id" type="xsd:byte" use="optional" /&gt; </xsl:comment>
    </xsd:complexType>
  </xsl:template>
  
  <xsl:template name="createTypeName">
    <xsl:param name="elementName" />
    <xsl:variable name="typeName">
      <xsl:call-template name="capitalizeFirstLetter">
        <xsl:with-param name="string" select="$elementName" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$elementName = $typeName">
        <xsl:value-of select="concat($typeName,'Type')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$typeName" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="elementWithMissingType" match="text()" />
  
</xsl:stylesheet>