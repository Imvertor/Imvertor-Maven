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
          Transform BOM UML constructs to canonical UML constructs.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="project-package" select="(//imvert:package[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-project-package')])[1]"/>
    <xsl:variable name="base-package" select="($project-package//imvert:package[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-base-package')])[1]"/>
    <xsl:variable name="external-package" select="$project-package/imvert:package[. != $base-package]"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- <<project >> package -->
    <xsl:template match="imvert:package[.=$project-package]">
        <imvert:package>
            <xsl:apply-templates select="*[not(self::imvert:package)]"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:package>
    </xsl:template>
    
    <!-- <<base>> package -->
    <xsl:template match="imvert:package[.=$base-package]">
        <imvert:package>
            <xsl:apply-templates select="*"/>
            <xsl:variable name="s" as="element()+">
                <imvert:namespace>
                    <xsl:value-of select="concat('http://www.kadaster.nl/schemas/bom/', encode-for-uri(imvert:found-name))"/>
                </imvert:namespace>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$s)"/>
            <xsl:variable name="s" as="element()+">
                <imvert:stereotype>
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-base-package')[1]"/>
                </imvert:stereotype>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$s)"/>
        </imvert:package>
    </xsl:template>
    
    <!-- <<external>> package: all siblings of the base -->
    <xsl:template match="imvert:package[.=$external-package]">
        <imvert:package>
            <xsl:apply-templates select="*"/>
            <xsl:variable name="s" as="element()+">
                <imvert:namespace>
                    <xsl:value-of select="concat('http://www.kadaster.nl/schemas/bom/', encode-for-uri(imvert:found-name))"/>
                </imvert:namespace>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$s)"/>
            <xsl:variable name="s" as="element()+">
                <imvert:stereotype>
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-external-package')[1]"/>
                </imvert:stereotype>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$s)"/>
        </imvert:package>
    </xsl:template>
    
    <!-- <<domain>> package -->
    <xsl:template match="imvert:package[parent::imvert:package/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-base-package')]">
        <imvert:package>
            <xsl:apply-templates select="*"/>
            <xsl:variable name="v" as="element()+">
                <imvert:namespace>
                    <xsl:value-of select="concat('http://www.kadaster.nl/schemas/bom/', encode-for-uri(../imvert:found-name),'/',encode-for-uri(imvert:found-name))"/>
                </imvert:namespace>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$v)"/>
            <xsl:variable name="v" as="element()+">
                <imvert:stereotype>
                    <xsl:value-of select="imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))[1]"/>
                </imvert:stereotype>
                <imvert:version>
                    <xsl:value-of select="$base-package/imvert:version"/>
                </imvert:version>
                <imvert:phase>
                    <xsl:value-of select="$base-package/imvert:phase"/>
                </imvert:phase>
                <imvert:release>
                    <xsl:value-of select="$base-package/imvert:release"/>
                </imvert:release>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$v)"/>
        </imvert:package>
    </xsl:template>
    
    <!-- associations must have a name and stereotype -->
    <xsl:template match="imvert:association">
        <imvert:association>
            <xsl:apply-templates select="*"/>
            <xsl:if test="empty(imvert:found-name)">
                <xsl:variable name="v" select="concat('anonymous_', generate-id(.))"/>
                <imvert:name original="{$v}">
                    <xsl:value-of select="$v"/>
                </imvert:name>
            </xsl:if>
        </imvert:association>
    </xsl:template>

    <!-- attributes must have a type -->
    <xsl:template match="imvert:attribute">
        <imvert:attribute>
            <xsl:apply-templates select="*"/>
            <xsl:variable name="v" as="element()+">
                <imvert:baretype>AN</imvert:baretype>
                <imvert:type-name>string</imvert:type-name>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$v)"/>
        </imvert:attribute>
    </xsl:template>
    
    <xsl:template match="imvert:attribute/imvert:found-name[imf:get-normalized-name(.,'property-name')=imf:get-normalized-name('identificatie','property-name')]">
        <imvert:name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'property-name')"/>
        </imvert:name>
        <imvert:stereotype>
            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-identificatie')[1]"/>
        </imvert:stereotype>
        <is-id>true</is-id>
    </xsl:template>
    
    <!-- generate the correct name here -->
    <xsl:template match="imvert:found-name">
        <xsl:variable name="type" select="
            if (parent::imvert:package) then 'package-name' else 
            if (parent::imvert:attribute) then 'property-name' else
            if (parent::imvert:association) then 'property-name' else 'class-name'" as="xs:string"/>
        <imvert:name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,$type)"/>
        </imvert:name>
    </xsl:template>
    
    <!-- generate the correct name for types specified, but only when the type is declared as a class (i.e. no system types) -->
    <xsl:template match="imvert:*[imvert:type-id]/imvert:type-name">
        <imvert:type-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'class-name')"/>
        </imvert:type-name>
    </xsl:template>
    
    <!-- generate the correct name for packages of types specified -->
    <xsl:template match="imvert:type-package">
        <imvert:type-package original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:type-package>
    </xsl:template>
   
   <!-- ignore type names -->
    <xsl:template match="imvert:baretype">
        <imvert:baretype>AN</imvert:baretype>
    </xsl:template>
    
    <xsl:template match="imvert:type-name">
        <imvert:type-name>string</imvert:type-name>
    </xsl:template>
    
    <xsl:template match="imvert:version">
        <imvert:version>
            <xsl:value-of select="if (tokenize(.,'\.')[3]) then . else concat(.,'.0')"/>
        </imvert:version>
    </xsl:template>
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>    
  
    <xsl:function name="imf:create-when-missing">
        <xsl:param name="this"/>
        <xsl:param name="new-elements" as="element()+"/>
        <xsl:for-each select="$new-elements">
            <xsl:variable name="name" select="name(.)"/>
            <xsl:if test="empty($this/*[name()=$name])">
                <xsl:sequence select="."/>
            </xsl:if>        
        </xsl:for-each>
    </xsl:function>
</xsl:stylesheet>
