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
        Validation of MIM 1.2 models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="application-package" select="//imvert:package[imf:boolean(imvert:is-root-package)]"/>
    <xsl:variable name="mim-version" select="imf:get-tagged-value($application-package,'##CFG-TV-MIMVERSION')"/>
    
    <xsl:template match="/">
        <xsl:sequence select="dlogger:save('$app',$application-package)"></xsl:sequence>
        <xsl:sequence select="dlogger:save('$mim-version',$mim-version)"></xsl:sequence>
        <xsl:next-match/>    
    </xsl:template>
    
    <xsl:template match="imvert:package[imf:member-of(.,$application-package)]" priority="101">
        
        <xsl:sequence select="imf:set-xparm('appinfo/mim-model-version',$mim-version)"/>

        <xsl:sequence select="imf:check-mimversion(.)"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <!--setup-->
        
        <xsl:variable name="supertypes" select="imvert:supertype"/>
        <xsl:variable name="non-mixin-supertypes" select="$supertypes[not(imvert:stereotype/@id = 'stereotype-name-static-generalization')]"/>
        
        <!--validation-->
       
        <xsl:sequence select="imf:report-error(., 
            $non-mixin-supertypes[2], 
            'Several supertypes [1] are referenced as non-mixin supertype', imf:string-group(for $s in $non-mixin-supertypes/imvert:type-name/@original return $s))"/>
        
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
    <!-- 
        test of MIM versie overeen komt met verwachte MIM versie 
        https://github.com/Imvertor/Imvertor-Maven/issues/461 
    -->
    <xsl:function name="imf:check-mimversion">
        <xsl:param name="this"/>
        <xsl:variable name="compliancy-version" select="imf:get-xparm('system/mim-compliancy-version')"/>
        <xsl:variable name="model-version" select="imf:get-xparm('appinfo/mim-model-version')"/>
        <xsl:sequence select="imf:report-warning($this, 
            not($mim-version and starts-with($model-version,$compliancy-version)), 
            'MIM version [1] does not match the configured version [2]',($model-version,$compliancy-version))"/>
    </xsl:function>
    
</xsl:stylesheet>
