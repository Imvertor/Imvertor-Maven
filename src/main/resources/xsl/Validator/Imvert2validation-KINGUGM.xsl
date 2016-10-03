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
        Validation of the UML only for KING rules, which follow the BP rules mostly. 
    -->
    
    <xsl:import href="Imvert2validation-KING.xsl"/>
    
    <!-- TODO added validation for KING exchange models UGM -->
    
    <xsl:template match="imvert:association[not(imvert:aggregation = 'composite')]">

        <!-- setup -->
        <xsl:variable name="alias" select="imvert:alias"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-error(., 
            empty($alias), 
            'No alias found for association')"/>
        
        <xsl:next-match/>
    </xsl:template>
   
    <xsl:template match="imvert:association[imvert:aggregation = 'composite']">
        <!-- setup -->
       
        <!-- validate -->
       
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value[imvert:name = (
        imf:get-normalized-name('Minimum waarde (inclusief)','tv-name'),
        imf:get-normalized-name('Maximum waarde (inclusief)','tv-name')
        )]">
        <!-- setup -->
        <xsl:variable name="construct" select="../.."/>
        <!-- validate -->
        <xsl:sequence select="imf:report-error($construct, 
            $construct/imvert:type-name = ('scalar-string','scalar-uri'), 
            'Tagged value [1] cannot be specified on [2]', (imvert:name/@original, $construct/imvert:type-name))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotype-names('stereotype-name-referentielijst')]">
        <xsl:message>TESTING</xsl:message>
        <!-- setup -->
        <xsl:variable name="alias" select="imvert:alias"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-error(., 
            empty($alias), 
            'No alias found for [1]', imvert:stereotype)"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:is-id">
        <!-- setup -->
        <xsl:variable name="tv-k" select="imf:get-tagged-value-element(..,'Indicatie kerngegeven')"/>
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(.., 
            imf:boolean(.) and not(imf:boolean($tv-k)), 
            'Identifiable construct must assign yes to the tagged value [1]', $tv-k/imvert:name/@original)"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:name">
        <!-- setup -->
        <xsl:variable name="name" select="imvert:name"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(.., 
            matches($name,'^[A-Za-z0-9\-\.]+$'), 
            'Name has unsupported characters', ())"/>
        
        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>
