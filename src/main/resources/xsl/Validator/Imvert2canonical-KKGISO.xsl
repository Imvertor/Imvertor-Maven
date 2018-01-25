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
       Canonization of KKG ISO models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <?x
    <!-- in KKG ISO, stereotype on associations are implied --> 
    <xsl:template match="imvert:association">
        
        <xsl:variable name="target-class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:variable name="target-is-objecttype" select="$target-class/imvert:stereotype/@id = ('stereotype-name-objecttype')"/>
        
        <imvert:association>
            <xsl:choose>
                <xsl:when test="$target-is-objecttype and empty(imvert:name)">
                    <imvert:name origin="system">
                        <xsl:value-of select="imf:get-normalized-name(imvert:type-name,'property-name')"/>
                    </imvert:name>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:name"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--x
            <xsl:if test="$target-is-objecttype and not(imvert:stereotype/@id = 'stereotype-name-relatiesoort')">
                <imvert:stereotype origin="system" id="stereotype-name-relatiesoort">
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-relatiesoort')"/>
                </imvert:stereotype>
            </xsl:if>
            x-->
            <xsl:apply-templates select="*[not(self::imvert:name)]"/>
        </imvert:association>
    </xsl:template>
    x?>
    
    <xsl:template match="imvert:stereotype[. = 'ENUMERATION' and $language = 'nl']">
        <!-- EA inserted stereotype ENUMERATION removed -->
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
