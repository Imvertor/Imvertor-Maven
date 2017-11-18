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
          
        1/ redefine nilreason (cli:nilapproach):  nil-approach-counter
          
    -->
    
    <xsl:variable name="nil-approach" select="imf:get-config-string('cli','nilapproach','elm')"/>
    
    <xsl:template match="/">
        <xsl:sequence select="imf:track('Applying nil approach',())"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- =========== nil-approach-counter ================== -->
 
    <xsl:template match="mark">
        <xsl:choose>
            <xsl:when test="@approach = $nil-approach">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <!-- remove this section; it is not conform the requested approach -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
        assign the nillable attribute to all elements that are marked nillable 
    -->
    <xsl:template match="xs:element[parent::mark[@approach = 'elm' and imf:boolean(@nillable)]]">
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
    
    <xsl:template match="xs:element[parent::mark[@approach = 'att']]">
        <xsl:sequence select="imf:msg('ERROR','STUB Unsupported nil approach',())"/>
        
        <?x
        <xsl:copy>
            <xsl:apply-templates/>
            <!-- add nilreason when needed -->
            <xsl:choose>
                <xsl:when test="imf:boolean(parent::mark/@nilreason)">
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{../@type}">
                                <xs:attribute name="nilReason" type="xs:string" use="optional"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type" select="../@type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
        ?>
        
    </xsl:template>
    
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
