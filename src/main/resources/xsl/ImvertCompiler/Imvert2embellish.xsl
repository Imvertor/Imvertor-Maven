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
        Insert non-essential information for a simpler processing by reporting and XSD conversion tool. 
        
        Set the imvert:position value to the position specified by tagged value, in accordance with the applicable metamodel. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <imvert:id><xsl:value-of select="$application-package-release-name"/></imvert:id>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="imvert:package">
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:class">
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:supertype">
        <xsl:copy>
            <xsl:variable name="superclass" select="imf:get-construct-by-id(imvert:type-id)"/>
            <xsl:attribute name="display-name" select="imf:get-display-name($superclass)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name($superclass)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:attribute">
        <xsl:variable name="class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            
            <xsl:choose>
                <xsl:when test="imvert:type-id and $class">
                    <xsl:attribute name="type-display-name" select="imf:get-display-name($class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type-display-name" select="imvert:type-name"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="imvert:copy-down-type-id">
                <xsl:variable name="copy-down-class" select="imf:get-construct-by-id(imvert:copy-down-type-id)"/>
                <xsl:attribute name="copy-down-display-name" select="imf:get-construct-name($copy-down-class)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:association">
        <xsl:variable name="class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            <xsl:attribute name="type-display-name" select="imf:get-display-name($class)"/>
            <xsl:attribute name="type-formal-name" select="imf:get-construct-formal-name($class)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:position">
        <!-- get the tagged value that sets the position ans use that value; if no such tagged value, use the current value -->
        <xsl:variable name="position-specified" select="imf:get-tagged-value(..,imf:get-normalized-names('position','tv-name'))"/>
        <xsl:variable name="position-calculated" select="($position-specified,.)[1]"/>
        <xsl:copy>
            <xsl:attribute name="original" select="."/>
            <xsl:value-of select="$position-calculated"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
   
    <xsl:function name="imf:get-tagged-value" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="tv-norm-name" as="xs:string"/>
        <xsl:sequence select="$this/imvert:tagged-values/imvert:tagged-value[imvert:name=$tv-norm-name]/imvert:value"/>
    </xsl:function>

</xsl:stylesheet>
