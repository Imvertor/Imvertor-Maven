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
        Compile Base info. This is:
        position | Name | Property | Type | minocc | maxOcc |stereotype 
    -->
    <xsl:template match="imvert:packages" mode="compactview">
        <page>
            <title>Compact view</title>
            <content>
                <div>
                    <div class="intro">
                        <p>
                            This is a technical overview ofd all constructs, suitable for import into Excel.
                        </p>
                    </div>
                    <table>
                        <xsl:sequence select="imf:create-table-header('pos:10,property:40,type:40,min:5,max:5,stereotype:10')"/>
                        <xsl:apply-templates select=".//imvert:class[not(imvert:ref-master)]" mode="compactview"/>
                    </table>
                </div>
            </content>
        </page>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="compactview">
        <tr>
            <td/>
            <td>
                <xsl:sequence select="imf:get-construct-name(.)"/>
            </td>
            <td/>
            <td>
                <xsl:value-of select="imvert:min-occurs"/>
            </td>   
            <td>
                <xsl:value-of select="imvert:max-occurs"/>
            </td>   
            <td>
                <xsl:value-of select="string-join(imvert:stereotype,' ')"/>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="imvert:attributes/imvert:attribute|imvert:associations/imvert:association">
                <xsl:for-each select="imvert:attributes/imvert:attribute|imvert:associations/imvert:association">
                    <xsl:sort select="xs:integer(imvert:position)"/>
                    <xsl:apply-templates select="." mode="compactview"/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="compactview">
        <xsl:apply-templates select="." mode="compactview-property"/>   
    </xsl:template>
    <xsl:template match="imvert:association" mode="compactview">
        <xsl:apply-templates select="." mode="compactview-property"/>   
    </xsl:template>
    
    <xsl:template match="*" mode="compactview-property">
        <tr>
            <td>
                <xsl:value-of select="imvert:position"/>
            </td>
            <td>
                <xsl:sequence select="imf:get-construct-name(.)"/>
            </td>
            <td>
                <xsl:value-of select="@type-display-name"/>
                <xsl:if test="imvert:baretype != imvert:type-name"> (<xsl:value-of select="imvert:baretype"/>)</xsl:if>
            </td>   
            <td>
                <xsl:value-of select="imvert:min-occurs"/>
            </td>   
            <td>
                <xsl:value-of select="imvert:max-occurs"/>
            </td>   
            <td>
                <xsl:value-of select="string-join(imvert:stereotype,' ')"/>
            </td>
        </tr>
     </xsl:template>

    <xsl:template match="*|text()" mode="compactview">
        <xsl:apply-templates mode="compactview"/>
    </xsl:template>  
   
</xsl:stylesheet>
