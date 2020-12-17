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
    
    xmlns:http="http://expath.org/ns/http-client"
    
    version="3.0">
    
    <!-- check out http://expath.org/spec/http-client -->
    
    <xsl:function name="imf:expath-send-request" as="item()+">
        <xsl:param name="http-request" as="element(http:request)"/>
        <xsl:sequence select="http:send-request($http-request)"/>
    </xsl:function>
    
    <xsl:function name="imf:expath-send-request" as="item()+">
        <xsl:param name="http-request" as="element(http:request)?"/>
        <xsl:param name="href" as="xs:string?"/>
        <xsl:sequence select="http:send-request($http-request,$href)"/>
    </xsl:function>
    
    <xsl:function name="imf:expath-send-request" as="item()+">
        <xsl:param name="http-request" as="element(http:request)?"/>
        <xsl:param name="href" as="xs:string?"/>
        <xsl:param name="bodies" as="item()*"/>
        <xsl:sequence select="http:send-request($http-request,$href,$bodies)"/>
    </xsl:function>
    
</xsl:stylesheet>