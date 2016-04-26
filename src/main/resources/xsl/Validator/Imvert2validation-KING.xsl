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
        Validation of the UML only for KING rules, which follow the BP rules mostly. 
        This validatiuon may be imported by stylesheets for SIM or UGM that augment the validation rules.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="application-package" select="(//imvert:package[imvert:name/@original=$application-package-name])[1]"/>
    
    <xsl:variable name="tvs" select="imf:get-config-tagged-values()" as="element(tv)*"/>
    
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
            <xsl:apply-templates select=".//imvert:package[.=$application-package]"/>
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="imvert:class">
       
        <xsl:variable name="this-id" select="imvert:id"/>
        <xsl:variable name="is-associationclass" select="$document-classes//imvert:association-class/imvert:type-id = $this-id"/>
        
        <!-- association classes -->
        <xsl:sequence select="imf:report-error(., 
            $is-associationclass and not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse')), 
            'Association class must be stereotyped as [1]',imf:get-config-stereotypes('stereotype-name-relatieklasse'))"/>
        <xsl:sequence select="imf:report-error(., 
            not($is-associationclass) and imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse'), 
            'Class may not be stereotyped as [1]',imf:get-config-stereotypes('stereotype-name-relatieklasse'))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!-- skip these
        
    <xsl:template match="imvert:attribute/imvert:type-modifier[. = '+P']">
        <xsl:sequence select="imf:report-warning(.., 
            (empty(../imvert:pattern)), 
            'Pattern modifier (+P) found but no pattern defined')"/>
        <xsl:next-match/>
    </xsl:template>
    <xsl:template match="imvert:attribute/imvert:pattern">
        <xsl:sequence select="imf:report-warning(.., 
            not(../imvert:type-modifier = '+P'), 
            'Pattern defined but no pattern modifier (+P) specified')"/>
        <xsl:next-match/>
    </xsl:template>
    
    -->
    
    <xsl:template match="imvert:association[imvert:aggregation = 'composite']/imvert:tagged-value/imvert:name">
        <!-- setup -->
        <!-- gegevengroep compositie: rule is that some tagged values should not occur on composities (NOC) -->
        <xsl:sequence select="imf:report-error(., 
            empty($tvs[@rules = 'NOC'] = .), 
            'Tagged value [1] not allowed on composition relation', name)"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!-- validate the tagged values based on the @validate attribute in the configuration --> 
    <xsl:template match="imvert:tagged-value">
        <!-- setup -->
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(., 
            empty($tvs = imvert:name), 
            'Tagged value [1] not recognized', imvert:name)"/>
        <xsl:sequence select="imf:report-error(., 
            $tvs[. = current()/imvert:name]/@validate = 'boolean' and not(imvert:allow-tagged-value(imvert:value,'boolean')), 
            'Tagged value: [1] is not allowed for: [2]', (imvert:value, imvert:name))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:association[imvert:target-stereotype = imf:get-config-stereotypes('stereotype-name-composite-id')]">
        <!--TODO is this rule required? we already test if an objecttype has an ID attribute --> 
   
        <xsl:variable name="this" select="."/>
        
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="superclasses" select="imf:get-superclasses($class)"/>
        <xsl:variable name="source-has-id" select="($class,$superclasses)/imvert:attributes/imvert:attribute/imvert:is-id = 'true'"/>
        
        <xsl:variable name="defining-class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:variable name="defining-superclasses" select="imf:get-superclasses($defining-class)"/>
        <xsl:variable name="target-has-id" select="($defining-class,$defining-superclasses)/imvert:attributes/imvert:attribute/imvert:is-id = 'true'"/>
        
        <xsl:sequence select="imf:report-error(., 
            not($source-has-id), 
            'Source class [1] must have or inherit an attribute that is an ID', 
            imf:get-construct-name($class))"/>
        
        <xsl:sequence select="imf:report-error(., 
            not($target-has-id), 
            'Target class [1] must have or inherit an attribute that is an ID', 
            imf:get-construct-name($defining-class))"/>
        
        <xsl:sequence select="imf:report-error(., 
            not($defining-class/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')), 
            'Target class [1] must have stereotype [2] because the target in relation [3] is stereotyped as [4]', 
            (imf:get-construct-name($defining-class),imf:get-config-stereotypes('stereotype-name-objecttype'), imvert:name, imf:get-config-stereotypes('stereotype-name-composite-id') ))"/>
        
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
    
    <xsl:function name="imvert:allow-tagged-value" as="xs:boolean">
        <xsl:param name="value"/>
        <xsl:param name="rule"/>
        <xsl:choose>
            <xsl:when test="$rule = 'boolean'">
                <xsl:sequence select="$value = ('Ja', 'Nee', 'zie groep')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/> <!-- should not occur -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
