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
    xmlns:imvert-history="http://www.imvertor.org/schema/history"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/">
        <imvert-history:versions>
            <xsl:sequence select="imf:compile-imvert-filter()"/>
            <imvert-history:variants>
                <xsl:apply-templates select="/workbook/sheet"/>
            </imvert-history:variants>
        </imvert-history:versions>
    </xsl:template>
  
    <xsl:template match="sheet">
        <imvert-history:variant>
            <xsl:sequence select="imf:create-output-element('imvert-history:sheet-name',name)"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:variant-name',row[1]/col[1]/data)"/>
            <imvert-history:revisions>
                <xsl:apply-templates select="row[(position() &gt; 2) and normalize-space(col[1]/data)]" mode="data"/>
            </imvert-history:revisions>
        </imvert-history:variant>
    </xsl:template>
    
    <xsl:template match="row" mode="data">
        <imvert-history:revision>
            <xsl:attribute name="nr" select="@number - 1"/> <!-- third row, first is number 0 -->
            <xsl:sequence select="imf:create-output-element('imvert-history:rev-number',normalize-space(col[@number='0']/data))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:rev-date',normalize-space(col[@number='1']/data))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:package',imf:interpret(normalize-space(col[@number='2']/data)))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:class',imf:interpret(normalize-space(col[@number='3']/data)))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:property',imf:interpret(normalize-space(col[@number='4']/data)))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:date',normalize-space(col[@number='5']/data))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:contact',normalize-space(col[@number='6']/data))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:change',normalize-space(col[@number='7']/data))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:request-number',normalize-space(col[@number='8']/data))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:status',normalize-space(col[@number='9']/data))"/>
            <xsl:sequence select="imf:create-output-element('imvert-history:remarks',normalize-space(col[@number='10']/data))"/>
        </imvert-history:revision>
    </xsl:template>
    
    <!-- when * in a cell, return a space -->
    <xsl:function name="imf:interpret" as="xs:string">
        <xsl:param name="cell-content"/>
        <xsl:value-of select="$cell-content"/> <!-- NO INTERPRETATION IMPLEMENTED -->
    </xsl:function>
</xsl:stylesheet>
