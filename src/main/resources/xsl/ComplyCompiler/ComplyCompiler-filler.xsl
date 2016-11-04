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
    
    <xsl:variable name="sheet-gegevensgroepen-tab-name">'Complex types'</xsl:variable>
    <xsl:variable name="xsi-schema-reference" as="attribute()?">
        <xsl:attribute name="xsi:schemaLocation" select="concat($ooxml-namespace,' ', $ooxml-schemalocation-url)"/>
    </xsl:variable>
    
    <!-- 
        prepare all info from EP message set, transform to a worksheet block-buildup that can be processed "in sequence"
    -->
    <xsl:variable name="imvertor-ep-result-path" select="imf:get-config-string('system','imvertor-ep-result')"/>
    <xsl:variable name="message-set-flat" select="imf:document($imvertor-ep-result-path)/cp:sheets"/>
    
    <!-- 
        get the sheets from template 
    -->
    <xsl:variable name="__content" select="/"/>
    <xsl:variable name="sheet1" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet1.xml']/worksheet"/>
    <xsl:variable name="sheet2" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet2.xml']/worksheet"/>
    <xsl:variable name="sheet3" select="$__content/cw:files/cw:file[@path = 'xl\worksheets\sheet3.xml']/worksheet"/>
   
    <xsl:variable name="comments1" select="$__content/cw:files/cw:file[@path = 'xl\comments1.xml']/comments"/>
    <xsl:variable name="comments2" select="$__content/cw:files/cw:file[@path = 'xl\comments2.xml']/comments"/>

    <xsl:variable name="drawings1" select="$__content/cw:files/cw:file[@path = 'xl\drawings\vmlDrawing1.vml']/*:xml"/>
    <xsl:variable name="drawings2" select="$__content/cw:files/cw:file[@path = 'xl\drawings\vmlDrawing2.vml']/*:xml"/>
    
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
    
    <xsl:template match="conditionalFormatting" mode="process-variabelen">
        <xsl:apply-templates select="." mode="process-all">
            <xsl:with-param name="blocks" select="$message-set-flat/cp:sheet[3]/cp:block"/>
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
                 
                    <!-- getalminmaxwaarde - geheel getal met minimum en maximum waarde -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:mininclusive and cp:maxinclusive">
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),cp:mininclusive,cp:maxinclusive,$sqref)"/>
                    </xsl:when>  
                    <!-- getalminmaxwaarde - geheel getal met minimum waarde -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:mininclusive">
                        <xsl:sequence select="imf:create-data-validation(.,'whole','greaterThanOrEqual',cp:mininclusive,(),$sqref)"/>
                    </xsl:when>                    
                    <!-- getalminmaxwaarde - geheel getal met maximum waarde -->
                    <xsl:when test="cp:type = 'scalar-integer' and cp:maxinclusive">
                        <xsl:sequence select="imf:create-data-validation(.,'whole','lowerThanOrEqual',(),cp:maxinclusive,$sqref)"/>
                    </xsl:when>                    
                    
                    
                    <!-- ?? gebroken getal -->
                    <xsl:when test="cp:type = 'scalar-decimal' and cp:totaldigits">
                        <xsl:sequence select="imf:create-data-validation(.,'whole',(),concat('-',$form),$form,$sqref)"/>
                    </xsl:when>
                    
                    <xsl:when test="cp:type = 'scalar-boolean'">
                        <xsl:sequence select="imf:create-data-validation(.,'list',(),concat($quot,'0,1,true,false',$quot),(),$sqref)"/>
                    </xsl:when>
                    
                    <!-- tekenreeks of getal met vaste lengte -->
                    <xsl:when test="cp:type = ('scalar-string','scalar-integer') and cp:minlength and cp:maxlength and (cp:minlength eq cp:maxlength)">
                        <xsl:sequence select="imf:create-data-validation(.,'textLength','equal',cp:maxlength,(),$sqref)"/>
                    </xsl:when>
                    <xsl:when test="cp:type = ('scalar-string','scalar-integer') and cp:minlength and cp:maxlength">
                        <xsl:sequence select="imf:create-data-validation(.,'textLength',(),cp:minlength,cp:maxlength,$sqref)"/>
                    </xsl:when>
                    
                    <?TODO
                    <!-- tekenreeks of getal met minimale lengte -->
                    <xsl:when test="cp:type = ('scalar-string','scalar-integer') and cp:minlength">
                        <xsl:sequence select="imf:create-data-validation(.,'textLength','greaterThanOrEqual',cp:minlength,(),$sqref)"/>
                    </xsl:when>
                    ?>
                    
                    <!-- tekenreeks of getal met maximale lengte -->
                    <xsl:when test="cp:type = ('scalar-string','scalar-integer') and cp:maxlength">
                        <xsl:sequence select="imf:create-data-validation(.,'textLength','lessThanOrEqual',cp:maxlength,(),$sqref)"/>
                    </xsl:when>
                    
                    <!-- enumeratie - enumeratie -->
                    <xsl:when test="cp:enum">
                        <xsl:sequence select="imf:create-data-validation(.,'list',(),concat($quot,cp:enum,$quot),(),$sqref)"/>
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
    
   <!-- sheet 3 heeft geen legacy drawing dus maak er eentje -->
    <xsl:template match="legacyDrawing" mode="process-variabelen">
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
                <xsl:for-each select="cp:prop[@type='spec']">     
                    <xsl:variable name="construct-row" select="$message-row + count(preceding-sibling::cp:prop)"/>
                    <xsl:variable name="comment-lines" as="element(r)*">
                        <xsl:sequence select="imf:create-data-comment('Naam',cp:name)"/>    
                        <xsl:sequence select="imf:create-data-comment('Is ID',cp:xxx)"/>    
                        <xsl:sequence select="imf:create-data-comment('Type',cp:type)"/>    
                        <xsl:sequence select="imf:create-data-comment('Min lengte',cp:minlength)"/>    
                        <xsl:sequence select="imf:create-data-comment('Max lengte',cp:maxlength)"/>    
                        <xsl:sequence select="imf:create-data-comment('Patroon',cp:pattern)"/>    
                        <xsl:sequence select="imf:create-data-comment('Patroon beschrijving',cp:patterndesc)"/>    
                        <xsl:sequence select="imf:create-data-comment('Voidable',cp:voidable)"/>    
                        <xsl:sequence select="imf:create-data-comment('Kerngegeven',cp:kerngegeven)"/>    
                        <xsl:sequence select="imf:create-data-comment('Authentiek',cp:authentiek)"/>    
                        <xsl:sequence select="imf:create-data-comment('Regels',cp:regels)"/>    
                        <xsl:sequence select="imf:create-data-comment('Min waarde',cp:mininclusive)"/>    
                        <xsl:sequence select="imf:create-data-comment('Max waarde',cp:maxinclusive)"/>    
                        <xsl:sequence select="imf:create-data-comment('Documentatie',cp:documentation)"/>    
                    </xsl:variable>
                    <xsl:if test="exists($comment-lines)">
                        <comment ref="B{$construct-row}" authorId="0" > <!-- TODO ? shapeId="comment_{$sheet-number}_{$message-row}" -->
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
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:create-range">
        <xsl:param name="range"/>
        <xsl:value-of select="concat($range/@sl,$range/@sn,':',$range/@el,$range/@en)"/>
    </xsl:function>
  
    <xsl:function name="imf:safe-text">
        <xsl:param name="text"/>
        <xsl:variable name="textr" select="replace($text,concat('[^A-Za-z0-9:@%&amp;\*;,\.=+\-\s\(\)\{\}\[\]\?!\\',$quot,$apos,']'),'?')"/>
        <xsl:value-of select="if ($textr = $text) then $text else concat($textr,'&#10;[Description character issues resolved, see original text for full explanation]')">
        </xsl:value-of>
    </xsl:function>
</xsl:stylesheet>
