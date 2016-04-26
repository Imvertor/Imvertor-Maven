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
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    
    xmlns:uml="http://schema.omg.org/spec/UML/2.1" 
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" 
 
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns="http://www.w3.org/1999/xhtml"
    
    version="2.0">
    
    <xsl:template match="/">
        <config>
            <xsl:apply-templates select="//imvert:label[@lang='nl']"/>
        </config>
    </xsl:template>
    <xsl:template match="imvert:label">
        <map kk="{.}" im="{.}"/>
    </xsl:template>
        
</xsl:stylesheet>