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
    
    <xsl:variable name="sn-entiteitrelatie" select="imf:get-normalized-name('stereotype-name-entiteitrelatie','stereotype-name')"/>
    
    <!-- 
        association validation 
    -->
    <xsl:template match="imvert:association">
        <!--setup-->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="superclasses" select="imf:get-superclasses($class)"/>
        <xsl:variable name="package" select="$class/.."/>
        <xsl:variable name="is-collection" select="$class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')"/>
        <xsl:variable name="association-class-id" select="imvert:association-class/imvert:type-id"/>
        <xsl:variable name="property-names" select="$class/(imvert:atributes | imvert:associations)/*/imvert:name"/>
        <xsl:variable name="name" select="imvert:name"/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:variable name="defining-classes" select="($defining-class, imf:get-superclasses($defining-class))"/>
        <xsl:variable name="is-combined-identification" select="imf:get-tagged-value($this,'Gecombineerde identificatie')"/>
        <xsl:variable name="target-navigable" select="imvert:target-navigable"/>
        <xsl:variable name="stereotypes" select="imvert:stereotype"/>
        <xsl:variable name="class-stereotypes" select="$class/imvert:stereotype"/>
        
        <!-- Task #487793 - Check in imvertor op waarde van relatienaam (bij stereotype EntiteitRelatie) -->
        <xsl:variable name="accepted-relation-names" select="imf:get-config-stereotype-entity-relation-constraint($class-stereotypes)"/>
        
        <!--validation-->
        
        <!-- Task #487793 Check in imvertor op waarde van relatienaam (bij stereotype EntiteitRelatie) -->
        <xsl:sequence select="imf:report-warning(., 
            (
            exists($accepted-relation-names)
            and
            not(imvert:name = $accepted-relation-names)
            ), 
            'Relation with stereotype [1] for class with stereotype [2] has inappropriate name',($stereotypes,$class-stereotypes))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>
