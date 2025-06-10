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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    xmlns:local="urn:local"
    
    exclude-result-prefixes="#all"
    expand-text="yes">
    
    <!-- 
         Reporting stylesheet for the Release comparer
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/cmps">
        <cmps>
            <xsl:variable name="res" as="element(res)*">
                <xsl:apply-templates select="res"/>
            </xsl:variable>
            <xsl:sequence select="$res"/>
            <xsl:sequence select="imf:set-xparm('appinfo/compare-differences-clean',count($res))"/>
        </cmps>
    </xsl:template>

    <xsl:template match="res">
        <xsl:variable name="parent-id" select="imf:substring-before-last(cmp[1]/@id,'_')"/>
        <xsl:if test="not(/cmps/res[@type = ('ADDED','REMOVED')]/cmp/@id = $parent-id)">
            <xsl:sequence select="."/>
        </xsl:if>
    </xsl:template>

    <xsl:function name="imf:substring-before-last" as="xs:string"> <!-- https://stackoverflow.com/questions/3141847/xslt-finding-last-occurence-in-a-string -->
        <xsl:param name="s" as="xs:string"/>
        <xsl:param name="delim" as="xs:string"/>
        <xsl:value-of select="
            if (contains($s,$delim)) 
            then substring($s,1,index-of(string-to-codepoints($s),string-to-codepoints($delim))[last()] - 1)
            else ''
        "/>
    </xsl:function>

</xsl:stylesheet>