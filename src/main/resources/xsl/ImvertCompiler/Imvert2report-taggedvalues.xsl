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
      Report omn tagged values.
    -->
    
    <xsl:variable name="system-defined-tagged-value-names" select="$configuration-tvset-file//tagged-values/tv[@origin = 'system']/name" as="xs:string*"/>
    
    <xsl:template match="imvert:packages" mode="tv">
        <page>
            <title>Tagged values</title>
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
                    <table>
                        <xsl:sequence select="imf:create-table-header('tagged value name:60,occurs:10,occurs on:30')"/>
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
                    </table>
                </div>
                <div>
                    <h1>Tagged values specified</h1>
                    <div class="intro">
                        <p>
                            The list provids a complete overview of all <i>specified</i> tagged value names and values. 
                            If derived, the applicationrelease is specified ("origin"), otherwise "(here)" is shown.
                            Note that some tagged values of the supplier are not derived, an therefore not shown here.
                        </p>
                        <p>The following system defined tagged values are not shown: <xsl:value-of select="string-join($system-defined-tagged-value-names,', ')"/></p>
                    </div>               
                    <table>
                        <xsl:sequence select="imf:create-table-header('construct:30,tagged value name:20,value:20,origin:30')"/>
                        <xsl:for-each select=".//*[imvert:tagged-values/* and exists(@display-name)]">
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
                                        <xsl:sequence select="if (imf:boolean(@derivation-local)) then '(here)' else string-join((@derivation-project,@derivation-application,@derivation-release),', ')"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </xsl:for-each>
                    </table>
                </div>
            </content>
        </page>
    </xsl:template>
         
</xsl:stylesheet>
