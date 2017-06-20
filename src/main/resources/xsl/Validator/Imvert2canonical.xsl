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
   
    <xsl:variable name="chop" select="imf:boolean(imf:get-config-string('cli','chop','no'))"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation = 'datatype' and empty(imvert:stereotype)]">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <imvert:stereotype origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-simpletype')[1]"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:supertype">
        <xsl:choose>
            <xsl:when test="exists(imvert:type-id) and empty(imf:get-construct-by-id(imvert:type-id)) and $chop">
                <xsl:comment select="concat('Chopped supertype: ', imvert:type-name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:designation = 'enumeration']/imvert:attributes/imvert:attribute">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <imvert:stereotype origin="system">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-enum')[1]"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:association">
        <xsl:choose>
            <xsl:when test="imvert:stereotype = imf:get-config-stereotypes('stereotype-name-trace')">
                <!-- remove explicit trace relations; traces are recorded as imvert:trace (client to supplier) -->
            </xsl:when>
            <xsl:when test="exists(imvert:type-id) and empty(imf:get-construct-by-id(imvert:type-id)) and $chop">
                <xsl:comment select="concat('Chopped association: ', imvert:name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:attribute">
        <xsl:choose>
            <xsl:when test="exists(imvert:type-id) and empty(imf:get-construct-by-id(imvert:type-id)) and $chop">
                <xsl:comment select="concat('Chopped attribute: ', imvert:name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        IM-445
        remove references to a type ID when no type name could be determined 
        This happens when references occur to parts of the EA that are not in scope
    -->
    <xsl:template match="imvert:type-id[empty(../imvert:type-name)]">
        <imvert:type-id>OUT-OF-SCOPE</imvert:type-id>
        <imvert:type-name>OUT-OF-SCOPE</imvert:type-name>
    </xsl:template>
    
    <!-- 
        IM-457
        Replace the position by the taggd value "position" when supplied; otherwise leave unchanged.
    -->
    <xsl:template match="imvert:position">
        <imvert:position>
            <xsl:variable name="tv-pos" select="imf:get-tagged-value(..,'##CFG-TV-POSITION')"/>
            <xsl:value-of select="if (exists($tv-pos)) then $tv-pos else ."/>
        </imvert:position>
    </xsl:template>
    
    <!-- transform inspire notes to tagged values -->
    <xsl:template match="imvert:tagged-values">
        <xsl:copy>
            <!-- first copy all existing; only when a value is specified  -->
            <xsl:apply-templates select="imvert:tagged-value[normalize-space(imvert:value)]"/>
            
            <!-- then add the tvs extracted from notes -->
            <xsl:variable name="construct" select=".."/>
            <xsl:for-each select="$construct[exists(imvert:stereotype)]/imvert:documentation/section"> <!-- only for constructs with stereotyes; no rules are defined for other constructs -->
                <xsl:variable name="title" select="title"/>
                <xsl:variable name="norm-title" select="upper-case($title)"/>
                <xsl:variable name="body" select="body"/>
                
                <xsl:variable name="target-tv-id" select="$configuration-notesrules-file/notes-rule[@lang=$language]/section[upper-case(@title) = $norm-title]/@tagged-value"/>
                
                <xsl:variable name="current-tv" select="imf:get-tagged-value-by-id($construct,$target-tv-id)/imvert:value"/> <!-- the current tagged value if any -->
                
                <xsl:choose>
                    <xsl:when test="not(normalize-space($title))">
                        <xsl:sequence select="imf:msg($construct,'WARN','Notes field has invalid format',())"/>
                    </xsl:when>
                    <xsl:when test="empty($target-tv-id)">
                        <xsl:sequence select="imf:msg($construct,'WARN','Notes field [1] not recognized, and skipped',$title)"/>
                    </xsl:when>
                    <xsl:when test="normalize-space($body) and normalize-space($current-tv)">
                        <xsl:sequence select="imf:msg($construct,'ERROR','Tagged value [1] in notes field [2] already specified',($target-tv-id,$title))"/>
                    </xsl:when>
                    <xsl:when test="normalize-space($body)">
                        <imvert:tagged-value origin="notes" id="{$target-tv-id}">
                            <imvert:name original="{$title}"><!-- Natural name -->
                                <xsl:value-of select="$norm-title"/> 
                            </imvert:name>
                            <imvert:value>
                                <xsl:value-of select="string-join(for $l in $body/*/* return imf:strip-ea-html($l),'&#10;')"/>
                            </imvert:value>
                        </imvert:tagged-value>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!-- add an @original attibute to maintain original value before canonization -->
    <xsl:template match="imvert:phase">
        <xsl:copy>
            <xsl:attribute name="original" select="."/>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="imf:get-tagged-value-by-id" as="element(imvert:tagged-value)*">
        <xsl:param name="construct"/>
        <xsl:param name="tv-id"/>
        <xsl:sequence select="$construct/imvert:tagged-values/imvert:tagged-value[@id = $tv-id]"/>
    </xsl:function>
    
    <xsl:function name="imf:strip-ea-html">
        <xsl:param name="text"/>
        <xsl:value-of select="imf:replace-inet-references($text)"/>
    </xsl:function>
    
</xsl:stylesheet>
