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
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-appconfig="http://www.imvertor.org/schema/appconfig"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:param name="config-file-path">config.xml</xsl:param>
    <xsl:param name="info-file-path">Imvert</xsl:param>
    
    <xsl:output indent="no"/>

    <xsl:variable name="document" select="/"/>
    
    <xsl:variable name="command" select="('add-tagged-value','del-tagged-value')"/>
    
    <xsl:template match="/">
        <xsl:variable name="sheets" select="/workbook/sheet
            [row[@number='0']/col[@number='0']/data='application']
            [row[@number='0']/col[@number='1']/data=$application-package-name]"/>
        
        <xsl:variable name="sheet" select="$sheets[name=$application-package-version][last()]"/>
        
        <xsl:variable name="startrow" select="($sheet/row[col[@number='0']/data = $command])[1]"/>
        
        <imvert-appconfig:appconfig>
            <xsl:choose>
                <xsl:when test="empty($sheet)">
                    <xsl:sequence select="imf:msg('ERROR','Cannot find application configuration for [1] version [2]', ($application-package-name,$application-package-version))"/>
                </xsl:when>
                <xsl:when test="empty($startrow)">
                    <xsl:sequence select="imf:msg('WARNING','Cannot find any configuration commands for [1] version [2]', ($application-package-name,$application-package-version))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:compile-imvert-filter()"/>
                    <imvert-appconfig:application-name>
                        <xsl:value-of select="$application-package-name"/>
                    </imvert-appconfig:application-name>
                    <imvert-appconfig:application-version>
                        <xsl:value-of select="$application-package-version"/>
                    </imvert-appconfig:application-version>
                    <xsl:apply-templates select="$sheet/row[number(@number) ge number($startrow/@number)]"/>
                </xsl:otherwise>
            </xsl:choose>
            <?x
            <source>
                <xsl:sequence select="/*"/>
            </source>
            ?>
        </imvert-appconfig:appconfig>
    </xsl:template>
    
    <xsl:template match="row[normalize-space(col[1]/data)]">
        <xsl:variable name="level" as="xs:string">
            <xsl:choose>
                <xsl:when test="col[@number='4']/data">relation</xsl:when>
                <xsl:when test="col[@number='3']/data">attribute</xsl:when>
                <xsl:when test="col[@number='2']/data">class</xsl:when>
                <xsl:when test="col[@number='1']/data">package</xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg('ERROR','Invalid specification at row [1]',../col/@number)"/>
                </xsl:otherwise>
            </xsl:choose>    
        </xsl:variable>
        <imvert-appconfig:command level="{$level}">
            <xsl:sequence select="imf:create-output-element('imvert-appconfig:modifier',col[@number='0']/data)"/>
            <xsl:sequence select="imf:create-output-element('imvert-appconfig:package',col[@number='1']/data)"/>
            <xsl:sequence select="imf:create-output-element('imvert-appconfig:class',col[@number='2']/data)"/>
            <xsl:sequence select="imf:create-output-element('imvert-appconfig:property',col[@number='3']/data)"/>
            <xsl:sequence select="imf:create-output-element('imvert-appconfig:target',col[@number='4']/data)"/>
            <xsl:sequence select="imf:create-output-element('imvert-appconfig:name',col[@number='5']/data)"/>
            <xsl:sequence select="imf:create-output-element('imvert-appconfig:value',col[@number='6']/data)"/>
        </imvert-appconfig:command>
    </xsl:template>
    
</xsl:stylesheet>
