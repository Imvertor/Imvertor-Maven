<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ext="http://www.imvertor.org/xsl/extensions"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  
  >
 
  <xsl:import href="../common/Imvert-common.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="imf:get-config-string('cli','transinfo') = '1'">
        <xsl:value-of select="/Archief/OpvoerDocument/DocumentInhoud"/>
      </xsl:when>
      <xsl:when test="imf:get-config-string('cli','transinfo') = '2'">
        <xsl:for-each select="/*/*:lokaalMeetstelsel"><!-- singleton-->
          <xsl:variable name="naam" select="*:naam"/>
          <xsl:variable name="veldwerk" select="*:veldwerk[1]"/>
          <xsl:variable name="kadGemCode" select="*:veldwerk[1]/@kadGemCode"/>
          <xsl:variable name="sectie" select="*:veldwerk[1]/@sectie"/>
          <xsl:for-each select="*:terreinPunt">
            <xsl:variable name="result">
              <xsl:value-of select="imf:cell($naam)"/>
              <xsl:value-of select="imf:cell(*:classificatieCode)"/>
              <xsl:value-of select="imf:cell(xs:integer(substring-before(*:Point/*:coordinates,',')) div 1000)"/>
              <xsl:value-of select="imf:cell(xs:integer(substring-after(*:Point/*:coordinates,',')) div 1000)"/>
              <xsl:value-of select="imf:cell(*:puntNummer)"/>
              <xsl:value-of select="imf:cell($veldwerk)"/>
              <xsl:value-of select="imf:cell($kadGemCode)"/>
              <xsl:value-of select="imf:cell($sectie)"/>
            </xsl:variable>
            <xsl:value-of select="concat(substring($result,1,string-length($result) - 1),'&#10;')"/>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:function name="imf:cell">
    <xsl:param name="val"/>
    <xsl:value-of select="concat('&quot;',$val,'&quot;,')"/>
  </xsl:function>
  
</xsl:stylesheet>