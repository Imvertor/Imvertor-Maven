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
         Reporting stylesheet for the reporting step itself.
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:template match="/config">
        <xsl:variable name="messages" select="$configuration//messages/message[src='XMI1Imvert']"/>
        <xsl:variable name="errors" select="$messages[type=('FATAL','ERROR')]"/>
        <xsl:variable name="office-filename" select="imf:get-config-string('appinfo','office-documentation-filename')"/>
        <xsl:variable name="remote-url" select="imf:get-config-string('properties','giturl-resolved',())"/>
        <report>
            <step-display-name>Office compiler</step-display-name>
            <status>
                <xsl:sequence select="if (count($errors) eq 0) then 'succeeds' else 'fails'"/>
            </status>
            <summary>
                <info label="Office documentation">
                    <xsl:sequence select="imf:report-key-label('Saved as','appinfo','office-documentation-filename')"/>
                </info>
            </summary>
            <page>
                <title>Office documentation</title>
                <intro/>
                <content>
                    <div>
                        <xsl:choose>
                            <xsl:when test="$remote-url">
                                <p>This documentation is intended to be published remotely. Please check 
                                    <a href="{$remote-url}" target="remote-url">
                                        <xsl:value-of select="$remote-url"/>
                                    </a>
                                </p>
                            </xsl:when>
                            <xsl:otherwise>
                                <p>This documentation is packaged for further processing.</p>
                            </xsl:otherwise>
                        </xsl:choose>
                        <p>Packaged documentation files are <a href="{concat('../../cat/',$office-filename,'.html')}">here</a>.</p>
                    </div>
                    <xsl:if test="false()">
                        <div>
                            <h1>VOORBEELD WEERGAVE VAN ALLE XML COMPARES</h1>
                            <div>
                                <h2>VOORBEELD WEERGAVE VAN ÉÉN XML COMPARE</h2>
                                <div class="xcomp">
                                    <div class="e">
                                        <div>
                                            <span class="b" onclick="click(event)">-</span>
                                            <span class="m">&lt;</span>
                                            <span class="en">model</span>
                                            <w>
                                                <span class="an">identifier</span>
                                                <span class="m">="</span>
                                                <span class="avd">id-7ac0592f-72c0-4c19-8894-d67a8d109282</span>
                                                <span class="arrow"> ⇨ </span>
                                                <span class="avi">id-5395f4bb-65dc-4236-9a07-09020940f82e</span>
                                                <span class="m">"</span>
                                                <span class="an">xsi:schemaLocation</span>
                                                <span class="m">="</span>
                                                <span class="av">http://www.opengroup.org/xsd/archimate http://www.opengroup.org/xsd/archimate/archimate_v2p1.xsd http://purl.org/dc/elements/1.1/ http://dublincore.org/schemas/xmls/qdc/2008/02/11/dc.xsd</span>
                                                <span class="m">"</span>
                                            </w>
                                            <w>
                                                <span class="an">xmlns</span>
                                                <span class="m">="</span>
                                                <span class="av">http://www.opengroup.org/xsd/archimate</span>
                                                <span class="m">"</span>
                                                <span class="an">xmlns:dc</span>
                                                <span class="m">="</span>
                                                <span class="av">http://purl.org/dc/elements/1.1/</span>
                                                <span class="m">"</span>
                                                <span class="an">xmlns:xsi</span>
                                                <span class="m">="</span>
                                                <span class="av">http://www.w3.org/2001/XMLSchema-instance</span>
                                                <span class="m">"</span>
                                            </w>
                                            <span class="m">&gt;</span>
                                        </div>
                                        <div>
                                            <div class="e">
                                                <div>
                                                    <span class="b" onclick="click(event)">-</span>
                                                    <span class="m">&lt;</span>
                                                    <span class="en">metadata</span>
                                                    <span class="m">&gt;</span>
                                                </div>
                                                <div>
                                                    <div class="e">
                                                        <span class="m">&lt;</span>
                                                        <span class="en">schema</span>
                                                        <span class="m">&gt;</span>
                                                        <span class="t">
                                                            <span class="t">Dublin Core</span>
                                                        </span>
                                                        <span class="m">&lt;/</span>
                                                        <span class="en">schema</span>
                                                        <span class="m">&gt;</span>
                                                    </div>
                                                    <div class="e">
                                                        <span class="m">&lt;</span>
                                                        <span class="en">schemaversion</span>
                                                        <span class="m">&gt;</span>
                                                        <span class="t">
                                                            <span class="t">1.1</span>
                                                        </span>
                                                        <span class="m">&lt;/</span>
                                                        <span class="en">schemaversion</span>
                                                        <span class="m">&gt;</span>
                                                    </div>
                                                    <div>
                                                        <span class="m">&lt;/</span>
                                                        <span class="en">metadata</span>
                                                        <span class="m">&gt;</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="e">
                                                <span class="m">&lt;</span>
                                                <span class="en">name</span>
                                                <w>
                                                    <span class="an">xml:lang</span>
                                                    <span class="m">="</span>
                                                    <span class="av">nl</span>
                                                    <span class="m">"</span>
                                                </w>
                                                <span class="m">&gt;</span>
                                                <span class="t">
                                                    <span class="t">GEMMA kennismodel</span>
                                                </span>
                                                <span class="m">&lt;/</span>
                                                <span class="en">name</span>
                                                <span class="m">&gt;</span>
                                            </div>
                                            <div class="e">
                                                <span class="m">&lt;</span>
                                                <span class="en">documentation</span>
                                                <w>
                                                    <span class="an">xml:lang</span>
                                                    <span class="m">="</span>
                                                    <span class="av">nl</span>
                                                    <span class="m">"</span>
                                                </w>
                                                <span class="m">&gt;</span>
                                                <span class="t">
                                                    <span class="t">Het kennismodel toont de in de GEMMA gebruikte ArchiMate concepten.</span>
                                                    <span class="del"> De modelleerafspraken zijn vervolgens een weergave van de opbouw van de GEMMA architectuurrepository en toont de verbinding met pakketten en koppelingen in het exportbestand van de Softwarecatalogus.</span>
                                                </span>
                                                <span class="m">&lt;/</span>
                                                <span class="en">documentation</span>
                                                <span class="m">&gt;</span>
                                            </div>
                                            <div class="e">
                                                <div>
                                                    <span class="b" onclick="click(event)">-</span>
                                                    <span class="m">&lt;</span>
                                                    <span class="en">properties</span>
                                                    <span class="m">&gt;</span>
                                                </div>
                                                <div>
                                                    <div class="del">
                                                        <div class="e">
                                                            <div>
                                                                <span class="b" onclick="click(event)">-</span>
                                                                <span class="m">&lt;</span>
                                                                <span class="en">property</span>
                                                                <w>
                                                                    <span class="an">identifierref</span>
                                                                    <span class="m">="</span>
                                                                    <span class="av">KNG_DocRemark</span>
                                                                    <span class="m">"</span>
                                                                </w>
                                                                <span class="m">&gt;</span>
                                                            </div>
                                                            <div>
                                                                <div class="e">
                                                                    <span class="m">&lt;</span>
                                                                    <span class="en">value</span>
                                                                    <w>
                                                                        <span class="an">xml:lang</span>
                                                                        <span class="m">="</span>
                                                                        <span class="av">nl</span>
                                                                        <span class="m">"</span>
                                                                    </w>
                                                                    <span class="m">&gt;</span>
                                                                    <span class="t">
                                                                        <span class="t"> 21-11-2016 Landelijke voorzieningen schrijven standaard voor, SWC leidt hier de in gebruik zijnde versies van af 12-10-2016 Kennismodel voor Softwarecatalogus ArchiMate export </span>
                                                                    </span>
                                                                    <span class="m">&lt;/</span>
                                                                    <span class="en">value</span>
                                                                    <span class="m">&gt;</span>
                                                                </div>
                                                                <div>
                                                                    <span class="m">&lt;/</span>
                                                                    <span class="en">property</span>
                                                                    <span class="m">&gt;</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="e">
                                                        <div>
                                                            <span class="b" onclick="click(event)">-</span>
                                                            <span class="m">&lt;</span>
                                                            <span class="en">property</span>
                                                            <w>
                                                                <span class="an">identifierref</span>
                                                                <span class="m">="</span>
                                                                <span class="av">KNG_ModelPublish</span>
                                                                <span class="m">"</span>
                                                            </w>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <h2>VOORBEELD WEERGAVE VAN NOG EEN XML COMPARE</h2>
                                <div class="xcomp">
                                    <div class="e">
                                        <div>
                                            <span class="b" onclick="click(event)">-</span>
                                            <span class="m">&lt;</span>
                                            <span class="en">model</span>
                                            <w>
                                                <span class="an">identifier</span>
                                                <span class="m">="</span>
                                                <span class="avd">id-7ac0592f-72c0-4c19-8894-d67a8d109282</span>
                                                <span class="arrow"> ⇨ </span>
                                                <span class="avi">id-5395f4bb-65dc-4236-9a07-09020940f82e</span>
                                                <span class="m">"</span>
                                                <span class="an">xsi:schemaLocation</span>
                                                <span class="m">="</span>
                                                <span class="av">http://www.opengroup.org/xsd/archimate http://www.opengroup.org/xsd/archimate/archimate_v2p1.xsd http://purl.org/dc/elements/1.1/ http://dublincore.org/schemas/xmls/qdc/2008/02/11/dc.xsd</span>
                                                <span class="m">"</span>
                                            </w>
                                            <w>
                                                <span class="an">xmlns</span>
                                                <span class="m">="</span>
                                                <span class="av">http://www.opengroup.org/xsd/archimate</span>
                                                <span class="m">"</span>
                                                <span class="an">xmlns:dc</span>
                                                <span class="m">="</span>
                                                <span class="av">http://purl.org/dc/elements/1.1/</span>
                                                <span class="m">"</span>
                                                <span class="an">xmlns:xsi</span>
                                                <span class="m">="</span>
                                                <span class="av">http://www.w3.org/2001/XMLSchema-instance</span>
                                                <span class="m">"</span>
                                            </w>
                                            <span class="m">&gt;</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>      
                    </xsl:if>
                  
                </content>
            </page>
        </report>
        
    </xsl:template>

</xsl:stylesheet>
