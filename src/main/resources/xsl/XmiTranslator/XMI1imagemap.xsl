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
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="stylesheet-code">IMVIM</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
     <xsl:variable name="xmi-document" select="/"/>

    <xsl:template match="/">
        <imvert-imap:diagrams>
            <xsl:for-each-group select="//UML:Diagram" group-by="@owner"> 
                <xsl:for-each select="current-group()">
                    <xsl:sort select="imf:compile-sort-key(.)"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:for-each-group>
        </imvert-imap:diagrams>
    </xsl:template>
    
    <xsl:template match="UML:Diagram[@diagramType = 'ClassDiagram']">
        <xsl:variable name="in-construct" select="UML:ModelElement.taggedValue/UML:TaggedValue[@tag='parent']/@value"/>
        <imvert-imap:diagram>
            <imvert-imap:name>
                <xsl:value-of select="@name"/>
            </imvert-imap:name>
            <imvert-imap:id>
                <xsl:value-of select="@xmi.id"/>
            </imvert-imap:id>
            <imvert-imap:type>
                <xsl:value-of select="@diagramType"/>
            </imvert-imap:type>
            <imvert-imap:in-package>
                <xsl:value-of select="@owner"/>
            </imvert-imap:in-package>
            <xsl:if test="$in-construct">
                <imvert-imap:in-construct>
                    <xsl:value-of select="$in-construct"/>
                </imvert-imap:in-construct>
            </xsl:if>
            <imvert-imap:documentation>
                <xsl:value-of select="UML:ModelElement.taggedValue/UML:TaggedValue[@tag = 'documentation']/@value"/>
            </imvert-imap:documentation>
            
            <xsl:variable name="purpose" as="element()?">
                <xsl:choose>
                    <xsl:when test="$configuration-docrules-file/diagram-type-strategy eq 'prefix'">
                        <xsl:variable name="tk" select="for $c in tokenize(@name,':') return normalize-space($c)"/>
                        <xsl:sequence select="$configuration-docrules-file/image-purpose[marker = $tk[1]]"/>
                    </xsl:when>
                    <xsl:when test="$configuration-docrules-file/diagram-type-strategy eq 'suffix'">
                        <xsl:variable name="tk" select="for $c in tokenize(@name,'-') return normalize-space($c)"/>
                        <xsl:sequence select="$configuration-docrules-file/image-purpose[marker = $tk[last()]]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- cannot determine purpose, or diagram-type-strategy eq 'none' -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="purpose-id" select="$purpose/@id" as="xs:string?"/>
            <xsl:variable name="show-caption" select="imf:boolean($purpose/show-caption)" as="xs:boolean"/>
            <xsl:if test="exists($purpose-id)">
                <imvert-imap:purpose>
                    <xsl:value-of select="$purpose-id"/>
                </imvert-imap:purpose>
            </xsl:if>
            <imvert-imap:show-caption>
                <xsl:value-of select="$show-caption"/>
            </imvert-imap:show-caption>
            <xsl:apply-templates select="UML:Diagram.element/UML:DiagramElement"/>
        </imvert-imap:diagram>
    </xsl:template>
    
    <xsl:template match="UML:Diagram[not(@diagramType = 'ClassDiagram')]">
        <!-- skip other types of diagrams -->
    </xsl:template>
    
    <!-- example:
        <UML:DiagramElement 
            geometry="Left=164;Top=781;Right=279;Bottom=836;imgL=149;imgT=796;imgR=264;imgB=851;" 
            subject="EAID_1392239D_5A76_4836_B22A_847C6C9AE06A" 
            seqno="1" 
            style="DUID=072A17DA;"/>
    -->
    <xsl:template match="UML:DiagramElement">
        <imvert-imap:map>
            <imvert-imap:for-id>
                <xsl:value-of select="@subject"/>
            </imvert-imap:for-id>
            <xsl:analyze-string select="@geometry" regex="(.*?)=(.*?);">
                <xsl:matching-substring>
                    <xsl:if test="starts-with(regex-group(1),'img')">
                        <imvert-imap:loc type="{regex-group(1)}">
                            <xsl:value-of select="regex-group(2)"/>
                        </imvert-imap:loc>
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <!-- ignore, should not occur -->
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </imvert-imap:map>
    </xsl:template>
    
    
</xsl:stylesheet>
