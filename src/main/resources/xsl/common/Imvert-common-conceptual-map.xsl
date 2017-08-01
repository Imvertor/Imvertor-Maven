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
 </xsl:stylesheet>
