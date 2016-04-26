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

    <xsl:param name="xsd-files-generated"/>
    <xsl:param name="etc-files-generated"/>
   
    <xsl:variable name="RELEASENAME" select="$application-package-release-name"/>
    <xsl:variable name="EAVERSION" select="/imvert:packages/imvert:exporter"/>
    <xsl:variable name="APPLICATIONNAME" select="$application-package-name"/>
    <xsl:variable name="CONTACTEMAIL" select="imf:get-config-string('cli','contactemail','(unspecified)')"/>
    <xsl:variable name="CONTACTURL" select="imf:get-config-string('cli','contacturl','(unspecified)')"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    Readme - <xsl:value-of select="$application-package-name"/>
                </title>
            </head>
            <body>
                <h2>
                    Readme - <xsl:value-of select="$application-package-name"/>
                </h2>
                <p> Dit is informatie bij de release met de naam <br/>
                    <b><xsl:value-of select="$RELEASENAME"/></b>. </p>
                <p> Dit bestand is opgebouwd uit de volgende folders: </p>
                <ul>
                    <li> Folder <a href="doc/index.html">/doc</a> bevat de systeemdocumentatie. Systeem documentatie betreft een rapportage van het aangeboden UML model vanuit het perspectief van de omzetting naar een XML schema. </li>
                    <xsl:if test="$uml-report-available = 'true'">
                        <li> Folder <a href="uml/report/index.html">/uml</a> bevat een d.m.v. <xsl:value-of select="$EAVERSION"/> samengesteld HTML report. Dit is informatie die ontleend is aan de applicatie en de applicaties waar het op teruggaat. </li>
                    </xsl:if>
                    <xsl:variable name="xsd-files" select="tokenize($xsd-files-generated,';')"/>
                    <xsl:if test="exists($xsd-files)">
                        <li> Folder /xsd bevat het gegenereerde schema, en de schema’s waar dit naar verwijst. Het gegenereerde schema voor de applicatie zelf zit in de folder met de naam "<xsl:value-of select="$APPLICATIONNAME"/>". Hierin zijn alle gegenereerde schema’s, per package, opgenomen in eigen folders met de naam van het package. Daarin is het (enige) schema geplaatst. Ook worden voor referentie elementen aparte schema’s opgesteld met de naam X-ref, wanneer van toepassing.
                            <pre>
                                <xsl:for-each select="$xsd-files">
                                    <xsl:if test="ends-with(.,'.xsd')">
                                        <a href="{.}"><xsl:value-of select="."/></a><br/>
                                    </xsl:if>
                                </xsl:for-each>
                            </pre>
                        </li>
                    </xsl:if>
                    <xsl:variable name="etc-files" select="tokenize($etc-files-generated,';')"/>
                    <xsl:if test="exists($etc-files)">
                        <li> Folder /etc bevat (afhankelijk van de status van de applicatie) het samengestelde EAP sjabloon, Imvert informatie over de historie, en Imvert informatie over het UML model. Wie een beetje handig is met XML kan deze bestanden oppikken en er geheel eigen reports op draaien. 
                            <pre>
                                <xsl:for-each select="$etc-files">
                                    <xsl:if test="contains(.,'.')">
                                        <a href="{.}"><xsl:value-of select="."/></a><br/>
                                    </xsl:if>
                                </xsl:for-each>
                            </pre>
                        </li>
                    </xsl:if>
                </ul>
                <xsl:if test="normalize-space($CONTACTURL)">
                    <p> Kijk verder op <a href="http://{$CONTACTURL}"><xsl:value-of select="$CONTACTURL"/></a>. </p>
                </xsl:if>
                <xsl:if test="normalize-space($CONTACTEMAIL)">
                    <p> Reacties op de vorm van deze release zijn welkom. Neem contact op met <a href="{concat('mailto:',$CONTACTEMAIL)}"><xsl:value-of select="$CONTACTEMAIL"/></a>. </p>
                </xsl:if>
                <hr/>
                <i><xsl:value-of select="imf:create-markers()"/></i>
            </body>
        </html>
    </xsl:template>

    <xsl:function name="imf:create-markers">
        <xsl:value-of select="string-join(
            ('#ph:', imf:get-config-string('appinfo','phase'), 
            '#ts:', imf:get-config-string('appinfo','task'), 
            '#er:', imf:get-config-string('appinfo','error-count'), 
            '#re:', imf:get-config-string('appinfo','release'), 
            '#dt:', imf:get-config-string('run','start'), 
            '#id:', imf:get-config-string('system','generation-id'), 
            '#'),'')"/>
    </xsl:function>
</xsl:stylesheet>
