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
    
    <xsl:variable name="errors" select="xs:integer(imf:get-config-string('appinfo','compliancy-error-count','-1'))"/>
    
    <xsl:template match="/config">
        <report>
            <step-display-name>Compliancy extractor</step-display-name>
            <summary>
                <!-- general -->
                <info label="Comply extractor">
                    <xsl:sequence select="imf:report-label('Exceptions',if ($errors eq -1) then 'No validation performed' else $errors)"/>
                </info>
             </summary>
            <xsl:if test="$errors gt 0">
                <page>
                    <title>Compliancy errors</title>
                    <info>
                        <xsl:value-of select="concat('(', $errors,' exceptions, ')"/>
                    </info>
                    <intro>
                        <p>This is the overview of all exceptions (errors and warnings) on processing the compliancy test instances generated. 
                            When a file has XML exceptions, STP will not be tested.</p>
                        <p>
                            <xsl:value-of select="if ($errors eq -1) then 'No validation performed.' else concat($errors, ' exceptions for this run.')"/> 
                        </p>
                    </intro>
                    <xsl:if test="$errors gt 0">
                        <content>
                            <div>
                                <table id="table-errors" class="tablesorter">
                                    <col style="width:10%"/>
                                    <col style="width:20%"/>
                                    <col style="width:70%"/>
                                    <thead>
                                        <tr class="tableHeader">
                                            <th>Type</th>
                                            <th>File</th>
                                            <th>Message</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="$messages[type='COMPLY']">
                                            <xsl:variable name="parts" as="xs:string*">
                                                <xsl:analyze-string select="text" regex="^(STP:)?\((.*?)\)(.*)$">
                                                    <xsl:matching-substring>
                                                        <xsl:value-of select="regex-group(1)"/>
                                                        <xsl:value-of select="regex-group(2)"/>
                                                        <xsl:value-of select="regex-group(3)"/>
                                                    </xsl:matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:variable>
                                            <xsl:if test="$parts[2]">
                                                <tr class="{type}">
                                                    <td>
                                                        <xsl:value-of select="if ($parts[1] eq 'STP:') then 'STP' else 'XML'"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="$parts[2]"/>
                                                    </td>
                                                    <td>
                                                        <xsl:choose>
                                                            <xsl:when test="$parts[1] eq 'STP:'">
                                                                <xsl:sequence select="imf:render-STP-message($parts[3])"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:sequence select="imf:render-XML-message($parts[3])"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </content>
                    </xsl:if>
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
