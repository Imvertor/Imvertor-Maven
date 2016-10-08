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
         Canonization of the input, common to all metamodels.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="output-folder" select="imf:get-config-string('system','managedoutputfolder')"/>
    <xsl:variable name="owner" select="imf:get-config-string('cli','owner')"/>
    
    <xsl:variable name="stereotype-proxy" select="imf:get-config-stereotypes(('stereotype-name-att-proxy','stereotype-name-obj-proxy','stereotype-name-grp-proxy'))"/>
    
    <xsl:variable name="local-constructs" select="('attributes', 'associations', 'name', 'id')"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:copy>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = $stereotype-proxy]">
        <xsl:apply-templates select="." mode="proxy"/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-proxy]">
        <xsl:apply-templates select="." mode="proxy"/>
    </xsl:template>
    
    <xsl:template match="imvert:class|imvert:attribute" mode="proxy">
        <?xx this is for not-manually traced constructs:
            <xsl:variable name="formal-name" select="imf:get-construct-formal-name(.)"/>
            <xsl:variable name="formal-trace-name" select="imf:get-construct-formal-trace-name(.)"/>
            <xsl:variable name="supplier-subpath" select="imf:get-construct-supplier-system-subpath(.)"/>
            <xsl:variable name="supplier-doc" select="imf:document(concat($output-folder,'/applications/',$supplier-subpath,'/etc/system.imvert.xml'))"/>
            <xsl:variable name="supplier-construct" select="imf:get-supplier($supplier-doc,$formal-trace-name)"/>
        ?>
        
        <xsl:variable name="trace-id" select="imvert:trace"/>
        <xsl:variable name="supplier-subpath" select="imf:get-construct-supplier-system-subpath(.)"/>
        <xsl:variable name="supplier-doc" select="imf:document(concat($output-folder,'/applications/',$supplier-subpath,'/etc/system.imvert.xml'))"/>
        <xsl:variable name="supplier-construct" select="imf:get-construct-by-id($trace-id,$supplier-doc)"/>
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="count($trace-id) != 1">
                    <xsl:sequence select="imf:msg(.,'ERROR', 'Proxy requires a single outgoing trace',())"/>
                </xsl:when>
                <xsl:when test="empty($supplier-doc)">
                    <xsl:sequence select="imf:msg(.,'ERROR','No such proxy supplier document location: [1]',$supplier-subpath)"/>
                </xsl:when>
                <xsl:when test="empty($supplier-construct)">
                    <xsl:sequence select="imf:msg(.,'ERROR','Proxy could not be resolved at location [1]',($supplier-subpath))"/>
                </xsl:when>
                <?x TODO proxies op proxies wél toesaan, Moet daar een waarschuwing op komen? Of is het gewoon?
                <xsl:when test="exists($supplier-construct/imvert:proxy)">
                    <xsl:sequence select="imf:msg(.,'ERROR','Proxy resolves to a proxy at location [1]',($supplier-subpath))"/>
                </xsl:when>
                ?>
                <xsl:otherwise>
                    <imvert:proxy origin="system" original-location="{$supplier-subpath}">
                        <xsl:value-of select="$supplier-construct/imvert:id"/>
                    </imvert:proxy>
                    <!-- 
                        copy for this proxy the local constructs 
                    -->
                    <xsl:sequence select="*[local-name(.) = $local-constructs]"/>
                    <!-- 
                        copy all supplier info to this construct, except for local constructs 
                    -->
                    <xsl:sequence select="$supplier-construct/*[not(local-name(.) = $local-constructs)]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
 
    <xsl:template match="*" mode="#default proxy">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
