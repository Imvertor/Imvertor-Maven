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
    
    <xsl:variable name="calls-doc" select="imf:document(imf:get-config-string('properties','WORK_XSLTCALLS_CHAIN_FILE'),true())"/>
    
    <xsl:variable name="sign-identity">=</xsl:variable>
    <xsl:variable name="sign-dummy">x</xsl:variable>
    <xsl:variable name="sign-step">&#8617;</xsl:variable>
    <xsl:variable name="sign-final">&#8718;</xsl:variable>
    
    <xsl:template match="config" mode="xslt-calls">
        <page>
            <title>Transformations overview</title>
            <intro>
                <p>
                    Info on the XSLT transformations made.
                </p>
                <p>Type columns signs are:</p>
                <ul>
                    <li>[ <xsl:value-of select="$sign-step"/> ] A step result used in a subsequent transformation</li>
                    <li>[ <xsl:value-of select="$sign-final"/> ] A step result that is final</li>
                    <li>[ <xsl:value-of select="$sign-dummy"/> ] A step result used that is created by several transformations and may be considerd dummy output</li>
                    <li>[ <xsl:value-of select="$sign-identity"/> ] A step result that replaces the input</li>
                </ul>
            </intro> 
            <content>
                <table class="tablesorter"> 
                    <xsl:variable name="rows" as="element(tr)*">
                        <xsl:for-each select="$calls-doc/calls/call">
                            <tr class="{if (@input = 'parms.xml') then 'cmp-system' else ''}">
                                <td>
                                    <xsl:value-of select="@step"/> 
                                </td>
                                <td>
                                    <xsl:value-of select="@input"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@xslt"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@output"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="@input = @output">
                                            <xsl:value-of select="$sign-identity"/> 
                                        </xsl:when>
                                        <xsl:when test="count($calls-doc/calls/call/@output = current()/@output) gt 1">
                                            <xsl:value-of select="$sign-dummy"/> 
                                        </xsl:when>
                                        <xsl:when test="$calls-doc/calls/call/@input = current()/@output">
                                            <xsl:value-of select="$sign-step"/> <!-- curly arrow -->
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$sign-final"/> <!-- final result -->
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:value-of select="@duration"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-result-table-by-tr($rows,'Step:10,Input:25,XSLT:25,Output:25,Ty:5,Dur:10','table-calls')"/>
                </table>

            </content>
        </page>
    </xsl:template>
         
</xsl:stylesheet>
