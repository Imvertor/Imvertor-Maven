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
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Reporting stylesheet for XSD compiler
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
   
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
    <xsl:variable name="document" select="imf:document(imf:get-config-string('properties','WORK_EMBELLISH_FILE'),true())"/>
    
    <xsl:variable name="selected-cols-names">
        entiteittype
        typeBericht
        berichtcode
        berichtnaam
        alles-opnemen?
        entiteit
        relatie
        attribuut
        kardinaliteit
        imvert-id
    </xsl:variable>
    <xsl:variable name="selected-cols" select="tokenize($selected-cols-names,'\s+')" as="xs:string+"/>
    
    <xsl:template match="/config">
        <xsl:variable name="schema-requested" select="imf:boolean(imf:get-config-string('cli','createxmlschema'))"/>
        <xsl:variable name="schemarules" select="imf:get-config-string('cli','schemarules')"/>
        <xsl:variable name="berichten-infoset" select="imf:document(imf:get-config-string('properties','RESULT_ENDPRODUCT_MSG_FILE_PATH'),false())"/>
        <report>
            <step-display-name>XML Schema compiler</step-display-name>
            <xsl:choose>
                <xsl:when test="not($schema-requested)">
                    <!-- skip -->
                </xsl:when>
                <xsl:when test="$schemarules = 'Kadaster'">
                    <status/>
                    <summary>
                        <xsl:sequence select="imf:report-label('Schemas', '(TODO Kadaster)')"/>
                    </summary>
                </xsl:when>
                <xsl:when test="$schemarules = 'BRO'">
                    <status/>
                    <summary>
                        <xsl:sequence select="imf:report-label('Schemas', '(TODO KKG)')"/>
                    </summary>
                </xsl:when>
                <xsl:when test="$schemarules = ('KINGUGM','KINGBSM', 'RWS-L', 'RWS-B')">
                    <xsl:variable name="berichten-table" select="imf:create-berichten-table($berichten-infoset/berichten/*)"/>
                    <status/>
                    <summary>
                        <info label="XML schema generation">
                            <xsl:sequence select="imf:report-label('Koppelvlak', concat(count($berichten-infoset/berichten/bericht),' berichtdefinities'))"/>
                        </info>
                    </summary>
                    <page>
                        <title>XML Schema info</title>
                        <content>
                            <div>
                                <div class="intro">
                                    <p>
                                        Deze tabel geeft een opsomming van eigenschappen die moeten worden opgenomen in de berichtschema's.
                                        Eigenschappen zijn attributen of relaties.
                                    </p><p>    
                                        Deze tabel moet als volgt worden gelezen.
                                    </p>
                                    <ul>
                                        <li>Als een <b>typeBericht</b> bericht wordt gemaakt en daarin komt een <b>entiteit</b> voor, 
                                            dan moet het <b>attribuut</b> worden opgenomen of verwijderd, 
                                            afhankelijk van de opgegeven <b>kardinaliteit</b>. 
                                            Dit kan een attribuut of een relatie betreffen.
                                            Voorbeeld: In standaard antwoordberichten is van een natuurlijk persoon de achternaam verplicht.</li>
                                        <li> Als de <b>kardinaliteit</b> 0 is, niet opnemen.
                                            Voorbeeld: in speciaal bericht x moet de voornaam worden verwijderd.</li>
                                        <li>Als een <b>relatie</b> is benoemd, dan moet de regel worden gevolgd alléén 
                                            als de genoemde <b>entiteit</b> deze inkomende relate heeft.
                                            Voorbeeld: van een natuurlijk persoon wordt alleen het BSN opgenomen als het als kind wordt opgenomen. 
                                        </li>
                                        <li>Als er een <b>berichtnaam</b> is opgegeven, dan betreft de regel alleen voor niet-standaard berichten,
                                            dus die deze specifieke naam hebben.</li>
                                        <li>De naam van het betreffende bericht is opgebouwd uit <b>entiteittype</b> en <b>berichtcode</b>, 
                                            eventueel uitgebreid met de <b>berichtnaam</b>. 
                                            Voorbeeld: npsLa01, npsLa01-alternatief.</li>
                                    </ul>
                                </div>
                                <table class="tablesorter"> 
                                    <xsl:variable name="header" select="string-join(for $c in $selected-cols[normalize-space(.)] return concat($c,':10'),',')"/>
                                    <xsl:variable name="rows" as="element(tr)*">
                                        <xsl:apply-templates select="$berichten-table//row" mode="workbook-berichtschema"/>
                                    </xsl:variable>
                                    <xsl:sequence select="imf:create-result-table-by-tr($rows,$header,'table-schema')"/>
                                </table>
                            </div>
                        </content>
                    </page>
                                    
                </xsl:when>
                <xsl:when test="$schemarules = 'ISO19136'">
                    <status/>
                    <summary>
                        <xsl:sequence select="imf:report-label('Schemas', '(TODO ISO19136)')"/>
                    </summary>
                </xsl:when>
                <xsl:when test="$schemarules = 'KadasterNEN3610'">
                    <status/>
                    <summary>
                        <xsl:sequence select="imf:report-label('Schemas', '(TODO KadasterNEN3610)')"/>
                    </summary>
                </xsl:when>
                <xsl:when test="$schemarules = 'RWS'">
                    <status/>
                    <summary>
                        <xsl:sequence select="imf:report-label('Schemas', '(TODO RWS)')"/>
                    </summary>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg('FATAL','No such schemarules: [1]', $schemarules)"/>
                </xsl:otherwise>
            </xsl:choose>
       </report>
    </xsl:template>
    
    
    <xsl:template match="row" mode="workbook-berichtschema">
        <tr>
            <xsl:apply-templates select="col[@naam = $selected-cols]" mode="#current"/>
        </tr>
    </xsl:template>

    <xsl:template match="col" mode="workbook-berichtschema">
        <td>
            <xsl:apply-templates mode="#current"/>
        </td>
    </xsl:template>
    
    <xsl:template match="node()" mode="workbook-berichtschema">
        <xsl:value-of select="."/>
    </xsl:template>
    
</xsl:stylesheet>
