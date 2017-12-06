<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 VNG/KING
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
    
    <xsl:variable name="messages" select="/config/messages/message"/>
    
    <xsl:variable name="xml-errors" select="xs:integer(imf:get-config-string('appinfo','compliancy-error-count-XML','-1'))"/>
    <xsl:variable name="wus-errors" select="xs:integer(imf:get-config-string('appinfo','compliancy-error-count-WUS','-1'))"/>
    
    <xsl:template match="/config">
        <report>
            <step-display-name>Compliancy extractor</step-display-name>
            <summary>
                <!-- general -->
                <info label="Comply extractor">
                    <xsl:sequence select="imf:report-label('XML errors',if ($xml-errors eq -1) then 'No validation performed' else $xml-errors)"/>
                    <xsl:sequence select="imf:report-label('WUS errors',if ($wus-errors eq -1) then 'No validation performed' else $wus-errors)"/>
                </info>
             </summary>
            <xsl:if test="$xml-errors gt 0 or $wus-errors gt 0">
                <page>
                    <title>Compliancy errors</title>
                    <content>
                        <xsl:if test="$xml-errors gt 0">
                            <div>
                                <h1>XML parse errors</h1>
                                <div>
                                    <table id="table-xml-parse-errors" class="tablesorter">
                                        <col style="width:30%"/>
                                        <col style="width:70%"/>
                                        <thead>
                                            <tr class="tableHeader">
                                                <th>File</th>
                                                <th>Message</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="$messages[type='COMPLYXML']">
                                                <xsl:variable name="parts" as="xs:string*">
                                                    <xsl:analyze-string select="text" regex="^\((.*?)\)(.*)$">
                                                        <xsl:matching-substring>
                                                            <xsl:value-of select="regex-group(1)"/>
                                                            <xsl:value-of select="regex-group(2)"/>
                                                        </xsl:matching-substring>
                                                    </xsl:analyze-string>
                                                </xsl:variable>
                                                <xsl:if test="$parts[1]">
                                                    <tr class="{type}">
                                                        <td>
                                                            <xsl:value-of select="$parts[1]"/>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="$parts[2]"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </xsl:if>
                        <xsl:if test="$wus-errors gt 0">
                            <div>
                                <h1>WUS messages</h1>
                                <div>
                                    <table id="table-wus-errors" class="tablesorter">
                                        <col style="width:30%"/>
                                        <col style="width:70%"/>
                                        <thead>
                                            <tr class="tableHeader">
                                                <th>File</th>
                                                <th>Message</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="$messages[type='COMPLYWUS']">
                                                <xsl:variable name="parts" as="xs:string*">
                                                    <xsl:analyze-string select="text" regex="^\((.*?)\)(.*)$">
                                                        <xsl:matching-substring>
                                                            <xsl:value-of select="regex-group(1)"/>
                                                            <xsl:value-of select="regex-group(2)"/>
                                                        </xsl:matching-substring>
                                                    </xsl:analyze-string>
                                                </xsl:variable>
                                                <xsl:if test="$parts[1]">
                                                    <tr class="{type}">
                                                        <td>
                                                            <xsl:value-of select="$parts[1]"/>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="$parts[2]"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </xsl:if>
                   </content>
                </page>
            </xsl:if>
           </report>
   </xsl:template>
    
</xsl:stylesheet>
