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
    version="2.0">

    <!-- 
        Validation of KKG models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="application-package" select="(//imvert:package[imvert:name/@original=$application-package-name])[1]"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
            <!-- process the application package -->
            <xsl:apply-templates select="imvert:package[.=$application-package]"/>
        </imvert:report>
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
