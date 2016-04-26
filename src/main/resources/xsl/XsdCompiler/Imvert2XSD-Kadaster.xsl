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

    exclude-result-prefixes="#all"
    version="2.0">

    <!-- TODO enhance - Schema indent nice and predictable; 
        attributes alphabetically sorted within element. Texts must be normalized-spaced. Needed for technical diffs. -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-doc.xsl"/>
    
    <xsl:variable name="avoid-substitutions" select="if ($use-substitutions='no') then true() else false()"/>
    
    <xsl:param name="config-file-path">unknown-file</xsl:param>
   
    <xsl:output indent="yes" method="xml" encoding="UTF-8" exclude-result-prefixes="#all"/>
    
    <xsl:variable name="xsd-folder-path" select="imf:get-config-string('system','xsd-folder-path')"/>

    <!-- 
        Determine which type is defined in which package 
    -->
    <xsl:variable name="type-in-package" as="element()*">
        <xsl:apply-templates select="$document//imvert:class" mode="type-in-package"/>
    </xsl:variable>
    
    <!-- 
        What types result in an attribute in stead of an element? 
        This is always the case for ID values.
        It is not possible to mix the use of types on elements and attributes. 
        Note that Imvertor is element-oriented, not attribute-oriented.
    -->
    <xsl:variable name="xml-attribute-type" select="('ID')"/>

    <xsl:variable 
        name="external-schema-names" 
        select="$document//imvert:package[imvert:stereotype=(imf:get-config-stereotypes(('stereotype-name-external-package','stereotype-name-system-package')))]/imvert:name" 
        as="xs:string*"/>
    
    <xsl:variable 
        name="reference-classes" 
        select="$document//imvert:class[imvert:ref-master]" 
        as="node()*"/>
    
    <xsl:variable name="base-namespace" select="/imvert:packages/imvert:base-namespace"/>
    
    <xsl:template match="imvert:class" mode="type-in-package">
        <type 
            name="{imvert:name}"
            id="{imvert:id}"
            prefix="{imf:get-short-name(parent::imvert:package/imvert:name)}" 
            ns="{imf:get-namespace(parent::imvert:package)}" 
            file="{imf:get-xsd-filesubpath(parent::imvert:package)}"/>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:variable name="application-release" select="imf:get-release(/imvert:package)"/>
        <imvert:schemas>
            <xsl:sequence select="imf:create-info-element('imvert:exporter',$document/imvert:packages/imvert:exporter)"/>
            <xsl:sequence select="imf:create-info-element('imvert:schema-exported',$document/imvert:packages/imvert:exported)"/>
            <xsl:sequence select="imf:create-info-element('imvert:schema-filter-version',imf:get-svn-id-info($document/imvert:packages/imvert:filter/imvert:version))"/>
            <xsl:sequence select="imf:create-info-element('imvert:latest-svn-revision',concat($char-dollar,'Id',$char-dollar))"/>
            
            <!-- Schemas for external packages are not generated, but added to the release manually. -->
            <xsl:apply-templates select="$document/imvert:packages/imvert:package[not(imvert:name = $external-schema-names)]"/>
        </imvert:schemas>
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
        
        <xsl:variable name="this-package-referenced-linkable-subclasses" as="node()*">
            <xsl:for-each select="$this-package-associated-classes">
                <xsl:sequence select="imf:get-linkable-subclasses-or-self(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="this-package-referenced-substitutable-subclasses" as="node()*">
            <xsl:if test="$avoid-substitutions">
                <xsl:for-each select="$this-package-associated-classes">
                    <xsl:sequence select="imf:get-substitutable-subclasses-or-self(.)"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="schema-version" select="imvert:version"/>
        <xsl:variable name="schema-phase" select="imvert:phase"/>
        <xsl:variable name="schema-release" select="imf:get-release(.)"/>
        
        <!-- precompile namespaces and imports 
        
            An import is inserted when this package references a type in the imported package, unless this is a relation type and 
            the class is referenced (Xref, in stead of X).
        -->
        <xsl:variable name="nsim-tally" as="node()*">
            <!--
                is this a reference package? (generated by system)
            -->
            <xsl:if test="$this-package-is-referencing">
                <xsl:variable name="pack" select="$document-packages[imvert:name = imf:get-normalized-name('xlinks','package-name')]"/>
                <xsl:choose>
                    <xsl:when test="imf:boolean($external-schemas-reference-by-url)">
                        <import xmlns="" prefix="xlink" namespace="{$pack/imvert:namespace}" schemaLocation="{$pack/imvert:location}" reason="(10) this package uses linking constructs; schema reference is by URL"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="file-fullpath" select="imf:get-xsd-filefullpath($pack)"/>
                        <import xmlns="" prefix="xlink" namespace="{$pack/imvert:namespace}" schemaLocation="{$file-fullpath}" reason="(10) this package uses linking constructs; schema reference is local"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
    
            <!-- 
                Do we need to reference external schema's? 
                If so, a reference is made to the name of the external schema. 
            -->
            <xsl:for-each select="$this-package//(imvert:type-package|imvert:supertype[not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-static-generalization'))]/imvert:type-package)[.=$external-schema-names]">
                <xsl:variable name="type" select="."/>
                <xsl:variable name="pack" select="$document-packages[imvert:name=$type]"/>
                <xsl:variable name="prefix" select="imf:get-short-name($pack/imvert:name)"/>
                <xsl:choose>
                    <xsl:when test="imf:boolean($external-schemas-reference-by-url)">
                        <import xmlns="" prefix="{$prefix}" namespace="{$pack/imvert:namespace}" schemaLocation="{$pack/imvert:location}" reason="(11a) defines a required type or dynamic supertype of any construct within the current schema; schema reference is by URL"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="file-fullpath" select="imf:get-xsd-filefullpath($pack)"/>
                        <import xmlns="" prefix="{$prefix}" namespace="{$pack/imvert:namespace}" schemaLocation="{$file-fullpath}" reason="(11b) defines a required type or dynamic supertype of any construct within the current schema; schema reference is local"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <!-- 
                Import all packages that are referenced
                Scan each package in this application to see if it satisfies some import criterium.
                If so, add it to the list of imports.
            -->
            <xsl:for-each select="$document-packages[.!=$this-package and not(imvert:name=$external-schema-names)]">
                <xsl:variable name="scanned-package" select="."/>
                <xsl:variable name="scanned-package-name" select="$scanned-package/imvert:name"/>
                <xsl:variable name="scanned-package-prefix" select="imf:get-short-name($scanned-package-name)"/>
                <xsl:variable name="scanned-package-types" select="$type-in-package[@prefix=$scanned-package-prefix]" as="item()*"/>
                
                <xsl:variable name="referenced" as="xs:string?">
                    <xsl:choose>
                        <!-- 
                            Does the scanned package define any of the current package's subtypes and if so, is that relation static? 
                            This is the case when the subtype relation is between <<Objecttype>>s and it not stereotyped <<dynamic>>.
                        --> 
                        <xsl:when test="$scanned-package/imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')]/imvert:supertype[not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-dynamic-generalization'))]/imvert:type-id = $this-package/imvert:id">
                            <xsl:value-of select="'(0) defines any of the current schema subtypes and the relation is static'"/>
                        </xsl:when>
                        <!-- 
                            does the scanned package define any of the current package's supertypes and is this relation dynamic? 
                        --> 
                        <xsl:when test="$scanned-package-types/@id = $this-package/imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')]/imvert:supertype[not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-static-generalization'))]/imvert:type-id">
                            <xsl:value-of select="'(1) defines any of the current schema supertypes which is an objectttype, and the relation is dynamic'"/>
                        </xsl:when>
                        <!-- 
                            for all other type relations, all subtyping is dynamic 
                        --> 
                        <xsl:when test="$scanned-package-types/@id = $this-package/imvert:class[not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype'))]/imvert:supertype/imvert:type-id">
                            <xsl:value-of select="'(1) defines any of the current schema supertypes (but not an object type), and the relation is dynamic'"/>
                        </xsl:when>
                        
                        <!-- 
                            does the scanned package define any of the current package's attribute types (excluding unions)? 
                        --> 
                        <xsl:when test="$scanned-package-types/@id = $this-package/imvert:class[not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union'))]/imvert:attributes/imvert:attribute/imvert:type-id">
                            <xsl:value-of select="'(2) defines the type of some attribute in this schema'"/>
                        </xsl:when>
                        
                        <!-- 
                            does the scanned package define any of the current package's association types? 
                        --> 
                        <xsl:when test="$scanned-package-types/@id = $this-package-associated-type-ids">
                            <xsl:value-of select="'(3) defines the type of some association in this schema'"/>
                        </xsl:when>
                        
                        <!-- 
                            does the scanned package define a subtype of any of the current package's association types, and do we avoid substitutions? 
                        --> 
                        <xsl:when test="
                            not($this-package-is-referencing) 
                            and
                            $scanned-package/imvert:class/imvert:id = $this-package-referenced-substitutable-subclasses/imvert:id">
                            <xsl:value-of select="'(3) defines a subtype of some association in this schema and we avoid substitutions'"/>
                        </xsl:when>
                        
                        <!-- 
                            static substitution inheritance: import the scanned package when it defines a reference class which implements a reference to any of the current package's concrete subclasses 
                        --> 
                        <xsl:when test="
                            not($this-package-is-referencing) 
                            and 
                            $scanned-package/imvert:class/imvert:ref-master = $this-package-referenced-linkable-subclasses/imvert:name
                            ">
                            <xsl:value-of select="'(6) defines a reference type (Xref) which implements a reference to any of the current schema concrete subtypes'"/>
                        </xsl:when> 
                        
                        <!-- 
                            import the scanned package when it defines a reference class which implements a reference to any of the current package's classes 
                        --> 
                        <xsl:when test="not($this-package-is-referencing) and $scanned-package/imvert:class/imvert:ref-master = $this-package/imvert:class/imvert:associations/imvert:association/imvert:type-name">
                            <xsl:value-of select="'(4) defines a reference type (Xref) which implements a reference to any of the current schema types, by association type'"/>
                        </xsl:when> 
                        <xsl:when test="not($this-package-is-referencing) and $scanned-package/imvert:class/imvert:ref-master = $this-package/imvert:class/imvert:attributes/imvert:attribute/imvert:type-name">
                            <xsl:value-of select="'(5) defines a reference type (Xref) which implements a reference to any of the current schema types, by attribute type'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:variable name="referenced-no-ref" as="xs:string?">
                    <xsl:choose>
                        <!-- Objecttypes only occur in associations. So test referenced for associations only. -->
                        <xsl:when test="starts-with($referenced,'(3)')">
                            <!-- determine which types, references by this package, are defined in the scanned package --> 
                            <xsl:variable name="associated-types" select="
                                if ($avoid-substitutions) 
                                then $scanned-package-types[@id = $this-package-referenced-substitutable-subclasses/imvert:id]
                                else $scanned-package-types[@id = $this-package-associated-type-ids]
                                "/>
                            <!-- determine which classes in the current package reference that type -->
                            <xsl:variable name="classes" select="
                                if ($avoid-substitutions) 
                                then $this-package/imvert:class[.//imvert:association/imvert:type-id = $this-package-referenced-substitutable-subclasses/imvert:id]
                                else $this-package/imvert:class[.//imvert:association/imvert:type-id = $associated-types/@id]"/>
                            <xsl:choose>
                                <!-- check if the class is a collection -->
                                <xsl:when test="$classes[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')]">
                                    <!-- at least one of the classes that references the object is a collection, so we need to include the class. -->
                                    <xsl:value-of select="$referenced"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Compile a list of all association types that are referenced in the scanned package, and that do not function as a ref-master of any class -->
                                    <!-- When all references to a type are types for which a reference class is created (i.e. a class with a ref-master), do not import -->
                                    <!-- Example: Adres::_WoonlocatieBinnenland -->
                                    <xsl:variable name="this-package-associated-types-in-scanned-package" as="item()*">
                                        <xsl:for-each select="$this-package-associated-types">
                                            <xsl:variable name="name" select="xs:string(.)"/>
                                            <xsl:if test="($name = $scanned-package-types/@name) and not($document-classes/imvert:ref-master = $name)">
                                                <xsl:sequence select="."/>
                                            </xsl:if>
                                        </xsl:for-each>           
                                    </xsl:variable> 
                                    <xsl:if test="exists($this-package-associated-types-in-scanned-package)">
                                        <xsl:value-of select="$referenced"/>
                                    </xsl:if>      
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$referenced"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$referenced-no-ref">
                    <xsl:variable name="namespace" select="imf:get-namespace($scanned-package)"/>
                    <xsl:variable name="file-fullpath" select="imf:get-xsd-filefullpath($scanned-package)"/>
                    <import xmlns="" prefix="{$scanned-package-prefix}" namespace="{$namespace}" schemaLocation="{$file-fullpath}" reason="{$referenced-no-ref}"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- filter namespace/imports so that each is represented once -->
        <xsl:variable name="nsim" as="node()*">
            <xsl:for-each-group select="$nsim-tally" group-by="@namespace">
                <xsl:sort select="@namespace"/>
                <xsl:sequence select="."/>
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:variable name="schema-subpath" select="imf:get-xsd-filesubpath(.)"/>
        <xsl:variable name="schemafile" select="imf:get-xsd-filefullpath(.)"/>
        <imvert:schema> 
            <xsl:sequence select="imvert:name"/>
            <xsl:sequence select="imf:create-info-element('imvert:namespace',imf:get-namespace(.))"/>
            <xsl:sequence select="imf:create-info-element('imvert:result-file-subpath',$schema-subpath)"/>
            <xsl:sequence select="imf:create-info-element('imvert:xsd-path',$xsd-folder-path)"/>
            <xsl:sequence select="imf:create-info-element('imvert:result-file-fullpath',$schemafile)"/>
        </imvert:schema>
        
        <xsl:result-document href="{$schemafile}" method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
            <xs:schema>
                <!-- schema attributes -->
                <xsl:attribute name="targetNamespace" select="imf:get-namespace(.)"/>
                <xsl:attribute name="elementFormDefault" select="'qualified'"/>
                <xsl:attribute name="attributeFormDefault" select="'unqualified'"/>
                
                <!-- set version attribute to the version number -->
                <xsl:attribute name="version" select="concat($schema-version,'-',$schema-phase)"/>
        
                <!-- set my own namespaces (qualified) -->
                <xsl:namespace name="{imf:get-short-name(imvert:name)}" select="imf:get-namespace(.)"/>
                
                <!-- set namespaces of all imported schema's -->
                <xsl:for-each select="$nsim">
                    <xsl:namespace name="{@prefix}" select="@namespace"/>
                </xsl:for-each>
                
                <!-- version info -->
                <xsl:sequence select="imf:get-annotation(.,imf:get-schema-info(.),imf:get-appinfo-version(.))"/>
                
                <!-- set the imports -->
                <xsl:for-each select="$nsim">
                    <xsl:sequence select="imf:debug($this-package,concat('Import because: ',@reason))"/>
                    <!-- schema location which is absolute (http://, file:// etc.) is copied as-is, other locations are relative to current schema -->
                    <xsl:variable name="schemalocation" select="if (contains(@schemalocation,':')) then @schemalocation else imf:get-rel-path($schemafile,@schemaLocation)"/>
                    <xs:import namespace="{@namespace}" schemaLocation="{$schemalocation}"/>
                </xsl:for-each>
                
                <!-- XSD complextypes -->
                <xsl:apply-templates select="imvert:class[not(imvert:stereotype=(imf:get-config-stereotypes(('stereotype-name-enumeration','stereotype-name-codelist'))) or imvert:designation='datatype')]"/>
            
                <!-- XSD simpletypes -->
                <xsl:apply-templates select="imvert:class[imvert:designation='datatype']"/>
  
                <!-- XSD enumerations -->
                <xsl:apply-templates select="imvert:class[imvert:stereotype=(imf:get-config-stereotypes(('stereotype-name-enumeration','stereotype-name-codelist')))]"/>
                
                <!-- simple type attributes for attributes types that restrict a simple type; needed to set nilReason attribute -->
                <xsl:apply-templates 
                    select="imvert:class/imvert:attributes/imvert:attribute[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-voidable') and imf:is-restriction(.)]"
                    mode="nil-reason">
                    <xsl:with-param name="package-name" select="$this-package/imvert:name"/>
                </xsl:apply-templates>
                
                <xsl:if test="imvert:class/imvert:attributes/imvert:attribute[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-voidable') and imvert:type-modifier='?']">
                    <xs:simpleType name="Fixtype_incompleteDate">
                        <xs:union memberTypes="xs:date xs:gYearMonth xs:gYear"/>
                    </xs:simpleType>
                </xsl:if> 
            </xs:schema>
        </xsl:result-document>
        
        <xsl:variable name="must-cva" select="imf:boolean(imf:get-config-string('cli','create-cva-files'))"/>
        <xsl:variable name="atts" select="$this-package//imvert:attribute[imvert:type-name=imf:get-config-parameter('class-name-waardelijst')]"/>
        <xsl:if test="$must-cva and $atts[1]">
        
            <xsl:variable name="infos" as="element()*">
                <xsl:for-each select="$atts">
                    <xsl:sequence select="imf:get-cva-info(.)"/>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:variable name="xsd-filename" select="substring-before(tokenize($schema-subpath,'/')[last()],'.xsd')"/>
            <xsl:variable name="cva-localname" select="concat('rules-', $xsd-filename)"/>
            <xsl:variable name="cvafile" select="concat(substring-before($schemafile, '.xsd'),'.cva')"/>
            
            <xsl:result-document href="{$cvafile}" method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
                <cva:ContextValueAssociation 
                    xmlns:cva="http://docs.oasis-open.org/codelist/ns/ContextValueAssociation/1.0/"
                    queryBinding="xslt"
                    name="{$cva-localname}"
                    >
                    <xsl:for-each select="$infos">
                        <xsl:namespace name="{@prefix}" select="@ns"/>
                    </xsl:for-each>
                    <!-- set the namespace of the referenced elements in xpath -->
                    <Title>This is a context/value association file for the XML schema at <xsl:value-of select="concat('http://www.imvertor.org/schema/',$schema-subpath)"/>.</Title>
                    <ValueLists>
                        <xsl:for-each-group select="$atts" group-by="imvert:data-location">
                            <xsl:variable name="info" select="imf:get-cva-info(current-group()[1])"/>
                            <ValueList xml:id="{$info/@id}" uri="{$info/@uri}" key="Code"/>
                        </xsl:for-each-group>
                    </ValueLists>
                    <Contexts>
                        <xsl:for-each select="$infos">
                            <Context item="{@item}" scope="{@scope}" values="{@id}"/>
                        </xsl:for-each>
                    </Contexts>
                </cva:ContextValueAssociation>
            </xsl:result-document>      
        </xsl:if>
      
    </xsl:template>
        
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-enumeration')]">
        <xs:simpleType name="{imvert:name}">
            <xsl:sequence select="imf:get-annotation(.)"/>
            <xs:restriction base="xs:string">
                <xsl:for-each select="imvert:enum">
                    <xsl:sort select="xs:integer(imvert:position)" order="ascending"/>
                    <xs:enumeration value="{.}"/>
                </xsl:for-each>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>    
    
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-codelist')]">
        <xs:simpleType name="{imvert:name}">
            <xsl:sequence select="imf:get-annotation(.)"/>
            <xs:restriction base="xs:string">
                <xsl:for-each select="imvert:enum">
                    <xsl:sort select="xs:integer(imvert:position)" order="ascending"/>
                    <xs:enumeration value="{.}"/>
                </xsl:for-each>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>    
    
    <xsl:template match="imvert:class[imvert:designation='datatype']">
        <xsl:choose>
            <xsl:when test="imvert:attributes/* or imvert:associations/*">
                <xsl:sequence select="imf:debug(.,'Datatype with data elements or associations')"/>
                <xsl:next-match/> <!-- i.e. template that matches imvert:class --> 
            </xsl:when>
            <xsl:when test="imvert:union">
                <xsl:sequence select="imf:debug(.,'Datatype is a union')"/>
                <xs:simpleType name="{imvert:name}">
                    <xsl:sequence select="imf:get-annotation(.)"/>
                    <xsl:apply-templates select="imvert:union"/>
                </xs:simpleType>
            </xsl:when>
            <xsl:otherwise>
                <!-- A type like zipcode -->
                <xsl:sequence select="imf:debug(.,'A simple datatype')"/>
                <xs:simpleType name="{imvert:name}">
                    <xsl:sequence select="imf:get-annotation(.)"/>
                    <xs:restriction base="xs:string">
                        <xsl:sequence select="imf:create-datatype-property(.)"/>
                    </xs:restriction>
                </xs:simpleType>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <xsl:variable name="package-name" select="parent::imvert:package/imvert:name"/>
        <xsl:variable name="type-name" select="imvert:name"/>
        <xsl:variable name="type-id" select="imvert:id"/>
        <xsl:variable name="primitive" select="imvert:primitive"/>
        <xsl:variable name="supertype" select="imvert:supertype[not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-static-generalization'))][1]"/>
        <xsl:variable name="supertype-name" select="$supertype/imvert:type-name"/>
        <xsl:variable name="supertype-package-name" select="$supertype/imvert:type-package"/>
        <xsl:variable name="supertype-substitutiongroup" select="$supertype/imvert:xsd-substitutiongroup"/> 
        <xsl:variable name="abstract" select="imvert:abstract"/>
        
        <xsl:variable name="data-location" select="imf:get-appinfo-location(.)"/>
        
        <!-- all classes are element + complex type declaration; except for datatypes (<<datatype>>). -->
        <xsl:variable name="is-choice-member" select="$document-classes[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union') and imvert:attributes/imvert:attribute/imvert:type-id = $type-id]"/>
        
        <xsl:sequence select="imf:debug(.,'Base class processing')"/>
        <xsl:if test="not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-datatype')) or $is-choice-member">
            <xsl:sequence select="imf:debug(.,'A union element, or not a datatype')"/>
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
                <xsl:sequence select="imf:get-annotation(.,(),$data-location)"/>
            </xs:element>
        </xsl:if>
        
        <xsl:variable name="content" as="element()?">
            <xsl:choose>
                <xsl:when test="imvert:stereotype=imf:get-config-stereotypes('stereotype-name-system-reference-class') and not($supertype-name)">
                    <complex>
                        <xs:attribute name="type" type="xs:string" fixed="simple"/>
                        <xs:attribute ref="xlink:href" use="required"/>
                    </complex>
                </xsl:when>
                <xsl:when test="imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union')">
                    <!-- attributes of a NEN3610 union, i.e. a choice between classes. The choice is a specialization of a datatype -->
                    <xsl:variable name="atts">
                        <xsl:for-each select="imvert:attributes/imvert:attribute">
                            <xsl:sort select="xs:integer(imvert:position)" order="ascending"/>
                            <xsl:variable name="defining-class" select="imf:get-defining-class(.)"/>   
                            <xsl:variable name="is-composite" select="imvert:aggregation='composite'"/>
                            <xsl:choose>
                                <xsl:when test="empty($defining-class)">
                                    <xsl:sequence select="imf:msg(.,'ERROR', 'Unknown type for attribute',())"/> <!-- IM-291 -->
                                </xsl:when>
                                <xsl:when test="imf:is-linkable($defining-class) and imf:boolean($buildcollection)"> 
                                    <!-- when the class is linkable, and using collections, use the reference element name -->
                                    <xs:element ref="{imf:get-reference-class-name($defining-class)}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- not linkable -->
                                    <xsl:sequence select="imf:create-element-property(.)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="$atts">
                        <complex>
                            <xs:choice>
                                <xsl:attribute name="minOccurs" select="if (imvert:min-occurs) then imvert:min-occurs else '1'"/>
                                <xsl:attribute name="maxOccurs" select="if (imvert:max-occurs) then imvert:max-occurs else '1'"/>
                                <xsl:sequence select="$atts"/>
                            </xs:choice>
                        </complex>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="imvert:stereotype=imf:get-config-stereotypes('stereotype-name-complextype') and exists(imvert:pattern)"><!-- IM-325 -->
                    <simple>
                        <xs:annotation>
                            <xs:documentation>This complex datatype is transformed to a simple type because a content pattern is defined.</xs:documentation>
                        </xs:annotation>
                        <xs:restriction base="xs:string">
                            <xs:pattern value="{imvert:pattern}"/>
                        </xs:restriction>
                    </simple>
                </xsl:when>
                <xsl:when test="imvert:stereotype=imf:get-config-stereotypes('stereotype-name-datatype') and exists(imvert:pattern)">
                    <simple>
                        <xs:restriction base="xs:string">
                            <xs:pattern value="{imvert:pattern}"/>
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
                                <xsl:sort select="xs:integer(imvert:position)" order="ascending"/>
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
                        
                        <xsl:if test="imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype') and exists($incoming-refs) and not(exists($super-incoming-refs))">
                            <xs:attribute name="id" type="xs:ID" use="optional"/>
                        </xsl:if>
                        <xsl:for-each select="imvert:attributes/imvert:attribute[imvert:type-name=$xml-attribute-type]">
                            <xsl:sort select="xs:integer(imvert:position)" order="ascending"/>
                            <xsl:sequence select="imf:create-attribute-property(.)"/>
                        </xsl:for-each>
                    </complex>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$content/self::complex">
                <xs:complexType>
                    <xsl:attribute name="name" select="$type-name"/>
                    <xsl:attribute name="abstract" select="$abstract"/>
                    <xsl:choose>
                        <xsl:when test="$supertype-name">
                            <xs:complexContent>
                                <xs:extension base="{imf:get-type($supertype-name,$supertype-package-name)}">
                                    <xsl:if test="exists($content/*)">
                                        <xsl:sequence select="$content/*"/>
                                    </xsl:if>
                                </xs:extension>
                            </xs:complexContent>
                        </xsl:when>
                        <xsl:when test="exists($content)">
                            <xsl:sequence select="$content/*"/>
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
                                        <xsl:sequence select="$content/*"/>
                                    </xsl:if>
                                </xs:extension>
                            </xs:simpleContent>
                        </xsl:when>
                        <xsl:when test="exists($content)">
                            <xsl:sequence select="$content/*"/>
                        </xsl:when>
                    </xsl:choose>      
                </xs:simpleType>
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
                <xsl:sequence select="imf:create-datatype-property(.)"/>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>
    
    <xsl:template match="*|@*|text()">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:function name="imf:get-annotation" as="node()?">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:get-annotation($this,(),())"/>
    </xsl:function>
    <xsl:function name="imf:get-annotation" as="node()?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="added-documentation" as="node()*"/>
        <xsl:param name="added-appinfo" as="node()*"/>
        <xsl:variable name="documentation" select="($added-documentation, imf:get-documentation($this))"/>
        <xsl:if test="$added-appinfo or $documentation">
            <xs:annotation>
                <xsl:sequence select="$added-appinfo"/>
                <xsl:sequence select="$documentation"/>
            </xs:annotation>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-schema-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/file-location',imf:get-xsd-filesubpath($this))"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/conversion',imf:get-config-parameter('pretext-encoding'))"/>
    </xsl:function>
    
    <!-- get a type name based on the type specified, that is suited for XSD -->
    <xsl:function name="imf:get-type" as="xs:string">
        <xsl:param name="uml-type" as="xs:string"/>
        <xsl:param name="package-name" as="xs:string?"/>
        
        <!-- IM-69
            introduceer de mogelijkheid datatypen naar systeem typen te mappen 
        -->
        <xsl:variable name="defining-class" select="imf:get-class($uml-type,$package-name)"/>
        <xsl:variable name="primitive" select="$defining-class/imvert:primitive"/>
        
        <xsl:variable name="uml-type-name" select="if (contains($uml-type,':')) then substring-after($uml-type,':') else $uml-type"/>
        <xsl:variable name="primitive-type" select="substring-after($uml-type-name,'http://schema.omg.org/spec/UML/2.1/uml.xml#')"/>
        <xsl:variable name="base-type" select="upper-case(
            if ($primitive)
            then $primitive
            else
                if ($primitive-type) 
                then $primitive-type 
                else 
                    if (not($package-name) or imf:is-system-package($package-name)) 
                    then $uml-type-name 
                    else '')"/>
        <xsl:choose>
            <xsl:when test="$base-type"> 
                <xsl:choose>
                    <xsl:when test="$base-type='CHAR'">xs:string</xsl:when> <!-- backward compat -->
                    <xsl:when test="$base-type='STRING'">xs:string</xsl:when> 
                    <xsl:when test="$base-type='INTEGER'">xs:integer</xsl:when> <!-- xsd:integer — Signed integers of arbitrary length -->
                    <xsl:when test="$base-type='DECIMAL'">xs:decimal</xsl:when>
                    <xsl:when test="$base-type='DATETIME'">xs:dateTime</xsl:when>
                    <xsl:when test="$base-type='TIME'">xs:time</xsl:when>
                    <xsl:when test="$base-type='BOOLEAN'">xs:boolean</xsl:when>
                    <xsl:when test="$base-type='URI'">xs:anyURI</xsl:when>
                    <xsl:when test="$base-type='#ANY'">#any</xsl:when>
                    <xsl:when test="$base-type='#MIX'">#mix</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'xs:string'"/>
                        <xsl:sequence select="imf:msg('ERROR', 'Unknown native type: [1]', $base-type)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(imf:get-short-name($package-name),':',$uml-type-name)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:create-element-property" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:variable name="is-voidable" select="$this/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-voidable')"/>
        <xsl:variable name="is-restriction" select="imf:is-restriction($this)"/>
        <xsl:variable name="is-estimation" select="imf:is-estimation($this)"/>
        <xsl:variable name="basetype-name" select="if ($is-voidable) then imf:get-restriction-basetype-name($this) else ''"/>
        <xsl:variable name="package-name" select="$this/ancestor::imvert:package[last()]/imvert:name"/>
        
        <xsl:variable name="name" select="$this/imvert:name"/>
        <xsl:variable name="type" select="imf:get-type($this/imvert:type-name,$this/imvert:type-package)"/>
      
        <xsl:variable name="is-any" select="$type = '#any'"/>
        <xsl:variable name="is-mix" select="$type = '#mix'"/>
        
        <xsl:variable name="defining-class" select="imf:get-defining-class($this)"/>                            
        <xsl:variable name="is-enumeration" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-enumeration')"/>
        <xsl:variable name="is-datatype" select="$defining-class/imvert:designation='datatype'"/>
        <xsl:variable name="is-complextype" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-complextype','stereotype-name-referentielijst'))"/>
        <xsl:variable name="name-conceptual-type" select="if ($this/imvert:attribute-type-name) then imf:get-type($this/imvert:attribute-type-name,$this/imvert:type-package) else ''"/>
        
        <xsl:variable name="is-external" select="not($defining-class) and $this/imvert:type-package=$external-schema-names"/>
        <xsl:variable name="is-choice" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union')"/>
        <xsl:variable name="is-choice-member" select="$this/ancestor::imvert:class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union')"/>
        <xsl:variable name="is-composite" select="$this/imvert:aggregation='composite'"/>
        <xsl:variable name="is-collection-member" select="$this/../../imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')"/>
        <xsl:variable name="is-primitive" select="exists($this/imvert:primitive)"/>
        <xsl:variable name="is-anonymous" select="$this/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-anonymous')"/>
        <xsl:variable name="is-type-modified-incomplete" select="$this/imvert:type-modifier = '?'"/>
        
        <xsl:variable name="association-class-id" select="$this/imvert:association-class/imvert:type-id"/>
        <xsl:variable name="min-occurs-assoc" select="if ($this/imvert:min-occurs='0') then '0' else '1'"/>
        <xsl:variable name="min-occurs-target" select="if ($this/imvert:min-occurs='0') then '1' else $this/imvert:min-occurs"/>
        
        <xsl:variable name="data-location" select="imf:get-appinfo-location($this)"/>
            
        <xsl:choose>
            <!-- any type, i.e. #any -->
            <xsl:when test="$is-any">
                <xsl:variable name="package-name" select="$this/imvert:any-from-package"/>
                <xsl:variable name="package-namespace" select="$document-packages[imvert:name=$package-name]/imvert:namespace"/>
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'Any type')"/>
                    <xs:complexType>
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
                    <xsl:sequence select="imf:debug($this,'Mix of elements')"/>
                    <xs:complexType mixed="true">
                        <!-- TODO how to define possible elements in mixed contents? -->
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <!-- base types such as xs:string and xs:boolean -->
            <xsl:when test="$type='xs:dateTime' and $is-type-modified-incomplete and $is-voidable"> <!-- incomplete type, and could be, but may may not be empty -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:debug($this,'A voidable incomplete datetime')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{imf:get-type('Fixtype_incompleteDate',$package-name)}">
                                <xsl:sequence select="imf:create-nilreason()"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$type='xs:dateTime' and $is-type-modified-incomplete"> <!-- incomplete type -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="imf:get-type('Fixtype_incompleteDate',$package-name)"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'An incomplete datetime')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                </xs:element>
            </xsl:when>
            
            <xsl:when test="starts-with($type,'xs:') and $is-voidable"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:debug($this,'A voidable primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <!-- 
                                Determine the effective type, this is the actual type such as xs:string or a generated basetype 
                                When basetype, the type referenced in the extension is the generated type, 'Basetype_*', introduced at the end of the schema 
                            -->
                            <xsl:variable name="effective-type" select="if ($is-restriction) then imf:get-type($basetype-name,$package-name) else $type"/>
                            <xs:extension base="{$effective-type}">
                                <xsl:sequence select="imf:create-nilreason()"/>
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
                    <xsl:sequence select="imf:debug($this,'A restriction on a primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xsl:choose>
                        <xsl:when test="false() and $is-estimation"> <!-- deactivated! -->
                            <!-- TODO research / This is a restriction on xs:string datatype, but also extension as attributes are added. How? -->
                            <xs:complexType>
                                <xs:simpleContent>
                                    <xs:restriction base="{$type}">
                                        <xsl:sequence select="imf:create-datatype-property($this)"/>
                                    </xs:restriction>
                                    <xsl:sequence select="imf:create-estimation($is-estimation)"/>
                                </xs:simpleContent>
                            </xs:complexType>
                        </xsl:when>
                        <xsl:otherwise>
                            <xs:simpleType>
                                <xs:restriction base="{$type}">
                                    <xsl:sequence select="imf:create-datatype-property($this)"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xsl:otherwise>
                    </xsl:choose>
                </xs:element>
            </xsl:when>
            <xsl:when test="$type=('xs:string') and not($this/imvert:baretype='TXT')"> <!-- these types could be, but may may not be empty -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'A string')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:simpleType>
                        <xs:restriction base="{$type}">
                            <xs:pattern value="\S.*"/> <!-- Note: do not use xs:minLength as this allows for a single space -->
                        </xs:restriction>
                    </xs:simpleType>
                </xs:element>
            </xsl:when>
            <xsl:when test="starts-with($type,'xs:')"> 
                <!-- any xsd primitve type such as xs:integer, and the TXT type -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'A primitive type')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-primitive"> 
                <!-- any xsd primitve type such as integer -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$this/imvert:type-name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'A primitive type, after mapping')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-enumeration and $is-voidable">
                <!-- an enumeration or a datatype such as postcode -->
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:debug($this,'A voidable enumeration')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{$type}">
                                <xsl:sequence select="imf:create-nilreason()"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-datatype and $is-voidable">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:debug($this,'A voidable datatype')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xs:simpleContent>
                            <xs:extension base="{$type}">
                                <xsl:sequence select="imf:create-nilreason()"/>
                            </xs:extension>
                        </xs:simpleContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-enumeration or $is-datatype">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'An enumeration or a datatype')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="not($name) and $is-external">
                <!-- a reference to an external construct -->
                <xs:element>
                    <xsl:attribute name="ref" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'No name and the type is external')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-choice and $is-voidable"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:debug($this,'The type of this property is a union, and voidable')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                    <xs:complexType>
                        <xs:complexContent>
                            <xs:extension base="{$type}">
                                <xsl:sequence select="imf:create-nilreason()"/>
                            </xs:extension>
                        </xs:complexContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-choice"> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'The type of this property is a union')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-choice-member"> 
                <!-- an attribute of a NEN3610 union -->
                <xs:element>
                    <xsl:attribute name="ref" select="$type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'A member of a union')"/>
                    <xsl:sequence select="imf:get-annotation($this)"/>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-complextype and $is-voidable">
                <!-- note that we do not support avoiding substitution on complex datatypes --> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:debug($this,'A voidable complex type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xs:complexContent>
                            <xs:extension base="{if ($name-conceptual-type) then $name-conceptual-type else $type}">
                                <xsl:sequence select="imf:create-nilreason()"/>
                            </xs:extension>
                        </xs:complexContent>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-complextype">
                <!-- note that we do not support avoiding substitution on complex datatypes --> 
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="type" select="if ($name-conceptual-type) then $name-conceptual-type else $type"/>
                    <xsl:attribute name="minOccurs" select="$this/imvert:min-occurs"/>
                    <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:debug($this,'A complex type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                </xs:element>
           </xsl:when>
            <xsl:when test="$is-external and $is-voidable">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="1"/>
                    <xsl:attribute name="nillable">true</xsl:attribute>
                    <xsl:sequence select="imf:debug($this,'A voidable external type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element ref="{$type}" minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}"/>
                        </xs:sequence>
                        <xsl:sequence select="imf:create-nilreason()"/>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="$is-external">
                <xs:element>
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                    <xsl:attribute name="maxOccurs" select="1"/>
                    <xsl:sequence select="imf:debug($this,'An external type')"/>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <!-- TODO continue: introduce correct reference / see IM-59 -->
                    <xsl:variable name="reftype" select="if ($this/ancestor::imvert:package[last()][imvert:metamodel='BP']) then $type else $type"/>
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element ref="{$reftype}" minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}"/>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
            </xsl:when>
            <xsl:when test="not($defining-class)">
                <xsl:sequence select="imf:debug($this,'No defining class!')"/>
                <xsl:sequence select="imf:msg('ERROR','Reference to an undefined class [1]',$type)"/>
                <!-- this can be the case when this class is not part of a configured package, please correct in UML -->
            </xsl:when>
            <xsl:when test="not($name) or $is-anonymous"> 
                <!-- an unnamed association -->
                <xsl:choose>
                    <xsl:when test="$avoid-substitutions">
                        <xs:choice minOccurs="{$this/imvert:min-occurs}" maxOccurs="{$this/imvert:max-occurs}">
                            <xsl:variable name="sub-classes" select="($defining-class, imf:get-substitution-classes($defining-class))"/>
                            <xsl:sequence select="imf:debug($this,'An unnamed association, avoiding substitutions')"/>
                            <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
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
                            <xsl:sequence select="imf:debug($this,'An unnamed association')"/>
                            <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
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
                                    <xsl:sequence select="imf:debug($this,'A wrapped member, avoiding substitutions')"/>
                                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                                    <xsl:for-each select="$sub-classes[not(imf:boolean(imvert:abstract))]">
                                        <xs:element ref="{imf:get-qname(.)}"/>
                                    </xsl:for-each>
                                </xs:choice>
                            </xs:complexType>
                        </xsl:when>
                        <xsl:otherwise>
                            <xs:element>
                                <xsl:attribute name="ref" select="$type"/>
                                <xsl:sequence select="imf:debug($this,'A wrapped member')"/>
                                <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
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
                                    <xsl:sequence select="imf:debug($this,'Buildcollection suppressed, abstract class ignored')"/>
                                </xsl:when>
                                <xsl:when test="not(imf:boolean($buildcollection))">
                                    <xsl:sequence select="imf:debug($this,'Buildcollection suppressed')"/>
                                    <xs:element ref="{imf:get-qname(.)}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:debug($this,'Buildcollection allowed')"/>
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
                                <xsl:sequence select="imf:debug($this,'An association class')"/>
                                <xsl:variable name="association-class" select="$document//imvert:class[imvert:id=$association-class-id]"/>
                                <xs:element ref="{imf:get-qname($association-class)}"/>
                            </xs:sequence>
                        </xsl:when>
                        <xsl:otherwise>
                            <xs:choice minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}">
                                <xsl:sequence select="$choice"/>
                            </xs:choice>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="$is-voidable">
                        <xsl:sequence select="imf:create-nilreason()"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$is-composite and imf:boolean($anonymous-components) and not($is-voidable)">
                        <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                        <xs:sequence>
                            <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                            <xsl:attribute name="maxOccurs" select="1"/>
                            <xsl:sequence select="imf:debug($this,'An objecttype, anonymous')"/>
                            <xsl:sequence select="$content"/>
                        </xs:sequence>
                    </xsl:when>
                    <xsl:otherwise>
                        <xs:element>
                            <xsl:attribute name="name" select="$name"/>
                            <xsl:attribute name="minOccurs" select="$min-occurs-assoc"/>
                            <xsl:attribute name="maxOccurs" select="1"/>
                            <xsl:choose>
                                <xsl:when test="$is-composite and imf:boolean($anonymous-components) and $is-voidable">
                                    <xsl:attribute name="nillable">true</xsl:attribute>
                                    <xsl:sequence select="imf:debug($this,'An objecttype, anonymous, but voidable')"/>
                                    <xsl:sequence select="imf:msg('WARN','Anonymous component is voidable and therefore must be named: [1]',$name)"/>
                                </xsl:when>
                                <xsl:when test="$is-voidable">
                                    <xsl:attribute name="nillable">true</xsl:attribute>
                                    <xsl:sequence select="imf:debug($this,'An objecttype, voidable')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:debug($this,'An objecttype')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
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
                    <xsl:if test="$is-voidable">
                        <xsl:attribute name="nillable">true</xsl:attribute>
                    </xsl:if>
                    <xsl:sequence select="imf:get-annotation($this,$data-location,())"/>
                    <xs:complexType>
                        <xsl:variable name="result">
                            <xsl:choose>
                                <!-- TODO improvement / association classes are not covered well by current implementation; check out more contexts where the assoc. class may occur -->
                                <xsl:when test="$association-class-id">
                                    <xsl:sequence select="imf:debug($this,'Default property definition: an association class')"/>
                                    <xsl:variable name="association-class" select="$document//imvert:class[imvert:id=$association-class-id]"/>
                                    <xs:element ref="{imf:get-qname($association-class)}" minOccurs="{$min-occurs-target}" maxOccurs="{$this/imvert:max-occurs}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$avoid-substitutions">
                                            <xsl:sequence select="imf:debug($this,'Default property definition, avoiding substitutions')"/>
                                            <xsl:variable name="sub-classes" select="($defining-class, imf:get-substitution-classes($defining-class))"/>
                                            <xsl:variable name="result-set" select="$sub-classes[not(imf:boolean(imvert:abstract))]"/>
                                            <xsl:choose>
                                                <xsl:when test="count($result-set) gt 1">
                                                    <xs:choice>
                                                        <xsl:attribute name="minOccurs" select="$min-occurs-target"/>
                                                        <xsl:attribute name="maxOccurs" select="$this/imvert:max-occurs"/>
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
                                                    </xs:element>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="imf:debug($this,'Default property definition')"/>
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
                        <xsl:if test="$is-voidable">
                            <xsl:sequence select="imf:create-nilreason()"/>
                        </xsl:if>
                    </xs:complexType>
                </xs:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:create-attribute-property" as="item()*">
        <xsl:param name="this" as="node()"/>
  
        <xsl:variable name="voidable" select="$this/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-voidable')"/>
        <xsl:variable name="type" select="imf:get-type($this/imvert:type-name,$this/imvert:type-package)"/>
        <xs:attribute>
            <xsl:attribute name="name" select="$this/imvert:name"/>
            <xsl:attribute name="use" select="if ($this/imvert:min-occurs='0') then 'optional' else 'required'"/>
            <xsl:attribute name="type" select="$type"/>
            <xsl:sequence select="imf:get-annotation($this)"/>
        </xs:attribute>
    </xsl:function>

    <xsl:function name="imf:create-datatype-property" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:apply-templates select="$this/imvert:pattern"/>
        <xsl:apply-templates select="$this/imvert:max-length"/>
        <xsl:apply-templates select="$this/imvert:total-digits"/> 
        <xsl:apply-templates select="$this/imvert:fraction-digits"/>
        <xsl:if test="not($this/(imvert:pattern|imvert:total-digits)) and not($this/imvert:baretype='TXT')">
            <xsl:sequence select="imf:create-nonempty-constraint($this/imvert:type-name)"/>
        </xsl:if>
    </xsl:function>
    <xsl:template match="imvert:pattern">
        <xs:pattern value="{.}"/>
    </xsl:template>
    <xsl:template match="imvert:max-length">
        <xs:maxLength value="{.}"/>
    </xsl:template>
    <xsl:template match="imvert:total-digits">
        <xs:totalDigits value="{.}"/>
    </xsl:template>
    <xsl:template match="imvert:fraction-digits">
        <xs:fractionDigits value="{.}"/>
    </xsl:template>
  
    <xsl:template match="imvert:union">
        <xsl:variable name="membertypes" as="item()*">
            <!-- for each referenced datatype, determine the actual XSD equivalent. Produce a xs:union construct. -->
            <xsl:for-each select="tokenize(normalize-space(.),'\s+')">
                <xsl:value-of select="imf:get-type(.,'')"/>
            </xsl:for-each>
        </xsl:variable>
        <xs:union memberTypes="{string-join($membertypes,' ')}"/>
    </xsl:template>
    
    <xsl:function name="imf:is-system-package" as="xs:boolean">
        <xsl:param name="package-name" as="xs:string"/>
        <xsl:copy-of select="substring-before($package-name,'_') = ('EA','Info')"/>
    </xsl:function>
   
    <xsl:function name="imf:is-restriction" as="xs:boolean">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="exists($this/(imvert:pattern | imvert:max-length | imvert:total-digits | imvert:fraction-digits))"/>
    </xsl:function>
    <xsl:function name="imf:is-estimation" as="xs:boolean">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="$this/imvert:stereotype = 'estimation'"/>
    </xsl:function>
    
    <?x associates komen niet meer voor?
        
    <xsl:function name="imf:is-association-class" as="xs:boolean">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="exists($this/imvert:associates)"/>
    </xsl:function>
    ?>
    
    <xsl:function name="imf:get-restriction-basetype-name" as="xs:string">
        <xsl:param name="this" as="node()"/> <!-- any attribute/association node. -->
        <xsl:value-of select="concat('Basetype_',$this/ancestor::imvert:class/imvert:name,'_',$this/imvert:name)"/>
    </xsl:function>
    
    <xsl:function name="imf:create-nilreason">
        <xs:attribute name="nilReason" type="xs:string" use="optional"/>
    </xsl:function>
    
    <xsl:function name="imf:create-estimation">
        <xsl:param name="is-estimation" as="xs:boolean"/>
        <xsl:if test="$is-estimation">
            <xs:attribute name="estimated" type="xs:boolean" use="optional"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation" as="node()*">
        <xsl:param name="construct" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/technical-documentation',
            imf:xhtml-to-flatdoc(imf:get-compiled-documentation($construct,$model-is-traced)))"/>
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
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/schema-info/svn',concat($char-dollar,'Id',$char-dollar))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-appinfo-location" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/data-info/uri',$this/imvert:data-location)"/>
    </xsl:function>
    
    <xsl:function name="imf:create-doc-element" as="node()*">
        <xsl:param name="element-name" as="xs:string"/>
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="value" as="xs:string*"/>
        <xsl:for-each select="$value[normalize-space(.)]">
            <xsl:element name="{$element-name}">
                <xsl:attribute name="source" select="$namespace"/>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:create-info-element" as="node()*">
        <xsl:param name="element-name" as="xs:string"/>
        <xsl:param name="value" as="xs:string*"/>
        <xsl:for-each select="$value">
            <xsl:element name="{$element-name}">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:function>
        
    <xsl:function name="imf:get-qname" as="xs:string">
        <xsl:param name="class" as="node()"/>
        <xsl:value-of select="concat(imf:get-short-name($class/parent::imvert:package/imvert:name),':',$class/imvert:name)"/>
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

    <xsl:function name="imf:create-nonempty-constraint" as="item()*">
        <xsl:param name="type" as="xs:string?"/>
        <xsl:if test="$type=('char', 'string', 'uri') or not($type)">
            <xs:pattern value="\S.*"/> <!-- Note: do not use xs:minLength as this allows for a single space -->
        </xsl:if>
    </xsl:function>
    
    <!-- return the class that defines the type of the attribute or association passed. --> 
    <xsl:function name="imf:get-defining-class" as="node()?">
        <xsl:param name="this" as="node()"/>
        
        <?x
        <xsl:variable name="n" select="imf:get-construct-name($this)"></xsl:variable>
        <xsl:variable name="c" select="$document-packages[imvert:name=$this/imvert:type-package]/imvert:class[imvert:name=$this/imvert:type-name]"/>
        
        <xsl:if test="count($c) gt 1">
            <xsl:for-each select="$c">
                <xsl:message select="concat($n, ' - ', imf:get-construct-name(.))"/>
            </xsl:for-each>
        </xsl:if>
        ?>    
        <xsl:sequence select="$document-packages[imvert:name=$this/imvert:type-package]/imvert:class[imvert:name=$this/imvert:type-name]"/>                            
    </xsl:function>

    <!-- 
        Return the complete subpath and filename of the xsd file to be generated.
        Sample: my/schema/MyappMypackage_1_0_3.xsd
    -->
    <xsl:function name="imf:get-xsd-filesubpath" as="xs:string">
        <xsl:param name="this" as="node()"/> <!-- a package -->
        <xsl:choose>
            <xsl:when test="$this/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-external-package','stereotype-name-system-package'))"> 
                <!-- 
                    the package is external (GML, Xlink or the like). 
                    Place reference to that external pack. 
                    The package is copied alongside the target application package.
                    Note that the xsd foilder path is set to the project name (e.g. IMKAD) but the external 
                    schema's are copied to the folder at the parent location. So the folder path is 1 step up. 
                --> 
                <xsl:value-of select="concat('../',imf:get-uri-parts($this/imvert:location)/path)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(imf:get-xsd-filefolder($this), '/', imf:get-xsd-filename($this))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
  
    <!-- 
        return the full XSD file path of the package passed.
    -->
    <xsl:function name="imf:get-xsd-filefullpath" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="schema-subpath" select="imf:get-xsd-filesubpath($this)"/>
        <xsl:value-of select="concat($xsd-folder-path,$schema-subpath)"/>
    </xsl:function>
  
    <!-- 
        Get the path of the xsd file. This is the part of the namespace that is behind the repository-url.
        Example:
        root namespace (alias) is: 
            http://www.imvertor.org/schema
        URL is: 
            http://www.imvertor.org/schema/my/schema/
        and release is: 
            20120307
        returns: 
            /my/schema/v20120307
    -->    
    <xsl:function name="imf:get-xsd-filefolder" as="xs:string">
        <xsl:param name="this" as="node()"/> <!-- an imvert:package -->
        <xsl:value-of select="concat(substring-after($this/imvert:namespace,concat($base-namespace,'/')),'/v',$this/imvert:release)"/>
    </xsl:function>
    
    <!--
        Return the file name of the XSD to be generated.
    -->
    <xsl:function name="imf:get-xsd-filename" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="concat($variant-package-name,$application-package-name,'_',$this/imvert:name,'_v',replace($this/imvert:version,'\.','_'),'.xsd')"/>
    </xsl:function>
    
    <!-- 
        return the release number of the Model and therefore the XSD to be generated 
    -->
    <xsl:function name="imf:get-release" as="item()">
        <xsl:param name="this" as="node()"/>
        <!-- 
            Assume release of supplier, unless release specified.
        -->
        <xsl:variable name="release" select="$this/imvert:release"/>
        <xsl:choose>
            <xsl:when test="normalize-space($release)">
                <xsl:value-of select="$release"/>
            </xsl:when>
            <xsl:when test="$this/imvert:base">
                <!-- <xsl:sequence select="imf:msg($this,'WARN',concat('Release date not set. Copying from supplier package. Package is: ', $this/imvert:name, ' (', $this/imvert:namespace, ')'))"/> -->
                <xsl:value-of select="imf:get-release($this/imvert:base)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR', 'No (supplier) release found for package: [1] ([2])',($this/imvert:name,$this/imvert:namespace))"/>
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
        <xsl:variable name="external-package" select="$this/ancestor::imvert:package[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-external-package')][1]"/>
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
    
    <!-- 
        Return the members of sequence set1 that are not in set2. 
        The comparison is based on the string value of the members. 
    -->
    <xsl:function name="imf:sequence-except-by-string-value" as="item()*">
        <xsl:param name="set1" as="item()*"/>
        <xsl:param name="set2" as="item()*"/>
        <xsl:for-each select="$set1">
            <xsl:variable name="stringvalue" select="xs:string(.)"/>
            <xsl:if test="not($set2 = $stringvalue)">
                <xsl:sequence select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <!-- 
        Return this class and all classes that are substitutable for this class, that are also linkable (and therefore a reference element must be created). 
        The class passed as rootclass may be abstract and still be linkable; linkable substitution classes must be concrete.
   
        This set also includes classes that realize this class in a static way.
        These classes do not inherit any properties of the realizes class, but can take its place. 
    -->
    <xsl:function name="imf:get-linkable-subclasses-or-self" as="node()*">
        <xsl:param name="rootclass" as="node()"/>
        <xsl:sequence select="imf:get-substitutable-subclasses-or-self($rootclass)[imf:is-linkable(.)]"/>
    </xsl:function>
    
    <!-- 
        Return all classes that can be substituted for the class passed, and self. 
        Do not return abstract classes. 
    -->
    <xsl:function name="imf:get-substitutable-subclasses-or-self" as="element()*">
        <xsl:param name="rootclass" as="element()"/>
        <xsl:variable name="substitution-classes" select="imf:get-substitution-classes($rootclass)"/>
        <xsl:sequence select="$rootclass"/>
        <xsl:sequence select="$substitution-classes"/>
    </xsl:function>
    
    <!-- 
        Return all classes that can be substituted for the class passed, but not self.
        Also returns abstract classes.
    -->
    <xsl:function name="imf:get-substitution-classes" as="node()*">
        <xsl:param name="class" as="node()"/>
        <xsl:variable name="class-id" select="$class/imvert:id"/>
        <xsl:for-each select="$document-classes[imvert:substitution/imvert:supplier-id=$class-id or imvert:supertype/imvert:type-id=$class-id]">
            <xsl:sequence select="."/>
            <xsl:sequence select="imf:get-substitution-classes(.)"/>
        </xsl:for-each>
    </xsl:function>
        
    <xsl:function name="imf:get-cva-info" as="element()">
        <xsl:param name="attribute" as="element()"/>
        <xsl:variable name="class" select="$attribute/../.."/>
        <xsl:variable name="package" select="$class/.."/>
        <xsl:variable name="ns" select="imf:get-namespace($package)"/>
        <xsl:variable name="ns-name" select="$package/imvert:name"/>
        <xsl:variable name="parent-name" select="$class/imvert:name"/>
        <xsl:variable name="child-name" select="$attribute/imvert:name"/>
        <xsl:variable name="uri" select="$attribute/imvert:data-location"/>
        <xsl:variable name="file" select="concat($attribute/imvert:data-location,'.xml')"/>
        <xsl:variable name="id" select="substring-after($attribute/imvert:data-location,imf:get-config-parameter('url-prefix-schema-waardelijsten'))"/>
        <xsl:variable name="scope" select="concat($ns-name,':',$parent-name)"/>
        <xsl:variable name="item" select="concat($ns-name,':',$child-name)"/>
        <info id="{$id}" uri="{$uri}" file="{$file}" scope="{$scope}" item="{$item}" prefix="{$ns-name}" ns="{$ns}"/>  
    </xsl:function>
    
    <xsl:function name="imf:debug" as="node()*">
        <xsl:param name="info-node" as="node()"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:if test="imf:boolean($debug)">
            <xsl:comment select="concat(imf:get-construct-name($info-node), ' - ', $text)"/>
        </xsl:if>
    </xsl:function>

    <!-- return all associations to this class -->
    <xsl:function name="imf:get-references">
        <xsl:param name="class" as="element()"/>
        <xsl:variable name="id" select="$class/imvert:id"/>
        <xsl:sequence select="for $a in $document-classes//imvert:association return if ($a/imvert:type-id = $id) then $a else ()"/>
    </xsl:function>
    
    <xsl:function name="imf:is-abstract">
        <xsl:param name="class"/>
        <xsl:sequence select="imf:boolean($class/imvert:abstract)"/>        
    </xsl:function>

</xsl:stylesheet>
