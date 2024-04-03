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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    >
    
    <!-- 
        Validation of KING/VNGR BSM models (module).
    -->
        
    <xsl:variable name="requires-alias" select="imf:boolean(imf:get-config-string('cli','stub_requiresalias','yes'))" as="xs:boolean"/>
    
    <xsl:template match="imvert:association[imvert:stereotype/@id = ('stereotype-name-relatiesoort')]">
        
        <!-- setup -->
        <xsl:variable name="alias" select="imvert:alias"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-error(., 
            $requires-alias and empty($alias), 
            'No alias found for association')"/>
        
        <xsl:sequence select="imf:report-error(., 
            $requires-alias and exists($alias) and not(matches($alias,'^([A-Z]{6})|([A-Z]{9})$')), 
            'Alias [1] must be 6 or 9 uppercase characters',$alias)"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype','stereotype-name-referentielijst')]">
        <!-- setup -->
        
        <xsl:variable name="alias" select="imvert:alias"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-error(., 
            $requires-alias and empty($alias), 
            'No alias found for [1]', imvert:stereotype)"/>
        
        <xsl:sequence select="imf:report-error(., 
            $requires-alias and exists($alias) and not(matches($alias,'^([A-Z]{3})$')), 
            'Alias [1] for [2] must be 3 uppercase characters',($alias,imvert:stereotype))"/>
 
        <xsl:next-match/>
    </xsl:template>

    
</xsl:stylesheet>
