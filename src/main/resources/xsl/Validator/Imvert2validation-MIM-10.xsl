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
    <xsl:variable name="mim-version" select="imf:get-tagged-value($application-package,'##CFG-TV-MIMVERSION')"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
    
            <xsl:sequence select="imf:set-xparm('appinfo/mim-model-version',$mim-version)"/>
            
            <!-- 
                test of MIM versie overeen komt met verwachte MIM versie 
                https://github.com/Imvertor/Imvertor-Maven/issues/461 
            -->
            <xsl:variable name="compliancy-version" select="imf:get-xparm('system/mim-compliancy-version')"/>
            <xsl:variable name="model-version" select="imf:get-xparm('appinfo/mim-model-version')"/>
            
            <xsl:sequence select="imf:report-warning(., 
                not($model-version), 
                'MIM version not specified',())"/>
            
            <xsl:sequence select="imf:report-warning(., 
                $model-version and not($mim-version and starts-with($model-version,$compliancy-version)), 
                'MIM version [1] does not match the configured version [2]',($model-version,$compliancy-version))"/>
            
            <!-- process the application package -->
            <xsl:apply-templates select="$application-package"/>
            
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
    <!-- no additional validations -->    
    
</xsl:stylesheet>
