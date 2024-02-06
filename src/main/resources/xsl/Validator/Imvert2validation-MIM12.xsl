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
    
    <xsl:template match="imvert:class">
        <!--setup-->
        
        <xsl:variable name="supertypes" select="imvert:supertype"/>
        <xsl:variable name="non-mixin-supertypes" select="$supertypes[not(imvert:stereotype/@id = 'stereotype-name-static-generalization')]"/>
        
        <!--validation-->
       
        <xsl:sequence select="dlogger:save('$non-mixin-supertypes',$non-mixin-supertypes)"/>  
        <xsl:sequence select="imf:report-error(., 
            $non-mixin-supertypes[2], 
            'Several supertypes [1] are referenced as non-mixin supertype', imf:string-group(for $s in $non-mixin-supertypes/imvert:type-name/@original return $s))"/>
        
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
