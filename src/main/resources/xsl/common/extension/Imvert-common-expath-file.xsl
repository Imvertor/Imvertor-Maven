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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert="http://www.imvertor.org/xsl/functions"
    
    xmlns:file="http://expath.org/ns/file"
    
    version="3.0">
    
    <xsl:function name="imf:expath-write" as="xs:boolean?">
        <xsl:param name="file-path"/>
        <xsl:param name="xml-contents"/>
        <xsl:sequence select="file:write($file-path,$xml-contents)"/>
    </xsl:function>
    
    <xsl:function name="imf:expath-write" as="xs:boolean?">
        <xsl:param name="file-path"/>
        <xsl:param name="xml-contents"/>
        <xsl:param name="output-parameters"/>
        <xsl:sequence select="file:write($file-path,$xml-contents,$output-parameters)"/>
    </xsl:function>
    
    <xsl:function name="imf:expath-exists" as="xs:boolean?">
        <xsl:param name="file-path"/>
        <xsl:sequence select="file:exists($file-path)"/>
    </xsl:function>
    
    <xsl:function name="imf:expath-write-binary" as="xs:boolean?">
        <xsl:param name="file-path" as="xs:string"/>
        <xsl:param name="base64-content" as="xs:string"/>
        <xsl:variable name="base64" select="xs:base64Binary($base64-content)"/>
        <xsl:sequence select="file:write-binary($file-path,$base64)"/>
    </xsl:function>
    
</xsl:stylesheet>