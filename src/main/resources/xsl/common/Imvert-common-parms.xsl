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
    xmlns:uml="http://schema.omg.org/spec/UML/2.1" 
    xmlns:UML="VERVALLEN" 
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0" 
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" 
    xmlns:imvert="http://www.imvertor.org/schema/system" 
    xmlns:imvert-history="http://www.imvertor.org/schema/history" 
    xmlns:imf="http://www.imvertor.org/xsl/functions" 
    xmlns:ekf="http://EliotKimber/functions" 
    
    xmlns:functx="http://www.functx.com" 
    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
        ==========================================
        parameters available to all stylesheets
        ==========================================
    -->

    <xsl:param name="xml-configuration-url"/>
    <xsl:param name="xml-input-nme"/>
    <xsl:param name="xml-output-name"/>
    <xsl:param name="xml-stylesheet-name"/>
    
    <!-- 
        ==========================================
        variables available to all stylesheets
        ==========================================
    -->
    <xsl:variable name="imvertor-start" select="imf:get-config-string('run','start','(UNKNOWN TIME)')"/>
    <xsl:variable name="imvertor-version" select="imf:get-config-string('run','version','(UNKNOWN VERSION)')"/>
    <xsl:variable name="imvertor-release" select="imf:get-config-string('run','release','(UNKNOWN RELEASE)')"/>
    
    <xsl:variable name="debug" select="imf:get-config-string('cli','debug','false')"/>
    <xsl:variable name="debugging" select="imf:boolean($debug)"/>
    
    <xsl:variable name="generation-date" select="imf:get-config-string('run','start','1900-01-01T00:00:00.0000')"/>

    <xsl:variable name="owner-name" select="imf:get-normalized-name(imf:get-config-string('cli','owner'),'system-name')"/>
    <xsl:variable name="project-name" select="imf:get-normalized-name(imf:get-config-string('cli','project'),'system-name')"/>
    <xsl:variable name="application-package-name" select="imf:get-config-string('cli','application')"/>
    
    <xsl:variable name="application-package-version" select="imf:get-config-string('appinfo','version')"/>
    <xsl:variable name="application-package-release" select="imf:get-config-string('appinfo','release')"/>
    
    <xsl:variable name="short-prefix" select="imf:get-config-string('cli','shortprefix')"/>
    
    <!-- set by EapCompiler: -->
    <xsl:variable name="uml-report-available" select="imf:get-config-string('system','uml-report-available')"/>
    
    <xsl:variable name="buildcollection" select="imf:get-config-string('cli','buildcollection','yes')"/>
    <xsl:variable name="profile-collection-wrappers" select="imf:get-config-string('system','profile-collection-wrappers','no')"/> <!--TODO profile-collection-wrappers is never set, and so always defaults to NO -->
    <xsl:variable name="normalize-names" select="imf:get-config-string('cli','normalizenames')"/>
    
    <xsl:variable name="applications-folder-path" select="imf:get-config-string('properties','APPLICATIONS_FOLDER')"/>
    <xsl:variable name="application-package-release-name" select="imf:get-config-string('appinfo','release-name')"/>
    
    <xsl:variable name="derivationtree-file-url" select="imf:file-to-url(imf:get-config-string('properties','WORK_DERIVATIONTREE_FILE'))"/>
    
    <xsl:variable name="derive-documentation" select="imf:get-config-string('cli','derivedoc')"/>
    <xsl:variable name="use-substitutions" select="imf:get-config-string('cli','substitutions')"/>
    <xsl:variable name="external-schemas-reference-by-url" select="imf:get-config-string('cli','externalurl')"/>
    <xsl:variable name="anonymous-components" select="false()"/> <!-- IM-83 STALLED! -->
    
    <xsl:variable name="variant-package-name" select="''"/> <!--TODO remove: not specified -->
    
    <xsl:variable name="template-file-model-guid" select="imf:get-config-string('system','template-file-model-guid','unknown')"/>
 
</xsl:stylesheet>
