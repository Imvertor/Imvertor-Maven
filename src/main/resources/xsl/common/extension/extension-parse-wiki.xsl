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
    
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    version="2.0">
  
    <xsl:import href="extension-parse-html.xsl"/>
    
    <!-- return XML representation of the wiki using markup language as defined. -->
    
    <xsl:function name="imf:parse-wiki" as="element(xhtml:body)">
        <xsl:param name="wiki-string" as="xs:string"/>
        <xsl:param name="wiki-language" as="xs:string"/>

        <xsl:variable name="raw" select="ext:imvertorParseWiki($wiki-string,$wiki-language)"/>
        <xsl:variable name="xml" select="imf:parse-html((),$raw,false())"/>
        <xsl:sequence select="$xml/xhtml:body"/>
    </xsl:function>
    
</xsl:stylesheet>