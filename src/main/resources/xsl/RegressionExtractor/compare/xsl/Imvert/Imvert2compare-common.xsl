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
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:param name="debug"/>

    <xsl:param name="info-version"/>
    <xsl:param name="info-ctrlpath"/>
    <xsl:param name="info-testpath"/>
    <xsl:param name="info-config"/>
    
    <xsl:param name="work-folder-uri"/>
    
    <xsl:param name="diff-filepath"/>
    <xsl:param name="ctrl-filepath"/>
    <xsl:param name="test-filepath"/>
   
    <xsl:param name="ctrl-name-mapping-filepath"/>
    <xsl:param name="test-name-mapping-filepath"/>
    
    <xsl:param name="identify-construct-by-function"/> <!-- implemented: name, id -->
    <xsl:param name="comparison-role"/> <!-- ctrl or test -->
    <xsl:param name="include-reference-packages"/> <!-- true or false -->
   
    <xsl:param name="compare-label"/>
    
    <xsl:variable name="imvert-compare-config-doc" select="document($info-config)"/>
    <xsl:key name="imvert-compare-config" match="elm" use="@form"/>    
    
    <xsl:variable name="imvert-compare-mode" select="
        if ($compare-label = 'derivation') then 'V' else 
        if ($compare-label = 'release') then 'R' else 
        if ($compare-label = 'documentation') then 'D' else 
        'I'"/>
    
    <xsl:variable name="sep">-</xsl:variable>
    
    <xsl:function name="imf:debug" as="xs:boolean?">
        <xsl:param name="txt"/>
        <xsl:if test="$debug = 'true'">
            <xsl:message select="concat('DEBUG ', $txt)"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>