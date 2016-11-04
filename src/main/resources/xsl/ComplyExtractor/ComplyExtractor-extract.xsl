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
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:variable name="all-shared-strings" as="element()*">
        <xsl:sequence select="/cw:files/cw:file[@path='xl\sharedStrings.xml']/*:sst/*:si"/>
    </xsl:variable>
    
    <!-- 
        global variables are referenced in cells using #{referentienummer) and the like 
        
        provided as local <var> elements.
    -->    
    <xsl:variable name="all-global-variables" as="element(var)*">
        <xsl:for-each select="/cw:files/cw:file[@path = 'xl\worksheets\sheet3.xml']/*:worksheet/*:sheetData/*:row">
            <xsl:variable name="name" select="imf:get-string(*:c[1])"/>
            <xsl:variable name="value" select="imf:get-string(*:c[2])"/>
            <var name="{$name}" value="{$value}"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/cw:files/cw:file[@path = 'xl\worksheets\sheet1.xml']">
        <xsl:variable name="folderpath" select="imf:get-config-string('properties','IMVERTOR_COMPLY_EXTRACT_TARGET')"/>
        <xsl:variable name="filepath" select="imf:file-to-url(concat($folderpath,'/','test1.xml'))"/>
        <xsl:sequence select="imf:msg(.,'INFO','Path is [1]',$filepath)"/>
      
        <!--
            iterate over all messages, and for each message all columns
        -->
        <xsl:variable name="messages">
            <xsl:for-each select="/cw:files/cw:file[@path = 'xl\worksheets\sheet1.xml']/*:worksheet/*:sheetData/*:row">
                <xsl:variable name="cell" select="imf:get-cell-info(.,1)"/>
                <xsl:choose>
                    <xsl:when test="not($cell/@val = '')">
                        <!-- message is a block that starts with a non-empty cell in column 1. -->
                        
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>  
        </xsl:variable>
      
        <xsl:result-document href="{$filepath}">
            <xsl:comment select="imf:format-dateTime(current-dateTime())"/>
            <test-file>
                <xsl:for-each select="$all-global-variables">
                    <xsl:value-of select="concat(@name, ' = ', @value)"/>
                </xsl:for-each>
            </test-file>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        get the string from the shared strings section 
    -->
    <xsl:function name="imf:get-string" as="xs:string">
        <xsl:param name="c"/>
        <xsl:value-of select="if ($c/@t='s') then $all-shared-strings[xs:integer($c/*:v) + 1] else string-join($c/*:v,'')"/>
    </xsl:function>
    
    <!-- 
        get the cell info for the row cell at index supplied.
        A cell may not exist or be empty; in both cases the value is empty string. 
        First cell on sheet is <cell row="1" col="1" val="value of this cell"/> 
    -->
    <xsl:function name="imf:get-cell-info" as="element(cell)">
        <xsl:param name="row" as="element()"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:variable name="letter" select="substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ',$index,1)"/>
        <xsl:variable name="c" select="$row/*:c[starts-with(@r,$letter)]"/>
        <cell>
            <xsl:attribute name="row" select="$row/@r"/>
            <xsl:attribute name="col" select="$index"/>
            <xsl:attribute name="val" select="if (exists($c)) then imf:get-string($c) else ''"/>
        </cell>
    </xsl:function>
    
</xsl:stylesheet>
