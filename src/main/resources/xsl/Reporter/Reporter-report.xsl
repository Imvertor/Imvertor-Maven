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
    
    <xsl:output method="html" indent="no"/>
    
    <!--
        Compile the full documentation on the run by accessing the reports of each of the previous step.
        Context document is configuration file
        This stylesheet generates a final Report.xml file, but in the process builds HTML result files as required.
    -->
    
    <xsl:variable name="doc-folder-path" select="imf:get-config-string('system','work-doc-folder-path')"/>
    <xsl:variable name="doc-folder-url" select="imf:filespec($doc-folder-path,'U')[2]"/>

    <xsl:variable name="no-subpath">
        <xsl:variable name="rtry" as="xs:string*">
            <xsl:value-of select="imf:get-config-string('appinfo','project-name','project?')"/>
            <xsl:value-of select="imf:get-config-string('appinfo','application-name','model?')"/>
            <xsl:value-of select="imf:get-config-string('appinfo','release','release?')"/>
        </xsl:variable> 
        <xsl:value-of select="string-join($rtry,'/')"/>
    </xsl:variable>
    
    <xsl:variable name="status" select="if (imf:get-config-string('appinfo','error-count') = '0' and imf:get-config-string('appinfo','warning-count') = '0') then 'okay' else 'not-okay'"/>
    
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
                    <xsl:variable name="step-result-file-spec" select="imf:filespec($step-result-file-path,'EU')" />
                    <xsl:variable name="step-result-file-exists" select="$step-result-file-spec[5] = 'E'"/>
                    <xsl:variable name="step-result-file-url" select="$step-result-file-spec[2]"/>
                    <xsl:if test="$step-result-file-exists">
                        <xsl:sequence select="imf:document($step-result-file-url,true())/report/*"/>
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
                    <frame src="home/index.html" name="contents" title="Contents"/>
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
                    <xsl:sequence select="imf:create-report-page-header('IMVERTOR Processing report')"/>
                    <ol>
                        <li>
                            <a href="../home/index.html" target="contents">
                                Home
                            </a>
                        </li>
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
        
        
        <!-- create a home page-->
        <xsl:result-document href="{$doc-folder-url}/home/index.html">
            <html>
                <xsl:call-template name="create-html-head">
                    <xsl:with-param name="title" select="'Imvert - Home'"/>
                    <xsl:with-param name="table-ids" select="()"/>
                </xsl:call-template>
                <body>
                    <div class="home">
                        <xsl:sequence select="imf:create-report-home-header('IMVERTOR Processing report')"/>
                        <p>Created by:
                            <xsl:value-of select="imf:get-config-string('run','version')"/>
                        </p>
                        <xsl:if test="$job-id">
                            <p>Job: 
                                <a href="{$dashboard-reference}" target="imvertorDashboard">
                                    <xsl:value-of select="$job-id"/>
                                </a>, user <xsl:value-of select="$user-id"/></p>  
                        </xsl:if>
                        <p class="processing-status-{$status}">
                            <xsl:value-of select="imf:get-config-string('appinfo','status-message')"/>
                        </p>
                        <!--TODO
                        <p>
                            Check the <a href="../readme/index.html">"readme" section</a> for more information about the contents of this release.
                        </p>
                        -->
                    </div>
                </body>
            </html>
        </xsl:result-document>
        
        <!-- create a full overview page from all summaries -->
        <xsl:result-document href="{$doc-folder-url}/overview/index.html">
            <html>
                <xsl:call-template name="create-html-head">
                    <xsl:with-param name="title" select="'Imvert - Overview'"/>
                    <xsl:with-param name="table-ids" select="'table-overview'"/>
                </xsl:call-template>
                <body>
                    <h1>
                        Overview
                    </h1>
                    <table class="tablesorter"> 
                        <xsl:variable name="rows" as="element(tr)*">
                            <xsl:apply-templates select="$reports/summary" mode="summary"/>
                        </xsl:variable>
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,'step:20,aspect:20,value:60','table-overview')"/>
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
        <xsl:param name="table-ids" as="xs:string*"/> <!-- pass IDs for each table that must be sorted -->
        <head>
            <title>
                <xsl:value-of select="$title"/>
            </title>
            <xsl:for-each select="tokenize(imf:get-config-parameter('web-css'),';')[normalize-space()]">
                <link href="{normalize-space(.)}" rel="stylesheet"/>
            </xsl:for-each>
            <xsl:for-each select="tokenize(imf:get-config-parameter('web-scripts'),';')[normalize-space()]">
                <script src="{normalize-space(.)}" type="text/javascript"/>
            </xsl:for-each>
            <!-- http://tablesorter.com/; get all tables that are have id run init script to make them sortable -->
            <xsl:if test="exists($table-ids)">
                <script>
                    $(function() { 
                    <xsl:for-each select="$table-ids">
                        $("#<xsl:value-of select="."/>").tablesorter(); 
                    </xsl:for-each>
                    });  
                </script>
            </xsl:if>
        </head>
    </xsl:template>   
    
    <xsl:template match="page" mode="toc">
        <li>
            <xsl:choose>
                <xsl:when test="content">
                    <a href="../{../step-name}-{count(preceding-sibling::page)}/index.html" target="contents">
                        <xsl:value-of select="title"/>
                    </a>
                </xsl:when>
                <xsl:when test="content-ref">
                    <a href="{content-ref/@href}" target="contents">
                        <xsl:value-of select="title"/>
                    </a>
                </xsl:when>
            </xsl:choose>
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
        <xsl:choose>
            <xsl:when test="content">
                <xsl:result-document href="{$doc-folder-url}/{../step-name}-{count(preceding-sibling::page)}/index.html">
                    <html>
                        <xsl:call-template name="create-html-head">
                            <xsl:with-param name="title" select="concat('Imvert - ', ../step-display-name)"/>
                            <xsl:with-param name="table-ids" select=".//table/@id"/>
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
            </xsl:when>
            <xsl:when test="content-ref">
                <!-- nothing, points to different location -->
            </xsl:when>
        </xsl:choose>
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
        
    <xsl:function name="imf:create-report-page-header">
        <xsl:param name="title"/>
        <img src="{imf:get-config-parameter('web-logo')}" class="overview-logo"/>
        <div class="overview-title">
            <xsl:value-of select="$title"/>
        </div>
        <div  class="overview">
            <p>
                <xsl:value-of select="imf:get-config-string('appinfo','subpath',$no-subpath)"/>
            </p>  
        </div>
    </xsl:function>
    
    <xsl:function name="imf:create-report-home-header">
        <xsl:param name="title"></xsl:param>
        <img src="{imf:get-config-parameter('web-logo-big')}" class="home-logo"/>
        <div class="home-title">
            <xsl:value-of select="$title"/>
        </div>
        <div class="home-block">
            <p class="subpath">
                <xsl:value-of select="imf:get-config-string('appinfo','subpath',$no-subpath)"/>
            </p>
            <p>
                <xsl:value-of select="imf:get-config-string('appinfo','original-project-name')"/>
            </p>
            <p class="app">
                <xsl:value-of select="imf:get-config-string('appinfo','original-application-name')"/>
            </p>
            <p>
                Release <xsl:value-of select="imf:get-config-string('appinfo','release')"/>,
                version <xsl:value-of select="imf:get-config-string('appinfo','version')"/> at phase
                <xsl:value-of select="imf:get-config-string('appinfo','phase')"/>
                <br></br>
                <xsl:value-of select="imf:get-config-string('appinfo','error-count')"/> errors,
                <xsl:value-of select="imf:get-config-string('appinfo','warning-count')"/> warnings.
            </p>  
            <p>
                Generated at
                <xsl:value-of select="imf:format-dateTime(current-dateTime())"/>
            </p>  
        </div>
    </xsl:function>
</xsl:stylesheet>
