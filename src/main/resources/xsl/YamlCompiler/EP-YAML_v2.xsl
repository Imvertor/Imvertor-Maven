<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:template match="ep:message-sets">
        
        <!-- header-->
        <xsl:text>  swagger: '2.0
info:
    version: '1'
    title: 'xml2json'
    description: 'xml2json'
host: virtserver.swaggerhub.com
basePath: /King3/xml2json/1
schemes:
-   https</xsl:text>
        
        <!--paths MOETEN IN APARTE FILE (geen json)   -->
        <xsl:text>&#xa;paths:</xsl:text>
        
        
        <xsl:for-each select="ep:message-set/ep:message[@type = 'request']">
            <xsl:variable name="typenumber" select="@typenumber"/>
            <xsl:text>&#xa; </xsl:text><xsl:value-of select="concat('/AAA/',ep:tech-name,':')"/>
            <xsl:text>&#xa;  post:
   tags:
    - AAA
   summary: ''
   operationId: AAA_</xsl:text><xsl:value-of select="ep:tech-name"/>
            <xsl:text>&#xa;   consumes: 
      - application/json
   parameters:
      - in: body
        name: test1
        description: test1 desc.
        schema:
         $ref: '#/definitions/</xsl:text><xsl:value-of select="substring-after(ep:seq/ep:construct[not(@ismetadata)][@prefix='bsmr'][starts-with(ep:type-name, 'bsmr:')][1]/ep:type-name, ':')"/><xsl:text>'</xsl:text>
            <xsl:text>
   responses:
    200:
     description: OK
     schema:
       </xsl:text>
            <xsl:for-each select="../ep:message[@type = 'response'][@typenumber=$typenumber]">
       <xsl:text>$ref: '#/definitions/</xsl:text><xsl:value-of select="substring-after(ep:seq/ep:construct[not(@ismetadata)][@prefix='bsmr'][starts-with(ep:type-name, 'bsmr:')][1]/ep:type-name, ':')"/><xsl:text>'</xsl:text>
            </xsl:for-each>
            </xsl:for-each>
        
        
    </xsl:template>
</xsl:stylesheet>