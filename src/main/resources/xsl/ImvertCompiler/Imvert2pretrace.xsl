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
         Create a listing of all dependencies between packages.
         For each construct that is derived (i.e. is client), add the ID of the supplier.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-trace.xsl"/>
    
    <xsl:variable name="output-folder" select="imf:get-config-string('system','managedoutputfolder')"/>
    <xsl:variable name="owner" select="imf:get-config-string('cli','owner')"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:if test="exists(//imvert:trace[1])">
            <xsl:sequence select="imf:msg('ERROR','Model has unexpected user-defined traces')"/>
        </xsl:if>
        <xsl:copy>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class | imvert:attribute | imvert:association">
        <xsl:variable name="formal-name" select="@formal-name"/>
        <xsl:variable name="formal-trace-name" select="imf:get-construct-formal-trace-name(.)"/>
        <xsl:variable name="supplier-subpath" select="imf:get-construct-supplier-system-subpath(.)"/>
        <xsl:variable name="supplier-doc" select="imf:document(concat($output-folder,'/applications/',$supplier-subpath,'/etc/system.imvert.xml'))"/>
        <xsl:variable name="supplier-construct" select="imf:get-supplier($supplier-doc,$formal-trace-name)"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="empty($supplier-subpath)">
                    <xsl:comment select="concat('No traces applicable for ', $formal-trace-name)"/>
                </xsl:when>
                <xsl:when test="empty($supplier-doc)">
                    <xsl:sequence select="imf:msg('WARNING',concat('No such supplier document: ',$supplier-subpath))"/>
                </xsl:when>
                <xsl:when test="empty($supplier-construct)">
                    <xsl:comment select="concat('No trace found for ', $formal-trace-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <imvert:trace origin="system" original-location="{$supplier-subpath}">
                        <xsl:value-of select="$supplier-construct/imvert:id"/>
                    </imvert:trace>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:get-supplier" as="element()?">
        <xsl:param name="supplier-doc" as="document-node()?"/>
        <xsl:param name="formal-name" as="xs:string?"/>
        <xsl:sequence select="($supplier-doc//imvert:*[@formal-name = $formal-name])[1]"/>
    </xsl:function>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
 </xsl:stylesheet>
