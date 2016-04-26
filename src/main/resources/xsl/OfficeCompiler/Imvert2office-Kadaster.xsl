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

    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
         INTEGRALE KOPIE VAN KINGSIM. MOETEN WE DIT NIET SAMENTREKKEN?
        
       IM-284  Documentatie bij imkad/cdmkad in opgemaakte PDF vorm
    -->
    
    <!--<xsl:import href="http://www.imvertor.org/imvertor/1.0/xslt/common/Imvert-common.xsl"/>-->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    
   <xsl:variable name="quot"><!--'--></xsl:variable>
    
    <xsl:variable name="pre-headed-result" as="item()*">
        <xsl:apply-templates select="/imvert:packages/imvert:package"/>
    </xsl:variable>
    <xsl:variable name="pre-header-result-start" select="-1"/> <!-- the header structure starts at h0 -->
    
    <xsl:template match="/imvert:packages">
        <html>
            <head>
                <meta charset="UTF-8"/> 
                <style type="text/css">
                    body {
                    font-family:"Calibri","Verdana",sans-serif;
                        font-size:11.0pt;
                    }
                    table {
                        width: 100%;
                    }
                    table, th, td {
                        border: none;
                        font-size:11.0pt;
                    }
                    td {
                        vertical-align: top;
                    }
                    h1, h2, h3, h4,h5 {
                        color:#003359;
                    }
                    h1 {
                        page-break-before:always;
                        font-size:16.0pt;
                    }
                    h2 {
                        font-size:12.0pt;
                    }
                    h3 {
                        font-size:12.0pt;
                    }
                    h4 {
                    font-size:12.0pt;
                    }
                    h5 {
                    font-size:12.0pt;
                    }
                    tr.tableheader {
                        font-style: italic;
                    }
                </style>
            </head>
            <body>
                <p>
                    <xsl:value-of select="concat($application-package-release-name, ' | ', $imvertor-version, ' | ', $generation-date)"/>
                </p>
                <xsl:apply-templates select="$pre-headed-result" mode="toc"/>
                <xsl:apply-templates select="$pre-headed-result" mode="headers"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="imvert:package[exists(imvert:name/@original)]">
        <h-1>Package <xsl:value-of select="imvert:name/@original"/></h-1>
        
        <h0>Overzicht</h0>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-objecttype','Objecttypen',false())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-relatieklasse','Relatieklassen',false())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-referentielijst','Referentielijsten',false())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-union','Unions',false())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-complextype','Datatypen',false())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-enumeration','Enumeraties',false())"/>
        
        <h0>Details</h0>
        
        <xsl:sequence select="imf:get-section(.,'stereotype-name-objecttype','Objecttypen',true())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-relatieklasse','Relatieklassen',true())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-referentielijst','Referentielijsten',true())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-union','Unions',true())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-complextype','Datatypen',true())"/>
        <xsl:sequence select="imf:get-section(.,'stereotype-name-enumeration','Enumeraties',true())"/>
        
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')]">
        <xsl:variable name="is-abstract-text" select="if (imf:boolean(imvert:abstract)) then 'Ja' else 'Nee'"/>
        
        <xsl:variable name="rel-aanduiding" select="imvert:associations/imvert:association[imvert:target-stereotype = imf:get-config-stereotypes('stereotype-name-composite-id')]"/>
        <xsl:variable name="con-aanduiding" select="imf:get-construct-by-id($rel-aanduiding/imvert:type-id)"/>
        <xsl:variable name="id-aanduiding" select="imf:get-tagged-value-unieke-aanduiding(.)"/>
        
        <xsl:variable name="aanduiding">
            <xsl:choose>
                <xsl:when test="exists($rel-aanduiding) and exists($id-aanduiding)">
                    <xsl:value-of select="concat('Combinatie van ', $id-aanduiding,' en ', $con-aanduiding/imvert:name/@original)"/>
                </xsl:when>
                <xsl:when test="exists($rel-aanduiding)">
                    <xsl:value-of select="$con-aanduiding/imvert:name/@original"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$id-aanduiding"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <h2>
            <xsl:value-of select="concat('Objecttype ', imvert:name/@original)"/>
        </h2>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Mnemonic',imvert:alias)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Unieke aanduiding',$aanduiding)"/>
                <xsl:sequence select="imf:label-waarde('Indicatie abstract object',$is-abstract-text)"/>
                <xsl:sequence select="imf:label-waarde('Populatie',imf:get-tagged-value(.,'Populatie'))"/>
                <xsl:sequence select="imf:label-waarde('Kwaliteitsbegrip',imf:get-tagged-value(.,'Kwaliteitsbegrip'))"/>
            </tbody>
        </table>
        <!-- hier alle attributen; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:attributes" mode="short"/>
        <!-- hier alle relaties; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:associations" mode="short"/>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse')]">
        <h2>
            <xsl:value-of select="concat('Relatieklasse ', imvert:name/@original)"/>
        </h2>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Mnemonic',imvert:alias)"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Relatiesoort',imf:get-relatiesoort(.))"/>
            </tbody>
        </table>
        <!-- hier alle attributen; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:attributes" mode="short"/>
        <!-- hier alle relaties; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:associations" mode="short"/>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst')]">
        <h2>
            <xsl:value-of select="concat('Referentielijst ', imvert:name/@original)"/>
        </h2>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Mnemonic',imvert:alias)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Data locatie',imf:get-tagged-value(.,'Data locatie'))"/>
                <xsl:sequence select="imf:label-waarde('Unieke aanduiding',imf:get-tagged-value-unieke-aanduiding(.))"/>
            </tbody>
        </table>
        <!-- hier alle attributen; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:attributes" mode="short"/>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union')]">
        <h2>
            <xsl:value-of select="concat('Union ', imvert:name/@original)"/>
        </h2>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
             <!--TODO   <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/> -->
            </tbody>
        </table>
        <!-- hier alle attributen; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:attributes" mode="short"/>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-complextype')]">
        <h2>
            <xsl:value-of select="concat('Datatype ', imvert:name/@original)"/>
        </h2>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
            </tbody>
        </table>
        <!-- hier alle attributen; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:attributes" mode="short"/>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]">
        <xsl:variable name="naam" select="imvert:name/@original"/>
        <xsl:variable name="note" select="imf:get-formatted-compiled-documentation(.)"/>
        <xsl:sequence select="imf:label-waarde($naam,$note,true())"/>
     </xsl:template>

    <!-- uitzondering: gegevensgroeptype wordt apart getoond. -->
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')]">
        <h4>
            <xsl:value-of select="concat(imvert:stereotype, ' ', imvert:name/@original)"/>
        </h4>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Mnemonic',imvert:alias)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/> 
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Unieke aanduiding',imf:get-tagged-value-unieke-aanduiding(.))"/>
                <xsl:sequence select="imf:label-waarde('Populatie',imf:get-tagged-value(.,'Populatie'))"/>
                <xsl:sequence select="imf:label-waarde('Kwaliteitsbegrip',imf:get-tagged-value(.,'Kwaliteitsbegrip'))"/>
            </tbody>
        </table>
        <!-- hier alle attributen; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:attributes" mode="gegevensgroeptype"/>
        <!-- hier alle relaties; als ingebedde tabel -->
        <xsl:apply-templates select="imvert:associations" mode="gegevensgroeptype"/>
    </xsl:template>

    <xsl:template match="imvert:attributes" mode="short gegevensgroeptype">
        <xsl:variable name="r" as="element()*">
            <xsl:apply-templates select="imvert:attribute" mode="#current"/>
            <!-- als de class ook gegevensgroepen heeft, die attributen hier invoegen -->
            <xsl:for-each select="../imvert:associations/imvert:association">
                <xsl:variable name="defining-class" select="if (exists(imvert:type-id)) then imf:get-construct-in-derivation-by-id(imvert:type-id) else ()"/>
                <xsl:if test="$defining-class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')]">
                    <xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="gegevensgroeptype"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($r)">
            <p><b>Overzicht attributen</b></p>
            <table>
                <tbody>
                    <tr class="tableheader">
                        <td width="5%">&#160;</td>
                        <td width="25%">Attribuutnaam</td>
                        <td width="50%">Definitie</td>
                        <td width="10%">Formaat</td>
                        <td width="10%">Kardi- naliteit</td>
                    </tr>
                    <xsl:sequence select="$r"/>
                </tbody>
            </table> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="short">
        <tr>
            <td width="5%">&#160;</td>
            <td width="25%"><xsl:value-of select="imvert:name/@original"/></td>
            <td width="50%"><xsl:sequence select="imf:get-formatted-compiled-documentation(.)"/></td>
            <td width="10%"><xsl:value-of select="imf:translate(imf:splice(imvert:baretype),false())"/></td>
            <td width="10%"><xsl:value-of select="imf:get-cardinality(imvert:min-occurs,imvert:max-occurs)"/></td>
        </tr>
    </xsl:template>

    <xsl:template match="imvert:attribute" mode="gegevensgroeptype">
        <tr>
            <td>&#160;</td>
            <td>- <xsl:value-of select="imvert:name/@original"/></td>
            <td><xsl:sequence select="imf:get-formatted-compiled-documentation(.)"/></td>
            <td><xsl:value-of select="imf:translate(imvert:baretype,false())"/></td>
            <td><xsl:value-of select="imf:get-cardinality(imvert:min-occurs,imvert:max-occurs)"/></td>
        </tr>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="composition">
        <!-- toon alsof het een attribuut is -->
        <tr>
            <td>&#160;</td>
            <td><xsl:value-of select="imvert:name/@original"/>:</td>
            <td><xsl:sequence select="imf:get-formatted-compiled-documentation(.)"/></td>
            <td><xsl:value-of select="imf:translate(imvert:baretype,false())"/></td>
            <td><xsl:value-of select="imf:get-cardinality(imvert:min-occurs,imvert:max-occurs)"/></td>
        </tr>
    </xsl:template>
    
    <xsl:template match="imvert:associations" mode="short gegevensgroeptype">
        <xsl:variable name="r" as="element()*">
            <xsl:apply-templates select="imvert:association[not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-association-to-composite'))]" mode="#current"/>
        </xsl:variable>
        <xsl:if test="exists($r)">
            <p><b>Overzicht relaties</b></p>
            <table>
                <tbody>
                    <tr class="tableheader">
                        <td width="5%">&#160;</td>
                        <td width="25%">Relatienaam met kardinaliteiten</td>
                        <td width="70%">Definitie</td>
                    </tr>
                    <xsl:sequence select="$r"/>
                </tbody>
            </table> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="short gegevensgroeptype">
        <tr>
            <td width="5%">&#160;</td>
            <td width="40%">
                <!--
                Voorbeeld: ZAAKTYPE [1..*] heeft relevant BESLUITTYPE [0..*]
                -->
                <xsl:value-of select="concat(
                    ../../imvert:name/@original,
                    ' [', imf:get-cardinality(imvert:min-occurs-source,imvert:max-occurs-source), ']',
                    ' ',
                    imvert:name/@original,
                    ' ',
                    imvert:type-name/@original,
                    ' [', imf:get-cardinality(imvert:min-occurs,imvert:max-occurs), ']')"/>
            </td>
            <td width="55%"><xsl:sequence select="imf:get-formatted-compiled-documentation(.)"/></td>
        </tr>
    </xsl:template>
    
    <!-- Stel detailinfo samen voor een objecttype, relatieklasse, enumeratie -->
    <xsl:template match="imvert:class" mode="detail">
        <xsl:variable name="type" select="imf:translate(imvert:stereotype[1],true())"/>
        <h3>
            <xsl:value-of select="concat($type, ' ', imvert:name/@original)"/>
        </h3>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
        <xsl:variable name="associations" select="imvert:associations/imvert:association"/>
        <xsl:variable name="compositions" select="$associations[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-association-to-composite')]"/>
        <xsl:for-each select="$compositions">
            <xsl:variable name="defining-class" select="if (exists(imvert:type-id)) then imf:get-construct-in-derivation-by-id(imvert:type-id) else ()"/>
            <xsl:apply-templates select="$defining-class" mode="detail"/>
            <!--<xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="detail"/>-->
        </xsl:for-each>
        <xsl:apply-templates select="($associations except $compositions)" mode="detail"/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]" mode="detail">
        <h3>
            <xsl:value-of select="concat('Enumeratie ', imvert:name/@original)"/>
        </h3>
        <table>
            <tbody>
                <td width="20%">
                    <b>Definitie</b>
                </td>
                <td width="80%">
                    <xsl:sequence select="imf:get-formatted-compiled-documentation(.)"/>
                </td>
            </tbody>
        </table>
        <table>
            <tbody>
                <tr>
                    <td width="20%">
                        <i>Code</i>
                    </td>
                    <td width="30%">
                        <i>Naam</i>
                    </td>
                    <td width="50%">
                        <i>Definitie</i>
                    </td>
                </tr>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie"/>
            </tbody>        
        </table>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')]" mode="detail">
        
        <xsl:variable name="min" select="imvert:min-occurs"/>
        <xsl:variable name="max" select="imvert:max-occurs"/>
        
        <h4>
            <xsl:value-of select="concat('Gegevensgroeptype ', imvert:name/@original)"/>
        </h4>
        <table>
            <tbody>
                <!-- precies hetzelfde als voor attributen ! -->
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Code',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Mogelijk geen waarde',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie materiële historie',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie formele historie',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie in onderzoek',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:label-waarde('Aanduiding strijdigheid/nietigheid ',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality($min,$max))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie authentiek',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>
                <xsl:sequence select="imf:label-waarde('Regels',imf:get-tagged-value(.,'Regels'))"/>
            </tbody>
        </table>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>

        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
        
    </xsl:template>
    
   <xsl:template match="imvert:attribute" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="if (exists(imvert:type-id)) then imf:get-construct-in-derivation-by-id(imvert:type-id) else ()"/>
        <xsl:variable name="naam" select="$construct/imvert:name/@original"/>
        <xsl:choose>
            <xsl:when test="$defining-class/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')">
                <xsl:apply-templates select="$defining-class" mode="detail"/>
            </xsl:when>
            <xsl:when test="$construct/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')">
                <xsl:apply-templates select="." mode="detail-gegevensgroeptype"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentieelement')">
                <xsl:apply-templates select="." mode="detail-referentieelement"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union-element')">
                <xsl:apply-templates select="." mode="detail-unionelement"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype = imf:get-config-stereotypes('stereotype-name-data-element')">
                <xsl:apply-templates select="." mode="detail-dataelement"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="detail-normal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-normal">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <h4>
            <xsl:value-of select="concat('Attribuutsoort ', imvert:name/@original)"/>
        </h4>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Code',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Mogelijk geen waarde',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:label-waarde('Formaat',imf:translate(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:label-waarde('Patroon',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:label-waarde('Waardenverzameling',imf:get-tagged-value-waardenverzameling(.))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie materiële historie',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie formele historie',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie in onderzoek',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:label-waarde('Aanduiding strijdigheid/nietigheid ',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie authentiek',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie afleidbaar',$is-afleidbaar-text)"/>
                <xsl:sequence select="imf:label-waarde('Regels',imf:get-tagged-value(.,'Regels'))"/>
            </tbody>
        </table>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
       
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-enumeratie">
        <tr>
            <td width="20%">
                <xsl:value-of select="imvert:alias"/>
            </td>
            <td width="30%">
                <xsl:value-of select="imvert:name/@original"/>
            </td>
            <td width="50%">
                <xsl:sequence select="imf:get-formatted-compiled-documentation(.)"/>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <h4>
            <xsl:value-of select="concat('Attribuutsoort ', $quot, imvert:name/@original, $quot, ' van gegevensgroeptype ',$quot,  $construct/imvert:name/@original, $quot)"/>
        </h4>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Code',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Mogelijk geen waarde',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:label-waarde('Formaat',imf:translate(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:label-waarde('Patroon',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:label-waarde('Waardenverzameling',imf:get-tagged-value-waardenverzameling(.))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie materiële historie',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie formele historie',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie in onderzoek',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:label-waarde('Aanduiding strijdigheid/nietigheid ',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie authentiek',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>
                <xsl:sequence select="imf:label-waarde('Regels',imf:get-tagged-value(.,'Regels'))"/>
            </tbody>
        </table>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
    
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-referentieelement">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <h4>
            <xsl:value-of select="concat('Referentie element ', imvert:name/@original)"/>
        </h4>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Code',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Formaat',imf:translate(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:label-waarde('Patroon',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
            </tbody>
        </table>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-unionelement">
        <xsl:variable name="construct" select="../.."/>
        <h4>
            <xsl:value-of select="concat('Union element ', imvert:name/@original)"/>
        </h4>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
            </tbody>
        </table>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-dataelement">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <h4>
            <xsl:value-of select="concat('Data element ', imvert:name/@original)"/>
        </h4>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Formaat',imf:translate(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:label-waarde('Patroon',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie afleidbaar',$is-afleidbaar-text)"/>
            </tbody>
        </table>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        
    </xsl:template>
  
    <xsl:template match="imvert:association" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="if (exists(imvert:type-id)) then imf:get-construct-in-derivation-by-id(imvert:type-id) else ()"/>
        <xsl:variable name="is-identifying" select="imvert:target-stereotype = imf:get-config-stereotypes('stereotype-name-composite-id')"/>
        <h4>
            <xsl:value-of select="concat('Relatiesoort ', imvert:name/@original)"/>
        </h4>
        <table>
            <tbody>
                <xsl:sequence select="imf:label-waarde('Naam',imvert:name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Gerelateerd objecttype',imvert:type-name/@original)"/>
                <xsl:sequence select="imf:label-waarde('Indicatie kardinaliteit',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:label-waarde('Herkomst',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:label-waarde('Code',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:label-waarde('Definitie',imf:get-formatted-compiled-documentation(.),true())"/>
                <xsl:sequence select="imf:label-waarde('Herkomst definitie',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:label-waarde('Datum opname',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:label-waarde('Mogelijk geen waarde',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie materiële historie',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie formele historie',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie in onderzoek',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:label-waarde('Aanduiding strijdigheid/nietigheid ',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:label-waarde('Indicatie authentiek',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>                
                <xsl:sequence select="imf:label-waarde('Regels',imf:get-tagged-value(.,'Regels'))"/>
            </tbody>
        </table>
        <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
       
    </xsl:template>
    
    <!--
        de tagged value moet gelijk zijn aan de aangeven string. 
    -->
    <xsl:function name="imf:get-tagged-value" as="xs:string">
        <xsl:param name="this"/>
        <xsl:param name="tv-name"/>
        <xsl:variable name="normalized-tv-name" select="imf:get-normalized-name($tv-name,'tv-name')"/>
        <xsl:value-of select="imf:get-clean-documentation-string($this/*/imvert:tagged-value[imvert:name = $normalized-tv-name][1]/imvert:value)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-unieke-aanduiding">
        <xsl:param name="this"/>
        <xsl:variable name="id-attribute" select="$this/imvert:attributes/imvert:attribute[imf:boolean(imvert:is-id)]"/>
        <xsl:sequence select="if (exists($id-attribute)) then $id-attribute/imvert:name/@original else ''"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-waardenverzameling">
        <xsl:param name="this"/>
        <xsl:variable name="defining-class" select="if ($this/imvert:type-id) then imf:get-construct-in-derivation-by-id($this/imvert:type-id) else ()"/>
        <xsl:variable name="defining-stereotype" select="$defining-class/imvert:stereotype"/>
        <xsl:choose>
            <xsl:when test="$defining-stereotype = imf:get-normalized-name('referentielijst','stereotype-name')">
                <xsl:value-of select="$defining-class/imvert:name/@original"/>
            </xsl:when>
            <xsl:when test="$defining-stereotype = imf:get-normalized-name('enumeration','stereotype-name')">
                <xsl:value-of select="$defining-class/imvert:name/@original"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- empty -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:label-waarde" as="element()"> 
        <xsl:param name="label"/>
        <xsl:param name="waarde"/>
        <xsl:sequence select="imf:label-waarde($label,$waarde,false())"/>
    </xsl:function>
    <xsl:function name="imf:label-waarde" as="element()"> 
        <xsl:param name="label"/>
        <xsl:param name="waarde"/>
        <xsl:param name="as-sequence"/>
        <tr>
            <td width="30%">
                <b><xsl:value-of select="$label"/></b>
            </td>
            <td width="70%">
                <xsl:choose>
                    <xsl:when test="$as-sequence">
                        <xsl:sequence select="$waarde"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$waarde"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:function>
    
    <xsl:function name="imf:get-cardinality" as="xs:string"> 
        <xsl:param name="min"/>
        <xsl:param name="max"/>
        <xsl:choose>
            <xsl:when test="$min = $max or empty($max)">
                <xsl:value-of select="$min"/>
            </xsl:when>
            <xsl:when test="$max = 'unbounded'">
                <xsl:value-of select="concat($min, ' .. *')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($min, ' .. ', $max)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-clean-documentation-string">
        <xsl:param name="doc-string"/>
        <xsl:variable name="r1" select="substring-after($doc-string,'&lt;memo&gt;')"/>
        <xsl:variable name="r2" select="if (normalize-space($r1)) then $r1 else $doc-string"/>
        <xsl:variable name="r3" select="if (starts-with($r2,'[newline]')) then substring($r2,10) else $r2"/>
        <xsl:variable name="r4" select="replace($r3,'\[newline\]',' ')"/>
        <xsl:variable name="r5" select="replace($r4,'&lt;.*?&gt;','')"/>
        <xsl:variable name="r6" select="replace($r5,'Description:','')"/>
        <xsl:value-of select="$r6"/>
    </xsl:function>
    
    <xsl:function name="imf:authentiek-is-derived">
        <xsl:param name="this"/>
        <xsl:if test="imf:get-tagged-value($this,'derived') = '1'">
            <xsl:value-of select="' (is afgeleid)'"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-toelichting">
        <xsl:param name="documentatie"/>
        <xsl:if test="normalize-space($documentatie)">
            <table>
                <tbody>
                    <xsl:sequence select="imf:label-waarde('Toelichting','')"/>
                </tbody>
            </table>
            <table>
                <tbody>
                    <tr>
                        <td width="5%">&#160;</td>
                        <td width="95%">
                            <xsl:value-of select="$documentatie"/>
                        </td>
                    </tr>
                </tbody>        
            </table>        
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:translate" as="xs:string?">
        <xsl:param name="key"/>
        <xsl:param name="must-be-known"/>
        
        <xsl:variable name="keyn" select="upper-case($key)"/> 
        <xsl:choose>
            <xsl:when test="$keyn = 'BOOLEAN'">Boolean</xsl:when>
            <xsl:when test="$keyn = 'DATE'">Datum</xsl:when>
            <xsl:when test="$keyn = 'DATETIME'">DatumTijd</xsl:when>
            <xsl:when test="$keyn = 'KINGDATEPU'">DatumMogelijkOnbekend</xsl:when>
            <xsl:when test="$keyn = 'KINGDATEPI'">DatumMogelijkOnvolledig</xsl:when>
            <xsl:when test="$keyn = 'INTEGER'">Int</xsl:when>
            <xsl:when test="$keyn = 'FLOAT'">Real</xsl:when>
            <xsl:when test="$keyn = 'YEAR'">Jaar</xsl:when>
            <xsl:when test="$keyn = 'TXT'">Tekst</xsl:when>
            <xsl:when test="$keyn = 'POSTCODE'">Postcode</xsl:when>
            
            <xsl:when test="$keyn = 'OBJECTTYPE'">Objecttype</xsl:when>
            <xsl:when test="$keyn = 'RELATIEKLASSE'">Relatieklasse</xsl:when>
            <xsl:when test="$keyn = 'ENUMERATIE'">Enumeratie</xsl:when>
            <xsl:when test="$keyn = 'REFERENTIELIJST'">Referentielijst</xsl:when>
            <xsl:when test="$keyn = 'REFERENTIEGEGEVEN'">Referentiegegeven</xsl:when>
            <xsl:when test="$keyn = 'UNION'">Union</xsl:when>
            <xsl:when test="$keyn = 'UNION ELMENT'">Union element</xsl:when>
            <xsl:when test="$keyn = 'COMPLEX DATATYPE'">Complex datatype</xsl:when>
            <xsl:when test="$keyn = 'DATA ELMENT'">Data element</xsl:when>
            <xsl:when test="$keyn = 'GEGEVENSGROEPTYPE'">Gegevensgroeptype</xsl:when>
            
            <xsl:when test="$must-be-known">
                <xsl:sequence select="imf:msg('FATAL','Unknown type of construct requires translation: [1]',$key)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$key"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Verwijder het uppercase gedeelte uit de base type name. 
        Dus Splitsingstekeningreferentie APPARTEMENTSRECHTSPLITSING wordt Splitsingstekeningreferentie.
    -->
    <xsl:function name="imf:splice">
        <xsl:param name="typename"/>
        <xsl:analyze-string select="$typename" regex="^(.*?)\s+?([^a-z]+)$">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="$typename"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="imf:get-relatiesoort">
        <xsl:param name="relatieklasse"/>
        <xsl:variable name="id" select="$relatieklasse/imvert:id"/>
        <xsl:variable name="assoc-class" select="$document-classes//imvert:association-class[imvert:type-id = $id]"/>
        <xsl:variable name="fromclass" select="$assoc-class/ancestor::imvert:class"/>
        <xsl:variable name="assoc" select="$assoc-class/.."/>
        <xsl:value-of select="concat($fromclass/imvert:name/@original, ' ',$assoc/imvert:name/@original,' ',$assoc/imvert:type-name/@original)"/>
    </xsl:function>
 
 
    <!-- TOC processing -->
    <xsl:template match="*|@*" mode="toc">
        <!-- TODO -->
    </xsl:template>
    
    <!-- header processing -->
    <xsl:template match="*|@*" mode="headers">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[matches(local-name(.),'^h-?\d$')]" mode="headers">
        <xsl:variable name="level" select="xs:integer(substring(local-name(.),2))"/>
        <xsl:element name="{concat('h', $level + (1 - $pre-header-result-start))}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="imf:get-section">
        <xsl:param name="package"/>
        <xsl:param name="stereotype"/>
        <xsl:param name="label"/>
        <xsl:param name="detail"/>

        <xsl:variable name="enums" as="element()*">
            <xsl:apply-templates select="$package/imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]">
                <xsl:sort select="imvert:name"/>
            </xsl:apply-templates>
        </xsl:variable>

        <xsl:variable name="sections" as="element()*">
            <xsl:choose>
                <xsl:when test="not($detail) and imf:get-config-stereotypes($stereotype) = imf:get-config-stereotypes('stereotype-name-enumeration') and exists($enums)">
                    <table>
                        <tbody>
                            <tr>
                                <td><b>Enumeratie</b></td>
                                <td><b>Definitie</b></td>
                            </tr>
                            <xsl:sequence select="$enums"/>
                        </tbody>
                    </table>
                </xsl:when>
                <xsl:when test="$detail">
                    <xsl:apply-templates select="$package/imvert:class[imvert:stereotype = imf:get-config-stereotypes($stereotype)]" mode="detail">
                        <xsl:sort select="imvert:name"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$package/imvert:class[imvert:stereotype = imf:get-config-stereotypes($stereotype)]">
                        <xsl:sort select="imvert:name"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="exists($sections)">
            <h1><xsl:value-of select="$label"/></h1>
            <xsl:sequence select="$sections"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-formatted-compiled-documentation" as="item()*">
        <xsl:param name="struct"/>
        <xsl:sequence select="imf:get-compiled-documentation($struct,$model-is-traced)"/>
    </xsl:function>
    
</xsl:stylesheet>
