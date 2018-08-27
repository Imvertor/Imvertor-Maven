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
         Create the full HTML report, and compile a summary ("overview") from the individual steps.
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:include href="report-parameters.xsl"/>
    <xsl:include href="report-profiles.xsl"/>
    <xsl:include href="report-xsltcalls.xsl"/>
    
    <xsl:variable name="error-count" select="imf:get-config-string('appinfo','error-count')"/>
    <xsl:variable name="warning-count" select="imf:get-config-string('appinfo','warning-count')"/>
    <xsl:variable name="status-message" select="imf:get-config-string('appinfo','status-message')"/>
    
    <xsl:variable name="schema-error-count" select="imf:get-config-string('appinfo','schema-error-count','0')"/>
    <xsl:variable name="message-collapse-keys" select="tokenize(imf:get-config-string('appinfo','message-collapse-keys',''),'\s+')"/>
    
    <xsl:variable name="messages" select="/config/messages/message[type = ('FATAL','ERROR','WARNING','INFO','DEBUG','TRACE')]"/>
    
    <xsl:template match="/config">
        
        <report>
            <step-display-name>Run analysis</step-display-name>
            <summary>
                <info label="Status">
                    <xsl:sequence select="imf:report-label('Message', $status-message)"/>
                </info>
                <info label="Exceptions">
                    <xsl:sequence select="imf:report-label('Errors', $error-count)"/>
                    <xsl:sequence select="imf:report-label('Warnings', $warning-count)"/>
                    <xsl:sequence select="imf:report-label('Schema errors', $schema-error-count)"/>
                </info>
                <info label="Run">
                    <xsl:sequence select="imf:report-label('Debug mode', imf:get-config-string('cli','debugmode'))"/>
                    <xsl:sequence select="imf:report-label('Profile mode', imf:get-config-string('cli','profilemode'))"/>
                </info>
                <info label="Run">
                    <xsl:sequence select="imf:report-label('Job server path', $server-dashboard-path)"/>
                </info>
                
            </summary>
            <xsl:if test="exists($messages)">
                <!-- generate complete overview of all messages -->
                <page>
                    <title>Run analysis</title>
                    <info>
                        <xsl:value-of select="concat('(', $error-count,' errors, ', $warning-count, ' warnings)')"/>
                    </info>
                    <content>
                        <div>
                            <h1>Explanation</h1>
                            <p>This is the overview of all errors and warnings.</p>
                            <p>If hints are show, these are intended to support the user of this release to assess the impact on current implementations</p>
                            <xsl:if test="$schema-error-count ne '0'">
                                <p>
                                    This table also reports errors found when parsing the result XML schema(s). 
                                    These messages should not occur here, and indicate an error in the software.
                                    Please contact your system administrator, providing the orginal resources, as well as this report.
                                </p>
                            </xsl:if>
                        </div>
                        <xsl:if test="$messages/wiki = $message-collapse-keys">
                            <div>
                                <h1>Short overview</h1>
                                <p>This overview is compacted such that a number of message types is collapsed, showing only the first occurrence of the message.</p>
                                <p>The types of messages to be collapsed is defined as a runtime parameter.</p>
                                <table class="tablesorter"> 
                                    <xsl:variable name="rows" as="element(tr)*">
                                        <xsl:for-each-group select="$messages" group-by="wiki">
                                            <xsl:choose>
                                                <xsl:when test="current-grouping-key() = $message-collapse-keys">
                                                    <xsl:variable name="this" select="current-group()[1]"/>
                                                    <tr class="{$this/type}">
                                                        <td><xsl:value-of select="$this/type"/></td>
                                                        <td>
                                                            <xsl:value-of select="$this/stepconstruct"/>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="concat(count(current-group()), ' similar')"/>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="if ($this/steptext) then $this/steptext else $this/text"/>
                                                        </td>
                                                    </tr>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:for-each select="current-group()">
                                                        <xsl:variable name="this" select="."/>
                                                        <tr class="{$this/type}">
                                                            <td><xsl:value-of select="$this/type"/></td>
                                                            <td>
                                                                <xsl:value-of select="$this/stepconstruct"/>
                                                            </td>
                                                            <td> </td>
                                                            <td>
                                                                <xsl:value-of select="if ($this/steptext) then $this/steptext else $this/text"/>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each-group>
                                    </xsl:variable>
                                    <xsl:sequence select="imf:create-result-table-by-tr($rows,'Type:10,Element:30,Collapse:10,Message:50',concat('table-run-short-',position()))"/>
                                </table>
                            </div>
                        </xsl:if>
                        <div>
                            <h1>Full overview</h1>
                            <p>This overview is complete, showing all messages including the identifier of the construct and the stylesheet responsible for the message.</p>
                            <table class="tablesorter"> 
                                <xsl:variable name="rows" as="element(tr)*">
                                    <xsl:for-each select="$messages">
                                        <tr class="{type}">
                                            <td><xsl:value-of select="type"/></td>
                                            <td>
                                                <xsl:value-of select="stepconstruct"/>
                                                <xsl:text> </xsl:text>
                                                <span class="tid">
                                                    <xsl:value-of select="id"/>
                                                </span>
                                            </td>
                                            <td>
                                                <xsl:value-of select="if (steptext) then steptext else text"/>
                                                <xsl:text> </xsl:text>
                                                <span class="tid">
                                                    <xsl:value-of select="stepname"/>
                                                    /
                                                    <xsl:value-of select="src"/>
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:sequence select="imf:create-result-table-by-tr($rows,'Type:10,Element:30,Message:60',concat('table-run-full-',position()))"/>
                            </table>
                        </div>
                    </content>
                </page>
            </xsl:if>
            
            <xsl:if test="imf:get-config-string('cli','chain','ChainTranslateAndReport') = 'ChainTranslateAndReport'"> 
                <!-- TODO dit moet echt anders, afschermen van Imvertor functies van bijv. Regression functies -->
                
                <!-- generated overview of parameters -->
                <xsl:apply-templates select="." mode="doc-parameters"/>
                
                <!-- generated overview of xslt calls -->
                <xsl:apply-templates select="." mode="xslt-calls"/>
                
                <!-- generate profile info -->
                <xsl:variable name="profiles-doc-path" select="imf:get-config-string('system','profiles-doc')"/>
                <xsl:if test="normalize-space($profiles-doc-path)">
                    <xsl:variable name="profiles-doc" select="imf:document($profiles-doc-path,false())"/>
                    <xsl:apply-templates select="$profiles-doc/profiles" mode="doc-profiles"/>
                </xsl:if>                    
            </xsl:if>
            
        </report>
    </xsl:template>
    
</xsl:stylesheet>
