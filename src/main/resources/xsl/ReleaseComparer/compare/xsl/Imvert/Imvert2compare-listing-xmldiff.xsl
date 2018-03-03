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
    
    xmlns:deltaxml="http://www.armatiek.com/xslweb/diff/well-formed-delta"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-result="http://www.kadaster.nl/schemas/imvertor/application/v20141001"
    
    version="2.0">

    <!--
        Process the results of XMLdiff.
    -->
   
    <xsl:import href="Imvert2compare-common.xsl"/>
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:variable name="ctrl-url" select="concat('file:/', replace($ctrl-filepath,'\\','/'))"/>
    <xsl:variable name="test-url" select="concat('file:/', replace($test-filepath,'\\','/'))"/>

    <!-- context document is difference result xml -->
    <xsl:template match="/root-of-compare">
        <imvert:report>
            <imvert:ctrl>
                <xsl:value-of select="$ctrl-url"/>
            </imvert:ctrl>           
            <imvert:test>
                <xsl:value-of select="$test-url"/>
            </imvert:test>    
            <imvert:diffs>
                <xsl:apply-templates select="*"/>
            </imvert:diffs>
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="*">
       
        <xsl:variable name="delta" select="@deltaxml:delta"/>
        <xsl:variable name="level" select="count(ancestor::*)"/>
        
        <xsl:choose>
            <xsl:when test="$delta = 'A=B'">
                <!-- no differences -->
            </xsl:when>
            
            <xsl:when test="self::deltaxml:attributes">
                <!-- skip -->
            </xsl:when>
            
            <xsl:when test="$delta = 'A!=B' and $level = 1">
                <xsl:apply-templates select="*"/>
            </xsl:when>
            
            <xsl:otherwise>
                <imvert:diff>
                    <imvert:compos>
                        <xsl:value-of select="if ($level = 1) then compos else ../compos"/>
                    </imvert:compos>    
                    <imvert:base>
                        <xsl:value-of select="local-name(if ($level = 1) then . else ..)"/>
                    </imvert:base>    
                    <imvert:type>
                        <xsl:value-of select="local-name(if ($level = 2) then . else ())"/>
                    </imvert:type>    
                    <!-- 4 columns -->
                    <imvert:ctrl>
                        <xsl:sequence select="if ($delta = 'A') then '*' else if ($delta = 'A!=B') then imf:get-text-of(.,'A') else '(empty)' "/>
                    </imvert:ctrl>
                    <imvert:test>
                        <xsl:sequence select="if ($delta = 'B') then '*' else if ($delta = 'A!=B') then imf:get-text-of(.,'B') else '(empty)' "/>
                    </imvert:test>
                    <imvert:change>
                        <xsl:value-of select="if ($delta = 'A') then 'removed' else if ($delta = 'B') then 'added' else 'changed' "/>
                    </imvert:change>
                    <imvert:level>user</imvert:level>
                </imvert:diff>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
       
    <xsl:template match="node()|@*" priority="-1">
        <!-- skip -->
    </xsl:template>
    
    <xsl:function name="imf:get-text-of">
        <xsl:param name="elm"/>
        <xsl:param name="label"/> <!-- A or B -->
        <xsl:for-each select="$elm/node()">
            <xsl:variable name="selected" select="deltaxml:text[@deltaxml:delta = $label]"/>
            <xsl:choose>
                <xsl:when test="$selected">
                    <xsl:value-of select="$selected"/>
                </xsl:when>
                <xsl:when test="deltaxml:text">
                      <!--skip-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
</xsl:stylesheet>
