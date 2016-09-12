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
    
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
        fix some XMI constructs before transforming the XMI to imvert 
    
        zie "\Documents\20160907 Kadaster migratie naar nieuwe metamodel.xlsx"  
    -->

    <xsl:template match="XMI">
        <xsl:comment select="concat('Migrated dd. ', current-dateTime())"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!-- localize de stereotypes -->
    <xsl:template match="UML:Stereotype/@name">
        <xsl:variable name="v" select="lower-case(.)"/>
        <xsl:attribute name="name">
            <xsl:choose>
                <xsl:when test="$v = 'domain'">domein</xsl:when>
                <xsl:when test="$v = 'application'">toepassing</xsl:when>
                <xsl:when test="$v = 'external'">extern</xsl:when>
                <xsl:when test="$v = 'recyclebin'">prullenbak</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!-- localize de stereotypes -->
    <xsl:template match="UML:TaggedValue[@tag = 'stereotype']/@value">
        <xsl:variable name="v" select="lower-case(.)"/>
        <xsl:attribute name="value">
            <xsl:choose>
                <xsl:when test="$v = 'domain'">domein</xsl:when>
                <xsl:when test="$v = 'application'">toepassing</xsl:when>
                <xsl:when test="$v = 'external'">extern</xsl:when>
                <xsl:when test="$v = 'recyclebin'">prullenbak</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="UML:TaggedValue[@tag = '$ea_xref_property']/@value">
        <xsl:variable name="v1" select="."/>
        <xsl:variable name="v2" select="replace($v1,'@STEREO;Name=application;','@STEREO;Name=toepassing;')"/>
        <xsl:variable name="v3" select="replace($v2,'@STEREO;Name=domain;','@STEREO;Name=domein;')"/>
        <xsl:variable name="v4" select="replace($v3,'@STEREO;Name=external;','@STEREO;Name=extern;')"/>
        <xsl:variable name="v5" select="replace($v4,'@STEREO;Name=recyclebin;','@STEREO;Name=prullenbak;')"/>
        
        <xsl:attribute name="value" select="$v5"/>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
