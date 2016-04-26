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
        Expand the Imveror file based on derived information.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <!--
        The document that holds all layers, i.e. the result of Imvert2derivationtree 
    -->
    <xsl:variable name="imvert-derivation-tree" select="imf:document(imf:get-config-string('properties','WORK_DERIVATIONTREE_FILE'))"/>
    
    <xsl:variable name="config-tagged-values" select="imf:get-config-tagged-values()"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:copy>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        EXPAND THE DOCUMENTATION
        Documentation is compiled in a full form: all documentation of the client and all suppliers. 
    -->  
    <xsl:template match="imvert:application | imvert:package | imvert:class | imvert:attribute | imvert:association">
        <xsl:variable name="derived-documentation" select="imf:get-compiled-documentation(.,$model-is-traced)"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*[empty(self::imvert:documentation)]"/>
            <imvert:documentation>
                <xsl:sequence select="$derived-documentation"/>
            </imvert:documentation>
        </xsl:copy>
    </xsl:template>
    
    <!--
        EXPAND THE TAGGED VALUES
        All tagged values must be passed for this construct, including all derived ones. 
        The last specified value prevails. 
        For each tagged value, the derivation origin is specified.
    -->
    <xsl:template match="imvert:tagged-values">
        <xsl:variable name="governing-construct" select="ancestor::imvert:*[imvert:id][1]"/>
        <xsl:copy>
            <xsl:variable name="ds" select="imf:get-compiled-tagged-values($governing-construct,$model-is-traced,false())"/>
            <xsl:for-each select="$ds">
                <imvert:tagged-value>
                    <xsl:attribute name="derivation-project" select="@project"/>
                    <xsl:attribute name="derivation-application" select="@application"/>
                    <xsl:attribute name="derivation-release" select="@release"/>
                    <xsl:attribute name="derivation-local" select="@local"/>
                    <imvert:name original="{@original-name}">
                        <xsl:value-of select="@name"/>
                    </imvert:name>
                    <imvert:value original="{@original-value}">
                        <xsl:value-of select="@value"/>
                    </imvert:value>
                </imvert:tagged-value>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- default: copy all -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
