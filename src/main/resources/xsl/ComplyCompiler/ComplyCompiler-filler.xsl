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
    
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" 
    xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" 
    xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main" 
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:cp="http://www.imvertor.org/schema/comply-excel"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
   
    <xsl:include href="ComplyCompiler-flat.xsl"/>
    
    <xsl:variable name="debug" select="true()"/>
    
    <xsl:variable name="ooxml-namespace" select="'http://schemas.openxmlformats.org/spreadsheetml/2006/main'"/>
    <xsl:variable name="ooxml-schemalocation-file" select="'D:\projects\validprojects\Kadaster-Imvertor\Imvertor-OS\ImvertorCommon\trunk\xsd\ooxml\sml.xsd'"/>
    <xsl:variable name="ooxml-schemalocation-url" select="imf:file-to-url($ooxml-schemalocation-file)"/>
    
    <xsl:variable name="sheet-gegevensgroepen-tab-name">'Gegevensgroepen'</xsl:variable>
    
    <!-- 
        preprare all info from EP message set, transform to a worksheet block-buildup that can be processed "in sequence"
    -->
    <xsl:variable name="imvertor-ep-result-path" select="imf:get-config-string('system','imvertor-ep-result')"/>
    <xsl:variable name="message-set-raw" select="imf:document($imvertor-ep-result-path)"/>
    <xsl:variable name="message-set-flat" as="element(cp:sheets)">
        <xsl:apply-templates select="$message-set-raw/ep:message-set" mode="prepare-flat"/>
    </xsl:variable>
    
    <!-- 
        get the sheets from template 
    -->
    <xsl:variable name="__content" select="/"/>
    <xsl:variable name="sheet1" select="$__content/zip-content-wrapper:files/zip-content-wrapper:file[@path = 'xl\worksheets\sheet1.xml']/worksheet"/>
    <xsl:variable name="sheet2" select="$__content/zip-content-wrapper:files/zip-content-wrapper:file[@path = 'xl\worksheets\sheet2.xml']/worksheet"/>
    <xsl:variable name="sheet3" select="$__content/zip-content-wrapper:files/zip-content-wrapper:file[@path = 'xl\worksheets\sheet3.xml']/worksheet"/>
    
    <xsl:template match="/">
        <xsl:if test="$debug">
            <xsl:result-document href="file:/c:/temp/flat.xml">
                <xsl:sequence select="$message-set-flat"/>
            </xsl:result-document>
        </xsl:if>
       
        <!--process the template -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="zip-content-wrapper:file/worksheet">
        <xsl:variable name="worksheet" select="imf:select-context-element(.,(
            'sheetPr',
            'dimension',
            'sheetViews',
            'sheetFormatPr',
            'cols',
            'sheetData',
            'conditionalFormatting',
            'dataValidations',
            'hyperlinks',
            'pageMargins',
            'pageSetup',
            'legacyDrawing'))"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xsi:schemaLocation" select="concat($ooxml-namespace,' ', $ooxml-schemalocation-url)"/> 
            <xsl:choose>
                <xsl:when test=". = $sheet1">
                    <xsl:apply-templates select="$worksheet" mode="process-berichten"/>
                </xsl:when>
                <xsl:when test=". = $sheet2">
                    <xsl:apply-templates select="$worksheet" mode="process-complextypes"/>
                </xsl:when>
                <xsl:when test=". = $sheet3">
                    <xsl:apply-templates select="$worksheet" mode="process-variabelen"/>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="zip-content-wrapper:file/workbook">
        <xsl:variable name="workbook" select="imf:select-context-element(.,(
            'fileVersion',
            'workbookPr', 
            'bookViews',
            'sheets',
            'definedNames',
            'calcPr',
            'fileRecoveryPr'))"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xsi:schemaLocation" select="concat($ooxml-namespace,' ', $ooxml-schemalocation-url)"/> 
            <xsl:apply-templates select="$workbook" mode="process-workbook"/>
        </xsl:copy>
        
    </xsl:template>
    
    <!-- ============ workbook ============== -->
    
    <xsl:template match="definedNames" mode="process-workbook">
        <xsl:variable name="result" as="element()*">
            <xsl:for-each select="$message-set-flat/cp:sheet[2]/cp:block">
                <xsl:variable name="sequence-id" select="cp:id"/>
                <xsl:variable name="gegevensgroep-header-rij" select="imf:get-row-for-block(.)"/>
                <definedName name="{$sequence-id}">
                    <xsl:value-of select="concat($sheet-gegevensgroepen-tab-name,'!$A$', $gegevensgroep-header-rij)"/>
                </definedName>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($result)">
            <definedNames>
                <xsl:sequence select="$result"/>
            </definedNames>
        </xsl:if>
    </xsl:template>
    
    <!-- ============ berichten =========== -->
    
    <xsl:template match="sheetData" mode="process-berichten">
        <xsl:variable name="sheet-blocks" select="$message-set-flat/cp:sheet[1]/cp:block" as="element(cp:block)*"/>
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$sheet-blocks"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="sheetData" mode="process-complextypes">
        <xsl:variable name="sheet-blocks" select="$message-set-flat/cp:sheet[2]/cp:block" as="element(cp:block)*"/>
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$sheet-blocks"/>
        </xsl:apply-templates>
    </xsl:template>
  
  <?x
        <xsl:copy>
            
            <!-- skip first row -->
            <xsl:apply-templates select="row[1]"/>
            
            <!-- process all messages and top constructs -->
            <xsl:for-each select="$sheet-blocks">
                <xsl:variable name="message-row" select="imf:get-row-for-block(.)"/>
                <xsl:variable name="message-name" select="cp:prop[@type='header']"/>
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
                <xsl:for-each select="cp:prop[@type='spec']">
                    <xsl:variable name="construct-row" select="$message-row + count(preceding-sibling::cp:prop)"/>
                    <!-- Maak een row voor iedere construct. -->
                    <xsl:variable name="tech-name" select="cp:element"/>
                    <xsl:variable name="cardinality" select="cp:cardinal"/>
                    <xsl:variable name="is-attribute" select="cp:attribute = 'true'"/>
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
?>
    
    <xsl:template match="conditionalFormatting" mode="process-berichten">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[1]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="conditionalFormatting" mode="process-complextypes">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[2]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="conditionalFormatting" mode="process-variabelen">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[3]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="conditionalFormatting" mode="process-all">
       <xsl:param name="blocks"/>
       <xsl:variable name="ranges" as="element(range)*">
            <xsl:for-each select="$blocks">
                <xsl:variable name="element-count" select="count(cp:prop) - 2"/>
                <xsl:variable name="start-col-letter">D</xsl:variable>
                <xsl:variable name="end-col-letter">K</xsl:variable>
                <xsl:variable name="gegevensgroep-header-rij" select="imf:get-row-for-block(.)"/>
                <xsl:variable name="first-element-rij" select="$gegevensgroep-header-rij + 1"/>
                <xsl:variable name="last-element-rij" select="$first-element-rij + $element-count - 1"/>
                <range sl="{$start-col-letter}" el="{$end-col-letter}" sn="{$first-element-rij}" en="{$last-element-rij}" hn="{$gegevensgroep-header-rij}"/> 
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
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[1]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="dimension" mode="process-complextypes">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[2]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="dimension" mode="process-variables">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[3]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="dimension" mode="process-all">
        <xsl:param name="blocks"/>
        <xsl:variable name="pos" select="count($blocks/cp:prop)"/>
        <dimension ref="A1:K{$pos}"/>
    </xsl:template>
    
    <xsl:template match="dataValidations" mode="process-berichten">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[1]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="dataValidations" mode="process-complextypes">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[2]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="dataValidations" mode="process-variabelen">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[3]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- 
        de data validaties zijn gebaseerd op het overzicht:
        "d:\projects\validprojects\KING\planio-repository\StUF Schemagenerator\Documentatie\PoC Compliancy berichten\inventarisatie simpleType restricties.xlsx"
    -->
    <xsl:template match="dataValidations" mode="process-all">
        <xsl:param name="blocks"/>
        <xsl:variable name="quot">"</xsl:variable>
        <xsl:variable name="sheet" select="$blocks[1]/@sheet"/> 
        <xsl:variable name="result" as="element()*">
            <xsl:for-each select="$blocks/cp:prop[@type='spec']">
                <xsl:variable name="row" select="count(preceding::cp:prop[../@sheet=$sheet]) + 2"/>
                <xsl:variable name="sqref" select="concat('$D$',$row,':K$',$row)"/>
                <xsl:variable name="form" select="string-join(for $i in (1 to xs:integer(cp:totaldigits)) return '9','')"/>  <!-- e.g. 9999 for totaldigits = 4 -->
                <xsl:choose>
                    <!-- 2 base type = complex type -->
                    <xsl:when test="@ref">
                        <xsl:sequence select="imf:create-data-validation(.,'list',(),concat($sheet-gegevensgroepen-tab-name,'!$D$', $row - 1, ':$K$', $row - 1),(),$sqref)"/>
                    </xsl:when>
                    <!-- 3 4 base type =  * | restrictie = fixed of enumeratie -->
                    <xsl:when test="cp:enum">
                        <xsl:sequence select="imf:create-data-validation(.,'list',(),concat($quot,cp:enum,$quot),(),$sqref)"/>
                    </xsl:when>
                    <!-- 5 base type =  * | restrictie = patroon -->
                    <xsl:when test="cp:pattern">
                        <!--TODO commentaar -->
                    </xsl:when>
                    <!-- 6 base type is nonNegativeInteger -->
                    <xsl:when test="cp:type = 'scalar-integer'">
                        <!-- TODO kennen we die? -->
                        <xsl:sequence select="imf:create-data-validation(.,'whole','greaterThanOrEqual',0,(),$sqref)"/>
                    </xsl:when>
                    <!-- 7 base type is positiveInteger -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:totaldigits">
                        <!-- TODO kennen we die? -->
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),1,'greaterThanOrEqual',$sqref)"/>
                    </xsl:when>
                    <!-- 8 9 base type is int | restrictie = totaldigits-->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:totaldigits">
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),concat('-',$form),$form,$sqref)"/>
                    </xsl:when>
                    <!-- 10 base type is nonNegativeInteger | restriction = totaldigits -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:totaldigits">
                        <!-- TODO kennen we die? -->
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),0,$form,$sqref)"/>
                    </xsl:when>
                    <!-- 11 base type is positiveInteger | restriction = totaldigits -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:totaldigits">
                        <!-- TODO kennen we die? -->
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),1,$form,$sqref)"/>
                    </xsl:when>
                    <!-- 12 base type is decimal | restriction = totaldigits -->
                    <xsl:when test="cp:type = 'scalar-integer' and UNKNOWN">
                        <!-- TODO kennen we die? -->
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),xs:integer(cp:totaldigits) + 2,(),$sqref)"/>
                    </xsl:when>
                    <!-- 13 base type is integer | restriction = maxinclusive -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:maxinclusive">
                        <!-- TODO kennen we die? -->
                        <xsl:sequence select="imf:create-data-validation(.,'whole','lessThanOrEqual',cp:maxinclusive,(),$sqref)"/>
                    </xsl:when>
                    <!-- 14 base type is integer | restriction = min+maxinclusive -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:mininclusive and cp:maxinclusive">
                        <!-- TODO kennen we die? -->
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),cp:mininclusive,cp:maxinclusive,$sqref)"/>
                    </xsl:when>
                    <!-- 15 base type is string | restriction = length -->
                    <xsl:when test="cp:type = 'scalar-string' and cp:length">
                        <xsl:sequence select="imf:create-data-validation(.,'textLength','equal',cp:length,(),$sqref)"/>
                    </xsl:when>
                    <!-- 16 base type is string | restriction = maxlength -->
                    <xsl:when test="cp:type = 'scalar-string' and cp:maxlength">
                        <xsl:sequence select="imf:create-data-validation(.,'textLength','lessThanOrEqual',cp:maxlength,(),$sqref)"/>
                    </xsl:when>
                    <!-- 17 base type is string | restriction = min/maxlength -->
                    <xsl:when test="cp:type = 'scalar-string' and cp:minlength and cp:maxlength">
                        <xsl:sequence select="imf:create-data-validation(.,'textLength',(),cp:minlength,cp:maxlength,$sqref)"/>
                    </xsl:when>
                    
                </xsl:choose>
                
                
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($result)">
            <dataValidations>
                <xsl:sequence select="$result"/>
            </dataValidations>
        </xsl:if>
    </xsl:template>
   
    <xsl:function name="imf:create-data-validation" as="element()">
        <xsl:param name="prop"/>
        <xsl:param name="type"/>
        <xsl:param name="operator"/>
        <xsl:param name="formula1"/>
        <xsl:param name="formula2"/>
        <xsl:param name="sqref"/>
        <dataValidation allowBlank="1" showInputMessage="1" showErrorMessage="1">
            <xsl:attribute name="type" select="$type"/>
            <xsl:attribute name="sqref" select="$sqref"/>
            <xsl:if test="$operator">
                <xsl:attribute name="operator" select="$operator"/>
            </xsl:if>
            <formula1>
                <xsl:value-of select="$formula1"/>
            </formula1>
            <xsl:if test="$formula2">
                <formula2>
                    <xsl:value-of select="$formula2"/>
                </formula2>
            </xsl:if>
        </dataValidation>
    </xsl:function>
    <!-- 
        Iedere construct//construct wordt op sheet 2 geplaatst. Er moet dus een hyperlink naar toe kunnen vanaf shet 1 en 2.
        Het krijgt daarom een unieke naam.
    -->
    <xsl:template match="hyperlinks" mode="process-berichten">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[1]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="hyperlinks" mode="process-complextypes">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[2]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="hyperlinks" mode="process-variabelen">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[3]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="hyperlinks" mode="process-all">
        <xsl:param name="blocks"/> <!-- always within a single sheet -->
        <xsl:variable name="sheet" select="$blocks[1]/@sheet"/> 
        <xsl:variable name="result" as="element()*">
            <xsl:for-each select="$blocks/cp:prop[exists(@ref)]">
                <xsl:variable name="element-rij" select="count(preceding::cp:prop[../@sheet=$sheet]) + 2"/>
                <xsl:variable name="sequence-id" select="@ref"/>
                <xsl:variable name="element-name" select="cp:element"/>
                <hyperlink ref="B{$element-rij}" location="{$sequence-id}" display="{$element-name}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($result)">
            <hyperlinks>
                <xsl:sequence select="$result"/>
            </hyperlinks>
        </xsl:if>
    </xsl:template>
    
    <!-- ============ complextypes =========== -->
    
    <xsl:template match="sheetData" mode="process-all">
        <xsl:param name="blocks"/>
        <xsl:variable name="sheet-number" select="$blocks[1]/@sheet"/>
        
        <xsl:copy>
            
            <!-- skip first row -->
            <xsl:apply-templates select="row[1]"/>
            
            <!-- process all messages and top constructs -->
            <xsl:for-each select="$blocks">
                <xsl:variable name="message-row" select="imf:get-row-for-block(.)"/>
                <xsl:variable name="message-name" select="cp:prop[@type='header']"/>
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
                <xsl:for-each select="cp:prop[@type='spec']">
                    <xsl:variable name="construct-row" select="$message-row + count(preceding-sibling::cp:prop)"/>
                    <!-- Maak een row voor iedere construct. -->
                    <xsl:variable name="tech-name" select="cp:element"/>
                    <xsl:variable name="cardinality" select="cp:cardinal"/>
                    <xsl:variable name="is-attribute" select="cp:attribute = 'true'"/>
                    <xsl:variable name="fixed-value" select="cp:fixed"/>
                    <row r="{$construct-row}" spans="1:11">
                        <xsl:choose>
                            <xsl:when test="$is-attribute">
                                <xsl:attribute name="outlineLevel">1</xsl:attribute>
                                <c r="B{$construct-row}" s="3" t="inlineStr">
                                    <is>
                                        <t>
                                            <xsl:value-of select="concat('@',$tech-name)"/>
                                        </t>
                                    </is>
                                </c>
                            </xsl:when>
                            <xsl:otherwise>
                                <c r="B{$construct-row}" t="inlineStr">
                                    <xsl:choose>
                                        <xsl:when test="exists(@ref)">
                                           <xsl:attribute name="s" select="4"/> 
                                        </xsl:when>
                                    </xsl:choose>
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
                            <c r="{$col-letter}{$construct-row}">
                                <xsl:choose>
                                    <xsl:when test="$fixed-value">
                                        <v><xsl:value-of select="$fixed-value"/></v>
                                    </xsl:when>
                                </xsl:choose>
                            </c>
                        </xsl:for-each>
                    </row>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- ============ variabelen =========== -->
    
    <xsl:template match="worksheet" mode="process-variabelen">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- ============ algemeen =========== -->
    
    <!-- 
        Op welke regel start dit blok?
    -->
    <xsl:function name="imf:get-row-for-block" as="xs:integer">
        <xsl:param name="block" as="element()"/>
        <xsl:variable name="sheet" select="$block/@sheet"/> <!-- must be on the same sheet --> 
        <xsl:value-of select="count($block/preceding::cp:prop[../@sheet = $sheet]) + 2"/> <!-- add sheet header line, and row numbers start at 1. -->
    </xsl:function>
    
    <!-- 
        Context elements may or may not be part of the template. 
        When part, return that element, when not, create one for templates to fire. 
    -->    
    <xsl:function name="imf:select-context-element" as="item()*">
        <xsl:param name="parent" as="element()"/>
        <xsl:param name="element-names" as="xs:string+"/>
        <xsl:for-each select="$element-names">
            <xsl:variable name="element-name" select="."/>
            <xsl:variable name="child" select="$parent/*[name() = $element-name]"/>
            <xsl:choose>
                <xsl:when test="exists($child)">
                    <xsl:sequence select="$child"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="{$element-name}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="zip-content-wrapper:dummy"/>
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
