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
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">

    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:variable name="associations" select="//imvert:association"/>
    
    <!-- 
        Transform previous metamodel to current BP metamodel.
        
        This is a temporary fix.
        
    -->
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:choose>
                <xsl:when test="imf:get-config-string('cli','migrate','no') = 'yes'">
                    <xsl:sequence select="imf:compile-imvert-header(.)"/>
                    <xsl:apply-templates select="imvert:package"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="*"/>
                </xsl:otherwise>
            </xsl:choose>
        </imvert:packages>
    </xsl:template>
    
    <!--
        Voidable, but missing required tagged value "Mogelijk geen waarde"
    -->
    <xsl:template match="imvert:tagged-values">
        <imvert:tagged-values>
            <xsl:if test="../imvert:stereotype = 'VOIDABLE' and empty(imf:get-most-relevant-compiled-taggedvalue-element(.,'##CFG-TV-VOIDABLE'))">
                <imvert:tagged-value origin='migrate'>
                    <imvert:name original="Mogelijk geen waarde">mogelijk geen waarde</imvert:name>
                    <imvert:value original="Ja">Ja</imvert:value>
                </imvert:tagged-value>
            </xsl:if>
            <xsl:apply-templates/>
        </imvert:tagged-values>    </xsl:template>
    <!--
        Identification attribute is not marked as ID
    -->
    <xsl:template match="imvert:attribute">
        <imvert:attribute>
            <xsl:if test="imvert:stereotype = 'IDENTIFICATIE' and empty(imvert:is-id)">
                <imvert:is-id origin='migrate'>true</imvert:is-id>
            </xsl:if>
            <xsl:if test="imvert:stereotype = 'IDENTIFICATIE' and not(imvert:stereotype = 'ATTRIBUUTSOORT')">
                <imvert:stereotype origin='migrate'>ATTRIBUUTSOORT</imvert:stereotype>
            </xsl:if>
            <xsl:if test="not(imvert:stereotype = 'DATA ELEMENT') and ../../imvert:stereotype = 'COMPLEX DATATYPE'">
                <imvert:stereotype origin='migrate'>DATA ELEMENT</imvert:stereotype>
            </xsl:if>
            
            <xsl:variable name="baretype" select="string(imvert:baretype)"/>
            <xsl:variable name="parse" as="xs:string*">
                <xsl:analyze-string select="$baretype" regex="^D(\d+)\.(\d+)$">
                    <xsl:matching-substring>
                        <xsl:sequence select="(regex-group(1),regex-group(2))"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$baretype = 'DATE'">
                    <imvert:baretype>DATUM</imvert:baretype>
                    <imvert:type-name>scalar-date</imvert:type-name>
                </xsl:when>
                <xsl:when test="$baretype = 'DATETIME'">
                    <imvert:baretype>DT</imvert:baretype>
                    <imvert:type-name>scalar-datetime</imvert:type-name>
                </xsl:when>
                <xsl:when test="$baretype = 'BOOLEAN'">
                    <imvert:baretype>INDIC</imvert:baretype>
                    <imvert:type-name>scalar-boolean</imvert:type-name>
                </xsl:when>
                <xsl:when test="$baretype = 'TIME'">
                    <imvert:baretype>TIJD</imvert:baretype>
                    <imvert:type-name>scalar-time</imvert:type-name>
                </xsl:when>
                <xsl:when test="$baretype = 'YEAR'">
                    <imvert:baretype>JAAR</imvert:baretype>
                    <imvert:type-name>scalar-year</imvert:type-name>
                </xsl:when>
                <xsl:when test="exists($parse[1])">
                    <imvert:baretype>
                        <xsl:value-of select="concat('N',$parse[1],',',$parse[2])"/>
                    </imvert:baretype>
                    <imvert:type-name>scalar-decimal</imvert:type-name>
                    <imvert:fraction-digits>
                        <xsl:value-of select="$parse[2]"/>
                    </imvert:fraction-digits>
                    <imvert:total-digits>
                        <xsl:value-of select="xs:integer($parse[1]) + xs:integer($parse[2])"/>
                    </imvert:total-digits>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:baretype"/>
                    <xsl:apply-templates select="imvert:type-name"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:apply-templates select="*[not(local-name() = ('baretype','type-name'))]"/>
            
        </imvert:attribute>
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:stereotype[. = 'COLLECTION']">
        <imvert:stereotype origin='migrate'>COLLECTIE</imvert:stereotype>
    </xsl:template>
    <xsl:template match="imvert:class/imvert:stereotype[. = 'WAARDELIJSTGEGEVEN']">
        <imvert:stereotype origin='migrate'>REFERENTIELIJST</imvert:stereotype>
    </xsl:template>
    
    <!--
       ERROR 
       AKRHYPGeregistreerdPersoon is géén gegevengroeptype.
       Algemeen: een gewone relatie naar een gegevensgroeptype? dan wordt het een objecttype. 
    -->
    <xsl:template match="imvert:class[imvert:stereotype = 'GEGEVENSGROEPTYPE']">
        <imvert:class>
            <xsl:choose>
                <xsl:when test="$associations[imvert:type-id = current()/imvert:id and imvert:stereotype = 'RELATIESOORT']">
                    <xsl:sequence select="imf:msg(.,'WARNING','MIGRATIE: GEGEVENSGROEPTYPE niet toegestaan; we maken er OBJECTTYPE van',())"/>
                    <imvert:stereotype origin="migrate">OBJECTTYPE</imvert:stereotype>
                </xsl:when>
                <xsl:when test="*/imvert:attribute/imvert:stereotype = 'IDENTIFICATIE'">
                    <xsl:sequence select="imf:msg(.,'WARNING','MIGRATIE: GEGEVENSGROEPTYPE mogen geen IDENTIFICATIE attribuut hebben; we maken er OBJECTTYPE van',())"/>
                    <imvert:stereotype origin="migrate">OBJECTTYPE</imvert:stereotype>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="imvert:stereotype"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[local-name() != ('stereotype')]"/>
        </imvert:class>
    </xsl:template>
    <!--
       ERROR 
       Nummeraanduiding is als externe koppeling gespecificeerd.
       dat moet echter de compositie relatie zijn.
    -->
    <xsl:template match="imvert:class/imvert:stereotype[. = 'EXTERNE KOPPELING']">
        <xsl:sequence select="imf:msg(..,'WARNING','MIGRATIE: EXTERNE KOPPELING is bedoeld voor relaties',())"/>
    </xsl:template>
    <xsl:template match="imvert:association">
        <imvert:association>
            <xsl:if test="imf:get-construct-by-id(imvert:type-id)/imvert:stereotype = 'EXTERNE KOPPELING'">
                <imvert:aggregation origin='migrate'>composite</imvert:aggregation>
                <imvert:stereotype origin='migrate'>EXTERNE KOPPELING</imvert:stereotype>
           </xsl:if>
            <xsl:apply-templates/>
        </imvert:association>
    </xsl:template>
    
    <xsl:template match="imvert:union">
        <imvert:union origin="migrate">
            <xsl:for-each select="tokenize(.,'\s+')">
                <xsl:value-of select="concat('scalar-',.,' ')"/>
            </xsl:for-each>           
        </imvert:union>
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
