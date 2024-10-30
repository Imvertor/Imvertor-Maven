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
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all"
    expand-text="yes"
    version="3.0">
    
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
    <xsl:variable name="configuration-translations" select="$configuration-file/config/translations"/>
    
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
                        <h1>Metamodel version info</h1>
                        <xsl:apply-templates select="." mode="versions"/>
                    </div>
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
                        <xsl:apply-templates select="." mode="metamodel-pseudotvs-desc"/>
                    </div>       
                    <div>
                        <h1>Conceptual schemas</h1>
                        <xsl:apply-templates select="." mode="metamodel-cs"/>
                    </div> 
                    <div>
                        <h1>Documentation rules</h1>
                        <xsl:apply-templates select="." mode="docrules"/>
                    </div> 
                    <div>
                        <h1>Visuals</h1>
                        <xsl:apply-templates select="." mode="metamodel-visuals"/>
                    </div>
                    <div>
                        <h1>Translations</h1>
                        <xsl:apply-templates select="$configuration-translations" mode="translations"/>
                    </div>
                </content>
            </page>
        </report>
    </xsl:template>

    <xsl:template match="/config" mode="versions">
        <xsl:variable name="rows" as="element(tr)*">
            <tr>
                <td>Metamodel</td>
                <td>{imf:get-xparm('appinfo/metamodel-name')} {imf:get-xparm('appinfo/metamodel-minor-version')}</td>
            </tr>
            <tr>
                <td>Specified metamodel version</td>
                <td>{imf:get-xparm('appinfo/metamodel-specified-version')}</td>
            </tr>
            <tr>
                <td>Configured metamodel version</td>
                <td>{imf:get-xparm('appinfo/metamodel-configured-version')}</td>
            </tr>
            <tr>
                <td>Validate by metamodel version</td>
                <td>{imf:get-xparm('appinfo/metamodel-major-version')}</td>
            </tr>
            <tr>
                <td>Extension</td>
                <td>{imf:get-xparm('appinfo/metamodel-extension')} {imf:get-xparm('appinfo/metamodel-extension-version')}</td>
            </tr>
            <tr>
                <td>Full name</td>
                <td>{imf:get-xparm('appinfo/metamodel-name-and-version')}</td>
            </tr>
        </xsl:variable>
        <xsl:sequence select="imf:create-result-table-by-tr($rows,'parameter:30,value:70','table-versions')"/>
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
                        <xsl:sequence select="imf:get-src(.)"/>
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
                        <xsl:sequence select="imf:get-src(.)"/>
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
                        <xsl:sequence select="imf:get-src(name[1])"/>
                    </td>
                </tr>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="imf:create-result-table-by-tr($rows,'scalar:15,desc:30,info:20,config:35','table-scalars')"/>
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
                            <xsl:sequence select="imf:get-src(name[1])"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'stereo:40,on constructs:20,config:40','table-stereos')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="/config" mode="metamodel-visuals">
        <div>
            <h2>Visuals configuration</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:variable name="categories" select="$configuration-visuals-file/category" as="element()*"/>
                <xsl:for-each select="$configuration-visuals-file/stereo">
                    <xsl:sort select="imf:get-config-name-by-id(@id)"/>
                    <xsl:variable name="category-id" select="toolbox/@category"/>
                    <xsl:variable name="category" select="$categories[@id = $category-id]/desc"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:get-config-name-by-id(@id)"/>
                        </td>
                        <td>
                            <xsl:value-of select="string-join($category,', ')"/>
                        </td>
                        <td>
                            <xsl:sequence select="imf:get-src(toolbox)"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'stereo:20,visual category:40,config:40','table-visuals')"/>
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
                                <xsl:sequence select="imf:show-name(.,false())"/>
                                (<xsl:value-of select="stereotypes/stereo[@id = $stereo-id]/@minmax"/>)
                                <br/>
                            </xsl:for-each>    
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'stereo:20,applicable tagged values:80','table-stereo-tv')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="/config" mode="docrules">
        <div>
            <h2>Documentation rules</h2>
            
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="$configuration-docrules-file//doc-rule">
                    <xsl:sort select="xs:integer(@order)"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:show-name(.,position() != last())"/>
                        </td>
                        <td>
                            <xsl:value-of select="@order"/>
                        </td>
                        <td>
                            <xsl:sequence select="imf:get-src(name[1])"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'label:40,order:20,config:40','table-docrules')"/>
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
                            <xsl:sequence select="imf:get-src(name[1])"/>
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
                        <td>
                            <xsl:for-each select="catalog">
                                <a href="{.}">link</a>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'tagged value:20,description:70,catalog:10','table-tvs-desc')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="/config" mode="metamodel-pseudotvs-desc">
        <div>
            <h2>Pseudo tagged value descriptions</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="$configuration-tvset-file//tagged-values/pseudo-tv">
                    <xsl:sort select="name[1]"/>
                    <tr>
                        <td>
                            <xsl:sequence select="imf:show-name(.,position() != last())"/>
                        </td>
                        <td>
                            <xsl:value-of select="desc"/>
                        </td>
                        <td>
                            <xsl:for-each select="catalog">
                                <a href="{.}">link</a>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'pseudo tagged value:20,description:70,catalog:10','table-peudotvs-desc')"/>
        </div>
    </xsl:template>
    
    <xsl:template match="/config/translations" mode="translations">

        <div>
            <h2>Translations of included constructs</h2>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="trans">
                    <xsl:sort select="root"/>
                    <xsl:sort select="part"/>
                    <xsl:sort select="name[@orig-lang = 'nl'][1]"/><!-- NB het kan voorkomen dat een construct meerdere namen heeft, denk aan DATETIME en DT --> 
                    <tr>
                        <td>
                            <xsl:value-of select="root"/>
                        </td>
                        <td>
                            <xsl:value-of select="part"/>
                        </td>
                        <td>
                            <xsl:value-of select="name[@orig-lang = 'nl']"/>
                        </td>
                        <td>
                            <xsl:value-of select="name[@orig-lang = 'en']"/>
                        </td>
                        <td>
                            <xsl:value-of select="paths/path[last()]"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'root:15,part:15,NL:20,EN:20,config:30','table-translations-desc')"/>
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
    
    <xsl:function name="imf:get-src" as="item()*">
        <xsl:param name="this"/>
        <xsl:variable name="src" select="tokenize($this/@src,'&lt;')"/>
        <b>
            <xsl:value-of select="$src[1]"/>
        </b>
        <xsl:if test="exists(subsequence($src,2))">
            <xsl:value-of select="' &#8592; '"/>
            <xsl:value-of select="string-join(subsequence($src,2),' &#8592; ')"/>
            <xsl:if test="normalize-space($this/@srcbase)">
                <br/>
                <br/>
                <pre>
                    <xsl:value-of select="concat('/', tokenize($this/@srcbase,'\.\./')[last()])"/>
                </pre>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
