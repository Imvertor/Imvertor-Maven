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

    <!-- versie info bevindt zich in een apart file -->
   
    <xsl:template match="imvert:packages" mode="identification">
        <page>
            <title>Identification</title>
            <content>
                <div>
                    <div class="intro">
                        <p>
                            This overview shows which classes can be shared or may be identified (externally).
                            For each class the following is specified:
                        </p>
                        <ul>
                            <li>Identifier? Instances of the class can referenced externally by some identifier: any attribute is stereotyped as the external identifier attribute.
                            </li>
                            <li>Shared? The class is stereotyped as an Object type, and therefore has a local ID
                            </li>
                        </ul>
                        <p>When inherit, the class may be identified because some superclass may be identified.</p>
                    </div>
                    <xsl:variable name="rows" as="node()*">
                        <xsl:for-each select=".//imvert:package[not(imvert:ref-master)]">
                            <xsl:sort select="imvert:name" order="ascending"/>
                            <xsl:apply-templates select="imvert:class" mode="identification"/>
                        </xsl:for-each> 
                    </xsl:variable>
                    <xsl:sequence select="imf:create-result-table($rows,'class:80,identifier?:10,shared?:10')"/>
                </div>
            </content>
        </page>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="identification">
        <xsl:variable name="superclasses" select="imf:get-superclasses(.)"/>
        <row xmlns="">
            <xsl:sequence select="imf:create-output-element('cell',imf:get-construct-name(.),$empty)"/>
            <cell>
                <xsl:choose>
                    <!-- Identificattion? - instances of the class can be referenced externally by some identifier: 
                        is-ID is set.-->
                    <xsl:when test="$superclasses/imvert:attributes/imvert:attribute/imvert:is-id = 'true'">inherit</xsl:when>
                    <xsl:when test="imvert:attributes/imvert:attribute/imvert:is-id = 'true'">yes</xsl:when>
                </xsl:choose>
            </cell>
            <cell>
                <xsl:choose>
                    <!-- Shared? - the class is stereotyped as an Object type, and therefore has a local ID -->
                    <xsl:when test="$superclasses/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')">inherit</xsl:when>
                    <xsl:when test="imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')">yes</xsl:when>
                </xsl:choose>
            </cell>
        </row>
    </xsl:template>
    
</xsl:stylesheet>
