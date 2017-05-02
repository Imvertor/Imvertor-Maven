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
          
        1/ redefine nilreason (cli:nilapproach):  nil-approach-choice
          
    -->
    
    <xsl:variable name="nil-approach" select="imf:get-config-string('cli','nilapproach','att')"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <!-- =========== nil-approach-choice ================== -->
    
    <xsl:template match="*[@nillable='true']">
        <xsl:choose>
            <xsl:when test="$nil-approach = 'choice'">
                <!-- follow new choice approach -->
                <xsl:copy>
                    <xsl:apply-templates select="@*"  mode="nil-approach-choice"/>
                    <xsl:apply-templates select="node()" mode="nil-approach-choice"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$nil-approach = 'att'">
                <!-- as generated -->
                <xsl:next-match/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <?x
    <xsl:template match="*[@nillable='true']/xs:complexType/xs:complexContent/xs:extension" mode="nil-approach-choice">
        
        
    </xsl:template>
    
    <xsl:template match="*[@nillable='true']/xs:complexType/xs:simpleContent/xs:extension" mode="nil-approach-choice">
        
        
    </xsl:template>
    ?>
    
    <xsl:template match="*[@nillable='true']/xs:complexType/xs:sequence" mode="nil-approach-choice">
        <xsl:comment select="'nil-approach-choice 2'"/>
        <xs:choice minOccurs="1" maxOccurs="1">
            <xsl:sequence select="."/>
            <xs:element name="nilReason" type="xs:string"/>
        </xs:choice>
    </xsl:template>
    
    <xsl:template match="*[@nillable='true']/xs:complexType/xs:choice" mode="nil-approach-choice">
        <xsl:comment select="'nil-approach-choice 1'"/>
        <xs:choice minOccurs="1" maxOccurs="1">
            <xsl:sequence select="."/>
            <xs:element name="nilReason" type="xs:string"/>
        </xs:choice>
    </xsl:template>
    
    <xsl:template match="xs:attribute[@name='nilReason']" mode="nil-approach-choice">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="@nillable" mode="nil-approach-choice">
        <!-- remove -->
    </xsl:template>
    
    
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
