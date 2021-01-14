<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  xmlns:dlogger-impl="http://www.armatiek.nl/functions/dlogger"
  xmlns:dlogger-proxy="http://www.armatiek.nl/functions/dlogger-proxy"
  exclude-result-prefixes="#all"
  
  version="3.0"
  expand-text="yes">
  
  <xsl:variable name="dlogger-active" select="system-property('dlogger') = 'true'" static="true" as="xs:boolean"/>
  <xsl:include href="../../../static/xsl/dlogger/DLogger.xsl" use-when="$dlogger-active"/>
  
  <xsl:function name="dlogger-proxy:init" as="empty-sequence()">
    <xsl:sequence use-when="$dlogger-active">
      <xsl:choose>
        <xsl:when test="$dlogger-impl:dlogger-mode">
          <xsl:sequence  select="imf:msg('INFO','DLogger active as [1]',($dlogger-impl:dlogger-client))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence  select="imf:msg('INFO','DLogger active (but idle)')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:sequence select="dlogger-impl:init()"/>
    </xsl:sequence>
  </xsl:function> 
  
  <xsl:function name="dlogger-proxy:init" as="empty-sequence()">
    <xsl:param name="clear" as="xs:boolean"/>
    <xsl:sequence select="dlogger-impl:init($clear)" use-when="$dlogger-active"/>
  </xsl:function>
  
  <xsl:function name="dlogger-proxy:save" as="empty-sequence()">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="contents" as="item()*"/>
    <xsl:sequence select="dlogger-impl:save($label, $contents)" use-when="$dlogger-active"/> 
  </xsl:function>
  
  <xsl:function name="dlogger-proxy:save" as="empty-sequence()" use-when="$dlogger-active">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="contents" as="item()*"/>
    <xsl:param name="type" as="xs:string?"/>
    <xsl:sequence select="dlogger-impl:save($label, $contents, $type)" use-when="$dlogger-active"/> 
  </xsl:function>
  
  <xsl:function name="dlogger-proxy:comment" as="comment()?">
    <xsl:param name="label" as="xs:string"/>
    <xsl:sequence select="dlogger-impl:comment($label)" use-when="$dlogger-active"/>
  </xsl:function>  
  
</xsl:stylesheet>