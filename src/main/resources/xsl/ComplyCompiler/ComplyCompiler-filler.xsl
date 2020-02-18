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
  
    xmlns:cw="http://www.armatiek.nl/namespace/zip-content-wrapper"
    
    xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    xpath-default-namespace="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" 
    xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" 
    xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main" 
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    
    xmlns:v="urn:schemas-microsoft-com:vml"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:x="urn:schemas-microsoft-com:office:excel"
    xmlns:mv="http://macVmlSchemaUri"           
    
    xmlns:content-types="http://schemas.openxmlformats.org/package/2006/content-types"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:functx="http://www.functx.com"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:cp="http://www.imvertor.org/schema/comply-excel"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
   
    <xsl:variable name="debug" select="true()"/>
    
    <xsl:variable name="ooxml-namespace" select="'http://schemas.openxmlformats.org/spreadsheetml/2006/main'"/>
    <xsl:variable name="ooxml-schemalocation-file" select="'D:\projects\validprojects\Kadaster-Imvertor\Imvertor-OS\ImvertorCommon\trunk\xsd\ooxml\sml.xsd'"/>
    <xsl:variable name="ooxml-schemalocation-url" select="imf:file-to-url($ooxml-schemalocation-file)"/>
    
    <xsl:variable name="quot">"</xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>
    
    <xsl:variable name="sheet-gegevensgroepen-tab-name">Gegevensgroepen</xsl:variable>
    <xsl:variable name="xsi-schema-reference" as="attribute()?">
        <xsl:attribute name="xsi:schemaLocation" select="concat($ooxml-namespace,' ', $ooxml-schemalocation-url)"/>
    </xsl:variable>
    
    <!-- 
        prepare all info from EP message set, transform to a worksheet block-buildup that can be processed "in sequence"
    -->
    <xsl:variable name="imvertor-ep-result-path" select="imf:get-config-string('system','imvertor-ep-result')"/>
    <xsl:variable name="message-set-flat" select="imf:document($imvertor-ep-result-path,true())/cp:sheets"/>
    
    <!-- 
        get the sheets from template 
    -->
    <xsl:variable name="__content" select="/"/>
    <xsl:variable name="sheet1" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet1.xml']/worksheet"/>
    <xsl:variable name="sheet2" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet2.xml']/worksheet"/>
    <xsl:variable name="sheet3" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet3.xml']/worksheet"/>
    <xsl:variable name="sheet4" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet4.xml']/worksheet"/> <!-- store namespaces there -->
    <xsl:variable name="sheet5" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet5.xml']/worksheet"/> <!-- store metadata there -->
    
    <xsl:variable name="comments1" select="$__content/cw:files/cw:file[@path = 'xl\comments1.xml']/comments"/>
    <xsl:variable name="comments2" select="$__content/cw:files/cw:file[@path = 'xl\comments2.xml']/comments"/>

    <xsl:variable name="drawings1" select="$__content/cw:files/cw:file[@path = 'xl\drawings\vmlDrawing1.vml']/*:xml"/>
    <xsl:variable name="drawings2" select="$__content/cw:files/cw:file[@path = 'xl\drawings\vmlDrawing2.vml']/*:xml"/>
    
    <xsl:variable name="namespaces" select="$message-set-flat/cp:sheet[3]/cp:ns"/> <!-- <ns prefix="prefix">namespace</ns> -->
    
    <xsl:template match="/">
        <!--process the template -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="cw:file/worksheet">
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
            <xsl:sequence select="$xsi-schema-reference"/>
            <xsl:choose>
                <xsl:when test=". is $sheet1">
                    <xsl:apply-templates select="$worksheet" mode="process-berichten"/>
                </xsl:when>
                <xsl:when test=". is $sheet2">
                    <xsl:apply-templates select="$worksheet" mode="process-complextypes"/>
                </xsl:when>
                <xsl:when test=". is $sheet3">
                    <xsl:apply-templates select="$worksheet" mode="process-variabelen"/>
                </xsl:when>
                <xsl:when test=". is $sheet4">
                    <xsl:apply-templates select="$worksheet" mode="process-namespaces"/>
                </xsl:when>
                <xsl:when test=". is $sheet5">
                    <xsl:apply-templates select="$worksheet" mode="process-metadata"/>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="cw:file/workbook">
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
            <xsl:sequence select="$xsi-schema-reference"/>
            <xsl:apply-templates select="$workbook" mode="process-workbook"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="cw:file/comments">
        <xsl:variable name="comments" select="imf:select-context-element(.,(
            'authors',
            'commentList'))"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:sequence select="$xsi-schema-reference"/>
            <xsl:choose>
                <xsl:when test=". is $comments1">
                    <xsl:apply-templates select="$comments" mode="process-berichten"/>
                </xsl:when>
                <xsl:when test=". is $comments2">
                    <xsl:apply-templates select="$comments" mode="process-complextypes"/>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="cw:file/*:xml">
        <xsl:variable name="drawings" select="imf:select-context-element(.,(
            'o:shapelayout',
            'v:shapetype',
            'v:shape'))"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test=". is $drawings1">
                    <xsl:apply-templates select="$drawings" mode="process-berichten"/>
                </xsl:when>
                <xsl:when test=". is $drawings2">
                    <xsl:apply-templates select="$drawings" mode="process-complextypes"/>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO hoe? -->
    <xsl:template match="cw:XXXfile/content-types:Types" xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
        
        <xsl:variable name="types" select="imf:select-context-element(.,(
            'Default',
            'Override'))"/>
        
        <xsl:copy>
            <xsl:apply-templates select="$types" mode="process-content-types"/>
           
            <!-- en voeg toe??? -->
            <Default Extension="vml" ContentType="application/vnd.openxmlformats-officedocument.vmlDrawing"/>
            <Override PartName="/xl/comments1.xml"
                ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml"/>
            <Override PartName="/xl/comments2.xml"
                ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml"/>
            
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
    
    <xsl:template match="conditionalFormatting" mode="process-variabelen process-namespaces process-metadata">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="()"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="conditionalFormatting[exists(preceding-sibling::conditionalFormatting)]" mode="process-all">
        <!-- skip these; only process the first in range; no wrapper in ooxml -->
    </xsl:template>
    
    <xsl:template match="conditionalFormatting" mode="process-all">
        <xsl:param name="blocks"/>
        <!-- this is the frst, triggers the insertion -->
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
        <xsl:if test="exists($blocks)">
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
        </xsl:if>
        <!-- then for each block of input -->
        <xsl:for-each select="$ranges">
            <conditionalFormatting sqref="{imf:create-range(.)}">
                <xsl:variable name="volgnummer" select="position()"/>
                <cfRule type="expression" dxfId="0" priority="{$volgnummer}" stopIfTrue="1">
                    <formula>D$<xsl:value-of select="@hn"/>=""</formula>
                </cfRule>
            </conditionalFormatting>
        </xsl:for-each>
        <!-- then for each prop within block, when choice -->
        <xsl:for-each select="$blocks/cp:prop[@group = 'choice']">
            <xsl:variable name="range" as="element(range)">
                <xsl:variable name="start-col-letter">D</xsl:variable>
                <xsl:variable name="end-col-letter">K</xsl:variable>
                <xsl:variable name="gegevensgroep-header-rij" select="imf:get-row-for-block(..)"/>
                <xsl:variable name="element-rij" select="imf:get-row-for-prop(.)"/>
                <range sl="{$start-col-letter}" el="{$end-col-letter}" sn="{$element-rij}" en="{$element-rij}" hn="{$gegevensgroep-header-rij}"/> 
            </xsl:variable>
            <conditionalFormatting sqref="{imf:create-range($range)}">
                <xsl:variable name="volgnummer" select="position()"/>
                <cfRule type="containsBlanks" dxfId="3" priority="{1000+$volgnummer}" stopIfTrue="1">
                    <formula>LEN(TRIM(D<xsl:value-of select="$range/@sn"/>))=0</formula>
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
            <xsl:with-param name="blocks" select="()"/>
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
    <xsl:template match="dataValidations" mode="process-variabelen process-namespaces process-metadata">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="()"/>
        </xsl:apply-templates>
    </xsl:template>
 
    <!-- 
        de data validaties zijn gebaseerd op het overzicht:
        "d:\projects\validprojects\KING\planio-repository\StUF Schemagenerator\Documentatie\PoC Compliancy berichten\inventarisatie simpleType restricties.xlsx"
        deze template levert twee soorten elementen op:
        
        dataValidation voor formele validatie
        r elementen voor binnen een text element in comments
        
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
                <xsl:variable name="ref" select="@ref"/>
                
                <xsl:choose>
                    <!-- base type = complex type -->
                    <xsl:when test="exists($ref)">
                        <xsl:variable name="group-header" select="$message-set-flat/cp:sheet[2]/cp:block[cp:id = $ref]"/>
                        <xsl:variable name="group-row" select="count($group-header/preceding::cp:prop[../@sheet='2']) + 2"/>
                        <xsl:sequence select="imf:create-data-validation(.,'list',(),concat($sheet-gegevensgroepen-tab-name,'!$D$', $group-row, ':$K$', $group-row),(),$sqref)"/>
                    </xsl:when>
                    <xsl:when test="cp:enum">
                        <xsl:sequence select="imf:create-data-validation(.,'list',(),concat($quot,cp:enum,$quot),(),$sqref)"/>
                    </xsl:when>
                    <xsl:when test="cp:type = 'scalar-integer'">
                        <!-- when no bounds set, calculate integer value, always positive. -->
                        <xsl:variable name="mininclusive" select="
                            if (cp:mininclusive) 
                            then cp:mininclusive 
                            else 
                                if (cp:minlength) 
                                then 10 * (xs:integer(cp:minlength) - 1) 
                                else ()"/>
                        <xsl:variable name="maxinclusive" select="
                            if (cp:maxinclusive) 
                            then cp:maxinclusive 
                            else 
                                if (cp:maxlength) 
                                then xs:integer(functx:repeat-string('9',xs:integer(cp:maxlength)))  
                                else ()"/>
                        <xsl:choose>
                            <!-- getalminmaxwaarde - geheel getal met minimum en maximum waarde -->
                            <xsl:when test="$mininclusive and $maxinclusive">
                                <xsl:sequence select="imf:create-data-validation(.,'whole',(),$mininclusive,$maxinclusive,$sqref)"/>
                            </xsl:when>  
                            <!-- getalminmaxwaarde - geheel getal met minimum waarde -->
                            <xsl:when test="$mininclusive">
                                <xsl:sequence select="imf:create-data-validation(.,'whole','greaterThanOrEqual',$mininclusive,(),$sqref)"/>
                            </xsl:when>                    
                            <!-- getalminmaxwaarde - geheel getal met maximum waarde -->
                            <xsl:when test="$maxinclusive">
                                <xsl:sequence select="imf:create-data-validation(.,'whole','lessThanOrEqual',$maxinclusive,(),$sqref)"/>
                            </xsl:when>                    
                            <!-- geheel getal -->
                            <xsl:otherwise>
                                <xsl:sequence select="imf:create-data-validation(.,'whole',(),(),(),$sqref)"/>
                            </xsl:otherwise>                    
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="cp:type = 'scalar-decimal'">
                        <xsl:choose>
                            <!-- ?? gebroken getal -->
                            <xsl:when test="cp:totaldigits">
                                <xsl:sequence select="imf:create-data-validation(.,'whole',(),concat('-',$form),$form,$sqref)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- no additional validations -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="cp:type = 'scalar-boolean'">
                        <xsl:sequence select="imf:create-data-validation(.,'list',(),concat($quot,'0,1,true,false',$quot),(),$sqref)"/>
                    </xsl:when>
                    <xsl:when test="cp:type = 'scalar-string'">
                        <xsl:choose>
                            <xsl:when test="cp:minlength and cp:maxlength and (cp:minlength eq cp:maxlength)">
                                <xsl:sequence select="imf:create-data-validation(.,'textLength','equal',cp:maxlength,(),$sqref)"/>
                            </xsl:when>
                            <xsl:when test="cp:minlength and cp:maxlength">
                                <xsl:sequence select="imf:create-data-validation(.,'textLength',(),cp:minlength,cp:maxlength,$sqref)"/>
                            </xsl:when>
                            <!-- tekenreeks of getal met maximale lengte -->
                            <xsl:when test="cp:maxlength">
                                <xsl:sequence select="imf:create-data-validation(.,'textLength','lessThanOrEqual',cp:maxlength,(),$sqref)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- no additional validations -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($result)">
            <dataValidations count="{count($result)}">
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
            <xsl:comment select="concat('data validation on ',$prop/cp:name)"/>
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
        •	name
        •	is-id
        •	type-name
        •	min-length
        •	max-length
        •	pattern
        •	voidable
        •	kerngegeven
        •	authentiek
        •	regels
        •	min-value
        •	max-value
        •	documentation
    -->
    <xsl:function name="imf:create-data-comment">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="normalize-space($value)">
            <r>
                <rPr>
                    <b/>
                    <!--
                    <sz val="9"/>
                    <color indexed="81"/>
                    <rFont val="Calibri"/>
                    <family val="2"/>
                    -->
                </rPr>
                <t xml:space="preserve"><xsl:value-of select="concat($name,': ')"/></t>
            </r>
            <r>
                <rPr>
                    <!--
                    <sz val="9"/>
                    <color indexed="81"/>
                    <rFont val="Calibri"/>
                    <family val="2"/>
                    -->
                </rPr>
                <t xml:space="preserve"><xsl:value-of select="concat(imf:safe-text(normalize-space($value)),'&#10;')"/></t>
            </r>
        </xsl:if>
    </xsl:function>
    
    <!--geen legacy drawing, dus maak er eentje -->
    <xsl:template match="legacyDrawing" mode="process-berichten process-complextypes process-variabelen process-namespaces process-metadata">
        <xsl:copy>
            <xsl:attribute name="r:id">rId1</xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        Iedere construct//construct wordt op sheet 2 geplaatst. Er moet dus een hyperlink naar toe kunnen vanaf sheet 1 en 2.
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
    
    <xsl:template match="hyperlinks" mode="process-variabelen process-namespaces process-metadata">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="()"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="hyperlinks" mode="process-all">
        <xsl:param name="blocks"/> <!-- always within a single sheet -->
        <xsl:variable name="sheet" select="$blocks[1]/@sheet"/> 
        <xsl:variable name="result" as="element()*">
            <xsl:for-each select="$blocks/cp:prop[exists(@ref)]">
                <xsl:variable name="element-rij" select="count(preceding::cp:prop[../@sheet=$sheet]) + 2"/>
                <xsl:variable name="sequence-id" select="@ref"/>
                <xsl:variable name="element-name" select="cp:name"/>
                <hyperlink ref="B{$element-rij}" location="{$sequence-id}" display="{$element-name}"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($result)">
            <hyperlinks>
                <xsl:sequence select="$result"/>
            </hyperlinks>
        </xsl:if>
    </xsl:template>
    
    <!-- == comments == -->
    
    <xsl:template match="authors" mode="process-berichten">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[1]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="authors" mode="process-all">
        <authors>
            <author>Frank Samwel</author>
            <!--<xsl:value-of select="concat($imvertor-version, ' at ', current-dateTime())"/>-->
        </authors>
    </xsl:template>
    
    <xsl:template match="commentList" mode="process-berichten">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[1]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="commentList" mode="process-complextypes">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[2]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="commentList" mode="process-all">
        <xsl:param name="blocks"/>
        <xsl:variable name="sheet-number" select="$blocks[1]/@sheet"/>
        <xsl:copy>
            <xsl:for-each select="$blocks">
                <xsl:variable name="message-row" select="imf:get-row-for-block(.)"/>
                <xsl:for-each select="cp:prop[@type=('header','spec')]">     
                    <xsl:variable name="construct-col" select="if (@type='header') then 'A' else 'B'"/>
                    <xsl:variable name="construct-row" select="$message-row + count(preceding-sibling::cp:prop)"/>
                    <xsl:variable name="comment-lines" as="element(r)*">
                        <xsl:sequence select="imf:create-data-comment('Is ID',cp:xxx)"/>    <!-- TODO -->
                        <xsl:sequence select="imf:create-data-comment('Type',cp:type)"/>    
                        <xsl:sequence select="imf:create-data-comment('Min lengte',cp:minlength)"/>    
                        <xsl:sequence select="imf:create-data-comment('Max lengte',cp:maxlength)"/>    
                        <xsl:sequence select="imf:create-data-comment('Patroon',cp:pattern)"/>    
                        <xsl:sequence select="imf:create-data-comment('Patroon beschrijving',cp:patterndesc)"/>    
                        <xsl:sequence select="imf:create-data-comment('Voidable',cp:voidable)"/>    
                        <xsl:sequence select="imf:create-data-comment('Matchgegeven',cp:matchgegeven)"/>    
                        <xsl:sequence select="imf:create-data-comment('Authentiek',cp:authentiek)"/>    
                        <xsl:sequence select="imf:create-data-comment('Regels',cp:regels)"/>    
                        <xsl:sequence select="imf:create-data-comment('Min waarde',cp:mininclusive)"/>    
                        <xsl:sequence select="imf:create-data-comment('Max waarde',cp:maxinclusive)"/>    
                        <xsl:sequence select="imf:create-data-comment('Definitie',cp:definition)"/>    
                        <xsl:sequence select="imf:create-data-comment('Omschrijving',cp:description)"/>    
                        <xsl:sequence select="imf:create-data-comment('Tip',cp:tip)"/>   
                    </xsl:variable>
                    <xsl:if test="exists($comment-lines)">
                        <comment ref="{$construct-col}{$construct-row}" authorId="0" > <!-- TODO ? shapeId="comment_{$sheet-number}_{$message-row}" -->
                            <text>
                                <xsl:sequence select="$comment-lines"/>
                            </text>
                        </comment>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="v:shape" mode="process-berichten">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[1]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="v:shape" mode="process-complextypes">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[2]/cp:block"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="v:shape[exists(preceding-sibling::v:shape)]" mode="process-all">
        <!-- skip; only process first in range -->
    </xsl:template>
    
    <xsl:template match="v:shape" mode="process-all">
        <xsl:param name="blocks"/>
        <xsl:variable name="sheet-number" select="$blocks[1]/@sheet"/>
        <xsl:for-each select="$blocks">
            <xsl:variable name="message-row" select="imf:get-row-for-block(.)"/>
            <xsl:for-each select="cp:prop[@type='spec']">     
                <xsl:variable name="construct-row" select="$message-row + count(preceding-sibling::cp:prop)"/>
                <xsl:variable name="margin-top" select="($construct-row * 16) - 25"/>
                <xsl:variable name="width" select="282"/>
                <xsl:variable name="height" select="29"/>
                <v:shape 
                    id="comment_{$sheet-number}_{$construct-row}"
                    type="#_x0000_t202"
                    style="position:absolute;margin-left:50pt;margin-top:{$margin-top}pt;width:{$width}pt;height:{$height}pt;z-index:1;visibility:hidden;mso-wrap-style:tight"
                    fillcolor="#fbf6d6"
                    strokecolor="#edeaa1">
                    <v:fill color2="#fbfe82" angle="-180" type="gradient">
                        <o:fill v:ext="view" type="gradientUnscaled"/>
                    </v:fill>
                    <v:shadow on="t" obscured="t"/>
                    <v:path o:connecttype="none"/>
                    <v:textbox>
                        <div style="text-align:left"/>
                    </v:textbox>
                    <x:ClientData ObjectType="Note">
                        <x:MoveWithCells/>
                        <x:SizeWithCells/>
                        <x:Anchor>1, 15, <xsl:value-of select="$construct-row - 2"/>, 6, 6, 20, <xsl:value-of select="$construct-row + 13"/>, 2</x:Anchor>
                        <x:AutoFill>False</x:AutoFill>
                        <x:Row><xsl:value-of select="$construct-row - 1"/></x:Row>
                        <x:Column>1</x:Column>
                    </x:ClientData>
                </v:shape>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ============ complextypes =========== -->
    
    <!-- sheet data must be added based on namespace declarations -->
    <xsl:template match="sheetData" mode="process-namespaces">
        <xsl:copy>
            <!-- skip first row -->
            <xsl:apply-templates select="row[1]"/>
            <xsl:for-each select="$namespaces">
                <xsl:variable name="message-row" select="position() + 1"/>
                <xsl:sequence select="imf:create-row($message-row,@prefix,.,3)"/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- add all info required for processing the XML here -->
    <xsl:template match="sheetData" mode="process-metadata">
        <xsl:copy>
            <!-- skip first row -->
            <xsl:apply-templates select="row[1]"/>
            
            <xsl:sequence select="imf:create-row(2,'creation-version',imf:get-config-string('run','version'),3)"/>
            <xsl:sequence select="imf:create-row(3,'creation-date',imf:format-dateTime(current-dateTime()),3)"/>
        
            <xsl:sequence select="imf:create-row(5,'edit-version','(enter version info here)',0)"/>
            <xsl:sequence select="imf:create-row(6,'edit-date','(enter date here)',0)"/>
            
            <xsl:sequence select="imf:create-row(9,'schema-prefix',imf:get-config-string('appinfo','koppelvlak-namespace-prefix'),3)"/>
            <xsl:sequence select="imf:create-row(10,'schema-namespace',imf:get-config-string('appinfo','koppelvlak-namespace'),3)"/>
            <xsl:sequence select="imf:create-row(11,'schema-subpath',imf:get-config-string('appinfo','xsd-result-subpath-kv'),3)"/>
       
            <xsl:sequence select="imf:create-row(13,'job-id',imf:get-config-string('cli','jobid'),3)"/>
            <xsl:sequence select="imf:create-row(14,'project-name',imf:get-config-string('appinfo','project-name'),3)"/>
            <xsl:sequence select="imf:create-row(15,'model-name',imf:get-config-string('appinfo','application-name'),3)"/>
            <xsl:sequence select="imf:create-row(16,'model-release',imf:get-config-string('appinfo','release'),3)"/>
            
            <!--x
            <xsl:for-each select="0 to 10">
                <row r="{. + 30}" spans="2:2">
                    <c r="B{. + 30}" s="{.}" t="inlineStr">
                        <is>
                            <t>TESTJE @s = <xsl:value-of select="."/></t>
                        </is>
                    </c>
                </row>
            </xsl:for-each>
            x-->
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:create-row">
        <xsl:param name="rownr"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:param name="style"/>
        <row r="{$rownr}" spans="1:2">
            <c r="A{$rownr}" s="{$style}" t="inlineStr">
                <is>
                    <t><xsl:value-of select="$name"/></t>
                </is>
            </c>
            <c r="B{$rownr}" s="{$style}" t="inlineStr">
                <is>
                    <t><xsl:value-of select="$value"/></t>
                </is>
            </c>
        </row>
    </xsl:function>

    <!-- standard processing of sheet data -->
    <xsl:template match="sheetData" mode="process-all">
        <xsl:param name="blocks"/>
        <xsl:variable name="sheet-number" select="$blocks[1]/@sheet"/>
        
        <xsl:copy>
            
            <!-- skip first row -->
            <xsl:apply-templates select="row[1]"/>
            
            <!-- process all messages and top constructs -->
            <xsl:for-each select="$blocks">
                <xsl:variable name="message-row" select="imf:get-row-for-block(.)"/>
                <xsl:variable name="message-name" select="cp:prop[@type='header']/cp:name"/>
                <xsl:variable name="message-tip" select="cp:prop[@type='header']/cp:tip"/>
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
                <xsl:for-each select="cp:prop">
                    <xsl:variable name="construct-row" select="$message-row + count(preceding-sibling::cp:prop)"/>
                    <!-- Maak een row voor iedere construct. -->
                    <xsl:variable name="tech-name" select="cp:name"/>
                    <xsl:variable name="cardinality" select="cp:cardinal"/>
                    <xsl:variable name="is-attribute" select="cp:attribute = 'true'"/>
                    <xsl:variable name="is-choice" select="@group = 'choice'"/>
                    <xsl:variable name="fixed-value" select="cp:fixed"/>
                    <xsl:choose>
                        <xsl:when test="@type='spec'">
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
                                                <xsl:when test="$is-choice">
                                                    <xsl:attribute name="s" select="6"/> 
                                                </xsl:when>
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
                                    <xsl:choose>
                                        <xsl:when test="$fixed-value">
                                            <c r="{$col-letter}{$construct-row}">
                                                <v><xsl:value-of select="$fixed-value"/></v>
                                            </c>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                            </row>
                        </xsl:when>
                        <xsl:when test="@type='choice'">
                            <!-- the choice header -->
                            <row r="{$construct-row}" spans="1:11">
                                <c r="B{$construct-row}" t="inlineStr" s="5">
                                    <is>
                                        <t>
                                            CHOICE
                                        </t>
                                    </is>
                                </c>
                                <c r="C{$construct-row}" t="inlineStr">
                                    <is>
                                        <t>
                                            <xsl:value-of select="$cardinality"/>
                                        </t>
                                    </is>
                                </c>
                            </row>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:copy>
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
        op welke regel staat deze prop? 
    -->
    <xsl:function name="imf:get-row-for-prop" as="xs:integer">
        <xsl:param name="prop" as="element()"/>
        <xsl:value-of select="imf:get-row-for-block($prop/..) + count($prop/preceding-sibling::cp:prop)"/>
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
    
    <xsl:template match="cw:dummy"/>
    
    <xsl:template match="node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*" mode="#all">
        <xsl:sequence select="."/>
    </xsl:template>
    <xsl:template match="@*:Ignorable" mode="#all">
        <!-- skip -->
    </xsl:template>
    <xsl:template match="@*:dyDescent" mode="#all">
        <!-- skip -->
    </xsl:template>
    
    <xsl:function name="imf:create-range">
        <xsl:param name="range"/>
        <xsl:value-of select="concat($range/@sl,$range/@sn,':',$range/@el,$range/@en)"/>
    </xsl:function>
  
    <xsl:function name="imf:safe-text">
        <xsl:param name="text"/>
        <xsl:variable name="textr" select="replace($text,concat('[^A-Za-z0-9:_@%&amp;\*;,\.=+\-\s\(\)\{\}\[\]\?!\\',$quot,$apos,']'),'?')"/>
        <xsl:value-of select="if ($textr = $text) then $text else $textr"> <!-- was: concat($textr,'&#10;[Description character issues resolved, see original text for full explanation]') -->
        </xsl:value-of>
    </xsl:function>
</xsl:stylesheet>
