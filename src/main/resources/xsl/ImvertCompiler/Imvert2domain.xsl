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
        Verwijder alle packages die binnen een domain package vallen.
        Verwijder tevens alle packages die tussen root package en domain vallen.
        
        Dus als wordt verwezen naar een object in subdomain, dan wordt dat vervangen door het domein waar het onderdeel van is.
        Subdomeinen zijn slechts een groeperingsconstructie tbv. UML en spelen geen rol in XSD (en documentatie).
        
        Dit stylesheet plaatst tevens de base-namespace op alle packages.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <!-- bepaal welke package de applicatie bevat -->
    <xsl:variable name="base-package" select="
        $document-packages[imvert:name=imf:get-normalized-name($application-package-name,'package-name') 
        and 
        imvert:stereotype/@id = ('stereotype-name-base-package','stereotype-name-application-package')]"/>
    
    <xsl:variable name="known-package" select="(
        'stereotype-name-domain-package',
        'stereotype-name-view-package',
        'stereotype-name-base-package', 
        'stereotype-name-application-package', 
        'stereotype-name-system-package', 
        'stereotype-name-components-package', 
        'stereotype-name-external-package',
        'stereotype-name-internal-package')"/>
    
    <xsl:variable name="domain-mapping" as="node()*">
        <xsl:for-each select="$base-package/descendant-or-self::imvert:package">
            <xsl:variable name="domain" select="ancestor-or-self::imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-view-package')][1]"/>
            <map sd-name="{imvert:name}" sd-id="{imvert:id}" d-name="{if ($domain) then $domain/imvert:name else imvert:name}"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="*[not(self::imvert:package or self::imvert:filters)]"/>
            <xsl:sequence select="imf:create-output-element('imvert:base-namespace',$base-package/imvert:namespace)"/>
            <xsl:sequence select="imf:create-output-element('imvert:version',$base-package/imvert:version)"/>
            <xsl:sequence select="imf:create-output-element('imvert:phase',$base-package/imvert:phase)"/>
            <!--<xsl:sequence select="imf:create-output-element('imvert:release',$base-package/imvert:release)"/>-->
            <!--<xsl:sequence select="imf:create-output-element('imvert:documentation',$base-package/imvert:documentation/node(),'',false(),false())"/>-->
            <imvert:filters>
                <xsl:sequence select="imvert:filters/imvert:filter"/>
                <xsl:sequence select="imf:compile-imvert-filter()"/>
            </imvert:filters>
            <xsl:choose>
                <xsl:when test="empty($base-package)">
                    <xsl:sequence select="imf:msg('ERROR','No package [1] defined with stereotype base or application. Is the name valid?',$application-package-name)"/>
                </xsl:when>
                <xsl:when test="empty($base-package/imvert:namespace)">
                    <xsl:sequence select="imf:msg('ERROR','No root namespace defined.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:package"/>
                </xsl:otherwise>
            </xsl:choose>
        </imvert:packages>
    </xsl:template>
    
    <!-- een package dat geen domain is en valt binnen een root package wordt verwijderd. -->
    <xsl:template match="imvert:package[not(imvert:stereotype/@id = $known-package)]">
        <!-- een package dat ergens binnen een domein package is opgenomen wordt verwijderd -->
        <xsl:if test="ancestor::imvert:package/imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-view-package')">
            <xsl:apply-templates select="imvert:class"/>
        </xsl:if>
        <xsl:apply-templates select="imvert:package"/>
    </xsl:template>
    
    <xsl:template match="imvert:type-package">
        <xsl:variable name="type-id" select="../imvert:type-id"/>
        <xsl:variable name="type-package" select="$base-package/descendant-or-self::imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-view-package') and .//imvert:id = $type-id]"/>
        <xsl:choose>
            <xsl:when test="../imvert:baretype">
               <!-- remove -->
            </xsl:when>
            <xsl:when test=". eq $type-package/imvert:name">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-output-element('imvert:type-package',($type-package/imvert:name,.)[1])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <imvert:class>
            <xsl:apply-templates/>
            <xsl:variable name="subpackages" select="imf:get-package-structure(.)"/>
            <xsl:for-each select="$subpackages">
                <xsl:sequence select="imf:create-output-element('imvert:subpackage',imvert:name)"/>
            </xsl:for-each>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Return all packages that the element is part of, that are (within) a domain package -->
    <xsl:function name="imf:get-package-structure" as="element()*">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="$this/ancestor-or-self::imvert:package"/>
    </xsl:function>
</xsl:stylesheet>