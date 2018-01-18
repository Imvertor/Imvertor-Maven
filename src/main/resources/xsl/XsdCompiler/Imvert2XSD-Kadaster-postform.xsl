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
        This stylesheet postprocesses the complete set of schema's basis on particular settings.
          
        This is:
          
        1/ apply the nilreason
          
    -->
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- =========== nil-approach-counter ================== -->
 
    <xsl:template match="mark">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- 
        assign the nillable attribute to all elements that are marked nillable 
    -->
    <xsl:template match="xs:element[parent::mark[imf:boolean(@nillable)]]">
        <xs:element>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="nillable">true</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xs:element>
        <!-- add nilreason when needed -->    
        <xsl:if test="imf:boolean(parent::mark/@nilreason)">
            <xs:element name="{@name}Nilreason" type="xs:string" minOccurs="0"/>
        </xsl:if>
    </xsl:template>
        
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
