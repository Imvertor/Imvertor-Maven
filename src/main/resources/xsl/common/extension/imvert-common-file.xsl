<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert="http://www.imvertor.org/xsl/functions"
    
    version="3.0">
    
    
    <xsl:function name="imf:decodeBase64" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="ext:imvertorBase64Decode($string)"/>
    </xsl:function>
    
    <xsl:function name="imf:encodeBase64" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="ext:imvertorBase64Encode($string)"/>
    </xsl:function>
    
</xsl:stylesheet>