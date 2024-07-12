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
    
    exclude-result-prefixes="#all"
    expand-text="yes"
    >
    
    <!-- 
       Canonization of Kadaster models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:import href="Imvert2canonical-KadasterMIMFORMAT.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:variable name="result-app" as="element(imvert:packages)">
            <imvert:packages>
                <xsl:sequence select="imf:compile-imvert-header(.)"/>
                <xsl:apply-templates select="imvert:package"/>
            </imvert:packages>
        </xsl:variable>
        <!-- introduceer aparte canonisering wanneer UML van specifiek type is. -->
        <xsl:choose>
            <xsl:when test="$result-app/imvert:application = 'MIMFORMAT'"><!-- UMLMETA type tbv. MIMFORMAT -->
                <xsl:apply-templates select="$result-app" mode="mimformat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$result-app"/>
            </xsl:otherwise>
        </xsl:choose>
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
    
    <?remove see #GH-254    
    <!-- 
        Union en union element moet nu expliciet worden doorgegeven als specifiek stereotype.
        Keuze tussen datatypen is enige keuze die CDMKAD modellen kennen.
    -->
    <xsl:template match="imvert:class/imvert:stereotype[@id = 'stereotype-name-union']">
        <xsl:variable name="attributes" select="../imvert:attributes/imvert:attribute"/>
        <xsl:sequence select="."/>
        <imvert:stereotype id="stereotype-name-union-datatypes" origin="system">{imf:get-config-name-by-id('stereotype-name-union-datatypes')}</imvert:stereotype>
    </xsl:template>
    remove?>
      
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>  
</xsl:stylesheet>
