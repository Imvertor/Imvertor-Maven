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

    xmlns:html="http://www.w3.org/1999/xhtml"    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
       Test the documentation for occurrences of links to the kenniskluis.
       If found, test if actually available there. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:variable name="concept-documentation-path" select="imf:get-config-string('appinfo','concepts-file')"/>
    
    <xsl:variable name="concepts" select="imf:document($concept-documentation-path)/imvert:concepts"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:sequence select="if (empty($concepts)) then imf:msg('WARN','No concepts found at [1]',$concept-documentation-path) else ()"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>

    <!-- 
        Check against kenniskluis and add the kenniskluis references, i.e. a set of imvert:concept elements. 
    -->
    <xsl:template match="imvert:documentation">
        <xsl:variable name="this" select="."/>
 
        <!-- first copy as-is -->
        <xsl:sequence select="."/>
        <!-- 
            test if any links, and if so, test of in kenniskluis, and report on this.
            Sample:
             <imvert:documentation>
             ...Appartementsrecht: &lt;a href="$inet://brk.kadaster.nl/id/begrip/Appartementsrecht"&gt;&lt;font color="#0000ff"&gt;&lt;u&gt;brk.kadaster.nl/id/begrip/Appartementsrecht&lt;/u&gt;&lt;/font&gt;&lt;/a&gt;
  
        -->
        <xsl:variable name="expanded" as="element()*">
            <xsl:for-each select="$this//html:a[normalize-space(@href)]">
                <xsl:analyze-string select="@href" regex="^(http://brk\.kadaster\.nl/)(doc)/begrip/([A-Za-z0-9_\-]+)$">
                    <xsl:matching-substring>
                        <xsl:variable name="uri" select="concat(regex-group(1),'id/begrip/',regex-group(3))"/>
                        <xsl:variable name="resolved" select="imf:fetch-concept-documentation($uri)"/>
                        <xsl:if test="exists($resolved)">
                            <imvert:concept>
                                <imvert:uri>
                                    <xsl:value-of select="$uri"/>
                                </imvert:uri>
                                <imvert:info>
                                    <xsl:value-of select="$resolved"/>
                                </imvert:info>
                            </imvert:concept>
                        </xsl:if>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <!-- other link -->
                        <xsl:choose>
                            <xsl:when test="starts-with(.,'#')"/>
                            <xsl:when test="not(unparsed-text-available(.))">
                                <xsl:sequence select="imf:msg($this,'WARN','Cannot access URL [1]',.)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($expanded)">
            <imvert:concepts>
                <xsl:sequence select="$expanded"/>
            </imvert:concepts>
        </xsl:if>     
    </xsl:template>
    
    <xsl:function name="imf:fetch-concept-documentation" as="xs:string?">
        <xsl:param name="uri"/> <!-- complete uri, e.g. http://brk.kadaster.nl/id/begrip/Appartementsrecht --> 
        <xsl:variable name="info" select="$concepts/imvert:concept[imvert:uri = $uri]"/>
        <xsl:variable name="label" select="$info/imvert:label[@lang='nl']"/>
        <xsl:variable name="def" select="$info/imvert:definition[@lang='nl']"/>
        <xsl:variable name="law" select="$info/imvert:legal"/>
        <xsl:variable name="obsolete" select="if (exists($info/imvert:obsolete)) then ' (obsolete)' else ''"/>
        <xsl:variable name="link"/>
        <xsl:choose>
            <xsl:when test="exists($info)">
                <xsl:value-of select="concat(
                    $label, 
                    $obsolete,
                    ': ', 
                    if (exists($def)) then $def else '(Geen definitie beschikbaar)',
                    if (exists($law)) then concat(' (',string-join($law,';'),')') else '')"/>
                <xsl:if test="$obsolete != ''">
                    <xsl:sequence select="imf:msg('WARN','The uri [11 is obsolete', $uri)"/>    
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR','The uri [1] is undefined', $uri)"/>    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
