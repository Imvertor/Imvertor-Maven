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
    
    <xsl:variable name="local-constructs" select="('name', 'id')"/> <!-- 'attributes', 'associations', ? -->
    
    <xsl:variable name="document-proxies" select="//*[imvert:stereotype = $stereotype-proxy]"/>
    
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
    
    <!--TODO deze code loopt grotendeels parallel met imvert2pretrace.xsl. gelijktrekken. -->
    <!--TODO inlezen van losse documenten tegengaan; volg het gecompileerde suppliers document -->
    <xsl:template match="imvert:class|imvert:attribute" mode="proxy">
       
        <xsl:variable name="this" select="."/>
        <xsl:variable name="trace-id" select="$this/imvert:trace"/>
        <xsl:variable name="supplier-subpaths" select="imf:get-construct-supplier-system-subpaths($this)"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="count($trace-id) != 1">
                    <xsl:sequence select="imf:msg(.,'ERROR', 'Proxy requires a single outgoing trace, [1] traces found',count($trace-id))"/>
                </xsl:when>
                <xsl:when test="empty($supplier-subpaths)">
                    <xsl:sequence select="imf:msg('ERROR','Proxy without trace')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="result" as="element()*">
                        <xsl:for-each select="$supplier-subpaths">
                            <xsl:variable name="supplier-doc" select="imf:get-imvert-supplier-doc(.)"/>
                            <xsl:variable name="supplier-construct" select="imf:get-construct-by-id($trace-id,$supplier-doc)"/>
                            <xsl:choose>
                                <xsl:when test="empty($supplier-doc)">
                                    <xsl:sequence select="imf:msg($this,'WARNING','No such supplier document: [1]',.)"/>
                                </xsl:when>
                                <xsl:when test="exists($supplier-construct)">
                                    <!-- this is reached only once. -->
                                    <imvert:proxy origin="system" original-location="{.}">
                                        <xsl:value-of select="$supplier-construct/imvert:id"/>
                                    </imvert:proxy>
                                    <!-- 
                                        copy for this proxy the local constructs 
                                    -->
                                    <xsl:sequence select="$this/*[local-name(.) = ('name','id')]"/>
                                    <!-- 
                                        copy all supplier info to this construct, except for local constructs 
                                    -->
                                    <xsl:sequence select="$supplier-construct/*[not(local-name(.) = ('name','id','attributes','associations'))]"/>
                                    <xsl:if test="local-name($this) = 'class'">
                                        <!--
                                            copy first the supplier attributes, and then the local attributes, and associations
                                        -->
                                        <imvert:attributes>
                                            <xsl:apply-templates select="$supplier-construct/imvert:attributes/imvert:attribute" mode="proxy-sub"/>
                                            <xsl:sequence select="$this/imvert:attributes/imvert:attribute"/>
                                        </imvert:attributes>
                                        <imvert:associations>
                                            <xsl:apply-templates select="$supplier-construct/imvert:associations/imvert:association" mode="proxy-sub"/>
                                            <xsl:sequence select="$this/imvert:associations/imvert:association"/>
                                        </imvert:associations>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="empty($result)">
                            <xsl:sequence select="imf:msg(.,'ERROR', 'Unable to resolve the proxy trace, tried [1]',(string-join($supplier-subpaths,'; ')))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$result"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
 
    <xsl:template match="imvert:association" mode="proxy-sub">
        <imvert:association>
            <xsl:apply-templates mode="#current"/>
        </imvert:association>
    </xsl:template>
    <xsl:template match="imvert:attribute" mode="proxy-sub">
        <imvert:attribute>
            <xsl:apply-templates mode="#current"/>
        </imvert:attribute>
    </xsl:template>
    <!-- 
        the target of an association of a supplier, must be replaced by the proxy :
    -->
    <xsl:template match="imvert:type-id" mode="proxy-sub">
        <xsl:variable name="id" select="."/>
        <xsl:variable name="proxy" select="$document-proxies[imvert:trace = $id]"/>
        <xsl:choose>
            <xsl:when test="count($proxy) != 1">
                <xsl:sequence select="imf:msg(..,'ERROR', 'Proxy association deadlock, [1] traces found',count($proxy))"/>
            </xsl:when>
            <xsl:otherwise>
                <imvert:type-id origin="proxy" original="{$id}">
                    <xsl:value-of select="$proxy/imvert:id"/>
                </imvert:type-id>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
    <xsl:template match="*" mode="#default proxy proxy-sub">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
