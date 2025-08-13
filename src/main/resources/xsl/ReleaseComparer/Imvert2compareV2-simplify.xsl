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
    xmlns:local="urn:local"
    
    exclude-result-prefixes="#all"
    expand-text="yes">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:param name="compare-system-packages" as="xs:string">false</xsl:param>
    
    <xsl:output indent="yes"/>
    
    <!-- Input is system.imvert.xml file -->
    <xsl:template match="/">
        <compare>
            <xsl:apply-templates/>
        </compare>
    </xsl:template>
    
    <xsl:template match="imvert:packages">
        <xsl:sequence select="local:fetch-local-application(.)"/>
        <xsl:sequence select="local:fetch-identification(.)"/>
        <xsl:sequence select="local:fetch-release(.)"/>
        <xsl:sequence select="local:fetch-derivation(.)"/>
        <xsl:sequence select="local:fetch-tagged(.)"/>
        <xsl:sequence select="local:fetch-constraint(.)"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="imvert:package">
        <xsl:choose>
            <xsl:when test="not(imf:boolean($compare-system-packages)) and (@origin eq 'system')">
                <!-- do not compare -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="local:fetch-this(.)"/>
                <xsl:sequence select="local:fetch-local-package(.)"/>
                <xsl:sequence select="local:fetch-identification(.)"/>
                <xsl:sequence select="local:fetch-release(.)"/>
                <xsl:sequence select="local:fetch-referencing(.)"/>
                <xsl:sequence select="local:fetch-derivation(.)"/>
                <xsl:sequence select="local:fetch-conceptual(.)"/>
                <xsl:sequence select="local:fetch-tagged(.)"/>
                <xsl:sequence select="local:fetch-constraint(.)"/>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="imvert:class">
        <xsl:sequence select="local:fetch-this(.)"/>
        <xsl:sequence select="local:fetch-local-class(.)"/>
        <xsl:sequence select="local:fetch-identification(.)"/>
        <xsl:sequence select="local:fetch-release(.)"/>
        <xsl:sequence select="local:fetch-derivation(.)"/>
        <xsl:sequence select="local:fetch-tagged(.)"/>
        <xsl:sequence select="local:fetch-constraint(.)"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="imvert:attribute">
        <xsl:sequence select="local:fetch-this(.)"/>
        <xsl:sequence select="local:fetch-local-attribute(.)"/>
        <xsl:sequence select="local:fetch-identification(.)"/>
        <xsl:sequence select="local:fetch-release(.)"/>
        <xsl:sequence select="local:fetch-derivation(.)"/>
        <xsl:sequence select="local:fetch-type(.)"/>
        <xsl:sequence select="local:fetch-cardinality(.)"/>
        <xsl:sequence select="local:fetch-tagged(.)"/>
        <xsl:sequence select="local:fetch-constraint(.)"/>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="imvert:association">
        <xsl:sequence select="local:fetch-this(.)"/>
        <xsl:sequence select="local:fetch-local-association(.)"/>
        <xsl:sequence select="local:fetch-identification(.)"/>
        <xsl:sequence select="local:fetch-release(.)"/>
        <xsl:sequence select="local:fetch-derivation(.)"/>
        <xsl:sequence select="local:fetch-type(.)"/>
        <xsl:sequence select="local:fetch-cardinality(.)"/>
        <xsl:sequence select="local:fetch-tagged(.)"/>
        <xsl:sequence select="local:fetch-constraint(.)"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="text()">
        <!-- ignore -->
    </xsl:template>
    
    <!-- 
        thematische functies, gegeven exact af wat er moet worden vergeleken. 
    -->
    
    <xsl:function name="local:fetch-this">
        <xsl:param name="this"/>
        <xsl:sequence select="local:create-row($this,false())"/>
    </xsl:function>
    
    <xsl:function name="local:fetch-identification">
        <xsl:param name="this"/>
        <xsl:sequence select="local:create-row($this/imvert:id-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:name)"/>
        <xsl:sequence select="local:create-row($this/imvert:alias)"/>
        <xsl:sequence select="local:create-row($this/imvert:namespace)"/>
        <xsl:sequence select="local:create-row($this/imvert:stereotype)"/>
        <xsl:sequence select="local:create-row($this/imvert:trace)"/>
        <xsl:sequence select="local:create-row($this/imvert:scope)"/>
        <xsl:sequence select="local:create-row($this/imvert:visibility)"/>
    </xsl:function>
    
    <xsl:function name="local:fetch-release">
        <xsl:param name="this"/>
        <xsl:sequence select="local:create-row($this/imvert:version)"/>
        <xsl:sequence select="local:create-row($this/imvert:release-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:phase)"/>
        <xsl:sequence select="local:create-row($this/imvert:documentation-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:author)"/>
        <xsl:sequence select="local:create-row($this/imvert:created-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:modified-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:web-location)"/>
        <xsl:sequence select="local:create-row($this/imvert:location)"/>
        <!-- TODO concepts -->
    </xsl:function>
    
    <xsl:function name="local:fetch-referencing">
        <xsl:param name="this"/>
        <!-- only one -->
        <xsl:sequence select="local:create-row($this/imvert:ref-version)"/>
        <xsl:sequence select="local:create-row($this/imvert:ref-release)"/>
        <xsl:sequence select="local:create-row($this/imvert:ref-master)"/>
    </xsl:function>
    
    <xsl:function name="local:fetch-derivation">
        <xsl:param name="this"/>
        <xsl:sequence select="local:create-row($this/imvert:derived)"/>
        <xsl:sequence select="local:create-row($this/imvert:metamodel)"/>
    </xsl:function>
    
    <xsl:function name="local:fetch-type">
        <xsl:param name="this"/>
        <xsl:sequence select="local:create-row($this/imvert:type-name)"/>
        <xsl:sequence select="local:create-row($this/imvert:type-id-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:type-package)"/>
        <xsl:sequence select="local:create-row($this/imvert:baretype)"/>
    </xsl:function>
    
    <xsl:function name="local:fetch-cardinality">
        <xsl:param name="this"/>
        <xsl:sequence select="local:create-row($this/imvert:min-occurs)"/>
        <xsl:sequence select="local:create-row($this/imvert:max-occurs)"/>
        <xsl:sequence select="local:create-row($this/imvert:min-occurs-source)"/>
        <xsl:sequence select="local:create-row($this/imvert:max-occurs-source)"/>
    </xsl:function>
    
    <xsl:function name="local:fetch-tagged">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/imvert:tagged-values/imvert:tagged-value">
            <xsl:sort select="imvert:name"/>
            <xsl:sequence select="local:create-row(.)"/>
        </xsl:for-each>
    </xsl:function>
    
   <xsl:function name="local:fetch-constraint">
        <xsl:param name="this"/>
        <!--todo-->
    </xsl:function>
   
    <xsl:function name="local:fetch-conceptual">
        <xsl:param name="this"/>
        <xsl:sequence select="local:create-row($this/imvert:conceptual-schema-namespace)"/>
        <xsl:sequence select="local:create-row($this/imvert:conceptual-schema-version)"/>
        <xsl:sequence select="local:create-row($this/imvert:conceptual-schema-phase)"/>
        <xsl:sequence select="local:create-row($this/imvert:conceptual-schema-author)"/>
        <xsl:sequence select="local:create-row($this/imvert:conceptual-schema-type)"/>
    </xsl:function>
    
    <!-- local for application, package, class, attriute or association -->
    <xsl:function name="local:fetch-local-application">
        <xsl:param name="this"/>
        
        <xsl:sequence select="local:create-row($this/imvert:subpath)"/>
        <xsl:sequence select="local:create-row($this/imvert:project-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:generated-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:generator)"/>
        <xsl:sequence select="local:create-row($this/imvert:exported-REMOVE)"/>
        <xsl:sequence select="local:create-row($this/imvert:exporter)"/>
        
    </xsl:function>
    
    <xsl:function name="local:fetch-local-package">
        <xsl:param name="this"/>
        
    </xsl:function>
    
    <xsl:function name="local:fetch-local-class">
        <xsl:param name="this"/>
        
        <xsl:sequence select="local:create-row($this/imvert:abstract)"/>
        <xsl:sequence select="local:create-row($this/imvert:designation)"/>
        <xsl:sequence select="local:create-row($this/imvert:origin)"/>
        <xsl:sequence select="local:create-row($this/imvert:pattern)"/>
        <xsl:sequence select="local:create-row($this/imvert:union)"/>
        <xsl:sequence select="local:create-row($this/imvert:primitive)"/>
        <xsl:sequence select="local:create-row($this/imvert:ref-master)"/>
        <xsl:sequence select="local:create-row($this/imvert:conceptual-schema-class-name)"/>
        <xsl:sequence select="local:create-row($this/imvert:subpackage)"/>
        
    </xsl:function>
    
    <xsl:function name="local:fetch-local-attribute">
        <xsl:param name="this"/>
        
        <xsl:sequence select="local:create-row($this/imvert:maxLength)"/>
        <xsl:sequence select="local:create-row($this/imvert:fraction-digits)"/>
        <xsl:sequence select="local:create-row($this/imvert:total-digits)"/>
        <xsl:sequence select="local:create-row($this/imvert:data-location)"/>
        <xsl:sequence select="local:create-row($this/imvert:position)"/>
        <xsl:sequence select="local:create-row($this/imvert:attribute-type-name)"/>
        <xsl:sequence select="local:create-row($this/imvert:attribute-type-designation)"/>
        <xsl:sequence select="local:create-row($this/imvert:copy-down-type-id)"/>
        <xsl:sequence select="local:create-row($this/imvert:conceptual-schema-type)"/>
        
    </xsl:function>
    
    <xsl:function name="local:fetch-local-association">
        <xsl:param name="this"/>
        
        <xsl:sequence select="local:create-row($this/imvert:aggregation)"/>
        <xsl:sequence select="local:create-row($this/imvert:position)"/>
        <xsl:sequence select="local:create-row($this/imvert:copy-down-type-id)"/>
        <xsl:sequence select="local:create-row($this/imvert:source-name)"/>
        <xsl:sequence select="local:create-row($this/imvert:source-alias)"/>
        <xsl:sequence select="local:create-row($this/imvert:target-name)"/>
        <xsl:sequence select="local:create-row($this/imvert:target-alias)"/>
        
    </xsl:function>
    
    <xsl:function name="local:create-row" as="element()*">
        <xsl:param name="element" as="element()*"/>
        <xsl:sequence select="local:create-row($element,true())"/>
    </xsl:function>
    
    <xsl:function name="local:create-row" as="element()*">
        <xsl:param name="element" as="element()*"/>
        <xsl:param name="as-property" as="xs:boolean"/>
        <xsl:for-each select="$element">
             <xsl:variable name="element-id" as="xs:string+">
                 <xsl:for-each select="$element/ancestor-or-self::*">
                     <xsl:variable name="is-root" select="local-name(../..) = 'packages'"/>
                     <xsl:choose>
                         <xsl:when test="local-name() = 'packages'">IM</xsl:when>
                         <xsl:when test="local-name() = 'package'">{local:get-safe-name(imvert:name)}</xsl:when>
                         <xsl:when test="local-name() = 'class'">{local:get-safe-name(imvert:name)}</xsl:when>
                         <xsl:when test="local-name() = 'attribute'">{local:get-safe-name(imvert:name)}</xsl:when>
                         <xsl:when test="local-name() = 'association'">{local:get-safe-name(imvert:name)}</xsl:when>
                         <xsl:when test="local-name() = 'source'">{local:get-safe-name(imvert:role)}</xsl:when>
                         <xsl:when test="local-name() = 'target'">{local:get-safe-name(imvert:role)}</xsl:when>
                         <xsl:when test="local-name() = 'tagged-value'">{if ($is-root) then 'AA_TV' else 'TV'}{local:get-safe-name(imvert:name)}</xsl:when>
                         <xsl:when test="empty(*)">{local-name()}</xsl:when>
                     </xsl:choose>
                 </xsl:for-each>
             </xsl:variable>
             <xsl:element name="{string-join($element-id,'_')}">
                 <xsl:for-each select="$element/ancestor-or-self::*">
                     <xsl:variable name="stereo" select="local:get-stereo(.)"/>
                     <xsl:choose>
                         <xsl:when test="local-name() = 'package'">
                             <xsl:attribute name="domain">{imvert:name/@original}</xsl:attribute>
                             <xsl:attribute name="domain-stereo">{$stereo}</xsl:attribute>
                         </xsl:when>
                         <xsl:when test="local-name() = 'class'">
                             <xsl:attribute name="class">{imvert:name/@original}</xsl:attribute>
                             <xsl:attribute name="class-stereo">{$stereo}</xsl:attribute>
                         </xsl:when>
                         <xsl:when test="local-name() = ('attribute','association')">
                             <xsl:attribute name="attass">{imvert:name/@original}</xsl:attribute>
                             <xsl:attribute name="attass-stereo">{$stereo}</xsl:attribute>
                         </xsl:when>
                         <xsl:when test="local-name() = ('source','target')">
                             <xsl:attribute name="attass">{imvert:role/@original}</xsl:attribute>
                             <xsl:attribute name="attass-stereo">{$stereo}</xsl:attribute>
                         </xsl:when>
                         <!-- TODO rollen -->
                         <xsl:when test="local-name() = ('tagged-value')">
                             <xsl:variable name="value">{imvert:value}</xsl:variable>
                             <xsl:attribute name="property">{imvert:name/@original}</xsl:attribute>
                             <xsl:attribute name="value">{normalize-space($value)}</xsl:attribute>
                             <xsl:attribute name="property-stereo">TAGGED VALUE</xsl:attribute>
                         </xsl:when>
                         <xsl:when test="not($as-property)">
                             <xsl:attribute name="property"><!--leeg--></xsl:attribute>
                         </xsl:when>
                         <xsl:when test="empty(*)">
                             <xsl:variable name="value">{.}</xsl:variable>
                             <xsl:attribute name="property">{local-name()}</xsl:attribute>
                             <xsl:attribute name="value">{normalize-space($value)}</xsl:attribute>
                         </xsl:when>
                     </xsl:choose>
                 </xsl:for-each>
             </xsl:element>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="local:get-safe-name" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="encoded" as="xs:string*">
            <xsl:analyze-string select="$name" regex="[A-Za-z0-9]+">
                <xsl:matching-substring>
                    <xsl:value-of select="."/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex=".">
                        <xsl:matching-substring>
                            <xsl:value-of select="'_' || string-to-codepoints(.) || '_'"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($encoded,'')"/>
    </xsl:function>
    
    <xsl:function name="local:get-stereo" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:value-of select="string-join($this/imvert:stereotype,', ')"/>
    </xsl:function>
    
</xsl:stylesheet>
