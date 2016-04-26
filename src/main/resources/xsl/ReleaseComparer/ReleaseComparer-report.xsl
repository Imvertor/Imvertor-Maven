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
         Reporting stylesheet for the Release comparer
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
   
   <!--
        Delegated to "plugin" configuration for compare 
    -->
    <xsl:import href="compare/xsl/Imvert/Imvert2compare-report-horizontal.xsl"/>
   
    <xsl:template match="/config">
       
       <report>
            <step-display-name>Release comparison</step-display-name>
            
           <!-- for documentation release compare: -->
           
            <!-- get the docrelease name, if any -->
            <xsl:sequence select="imf:set-config-string('system','compare-label','documentation',true())"/>
            <xsl:variable name="documentation-release" select="imf:get-config-string('system', 'documentation-release', false())"/>
            <!-- determine the location of the report generated -->
            <xsl:variable name="report-doc" select="document(imf:file-to-url(imf:get-config-string('properties', 'WORK_COMPARE_LISTING_FILE')))"/>
            <!-- get the number of differences found in check against previous release -->
            <xsl:variable name="diff-count-doc" select="imf:get-config-string('appinfo', 'compare-differences-documentation')"/>
            
           <xsl:if test="normalize-space($documentation-release)">
                <xsl:if test="$diff-count-doc ne '0'">
                    <summary>
                        <info label="Documentation release">
                            <xsl:sequence select="imf:report-label('Release date', $documentation-release)"/>
                            <xsl:sequence select="imf:report-label('differences found', $diff-count-doc)"/>
                        </info>
                    </summary>
                    <xsl:for-each select="$report-doc">
                        <!-- set the context document -->
                        <xsl:call-template name="fetch-comparison-report">
                            <xsl:with-param name="title">Documentation release comparison</xsl:with-param>
                            <xsl:with-param name="info">
                                <xsl:value-of select="concat('(', count($report-doc//imvert:diffs/imvert:diff),' differences)')"/>
                            </xsl:with-param>
                            <xsl:with-param name="intro">
                                <p>
                                    This table show all unexpected differences between the previous version and the compiled version of the UML:
                                    <ul>
                                        <li>
                                            Control: the previous release.
                                        </li>
                                        <li>
                                            Test: the current release.  
                                        </li>
                                    </ul> 
                                </p>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
            
            <!-- for derivation compare (client/supplier): -->
            
            <!-- determine the location of the report generated -->
            <xsl:sequence select="imf:set-config-string('system','compare-label','derivation',true())"/>
            <xsl:variable name="report-derv" select="document(imf:file-to-url(imf:get-config-string('properties', 'WORK_COMPARE_LISTING_FILE')))"/>
            <!-- get the number of differences found in check against suppler -->
            <xsl:variable name="diff-count-derv" select="imf:get-config-string('appinfo', 'compare-differences-derivation')"/>
            
            <xsl:if test="$diff-count-derv ne '0'">
                <summary>
                    <info label="Derivation comparison">
                        <xsl:sequence select="imf:report-label('Differences found', $diff-count-derv)"/>
                    </info>
                </summary>
                <xsl:for-each select="$report-derv">
                    <!-- set the context document -->
                    <xsl:call-template name="fetch-comparison-report">
                        <xsl:with-param name="title">Derivation comparison</xsl:with-param>
                        <xsl:with-param name="info">
                            <xsl:value-of select="concat('(', count($report-derv//imvert:diffs/imvert:diff),' differences)')"/>
                        </xsl:with-param>
                        <xsl:with-param name="intro">
                            <p>  This table show all differences between the compiled version of the UML:
                                <ul>
                                    <li>
                                        Control: the supplier release.
                                    </li>
                                    <li>
                                        Test: the (current) client release.  
                                    </li>
                                </ul> 
                            </p>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
          
          <!-- for release compare: -->
          
          <!-- determine the location of the report generated -->
          <xsl:sequence select="imf:set-config-string('system','compare-label','release',true())"/>
          <xsl:variable name="report-release" select="document(imf:file-to-url(imf:get-config-string('properties', 'WORK_COMPARE_LISTING_FILE')))"/>
          <!-- get the number of differences found in check against suppler -->
          <xsl:variable name="diff-count-release" select="imf:get-config-string('appinfo', 'compare-differences-release')"/>
          
            <xsl:if test="$diff-count-release ne '0'">
                <summary>
                    <info label="Release comparison">
                        <xsl:sequence select="imf:report-label('Differences found', $diff-count-release)"/>
                    </info>
                </summary>
                <xsl:for-each select="$report-release">
                    <!-- set the context document -->
                    <xsl:call-template name="fetch-comparison-report">
                        <xsl:with-param name="title">Release comparison</xsl:with-param>
                        <xsl:with-param name="info">
                            <xsl:value-of select="concat('(', count($report-derv//imvert:diffs/imvert:diff),' differences)')"/>
                        </xsl:with-param>
                        <xsl:with-param name="intro">
                            <p>  This table show all differences between the current and revuously released version of the UML:
                                <ul>
                                    <li>
                                        Control: the previous release: <xsl:value-of select="imf:get-config-string('cli','comparewith')"/>.
                                    </li>
                                    <li>
                                        Test: the current release: <xsl:value-of select="imf:get-config-string('appinfo','release')"/>.  
                                    </li>
                                </ul> 
                            </p>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </report>
    </xsl:template>
    
</xsl:stylesheet>
