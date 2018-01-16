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
          This applies to the UGM.
    -->
    
    <xsl:import href="Imvert2canonical-RWS-common.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
   
    <!-- 
         sorteer alle associaties op alfabetische volgorde. Hierbij eerst de relaties, dan de externe koppelingen 
     -->
    <xsl:template match="imvert:class">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="imvert:*[not(self::imvert:associations)]"/>
            <imvert:associations>
                <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-relatiesoort')]">
                    <xsl:sort select="imvert:name"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
                <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-externekoppeling')]">
                    <xsl:sort select="imvert:name"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </imvert:associations>
        </xsl:copy>
    </xsl:template>  
  
</xsl:stylesheet>
