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
    
    <xsl:import href="Imvert2compare-common.xsl"/>
    
    <xsl:variable name="ctrl-name-map" select="document($ctrl-name-mapping-filepath)/maps/map" as="element()*"/>
    <xsl:variable name="test-name-map" select="document($test-name-mapping-filepath)/maps/map" as="element()*"/>
    
    <xsl:template name="fetch-comparison-report">
        <xsl:param name="title"/>
        <xsl:param name="info"/>
        <xsl:param name="intro"/>
        <page>
            <title><xsl:value-of select="$title"/></title>
            <info>
                <xsl:sequence select="$info"/>
            </info>
            <content>
                <div class="intro">
                    <xsl:sequence select="$intro"/>
                </div>   
                <xsl:choose>
                    <xsl:when test="exists(/imvert:report/imvert:diffs)">
                        <table class="compare">
                            <tr class="tableHeader"        >
                                <td>Package</td>
                                <td>Class</td>
                                <td>Attrib/Assoc</td>
                                <td>Property</td>
                                <td>Explain</td>
                                <td>LVL</td>
                                <td>Change</td>
                                <td>Control</td>
                                <td>Test</td>
                            </tr>
                            <xsl:apply-templates select="/imvert:report" mode="diffs">
                                <xsl:with-param name="level" select="'user'"/>
                            </xsl:apply-templates>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>No differences found!</p>
                    </xsl:otherwise>
                </xsl:choose>
            </content>    
        </page>
    </xsl:template>
    
    <xsl:template match="imvert:report" mode="diffs">
        <xsl:param name="level"/>
        
        <xsl:for-each select="imvert:diffs/imvert:diff[imvert:level = $level]">
            <xsl:sort select="imvert:compos"/>
            <xsl:variable name="compos" select="imvert:compos"/>
            <xsl:variable name="orig-ctrl" select="$ctrl-name-map[@elm=$compos]/@orig"/>
            <xsl:variable name="orig-test" select="$test-name-map[@elm=$compos]/@orig"/>
            <xsl:variable name="orig" select="if (exists($orig-ctrl)) then $orig-ctrl[1] else $orig-test[1]"/>
            <xsl:variable name="tokens" select="tokenize($orig,'\.')"/>
            <xsl:variable name="info" select="key('imvert-compare-config',imvert:type,$imvert-compare-config-doc)[1]"/>
            
            <xsl:sequence select="imf:debug(concat('Reporting on ', $orig))"/>
            <tr>
                <xsl:if test="$info/../@level='system'">
                    <xsl:attribute name="class">cmp-system</xsl:attribute>
                </xsl:if>
                <!-- package -->
                <td>
                    <xsl:value-of select="if ($tokens[1] = 'AAROOT') then '(Model)' else $tokens[1]"/>
                </td>
                <!-- class -->
                <td>
                    <xsl:value-of select="$tokens[2]"/>
                </td>
                <!-- Attrib/assoc -->
                <td>
                    <xsl:value-of select="$tokens[3]"/>
                </td>
                <!-- property -->
                <td>
                    <xsl:variable name="type" select="imvert:type"/>
                    <xsl:variable name="orig-tv-ctrl" select="$ctrl-name-map[@elm=$type]/@orig"/>
                    <xsl:variable name="orig-tv-test" select="$test-name-map[@elm=$type]/@orig"/>
                    <xsl:variable name="orig-tv" select="if (exists($orig-tv-ctrl)) then $orig-tv-ctrl else $orig-tv-test"/>
                    <xsl:value-of select="if (starts-with($type,'tv_')) then $orig-tv else $type"/>
                </td>
                <!-- explain -->
                <td>
                    <xsl:value-of select="$info"/>
                </td>
                <!-- lvl  -->
                <td>
                    <xsl:value-of select="($info/../@level,'model')[1]"/>
                </td>
                <!-- change-->
                <td>
                    <xsl:value-of select="imvert:change"/>
                </td>
                <!-- ctrl construct -->
                <td>
                    <xsl:if test="imvert:change = 'value'">
                        <xsl:attribute name="class">code</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="imvert:ctrl"/>
                </td>
                <!-- test construct -->
                <td>
                    <xsl:if test="imvert:change = 'value'">
                        <xsl:attribute name="class">code</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="imvert:test"/>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
