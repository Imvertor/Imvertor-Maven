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
    
    xmlns:cs="http://www.imvertor.org/metamodels/conceptualschemas/model/v20181210"
    xmlns:cs-ref="http://www.imvertor.org/metamodels/conceptualschemas/model-ref/v20181210"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    version="3.0">
    
    <!-- 
        There may be conceptual schema's referenced within the UML. 
        These should be replaced by the concrete schema's. 
        The association between conceptual and concrete schemas is recorded in a conceptual-schemas mapping file.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:import href="../common/Imvert-common-conceptual-map.xsl"/>
   
    <xsl:variable name="stylesheet-code">CSCH</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:variable name="n" select="if (imf:boolean(imf:get-xparm('cli/creategmlprofile'))) then imf:get-xparm('cli/gmlprofilename') else lower-case(imf:get-xparm('cli/owner'))"/>
    <xsl:variable name="pn" select="imf:merge-parms($n) || '-gml'"/>
    
    <xsl:template match="/imvert:packages">
    
        <!--
            profile name is when createprofile, use profilename, else use owner name.
            the profile name is required when XSD is created and when imports are resolved, so set this xparm here,.
        -->
        <xsl:sequence select="imf:set-xparm('appinfo/gml-profile-name',$pn)"/><!-- #300 fix -->
        <xsl:sequence select="imf:set-xparm('appinfo/gml-profile-name-encoded',encode-for-uri($pn))"/>
    
        <imvert:packages>
            <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-svn-id',$conceptual-schema-mapping/svn-id)"/>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
        
    </xsl:template>
    
    <xsl:template match="imvert:package">
        <xsl:choose>
            <xsl:when test="imf:is-conceptual(.)">
                <xsl:variable name="maps" select="imf:get-conceptual-schema-map(imvert:namespace,$conceptual-schema-mapping-name)"/>
                <xsl:variable name="map" select="$maps[cs:constructs/cs:Construct/cs:name = current()/imvert:class/imvert:name]"/><!-- select the map that declares any of the conceptual constructs -->
                <xsl:choose>
                    <xsl:when test="exists($map[2])">
                        <xsl:sequence select="imf:msg('FATAL','More than one applicable map for namespace [1] when using mapping [2]',(imvert:namespace,$conceptual-schema-mapping-name))"/>
                    </xsl:when>
                    <xsl:when test="exists($map)">
                        <!-- replace this by the concrete package -->
                        <imvert:package>
                            <xsl:apply-templates mode="conceptual">
                                <xsl:with-param name="map" select="$map"/>
                            </xsl:apply-templates>
                        </imvert:package>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:msg('ERROR','Cannot determine a map for namespace [1] when using mapping [2]',(imvert:namespace,$conceptual-schema-mapping-name))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <xsl:template match="imvert:package/imvert:namespace" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)+"/>
        
        <!-- #300 Location moet de locatie zijn van het GML profiel als dat voor dit specifieke model is gegenereerd -->
        <xsl:variable name="location" as="xs:string">
            <xsl:choose>
                <xsl:when test="$map/cs:namespace = 'http://www.opengis.net/gml/3.2' and imf:boolean(imf:get-xparm('cli/creategmlprofile'))">
                    <xsl:value-of select="'gml/3.2/' || $pn || '.xsd'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$map/cs:location"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-name',$map/cs:id)"/>
        <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-namespace',.)"/>
        <xsl:sequence select="imf:create-output-element('imvert:namespace',$map/cs:namespace)"/>
        <xsl:sequence select="imf:create-output-element('imvert:location',$location)"/>
        <xsl:sequence select="imf:create-output-element('imvert:owner',$map/cs:owner)"/>
        <!--
             when a release is specified, use that, only when known; otherise take the default release as defined in map
        -->
        <xsl:variable name="specified-release" select="../imvert:release"/>
        <xsl:variable name="known-releases" select="$map/cs:release"/> <!-- may be multiple -->
        
        <xsl:if test="empty($map/cs:owner)">
            <xsl:sequence select="imf:msg(..,'ERROR','No owner specified for conceptual map [1]',$map/cs:id)"/>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="exists($specified-release) and not($specified-release = $known-releases)">
                <xsl:sequence select="imf:msg(..,'ERROR','No such release [1] configured for external package known as [2]',($specified-release,.))"/>
            </xsl:when>
            <xsl:when test="exists($specified-release)">
                <xsl:sequence select="imf:create-output-element('imvert:release',$specified-release)"/>
            </xsl:when>
            <xsl:when test="empty($known-releases)">
                <xsl:sequence select="imf:msg(..,'ERROR','No release specified and no known releases',())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-output-element('imvert:release',$known-releases[last()])"/>
            </xsl:otherwise>
        </xsl:choose>
     
    </xsl:template>
    
    <!-- replace the short name by the short name configured in the conceptual map --> 
    <xsl:template match="imvert:package/imvert:short-name" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)"/>
        <xsl:sequence select="imf:create-output-element('imvert:short-name',imf:resolve-cs-ref($map/cs:forSchema/cs-ref:ConceptualSchemaRef,'ConceptualSchema')/cs:shortName)"/>
    </xsl:template>
   
    <xsl:template match="imvert:package/imvert:version" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)"/>
        <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-version',.)"/>
        <xsl:sequence select="imf:create-output-element('imvert:version',$map/cs:version)"/>
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:phase" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)"/>
        <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-phase',.)"/>
        <xsl:sequence select="imf:create-output-element('imvert:phase',$map/cs:phase)"/>
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:release" mode="conceptual">
        <!-- remove; is reset in other template -->
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:author" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)"/>
        <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-author',.)"/>
        <xsl:sequence select="imf:create-output-element('imvert:author','(system)')"/>
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:svn-string" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)"/>
        <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-svn-string',.)"/>
        <xsl:sequence select="imf:create-output-element('imvert:svn-string','(unspecified)')"/>
    </xsl:template>
    
    <xsl:template match="imvert:package/imvert:class" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)"/>
        <imvert:class>
            <xsl:apply-templates mode="conceptual">
                <xsl:with-param name="map" select="$map"/>
            </xsl:apply-templates>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:name" mode="conceptual">
        <xsl:param name="map" as="element(cs:Map)"/>
        <xsl:variable name="mapped-construct" select="$map//cs:Construct[cs:name = current()/@original]"/>
        <xsl:choose>
            <xsl:when test="$mapped-construct">
                <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-class-name',.)"/>
                <imvert:name> <!-- TODO eigenlijk moet deze imvert:name weg. Altijd de juiste construct oplossen als je betreffende schema aan het maken bent, via conceptual schema... -->
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="$mapped-construct/cs:xsdTypes/cs:XsdType/cs:name"/>
                </imvert:name>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR','Cannot determine an element name for interface name [1] when using mapping [2]',(.,$conceptual-schema-mapping-name))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="
        imvert:attribute[imvert:type-id]/imvert:type-name | 
        imvert:supertype[imvert:type-id]/imvert:type-name |
        imvert:supertype[imvert:type-id]/imvert:xsd-substitutiongroup">
        <!-- check if the type is taken from a conceptual schema package -->
        <xsl:variable name="is-intern" select="exists(ancestor::imvert:package[imvert:package-replacement = 'internal'])"/>
        <xsl:variable name="class" select="imf:get-construct-by-id(../imvert:type-id)"/>
        
        <xsl:if test="count($class) gt 1">
            <xsl:sequence select="imf:msg(.,'FATAL', 'Multiple classes found with same ID: [1]',../imvert:type-id)"/>
        </xsl:if>
        
        <xsl:variable name="pack" select="$class/ancestor::imvert:package[imvert:namespace][1]"/>
        
        <xsl:choose>
            <xsl:when test="$is-intern">
                <!-- when taken from intern, all external references are already resolved. -->
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="../imvert:conceptual-schema-type">
                <!--TODO: for now, assume resolved; however proxies should be resolved more robust, see VNG REDMINE 490086 -->
                <xsl:comment>TODO may not be resolved!</xsl:comment>
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="empty($class)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test=". = $name-none">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="imf:is-conceptual($class)">
                <!-- class in a conceptual schema package -->
                <xsl:variable name="original-name" select="@original"/>
                <xsl:variable name="map" select="imf:get-conceptual-schema-map($pack/imvert:namespace,$conceptual-schema-mapping-name)"/>
                <xsl:variable name="construct" select="$map/cs:constructs/cs:Construct[(cs:originalName,cs:name)[1] = $original-name]"/>
                <xsl:variable name="mapped-xsd-type" select="$construct/cs:xsdTypes/cs:XsdType"/>
                <xsl:variable name="mapped-oas-type" select="$construct/cs:oasTypes/cs:OasType"/>
                <xsl:choose>
                    <xsl:when test="empty($map)">
                        <xsl:sequence select="imf:msg(..,'ERROR','Cannot determine the map for namespace [1]',($pack/imvert:namespace))"/>
                    </xsl:when>
                    <xsl:when test="empty($construct)">
                        <xsl:sequence select="imf:msg(..,'ERROR','Cannot find a construct [1] in the map for namespace [2]',($original-name, $pack/imvert:namespace))"/>
                    </xsl:when>
                    <xsl:when test="exists($mapped-xsd-type) or exists($mapped-oas-type)">
                        <xsl:sequence select="imf:create-output-element('imvert:conceptual-schema-type',.)"/>
                        <xsl:if  test="$mapped-xsd-type">
                            <xsl:if test="imf:boolean($mapped-xsd-type/cs:primitive)">
                                <xsl:sequence select="imf:create-output-element('imvert:primitive',$mapped-xsd-type/cs:name)"/>
                            </xsl:if>
                            <xsl:sequence select="imf:create-output-element(name(.),$mapped-xsd-type/cs:name)"/>
                            <xsl:variable name="att-name" select="$mapped-xsd-type/cs:asAttribute"/>
                            <xsl:variable name="att-desig" select="$mapped-xsd-type/cs:asAttributeDesignation"/>
                            <xsl:variable name="att-hasNilreason" select="$mapped-xsd-type/cs:hasNilreason"/>
                            <xsl:variable name="is-union-element" select="parent::imvert:attribute/imvert:stereotype/@id = ('stereotype-name-union-element')"/>
                            <xsl:choose>
                                <!-- when in context of attribute, and not a union element, check if an asAttribute is specified -->
                                <xsl:when test="parent::imvert:attribute and $att-name and not($is-union-element)">
                                    <xsl:sequence select="imf:create-output-element('imvert:attribute-type-name',$att-name)"/>
                                    <xsl:sequence select="imf:create-output-element('imvert:attribute-type-designation',$att-desig)"/>
                                    <xsl:sequence select="imf:create-output-element('imvert:attribute-type-hasnilreason',$att-hasNilreason)"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if  test="$mapped-oas-type">
                            <xsl:if test="imf:boolean($mapped-oas-type/cs:primitive)">
                                <xsl:sequence select="imf:create-output-element('imvert:primitive-oas',$mapped-oas-type/cs:name)"/>
                            </xsl:if>
                            <xsl:sequence select="imf:create-output-element('imvert:type-name-oas',$mapped-oas-type/cs:name)"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <?x er is geen reden om te waarschuwen dat een type mapping niet bestaat, wanneer geen schema's worden gegenereerd. Die melding moet pas op dat moment worden gedaan.  
                        <xsl:sequence select="imf:msg(..,'WARNING','No type mapping found for [1] in namespace [2] when using mapping [3]',($original-name,$pack/imvert:namespace,$conceptual-schema-mapping-name))"/>
                        x?>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*" mode="conceptual #default">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
