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
   
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:functx="http://www.functx.com"
    
    xmlns:StUF="http://www.stufstandaarden.nl/onderlaag/stuf0302"
    xmlns:metadata="http://www.stufstandaarden.nl/metadataVoorVerwerking" 
   
    xmlns:gml="http://www.opengis.net/gml"
    
    exclude-result-prefixes="xsl UML imvert imvert ekf"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/extension/Imvert-common-text.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:include href="Imvert2XSD-KING-common.xsl"/>
    <xsl:include href="Imvert2XSD-KING-common-checksum.xsl"/>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8" exclude-result-prefixes="#all"/>
    
    <xsl:variable name="stylesheet-code">BES</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>

    <xsl:variable name="xsd-application-folder-path" select="imf:get-config-string('system','xsd-application-folder-path')"/>
    <xsl:variable name="allow-comments-in-schema" select="true() or $debug = 'true'"/>
    
    <xsl:variable 
        name="external-schema-names" 
        select="$imvert-document//imvert:package[imvert:stereotype=(imf:get-config-stereotypes(('stereotype-name-external-package','stereotype-name-system-package')))]/imvert:name" 
        as="xs:string*"/>
    
    <xsl:variable name="elementFormDefault" select="if (imf:boolean(imf:get-config-string('cli','elementisqualified','yes'))) then 'qualified' else 'unqualified'"/>
    <xsl:variable name="attributeFormDefault" select="if (imf:boolean(imf:get-config-string('cli','attributeisqualified','no'))) then 'qualified' else 'unqualified'"/>
   
    <xsl:variable name="all-simpletype-attributes" select="//imvert:attribute[empty(imvert:type)]"/> <!-- needed for disambiguation of duplicate attribute names -->
    
    <xsl:variable name="StUF-prefix" select="'StUF'"/>
   
    <xsl:template match="/">
        <xsl:apply-templates select="imvert:packages"/>
    </xsl:template>
    
    <xsl:template match="imvert:packages">
        
        <xsl:variable name="schemas">
            <schemas>
                <xsl:apply-templates select="imvert:package"/>
            </schemas>
        </xsl:variable>
        
        <!-- check validity of schema -->
       <?skip <xsl:apply-templates select="$schemas" mode="xsd-test"/> ?>
        
        <xsl:sequence select="$schemas"/>
    </xsl:template>
    
    <xsl:template match="imvert:package">
        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        <xsl:variable name="pack-version" select="$pack/@xsd-version"/>
        <xsl:variable name="target-namespace" select="$pack/@xsd-target-namespace"/>
        
        <!-- als er één construct is die subsetting is, dan moet je de onderliggende schema's invoegen -->
        <xsl:variable name="is-subset-derived" select="exists(.//imvert:subset-info[imf:boolean(imvert:is-subsetting)])"/>
        
        <xsl:variable name="main-prefix" select="imf:get-config-string('appinfo','xsd-short-name')"/>
        <xsl:variable name="main-version" select="imf:get-config-string('appinfo','xsd-version')"/>
        
        <xsl:variable name="includes" select="if ($is-subset-derived) then concat($pack-prefix,$pack-version) else ()"/>
        <xsl:variable name="i-am" select="concat($main-prefix,$main-version)"/>
        
        <xsl:sequence select="imf:track('Creating schema for [1]',$target-namespace)"/>
        
        <xsl:variable name="schema" as="element(schema)">
            <schema 
                version="{$pack-version}" 
                prefix="{$pack-prefix}" 
                target-namespace="{$target-namespace}" 
                attribute-form-default="{$attributeFormDefault}" 
                element-form-default="{$elementFormDefault}"
                >
                
                <xsl:if test="$includes">
                    <xsl:attribute name="includes" select="$includes"/>
                </xsl:if>
                <xsl:attribute name="i-am" select="$i-am"/>
            
                <xsl:choose>
                    <xsl:when test="$is-subset-derived">
                        <ent-part>
                            <xs:include schemaLocation="../../{$includes}/entiteiten/{$includes}_ent_basis.xsd"/>
                            
                            <xsl:for-each select="imvert:xsd-import">
                                <xs:import schemaLocation="{$i-am}_{@xsd-prefix}{@xsd-version}_ent_basis.xsd" namespace="{@xsd-target-namespace}" imvert-xsd-prefix="{@xsd-prefix}"/>    
                            </xsl:for-each>
                            
                            <xs:import schemaLocation="../../0302/stuf0302.xsd" namespace="http://www.stufstandaarden.nl/onderlaag/stuf0302" />
                            <xs:import schemaLocation="../../gml-3.1.1.2/gml/3.1.1/base/gml.xsd" namespace="http://www.opengis.net/gml" />
                        
                        </ent-part>
                    </xsl:when>
                    <xsl:otherwise>
                        <ent-part>
                            <xsl:for-each select="imvert:xsd-import">
                                <xs:import schemaLocation="{$i-am}_{@xsd-prefix}{@xsd-version}_ent_basis.xsd" namespace="{@xsd-target-namespace}" imvert-xsd-prefix="{@xsd-prefix}"/>
                            </xsl:for-each>
                            
                            <xs:import schemaLocation="../../0302/stuf0302.xsd" namespace="http://www.stufstandaarden.nl/onderlaag/stuf0302" />
                            <xs:import schemaLocation="../../gml-3.1.1.2/gml/3.1.1/base/gml.xsd" namespace="http://www.opengis.net/gml" />

                        </ent-part>           
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:choose>
                    <xsl:when test="$is-subset-derived">
                        <dat-part>
                            <xs:include schemaLocation="../../{$includes}/entiteiten/{$includes}_datatypes.xsd"/>
                     
                            <xsl:for-each select="imvert:xsd-import">
                                <xs:import schemaLocation="{@xsd-prefix}{@xsd-version}_datatypes.xsd" namespace="{@xsd-target-namespace}" imvert-xsd-prefix="{@xsd-prefix}"/>
                            </xsl:for-each>
                            
                            <xs:import schemaLocation="../../0302/stuf0302.xsd" namespace="http://www.stufstandaarden.nl/onderlaag/stuf0302" />
                            <xs:import schemaLocation="../../gml-3.1.1.2/gml/3.1.1/base/gml.xsd" namespace="http://www.opengis.net/gml" />
                  
                        </dat-part>
                    </xsl:when>
                    <xsl:otherwise>
                        <dat-part>
                            <xsl:for-each select="imvert:xsd-import">
                                <xs:import schemaLocation="{$i-am}_{@xsd-prefix}{@xsd-version}_datatypes.xsd" namespace="{@xsd-target-namespace}" imvert-xsd-prefix="{@xsd-prefix}"/>
                            </xsl:for-each>

                            <xs:import schemaLocation="../../0302/stuf0302.xsd" namespace="http://www.stufstandaarden.nl/onderlaag/stuf0302" />
                            <xs:import schemaLocation="../../gml-3.1.1.2/gml/3.1.1/base/gml.xsd" namespace="http://www.opengis.net/gml" />

                        </dat-part>
                    </xsl:otherwise>
                </xsl:choose>
                
                <ent-part>
                    <xsl:if test="not($is-subset-derived)">
                        <xs:attribute name="entiteittype" type="{$StUF-prefix}:Entiteittype"/>  
                    </xsl:if>
                </ent-part>
                
                <ent-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van Basistypen *** ')"/>
                    
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-objecttype')]" mode="mode-global-objecttype"/>
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-referentielijst')]" mode="mode-global-objecttype"/>
                    <!--<xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-relatieklasse')]" mode="mode-global-objecttype"/>-->
                </ent-part>
                
                <ent-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van Associatietypen *** ')"/>
                    
                    <xsl:for-each-group 
                        select=".//imvert:association[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-relatiesoort')]" 
                        group-by="imf:get-compiled-name(.)">
                        <xsl:apply-templates select="current-group()[1]" mode="mode-global-association-type"/>
                    </xsl:for-each-group>
                </ent-part>
                
                <ent-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van matchgegevens *** ')"/>
                    
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-objecttype')]" mode="mode-global-matchgegevens"/>
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-referentielijst')]" mode="mode-global-matchgegevens"/>
                    <!--<xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-relatieklasse')]" mode="mode-global-matchgegevens"/>-->
                </ent-part>
                
                <ent-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van gegevensgroeptypen *** ')"/>
                    
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-composite')]" mode="mode-global-gegevensgroeptype">
                        <xsl:with-param name="matchgegevens" select="false()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-composite')]" mode="mode-global-gegevensgroeptype">
                        <xsl:with-param name="matchgegevens" select="true()"/>
                    </xsl:apply-templates>
                </ent-part>
                
                <dat-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van simple types *** ')"/>
                    
                    <xsl:for-each-group 
                        select=".//imvert:attribute[empty(imvert:type-id)]" 
                        group-by="imf:useable-attribute-name(imf:get-compiled-name(.),.)">
                        <xsl:apply-templates select="current-group()[1]" mode="mode-global-attribute-simpletype"/>
                    </xsl:for-each-group>
                </dat-part>
                
                <ent-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van niet-simpletypes *** ')"/>
                    
                    <xsl:for-each-group 
                        select=".//imvert:attribute[exists(imvert:type-id) and empty(imvert:conceptual-schema-type)]" 
                        group-by="imf:get-compiled-name(.)">
                        <xsl:apply-templates select="current-group()[1]" mode="mode-global-attribute-niet-simpletype"/>
                    </xsl:for-each-group>
                </ent-part>
                
                <dat-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van Externe typen *** ')"/>
                    
                    <xsl:for-each-group 
                        select=".//imvert:attribute[exists(imvert:conceptual-schema-type)]" 
                        group-by="imvert:baretype">
                        <xsl:apply-templates select="current-group()[1]" mode="mode-global-attribute-niet-simpletype"/>
                    </xsl:for-each-group>
                </dat-part>
                
                <dat-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van Complex datatypes *** ')"/>
                    
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-complextype')]" mode="mode-global-complextype"/>
                </dat-part>
                
                <dat-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van Enumeraties *** ')"/>
                    
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-enumeration')]" mode="mode-global-enumeration"/>
                </dat-part>
                
                <dat-part>
                    <xsl:sequence select="imf:create-debug-comment(' *** Declaratie van Unions *** ')"/>
                    
                    <xsl:apply-templates select=".//imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-union')]" mode="mode-global-union"/>
                </dat-part>
            </schema>
                       
        </xsl:variable>
        
        <xsl:sequence select="$schema"/>
        
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="mode-global-objecttype">
        
        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="superclasses" select="imf:get-superclass(.)"/>
        <xsl:variable name="subclasses" select="imf:get-subclasses(.)"/>
        <xsl:variable name="concrete-subclasses" select="$subclasses[not(imf:boolean(imvert:abstract))]"/>
        
        <xsl:variable name="is-supertype" select="exists($subclasses)"/>
        <xsl:variable name="is-subtype" select="exists($superclasses)"/>

        <xsl:variable name="base-for-history" select="if ($is-subtype) then (., $superclasses) else ."/>
        <xsl:variable name="attributes" select="imf:get-all-attributes($base-for-history)"/>
        <xsl:variable name="hisform-on-attributes" select="$attributes[imf:get-history(.)[1]]"/>
        <xsl:variable name="hismate-on-attributes" select="$attributes[imf:get-history(.)[2]]"/>
        
        <xsl:variable name="basis-body" as="element()*">
            <xs:sequence>
                <xsl:sequence select="imf:create-debug-comment('mode-global-objecttype (Attributes)')"/>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-attribute"/>
                
                <xsl:sequence select="imf:create-debug-comment('mode-global-objecttype (Compositie relaties)')"/>
                <xsl:apply-templates select="imvert:associations/imvert:association[imvert:aggregation = 'composite']" mode="mode-local-composition">
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates>
                
                <xsl:if test="not($is-supertype)">
                    <xsl:if test="imf:is-authentiek(.)">
                        <xs:element name="authentiek" type="{$StUF-prefix}:StatusMetagegeven-basis" minOccurs="0" maxOccurs="unbounded"/> <!--DONE bg:authentiek-TODO -->
                    </xsl:if>
                    <xsl:if test="imf:is-in-onderzoek(.)">
                        <xs:element name="inOnderzoek" type="{$StUF-prefix}:StatusMetagegeven-basis" minOccurs="0" maxOccurs="unbounded"/>
                    </xsl:if>
                    
                    <xsl:if test="not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst'))">
                        <xs:element ref="{$StUF-prefix}:tijdvakGeldigheid" minOccurs="0"/>
                        <xs:element ref="{$StUF-prefix}:tijdstipRegistratie" minOccurs="0"/>
                        <xs:element ref="{$StUF-prefix}:extraElementen" minOccurs="0"/>
                        <xs:element ref="{$StUF-prefix}:aanvullendeElementen" minOccurs="0"/>
                    </xsl:if>       
                    
                    <xsl:if test="$hismate-on-attributes">
                        <xs:element name ="historieMaterieel" 
                            type="{concat(imf:get-effective-prefix(.), ':', imf:get-effective-name(.),imf:get-effective-suffix(.,false()))}" 
                            minOccurs="0"
                            maxOccurs="unbounded"/>
                    </xsl:if>
                    <xsl:if test="$hisform-on-attributes">
                        <xs:element name="historieFormeel" 
                            type="{concat(imf:get-effective-prefix(.), ':', imf:get-effective-name(.),imf:get-effective-suffix(.,false()))}"  
                            minOccurs="0" 
                            />  
                    </xsl:if>
                </xsl:if>
                            
                <xsl:sequence select="imf:create-debug-comment('mode-global-objecttype (Associations: uitgaand)')"/>
                <xsl:apply-templates select="imvert:associations/imvert:association[not(imvert:aggregation = 'composite')]" mode="mode-local-association">
                    <xsl:with-param name="richting">uitgaand</xsl:with-param>
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates>
            </xs:sequence>
            
            <xsl:choose>
                <xsl:when test="$is-supertype and $is-subtype">
                   <!-- none -->
                </xsl:when>
                <xsl:when test="$is-supertype">
                    <xs:attributeGroup ref="{$StUF-prefix}:entiteit"/> 
                </xsl:when>
                <xsl:when test="$is-subtype">
                    <xs:attribute ref="{$pack-prefix}:entiteittype" fixed="{imf:get-entiteittype(.)}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xs:attribute ref="{$pack-prefix}:entiteittype" fixed="{imf:get-entiteittype(.)}"/>
                    <xs:attributeGroup ref="{$StUF-prefix}:entiteit"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Algo 20170501 Vervolgstap -->
        <xsl:variable name="super-basis" as="node()+">
            <xsl:sequence select="imf:create-debug-comment('mode-global-objecttype (A supertype required choices, Vervolgstap)')"/>
            <xs:complexType name="{concat(imf:get-effective-name(.),imf:get-effective-suffix(.,false()))}">
                <xs:choice minOccurs="0" maxOccurs="{count($concrete-subclasses)}">
                    <xsl:for-each select="$concrete-subclasses">
                        <xs:element name="{imvert:name}" type="{concat(imf:get-effective-prefix(.), ':', imf:get-effective-name(.),imf:get-effective-suffix(.,false()))}"/>
                    </xsl:for-each>
                </xs:choice>
            </xs:complexType>
            <xs:complexType name="{concat(imf:get-effective-name(.),'-matchgegevens')}">
                <xs:complexContent>
                    <xs:restriction base="{concat(imf:get-effective-prefix(.),':',imf:get-effective-name(.),imf:get-effective-suffix(.,false()))}">
                        <xs:choice minOccurs="1" maxOccurs="{count($concrete-subclasses)}">
                            <xsl:for-each select="$concrete-subclasses">
                                <xs:element name="{imvert:name}" type="{concat(imf:get-effective-prefix(.), ':', imf:get-effective-name(.),'-matchgegevens')}"/> <!-- TODO 1 -->
                            </xsl:for-each>
                        </xs:choice>
                    </xs:restriction>
                </xs:complexContent>
            </xs:complexType>
        </xsl:variable>
        
        <xsl:variable name="declaration">
            <xsl:choose> <!-- TODO DONE ComplexType PES-basis moet een extension zijn van SUB-abstract -->
                <xsl:when test="$is-subtype and exists($superclasses[2])">  <!-- no example -->
                    <xsl:sequence select="imf:msg(.,'ERROR','Unable to define subtype for multiple supertypes: [1]',string-join($superclasses[1]/imvert:name/@original,', '))"/>
                </xsl:when>
                
                <xsl:when test="$is-subtype and $is-supertype"> <!-- e.g. PES -->
                    <xsl:sequence select="imf:create-debug-comment(concat('mode-global-objecttype Objecttype is sub- and supertype # ',imvert:name/@original))"/>
                    <xs:complexType name="{imf:get-effective-name(.)}-super">
                        <xsl:sequence select="imf:create-annotation(.)"/>
                        <xs:complexContent>
                            <xs:extension base="{concat(imf:get-effective-prefix(.),':',imf:get-effective-name($superclasses[1]),'-super')}">
                                <xsl:sequence select="$basis-body"/>     
                            </xs:extension>
                        </xs:complexContent>
                    </xs:complexType>
                    
                    <xsl:sequence select="$super-basis"/>
                </xsl:when>
                
                <xsl:when test="$is-supertype">  <!-- e.g. SUB -->
                    <xsl:sequence select="imf:create-debug-comment(concat('mode-global-objecttype Objecttype is supertype but not subtype# ',imvert:name/@original))"/>
                    <xs:complexType name="{imf:get-effective-name(.)}-super">
                        <xsl:sequence select="imf:create-annotation(.)"/>
                        <xsl:sequence select="$basis-body"/>
                    </xs:complexType>
                    
                    <xsl:sequence select="$super-basis"/>
                </xsl:when>
                
                <xsl:when test="$is-subtype"> <!-- e.g. NPS -->
                    <xsl:sequence select="imf:create-debug-comment(concat('mode-global-objecttype Objecttype is subtype # ',imvert:name/@original))"/>
                    <xs:complexType name="{imf:get-effective-name(.)}{imf:get-effective-suffix(.,false())}">
                        <xsl:sequence select="imf:create-annotation(.)"/>
                        <xs:complexContent>
                            <xs:extension base="{concat(imf:get-effective-prefix(.),':',imf:get-effective-name($superclasses[1]),'-super')}">
                                <xsl:sequence select="$basis-body"/>     
                            </xs:extension>
                        </xs:complexContent>
                    </xs:complexType>
                </xsl:when>
                
                <xsl:otherwise>  <!-- e.g. PND maar ook RON referentietabel -->
                    <xsl:sequence select="imf:create-debug-comment(concat('mode-global-objecttype Objecttype is not a subtype or supertype # ',imvert:name/@original))"/>
                    <xs:complexType name="{imf:get-effective-name(.)}{imf:get-effective-suffix(.,false())}">
                        <xsl:sequence select="imf:create-annotation(.)"/>
                        <xsl:sequence select="$basis-body"/>
                    </xs:complexType>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="imf:create-subset-class-marker(.,$declaration)"/>
           
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="mode-global-matchgegevens">

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:variable name="matchgegevens-att" select="imvert:attributes/imvert:attribute[starts-with(imf:get-taggedvalue(.,'##CFG-TV-INDICATIEMATCHGEGEVEN'),'J')]"/>
        <xsl:variable name="matchgegevens-ass" select="imvert:associations/imvert:association[starts-with(imf:get-taggedvalue(.,'##CFG-TV-INDICATIEMATCHGEGEVEN'),'J') and not(imvert:aggregation = 'composite')]"/>
       
        <!-- determine if associations to groups with matchgegevens exist -->
        <xsl:variable name="matchgegevens-cmp" as="element(imvert:association)*">
            <xsl:for-each select="imvert:associations/imvert:association[imvert:aggregation = 'composite']">
                <xsl:variable name="defining-class" select="imf:get-by-id(imvert:type-id)"/>
                <xsl:variable name="is-group" select="$defining-class/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')"/>
                <xsl:variable name="has-matchgegeven" select="for $att in $defining-class/imvert:attributes/imvert:attribute return starts-with(imf:get-taggedvalue($att,'##CFG-TV-INDICATIEMATCHGEGEVEN'),'J')"/>
                <xsl:if test="$is-group and imf:boolean-or($has-matchgegeven)">
                  <xsl:sequence select="."/>
                </xsl:if> 
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="superclasses" select="imf:get-superclasses(.)"/>
        <xsl:variable name="subclasses" select="imf:get-subclasses(.)"/>
        <xsl:variable name="is-subtype" select="exists($superclasses)"/>
        <xsl:variable name="is-supertype" select="exists($subclasses)"/>
        <xsl:variable name="is-abstract" select="imf:boolean(imvert:abstract)"/>
        
        <xsl:variable name="body-kern">
            <xs:sequence>
                <!-- attributes in order found -->
                <xsl:apply-templates select="$matchgegevens-att" mode="mode-local-attribute">
                    <xsl:with-param name="matchgegevens" select="true()"/>
                </xsl:apply-templates>
                <!-- assocations sorted -->
                <xsl:apply-templates select="$matchgegevens-cmp" mode="mode-local-composition">
                    <xsl:with-param name="matchgegevens" select="true()"/>
                    <xsl:sort select="@type-display-name"/><!-- de naam van de groep als basis voor opeenvolging -->
                </xsl:apply-templates>
                <xsl:apply-templates select="$matchgegevens-ass" mode="mode-local-association">
                    <xsl:with-param name="matchgegevens" select="true()"/>
                    <xsl:with-param name="richting" select="'uitgaand'"/>
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates>
            </xs:sequence>
        </xsl:variable>
        
        <xsl:variable name="declaration">
            <xsl:if test="not($is-abstract)">
                <xsl:sequence select="imf:create-debug-comment(concat('mode-global-matchgegevens matchgegevens # ',@display-name))"/>
                <xs:complexType name="{imf:get-effective-name(.)}-matchgegevens"> <!-- TODO 1 -->
                    <xs:complexContent>
                        <xs:restriction base="{imf:get-effective-prefix(.)}:{imf:get-effective-name(.)}{imf:get-effective-suffix(.,false())}">
                            <xsl:sequence select="$body-kern"/>
                            <xs:attribute ref="{$pack-prefix}:entiteittype" fixed="{imf:get-entiteittype(.)}" use="required"/>
                            <xs:attribute name="scope" type="{$StUF-prefix}:StUFScope" use="prohibited"/>
                        </xs:restriction>
                    </xs:complexContent>
                </xs:complexType>
            </xsl:if>
        </xsl:variable>
        <xsl:sequence select="imf:create-subset-class-marker(.,$declaration)"/>
                
    </xsl:template>
    
    <!-- Groepsattribuutsoort -->
    <xsl:template match="imvert:class" mode="mode-global-gegevensgroeptype">
        <xsl:param name="matchgegevens" select="false()"/>
        
        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('mode-global-gegevensgroeptype Groepsattribuutsoort # ',@display-name))"/>
        
        <xsl:variable name="seq" as="element(xs:sequence)">
            <xs:sequence minOccurs="0">
                <xsl:sequence select="imf:create-debug-comment('mode-global-gegevensgroeptype (Attributes)')"/>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-attribute">
                    <xsl:with-param name="matchgegevens" select="$matchgegevens"/>
                </xsl:apply-templates>
                <xsl:sequence select="imf:create-debug-comment('mode-global-gegevensgroeptype (Groepen)')"/>
                <xsl:apply-templates select="imvert:associations/imvert:association[imvert:aggregation = 'composite']" mode="mode-local-composition">
                    <xsl:with-param name="matchgegevens" select="$matchgegevens"/>
                    <xsl:sort select="@type-display-name"/><!-- de naam van de groep als basis voor opeenvolging -->
                </xsl:apply-templates>
                <xsl:sequence select="imf:create-debug-comment('mode-global-gegevensgroeptype (Associations)')"/>
                <xsl:apply-templates select="imvert:associations/imvert:association[not(imvert:aggregation = 'composite')]" mode="mode-local-association">
                    <xsl:with-param name="matchgegevens" select="$matchgegevens"/>
                    <xsl:with-param name="richting">uitgaand</xsl:with-param>
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates>
            </xs:sequence>
        </xsl:variable>
     
         <xsl:choose>
             <xsl:when test="$matchgegevens and empty($seq/*)">
                 <xsl:sequence select="imf:create-debug-comment('Matchgegevens requested, but none found.')"/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:variable name="declaration">
                     <xs:complexType name="{imf:capitalize($compiled-name)}{imf:get-effective-suffix(.,$matchgegevens)}">
                         <xsl:choose>
                             <xsl:when test="$matchgegevens and exists($seq/*)">
                                 <xsl:sequence select="imf:create-debug-comment('Matchgegevens requested, some found.')"/>
                                 <xs:complexContent>
                                     <xs:restriction base="{imf:get-effective-prefix(.)}:{imf:capitalize($compiled-name)}{imf:get-effective-suffix(.,false())}">
                                         <xsl:sequence select="$seq"/>
                                     </xs:restriction>
                                 </xs:complexContent>
                             </xsl:when>
                             <xsl:otherwise>
                                 <xsl:sequence select="$seq"/>
                             </xsl:otherwise>
                         </xsl:choose>
                     </xs:complexType>
                 </xsl:variable>
                 <xsl:sequence select="imf:create-subset-class-marker(.,$declaration)"/>
             </xsl:otherwise>
         </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="mode-global-complextype">

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('mode-global-complextype Complextype # ',imvert:name/@original))"/>
        <xs:complexType name="{imf:capitalize($compiled-name)}-e">
            <xs:complexContent>
                <xs:extension base="{$pack-prefix}:{imf:capitalize($compiled-name)}">
                    <xs:attribute name="noValue" type="{$StUF-prefix}:NoValue"/>
                </xs:extension>
            </xs:complexContent>
        </xs:complexType>
        <xs:complexType name="{imf:capitalize($compiled-name)}"> 
            <xs:sequence minOccurs="0">
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-attribute"/>
            </xs:sequence>
        </xs:complexType>
      
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="mode-global-enumeration">

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('mode-global-enumeration Enumeration # ',imvert:name/@original))"/>
        
        <xs:complexType name="{imf:capitalize($compiled-name)}-e"> 
            <xs:simpleContent>
                <xs:extension base="{$pack-prefix}:{imf:capitalize($compiled-name)}">
                    <xs:attribute name="noValue" type="{$StUF-prefix}:NoValue"/>
                </xs:extension>
            </xs:simpleContent>
        </xs:complexType>
        
        <xs:simpleType name="{imf:capitalize($compiled-name)}">
            <xs:restriction base="xs:string">
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-enum"/>
                <xs:enumeration value=""/><!--Bug #488638-->
            </xs:restriction>
        </xs:simpleType>
        
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="mode-global-union">

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('mode-global-union Union # ',imvert:name/@original))"/>
        <xs:complexType name="{imf:capitalize($compiled-name)}-e">
            <xs:complexContent>
                <xs:extension base="{$pack-prefix}:{imf:capitalize($compiled-name)}">
                    <xs:attribute name="noValue" type="{$StUF-prefix}:NoValue"/>
                </xs:extension>
            </xs:complexContent>
        </xs:complexType>
        <xs:complexType name="{imf:capitalize($compiled-name)}"> 
            <xs:choice minOccurs="0">
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-attribute"/>
            </xs:choice>
        </xs:complexType>
        
    </xsl:template>
    
    
    <!-- LOCAL SUBSTRUCTURES -->
    
    <!--
        Een attribuut heeft een type. Dat type is bepalend, behalve wanneer het een referentie tabel is. 
        Dan moet (alléén) de type info van het matchgegeven attribuut worden opgehaald van die tabelentiteit.
        -->
    <xsl:template match="imvert:attribute" mode="mode-local-attribute">
        <xsl:param name="matchgegevens" select="false()"/>
       
        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="this-attribute" select="."/>

        <xsl:variable name="compiled-name" select="imf:get-compiled-name($this-attribute)"/>
        
        <xsl:variable name="cardinality" select="imf:get-cardinality($this-attribute)"/>
        <xsl:variable name="history" select="imf:get-history($this-attribute)"/>
        
        <xsl:variable name="this-is-complextype" select="imf:get-stereotype($this-attribute/../..) = imf:get-config-stereotypes('stereotype-name-complextype')"/>
   
        <xsl:variable name="this-type" select="imf:get-class($this-attribute)"/>
        
        <xsl:variable name="type-is-referentietabel" select="imf:get-stereotype($this-type) = imf:get-config-stereotypes('stereotype-name-referentielijst')"/>
        
        <!-- when referentietabel, assume the attribute is the is-id attribute of the referentie tabel -->
        <xsl:variable name="applicable-attribute" select="if ($type-is-referentietabel) then $this-type//imvert:attribute[imf:boolean(imvert:is-id)] else $this-attribute"/>
        
        <xsl:variable name="type" select="imf:get-class($applicable-attribute)"/>
  
        <xsl:variable name="compiled-name-type" select="imf:get-compiled-name($type)"/>
        
        <xsl:variable name="type-is-datatype" select="$type/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-simpletype')"/>
        <xsl:variable name="type-is-complextype" select="$type/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-complextype')"/>
        
        <xsl:variable name="type-is-scalar-non-emptyable" select="$applicable-attribute/imvert:type-name = ('scalar-integer','scalar-decimal')"/>
        <xsl:variable name="type-is-scalar-empty" select="$applicable-attribute/imvert:type-name = ('scalar-date','scalar-year','scalar-yearmonth','scalar-datetime','scalar-postcode','scalar-boolean')"/>
        <xsl:variable name="type-is-enumeration" select="imf:get-stereotype($type) = imf:get-config-stereotypes('stereotype-name-enumeration')"/>
        <xsl:variable name="type-is-union" select="imf:get-stereotype($type) = imf:get-config-stereotypes('stereotype-name-union')"/>
        
        <xsl:variable name="type-is-external" select="exists($applicable-attribute/imvert:conceptual-schema-type)"/>
        
        <xsl:variable name="scalar-att-type" select="imf:get-stuf-scalar-attribute-type($applicable-attribute)"/>
        
        <xsl:variable name="min-occurs" select="if ($this-is-complextype or $matchgegevens) then 1 else 0"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('mode-local-attribute Local attribute # ',@display-name))"/>
        
        <xsl:choose>
            
            <xsl:when test="$matchgegevens and not(starts-with(imf:get-taggedvalue(.,'##CFG-TV-INDICATIEMATCHGEGEVEN'),'J'))">
                <!-- het is geen matchgegeven, dus laat weg. -->
            </xsl:when>
            
            <xsl:when test="$type-is-scalar-empty">
                <xsl:sequence select="imf:create-debug-comment('Scalar en kan leeg worden; Case: Type is een voorgedefinieerd type')"/>
                <xs:element
                    name="{$compiled-name}" 
                    type="{$scalar-att-type}" 
                    minOccurs="{$min-occurs}" 
                    maxOccurs="{$cardinality[4]}"
                    >
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="$type-is-enumeration">
                <xsl:sequence select="imf:create-debug-comment('Een enumeratie; Case: Type verwijst naar enumeratie')"/>
                <xs:element
                    name="{$compiled-name}" 
                    type="{imf:get-effective-prefix($this-type)}:{imf:capitalize($compiled-name-type)}-e" 
                    minOccurs="{$min-occurs}"  
                    maxOccurs="{$cardinality[4]}"
                    >
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="$type-is-union">
                <xsl:sequence select="imf:create-debug-comment('Een union; Case: Type verwijst naar union')"/>
                <xs:element
                    name="{$compiled-name}" 
                    type="{imf:get-effective-prefix($this-type)}:{imf:capitalize($compiled-name-type)}-e" 
                    minOccurs="{$min-occurs}" 
                    maxOccurs="{$cardinality[4]}"
                    >
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                </xs:element>
            </xsl:when>
            
            <!--Type is tabel entiteit -->
            <xsl:when test="not($applicable-attribute is $this-attribute)">
                <xsl:sequence select="imf:create-debug-comment('Attribute redirected to referentie tabel; Case: Type verwijst naar tabelentiteit')"/>

                <xsl:variable name="applicable-compiled-name" select="imf:get-compiled-name($applicable-attribute)"/>
                
                <xsl:variable name="checksum-strings" select="imf:get-blackboard-simpletype-entry-info($applicable-attribute)"/>
                <xsl:variable name="checksum-string" select="imf:store-blackboard-simpletype-entry-info($checksum-strings)"/>
                <xs:element
                    name="{$compiled-name}" 
                    type="{imf:get-effective-prefix($this-type)}:{imf:capitalize(imf:useable-attribute-name($applicable-compiled-name,.))}-e" 
                    minOccurs="{$min-occurs}" 
                    maxOccurs="{$cardinality[4]}"
                    imvert-checksum="{$checksum-string}"
                    >
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                    <xsl:if test="$type-is-scalar-non-emptyable">
                        <xsl:attribute name="nillable">true</xsl:attribute>
                    </xsl:if>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="$type-is-complextype"><!-- DONE Complex datatype niet goed geïmplementeerd -->
                <xsl:sequence select="imf:create-debug-comment('Een complex datatype Case: Type verwijst naar complex-datatype')"/>
                <xs:element
                    name="{$compiled-name}" 
                    type="{imf:get-effective-prefix($this-type)}:{imf:capitalize($compiled-name-type)}-e" 
                    minOccurs="{$min-occurs}" 
                    maxOccurs="{$cardinality[4]}"
                    >
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="$type-is-external">
                <xsl:sequence select="imf:create-debug-comment('Een extern type; Case: Type verwijst naar interface')"/>
                <xsl:variable name="external-type-name" select="imvert:baretype"/>
                <xs:element
                    name="{$compiled-name}" 
                    type="{imf:get-effective-prefix($this-type)}:{imf:capitalize($external-type-name)}-e" 
                    minOccurs="{$min-occurs}" 
                    maxOccurs="{$cardinality[4]}"
                    >
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                </xs:element>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment('Een simpel datatype; Else:  Custom type')"/> 

                <xsl:variable name="applicable-compiled-name" select="imf:get-compiled-name($applicable-attribute)"/>
                
                <xsl:variable name="checksum-strings" select="imf:get-blackboard-simpletype-entry-info(.)"/>
                <xsl:variable name="checksum-string" select="imf:store-blackboard-simpletype-entry-info($checksum-strings)"/>

                <xs:element
                    name="{$compiled-name}" 
                    type="{$pack-prefix}:{imf:capitalize(imf:useable-attribute-name($applicable-compiled-name,.))}-e" 
                    minOccurs="{$min-occurs}" 
                    maxOccurs="{$cardinality[4]}"
                    imvert-checksum="{$checksum-string}"
                    >
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                    <xsl:if test="$type-is-scalar-non-emptyable">
                        <xsl:attribute name="nillable">true</xsl:attribute>
                    </xsl:if>
                </xs:element>
            </xsl:otherwise>
            
        </xsl:choose>
            
       
    </xsl:template>
    
    <xsl:function name="imf:get-external-type-name">
        <xsl:param name="attribute"/>
        <xsl:param name="as-type" as="xs:boolean"/>
        <!-- determine the name; hard koderen -->
        <xsl:for-each select="$attribute"> <!-- singleton -->
            <xsl:choose>
                <xsl:when test="imvert:type-package='Geography Markup Language 3'">
                    <xsl:variable name="type-suffix" select="if ($as-type) then 'Type' else ''"/>
                    <xsl:variable name="type-prefix">
                        <xsl:choose>
                            <xsl:when test="empty(imvert:conceptual-schema-type)">
                                <xsl:sequence select="imf:msg(.,'ERROR','No conceptual schema type specified',())"/>
                            </xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Point'">gml:Point</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Curve'">gml:Curve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Surface'">gml:Surface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiPoint'">gml:MultiPoint</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiSurface'">gml:MultiSurface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiCurve'">gml:MultiCurve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Geometry'">gml:Geometry</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiGeometry'">gml:MultiGeometry</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_ArcString'">gml:ArcString</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_LineString'">gml:LineString</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Polygon'">gml:Polygon</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Object'">gml:GeometryProperty</xsl:when><!-- see http://www.geonovum.nl/onderwerpen/geography-markup-language-gml/documenten/handreiking-geometrie-model-en-gml-10 -->
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Primitive'">gml:Primitive</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Position'">gml:Position</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_PointArray'">gml:PointArray</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Solid'">gml:Solid</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_OrientableCurve'">gml:OrientableCurve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_OrientableSurface'">gml:OrientableSurface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_CompositePoint'">gml:CompositePoint</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiSolid'">gml:MultiSolid</xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the [1] type [2]', (imvert:type-package,imvert:conceptual-schema-type))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="concat($type-prefix,$type-suffix)"/>
               </xsl:when>
                <xsl:when test="empty(imvert:type-package)">
                    <!-- TODO -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- geen andere externe packages bekend -->
                    <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the external package [1]', imvert:type-package)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:function>
    
    <xsl:template match="imvert:attribute[imf:stub-ignored-properties(.)]" mode="#all">
        <!-- skip this -->
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="mode-local-enum">
        
        <!-- STUB De naam van een enumeratie is die overgenomen uit SIM. Niet camelcase. Vooralsnog ook daar ophalen. -->
        <xsl:sequence select="imf:create-debug-comment(concat('mode-local-attribute Local enum # ',@display-name))"/>
        
        <xsl:variable name="supplier" select="imf:get-trace-suppliers-for-construct(.,1)[@project='SIM'][1]"/>
        <xsl:variable name="construct" select="if ($supplier) then imf:get-trace-construct-by-supplier($supplier,$imvert-document) else ()"/>
        <xsl:variable name="SIM-name" select="($construct/imvert:name, imvert:name)[1]"/>
       
        <xs:enumeration value="{$SIM-name}"/>
        
    </xsl:template>

    <xsl:template match="imvert:association[imf:stub-ignored-properties(.)]" mode="#all">
        <!-- skip this -->
    </xsl:template>
    
    <!-- dit betreft echte relaties, dus geen composities -->
    <xsl:template match="imvert:association" mode="mode-local-association">
        <xsl:param name="matchgegevens" select="false()"/>
        <xsl:param name="richting" select="'uitgaand'"/>
        
        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        <xsl:variable name="cardinality" select="imf:get-cardinality(.)"/>
        <xsl:variable name="history" select="imf:get-history(.)"/>
        
        <xsl:variable name="source" select="ancestor::imvert:class"/>
        
        <xsl:variable name="target" select="imf:get-class(.)"/>
        
        <xsl:variable name="assoc-name" select="imvert:name"/> <!-- was: concat(imvert:name,imf:capitalize($target/imvert:name)), nu met de hand -->
        <xsl:choose>
            <xsl:when test="$matchgegevens and not(starts-with(imf:get-taggedvalue(.,'##CFG-TV-INDICATIEMATCHGEGEVEN'),'J'))">
                <!-- het is geen matchgegeven, dus laat weg. -->
            </xsl:when>
            <xsl:when test="$richting = 'uitgaand'">
                <xsl:sequence select="imf:create-debug-comment(concat('mode-local-association Uitgaande relatie # ',@display-name))"/>
                
                <xsl:variable name="heen-typeref" select="concat(imf:get-effective-prefix(.), ':', imf:get-effective-name(.),imf:get-effective-suffix(.,$matchgegevens))"/>
                
                <xsl:variable name="has-form-his" select="$history[1]"/>
                <xsl:variable name="has-mat-his" select="$history[2]"/>
                
                <xsl:variable name="target-minoccurs" select="if ($matchgegevens) then 1 else 0"/>
                <xsl:variable name="target-cardinality" select="if ($has-mat-his and not($has-form-his)) then 'unbounded' else $cardinality[4]"/> <!-- als materiele historie en niet formeel, dan is target altijd unbounded -->
                
                <xs:element
                    name="{$assoc-name}" 
                    type="{$heen-typeref}" 
                    minOccurs="{$target-minoccurs}" 
                    maxOccurs="{$target-cardinality}"
                    > <!-- must be 0, fixed -->
                    <xsl:sequence select="imf:create-historie-attributes($history[1],$history[2])"/>
                </xs:element>
            </xsl:when>
            <xsl:otherwise>
               <!-- er hoeft geen terugrelatie te worden gegenereerd -->
            </xsl:otherwise>
        </xsl:choose>
    
    </xsl:template>
    
    <!-- dit betreft gegevensgroepen, dus composities -->
    <xsl:template match="imvert:association" mode="mode-local-composition">
        <xsl:param name="matchgegevens" select="false()"/>

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:variable name="cardinality" select="imf:get-cardinality(.)"/>
        <xsl:variable name="history" select="imf:get-history(.)"/>
        
        <xsl:variable name="target-minoccurs" select="if ($matchgegevens) then 1 else 0"/>
        
        <xsl:variable name="type" select="imf:get-class(.)"/>
        <xsl:variable name="compiled-name-type" select="imf:get-compiled-name($type)"/>
       
        <xsl:variable name="group-history" select="imf:get-history($type)"/>
        
        <!-- anders dan voor een gewone relatie kijken we naar de Groep zelf om te zien of het een restriction class is. (via imf:get-effective-suffix()) --> 
        <xsl:variable name="suffix" select="imf:get-effective-suffix($type,$matchgegevens)"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('mode-local-composition Association # ',@display-name))"/>
        
        <xs:element
            name="{$compiled-name}" 
            type="{concat(imf:get-effective-prefix($type), ':', $compiled-name-type)}{$suffix}" 
            minOccurs="{$target-minoccurs}" 
            maxOccurs="{$cardinality[4]}"
            >
            <xsl:sequence select="imf:create-historie-attributes($history[1] or $group-history[1],$history[2] or $group-history[2])"/>
        </xs:element>
        
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="mode-global-association-type">
        
        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="source" select="ancestor::imvert:class"/>
        
        <xsl:variable name="target" select="imf:get-class(.)"/>
        
        <xsl:variable name="hisform-on-association" select="imf:get-history(.)[1]"/>
        <xsl:variable name="hismate-on-association" select="imf:get-history(.)[2]"/>
        
        <xsl:variable name="association-class" select="imf:get-by-id(imvert:association-class/imvert:type-id)"/>
        <xsl:variable name="association-class-attributes" select="imf:get-all-attributes($association-class)"/>
        <xsl:variable name="association-class-associations" select="$association-class//imvert:association[not(imvert:aggregation = 'composite')]"/>
        <xsl:variable name="association-class-compositions" select="$association-class//imvert:association[imvert:aggregation = 'composite']"/>
        
        <xsl:variable name="hisform-on-association-attributes" select="$association-class-attributes[imf:get-history(.)[1]]"/>
        <xsl:variable name="hismate-on-association-attributes" select="$association-class-attributes[imf:get-history(.)[2]]"/>
        
        <xsl:variable name="source-alias" select="imf:get-effective-name(imvert:source)"/>
        <xsl:variable name="target-alias" select="imf:get-effective-name(imvert:target)"/>
       
        <xsl:sequence select="imf:create-debug-comment(concat('mode-global-association-type Outgoing Association declaration # ',@display-name))"/>
    
        <xsl:variable name="declaration">
            <xs:complexType name="{imf:get-compiled-name(.)}{imf:get-effective-suffix(.,false())}">
                
                <xsl:sequence select="imf:create-annotation(.)"/>
                
                <xs:sequence minOccurs="0">
                    
                    <xs:element 
                        name="gerelateerde" 
                        type="{imf:get-effective-prefix($target)}:{imf:get-effective-name($target)}{imf:get-effective-suffix($target,false())}"
                        minOccurs="0"/>
                    
                    <!-- add the attributes & associations of the association class, if any -->
                    
                    <xsl:sequence select="imf:create-debug-comment('mode-global-association-type (Attributes)')"/>
                    <xsl:apply-templates select="$association-class-attributes" mode="mode-local-attribute"/>
                    
                    <xsl:sequence select="imf:create-debug-comment('mode-global-association-type (Compositie relaties)')"/>
                    <xsl:apply-templates select="$association-class-compositions" mode="mode-local-composition">
                        <xsl:sort select="imvert:name"/>
                    </xsl:apply-templates>
                    
                    <xsl:if test="imf:property-is-authentiek(.) or (exists($association-class) and imf:is-authentiek($association-class))">
                        <!-- avoid duplicates -->
                        <xs:element name="authentiek" type="{$StUF-prefix}:StatusMetagegeven-basis" minOccurs="0" maxOccurs="unbounded"/><!-- DONE bg:authentiek-TODO -->
                    </xsl:if>
                    <xsl:if test="imf:property-is-in-onderzoek(.) or (exists($association-class) and imf:is-in-onderzoek($association-class))">
                        <xs:element name="inOnderzoek" type="{$StUF-prefix}:StatusMetagegeven-basis" minOccurs="0" maxOccurs="unbounded"/>
                    </xsl:if>
                    
                    <xsl:if test="$hismate-on-association"><!-- DONE HeeftAlsKind heeft geen materiele historie -->
                        <xs:element ref="{$StUF-prefix}:tijdvakRelatie" minOccurs="0"/>                        
                    </xsl:if>
                    
                    <xsl:if test="exists($association-class)">
                        <xs:element ref="{$StUF-prefix}:tijdvakGeldigheid" minOccurs="0"/>
                    </xsl:if>
                    
                    <xs:element ref="{$StUF-prefix}:tijdstipRegistratie" minOccurs="0"/>
                    
                    <!--algo 20170501 <xsl:if test="exists($association-class)">-->
                    <xs:element ref="{$StUF-prefix}:extraElementen" minOccurs="0"/>
                    <xs:element ref="{$StUF-prefix}:aanvullendeElementen" minOccurs="0"/>
                    <!--</xsl:if>-->
                    
                    <xsl:if test="exists($association-class) and exists($hismate-on-association-attributes)">
                        <xs:element name ="historieMaterieel" 
                            type="{concat(imf:get-effective-prefix($target), ':',imf:get-effective-name($target),imf:get-effective-suffix($target,false()))}" 
                            minOccurs="0"     
                            maxOccurs="unbounded"/>
                    </xsl:if>
                    <xsl:if test="exists($association-class) and exists($hisform-on-association-attributes)">
                        <xs:element name="historieFormeel" 
                            type="{concat(imf:get-effective-prefix($target), ':',imf:get-effective-name($target),imf:get-effective-suffix($target,false()))}"  
                            minOccurs="0"/>  
                    </xsl:if>
                    <xsl:if test="$hisform-on-association"> <!-- was: empty($association-class) -->
                        <xs:element name="historieFormeelRelatie" 
                            type="{concat(imf:get-effective-prefix($target), ':',imf:get-effective-name($target),imf:get-effective-suffix($target,false()))}"
                            minOccurs="0"/>  
                    </xsl:if>
                    
                    <xsl:apply-templates select="$association-class-associations" mode="mode-local-association"/>
                    
                </xs:sequence>
                <xs:attribute ref="{$pack-prefix}:entiteittype" fixed="{imf:get-entiteittype(.)}"/>
                <xs:attributeGroup ref="{$StUF-prefix}:entiteit"/>
                
            </xs:complexType>        
        </xsl:variable>
        <xsl:sequence select="imf:create-subset-class-marker(.,$declaration)"/>
                        
        <xsl:variable name="target-is-supertype-label" select="'-matchgegevens'"/>
        <xsl:sequence select="imf:create-debug-comment(concat('mode-global-association-type Outgoing Association matchgegevens # ',@display-name))"/>
        <xs:complexType name="{imf:get-effective-name(.)}-matchgegevens">
            <xs:annotation>    
                <xs:documentation>Matchgegevens van de relatie.</xs:documentation>
            </xs:annotation>
            <xs:complexContent>
                <xs:restriction base="{imf:get-effective-prefix(.)}:{imf:get-effective-name(.)}{imf:get-effective-suffix(.,false())}">
                    <xs:sequence minOccurs="1">
                        <xs:element 
                            name="gerelateerde" 
                            type="{imf:get-effective-prefix($target)}:{imf:get-effective-name($target)}{$target-is-supertype-label}"
                            />
                    </xs:sequence>
                    <xs:attribute ref="{imf:get-effective-prefix(.)}:entiteittype" fixed="{imf:get-entiteittype(.)}" use="required"/>
                    <xs:attribute name="scope" type="{$StUF-prefix}:StUFScope" use="prohibited"/>
                </xs:restriction>
            </xs:complexContent>
        </xs:complexType>
        
     </xsl:template>
    
    <!-- called only with attributes that have no type-id -->
    <xsl:template match="imvert:attribute" mode="mode-global-attribute-simpletype">

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="class" select="../.."/>
        
        <xsl:variable name="compiled-name" select="imf:useable-attribute-name(imf:get-compiled-name(.),.)"/>
        <xsl:variable name="checksum-strings" select="imf:get-blackboard-simpletype-entry-info(.)"/>
        <xsl:variable name="checksum-string" select="imf:store-blackboard-simpletype-entry-info($checksum-strings)"/>
        
        <xsl:variable name="stuf-scalar" select="imf:get-stuf-scalar-attribute-type(.)"/>
        
        <xsl:variable name="max-length" select="imvert:max-length"/>
        <xsl:variable name="total-digits" select="imvert:total-digits"/>
        <xsl:variable name="fraction-digits" select="imvert:fraction-digits"/>
        
        <xsl:variable name="min-waarde" select="imf:get-taggedvalue(.,'##CFG-TV-MINVALUEINCLUSIVE')"/>
        <xsl:variable name="max-waarde" select="imf:get-taggedvalue(.,'##CFG-TV-MAXVALUEINCLUSIVE')"/>
        <xsl:variable name="min-length" select="imf:get-taggedvalue(.,'##CFG-TV-MINLENGTH')"/>
        <xsl:variable name="patroon" select="imf:get-taggedvalue(.,'##CFG-TV-FORMALPATTERN')"/>
        
        <xsl:variable name="nillable-patroon" select="if (normalize-space($patroon)) then concat('(', $patroon,')?') else ()"/>
        
        <xsl:variable name="is-subset-class" select="imf:boolean($class/imvert:subset-info/imvert:is-subset-class)"/>
        
        <xsl:variable name="facetten">
            <xsl:sequence select="imf:create-facet('xs:pattern',$nillable-patroon)"/>
            <xsl:sequence select="imf:create-facet('xs:minInclusive',$min-waarde)"/>
            <xsl:sequence select="imf:create-facet('xs:maxInclusive',$max-waarde)"/>
            <xsl:sequence select="imf:create-facet('xs:minLength',$min-length)"/>
            <xsl:sequence select="imf:create-facet('xs:maxLength',$max-length)"/>
            <xsl:sequence select="imf:create-facet('xs:totalDigits',$total-digits)"/>
            <xsl:sequence select="imf:create-facet('xs:fractionDigits',$fraction-digits)"/>
        </xsl:variable>
        
        <xsl:variable name="name" select="imf:capitalize($compiled-name)"/>
        <xsl:choose>
            <xsl:when test="exists($stuf-scalar)">
                <!-- gedefinieerd in onderlaag -->
            </xsl:when>
            <xsl:when test="$is-subset-class">
                <!-- 
                    de class is gedefinieerd in basisschema waar dit schema een restriction van is ; 
                    de attributen kunnen nooit een ander datatype hebben dan daarin is gedefinieerd. 
                -->
            </xsl:when>
            <xsl:when test="exists(imvert:type-name)">
                <xsl:sequence select="imf:create-debug-comment(concat('mode-global-attribute-simpletype Attribuut type (simple) # ',@display-name))"/>
                <xs:complexType name="{$name}-e" imvert-checksum="{$checksum-string}">
                    <xs:simpleContent>
                        <xs:extension base="{imf:get-effective-prefix(.)}:{$name}" imvert-checksum="{$checksum-string}">
                            <xs:attribute name="noValue" type="{$StUF-prefix}:NoValue"/>
                            <xsl:if test="empty($nillable-patroon)">
                                <xs:attribute name="wildcard" type="{$StUF-prefix}:Wildcard"/>
                            </xsl:if>
                        </xs:extension>
                    </xs:simpleContent>
                </xs:complexType>
                <xs:simpleType name="{$name}" imvert-checksum="{$checksum-string}">
                    <xsl:choose>
                        <xsl:when test="imvert:type-name = 'scalar-integer'">
                            <xs:restriction base="xs:integer">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-string'">
                            <xs:restriction base="xs:string">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-decimal'">
                            <xs:restriction base="xs:decimal">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-boolean'">
                            <xs:restriction base="xs:boolean">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-date'">
                            <xs:restriction base="xs:dateTime">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-txt'">
                            <xs:restriction base="xs:string">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>    
                        <xsl:when test="imvert:type-name = 'scalar-uri'">
                            <xs:restriction base="xs:anyURI">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-postcode'">
                            <xs:restriction base="{$StUF-prefix}:postcode">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-year'">
                            <xs:restriction base="xs:gYear">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-month'">
                            <xs:restriction base="xs:gMonth">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-day'">
                            <xs:restriction base="xs:gDay">
                                <xsl:sequence select="$facetten"/>
                            </xs:restriction>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the simple attribute type: [1]', imvert:type-name)"/>
                        </xsl:otherwise>                
                    </xsl:choose>
                </xs:simpleType>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- called only with attributes that have a type-id -->
    <xsl:template match="imvert:attribute" mode="mode-global-attribute-niet-simpletype">

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:variable name="type" select="imf:get-class(.)"/>
        <xsl:variable name="type-stereo" select="imf:get-stereotype($type)"/>
        <xsl:variable name="compiled-type-name" select="imf:get-compiled-name($type)"/>
        
        <xsl:variable name="type-is-complextype" select="$type-stereo = imf:get-config-stereotypes('stereotype-name-complextype')"/>
        <xsl:variable name="type-is-referentietabel" select="$type-stereo = imf:get-config-stereotypes('stereotype-name-referentielijst')"/>
        <xsl:variable name="type-is-enumeration" select="$type-stereo = imf:get-config-stereotypes('stereotype-name-enumeration')"/>
        <xsl:variable name="type-is-union" select="$type-stereo = imf:get-config-stereotypes('stereotype-name-union')"/>
        <xsl:variable name="type-is-interface" select="$type-stereo = imf:get-config-stereotypes('stereotype-name-interface')"/>
      
        <xsl:variable name="type-is-external" select="exists(imvert:conceptual-schema-type)"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('mode-global-attribute-niet-simpletype Attribuut type (not simple) # ',@display-name))"/>
        
        <xsl:choose>
            <xsl:when test="$type-is-complextype"><!-- DONE removed: Complex datatype niet goed geïmplementeerd -->
                <!--xx
                <xsl:sequence select="imf:create-debug-comment('Type is complex datatype')"/>
                <xs:complexType name="{imf:capitalize($compiled-name)}">
                    <xs:complexContent>
                        <xs:extension base="{concat($prefix,':',imf:capitalize($compiled-type-name))}"/>
                    </xs:complexContent>
                </xs:complexType>
                xx-->
            </xsl:when>
            <xsl:when test="$type-is-referentietabel">
                <!-- skip! je verwijst niet naar referentietabellen maar altijd naar de key daarvan.
                    
                <xsl:sequence select="imf:create-debug-comment('Type is referentie tabel')"/>
                <xs:complexType name="{imf:capitalize($compiled-name)}">
                    <xs:complexContent>
                        <xs:extension base="{concat($prefix,':',imf:capitalize($compiled-type-name),'-basis')}"/>
                    </xs:complexContent>
                </xs:complexType>
                -->
            </xsl:when>
            <!--xx
            <xsl:when test="$type-is-enumeration">
                <xsl:sequence select="imf:create-debug-comment('Type is enumeration')"/>
                <xs:complexType name="{imf:capitalize($compiled-name)}-e">
                    <xs:simpleContent>
                        <xs:extension base="{concat($prefix,':',imf:capitalize($compiled-type-name))}"/>
                    </xs:simpleContent>
                </xs:complexType>
            </xsl:when>
            xx-->
            <xsl:when test="$type-is-enumeration">
                <!-- ook hier niet opnemen -->
            </xsl:when>
            <xsl:when test="$type-is-union">
                <!--xx
                <xsl:sequence select="imf:create-debug-comment('Type is union')"/>
                <xs:complexType name="{imf:capitalize($compiled-name)}-e">
                    <xs:complexContent>
                        <xs:extension base="{$prefix}:{imf:capitalize($compiled-name)}">
                            <xs:attribute name="noValue" type="{$StUF-prefix}:NoValue"/>
                        </xs:extension>
                    </xs:complexContent>
                </xs:complexType>
                <xs:complexType name="{imf:capitalize($compiled-name)}">
                    <xs:complexContent>
                        <xs:extension base="{concat($prefix,':',imf:capitalize($compiled-type-name))}"/>
                    </xs:complexContent>
                </xs:complexType>
            xx-->
            </xsl:when>
            <xsl:when test="$type-is-external">
                <xsl:sequence select="imf:create-debug-comment('Type is external')"/>
                <xs:complexType name="{imf:capitalize(imvert:baretype)}-e">
                    <xs:complexContent>
                        <xs:extension base="{imf:get-external-type-name(.,true())}">
                            <xs:attribute name="noValue" type="StUF:NoValue"/>
                        </xs:extension>
                    </xs:complexContent>
                </xs:complexType>
            </xsl:when>
            <xsl:when test="$type-is-interface">
                <xsl:sequence select="imf:create-debug-comment('Type is interface')"/>
                <xs:complexType name="{imf:capitalize($compiled-name)}-e">
                    <xs:complexContent>
                        <xs:extension base="{$pack-prefix}:{imf:capitalize($compiled-name)}">
                            <xs:attribute name="noValue" type="{$StUF-prefix}:NoValue"/>
                        </xs:extension>
                    </xs:complexContent>
                </xs:complexType>
                <xs:complexType name="{imf:capitalize($compiled-name)}">
                    <xs:complexContent>
                        <xs:extension base="{imf:get-external-type-name(.,true())}"/>
                    </xs:complexContent>
                </xs:complexType>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment(concat('TODO Geen bekend type: ',string-join($type-stereo,';')))"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="mode-global-attribute-referentie-element">

        <xsl:variable name="pack" select="imf:get-package(.)"/>
        <xsl:variable name="pack-prefix" select="$pack/@xsd-prefix"/>
        
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        
        <xsl:variable name="stuf-scalar" select="imf:get-stuf-scalar-attribute-type(.)"/>
        
        <xsl:choose>
            <xsl:when test="exists($stuf-scalar)">
                <xsl:sequence select="imf:create-debug-comment(concat('mode-global-attribute-referentie-element Referentie element 1 # ',imvert:name/@original))"/>
       
                <xs:simpleType name="{concat(imf:capitalize($compiled-name),'-e')}"> 
                    <xs:restriction base="{$stuf-scalar}"/>
                </xs:simpleType>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment(concat('mode-global-attribute-referentie-element Referentie element 2 # ',imvert:name/@original))"/>
                
                <xs:complexType name="{concat(imf:capitalize($compiled-name),'-e')}">
                    <xs:simpleContent>
                        <xs:extension base="{concat($pack-prefix,':',imf:capitalize($compiled-name))}">
                            <xs:attributeGroup ref="{$StUF-prefix}:element"/>
                        </xs:extension>
                    </xs:simpleContent>
                </xs:complexType>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
      
    <xsl:function name="imf:get-compiled-name">
        <xsl:param name="this" as="element()"/>

        <xsl:variable name="pack" select="imf:get-package($this)"/>
        
        <xsl:variable name="type" select="local-name($this)"/>
        <xsl:variable name="stereotype" select="imf:get-stereotype($this)"/>
        <xsl:variable name="alias" select="imf:get-effective-name($this)"/>
        <xsl:variable name="name-raw" select="$this/imvert:name"/>
        <xsl:variable name="name-form" select="replace(imf:strip-accents($name-raw),'[^\p{L}0-9.\-]+','_')"/>
       
        <xsl:variable name="name" select="$name-form"/>
        
        <xsl:choose>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-composite')">
                <xsl:value-of select="$alias"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')">
                <xsl:value-of select="$alias"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse')">
                <xsl:value-of select="$alias"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst')">
                <xsl:value-of select="$alias"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-complextype')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-union')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = imf:get-config-stereotypes('stereotype-name-interface')">
                <!-- this must be an external -->
                <xsl:variable name="external-name" select="imf:get-external-type-name($this,true())"/>
                <xsl:value-of select="$external-name"/>
            </xsl:when>
            <xsl:when test="$type = 'attribute' and $stereotype = imf:get-config-stereotypes('stereotype-name-attribute')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'attribute' and $stereotype = imf:get-config-stereotypes('stereotype-name-referentie-element')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'attribute' and $stereotype = imf:get-config-stereotypes('stereotype-name-data-element')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'attribute' and $stereotype = imf:get-config-stereotypes('stereotype-name-enum')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'attribute' and $stereotype = imf:get-config-stereotypes('stereotype-name-union-element')">
                <xsl:value-of select="imf:useable-attribute-name($name,$this)"/>
            </xsl:when>
            <xsl:when test="$type = 'association' and $stereotype = 'relatiesoort' and normalize-space($alias)">
                <!-- if this relation occurs multiple times, add the alias of the target object -->
                <xsl:value-of select="$alias"/>
            </xsl:when>
            <xsl:when test="$type = 'association' and $this/imvert:aggregation = 'composite'">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'association' and $stereotype = 'relatiesoort'">
                <xsl:sequence select="imf:msg($this,'ERROR','No alias',())"/>
                <xsl:value-of select="lower-case($name)"/>
            </xsl:when>
            <xsl:when test="$type = 'association' and normalize-space($alias)"> <!-- composite -->
                <xsl:value-of select="$alias"/>
            </xsl:when>
            <xsl:when test="$type = 'association'">
                <xsl:sequence select="imf:msg($this,'ERROR','No alias',())"/>
                <xsl:value-of select="lower-case($name)"/>
            </xsl:when>
            <!-- TODO meer soorten namen uitwerken? -->
            <xsl:otherwise>
                <xsl:sequence select="imf:msg($this,'ERROR','Unknown type [1] with stereo [2]', ($type, string-join($stereotype,', ')))"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="imf:get-cardinality" as="xs:string+">
        <xsl:param name="this"/>
        <xsl:variable name="source-min" select="$this/imvert:min-occurs-source"/>
        <xsl:variable name="source-max" select="$this/imvert:max-occurs-source"/>
        <xsl:variable name="target-min" select="$this/imvert:min-occurs"/>
        <xsl:variable name="target-max" select="$this/imvert:max-occurs"/>
        <xsl:sequence select="(normalize-space($source-min),normalize-space($source-max),normalize-space($target-min),normalize-space($target-max))"/>
    </xsl:function>
    
    <!-- 
        return (formal?, material?) boolean values 
    
        if this is a composition to a group, inspect the group history 
    -->
    <xsl:function name="imf:get-history" as="xs:boolean+">
        <xsl:param name="this"/>
        <xsl:variable name="formal-this" select="imf:get-taggedvalue($this,'##CFG-TV-INDICATIONFORMALHISTORY')"/>
        <xsl:variable name="formal-grp" select="imf:get-taggedvalue(imf:get-groepattribuutsoort($this),'##CFG-TV-INDICATIONFORMALHISTORY')"/>
        <xsl:variable name="formal" select="if ($formal-this = 'ZIEGROEP') then $formal-grp else $formal-this"/>
        <xsl:variable name="material-this" select="imf:get-taggedvalue($this,'##CFG-TV-INDICATIONMATERIALHISTORY')"/>
        <xsl:variable name="material-grp" select="imf:get-taggedvalue(imf:get-groepattribuutsoort($this),'##CFG-TV-INDICATIONMATERIALHISTORY')"/>
        <xsl:variable name="material" select="if ($material-this = 'ZIEGROEP') then $material-grp else $material-this"/>
        <xsl:sequence select="(imf:boolean($this,$formal),imf:boolean($this,$material))"/>
    </xsl:function>

    <!-- true when: 
        Alleen als één van de elementen of groepen een ‘Indicatie authentiek’ gelijk aan Authentiek, Landelijk kerngegeven, 
        Gemeentelijk kerngegeven of Overig heeft 
    -->
    <xsl:function name="imf:is-authentiek" as="xs:boolean">
        <xsl:param name="this" as="element(imvert:class)"/>
        <xsl:variable name="elements" select="imf:get-all-attributes($this)"/>
        <xsl:variable name="bools" as="xs:boolean*">
            <xsl:for-each select="$elements">
               <xsl:sequence select="imf:property-is-authentiek(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="imf:boolean-or($bools)"/>   
    </xsl:function>     
    <xsl:function name="imf:property-is-authentiek" as="xs:boolean">
        <xsl:param name="this" as="element()"/>
        <!-- see if any or the relevant tagged values for this attribute is authentic -->
        <xsl:variable name="tv" select="imf:get-taggedvalue($this,'##CFG-TV-INDICATIONAUTHENTIC')"/>
        <xsl:sequence select="$tv = ('Authentiek', 'Basisgegeven', 'Landelijk kerngegeven','Gemeentelijk kerngegeven','Overig')"/>
    </xsl:function>     
    
    <xsl:function name="imf:get-stereotype" as="xs:string*">
        <xsl:param name="this"/>
        <xsl:sequence select="$this/imvert:stereotype"/>
    </xsl:function>

    <xsl:function name="imf:get-taggedvalue" as="xs:string?">
        <xsl:param name="this"/>
        <xsl:param name="name"/>
        <xsl:choose>
            <!-- the imvert:packages root element is never derived. To get the tagged value directly. -->
            <xsl:when test="$this/self::imvert:packages">
                <xsl:sequence select="imf:get-tagged-value($this,$name)"/>
            </xsl:when>
            <!-- any other element may be derived. So get the tagged value from the derivation tree. -->
            <xsl:otherwise>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($this,$name)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-groepattribuutsoort" as="element()?">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="$this/ancestor-or-self::imvert:class[imf:get-stereotype(.) = imf:get-config-stereotypes('stereotype-name-composite')]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation">
        <xsl:param name="this"/>
        <xsl:value-of select="normalize-space($this/imvert:documentation)"/>
    </xsl:function>
    
    <!-- tools -->
    
    <xsl:function name="imf:capitalize">
        <xsl:param name="name"/>
        <xsl:value-of select="concat(upper-case(substring($name,1,1)),substring($name,2))"/>
    </xsl:function>
    
    <xsl:function name="imf:boolean" as="xs:boolean">
        <xsl:param name="this"/>
        <xsl:param name="value"/>
        <xsl:sequence select="starts-with($value,'J')"/>
    </xsl:function>

    <!-- 
        ============================================== 
        common for all model based stylesheets 
        ============================================== 
    -->
    
    <xsl:function name="imf:get-construct-name" as="item()*">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="name" select="imf:sub-name($this)"/>
        <xsl:variable name="package-name" select="imf:sub-name($this/ancestor-or-self::imvert:package[1])"/>
        <xsl:variable name="class-name" select="imf:sub-name($this/ancestor-or-self::imvert:class[1])"/>
        <xsl:choose>
            <xsl:when test="$this/self::imvert:package">
                <xsl:sequence select="imf:compile-construct-name($name,'','','')"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:base">
                <xsl:sequence select="imf:compile-construct-name($name,'','','')"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:class">
                <xsl:sequence select="imf:compile-construct-name($package-name,$name,'','')"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:type">
                <xsl:sequence select="imf:compile-construct-name($this/imvert:type-package,$this/imvert:type-name,'','')"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:attribute">
                <xsl:sequence select="imf:compile-construct-name($package-name,$class-name,$name,'attrib')"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:association[not(imf:sub-name(.))]">
                <xsl:variable name="type" select="concat('[',$this/imvert:type-name,']')"/>
                <xsl:sequence select="imf:compile-construct-name($package-name,$class-name,$type,'aggr')"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:association">
                <xsl:sequence select="imf:compile-construct-name($package-name,$class-name,$name,'assoc')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:compile-construct-name($package-name,$name,local-name($this),'')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:sub-name">
        <xsl:param name="this"/>
        <xsl:value-of select="$this/imvert:name"/>
    </xsl:function>

    <xsl:function name="imf:get-class" as="element()?">
        <xsl:param name="this"/>
        <xsl:variable name="id" select="$this/imvert:type-id"/>
        <xsl:if test="normalize-space($id)">
            <xsl:variable name="class" select="root($this)//imvert:class[imf:get-id(.) = $id]"/>
            <xsl:sequence select="$class"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:stub-create-name">
        <xsl:param name="literal-name"/>
        <xsl:value-of select="concat('STUB-',replace($literal-name,'[^a-zA-Z]','_'))"/>
    </xsl:function>

    <xsl:function name="imf:parse-names" as="xs:string*">
        <xsl:param name="text" as="xs:string"/>
        <xsl:analyze-string select="$text" regex="'(.+?)'">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="imf:get-by-id" as="element()?">
        <xsl:param name="id"/>
        <xsl:sequence select="$document//*[imf:get-id(.) = $id]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-id" as="xs:string">
        <xsl:param name="this"/>
        <xsl:variable name="id" select="$this/imvert:id"/>
        <xsl:value-of select="$id"/>
    </xsl:function>
    
    <!-- get the ID of the type of the attribute or association -->
    <xsl:function name="imf:get-type-id" as="xs:string">
        <xsl:param name="this"/>
        <xsl:variable name="id" select="$this/imvert:type-id"/>
        <xsl:value-of select="$id"/>
    </xsl:function>
    
    <!-- return suffixes to append to relation names. [1] is incoming, [2] is outgoing -->
    <xsl:function name="imf:get-relation-suffix" as="xs:string+">
        <xsl:param name="this"/> <!-- an Association element -->
        <xsl:variable name="targetAlias" select="imf:get-effective-name($this/imvert:target)"/>
        <xsl:variable name="targetId" select="imf:get-type-id($this)"/>
        
        <xsl:variable name="other-associations" select="root($this)//imvert:association[imf:get-effective-name(imvert:target) = $targetAlias and imf:get-type-id(.) = $targetId]"/>
        <xsl:variable name="class" select="$this/ancestor::imvert:class"/>
        <xsl:value-of select="if (count($other-associations) gt 1) then imf:capitalize($class/imvert:name) else ''"/>

        <xsl:variable name="class" select="root($this)//imvert:class[imf:get-id(.) = $targetId]"/>
        <xsl:value-of select="if (count($this/../imvert:association[imf:get-effective-name(imvert:target) = $targetAlias]) gt 1) then imf:capitalize($class/imvert:name) else ''"/>

    </xsl:function>
    
    <xsl:function name="imf:create-annotation">
        <xsl:param name="this"/>
        <xs:annotation>
            <xs:documentation>
                <xsl:value-of select="$this/imvert:name/@original"/>
            </xs:documentation>
        </xs:annotation>
    </xsl:function>
    
    <!-- deze scalars kunnen meteen uit de StUF onderlaag worden gehaald -->
    <xsl:function name="imf:get-stuf-scalar-attribute-type" as="xs:string?">
        <xsl:param name="attribute"/>
   
        <xsl:choose>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-date' and $attribute/imvert:type-modifier = '?'">
                <xsl:value-of select="concat($StUF-prefix,':DatumMogelijkOnvolledig-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-date'">
                <xsl:value-of select="concat($StUF-prefix,':Datum-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-datetime' and $attribute/imvert:type-modifier = '?'">
                <xsl:value-of select="concat($StUF-prefix,':TijdstipMogelijkOnvolledig-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-datetime'">
                <xsl:value-of select="concat($StUF-prefix,':Tijdstip-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-year'">
                <xsl:value-of select="concat($StUF-prefix,':Jaar-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-yearmonth'">
                <xsl:value-of select="concat($StUF-prefix,':JaarMaand-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-postcode'">
                <xsl:value-of select="concat($StUF-prefix,':Postcode-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-boolean'">
                <xsl:value-of select="concat($StUF-prefix,':INDIC-e')"/>
            </xsl:when>
        </xsl:choose>
    
    </xsl:function>
    
    <xsl:function name="imf:create-facet" as="element()?">
        <xsl:param name="elementname"/>
        <xsl:param name="content"/>
        <xsl:if test="normalize-space($content)">
            <xsl:element name="{$elementname}">
                <xsl:attribute name="value" select="$content"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-external-element-name">
        <xsl:param name="conceptual-schema-namespace"/>
        <xsl:param name="conceptual-schema-class-name"/>
        
    </xsl:function>
    
    <!-- een klasse is in onderzoek als een van haar attributen of attributen in een gegevensgroep in onderzoek is -->
    <xsl:function name="imf:is-in-onderzoek" as="xs:boolean">
        <xsl:param name="this" as="element(imvert:class)"/>
        <xsl:variable name="elements" select="imf:get-all-attributes($this)"/>
        <xsl:variable name="bools" as="xs:boolean*">
            <xsl:for-each select="$elements">
               <xsl:sequence select="imf:property-is-in-onderzoek(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="imf:boolean-or($bools)"/>   
    </xsl:function>
    <xsl:function name="imf:property-is-in-onderzoek" as="xs:boolean">
        <xsl:param name="this" as="element()"/><!-- imvert:class (gegevensgroep) of imvert:attribute -->
        <!-- see if any of the relevant tagged values for this attribute is authentic -->
        <xsl:variable name="tv" select="imf:get-taggedvalue($this,'##CFG-TV-INDICATIEINONDERZOEK')"/>
        <xsl:sequence select="$tv = 'Ja' or ($tv = 'Zie groep' and imf:property-is-in-onderzoek($this/../..))"/>
    </xsl:function>        
    
    <xsl:function name="imf:create-historie-attributes" as="attribute()*">
        <xsl:param name="formeel"/>
        <xsl:param name="materieel"/>
        <xsl:if test="imf:boolean($formeel)">
            <xsl:attribute name="metadata:formeleHistorie" select="$formeel"/>
        </xsl:if>
        <xsl:if test="imf:boolean($materieel)">
            <xsl:attribute name="metadata:materieleHistorie" select="$materieel"/>
        </xsl:if>
    </xsl:function>
    
    <!-- get all attributes defined on the class, group or any composite group -->
    <xsl:function name="imf:get-all-attributes" as="element(imvert:attribute)*">
        <xsl:param name="this" as="element(imvert:class)*"/>
        <xsl:sequence select="$this/imvert:attributes/imvert:attribute"/>
       
        <?x
        <xsl:variable name="group-type-ids" select="$this/imvert:associations/imvert:association[imvert:aggregation = 'composite']/imvert:type-id"/>
        <xsl:variable name="groups" select="for $id in $group-type-ids return imf:get-construct-by-id($id)"/>
        <xsl:sequence select="for $group in $groups return imf:get-all-attributes($group)"/>
        x?>
    </xsl:function>
    
    <xsl:function name="imf:stub-ignored-properties">
        <xsl:param name="attribute"/>
        <xsl:sequence select="$attribute/imvert:name = ('xxsoort','xxxsbiCode','xxxvoorvoegsel','xxxscheidingsteken','xxxauthentiek','xxxisOnderdeelVan')"/>
    </xsl:function>
    
    <!-- attributen kunnen twee of meermaals met dezelfde naam voorkomen. Disambigueer in die situaties. Plaats alias van de klasse erachter. Alleen voor simple types! -->
    <xsl:function name="imf:useable-attribute-name">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="attribute" as="element(imvert:attribute)"/>
        <xsl:choose>
            <xsl:when test="empty($attribute/imvert:type-id) and exists($attribute/imvert:baretype) and count($all-simpletype-attributes[imvert:name = $attribute/imvert:name]) gt 1">
               <!--xx <xsl:message select="concat($attribute/imvert:name, ';', $attribute/@display-name)"/> xx-->
                <xsl:value-of select="concat($name,imf:get-effective-name($attribute/../..))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:create-subset-class-marker" as="node()*">
        <xsl:param name="construct"/>
        <xsl:param name="xsd-construct"/>
     
        <xsl:variable name="marker-info" select="$construct/imvert:subset-info"/>
        <xsl:choose>
            <xsl:when test="exists($marker-info)">
                <subset-class-marker>
                    <xsl:copy-of select="$marker-info"/>
                    <xsl:sequence select="$xsd-construct"/>
                </subset-class-marker>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$xsd-construct"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>    
    
    <xsl:function name="imf:get-package">
        <xsl:param name="construct"/>
        <xsl:sequence select="$construct/ancestor-or-self::imvert:package"/>
    </xsl:function>
    
    <!-- 
        name is the alias, and, if subsetting, a restriction identifier 
    -->
    <xsl:function name="imf:get-effective-name">
        <xsl:param name="this"/>
        <xsl:variable name="effective-name" select="$this/imvert:subset-info/imvert:effective-name"/>
        <xsl:value-of select="if ($effective-name) then $effective-name else $this/imvert:alias"/>
    </xsl:function>
    <!-- 
        prefix is the namespace in which the construct exists 
    -->
    <xsl:function name="imf:get-effective-prefix">
        <xsl:param name="this"/>
        <xsl:variable name="effective-prefix" select="$this/imvert:subset-info/imvert:effective-prefix"/>
        <xsl:value-of select="if ($effective-prefix) then $effective-prefix else $this/ancestor-or-self::imvert:package[last()]/@xsd-prefix"/>
    </xsl:function>
    <!-- 
        suffix is basis or matchgegevens or nothing depending on subclass and as-matchgegevens parameter 
    -->
    <xsl:function name="imf:get-effective-suffix">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="as-matchgegevens" as="xs:boolean"/>
        <xsl:variable name="is-restriction" select="imf:boolean($this/imvert:subset-info/imvert:is-restriction-class)"/>
        <xsl:value-of select="if ($as-matchgegevens) then '-matchgegevens' else if ($is-restriction) then '' else '-basis'"/> 
    </xsl:function>
    
    <xsl:function name="imf:get-entiteittype">
        <xsl:param name="this"/>
        <xsl:variable name="entiteittype" select="$this/imvert:alias"/>
        <xsl:value-of select="$entiteittype"/>
    </xsl:function>
       
    <xsl:template match="imvert:dummy"/>
    
</xsl:stylesheet>
