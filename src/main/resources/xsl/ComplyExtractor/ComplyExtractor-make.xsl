<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 VNG/KING
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
  
    xmlns:ws="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/zip-content-wrapper"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
       Make all XML test files from the extraction result file. 
    -->    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <!-- 
        The mode is test or valid. 
        If valid, insert variable values and save to different location. The test cases will be validated.
    -->
    <xsl:param name="generation-mode">final</xsl:param>
    
    <xsl:variable name="tests-path" select="imf:get-config-string('properties',if ($generation-mode = 'final') then 'WORK_COMPLY_MAKE_FOLDER_FINAL' else 'WORK_COMPLY_MAKE_FOLDER_VALID')"/>
    
    <xsl:template match="/">
        <extraction-result>
            <xsl:apply-templates select="/message-collection/message"/>
        </extraction-result>
    </xsl:template>
    
    <xsl:template match="message">
        <xsl:sequence select="imf:track('Creating message [1]',@file-name)"/>
        <xsl:variable name="file-path" select="imf:file-to-url(concat($tests-path,'/',@file-name,'.xml'))"/>
        <xsl:variable name="doc">
            <xsl:apply-templates select="*"/>
        </xsl:variable>
        <xsl:result-document href="{$file-path}">
            <xsl:sequence select="imf:pretty-print($doc,false())"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="*[processing-instruction('test-value') and $generation-mode = 'valid']">
        <!-- the format is #{referentienummer}<?test-value ruimte12345?> -->
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="processing-instruction('test-value')"/>
        </xsl:copy>
        <xsl:comment>
            <xsl:value-of select="."/>
        </xsl:comment>
    </xsl:template>
 
    <xsl:template match="processing-instruction()|comment()">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="*|text()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*|text()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
