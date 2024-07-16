<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    >
    
    <!-- 
        Validation of MIM 1.0 models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>

    <xsl:variable name="application-package" select="/imvert:packages/imvert:package[imf:boolean(imvert:is-root-package)]"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
    
            <!-- 
                test of MIM versie overeen komt met verwachte MIM versie 
                https://github.com/Imvertor/Imvertor-Maven/issues/461 
            -->
            <xsl:variable name="mim-version" select="imf:get-tagged-value($application-package,'##CFG-TV-MIMVERSION')"/><!-- zoals in model opgenomen -->
            <xsl:variable name="configured-version" select="imf:get-xparm('system/mim-configured-version')"/><!-- zoals in de configuratie opgegeven -->
            <xsl:variable name="tv-name" select="imf:get-config-name-by-id('CFG-TV-MIMVERSION')"/>
            
            <xsl:sequence select="imf:report-warning(., 
                not($mim-version), 
                'Tagged value [1] not specified, assuming [2]',($tv-name, $configured-version))"/>
            
            <xsl:sequence select="imf:report-warning(., 
                $mim-version and not(starts-with($mim-version,$configured-version)), 
                'Tag [1] value [2] does not match the configured version [3]',($tv-name, $mim-version, $configured-version))"/>
            
            <!-- process the application package -->
            <xsl:apply-templates select="$application-package"/>
            
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
    <!-- no additional validations -->    
    
</xsl:stylesheet>
