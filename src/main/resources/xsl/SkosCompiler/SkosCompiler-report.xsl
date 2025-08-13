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
    
    xmlns:sh="http://www.w3.org/ns/shacl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    version="3.0">
    
    <!-- 
         Reporting stylesheet for SHACL compiler
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
   
    <xsl:variable name="report" select="imf:document(imf:get-xparm('properties/RESULT_SHACL_VALIDATION_PATH'))"/>
    
    <xsl:variable name="validated" select="imf:boolean(imf:get-xparm('cli/validateskos'))"/>
    
    <xsl:variable name="error-descriptions" select="$report/rdf:RDF/rdf:Description[sh:resultSeverity/@rdf:resource = 'http://www.w3.org/ns/shacl#Violation' and sh:resultMessage]"/>
    
    <xsl:template match="/config">
        <report>
            <step-display-name>SKOS compiler</step-display-name>
            <status/>
            <summary>
                <info label="Status">
                    <xsl:sequence select="imf:report-key-label('Skos created','system','skos-created')"/>
                    <xsl:sequence select="imf:report-label('Skos validated',$validated)"/>
                    <xsl:sequence select="imf:report-label('Skos errors',count($error-descriptions))"/>
                </info>
            </summary>
            <xsl:if test="$validated">
                <page>
                    <title>SKOS validation</title>
                    <info>({count($error-descriptions)} errors)</info>
                    <xsl:choose>
                        <xsl:when test="$report">
                            <intro>
                                <p>SKOS errors are shown below.</p>
                            </intro>
                            <content>
                                <table class="tablesorter"> 
                                    <xsl:variable name="rows" as="element(tr)*">
                                        <xsl:apply-templates select="$error-descriptions" mode="validate"/>
                                    </xsl:variable>
                                    <xsl:sequence select="imf:create-result-table-by-tr($rows,'Focus:40,Error:60','table-skos')"/>
                                </table>
                            </content>
                        </xsl:when>
                        <xsl:otherwise>
                            <intro>
                                <p><i>No errors.</i></p>
                            </intro>
                        </xsl:otherwise>
                    </xsl:choose>
                </page>
            </xsl:if>
       </report>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="validate">
        <tr>
            <td>{sh:focusNode/@rdf:resource}</td>
            <td>
                <xsl:for-each select="sh:resultMessage">
                    <xsl:text>{.}</xsl:text>
                    <br/>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>    
    
</xsl:stylesheet>
