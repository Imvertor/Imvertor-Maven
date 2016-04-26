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

    xmlns:imvert-appconfig="http://www.imvertor.org/schema/appconfig"

    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!-- 
        Context document is the canonized imvertor base file.
        Apply the commands stored in Excel, passed as a appconfig XML file.
    -->

    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output indent="no"/>
    
    <xsl:variable name="imvert-appconfig-path" select="imf:get-config-string('properties','WORK_APPCONFIG_FILE')"/>
    <xsl:variable name="imvert-appconfig-url" select="imf:filespec($imvert-appconfig-path)[2]"/>
    
    <xsl:variable name="apc-document" select="imf:document($imvert-appconfig-url)/imvert-appconfig:appconfig"/>
    
    <xsl:variable name="apc-application-name" select="$apc-document/imvert-appconfig:application-name"/>
    <xsl:variable name="apc-application-version" select="$apc-document/imvert-appconfig:application-version"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- packages within the application -->
    <xsl:template match="imvert:*[ancestor-or-self::imvert:package/imvert:name/@original = $apc-application-name]/imvert:tagged-values">
     
        <xsl:variable name="this" select=".."/>

        <xsl:variable name="current-package-name" select="ancestor-or-self::imvert:package/imvert:name/@original"/>
        <xsl:variable name="current-class-name" select="ancestor-or-self::imvert:class/imvert:name/@original"/>
        <xsl:variable name="current-attribute-name" select="ancestor-or-self::imvert:attribute/imvert:name/@original"/>
        <xsl:variable name="current-association-name" select="ancestor-or-self::imvert:association/imvert:name/@original"/>
        
        <imvert:tagged-values>
            <!-- first delete any -->
            <xsl:variable name="step1" as="element()*">
                <xsl:for-each select="imvert:tagged-value">
                    <xsl:variable name="current-tv-name" select="imvert:name"/>
                    <xsl:choose>
                        <xsl:when test="
                            $this/self::imvert:package and 
                            $apc-document/imvert-appconfig:command[
                                @level = 'package' and 
                                imvert-appconfig:modifier = 'del-tagged-value' and
                                imvert-appconfig:package = $current-package-name and 
                                imvert-appconfig:name = $current-tv-name]">
                            <!-- delete = skip -->
                        </xsl:when>
                        <xsl:when test="
                            $this/self::imvert:class and 
                            $apc-document/imvert-appconfig:command[
                                @level = 'class' and 
                                imvert-appconfig:modifier = 'del-tagged-value' and
                                imvert-appconfig:package = $current-package-name and 
                                imvert-appconfig:class = $current-class-name and 
                                imvert-appconfig:name = $current-tv-name]">
                            <!-- delete = skip -->
                        </xsl:when>
                        <xsl:when test="
                            $this/self::imvert:attribute and 
                            $apc-document/imvert-appconfig:command[
                                @level = 'attribute' and 
                                imvert-appconfig:modifier = 'del-tagged-value' and
                                imvert-appconfig:package = $current-package-name and 
                                imvert-appconfig:class = $current-class-name and 
                                imvert-appconfig:attribute = $current-attribute-name and 
                                imvert-appconfig:name = $current-tv-name]">
                            <!-- delete = skip -->
                        </xsl:when>
                        <xsl:when test="
                            $this/self::imvert:association and 
                            $apc-document/imvert-appconfig:command[
                                @level = 'relation' and 
                                imvert-appconfig:modifier = 'del-tagged-value' and
                                imvert-appconfig:package = $current-package-name and 
                                imvert-appconfig:class = $current-class-name and 
                                imvert-appconfig:relation = $current-association-name and 
                                imvert-appconfig:name = $current-tv-name]">
                            <!-- delete = skip -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:sequence select="$step1"/>
            
            <!-- then add some -->
            <xsl:for-each select="$apc-document/imvert-appconfig:command[imvert-appconfig:modifier = 'add-tagged-value']">
                <xsl:variable name="must-copy" as="xs:string?">
                    <xsl:choose>
                        <xsl:when test="
                            $this/self::imvert:package and 
                            @level = 'package' and 
                            imvert-appconfig:package = $current-package-name
                            ">true</xsl:when>
                        <xsl:when test="
                            $this/self::imvert:class and 
                            @level = 'class' and 
                            imvert-appconfig:package = $current-package-name and 
                            imvert-appconfig:class = $current-class-name 
                            ">true</xsl:when>
                        <xsl:when test="
                            $this/self::imvert:attribute and 
                            @level = 'attribute' and 
                            imvert-appconfig:package = $current-package-name and 
                            imvert-appconfig:class = $current-class-name and  
                            imvert-appconfig:attribute = $current-attribute-name 
                            ">true</xsl:when>
                        <xsl:when test="
                            $this/self::imvert:association and 
                            @level = 'relation' and 
                            imvert-appconfig:package = $current-package-name and 
                            imvert-appconfig:class = $current-class-name and  
                            imvert-appconfig:relation = $current-association-name 
                            ">true</xsl:when>
                        <xsl:otherwise>false</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$must-copy = 'true'">
                    <imvert:tagged-value origin="apc">
                        <imvert:name><xsl:value-of select="imvert-appconfig:name"/></imvert:name>
                        <imvert:value><xsl:value-of select="imvert-appconfig:value"/></imvert:value>
                    </imvert:tagged-value>
                </xsl:if>
            </xsl:for-each>
        </imvert:tagged-values>
    </xsl:template>
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
