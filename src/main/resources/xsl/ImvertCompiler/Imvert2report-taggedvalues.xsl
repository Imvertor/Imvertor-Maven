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
    
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
      Report omn tagged values.
    -->
    
    <xsl:variable name="system-defined-tagged-value-names" select="$configuration-tvset-file//tagged-values/tv[@origin = 'system']/name" as="xs:string*"/>
    
    <xsl:template match="imvert:packages" mode="tv">
        <page>
            <title>Tagged values</title>
            <intro/>
            <content>
                <div>
                    <h1>Tagged values statistics</h1>
                    <div class="intro">
                        <p>
                            This table reports all tagged value found within the application. 
                        </p>
                        <p>
                            The list shows the name, the number of times it occurs, and the constructs that holds that tagged value. 
                        </p>
                    </div>               
                    <table class="tablesorter"> 
                        <xsl:variable name="rows" as="element(tr)*">
                            <xsl:for-each-group select=".//imvert:tagged-value" group-by="imvert:name">
                                <xsl:sort select="current-grouping-key()"/>
                                <tr>
                                    <td>
                                        <xsl:value-of select="current-grouping-key()"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="count(current-group())"/>
                                    </td>
                                    <td>
                                        <xsl:variable name="levels" as="xs:string*">
                                            <xsl:for-each-group select="current-group()" group-by="local-name(../..)">
                                                <xsl:sort select="current-grouping-key()"/>
                                                <xsl:value-of select="current-grouping-key()"/>
                                            </xsl:for-each-group>
                                        </xsl:variable>
                                        <xsl:value-of select="string-join($levels,',  ')"/>
                                    </td>
                                </tr>
                            </xsl:for-each-group>
                        </xsl:variable>
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,'tagged value name:60,occurs:10,occurs on:30','table-tv1')"/>
                    </table>
                </div>
                <div>
                    <h1>Tagged values specified</h1>
                    <div class="intro">
                        <p>
                            The list provides a complete overview of all <i>specified</i> tagged value names and values. 
                            If derived, the applicationrelease is specified ("origin"), otherwise "(here)" is shown.
                            Note that some tagged values of the supplier are not derived, and therefore not shown here.
                        </p>
                        <xsl:variable name="ns" select="string-join($system-defined-tagged-value-names,', ')"/>
                        <xsl:if test="normalize-space($ns)">
                            <p>The following system defined tagged values are not shown: <xsl:value-of select="$ns"/></p>
                        </xsl:if>
                    </div>           
                    <table class="tablesorter"> 
                        <xsl:variable name="rows" as="element(tr)*">
                            <xsl:for-each select="descendant-or-self::*[imvert:tagged-values/* and exists(@display-name)]">
                                <xsl:sort select="@display-name"/>
                                <xsl:variable name="display-name" select="@display-name"/>
                                <xsl:for-each select="imvert:tagged-values/imvert:tagged-value[node() and not(imvert:name = $system-defined-tagged-value-names)]">
                                    <tr>
                                        <td>
                                            <xsl:value-of select="$display-name"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="imvert:name/@original"/>
                                        </td>
                                        <td>
                                            <xsl:variable name="value" select="if (exists(imvert:value/@original)) then imvert:value/@original else imvert:value"/>
                                            <xsl:sequence select="imf:format-documentation-to-html($value)"/>
                                        </td>
                                        <td>
                                            <xsl:sequence select="if (xs:integer(@derivation-level) = 1) then '(here)' else string-join((@derivation-project,@derivation-application,@derivation-release),', ')"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,'construct:30,tagged value name:20,value:20,origin:30','table-tv2')"/>
                    </table>
                </div>
                <div>
                    <h1>Rules specified</h1>
                    <div class="intro">
                        <p>
                            The list provids an overview of all rules, specified or derived.
                        </p>
                    </div>           
                    <table class="tablesorter"> 
                        <xsl:variable name="abbrev" select="tokenize(imvert:base-namespace,'/')[last()]" as="xs:string?"/>
                        
                        <xsl:variable name="rows" as="element(tr)*">
                            <xsl:variable name="set" as="element(imvert:tagged-value)*">
                                <xsl:for-each select=".//imvert:class">
                                    <xsl:sequence select="imvert:tagged-values/imvert:tagged-value[@id = ('CFG-TV-RULES','CFG-TV-RULES-IMBROA','CFG-TV-EXPLAINNOVALUE')]"/> 
                                    <xsl:for-each select="imvert:attributes/imvert:attribute">
                                        <xsl:sequence select="imvert:tagged-values/imvert:tagged-value[@id = ('CFG-TV-RULES','CFG-TV-RULES-IMBROA','CFG-TV-EXPLAINNOVALUE')]"/> 
                                    </xsl:for-each>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:for-each select="$set">
                                <xsl:variable name="class" select="ancestor-or-self::imvert:class"/>
                                <xsl:variable name="attribute" select="ancestor-or-self::imvert:attribute"/>
                                <xsl:variable name="pars" select="imvert:value/xhtml:body/xhtml:p"/>
                                
                                <!-- columns -->
                                <xsl:variable name="col-RO" select="$abbrev"/>
                                <xsl:variable name="col-Regime" select="if (@id = 'CFG-TV-RULES') then 'IMBRO' else if (@id = 'CFG-TV-RULES-IMBROA') then 'IMBRO/A' else '-'"/>
                                <xsl:variable name="col-Regime-prefix" select="if (@id = 'CFG-TV-RULES') then 'IMBRO' else if (@id = 'CFG-TV-RULES-IMBROA') then 'IMBRO/A' else 'Nillable'"/>
                                <xsl:variable name="col-Entiteit" select="$class/imvert:name/@original"/>
                                <xsl:variable name="col-Attribuut" select="$attribute/imvert:name/@original"/>
                               
                                <xsl:for-each select="$pars">
                                    <xsl:variable name="subregel" select="node()"/>
                                    <tr>
                                        <td><!--A-->
                                            <xsl:sequence select="$col-RO"/>
                                        </td>
                                        <td><!--C-->
                                            <xsl:sequence select="$col-Regime"/>
                                        </td>
                                        <td><!--G-->
                                            <xsl:value-of select="$col-Entiteit"/>
                                        </td>
                                        <td><!--I-->
                                            <xsl:value-of select="$col-Attribuut"/>
                                        </td>
                                        <td><!--L-->
                                            <i><xsl:value-of select="$col-Regime-prefix"/></i>
                                            <br/>
                                            <xsl:sequence select="$subregel"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,'RO:5,Kwaliteitsregime:5,Entiteit:5,Attribuut:5,Regels:20','table-tv3')"/>
                    </table>
                </div>
            </content>
        </page>
    </xsl:template>
         
</xsl:stylesheet>
