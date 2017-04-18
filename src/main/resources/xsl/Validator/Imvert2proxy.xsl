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
         
         ADAPTION IN ACCORDANCE WITH https://kinggemeenten.plan.io/issues/487891 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="output-folder" select="imf:get-config-string('system','managedoutputfolder')"/>
    <xsl:variable name="owner" select="imf:get-config-string('cli','owner')"/>
    
    <xsl:variable name="stereotype-proxy" select="imf:get-config-stereotypes(('stereotype-name-att-proxy','stereotype-name-obj-proxy','stereotype-name-grp-proxy','stereotype-name-prd-proxy'))"/>
    
    <xsl:variable name="local-constructs" select="('name', 'id')"/> <!-- 'attributes', 'associations', ? -->
    
    <xsl:variable name="document-proxies" select="//*[imvert:stereotype = $stereotype-proxy]"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:copy>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package" mode="client"/>
        </xsl:copy>
    </xsl:template>
    
    <!--TODO inlezen van losse documenten tegengaan; volg het gecompileerde suppliers document -->
    <xsl:template match="imvert:class[imvert:stereotype = $stereotype-proxy] | imvert:attribute[imvert:stereotype = $stereotype-proxy]" mode="client">
        <xsl:variable name="client" select="."/>
        <xsl:variable name="trace-id" select="$client/imvert:trace" as="element()*"/>
        <xsl:variable name="supplier-subpaths" select="imf:get-construct-supplier-system-subpaths($client)" as="xs:string*"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="count($trace-id) != 1">
                    <xsl:sequence select="imf:msg(.,'ERROR', 'Proxy requires a single outgoing trace, [1] traces found',count($trace-id))"/>
                </xsl:when>
                <xsl:when test="empty($supplier-subpaths)">
                    <xsl:sequence select="imf:msg(.,'ERROR','Could not determine a supplier subpath')"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- get the construct traced in any supplier -->
                    <xsl:variable name="result" as="element()*">
                        <xsl:for-each select="$supplier-subpaths">
                            <xsl:variable name="supplier-doc" select="imf:get-imvert-supplier-doc(.)"/>
                            <xsl:variable name="supplier" select="imf:get-construct-by-id($trace-id,$supplier-doc)"/>
                            <xsl:choose>
                                <xsl:when test="empty($supplier-doc)">
                                    <xsl:sequence select="imf:msg($client,'WARNING','No such supplier document: [1]',.)"/>
                                </xsl:when>
                                <xsl:when test="exists($supplier)">
                                    <!-- this is reached only once. -->
                                   
                                    <xsl:apply-templates select="$client/imvert:name" mode="client"/>
                                    <xsl:apply-templates select="$client/imvert:id" mode="client"/>
                                    
                                    <imvert:proxy origin="system" original-location="{.}">
                                        <xsl:value-of select="$supplier/imvert:id"/>
                                    </imvert:proxy>
                                    
                                    <xsl:apply-templates select="$client/imvert:min-occurs" mode="client"/>
                                    <xsl:apply-templates select="$client/imvert:max-occurs" mode="client"/>
                               
                                    <!-- 
                                         Copy for this proxy the local constructs 
                                         This template filters out what should not be copied.
                                    -->
                                    <xsl:apply-templates select="$supplier/*" mode="supplier"/>
                                    
                                    <!-- process the attributes and associations -->
                                    <xsl:apply-templates select="$client/imvert:attributes" mode="client"/>
                                    <xsl:apply-templates select="$client/imvert:associations" mode="client"/>
                                    
                                    <!-- 
                                         get the applicable tagged values for the proxy, and add those for the supplier.
                                    -->
                                    <xsl:variable name="tv-client" as="element()*">
                                        <xsl:apply-templates select="$client/imvert:tagged-values/*" mode="client"/>
                                    </xsl:variable>
                                    <xsl:variable name="tv-supplier" as="element()*">
                                        <xsl:apply-templates select="$supplier/imvert:tagged-values/*" mode="supplier"/>
                                    </xsl:variable>
                                    <imvert:tagged-values>
                                        <xsl:for-each-group select="($tv-supplier,$tv-client)" group-by="imvert:name">
                                            <xsl:apply-templates select="current-group()[1]" mode="client"/>
                                        </xsl:for-each-group>
                                    </imvert:tagged-values>
                                    
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- this supplier doesn't provide the info -->
                                </xsl:otherwise>
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
    
    <xsl:template match="imvert:id | imvert:class/imvert:name | imvert:attribute/imvert:name | imvert:min-occurs | imvert:max-occurs | imvert:attributes | imvert:associations | imvert:tagged-values" mode="supplier">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value[imvert:name = ('Regels','Toelichting')]" mode="supplier">
        <!-- skip; never copy these from the supplier. -->
    </xsl:template>
    
    <?x
    <!-- 
        the target of an association of a supplier, must be replaced by the proxy :
    -->
    <xsl:template match="imvert:type-id" mode="supplier">
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
    x?>
    
    <xsl:template match="node()" mode="#all">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
