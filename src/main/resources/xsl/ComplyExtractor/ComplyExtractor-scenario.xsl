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
      Create the scenario file. 
    -->    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:param name="generation-mode">final</xsl:param>
    
    <xsl:variable name="tests-path" select="imf:get-config-string('properties',if ($generation-mode = 'final') then 'WORK_COMPLY_MAKE_FOLDER_FINAL' else 'WORK_COMPLY_MAKE_FOLDER_VALID')"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="/testset/import-messages"/>
    </xsl:template>
    
    <xsl:template match="import-messages">
        <xsl:sequence select="imf:pretty-print(.,false())"/>
        
        <!-- add tests -->
        <xsl:for-each select="message">
            <xsl:variable name="content" select="content"/>
            <xsl:if test="empty(scenario)">
                <xsl:sequence select="imf:msg(.,'ERROR','Message scenario is missing',())"/>
            </xsl:if>         
            <xsl:if test="empty(step)">
                <xsl:sequence select="imf:msg(.,'ERROR','Message step is missing',())"/>
            </xsl:if>         
            <xsl:if test="empty(content)">
                <xsl:sequence select="imf:msg(.,'ERROR','Message content is missing',())"/>
            </xsl:if>         
            <xsl:if test="empty(/testset/groups[1]/group[concat(@label,'.xml') = $content])">
                <xsl:sequence select="imf:msg(.,'ERROR','Scenario references a message that is not defined: [1]',$content)"/>
            </xsl:if>         
        </xsl:for-each>
        
    </xsl:template>
          
</xsl:stylesheet>
