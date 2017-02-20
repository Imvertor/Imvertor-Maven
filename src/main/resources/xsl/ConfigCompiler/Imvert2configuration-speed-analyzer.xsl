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
    
   
    <xsl:template match="/" mode="speed-analyzer">
        <xsl:variable name="r">
            <xsl:variable name="bulk" as="element(root)">
                <root>
                    <xsl:for-each select="1 to 1">
                        <element original="Indicatie authentiek" normalized="Indicatie authentiek"/>
                    </xsl:for-each>
                </root>
            </xsl:variable>    
            
            <xsl:message select="current-dateTime()"/>
            
            <xsl:apply-templates select="$bulk/element" mode="not-normalized"/>
            
            <xsl:message select="current-dateTime()"/>
            
            <xsl:apply-templates select="$bulk/element" mode="normalized"/>
            
            <xsl:message select="current-dateTime()"/>
            
        </xsl:variable>
        <xsl:comment select="count($r/r2)"/>        
            
    </xsl:template>
    
    <xsl:template match="element" mode="normalized">
        <xsl:if test="exists(@normalized)">
            <r1/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="element" mode="not-normalized">
        <xsl:if test="exists(imf:get-normalized-name(@original,'tv-name'))">
          <r2/>  
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
