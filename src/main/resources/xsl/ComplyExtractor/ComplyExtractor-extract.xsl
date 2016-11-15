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
    <xsl:template match="/cw:files">
        <testset>
            <xsl:attribute name="generated" select="current-dateTime()"/>
            <xsl:attribute name="excel-creator" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:creator"/>
            <xsl:attribute name="excel-lastModifiedBy" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:lastModifiedBy"/>
            <xsl:attribute name="excel-created" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:created"/>
            <xsl:attribute name="excel-modified" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:modified"/>
            <xsl:attribute name="excel-app-version" select="cw:file[@path='docProps\app.xml']/*:Properties/*:AppVersion"/>
            <groups part="1">
                <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet1.xml']" mode="create-group"/>
            </groups>
            <groups part="2">
                <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet2.xml']" mode="create-group"/>
            </groups>
            <variables>
                <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet3.xml']" mode="create-vars"/>
            </variables>
        </testset>
    </xsl:template>
    
    <xsl:template match="cw:file" mode="create-group">
        <xsl:variable name="worksheet" select="*:worksheet"/>
        <xsl:variable name="worksheet-rows" select="$worksheet/*:sheetData/*:row"/>
        <!-- last row number plus 1, sentinel for the last group -->
        <xsl:variable name="last-r" select="xs:integer($worksheet-rows[last()]/@r) + 1"/>
        <!-- list of all start row numbers; skip the header at position 1  -->
        <xsl:variable name="start-row-nrs" select="for $r in ($worksheet-rows[position() gt 1 and not(imf:get-cell-info(.,1)/@val = '')]) return xs:integer($r/@r)" as="xs:integer*"/>
        
        <?x
        <xsl:message select="concat('2>', count($worksheet-rows))"/>
        <xsl:message select="concat('2>', $last-r)"/>
        <xsl:message select="concat('2>', count($start-row-nrs))"/>
        x?>
        
        <xsl:for-each select="$start-row-nrs">
            <xsl:variable name="index" select="position()"/>
            <xsl:variable name="cur-r" select="."/>
            
            <xsl:variable name="next-r-found" select="$start-row-nrs[$index + 1]"/>
            <!--<xsl:variable name="next-row" select="$worksheet-rows[$cur-r eq $next-r]"/>-->
            
            <xsl:variable name="next-r" select="if (exists($next-r-found)) then $next-r-found else $last-r"/>
          
            <xsl:variable name="cur-row" select="$worksheet-rows[xs:integer(@r) eq $cur-r]"/>
            <xsl:variable name="following-rows" select="$worksheet-rows[xs:integer(@r) gt $cur-r and xs:integer(@r) lt $next-r]"/>
            
            <?x 
            <xsl:message select="concat('1>', count($worksheet-rows))"/>
            <xsl:message select="concat('1>', string-join(for $s in $start-row-nrs return string($s),' '))"/>
            <xsl:message select="concat('1>', count($following-rows))"/>
            x?>

            <!-- the last column is the last for the first row. All columns are filled and named. -->
            <xsl:variable name="last-col" select="count($worksheet-rows[@r eq '1']/*:c)"/>
            <!-- the first cell holds the type of group -->
            <xsl:variable name="type" select="imf:get-cell-info($cur-row,1)/@val"/>
            <!-- columns run over nrs 4 upto last -->
            <xsl:for-each select="4 to $last-col">
                <xsl:variable name="label" select="imf:get-cell-info($cur-row,.)/@val"/>
                <xsl:if test="normalize-space($label)">
                    <group label="{$label}" type="{$type}">
                        <xsl:variable name="column-index" select="."/>
                        <xsl:for-each select="$following-rows">
                            <cell name="{imf:get-cell-info(.,2)/@val}" value="{imf:get-cell-info(.,$column-index)/@val}" link="{imf:is-hyperlink($worksheet,@r)}"/>                 
                        </xsl:for-each>
                    </group>
                </xsl:if>
            </xsl:for-each>
        
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="cw:file" mode="create-vars">
        <xsl:variable name="worksheet-rows" select="*:worksheet/*:sheetData/*:row"/>
        <xsl:for-each select="$worksheet-rows">
            <xsl:variable name="name" select="imf:get-string(*:c[1])"/>
            <xsl:variable name="value" select="imf:get-string(*:c[2])"/>
            <variable name="{$name}" value="{$value}"/>
        </xsl:for-each>
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
    
    <!-- check if the label in col 2 is a hyperlink -->
    <xsl:function name="imf:is-hyperlink" as="xs:boolean">
        <xsl:param name="worksheet"/>
        <xsl:param name="r"/> <!-- e.g. 3 -->
        <xsl:variable name="link" select="$worksheet/*:hyperlinks/*:hyperlink[@ref = concat('B',$r)]"/>
        <xsl:sequence select="exists($link)"/>
    </xsl:function>
    
</xsl:stylesheet>
