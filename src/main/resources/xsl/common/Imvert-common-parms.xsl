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
    <xsl:variable name="imvertor-version" select="imf:get-config-string('run','imvertor-version','(UNKNOWN)')"/>
    <xsl:variable name="debug" select="imf:get-config-string('cli','debug','false')"/>

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
    
    <?remove
    
    <!-- ================================================================================== -->
    <!-- TODO ga na of deze nog nodig zijn. -->
    
    <xsl:variable name="todo-system-input-folder-path" select="imf:get-config-string('migrate','system-input-folder-path')"/>
    
    <xsl:variable name="todo-properties-file-path" select="imf:get-config-string('migrate','properties-file-path')"/>

    <xsl:variable name="todo-base-package-name" select="imf:get-config-string('migrate','base-package-name')"/>
    <xsl:variable name="todo-application-package-version" select="imf:get-config-string('migrate','application-package-version')"/>
    <xsl:variable name="todo-application-package-phase" select="imf:get-config-string('migrate','application-package-phase')"/>
    <xsl:variable name="todo-application-package-task" select="imf:get-config-string('migrate','application-package-task')"/>
    <!-- e.g. /applications/imvertor/Imvertor/20141001/xsd/Imvertor/application/v20141001/Imvertor_Application_v1_0_0.xsd -->
    <xsl:variable name="todo-searchpath" select="imf:get-config-string('migrate','searchpath')"/>
    <xsl:variable name="todo-metamodel" select="imf:get-config-string('migrate','metamodel')"/>
    <xsl:variable name="todo-passed-file" select="imf:get-config-string('migrate','passed-file')"/>
    <xsl:variable name="todo-passed-file-uri" select="imf:get-config-string('migrate','passed-file-uri')"/>
    <xsl:variable name="todo-active-xmi-file" select="imf:get-config-string('migrate','active-xmi-file')"/>
    <xsl:variable name="todo-active-xmi-file-uri" select="imf:get-config-string('migrate','active-xmi-file-uri')"/>
    <xsl:variable name="todo-active-xmi-file-origin" select="imf:get-config-string('migrate','active-xmi-file-origin')"/>
    <xsl:variable name="todo-list-settings" select="imf:get-config-string('migrate','list-settings')"/>
    <xsl:variable name="todo-validate-schema" select="imf:get-config-string('migrate','validate-schema')"/>
    <xsl:variable name="todo-validate-derivation" select="imf:get-config-string('migrate','validate-derivation')"/>
    <xsl:variable name="todo-documentation-release" select="imf:get-config-string('migrate','documentation-release')"/>

   

    <xsl:variable name="todo-propertiesfile-svn-id" select="imf:get-config-string('migrate','propertiesfile-svn-id')"/>
    <xsl:variable name="todo-start-history-at" select="imf:get-config-string('migrate','start-history-at')"/>

    <xsl:variable name="todo-conceptual-schema-mapping-file" select="imf:get-config-string('migrate','conceptual-schema-mapping-file','unknown-file')"/>

    <xsl:variable name="todo-local-schema-mapping-file" select="imf:get-config-string('migrate','local-schema-mapping-file','unknown-file')"/>


    <!-- 
        messages that report status (sent to screen immediately)
    -->
    <xsl:variable name="todo-status-message-level" select="imf:get-config-string('migrate','status-message-level', 'STATUS')"/>
    <!-- 
        messages that should be sent to screen : any of
        ('ERROR','WARN','STATUS','INFO') 
    -->
    <xsl:variable name="todo-screen-message-level" select="imf:get-config-string('migrate','screen-message-level','FATAL ERROR WARN HINT')"/>
    <!-- 
        messages that must be recorded in documentation 
    -->
    <xsl:variable name="todo-report-message-level" select="imf:get-config-string('migrate','report-message-level','FATAL ERROR WARN HINT')"/>

    <xsl:variable name="todo-imvertor-svn-version" select="imf:get-config-string('migrate','imvertor-svn-version','(UNKNOWN)')"/>

    <xsl:variable name="todo-imvert-folder-path" select="imf:get-config-string('migrate','imvert-folder-path','unknown')"/>
    <xsl:variable name="todo-doc-folder-path" select="imf:get-config-string('migrate','doc-folder-path','unknown')"/>

    <xsl:variable name="todo-validation-file-path" select="imf:get-config-string('migrate','validation-file-path','unknown')"/>
    <xsl:variable name="todo-derivation-file-path" select="imf:get-config-string('migrate','derivation-file-path','unknown')"/>
    <xsl:variable name="todo-schemavalidation-file-path" select="imf:get-config-string('migrate','schemavalidation-file-path','unknown')"/>
    <xsl:variable name="todo-history-file-path" select="imf:get-config-string('migrate','history-file-path','unknown')"/>
    <xsl:variable name="todo-history-file-exists" select="imf:get-config-string('migrate','history-file-exists','false')"/>

    <xsl:variable name="todo-release-to-public" select="imf:get-config-string('migrate','release-to-public','true')"/>
    <!-- when false, generate debugging files too. -->

    <xsl:variable name="todo-contact-email" select="imf:get-config-string('migrate','contact-email')"/>
    <xsl:variable name="todo-contact-url" select="imf:get-config-string('migrate','contact-url')"/>

    <xsl:variable name="todo-imvertor-errors" select="imf:get-config-string('migrate','imvertor-errors')"/>


    <!-- files that are generated by XSD or ETC routines -->
    <xsl:variable name="todo-xsd-files-generated" select="imf:get-config-string('migrate','xsd-files-generated')"/>
    <xsl:variable name="todo-etc-files-generated" select="imf:get-config-string('migrate','etc-files-generated')"/>


    remove?>

</xsl:stylesheet>
