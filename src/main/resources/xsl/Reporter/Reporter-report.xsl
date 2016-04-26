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
    
    <!--
        Compile the full documentation on the run by accessing the reports of each of the previous step.
        Context document is configuration file
        This stylesheet generates a final Report.xml file, but in the process builds HTML result files as required.
    -->
    
    <xsl:variable name="doc-folder-path" select="imf:get-config-string('system','work-doc-folder-path')"/>
    <xsl:variable name="doc-folder-url" select="imf:filespec($doc-folder-path)[2]"/>
    
    <?x
    <xsl:variable name="cfg-owner-file-path" select="concat(imf:get-config-string('system','etc-folder-path'),'/common/owners.xml')"/>
    <xsl:variable name="cfg-owner-file-url" select="imf:filespec($cfg-owner-file-path)[2]"/>
    <xsl:variable name="cfg-owner-file-doc" select="imf:document($cfg-owner-file-url)"/>
    
    <xsl:variable name="owner" select="imf:get-config-string('cli','owner')"/>
    
    <xsl:variable name="owner-info" select="$cfg-owner-file-doc//project-owner[name=$owner]"/>
    ?>
    
    <xsl:template match="/config">
        
        <!-- compile complete set of reports from all steps -->
        <xsl:variable name="path" select="$configuration/config/system/work-folder-path"/>
        <xsl:variable name="reports" as="element()*">
            <xsl:for-each select="$configuration/config/steps/step-name[. ne 'Reporter']">
                <report>
                    <step-name>
                        <xsl:value-of select="."/>
                    </step-name>
                    <xsl:variable name="step-result-file-path" select="concat($path, '/rep/', ., '-report.xml')"/>
                    <xsl:variable name="step-result-file-spec" select="imf:filespec($step-result-file-path)" />
                    <xsl:variable name="step-result-file-exists" select="$step-result-file-spec[5] = 'E'"/>
                    <xsl:variable name="step-result-file-url" select="$step-result-file-spec[2]"/>
                    <xsl:if test="$step-result-file-exists">
                        <xsl:sequence select="imf:document($step-result-file-url)/report/*"/>
                    </xsl:if>       
                </report>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- create frameset -->
        <xsl:result-document href="{$doc-folder-url}/index.html">
            <html>
                <xsl:call-template name="create-html-head">
                    <xsl:with-param name="title" select="concat('Imvert - ', imf:get-config-string('cli','application','Unknown application'))"/>
                </xsl:call-template>
                <frameset cols="20%,80%" title="Imvertor documentation">
                    <frame src="toc/index.html" name="toc" title="Table of contents"/>
                    <frame src="overview/index.html" name="contents" title="Contents"/>
                    <noframes>
                        <h2>Frame Alert</h2>
                        <p>This document is designed to be viewed using the frames feature. If you see this message, you are using a non-frame-capable web client.</p>
                    </noframes>
                </frameset>
            </html>      
        </xsl:result-document>
        
        <!-- create toc -->
        <xsl:result-document href="{$doc-folder-url}/toc/index.html">
            <html>
                <xsl:call-template name="create-html-head">
                    <xsl:with-param name="title" select="'Imvert - TOC'"/>
                </xsl:call-template>
                <body>
                    <img src="{imf:get-config-parameter('web-logo')}"/>
                    <h1>Processing report</h1>
                    <p>
                        <xsl:value-of select="imf:get-config-string('run','version')"/>
                    </p>
                    <b>
                        <xsl:value-of select="imf:get-config-string('appinfo','status-message')"/>
                    </b>
                    <ol>
                        <li>
                            <a href="../overview/index.html" target="contents">
                                Overview
                            </a>
                        </li>
                        <xsl:apply-templates select="$reports/page" mode="toc"/>
                    </ol>
                </body>
            </html>
        </xsl:result-document>
        
        <!-- create a full overview page from all summaries -->
        <xsl:result-document href="{$doc-folder-url}/overview/index.html">
            <html>
                <xsl:call-template name="create-html-head">
                    <xsl:with-param name="title" select="'Imvert - Overview'"/>
                </xsl:call-template>
                <body>
                    <h1>Overview</h1>
                    <table>
                        <thead>
                            <tr class="tableHeader">
                                <td>Step</td>
                                <td>Aspect</td>
                                <td>Value</td>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:apply-templates select="$reports/summary" mode="summary"/>
                        </tbody>
                    </table>
                </body>
            </html>
        </xsl:result-document>
        
        <xsl:variable name="other-messages" select="messages/message"/> <!--TODO herken binnen de meldingn de niet-validatie-meldingen  -->
        <xsl:variable name="other-errors" select="$other-messages"/>
        <xsl:variable name="other-warnings" select="$other-messages"/>

        <xsl:if test="($other-errors + $other-warnings) gt 0">
            <!--TODO samenbrengen in een lijst van fouten, anders dan validatiefouten... -->
            
        </xsl:if>
        
        <!-- create report pages -->
        <xsl:apply-templates select="$reports/page" mode="content"/>
        
        <!-- and send the xml to the "report" for debugging puposes. -->
        <reports>
            <xsl:sequence select="$reports"/>
        </reports>
    </xsl:template>
    
    <!-- default -->
    <xsl:template match="*|text()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="create-html-head">
        <xsl:param name="title"/>
        <head>
            <title>
                <xsl:value-of select="$title"/>
            </title>
            <link href="{imf:get-config-parameter('web-css')}" rel="stylesheet"/>
        </head>
    </xsl:template>   
    
    <xsl:template match="page" mode="toc">
        <li>
            <a href="../{../step-name}-{count(preceding-sibling::page)}/index.html" target="contents">
                <xsl:value-of select="title"/>
            </a>
            <xsl:if test="exists(info)">
                <xsl:value-of select="concat(' ', info)"/>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="summary" mode="summary">
        <xsl:apply-templates select="info" mode="summary"/>
    </xsl:template>
    
    <xsl:template match="info" mode="summary">
        <tr>
            <td>
                <xsl:value-of select="../../step-display-name"/>
            </td>
            <td>
                <xsl:value-of select="@label"/>
            </td>
            <td>
                <xsl:apply-templates mode="content-body"/>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="page" mode="content">
        <xsl:result-document href="{$doc-folder-url}/{../step-name}-{count(preceding-sibling::page)}/index.html">
            <html>
                <xsl:call-template name="create-html-head">
                    <xsl:with-param name="title" select="concat('Imvert - ', ../step-display-name)"/>
                </xsl:call-template>
                <body>
                    <h1>
                        <xsl:value-of select="title"/>
                    </h1>
                    <xsl:apply-templates select="content" mode="content-toc"/>
                    <xsl:apply-templates select="content" mode="content-body"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!-- create a document-local TOC when more than one div -->
    <xsl:template match="content" mode="content-toc">
        <xsl:choose>
            <xsl:when test="div[2]">
                <p>Contents:</p>
                <ol>
                    <xsl:apply-templates select="div[h1]" mode="content-toc"/>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <!-- no TOC -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div" mode="content-toc">
        <li>
            <a href="#{generate-id(h1)}">
                <xsl:sequence select="h1/node()"/>
            </a>
        </li>
    </xsl:template>
    
    <!-- create a representation of the step report or summary values: mostly a copy but output may be enhanced. -->
    <xsl:template match="content" mode="content-body">
        <xsl:apply-templates select="*" mode="content-body"/>
    </xsl:template>
    
    <xsl:template match="h1" mode="content-body">
        <a name="{generate-id()}"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!-- default template for report body -->
    <xsl:template match="node()|@*" mode="content-body">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="content-body"/>
        </xsl:copy>
    </xsl:template>
        
</xsl:stylesheet>
