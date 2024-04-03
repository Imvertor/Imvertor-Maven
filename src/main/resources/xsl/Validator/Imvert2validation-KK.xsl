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
        Validation of Kadaster/KING rules. 
        
        Called from within kadaster/KING validation XSLTs.
    -->
    
    <!-- 
        attribute validation 
    -->
    <xsl:template match="imvert:attribute" priority="30">
        <!-- setup -->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        
        <xsl:variable name="is-grouptype" select="imvert:stereotype/@id = ('stereotype-name-attributegroup')"/>
        <xsl:variable name="has-grouptype" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-composite')"/>
        
        <xsl:variable name="designation" select="$defining-class/imvert:designation"/>
        <xsl:variable name="is-designated-interface" select="$defining-class/imvert:stereotype/@id = (('stereotype-name-interface'))"/>
       
        <?x
        <!-- Jira IM-420 -->
        <xsl:sequence select="imf:report-warning(., 
            not($is-grouptype) and not($designation=('datatype','enumeration') or $is-designated-interface or empty($defining-class)), 
            'Type of [1] must be a datatype, but is [2].', (imf:string-group($this/imvert:stereotype),imf:string-group($defining-class/imvert:stereotype)))"/>
        x?>
        
        <xsl:sequence select="imf:report-warning(., 
            $is-grouptype and not($has-grouptype), 
            'Type of [1] must be an attribute group, but is [2].', (imf:string-group($this/imvert:stereotype),imf:string-group($defining-class/imvert:stereotype)))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    
</xsl:stylesheet>
