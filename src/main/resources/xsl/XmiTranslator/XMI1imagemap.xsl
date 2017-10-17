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
    
    <xsl:import href="../common/Imvert-common.xsl"/>
   
    <xsl:variable name="stylesheet-code">IMVIM</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
     <xsl:variable name="xmi-document" select="/"/>

    <xsl:template match="/">
        <imvert:map>
            <xsl:apply-templates select="//UML:Diagram"/>
        </imvert:map>
    </xsl:template>
    
    <xsl:template match="UML:Diagram[@diagramType = 'ClassDiagram']">
        <imvert:diagram>
            <imvert:id>
                <xsl:value-of select="@xmi.id"/>
            </imvert:id>
            <xsl:apply-templates select="UML:Diagram.element/UML:DiagramElement"/>
        </imvert:diagram>
    </xsl:template>
    
    <!-- example:
        <UML:DiagramElement 
            geometry="Left=164;Top=781;Right=279;Bottom=836;imgL=149;imgT=796;imgR=264;imgB=851;" 
            subject="EAID_1392239D_5A76_4836_B22A_847C6C9AE06A" 
            seqno="1" 
            style="DUID=072A17DA;"/>
    -->
    <xsl:template match="UML:DiagramElement">
        <imvert:geo>
            <imvert:model-element-id>
                <xsl:value-of select="@subject"/>
            </imvert:model-element-id>
            <xsl:analyze-string select="@geometry" regex="(.*?)=(.*?);">
                <xsl:matching-substring>
                    <xsl:if test="starts-with(regex-group(1),'img')">
                        <imvert:loc type="{regex-group(1)}">
                            <xsl:value-of select="regex-group(2)"/>
                        </imvert:loc>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <!-- ignore, should not occur -->
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </imvert:geo>
    </xsl:template>
    
    
</xsl:stylesheet>
