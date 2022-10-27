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
        Generate a file that lists package dependencies.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:variable name="root-package" select="('stereotype-name-informatiemodel-package','stereotype-name-base-package','stereotype-name-variant-package','stereotype-name-application-package')"/>
        <imvert:package-dependencies>
         
            <xsl:apply-templates select="$document-packages[imvert:name/@original=$application-package-name and imvert:stereotype/@id = $root-package]" mode="package-dependencies"/>
       
            <xsl:variable name="suppliers" select="imf:analyze-supplier-docs(.)"/>
            <!-- avoid duplicates, several models may reference the same supplier -->
            <xsl:for-each-group select="$suppliers" group-by="@subpath">
                <xsl:sequence select="current-group()[1]"/>
                <!-- and write this info to parms -->
                <xsl:sequence select="imf:set-config-string('appinfo','supplier-subpath',current-grouping-key(),false())"/>
            </xsl:for-each-group>
            
        </imvert:package-dependencies>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="package-dependencies">
        <imvert:package id="{imvert:id}" name="{imvert:name}" release="{imvert:release}">
            <xsl:for-each select="imvert:supplier">
                <imvert:supplier  supplier-project="{imvert:supplier-project}" supplier-name="{imvert:supplier-name}" supplier-release="{imvert:supplier-release}"/>
            </xsl:for-each>
        </imvert:package>
        <xsl:variable name="supplier-id" select="imvert:used-package-id"/>
        <xsl:if test="$supplier-id">
            <xsl:apply-templates select="$document-packages[imvert:id=$supplier-id]" mode="package-dependencies"/>
        </xsl:if>
    </xsl:template>
    
    <!-- 
        return a list of imvert:supplier-contents elements, for each supplier-of-a-supplier. 
    -->
    <xsl:function name="imf:analyze-supplier-docs" as="element(imvert:supplier-contents)*">
        <xsl:param name="root" as="element(imvert:packages)"/>
        <xsl:for-each-group select="$root//imvert:supplier[imvert:supplier-project]" group-by="imf:get-trace-supplier-subpath(imvert:supplier-project,imvert:supplier-name,imvert:supplier-release)">
            <xsl:for-each select="current-group()[1]"><!-- singleton -->
                <xsl:variable name="subpath" select="current-grouping-key()"/>
                <xsl:variable name="supplier-doc" select="imf:get-imvert-supplier-doc($subpath)"/>
                <xsl:choose>
                    <xsl:when test="empty($supplier-doc)">
                        <xsl:sequence select="imf:msg(.,'ERROR','Cannot find supplier for subpath [1]',($subpath))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- list of supports expected -->
                        <xsl:variable name="support-config" as="element(support)*"> <!-- TODO configure! -->
                            <support>
                                <!-- identifier for this support level --> 
                                <level>STEREOID</level>
                                <!-- severity of support violation: FATAL ERROR WARNING INFO --> 
                                <severity>ERROR</severity>
                                <!-- description to be shown in error message --> 
                                <info>Stereotypes must have an ID</info>
                                <!-- what minimum version is the feature implemented in? -->
                                <version>1.39.0</version>
                            </support>
                        </xsl:variable>
                        
                        <xsl:variable name="support-levels" select="$support-config/level"/>
                        <xsl:variable name="supplier-supports" select="$supplier-doc/imvert:packages/imvert:supports/imvert:support"/>
                        <xsl:variable name="supplier-support-levels" select="$supplier-supports/imvert:level"/>
                        <xsl:variable name="missing-supplier-support" select="for $s in $support-levels return if ($s eq $supplier-support-levels) then () else $s"/>
                        <xsl:choose>
                            <!-- test if supplier is upgraded to a certain level -->
                            <xsl:when test="exists($missing-supplier-support)">
                                <xsl:for-each select="$support-config[level = $missing-supplier-support]">
                                   <xsl:sequence select="imf:msg(.,severity,'Supplier not upgraded: [1]. Please upgrade [2] first to version [3] or later.',(info,$subpath,version))"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <imvert:supplier-contents subpath="{$subpath}">
                                    <xsl:sequence select="$supplier-doc"/>
                                </imvert:supplier-contents>
                                <xsl:sequence select="imf:analyze-supplier-docs($supplier-doc/imvert:packages)"/>
                            </xsl:otherwise>
                        </xsl:choose>                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each-group>
    </xsl:function>
    
</xsl:stylesheet>
