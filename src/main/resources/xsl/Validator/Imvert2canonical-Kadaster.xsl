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
          Transform BP UML constructs to canonical UML constructs.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
  
    <xsl:template match="imvert:phase">
        <xsl:variable name="found-value" select="normalize-space(lower-case(.))"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="$found-value='1.0'">1</xsl:when> 
                <xsl:when test="$found-value='concept'">0</xsl:when> 
                <xsl:when test="$found-value='draft'">1</xsl:when> 
                <xsl:when test="$found-value='finaldraft'">2</xsl:when> 
                <xsl:when test="$found-value='final draft'">2</xsl:when> 
                <xsl:when test="$found-value='final'">3</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="imf:compute-phase(.)"/>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        Een service heeft mogelijk 4 envelop-connecties (proces, header, log, product). 
        Daarnaast heeft het een uitgaande relatie naar een <<product>>
    -->
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-service')]/imvert:associations/imvert:association[empty(imvert:name)]">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <imvert:name origin="system">
                <xsl:value-of select="concat('generated-name-',generate-id())"/>
            </imvert:name>
        </xsl:copy>
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
