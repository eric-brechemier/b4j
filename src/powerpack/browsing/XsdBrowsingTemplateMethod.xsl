<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:config="http://eric.brechemier.name/2004/generation/encoder-decoder/config"
  exclude-result-prefixes="xsd config"
>
  <xsl:import href="../../browsing/XsdBrowsingTemplateMethod.xsl" /> 
  
  <!--
  PowerPack extension for Xml Schema Browsing with id/ref management.
  
  Input:
    Basic XML Schema describing (for example) Femto SVG.
   
  Output (Abstract):
    This stylesheet is to be imported by another one.
    Following Gang of 4 Template Method design pattern, it defines browsing algorithm with abstract actions,
    and delegates concrete actions implementation to importing stylesheets.
    
  Created:
    by Eric Bréchemier
    on November 12th, 2004
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:template mode="processDocumentContent" match="xsd:schema">
    <xsl:if test="$formatVersion != 'DISABLED'">
      <xsl:apply-templates mode="processVersionNumber" select="." />
    </xsl:if>
    <xsl:if test="//xsd:keyref">
      <xsl:apply-templates mode="processIdRefResolutionStacks" select="." />
    </xsl:if>
    <xsl:apply-templates mode="processRootElement" select="." />
  </xsl:template>
  
  <xsl:template mode="processElement" match="xsd:element[@type]">
    <xsl:apply-templates mode="processKeyOrUniqueConstraint" select="xsd:key | xsd:unique" />
    <xsl:apply-templates mode="processKeyrefConstraint" select="xsd:keyref" />
    
    <xsl:apply-imports />
  </xsl:template>
  
  <xsl:template mode="processAttributeValue" match="xsd:attribute[@type]">
    <xsl:apply-templates mode="processPowerPackTypedValue" select=".">
      <xsl:with-param name="typeRef" select="@type"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processTextValue" match="xsd:simpleContent[xsd:extension/@base]">
    <xsl:apply-templates mode="processPowerPackTypedValue" select=".">
      <xsl:with-param name="typeRef" select="xsd:extension/@base"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="processPowerPackTypedValue" match=" xsd:attribute | xsd:simpleContent ">
    <xsl:param name="typeRef" />
    
    <xsl:variable name="includeIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/includeValues/'" />
    <xsl:variable name="ignoreIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/ignoreValues/'" />
    
    <xsl:variable name="typeName" select="substring-after($typeRef,':')"/>
    <xsl:variable name="typePrefix" select="substring-before($typeRef,':')"/>
    <xsl:variable name="typeNamespaceURI">
      <xsl:call-template name="namespaceURI">
        <xsl:with-param name="prefix" select="$typePrefix" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$typeNamespaceURI = $includeIdRefURI">
        <xsl:choose>
          <xsl:when test="$typeName = 'Id'">
            <!-- <xsl:apply-templates mode="processReferree" select="."/> -->
            <xsl:apply-templates mode="processByteValue" select="."/>
          </xsl:when>
          <xsl:when test="$typeName = 'IdRef'">
            <!-- <xsl:apply-templates mode="processReferrer" select="."/> -->
            <xsl:apply-templates mode="processByteValue" select="." />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="processTypedValue" select=".">
              <xsl:with-param name="typeRef" select="$typeRef"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$typeNamespaceURI = $ignoreIdRefURI">
        <xsl:choose>
          <xsl:when test="$typeName = 'Id'" />
          <xsl:when test="$typeName = 'IdRef'" />
          <xsl:when test="$typeName = 'FileName'">
            <xsl:apply-templates mode="processInlineFile" select="." />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="processTypedValue" select=".">
              <xsl:with-param name="typeRef" select="$typeRef"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        
        <xsl:apply-templates mode="processTypedValue" select=".">
          <xsl:with-param name="typeRef" select="$typeRef"/>
        </xsl:apply-templates>
        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="returnElementProcessingResult" match="xsd:complexType[@name]">
    <xsl:apply-templates mode="processAllReferrees" select="." />
    <xsl:apply-templates mode="processAllReferrers" select="." />
  </xsl:template>
  
  <xsl:template mode="processAllReferrees" match="xsd:complexType[@name]">
    
    <xsl:variable name="includeIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/includeValues/'" />
    <xsl:variable name="ignoreIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/ignoreValues/'" />
    
    <xsl:for-each select=".//xsd:attribute[@name and @type]">
      <xsl:variable name="typeName" select="substring-after(@type,':')"/>
      <xsl:variable name="typePrefix" select="substring-before(@type,':')"/>
      <xsl:variable name="typeNamespaceURI">
        <xsl:call-template name="namespaceURI">
          <xsl:with-param name="prefix" select="$typePrefix" />
        </xsl:call-template>
      </xsl:variable>
      
      <xsl:if test="$typeName='Id' and ($typeNamespaceURI=$includeIdRefURI or $typeNamespaceURI=$ignoreIdRefURI)">
        <xsl:apply-templates mode="processReferree" select="."/>
      </xsl:if>
    </xsl:for-each>
    
  </xsl:template>
  
  <xsl:template mode="processAllReferrers" match="xsd:complexType[@name]">
    
    <xsl:variable name="includeIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/includeValues/'" />
    <xsl:variable name="ignoreIdRefURI" select="'http://eric.brechemier.name/2004/generation/encoder-decoder/idRefResolution/ignoreValues/'" />
    
    <xsl:for-each select=".//xsd:attribute[@name and @type]">
      <xsl:variable name="typeName" select="substring-after(@type,':')"/>
      <xsl:variable name="typePrefix" select="substring-before(@type,':')"/>
      <xsl:variable name="typeNamespaceURI">
        <xsl:call-template name="namespaceURI">
          <xsl:with-param name="prefix" select="$typePrefix" />
        </xsl:call-template>
      </xsl:variable>
      
      <xsl:if test="$typeName='IdRef' and ($typeNamespaceURI=$includeIdRefURI or $typeNamespaceURI=$ignoreIdRefURI)">
        <xsl:apply-templates mode="processReferrer" select="."/>
      </xsl:if>
    </xsl:for-each>
    
  </xsl:template>
  
  
  <xsl:template mode="processReferree" match="xsd:attribute">
    <xsl:variable name="idAttribute" select="."/>
    
    <xsl:variable name="fullKeyName">
      <xsl:call-template name="fullKeyOrUniqueName" />
    </xsl:variable>
    <xsl:if test="$fullKeyName != ''">
      <xsl:for-each select="//xsd:keyref[@name and @refer=$fullKeyName]">
        
        <xsl:apply-templates mode="processReferreeActions" select="$idAttribute">
          <xsl:with-param name="keyref" select="."/>
          <xsl:with-param name="keyrefName" select="@name"/>
        </xsl:apply-templates>
        
      </xsl:for-each>
    </xsl:if>
    
  </xsl:template>
  
  
  
  <xsl:template mode="processReferrer" match="xsd:attribute">
    
    <xsl:variable name="keyrefName">
      <xsl:call-template name="keyrefName" />
    </xsl:variable>
    <xsl:if test="$keyrefName != ''">
      <xsl:apply-templates mode="processReferrerActions" select=".">
        <xsl:with-param name="keyrefName" select="$keyrefName"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="processKeyOrUniqueConstraint" match="node()" />
  <xsl:template mode="processKeyrefConstraint" match="node()" />
  
  <xsl:template mode="processAllReferrees" match="node()" />
  <xsl:template mode="processAllReferrers" match="node()" />
  
  <xsl:template mode="processReferree" match="node()" />
  <xsl:template mode="processReferrer" match="node()" />
  
  <xsl:template mode="processReferreeActions" match="node()" />
  <xsl:template mode="processReferrerActions" match="node()" />
  
  <xsl:template mode="processPowerPackTypedValue" match="node()" />
  
  <xsl:template mode="processInlineFile" match="node()" />
  
</xsl:stylesheet>