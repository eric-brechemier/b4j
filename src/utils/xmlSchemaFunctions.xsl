<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
>
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
   
  <!-- 
  Xml Schema Data Handling named templates:
  
  * targetNamespacePrefix() as string
  * targetNamespaceURI() as string
  * xmlSchemaNamespacePrefix() as string
  * namespaceURI(prefix as string) as string
  
  * qualifyWithTargetPrefix(localName as string) as string
  * elementName(complexTypeName as string) as string
  * attributeParentComplexTypeName(attribute as xsd:attribute) as string
  * attributeParentElementName(attribute as xsd:attribute) as string
  
  * keyOrUniqueName(idAttribute as xsd:attribute) as string
  * fullKeyOrUniqueName(idAttribute as xsd:attribute) as string
  * isElementLeafInXpath(xpath as string, fullElementName as string) as boolean
  * keyrefName(refAttribute as xsd:attribute) as string
  
  * buildXpathSelectForKeyConstraints(xpathAcc as string, keyConstraints as xsd:key|xsd:unique|xsd:keyref node-set ) as string
  * buildXpathSelectForOneKeyConstraint (xpathAcc as string, keyConstraint as xsd:key|xsd:unique|xsd:keyref node, xpathToProcess as string, xpathFieldSuffix as string) as string
  
  * xpathUnion (xpathLeft as string, xpathRight as string) as string
  -->
  
  <xsl:template name="targetNamespacePrefix">
    <xsl:variable name="targetNamespaceURI" select="/xsd:schema/@targetNamespace" />
    <xsl:variable name="targetNamespace" select="/xsd:schema/namespace::*[.=$targetNamespaceURI]" />
    <xsl:value-of select="local-name($targetNamespace)" />
  </xsl:template>
  
  <xsl:template name="targetNamespaceURI">
    <xsl:variable name="targetNamespaceURI" select="/xsd:schema/@targetNamespace" />
    <xsl:value-of select="$targetNamespaceURI" />
  </xsl:template>
  
  <xsl:template name="xmlSchemaNamespacePrefix">
    <xsl:variable name="xsdNamespaceURI" select="'http://www.w3.org/2001/XMLSchema'" />
    <xsl:variable name="xsdNamespace" select="/xsd:schema/namespace::*[.=$xsdNamespaceURI]" />
    <xsl:value-of select="local-name($xsdNamespace)" />
  </xsl:template>
  
  <xsl:template name="namespaceURI">
    <xsl:param name="prefix" />
    <xsl:variable name="elementDefiningNamespace" 
      select="ancestor-or-self::*[ namespace::*[local-name()=$prefix] ]" />
    <xsl:variable name="namespaceForPrefix" select="$elementDefiningNamespace/namespace::*[local-name()=$prefix]" />
    <xsl:variable name="namespaceURI">
      <xsl:value-of select="$namespaceForPrefix" />
    </xsl:variable>
    <xsl:value-of select="$namespaceURI" />
  </xsl:template>
  
  
  <xsl:template name="qualifyWithTargetPrefix">
    <xsl:param name="localName" />
    
    <xsl:variable name="targetPrefix">
      <xsl:call-template name="targetNamespacePrefix"/>
    </xsl:variable>
    <xsl:value-of select="concat($targetPrefix,':',$localName)"/>
  </xsl:template>
  
  <xsl:template name="elementName">
    <xsl:param name="complexTypeName" />
    
    <xsl:variable name="fullComplexTypeName">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName" select="$complexTypeName" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:value-of select="/xsd:schema/xsd:element[@type=$fullComplexTypeName]/@name" />
  </xsl:template>
  
  <xsl:template name="attributeParentComplexTypeName">
    <xsl:param name="attribute" />
    
    <xsl:value-of select="$attribute/ancestor::xsd:complexType/@name" />
  </xsl:template>
  
  <xsl:template name="attributeParentElementName">
    <xsl:param name="attribute" select="."/>
    
    <xsl:variable name="attributeParentComplexTypeName">
      <xsl:call-template name="attributeParentComplexTypeName">
        <xsl:with-param name="attribute" select="$attribute" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:call-template name="elementName">
      <xsl:with-param name="complexTypeName" select="$attributeParentComplexTypeName" />
    </xsl:call-template>
    
  </xsl:template>
  
  
  <xsl:template name="keyOrUniqueName">
    <xsl:param name="idAttribute" select="."/>
    
    <xsl:variable name="xpathForAttribute" select="concat('@',$idAttribute/@name)" />
    <xsl:variable name="parentElementName">
      <xsl:call-template name="attributeParentElementName">
        <xsl:with-param name="attribute" select="$idAttribute" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fullParentElementName">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName" select="$parentElementName" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="potentialKeyOrUnique"
      select="//xsd:field
              [
                    (parent::xsd:key or parent::xsd:unique)
                and @xpath=$xpathForAttribute
                and preceding-sibling::xsd:selector
                    [
                        (
                            contains(@xpath,$parentElementName)
                        and contains(@xpath,$fullParentElementName)
                        )
                      or
                        (
                          contains(@xpath,'*')
                        )
                    ]
              ]
              /..
             " 
    />
    
    <xsl:variable name="result">
      <xsl:for-each select="$potentialKeyOrUnique">
        <!-- only one key or unique maximum is expected to match 
        modify following to return several results more cleanly (may need XSLT 1.1 on client-side)
        -->
        <xsl:variable name="isReallyCorrespondingKeyOrUnique">
          <xsl:variable name="doesXpathContainElementAsLeaf">
            <xsl:call-template name="isElementLeafInXpath">
              <xsl:with-param name="xpath" select="xsd:selector/@xpath" />
              <xsl:with-param name="fullElementName" select="$fullParentElementName"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="$doesXpathContainElementAsLeaf='true'" />
        </xsl:variable>
        <xsl:if test="$isReallyCorrespondingKeyOrUnique='true'">
          <xsl:value-of select="@name" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:value-of select="$result" />
  </xsl:template>
  
  <!-- NOTA: returns true too when * or sameprefix:* is found as leaf -->
  <xsl:template name="isElementLeafInXpath">
    <xsl:param name="xpath" />
    <xsl:param name="fullElementName" />
    
    <xsl:choose>
      <xsl:when test="contains($xpath,'|')">
      
        <xsl:variable name="isElementLeafInXpathBegin">
          <xsl:call-template name="isElementLeafInXpath">
            <xsl:with-param name="xpath" select="substring-before($xpath,'|')" />
            <xsl:with-param name="fullElementName" select="$fullElementName"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$isElementLeafInXpathBegin='true'">
            <xsl:value-of select="$isElementLeafInXpathBegin"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="isElementLeafInXpath">
              <xsl:with-param name="xpath" select="substring-after($xpath,'|')" />
              <xsl:with-param name="fullElementName" select="$fullElementName"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:when>
      <xsl:when test="contains($xpath,'/')">
        
        <xsl:call-template name="isElementLeafInXpath">
          <xsl:with-param name="xpath" select="substring-after($xpath,'/')" />
          <xsl:with-param name="fullElementName" select="$fullElementName"/>
        </xsl:call-template>
        
      </xsl:when>
      <xsl:when test="contains($xpath,' ')">
      
        <xsl:call-template name="isElementLeafInXpath">
          <xsl:with-param name="xpath" select="translate($xpath,' ','')" />
          <xsl:with-param name="fullElementName" select="$fullElementName"/>
        </xsl:call-template>
      
      </xsl:when>
      <xsl:when test="$xpath = $fullElementName">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="$xpath = '*'">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="substring-after($xpath,':') = '*' and substring-before($xpath,':')=substring-before($fullElementName,':')">
        <!-- NOTA: doesn't check same namespace with different prefixes. 
        compare namespaceURIs instead to be more namespace compliant -->
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="fullKeyOrUniqueName">
    <xsl:param name="idAttribute" select="."/>
    
    <xsl:variable name="localKeyOrUniqueName">
      <xsl:call-template name="keyOrUniqueName">
        <xsl:with-param name="idAttribute" select="$idAttribute"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:if test="$localKeyOrUniqueName != ''">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName" select="$localKeyOrUniqueName" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="keyrefName">
    <xsl:param name="refAttribute" select="."/>
    
    <xsl:variable name="xpathForAttribute" select="concat('@',$refAttribute/@name)" />
    <xsl:variable name="parentElementName">
      <xsl:call-template name="attributeParentElementName">
        <xsl:with-param name="attribute" select="$refAttribute" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fullParentElementName">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName" select="$parentElementName" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="potentialKeyref"
      select="//xsd:field
              [
                    parent::xsd:keyref
                and @xpath=$xpathForAttribute
                and preceding-sibling::xsd:selector
                    [
                        (
                            contains(@xpath,$parentElementName)
                        and contains(@xpath,$fullParentElementName)
                        )
                      or
                        (
                          contains(@xpath,'*')
                        )
                    ]
              ]
              /..
             " 
    />
    
    <xsl:variable name="result">
      <xsl:for-each select="$potentialKeyref">
        <!-- only one keyref maximum is expected to match:
        one element attribute should only be used in one keyref.
        Modify following to return several results more cleanly (may need XSLT 1.1 on client-side)
        -->
        <xsl:variable name="isReallyCorrespondingKeyref">
          <xsl:variable name="doesXpathContainElementAsLeaf">
            <xsl:call-template name="isElementLeafInXpath">
              <xsl:with-param name="xpath" select="xsd:selector/@xpath" />
              <xsl:with-param name="fullElementName" select="$fullParentElementName"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="$doesXpathContainElementAsLeaf='true'" />
        </xsl:variable>
        <xsl:if test="$isReallyCorrespondingKeyref='true'">
          <xsl:value-of select="@name" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:value-of select="$result" />
  </xsl:template>
  
  
  <xsl:template name="buildXpathSelectForKeyConstraints">
    <xsl:param name="xpathAcc" select="''"/>
    <xsl:param name="keyConstraints" />
    
    <xsl:choose>
      <xsl:when test="$keyConstraints">
        
        <xsl:variable name="firstConstraint" select="$keyConstraints[1]"/>
        <xsl:variable name="newXpathAcc">
          <xsl:call-template name="buildXpathSelectForOneKeyConstraint">
            <xsl:with-param name="keyConstraint" select="$firstConstraint" />
            <xsl:with-param name="xpathAcc" select="$xpathAcc"/>
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="buildXpathSelectForKeyConstraints">
          <xsl:with-param name="xpathAcc" select="$newXpathAcc" />
          <xsl:with-param name="keyConstraints" select="$keyConstraints[position()&gt;1]" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$xpathAcc" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="buildXpathSelectForOneKeyConstraint">
    <xsl:param name="xpathAcc" select="''"/>
    <xsl:param name="keyConstraint" />
    <xsl:param name="xpathToProcess" select="$keyConstraint/xsd:selector/@xpath" />
    <xsl:param name="xpathFieldSuffix" select="concat('/',$keyConstraint/xsd:field/@xpath)" />
    <xsl:param name="xpathPrefix" select="''" />
    
    <xsl:choose>
      <xsl:when test="contains($xpathToProcess,'|')">
        <xsl:variable name="xpathSelect" 
          select="concat($xpathPrefix,normalize-space(substring-before($xpathToProcess,'|')),$xpathFieldSuffix)"/>
        <xsl:variable name="newXpathAcc">
          <xsl:call-template name="xpathUnion">
            <xsl:with-param name="xpathLeft" select="$xpathAcc" />
            <xsl:with-param name="xpathRight" select="$xpathSelect" />
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="buildXpathSelectForOneKeyConstraint">
          <xsl:with-param name="xpathAcc" select="$newXpathAcc"/>
          <xsl:with-param name="keyConstraint" select="$keyConstraint" />
          <xsl:with-param name="xpathToProcess" select="substring-after($xpathToProcess,'|')"/>
          <xsl:with-param name="xpathFieldSuffix" select="$xpathFieldSuffix" />
          <xsl:with-param name="xpathPrefix" select="$xpathPrefix" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="xpathSelect" 
          select="concat($xpathPrefix,normalize-space($xpathToProcess),$xpathFieldSuffix)"/>
        <xsl:variable name="resultXpath">
          <xsl:call-template name="xpathUnion">
            <xsl:with-param name="xpathLeft" select="$xpathAcc" />
            <xsl:with-param name="xpathRight" select="$xpathSelect" />
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="$resultXpath" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="xpathUnion">
    <xsl:param name="xpathLeft" />
    <xsl:param name="xpathRight" />
    
    <xsl:choose>
      <xsl:when test="normalize-space($xpathLeft)=''">
        <xsl:value-of select="$xpathRight" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($xpathLeft,' | ',$xpathRight)" />
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
</xsl:stylesheet>