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
  
    xmlns:zip-content-wrapper="http://www.armatiek.nl/namespace/zip-content-wrapper"
    
    xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    xpath-default-namespace="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
   
    <xsl:variable name="ooxml-namespace" select="'http://schemas.openxmlformats.org/spreadsheetml/2006/main'"/>
    <xsl:variable name="ooxml-schemalocation-file" select="'D:\projects\validprojects\Kadaster-Imvertor\Imvertor-OS\ImvertorCommon\trunk\xsd\ooxml\sml.xsd'"/>
    <xsl:variable name="ooxml-schemalocation-url" select="imf:file-to-url($ooxml-schemalocation-file)"/>
    
    <xsl:variable name="imvertor-ep-result-path" select="imf:get-config-string('system','imvertor-ep-result')"/>
    <xsl:variable name="message-set" select="imf:document($imvertor-ep-result-path)/ep:message-set"/>
    
    <xsl:variable name="debug" select="true()"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="/">
        <xsl:message select="$imvertor-ep-result-path"></xsl:message>
        <xsl:if test="$debug">
            <xsl:result-document href="file:/c:/temp/sheet-1.xml">
                <xsl:sequence select="//zip-content-wrapper:file[@path='xl\worksheets\sheet1.xml']"/>
            </xsl:result-document>
            <xsl:result-document href="file:/c:/temp/sheet-2.xml">
                <xsl:sequence select="//zip-content-wrapper:file[@path='xl\worksheets\sheet2.xml']"/>
            </xsl:result-document>
        </xsl:if>
       
        <!--process the template -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="worksheet">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xsi:schemaLocation" select="concat($ooxml-namespace,' ', $ooxml-schemalocation-url)"/> 
            <xsl:apply-templates select=".[../@path = 'xl\worksheets\sheet1.xml']" mode="process-berichten"/>
            <xsl:apply-templates select=".[../@path = 'xl\worksheets\sheet2.xml']" mode="process-complextypes"/>
            <xsl:apply-templates select=".[../@path = 'xl\worksheets\sheet3.xml']" mode="process-variabelen"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ============ berichten =========== -->
    
    <xsl:template match="worksheet" mode="process-berichten">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="sheetData" mode="process-berichten">
        <xsl:variable name="root-elements" select="$message-set/ep:message"/>
                <xsl:copy>
            
            <!-- skip first row -->
            <xsl:apply-templates select="row[1]"/>
            
            <!-- process all messages and top constructs -->
            <xsl:for-each select="$root-elements">
                <xsl:variable name="message-row" select="imf:get-row-for-message(.)"/>
                <xsl:variable name="message-name" select="ep:name"/>
                <xsl:variable name="col-letters" select="tokenize('B C D E F G H I J K','\s')"/>
                
                <!-- create header -->
                <row r="{$message-row}" spans="1:11">
                    <c r="A{$message-row}" s="2" t="inlineStr">
                        <is>
                            <t>
                                <xsl:value-of select="$message-name"/>
                            </t>
                        </is>
                    </c>
                    <xsl:for-each select="$col-letters">
                        <xsl:variable name="col-letter" select="."/>
                        <c r="{$col-letter}{$message-row}" s="2">
                            <!-- empty -->
                        </c>
                    </xsl:for-each>
                </row>
                <xsl:for-each select="*/ep:construct">
                    <xsl:variable name="construct-row" select="$message-row + count(preceding-sibling::ep:construct) + 1"/>
                    <!-- Maak een row voor iedere construct. -->
                    <xsl:variable name="tech-name" select="ep:name"/>
                    <xsl:variable name="cardinality" select="imf:format-cardinality(ep:min-occurs,ep:max-occurs)"/>
                    <xsl:variable name="is-attribute" select="ep:is-attribute = 'true'"/>
                    <row r="{$construct-row}" spans="1:11">
                        <xsl:choose>
                            <xsl:when test="$is-attribute">
                                <xsl:attribute name="outlineLevel">1</xsl:attribute>
                                <c r="B{$construct-row}" s="3" t="inlineStr">
                                    <is>
                                        <t>
                                            @<xsl:value-of select="$tech-name"/>
                                        </t>
                                    </is>
                                </c>
                            </xsl:when>
                            <xsl:otherwise>
                                <c r="B{$construct-row}" t="inlineStr">
                                    <is>
                                        <t>
                                            <xsl:value-of select="$tech-name"/>
                                        </t>
                                    </is>
                                </c>
                            </xsl:otherwise>
                        </xsl:choose>
                        <c r="C{$construct-row}" t="inlineStr">
                            <is>
                                <t>
                                    <xsl:value-of select="$cardinality"/>
                                </t>
                            </is>
                        </c>
                        <xsl:for-each select="subsequence($col-letters,3)">
                            <xsl:variable name="col-letter" select="."/>
                            <c r="{$col-letter}{$construct-row}" s="2">
                                <!-- empty -->
                            </c>
                        </xsl:for-each>
                    </row>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="conditionalFormatting" mode="process-berichten">
       <xsl:variable name="ranges" as="element(range)*">
            <xsl:for-each select="$message-set/ep:message">
                <xsl:variable name="element-count" select="imf:get-row-count-for-message(.)"/>
                <xsl:variable name="start-col-letter">D</xsl:variable>
                <xsl:variable name="end-col-letter">K</xsl:variable>
                <xsl:variable name="first-element-rij" select="imf:get-row-for-message(.)"/>
                <xsl:variable name="last-element-rij" select="$first-element-rij + $element-count - 1"/>
                <range sl="{$start-col-letter}" el="{$end-col-letter}" sn="{$first-element-rij + 1}" en="{$last-element-rij - 1}" hn="{$first-element-rij}"/> 
            </xsl:for-each>
        </xsl:variable>
        <!-- first general -->
        <conditionalFormatting sqref="{string-join(for $r in $ranges return imf:create-range($r),' ')}">
            <cfRule type="expression" dxfId="1" priority="7998" stopIfTrue="1">
                <formula>OR($C3="",MID($C3,1,1)="0")</formula>
            </cfRule>
            <cfRule type="expression" dxfId="1" priority="7999" stopIfTrue="1">
                <formula>OR($B3="CHOICE",$B3="SEQUENCE")</formula>
            </cfRule>
            <cfRule type="containsBlanks" dxfId="2" priority="10000">
                <formula>LEN(TRIM(D3))=0</formula>
            </cfRule>
        </conditionalFormatting>
        <!-- then for each block of input -->
        <xsl:for-each select="$ranges">
            <conditionalFormatting sqref="{imf:create-range(.)}">
                <xsl:variable name="volgnummer" select="position()"/>
                <cfRule type="expression" dxfId="0" priority="{$volgnummer}" stopIfTrue="1">
                    <formula>D$<xsl:value-of select="@hn"/>=""</formula>
                </cfRule>
            </conditionalFormatting>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="dimension" mode="process-berichten">
        <xsl:variable name="last-message" select="$message-set/ep:message[last()]"/>
        <xsl:variable name="pos" select="imf:get-row-for-message($last-message) + imf:get-row-count-for-message($last-message) - 2"/>
        <dimension ref="A1:K{$pos}"/>
    </xsl:template>
    
    
    <!-- 
        Bereken hoeveel rijen deze constructie zal innemen in de excel. 
        Voor een bericht is dat alléén het aantal child constructs, plus naamregel plus witregel.
    -->
    <xsl:function name="imf:get-row-count-for-message" as="xs:integer">
        <xsl:param name="message" as="element()"/>
        <xsl:value-of select="count($message/ep:seq/ep:construct) + 2"/>
    </xsl:function>
    
    <!-- 
        Op welke regel start dit bericht?
    -->
    <xsl:function name="imf:get-row-for-message" as="xs:integer">
        <xsl:param name="message" as="element()"/>
        <xsl:variable name="counts" as="xs:integer*">
            <xsl:for-each select="$message/preceding-sibling::ep:message">
                <xsl:value-of select="imf:get-row-count-for-message(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="2 + sum($counts)"/>
    </xsl:function>
    
   
    <!-- ============ complextypes =========== -->
    
    <xsl:template match="worksheet" mode="process-complextypes">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:function name="imf:get-row-count-for-preceding-complextypes" as="xs:integer">
        <xsl:param name="complextype" as="element()"/>
        <xsl:variable name="counts" as="xs:integer*">
            <xsl:for-each select="$complextype/preceding-sibling::ep:message">
                <xsl:value-of select="imf:get-row-count-for-message(.) + 2"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="sum($counts)"/>
    </xsl:function>
    <!-- ============ variabelen =========== -->
    
    <xsl:template match="worksheet" mode="process-variabelen">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- ============ algemeen =========== -->
    
    <xsl:function name="imf:create-range">
        <xsl:param name="range"/>
        <xsl:value-of select="concat($range/@sl,$range/@sn,':',$range/@el,$range/@en)"/>
    </xsl:function>
    
    <xsl:function name="imf:format-cardinality">
        <xsl:param name="min-occurs"/>
        <xsl:param name="max-occurs"/>
        <xsl:value-of select="concat($min-occurs,'..',if ($max-occurs = 'unbounded') then 'n' else $max-occurs)"/>
    </xsl:function>
    
    <xsl:template match="zip-content-wrapper:dummy"/>
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
