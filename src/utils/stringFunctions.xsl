<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
   version="1.0"
   xml:lang="en"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
   <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" />
   
  <!-- 
  String manipulation named templates:
  
  * capitalizeFirstLetter(string as string) as string
  
  -->
  
	<xsl:template name="capitalizeFirstLetter">
    <xsl:param name="string" />
    <xsl:variable name="lowerAlphabet" select="'aäàâbcdeëéèêfghiïîjklmnoöôpqrstuüùûvwxyz'" />
    <xsl:variable name="upperAlphabet" select="'AAAABCDEEEEEFGHIIIJKLMNOOOPQRSTUUUUVWXYZ'" />
    
    <xsl:variable name="firstLetter" select="substring($string,1,1)" />
    <xsl:variable name="followingLetters" select="substring-after($string,$firstLetter)" />
    <xsl:variable name="capitalFirstLetter" select="translate($firstLetter,$lowerAlphabet,$upperAlphabet)" />
    
    <xsl:value-of select="concat($capitalFirstLetter,$followingLetters)" />
  </xsl:template>
  
</xsl:stylesheet>