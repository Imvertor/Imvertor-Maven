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
      Report on the current parameter settings.
    -->
    
    <xsl:variable name="xparms-doc" select="imf:document(imf:get-config-string('properties','WORK_XPARMS_CHAIN_FILE'),true())"/>
    
    <xsl:template match="config" mode="doc-parameters">
        <page>
            <title>Properties passed</title>
            <intro>
                <p>
                    Info on the parameters passed for this run, and their values.
                </p>
                <p>
                    Arguments are passed in files, in this order:
                    <ol>
                        <xsl:for-each select="reverse($xparms-doc/xparms/xparm[@name = 'cli/arguments'])">
                            <li>
                                <xsl:if test="position() != 1">
                                    includes: 
                                </xsl:if>
                                <xsl:value-of select="imf:recognize-file(@value)"/>
                            </li>
                        </xsl:for-each>
                    </ol>
                </p>
            </intro> 
            <content>
                <!--
                <xmp>
                    <xsl:sequence select="$configuration/config"></xsl:sequence>
                </xmp>
                -->
                <table class="tablesorter"> 
                    <xsl:variable name="rows" as="element(tr)*">
                        <xsl:for-each select="$configuration/config/clispecs/clispec[not(longKey = 'arguments')]">
                            <xsl:sort select="longKey"/>

                            <xsl:variable name="cli-info" select="."/>
                            <xsl:variable name="name" select="longKey"/>
                            <xsl:variable name="value" select="$configuration/config/cli/*[name() = $name]"/>
                            
                            <tr class="{if (empty($value)) then 'cmp-system' else ''}">
                                <td>
                                    <xsl:value-of select="$name"/> 
                                </td>
                                <td>
                                    <xsl:value-of select="$cli-info/argKey"/>
                                </td>
                                <td>
                                    <b><xsl:value-of select="imf:recognize-file($value)"/></b>
                                </td>
                                <td>
                                    <xsl:value-of select="$cli-info/description"/>
                                </td>
                                <td>
                                    <xsl:value-of select="$cli-info/isRequired"/>
                                </td>
                                <td>
                                    <xsl:value-of select="$cli-info/stepName"/> 
                                </td>
                                <td>
                                    <xsl:for-each select="reverse($xparms-doc/xparms/xparm[@name = concat('cli/',$name)])">
                                        <xsl:value-of select="imf:recognize-file(@origin)"/>:
                                        <xsl:choose>
                                            <xsl:when test="position() = 1">
                                                <b>
                                                    <xsl:value-of select="imf:recognize-file(@value)"/> 
                                                </b>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="imf:recognize-file(@value)"/> 
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <br/>
                                    </xsl:for-each>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-result-table-by-tr($rows,'Name:10,Args:10,Value:10,Explain:20,Required?:10,Step:10,Defined in:30','table-cli')"/>
                </table>
            </content>
        </page>
    </xsl:template>
    
    <xsl:function name="imf:recognize-file">
        <xsl:param name="value"/>
        <xsl:value-of select="if (substring($value,2,1) = ':' or substring($value,1,1) = '/') then concat('(File) ', tokenize($value, '[\\/]')[last()]) else $value"/>
    </xsl:function>
         
</xsl:stylesheet>
