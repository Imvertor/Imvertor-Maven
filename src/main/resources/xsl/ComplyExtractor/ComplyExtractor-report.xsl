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
    
    <xsl:variable name="XML-errors" select="xs:integer(imf:get-config-string('appinfo','compliancy-error-count-XML','-1'))"/>
    <xsl:variable name="STP-errors" select="xs:integer(imf:get-config-string('appinfo','compliancy-error-count-STP','-1'))"/>
    
    <xsl:template match="/config">
        <report>
            <step-display-name>Compliancy extractor</step-display-name>
            <summary>
                <!-- general -->
                <info label="Comply extractor">
                    <xsl:sequence select="imf:report-label('XML errors',if ($XML-errors eq -1) then 'No validation performed' else $XML-errors)"/>
                    <xsl:sequence select="imf:report-label('STP errors',if ($STP-errors eq -1) then 'No validation performed' else $STP-errors)"/>
                </info>
             </summary>
            <xsl:if test="$XML-errors gt 0 or $STP-errors gt 0">
                <page>
                    <title>Compliancy errors</title>
                    <info>
                        <xsl:value-of select="concat('(', ($XML-errors + $STP-errors),' exceptions, ')"/>
                    </info>
                    <content>
                        <div>
                            <h1>Explanation</h1>
                            <p>This is the overview of all exceptions (errors and warnings) on processing the compliancy test instances generated.</p>
                            <p>Two checks are made on each instance: </p>
                            <ul>
                                <li>
                                    XML schema validation; results shown when some occur. 
                                    <xsl:value-of select="if ($XML-errors eq -1) then 'No validation performed.' else concat($XML-errors, ' exceptions for this run.')"/> 
                                </li>
                                <li>
                                    STP validation; results shown when some occur. 
                                    <xsl:value-of select="if ($STP-errors eq -1) then 'No validation performed.' else concat($STP-errors, ' exceptions for this run.')"/> 
                                    
                                </li>
                            </ul>
                        </div>
                        <xsl:if test="$XML-errors gt 0">
                            <div>
                                <h1>XML parse exceptions</h1>
                                <div>
                                    <table id="table-XML-parse-errors" class="tablesorter">
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
                                                            <xsl:sequence select="imf:render-XML-message($parts[2])"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </xsl:if>
                        <xsl:if test="$STP-errors gt 0">
                            <div>
                                <h1>STP exceptions</h1>
                                <div>
                                    <table id="table-STP-errors" class="tablesorter">
                                        <col style="width:30%"/>
                                        <col style="width:70%"/>
                                        <thead>
                                            <tr class="tableHeader">
                                                <th>File</th>
                                                <th>Message</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="$messages[type='COMPLYSTP']">
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
                                                            <xsl:sequence select="imf:render-STP-message($parts[2])"/>
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
    
    <!-- example: 	cvc-complex-type.2.1: Element 'StUF:datum' must have no character or element information item [children], because the type's content type is empty. -->
    <xsl:function name="imf:render-XML-message">
        <xsl:param name="message" as="xs:string"/>
        <xsl:analyze-string select="$message" regex="^(.*?):\s(.*?)$">
            <xsl:matching-substring>
                <xsl:variable name="error" select="true()"/>
                <span class="{if ($error) then 'ERROR' else 'WARNING'}">
                    <xsl:value-of select="if ($error) then 'ERROR' else 'WARNING'"/>
                    <xsl:value-of select="', ref: '"/>
                    <a target="w3c-source-reference" href="{concat('https://www.w3.org/TR/xmlschema11-1/#',substring-before(regex-group(1),'.'))}">
                        <xsl:value-of select="regex-group(1)"/>
                    </a>
                    <xsl:value-of select="concat('. Message: ',regex-group(2))"/>
                </span>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                UNRECOGNIZED MESSAGE: [<xsl:value-of select="$message"/>]
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
  
    <!-- example: E:STP00158:F:Couldn't define message type. -->
    <xsl:function name="imf:render-STP-message">
        <xsl:param name="message" as="xs:string"/>
        <xsl:analyze-string select="$message" regex="^(.):(.*?):(.*?):(.*)$">
            <xsl:matching-substring>
                <xsl:variable name="error" select="regex-group(1) = 'E'"/>
                <span class="{if ($error) then 'ERROR' else 'WARNING'}">
                    <xsl:value-of select="if ($error) then 'ERROR' else 'WARNING'"/>
                    <xsl:value-of select="concat(', code: ',regex-group(2))"/>
                    <xsl:value-of select="concat(', status: ',regex-group(3))"/>
                    <xsl:value-of select="concat('. Message: ',regex-group(4))"/>
                </span>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                UNRECOGNIZED REPLY: [<xsl:value-of select="$message"/>]
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
</xsl:stylesheet>
