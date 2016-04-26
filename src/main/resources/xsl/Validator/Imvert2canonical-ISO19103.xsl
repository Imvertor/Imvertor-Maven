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
          Transform ISO19103 UML constructs to canonical UML constructs.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="application-package" select="//imvert:package[imvert:name=$application-package-name][1]"/>
    
    <xsl:variable name="gml-interfaces" select="$document-packages[imvert:found-name='GML3']/imvert:class"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="imvert:package[imvert:class/imvert:associations/imvert:association[imvert:found-name='FeatureMember']]">
        <xsl:variable name="assoc" select="imvert:class/imvert:associations/imvert:association[imvert:found-name='FeatureMember'][1]"/>
        <imvert:package>
            <xsl:apply-templates/>
            <!-- and add the intermediate feature member class -->
            <imvert:class>
                <imvert:origin>
                    <xsl:value-of select="imf:get-config-parameter('name-origin-system')"/>
                </imvert:origin>
                <xsl:apply-templates select="$assoc/imvert:found-name"/>
                <imvert:abstract>false</imvert:abstract>
                <imvert:id>
                    <xsl:value-of select="generate-id($assoc)"/>
                </imvert:id>
                <xsl:sequence select="imf:create-GM-supertype('GM_AbstractFeatureMemberType',$name-none)"/>
                <imvert:associations>
                    <imvert:association>
                        <imvert:name>(anonymous)</imvert:name>
                        <imvert:stereotype>
                            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-anonymous')"/>
                        </imvert:stereotype>
                        <xsl:sequence select="$assoc/imvert:type-name"/>
                        <xsl:sequence select="$assoc/imvert:type-id"/>
                        <xsl:sequence select="$assoc/imvert:type-package"/>
                        <imvert:min-occurs-source>1</imvert:min-occurs-source>
                        <imvert:max-occurs-source>1</imvert:max-occurs-source>
                        <imvert:min-occurs>1</imvert:min-occurs>
                        <imvert:max-occurs>1</imvert:max-occurs>
                        <xsl:sequence select="imvert:documentation"/>
                    </imvert:association>
                </imvert:associations>
            </imvert:class>
        </imvert:package>
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:stereotype[.=imf:get-config-stereotypes('stereotype-name-iso-19103-applicationschema')]">
        <imvert:stereotype original="{.}">
            <xsl:value-of select="imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))"/>
        </imvert:stereotype>
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:stereotype[.=imf:get-config-stereotypes('stereotype-name-iso-19103-leaf')]">
        <imvert:stereotype original="{.}"/>
    </xsl:template>
    <xsl:template match="imvert:package/imvert:stereotype[.=imf:get-config-stereotypes('stereotype-name-iso-19103-datatype')]">
        <imvert:stereotype original="{.}">complex datatype</imvert:stereotype>
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:stereotype[.=imf:get-config-stereotypes('stereotype-name-iso-19103-union')]">
        <imvert:stereotype original="{.}">
            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-union')"/>
        </imvert:stereotype>
    </xsl:template>
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-iso-19103-union')]/imvert:attributes/imvert:attribute">
        <xsl:copy>
            <xsl:apply-templates/>
            <imvert:stereotype>
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-union-element')"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-iso-19103-featurecollection and empty(imvert:supertype)')]">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:sequence select="imf:create-GM-supertype('GM_AbstractGMLType','GM_AbstractGML')"/>
        </xsl:copy>
    </xsl:template> 
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-iso-19103-featuretype and empty(imvert:supertype)')]">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:sequence select="imf:create-GM-supertype('GM_AbstractFeatureType','GM_AbstractFeature')"/>
        </xsl:copy>
    </xsl:template> 
    
   
    
    <!-- TODO -->
    <!-- 
        FeatureMember is a relation. 
        This must be replaced by a class definition which inherits properties of GM_AbstractFeatureMember.
    -->
    <xsl:template match="imvert:association[imvert:found-name='FeatureMember']">
        <imvert:association>
            <imvert:origin>
                <xsl:value-of select="imf:get-config-parameter('name-origin-system')"/>
            </imvert:origin>
            <imvert:name>(anonymous)</imvert:name>
            <imvert:type-name>
                <xsl:value-of select="imvert:found-name"/>
            </imvert:type-name>
            <imvert:type-id>
                <xsl:value-of select="generate-id(.)"/>
            </imvert:type-id>
            <imvert:type-package>
                <xsl:value-of select="ancestor::imvert:package[1]/imvert:found-name"/>
            </imvert:type-package>
            <xsl:sequence select="imvert:min-occurs-source"/>
            <xsl:sequence select="imvert:max-occurs-source"/>
            <xsl:sequence select="imvert:min-occurs"/>
            <xsl:sequence select="imvert:max-occurs"/>
            <xsl:sequence select="imvert:documentation"/>
            <imvert:stereotype>
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-anonymous')"/>
            </imvert:stereotype>
        </imvert:association>
    </xsl:template> 
    
    <xsl:template match="imvert:class/imvert:stereotype[.=imf:get-config-stereotypes('stereotype-name-iso-19103-featurecollection')]">
        <imvert:stereotype original="{.}">
            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-collection')"/>
        </imvert:stereotype>
    </xsl:template> 
    
    <xsl:template match="imvert:class/imvert:stereotype[.=imf:get-config-stereotypes('stereotype-name-iso-19103-featuretype')]">
        <imvert:stereotype original="{.}">
            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-objecttype')"/>
        </imvert:stereotype>
    </xsl:template> 
    
    <!-- generate the correct name here -->
    <xsl:template match="imvert:found-name">
        <imvert:name original="{.}">
            <xsl:value-of select="."/> <!-- no change -->
        </imvert:name>
    </xsl:template>
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>    
    
    <xsl:function name="imf:create-GM-supertype" as="element()">
        <xsl:param name="gm-extensionbase"/>
        <xsl:param name="gm-substitutionGroup"/>
        <imvert:supertype>
            <xsl:sequence select="imf:create-output-element('imvert:type-name',$gm-extensionbase)"/>
            <xsl:sequence select="imf:create-output-element('imvert:type-id',$gml-interfaces[imvert:found-name=$gm-extensionbase]/imvert:id)"/>
            <xsl:sequence select="imf:create-output-element('imvert:type-package','GML3')"/>
            <xsl:sequence select="imf:create-output-element('imvert:xsd-substitutiongroup',$gm-substitutionGroup)"/>
        </imvert:supertype>
    </xsl:function>
</xsl:stylesheet>
