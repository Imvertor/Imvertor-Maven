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

    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all" 
    expand-text="yes"
    version="3.0">

    <!-- 
       Canonization of MIM models.
    -->
    
    <xsl:import href="Imvert2canonical-MIM10.xsl"/> <!-- for now, use MIM 1.0 -->    
    
    <xsl:template match="imvert:class/imvert:stereotype[@id = 'stereotype-name-union']" priority="1">
        <xsl:variable name="attributes" select="../imvert:attributes/imvert:attribute"/>
        <xsl:variable name="attribute-uses" as="xs:string*">
            <xsl:for-each select="$attributes">
                <xsl:variable name="designation" select="$document-classes[imvert:id = current()/imvert:type-id]/imvert:designation"/>
                <xsl:choose>
                    <xsl:when test="$designation = 'datatype'">D</xsl:when>
                    <xsl:when test="$designation = 'class'">C</xsl:when>
                    <xsl:when test="$designation = 'enumeration'">E</xsl:when>
                    <!-- anders: het betreft wrsch een interface, dus in een outside package. -->
                    <xsl:otherwise>D</xsl:otherwise><!-- TODO moeten we eigenlijk hier oplossen maar we gaan er maar vanuit dat het een datatype betreft -->
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:next-match/>
        <xsl:choose>
            <xsl:when test="$attribute-uses = 'D'">
                <!-- neem aan dat het een keuze tussen datatypen betreft -->
                <imvert:stereotype id="stereotype-name-union-datatypes" origin="system">{.}</imvert:stereotype>
            </xsl:when>
            <xsl:when test="$attribute-uses = ('C','E')">
                <!-- TODO neem aan dat het een keuze tussen attributen betreft (casussen nog nalopen)-->
                <imvert:stereotype id="stereotype-name-union-attributes" origin="system">{.}</imvert:stereotype>
            </xsl:when>
            <xsl:otherwise>
                <!-- neem aan dat het een keuze tussen associaties betreft -->
                <imvert:stereotype id="stereotype-name-union-associations" origin="system">{.}</imvert:stereotype>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- de relatie heeft stereotype "keuze" -->
    <xsl:template name="association-with-union" match="imvert:association[imvert:stereotype/@id = 'stereotype-name-union']" priority="1">
        <xsl:variable name="name" select="'association_' || count(preceding-sibling::imvert:association)"/>
        <xsl:copy>
            <xsl:apply-templates select="*[empty(self::imvert:stereotype) and empty(self::imvert:name)]"/>
            <!-- geef een naam; formeel mag er geen naam zijn -->
            <imvert:name original="{$name}" origin="system">{$name}</imvert:name>
            <xsl:sequence select="imvert:stereotype"/>
            <imvert:stereotype id="stereotype-name-union-association" origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-union-association')"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <!-- de relatie heeft een relatierol met stereotype "keuze" -->
    <xsl:template match="imvert:association[imvert:target/imvert:stereotype/@id = 'stereotype-name-union']" priority="1">
        <xsl:variable name="name" select="'association_' || count(preceding-sibling::imvert:association)"/>
        <xsl:copy>
            <xsl:apply-templates select="*[empty(self::imvert:name)]"/>
            <!-- geef een naam; formeel mag er geen naam zijn -->
            <imvert:name original="{$name}" origin="system">{$name}</imvert:name>
        </xsl:copy>
    </xsl:template>
    
    <!-- associatierol met stereotype name "keuze" --> 
    <xsl:template match="imvert:association/imvert:target[imvert:stereotype/@id = 'stereotype-name-union']" priority="1">
        <xsl:variable name="name" select="'associationrole_' || count(../preceding-sibling::imvert:association)"/>
        <xsl:copy>
            <xsl:apply-templates select="*[empty(self::imvert:stereotype) and empty(self::imvert:role)]"/>
            <imvert:role original="{$name}" origin="system">{$name}</imvert:role>
            <xsl:sequence select="imvert:stereotype"/>
            <imvert:stereotype id="stereotype-name-union-association" origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-union-association')"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
