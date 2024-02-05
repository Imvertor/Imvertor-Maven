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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy" 
    >
    
    <!-- 
       Canonization of UGM models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- 
         sorteer alle associaties op alfabetische volgorde. Hierbij eerst de attribuutgroepen, daarna de relaties, dan de externe koppelingen 
     -->
    <xsl:template match="imvert:class">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="imvert:*[not(self::imvert:associations)]"/>
            <imvert:associations>
                <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]">
                    <xsl:sort select="imvert:name"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
                <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-relatiesoort')]">
                    <xsl:sort select="imvert:name"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
                <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-externekoppeling')]">
                    <xsl:sort select="imvert:name"/>
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </imvert:associations>
        </xsl:copy>
    </xsl:template>  

        
    <!-- UGM is opgesteld met dubbelingen van tagged values. Breng deze terug tot één. -->
    <xsl:template match="imvert:tagged-values">
        
        <!-- PATCH 
            sommige UGM zijn nog opgesteld met indicatie kerngegeven. Migreer. Task #488870 -->
        <xsl:variable name="tagged-values-migrated" as="element(imvert:tagged-value)*">
            <xsl:for-each select="imvert:tagged-value">
                <xsl:choose>
                    <xsl:when test="@id = 'CFG-TV-INDICATIEMATCHGEGEVEN' and ../imvert:tagged-value/@id = 'CFG-TV-INDICATIEKERNGEGEVEN'">
                        <!-- skip, als kerngegeven opgegegen let dan niet op matchgegeven -->
                    </xsl:when>
                    <xsl:when test="@id = 'CFG-TV-INDICATIEKERNGEGEVEN'">
                        <imvert:tagged-value id="CFG-TV-INDICATIEMATCHGEGEVEN">
                            <imvert:name origibal="Indicatie matchgegeven">Indicatie matchgegeven</imvert:name>
                            <xsl:sequence select="imvert:value"/>
                        </imvert:tagged-value>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <imvert:tagged-values>
            <xsl:for-each-group select="$tagged-values-migrated" group-by="@id">
                <imvert:tagged-value>
                    <xsl:copy-of select="current-group()[1]/@*"/>
                    <xsl:copy-of select="current-group()[1]/imvert:name"/>
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'CFG-TV-INDICATIEMATCHGEGEVEN'">
                            <xsl:variable name="values" select="current-group()/imvert:value"/>
                            <xsl:variable name="value" select="imf:boolean-or(for $b in $values return imf:boolean($b))"/>
                            <imvert:value original="{@original}">
                                <xsl:value-of select="if ($value) then 'JA' else 'NEE'"/>
                            </imvert:value>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="value" select="current-group()[1]/imvert:value"/>
                            <xsl:sequence select="$value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </imvert:tagged-value>
            </xsl:for-each-group>
        </imvert:tagged-values>
    </xsl:template>
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
</xsl:stylesheet>
