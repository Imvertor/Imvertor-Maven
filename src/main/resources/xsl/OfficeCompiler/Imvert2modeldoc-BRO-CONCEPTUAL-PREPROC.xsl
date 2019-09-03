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
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"

    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
        (1) verander alle gegevensgroeptypen in objecttypen
        (2) selecteer specifieke tagged values voor Registratieobjecttype
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="huidige-registratie-object" select="//imvert:class[imvert:supertype/imvert:type-name = 'Registratieobject']"/>

    <xsl:template match="/imvert:packages">
        <xsl:variable name="domains" select="imvert:package[imvert:stereotype/@id = 'stereotype-name-domain-package']"/>
        <xsl:choose>
            <xsl:when test="count($domains) gt 1">
                <xsl:sequence select="imf:msg('ERROR','STUB Cannot yet process more than one domain for BRO: [1]', imf:string-group($domains/imvert:name/@original))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
     
    <!-- (1) -->
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-attributegroup']">
        <!-- vervalt, wordt relatie -->
    </xsl:template>
   
    <xsl:template match="imvert:associations">
        <xsl:copy>
            <xsl:apply-templates/>
            
            <!-- maak nieuwe relatie aan in plaats van attribuut van type gegevensgroep -->
            <xsl:variable name="ag" select="../imvert:attributes/imvert:attribute[imvert:stereotype/@id = 'stereotype-name-attributegroup']"/>
            <xsl:for-each select="$ag">
                <xsl:variable name="current-ag" select="."/>
                <imvert:association>
                    <xsl:apply-templates select="$current-ag/*"/>
                    
                    <imvert:target>
                        <imvert:stereotype id="stereotype-name-relation-role">RELATIEROL</imvert:stereotype>
                        <imvert:role original="{$current-ag/imvert:name/@original}"><xsl:value-of select="$current-ag/imvert:name"/></imvert:role>
                        <imvert:navigable>true</imvert:navigable>

                        <xsl:apply-templates select="$current-ag/imvert:tagged-values"/>
                    </imvert:target>
                </imvert:association>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:stereotype[@id = 'stereotype-name-composite']">
        <imvert:stereotype id="stereotype-name-objecttype">OBJECTTYPE</imvert:stereotype>
    </xsl:template>    
    
    <xsl:template match="imvert:stereotype[@id = 'stereotype-name-attributegroup']">
        <imvert:stereotype id="stereotype-name-relatiesoort">RELATIESOORT</imvert:stereotype>
    </xsl:template>    
    
    <!-- (2) -->
    <xsl:template match="imvert:class[imvert:name = 'Registratieobject']/imvert:tagged-values">
        <xsl:copy>
            <xsl:apply-templates select="imvert:tagged-value[@id = 'CFG-TV-NAME']"/>
            <xsl:apply-templates select="imvert:tagged-value[@id = 'CFG-TV-DEFINITION']"/>
            <xsl:apply-templates select="imvert:tagged-value[@id = 'CFG-TV-POPULATION']"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- defaults -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
