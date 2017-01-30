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
        
	 * 1 P Path,
	 * 2 U URL,
	 * 3 N name (no extension),
	 * 4 X extension,
	 * 5 E E when exists, otherwise e.
	 * 
	 * The following strings are added when the path exists:
	 *  
	 * 6 F when it is a file, otherwise f (it's a directory)
	 * 7 H when it is hidden, otherwise h
	 * 8 R when it can be read, otherwise r
	 * 9 W when it can be written to, otherwise w
	 * 10 C when it can be executed, otherwise c
	 * 11 D the date & time in ISO format

     * When an error occured, only 1 string is returned, the error message.
	 
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