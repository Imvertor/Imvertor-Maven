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
    
    xmlns:cs="http://www.imvertor.org/metamodels/conceptualschemas/model/v20181210"
    xmlns:cs-ref="http://www.imvertor.org/metamodels/conceptualschemas/model-ref/v20181210"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
       Introduces the schema mapping file.
       
       Creates a common function for creating a catalog entry extracted from the conceptual map.
    -->

    <xsl:variable name="conceptual-schema-mapping-name" select="imf:get-config-string('cli','mapping')"/>
    <xsl:variable name="conceptual-schema-mapping-file" select="imf:get-config-string('properties','CONCEPTUAL_SCHEMA_MAPPING_FILE')"/>
    <xsl:variable name="conceptual-schema-mapping" select="imf:document($conceptual-schema-mapping-file,true())/cs:ConceptualSchemas"/>
    
    <xsl:function name="imf:create-catalog-url" as="xs:string?">
        <xsl:param name="construct" as="element(cs:Construct)?"/> <!-- the construct that is part of a conceptual map -->
           
        <xsl:variable name="conceptual-schema" select="imf:get-schema-for-construct($construct)"/>
        <xsl:sequence select="if ($conceptual-schema/cs:catalogUrl) then replace($conceptual-schema/cs:catalogUrl,'\[entry\]',string($construct/cs:catalogEntries/cs:catalogEntry/cs:name)) else ()"/>
 
    </xsl:function>
    
    <!-- 
        Return the construct that is part of a conceptual map, that defines the class passed. 
        The class is typically an <<interface>> within an <<external>>. 
        
        Specify the min/max numer of constructs that are expected to be returned.
    -->
    <xsl:function name="imf:get-conceptual-constructs" as="element(cs:Construct)*">
        <xsl:param name="class" as="element(imvert:class)"/><!-- TODO dit mag ook eigenlijk iedere constructie zijn met een unieke naam volgens de mapping. -->
        <xsl:param name="min-count" as="xs:integer?"/>
        <xsl:param name="max-count" as="xs:integer?"/>
        
        <xsl:variable name="namespace" select="($class/ancestor-or-self::imvert:package)[last()]/imvert:conceptual-schema-namespace"/>
        <xsl:variable name="maps" select="imf:get-conceptual-schema-map($namespace,$conceptual-schema-mapping-name)"/>
        <xsl:variable name="constructs" select="$maps/cs:constructs/cs:Construct[cs:name = $class/imvert:name/@original]"/>
        <xsl:choose>
            <xsl:when test="($max-count ge 1) and $constructs[$max-count + 1]">
                <xsl:sequence select="imf:msg($class,'ERROR','Found [1] conceptual constructs declarations [2] in map [3], [4] allowed',
                    (count($constructs),imf:string-group($constructs/cs:name),$conceptual-schema-mapping-name,$max-count))"/>
            </xsl:when>
            <xsl:when test="($min-count ge 1) and empty($constructs[$min-count])">
                <xsl:sequence select="imf:msg($class,'ERROR','Found [1] conceptual constructs declarations [2] in map [3], [4] required',
                    (count($constructs),imf:string-group($constructs/cs:name),$conceptual-schema-mapping-name,$min-count))"/>
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
    <xsl:function name="imf:get-conceptual-construct" as="element(cs:Construct)?">
        <xsl:param name="imvert-class" as="element(imvert:class)"/>
        <xsl:sequence select="imf:get-conceptual-constructs($imvert-class,1,1)"/>
    </xsl:function>
    
    <!-- return the conceptual schema <map> elements that may holds the mapping of conceptual names to construct in the schema -->
    <xsl:function name="imf:get-conceptual-schema-map" as="element(cs:Map)*">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="use-mapping" as="xs:string"/>
        
        <xsl:variable name="conceptual-schema-ids" select="$conceptual-schema-mapping//cs:ConceptualSchema[cs:url = $url]/cs:id"/>
        <xsl:variable name="maps" select="$conceptual-schema-mapping/cs:components/cs:ConceptualSchemasComponents/cs:Map[imf:resolve-cs-ref(cs:forSchema/cs-ref:ConceptualSchemaRef,'ConceptualSchema')/cs:id = $conceptual-schema-ids]"/>
        
        <!-- select maps that are in the mapping -->
        <xsl:variable name="used-maps" select="$conceptual-schema-mapping/cs:mappings/cs:Mapping[cs:name = $use-mapping]"/>
        <xsl:variable name="selected-mapping" as="element(cs:Map)*">
            <xsl:for-each select="$maps">
                <xsl:if test="cs:id = (for $m in $used-maps/cs:use/cs-ref:MapRef return imf:resolve-cs-ref($m,'Map')/cs:id)">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$selected-mapping"/>
       
        <?x
        <xsl:message>--</xsl:message>
        <xsl:message select="$url"></xsl:message>
        <xsl:message>--1</xsl:message>
        <xsl:message select="$use-mapping"></xsl:message>
        <xsl:message>--2</xsl:message>
        <xsl:message select="$selected-mapping/cs:id"></xsl:message>
        <xsl:message>--3</xsl:message>
        <xsl:message select="$conceptual-schema-ids"></xsl:message>
        <xsl:message>--4</xsl:message>
        <xsl:message select="count($maps)"></xsl:message>
        x?>
        
    </xsl:function>
    
    <xsl:function name="imf:resolve-cs-ref" as="element()?">
        <xsl:param name="element" as="element()"/> <!-- a cs-ref:* element -->
        <xsl:param name="element-type" as="xs:string+"/> <!-- local name(s) of the element(s) for which this ID is valid -->
        <xsl:variable name="id" select="substring($element/@xlink:href,2)"/>
        <xsl:variable name="target" select="root($element)/cs:ConceptualSchemas/cs:components/cs:ConceptualSchemasComponents/cs:*[cs:id = $id and local-name(.) = $element-type]"/>
        <xsl:choose>
            <xsl:when test="count($target) = 1">
                <xsl:sequence select="$target"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg(root($element),'FATAL','Found [1] items with id [2] allowed for names [3], in mapping named [4]', (count($target), $id, imf:string-group($element-type), $conceptual-schema-mapping-name))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-schema-for-construct">
        <xsl:param name="construct" as="element(cs:Construct)"/>
        <xsl:sequence select="imf:resolve-cs-ref($construct/../../cs:forSchema/cs-ref:ConceptualSchemaRef,'ConceptualSchema')"/>
    </xsl:function>
    
 </xsl:stylesheet>
