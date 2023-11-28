<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="3.0"
    
    >

    <!-- 
        Validation of MIM 1.1.1 models. 
    -->
    
    <xsl:import href="Imvert2validation-MIM11.xsl"/>
    
    <!-- ik neem aan dat constraints alleen mogen voorkomen op 3 benoemde modelelementen -->
    
    <xsl:template match="imvert:constraint">
    
        <xsl:variable name="parent-stereotypes" select="../../imvert:stereotype"/>
        
        <?x zie https://github.com/Geonovum/MIM-Werkomgeving/issues/317
            
        <xsl:sequence select="imf:report-error(., 
            not($parent-stereotypes/@id = ('stereotype-name-objecttype','stereotype-name-composite','stereotype-name-relatieklasse')), 
            'Constraint must not appear here', ())"/>
            
        x?>
        <xsl:next-match/>
        
    </xsl:template>

    <!-- 
        Json BP validaties 
    -->
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype','stereotype-name-relatieklasse','stereotype-name-koppelklasse')]">
        
        <xsl:variable name="tv-primary-interval" select="for $a in (imvert:attributes/imvert:attribute) return imf:get-tagged-value($a,'##CFG-TV-PRIMARYINTERVAL')"/>
        
        <xsl:sequence select="imf:report-error(., 
            count($tv-primary-interval) gt 2, 
            'Too many tagged values[1] on this [2]', 
            (imf:get-config-name-by-id('CFG-TV-PRIMARYINTERVAL'),imf:get-config-name-by-id(imvert:stereotype/@id)))"/>
        
        <xsl:sequence select="imf:report-error(., 
            count($tv-primary-interval) eq 2 and not($tv-primary-interval = 'start' and $tv-primary-interval = 'end'), 
            'Tagged value [1] on attributes may only be combined by values [2] and [3]', 
            (imf:get-config-name-by-id('CFG-TV-PRIMARYINTERVAL'),'start','end'))"/>
        
        <xsl:sequence select="imf:report-error(., 
            count($tv-primary-interval) eq 1 and not($tv-primary-interval = 'interval'), 
            'Tagged value [1] on attribute has unexpected value. Use [2], [3] or [4] in a valid combination of attributes', 
            (imf:get-config-name-by-id('CFG-TV-PRIMARYINTERVAL'),'interval','start','end'))"/>
        
        <xsl:next-match/>
        
    </xsl:template>
    
</xsl:stylesheet>
