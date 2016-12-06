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
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 

    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Create a representation of the imvert document but only 
         maintain info that is needed for clients, accessing supplier-info.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="stylesheet-code">SPP</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:template match="imvert:packages | imvert:package | imvert:class | imvert:attribute | imvert:association">
        <xsl:copy>
          
            <xsl:copy-of select="@*"/>
          
            <!--
            <xsl:copy-of select="@formal-name"/>
            
            <xsl:sequence select="imvert:id"/>
            <xsl:sequence select="imvert:documentation"/>
            <xsl:sequence select="type-name"/>
            <xsl:sequence select="max-length"/>
            <xsl:sequence select="min-occurs"/>
            <xsl:sequence select="max-occurs"/>
            <xsl:sequence select="imvert:tagged-values"/>
            -->
            
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
</xsl:stylesheet>
