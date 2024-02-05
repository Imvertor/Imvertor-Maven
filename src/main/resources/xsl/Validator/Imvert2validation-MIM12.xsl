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
        Validation of MIM 1.2 models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <!--
        No additional rules
    -->
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
