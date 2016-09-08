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
         Canonization of the input, common to all metamodels.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
   
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation = 'datatype']">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <imvert:stereotype origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-datatype')[1]"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation = 'enumeration']/imvert:attributes/imvert:attribute">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <imvert:stereotype origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-enum')[1]"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove explicit trace relations; traces are recorded as imvert:trace (client to supplier) -->
    <xsl:template match="imvert:association[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-trace')]">
        <!-- remove -->
    </xsl:template>
    
    <!-- 
        IM-445
        remove references to a type ID when no type name could be determined 
        This happens when references occur to parts of the EA that are not in scope
    -->
    <xsl:template match="imvert:type-id[empty(../imvert:type-name)]">
        <imvert:type-id>OUT-OF-SCOPE</imvert:type-id>
        <imvert:type-name>OUT-OF-SCOPE</imvert:type-name>
    </xsl:template>
    
    <!-- 
        IM-457
        Replace the position by the taggd value "position" when supplied; otherwise leave unchanged.
    -->
    <xsl:template match="imvert:position">
        <imvert:position>
            <xsl:variable name="tv-pos" select="../imvert:tagged-values/imvert:tagged-value[imvert:name = imf:get-config-tagged-values('Position')]/imvert:value"/>
            <xsl:value-of select="if (exists($tv-pos)) then string($tv-pos) else ."/>
        </imvert:position>
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
