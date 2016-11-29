<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 VNG/KING
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
  
    xmlns:ws="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/zip-content-wrapper"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:StUF="STUF/NAMESPACE"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    <xsl:import href="../common/Imvert-common-compact.xsl"/>

    <xsl:variable name="testset" select="/testset"/>
    
    <xsl:variable name="all-namespaces" as="element()*">
        <ns prefix="StUF" namespace="STUF/NAMESPACE"/>
        <ns prefix="a1" namespace="BG/NAMESPACE/a1"/>
        <ns prefix="a2" namespace="BG/NAMESPACE/a2"/>
    </xsl:variable>
    
    <xsl:variable name="all-test-values" select="$testset/variables/variable"/>
      
    <xsl:template match="/">
        <message-collection>
            <!-- first define all used namespaces -->
            <xsl:for-each-group select="//cell" group-by="@name">
                <xsl:variable name="parse" select="imf:ns-parse(current-grouping-key())"/>
                <xsl:if test="exists($parse[2])">
                    <xsl:namespace name="{$parse[2]}" select="$parse[3]"/>
                </xsl:if> 
            </xsl:for-each-group>
            <!-- next compile the messages -->
            <xsl:sequence select="imf:debug($testset,'Generated [1] using excel version [2]', ($testset/@generated, $testset/@excel-app-version))"/>
            <xsl:variable name="messages" as="node()*">
                <xsl:for-each-group select="$testset/groups[@part = '1']/group" group-by="@type">
                    <xsl:apply-templates select="current-group()" mode="message-column"/>
                </xsl:for-each-group>
            </xsl:variable>
            <!-- the remove all "blanks" -->
            <xsl:apply-templates select="$messages" mode="common-compact"/>
            <!-- done -->
        </message-collection>
    </xsl:template>
    
    <!-- sheet1, each next column -->
    <xsl:template match="group" mode="message-column">
        <xsl:sequence select="imf:debug(.,'Group label [1]', (@label))"/>
        <message file-name="{@label}">
            <xsl:variable name="parse" select="imf:ns-parse(@type)"/>
            <xsl:element name="{$parse[1]}">
                <xsl:if test="exists($parse[2])">
                    <xsl:namespace name="{$parse[2]}" select="$parse[3]"/>
                </xsl:if> 
                <xsl:apply-templates select="cell" mode="message-cell"/>
            </xsl:element>
        </message>
    </xsl:template>
    
    <!-- sheet1, each next cell in column: a link  -->
    <xsl:template match="cell[exists(@link)]" mode="message-cell">
        <xsl:sequence select="imf:debug(.,'message-cell Cell value [1]', (@value))"/>
        <xsl:variable name="following-attributes" select="imf:get-attributes(.)"/>
      
        <!-- determine which group is linked to -->
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="label" select="@value"/>
        <xsl:variable name="link" select="@link"/>
        <xsl:variable name="linked-group" select="/testset/groups[@part = '2']/group[@label = $label and @id = $link]"/>
        
        <xsl:choose>
            <xsl:when test="empty($label)">
                <!-- skip, this is a link but no link group selected -->
            </xsl:when>
            <xsl:when test="count($linked-group) eq 1">
                <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
                <xsl:element name="{$parse[1]}">
                    <xsl:if test="exists($parse[2])">
                        <xsl:namespace name="{$parse[2]}" select="$parse[3]"/>
                    </xsl:if> 
                    <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
                    <xsl:apply-templates select="$linked-group" mode="data-column"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="exists($following-attributes)">
                <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
                <xsl:element name="{$parse[1]}">
                    <xsl:if test="exists($parse[2])">
                        <xsl:namespace name="{$parse[2]}" select="$parse[3]"/>
                    </xsl:if> 
                    <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
                    <!-- no content -->
                </xsl:element>
            </xsl:when>
            <xsl:when test="count($linked-group) lt 1">
                <xsl:sequence select="imf:msg(.,'ERROR','Cannot find group following link [1]', ($link))"/>
            </xsl:when>
            <xsl:when test="count($linked-group) gt 1">
                <xsl:sequence select="imf:msg(.,'ERROR','Too many group types [1], column name [2]', ($linked-group[1]/@name,$linked-group[1]/@value))"/>
            </xsl:when>
        </xsl:choose>
       
    </xsl:template>

    <xsl:template match="cell[starts-with(@name,'@')]"  mode="message-cell" priority="100">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="cell[starts-with(@name,'@')]"  mode="data-cell" priority="100">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="cell[starts-with(@name,'@')]"  mode="attribute-cell">
        <xsl:attribute name="{substring-after(@name,'@')}" select="@value"/>
    </xsl:template>
    
    <!-- sheet1, each next cell in column: a value  -->
    <xsl:template match="cell[empty(@link)]" mode="message-cell">
       <xsl:sequence select="imf:debug(.,'message-cell Cell text [1]', ())"/>
       <stub>
           <xsl:variable name="following-attributes" select="imf:get-attributes(.)"/>
           <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
           cell data in sheet1
       </stub>
    </xsl:template>
    
    <!-- a group in the sheet 2 (data) -->
    <xsl:template match="group" mode="data-column">
        <xsl:sequence select="imf:debug(.,'data-column Group in data', ())"/>
        <xsl:apply-templates select="cell" mode="data-cell"/>
    </xsl:template>
    
    <!-- sheet2, each next cell in column: a link  -->
    <xsl:template match="cell[exists(@link)]" mode="data-cell">
        <xsl:sequence select="imf:debug(.,'data-cell Cell link value - type [1] label [2] link [3]', (@name, @value,@link))"/>
        
        <xsl:variable name="label" select="@value"/>
        <xsl:variable name="link" select="@link"/>
        <xsl:variable name="linked-group" select="$testset/groups[@part = '2']/group[@label = $label and @id = $link]"/>
        
        <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
        <xsl:element name="{$parse[1]}">
            <xsl:if test="exists($parse[2])">
                <xsl:namespace name="{$parse[2]}" select="$parse[3]"/>
            </xsl:if> 
            <xsl:variable name="following-attributes" select="imf:get-attributes(.)"/>
            <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
            <xsl:choose>
                <xsl:when test="empty($label)">
                    <!-- skip a link cell when no value specified. -->
                </xsl:when>
                <xsl:when test="exists($linked-group)">
                    <xsl:apply-templates select="$linked-group" mode="data-column"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:debug(.,'ERROR', ())"/>
                    <xsl:sequence select="imf:msg(.,'ERROR','Cannot resolve link to [1] as defined on [2]',($link,$label))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element> 
        
    </xsl:template>
    
    <!-- sheet2, each next cell in column: a value  -->
    <xsl:template match="cell[empty(@link)]" mode="data-cell">
        <xsl:variable name="name" select="@name"/>
        <xsl:sequence select="imf:debug(.,'data-cell Cell text [1]', ($name))"/>
        <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
        <xsl:element name="{$parse[1]}">
            <xsl:if test="exists($parse[2])">
                <xsl:namespace name="{$parse[2]}" select="$parse[3]"/>
            </xsl:if>  <!--StUF:noValue -->
            <xsl:variable name="following-attributes" select="imf:get-attributes(.)"/>
            <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
            <xsl:value-of select="@value"/>
            <!-- add a processing instruction that holds the test value if any -->
            <xsl:variable name="test-value" select="$all-test-values[@name=current()/@value]"/>
            <xsl:if test="exists($test-value)">
                <xsl:processing-instruction name="test-value" select="$test-value"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="imf:debug">
        <xsl:param name="element"/>
        <xsl:param name="text"/>
        <xsl:param name="info"/>
        <xsl:choose>
            <xsl:when test="true()">
                <xsl:variable name="ctext" select="imf:msg-insert-parms($text,$info)"/>
                <xsl:comment select="concat(name($element),': ', $ctext)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-attributes" as="element()*">
        <xsl:param name="element"/>
        <xsl:sequence select="imf:fetch($element,())"/>
    </xsl:function>
    
    <xsl:function name="imf:fetch" as="element(cell)*">
        <xsl:param name="anchor" as="element(cell)"/>
        <xsl:param name="fetched" as="element(cell)*"/>
        <xsl:for-each select="($anchor,$fetched)[last()]"> <!-- singleton -->
            <xsl:variable name="next" select="following-sibling::*[1]"/>
            <xsl:sequence select=" if (imf:fetch-test($next)) then imf:fetch($anchor,($fetched,$next)) else $fetched"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-test" as="xs:boolean">
        <xsl:param name="cell"/>
        <xsl:sequence select="starts-with($cell/@name,'@')"/>
    </xsl:function>
        
    <xsl:function name="imf:ns-parse" as="xs:string+">
        <xsl:param name="name"/>
        <xsl:variable name="parse" select="tokenize($name,':')"/>
        <xsl:choose>
            <xsl:when test="$parse[2]">
                <xsl:variable name="prefix" select="if (starts-with($parse[1],'@')) then substring($parse[1],2) else $parse[1]"/>
                <xsl:value-of select="$parse[2]"/>
                <xsl:value-of select="$prefix"/>
                <xsl:value-of select="$all-namespaces[@prefix=$prefix]/@namespace"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$parse[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>