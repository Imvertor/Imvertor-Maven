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
        select="//imvert:package[imvert:is-root-package='true']"
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
                <xsl:for-each-group select="$external-packages[(imvert:class/imvert:id = $result-packages//(imvert:type-id | imvert:supertype/imvert:type-id)) or imvert:stereotype=imf:get-config-stereotypes('stereotype-name-system-package')]" group-by="imvert:id">
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
    
    <!--x 
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-product','stereotype-name-process','stereotype-name-service'))]">
        <xsl:variable name="collection-name" select="concat(imvert:name,imf:get-config-parameter('imvertor-translate-suffix-components'))"/>
        <xsl:variable name="collection-id" select="concat('collection_', generate-id(.))"/>
        <xsl:variable name="collection-package-name" select="../imvert:name"/>
        <xsl:variable name="collection-class" as="element()?">
            <!- - when no collection type class referenced, roll your own - -> 
            <!- - IM-110 but only when buildcollection yes - ->
            <xsl:if test="imf:boolean($buildcollection)">
                <xsl:if test="not(imvert:associations/imvert:association/imvert:type-id[imf:get-construct-by-id(.)/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')])">
                    <xsl:sequence select="imf:msg('INFO','Catalog class [1] ([2]) does not include any collection. Appending [3].', (string(imf:get-construct-name(.)), string-join(imvert:stereotype,', '),$collection-name))"/>
                    <imvert:class>
                        <xsl:sequence select="imf:create-output-element('imvert:id',$collection-id)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:name',$collection-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:stereotype',imf:get-config-stereotypes('stereotype-name-collection'))"/>
                        <xsl:sequence select="imf:create-output-element('imvert:abstract','false')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:origin',imf:get-config-parameter('name-origin-system'))"/>
                        <imvert:associations>
                            <xsl:variable name="all-collection-member-classes" select="imf:get-all-collection-member-classes(.)"/>
                            <xsl:for-each select="$all-collection-member-classes">
                                <imvert:association>
                                    <xsl:sequence select="imf:create-output-element('imvert:type-name',imvert:name)"/>
                                    <xsl:sequence select="imf:create-output-element('imvert:type-id',imvert:id)"/>
                                    <xsl:sequence select="imf:create-output-element('imvert:type-package',../imvert:name)"/>
                                    <xsl:sequence select="imf:create-output-element('imvert:min-occurs','0')"/>
                                    <xsl:sequence select="imf:create-output-element('imvert:max-occurs','unbounded')"/>
                                </imvert:association>
                            </xsl:for-each>
                        </imvert:associations>
                    </imvert:class>
                </xsl:if>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="super-classes" select="imf:get-superclasses(.)"/>
        <xsl:variable name="super-products" select="$super-classes[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-product','stereotype-name-process','stereotype-name-service'))]"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:sequence select="*[not(self::imvert:associations)]"/>
            <imvert:associations>
                <xsl:sequence select="imvert:associations/imvert:association"/>
                <!- - 
                    IM-136 
                    alleen deze constructie als geen subtype van een ander product.
                - ->
                <xsl:if test="$collection-class and empty($super-products)">
                    <imvert:association>
                        <xsl:sequence select="imf:create-output-element('imvert:name',imf:get-config-parameter('imvertor-translate-association-components'))"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-name',$collection-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-id',$collection-id)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-package',$collection-package-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:min-occurs','1')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:max-occurs','1')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:position','999')"/>
                    </imvert:association>
                </xsl:if>
            </imvert:associations>
        </xsl:copy>
            
        <xsl:sequence select="$collection-class"/>
    </xsl:template>
    x-->
    
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
