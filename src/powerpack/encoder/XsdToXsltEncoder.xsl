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
  <xsl:import href="../browsing/XsdBrowsingTemplateMethod.xsl" />
  
  <!--
  PowerPack extension for Custom XML Encoding with id/ref management.
  
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
  
  <xsl:include href="../../encoder/XsdToXsltEncoder.body.xsl" />
  
  <xsl:template mode="processIdRefResolutionStacks" match="xsd:schema">
    <stack:new stack="backwardIds" />
    <stack:new stack="forwardRefs" />
  </xsl:template>
  
  <xsl:template mode="processReferree" match="xsd:attribute[@name and not(@use='required')]">
    
    <xsl:variable name="xpathAttribute" select="concat('@',@name)" />
    <gxslt:if test="{$xpathAttribute}">
      <xsl:apply-imports />
    </gxslt:if>
    
  </xsl:template>
  
  <xsl:template mode="processReferree" match="xsd:attribute">
    <gxslt:if test="/">
      <xsl:apply-imports />
    </gxslt:if>
  </xsl:template>
  
  <xsl:template mode="processReferreeActions" match="xsd:attribute[@name]">
    <xsl:param name="keyref" />
    <xsl:param name="keyrefName" />
    
    <xsl:variable name="elementFullName">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName">
          <xsl:call-template name="attributeParentElementName">
            <xsl:with-param name="attribute" select="." />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="attributeName" select="@name" />
    <xsl:variable name="xpathAttribute" select="concat('@',$attributeName)" />
    <gxslt:variable name="gxsltId" select="{$xpathAttribute}" />
    
    <xsl:variable name="fullContextElementName">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName" select="$keyref/ancestor::xsd:element/@name" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="xpathSelectAllPotentialRefs">
      <xsl:call-template name="buildXpathSelectForOneKeyConstraint">
        <xsl:with-param name="keyConstraint" select="$keyref" />
        <xsl:with-param name="xpathPrefix" select="concat('//',$fullContextElementName,'/')" />
      </xsl:call-template>
    </xsl:variable>
    <gxslt:variable name="gxsltXpathSelectAllPotentialRefs{position()}" select="{$xpathSelectAllPotentialRefs}" />
    <gxslt:variable name="gxsltXpathSelectAllMyRefs{position()}" select="$gxsltXpathSelectAllPotentialRefs{position()}[.=$gxsltId]" />
    
    <gxslt:variable name="gxsltXpathSelectAllMyRefsBefore{position()}" 
      select="$gxsltXpathSelectAllMyRefs{position()}[ ../following::{$elementFullName}[{$xpathAttribute}=$gxsltId] ]" 
    />
    <gxslt:if test="$gxsltXpathSelectAllMyRefsBefore{position()}">
      <stack:getEachPositionOn stack="forwardRefs" elementId="{'{'}$gxsltId{'}'}" topic="{$keyrefName}"/>
    </gxslt:if>
    
    <gxslt:variable name="gxsltXpathSelectAllMyRefsAfterOrSelf{position()}" 
      select="$gxsltXpathSelectAllMyRefs{position()}
        [ ../preceding::{$elementFullName}[{$xpathAttribute}=$gxsltId] 
          | parent::{$elementFullName}[{$xpathAttribute}=$gxsltId] 
        ]" 
    />
    <gxslt:choose>
      <gxslt:when test="$gxsltXpathSelectAllMyRefsAfterOrSelf{position()}">
        <stack:putOn stack="backwardIds" elementId="{'{'}$gxsltId{'}'}" topic="{$keyrefName}"/>
      </gxslt:when>
      <gxslt:otherwise>
        <stack:break topic="{$keyrefName}"/>
      </gxslt:otherwise>
    </gxslt:choose>
  </xsl:template>
  
  <xsl:template mode="processReferrer" match="xsd:attribute[@name and not(@use='required')]">
    
    <xsl:variable name="xpathAttribute" select="concat('@',@name)" />
    <gxslt:if test="{$xpathAttribute}">
      <xsl:apply-imports />
    </gxslt:if>
    
  </xsl:template>
  
  <xsl:template mode="processReferrer" match="xsd:attribute">
    <gxslt:if test="/">
      <xsl:apply-imports />
    </gxslt:if>
  </xsl:template>
  
  <xsl:template mode="processReferrerActions" match="xsd:attribute[@name]">
    <xsl:param name="keyrefName" />
    
    <xsl:variable name="xpathAttribute" select="concat('@',@name)" />
    <gxslt:variable name="gxsltRef" select="{$xpathAttribute}" />
    
    <xsl:variable name="keyrefConstraint" select="//xsd:keyref[@name=$keyrefName and @refer]" />
    <xsl:variable name="keyName" select="substring-after($keyrefConstraint/@refer,':')"/>
    <xsl:variable name="keyOrUniqueConstraint" select="//xsd:key[@name=$keyName] | //xsd:unique[@name=$keyName]" />
    
    <xsl:variable name="fullContextElementName">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName" select="$keyOrUniqueConstraint/ancestor::xsd:element/@name" />
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="elementFullName">
      <xsl:call-template name="qualifyWithTargetPrefix">
        <xsl:with-param name="localName">
          <xsl:call-template name="attributeParentElementName" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="xpathSelectAllPotentialIds">
      <xsl:call-template name="buildXpathSelectForOneKeyConstraint">
        <xsl:with-param name="keyConstraint" select="$keyOrUniqueConstraint" />
        <xsl:with-param name="xpathPrefix" select="concat('//',$fullContextElementName,'/')" />
      </xsl:call-template>
    </xsl:variable>
    
    <gxslt:variable name="gxsltXpathSelectAllPotentialIds" select="{$xpathSelectAllPotentialIds}" />
    <gxslt:variable name="gxsltXpathSelectMyUniqueId" select="$gxsltXpathSelectAllPotentialIds[.=$gxsltRef]" />
    
    <gxslt:variable name="referrerId" select="generate-id(.)" />
    <gxslt:variable name="gxsltXpathSelectMyUniqueIdBefore" 
      select="$gxsltXpathSelectMyUniqueId[ ../following::{$elementFullName}[generate-id()=$referrerId] ]" 
    />
    
    <gxslt:choose>
      <gxslt:when test="$gxsltXpathSelectMyUniqueIdBefore">
        <stack:getPositionOn stack="backwardIds" elementId="{'{'}$gxsltRef{'}'}" topic="{$keyrefName}"/>
      </gxslt:when>
      <gxslt:otherwise>
        <stack:putOn stack="forwardRefs" elementId="{'{'}$gxsltRef{'}'}" topic="{$keyrefName}"/>
      </gxslt:otherwise>
    </gxslt:choose>
  </xsl:template>
  
  
  <xsl:template mode="processInlineFile" match=" xsd:attribute | xsd:simpleContent ">
    <isob4j:file>
      <xsl:apply-templates mode="encodeValue" select="."/>
    </isob4j:file>
  </xsl:template>
  
</xsl:stylesheet>