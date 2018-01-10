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
        Transform the imvert information to an application by merging the layers.
     -->
    
    <!-- TODO IM-70 Wrapper elementen in XSD voor datacollecties toestaan -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable 
        name="external-packages" 
        select="//imvert:package[ancestor-or-self::imvert:package/imvert:stereotype=(imf:get-config-stereotypes(('stereotype-name-external-package','stereotype-name-system-package')))]" 
        as="node()*"/>
    
    <xsl:variable 
        name="application-package" 
        select="//imvert:package[imf:boolean(imvert:is-root-package)]"
        as="node()*"/>
    
    <!-- override document packages by the packages in the application tree -->
    <xsl:variable 
        name="document-packages" 
        select="($external-packages, $application-package/descendant-or-self::imvert:package)"
        as="node()*"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            
            <xsl:variable name="intro" select="*[not(self::imvert:package)]"/>
            <xsl:apply-templates select="$intro" mode="finalize"/>
            
            <xsl:sequence select="imf:compile-imvert-filter()"/>
            
            <xsl:sequence select="$application-package/imvert:id"/>
            <xsl:sequence select="$application-package/imvert:supplier"/>
            <xsl:sequence select="$application-package/imvert:stereotype"/>
            <xsl:sequence select="$application-package/imvert:documentation"/>
            <xsl:sequence select="$application-package/imvert:tagged-values"/>
            <xsl:sequence select="$application-package/imvert:constraints"/>
            
            <xsl:variable name="result-packages" as="node()*">
                <!-- verwerk alle subpackages van de gekozen parent package bijv. VariantX of ApplicationY -->
                <xsl:apply-templates select="$application-package/imvert:package"/>
            </xsl:variable>
            <xsl:apply-templates select="$result-packages" mode="finalize"/>
            
            <!-- if any type is taken from an external package, or if it is a system package, import that external package -->
            <xsl:variable name="result-external-packages" as="node()*">
                <xsl:for-each-group select="$external-packages[
                    imf:boolean(imvert:class/imvert:sentinel) 
                    or 
                    (imvert:class/imvert:id = $result-packages//(imvert:type-id | imvert:supertype/imvert:type-id)) 
                    or 
                    imvert:stereotype=imf:get-config-stereotypes('stereotype-name-system-package')]" 
                    group-by="imvert:id">
                
                    <xsl:sequence select="."/>
                </xsl:for-each-group>
            </xsl:variable>
           
            <xsl:apply-templates select="$result-external-packages" mode="finalize"/>
            
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- finalization: add some info to the compiled document fragment -->
    
    <xsl:template match="*" mode="finalize">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="finalize"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:type-id" mode="finalize">
        <xsl:copy-of select="."/>
        <xsl:if test="not(../imvert:type-package)">
            <xsl:variable name="id" select="imf:get-package-id(.)"/>
            <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-construct-by-id($id)/imvert:name)"/>  
            <xsl:sequence select="imf:create-output-element('imvert:type-package-id',$id)"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="imvert:supertype/imvert:type-id" mode="finalize">
        <xsl:copy-of select="."/>
        <xsl:if test="not(../imvert:type-package)">
            <xsl:variable name="id" select="imf:get-package-id(.)"/>
            <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-construct-by-id($id)/imvert:name)"/>  
            <xsl:sequence select="imf:create-output-element('imvert:type-package-id',$id)"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="finalize">
        <xsl:copy>
            <xsl:apply-templates select="*[not(self::imvert:class)]" mode="finalize"/>
            <xsl:apply-templates select="ancestor::imvert:package/imvert:stereotype" mode="finalize"/>
            <xsl:apply-templates select="imvert:class" mode="finalize"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- get the ID of the package that defines the type with the ID passed -->
    <xsl:function name="imf:get-package-id" as="xs:string">
        <xsl:param name="type-id" as="xs:string?"/>
        <xsl:variable name="class" select="$imvert-document//*[imvert:id=$type-id]"/>
        <xsl:value-of select="$class/../imvert:id"/>
    </xsl:function>
   
</xsl:stylesheet>
