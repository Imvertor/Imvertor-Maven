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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert="http://www.imvertor.org/xsl/functions"
    
    version="2.0">
    
    <!--
        
	 * Filespec is an array of strings. This holds info on the file, based on the requested info type, expressed as an Uppercase letter in options.
	 * 
	 * 0 P Path,
	 * 1 U URL,
	 * 2 N name (no extension),
	 * 3 X extension,
	 * 4 E E when exists, otherwise e.
	 * 
	 * The following strings are added when the path exists: requires E parameter (this info is only extracted when E is tested):
	 *  
	 * 5 F when it is a file, otherwise f (it's a directory)
	 * 6 H when it is hidden, otherwise h
	 * 7 R when it can be read, otherwise r
	 * 8 W when it can be written to, otherwise w
	 * 9 C when it can be executed, otherwise c
	 * 10 D the date & time in ISO format
	 *
	 * When an error occurred, only 1 string is returned, the error message.
	 * 
	 
    -->
    
    <xsl:function name="imf:filespec" as="xs:string*">
        <xsl:param name="file"/>
        <xsl:sequence select="ext:imvertorFileSpec($file,'PUNXEFHRWCD')"/>
    </xsl:function>
    
    <xsl:function name="imf:filespec" as="xs:string*">
        <xsl:param name="file" as="xs:string"/>
        <xsl:param name="options" as="xs:string"/>
        <xsl:sequence select="ext:imvertorFileSpec($file,$options)"/>
    </xsl:function>
    
</xsl:stylesheet>