<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
   xmlns:config="http://eric.brechemier.name/2004/generation/encoder-decoder/config"
   xmlns:a4j="http://eric.brechemier.name/2004/generation/encoder-decoder/semanticActionsForJava"
>
  <xsl:import href="../utils/sameButDifferent.xsl" />
  
  <xsl:include href="../utils/xmlSchemaFunctions.xsl" />
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
  
  <!-- Based on Design Pattern : Same but Different ([Drix 2002] copie non conforme, p.443 )
  
  Add Missing Annotations for Semantic Actions in given Xml Schema.
  Input:
  Xml Schema file.
  Output: 
  Same file with empty annotations for actions definitions expected by b4j encoder generator.
  -->
  
  <xsl:template match="/">
    <xsl:apply-templates mode="copy" />
  </xsl:template>
  
  <xsl:template mode="copy" match="xsd:schema[not(xsd:annotation/xsd:appinfo)]">
		<xsl:copy>
      <xsl:call-template name="continueCopyAttributesAndNamespaces" />
      <xsd:annotation>
        <xsl:copy-of select="xsd:annotation/xsd:documentation" />
        <xsd:appinfo>
          <config:root element="USER-ROOT-ELEMENT">
            <xsl:variable name="firstElementName" select="/xsd:schema/xsd:element[1]/@name" />
            <xsl:if test="$firstElementName">
              <xsl:attribute name="element">
                <xsl:value-of select="$firstElementName" />
              </xsl:attribute>
            </xsl:if>
          </config:root>
          <a4j:packages>
          // Java imports
          </a4j:packages>
          <a4j:globalDef>
          // Global _static_ attributes and _static_ methods declarations for Decoder Class
          </a4j:globalDef>
          <a4j:events>
            <a4j:context>
              <xsl:comment>
                &lt;a4j:fromParent&gt;short param, int otherParam,...&lt;/a4j:fromParent&gt;
                &lt;a4j:parentContinuation returnType="GlobalDocumentType" returnVariable="document"/&gt;
                &lt;a4j:childContinuation&gt;null, otherParam,...&lt;/a4j:childContinuation&gt;
              </xsl:comment>
            </a4j:context>
            <a4j:onDocumentStart>
            // User Java Code
            </a4j:onDocumentStart>
            <xsl:comment>
              &lt;a4j:onEachChildEnd fromChild="RootType root"&gt;
              // User Java Code
              // e.g. document = root;
              &lt;/a4j:onEachChildEnd&gt;
            </xsl:comment>
            <a4j:onDocumentEnd>
            // User Java Code
            </a4j:onDocumentEnd>
            <xsl:comment>
              &lt;a4j:onError name="e"&gt;
              
              &lt;/a4j:onError&gt;
            </xsl:comment>
          </a4j:events>
          <xsl:call-template name="checkAndAddResolutionEvents"/>
        </xsd:appinfo>
      </xsd:annotation>
      <xsl:call-template name="continueCopyChildren" />
    </xsl:copy>
	</xsl:template>
  
  <xsl:template mode="copy" match="xsd:complexType[not(xsd:annotation/xsd:appinfo)]
                                                  [xsd:choice | xsd:sequence]" priority="2">
		<xsl:copy>
      <xsl:call-template name="continueCopyAttributesAndNamespaces" />
      <xsd:annotation>
        <xsl:copy-of select="xsd:annotation/xsd:documentation" />
        <xsd:appinfo>
          <a4j:events>
            <xsl:call-template name="emptyContext" />
            <a4j:onElementStart>
            // User Java Code
            </a4j:onElementStart>
            <a4j:onAttributesEnd>
            // User Java Code
            // e.g. if (isAtIdPresent) {
            //        currentElement = new ElementType(atId); 
            //      } else {
            //        currentElement = new ElementType();
            //      }
            </a4j:onAttributesEnd>
            <a4j:onChildrenCount alias="childCount">
            // User Java Code
            // e.g. ChildType[] children = new ChildType[childCount];
            //      currentElement.setChildren(children);
            </a4j:onChildrenCount>
            <xsl:comment>
              &lt;a4j:onEachChildEnd fromChild="ChildType child" position="i"&gt;
              // User Java Code
              // e.g. children[i]=child;
              &lt;/a4j:onEachChildEnd&gt;
            </xsl:comment>
            <a4j:onElementEnd>
            // User Java Code
            </a4j:onElementEnd>
          </a4j:events>
          <xsl:call-template name="checkAndAddResolutionEvents"/>
        </xsd:appinfo>
      </xsd:annotation>
      <xsl:call-template name="continueCopyChildren" />
    </xsl:copy>
	</xsl:template>
  
  <xsl:template mode="copy" match="xsd:complexType[not(xsd:annotation/xsd:appinfo)]
                                                  [xsd:simpleContent]" priority="2">
		<xsl:copy>
      <xsl:call-template name="continueCopyAttributesAndNamespaces" />
      <xsd:annotation>
        <xsl:copy-of select="xsd:annotation/xsd:documentation" />
        <xsd:appinfo>
          <a4j:events>
            <xsl:call-template name="emptyContext" />
            <a4j:onElementStart>
            // User Java Code
            </a4j:onElementStart>
            <a4j:onAttributesEnd>
            // User Java Code
            // e.g. if (isAtIdPresent) {
            //        currentElement = new ElementType(atId); 
            //      } else {
            //        currentElement = new ElementType();
            //      }
            </a4j:onAttributesEnd>
            <a4j:onValueEnd alias="textValue">
            // User Java Code
            // e.g. currentElement.text = textValue;
            </a4j:onValueEnd>
            <a4j:onElementEnd>
            // User Java Code
            </a4j:onElementEnd>
          </a4j:events>
          <xsl:call-template name="checkAndAddResolutionEvents"/>
        </xsd:appinfo>
      </xsd:annotation>
      <xsl:call-template name="continueCopyChildren" />
    </xsl:copy>
	</xsl:template>
  
  <xsl:template mode="copy" match="xsd:complexType[not(xsd:annotation/xsd:appinfo)]" priority="1">
		<xsl:copy>
      <xsl:call-template name="continueCopyAttributesAndNamespaces" />
      <xsd:annotation>
        <xsd:appinfo>
          <a4j:events>
            <xsl:call-template name="emptyContext" />
            <a4j:onElementStart>
            // User Java Code
            </a4j:onElementStart>
            <a4j:onAttributesEnd>
            // User Java Code
            // e.g. if (isAtIdPresent) {
            //        currentElement = new ElementType(atId); 
            //      } else {
            //        currentElement = new ElementType();
            //      }
            </a4j:onAttributesEnd>
            <a4j:onElementEnd>
            // User Java Code
            </a4j:onElementEnd>
          </a4j:events>
          <xsl:call-template name="checkAndAddResolutionEvents"/>
        </xsd:appinfo>
      </xsd:annotation>
      <xsl:call-template name="continueCopyChildren" />
    </xsl:copy>
	</xsl:template>
  
  <xsl:template mode="copy" match="xsd:annotation[not(xsd:appinfo)]" />
  
  <xsl:template name="emptyContext">
    <a4j:context>
      <xsl:comment>
        &lt;a4j:fromParent&gt;Object parentElement, int otherParam,...&lt;/a4j:fromParent&gt;
        &lt;a4j:parentContinuation returnType="ElementType" returnVariable="currentElement"/&gt;
        &lt;a4j:childContinuation&gt;currentElement, otherParam,...&lt;/a4j:childContinuation&gt;
      </xsl:comment>
      <xsl:call-template name="checkAndAddResolutionContinuationInContext" />
    </a4j:context>
  </xsl:template>
  
  <xsl:template mode="copy" match="a4j:context[not(a4j:publish | a4j:subscribe)]">
    <xsl:copy>
      <xsl:call-template name="continueCopy" />
      <xsl:call-template name="checkAndAddResolutionContinuationInContext" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="copy" match="xsd:appinfo[not(a4j:idRefResolution)]">
    <xsl:copy>
      <xsl:call-template name="continueCopy" />
      <xsl:call-template name="checkAndAddResolutionEvents"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="checkAndAddResolutionContinuationInContext">
    
    <xsl:variable name="includePrefix" select="'include'"/>
    <xsl:variable name="ignorePrefix" select="'ignore'"/>
    
    <xsl:variable name="includeId" select="concat($includePrefix,':Id')" />
    <xsl:variable name="ignoreId" select="concat($ignorePrefix,':Id')" />
    
    <xsl:for-each select="ancestor-or-self::xsd:complexType//xsd:attribute[@type=$includeId or @type=$ignoreId]">
      <xsl:variable name="fullKeyName">
        <xsl:call-template name="fullKeyOrUniqueName" />
      </xsl:variable>
      
      <xsl:if test="$fullKeyName != ''">
        <xsl:for-each select="//xsd:keyref[@refer=$fullKeyName]">
          <a4j:publish topic="{@name}" referree="currentElement"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
    
    <xsl:variable name="includeIdRef" select="concat($includePrefix,':IdRef')" />
    <xsl:variable name="ignoreIdRef" select="concat($ignorePrefix,':IdRef')" />
    
    <xsl:for-each select="ancestor-or-self::xsd:complexType//xsd:attribute[@type=$includeIdRef or @type=$ignoreIdRef]">
      <xsl:variable name="keyrefName">
        <xsl:call-template name="keyrefName" />
      </xsl:variable>
      
      <xsl:if test="$keyrefName != ''">
        <a4j:subscribe topic="{$keyrefName}" referrer="currentElement"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="checkAndAddResolutionEvents">
    
    <xsl:variable name="includePrefix" select="'include'"/>
    <xsl:variable name="ignorePrefix" select="'ignore'"/>
    
    <xsl:variable name="includeIdRef" select="concat($includePrefix,':IdRef')" />
    <xsl:variable name="ignoreIdRef" select="concat($ignorePrefix,':IdRef')" />
    
    <xsl:for-each select="ancestor-or-self::xsd:complexType//xsd:attribute[@type=$includeIdRef or @type=$ignoreIdRef]">
      <xsl:variable name="keyrefName">
        <xsl:call-template name="keyrefName" />
      </xsl:variable>
      
      <xsl:if test="$keyrefName != ''">
        <a4j:topic keyref="{$keyrefName}">
          <a4j:context>
            <a4j:fromReferree object="ReferreeType referree"/>
            <a4j:fromReferrer object="ReferrerType referrer"/>
          </a4j:context>
          <a4j:onMessage>
            // User Java Code
            // e.g. referrer.setTarget( referree );
          </a4j:onMessage>
        </a4j:topic>
      </xsl:if>
    </xsl:for-each>
    
  </xsl:template>
  
</xsl:stylesheet>