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
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
       Introduces the schema mapping file.
       
       Creates a common function for creating a catalog entry extracted from the conceptual map.
    -->

    <xsl:variable name="conceptual-schema-mapping-name" select="imf:get-config-string('cli','mapping')"/>
    <xsl:variable name="conceptual-schema-mapping-file" select="imf:get-config-string('properties','CONCEPTUAL_SCHEMA_MAPPING_FILE')"/>
    <xsl:variable name="conceptual-schema-mapping" select="imf:document($conceptual-schema-mapping-file,true())/conceptual-schemas"/>
    
    <xsl:function name="imf:create-catalog-url" as="xs:string?">
        <xsl:param name="construct" as="element(construct)?"/> <!-- the construct that is part of a conceptual map -->
           
        <xsl:variable name="conceptual-schema" select="$construct/../.."/>
        <xsl:sequence select="if ($conceptual-schema/catalog) then replace($conceptual-schema/catalog,'\[entry\]',$construct/catalog-entry) else ()"/>
 
    </xsl:function>
    
    <!-- 
        Return the construct that is part of a conceptual map, that defines the class passed. 
        The class is typically an <<interface>> within an <<external>>. 
        
        Specify the min/max numer of constructs that are expected to be returned.
    -->
    <xsl:function name="imf:get-conceptual-constructs" as="element(construct)*">
        <xsl:param name="class" as="element(imvert:class)"/><!-- TODO dit mag ook eigenlijk iedere constructie zijn met een unieke naam volgens de mapping. -->
        <xsl:param name="min-count" as="xs:integer?"/>
        <xsl:param name="max-count" as="xs:integer?"/>
        
        <xsl:variable name="namespace" select="($class/ancestor-or-self::imvert:package)[last()]/imvert:conceptual-schema-namespace"/>
        <xsl:variable name="maps" select="imf:get-conceptual-schema-map($namespace,$conceptual-schema-mapping-name)"/>
        <xsl:variable name="constructs" select="$maps/construct[name = $class/imvert:name/@original]"/>
        
        <xsl:choose>
            <xsl:when test="($max-count ge 1) and $constructs[$max-count + 1]">
                <xsl:sequence select="imf:msg($class,'ERROR','Found [1] conceptual constructs declarations [2] in map [3], [4] allowed',
                    (count($constructs),imf:string-group($constructs/name),$conceptual-schema-mapping-name,$max-count))"/>
            </xsl:when>
            <xsl:when test="($min-count ge 1) and empty($constructs[$min-count])">
                <xsl:sequence select="imf:msg($class,'ERROR','Found [1] conceptual constructs declarations [2] in map [3], [4] required',
                    (count($constructs),imf:string-group($constructs/name),$conceptual-schema-mapping-name,$min-count))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$constructs"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Return the single construct that is part of a conceptual map, that defines the class passed. 
        The class is typically and <<interface>> but may be any class. 
    -->
    <xsl:function name="imf:get-conceptual-construct" as="element(construct)?">
        <xsl:param name="imvert-class" as="element(imvert:class)"/>
        <xsl:sequence select="imf:get-conceptual-constructs($imvert-class,1,1)"/>
    </xsl:function>
    
    <!-- return the conceptual schema <map> element which holds the mapping of conceptual names to construct in the schema -->
    <xsl:function name="imf:get-conceptual-schema-map" as="element()*">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="use-mapping" as="xs:string"/>
        <xsl:variable name="mapping-uses" select="$conceptual-schema-mapping//mapping[@name=$use-mapping]/use"/>
        <xsl:variable name="conceptual-schema" select="$conceptual-schema-mapping/conceptual-schema[url=$url]"/>
        <xsl:variable name="selected-mapping" select="$conceptual-schema/map[@name=$mapping-uses]"/>
        <xsl:sequence select="imf:msg('DEBUG','Use mapping [1] for URL [2], conceptual schemas [3], maps [4]',($use-mapping,$url,count($conceptual-schema),count($selected-mapping)))"/>
        <xsl:sequence select="$selected-mapping"/>
    </xsl:function>
    
 </xsl:stylesheet>
