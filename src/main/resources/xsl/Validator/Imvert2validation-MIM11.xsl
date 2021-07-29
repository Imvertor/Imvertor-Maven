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
        Validation of MIM 1.1 models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="application-package" select="//imvert:package[imf:boolean(imvert:is-root-package)]"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
            <!-- process the application package -->
            <xsl:apply-templates select="imvert:package[imf:member-of(.,$application-package)]"/>
        </imvert:report>
    </xsl:template>
      
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-union-for-attributes']">
        <!--setup-->
        <xsl:sequence select="imf:report-error(., 
            (imvert:min-occurs ne '1' or imvert:max-occurs ne '1'), 
            'Attribute with stereotype [1] must have cardinality of 1..1', 'KEUZE')"/>
        <xsl:next-match/>
    </xsl:template>

    <!-- 
        other validation that is required for the immediate XMI translation result. 
    -->
    <xsl:template match="*"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
    <xsl:template match="text()|processing-instruction()"> 
        <!-- nothing -->
    </xsl:template> 
    
</xsl:stylesheet>
