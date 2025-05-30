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
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy" 
    
    exclude-result-prefixes="#all"
    expand-text="yes"
    >
    
    <!-- 
       Canonization of Waterschapshuis models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <?x Dit is nog onderwerp van discussie
    <!--
        Enumeratie waarden worden omschrijvingen.
        Enumeratie initiele waarden worden enumeratiewaarden.
        
        NB In de respec output wordt een derde kolom toegevoegd, voor de definitie.
    -->
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-enum']">
        <imvert:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[not(local-name() = ('name','tagged-values'))]"/>
            <xsl:variable name="passed-name" select="imvert:name"/>
            <xsl:variable name="passed-definition" select="imf:get-tagged-value-element(.,'##CFG-TV-DEFINITION')/*"/>
            <xsl:variable name="passed-initialvalue" select="normalize-space(imvert:initial-value)"/>
            <imvert:name original="{$passed-initialvalue}">{$passed-initialvalue}</imvert:name>
            <imvert:tagged-values>
                <xsl:for-each select="imvert:tagged-values/*[not(@id = ('CFG-TV-DEFINITION','CFG-TV-DESCRIPTION'))]">
                    <xsl:apply-templates select="."/>
                    <imvert:tagged-value id="CFG-TV-DEFINITION" level="1">
                        <imvert:name original="Definitie">definitie</imvert:name>
                        <imvert:value original="{$passed-name}">{$passed-name}</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-DESCRIPTION" level="1">
                        <imvert:name original="Omschrijving">omschrijving</imvert:name>
                        <imvert:value>
                            <xsl:sequence select="$passed-definition"/>
                        </imvert:value>
                    </imvert:tagged-value>
                </xsl:for-each>
            </imvert:tagged-values>
        </imvert:attribute>
    </xsl:template>
    x?>
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>  
    
</xsl:stylesheet>
