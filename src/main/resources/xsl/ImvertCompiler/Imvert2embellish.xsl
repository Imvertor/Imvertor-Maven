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
        Insert non-essential information for a simpler processing by reporting and XSD conversion tool. 
        
        Set the imvert:position value to the position specified by tagged value, in accordance with the applicable metamodel. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:variable name="stylesheet-code">EMB</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:template match="/imvert:packages">
       
        <xsl:variable name="current-phase-level" select="imvert:phase"/>
        <xsl:variable name="cfg-phase" select="$configuration-versionrules-file/phase-rule/phase[level = $current-phase-level]"/>
        <xsl:variable name="is-fixed" select="imf:boolean($cfg-phase/is-fixed)"/>
        <xsl:variable name="allow-docrelease" select="imf:boolean($cfg-phase/allow-docrelease)"/>

        <imvert:packages>
            <xsl:sequence select="imf:create-output-element('imvert:subpath',imf:get-subpath(imvert:project,imvert:application,imvert:release))"/>
            <xsl:sequence select="imf:create-output-element('imvert:model-id',$application-package-release-name)"/>
            <xsl:sequence select="imf:create-output-element('imvert:is-fixed',$is-fixed)"/>
            <xsl:sequence select="imf:create-output-element('imvert:allow-docrelease',$allow-docrelease)"/>
           
            <!-- add run info, number of errors and warnings so far -->
            <imvert:process>
                <imvert:job>
                    <xsl:value-of select="$job-id"/>
                </imvert:job>
                <imvert:owner>
                    <xsl:value-of select="$owner-name"/>
                </imvert:owner>
                <imvert:user>
                    <xsl:value-of select="$user-id"/>
                </imvert:user>
                <imvert:errors>
                    <xsl:value-of select="imf:get-config-string('system','error-count','0')"/>
                </imvert:errors>
                <imvert:warnings>
                    <xsl:value-of select="imf:get-config-string('system','warning-count','0')"/>
                </imvert:warnings>
            </imvert:process>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="imvert:package">
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            
            <xsl:sequence select="imf:get-embellish-suppliers(.)"/>
            
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:class">
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            
            <xsl:sequence select="imf:get-embellish-suppliers(.)"/>
    
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:supertype">
        <xsl:copy>
            <xsl:variable name="superclass" select="imf:get-construct-by-id(imvert:type-id)"/>
            <xsl:attribute name="display-name" select="imf:get-display-name($superclass)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name($superclass)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:attribute">
        <xsl:variable name="class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            
            <xsl:choose>
                <xsl:when test="imvert:type-id and $class">
                    <xsl:attribute name="type-display-name" select="imf:get-display-name($class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type-display-name" select="imvert:type-name"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="imvert:copy-down-type-id">
                <xsl:variable name="copy-down-class" select="imf:get-construct-by-id(imvert:copy-down-type-id)"/>
                <xsl:attribute name="copy-down-display-name" select="imf:get-construct-name($copy-down-class)"/>
            </xsl:if>
  
            <xsl:sequence select="imf:get-embellish-suppliers(.)"/>

            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:association">
        <xsl:variable name="class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:attribute name="formal-name" select="imf:get-construct-formal-name(.)"/>
            <xsl:attribute name="type-display-name" select="imf:get-display-name($class)"/>
            <xsl:attribute name="type-formal-name" select="imf:get-construct-formal-name($class)"/>
            
            <xsl:sequence select="imf:get-embellish-suppliers(.)"/>
            
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:position">
        <!-- get the tagged value that sets the position ans use that value; if no such tagged value, use the current value -->
        <xsl:variable name="position-specified" select="imf:get-tagged-value(..,'##CFG-TV-POSITION')"/>
        <xsl:variable name="position-calculated" select="($position-specified,.)[1]"/>
        <xsl:copy>
            <xsl:attribute name="original" select="."/>
            <xsl:value-of select="$position-calculated"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
   
    <xsl:function name="imf:get-embellish-suppliers" as="element()*">
        <xsl:param name="construct"/>
        <xsl:if test="$debugging">
            <imvert:resolved-suppliers>
                <xsl:sequence select="imf:get-trace-suppliers-for-construct($construct,1)"/>
            </imvert:resolved-suppliers>
            <imvert:resolved-documentation>
                <xsl:sequence select="imf:get-compiled-documentation($construct)"/>
            </imvert:resolved-documentation>
            <imvert:resolved-tagged-values>
                <xsl:variable name="tvs" select="imf:get-compiled-tagged-values($construct,false())"/>
                <xsl:for-each-group select="$tvs" group-by="@name">
                    <imvert:resolved-tagged-value-group name="{current-group()[1]/@name}">
                        <xsl:for-each select="current-group()">
                            <imvert:tagged-value>
                                <xsl:attribute name="derivation-project" select="@project"/>
                                <xsl:attribute name="derivation-application" select="@application"/>
                                <xsl:attribute name="derivation-release" select="@release"/>
                                <xsl:attribute name="derivation-level" select="@level"/>
                                <imvert:name original="{@original-name}">
                                    <xsl:value-of select="@name"/>
                                </imvert:name>
                                <imvert:value original="{@original-value}">
                                    <xsl:value-of select="@value"/>
                                </imvert:value>
                            </imvert:tagged-value>
                        </xsl:for-each>
                    </imvert:resolved-tagged-value-group>
                </xsl:for-each-group>
            </imvert:resolved-tagged-values>
        </xsl:if>
    </xsl:function>
  
</xsl:stylesheet>
