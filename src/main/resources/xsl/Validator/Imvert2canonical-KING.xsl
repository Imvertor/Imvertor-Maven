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
          Transform KING UML constructs to canonical UML constructs.
          This canonization stylesheet is imported by sopecific UGM or SIM stylesheets.
    -->
    
    <xsl:import href="Imvert2canonical-KING-common.xsl"/>
     
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- Rule: remove all empty packages where applicable. --> 
    <xsl:template match="imvert:package[empty(imvert:stereotype)]">
        <xsl:variable name="parent-package" select=".."/>
        <xsl:choose>
            <!-- skip some types of empty packages -->
            <xsl:when test="$parent-package/imvert:stereotype/@id = ('stereotype-name-base-package')"/>
            <xsl:when test="$parent-package/imvert:stereotype/@id = ('stereotype-name-application-package')"/>
            <xsl:when test="$parent-package/imvert:stereotype/@id = ('stereotype-name-project-package')"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- REDMINE #487818 -->
    <xsl:template match="imvert:supplier-package-name">
        <imvert:supplier-package-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:supplier-package-name>
    </xsl:template>
    
    <!-- assume any datatype to be steroetyped as datatype, when no stereotype is provided. -->
    <xsl:template match="imvert:class[imvert:designation = 'datatype' and empty(imvert:stereotype)]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <imvert:stereotype origin="canon" id="stereotype-name-simpletype">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-simpletype')"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO match phases to defined phases -->
    <xsl:template match="imvert:phase">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="original" select="."/>
            <xsl:choose>
                <xsl:when test=".='Goedgekeurd'">2</xsl:when> <!--TODO moet 3 zijn --> 
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value[imvert:name = imf:get-normalized-name('Indicatie formele historie','tv-name')]/imvert:value">
        <imvert:value>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="
                if (. = 'n.v.t.') then 'N.v.t.' else if (. = 'zie groep') then 'Zie groep' else .
            "/>
        </imvert:value>
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value[imvert:name = imf:get-normalized-name('Indicatie materiële historie','tv-name')]/imvert:value">
        <imvert:value>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="
                if (. = 'n.v.t.') then 'N.v.t.' else if (. = 'zie groep') then 'Zie groep' else .
            "/>
        </imvert:value>
    </xsl:template>
    
    
    
</xsl:stylesheet>
