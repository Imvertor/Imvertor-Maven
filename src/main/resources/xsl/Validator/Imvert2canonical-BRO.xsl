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
          Transform BP UML constructs to canonical UML constructs.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- generate the correct name here -->
    <xsl:template match="imvert:found-name">
        <xsl:variable name="type" select="
            if (parent::imvert:package) then 'package-name' else 
            if (parent::imvert:attribute) then 'property-name' else
            if (parent::imvert:association) then 'property-name' else 'class-name'"/>
        <imvert:name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,$type)"/>
        </imvert:name>
    </xsl:template>
    
    <xsl:template match="imvert:supplier-packagename">
        <imvert:supplier-package-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:supplier-package-name>
    </xsl:template>
    
    <!-- generate the correct name for types specified, but only when the type is declared as a class (i.e. no system types) -->
    <xsl:template match="imvert:*[imvert:type-id]/imvert:type-name">
        <imvert:type-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'class-name')"/>
        </imvert:type-name>
    </xsl:template>
    
    <!-- generate the correct name for packages of types specified -->
    <xsl:template match="imvert:type-package">
        <imvert:type-package original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:type-package>
    </xsl:template>
    
    <!-- when composition, and no name, generate name of the target class on that composition relation -->
    <!-- 
        KKG ISO doesnt require composition relation stereotype.
        when composition, and no stereotype, put the composition stereotype there -->
    <xsl:template match="imvert:association[imvert:aggregation='composite']">
        <imvert:association>
            <xsl:choose>
                <xsl:when test="empty(imvert:found-name)">
                    <imvert:name original="" origin="system">
                        <xsl:value-of select="imf:get-normalized-name(imvert:type-name,'property-name')"/>
                    </imvert:name>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:found-name"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="empty(imvert:stereotype)">
                    <imvert:stereotype origin="system">
                        <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-association-to-composite')"/>
                    </imvert:stereotype>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:stereotype"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[not(self::imvert:stereotype or self::imvert:found-name)]"/>
        </imvert:association>
    </xsl:template>
    
    <xsl:template match="imvert:phase">
        <xsl:variable name="original" select="normalize-space(lower-case(.))"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="original" select="$original"/>
            <xsl:choose>
                <xsl:when test="$original='1.0'">1</xsl:when> 
                <xsl:when test="$original='concept'">0</xsl:when> 
                <xsl:when test="$original='draft'">1</xsl:when> 
                <xsl:when test="$original='finaldraft'">2</xsl:when> 
                <xsl:when test="$original='final draft'">2</xsl:when> 
                <xsl:when test="$original='final'">3</xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="$original"/>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- transform inspire notes to tagged values -->
    <xsl:template match="imvert:tagged-values">
        <xsl:copy>
            <!-- first copy all existing; only when a value is specified  -->
            <xsl:apply-templates select="imvert:tagged-value[normalize-space(imvert:value)]"/>
            
            <!-- then add the tvs extracted from notes -->
            <xsl:variable name="construct" select=".."/>
            <xsl:for-each select="$construct/imvert:documentation/section">
                <xsl:variable name="title" select="title"/>
                <xsl:variable name="norm-title" select="upper-case($title)"/>
                <xsl:variable name="body" select="body"/>
                
                <xsl:variable name="target-tv-id" select="$configuration-notesrules-file/notes-rule[@lang=$language]/section[upper-case(@title) = $norm-title]/@tagged-value"/>
                
                <xsl:variable name="current-tv" select="imf:get-tagged-value-by-id($construct,$target-tv-id)/imvert:value"/> <!-- the current tagged value if any -->
                
                <xsl:choose>
                    <xsl:when test="empty($target-tv-id)">
                        <xsl:sequence select="imf:msg($construct,'WARN','Notes field [1] not recognized, and skipped',$title)"/>
                    </xsl:when>
                    <xsl:when test="normalize-space($body) and normalize-space($current-tv)">
                        <xsl:sequence select="imf:msg($construct,'ERROR','Tagged value [1] in notes field [2] already specified',($target-tv-id,$title))"/>
                    </xsl:when>
                    <xsl:when test="normalize-space($body)">
                        <imvert:tagged-value origin="notes" id="{$target-tv-id}">
                            <imvert:name original="{$title}">
                                <xsl:value-of select="$norm-title"/>
                            </imvert:name>
                            <imvert:value>
                                <xsl:value-of select="$body"/>
                            </imvert:value>
                        </imvert:tagged-value>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
  
    <xsl:function name="imf:get-tagged-value-by-id" as="element(imvert:tagged-value)*">
        <xsl:param name="construct"/>
        <xsl:param name="tv-id"/>
        <xsl:sequence select="$construct/imvert:tagged-values/imvert:tagged-value[@id = $tv-id]"/>
    </xsl:function>
   
</xsl:stylesheet>
