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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    >
    
    <!-- 
        Validation of ISO 19103 models. 
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>

    <xsl:variable name="application-package" select="//imvert:package[imf:boolean(imvert:is-root-package)]"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
            <!-- info used to determine report location are set here -->
            <xsl:variable name="application-package-release" select="$application-package/imvert:release"/>
            <xsl:variable name="application-package-version" select="$application-package/imvert:version"/>
            <xsl:variable name="application-package-phase" select="$application-package/imvert:phase"/>
            
            <xsl:attribute name="release" select="if ($application-package-release) then $application-package-release else '00000000'"/>
            <xsl:attribute name="version" select="if ($application-package-version) then $application-package-version else '0.0.0'"/>
            <xsl:attribute name="phase" select="if ($application-package-phase) then $application-package-phase else '0'"/>
            
            <xsl:sequence select="imf:report-error(., not($application-package), 'No such application package found: [1]', ($application-package-name))"/>
            <!-- process the application package -->
            <xsl:apply-templates select="imvert:package[imf:member-of(.,$application-package)]"/>
        </imvert:report>
    </xsl:template>
    
    <!--
        Rules for the application package
    -->
    <xsl:template match="imvert:package[imf:member-of(.,$application-package)]">
        <!--setup-->
        <xsl:variable name="this-package" select="."/>
   
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the domain packages
    -->
    <xsl:template match="imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package')]">
        <!--setup-->
        <xsl:variable name="this-package" select="."/>
        
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
        
    <xsl:template match="imvert:package" priority="0">
        <!--setup-->
        <xsl:variable name="this-package" select="."/>
        
        <!-- continue other validation -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
