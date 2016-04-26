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
    xmlns:imvert-history="http://www.imvertor.org/schema/history"

    exclude-result-prefixes="#all" 
    version="2.0">

    <xsl:template match="/config" mode="versions">
        <div class="intro">
            <xsl:variable name="variants" select="$history-doc/imvert-history:versions/imvert-history:variants/imvert-history:variant" as="node()*"/>
            <p>
                This overview shows all changes that relate to this version.
                The changs are listed chronologically.
            </p>
            <xsl:choose>
                <xsl:when test="exists($variants)">
                    <p>
                        <xsl:choose>
                            <xsl:when test="$start-history-at">
                                All changes that occurred at or after <xsl:value-of select="$start-history-at"/> are show. 
                            </xsl:when>
                            <xsl:when test="$prev-application-release">
                                Only the changes that occurred after the previous formal release of this application are show. 
                                This is therefore confined to changes after <xsl:value-of select="$history-start-release"/>. 
                            </xsl:when>
                            <xsl:otherwise>
                                Only the changes that concern this (first) release are show. 
                                This is confined to changes after <xsl:value-of select="$history-start-release"/>.
                            </xsl:otherwise>
                        </xsl:choose>
                    </p>
                    <p>
                        First all changes at application level are listed; 
                        then changes in the supplier models are listed.
                        <i>Not all changes in the supplier models are reflected in the client model.</i>
                    </p>
                    <p>
                        The tables are listed in ascending version number, and within a version listing in ascending release number.
                        Example: 
                        <b>CDMKAD: version 1.0.0 released 20110601</b> 
                        means: model name is CDMKAD, 
                        version number is 1.0.0, released at june 1st, 2011.
                        The tables are sorted by class affected by the change, and in these  
                        on date of the change, and in these on the property.
                    </p>
                    <p>
                        The tabels have the following columns:
                    </p>
                    <ul>
                        <li>Number of the change</li>
                        <li>Changed construct, in the form P::C.p in which P = package C = class, p = property</li>
                        <li>Variant of application name</li>
                        <li>Version of variant or application</li>
                        <li>Release number of the variant or application</li>
                        <li>Description of the change</li>
                        <xsl:if test="not(imf:boolean($release-to-public))">
                            <li>Internal (request/change) number which caused the change</li>
                            <li>Date of the change</li>
                        </xsl:if>
                    </ul>         
                    
                    <xsl:apply-templates select="$variants/imvert-history:revisions"/>
                </xsl:when>
                <xsl:otherwise>
                    <p><b>No reportable changes.</b></p>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
     
    <xsl:template match="imvert-history:revisions">
        <xsl:variable name="history-comparable-start-release" select="if ($start-history-at) then $start-history-at else $history-start-release"/>
        
        <xsl:for-each-group 
            select="imvert-history:revision[imvert-history:rev-date ge $history-comparable-start-release]" 
            group-by="concat(preceding::imvert-history:variant-name[1], ' ', imvert-history:rev-number,' ',imvert:rev-date)">
            <h2>
                <xsl:value-of select="concat(preceding::imvert-history:variant-name[1],': version ', imvert-history:rev-number,' released ', imvert-history:rev-date)"/>
            </h2>
            <xsl:variable name="rows" as="node()*">
                <xsl:for-each select="current-group()[imvert-history:status='ok']">
                    <xsl:sort select="imvert-history:date" order="ascending"/>
                    <xsl:sort select="imvert-history:package" order="ascending"/>
                    <xsl:sort select="imvert-history:class" order="ascending"/>
                    <xsl:sort select="imvert-history:property" order="ascending"/>
                    <xsl:variable name="nr" select="@nr"/>
                    <xsl:variable name="nm" select="if (imvert-history:package = '*') then '--' else imf:compile-construct-name(imvert-history:package, imvert-history:class, imvert-history:property, '')"/>
                    <row xmlns="">
                        <xsl:sequence select="imf:create-output-element('cell',string($nr),$empty)"/>
                        <xsl:sequence select="imf:create-output-element('cell',$nm,$empty,false())"/>
                        <xsl:sequence select="imf:create-output-element('cell',imvert-history:date,$empty)"/>
                        <xsl:sequence select="imf:create-output-element('cell',imvert-history:change,$empty)"/>
                        <xsl:sequence select="imf:create-output-element('cell',imvert-history:request-number,$empty)"/>
                    </row>
                </xsl:for-each> 
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table($rows,'number:10,construction:30,date:10,change:40,request:10')"/>
        </xsl:for-each-group>
    </xsl:template>
   
</xsl:stylesheet>
