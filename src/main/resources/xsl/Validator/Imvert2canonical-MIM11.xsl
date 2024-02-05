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
    >
    
    <!-- 
       Canonization of MIM 1.1 models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="att-stereos" select="
        (
        imf:get-config-name-by-id('stereotype-name-union-element'),
        imf:get-config-name-by-id('stereotype-name-attribute')
        )"/>
    
    <xsl:template match="imvert:class/imvert:stereotype[@id = 'stereotype-name-union']">
        <xsl:variable name="attributes" select="../imvert:attributes/imvert:attribute"/>
        
        <xsl:sequence select="."/>
        
        <xsl:variable name="firstatt-stereo" select="$attributes[1]/imvert:stereotype"/>
        <xsl:choose>
            <xsl:when test="$firstatt-stereo/@id = 'stereotype-name-union-element'">
                <!-- dit heeft de naam <<datatype>> -->
                <imvert:stereotype id="stereotype-name-union-datatypes" origin="system">{imf:get-config-name-by-id('stereotype-name-union-datatypes')}</imvert:stereotype>
            </xsl:when>
            <xsl:when test="$firstatt-stereo/@id = ('stereotype-name-attribute','stereotype-name-attributegroup')">
                <!-- dit heeft de naam <<attribuutsoort>> / <<gegevensgroep>> -->
                <imvert:stereotype id="stereotype-name-union-attributes" origin="system">{imf:get-config-name-by-id('stereotype-name-union-attributes')}</imvert:stereotype>
            </xsl:when>
            <xsl:when test="empty($attributes)">
                <!-- er zijn geen attributen; neem aan dat het een keuze tussen associaties betreft -->
                <imvert:stereotype id="stereotype-name-union-associations" origin="system">{imf:get-config-name-by-id('stereotype-name-union-associations')}</imvert:stereotype>
            </xsl:when>
            <xsl:when test="empty($firstatt-stereo)">
                <!-- attributen hebben geen stereotype -->
                <xsl:sequence select="imf:report-error(..,true(),'Attributes in a union must be stereotyped as one of [1]',imf:string-group($att-stereos))"/>
            </xsl:when>
            <xsl:when test="$firstatt-stereo/@id = ('stereotype-name-union-element-DEPRECATED')">
                <!-- dit heeft de naam <<keuze element>>; dat wordt voorlopig omgezet. -->
                <imvert:stereotype id="stereotype-name-union-datatypes" origin="system">{imf:get-config-name-by-id('stereotype-name-union-datatypes')}</imvert:stereotype>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-error(..,true(),'Cannot recognize type of choice. Stereotype of first attribute is [1]',imf:get-config-name-by-id($firstatt-stereo/@id))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- keuze attribute heeft oude stereotype "keuze element", omzetten met waarschuwing -->
    <xsl:template match="imvert:attribute/imvert:stereotype[@id = 'stereotype-name-union-element-DEPRECATED']">
        <xsl:sequence select="imf:report-warning(..,true(),'Attribute stereotype is deprecated: [1]',imf:get-config-name-by-id('stereotype-name-union-element-DEPRECATED'))"/>
        <xsl:sequence select="."/>
        
        <!-- voeg het juiste stereotype toe als deze niet al is opgegeven -->
        <xsl:if test="not(../imvert:stereotype/@id = 'stereotype-name-union-element')">
            <imvert:stereotype id="stereotype-name-union-element" origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-union-element')"/>
            </imvert:stereotype>
        </xsl:if>
    </xsl:template>
    
    <!-- keuze attribute heeft geen betekenis, use case 2 -->
    <xsl:template match="imvert:attribute/imvert:stereotype[@id = 'stereotype-name-union']">
        <xsl:sequence select="."/>
        <!-- voeg intern stereotype type -->
        <imvert:stereotype id="stereotype-name-union-for-attributes" origin="system">
            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-union-for-attributes')"/>
        </imvert:stereotype>
    </xsl:template>
    
    <!-- keuze attribuut heeft betekenis, use case 3 -->
    <xsl:template match="imvert:attribute/imvert:stereotype[@id = ('stereotype-name-attribute','stereotype-name-attributegroup')]">
        <xsl:variable name="parent-stereo-id" select="ancestor::imvert:class/imvert:stereotype/@id"/>
        <xsl:sequence select="."/>
        <xsl:if test="$parent-stereo-id = 'stereotype-name-union'">
            <imvert:stereotype id="stereotype-name-union-attribute" origin="system">{imf:get-config-stereotypes('stereotype-name-union-attribute')}</imvert:stereotype>
        </xsl:if>
    </xsl:template>
    
    <!-- de relatie heeft stereotype "keuze" -->
    <xsl:template name="association-with-union" match="imvert:association[imvert:stereotype/@id = 'stereotype-name-union']">
        <xsl:copy>
            <xsl:apply-templates select="*[empty(self::imvert:stereotype)]"/>
            <xsl:sequence select="imvert:stereotype"/>
            <imvert:stereotype id="stereotype-name-union-association" origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-union-association')"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <!-- Relatie en Rol vervangen als waarde van informatiemodelleringstype door correcte waarden. --> 
    <xsl:template match="/imvert:packages/imvert:package/imvert:tagged-values/imvert:tagged-value[@id = 'CFG-TV-IMRELATIONMODELINGTYPE']/imvert:value[. = ('Relatie','Rol')]">
        <xsl:sequence select="imf:report-warning(..,true(),'Tagged value is deprecated: [1]',.)"/>
        <imvert:value>{if (. = 'Relatie') then 'Relatiesoort leidend' else 'Relatierol leidend'}</imvert:value>
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
