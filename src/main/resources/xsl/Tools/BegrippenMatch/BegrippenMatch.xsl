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
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    
    xmlns:uml="http://schema.omg.org/spec/UML/2.1" 
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" 
 
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns="http://www.w3.org/1999/xhtml"
    
    version="2.0">
    
    <xsl:param name="kenniskluis-file-path"/>
    <xsl:param name="kenniskluis-namemap-file-path"/>
    
    <xsl:variable name="kenniskluis-doc" select="document($kenniskluis-file-path)"/>
    <xsl:variable name="kenniskluis-namemap-doc" select="document($kenniskluis-namemap-file-path)"/>
    
    <xsl:template match="/">
        <xsl:message select="$kenniskluis-file-path"/>
        <html>
            <head>
                <style>
                    td { 
                        align: left; 
                        vertical-align: top; 
                    }
                    table {
                        border-collapse: collapse;
                    }
                    table, th, td {
                        border: 1px solid black;
                    }
                </style>
            </head>
            <body>
                <table>
                    <xsl:apply-templates select="//imvert:class"/>
                </table>
            </body>
        </html>
    </xsl:template>
        
    <xsl:template match="*[(self::imvert:class | self::imvert:attribute | self::imvert:association) and empty(imvert:ref-master)]">
        <xsl:variable name="nname" select="imf:norm-name(imvert:name/@original)"/>
        <xsl:variable name="concept" select="$kenniskluis-doc//*[imvert:label[@lang='nl'][imf:norm-name(.) = $nname]]"/>
        <tr>
            <td>
                <xsl:value-of select="local-name()"/>
            </td>
            <td>
                <a href="{$concept/imvert:uri}" target="kenniskluis">
                    <xsl:value-of select="$concept/imvert:uri"/>
                </a>
            </td>
            <td>
                <xsl:value-of select="@display-name"/>
            </td>
            <td>
                <xsl:value-of select="$concept/imvert:definition[@lang='nl']"/>
            </td>
            <td>
                <xsl:value-of select="$concept/imvert:explanation[@lang='nl']"/>
            </td>
            <td>
                <xsl:sequence select="imvert:documentation/*"/>
            </td>
        </tr>
        <xsl:apply-templates select="*/imvert:attribute"/>
        <xsl:apply-templates select="*/imvert:association"/>
    </xsl:template>
   
    <xsl:function name="imf:norm-name">
        <xsl:param name="name"/>
        <xsl:variable name="kk-name" select="$kenniskluis-namemap-doc/config/map[@im=$name]/@kk"/>
        <xsl:variable name="select-name" select="if (exists($kk-name)) then $kk-name else $name"/>
        <xsl:value-of select="upper-case(string-join(tokenize($select-name,'[^a-zA-Z]'),''))"/>
    </xsl:function>
    
    <!-- default -->
    <xsl:template match="node()">
        <!-- remove -->
    </xsl:template>
    
</xsl:stylesheet>