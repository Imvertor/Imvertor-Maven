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
    exclude-result-prefixes="#all"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"

    version="2.0">

    <!-- 
        process the XML report on all generated schemas and flatten each schema:
        remove namespaces and resolve imports 
    -->
    
    <xsl:include href="../common/Imvert-common.xsl"/>
    <xsl:include href="extension/extension-variable.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
        
    <xsl:template match="/">
        <xsl:apply-templates select="*"/>       
    </xsl:template>
   
    <xsl:template match="xs:schema" mode="root">
        <xs:schema>
            <xsl:apply-templates select="@*"/>
            <xs:annotation>
                <xsl:sequence select="xs:annotation/xs:appinfo"/>
                <xs:appinfo source="http://www.imvertor.org/schema-info/mode">flat</xs:appinfo>
            </xs:annotation>
            <xsl:apply-templates select="*"/>
        </xs:schema>
    </xsl:template>
    
    <xsl:template match="xs:annotation">
        <!-- skip, processed elsewhere -->
    </xsl:template>
    
    <xsl:template match="xs:complexType[@name = 'components' or ends-with(@name,'Components')]">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="xs:element[@name = 'components' or ends-with(@name,'Components')]">
        <!-- remove -->
    </xsl:template>
    
    <?x
    <xsl:template match="xs:element/@ref | xs:element/@type | xs:extension/@base">
        <xsl:variable name="ns" select="substring-before(.,':')"/>
        <xsl:variable name="val" select="substring-after(.,':')"/>
        <xsl:choose>
            <xsl:when test="$ns = ('xs','xlink')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{name(.)}" select="if ($val = '') then . else $val"/>
            </xsl:otherwise>    
        </xsl:choose>
    </xsl:template>
    x?>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
