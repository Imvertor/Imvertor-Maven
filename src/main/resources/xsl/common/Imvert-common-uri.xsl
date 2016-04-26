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
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
        return the parts of an uri passed as elements: 
        <protocol>  e.g. http
        <server> e.g. www.armatiek.nl
        <path> e.g. projecten.html
        
        Access as e.g. imf:get-uri-parts("http://www.armatiek.nl/projecten.html")/path
    -->
    <xsl:function name="imf:get-uri-parts" as="element()*">
        <xsl:param name="uri" as="xs:string?"/>
        <xsl:if test="$uri">
            <xsl:variable name="uri-parts" select="tokenize($uri,'/')"/>
            <!-- 1 http://abc -->
            <!-- 2 uri:abc -->
            <!-- 3 /abc -->
            <xsl:variable name="type" select="
                if ($uri-parts[2]='' and ends-with($uri-parts[1],':')) then '1' 
                else if (contains($uri-parts[1],':')) then '2'
                else '3'"/>
            <xsl:choose>
                <xsl:when test="$type='1'">
                    <xsl:sequence select="imf:get-uri-parts-elements($uri-parts[1],$uri-parts[3],string-join(subsequence($uri-parts,4),'/'))"></xsl:sequence>
                </xsl:when>
                <xsl:when test="$type='2'">
                    <xsl:sequence select="imf:get-uri-parts-elements(substring-before($uri-parts[1],':'),'',concat(substring-after($uri-parts[1],':'),string-join(subsequence($uri-parts,2),'/')))"/>
                </xsl:when>
                <xsl:when test="$type='3'">
                    <xsl:sequence select="imf:get-uri-parts-elements('','',string-join($uri-parts,'/'))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
      </xsl:function>
    
    <xsl:function name="imf:get-uri-parts-elements" as="element()*">
        <xsl:param name="protocol"/>
        <xsl:param name="server"/>
        <xsl:param name="path"/>
        <uri>
            <protocol xmlns="">
                <xsl:value-of select="$protocol"/>
            </protocol>
            <server xmlns="">
                <xsl:value-of select="$server"/>
            </server>
            <path xmlns="">
                <xsl:value-of select="$path"/>
            </path>
        </uri>
    </xsl:function>
    
 </xsl:stylesheet>
