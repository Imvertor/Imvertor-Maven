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
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
        Validation of the UML only for Kadaster rules. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="application-package" select="(//imvert:package[imvert:name/@original=$application-package-name])[1]"/>
    
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
            <xsl:apply-templates select="imvert:package"/>
        </imvert:report>
    </xsl:template>
      
    <xsl:template match="imvert:package[.=$application-package]">
        <!--setup-->
        <xsl:variable name="this-package" select="."/>
        <xsl:variable name="root-release" select="imvert:release" as="xs:string?"/>
        <xsl:variable name="subpackage-releases" select="imvert:package/imvert:release[not(.=('99999999','00000000'))]" as="xs:string*"/>
        <xsl:variable name="collections" select=".//imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')]"/>  
        <xsl:sequence select="imf:report-error(., 
            ($document-classes/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype') and not($document-packages/imvert:name=('xlinks','Xlinks'))), 
            'The model uses shared classes but the xlink package is not included (properly).')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <xsl:variable name="package" select=".."/>
        <xsl:variable name="is-external" select="$package/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-external-package')"/>
        
        <!--
            Only Abstract classes start with _underscore        
        -->
        <xsl:sequence select="imf:report-warning(., 
            not($is-external) and imf:boolean(imvert:abstract) and not(starts-with(imvert:name,'_')), 
            'Abstract class name should start with underscore.')"/>
        <xsl:sequence select="imf:report-warning(., 
            not($is-external) and not(imf:boolean(imvert:abstract)) and starts-with(imvert:name,'_'), 
            'Concrete class name should not start with underscore.')"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
        attribute validation 
    -->
    <xsl:template match="imvert:attribute">
        <!-- setup -->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="class" select="../.."/>
        
        <xsl:sequence select="imf:report-error(., 
            (imvert:name=imf:get-config-parameter('fixed-identification-attribute-name') and not(imvert:is-id = 'true')), 
            'Identification attribute is not marked as ID')"/>
        
        <xsl:sequence select="imf:report-warning(., 
            (imvert:is-id = 'true' and not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-identificatie'))), 
            'Attribute is marked as ID but is not stereotyped as [1]', imf:get-config-stereotypes('stereotype-name-identificatie'))"/>
                
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class | imvert:attribute |imvert:association" priority="10">
        
        <xsl:sequence select="imf:report-warning(., 
            imvert:stereotype = imf:get-config-stereotypes('stereotype-name-voidable') and empty(imf:get-tagged-value(.,'Mogelijk geen waarde')), 
            'Voidable, but missing required tagged value &quot;Mogelijk geen waarde&quot;')"/>
        <xsl:sequence select="imf:report-warning(., 
            empty(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-voidable')) and imf:get-tagged-value(.,'Mogelijk geen waarde'), 
            'Tagged value &quot;Mogelijk geen waarde&quot; found, but not stereotyped as voidable' )"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!-- IM-269 -->
    <xsl:template match="imvert:attribute |imvert:association" priority="20">
        
        <?x decided not to signal this 
        <xsl:variable name="found-name" select="imvert:name/@original"/>
        <xsl:sequence select="imf:report-warning(., 
            matches($found-name,'^[A-Z]{2}'), 
            'UML property name [1] starts with multiple capital letters. The adapted name may be invalid.', $found-name)"/>
        ?>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:supertype[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-static-generalization')]" priority="1">
        <!--setup-->
        <!--validation-->
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
        other validation 
    -->
    <xsl:template match="*"> 
        <xsl:apply-templates/>
    </xsl:template> 

    <xsl:template match="text()|processing-instruction()"> 
        <!-- nothing -->
    </xsl:template>

</xsl:stylesheet>
