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
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    
    xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310" 
    xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
    xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" 
    xmlns:stuf="http://www.egem.nl/StUF/StUF0301" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    version="2.0">
    
    <xsl:key name="key-get-class-by-original-name" match="//imvert:class" use="imf:get-key-original-name-for-class(.)"/>
    <xsl:key name="key-get-class-by-formal-name" match="//imvert:class" use="imf:get-key-formal-name-for-class(.)"/>
    
    <xsl:function name="imf:get-class-by-name">
        <xsl:param name="package-name" as="xs:string"/>
        <xsl:param name="class-name" as="xs:string"/>
        <xsl:param name="is-original" as="xs:boolean"/>
        <xsl:variable name="key-name" select="imf:create-key-name($package-name,$class-name,$is-original)"/>
        <xsl:choose>
            <xsl:when test="$is-original">
                <xsl:sequence select="key('key-get-class-by-original-name',$key-name,$document)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="key('key-get-class-by-formal-name',$key-name,$document)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:create-key-name" as="xs:string">
        <xsl:param name="package-name"/>
        <xsl:param name="class-name"/>
        <xsl:param name="is-original"/>
        <xsl:value-of select="concat($is-original,'|',$package-name,'|',$class-name)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-key-original-name-for-class" as="xs:string">
        <xsl:param name="class"/>
        <xsl:variable name="package" select="$class/ancestor::imvert:package[1]"/>
        <xsl:variable name="key" select="imf:create-key-name($package/imvert:name/@original,$class/imvert:name/@original,true())"/>
        <xsl:value-of select="$key"/>
    </xsl:function>
    
    <xsl:function name="imf:get-key-formal-name-for-class" as="xs:string">
        <xsl:param name="class"/>
        <xsl:variable name="package" select="$class/ancestor::imvert:package[1]"/>
        <xsl:value-of select="imf:create-key-name($package/imvert:name,$class/imvert:name,false())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-berichten-table">
        <xsl:param name="berichten-infoset" as="element()*"/><!-- bericht | error -->
        <xsl:variable name="infomodel-naam" select="imf:get-config-string('appinfo','application-name')"/>
        <workbook>
            <sheet>
                <name>Productconfiguratie</name>
                <xsl:for-each select="$berichten-infoset[self::bericht]"> <!-- may also contain error element(s) -->
                    <xsl:variable name="is-vrij-bericht" select="bron = 'Vrij bericht'"/>
                    <xsl:variable name="entiteittype" select="entiteittype"/>
                    <xsl:variable name="berichttype" select="berichttype"/>
                    <xsl:variable name="afhandeling" select="afhandeling"/>
                    <xsl:for-each select="bericht-repertoire/berichtcodes/code">
                        <xsl:variable name="berichtcode" select="."/>
                        <xsl:variable name="berichtprefix">
                            <xsl:choose>
                                <xsl:when test="$berichttype = 'antwoord' and not($is-vrij-bericht)">La</xsl:when>
                                <xsl:when test="$berichttype = 'kennisgeving' and not($is-vrij-bericht)">Lk</xsl:when>
                                <xsl:when test="$berichttype = 'vraag' and not($is-vrij-bericht)">Lv</xsl:when>
                                
                                <xsl:when test="$berichttype = 'gelijk'">Gelijk</xsl:when><!-- TODO vaststellen perspectief vrij bericht -->
                                <xsl:when test="$berichttype = 'vanaf'">Vanaf</xsl:when>
                                <xsl:when test="$berichttype = 'tot en met'">Tm</xsl:when>
                                <xsl:when test="$berichttype = 'start'">Start</xsl:when>
                                <xsl:when test="$berichttype = 'scope'">Scope</xsl:when>
                                
                                <xsl:when test="$berichttype = 'selectie'">Di</xsl:when>
                                <xsl:when test="$berichttype = 'update'">Di</xsl:when>
                                <xsl:when test="$berichttype = 'antwoord'">Du</xsl:when>
                                <xsl:when test="$berichttype = 'entiteit'">Du</xsl:when> <!-- TODO dit kan inkomend en uitgaande zijn. waar vastleggen? -->
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:msg('FATAL','Onbekend berichttype: [1]',$berichttype)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="berichtnaam" select="../berichtnaam"/>
                        <xsl:for-each select="$berichten-infoset/instructions">
                            <xsl:variable name="entiteit" select="entiteit"/>
                            <xsl:variable name="attribuut" select="attribuut"/>
                            <xsl:variable name="id" select="id"/>
                            <xsl:for-each select="instruct[berichtnaam = $berichtnaam]">
                                <row>
                                    <col naam="entiteittype">
                                        <data><xsl:value-of select="$entiteittype"/></data>
                                    </col>
                                    <col naam="typeBericht">
                                        <data><xsl:value-of select="$berichttype"/></data>
                                    </col>
                                    <col naam="berichtcode">
                                        <data><xsl:value-of select="concat($berichtprefix,$berichtcode)"/></data>
                                    </col>
                                    <col naam="berichtnaam">
                                        <data><xsl:value-of select="if (berichtnaam != 'standaard') then berichtnaam else ''"/></data>
                                    </col>
                                    <col naam="informatiemodel">
                                        <data><xsl:value-of select="$infomodel-naam"/></data>
                                    </col>
                                    <col naam="alles-opnemen?">
                                        <data><xsl:value-of select="if ($afhandeling = 'kopieer') then 'ja' else 'nee'"/></data>
                                    </col>
                                    <col naam="entiteit">
                                        <data><xsl:value-of select="$entiteit"/></data>
                                    </col>
                                    <col naam="role-target">
                                        <data>(VERVALT)</data>
                                    </col>
                                    <col naam="relatie">
                                        <data><xsl:value-of select="if (exists(context-relation)) then context-relation else '-'"/></data>
                                    </col>
                                    <col naam="attribuut">
                                        <data><xsl:value-of select="$attribuut"/></data>
                                    </col>
                                    <col naam="kardinaliteit">
                                        <data><xsl:value-of select="value"/></data>
                                    </col>
                                    <col naam="imvert-id">
                                        <data><xsl:value-of select="$id"/></data>
                                    </col>
                                </row>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>   
                </xsl:for-each>
            </sheet>
        </workbook>
    </xsl:function>
    
</xsl:stylesheet>