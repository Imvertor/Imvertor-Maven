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
   
    <!-- 
        message types are 
        FATAL
        ERROR
        WARNING
        INFO
        DEBUG
    -->
   
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
    
    <!-- 
        complex message, pass context node, type, text, and parameters to insert within text 
        
        The message is stored when valid debug mode or when other type of message.
    -->
    <xsl:function name="imf:msg" as="empty-sequence()">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
        
        <xsl:if test="not($type = 'DEBUG') or imf:debug-mode()">
            <xsl:variable name="name" select="if ($this=$document) then '(ROOT)' else imf:get-construct-name($this)"/>
            <xsl:variable name="id" select="$this/imvert:id"/>
            <xsl:variable name="ctext" select="imf:msg-insert-parms($text,$info)"/>
            <xsl:variable name="wiki" select="if ($type = ('ERROR', 'WARNING', 'FATAL')) then imf:get-wiki-key($text) else ''"/>
            <xsl:message>
                <!-- note that messages are specially processed by Imvertor -->
                <xsl:sequence select="imf:create-output-element('imvert-message:src',$xml-stylesheet-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert-message:type',$type)"/>
                <xsl:sequence select="imf:create-output-element('imvert-message:name',$name)"/>
                <xsl:sequence select="imf:create-output-element('imvert-message:text',$ctext)"/>
                <xsl:sequence select="imf:create-output-element('imvert-message:id',$id)"/>
                <xsl:sequence select="imf:create-output-element('imvert-message:wiki',$wiki)"/>
                <xsl:sequence select="imf:create-output-element('imvert-message:mode',$xml-stylesheet-alias)"/>
            </xsl:message>
        </xsl:if>
        
    </xsl:function>
    
    <!-- 
		Insert parameters by position into the message string at locations [1], ... [n]. 
		When any parameter is not assigned to any position in the messages string, add at end. 
	--> 
    <xsl:function name="imf:msg-insert-parms" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="parms" as="item()*"/>
       <xsl:value-of select="imf:insert-fragments-by-index($string,$parms)"/>
    </xsl:function>
    
    <!-- 
		parameter is an element with subelements, in which case full constriuct name is returned, 
		or a text element or other primitive type, in which case the string value is returned. 
	-->
    <xsl:function name="imf:msg-insert-parms-val" as="xs:string?">
        <xsl:param name="this" as="item()"/>
        <xsl:value-of select="concat('&quot;',if ($this instance of element() and $this/*) then imf:get-construct-name($this) else string($this),'&quot;')"/>
    </xsl:function>
        
    <xsl:function name="imf:track" as="item()*">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
        <xsl:sequence select="imf:track(imf:msg-insert-parms($text,$info))"/>
    </xsl:function>
    
    <!--
        A wiki key is a sequence of the first letter or digit of any word in the text, in upper case.
        If the string starts with {ABC} then assume that is the correct wiki key.
        
        Assume text will always produce a valid wiki key.
    -->
    <xsl:function name="imf:get-wiki-key" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:variable name="parse" select="imf:parse-wiki-text($text)"/>
        <xsl:choose>
            <xsl:when test="count($parse) = 2">
                <xsl:value-of select="$parse[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tokens" select="tokenize(imf:extract(upper-case($text),'[A-Z0-9\s]'),'\s+')"/>
                <xsl:value-of select="string-join(for $w in $tokens return substring($w,1,1),'')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:parse-wiki-text" as="xs:string*">
        <xsl:param name="text" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($text,'{')">
                <xsl:analyze-string select="$text" regex="^\{{(.+?)\}}(.*)$">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>    </xsl:function>
    
    <!-- when sequence passed as msg parameter, return "1", "2" in stead of "1,2" -->
    <xsl:function name="imf:string-group" as="xs:string">
        <xsl:param name="values" as="item()*"/>
        <xsl:sequence select="string-join(for $v in $values return string($v),'&quot;, &quot;')"/>
    </xsl:function>
</xsl:stylesheet>
