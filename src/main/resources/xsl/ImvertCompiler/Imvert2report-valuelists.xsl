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

    <xsl:variable name="referencelist-ids" select=".//imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-referentielijst')]/imvert:id"/>
    <xsl:variable name="lists" select=".//imvert:attribute[imvert:type-id = $referencelist-ids]"/>
    
    <xsl:template match="imvert:packages" mode="valuelists">
        <xsl:if test="exists($lists)">
            <page>
                <title>Value lists</title>
                <content>
                    <div>
                        <div class="intro">
                            <p>
                                This overview shows all value lists in use, and which property has a value taken from this value list.
                            </p>
                            <p>
                                For each value list the following is specified:
                            </p>
                            <ul>
                                <li>Attribute for which the value is taken from the value list, in the form P::C.p in which P = package C = class, p = property</li>
                                <li>The URL formal name of the list. This is its data-location, and gives access to the published information on this value list.</li>
                            </ul>
                        </div>
                        <table>
                            <xsl:sequence select="imf:create-table-header('attribute:30,data location:70')"/>
                            <xsl:apply-templates select="$lists" mode="valuelists"/> 
                        </table>
                    </div>
                </content>
            </page>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="valuelists">
        <tr>
            <td>
                <!-- wat is de naam van het type waardenlijst? -->
                <xsl:sequence select="imf:get-construct-name(.)"/>
            </td>
            <td>
                <!-- welke data-location heeft dit attribuut? -->
                <xsl:variable name="url" select="imvert:data-location"/>
                <a href="{$url}">
                    <xsl:value-of select="$url"/>
                </a>
            </td>
        </tr>  
    </xsl:template>
    
</xsl:stylesheet>
