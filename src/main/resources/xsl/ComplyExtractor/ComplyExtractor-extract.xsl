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
    <xsl:import href="../common/Imvert-common-compact.xsl"/>
    
    <xsl:variable name="stylesheet-code">CE-E</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:variable name="sheet-gegevensgroepen-tab-name">Gegevensgroepen</xsl:variable>
    
    <xsl:variable name="__content" select="/"/>
    
    <xsl:template match="/">
        <xsl:variable name="extraction" as="item()*">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:apply-templates select="$extraction" mode="common-compact"/>
    </xsl:template>
    
    <xsl:variable name="all-shared-strings" as="element()*">
        <xsl:sequence select="/cw:files/cw:file[@path='xl\sharedStrings.xml']/*:sst/*:si"/>
    </xsl:variable>
    
    <!-- 
        global variables are referenced in cells using #{referentienummer) and the like 
        
        provided as local <var> elements.
    -->    
    <xsl:template match="/cw:files">
        <xsl:sequence select="imf:track('Reading Excel')"/>
        <xsl:variable name="testset" as="element(testset)">
            <testset>
                <xsl:attribute name="generated" select="current-dateTime()"/>
                <xsl:attribute name="excel-creator" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:creator"/>
                <xsl:attribute name="excel-lastModifiedBy" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:lastModifiedBy"/>
                <xsl:attribute name="excel-created" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:created"/>
                <xsl:attribute name="excel-modified" select="cw:file[@path='docProps\core.xml']/*:coreProperties/*:modified"/>
                <xsl:attribute name="excel-app-version" select="cw:file[@path='docProps\app.xml']/*:Properties/*:AppVersion"/>
                <groups part="1">
                    <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet1.xml']" mode="create-group">
                        <xsl:with-param name="sheet-nr" select="1"/>
                    </xsl:apply-templates>
                </groups>
                <groups part="2">
                    <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet2.xml']" mode="create-group">
                        <xsl:with-param name="sheet-nr" select="2"/>
                    </xsl:apply-templates>
                </groups>
                <variables>
                    <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet3.xml']" mode="create-vars"/>
                </variables>
                <namespaces>
                    <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet4.xml']" mode="create-namespaces"/>
                </namespaces>
                <parameters>
                    <xsl:apply-templates select="cw:file[@path = 'xl\worksheets\sheet5.xml']" mode="create-info"/>
                </parameters>
            </testset>
        </xsl:variable>
        <xsl:sequence select="$testset"/>
        
        <xsl:sequence select="imf:set-config-string('appinfo','project-name','#COMPLY')"/>
        <xsl:sequence select="imf:set-config-string('appinfo','application-name',$testset/parameters/parm[@name='model-name'])"/>
        <xsl:sequence select="imf:set-config-string('appinfo','release',$testset/parameters/parm[@name='model-release'])"/>
        
        <xsl:sequence select="imf:set-config-string('appinfo','subpath',imf:get-subpath(
            '#COMPLY',
            $testset/parameters/parm[@name='model-name'],
            $testset/parameters/parm[@name='model-release']))"/>

        <xsl:sequence select="imf:set-config-string('appinfo','release-name','TODO-DETERMINE-RELEASE-NAME')"/>


        <xsl:sequence select="imf:set-config-string('appinfo','model-subpath',imf:get-subpath(
            $testset/parameters/parm[@name='project-name'],
            $testset/parameters/parm[@name='model-name'],
            $testset/parameters/parm[@name='model-release']))"/>
   
        <xsl:sequence select="imf:set-config-string('appinfo','schema-subpath',$testset/parameters/parm[@name='schema-subpath'])"/>
        <xsl:sequence select="imf:set-config-string('appinfo','creation-version',$testset/parameters/parm[@name='creation-version'])"/>
        <xsl:sequence select="imf:set-config-string('appinfo','creation-date',$testset/parameters/parm[@name='creation-date'])"/>
        <xsl:sequence select="imf:set-config-string('appinfo','edit-version',$testset/parameters/parm[@name='edit-version'])"/>
        <xsl:sequence select="imf:set-config-string('appinfo','edit-date',$testset/parameters/parm[@name='edit-date'])"/>
        <xsl:sequence select="imf:set-config-string('appinfo','job-id',$testset/parameters/parm[@name='job-id'])"/>
        
    </xsl:template>
    
    <xsl:template match="cw:file" mode="create-group">
        <xsl:param name="sheet-nr" as="xs:integer"/> <!-- needed to determine where links are available --> 
        
        <xsl:variable name="worksheet" select="*:worksheet"/>
        <xsl:variable name="worksheet-rows" select="$worksheet/*:sheetData/*:row"/>
        <!-- last row number plus 1, sentinel for the last group -->
        <xsl:variable name="last-r" select="xs:integer($worksheet-rows[last()]/@r) + 1"/>
        <!-- list of all start row numbers; skip the header at position 1  -->
        <xsl:variable name="start-row-nrs" select="for $r in ($worksheet-rows[position() gt 1 and not(imf:get-cell-info(.,1,$sheet-nr)/@val = '')]) return xs:integer($r/@r)" as="xs:integer*"/>
        
        <!--
        <xsl:message select="concat('2>', count($worksheet-rows))"/>
        <xsl:message select="concat('2>', $last-r)"/>
        <xsl:message select="concat('2>', count($start-row-nrs))"/>
        -->
        
        <xsl:for-each select="$start-row-nrs">
            <xsl:variable name="index" select="position()"/>
            <xsl:variable name="cur-r" select="."/>
            
            <xsl:variable name="next-r-found" select="$start-row-nrs[$index + 1]"/>
            <!--<xsl:variable name="next-row" select="$worksheet-rows[$cur-r eq $next-r]"/>-->
            
            <xsl:variable name="next-r" select="if (exists($next-r-found)) then $next-r-found else $last-r"/>
          
            <xsl:variable name="cur-row" select="$worksheet-rows[xs:integer(@r) eq $cur-r]"/>
            <xsl:variable name="following-rows" select="$worksheet-rows[xs:integer(@r) gt $cur-r and xs:integer(@r) lt $next-r]"/>
            
            <!--
            <xsl:message select="concat('1>', count($worksheet-rows))"/>
            <xsl:message select="concat('1>', string-join(for $s in $start-row-nrs return string($s),' '))"/>
            <xsl:message select="concat('1>', count($following-rows))"/>
            -->
            
            <!-- the last column is the last for the first row. All columns are filled and named. -->
            <xsl:variable name="last-col" select="count($worksheet-rows[@r eq '1']/*:c)"/>
            <!-- the first cell holds the type of group -->
            <xsl:variable name="info" select="imf:get-cell-info($cur-row,1,$sheet-nr)"/>
            <xsl:variable name="type" select="$info/@val"/>
            <xsl:variable name="id" select="$info/@id"/>
            
            <!-- columns run over nrs 4 upto last -->
            <xsl:for-each select="4 to $last-col">
                <xsl:variable name="info" select="imf:get-cell-info($cur-row,.,$sheet-nr)"/>
                <xsl:variable name="label" select="$info/@val"/>
                <xsl:if test="normalize-space($label)">
                    <group label="{$label}" type="{$type}">
                        <xsl:if test="exists($id)">
                            <xsl:attribute name="id" select="$id"/>
                        </xsl:if>
                        <xsl:variable name="column-index" select="."/>
                        <xsl:for-each select="$following-rows">
                            <cell name="{imf:get-cell-info(.,2,$sheet-nr)/@val}" value="{imf:get-cell-info(.,$column-index,$sheet-nr)/@val}">
                                <xsl:variable name="link" select="imf:get-hyperlink($worksheet,@r)"/>
                                <xsl:if test="exists($link)">
                                    <xsl:attribute name="link" select="$link"/>
                                </xsl:if>
                            </cell>                 
                        </xsl:for-each>
                    </group>
                </xsl:if>
            </xsl:for-each>
        
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="cw:file" mode="create-vars">
        <xsl:variable name="worksheet-rows" select="*:worksheet/*:sheetData/*:row"/>
        <xsl:for-each select="$worksheet-rows[position() gt 1]">
            <xsl:variable name="name" select="imf:get-string(*:c[1])"/>
            <xsl:variable name="value" select="imf:get-string(*:c[2])"/>
            <variable name="{$name}">
                <xsl:value-of select="$value"/>
            </variable>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cw:file" mode="create-namespaces">
        <xsl:variable name="worksheet-rows" select="*:worksheet/*:sheetData/*:row"/>
        <xsl:for-each select="$worksheet-rows[position() gt 1]">
            <xsl:variable name="name" select="imf:get-string(*:c[1])"/>
            <xsl:variable name="value" select="imf:get-string(*:c[2])"/>
            <ns prefix="{$name}">
                <xsl:value-of select="$value"/>
            </ns>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="cw:file" mode="create-info">
        <xsl:variable name="worksheet-rows" select="*:worksheet/*:sheetData/*:row"/>
        <xsl:for-each select="$worksheet-rows[position() gt 1]">
            <xsl:variable name="name" select="imf:get-string(*:c[1])"/>
            <xsl:variable name="value" select="imf:get-string(*:c[2])"/>
            <parm name="{$name}">
                <xsl:value-of select="$value"/>
            </parm>
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
        <xsl:param name="sheet-nr" as="xs:integer"/>
        
        <xsl:variable name="letter" select="substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ',$index,1)"/>
        <xsl:variable name="c" select="$row/*:c[starts-with(@r,$letter)]"/>
        <xsl:variable name="v" select="imf:get-string($c)"/>
        
        <!-- determine the link form for this cell, e.g. Gegevensgroepen!$A$2 -->
        <xsl:variable name="cell-index" select="concat($sheet-gegevensgroepen-tab-name,'!$',$letter,'$',$row/@r)"/>
        <!-- determine the internal ID, e.g. EA002k3j4h5k2j34h5l-->
        <xsl:variable name="cell-id" select="$__content//*:definedNames/*:definedName[. = $cell-index]/@name"/>
    
        <cell>
            <xsl:attribute name="row" select="$row/@r"/>
            <xsl:attribute name="col" select="$index"/>
            <xsl:variable name="val" as="xs:string?">
                <xsl:choose>
                    <xsl:when test="$v = 'xsi:nil'">@xsi:nil</xsl:when>
                    <xsl:when test="empty($c)"><!--empty string--></xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$v"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="val" select="$val"/>
            <xsl:if test="$sheet-nr = 2 and exists($cell-id)">
                <xsl:attribute name="id" select="$cell-id"/>
            </xsl:if>
        </cell>
    </xsl:function>
    
    <!-- check if the label in col 2 is a hyperlink -->
    <xsl:function name="imf:get-hyperlink" as="xs:string?">
        <xsl:param name="worksheet"/>
        <xsl:param name="r"/> <!-- e.g. 3 -->
        <xsl:variable name="link" select="$worksheet/*:hyperlinks/*:hyperlink[@ref = concat('B',$r)][1]"/>
        <xsl:sequence select="$link/@location"/>
    </xsl:function>
    
</xsl:stylesheet>
