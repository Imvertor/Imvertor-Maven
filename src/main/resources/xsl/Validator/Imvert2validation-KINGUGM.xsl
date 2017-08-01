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
    <xsl:import href="Imvert2validation-KING-mod-alias.xsl"/>
    
    <!-- TODO added validation for KING exchange models UGM -->
   
    <xsl:template match="imvert:association[imvert:aggregation = 'composite']">
        <!-- setup -->
       
        <!-- validate -->
       
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value[imvert:id = (
        'CFG-TV-MINVALUEINCLUSIVE',
        'CFG-TV-MAXVALUEINCLUSIVE'
        )]">
        <!-- setup -->
        <xsl:variable name="construct" select="../.."/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-error($construct, 
            $construct/imvert:type-name = ('scalar-string','scalar-uri'), 
            'Tagged value [1] cannot be specified on [2]', (imvert:name/@original, $construct/imvert:type-name))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:is-id">
        <!-- setup -->
        <xsl:variable name="tv-k" select="imf:get-tagged-value-element(..,'##CFG-TV-INDICATIEMATCHGEGEVEN')"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(.., 
            exists($tv-k) and imf:boolean(.) and not(imf:boolean-or(for $b in $tv-k/imvert:value return imf:boolean($b))), 
            'Identifiable construct must assign yes to the tagged value [1]', $tv-k[1]/imvert:name)"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:static">
        <!-- setup -->
        <xsl:variable name="tv-k" select="imf:get-tagged-value-element(..,'##CFG-TV-INDICATIEMATCHGEGEVEN')"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(.., 
            empty($tv-k) and imf:boolean(.), 
            'Static construct must assign yes to the tagged value [1]', $tv-k[1]/imvert:name)"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value[@id = 'CFG-TV-INDICATIEMATCHGEGEVEN']">
        <!-- setup -->
        <xsl:variable name="construct" select="../.."/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(.., 
            not(imf:boolean(imvert:value)) and imf:boolean($construct/imvert:static), 
            'Construct that assigns yes to the tagged value [1] must be static', imvert:name/@original)"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[self::imvert:class | self::imvert:attribute | imvert:association]/imvert:name">
        <!-- setup -->
        <xsl:variable name="name" select="."/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(., 
            not(../imvert:stereotype = 'ENUM') and
            not(matches($name,'^[A-Za-z0-9\-\.]+$')), 
            'Name [1] has unsupported characters', (.))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst')]">
        <!-- setup -->
        
        <!-- validate -->
        <xsl:sequence select="imf:report-error(., 
            empty(*/imvert:attribute[imvert:is-id = 'true']), 
            'At least one attribute must identify this [1]', (imf:get-config-stereotypes('stereotype-name-referentielijst')))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    
</xsl:stylesheet>
