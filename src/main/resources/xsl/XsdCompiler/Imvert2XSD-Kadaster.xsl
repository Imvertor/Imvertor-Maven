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

<!-- adaptations
     
     after 1.27.1
        introduce <mark approach="elm"">
        remove estimations
        remove approach="att"

-->

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    
    xmlns:ekf="http://EliotKimber/functions"

    exclude-result-prefixes="#all"
    version="2.0">

    <!-- TODO enhance - Schema indent nice and predictable; 
        attributes alphabetically sorted within element. Texts must be normalized-spaced. Needed for technical diffs. -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-doc.xsl"/>
    
    <xsl:import href="common-xsd.xsl"/>
    
    <xsl:variable name="stylesheet-code">KAS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:variable name="avoid-substitutions" select="not(imf:boolean($use-substitutions))"/>
    
    <xsl:param name="config-file-path">unknown-file</xsl:param>
   
    <xsl:variable name="meta-is-role-based" select="imf:boolean(imf:get-xparm('appinfo/meta-is-role-based'))"/>
    
    <xsl:variable 
        name="reference-classes" 
        select="$imvert-document//imvert:class[imvert:ref-master]" 
        as="node()*"/>
    
    <xsl:variable name="base-namespace" select="/imvert:packages/imvert:base-namespace"/>
    
    <xsl:variable name="Type-suffix"><!--geen--></xsl:variable>
    <xsl:variable name="PropertyType-suffix"><!--geen--></xsl:variable>
    <xsl:variable name="EnumerationType-suffix"><!--geen--></xsl:variable>
    
    <xsl:template match="/">
        <xsl:sequence select="imf:template-create-schemas()"/>
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
                
                <!-- XSD complextypes -->
                <xsl:apply-templates select="imvert:class[not(imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist','stereotype-name-simpletype'))]"/>
            
                <!-- XSD simpletypes -->
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]"/>
  
                <!-- XSD enumerations -->
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist')]"/>
                
                <?x
                <!-- simple type attributes for attributes types that restrict a simple type; needed to set nilReason attribute -->
                <xsl:apply-templates 
                    select="imvert:class/imvert:attributes/imvert:attribute[(imvert:stereotype/@id = ('stereotype-name-voidable') or $is-forced-nillable) and imf:is-restriction(.)]"
                    mode="nil-reason">
                    <xsl:with-param name="package-name" select="$this-package/imvert:name"/>
                </xsl:apply-templates>
                x?>
                
                <xsl:if test="imvert:class/imvert:attributes/imvert:attribute[imvert:type-name='scalar-date' and imvert:type-modifier='?']">
                    <xs:simpleType name="Fixtype_incompleteDate">
                        <xsl:sequence select="imf:create-fixtype-property('scalar-date')"/>
                    </xs:simpleType>
                </xsl:if> 
                <xsl:if test="imvert:class/imvert:attributes/imvert:attribute[imvert:type-name=('scalar-datetime') and imvert:type-modifier='?']">
                    <xs:simpleType name="Fixtype_incompleteDateTime">
                        <xsl:sequence select="imf:create-fixtype-property('scalar-datetime')"/>
                    </xs:simpleType>
                </xsl:if> 
                <xsl:if test="imvert:class/imvert:attributes/imvert:attribute[imvert:type-name=('scalar-time') and imvert:type-modifier='?']">
                    <xs:simpleType name="Fixtype_incompleteTime">
                        <xsl:sequence select="imf:create-fixtype-property('scalar-time')"/>
                    </xs:simpleType>
                </xsl:if> 
            </xs:schema>
        
        </imvert:schema>
    </xsl:template>
        
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]">
        <xs:simpleType name="{imvert:name}">
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
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]">
        <xs:simpleType name="{imvert:name}">
            <xsl:variable name="appinfo-data-location" select="imf:get-appinfo-location(.)"/>
            <xsl:sequence select="imf:get-annotation(.,(),$appinfo-data-location)"/>
            <xs:restriction base="xs:string">
                <xsl:sequence select="imf:create-datatype-property(.,'xs:string')"/>
            </xs:restriction>
        </xs:simpleType>
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
                <xs:simpleType name="{imvert:name}">
                    <xsl:sequence select="imf:get-annotation(.)"/>
                    <xs:restriction base="{$supertype-primitive}">
                        <xsl:sequence select="imf:create-datatype-property(.,$supertype-primitive)"/>
                    </xs:restriction>
                </xs:simpleType>
            </xsl:when>
            <xsl:otherwise>
                <!-- A type like zipcode -->
                <xsl:sequence select="imf:create-xml-debug-comment(.,'A simple datatype')"/>
                <xs:simpleType name="{imvert:name}">
                    <xsl:sequence select="imf:get-annotation(.)"/>
                    <xsl:variable name="supertype">xs:string</xsl:variable>
                    <xs:restriction base="{$supertype}">
                        <xsl:sequence select="imf:create-datatype-property(.,'xs:string')"/>
                    </xs:restriction>
                </xs:simpleType>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-service')]">
        
        <xsl:variable name="method" select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-ENVELOPEMETHOD')"/>
     
        <xsl:variable name="type-name" select="imvert:name"/>
        <xsl:variable name="package-name" select="parent::imvert:package/imvert:name"/>

        <xsl:variable name="assocs" select="imvert:associations/imvert:association"/>
        <xsl:variable name="assoc-pr" select="$assocs[imvert:type-name='ProcesResultaat']"/>
        <xsl:variable name="assoc-pg" select="$assocs[imvert:type-name='ProductGegevens']"/>
        <xsl:variable name="assoc-log" select="$assocs[imvert:type-name='Log']"/>
        <xsl:variable name="assoc-proces" select="$assocs except ($assoc-pr,$assoc-pg,$assoc-log)"/> <!-- rest of the assocs must be products -->
        
        <xsl:variable name="targets" select="for $target in $assocs/imvert:type-id return imf:get-construct-by-id($target)"/>
        <xsl:variable name="products" select="$targets[imvert:stereotype/@id = ('stereotype-name-product')]"/>
      
        <!-- get the name of the first association that has a name entered by the modeller. --> 
        <xsl:variable name="rname" select="($assocs/imvert:name[not(@origin = 'system')])[1]"/>
        <xsl:variable name="results-name" select="if ($products[2] or empty($rname)) then 'GeleverdProduct' else $rname"/>
        
        <xsl:variable name="EnvelopProces-prefix" select="'pr'"/>
        <xsl:variable name="EnvelopProduct-prefix" select="'pg'"/>
        <xsl:variable name="EnvelopLog-prefix" select="'lg'"/>
        
        <xsl:variable name="is-request" select="ends-with(imvert:name,'Request')"/>
        <xsl:variable name="is-response" select="ends-with(imvert:name,'Response')"/>
        
        <xs:element name="{$type-name}">
            <xs:complexType>
                <xs:sequence>
                    <xsl:if test="exists($assoc-pr)">
                        <xs:element ref="{$EnvelopProces-prefix}:ProcesVerwerking" minOccurs="{$assoc-pr/imvert:min-occurs}" maxOccurs="{$assoc-pr/imvert:max-occurs}"/>
                    </xsl:if> 
                    <xsl:if test="exists($assoc-pg)">
                        <xs:element ref="{$EnvelopProduct-prefix}:ProductGegevens" minOccurs="{$assoc-pg/imvert:min-occurs}" maxOccurs="{$assoc-pg/imvert:max-occurs}"/>
                    </xsl:if> 
                    <xsl:variable name="products" as="element()*">
                        <xsl:for-each select="$assoc-proces">
                            <xsl:variable name="target" select="imf:get-construct-by-id(imvert:type-id)"/>
                            <xsl:variable name="min-occurs" select="imvert:min-occurs"/>
                            <xsl:variable name="max-occurs" select="imvert:max-occurs"/>
                            
                            <!-- test if the target is a product -->
                            <xsl:sequence select="
                                if (not($target/imvert:stereotype/@id = ('stereotype-name-process'))) 
                                then imf:msg(.,'ERROR','Target in [1] is not [2]',(imf:get-config-stereotypes('stereotype-name-service'),imf:get-config-stereotypes('stereotype-name-product'))) else ()"/>
                            
                            <xs:element ref="{imf:get-type($target/imvert:name,$target/parent::imvert:package/imvert:name)}" minOccurs="{$min-occurs}" maxOccurs="{$max-occurs}"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$is-request">
                            <xs:element name="verzoek">
                                <xs:complexType>
                                    <xs:choice>
                                        <xsl:sequence select="$products"/>
                                    </xs:choice>
                                </xs:complexType>
                            </xs:element>
                        </xsl:when>
                        <xsl:when test="$is-response">
                            <xs:element name="antwoord">
                                <xs:complexType>
                                    <xs:choice>
                                        <xsl:sequence select="$products"/>
                                    </xs:choice>
                                </xs:complexType>
                            </xs:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg(.,'ERROR','This service is not a request or response',())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="exists($assoc-log)">
                        <xs:element ref="{$EnvelopLog-prefix}:Log"  minOccurs="{$assoc-log/imvert:min-occurs}" maxOccurs="{$assoc-log/imvert:max-occurs}"/>
                    </xsl:if>
                </xs:sequence>
            </xs:complexType>
        </xs:element>
    </xsl:template>
    
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
        <xsl:variable name="is-includable" select="imf:boolean(imf:get-tagged-value(.,'##CFG-TV-INCLUDABLE'))"/>
        <xsl:variable name="appinfo-data-location" select="imf:get-appinfo-location(.)"/>
        <!-- all classes are element + complex type declaration; except for datatypes (<<datatype>>). -->
        <xsl:variable name="is-choice-member" select="$document-classes[imvert:stereotype/@id = ('stereotype-name-union') and imvert:attributes/imvert:attribute/imvert:type-id = $type-id]"/>
        
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
        
        <xsl:sequence select="imf:create-xml-debug-comment(.,'Base class processing')"/>
        <xsl:if test="(not(imvert:stereotype/@id = ('stereotype-name-simpletype')) or $is-choice-member) and not($is-keyed)">
            <xsl:sequence select="imf:create-xml-debug-comment(.,'A union element, or not a datatype and not keyed')"/>
            <xs:element name="{$type-name}" type="{imf:get-type($type-name,$package-name)}" abstract="{$abstract}">
                <xsl:choose>
                    <xsl:when test="not($supertype-name and not($avoid-substitutions))">
                        <!-- nothing -->
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
                <xsl:sequence select="imf:get-annotation(.,(),$appinfo-data-location)"/>
            </xs:element>
        </xsl:if>
        
        <xsl:variable name="content" as="element()?">
            <xsl:choose>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-system-reference-class') and $use-identifier-domains and not($supertype-name) and $domain-value">
                    <complex>
                        <xsl:sequence select="imf:create-xml-debug-comment(.,'Has a domain value')"/>
                        <xs:simpleContent>
                            <xs:extension base="xs:string">
                                <xs:attribute ref="xlink:href" use="optional"/>
                                <xs:attribute name="domein" use="optional" fixed="{$domain-value}"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </complex>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-system-reference-class') and $use-identifier-domains and exists($ref-master-identifiable-subtypes-with-domain)">
                    <complex>
                        <xsl:sequence select="imf:create-xml-debug-comment(.,'Reference master has (some) identifiable subtypes that have a domain')"/>
                        <xs:simpleContent>
                            <xs:extension base="xs:string">
                                <xs:attribute ref="xlink:href" use="optional"/>
                                <xs:attribute name="domein" use="optional" type="xs:string"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </complex>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-system-reference-class') and not($supertype-name)">
                    <complex>
                        <xsl:sequence select="imf:create-xml-debug-comment(.,'No supertypes, no domain processing')"/>
                        <xs:simpleContent>
                            <xs:extension base="xs:string">
                                <xs:attribute ref="xlink:href" use="optional"/><!-- sinds 1.61 -->
                            </xs:extension>
                        </xs:simpleContent>
                    </complex>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-union-datatypes','stereotype-name-union-attributes')"><!-- use case 1, 2, 3 -->
                    <!-- A choice between classes that represent datatypes. -->
                    <xsl:variable name="atts">
                        <xsl:for-each select="imvert:attributes/imvert:attribute">
                            <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                            <xsl:variable name="defining-class" select="imf:get-defining-class(.)"/>   
                            <xsl:variable name="defining-class-subclasses" select="imf:get-subclasses($defining-class)"/>   
                            
                            <xsl:variable name="defining-class-is-datatype" select="$defining-class/imvert:stereotype/@id = (
                                ('stereotype-name-simpletype','stereotype-name-enumeration','stereotype-name-codelist','stereotype-name-complextype','stereotype-name-union'))"/>   
                            <xsl:variable name="defining-class-is-primitive" select="exists(imvert:primitive)"/>   
                            <xsl:choose>
                                <xsl:when test="$defining-class-is-datatype or $defining-class-is-primitive">
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice attribute member, which is a primitive datatype')"/>
                                    <xsl:sequence select="imf:create-element-property(.)"/>
                                </xsl:when>
                                <xsl:when test="empty($defining-class) and $allow-scalar-in-union">
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice attribute member, which is a scalar type')"/>
                                    <xsl:sequence select="imf:create-element-property(.)"/>
                                </xsl:when>
                                <xsl:when test="empty($defining-class)">
                                    <xsl:sequence select="imf:msg(.,'ERROR', 'Unable to create a union of scalar types',())"/> <!-- IM-291 -->
                                </xsl:when>
                                <xsl:when test="imf:is-linkable($defining-class) and imf:boolean($buildcollection) and exists($defining-class-subclasses)"> 
                                    <!-- insert the subtypes rather than the abstract supertype -->
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice attribute  member, linkable, abstract')"/>
                                    <xsl:for-each select="($defining-class,$defining-class-subclasses)">
                                        <xs:element ref="{imf:get-reference-class-name(.)}"/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="imf:is-linkable($defining-class) and imf:boolean($buildcollection)"> 
                                    <!-- when the class is linkable, and using collections, use the reference element name -->
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice attribute member, linkable')"/>
                                    <xs:element ref="{imf:get-reference-class-name($defining-class)}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice attribute member')"/>
                                    <xsl:variable name="minOccurs" select="if (imvert:min-occurs) then imvert:min-occurs else '1'"/>
                                    <xsl:variable name="maxOccurs" select="if (imvert:max-occurs) then imvert:max-occurs else '1'"/>
                                    <xs:element ref="{imf:get-qname($defining-class)}" minOccurs="{$minOccurs}" maxOccurs="{$maxOccurs}"/>  
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="$atts">
                        <complex>
                            <xs:choice>
                                <xsl:attribute name="minOccurs" select="if (imvert:min-occurs) then imvert:min-occurs else '1'"/>
                                <xsl:attribute name="maxOccurs" select="if (imvert:max-occurs) then imvert:max-occurs else '1'"/>
                                <xsl:sequence select="imf:create-xml-debug-comment(.,'A number of attribute choices')"/>
                                <xsl:sequence select="$atts"/>
                            </xs:choice>
                        </complex>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-union-associations')"><!-- use case 4 -->
                    <xsl:variable name="assocs">
                        <xsl:for-each select="imvert:associations/imvert:association">
                            <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                            <xsl:variable name="defining-class" select="imf:get-defining-class(.)"/>   
                            <xsl:variable name="defining-class-subclasses" select="imf:get-subclasses($defining-class)"/>   
                            
                            <xsl:choose>
                                <xsl:when test="imf:is-linkable($defining-class) and imf:boolean($buildcollection) and exists($defining-class-subclasses)"> 
                                    <!-- insert the subtypes rather than the abstract supertype -->
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice association member, linkable, abstract')"/>
                                    <xsl:for-each select="($defining-class,$defining-class-subclasses)">
                                        <xs:element ref="{imf:get-reference-class-name(.)}"/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="imf:is-linkable($defining-class) and imf:boolean($buildcollection)"> 
                                    <!-- when the class is linkable, and using collections, use the reference element name -->
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice association member, linkable')"/>
                                    <xs:element ref="{imf:get-reference-class-name($defining-class)}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:create-xml-debug-comment(.,'A choice association member')"/>
                                    <xsl:variable name="minOccurs" select="if (imvert:min-occurs) then imvert:min-occurs else '1'"/>
                                    <xsl:variable name="maxOccurs" select="if (imvert:max-occurs) then imvert:max-occurs else '1'"/>
                                    <xs:element ref="{imf:get-qname($defining-class)}" minOccurs="{$minOccurs}" maxOccurs="{$maxOccurs}"/>  
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="$assocs">
                        <complex>
                            <xs:choice>
                                <xsl:attribute name="minOccurs" select="if (imvert:min-occurs) then imvert:min-occurs else '1'"/>
                                <xsl:attribute name="maxOccurs" select="if (imvert:max-occurs) then imvert:max-occurs else '1'"/>
                                <xsl:sequence select="imf:create-xml-debug-comment(.,'A number of association choices')"/>
                                <xsl:sequence select="$assocs"/>
                            </xs:choice>
                        </complex>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-complextype') and exists($formal-pattern)"><!-- IM-325 -->
                    <simple>
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
                        <xs:restriction base="xs:string">
                            <xs:pattern value="{$formal-pattern}"/>
                        </xs:restriction>
                    </simple>
                </xsl:when>
                
                <xsl:otherwise>
                    <complex>
                        <!-- XML elements are declared first -->
                        <xsl:variable name="atts" as="item()*">
                            <!-- 
                            UML Attribute positions default to 100. 
                            UML Association positions default to 200.
                            If all positions are explicitly set, use any value above 300 for convenience.
                            -->
                            <xsl:for-each select="imvert:attributes/imvert:attribute[not(imvert:type-name=$xml-attribute-type)] | imvert:associations/imvert:association">
                                <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                                <xsl:sequence select="imf:create-element-property(.)"/>
                            </xsl:for-each>
                            <?x associates komen niet meer voor?
                            <!-- then add associates for association class -->
                            <xsl:if test="imvert:associates">
                                <xsl:variable name="assoc-id" select="imvert:associates/imvert:target/imvert:id"/>
                                <xsl:variable name="association-class" select="$document//imvert:class[imvert:id=$assoc-id]"/>
                                <xs:element ref="{imf:get-qname($association-class)}"/>
                            </xsl:if>
                            ?>
                        </xsl:variable>
                        <xsl:if test="exists($atts)">
                            <xs:sequence>
                                <xsl:sequence select="$atts"/>
                            </xs:sequence>
                        </xsl:if>
                        <xsl:sequence select="imf:add-xmlbase($is-includable)"/>
                        
                        <!-- XML attributes are declared last -->
                        <!-- when <<ObjectType>> and no supertypes, assign id. -->
                        <!-- TODO enhance / Check if external schema provides ID
                            This assumes that any superclass taken from an external schema will provide the ID attribute. 
                            This should however be checked formally.
                            For kadaster schema's this is always the case, as may only inherit from AbstractFeatureType which defines an ID.
                        --> 
                        
                        <!-- IM-124 xml attribute id soms niet nodig -->
                        <xsl:variable name="incoming-refs" select="imf:get-references(.)"/>
                        <xsl:variable name="super-incoming-refs" select="for $c in imf:get-superclasses(.) return imf:get-references($c)"/>
                        
                        <xsl:if test="imvert:stereotype/@id = ('stereotype-name-objecttype') and exists($incoming-refs) and not(exists($super-incoming-refs))">
                            <xs:attribute name="id" type="xs:ID" use="optional"/>
                        </xsl:if>
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
                    <xsl:attribute name="name" select="$type-name"/>
                    <xsl:attribute name="abstract" select="$abstract"/>
                    <xsl:choose>
                        <xsl:when test="$supertype-name">
                            <xs:complexContent>
                                <xs:extension base="{imf:get-type($supertype-name,$supertype-package-name)}">
                                    <xsl:if test="exists($content/*)">
                                        <xsl:sequence select="$content/node()"/>
                                    </xsl:if>
                                </xs:extension>
                            </xs:complexContent>
                        </xsl:when>
                        <xsl:when test="exists($content/*)">
                            <xsl:sequence select="$content/node()"/>
                        </xsl:when>
                    </xsl:choose>      
                </xs:complexType>
            </xsl:when>
            <xsl:otherwise>
                <xs:simpleType>
                    <xsl:attribute name="name" select="$type-name"/>
                    <xsl:choose>
                        <xsl:when test="$supertype-name">
                            <xs:simpleContent>
                                <xs:extension base="{imf:get-type($supertype-name,$supertype-package-name)}">
                                    <xsl:if test="exists($content/*)">
                                        <xsl:sequence select="$content/node()"/>
                                    </xsl:if>
                                </xs:extension>
                            </xs:simpleContent>
                        </xsl:when>
                        <xsl:when test="exists($content/*)">
                            <xsl:sequence select="$content/node()"/>
                        </xsl:when>
                    </xsl:choose>      
                </xs:simpleType>
            </xsl:otherwise>
        </xsl:choose>
                
    </xsl:template>
    
    <?x
    <!-- 
        Create a simpletype from which a voidable simpletype can inherit (through restriction); needed to add a nilreason.
        See also http://stackoverflow.com/questions/626319/add-attributes-to-a-simpletype-or-restrictrion-to-a-complextype-in-xml-schema
    --> 
    <xsl:template match="imvert:attribute" mode="nil-reason">
        <xsl:variable name="basetype-name" select="imf:get-restriction-basetype-name(.)"/> <!-- e.g. Basetype_Bike_color -->
        
        <xsl:variable name="scalar" select="$all-scalars[@id=current()/imvert:type-name]"/> <!-- this is a scalar-string or the like -->
        <xsl:variable name="xs-type" select="$scalar/type-map[@formal-lang='xs']"/> <!-- returns xs:string or the like -->
        
        <xs:simpleType name="{$basetype-name}">
            <xs:annotation>
                <xs:documentation><p>Generated class. Introduced because the identified attribute is voidable and is a restriction of a simple type.</p></xs:documentation>
            </xs:annotation>
            <xs:restriction base="xs:{$xs-type}">
                <xsl:sequence select="imf:create-datatype-property(.)"/>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>
    x?>
    
    <xsl:template match="*|@*|text()">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:function name="imf:create-element-property" as="item()*">
        <xsl:param name="this" as="node()"/>
        
        <!-- nilllable may be forced for specific circumstances. This only applies to attributes of a true class or associations -->
        <xsl:variable name="is-property" select="exists(($this/self::imvert:attribute,$this/self::imvert:association))"/>
        <xsl:variable name="force-nillable" select="$is-property and $is-forced-nillable"/>
        
        <xsl:variable name="has-nilreason" select="imf:boolean(imf:get-tagged-value($this,'##CFG-TV-REASONNOVALUE'))"/>
        <xsl:variable name="has-voidable" select="imf:boolean(imf:get-tagged-value($this,'##CFG-TV-VOIDABLE'))"/>
        
        <xsl:variable name="is-voidable" select="$this/imvert:stereotype/@id = ('stereotype-name-voidable')"/> <!-- this is a kadaster combi: voidable and tv both required -->
        <xsl:variable name="is-nillable" select="$is-voidable or $has-voidable or $force-nillable"/>
        
        <xsl:variable name="is-restriction" select="imf:is-restriction($this)"/>
        <xsl:variable name="basetype-name" select="if ($is-nillable) then imf:get-restriction-basetype-name($this) else ''"/>
        <xsl:variable name="package-name" select="$this/ancestor::imvert:package[last()]/imvert:name"/>
        
        <xsl:variable name="name" select="if ($this/self::imvert:association and $meta-is-role-based) then $this/imvert:target/imvert:role else $this/imvert:name"/>
        <xsl:variable name="found-type" select="imf:get-type($this/imvert:type-name,$this/imvert:type-package)"/>
      
        <xsl:variable name="is-any" select="$found-type = '#any'"/>
        <xsl:variable name="is-mix" select="$found-type = '#mix'"/>
        
        <xsl:variable name="defining-class" select="imf:get-defining-class($this)"/>                            
        <xsl:variable name="is-enumeration-or-codelist" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist')"/>
        <xsl:variable name="is-datatype" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-simpletype')"/>
        <xsl:variable name="is-complextype" select="$defining-class/imvert:stereotype/@id = (('stereotype-name-complextype','stereotype-name-referentielijst'))"/>
        
        <xsl:variable name="is-conceptual-complextype" select="$this/imvert:attribute-type-designation='complextype'"/>
        <xsl:variable name="is-conceptual-hasnilreason" select="imf:boolean($this/imvert:attribute-type-hasnilreason)"/> <!-- IM-477 the conceptual type in external schema is nillable and therefore has nilReason attribute -->
        <xsl:variable name="name-conceptual-type" select="if ($this/imvert:attribute-type-name) then imf:get-type($this/imvert:attribute-type-name,$this/imvert:type-package) else ''"/>
        
        <xsl:variable name="type" select="if ($name-conceptual-type) then $name-conceptual-type else $found-type"/>
        
        <xsl:variable name="is-external" select="not($defining-class) and $this/imvert:type-package=$external-schema-names"/>
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
        
        <xsl:variable name="appinfo-data-location" select="imf:get-appinfo-location($this)"/>
        
        <xsl:variable name="has-key" select="$defining-class/imvert:attributes/imvert:attribute[imvert:stereotype/@id = 'stereotype-name-key']"/>
        
        <xsl:variable name="is-includable" select="imf:boolean(imf:get-tagged-value($this,'##CFG-TV-INCLUDABLE'))"/>
        
        <xsl:variable name="use-identifier-domains" select="imf:boolean(imf:get-xparm('cli/identifierdomains','no'))"/>
        <xsl:variable name="domain-value" select="imf:get-tagged-value($this,'##CFG-TV-DOMAIN')"/>
        
        <xsl:variable name="space-restriction" select="imf:create-nonempty-constraint('scalar-string')"/>
        
        <mark nillable="{$is-nillable}" nilreason="{$has-nilreason}">
            <xsl:choose>
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
            
            <xsl:when test="$type=('postcode')"> <!--TODO remove -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A postcode')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:simpleType>
                        <xs:restriction base="xs:string">
                            <xs:pattern value="[0-9]{{4}}[A-Z]{{2}}"/>
                        </xs:restriction>
                    </xs:simpleType>
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
            <xsl:when test="starts-with($type,'xs:') and $is-restriction"> <!-- any xsd primitve type such as xs:string, with local restrictions such as patterns -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A restriction on a primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:simpleType>
                        <xs:restriction base="{$type}">
                            <xsl:sequence select="imf:create-datatype-property($this,$type)"/>
                        </xs:restriction>
                    </xs:simpleType>
                </xs:element>
            </xsl:when>
                <xsl:when test="$type=('xs:string') and $space-restriction"> 
                    <xs:element>
                        <xsl:attribute name="name" select="$name"/>
                        <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                        <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                        <xsl:sequence select="imf:create-xml-debug-comment($this,'A string with actual content')"/>
                        <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                        <xs:simpleType>
                            <xs:restriction base="{$type}">
                               <xsl:sequence select="$space-restriction"/>
                            </xs:restriction>
                        </xs:simpleType>
                    </xs:element>
                </xsl:when>
                <?x            
            <xsl:when test="starts-with($type,'xs:')"> 
                <!-- 
                    Determine the effective type, this is the actual type such as xs:string or a generated basetype 
                    When basetype, the type referenced in the extension is the generated type, 'Basetype_*', introduced at the end of the schema 
                -->
                <xsl:variable name="effective-type" select="if ($is-restriction) then imf:get-type($basetype-name,$package-name) else $type"/>
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$effective-type"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A voidable primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            x?>
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
            <xsl:when test="$is-primitive and $this/imvert:type-name = 'xs:string'"> 
                <!-- als het feitelijk een string betreft, dan ook de facet dat deze niet leeg mag zijn --> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A string, after mapping')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                    <xs:simpleType>
                        <xs:restriction base="xs:string">
                            <xs:pattern value="\S.*"/>
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
            <xsl:when test="$is-enumeration-or-codelist">
                <!-- an enumeration or a datatype such as postcode -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An enumeration or codelist')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="($is-complextype or $is-conceptual-complextype)">
                <!-- note that we do not support avoiding substitution on complex datatypes --> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A complex type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-datatype and $use-identifier-domains and $domain-value">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A datatype with domain')"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{$type}">
                                <xs:attribute name="domein" type="xs:string" fixed="{$domain-value}"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-datatype">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A datatype')"/>
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
            <xsl:when test="$is-choice"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'The type of this property is a union')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-choice-member"> 
                <!-- an attribute of a NEN3610 union -->
                <xs:element>
                    <xsl:attribute name="ref" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A member of a union')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
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
            <xsl:when test="not($defining-class)">
                <xsl:sequence select="imf:create-xml-debug-comment($this,'No defining class!')"/>
                <xsl:sequence select="imf:msg('ERROR','Reference to an undefined class [1]',$type)"/>
                <!-- this can be the case when this class is not part of a configured package, please correct in UML -->
            </xsl:when>
            <xsl:when test="not($name) or $is-anonymous"> 
                <!-- an unnamed association -->
                <xsl:choose>
                    <xsl:when test="$avoid-substitutions">
                        <xs:choice minOccurs="{$this/imvert:min-occurs}" maxOccurs="{$this/imvert:max-occurs}">
                            <xsl:variable name="sub-classes" select="($defining-class, imf:get-substitution-classes($defining-class))"/>
                            <xsl:sequence select="imf:create-xml-debug-comment($this,'An unnamed association, avoiding substitutions')"/>
                            <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                            <xsl:for-each select="$sub-classes[not(imf:boolean(imvert:abstract))]">
                                <xs:element ref="{imf:get-qname(.)}"/>
                            </xsl:for-each>
                        </xs:choice>
                    </xsl:when>
                    <xsl:otherwise>
                        <xs:element>
                            <xsl:attribute name="ref" select="$type"/>
                            <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                            <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                            <xsl:sequence select="imf:create-xml-debug-comment($this,'An unnamed association')"/>
                            <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                        </xs:element>
                    </xsl:otherwise>            
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$name and $is-collection-member and imf:boolean($profile-collection-wrappers)">
                <!-- must wrap the element -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:choose>
                        <xsl:when test="$avoid-substitutions">
                            <xs:complexType>
                                <xs:choice>
                                    <xsl:variable name="sub-classes" select="($defining-class, imf:get-substitution-classes($defining-class))"/>
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'A wrapped member, avoiding substitutions')"/>
                                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                                    <xsl:for-each select="$sub-classes[not(imf:boolean(imvert:abstract))]">
                                        <xs:element ref="{imf:get-qname(.)}"/>
                                    </xsl:for-each>
                                </xs:choice>
                            </xs:complexType>
                        </xsl:when>
                        <xsl:otherwise>
                            <xs:element>
                                <xsl:attribute name="ref" select="$type"/>
                                <xsl:sequence select="imf:create-xml-debug-comment($this,'A wrapped member')"/>
                                <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                            </xs:element>
                        </xsl:otherwise>            
                    </xsl:choose>
                </xs:element>
            </xsl:when>
            <xsl:when test="imf:is-linkable($defining-class)">
                <!-- TODO IM-83 STALLED, BUT IMPLEMENTED FOR THIS CASE -->
                <!-- 
                    The class is an Objecttype, and therefore linkable.
                    This also covers void.
                    When component, and if components must be anonymous, do not create named element for relation type. (IM-83)
                -->
                <xsl:variable name="content">
                    <xsl:variable name="ref-classes" select="imf:get-linkable-subclasses-or-self($defining-class)"/>
                    <xsl:variable name="choice">
                        <!-- 
                            Any reference to an object type is realized through an Xref element.
                            We do not consider composite relations to be treated specially 
                            (and do not place a reference to X).
                        -->
                        <xsl:for-each select="$ref-classes">
                            <!-- IM-110 alle elementen hier zijn linkable -->
                            <xsl:choose>
                                <xsl:when test="not(imf:boolean($buildcollection)) and imf:is-abstract(.)">
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'Buildcollection suppressed, abstract class ignored')"/>
                                </xsl:when>
                                <xsl:when test="not(imf:boolean($buildcollection))">
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'Buildcollection suppressed')"/>
                                    <xs:element ref="{imf:get-qname(.)}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'Buildcollection allowed')"/>
                                    <xs:element ref="{imf:get-reference-class-name(.)}"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$association-class-id">
                            <xs:sequence minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}">
                                <xs:choice>
                                    <xsl:sequence select="$choice"/>
                                </xs:choice>
                                <!-- TODO improvement / association class probably not covered well -->
                                <xsl:sequence select="imf:create-xml-debug-comment($this,'An association class')"/>
                                <xsl:variable name="association-class" select="$imvert-document//imvert:class[imvert:id=$association-class-id]"/>
                                <xs:element ref="{imf:get-qname($association-class)}"/>
                            </xs:sequence>
                        </xsl:when>
                        <xsl:otherwise>
                            <xs:choice minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}">
                                <xsl:sequence select="$choice"/>
                            </xs:choice>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$is-composite and imf:boolean($anonymous-components) and not($is-nillable)">
                        <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                        <xs:sequence>
                            <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                            <xsl:attribute name="maxOccurs" select="1"/>
                            <xsl:sequence select="imf:create-xml-debug-comment($this,'An objecttype, anonymous')"/>
                            <xsl:sequence select="$content"/>
                        </xs:sequence>
                    </xsl:when>
                    <xsl:otherwise>
                        <xs:element>
                            <xsl:attribute name="name" select="$name"/>
                            <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                            <xsl:attribute name="maxOccurs" select="1"/>
                            <xsl:choose>
                                <xsl:when test="$is-composite and imf:boolean($anonymous-components) and $is-nillable">
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An objecttype, anonymous, but voidable')"/>
                                    <xsl:sequence select="imf:msg('WARNING','Anonymous component is voidable and therefore must be named: [1]',$name)"/>
                                </xsl:when>
                                <xsl:when test="$is-nillable">
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An objecttype, voidable')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'An objecttype')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                            <xs:complexType>
                                <xsl:sequence select="$content"/>
                            </xs:complexType>                            
                        </xs:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- TODO IM-83 STALLED, NOT IMPLEMENTED YET FOR THIS CASE -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="1"/>
                    <xsl:sequence select="imf:get-annotation($this,$appinfo-data-location,())"/>
                    <xs:complexType>
                        <xsl:variable name="result">
                            <xsl:choose>
                                <!-- TODO improvement / association classes are not covered well by current implementation; check out more contexts where the assoc. class may occur -->
                                <xsl:when test="$association-class-id">
                                    <xsl:sequence select="imf:create-xml-debug-comment($this,'Default property definition: an association class')"/>
                                    <xsl:variable name="association-class" select="$imvert-document//imvert:class[imvert:id=$association-class-id]"/>
                                    <xs:element ref="{imf:get-qname($association-class)}" minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$avoid-substitutions">
                                            <xsl:sequence select="imf:create-xml-debug-comment($this,'Default property definition, avoiding substitutions')"/>
                                            <xsl:variable name="sub-classes" select="($defining-class, imf:get-substitution-classes($defining-class))"/>
                                            <xsl:variable name="result-set" select="$sub-classes[not(imf:boolean(imvert:abstract))]"/>
                                            <xsl:choose>
                                                <xsl:when test="count($result-set) gt 1">
                                                    <xs:choice>
                                                        <xsl:attribute name="minOccurs" select="$min-occurs-target"/>
                                                        <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                                                        <xsl:sequence select="imf:create-xml-debug-comment($this,'... and the result set counts more that 1')"/>
                                                        <xsl:for-each select="$result-set">
                                                            <xs:element ref="{imf:get-qname(.)}"/>
                                                        </xsl:for-each>
                                                    </xs:choice>
                                                </xsl:when>
                                                <xsl:when test="count($result-set) eq 0">
                                                    <xsl:sequence select="imf:msg('ERROR','Attempt to reference an abstract class: [1]',$name)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xs:element ref="{imf:get-qname($result-set)}">
                                                        <xsl:attribute name="minOccurs" select="$min-occurs-target"/>
                                                        <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                                                        <xsl:sequence select="imf:create-xml-debug-comment($this,'... and the result set counts 1')"/>
                                                    </xs:element>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="imf:create-xml-debug-comment($this,'Default property definition')"/>
                                            <xs:element ref="{$type}" minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}"/>
                                        </xsl:otherwise>            
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="$result">
                            <xs:sequence>
                                <xsl:sequence select="$result"/>
                            </xs:sequence>
                        </xsl:if>
                    </xs:complexType>
                </xs:element>
            </xsl:otherwise>
        </xsl:choose>
        </mark>
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

    <?x associates komen niet meer voor?
        
    <xsl:function name="imf:is-association-class" as="xs:boolean">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="exists($this/imvert:associates)"/>
    </xsl:function>
    ?>
    
    <xsl:function name="imf:get-documentation" as="node()*">
        <xsl:param name="construct" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/technical-documentation',
            imf:xhtml-to-flatdoc(imf:get-compiled-documentation-as-html($construct)))"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/content-documentation',())"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/version-documentation',())"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/external-documentation',())"/>
    </xsl:function>
    
    <xsl:function name="imf:get-appinfo-version" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/uri',$this/imvert:namespace)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/version',$this/imvert:version)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/phase',$this/imvert:phase)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/release',imf:get-release($this))"/> 
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/generated',$generation-date)"/> 
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/generator',$imvertor-version)"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/owner',$owner-name)"/> 
        <!--<xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/svn',concat($char-dollar,'Id',$char-dollar))"/>-->
    </xsl:function>
        
    <xsl:function name="imf:get-namespace" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:choose>
            <xsl:when test="$this/imvert:stereotype='external-package'">
                <xsl:value-of select="$this/imvert:namespace"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($this/imvert:namespace,'/v', imf:get-release($this))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        Get the name of the referencing element. 
        This is the reference class for internal classes (such as AbcRef), or the element itself in any external schema.
        When the external schema conforms to the imvert mode for referencing (AbcRef), and a reference is made to this schema, 
        the reference package (normally generated implictly and on the fly) must be included explicitly.
    -->
    <xsl:function name="imf:get-reference-class-name" as="xs:string">
        <xsl:param name="this" as="node()"/> <!-- any defining class -->
        <xsl:variable name="external-package" select="$this/ancestor::imvert:package[imvert:stereotype/@id = ('stereotype-name-external-package')][1]"/>
        <xsl:variable name="ref-classes" select="$reference-classes[imvert:ref-master=$this/imvert:name]"/> <!-- returns Class1Ref or the like -->
        <xsl:variable name="ref-class" select="$ref-classes[parent::imvert:package/imvert:ref-master=$this/parent::imvert:package/imvert:name]"/>
        <xsl:choose>
            <xsl:when test="$external-package">
                <xsl:value-of select="imf:get-qname($this)"/>
            </xsl:when>
            <xsl:when test="not($external-package) and not($ref-class)">
                <xsl:value-of select="imf:msg('ERROR', 'Cannot determine the reference class for class [1] (package [2])', ($this/imvert:name, $this/parent::imvert:package/imvert:name))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-qname($ref-class)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="imf:add-xmlbase" as="element(xs:attribute)?">
        <xsl:param name="is-includable"/>
        <xsl:if test="$is-includable">
            <xs:attribute ref="xml:base" use="optional"/>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>
