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
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="regex-instruction" select="'^\s*(\S+?)\s*:\s*(\S+?)\s*=\s*(\S+?)\s*(\((.*?)\.(.*?)\)\s*)?$'"/>
    <xsl:variable name="regex-repertoire" select="'^\s*(\S+?)\s*:\s*((\d+|\s)+)\s*$'"/>
    
    <xsl:template match="/">
        <berichten>
            <xsl:apply-templates select="//imvert:class[imf:get-tagged-value(.,'config-berichttypes') != '']"/>
        </berichten>
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <xsl:variable name="bericht" select="."/>    <!-- eg. AntwoordBericht -->
        <xsl:variable name="relations" select="imvert:associations/imvert:association"/>
        <xsl:variable name="berichtnamen-prop" select="imf:get-applicable-property($bericht,'berichtnamen')"/>
        <xsl:variable name="berichtnamen-enum" select="imf:get-construct-by-id($berichtnamen-prop/imvert:type-id)"/>
        <xsl:variable name="berichtnamen" select="$berichtnamen-enum/*/imvert:attribute/imvert:name/@original"/>
        <xsl:choose>
            <xsl:when test="exists($berichtnamen-prop)">
                <xsl:for-each select="$relations">
                    <xsl:variable name="relation" select="."/>    <!-- eg. AntwoordBericht.antwoord -->                        
                    <xsl:variable name="roots" select="imf:get-construct-by-id(imvert:type-id)"/>    <!-- eg. Union: object -->
                    <xsl:choose>
                        <xsl:when test="$roots/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union')">
                            <!-- only process unions! -->
                            <xsl:for-each select="$roots/imvert:attributes/imvert:attribute">
                                <xsl:variable name="root" select="."/>    <!-- eg. object.nps -->
                                <bericht>
                                    <bron>
                                        <xsl:value-of select="$bericht/imvert:name/@original"/>
                                    </bron>
                                    <entiteittype>
                                        <xsl:value-of select="$root/imvert:name/@original"/>
                                    </entiteittype>
                                    <berichttype>
                                        <xsl:value-of select="$relation/imvert:name/@original"/>
                                    </berichttype>
                                    <xsl:variable name="afhandeling" select="imf:get-tagged-value($bericht,'config-afhandeling')"/>
                                    <xsl:if test="empty($afhandeling)">
                                        <xsl:sequence select="imf:msg($bericht,'ERROR','Geen afhandeling opgegeven',())"/>
                                    </xsl:if>
                                    <afhandeling>
                                        <xsl:value-of select="$afhandeling"/>
                                    </afhandeling>
                                    <xsl:variable name="repertoire" select="imf:process-tv-config($bericht,'config-berichttypes',$berichtnamen)"/>
                                    <bericht-repertoire>
                                        <xsl:sequence select="$repertoire"/>
                                    </bericht-repertoire>
                                    <xsl:for-each select="$root/imvert:type-id">
                                        <xsl:variable name="objecttype" select="imf:get-construct-by-id(.)"/>    <!-- eg. NATUURLIJK PERSOON -->
                                        <xsl:for-each select="($objecttype/imvert:attributes/imvert:attribute,$objecttype/imvert:associations/imvert:association)">
                                            <xsl:variable name="config" select="imf:process-tv-config(.,concat('config-',$relation/imvert:name),$berichtnamen)" as="element()*"/>
                                            <instructions>
                                                <entiteit>
                                                    <xsl:value-of select="$objecttype/imvert:name/@original"/>
                                                </entiteit>
                                                <attribuut>
                                                    <xsl:value-of select="imvert:name/@original"/>
                                                </attribuut>
                                                <id>
                                                    <xsl:value-of select="imvert:id"/>
                                                </id>
                                                <xsl:choose>
                                                    <xsl:when test="exists($config[self::instruct])">
                                                        <xsl:sequence select="$config"/>
                                                    </xsl:when>
                                                    <xsl:when test="$afhandeling = 'kopieer'">
                                                        <xsl:sequence select="$config"/><!-- may contain notes -->
                                                        <copy/>
                                                    </xsl:when>
                                                    <xsl:when test="$afhandeling = 'verwijder'">
                                                        <xsl:sequence select="$config"/><!-- may contain notes -->
                                                        <remove/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:sequence select="imf:local-error($bericht,'Geen bekende afhandeling opgegeven: [1]',($afhandeling))"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </instructions>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </bericht>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:local-error($bericht,'Berichttype mist het berichtnamen attribuut: [1]',($bericht/imvert:name/@original))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="imf:get-tagged-value">
        <xsl:param name="this"/>
        <xsl:param name="tv-name"/>
        <xsl:sequence select="$this/imvert:tagged-values/imvert:tagged-value[imvert:name = $tv-name]/imvert:value"/>
    </xsl:function>
    
    <xsl:function name="imf:process-tv-config" as="element()*">
        <xsl:param name="this"/>
        <xsl:param name="config-tv-name"/>
        <xsl:param name="berichtnamen"/>
        
        <xsl:variable name="config-tv-value" select="imf:get-tagged-value($this,$config-tv-name)"/>
        <!-- herken notitieregels. -->
        <xsl:analyze-string select="concat($config-tv-value,'[newline]')" regex="(.*?)\[newline\]">
            <xsl:matching-substring>
                <xsl:variable name="line" select="regex-group(1)"/>
                <xsl:choose>
                    <xsl:when test="starts-with($line,'#')">
                        <note>
                            <xsl:value-of select="normalize-space(substring-after($line,'#'))"/>
                        </note>
                    </xsl:when>
                    <xsl:when test="$config-tv-name = 'config-berichttypes'">
                        <!-- 
                            format:  berichttype: berichttype-nummering
                            example: standaard: 01 02 03 07   
                        -->
                        <xsl:analyze-string select="$line" regex="{$regex-repertoire}">
                            <xsl:matching-substring>
                                <xsl:variable name="berichtnaam" select="regex-group(1)"/>
                                <xsl:variable name="repertoire" select="regex-group(2)"/>
                                <xsl:choose>
                                    <xsl:when test="$berichtnamen = $berichtnaam">
                                        <berichtcodes>
                                            <xsl:sequence select="imf:create-output-element('berichtnaam',$berichtnaam,())"/>
                                            <xsl:for-each select="tokenize($repertoire,'\s+')">
                                                <xsl:sequence select="imf:create-output-element('code',.,())"/>
                                                <!-- validate -->
                                                <xsl:variable name="msg" as="xs:string?">
                                                    <xsl:choose>
                                                        <xsl:when test="xs:integer(.) gt 12 or xs:integer(.) lt 1">
                                                            <xsl:value-of select="concat('Onmogelijk berichttype: ', .)"/>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:sequence select="imf:local-error($this,$msg,())"/>
                                            </xsl:for-each>
                                        </berichtcodes>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="imf:local-error($this,'Geen bekende berichtnaam: [1]', $berichtnaam)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:sequence select="imf:local-error($this,'Fout in regel: [1]', .)"/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- 
                            format:  berichttype: name = value (context)
                            example: standaard: mult = 0 (NATUURLIJK PERSOON.is ouder van)   
                        -->
                        <xsl:analyze-string select="$line" regex="{$regex-instruction}">
                            <xsl:matching-substring>
                                <xsl:variable name="berichttype" select="regex-group(1)"/>
                                <xsl:variable name="level" select="regex-group(2)"/>
                                <xsl:variable name="value" select="regex-group(3)"/>
                                <xsl:variable name="context-source" select="regex-group(5)"/>
                                <xsl:variable name="context-relation" select="regex-group(6)"/>
                                <instruct>
                                    <xsl:sequence select="imf:create-output-element('level',$level,())"/>
                                    <xsl:sequence select="imf:create-output-element('context-source',$context-source,())"/>
                                    <xsl:sequence select="imf:create-output-element('context-relation',$context-relation,())"/>
                                    <xsl:sequence select="imf:create-output-element('berichtnaam',$berichttype,())"/>
                                    <xsl:sequence select="imf:create-output-element('value',$value,())"/>
                                    <!-- validate -->
                                    <xsl:variable name="context-source-class" select="imf:get-class-by-name('Model',$context-source,true())"/>
                                    <xsl:variable name="msg" as="xs:string?">
                                        <xsl:choose>
                                            <xsl:when test="normalize-space($context-source) and empty($context-source-class)">
                                                <xsl:value-of select="concat('No such source: &quot;',$context-source,'&quot;')"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:if test="exists($msg)">
                                        <xsl:sequence select="imf:msg('ERROR', $msg)"/>
                                        <error>
                                            <xsl:value-of select="$msg"/>
                                        </error>
                                    </xsl:if>
                                </instruct>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:variable name="msg" select="concat('Fout in regel; ', .)"/>
                                <xsl:sequence select="imf:msg('ERROR',$msg)"/>
                                <error>
                                    <xsl:value-of select="$msg"/>
                                </error>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
     
    </xsl:function>    
  
    <xsl:function name="imf:local-error" as="element(error)?">
        <xsl:param name="this"/>
        <xsl:param name="msg"/>
        <xsl:param name="info"/>
        <xsl:if test="normalize-space($msg)">
            <xsl:sequence select="imf:msg($this,'ERROR',imf:msg-insert-parms($msg,$info),())"/>
            <error>
                <xsl:value-of select="imf:msg-insert-parms(concat('[1] - ', $msg),imf:get-construct-name($this))"/>
            </error>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
