<?xml version="1.0" encoding="ISO-8859-1"?>
<gxslt:stylesheet xmlns:gxslt="http://www.w3.org/1999/XSL/Transform" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isob4j="http://eric.brechemier.name/2004/bin4java/isoXml" xmlns:stack="http://eric.brechemier.name/2004/bin4java/stacks" xmlns:gmr="http://www.example.com/Guess_Me_Right" version="1.0" xml:lang="en" exclude-result-prefixes="gmr" gmr:namespaceDeclarationForInput="ignore">
   <gxslt:output method="xml" indent="yes" encoding="ISO-8859-1"/>
   <gxslt:template match="/">
      <isob4j:document>
         <gxslt:apply-templates/>
      </isob4j:document>
   </gxslt:template>
   <gxslt:template match="gmr:quizz">
      <isob4j:element description="quizz">
         <isob4j:mask>
            <gxslt:attribute name="bit1">
               <gxslt:call-template name="bitIsPresent">
                  <gxslt:with-param name="node" select="@topic"/>
               </gxslt:call-template>
            </gxslt:attribute>
            <gxslt:attribute name="bit1Description">is topic present</gxslt:attribute>
         </isob4j:mask>
         <gxslt:if test="@topic">
            <isob4j:string>
               <gxslt:attribute name="description">topic</gxslt:attribute>
               <gxslt:value-of select="@topic"/>
            </isob4j:string>
         </gxslt:if>
         <isob4j:short description="questions count">
            <gxslt:value-of select="count(gmr:questions)"/>
         </isob4j:short>
         <isob4j:short description="result count">
            <gxslt:value-of select="count(gmr:result)"/>
         </isob4j:short>
         <gxslt:apply-templates/>
      </isob4j:element>
   </gxslt:template>
   <gxslt:template match="gmr:questions">
      <isob4j:element description="questions">
         <isob4j:short description="question count">
            <gxslt:value-of select="count(gmr:question)"/>
         </isob4j:short>
         <gxslt:apply-templates/>
      </isob4j:element>
   </gxslt:template>
   <gxslt:template match="gmr:result">
      <isob4j:element description="result">
         <isob4j:short description="category count">
            <gxslt:value-of select="count(gmr:category)"/>
         </isob4j:short>
         <gxslt:apply-templates/>
      </isob4j:element>
   </gxslt:template>
   <gxslt:template match="gmr:question">
      <isob4j:element description="question">
         <isob4j:mask>
            <gxslt:attribute name="bit1">
               <gxslt:call-template name="bitIsPresent">
                  <gxslt:with-param name="node" select="@title"/>
               </gxslt:call-template>
            </gxslt:attribute>
            <gxslt:attribute name="bit1Description">is title present</gxslt:attribute>
         </isob4j:mask>
         <gxslt:if test="@title">
            <isob4j:string>
               <gxslt:attribute name="description">title</gxslt:attribute>
               <gxslt:value-of select="@title"/>
            </isob4j:string>
         </gxslt:if>
         <isob4j:short description="text count">
            <gxslt:value-of select="count(gmr:text)"/>
         </isob4j:short>
         <isob4j:short description="answer count">
            <gxslt:value-of select="count(gmr:answer)"/>
         </isob4j:short>
         <gxslt:apply-templates/>
      </isob4j:element>
   </gxslt:template>
   <gxslt:template match="gmr:text">
      <isob4j:element description="text">
         <isob4j:string>
            <gxslt:attribute name="description">text value</gxslt:attribute>
            <gxslt:value-of select="."/>
         </isob4j:string>
      </isob4j:element>
   </gxslt:template>
   <gxslt:template match="gmr:answer">
      <isob4j:element description="answer">
         <isob4j:mask>
            <gxslt:attribute name="bit1">
               <gxslt:call-template name="bitIsPresent">
                  <gxslt:with-param name="node" select="@category"/>
               </gxslt:call-template>
            </gxslt:attribute>
            <gxslt:attribute name="bit1Description">is category present</gxslt:attribute>
         </isob4j:mask>
         <gxslt:if test="@category">
            <isob4j:string>
               <gxslt:attribute name="description">category</gxslt:attribute>
               <gxslt:value-of select="@category"/>
            </isob4j:string>
         </gxslt:if>
         <isob4j:string>
            <gxslt:attribute name="description">text value</gxslt:attribute>
            <gxslt:value-of select="."/>
         </isob4j:string>
      </isob4j:element>
   </gxslt:template>
   <gxslt:template match="gmr:category">
      <isob4j:element description="category">
         <isob4j:mask>
            <gxslt:attribute name="bit1">
               <gxslt:call-template name="bitIsPresent">
                  <gxslt:with-param name="node" select="@name"/>
               </gxslt:call-template>
            </gxslt:attribute>
            <gxslt:attribute name="bit1Description">is name present</gxslt:attribute>
         </isob4j:mask>
         <gxslt:if test="@name">
            <isob4j:string>
               <gxslt:attribute name="description">name</gxslt:attribute>
               <gxslt:value-of select="@name"/>
            </isob4j:string>
         </gxslt:if>
         <isob4j:string>
            <gxslt:attribute name="description">text value</gxslt:attribute>
            <gxslt:value-of select="."/>
         </isob4j:string>
      </isob4j:element>
   </gxslt:template>
   <gxslt:template name="bitIsPresent">
      <gxslt:param name="node"/>
      <gxslt:choose>
         <gxslt:when test="$node">
            <gxslt:value-of select="'1'"/>
         </gxslt:when>
         <gxslt:otherwise>
            <gxslt:value-of select="'0'"/>
         </gxslt:otherwise>
      </gxslt:choose>
   </gxslt:template>
   <gxslt:template match="text()"/>
</gxslt:stylesheet>