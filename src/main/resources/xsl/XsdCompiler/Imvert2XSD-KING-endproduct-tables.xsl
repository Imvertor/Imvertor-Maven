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
    xmlns:ep="http://www.imvertor.org/schema/endproduct" 
    exclude-result-prefixes="#all" version="2.0">

    <!-- 
       Produce a table for each messagetype.
    -->

    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>

    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>

    <xsl:variable name="quot"><!--'--></xsl:variable>

    <xsl:template match="/ep:message-set">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <style type="text/css">
                    body{
                        font-family: "Calibri", "Verdana", sans-serif;
                        font-size: 11.0pt;
                    }
                    table{
                        width: 100%;
                    }
                    table,
                    th,
                    td{
                        border: 1px solid black;
                        border-collapse: collapse;
                        font-size: 11.0pt;
                    }
                    td{
                        vertical-align: top;
                        padding: 3px;
                    }
                    h1,
                    h2,
                    h3,
                    h4,
                    h5{
                        color: #003359;
                    }
                    h1{
                        page-break-before: always;
                        font-size: 16.0pt;
                    }
                    h2{
                        font-size: 12.0pt;
                    }
                    h3{
                        font-size: 12.0pt;
                    }
                    h4{
                        font-size: 12.0pt;
                    }
                    h5{
                        font-size: 12.0pt;
                    }
                    tr.tableheader{
                        font-style: italic;
                    }</style>
            </head>
            <body>
                <ul>
                    <li>Date: <xsl:value-of select="ep:date"/></li>
                    <li>Name: <xsl:value-of select="ep:name"/></li>
                    <li>Namespace: <xsl:value-of select="ep:namespace"/></li>
                    <li>Prefix: <xsl:value-of select="ep:namespace-profix"/></li>
                    <li>Patch: <xsl:value-of select="ep:patch-number"/></li>
                    <li>Release: <xsl:value-of select="ep:release"/></li>
                </ul>
                <xsl:apply-templates select="ep:message"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="ep:message">
        <xsl:variable name="bericht-entiteit" select="ep:seq[1]/ep:construct[1]/ep:seq[1]/ep:construct[1]"/>
        <table>
            <col style="width:45%"/>
            <col style="width:45%"/>
            <col style="width:10%"/>
            <tr>
                <td colspan="2">
                    <b>Berichttype: </b>
                    <xsl:value-of select="concat(ep:name, ' (', ep:type, ')')"/>
                </td>
                <td> </td>
            </tr>
            <tr>
                <td>
                    <b>StUF elementen</b>
                </td>
                <td>
                    <b>IM attribuut</b>
                </td>
                <td>
                    <b>v/o</b>
                </td>
            </tr>
            <xsl:apply-templates select="$bericht-entiteit" mode="level1"/>
        </table>
    </xsl:template>

    <!-- level 1 is bericht entiteit level, alles daaronder is onderdeel van de content -->

    <xsl:template match="ep:construct" mode="level1">
        <tr>
            <td>
                <b>
                    <xsl:value-of select="imf:tables-get-path-name(., ())"/>
                </b>
            </td>
            <td/>
            <td>
                <xsl:sequence select="imf:tables-get-mult(.)"/>
            </td>
        </tr>
        <xsl:apply-templates select="ep:*/ep:construct[imf:table-must-show(.)]" mode="level2">
            <xsl:with-param name="bericht-entiteit" select="."/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="ep:construct" mode="level2">
        <xsl:param name="bericht-entiteit"/>
        <xsl:if test="not(ep:tech-name = 'gerelateerde')">
            <tr>
                <td>
                    <xsl:variable name="name" select="imf:tables-get-path-name(., $bericht-entiteit)"/>
                    <xsl:choose>
                        <xsl:when test="imf:table-is-association(.)">
                            <b>
                                <xsl:value-of select="$name"/>
                            </b>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <td>
                    <xsl:sequence select="imf:tables-get-natural-name(.)"/>
                    <xsl:sequence select="imf:table-get-documentation(.)"/>
                </td>
                <td>
                    <xsl:sequence select="imf:tables-get-mult(.)"/>
                </td>
            </tr>
        </xsl:if>
        <xsl:apply-templates select="ep:*/ep:construct[imf:table-must-show(.)]" mode="level2">
            <xsl:with-param name="bericht-entiteit" select="$bericht-entiteit"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:function name="imf:tables-get-mult">
        <xsl:param name="construct"/>
        <xsl:variable name="is-assoc" select="imf:table-is-association($construct)"/>
        <xsl:variable name="min" select="($construct/ep:min-occurs, 0)"/>
        <xsl:variable name="max" select="($construct/ep:max-occurs, 1)"/>
        <xsl:variable name="minmax" select="concat('[', $min[1], '..', $max[1], ']')"/>
        <xsl:value-of select="
                if ($is-assoc)
                then
                    $minmax
                else
                    if ($min[1] = 0)
                    then
                        if ($max[1] = 1)
                        then
                            'o'
                        else
                            $minmax
                    else
                        if ($max[1] = 1)
                        then
                            'v'
                        else
                            $minmax
                "/>
    </xsl:function>

    <xsl:function name="imf:tables-get-path-name" as="xs:string">
        <xsl:param name="construct"/>
        <xsl:param name="start-from-construct"/>
        <xsl:value-of select="string-join(imf:tables-get-path-names($construct, $start-from-construct), '/')"/>
    </xsl:function>

    <xsl:function name="imf:tables-get-path-names" as="xs:string+">
        <xsl:param name="construct"/>
        <xsl:param name="start-from-construct"/>
        <xsl:variable name="parent-construct" select="$construct/ancestor::ep:construct[1]"/>
        <xsl:variable name="tech-name" select="$construct/ep:tech-name"/>
        <xsl:sequence select="
                if ($parent-construct and not($parent-construct = $start-from-construct)) then
                    imf:tables-get-path-names($parent-construct, $start-from-construct)
                else
                    ()"/>
        <xsl:sequence select="
                if ($tech-name != 'gerelateerde') then
                    string($tech-name)
                else
                    ()"/>
    </xsl:function>

    <xsl:function name="imf:tables-get-natural-name">
        <xsl:param name="construct"/>

        <xsl:variable name="attribute-id" select="$construct/ep:id"/>
        <xsl:variable name="attribute-type" select="$construct/ep:type-name"/>
        <xsl:variable name="attribute-name" select="$construct/ep:name"/>
        <xsl:variable name="attribute-tech-name" select="$construct/ep:tech-name"/>

        <xsl:value-of select="concat(imf:table-get-type($construct), '')"/>
    </xsl:function>

    <xsl:function name="imf:table-must-show">
        <xsl:param name="construct"/>
        <xsl:sequence select="not(imf:boolean($construct/@ismetadata)) and not(starts-with($construct/ep:name, 'StUF:'))"/>
    </xsl:function>
    <xsl:function name="imf:table-is-association">
        <xsl:param name="construct"/>
        <xsl:sequence select="$construct/ep:*/*[imf:table-must-show(.)]"/>
    </xsl:function>

    <xsl:variable name="imf:table-get-type-names" select="tokenize('scalar-string Karakters scalar-integer Getal scalar-boolean Ja-Nee scalar-date Datum scalar-time Tijd scalar-datetime Datum-Tijd scalar-postcode Postcode', '\s+')" as="xs:string+"/>

    <xsl:function name="imf:table-get-type">
        <xsl:param name="construct"/>
        <xsl:variable name="type-name" select="$construct/ep:type-name"/>
        <xsl:variable name="index" select="
                index-of($imf:table-get-type-names, if ($type-name) then
                    $type-name
                else
                    'UNKNOWN')"/>
        <?x xsl:variable name="type-construct-name" select="imf:table-get-associated-type-name($construct/ep:id)"/ x?>
        <xsl:variable name="type-construct-name" select="imf:table-get-associated-type-name($construct)"/>
        <xsl:sequence select="
                if ($index[1]) then
                    subsequence($imf:table-get-type-names, $index[1] + 1, 1)
                else
                    if ($type-construct-name) then
                        $type-construct-name
                    else
                        concat('[', $type-name, ']')"/>
    </xsl:function>

    <xsl:function name="imf:table-get-associated-type-name">
        <?x xsl:param name="property-id"/ x?>
        <!-- een asociation of een attribute -->
        <?x xsl:variable name="property" select="
                if ($property-id) then
                    imf:get-construct-by-id($property-id, $derivation-tree)
                else
                    ()"/>
        <xsl:variable name="property-type" select="
                if ($property) then
                    imf:get-construct-by-id($property/imvert:type-id, $derivation-tree)
                else
                    ()"/ x?>
        <?x xsl:variable name="property-type-layers" select="imf:get-construct-in-all-layers($property-type)"/>
        <xsl:value-of select="$property-type-layers[last()]/*/imvert:name/@original"/ x?>
 
        <xsl:param name="construct"/>
        <!-- een asociation of een attribute -->
        <xsl:variable name="suppliers" select="imf:get-trace-suppliers-for-construct($construct,1)"/>
        <xsl:variable name="supplied-property-types">
            <xsl:for-each select="$suppliers">
                <xsl:variable name="supplier" select="."/>
                
                <xsl:variable name="property" as="element(imvert:property)?">
                    <xsl:variable name="supplied-property" select="imf:get-trace-construct-by-supplier($supplier,$imvert-document)"/>
                    <!-- copy the supplier info attributes to the property element -->
                    <xsl:if test="exists($supplied-property/node())">
                        <imvert:property>
                            <xsl:copy-of select="$supplier/@*"/>
                            <xsl:sequence select="$supplied-property/node()"/>
                        </imvert:property>
                    </xsl:if>						
                </xsl:variable>
                
                <xsl:sequence select="$property"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$supplied-property-types[last()]/*/imvert:name/@original"/>
    </xsl:function>

    <xsl:function name="imf:table-get-documentation">
        <xsl:param name="construct"/>
        <xsl:variable name="doc" select="normalize-space(substring-before($construct/ep:documentation,'--'))"/>
        <xsl:sequence select="if ($doc) then concat(' (', $doc, ')') else ()"/>
    </xsl:function>
</xsl:stylesheet>
