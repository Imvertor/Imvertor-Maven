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
    
    version="2.0">
    
    <!-- 
        A config string doesn't have to exist. If so, it returns an empty sequence.
    -->
    
    <xsl:function name="imf:get-config-string" as="xs:string?">
        <xsl:param name="group"/>
        <xsl:param name="name"/>
        <xsl:sequence select="(
            ext:imvertorParameterFile('GET',string($group),string($name),(),())
            )"/>      
    </xsl:function>
    
    <xsl:function name="imf:get-config-string" as="xs:string?">
        <xsl:param name="group"/>
        <xsl:param name="name"/>
        <xsl:param name="default"/>
        <xsl:variable name="cfg" select="imf:get-config-string($group,$name)"/>
        <xsl:sequence select="if (exists($cfg)) then $cfg else $default"/>
    </xsl:function>
    
    <xsl:function name="imf:remove-config" as="xs:string?">
        <xsl:param name="group"/>
        <xsl:param name="name"/>
        <xsl:sequence select="(
            ext:imvertorParameterFile('REMOVE',string($group),string($name),(),())
            )"/>      
    </xsl:function>
    
    <xsl:function name="imf:set-config-string" as="item()*">
        <xsl:param name="group"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:sequence select="(
            ext:imvertorParameterFile('SET',string($group),string($name),string($value),'false')
            )"/>      
    </xsl:function>
    
    <xsl:function name="imf:set-config-string" as="item()*">
        <xsl:param name="group"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:param name="overwrite"/>
        <xsl:sequence select="(
            ext:imvertorParameterFile('SET',string($group),string($name),string($value),if ($overwrite) then 'true' else 'false')
            )"/>      
    </xsl:function>
    
    <xsl:function name="imf:save-config-file" as="item()*">
        <xsl:sequence select="(
            ext:imvertorParameterFile('SAVE',(),(),(),()) 
            )"/>      
    </xsl:function>
    
</xsl:stylesheet>