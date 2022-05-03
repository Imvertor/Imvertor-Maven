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
    version="2.0">
    
    <!-- 
         Stylesheet to filter ANY xml file found in the tst or ref folder.
         This XSL is generic, and therefore calls upon any imported XSL (or such) to process specific types of file.
         The root element of the file found is passed in a wrapper element:
         
         <cw:file 
            type="{bin or xml}" 
            path="{relative path to the root of the main folder, including name of the file}" 
            date="{integer representation of date}" 
            name="{name of the file}" 
            ishidden="{boolean}" 
            isreadonly="{boolean}" 
            ext="{extension}" 
            fullpath="{full canonical path}"/>
         
         Note that date/time attribute and size attribute typically should be removed for regression comparisons.
         The other *:file data should be passed for reporting purposes.
         
         The folder passed holds the folders/files:
         /job/*
         /work/*
         /executor.imvert.xml
      -->
 
    <xsl:include href="../common/Imvert-common.xsl"/>
    
    <?assume-not-relevant
    <xsl:include href="RegressionExtractor-imvert.xsl"/>
    <xsl:include href="RegressionExtractor-imvert-schema.xsl"/>
    <xsl:include href="RegressionExtractor-history.xsl"/>
    <xsl:include href="RegressionExtractor-office-html.xsl"/>
    ?>
    <xsl:include href="RegressionExtractor-xsd.xsl"/>
    <xsl:include href="RegressionExtractor-eaprofile.xsl"/>
    <xsl:include href="RegressionExtractor-config.xsl"/>
    <?assume-not-relevant
    <xsl:include href="RegressionExtractor-schemas.xsl"/>
    <xsl:include href="RegressionExtractor-parms.xsl"/>
    ?>    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <xsl:template match="/"> <!-- let op! deze extractor wordt aangeroepen op cw:file root elementen! -->
        <xsl:apply-templates select="cw:file"/>
    </xsl:template>
  
    <xsl:template match="cw:file">
        <xsl:variable name="path" select="replace(@path, '\\','/')"/>
        <xsl:choose>
            <!--
                process the XSD's 
            -->
            <xsl:when test="starts-with($path, 'work/xsd/')">
                <xsl:sequence select="dlogger:save('XSD test',$path)"/>
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:apply-templates mode="mode-intermediate-xsd"/>
                </xsl:copy>
            </xsl:when>
           
            <!-- process the EA profile -->
            <xsl:when test="starts-with($path, 'work/ea/')">
                <xsl:sequence select="dlogger:save('EA test',$path)"/>
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:apply-templates mode="mode-intermediate-eaprofile"/>
                </xsl:copy>
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
