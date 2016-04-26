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

    <xsl:template match="/config" mode="versions-consolidated">
        <xsl:variable name="history-comparable-start-release" select="if ($start-history-at) then $start-history-at else $history-start-release"/>
        <xsl:variable name="revisions" select="$history-doc//imvert-history:revision[imvert-history:rev-date ge $history-comparable-start-release and imvert-history:status='ok']"/>
        
        <div class="intro">
            <p>
                This overview shows all changes that relate to this version, including changes in underlying models.
            </p>
        
            <xsl:choose>
                <xsl:when test="empty($revisions/imvert-history:class)">
                    <p><b>No reportable changes.</b></p>
                </xsl:when> 
                <xsl:otherwise>
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
                        All changes are merged for each class or property. 
                        If a change doesn't apply to a particular package, class or property it is not listed.
                        The table hold the following columns:
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
                    <xsl:for-each-group 
                        select="$revisions" 
                        group-by="imvert-history:package">
                        <xsl:sort select="imvert-history:package" order="ascending"/>
                        <xsl:if test="imvert-history:package != '*'">
                            <h2>
                                <xsl:sequence select="imf:compile-construct-name(imvert-history:package,'','','')"/>
                            </h2>
                        </xsl:if>
                        <xsl:for-each-group 
                            select="current-group()" 
                            group-by="imvert-history:class">
                            <xsl:sort select="imvert-history:class" order="ascending"/>
                            <xsl:if test="imvert-history:class != '*'">
                                <h2>
                                    <xsl:sequence select="imf:compile-construct-name(imvert-history:package, imvert-history:class,'','')"/>
                                </h2>
                            </xsl:if>
                            <xsl:variable name="rows" as="node()*">
                                <xsl:for-each select="current-group()">
                                    <xsl:sort select="normalize-space(imvert-history:package)" order="ascending"/>
                                    <xsl:sort select="normalize-space(imvert-history:class)" order="ascending"/>
                                    <xsl:sort select="normalize-space(imvert-history:property)" order="ascending"/>
                                    <xsl:sort select="imvert-history:rev-date" order="ascending"/>
                                    <xsl:sort select="imvert-history:date" order="ascending"/>
                                    <xsl:sort select="imvert-history:rev-number" order="ascending"/>
                                    <xsl:variable name="nr" select="@nr"/>
                                    <xsl:variable name="nm" select="if (imvert-history:package = '*') then '--' else imf:compile-construct-name(imvert-history:package, imvert-history:class, imvert-history:property, '')"/>
                                    <row xmlns="">
                                        <xsl:sequence select="imf:create-output-element('cell',string($nr),$empty)"/>
                                        <xsl:sequence select="imf:create-output-element('cell',$nm,$empty,false())"/>
                                        <xsl:sequence select="imf:create-output-element('cell',../../imvert-history:variant-name,$empty)"/>
                                        <xsl:sequence select="imf:create-output-element('cell',imvert-history:rev-number,$empty)"/>
                                        <xsl:sequence select="imf:create-output-element('cell',imvert-history:rev-date,$empty)"/>
                                        <xsl:sequence select="imf:create-output-element('cell',imvert-history:change,$empty)"/>
                                        <xsl:if test="not(imf:boolean($release-to-public))">
                                            <xsl:sequence select="imf:create-output-element('cell',imvert-history:request-number,$empty)"/>
                                            <xsl:sequence select="imf:create-output-element('cell',imvert-history:date,$empty)"/>
                                        </xsl:if>
                                    </row>
                                </xsl:for-each> 
                            </xsl:variable>
                            <xsl:variable name="process-info" select="
                                if (not(imf:boolean($release-to-public))) 
                                then 'change:35,request:10,date:5' 
                                else 'change:45'"/>
                            <xsl:sequence select="imf:create-result-table($rows,concat('number:5,construct:35,variant/app:5,version:5,release:5,',$process-info))"/>
                        </xsl:for-each-group>
                    </xsl:for-each-group>
               </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
     
</xsl:stylesheet>
