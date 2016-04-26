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
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Reporting stylesheet for the Apc modifier
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:import href="Imvert2report-quickview.xsl"/>
    <xsl:import href="Imvert2report-compactview.xsl"/>
    <xsl:import href="Imvert2report-typelisting.xsl"/>
    <xsl:import href="Imvert2report-valuelists.xsl"/>
    <xsl:import href="Imvert2report-state.xsl"/>
    <xsl:import href="Imvert2report-documentation.xsl"/>
    <xsl:import href="Imvert2report-identification.xsl"/>
    <xsl:import href="Imvert2report-conceptualschemas.xsl"/>
    <xsl:import href="Imvert2report-taggedvalues.xsl"/>
    <xsl:import href="Imvert2report-trace.xsl"/>
    
    <xsl:template match="/config">
        <xsl:variable name="doc" select="imf:document(imf:get-config-string('properties','WORK_EMBELLISH_FILE'))"/>
        <xsl:variable name="packages" select="$doc/imvert:packages/imvert:package[not(imvert:ref-master)]"/>
        <report>
            <step-display-name>Imvert compiler</step-display-name>
            <summary>
                <info label="User defined constructs">
                    <xsl:sequence select="imf:report-label('Packages', count($packages))"/>
                    <xsl:sequence select="imf:report-label('classes', count($packages/imvert:class))"/>
                </info>
            </summary>
            <xsl:apply-templates select="$doc/imvert:packages" mode="quickview"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="compactview"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="typelisting"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="valuelists"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="state"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="documentation"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="tv"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="identification"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="conceptualschemas"/>
            <xsl:apply-templates select="$doc/imvert:packages" mode="trace"/>
            
        </report>
    </xsl:template>

    
</xsl:stylesheet>
