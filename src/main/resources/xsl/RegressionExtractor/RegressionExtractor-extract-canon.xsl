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
    
    <!-- configuration and EA profiles -->
    <xsl:include href="../ConfigCompiler/ConfigCompiler-regtest.xsl"/>
    <xsl:include href="../ConfigCompiler/Imvert2metamodel-regtest.xsl"/>
    <xsl:include href="../ConfigCompiler/Imvert2ea-profile-regtest.xsl"/>
    
    <!-- Imvertor format -->
    <xsl:include href="../ImvertCompiler/ImvertCompiler-regtest.xsl"/>
    
    <!-- MIM serialization -->
    <xsl:include href="../MIMCompiler/MIMCompiler-regtest.xsl"/>
    
    <!-- XSD -->
    <xsl:include href="../XsdCompiler/XsdCompiler-regtest.xsl"/>
    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    
    <xsl:template match="/"> <!-- let op! deze extractor wordt aangeroepen op cw:file root elementen! -->
        <xsl:variable name="path" select="replace($file-path, '\\','/')"/>
        <xsl:choose>
            <!-- process the config profile -->
            <xsl:when test="$path = '/etc/config.xml'">
                <xsl:sequence select="dlogger:save('Config test',$path)"/>
                <xsl:apply-templates mode="mode-regtest-config"/>
            </xsl:when>
            <!-- process the metamodel -->
            <xsl:when test="$path = '/etc/metamodel.xml'">
                <xsl:sequence select="dlogger:save('Metamodel test',$path)"/>
                <xsl:apply-templates mode="mode-regtest-metamodel"/>
            </xsl:when>
            <!-- process the EA profile -->
            <xsl:when test="starts-with($path, '/ea/') and $file-type = 'xml'">
                <xsl:sequence select="dlogger:save('EA test',$path)"/>
                <xsl:apply-templates mode="mode-regtest-eaprofile"/>
            </xsl:when>
            <!-- process the imvertor intermediate format -->
            <xsl:when test="$path = '/etc/system.imvert.xml'">
                <xsl:sequence select="dlogger:save('Imvertor format test',$path)"/>
                <xsl:apply-templates mode="mode-regtest-imvert"/>
            </xsl:when>
            <!-- process the MIM serialisation result -->
            <xsl:when test="starts-with($path, '/mim/') and $file-type = 'xml'">
                <xsl:sequence select="dlogger:save('MIM serialization test',$path)"/>
                <xsl:apply-templates mode="mode-regtest-mimser"/>
            </xsl:when>
            <!-- process the XSD's -->
            <xsl:when test="starts-with($path, '/xsd/') and $file-type = 'xsd'">
                <xsl:sequence select="dlogger:save('XSD test',$path)"/>
                <xsl:apply-templates mode="mode-regtest-xsd"/>
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
        <REGTEST>IGNORED: {name()}</REGTEST>
    </xsl:template>
    
</xsl:stylesheet>
