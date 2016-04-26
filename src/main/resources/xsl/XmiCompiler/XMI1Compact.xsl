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
    xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    xmlns:UML="omg.org/UML1.3"
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
    xmlns:EAUML="http://www.sparxsystems.com/profiles/EAUML/1.0"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    
    <!-- Compact the XMI to only the relevant sections -->
 
    <xsl:variable name="document" select="/"/>

    <xsl:variable name="all-packages" select="//UML:Package"/>
    
    <xsl:variable name="project-packages" select="$all-packages[imf:get-xmi-stereotype(.) = imf:get-config-stereotypes('stereotype-name-project-package')]"/>
    <xsl:variable name="external-packages" select="$all-packages[imf:get-xmi-stereotype(.) = imf:get-config-stereotypes('stereotype-name-external-package')]"/>
    <xsl:variable name="app-package" select="$all-packages[imf:get-normalized-name(@name,'package-name') = imf:get-normalized-name($application-package-name,'package-name')]"/>
    <xsl:variable name="containing-packages" select="$app-package/ancestor::UML:Package"/>
    <xsl:variable name="project-package" select="$app-package/ancestor::UML:Package[. = $project-packages]"/>
    
    <xsl:template match="/">
       <xsl:choose>
           <xsl:when test="empty($project-package)">
               <xsl:sequence select="imf:msg('FATAL','No project found for application: [1]', $application-package-name)"/>
           </xsl:when>
           <xsl:when test="empty($project-package)">
               <xsl:sequence select="imf:msg('FATAL','No application found: [1]', $application-package-name)"/>
           </xsl:when>
           <xsl:otherwise>
               <xsl:apply-templates/>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
    
    <!-- 
        Create a full copy of the package and sub-structures for the application.
    -->
  
    <!-- copy all packages except those what are not witin application, or not external) -->
    <xsl:template match="UML:Package">
        <!-- package contains the app? -->
        <xsl:variable name="holds-app" select=". = $containing-packages"/>
        <!-- package is (part of) the app? -->
        <xsl:variable name="is-in-app" select="ancestor-or-self::UML:Package = $app-package"/>
        <!-- package is external? -->
        <xsl:variable name="is-in-ext" select="ancestor-or-self::UML:Package = $external-packages"/>
        <xsl:choose>
            <xsl:when test="$holds-app">
                <xsl:if test="imf:boolean($debug)">
                    <xsl:comment select="concat(@name, ' added becauee: holds-app')"/>
                </xsl:if>
                <xsl:next-match/>            
            </xsl:when>
            <xsl:when test="$is-in-ext">
                <xsl:if test="imf:boolean($debug)">
                    <xsl:comment select="concat(@name, ' added becauee: is-in-ext')"/>
                </xsl:if>
                <xsl:next-match/>            
            </xsl:when>
            <xsl:when test="$is-in-app">
                <xsl:if test="imf:boolean($debug)">
                    <xsl:comment select="concat(@name, ' added becauee: is-in-app')"/>
                </xsl:if>
                <xsl:next-match/>            
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="imf:boolean($debug)">
                    <xsl:comment select="concat(@name, ' purged')"/>
                </xsl:if>
                <!-- if any trace info available, copy those traces to a separate XMI section -->
                <extracted-traces>
                    <xsl:apply-templates select=".//UML:Association[UML:ModelElement.stereotype/UML:Stereotype/@name = 'trace']"/>
                </extracted-traces>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="imf:get-xmi-stereotype" as="xs:string*">
        <xsl:param name="construct"/>
        <xsl:sequence select="for $c in ($construct/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='stereotype']/@value) return imf:get-normalized-name($c,'stereotype-name')"/>
    </xsl:function>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
