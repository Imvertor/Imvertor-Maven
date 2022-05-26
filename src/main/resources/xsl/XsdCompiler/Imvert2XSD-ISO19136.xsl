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
    
    xmlns:gmlexr="http://www.opengis.net/gml/3.3/xer"
    xmlns:gmlsf="http://www.opengis.net/gmlsf/2.0"
    
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    
    exclude-result-prefixes="#all"
    version="2.0">

    <!-- 
        implementation of ISO 19136:2007
    -->

    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-doc.xsl"/>
    
    <xsl:import href="common-xsd.xsl"/>
    
    <xsl:variable name="stylesheet-code">ISOS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:param name="config-file-path">unknown-file</xsl:param>
   
    <!-- 
        Determine which type is defined in which package 
    -->
    <xsl:variable name="type-in-package" as="element()*">
        <xsl:apply-templates select="$imvert-document//imvert:class" mode="type-in-package"/>
    </xsl:variable>
    
    <xsl:variable name="base-namespace" select="/imvert:packages/imvert:base-namespace"/>

    <xsl:variable name="Type-suffix">Type</xsl:variable>
    <xsl:variable name="PropertyType-suffix">PropertyType</xsl:variable>
    <xsl:variable name="EnumerationType-suffix">Type</xsl:variable>
    
    <xsl:variable name="codelist-option" select="imf:get-config-string('cli','codelistoption','UNSPECIFIED')" as="xs:string"/>
    <xsl:variable name="gml-version" select="imf:get-config-string('cli','gmlversion','UNSPECIFIED')" as="xs:string"/>
    <xsl:variable name="sf-conformance-level" select="imf:get-config-string('cli','sfconformance','UNSPECIFIED')" as="xs:string"/>
    <xsl:variable name="associate-by-reference" select="imf:boolean(imf:get-config-string('cli','assocbyreference','false'))" as="xs:boolean"/>
    
    <xsl:variable name="model-version" select="/imvert:packages/imvert:version"/>
    
    <xsl:variable name="namespace-composition" select="imf:get-config-xmlschemarules()/parameter[@name='namespace-composition']"/>
    
    <xsl:template match="imvert:class" mode="type-in-package">
        <type 
            name="{imvert:name}"
            id="{imvert:id}"
            prefix="{parent::imvert:package/imvert:short-name}" 
            ns="{imf:get-namespace(parent::imvert:package)}" 
            file="{imf:get-xsd-filesubpath(parent::imvert:package)}"/>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:choose>
            <!-- preliminary validation -->
            <xsl:when test="empty($gml-version)">
                <xsl:sequence select="imf:msg(.,'ERROR', 'No required GML version specified')"/> 
            </xsl:when>
            <xsl:when test="empty($codelist-option)">
                <xsl:sequence select="imf:msg(.,'ERROR', 'No codelist option specified')"/> 
            </xsl:when>
            <xsl:when test="not($codelist-option = ('Option1','Option2','Option3'))">
                <xsl:sequence select="imf:msg(.,'ERROR', 'Invalid codelist option [1] for GML version [2]',($codelist-option,$gml-version))"/> 
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:template-create-schemas()"/>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:template>
    
    <!-- Internal packages processed here. -->
    <xsl:template match="imvert:package">
        <xsl:variable name="this-package" select="."/>
        <xsl:variable name="this-package-is-referencing" select="$this-package/imvert:ref-master"/>
        
        <xsl:variable name="this-package-associations" select="
            ($this-package/imvert:class/imvert:associations/imvert:association, 
            $this-package/imvert:class/imvert:attributes/imvert:attribute)" as="node()*"/>
        <xsl:variable name="this-package-associated-classes" select="$document-classes[imvert:id=$this-package-associations/imvert:type-id]" as="node()*"/>
        <xsl:variable name="this-package-associated-types" select="$this-package-associated-classes/imvert:name" as="xs:string*"/>
        <xsl:variable name="this-package-associated-type-ids" select="$this-package-associated-classes/imvert:id" as="xs:string*"/>
        
        <xsl:variable name="schema-version" select="imvert:version"/>
        <xsl:variable name="schema-phase" select="imvert:phase"/>
        
        <!-- historical note: we removed nsim-tally, and introduced a second step: the import XSL -->
        
        <xsl:variable name="schema-subpath" select="imf:get-xsd-filesubpath(.)"/>
        <xsl:variable name="schemafile" select="imf:get-xsd-filefullpath(.)"/>
        <imvert:schema> 
            <xsl:sequence select="imvert:name"/>
            <xsl:sequence select="imf:create-info-element('imvert:prefix',imvert:short-name)"/>
            <xsl:sequence select="imf:create-info-element('imvert:is-referencing',$this-package-is-referencing)"/>
            <xsl:sequence select="imf:create-info-element('imvert:namespace',imf:get-namespace(.))"/>
            <xsl:sequence select="imf:create-info-element('imvert:result-file-subpath',$schema-subpath)"/>
            <xsl:sequence select="imf:create-info-element('imvert:result-file-fullpath',$schemafile)"/>
            
            <xsl:variable name="file-url" select="imf:get-most-relevant-compiled-taggedvalue($this-package,'##CFG-TV-XSDLOCATION')"/>
            <xsl:sequence select="imf:create-info-element('imvert:result-url',$file-url)"/>
            
            <xs:schema>
                <!-- schema attributes -->
                <xsl:attribute name="targetNamespace" select="imf:get-namespace(.)"/>
                <xsl:attribute name="elementFormDefault" select="'qualified'"/>
                <xsl:attribute name="attributeFormDefault" select="'unqualified'"/>
                
                <!-- set version attribute to the version number -->
                <xsl:attribute name="version" select="concat($schema-version,'-',$schema-phase)"/>
        
                <!-- set my own namespaces (qualified) -->
                <xsl:namespace name="{imvert:short-name}" select="imf:get-namespace(.)"/>
                
                <!-- version info -->
                <xsl:sequence select="imf:get-annotation(.,imf:get-schema-info(.),imf:get-appinfo-version(.))"/>
                
                <!-- simple feature -->
                <xsl:if test="not($sf-conformance-level = 'UNSPECIFIED')">
                    <xs:annotation> 
                        <xs:appinfo
                            source="http://schemas.opengis.net/gmlsfProfile/2.0/gmlsfLevels.xsd"> 
                            <gmlsf:ComplianceLevel>
                                <xsl:value-of select="$sf-conformance-level"/>
                            </gmlsf:ComplianceLevel> 
                        </xs:appinfo> 
                    </xs:annotation>
                </xsl:if>
                
                <!-- XSD complextypes -->
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL PRODUCTS')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-product','stereotype-name-featurecollection')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL OBJECTTYPES')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL ASSOCIATIONCLASSES')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL COMPLEX TYPES')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL ATTRIBUTEGROUPTYPES')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]"/>
                
                <!-- XSD simpletypes -->
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL DATATYPES/PRIMITIVES')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL ENUMERATIONS')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL REFERENCELISTS')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL CODELISTS')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,'ALL UNIONS')"/>
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]"/>
                
                <!-- simple type attributes for attributes types that restrict a simple type; needed to set nilReason attribute -->
                <xsl:apply-templates 
                    select="imvert:class/imvert:attributes/imvert:attribute[(imvert:stereotype/@id = ('stereotype-name-voidable') or $is-forced-nillable) and imf:is-restriction(.)]"
                    mode="nil-reason">
                    <xsl:with-param name="package-name" select="$this-package/imvert:name"/>
                </xsl:apply-templates>
            </xs:schema>
        
        </imvert:schema>
         
    </xsl:template>
        
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-product')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'A product')"/>
        <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-featurecollection')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'A feature collection')"/>
        
        <xsl:variable name="package-name" select="parent::imvert:package/imvert:name"/>
        <xsl:variable name="type-name" select="imvert:name"/>
        <xsl:variable name="targets" select="imf:get-ISOrole-info(imvert:associations/imvert:association)"/>
        
        <!-- validate: check if the target roles are all called "featureMember"; this is an UML requirement -->
        
        <xsl:for-each select="$targets">
            <xsl:sequence select="imf:report-error(.,
                ((imvert:role | imvert:name) != 'featureMember'),
                'Any [1] association to a feature member must be named [2]',(imf:get-config-name-by-id('stereotype-name-featurecollection'),'featureMember'))"/>
        </xsl:for-each>
        
        <xs:element name="{$type-name}" 
            type="{imf:get-type($type-name,$package-name)}Type" 
            substitutionGroup="gml:AbstractGML"/>
        <xs:complexType name="{$type-name}Type">
            <xs:complexContent>
                <xs:extension base="gml:AbstractFeatureType">
                    <xs:sequence minOccurs="0" maxOccurs="unbounded">
                        <xs:element name="featureMember">
                            <xs:complexType>
                                <xs:complexContent>
                                    <xs:extension base="gml:AbstractFeatureMemberType">
                                        <xs:sequence>
                                            <xs:element ref="gml:AbstractFeature"/>
                                            
                                            <!-- omdat imports worden opgelost op basis van prefixen van gerefereerde constructs, moeten we hier expliciet de betreffende elementen benoemen. -->
                                            <xsl:for-each select="imvert:associations/imvert:association/imvert:type-id">
                                                <xs:element-stub name="{imf:get-qname(imf:get-association-construct-by-id(.,/))}"/>
                                            </xsl:for-each>    
                                        </xs:sequence>
                                    </xs:extension>
                                </xs:complexContent>
                            </xs:complexType>
                        </xs:element>
                    </xs:sequence>
                </xs:extension>
            </xs:complexContent>
        </xs:complexType>
    </xsl:template>
 
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'An objecttype')"/>
        <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
    </xsl:template>
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'An attributegrouptype')"/>
        <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'An association class')"/>
        <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'A complex datatype')"/>
        <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]">

        <xsl:choose>
            <xsl:when test="$codelist-option = 'Option3'">
                <xsl:variable name="codespace" select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DATALOCATION')"/>
                <xsl:sequence select="imf:create-xml-debug-comment(.,concat('A codelist at option: ',$codelist-option))"/>
                <xs:complexType name="{imvert:name}{$Type-suffix}">
                    <xs:simpleContent>
                        <xs:restriction base="gml:CodeWithAuthorityType">
                            <xs:attribute name="codeSpace" type="xs:anyURI" use="required" fixed="{$codespace}" />
                        </xs:restriction>
                    </xs:simpleContent>
                </xs:complexType>
            </xsl:when>
            <xsl:otherwise>
                <!-- all encoded at the attribute level -->
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>    

    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]">
        <xs:simpleType name="{imvert:name}{$Type-suffix}">
            <xsl:sequence select="imf:get-annotation(.)"/>
            <xs:restriction base="xs:string">
                <xsl:for-each select="imvert:attributes/imvert:attribute">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                    <xs:enumeration value="{imvert:name/@original}">
                        <xsl:sequence select="imf:get-annotation(.)"/>
                    </xs:enumeration>
                </xsl:for-each>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template> 
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'A referencelist')"/>
        <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
    </xsl:template>    
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]">
        <xsl:sequence select="imf:create-xml-debug-comment(.,'Datatype is a union')"/>
        <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]">
        <xsl:variable name="supertypes" select="(.,imf:get-superclasses(.))"/>
        <xsl:variable name="supertype-primitive" select="$supertypes/imvert:supertype/imvert:primitive"/><!-- er is max één supertype dat verwijst naar een primitive, dus uit de conceptual schemas -->

        <xsl:choose>
            <xsl:when test="imvert:attributes/* or imvert:associations/*">
                <xsl:sequence select="imf:create-xml-debug-comment(.,'Datatype with data elements or associations')"/>
                <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
            </xsl:when>
            <xsl:when test="imvert:union">
                <xsl:sequence select="imf:create-xml-debug-comment(.,'Datatype is a union')"/>
                <xs:simpleType name="{imvert:name}">
                    <xsl:sequence select="imf:get-annotation(.)"/>
                    <xsl:apply-templates select="imvert:union"/>
                </xs:simpleType>
            </xsl:when>
            <xsl:when test="$supertype-primitive">
                <xsl:sequence select="imf:create-xml-debug-comment(.,'A simple datatype, subtype of a primitive')"/>
                <xs:simpleType name="{imvert:name}{$Type-suffix}">
                    <xsl:sequence select="imf:get-annotation(.)"/>
                    <xs:restriction base="{$supertype-primitive}">
                        <xsl:sequence select="imf:create-datatype-property(.,$supertype-primitive)"/>
                    </xs:restriction>
                </xs:simpleType>
            </xsl:when>
            <xsl:otherwise>
                <!-- A type like zipcode -->
                <xsl:sequence select="imf:create-xml-debug-comment(.,'A simple datatype')"/>
                <xs:simpleType name="{imvert:name}{$Type-suffix}">
                    <xsl:sequence select="imf:get-annotation(.)"/>
                    <xsl:variable name="supertype">xs:string</xsl:variable>
                    <xs:restriction base="{$supertype}">
                        <xsl:sequence select="imf:create-datatype-property(.,'xs:string')"/>
                    </xs:restriction>
                </xs:simpleType>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
       feature types, association classes and complex dataypes X occurring in UML class diagram are created as 3 global constructs: 
           
           element X, occurring as a top element, possibly referenced from within any complex type definition. 
           type XType, the type of element X,
           type XPropertyType, the type of any property of type X
           
       -->
    <xsl:template match="imvert:class">
        <xsl:variable name="package-name" select="parent::imvert:package/imvert:name"/>
        <xsl:variable name="type-name" select="imvert:name"/>
        <xsl:variable name="type-id" select="imvert:id"/>
        <xsl:variable name="primitive" select="imvert:primitive"/>
        <xsl:variable name="supertype" select="imvert:supertype[not(imvert:stereotype/@id = ('stereotype-name-static-generalization'))][1]"/>
        <xsl:variable name="supertype-name" select="$supertype/imvert:type-name"/>
        <xsl:variable name="supertype-package-name" select="$supertype/imvert:type-package"/>
        <xsl:variable name="supertype-substitutiongroup" select="$supertype/imvert:xsd-substitutiongroup"/> 
        <xsl:variable name="abstract" select="imvert:abstract"/>
        
        <xsl:variable name="data-location" select="imf:get-appinfo-location(.)"/>
        
        <!-- all classes are element + complex type declaration; except for datatypes (<<datatype>>). -->
        
        <xsl:variable name="is-choice-member" select="$document-classes[imvert:stereotype/@id = ('stereotype-name-union') and imvert:attributes/imvert:attribute/imvert:type-id = $type-id]"/>
        <xsl:variable name="is-complex-datatype" select="imvert:stereotype/@id = ('stereotype-name-complextype')"/>
        <xsl:variable name="is-referencelist" select="imvert:stereotype/@id = ('stereotype-name-referentielijst')"/>
        <xsl:variable name="is-simple-datatype" select="imvert:stereotype/@id = ('stereotype-name-simpletype')"/>
        <xsl:variable name="is-objecttype" select="imvert:stereotype/@id = ('stereotype-name-objecttype')"/>
        <xsl:variable name="is-grouptype" select="imvert:stereotype/@id = ('stereotype-name-composite')"/>
        
        <xsl:variable name="is-keyed" select="imvert:attributes/imvert:attribute/imvert:stereotype/@id = 'stereotype-name-key'"/><!-- keyed classes are never represented on their own -->
        
        <xsl:variable name="ref-master" select="if (imvert:ref-master) then imf:get-construct-by-id(imvert:ref-master-id) else ()"/>
        <xsl:variable name="ref-masters" select="if ($ref-master) then ($ref-master,imf:get-superclasses($ref-master)) else ()"/>
        <xsl:variable name="ref-master-idatts" select="for $m in $ref-masters return $m/imvert:attributes/imvert:attribute[imf:boolean(imvert:is-id)]"/>
        <xsl:variable name="ref-master-identifiable-subtype-idatts" select="for $s in imf:get-subclasses($ref-master) return imf:get-id-attribute($s)"/>
        <xsl:variable name="ref-master-identifiable-subtypes-with-domain" select="for $a in $ref-master-identifiable-subtype-idatts return if (imf:get-tagged-value($a,'##CFG-TV-DOMAIN')) then $a/ancestor::imvert:class else ()"/>
        
        <xsl:variable name="use-identifier-domains" select="imf:boolean(imf:get-xparm('cli/identifierdomains','no'))"/>
        <xsl:variable name="domain-values" select="for $i in $ref-master-idatts return imf:get-tagged-value($i,'##CFG-TV-DOMAIN')"/>
        <xsl:variable name="domain-value" select="$domain-values[1]"/>
        
        <xsl:variable name="formal-pattern" select="imf:get-facet-pattern(.)"/>
        
        <!-- only generate elements for constructs thet may be referenced as an element. This is: all constructs but
            AttributeGroupType
            
            https://github.com/Imvertor/Imvertor-Maven/issues/41
        -->
        <xsl:if test="not($is-grouptype or $is-keyed)">
            <xs:element name="{$type-name}" type="{imf:get-type($type-name,$package-name)}{$Type-suffix}" abstract="{$abstract}">
                <xsl:choose>
                    <xsl:when test="not($supertype-name) and $is-objecttype">
                        <xsl:attribute name="substitutionGroup" select="'gml:AbstractFeature'"/>
                    </xsl:when>
                    <xsl:when test="not($supertype-name) and $is-grouptype">
                        <!--<xsl:attribute name="substitutionGroup" select="'gml:AbstractFeature'"/>-->
                    </xsl:when>
                    <xsl:when test="not($supertype-name)">
                        <!--<xsl:attribute name="substitutionGroup" select="'gml:AbstractObject'"/>-->
                    </xsl:when>
                    <xsl:when test="$supertype-substitutiongroup = $name-none">
                        <!-- nothing: explicit skip of this link to the subsitution group -->
                    </xsl:when>
                    <xsl:when test="$supertype-substitutiongroup">
                        <xsl:attribute name="substitutionGroup" select="imf:get-type($supertype-substitutiongroup,$supertype-package-name)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="substitutionGroup" select="imf:get-type($supertype-name,$supertype-package-name)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:sequence select="imf:get-annotation(.,$data-location,())"/> 
            </xs:element>
        </xsl:if>
        
        <xsl:variable name="content" as="element()?">
            <xsl:choose>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-union')">
                    <!-- attributes of a NEN3610 union, i.e. a choice between classes. The choice is a specialization of a datatype -->
                    <xsl:variable name="atts">
                        <xsl:for-each select="imvert:attributes/imvert:attribute">
                            <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                            <xsl:variable name="defining-class" select="imf:get-defining-class(.)"/>   
                            <xsl:variable name="defining-class-is-datatype" select="$defining-class/imvert:stereotype/@id = (
                                ('stereotype-name-simpletype','stereotype-name-enumeration','stereotype-name-codelist','stereotype-name-complextype','stereotype-name-union'))"/>   
                            <xsl:variable name="defining-class-is-primitive" select="exists(imvert:primitive)"/>   
                            <xsl:choose>
                                <xsl:when test="$defining-class-is-datatype or $defining-class-is-primitive">
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice member, which is a datatype')"/>
                                    <xsl:sequence select="imf:create-element-property(.)"/>
                                </xsl:when>
                                <xsl:when test="empty($defining-class) and $allow-scalar-in-union">
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice member, which is a scalar type')"/>
                                    <xsl:sequence select="imf:create-element-property(.)"/>
                                </xsl:when>
                                <xsl:when test="empty($defining-class)">
                                    <xsl:sequence select="imf:msg(.,'ERROR', 'Unable to create a union of scalar types',())"/> <!-- IM-291, https://github.com/Imvertor/Imvertor-Maven/issues/44 -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice member')"/>
                                    <xs:element ref="{imf:get-qname($defining-class)}"/>  
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="$atts">
                        <complex>
                            <xs:choice>
                                <xsl:attribute name="minOccurs" select="if (imvert:min-occurs) then imvert:min-occurs else '1'"/>
                                <xsl:attribute name="maxOccurs" select="if (imvert:max-occurs) then imvert:max-occurs else '1'"/>
                                <xsl:sequence select="imf:create-xml-debug-comment(.,'A number of choices')"/>
                                <xsl:sequence select="$atts"/>
                            </xs:choice>
                        </complex>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-complextype') and exists($formal-pattern)"><!-- IM-325 -->
                    <simple>
                        <xsl:sequence select="imf:create-xml-debug-comment(.,'A complex type with pattern')"/>
                        <xs:annotation>
                            <xs:documentation>This complex datatype is transformed to a simple type because a content pattern is defined.</xs:documentation>
                        </xs:annotation>
                        <xs:restriction base="xs:string">
                            <xs:pattern value="{$formal-pattern}"/>
                        </xs:restriction>
                    </simple>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-simpletype') and exists($formal-pattern)">
                    <simple>
                        <xsl:sequence select="imf:create-xml-debug-comment(.,'A simple type with a pattern')"/>
                        <xs:restriction base="xs:string">
                            <xs:pattern value="{$formal-pattern}"/>
                        </xs:restriction>
                    </simple>
                </xsl:when>
                
                <xsl:otherwise>
                    <complex>
                        <!-- XML elements are declared first -->
                        <xsl:variable name="atts" as="item()*">
                            <xsl:for-each select="imvert:attributes/imvert:attribute[not(imvert:type-name=$xml-attribute-type)] | imvert:associations/imvert:association">
                                <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                                <xsl:sequence select="imf:create-xml-debug-comment(.,'An attribute or association')"/>
                                <xsl:sequence select="imf:create-element-property(.)"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:if test="exists($atts)">
                            <xs:sequence>
                                <xsl:sequence select="$atts"/>
                            </xs:sequence>
                        </xsl:if>
                    
                        <xsl:variable name="incoming-refs" select="imf:get-references(.)"/>
                        <xsl:variable name="super-incoming-refs" select="for $c in imf:get-superclasses(.) return imf:get-references($c)"/>
                        
                        <xsl:for-each select="imvert:attributes/imvert:attribute[imvert:type-name=$xml-attribute-type]">
                            <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                            <xsl:sequence select="imf:create-attribute-property(.)"/>
                        </xsl:for-each>
                    </complex>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$is-keyed">
                <!-- skip -->
            </xsl:when>
         
            <xsl:when test="$content/self::complex">
             
                <xs:complexType>
                    <xsl:attribute name="name" select="concat($type-name,$Type-suffix)"/>
                    <xsl:attribute name="abstract" select="$abstract"/>
                    
                    <xsl:variable name="extension-base" as="xs:string?">
                        <xsl:choose>
                            <xsl:when test="$supertype-name">
                                <!--<xsl:message select="concat('complex/ ',$supertype-name,'/',$supertype-package-name,'/',imf:get-type($supertype-name,$supertype-package-name))"></xsl:message>-->
                                <xsl:value-of  select="concat(imf:get-type($supertype-name,$supertype-package-name),$Type-suffix)"/> 
                            </xsl:when>
                            <xsl:when test="$is-objecttype">
                                <xsl:value-of  select="'gml:AbstractFeatureType'"/> 
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- none -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="exists($extension-base)">
                            <xs:complexContent>
                                <xs:extension base="{$extension-base}">
                                    <xsl:if test="exists($content/*)">
                                        <xsl:sequence select="$content/node()"/>
                                    </xsl:if>
                                </xs:extension>
                            </xs:complexContent>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="exists($content/*)">
                                <xsl:sequence select="$content/node()"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xs:complexType>
                <xsl:choose>
                    <xsl:when test="$is-grouptype">
                        <!-- no property type -->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- add the property type -->
                        <xs:complexType>
                            <xsl:attribute name="name" select="concat($type-name,$PropertyType-suffix)"/>
                            <xsl:choose>
                                <xsl:when test="$is-objecttype and $associate-by-reference">
                                    <!-- enforce relations targeted by reference -->
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'Objectype, force by reference')"/>
                                    <xs:attributeGroup ref="gml:AssociationAttributeGroup"/>
                                    <xs:attributeGroup ref="gml:OwnershipAttributeGroup"/>
                                </xsl:when>
                                <xsl:when test="$is-objecttype">
                                    <!-- allow relations targeted by reference as well as inline -->
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'Objectype')"/>
                                    <xs:sequence minOccurs="0">
                                        <xs:element ref="{imf:get-type($type-name,$package-name)}"/>
                                    </xs:sequence>
                                    <xs:attributeGroup ref="gml:AssociationAttributeGroup"/>
                                    <xs:attributeGroup ref="gml:OwnershipAttributeGroup"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'Datatype')"/>
                                    <!-- a datatype -->
                                    <xs:sequence minOccurs="0">
                                        <xs:element ref="{imf:get-type($type-name,$package-name)}"/>
                                    </xs:sequence>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xs:complexType>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            <xsl:otherwise>
                <xs:simpleType>
                    
                    <xsl:attribute name="name" select="concat($type-name,$Type-suffix)"/>
                    <xsl:choose>
                        <xsl:when test="$supertype-name">
                            <!--<xsl:message select="concat('simple/ ',$supertype-name,'/',$supertype-package-name,'/',imf:get-type($supertype-name,$supertype-package-name))"></xsl:message>-->
                            <xs:simpleContent>
                                <xs:extension base="{imf:get-type($supertype-name,$supertype-package-name)}">
                                    <xsl:if test="exists($content/*)">
                                        <xsl:sequence select="$content/node()"/>
                                    </xsl:if>
                                </xs:extension>
                            </xs:simpleContent>
                        </xsl:when>
                        <xsl:when test="exists($content)">
                            <xsl:sequence select="$content/node()"/>
                        </xsl:when>
                    </xsl:choose>      
                </xs:simpleType>
                <!-- add the property type -->
                <xs:complexType>
                    <xsl:attribute name="name" select="concat($type-name,$PropertyType-suffix)"/>
                    <xs:sequence minOccurs="0">
                        <xs:element ref="{imf:get-type($type-name,$package-name)}"/>
                    </xs:sequence>
                </xs:complexType>
            </xsl:otherwise>
        </xsl:choose>
                
    </xsl:template>
    
    <!-- 
        Create a simpletype from which a voidable simpletype can inherit (through restriction); needed to add a nilreason.
        See also http://stackoverflow.com/questions/626319/add-attributes-to-a-simpletype-or-restrictrion-to-a-complextype-in-xml-schema
    --> 
    <xsl:template match="imvert:attribute" mode="nil-reason">
        <xsl:variable name="basetype-name" select="imf:get-restriction-basetype-name(.)"/> <!-- e.g. Class1_att2_Basetype -->
        <xsl:variable name="type" select="imf:get-type(imvert:type-name,imvert:type-package)"/>
        <xs:simpleType name="{$basetype-name}">
            <xs:annotation>
                <xs:documentation><p>Generated class. Introduced because the identified attribute is voidable and is a restriction of a simple type.</p></xs:documentation>
            </xs:annotation>
            <xs:restriction base="{$type}">
                <xsl:sequence select="imf:create-datatype-property(.,$type)"/>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>
    
    <xsl:template match="*|@*|text()">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:function name="imf:create-element-property" as="item()*">
        <xsl:param name="this" as="node()"/>
        
        <!-- nilllable may be forced for specific circumstances. This only applies to attributes of a true class or associations -->
        <xsl:variable name="is-property" select="exists(($this/self::imvert:attribute,$this/self::imvert:association))"/>
        <xsl:variable name="force-nillable" select="$is-property and $is-forced-nillable"/>
        
        <xsl:variable name="is-voidable" select="
            $this/imvert:stereotype/@id = ('stereotype-name-voidable')
            or
            imf:boolean(imf:get-most-relevant-compiled-taggedvalue($this,'##CFG-TV-VOIDABLE'))"/>
        <xsl:variable name="is-nillable" select="$is-voidable or $force-nillable"/>
        
        <xsl:variable name="is-restriction" select="imf:is-restriction($this)"/>
        <xsl:variable name="is-estimation" select="imf:is-estimation($this)"/>
        <xsl:variable name="basetype-name" select="if ($is-nillable) then imf:get-restriction-basetype-name($this) else ''"/>
        <xsl:variable name="package-name" select="$this/ancestor::imvert:package[last()]/imvert:name"/>
        
        <xsl:variable name="name" select="$this/imvert:name"/>
        <xsl:variable name="target-role-name" select="if ($this/self::imvert:association) then imf:get-ISOrole-info($this)/(imvert:name | imvert:role) else ()"/>
        <xsl:variable name="found-type" select="imf:get-type($this/imvert:type-name,$this/imvert:type-package)"/>
      
        <xsl:variable name="is-any" select="$found-type = '#any'"/>
        <xsl:variable name="is-mix" select="$found-type = '#mix'"/>
        
        <xsl:variable name="defining-class" select="imf:get-defining-class($this)"/>                            
        <xsl:variable name="is-enumeration" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-enumeration')"/>
        <xsl:variable name="is-datatype" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-simpletype')"/>
        <xsl:variable name="is-complextype" select="$defining-class/imvert:stereotype/@id = (('stereotype-name-complextype','stereotype-name-referentielijst'))"/>
        <xsl:variable name="is-grouptype" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-composite')"/>
        
        <xsl:variable name="is-conceptual" select="exists($this/imvert:conceptual-schema-type)"/>
        <xsl:variable name="is-conceptual-complextype" select="$this/imvert:attribute-type-designation='complextype'"/>
        <xsl:variable name="is-conceptual-enumeration" select="$this/imvert:attribute-type-designation='enumeration'"/>
        <xsl:variable name="is-conceptual-hasnilreason" select="imf:boolean($this/imvert:attribute-type-hasnilreason)"/> <!-- IM-477 the conceptual type in external schema is nillable and therefore has nilReason attribute -->
        <xsl:variable name="name-conceptual-type" select="if ($this/imvert:attribute-type-name) then imf:get-type($this/imvert:attribute-type-name,$this/imvert:type-package) else ()"/>
        
        <xsl:variable name="type" select="if ($name-conceptual-type) then $name-conceptual-type else $found-type"/>
        
        <xsl:variable name="is-external" select="not($defining-class) and $this/imvert:type-package=$external-schema-names"/>
        <xsl:variable name="is-codelist" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-codelist')"/>
        <xsl:variable name="is-choice" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-union')"/>
        <xsl:variable name="is-choice-member" select="$this/ancestor::imvert:class/imvert:stereotype/@id = ('stereotype-name-union')"/>
        <xsl:variable name="is-composite" select="$this/imvert:aggregation='composite'"/>
        <xsl:variable name="is-collection-member" select="$this/../../imvert:stereotype/@id = ('stereotype-name-collection')"/>
        <xsl:variable name="is-primitive" select="exists($this/imvert:primitive)"/>
        <xsl:variable name="is-anonymous" select="$this/imvert:stereotype/@id = ('stereotype-name-anonymous')"/>
        <xsl:variable name="is-type-modified-incomplete" select="$this/imvert:type-modifier = '?'"/>
        
        <xsl:variable name="association-class-id" select="$this/imvert:association-class/imvert:type-id"/>
        <xsl:variable name="min-occurs-assoc" select="if ($this/imvert:min-occurs='0') then '0' else '1'"/>
        <xsl:variable name="min-occurs-target" select="if ($this/imvert:min-occurs='0') then '1' else $this/imvert:min-occurs"/>
        
        <xsl:variable name="codespace" select="(imf:get-data-location($this),if ($defining-class) then imf:get-data-location($defining-class) else ())"/>
        
        <xsl:variable name="appinfo-data-location" select="imf:get-appinfo-location($this)"/> 
        <xsl:variable name="appinfo-codelist">
            <xs:appinfo>
                <CodeListName>
                    <xsl:value-of select="$this/imvert:type-name"/>
                </CodeListName>
                <CodeListURI>
                    <xsl:value-of select="$codespace"/>
                </CodeListURI>
            </xs:appinfo>
        </xsl:variable>
        
        <xsl:if test="$this/imvert:conceptual-schema-type = ('Measure','Meetwaarde') and not($this/imvert:type-package = ('GML3','RO-BRO'))">
            <xsl:sequence select="imf:msg('WARNING', 'Measure type [1] occurs in unexpected package [2]', ($this/imvert:conceptual-schema-type,$this/imvert:type-package))"/>
        </xsl:if> 
        
        <xsl:variable name="is-gml-measure" select="
            ($this/imvert:conceptual-schema-type = 'Measure' and $this/imvert:type-package = 'GML3')
            or
            ($this/imvert:conceptual-schema-type = 'Meetwaarde' and $this/imvert:type-package = 'RO-BRO')
            "/>

        <xsl:variable name="data-location" select="imf:get-appinfo-location($this)"/>
        
        <xsl:variable name="has-key" select="$defining-class/imvert:attributes/imvert:attribute[imvert:stereotype/@id = 'stereotype-name-key']"/>
        
        <xsl:variable name="use-identifier-domains" select="imf:boolean(imf:get-xparm('cli/identifierdomains','no'))"/>
        <xsl:variable name="domain-value" select="imf:get-tagged-value($this,'##CFG-TV-DOMAIN')"/>
        

        
        <xsl:choose>
            
            <!-- preliminary -->
            <xsl:when test="$codespace[2]">
                <xsl:sequence select="imf:msg($this,'ERROR','Codespace set on attribute as well as on type: [1] and [2]', ($codespace))"/>
            </xsl:when>
            
            <!-- any type, i.e. #any -->
            <xsl:when test="$is-any">
                <xsl:variable name="package-name" select="$this/imvert:any-from-package"/>
                <xsl:variable name="package-namespace" select="$document-packages[imvert:name=$package-name]/imvert:namespace"/>
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'Any type')"/>
                    <xs:complexType mixed="true">
                        <xs:sequence>
                            <xs:any minOccurs="0" maxOccurs="unbounded">
                                <xsl:attribute name="namespace" select="if (exists($package-name)) then $package-namespace else '##any'"/>
                                <xsl:attribute name="processContents">lax</xsl:attribute>
                            </xs:any>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-mix">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'Mix of elements')"/>
                    <xs:complexType mixed="true">
                        <!-- TODO how to define possible elements in mixed contents? -->
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="exists($has-key)">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A keyed value')"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="xs:string">
                                <xs:attribute name="{$has-key/imvert:name}" type="xs:string"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>  
            </xsl:when>
            
            <!--x
            <xsl:when test="$type=('postcode')"> <!- -TODO remove - ->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A postcode')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:simpleType>
                        <xs:restriction base="xs:string">
                            <xs:pattern value="[0-9]{{4}}[A-Z]{{2}}"/>
                        </xs:restriction>
                    </xs:simpleType>
                </xs:element>
            </xsl:when>
            x-->
            
            <!-- base types such as xs:string and xs:boolean -->
            <xsl:when test="$type=('xs:dateTime','xs:date','xs:time') and $is-type-modified-incomplete and $is-nillable"> <!-- incomplete type, and could be, but may may not be empty -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable incomplete datetime, date or time')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xsl:variable name="fixtype">
                                <xsl:choose>
                                    <xsl:when test="$type='xs:dateTime'">Fixtype_incompleteDateTime</xsl:when>
                                    <xsl:when test="$type='xs:date'">Fixtype_incompleteDate</xsl:when>
                                    <xsl:when test="$type='xs:time'">Fixtype_incompleteTime</xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xs:extension base="{imf:get-type($fixtype,$package-name)}">
                                <xsl:sequence select="imf:create-nilreason($is-conceptual-hasnilreason)"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$type=('xs:dateTime','xs:date','xs:time') and $is-type-modified-incomplete"> <!-- incomplete type -->
                <xsl:variable name="fixtype">
                    <xsl:choose>
                        <xsl:when test="$type='xs:dateTime'">Fixtype_incompleteDateTime</xsl:when>
                        <xsl:when test="$type='xs:date'">Fixtype_incompleteDate</xsl:when>
                        <xsl:when test="$type='xs:time'">Fixtype_incompleteTime</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="imf:get-type($fixtype,$package-name)"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An incomplete datetime, date or time')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="starts-with($type,'xs:') and $is-nillable"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <!-- 
                                Determine the effective type, this is the actual type such as xs:string or a generated basetype 
                                When basetype, the type referenced in the extension is the generated type, 'Basetype_*', introduced at the end of the schema 
                            -->
                            <xsl:variable name="effective-type" select="if ($is-restriction) then imf:get-type($basetype-name,$package-name) else $type"/>
                            <xsl:sequence select="imf:create-xml-debug-comment($this,if ($is-restriction) then 'A restriction on a primitive' else 'Not a restriction on a primitive')"/>
                            <xs:extension base="{$effective-type}">
                                <xsl:sequence select="imf:create-nilreason($is-conceptual-hasnilreason)"/>
                                <xsl:sequence select="imf:create-estimation($is-estimation)"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="starts-with($type,'xs:') and $is-restriction"> <!-- any xsd primitve type such as xs:string, with local restrictions such as patterns -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A restriction on a primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xsl:choose>
                        <xsl:when test="false() and $is-estimation"> <!-- deactivated! -->
                            <!-- TODO research / This is a restriction on xs:string datatype, but also extension as attributes are added. How? -->
                            <xs:complexType>
                                <xs:simpleContent>
                                    <xs:restriction base="{$type}">
                                        <xsl:sequence select="imf:create-datatype-property($this,$type)"/>
                                    </xs:restriction>
                                    <xsl:sequence select="imf:create-estimation($is-estimation)"/>
                                </xs:simpleContent>
                            </xs:complexType>
                        </xsl:when>
                        <xsl:otherwise>
                            <xs:simpleType>
                                <xs:restriction base="{$type}">
                                    <xsl:sequence select="imf:create-datatype-property($this,$type)"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xsl:otherwise>
                    </xsl:choose>
                </xs:element>
            </xsl:when>
            <xsl:when test="($type=('xs:string') and not($this/imvert:baretype='TXT')) or ($is-primitive and $this/imvert:type-name = 'xs:string')"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:variable name="nonempty" select="imf:create-nonempty-constraint($this)"/>
                    <xsl:choose>
                        <xsl:when test="exists($nonempty)">
                            <!-- strings may not be empty -->
                            <xsl:sequence select="imf:create-xml-debug-comment($this,'A string, mode 1')"/>
                            <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                            <xs:simpleType>
                                <xs:restriction base="{$type}">
                                    <xsl:sequence select="$nonempty"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="type" select="'xs:string'"/>
                            <xsl:sequence select="imf:create-xml-debug-comment($this,'A string, mode 2')"/>
                            <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xs:element>
            </xsl:when>
            <xsl:when test="starts-with($type,'xs:')"> 
                <!-- any xsd primitve type such as xs:integer, and the TXT type -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-primitive and $is-restriction"> 
                <!-- any xsd primitve type such as integer -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A restriction on a primitive type, after mapping')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                    <xs:simpleType>
                        <xs:restriction base="{$this/imvert:type-name}">
                            <xsl:sequence select="imf:create-datatype-property($this,$this/imvert:primitive)"/> 
                        </xs:restriction>
                    </xs:simpleType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-primitive"> 
                <!-- any xsd primitve type such as integer -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$this/imvert:type-name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A primitive type, after mapping')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-codelist and $is-nillable">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:attribute name="type" select="if ($codelist-option = 'Option1') then 'gml:ReferenceType' else if ($codelist-option = 'Option2') then 'gml:CodeType' else concat($type,'Type')"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,concat('A nillable codelist attribute at ', $codelist-option))"/>
                    <xsl:sequence select="imf:get-annotation($this,(),$appinfo-codelist)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-codelist">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="type" select="if ($codelist-option = 'Option1') then 'gml:ReferenceType' else if ($codelist-option = 'Option2') then 'gml:CodeType' else concat($type,'Type')"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,concat('A codelist attribute at ', $codelist-option))"/>
                    <xsl:sequence select="imf:get-annotation($this,(),$appinfo-codelist)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-enumeration and $is-nillable">
                <!-- an enumeration  -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable enumeration')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{$type}{$Type-suffix}">
                                <xsl:sequence select="imf:create-nilreason($is-conceptual-hasnilreason)"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-gml-measure">
                <xsl:variable name="uom" select="imf:get-most-relevant-compiled-taggedvalue($this,'##CFG-TV-UNITOFMEASURE')"/>
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:choose>
                        <xsl:when test="$is-nillable">
                            <xsl:attribute name="nillable">true</xsl:attribute>
                            <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable conceptual complex type, a GML Measure')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:create-xml-debug-comment($this,'A conceptual complex type, a GML Measure')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:restriction base="gml:MeasureType">
                                <xs:attribute name="uom" type="gml:UomIdentifier" use="required" fixed="{$uom}" />
                            </xs:restriction>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="($is-complextype or $is-conceptual-complextype) and $is-nillable">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable complex type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xsl:variable name="ext">
                            <xs:extension base="{$type}{$Type-suffix}">
                                <xsl:sequence select="imf:create-nilreason($is-conceptual-hasnilreason)"/>
                            </xs:extension>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="exists($defining-class/imvert:pattern)">
                                <xsl:sequence select="imf:create-xml-debug-comment($this,'The referenced type is simplified by pattern')"/>
                                <xs:simpleContent>
                                    <xsl:sequence select="$ext"/>
                                </xs:simpleContent>
                            </xsl:when>
                            <xsl:otherwise>
                                <xs:complexContent>
                                    <xsl:sequence select="$ext"/>
                                </xs:complexContent>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="$is-conceptual-complextype">
                <!-- note that we do not support avoiding substitution on complex datatypes -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A conceptual complex type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-conceptual-enumeration">
                <!-- note that we do not support avoiding substitution on complex datatypes -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="concat($type,$EnumerationType-suffix)"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A conceptual enumeration')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-complextype">
                <!-- note that we do not support avoiding substitution on complex datatypes --> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="concat($type,$PropertyType-suffix)"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A complex type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-datatype and $is-nillable">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable datatype')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{$type}{$Type-suffix}">
                                <xsl:sequence select="imf:create-nilreason($is-conceptual-hasnilreason)"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-datatype and $use-identifier-domains and $domain-value"><!-- TODO ook nillable hier kunnen opvangen? -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A datatype with domain')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{concat($type,$Type-suffix)}">
                                <xs:attribute name="domein" type="xs:string" fixed="{$domain-value}"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-enumeration or $is-datatype">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="concat($type,$Type-suffix)"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An enumeration or datatype')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="not($name) and $is-external">
                <!-- a reference to an external construct -->
                <xs:element>
                    <xsl:attribute name="ref" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'No name and the type is external')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-choice and $is-nillable"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'The type of this property is a union, and voidable')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                    <xs:complexType>
                        <xs:complexContent>
                            <xs:extension base="{concat($type,$PropertyType-suffix)}">
                                <xsl:sequence select="imf:create-nilreason($is-conceptual-hasnilreason)"/>
                            </xs:extension>
                        </xs:complexContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-choice"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="concat($type,$PropertyType-suffix)"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'The type of this property is a union')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-choice-member"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xs:complexType>
                        <xsl:sequence select="imf:create-xml-debug-comment($this,'A member of a union')"/>
                        <xsl:sequence select="imf:get-annotation($this)"/>
                        <xs:complexContent>
                            <xs:extension base="gml:AbstractMemberType">
                                <xs:sequence>
                                    <xs:element>
                                        <xsl:attribute name="ref" select="$type"/>
                                    </xs:element>
                                </xs:sequence>
                                <xs:attributeGroup ref="gml:AssociationAttributeGroup"/>
                            </xs:extension>
                        </xs:complexContent>
                    </xs:complexType>
                    
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-external and $is-nillable">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="1"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable external type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element ref="{$type}" minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}"/>
                        </xs:sequence>
                        <xsl:sequence select="imf:create-nilreason($is-conceptual-hasnilreason)"/>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-external">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="1"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An external type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <!-- TODO continue: introduce correct reference / see IM-59 -->
                    <xsl:variable name="reftype" select="$type"/>
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element ref="{$reftype}" minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}"/>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-conceptual">
                <!--TODO dit is waarschijnlijk te beperkt. De externe modellen moeten beter afgehandeld worden. -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="1"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A conceptual type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="not($defining-class)">
                <xsl:sequence select="imf:create-xml-debug-comment($this,'No defining class!')"/>
                <xsl:sequence select="imf:msg('ERROR','Reference to an undefined class [1]',$type)"/>
                <!-- this can be the case when this class is not part of a configured package, please correct in UML -->
            </xsl:when>
            <xsl:when test="not($name) or $is-anonymous"> 
                <!-- an unnamed association -->
                <xs:element>
                    <xsl:attribute name="ref" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An unnamed association')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- assume: Linkable, or flattened association class, or attributegroup --> 
                
                <!-- note that association classes are resolved/flattened in UML; see 10-129r1_Geography_Markup_Language_GML_Version_3.3.pdf section 12.3 -->
                
                <xsl:sequence select="imf:create-xml-debug-comment($this,'An association')"/>
                <xs:element minOccurs="{$this/imvert:min-occurs}" maxOccurs="{$this/imvert:max-occurs}">
                    <!-- 
                        When no role name specified, use the association name 
                        This should be rejected by validation
                    -->
                    <xsl:variable name="usable-name" select="if (normalize-space($target-role-name)) then $target-role-name else $name"/>
                    
                    <xsl:attribute name="name" select="$usable-name"/>
                    <xsl:attribute name="nillable" select="if ($is-nillable) then 'true' else 'false'"/>
                    
                    <xsl:choose>
                        <xsl:when test="$is-grouptype">
                            <xsl:attribute name="type" select="concat(imf:get-qname($defining-class),$Type-suffix)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="type" select="concat(imf:get-qname($defining-class),$PropertyType-suffix)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An objecttype')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    


     
    <xsl:template match="imvert:union">
        <xsl:variable name="membertypes" as="item()*">
            <!-- for each referenced datatype, determine the actual XSD equivalent. Produce a xs:union construct. -->
            <xsl:for-each select="tokenize(normalize-space(.),'\s+')">
                <xsl:value-of select="imf:get-type(.,'')"/>
            </xsl:for-each>
        </xsl:variable>
        <xs:union memberTypes="{string-join($membertypes,' ')}"/>
    </xsl:template>
    

    <xsl:function name="imf:is-estimation" as="xs:boolean">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="$this/imvert:stereotype/@id = ('stereotype-name-estimation')"/>
    </xsl:function>
    
    <?x associates komen niet meer voor?
        
    <xsl:function name="imf:is-association-class" as="xs:boolean">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="exists($this/imvert:associates)"/>
    </xsl:function>
    ?>
    

    

    
    <xsl:function name="imf:create-estimation">
        <xsl:param name="is-estimation" as="xs:boolean"/>
        <xsl:if test="$is-estimation">
            <xs:attribute name="estimated" type="xs:boolean" use="optional"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation" as="node()*">
        <xsl:param name="construct" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/model-info/technical-documentation',imf:compile-documentation($construct))"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/model-info/content-documentation',())"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/model-info/version-documentation',())"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/model-info/external-documentation',())"/>
    </xsl:function>
    
    <xsl:function name="imf:get-appinfo-version" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/model-info/project',$document/imvert:packages/imvert:project)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/model-info/application',$document/imvert:packages/imvert:application)"/> 
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/model-info/release',imf:get-release($this))"/> 
        
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/model-info/version',$this/imvert:version)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/model-info/phase',$this/imvert:phase)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/model-info/uri',$this/imvert:namespace)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/model-info/generated',$generation-date)"/> 
   
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/xml-schema-info/file-location',imf:get-xsd-filesubpath($this))"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/xml-schema-info/generated',$current-datetime)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/xml-schema-info/generator',$current-imvertor-version)"/>
    </xsl:function>
    
    
    <xsl:function name="imf:get-namespace" as="xs:string">
        <xsl:param name="this" as="element(imvert:package)"/> 
        
        <xsl:variable name="schema-version" select="$this/imvert:version"/>
        <xsl:variable name="schema-version-majorminor" select="string-join(subsequence(tokenize($schema-version,'\.'),1,2),'.')"/>
        
        <xsl:choose>
            <xsl:when test="$this/imvert:stereotype/@id = ('stereotype-name-external-package')">
                <xsl:value-of select="$this/imvert:namespace"/>
            </xsl:when>
            <xsl:when test="$namespace-composition = 'none'">
                <xsl:value-of select="$this/imvert:namespace"/>
            </xsl:when>
            <xsl:when test="$namespace-composition = 'version'">
                <xsl:value-of select="concat($this/imvert:namespace,'/', $schema-version)"/>
            </xsl:when>
            <xsl:when test="$namespace-composition = 'versionMajorMinor'">
                <xsl:value-of select="concat($this/imvert:namespace,'/', $schema-version-majorminor)"/>
            </xsl:when>
            <xsl:otherwise><!-- assume "release" -->
                <xsl:value-of select="concat($this/imvert:namespace,'/v', imf:get-release($this))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:compile-documentation">
        <xsl:param name="this"/>
        <xsl:variable name="name" select="imf:get-most-relevant-compiled-taggedvalue($this,'##CFG-TV-NAME')"/>
        <xsl:variable name="definition" select="imf:get-most-relevant-compiled-taggedvalue($this,'##CFG-TV-DEFINITION')"/>
        <xsl:variable name="explanation" select="imf:get-most-relevant-compiled-taggedvalue($this,'##CFG-TV-DESCRIPTION')"/>
        <xsl:variable name="pnam" select="if ($name) then concat('Name: ', $name) else ()"/>
        <xsl:variable name="pdef" select="if ($definition) then concat('Definition: ', normalize-space(string-join($definition,' '))) else ()"/>
        <xsl:variable name="pexp" select="if ($explanation) then concat('Explanation: ', normalize-space(string-join($explanation,' '))) else ()"/>
        <xsl:value-of select="string-join(($pnam,$pdef,$pexp),'&#10;')"/>
    </xsl:function>
    
    <!-- MIM variant kan zijn: rol of relatie. ISO vereist rol, maar ook relaties ondersteunen. Deze functie geeft een van beide terug afhankelijk van wat hij aantreft -->
    
    <xsl:function name="imf:get-ISOrole-info" as="element()*">
        <xsl:param name="association" as="element()*"/>
        <xsl:sequence select="for $a in $association return ($a/imvert:target,$a)[1]"/>
    </xsl:function>
    

    
</xsl:stylesheet>
