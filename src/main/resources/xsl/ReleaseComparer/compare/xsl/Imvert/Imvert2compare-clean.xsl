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
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    xmlns:html="http://www.w3.org/1999/xhtml" 
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"

    xmlns:dfx="http://www.topologi.com/2005/Diff-X" 
    xmlns:del="http://www.topologi.com/2005/Diff-X/Delete" 
    xmlns:ins="http://www.topologi.com/2005/Diff-X/Insert"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
       Compare two Imvert result files. This styelsheet cleans the infomation based on the type of comparison intended:
        
        D include for documentation release filter: compare of all non-documentary information
        I include for information compare: full comparison of all informative aspects of the model.
        V include for derivation filter: compare of all info, excluding stuff that is application specific such as names and release numbers
        R include for release filter: compare of all significant (non)-documentary information
        
       See Jira IM-147 "Documentatie release ondersteunen" and "IM-416 Compare aanbieden op supplier en op eerdere release"
    -->
   
    <xsl:import href="Imvert2compare-common.xsl"/>
    
    <xsl:output indent="no"/>
    
    <!-- create to representations, removing all documentation level elements -->
    <xsl:template match="/">
        <xsl:variable name="all">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:apply-templates select="$all" mode="nonempty"/> <!-- remove all elements that have no content --> 
    </xsl:template>
    
    <xsl:template match="imvert-result:*">
        <!-- 
            if tagged value, then determine the key, else use the local name. 
            The key must be same as the @form on any elm element in the config. 
        -->
        <xsl:variable name="use-name" select="if (self::imvert-result:TaggedValue) then concat('tv_',imvert-result:name) else local-name()"/>
        <xsl:variable name="info" select="key('imvert-compare-config',$use-name,$imvert-compare-config-doc)[last()]"/>
        
        <!--<xsl:message select="concat($use-name, '/', $info,'/',$info/@use,'/',$imvert-compare-mode)"/>-->
        
        <xsl:variable name="must-copy" select="contains($info/@use,$imvert-compare-mode)"/>
        
        <xsl:choose>
            <xsl:when test="$include-reference-packages = 'false' and exists(imvert-result:reference)">
                <!-- ignore -->
            </xsl:when>
            <xsl:when test="$identify-construct-by-function = 'id' and local-name() = 'id'">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="$identify-construct-by-function = 'name' and local-name() = 'name'">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="$must-copy and starts-with($use-name,'tv_')">
                <xsl:sequence select="."/>
            </xsl:when>
            <xsl:when test="$must-copy">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="exists(imvert-result:*)">
                <!-- there are subelements; this is probably a wrapper -->
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- ignore -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="html:*">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="*" mode="nonempty">
        <xsl:choose>
            <xsl:when test=".//text()">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="node()" mode="nonempty"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- ignore -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()" mode="nonempty">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="processing-instruction()|comment()" mode="#all">
        <!-- ignore -->
    </xsl:template>
    
</xsl:stylesheet>
