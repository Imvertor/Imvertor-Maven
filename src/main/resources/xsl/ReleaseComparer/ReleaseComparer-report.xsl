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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    xmlns:local="urn:local"
    
    exclude-result-prefixes="#all"
    expand-text="yes">
    
    <!-- 
         Reporting stylesheet for the Release comparer
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:template match="/config">
       
        <xsl:variable name="diff-doc" select="imf:document(imf:get-xparm('properties/WORK_COMPARE_DIFF_FILE'))"/>
        <xsl:sequence select="dlogger:save('$diff-doc',$diff-doc)"/>
        
        <xsl:variable name="cdiff" select="count($diff-doc/cmps/res)"/>
        <report>
            <step-display-name>Release comparison</step-display-name>
            <summary>
                <info label="Comparison">
                    <xsl:sequence select="imf:report-label('Number of differences', $cdiff)"/>
                </info>
            </summary>
            <page>
                <title>Comparison report</title>
                <info>({$cdiff} differences)</info>
                <intro>
                    <p>This report shows all differences found between {x} and {x}.</p>
                </intro>
                <content>
                    <table class="tablesorter"> 
                        <xsl:variable name="rows" as="element(tr)*">
                            <xsl:for-each select="$diff-doc/cmps/res/cmp[1]" >
                                <xsl:sort select="@id"/>
                                <xsl:variable name="type" select="../@type"/>
                                <tr>
                                    <xsl:choose>
                                        <xsl:when test="$type = 'CHANGED'">
                                            <td>Changed</td>
                                            <td>{@domain}</td>
                                            <td>{@class}</td>
                                            <td>{@attass}</td>
                                            <td>{local:show-property(@property)}</td>
                                            <td>{@value}</td>
                                            <td>{../cmp[2]/@value}</td>
                                        </xsl:when>
                                        <xsl:when test="$type = 'ADDED'">
                                            <td>Added</td>
                                            <td>{@domain}</td>
                                            <td>{@class}</td>
                                            <td>{@attass}</td>
                                            <td>{local:show-property(@property)}</td>
                                            <td></td>
                                            <td>{@value}</td>
                                        </xsl:when>
                                        <xsl:when test="$type = 'REMOVED'">
                                            <td>Removed</td>
                                            <td>{@domain}</td>
                                            <td>{@class}</td>
                                            <td>{@attass}</td>
                                            <td>{local:show-property(@property)}</td>
                                            <td></td>
                                            <td></td>
                                        </xsl:when>
                                    </xsl:choose>
                                </tr>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,'Diff:10,Domain:10,Class:10,Att/Assoc:10,Property:10,Old:25,New:25','compare-info')"/>
                    </table>
                </content>
            </page>
            <page>
                <title>Release notes</title>
                <info>({$cdiff} differences)</info>
                <intro>
                    <p>This report shows all differences found between {x} and {x}. This report is intended to provide ionformation for manually creating <i>release notes</i> on the model.</p>
                </intro>
                <content>
                    TODO
                </content>
            </page>
        </report>
        
    </xsl:template>
    
    <xsl:function name="local:show-property">
        <xsl:param name="prop" as="xs:string"/>
        <xsl:variable name="toks" select="tokenize($prop,':')"/>
        <xsl:choose>
            <xsl:when test="$toks[1] = 'system'">{$toks[2]}</xsl:when>
            <xsl:when test="$toks[1] = 'tag'">Tagged value: {$toks[2]}</xsl:when>
            <!-- er zijn geen andere, wel kan de waarde leeg zijn -->
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
