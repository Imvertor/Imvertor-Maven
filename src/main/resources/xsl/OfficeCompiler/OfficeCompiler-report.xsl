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
        <xsl:variable name="msword-filename" select="imf:get-config-string('appinfo','msword-documentation-filename')"/>
        <xsl:variable name="respec-filename" select="imf:get-config-string('appinfo','full-respec-documentation-filename')"/>
        
        <xsl:variable name="model-respec-filename" select="concat(imf:get-config-string('appinfo','application-name'),'.html')"/>
        
        <xsl:variable name="remote-url" select="imf:get-config-string('properties','giturl-resolved',())"/>
        <report>
            <step-display-name>Model documentation</step-display-name>
            <status>
                <xsl:sequence select="if (count($errors) eq 0) then 'succeeds' else 'fails'"/>
            </status>
            <summary>
                <info label="MsWord documentation">
                    <xsl:sequence select="imf:report-key-label('Saved as','appinfo','office-documentation-filename')"/>
                </info>
                <info label="Respec documentation">
                    <xsl:sequence select="imf:report-key-label('Saved as','appinfo','respec-documentation-filename')"/>
                </info>
            </summary>
            <page>
                <title>Model documentation</title>
                <intro>
                    <p>This is the documentation on the model. It contains a "catalog" of all constructs the make up the model.</p>
                    <xsl:choose>
                        <xsl:when test="$remote-url">
                            <p>The model documentation is published remotely by Imvertor. Please check 
                                <a href="{$remote-url}" target="remote-url">
                                    <xsl:value-of select="$remote-url"/>
                                </a>. 
                            </p>
                            <p>However, for archival purposes the documentation files are also packaged in this Imvertor model release.</p>
                            <p><strong>The preview supplied may show flaws as the intended publication environment is not available here.</strong></p>
                        </xsl:when>
                        <xsl:otherwise>
                            <p>The model documentation is packaged in this Imvertor model release for further processing.</p>
                        </xsl:otherwise>
                    </xsl:choose>
                </intro>
                <content>
                    <div>
                        <xsl:if test="$msword-filename">
                            <div>
                                <h1>MsWord documentation</h1>
                                <p>The HTML document may be opened in MsWord. 
                                    In order to apply specific styles to the markup, the contents of the MsWord document may be copied to the clipboard, 
                                    and pasted into a template document, or styles from a template document may be applied to the just created MsWord document.</p>
                                <p>Packaged documentation files are <a href="{concat('../../cat/',$msword-filename)}">here</a>.</p>
                            </div>
                        </xsl:if>
                        <xsl:if test="$respec-filename">
                            <div>
                                <h1>Respec documentation</h1>
                                <p>Packaged documentation files are <a href="{concat('../../cat/',$respec-filename)}">here</a>.</p>
                            </div>
                        </xsl:if>
                        <div>
                            <h1>External documentation</h1>
                            <p>Packaged externally compiled documentation files may be found <a href="{concat('../../cat/',$model-respec-filename)}">here</a>.</p>
                            <p><i>Please consult your Imvertor provider if the link does not resolve to a valid HTML document.</i></p>
                        </div>

                    </div>
                </content>
            </page>
          
        </report>
        
    </xsl:template>

</xsl:stylesheet>
