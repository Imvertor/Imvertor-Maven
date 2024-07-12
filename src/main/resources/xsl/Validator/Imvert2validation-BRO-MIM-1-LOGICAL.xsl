<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    >
    
    <!-- 
        Validation of BRO logical models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages" priority="1">
        <imvert:report>
            <xsl:next-match/>
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="*[self::imvert:class or self::imvert:attribute or self::imvert:association or self::imvert:target][imvert:stereotype/@id = (
        'stereotype-name-objecttype',
        'stereotype-name-codelist',
        'stereotype-name-enumeration',
        'stereotype-name-complextype',
        'stereotype-name-simpletype',
        'stereotype-name-attribute',
        'stereotype-name-relatiesoort',
        'stereotype-name-relation-role'
        )]" priority="1">
        
        <xsl:sequence select="imf:report-warning(., 
            empty(imvert:alias), 
            'No alias specified for [1]',imf:string-group(imf:get-config-stereotypes(imvert:stereotype/@id)))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
