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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy" 
    >
    
    <!-- 
       Canonization of MIM 1.0 models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- 
        enumerations and enums are not required when designation is enumeration. Add when not already specified by the UML 
        see https://github.com/Imvertor/Imvertor-Maven/issues/63
   
        we add priorities in the code below as we do not yet validate but type assignments may have been made to enumerations (which is invalid).
        
    -->
    <xsl:template match="imvert:class[imvert:designation = 'enumeration']" priority="1">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="not(imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist'))">
                <imvert:stereotype id="stereotype-name-enumeration" origin="system">
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-enumeration')"/>
                </imvert:stereotype>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation = 'enumeration']/imvert:attributes/imvert:attribute" priority="2">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="not(imvert:stereotype/@id = ('stereotype-name-enum'))">
                <imvert:stereotype id="stereotype-name-enum" origin="system">
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-enum')"/>
                </imvert:stereotype>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        add facets when these are specified as a tagged value 
    -->
    <xsl:template match="imvert:attribute[imvert:type-name = 'scalar-integer']" priority="3">
        <xsl:variable name="parse" select="imf:parse-scalar-length(imf:get-tagged-value(.,'##CFG-TV-LENGTH'))"/>
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:sequence select="imf:create-output-element('imvert:total-digits',$parse/max)"/>
            <xsl:sequence select="if ($parse/error) then imf:msg(.,$parse/error) else ()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:attribute[imvert:type-name = ('scalar-decimal','scalar-real')]" priority="4"><!-- TODO actually, decimal is not a MIM10 concept -->
        <xsl:variable name="parse" select="imf:parse-scalar-length(imf:get-tagged-value(.,'##CFG-TV-LENGTH'))"/>
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="$parse/error">
                    <xsl:sequence select="imf:msg(.,$parse/error)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:create-output-element('imvert:fraction-digits',$parse/post)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:total-digits',xs:integer($parse/pre) + xs:integer($parse/post))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:attribute[imvert:type-name = 'scalar-string']" priority="5">
        <xsl:variable name="pat" select="if (imvert:pattern) then () else imf:get-tagged-value(.,'##CFG-TV-FORMALPATTERN')"/>
        <xsl:variable name="parse" select="if (imvert:max-length) then () else imf:parse-scalar-length(imf:get-tagged-value(.,'##CFG-TV-LENGTH'))"/>
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:sequence select="imf:create-output-element('imvert:pattern',$pat)"/>
            <xsl:sequence select="imf:create-output-element('imvert:max-length',$parse/max)"/>
            <xsl:sequence select="if ($parse/error) then imf:msg(.,$parse/error) else ()"/>
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
   
   <!--
       Bijvoorbeeld:
        ‘1’ als de lengte exact 1 is; 
        ‘1..2’ als de lengte 1 tot en met 2 lang kan zijn;
        '‘1,2’ voor Decimale getallen met 1 cijfer voor de komma en 2 erna. Dit is van -9,99 tot +9,99;
    
    -->
    <xsl:function name="imf:parse-scalar-length" as="element()?">
        <xsl:param name="length-string" as="xs:string?"/>
        <xsl:if test="normalize-space($length-string)">
            <parse>
                <xsl:analyze-string select="$length-string" regex="^(\d+)(((\.\.)|(,))(\d+))?$">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="not(normalize-space(regex-group(2)))">
                                <max><xsl:value-of select="regex-group(1)"/></max>
                            </xsl:when>
                            <xsl:when test="regex-group(3) = '..' and normalize-space(regex-group(6))">
                                <min><xsl:value-of select="regex-group(1)"/></min>
                                <max><xsl:value-of select="regex-group(6)"/></max>
                            </xsl:when>
                            <xsl:when test="regex-group(3) = ',' and normalize-space(regex-group(6))">
                                <pre><xsl:value-of select="regex-group(1)"/></pre>
                                <post><xsl:value-of select="regex-group(6)"/></post>
                            </xsl:when>
                            <xsl:otherwise>
                                <error>Length has invalid format</error>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <error>Length has unrecognized format</error>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </parse>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
