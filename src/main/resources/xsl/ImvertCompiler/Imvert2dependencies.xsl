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
        Generate a file that lists package dependencies.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:variable name="root-package" select="imf:get-config-stereotypes(('stereotype-name-base-package','stereotype-name-variant-package','stereotype-name-application-package'))"/>
        <imvert:package-dependencies>
         
            <xsl:apply-templates select="$document-packages[imvert:name/@original=$application-package-name and imvert:stereotype=$root-package]" mode="package-dependencies"/>
       
            <xsl:variable name="suppliers" select="imf:analyze-supplier-docs(.)"/>
            <!-- avoid duplicates, several models mat reference the same supplier -->
            <xsl:for-each-group select="$suppliers" group-by="@subpath">
                <imvert:supplier-contents subpath="{current-grouping-key()}">
                    <xsl:sequence select="imf:get-imvert-supplier-doc(current-grouping-key())"/>
                </imvert:supplier-contents>
            </xsl:for-each-group>
            
        </imvert:package-dependencies>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="package-dependencies">
        <imvert:package id="{imvert:id}" name="{imvert:name}" release="{imvert:release}">
            <xsl:for-each select="imvert:supplier">
                <imvert:supplier  supplier-project="{imvert:supplier-project}" supplier-name="{imvert:supplier-name}" supplier-release="{imvert:supplier-release}"/>
            </xsl:for-each>
        </imvert:package>
        <xsl:variable name="supplier-id" select="imvert:used-package-id"/>
        <xsl:if test="$supplier-id">
            <xsl:apply-templates select="$document-packages[imvert:id=$supplier-id]" mode="package-dependencies"/>
        </xsl:if>
    </xsl:template>
    
    <!-- 
        return a list of imvert:supplier-contents elements, for each supplier-of-a-supplier. 
    -->
    <xsl:function name="imf:analyze-supplier-docs" as="element(imvert:supplier-contents)*">
        <xsl:param name="root" as="element(imvert:packages)"/>
        <xsl:for-each select="$root//imvert:supplier[imvert:supplier-project]">
            <xsl:variable name="subpath" select="imf:get-trace-supplier-subpath(imvert:supplier-project,imvert:supplier-name,imvert:supplier-release)"/>
            <xsl:variable name="supplier-doc" select="imf:get-imvert-supplier-doc($subpath)"/>
            <xsl:choose>
                <xsl:when test="exists($supplier-doc)">
                    <imvert:supplier-contents subpath="{$subpath}"/>
                    <xsl:sequence select="imf:analyze-supplier-docs($supplier-doc/imvert:packages)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg(.,'ERROR','Cannot find supplier for subpath [1]',($subpath))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
</xsl:stylesheet>
