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

    <xsl:variable name="referencelist-ids" select="$imvert-document/imvert:packages/imvert:package/imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst','stereotype-name-codelist')]/imvert:id"/>
    <xsl:variable name="lists" select="$imvert-document/imvert:packages/imvert:package/imvert:class/imvert:attributes/imvert:attribute[imvert:type-id = $referencelist-ids]"/>
    
    <xsl:template match="imvert:packages" mode="valuelists">
        <xsl:if test="exists($lists)">
            <page>
                <title>Reference and code lists</title>
                <intro>
                    <p>
                        This overview shows all reference/code lists in use, and which property has a value taken from this list.
                    </p>
                    <p>
                        For each list the following is specified:
                    </p>
                    <ul>
                        <li>Attribute for which the value is taken from the list, in the form P::C.p in which P = package C = class, p = property</li>
                        <li>Type of list</li>
                        <li>The URL formal name of the list. This is its Location, and gives access to the published information on this list.</li>
                        <li>Origin of the data location</li>
                    </ul>
                </intro>
                <content>
                    <table class="tablesorter"> 
                        <xsl:variable name="rows" as="element(tr)*">
                            <xsl:apply-templates select="$lists" mode="valuelists"/> 
                        </xsl:variable>
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,'attribute:30,type:10,location:50,origin:10,','table-values')"/>
                    </table>
                </content>
            </page>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="valuelists">
        <xsl:variable name="list" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:variable name="my-location" select="imf:get-data-location(.)"/>
        <xsl:variable name="its-location" select="imf:get-data-location($list)"/>
        <xsl:variable name="url" select="if ($my-location) then $my-location else $its-location"/>
        <xsl:variable name="url-origin" select="if ($my-location) then 'attribute' else 'list'"/>
        <tr>
            <td>
                <!-- wat is de naam van het type waardelijst? -->
                <xsl:sequence select="imf:get-construct-name(.)"/>
            </td>
            <td>
                <!-- type waardenlijst -->
                <xsl:sequence select="$list/imvert:stereotype"/>
            </td>
            <td>
                <span class="url">
                    <xsl:value-of select="$url"/>
                </span>
            </td>
            <td>
                <xsl:value-of select="$url-origin"/>
            </td>
        </tr>  
    </xsl:template>
    
</xsl:stylesheet>
