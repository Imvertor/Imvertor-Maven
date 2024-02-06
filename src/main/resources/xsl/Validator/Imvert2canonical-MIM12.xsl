<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy" 
    
    expand-text="yes"
    >
    
    <!-- 
       Canonization of MIM 1.2 models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <!--
       Rule: zet mixin tagged value om naar stereotype <<static>>.
    -->
   
    <xsl:variable name="sid">stereotype-name-static-generalization</xsl:variable>
    
    <xsl:template match="imvert:class/imvert:supertype">
        <imvert:supertype>
            <xsl:apply-templates/>
            <xsl:if test="imf:get-tagged-value(.,'##CFG-TV-MIXIN') = 'Ja'">
                <imvert:stereotype id="{$sid}">{imf:get-config-name-by-id($sid)}</imvert:stereotype>
            </xsl:if>
        </imvert:supertype>
    </xsl:template>
   
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>  
    
</xsl:stylesheet>
