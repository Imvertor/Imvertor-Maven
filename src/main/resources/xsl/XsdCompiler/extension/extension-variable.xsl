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
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    version="2.0">
  
    <xsl:function name="imf:get-variable" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:sequence select="imf:get-xparm(concat('variable/', imf:safe-variable-name($name)))"/>
    </xsl:function>
    
    <xsl:function name="imf:set-variable" as="xs:string?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="imf:set-xparm(concat('variable/', imf:safe-variable-name($name)),$value)"/>
    </xsl:function>
    
    <xsl:function name="imf:safe-variable-name" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:value-of select="replace($name,'[^A-Za-z0-9\._-]','_')"/>
    </xsl:function>
</xsl:stylesheet>