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
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    xmlns:ekf="http://EliotKimber/functions"

    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <!-- 
        This stylesheet pre-processes the UML in accordance with 10-129r1_Geography_Markup_Language_GML_Version_3.3.pdf 
          
        This is:
          
        1/ Introduce collection class when required.
        2/ Create ref packages when buildcollection is requested.s
          
    -->
    
    <xsl:template match="/">
        <xsl:sequence select="imf:track('Preforming schemas',())"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- 1  introduce collection class -->
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-product')]">
        <xsl:variable name="collection-name" select="concat(imvert:name,imf:get-config-parameter('imvertor-translate-suffix-components'))"/>
        <xsl:variable name="collection-id" select="concat('collection_', generate-id(.))"/>
        <xsl:variable name="collection-package-name" select="../imvert:name"/>
        <xsl:variable name="is-includable" select="imf:boolean(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-INCLUDABLE'))"/>
        <xsl:variable name="collection-class" as="element()?">
            <!-- when no collection type class referenced, roll your own --> 
            <!-- IM-110 but only when buildcollection yes -->
            <xsl:if test="imf:boolean($buildcollection)">
                <xsl:if test="empty(imf:get-tagged-value(.,'##CFG-TV-ENVELOPEMETHOD'))">
                    <xsl:if test="not(imvert:associations/imvert:association/imvert:type-id[imf:get-construct-by-id(.)/imvert:stereotype/@id = ('stereotype-name-collection')])">
                        <xsl:sequence select="imf:msg('INFO','Catalog class [1] ([2]) does not include any collection. Appending [3].', (string(imf:get-construct-name(.)), string-join(imvert:stereotype,', '),$collection-name))"/>
                        <imvert:class>
                            <xsl:sequence select="imf:create-output-element('imvert:id',$collection-id)"/>
                            <xsl:sequence select="imf:create-output-element('imvert:name',$collection-name)"/>
                            <imvert:stereotype id="stereotype-name-collection">
                                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-collection')"/>
                            </imvert:stereotype>
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
                            <imvert:tagged-values>
                                <imvert:tagged-value id="CFG-TV-INCLUDABLE" origin="system">
                                    <imvert:value><xsl:value-of select="$is-includable"/></imvert:value>
                                </imvert:tagged-value>
                            </imvert:tagged-values>
                        </imvert:class>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="super-classes" select="imf:get-superclasses(.)"/>
        <xsl:variable name="super-products" select="$super-classes[imvert:stereotype/@id = ('stereotype-name-product','stereotype-name-process','stereotype-name-service')]"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[not(self::imvert:associations)]"/>
            <imvert:associations>
                <xsl:apply-templates select="imvert:associations/imvert:association">
                    <xsl:with-param name="is-includable" select="$is-includable"/>
                </xsl:apply-templates>
                <!-- 
                    IM-136 
                    alleen deze constructie als geen subtype van een ander product.
                -->
                <xsl:if test="$collection-class and empty($super-products)">
                    <xsl:variable name="allow-multiple-collections" select="imf:boolean(imf:get-config-parameter('imvertor-allow-multiple-collections'))"/>
                    <imvert:association>
                        <xsl:sequence select="imf:create-output-element('imvert:name',imf:get-config-parameter('imvertor-translate-association-components'))"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-name',$collection-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-id',$collection-id)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-package',$collection-package-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:min-occurs','1')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:max-occurs',if ($allow-multiple-collections) then 'unbounded' else '1')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:position','999')"/>
                    </imvert:association>
                </xsl:if>
            </imvert:associations>
        </xsl:copy>
        
        <xsl:sequence select="$collection-class"/>
    </xsl:template>
    
    <xsl:template match="imvert:association">
        <xsl:param name="is-includable"/>
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <imvert:tagged-values>
                <imvert:tagged-value id="CFG-TV-INCLUDABLE" origin="system">
                    <imvert:value><xsl:value-of select="$is-includable"/></imvert:value>
                </imvert:tagged-value>
            </imvert:tagged-values>
        </xsl:copy>
    </xsl:template>
    
    <!-- 2 Create ref packages -->
    
    <xsl:template match="imvert:package">
        <!-- copy the package -->
        <xsl:next-match/>
        
        <xsl:variable name="identifiable-classes" select="imvert:class[imf:is-linkable(.)]"/>

        <!-- 
            Check if a reference package is required.
            A reference package is created only for domain packages, that have at least one class that is linkable.
        -->
        <xsl:if test="
            imf:boolean($buildcollection)
            and (imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-view-package')) 
            and $identifiable-classes">
           
            <!-- some of the classes are identifiable, so create a new package -->
            <xsl:variable name="namespace" select="imvert:namespace"/>
            <imvert:package origin="system">
                <xsl:variable name="gs" as="element()?">
                    <p>(Generated schema)</p>
                </xsl:variable>
                <xsl:sequence select="imf:create-output-element('imvert:id',imf:get-ref-id(.))"/>
                <xsl:sequence select="imf:create-output-element('imvert:name',imf:get-ref-name(.))"/>
                <xsl:sequence select="imf:create-output-element('imvert:short-name',concat(imvert:short-name,imf:get-config-parameter('reference-suffix-short')))"/>
                <xsl:sequence select="imf:create-output-element('imvert:namespace',imf:get-ref-namespace(.))"/>
                <xsl:sequence select="imf:create-output-element('imvert:documentation',$gs,(),false())"/>
                <xsl:sequence select="imf:create-output-element('imvert:author','(System)')"/>
                <xsl:sequence select="imf:create-output-element('imvert:version',(imvert:ref-version,imvert:version)[1])"/>
                <xsl:sequence select="imf:create-output-element('imvert:release',(imvert:ref-release,imvert:release)[1])"/> 
                <xsl:sequence select="imf:create-output-element('imvert:ref-master',imvert:name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:ref-master-id',imvert:id)"/>
                <xsl:apply-templates select="$identifiable-classes" mode="identifiable"/>
            </imvert:package>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="identifiable">
        <!-- an identifiable class -->
        <imvert:class>
            <xsl:variable name="gc" as="element()">
                <p>(Generated class)</p>
            </xsl:variable>
            <xsl:sequence select="imf:create-output-element('imvert:id',imf:get-ref-id(.))"/>
            <xsl:sequence select="imf:create-output-element('imvert:name',imf:get-ref-name(.))"/>
            <xsl:sequence select="imf:create-output-element('imvert:abstract','false')"/>
            <xsl:sequence select="imf:create-output-element('imvert:documentation',$gc,(),false())"/>
            <xsl:sequence select="imf:create-output-element('imvert:author','(System)')"/>
            <xsl:sequence select="imf:create-output-element('imvert:ref-master',imvert:name)"/>
            <xsl:sequence select="imf:create-output-element('imvert:ref-master-id',imvert:id)"/>
            <imvert:stereotype id="stereotype-name-system-reference-class">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-system-reference-class')"/>
            </imvert:stereotype>
        </imvert:class>
    </xsl:template>
    
    <xsl:function name="imf:get-ref-id" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="concat($this/imvert:id,imf:get-config-parameter('reference-suffix-id'))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-ref-name" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="concat($this/imvert:name,imf:get-config-parameter('reference-suffix-name'))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-ref-namespace" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="concat($this/imvert:namespace,'-ref')"/>
    </xsl:function>
    
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
