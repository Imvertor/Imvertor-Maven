<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 VNG/KING
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
  
    xmlns:ws="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Stylesheet to filter ANY xml file found in the tst or ref folder.
         This XSL is generic, and therefore calls upon any imported XSL (or such) to process specific types of file.
         The root element of the file found is passed in a wrapper element:
         
         <cw:file 
            type="{bin or xml}" 
            path="{relative path to the root of the main folder, including name of the file}" 
            date="{integer representation of date}" 
            name="{name of the file}" 
            ishidden="{boolean}" 
            isreadonly="{boolean}" 
            ext="{extension}" 
            fullpath="{full canonical path}"/>
         
         Note that date/time attribute and size attribute typically should be removed for regression comparisons.
         The other *:file data should be passed for reporting purposes.
      -->
    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
    
    <xsl:template match="/">
        <xsl:for-each select="cw:file">
            <xsl:sort select="@path" order="ascending"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/cw:file">
        <xsl:choose>
            <!-- 
                skip all XMI files 
            -->
            <xsl:when test="lower-case(@ext) = ('xmi')">
                <!-- ignore -->
            </xsl:when>
            <!-- 
                skip all binary files. 
                Assume that all differences in output can be explained by looking at the XML intermediate results. 
            -->
            <xsl:when test="@type = 'bin'">
                <!-- ignore -->
            </xsl:when>
            <!--
                Pass on for more fine-grained filtering
            -->    
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
