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
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-message="http://www.imvertor.org/schema/message"
    
    exclude-result-prefixes="#all"
    version="2.0">
   
    <!-- simple message, type and text -->
    <xsl:function name="imf:msg" as="item()*">
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:sequence select="imf:msg($document,$type,$text,())"/>
    </xsl:function>
    
    <!-- simple message, type, text and info inserted within text -->
    <xsl:function name="imf:msg" as="item()*">
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
        <xsl:sequence select="imf:msg($document,$type,$text,$info)"/>
    </xsl:function>
    
    <!-- complex message, pass context node, type, text, and parameters to insert within text -->
    <xsl:function name="imf:msg" as="element()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
        
        <xsl:variable name="name" select="if ($this=$document) then '' else imf:get-construct-name($this)"/>
        <xsl:variable name="ctext" select="if (exists($info)) then imf:msg-insert-parms($text,$info) else $text"/>
        <xsl:message>
            <!-- note that messages are specially processed by Imvertor -->
            <xsl:sequence select="imf:create-output-element('imvert-message:src',$xml-stylesheet-name)"/>
            <xsl:sequence select="imf:create-output-element('imvert-message:type',$type)"/>
            <xsl:sequence select="imf:create-output-element('imvert-message:name',$name)"/>
            <xsl:sequence select="imf:create-output-element('imvert-message:text',$ctext)"/>
        </xsl:message>
    </xsl:function>
    
    <!-- 
		Insert parameters by position into the message string at locations [1], ... [n]. 
		When any parameter is not assigned to any position in the messages string, add at end. 
	--> 
    <xsl:function name="imf:msg-insert-parms" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="parms" as="item()*"/>
        <xsl:variable name="locs" select="tokenize($string,'\[\d+\]')"/>
        <xsl:variable name="r">
            <xsl:analyze-string select="$string" regex="\[(\d)\]">
                <xsl:matching-substring>
                    <xsl:variable name="g" select="$parms[xs:integer(regex-group(1))]"/>
                    <xsl:value-of select="if ($g) then imf:msg-insert-parms-val($g) else '-null-'"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
            <!--
            <xsl:if test="count($parms) ge count($locs)">
                <xsl:variable name="amt" select="count($parms) - count($locs) + 1"/>
                <xsl:sequence select="for $i in (1 to $amt) return concat('; ',$parms[$i])"/>
            </xsl:if>
            -->
        </xsl:variable>
        <xsl:value-of select="$r"/>
    </xsl:function>
    
    <!-- 
		parameter is an element with subelements, in which case full constriuct name is returned, 
		or a text element or other primitive type, in which case the string value is returned. 
	-->
    <xsl:function name="imf:msg-insert-parms-val" as="xs:string?">
        <xsl:param name="this" as="item()"/>
        <xsl:value-of select="concat('&quot;',if ($this instance of element() and $this/*) then imf:get-construct-name($this) else string($this),'&quot;')"/>
    </xsl:function>
        
</xsl:stylesheet>
