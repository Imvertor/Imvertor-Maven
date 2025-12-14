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
       
        <xsl:variable name="diff-doc" select="imf:document(imf:get-xparm('properties/WORK_COMPAREV2_DIFF_CLEAN_FILE'))"/>
        
        <xsl:variable name="compare-method" select="imf:get-xparm('cli/compare')"/><!-- dat is 'supplier' of 'release' -->
        <xsl:variable name="supplier-subpath" select="imf:get-xparm('appinfo/supplier-subpath')"/>
        <xsl:variable name="old-subpath" select="$diff-doc/cmps/res/cmp[1][@property = 'subpath']/@value"/>
        <xsl:variable name="new-subpath" select="$diff-doc/cmps/res/cmp[2][@property = 'subpath']/@value"/>
        <xsl:variable name="compare-text">
            <xsl:choose>
                <xsl:when test="$old-subpath = $new-subpath">this model and the most recent succesfully built model release</xsl:when>
                <xsl:when test="$compare-method = 'supplier'">this model and its supplier model <b>{$supplier-subpath}</b></xsl:when>
                <xsl:when test="not($old-subpath or $new-subpath)">this model and the most recent succesfully built model release</xsl:when> 
                <xsl:otherwise>models <b>{$old-subpath}</b> and <b>{$new-subpath}</b></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="rows" as="element(tr)*">
            <xsl:for-each select="$diff-doc/cmps/res/cmp[1]" >
                <xsl:sort select="lower-case(@id)"/>
                <xsl:choose>
                    <xsl:when test="@property = 'subpath'">
                        <!-- skip -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="type" select="../@type"/>
                        <tr>
                            <xsl:choose>
                                <xsl:when test="$type = 'CHANGED'">
                                    <td>Changed</td>
                                    <td><xsl:sequence select="local:show-construct(.,'domain')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'class')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'attass')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'property')"/></td>
                                    <td>{@value}</td>
                                    <td>{../cmp[2]/@value}</td>
                                </xsl:when>
                                <xsl:when test="$type = 'ADDED'">
                                    <td>Added</td>
                                    <td><xsl:sequence select="local:show-construct(.,'domain')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'class')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'attass')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'property')"/></td>
                                    <td></td>
                                    <td>{@value}</td>
                                </xsl:when>
                                <xsl:when test="$type = 'REMOVED'">
                                    <td>Removed</td>
                                    <td><xsl:sequence select="local:show-construct(.,'domain')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'class')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'attass')"/></td>
                                    <td><xsl:sequence select="local:show-construct(.,'property')"/></td>
                                    <td></td>
                                    <td></td>
                                </xsl:when>
                            </xsl:choose>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="cdiff" select="count($rows)"/>
        
        <report>
            <step-display-name>Release comparison</step-display-name>
            <summary>
                <info label="Comparison">
                    <xsl:sequence select="imf:report-label('Compare method', $compare-method)"/>
                    <xsl:sequence select="imf:report-label('Number of differences', $cdiff)"/>
                </info>
            </summary>
            <page>
                <title>Comparison report</title>
                <info>({$cdiff} differences)</info>
                <intro>
                    <p>This report shows {$cdiff} differences found between <xsl:sequence select="$compare-text"/>.</p>
                </intro>
                <content>
                    <xsl:choose>
                        <xsl:when test="$cdiff = 0">
                            <p><i>No differences.</i></p>
                        </xsl:when>
                        <xsl:otherwise>
                            <table class="tablesorter"> 
                               <xsl:sequence select="imf:create-result-table-by-tr($rows,'Diff:10,Domain:10,Class:10,Att/Assoc:10,Property:10,' || (if ($compare-method = 'supplier') then 'Supplier:25,Client:25' else 'Old:25,New:25'),'compare-info')"/>
                            </table>           
                        </xsl:otherwise>
                    </xsl:choose>
                </content>
            </page>
            <page>
                <title>Release notes</title>
                <info>({$cdiff} differences)</info>
                <intro>
                    <p>This report shows {$cdiff} differences found between <xsl:sequence select="$compare-text"/>. This report is intended to provide sufficient information for manually creating <i>release notes</i> on the model.</p>
                </intro>
                <content>
                    <p><i>TODO</i></p>
                </content>
            </page>
        </report>
        
    </xsl:template>
    
    <xsl:function name="local:show-construct" as="item()*">
        <xsl:param name="this" as="element()?"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:variable name="name" select="$this/@*[local-name() = $type]"/>
        <xsl:variable name="stereo" select="$this/@*[local-name() = ($type || '-stereo')]"/>
        <xsl:sequence>
            <xsl:value-of select="$name"/>
            <xsl:if test="$stereo">
                <span class="tid"> ({lower-case($stereo)})</span>
            </xsl:if>    
        </xsl:sequence>
    </xsl:function>
        
</xsl:stylesheet>
