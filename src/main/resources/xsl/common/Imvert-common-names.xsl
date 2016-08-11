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
    xmlns:imvert="http://www.imvertor.org/schema/system"
    
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
    
    <!-- 
        Since tracing and proxies are supported, we need formal names. Add support here. 
    -->
    
    <xsl:variable name="traceable-package-stereotypes" select="imf:get-config-stereotypes(
        ('stereotype-name-domain-package',
        'stereotype-name-view-package',
        'stereotype-name-intern-package',
        'stereotype-name-extern-package'))"/>
    
    <xsl:function name="imf:get-construct-formal-name" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="type-name" select="local-name($this)"/>
        <xsl:variable name="package-name" select="$this/ancestor-or-self::imvert:package[imvert:stereotype = $traceable-package-stereotypes][1]/imvert:name"/>
        <xsl:variable name="class-name" select="$this/ancestor-or-self::imvert:class[1]/imvert:name"/>
        <xsl:variable name="prop-name" select="$this[self::imvert:attribute | self::association]/imvert:name"/> 
        <xsl:sequence select="imf:compile-construct-formal-name($type-name,$package-name,$class-name,$prop-name)"/>
    </xsl:function>
    
    <xsl:function name="imf:compile-construct-formal-name" as="xs:string">
        <xsl:param name="type-name" as="xs:string"/>
        <xsl:param name="package-name" as="xs:string?"/>
        <xsl:param name="class-name" as="xs:string?"/>
        <xsl:param name="property-name" as="xs:string?"/>
        <xsl:value-of select="string-join(($type-name,$package-name,$class-name,$property-name),'_')"/>
    </xsl:function>  
    
</xsl:stylesheet>
