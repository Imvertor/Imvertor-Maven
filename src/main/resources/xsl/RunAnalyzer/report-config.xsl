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
      Report on the current configuration.
    -->
    
    <xsl:template match="config" mode="doc-config">
        <page>
            <title>Configuration info</title>
            <content>
                <div>
                    <h1>Metamodels</h1>
                    <div class="intro">
                        <p>
                            Info on the current metamodels.
                            Applicable metamodel are:
                        </p>
                        <ul>
                            <xsl:for-each select="$configuration-metamodel-file/descendant-or-self::metamodel">
                                <li>
                                    <xsl:value-of select="concat(name,': ',description)"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                        <p>Metamodel extension list is:
                            <xsl:value-of select="string-join($configuration-metamodel-file/descendant-or-self::metamodel/name,', extends ')"/>
                        </p>
                    </div>               
                    <table>
                        <xsl:sequence select="imf:create-table-header('Stereotype(s):45,Allowed on:45,In metamodel:10')"/>
                        <xsl:for-each select="$configuration-metamodel-file/descendant-or-self::stereotypes/stereo">
                            <xsl:sort select="name[1]"/>
                            <xsl:variable name="mm" select="../../name"/>
                            <tr>
                                <td>
                                    <xsl:value-of select="string-join(name,', ')"/> 
                                </td>
                                <td>
                                    <xsl:value-of select="string-join(construct,', ')"/> 
                                </td>
                                <td>
                                    <xsl:value-of select="$mm"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </div>
                <div>
                    <h1>Tagged values</h1>
                    <div class="intro">
                        <p>
                            This is the overview of alle configured tagged values, and on which stereotypes they may be specified.
                        </p>
                        <p>
                            In right column the original tagset, possibly included by another tagset, is shown. 
                            Tagset inclusion list is:
                            <xsl:value-of select="string-join($configuration-tvset-file/descendant-or-self::tagset/name,', includes ')"/> 
                        </p>
                    </div>               
                    <table>
                        <xsl:sequence select="imf:create-table-header('tagged value name(s):45,allowed on stereotype(s):45,tagset:10')"/>
                        <xsl:for-each select="$configuration-tvset-file//tv">
                            <xsl:sort select="name[1]"/>
                            <tr>
                                <td>
                                    <xsl:value-of select="string-join(name/@original,', ')"/> 
                                </td>
                                <td>
                                    <xsl:value-of select="string-join(stereotypes/stereo/@original,',  ')"/>
                                </td>
                                <td>
                                    <xsl:value-of select="../../name"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </div>
              
            </content>
        </page>
    </xsl:template>
         
</xsl:stylesheet>
