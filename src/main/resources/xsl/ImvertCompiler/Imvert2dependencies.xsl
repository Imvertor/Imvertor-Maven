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
        </imvert:package-dependencies>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="package-dependencies">
        <imvert:package id="{imvert:id}" name="{imvert:name}" release="{imvert:release}" supplier-project="{imvert:supplier-project}" supplier-name="{imvert:supplier-name}" supplier-release="{imvert:supplier-release}"/>
        <xsl:variable name="supplier-id" select="imvert:used-package-id"/>
        <xsl:if test="$supplier-id">
            <xsl:apply-templates select="$document-packages[imvert:id=$supplier-id]" mode="package-dependencies"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
