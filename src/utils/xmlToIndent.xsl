<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   
>
  <xsl:include href="textFormatFunctions.xsl" />

  <xsl:output method="xml" indent="no" encoding="ISO-8859-1" />
   
  <!--
  Input:
    any xml file
 
  Output:
   same xml, indented
    
  Created (English Version):
   by Eric Bréchemier
   on October 20th, 2004
  (French version created in 2003)
  
  Executed with Saxon without specific extensions; command line example:
  (java/)java -jar (saxon/)saxon.jar -o XsltAbstractDecoder.xsl FemtoSvg.xsd XsdToXsltAbstractDecoder.xsl
  -->
  
  <xsl:template match="*">
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" /><xsl:copy>
      <xsl:copy-of select="@* | namespace::*" />
      <xsl:apply-templates />
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" /></xsl:copy>
	</xsl:template>
  
  <xsl:template match="*[  count(child::node())=0 ]">
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" />
      <xsl:copy-of select="." />
	</xsl:template>
  
  <xsl:template match="*[count(child::node())=1 and child::text()[not(contains(.,'&#xA;'))] ]">
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" /><xsl:copy>
      <xsl:copy-of select="@* | namespace::*" />
      <xsl:apply-templates />
    </xsl:copy>
	</xsl:template>
  
  <xsl:template match="comment()">
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" />
    <xsl:comment>
      <xsl:call-template name="indentText">
        <xsl:with-param name="text" select="." />
      </xsl:call-template>
    </xsl:comment>
  </xsl:template> 
  
  <xsl:template match="processing-instruction()">
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" />
    <xsl:processing-instruction name="{name()}">
      <xsl:call-template name="indentText">
        <xsl:with-param name="text" select="." />
      </xsl:call-template>
    </xsl:processing-instruction>
  </xsl:template> 
  
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="text()[contains(.,'&#xA;')]">
    <xsl:if test="normalize-space(.)!=''">
      <xsl:call-template name="newLine" /><xsl:call-template name="indent" />
      <xsl:call-template name="indentText">
        <xsl:with-param name="text">
          <xsl:call-template name="trimText">
            <xsl:with-param name="text" select="."/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  
  
  <xsl:template match="*[@xml:space='preserve']" priority="2">
    <xsl:call-template name="newLine" /><xsl:call-template name="indent" /><xsl:copy>
      <xsl:copy-of select="@* | namespace::*" />
      <xsl:apply-templates mode="preserve"/>
    </xsl:copy>
	</xsl:template>
  
  <xsl:template match="*" mode="preserve">
    <xsl:copy>
      <xsl:copy-of select="@* | namespace::*" />
      <xsl:apply-templates mode="preserve"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[@xml:space='default']" mode="preserve">
    <xsl:copy>
      <xsl:copy-of select="@* | namespace::*" />
      <xsl:apply-templates />
    </xsl:copy>
	</xsl:template>
  
  <xsl:template match="comment() | processing-instruction() | text()" mode="preserve">
    <xsl:copy-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>