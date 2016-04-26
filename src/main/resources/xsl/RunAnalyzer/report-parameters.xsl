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
    
    <xsl:template match="config" mode="doc-parameters">
        <page>
            <title>Runtime parameters passed</title>
            <content>
                <div>
                    <h1>Parameters</h1>
                    <div class="intro">
                        <p>
                            Info on the parameters passed for this run, and their values.
                        </p>
                    </div> 
                    <!--
                    <xmp>
                        <xsl:sequence select="$configuration/config"></xsl:sequence>
                    </xmp>
                    -->
                    <table>
                        <xsl:sequence select="imf:create-table-header('Name:10,Value:20,Args:10,Explain:40,Required?:10,Step:10')"/>
                        <xsl:for-each select="$configuration/config/cli/*">
                            <xsl:sort select="name()"/>
                            <xsl:variable name="name" select="name()"/>
                            <xsl:variable name="cli-info" select="$configuration/config/clispecs/clispec[longKey = $name]"/>
                            <tr>
                                <td>
                                    <xsl:value-of select="$name"/> 
                                </td>
                                <td>
                                    <xsl:value-of select="."/> 
                                </td>
                                <td>
                                    <xsl:value-of select="$cli-info/argKey"/>
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
                            </tr>
                        </xsl:for-each>
                    </table>
                </div>
            </content>
        </page>
    </xsl:template>
         
</xsl:stylesheet>
