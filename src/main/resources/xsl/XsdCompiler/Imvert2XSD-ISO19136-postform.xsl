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
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ekf="http://EliotKimber/functions"

    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <!-- 
        This stylesheet post-processes the XML schema collection created, 
        and executes just before the schema's are generated to *.XSD files.
          
        This is:
          
        1/ remove @minOccurs=1 and @maxOccurs=1 when specify-xsd-occurrence=default
        2/ remove @abstract=false
        3/ redirect NE3610IDPropertyType to NEN3610ID type. This is a patch for non conforming NEN3610 schema.
   
    -->
    <xsl:variable name="specify-xsd-occurrence-always" select="imf:get-config-schemarules()/specify-xsd-occurrence = 'always'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@minOccurs">
        <xsl:if test="$specify-xsd-occurrence-always or not(. = '1')">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>    
  
    <xsl:template match="@maxOccurs">
        <xsl:if test="$specify-xsd-occurrence-always or not(. = '1')">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>    
    
    <xsl:template match="@abstract">
        <xsl:if test=". = 'true'">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>    
    
    <xsl:template match="@type[.='NEN3610:NEN3610IDPropertyType']">
        <xsl:attribute name="type" select="'NEN3610:NEN3610ID'"/>
    </xsl:template>    
    
    
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
