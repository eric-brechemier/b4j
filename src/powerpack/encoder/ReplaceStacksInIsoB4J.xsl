<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
  version="1.0"
  xml:lang="en"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:isob4j="http://eric.brechemier.name/2004/bin4java/isoXml"
  xmlns:stack="http://eric.brechemier.name/2004/bin4java/stacks"
  
  exclude-result-prefixes="stack"
>
  <xsl:import href="../../utils/sameButDifferent.xsl" />
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
  <xsl:strip-space elements="isob4j:*" />
  
  <!-- Based on Design Pattern : Same but Different ([Drix 2002] copie non conforme, p.443 )
  
  Compute stacks methaphor equivalents in iso-b4j xml format.
  
  Input:
    Iso-B4J file with some stack elements.
  Output: 
    Same file where stack elements have been replaced by their iso-b4j equivalents.
  -->
  
  <xsl:template match="/">
    <xsl:apply-templates mode="copy" />
  </xsl:template>
  
  <xsl:template mode="copy" match="stack:new[@stack]">
    <xsl:variable name="stackName" select="@stack" />
    <isob4j:short description="stack {$stackName} size">
      <xsl:value-of select="count(//stack:putOn[@stack=$stackName])" />
    </isob4j:short>
  </xsl:template>
  
  <xsl:template mode="copy" match="stack:putOn[@stack and @elementId and @topic]">
    <xsl:apply-templates mode="positionOnStack" select="." />
  </xsl:template>
  
  <xsl:template mode="copy" match="stack:break">
    <isob4j:short description="end of actions {concat('for ',@topic)}">0</isob4j:short>
  </xsl:template>
  
  <xsl:template mode="copy" match="stack:getEachPositionOn[@stack and @elementId and @topic]
                                   | stack:getPositionOn[@stack and @elementId and @topic]
                                  "
  >
    <xsl:variable name="stackName" select="@stack" />
    <xsl:variable name="topicName" select="@topic" />
    <xsl:variable name="elementId" select="@elementId" />
    
    <xsl:variable name="precedingPutOn" select="preceding::stack:putOn[@stack=$stackName 
                                                 and @topic=$topicName and @elementId=$elementId]" 
    />
    <xsl:for-each select="$precedingPutOn">
      <xsl:apply-templates mode="positionOnStack" select="." />
    </xsl:for-each>
    
    <!-- error management: useful to show missing Id/IdRef attribut declarations -->
    <xsl:if test="not($precedingPutOn)">
      <xsl:message>
        <xsl:text>ERROR in replaceStacksInIsoB4J.xsl (referree/referrer resolution at encoding):
</xsl:text><xsl:text>Missing Id for </xsl:text><xsl:copy-of select="." />
      </xsl:message>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template mode="positionOnStack" match="stack:putOn[@stack='backwardIds']">
    <isob4j:short description="position on backwardIds for {@topic}:{@elementId}">
      <xsl:value-of select="- (count(preceding::stack:putOn[@stack='backwardIds'])+1)" />
    </isob4j:short>
  </xsl:template>
  
  <xsl:template mode="positionOnStack" match="stack:putOn[@stack='forwardRefs']">
    <isob4j:short description="position on forwardRefs for {@topic}:{@elementId}">
      <xsl:value-of select="count(preceding::stack:putOn[@stack='forwardRefs'])+1" />
    </isob4j:short>
  </xsl:template>
  
  <xsl:template mode="positionOnStack" match="node()"/>
  
</xsl:stylesheet>