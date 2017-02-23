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
    xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
  
    <xsl:variable name="key-current-root" select="/"/>
    
    <!-- define the keys -->
    <xsl:key name="key-imvert-construct-by-id" match="imvert:*" use="imvert:id"/>
    
    <!--more keys? -->
    
    
    
    <!-- define access using the keys -->
    <xsl:function name="imf:key-imvert-construct-by-id">
        <xsl:param name="id"/>
        <xsl:param name="root-document" as="document-node()?"/>
        <xsl:sequence select="imf:key-imvert('key-imvert-construct-by-id',$id, if (exists($root-document)) then $root-document else $key-current-root)"/>
    </xsl:function>
    
    <!-- define access using search, funtionally equivalent to key but slower -->
    <xsl:function name="imf:search-imvert-construct-by-id">
        <xsl:param name="id"/>
        <xsl:param name="root-element" as="node()?"/>
        <xsl:sequence select="$root-element/descendant-or-self::*[imvert:id=$id]"/>
    </xsl:function>
    
    <xsl:function name="imf:key-imvert" as="node()*">
        <xsl:param name="key-name" as="xs:string"/>
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="root-document" as="document-node()"/>
        <xsl:sequence select="key($key-name,$id,$root-document)"/>
    </xsl:function>
    
</xsl:stylesheet>
