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

    <!-- information on conceptual schemas accessed -->
    
    <xsl:variable name="conceptual-schema-mapping-name" select="imf:get-config-string('cli','mapping')"/>
    <xsl:variable name="conceptual-schema-mapping-file" select="imf:get-config-string('properties','CONCEPTUAL_SCHEMA_MAPPING_FILE')"/>
    
    <xsl:template match="imvert:packages" mode="conceptualschemas">
        <xsl:if test="exists(.//imvert:package[imvert:conceptual-schema-namespace])">
            <xsl:variable name="cf" select="imf:document($conceptual-schema-mapping-file)/conceptual-schemas"/>
            <page>
                <title>Conceptual schemas</title>
                <content>
                    <div>
                        <div class="intro">
                            <p>This overview shows which conceptual schemas were accessed and to what schemas they have been resolved.</p>
                            <ul>
                                <li>The Conceptual schema mapping name is set to <xsl:value-of select="$conceptual-schema-mapping-name"/>, stored in <xsl:value-of select="$conceptual-schema-mapping-file"/>, version <xsl:value-of select="$cf/svn-id"/>.</li>
                                <li>The overview below shows the conceptual package info, and the classes that are part of these conceptual schema packages.</li>
                            </ul>
                        </div>
                        <xsl:for-each select=".//imvert:package[imvert:conceptual-schema-namespace]">
                            <xsl:sort select="imf:get-construct-name(.)" order="ascending"/>
                            <xsl:variable name="row" as="element()">
                                <row xmlns="">
                                    <xsl:sequence select="imf:create-output-element('cell',imf:get-construct-name(.),$empty)"/>
                                    <xsl:sequence select="imf:create-output-element('cell',imvert:conceptual-schema-namespace,$empty)"/>
                                    <xsl:sequence select="imf:create-output-element('cell',imvert:conceptual-schema-version,$empty)"/>
                                    <xsl:sequence select="imf:create-output-element('cell',imvert:conceptual-schema-phase,$empty)"/>
                                    <xsl:sequence select="imf:create-output-element('cell',imvert:conceptual-schema-release,$empty)"/>
                                    <xsl:sequence select="imf:create-output-element('cell',imvert:conceptual-schema-author,$empty)"/>
                                    <xsl:sequence select="imf:create-output-element('cell',imvert:conceptual-schema-svn-string,$empty)"/>
                                </row>
                            </xsl:variable>
                            <xsl:sequence select="imf:create-result-table($row,'package:10,namespace:35,version:5,phase:5,release:10,author:10,SVN:25')"/>
                            <xsl:variable name="rows" as="element()*">
                                <xsl:for-each select=".//imvert:class">
                                    <xsl:sort select="imvert:name" order="ascending"/>
                                    <row xmlns="">
                                        <xsl:sequence select="imf:create-output-element('cell',imf:get-construct-name(.),$empty)"/>
                                        <xsl:sequence select="imf:create-output-element('cell',imvert:conceptual-schema-class-name,$empty)"/>
                                    </row>
                                </xsl:for-each> 
                            </xsl:variable>
                            <xsl:sequence select="imf:create-result-table($rows,'class name:40,conceptual class name:40')"/>
                        </xsl:for-each> 
                    </div>
                </content>
            </page>
        </xsl:if>
    </xsl:template>
          
</xsl:stylesheet>
