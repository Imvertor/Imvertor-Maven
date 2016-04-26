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
        Serialize the zip file to a temporary folder.
        Returns the (full) folder path.
    -->
    <xsl:function name="imf:serializeFromZip" as="xs:string*">
        <xsl:param name="filepath"/>
        <xsl:param name="folderpath"/>
        <xsl:sequence select="ext:imvertorZipSerializer($filepath,$folderpath)"/>
    </xsl:function>

    <!--
        Deserialize the folder to the new zip file.
        Returns the (full) zip file path.
    -->
    <xsl:function name="imf:deserializeToZip" as="xs:string*">
        <xsl:param name="folderpath"/>
        <xsl:param name="filepath"/>
        <xsl:sequence select="ext:imvertorZipDeserializer($folderpath,$filepath)"/>
    </xsl:function>
    
</xsl:stylesheet>