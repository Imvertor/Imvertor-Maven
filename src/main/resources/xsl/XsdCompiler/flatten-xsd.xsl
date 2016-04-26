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
    exclude-result-prefixes="#all"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"

    version="2.0">

    <!-- 
        process the XML report on all generated schemas and flatten each schema:
        remove namespaces and resolve imports 
    -->
    
    <xsl:include href="../common/Imvert-common.xsl"/>
    <xsl:include href="extension/extension-variable.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
        
    <xsl:template match="/imvert:schemas">
        <xsl:apply-templates select="imvert:schema/imvert:result-file-fullpath" mode="prepare"/>
        <xsl:apply-templates select="imvert:schema"/>       
    </xsl:template>
   
    <xsl:template match="imvert:result-file-fullpath" mode="prepare"> 
        <xsl:variable name="schema-name" select="tokenize(.,'/')[last()]"/>
        <xsl:variable name="doc-loc" select="concat(.,'-flat.xsd')"/>
        <xsl:sequence select="imf:set-variable(concat('MUST-COPY-',$schema-name),'1')"/>
    </xsl:template>
        
    <xsl:template match="imvert:schema">
        <xsl:variable name="doc-loc" select="concat(imvert:result-file-fullpath,'-flat.xsd')"/>
            <xsl:sequence select="imf:set-variable('base-schema',$doc-loc)"/> 
        <xsl:variable name="doc-result">
            <xsl:apply-templates select="imvert:result-file-fullpath"/>
        </xsl:variable>
        <xsl:result-document href="{$doc-loc}">
            <xsl:sequence select="$doc-result"/>
        </xsl:result-document>
    </xsl:template>
     
    <xsl:template match="imvert:result-file-fullpath">
        <xsl:variable name="schema-name" select="tokenize(.,'/')[last()]"/>
        <xsl:sequence select="imf:set-variable(concat(imf:get-variable('base-schema'),$schema-name),'1')"/>
        <xsl:variable name="doc" select="imf:document(.)"/>
        <xsl:apply-templates select="$doc/xs:schema" mode="root"/>
    </xsl:template>
    
    <xsl:template match="xs:schema" mode="root">
        <xs:schema>
            <xsl:copy-of select="@elementFormDefault"/>
            <xsl:copy-of select="@attributeFormDefault"/>
            <xsl:copy-of select="@version"/>
            <xs:annotation>
                <xsl:sequence select="xs:annotation/xs:appinfo"/>
                <xs:appinfo source="http://www.imvertor.org/schema-info/mode">flat</xs:appinfo>
            </xs:annotation>
            <xsl:apply-templates select="." mode="sub"/>
        </xs:schema>
    </xsl:template>
    
    <xsl:template match="xs:schema" mode="sub">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="xs:import">
        <xsl:variable name="schema-name" select="tokenize(@schemaLocation,'/')[last()]"/>
        <xsl:variable name="must-copy" select="imf:get-variable(concat('MUST-COPY-',$schema-name))"/>
        <xsl:variable name="status" select="imf:get-variable(concat(imf:get-variable('base-schema'),$schema-name))"/>
        <xsl:choose>
            <xsl:when test="$status = '1'">
                <!-- skip, already resolved -->
            </xsl:when>
            <xsl:when test="$must-copy = '1'">
                <!-- must resolve --> 
                <xsl:sequence select="imf:set-variable(concat(imf:get-variable('base-schema'),$schema-name),'1')"/>
                <xsl:variable name="doc" select="imf:document(@schemaLocation)"/>
                <xsl:comment select="concat('Start of ',@schemaLocation)"/>
                <xsl:apply-templates select="$doc/xs:schema" mode="sub"/>
                <xsl:comment select="concat('End of ',@schemaLocation)"/>
            </xsl:when>            
            <xsl:otherwise>
                <!-- maintain the import -->
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xs:annotation"/>
    
    <xsl:template match="xs:element/@ref | xs:element/@type | xs:extension/@base">
        <xsl:variable name="ns" select="substring-before(.,':')"/>
        <xsl:variable name="val" select="substring-after(.,':')"/>
        <xsl:choose>
            <xsl:when test="$ns = ('xs','xlink')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{name(.)}" select="if ($val = '') then . else $val"/>
            </xsl:otherwise>    
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xs:*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
  
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
