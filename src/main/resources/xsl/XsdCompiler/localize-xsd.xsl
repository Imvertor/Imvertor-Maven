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
       Translate URIs for imports and includes within the source XSD based on
       the mapping passed.
       This is part of the strategy to maintain a set of external schema's 
       needed for CDMKAD based schema's, and pass as a local copy in the distributions.
    -->
    
    <xsl:include href="../common/Imvert-common.xsl"/>
    
    <xsl:param name="local-schema-folder-name">unknown-folder</xsl:param>
    <xsl:param name="local-schema-mapping-file">unknown-file</xsl:param>
    
    <xsl:variable name="local-schema-mapping" select="imf:document($local-schema-mapping-file)/local-schemas"/>
    
    <xsl:variable name="local-mapping-notification" select="imf:get-config-parameter('local-mapping-notification')"/>
    
    <xsl:template match="/xs:schema">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:comment>
                <xsl:value-of select="concat('&#10;',normalize-space($local-mapping-notification),'&#10;')"/>
            </xsl:comment>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="xs:import/@schemaLocation">
        <xsl:attribute name="schemaLocation" select="imf:get-local-uri(.)"/>
    </xsl:template>
    <xsl:template match="xs:include/@schemaLocation">
        <xsl:attribute name="schemaLocation" select="imf:get-local-uri(.)"/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:function name="imf:get-local-uri" as="xs:string">
        <xsl:param name="external-location" as="xs:string"/>
        <xsl:variable name="local-schema" select="$local-schema-mapping/local-schema[@schemafolder=$local-schema-folder-name]"/>
        <xsl:variable name="local-map" 
            select="$local-schema/local-map[starts-with($external-location,@source-uri-prefix)]"/>
        <xsl:variable name="local-location" select="concat($local-map/@target-uri-prefix,substring-after($external-location,$local-map/@source-uri-prefix))"/>
        <xsl:value-of select="
            if ($local-map) 
            then $local-location
            else $external-location"/>
    </xsl:function>
    
</xsl:stylesheet>
