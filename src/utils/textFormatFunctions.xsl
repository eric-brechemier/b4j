<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
  <xsl:param name="indentWithUnit" select="'   '"/>
  
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
   
  <!-- 
  Text Formatting named templates:
  
  * indentText(text as string) as string
  * trimText(text as string) as string
  * stripLeadingWhiteSpace(text as string) as string
  * stripTrailingWhiteSpace(text as string) as string
  
  * indent() as string
  * space() as char
  * newLine() as char
  
  -->
  
  <xsl:template name="indentText">
    <xsl:param name="text" />
    <xsl:choose>
      <xsl:when test="contains($text,'&#xA;')">
        <xsl:call-template name="trimText">
          <xsl:with-param name="text" select="substring-before($text,'&#xA;')" />
        </xsl:call-template>
        <xsl:call-template name="newLine" /><xsl:call-template name="indent" />
        <xsl:call-template name="indentText">
          <xsl:with-param name="text" select="substring-after($text,'&#xA;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="trimText">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="trimText">
    <xsl:param name="text" />
    <xsl:call-template name="stripTrailingWhiteSpace">
      <xsl:with-param name="text">
        <xsl:call-template name="stripLeadingWhiteSpace">
          <xsl:with-param name="text" select="$text"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="stripLeadingWhiteSpace">
    <xsl:param name="text" />
    <xsl:choose>
      <xsl:when test="starts-with($text,'&#x20;') or starts-with($text,'&#x9;')
        or starts-with($text,'&#xD;') or starts-with($text,'&#xA;')">
        <xsl:call-template name="stripLeadingWhiteSpace">
          <xsl:with-param name="text">
            <xsl:value-of select="substring($text,2)" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="stripTrailingWhiteSpace">
    <xsl:param name="text" />
    <xsl:variable name="lastCharPos" select="string-length($text)" />
    <xsl:variable name="lastChar" select="substring($text,$lastCharPos,1)" />
    <xsl:choose>
      <xsl:when test="$lastChar='&#x20;' or $lastChar='&#x9;'
        or $lastChar='&#xD;' or $lastChar='&#xA;' ">
        <xsl:variable name="newStringLength" select="string-length($text)-1" />
        <xsl:call-template name="stripTrailingWhiteSpace">
          <xsl:with-param name="text">
            <xsl:value-of select="substring($text,1,$newStringLength)" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="indent">
    <xsl:for-each select="ancestor::*">
      <xsl:value-of select="$indentWithUnit" />
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="space">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template name="newLine">
    <xsl:text>
</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>