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
      Build the configuration file.
    -->
   
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="configuration-owner-file" select="imf:prepare-config(imf:document($configuration-owner-name))"/>
    <xsl:variable name="configuration-metamodel-file" select="imf:prepare-config(imf:document($configuration-metamodel-name))"/>
    <xsl:variable name="configuration-schemarules-file" select="imf:prepare-config(imf:document($configuration-schemarules-name))"/>
    <xsl:variable name="configuration-tvset-file" select="imf:prepare-config(imf:document($configuration-tvset-name))"/>
    
    <xsl:template match="/">
        <config>
            <xsl:sequence select="$configuration-owner-file"/>
            <xsl:sequence select="$configuration-metamodel-file"/>
            <xsl:sequence select="$configuration-schemarules-file"/>
            <xsl:sequence select="$configuration-tvset-file"/>
        </config>
    </xsl:template>
    
    <!-- name normalization on all configuration files -->
    
    <xsl:function name="imf:prepare-config">
        <xsl:param name="document" as="document-node()?"/>
        <xsl:apply-templates select="$document" mode="prepare-config"/>
    </xsl:function>
    
    <xsl:template match="tv/name" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'tv-name')"/>
    </xsl:template>
    
    <xsl:template match="tv/declared-values/value" mode="prepare-config">
        <xsl:variable name="norm" select="(../../@norm,'space')[1]"/>
        <xsl:sequence select="imf:prepare-config-tagged-value-element(.,$norm)"/>
    </xsl:template>
    
    <xsl:template match="tv/stereotypes/stereo" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'stereotype-name')"/>
    </xsl:template>
    
    <xsl:template match="stereotypes/stereo/name" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'stereotype-name')"/>
    </xsl:template>
    
    <xsl:function name="imf:prepare-config-name-element" as="element()?">
        <xsl:param name="name-element" as="element()"/>
        <xsl:param name="name-type" as="xs:string"/>
        <xsl:if test="$name-element/@lang = ($language,'#all')">
            <xsl:element name="{name($name-element)}">
                <xsl:apply-templates select="$name-element/@*" mode="prepare-config"/>
                <xsl:attribute name="original" select="$name-element/text()"/>
                <xsl:value-of select="imf:get-normalized-name($name-element,$name-type)"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:prepare-config-tagged-value-element" as="element()?">
        <xsl:param name="value-element" as="element()"/>
        <xsl:param name="norm-rule" as="xs:string"/>
        <xsl:if test="($value-element/ancestor-or-self::*/@lang)[1] = ($language,'#all')">
            <xsl:element name="{name($value-element)}">
                <xsl:apply-templates select="$value-element/@*" mode="prepare-config"/>
                <xsl:attribute name="original" select="$value-element/text()"/>
                <xsl:value-of select="imf:get-tagged-value-norm-prepare($value-element,$norm-rule)"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
