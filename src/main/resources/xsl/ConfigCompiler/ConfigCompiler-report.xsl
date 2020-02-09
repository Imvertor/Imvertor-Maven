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
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         report on configuration
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:import href="ConfigCompiler-conceptualschemas.xsl"/>
    
    <xsl:variable name="configuration-owner-files" select="string-join($configuration-owner-file//name[parent::project-owner],', ')"/>
    <xsl:variable name="configuration-metamodel-files" select="string-join($configuration-metamodel-file//name[parent::metamodel],', ')"/>
    <xsl:variable name="configuration-tagset-files" select="string-join($configuration-tvset-file//name[parent::tagset],', ')"/>
    <xsl:variable name="configuration-xmlschemarules-files" select="string-join($configuration-xmlschemarules-file//name[parent::xmlschema-rules],', ')"/>
    
    <xsl:variable name="configuration-tree-file" select="imf:document(imf:get-xparm('properties/WORK_CONFIG_TREE_FILE'))"/>
    
    <xsl:template match="/config">
        <report>
            <step-display-name>Config compiler</step-display-name>
            <summary>
                <info label="Models">
                    <xsl:sequence select="imf:report-label('Owner', $configuration-owner-files)"/>
                    <xsl:sequence select="imf:report-label('Metamodel',$configuration-metamodel-files )"/>
                    <xsl:sequence select="imf:report-label('Tagged values',$configuration-tagset-files)"/>
                    <xsl:sequence select="imf:report-label('XML Schema rules',$configuration-xmlschemarules-files )"/>
                </info>
            </summary>
            <page>
                <title>Configuration</title>
                <intro>
                    <p>This is a representation of the configuration used in processing the model. 
                        Note that any specification included will be overridden by any specification of an including configuration.</p>
                </intro>
                <content>
                    <div>
                        <h1>Configuration dependencies</h1>
                        <xsl:apply-templates select="$configuration-tree-file/*" mode="tree"/>
                    </div>
                    <div>
                        <h1>Owner</h1>
                        <xsl:apply-templates select="." mode="owner"/>
                    </div>
                    <div>
                        <h1>Metamodel: features</h1>
                        <xsl:apply-templates select="." mode="metamodel-features"/>
                    </div>
                    <div>
                        <h1>Metamodel: scalars</h1>
                        <xsl:apply-templates select="." mode="metamodel-scalars"/>
                    </div>        
                    <div>
                        <h1>Metamodel: stereotypes</h1>
                        <xsl:apply-templates select="." mode="metamodel-stereos"/>
                        <xsl:apply-templates select="." mode="metamodel-stereos-desc"/>
                        <xsl:apply-templates select="." mode="metamodel-stereos-tv"/>
                    </div>  
                    <div>
                        <h1>Metamodel: tagged values</h1>
                        <xsl:apply-templates select="." mode="metamodel-tvs"/>
                        <xsl:apply-templates select="." mode="metamodel-tvs-desc"/>
                    </div>       
                    <div>
                        <h1>Conceptual schemas</h1>
                        <xsl:apply-templates select="." mode="metamodel-cs"/>
                    </div>       
                </content>
            </page>
        </report>
    </xsl:template>

    <xsl:template match="/config" mode="owner">
        <xsl:variable name="rows" as="element(tr)*">
            <xsl:for-each select="$configuration-owner-file/parameter">
                <xsl:sort select="@name"/>
                <tr>
                    <td>
                        <xsl:value-of select="@name"/>
                    </td>
                    <td>
                        <xsl:value-of select="."/>
                    </td>
                    <td>
                        <xsl:value-of select="@src"/>
                    </td>
                </tr>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="imf:create-result-table-by-tr($rows,'parameter:30,value:50,config:20','table-owner')"/>
    </xsl:template>

    <xsl:template match="/config" mode="metamodel-features">
        <xsl:variable name="rows" as="element(tr)*">
            <xsl:for-each select="$configuration-metamodel-file/features/feature">
                <xsl:sort select="@name"/>
                <tr>
                    <td>
                        <xsl:value-of select="@name"/>
                    </td>
                    <td>
                        <xsl:value-of select="."/>
                    </td>
                    <td>
                        <xsl:value-of select="@src"/>
                    </td>
                </tr>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="imf:create-result-table-by-tr($rows,'feature:30,value:50,config:20','table-feature')"/>
    </xsl:template>

    <xsl:template match="/config" mode="metamodel-scalars">
        <xsl:variable name="rows" as="element(tr)*">
            <xsl:for-each select="$configuration-metamodel-file//scalars/scalar">
                <xsl:sort select="name[1]"/>
                <tr>
                    <td>
                        <xsl:sequence select="imf:show-name(.,position() != last())"/>
                    </td>
                    <td>
                        <xsl:value-of select="desc"/>
                    </td>
                    <td>
                        <xsl:value-of select="if (type-map) then concat('Type map for ', imf:get-lang(type-map/@formal-lang), ': ', type-map, '. ') else ()"/>
                        <xsl:value-of select="if (max-length) then 'Max length may be set. ' else ()"/>
                        <xsl:value-of select="if (fraction-digits) then 'Fraction digits may be set. ' else ()"/>
                        <xsl:value-of select="if (type-modifier) then 'A type modifier applies. ' else ()"/>
                    </td>
                    <td>
                        <xsl:value-of select="name[1]/@src"/>
                    </td>
                </tr>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="imf:create-result-table-by-tr($rows,'scalar:20,desc:40,info:20,config:20','table-scalars')"/>
    </xsl:template>
    
    <!--
         <stereo id="stereotype-name-referentielijst">
            <name lang="nl" original="referentielijst">REFERENTIELIJST</name>
            <desc>
                Een lijst met een opsomming van de mogelijke domeinwaarden van een attribuutsoort die in de loop van de tijd kan veranderen.
                Voorbeeld: referentielijst LAND, referentielijst NATIONALITEIT
               (Een "rij" in de "tabel".)
            </desc>
            <construct>class</construct>
            <construct>datatype</construct>
         </stereo>
    -->
    <xsl:template match="/config" mode="metamodel-stereos">
        <div>
            <h2>Stereotype configuration</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="$configuration-metamodel-file//stereotypes/stereo">
                    <xsl:sort select="name[1]"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:show-name(.,position() != last())"/>
                        </td>
                        <td>
                            <xsl:value-of select="string-join(construct,', ')"/>
                        </td>
                        <td>
                            <xsl:value-of select="name[1]/@src"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'stereo:40,on constructs:40,config:20','table-stereos')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="/config" mode="metamodel-stereos-desc">
        <div>
            <h2>Stereotype descriptions</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="$configuration-metamodel-file//stereotypes/stereo">
                    <xsl:sort select="name[1]"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:show-name(.,position() != last())"/>
                        </td>
                        <td>
                            <xsl:value-of select="string-join(desc,', ')"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'stereo:20,description:80','table-stereo-desc')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="/config" mode="metamodel-stereos-tv">
        <div>
            <h2>Stereotype applicable tagged values</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="$configuration-metamodel-file//stereotypes/stereo">
                    <xsl:sort select="name[1]"/>
                    <xsl:variable name="stereo-id" select="@id"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:show-name(.,position() != last())"/>
                        </td>
                        <td>
                            <xsl:for-each select="$configuration-tvset-file//tv[stereotypes/stereo/@id = $stereo-id]">
                                <xsl:sort select="name"/>
                                <xsl:sequence select="imf:show-name(.,position() != last())"/>
                            </xsl:for-each>    
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'stereo:20,applicable tagged values:80','table-stereo-tv')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="config" mode="tree">
        <ul>
            <xsl:apply-templates select="includes" mode="tree"/>
        </ul>
    </xsl:template>
    
    <xsl:template match="includes" mode="tree">
        <li>
            <p>
                <i><xsl:value-of select="@type"/>: </i>
                <b><xsl:value-of select="@name"/></b>
                <xsl:if test="normalize-space(@desc)">
                    <xsl:text> -- </xsl:text>
                    <xsl:value-of select="@desc"/>
                </xsl:if>
            </p>
            <xsl:if test="*">
                <ul>
                    <xsl:apply-templates select="includes" mode="#current"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>
    
    
    <!--
     <tv id="CFG-TV-SOURCE" norm="space">
            <name lang="nl" original="Herkomst">herkomst</name>
            <derive>yes</derive>
            <stereotypes>
               <stereo required="yes" lang="nl" original="Objecttype">OBJECTTYPE</stereo>
               <stereo required="yes" lang="nl" original="Complex datatype">COMPLEX DATATYPE</stereo>
               <stereo required="yes" lang="nl" original="Data element">DATA ELEMENT</stereo>
               <stereo required="yes" lang="nl" original="Attribuutsoort">ATTRIBUUTSOORT</stereo>
               <stereo required="yes" lang="nl" original="Relatiesoort">RELATIESOORT</stereo>
               <stereo required="yes" lang="nl" original="Gegevensgroeptype">GEGEVENSGROEPTYPE</stereo>
               <stereo required="yes" lang="nl" original="Referentielijst">REFERENTIELIJST</stereo>
               <stereo required="yes" lang="nl" original="Referentie element">REFERENTIE ELEMENT</stereo>
               <stereo required="yes" lang="nl" original="Union">UNION</stereo>
               <stereo required="yes" lang="nl" original="Union element">UNION ELEMENT</stereo>
               <stereo required="no" lang="nl" original="Codelijst">CODELIJST</stereo>
               <stereo required="no" lang="nl" original="Relatierol">RELATIEROL</stereo>
            </stereotypes>
            <declared-values/>
     </tv> 
    -->
    <xsl:template match="/config" mode="metamodel-tvs">
        <div>
            <h2>Tagged value configuration</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="$configuration-tvset-file//tagged-values/tv">
                    <xsl:sort select="name[1]"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:show-name(.,position() != last())"/>
                            <xsl:value-of select="if (normalize-space(@cross-meta)) then concat(' -- Cross meta: ', @cross-meta) else ''"/>
                        </td>
                        <td>
                           <xsl:value-of select="derive"/>
                        </td>
                        <td>
                            <xsl:variable name="subrows" as="element(tr)*">
                                <xsl:for-each select="stereotypes/stereo">
                                    <tr>
                                        <td><xsl:value-of select="."/></td>
                                        <td><xsl:value-of select="@original"/></td>
                                        <td><xsl:value-of select="@minmax"/></td>
                                    </tr>
                                </xsl:for-each>            
                            </xsl:variable>
                            <xsl:sequence select="imf:create-result-table-by-tr($subrows,'name:40,original name:40,minmax:20',concat('table-tvs-',generate-id(.)))"/>
                        </td>
                        <td>
                            <xsl:value-of select="name[1]/@src"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'tagged value:20,derive?:10,stereos:55,config:10','table-tvs')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="/config" mode="metamodel-tvs-desc">
        <div>
            <h2>Tagged value descriptions</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="$configuration-tvset-file//tagged-values/tv">
                    <xsl:sort select="name[1]"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:show-name(.,position() != last())"/>
                        </td>
                        <td>
                            <xsl:value-of select="desc"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'tagged value:20,description:80','table-tvs-desc')"/>
        </div>
    </xsl:template>
    
    <xsl:function name="imf:show-name">
        <xsl:param name="element"/>
        <xsl:param name="add-newline"/>
        
        <xsl:value-of select="string-join($element/name,', ')"/>
        <span class="tid">
            <xsl:value-of select="' ('"/>
            <xsl:value-of select="$element/@id"/>
            <xsl:value-of select="')'"/>
        </span>
        <xsl:if test="$add-newline">
            <br/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-lang">
        <xsl:param name="prefix"/>
        <xsl:choose>
            <xsl:when test="$prefix = 'xs'">XML Schema (xs)</xsl:when>
            <xsl:otherwise>Unknown formal language (<xsl:value-of select="$prefix"/>)</xsl:otherwise>
        </xsl:choose>
            
    </xsl:function>
</xsl:stylesheet>
