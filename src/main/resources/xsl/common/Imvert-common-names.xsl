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
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- all common variables replaced by cfg references, see IM-119 -->
        
    <xsl:variable name="language" select="imf:get-config-string('cli','language')"/>    
 
    <!--
        Translate a key (e.g. "pattern") within a particular realm (such as "tv", for tagged value) to a valid alternative key (eg. "patroon") 
        in accordance with the language chosen (eg. "nl").
    -->
    <!--TODO translate() beter integreren in alle configuraties -->
    <xsl:variable name="realms">
        <xi:include href="listings/realms.xml"/>
    </xsl:variable>
    <xsl:key name="key-realms" match="//map" use="concat(../../@name,'-',../@name,'-',@lang)"/>
    
    <xsl:function name="imf:translate" as="xs:string*">
        <xsl:param name="key" as="xs:string*"/>
        <xsl:param name="realm" as="xs:string"/>
        <xsl:for-each select="$key">
            <xsl:variable name="v" select="key('key-realms',concat($realm,'-',.,'-',$language),$realms)"/>
            <xsl:value-of select="if (normalize-space($v)) then $v else $key"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:translate-tv" as="xs:string*">
        <xsl:param name="key" as="xs:string*"/>
        <xsl:sequence select="imf:translate($key,'tv')"/>
    </xsl:function>
    
</xsl:stylesheet>
