<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 VNG/KING
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
  
    xmlns:ws="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-history="http://www.imvertor.org/schema/history"
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all"
    expand-text="yes"
    version="3.0">
    
    <!-- 
         Stylesheet to filter ANY xml file found in the tst-canon or ref-canon folder.
         This XSL is generic, and therefore calls upon any imported XSL (or such) to process specific types of file.
    -->
 
    <xsl:include href="../common/Imvert-common.xsl"/>
    
    <xsl:param name="file-path"/>
    <xsl:param name="file-type"/>
    
    <?assume-not-relevant
    <xsl:include href="RegressionExtractor-imvert.xsl"/>
    <xsl:include href="RegressionExtractor-imvert-schema.xsl"/>
    <xsl:include href="RegressionExtractor-history.xsl"/>
    <xsl:include href="RegressionExtractor-office-html.xsl"/>
    ?>
    <xsl:include href="RegressionExtractor-xsd.xsl"/>
    <xsl:include href="RegressionExtractor-eaprofile.xsl"/>
    <xsl:include href="RegressionExtractor-config.xsl"/>
    <xsl:include href="RegressionExtractor-metamodel.xsl"/>
    <xsl:include href="RegressionExtractor-parms.xsl"/>
    <?assume-not-relevant
    <xsl:include href="RegressionExtractor-schemas.xsl"/>
    ?>    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <xsl:template match="/"> <!-- let op! deze extractor wordt aangeroepen op cw:file root elementen! -->
        <xsl:variable name="path" select="replace($file-path, '\\','/')"/>
        
        <xsl:choose>
            <!--
                process the XSD's 
            -->
            <xsl:when test="starts-with($path, '/xsd/') and $file-type = 'xsd'">
                <xsl:apply-templates mode="mode-intermediate-xsd"/>
            </xsl:when>
            
            <!-- process the EA profile -->
            <xsl:when test="starts-with($path, '/ea/') and $file-type = 'xml'">
                <xsl:apply-templates mode="mode-intermediate-eaprofile"/>
            </xsl:when>
            
            <!-- process the config profile -->
            <xsl:when test="$path = '/etc/config.xml'">
                <xsl:apply-templates mode="mode-intermediate-config"/>
            </xsl:when>
            
            <!-- process the metamodel -->
            <xsl:when test="$path = '/etc/metamodel.xml'">
                <xsl:apply-templates mode="mode-intermediate-metamodel"/>
            </xsl:when>
            
            <!-- process the parms -->
            <xsl:when test="$path = '/etc/parms.xml'">
                <xsl:apply-templates mode="mode-intermediate-parms"/>
            </xsl:when>
            
            <!-- skip all others -->
        </xsl:choose>
    </xsl:template>
  
    <xsl:template match="*|text()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ignore all comments and pi's -->
    <xsl:template match="comment() | processing-instruction()" mode="#all"/>
    
    <xsl:template name="ignore">
        <xsl:value-of select="'&#10;'"/>
        <xsl:comment>IGNORED</xsl:comment>
        <xsl:value-of select="'&#10;'"/>
    </xsl:template>
    
</xsl:stylesheet>
