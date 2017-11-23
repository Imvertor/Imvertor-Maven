<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:template match="ep:message-sets">
        
        <!-- vind de koppelvlak namespace: -->      
        <xsl:variable name="kvnamespace" select="ep:message-set[@KV-namespace = 'yes']/@prefix"></xsl:variable>
        
        
        <!-- header-->
        <xsl:text>openapi: 3.0.0
info:
    version: "3.0"
    title: 'xml2json'
    description: 'xml2json'</xsl:text>
        
        <!--paths MOETEN IN APARTE FILE (geen json)   -->
        <xsl:text>&#xa;paths:</xsl:text>
        
        
        <xsl:for-each select="ep:message-set/ep:message[@messagetype = 'request']">
            <xsl:variable name="servicename" select="@servicename"/>
            <xsl:if test="exists(/ep:message-sets/ep:message-set/ep:message[@servicename = $servicename][@messagetype = 'response'])">
            <xsl:text>&#xa; </xsl:text><xsl:value-of select="concat('/',$kvnamespace,'/',ep:tech-name,':')"/>
            <xsl:text>&#xa;  post:
   tags:
    - </xsl:text><xsl:value-of select="$kvnamespace"/>
                <xsl:text>   
   summary: ''
   operationId: </xsl:text><xsl:value-of select="concat($kvnamespace, '_', ep:tech-name)"/>
            <xsl:text>&#xa;   requestBody: 
        description: OK
        required: true
        content:
         application/json:
          schema:
           $ref: '#/components/schemas/</xsl:text><xsl:value-of select="substring-after(ep:seq/ep:construct[not(@ismetadata)][@prefix='bsmr'][starts-with(ep:type-name, 'bsmr:') or starts-with(ep:type-name, 'bg:')][1]/ep:type-name, ':')"/><xsl:text>'</xsl:text>
            <xsl:text>
   responses:
    200:
     description: OK
     content:
      application/json:
       schema:
        items:
       </xsl:text>
            <xsl:for-each select="../ep:message[@messagetype = 'response'][@servicename=$servicename]">
                <xsl:text>  $ref: '#/components/schemas/</xsl:text><xsl:value-of select="substring-after(ep:seq/ep:construct[not(@ismetadata)][@prefix='bsmr'][starts-with(ep:type-name, 'bsmr:')][1]/ep:type-name, ':')"/><xsl:text>'</xsl:text>
            </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
        
        
    </xsl:template>
</xsl:stylesheet>