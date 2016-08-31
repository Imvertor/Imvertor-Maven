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
        Validation of the UML. 
        
        This checks if the UML is actually conform the rules set up for UML modelling, and suited for the 
        transformation to XML schemas.
    -->

    <!--TODO regel toevoegen: release moet zijn opgegeven op alle packages -->
    <!--TODO regel toevoegen: domain verplicht binnen application -->
    <!--TODO regel toevoegen: two namespaces op dezelfde prefix gemapped, hoe kan dat? ... domain packages mogen niet dezelfde naam hebben. -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="release-pattern">^(\d{8})$</xsl:variable>
    <xsl:variable name="phase-pattern">^(0|1|2|3)$</xsl:variable>
    <xsl:variable name="minoccurs-pattern">^(\d+)$</xsl:variable>
    <xsl:variable name="maxoccurs-pattern">^(\d+|unbounded)$</xsl:variable>
    
    <!-- test if the construct passed follows the naming conventions -->
    <xsl:variable name="convention-package-name-pattern">^(([A-Z][A-z0-9]+)+)$</xsl:variable>
    <xsl:variable name="convention-class-name-pattern">^(_?([A-Z][A-z0-9]+)+)$</xsl:variable>
    <xsl:variable name="convention-attribute-name-pattern">^([A-z][A-z0-9]+)$</xsl:variable>
    <xsl:variable name="convention-association-name-pattern">^([a-z][A-z0-9]+)$</xsl:variable>
    
    <!-- Stereotypes that must corresponde from superclass to subclass -->
    <xsl:variable name="copy-down-stereotypes-inheritance" as="xs:string*">
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-complextype')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-objecttype')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-koppelklasse')"/>
    </xsl:variable>
    <!-- Stereotypes that must correspond from subclass to superclass -->
    <xsl:variable name="copy-up-stereotypes-inheritance" as="xs:string*">
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-objecttype')"/>
    </xsl:variable>
    <!-- Stereotypes that must correspond from base to variant -->
    <xsl:variable name="copy-down-stereotypes-realization" as="xs:string*">
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-complextype')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-objecttype')"/>
    </xsl:variable>
    <!-- All possible application-level top-packages -->
    <xsl:variable name="top-package-stereotypes" as="xs:string*">
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-base-package')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-variant-package')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-application-package')"/>
    </xsl:variable>
    <!-- Stereotypes of packages that may define classes -->
    <xsl:variable name="schema-oriented-stereotypes" as="xs:string*">
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-system-package')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-external-package')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-internal-package')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-domain-package')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-view-package')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-components-package')"/>
    </xsl:variable>
    <!-- Stereotypes that may occur in unions -->
    <xsl:variable name="union-element-stereotypes" as="xs:string*">
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-objecttype')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-koppelklasse')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-union')"/>
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-composite')"/>
    </xsl:variable>
    <!-- Stereotypes that are referenced -->
    <xsl:variable name="xref-element-stereotypes" as="xs:string*">
        <xsl:sequence select="imf:get-config-stereotypes('stereotype-name-objecttype')"/>
        <!-- more when product -->
    </xsl:variable>
    
    <xsl:variable name="application-package" select="//imvert:package[imvert:name/@original=$application-package-name and imvert:stereotype= imf:get-config-stereotypes(('stereotype-name-application-package','stereotype-name-base-package'))][1]"/>
    
    <!-- 
        The set of external packages includes all packages that are <<external>> of any subpackage thereof.
        The external package must also define any class that is referenced by the application.
    -->
    <xsl:variable name="external-package" select="//imvert:package[ancestor-or-self::imvert:package/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-external-package') and (imvert:class/imvert:id = $application-package//(imvert:type-id | imvert:supertype/imvert:type-id)) or imvert:stereotype=imf:get-config-stereotypes('stereotype-name-system-package')]"/>
    
    <!-- 
        The set of internal packages includes all packages that are <<external>> of any subpackage thereof.
        The external package must also define any class that is referenced by the application.
    -->
    <xsl:variable name="internal-package" select="//imvert:package[ancestor-or-self::imvert:package/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-internal-package') and (imvert:class/imvert:id = $application-package//(imvert:type-id | imvert:supertype/imvert:type-id))]"/>
    <!-- 
        The set of compoennts packages includes all packages that are <<components>> of any subpackage thereof.
    -->
    <xsl:variable name="components-package" select="//imvert:package[ancestor-or-self::imvert:package/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-components-package')]"/>
    
    <xsl:variable name="domain-package" select="$application-package//imvert:package[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))]"/>
    <xsl:variable name="subdomain-package" select="$domain-package//imvert:package"/>
    
    <xsl:variable name="document-packages" select="($application-package,$domain-package,$subdomain-package,$external-package,$internal-package,$components-package)"/>
    <xsl:variable name="document-classes" select="$document-packages/imvert:class"/>

    <xsl:variable name="is-application" select="$application-package/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-application-package')"/>
    
    <xsl:variable name="schema-packages" select="$document-packages[imvert:stereotype = $schema-oriented-stereotypes]"/>

    <xsl:variable name="normalized-stereotype-none" select="imf:get-normalized-name('#none','stereotype-name')"/>
    
    <xsl:key name="key-unique-id" match="//*[imvert:id]" use="imvert:id"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
      
        Place rules here that focus on the complete specification rather than particular constructs. 
    -->
    <xsl:template match="/imvert:packages">
        
        <imvert:report>
            <!-- info used to determine report location are set here -->
            <xsl:variable name="application-package-release" select="$application-package/imvert:release"/>
            <xsl:variable name="application-package-version" select="$application-package/imvert:version"/>
            <xsl:variable name="application-package-phase" select="$application-package/imvert:phase"/>
            
            <xsl:variable name="release" select="if ($application-package-release) then $application-package-release else '00000000'"/>
            <xsl:variable name="version" select="if ($application-package-version) then $application-package-version else '0.0.0'"/>
            <xsl:variable name="phase" select="if ($application-package-phase) then $application-package-phase else '0'"/>
            
            <xsl:attribute name="release" select="$release"/>
            <xsl:attribute name="version" select="$version"/>
            <xsl:attribute name="phase" select="$phase"/>
            
            <classes>
                <xsl:sequence select="$document-classes"></xsl:sequence>
            </classes>
           
            <!-- add info to configuration -->
            <xsl:sequence select="imf:get-normalized-name(imf:get-config-string('cli','project'),'system-name')"/>
            
            <xsl:sequence select="imf:set-config-string('appinfo','project-name',$project-name)"/>
            <xsl:sequence select="imf:set-config-string('appinfo','application-name',$application-package-name)"/>
            <xsl:sequence select="imf:set-config-string('appinfo','version',$version)"/>
            <xsl:sequence select="imf:set-config-string('appinfo','phase',$phase)"/>
            <xsl:sequence select="imf:set-config-string('appinfo','release',$release)"/>
            
            <!-- determine if all constructs are unique -->
            <xsl:apply-templates select="*" mode="unique-id"/>
                
            <!-- process the application package -->
            <xsl:apply-templates select="imvert:package"/>
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="imvert:package[.=$application-package]" priority="101">
        <xsl:sequence select="imf:track('Validating package [1]',imvert:name)"/>
        <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:version,imf:get-config-parameter('application-version-regex'))), 
            'Version identifier has invalid format')"/>
        <xsl:sequence select="imf:report-error(., 
            not(normalize-space(imvert:namespace)), 
            'No root namespace defined for application')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:package[.. = $application-package]" priority="102">
        <!-- redmine #487837 Packages in <<application>> moeten bekend stereotype hebben -->
        <xsl:sequence select="imf:report-error(., 
            empty(imvert:stereotype = imf:get-normalized-names(
            ('imvert-stereotype-domain','imvert-stereotype-intern','imvert-stereotype-recyclebin'),'stereotype-name')), 
            'Package with unexpected stereotype(s): [1]', imvert:stereotype/@original)"/>
        <!-- en moeten een stereo hebben! -->
        <xsl:sequence select="imf:report-error(., 
            empty(imvert:stereotype), 
            'Package within application model must be stereotyped')"/>        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:package[.=$domain-package]" priority="101">
        <xsl:sequence select="imf:track('Validating package [1]',imvert:name)"/>
        <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:version,imf:get-config-parameter('domain-version-regex'))), 
            'Version identifier has invalid format')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the application and domain packages
    -->
    <xsl:template match="imvert:package[.=($application-package,$domain-package)]" priority="100">
        <!-- setup -->
        <xsl:variable name="this" select="."/>
        <!-- validation -->
        <!-- version and release check -->
     
        <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:phase,$phase-pattern)), 
            'Phase must be specified and must be 0, concept, 1, draft, 2, finaldraft, 3, or final')"/>
        <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:release,$release-pattern)), 
            'Release must be specified and takes the form YYYYMMDD')"/>
        <!-- naming -->
        <xsl:sequence select="imf:report-warning(., 
            not(imf:test-name-convention($this)), 
            'Package name does not obey convention')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the application package
    -->
    <xsl:template match="imvert:package[.=$application-package]" priority="50">
        <!--setup-->
        <xsl:variable name="this-package" select="."/>
        <xsl:variable name="root-release" select="imvert:release" as="xs:string?"/>
        <xsl:variable name="subpackage-releases" select="imvert:package/imvert:release[not(.=('99999999','00000000'))]" as="xs:string*"/>
        <xsl:variable name="collections" select=".//imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')]"/>
        <!--validation-->
        <xsl:sequence select="imf:report-error(., 
            not($document-packages/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-domain-package')), 
            'No domain subpackages found')"/>
        <xsl:sequence select="imf:report-error(., 
            not($root-release), 
            'The root package must have a release number.')"/>
        <!-- IM-110 -->
        <xsl:sequence select="imf:report-error(., 
            not(imf:boolean($buildcollection)) and exists($collections), 
            'Collection [1] is used but referencing is suppressed.', ($collections[1]))"/>
        <xsl:choose>
            <xsl:when test="count($subpackage-releases) != 0">
                <xsl:variable name="largest" select="imf:largest($subpackage-releases)"/>
                <xsl:sequence select="imf:report-error(., 
                    ($root-release gt $largest), 
                    'The root package release number [1] is too recent; none of the domain packages has this release; most recent is [2].',($root-release,$largest))"/>
                <xsl:sequence select="imf:report-error(., 
                    ($root-release lt $largest), 
                    'The root package release number [1] is too old; one or more of the domain packages has a more recent release: [2]',($root-release,$largest))"/>
                <xsl:sequence select="imf:report-error(., 
                    ($root-release != $largest), 
                    'The root package release number [1] is not found as the release of any domain package.',($root-release))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-error(., 
                    true(), 
                    'No domain package release information found.')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select=".//imvert:type-id">
            <xsl:variable name="refed-class" select="imf:get-construct-by-id(.)"/>
            <xsl:variable name="refed-name" select="../imvert:type-name"/> <!-- IM-91 -->
            <xsl:variable name="fails" select="not(imf:get-top-package($refed-class) = $this-package or imf:get-internal-package($refed-class) or imf:get-external-package($refed-class))"/>
            <xsl:choose>
                  <xsl:when test="exists(parent::imvert:supertype)">
                      <xsl:sequence select="imf:report-error(ancestor::*[imvert:name][1], 
                          $fails, 
                          'Supertype reference to a class that is not part of this or any external application')"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:sequence select="imf:report-error(ancestor::*[imvert:name][1], 
                          $fails, 
                          'Propertype type reference to a class that is not part of this or any external application: [1]',$refed-name)"/>
                  </xsl:otherwise>
              </xsl:choose>
        </xsl:for-each>
        <!-- 
            when any collection is found, it must be linked to one or more products.
            test if the collections actually hold a reference to all object types within range of this product 
            and check if it references object types outside this range (that cannot be referenced from within that product)
        --> 
        <xsl:for-each select="$collections">
            <!-- determine which product(s) reference this collection. -->
            <xsl:variable name="collection" select="."/>
            <xsl:variable name="collection-id" select="imvert:id"/>
            <xsl:variable name="products" select="$application-package//imvert:class[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-product','stereotype-name-process','stereotype-name-service')) and .//imvert:type-id=$collection-id]"/>
            
            <xsl:for-each select="$products">
                <xsl:variable name="product" select="."/>
                <xsl:variable name="all-calculated-collection-classes" select="imf:get-all-collection-member-classes-sub($products,())"/>
                <xsl:variable name="calculated-collection-classes" select="imf:get-all-collection-member-classes($products)"/>
                <xsl:variable name="collection-classes" select="for $c in $collection/imvert:associations/imvert:association[imvert:type-id] return imf:get-construct-by-id($c/imvert:type-id)"/>
                
                <xsl:for-each select="$calculated-collection-classes except $collection-classes">
                    <xsl:variable name="shared-class" select="."/>
                    <!-- IM-71 when any class references this class by a static liskov, assume the referenced class is not to be made part of the collection --> 
                    <xsl:sequence select="imf:report-warning(., 
                        (not($document-classes/imvert:substitution/imvert:supplier-id = $shared-class/imvert:id)), 
                        'Object type [1] is not part of the collection for product class [2], but should be, because the class (or some superclass) may be referenced.',($shared-class, $product))"/>
                </xsl:for-each>

                <xsl:for-each select="$collection-classes">
                    <xsl:variable name="shared-class" select="."/>
                    <!-- IM-71 when any class references this class and this is not by a static liskov, assume the referenced class is to be made part of the collection --> 
                    <xsl:sequence select="imf:report-warning(., 
                        (not($shared-class = $all-calculated-collection-classes) and not($document-classes/imvert:substitution/imvert:supplier-id = $shared-class/imvert:id)), 
                        'Object type [1] is part of the collection for product class [2], but cannot be referenced from within that product',($shared-class,$product))"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <!-- if there are no collections, build these automatically for each <<product>> class (in a later stage) -->
   
        <!-- validate the version chain, only when derived -->
        <xsl:if test="exists(ancestor-or-self::imvert:package[not(imf:boolean(imvert:derived))])">
            <xsl:apply-templates select="." mode="version-chain"/>
        </xsl:if>
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the domain packages
    -->
    <xsl:template match="imvert:package[.=$domain-package]" priority="50">
        <!--setup-->
        <xsl:variable name="is-schema-package" select="if (imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))) then true() else false()"/>
        <xsl:variable name="classnames" select="distinct-values(imf:get-duplicates(.//imvert:class/imvert:name))" as="xs:string*"/>
        <xsl:variable name="xref-objects" select=".//imvert:class[imvert:stereotype=$xref-element-stereotypes]"/>
        <xsl:variable name="application" select="ancestor::imvert:package[imvert:stereotype=$top-package-stereotypes][1]"/>
          <!--validation -->
        <xsl:sequence select="imf:report-error(., 
            $is-schema-package and not(imvert:namespace), 
            'Package has no alias (i.e. namespace).')"/>
        <xsl:sequence select="imf:report-error(., 
            not($is-schema-package), 
            'Domain package must have the domain stereotype.')"/>
        <xsl:sequence select="imf:report-error(., 
            not(empty($classnames)), 
            'Duplicate class name within (sub)package(s): [1]',$classnames)"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:namespace = $application/imvert:namespace,
            'Namespace of the domain package is the same as the application namespace [1].',(../imvert:namespace))"/>
        <xsl:sequence select="imf:report-error(., 
            not(starts-with(imvert:namespace,concat($application/imvert:namespace,'/'))),
            'Namespace of the domain package does not start with the application namespace [1].',(../imvert:namespace))"/>
        <xsl:sequence select="imf:report-error(., 
            (matches(substring-after(imvert:namespace,$application/imvert:namespace),'.*?//')),
            'Namespace of the domain package holds empty path //')"/>
        <xsl:sequence select="imf:report-error(., 
            ancestor::imvert:package[.=$domain-package],
            'Domain packages cannot be nested')"/>
      
        <?x dropped: this follows the version of the package itself 
            <xsl:sequence select="imf:report-error(., 
            $xref-objects and not(imvert:ref-version), 
            'No ref package version specified but the package uses referenceable classes.')"/>
        <xsl:sequence select="imf:report-error(., 
            $xref-objects and not(imvert:ref-release), 
            'No ref package release specified but the package uses referenceable classes.')"/>
        ?>
        
        <?remove ?
            <!-- validation on SVN link -->
            <xsl:sequence select="imf:report-error(., not($is-schema-package) and not(imvert:svn-string), 'No SVN ID found.')"/>
            <xsl:sequence select="imf:report-warning(., not($is-schema-package) and not(imvert:svn-revision), 'Cannot determine SVN revision number. Please update tagged value svnid.')"/>
        ?>
        
        <!-- validate the version chain -->
        <xsl:if test="exists(ancestor-or-self::imvert:package[not(imf:boolean(imvert:derived))])">
            <xsl:apply-templates select="." mode="version-chain"/>
        </xsl:if>
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the subdomain packages
    -->
    <xsl:template match="imvert:package[.=$subdomain-package]">
        <!--setup-->
        <!--validation -->
        <xsl:sequence select="imf:report-warning(., 
            normalize-space(imvert:stereotype), 
            'Package has stereotype(s) [1] but will be merged with domain package',(imvert:stereotype))"/>
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the external packages
    -->
    <xsl:template match="imvert:package[. = $external-package]">
        <!--setup-->
        <!--validation -->
        <xsl:sequence select="imf:report-error(., 
            imvert:stereotype = imf:get-config-stereotypes('stereotype-name-external-package') and 
            not(imf:is-conceptual(.)) and 
            not(normalize-space(imvert:location)), 
            'External non-conceptual packages must have a location tagged value',())"/>
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the internal packages
        REDMINE #487612
    -->
    <xsl:template match="imvert:package[. = $internal-package]">
        <!--setup-->
        <!--validation -->
    
        <!-- none yet -->
        
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for any package, be it domain, subdomain, or external package.
    -->
    <xsl:template match="imvert:package" priority="0">
        <!--setup-->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="packs-with-same-short-name" select="$schema-packages[imvert:short-name = $this/imvert:short-name]"/>
        <!--validation -->
        <!-- IM-85 -->
        <xsl:sequence select="imf:report-error(., 
            (count($packs-with-same-short-name) gt 1), 
            'Duplicate package short name: [1], check packages: [2]', (imvert:short-name, string-join($packs-with-same-short-name[. != $this]/imvert:name,', ')))"/>
        <xsl:sequence select="imf:report-error(., 
            (count(../imvert:package[imvert:name=$this/imvert:name]) gt 1), 
            'Duplicate package name.')"/>
        <xsl:sequence select="imf:report-error(.,
            /imvert:packages/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-application-package')
            and
            not(imvert:package/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')), 
            'At least one collection is required for applications.')"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:stereotype = $top-package-stereotypes
            and 
            ancestor::imvert:package[imvert:stereotype = $top-package-stereotypes],
            'Top packages cannot be nested')"/>
        
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-occurs(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>
        
        <!-- continue other validation -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for checking the version chain for domain package (this is only called on domain packages).
    -->
    <xsl:template match="imvert:package" mode="version-chain">
        <!--setup-->
        <xsl:variable name="this" select="."/>
        
        <xsl:variable name="supplier-name" select="($application-package/imvert:supplier/imvert:supplier-name, imvert:supplier/imvert:supplier-name)"/>
        <xsl:variable name="supplier-project" select="($application-package/imvert:supplier/imvert:supplier-project, imvert:supplier/imvert:supplier-project)"/>
        <xsl:variable name="supplier-release" select="($application-package/imvert:supplier/imvert:supplier-release, imvert:supplier/imvert:supplier-release)"/>
        
        <xsl:variable name="is-derived" select="imf:boolean((imvert:supplier/imvert:supplier-name,$application-package/imvert:supplier/imvert:supplier-name)[1])"/>
        
        <!-- validation on version and release -->
        <xsl:sequence select="imf:report-error(., 
            $is-application and $is-derived and empty($supplier-name), 
            'Supplier name not specified')"/>
        <xsl:sequence select="imf:report-error(., 
            $is-application and $is-derived and exists($supplier-name) and empty($supplier-release), 
            'Supplier release for supplier-name [1] not specified',$supplier-name)"/>
        <xsl:sequence select="imf:report-error(., 
            $is-application and $is-derived and exists($supplier-name) and empty($supplier-project), 
            'Supplier project for supplier-name [1] not specified',$supplier-name)"/>
            <!-- supplier-project not specified. This is expected when a supplier-name is given: ‘CDMKAD’. Ask your supplier about the corresponding supplier-name and supplier-project.  -->
        <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:phase,$phase-pattern)), 
            'Phase must be specified and must be 0, concept, 1, draft, 2, finaldraft, 3, or final')"/>
        <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:release,$release-pattern)), 
            'Release must be specified and takes the form YYYYMMDD')"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:ref-release and not(matches(imvert:ref-release,$release-pattern)), 
            'Reference release must take the form YYYMMDD')"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:base and (imvert:release lt imvert:base/imvert:release),
            'Client release date is before supplier release date.')"/>
        <xsl:sequence select="imf:report-warning(., 
            imvert:base and (xs:integer(imvert:phase) gt xs:integer(imvert:base/imvert:phase)),
            'Supplier phase mismatch, supplier is not in same or later phase.')"/>
        <xsl:apply-templates select="imvert:base" mode="version-chain"/>
    </xsl:template>
    
    
    <!-- 
        class validation 
    -->
    <xsl:template match="imvert:class">
        <!--setup-->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="this-id" select="imvert:id"/>
        <xsl:variable name="is-supertype" select="$document-classes/imvert:supertype/imvert:type-id=$this-id"/>
        <xsl:variable name="is-internal" select="not(ancestor::imvert:package/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-external-package','stereotype-name-internal-package','stereotype-name-system-package')))"/>
        <xsl:variable name="supertypes" select="imvert:supertype[not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-static-generalization'))]"/>
        <xsl:variable name="superclasses" select="imf:get-superclasses($this)"/>
        <xsl:variable name="is-id" select="(.,$superclasses)/imvert:attributes/imvert:attribute/imvert:is-id = 'true'"/>
        <xsl:variable name="is-abstract" select="imvert:abstract = 'true'"/>
        <xsl:variable name="is-toplevel" select="imf:is-toplevel($this)"/>
        <!--validation-->
        <xsl:sequence select="imf:report-warning(., 
            not(imf:test-name-convention($this)), 
            'Class name does not obey convention')"/>
        <xsl:sequence select="imf:report-error(., 
            (count(../imvert:class/imvert:name[.=$this/imvert:name]) gt 1), 
            'Duplicate class name.')"/>
        <xsl:sequence select="imf:report-error(., 
            $supertypes[2], 
            'Multiple supertypes are not supported.')"/>
        <xsl:sequence select="imf:report-error(., 
            not(imf:check-inherited-stereotypes(.)), 
            'Stereotype of supertype not assigned to its subtype.')"/>
        <xsl:sequence select="imf:report-error(., 
            not(imf:check-inheriting-stereotypes(.)), 
            'Stereotype of subtype not assigned to its supertype.')"/>
        <xsl:sequence select="imf:report-error(., 
            not(imf:check-base-stereotypes(.)), 
            'Stereotype of base type not assigned to its subtype')"/>
        <xsl:sequence select="imf:report-error(., 
            (imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union') and not(imvert:attributes/imvert:attribute)), 
            'Empty union class is not allowed.')"/>
        <xsl:sequence select="imf:report-error(., 
            (imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union') and imvert:associations/imvert:association), 
            'Association on union class is not allowed.')"/>
        <xsl:sequence select="imf:report-error(., 
            not(ancestor::imvert:package/imvert:stereotype=($schema-oriented-stereotypes)), 
            'Classes found outside a domain, system or external package.', string-join(imf:get-config-stereotypes('stereotype-name-domain-package'),'|'))"/>

        <!--Classes can only occur as part of a domain package, as only domain packages are transformed to XML schemas. If you want classes to be (temporarity) stored elsewhere, place move them to a <<recyclebin>> package.-->
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-occurs(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>

        <!--TODO CHECK VALIDATION OF MULTIPLE INHERITANCE
            <xsl:sequence select="imf:report-error(., count(imf:distinct($superclasses)) != count($superclasses), 'Multiple inheritance from same supertype')"/>
        -->
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-union','stereotype-name-composite'))) and (imvert:min-occurs or imvert:max-occurs), 
            'Cardinality on class is ignored.')"/>
        
        <!-- IM-137 must check names of classes. Conventions for xRef and xAltRef -->
        <xsl:sequence select="imf:report-warning(., 
            imvert:stereotype=imf:get-config-stereotypes('stereotype-name-reference') and not(ends-with(imvert:name,'AltRef')), 
            'Class must end with string AltRef when a reference class.')"/>
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-reference')) and ends-with(imvert:name,'AltRef'), 
            'Class may not end with string AltRef when not a reference class.')"/>
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-reference','stereotype-name-system-reference-class'))) and ends-with(imvert:name,'Ref'), 
            'Class may not end with string Ref when not a (system) reference class.')"/>
        
        <xsl:variable name="is-used-type" select="$document-classes/imvert:attributes/imvert:attribute/imvert:type-id=$this-id"/>
        <xsl:variable name="is-used-ref" select="$document-classes/imvert:associations/imvert:association/imvert:type-id=$this-id"/>
        
        <!-- TODO het niet gebruikt zijn van een klasse is een zaak van configuratie: wat zijn de potentiele topconstructs? -->
        <xsl:sequence select="imf:report-warning(., 
            $is-application and 
            not($is-toplevel) and not($is-used-type or $is-used-ref or $is-supertype), 
            'This [1] is not used.', if (exists(imvert:stereotype)) then imvert:stereotype else 'construct')"/>
        
        <xsl:next-match/>
    </xsl:template>
  
    <xsl:template match="imvert:class/imvert:supertype" priority="0">
        <!--setup-->
        <xsl:variable name="class" select=".."/>
        <xsl:variable name="super-name" select="imvert:type-name"/>
        <xsl:variable name="package-name" select="imvert:type-package"/>
        <xsl:variable name="package" select="$document-packages[imvert:name=$package-name]"/>
        <!--validation-->
        <xsl:sequence select="imf:report-error($class, 
            not($package), 
            'Required supertype package is not included')"/>
        <xsl:sequence select="imf:report-error($class, 
            not($package/imvert:class/imvert:name=$super-name), 
            'Expected supertype class not defined')"/>
        <xsl:sequence select="imf:report-hint(., 
            not(imf:is-release-age-compatible(.)), 
            'One of the subtypes is in an earlier release')"/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-interface')]">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')]">
        <!--setup-->
        <xsl:variable name="id" select="imvert:id"/>
        <!--validation-->
        <!-- TODO this code must be fine tuned, is too rough.
        <xsl:sequence select="imf:report-error(.,
            $is-application
            and
            not($collection-classes/imvert:associations/imvert:association/imvert:type-id=$id), 
            'This class does not occur in a collection, but cannot be embedded into the application.')"/>
        -->
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation=imf:get-config-stereotypes('stereotype-name-designation-datatype')]" priority="1">
        <!--setup-->
        <xsl:variable name="datatype-stereos" select="('stereotype-name-datatype','stereotype-name-complextype','stereotype-name-union')"/>
        <!--validation-->
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype=imf:get-config-stereotypes($datatype-stereos)), 
            'UML datatypes should be stereotyped as: [1]',string-join(imf:get-config-stereotypes($datatype-stereos),' or '))"/>
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-complextype','stereotype-name-union'))) and imvert:attributes/imvert:attribute, 
            'Simple datatypes should not have attributes')"/>
        <xsl:sequence select="imf:report-warning(., 
            imvert:associations/imvert:association, 
            'Datatypes should not have associations')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
        attribute validation 
    -->
    <xsl:template match="imvert:attribute">
        <!--setup-->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="property-names" select="$class/(imvert:atributes | imvert:associations)/*/imvert:name"/>
        <xsl:variable name="name" select="imvert:name"/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        <xsl:variable name="is-enumeration" select="$class/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-enumeration','stereotype-name-codelist'))"/>
        <xsl:variable name="baretype" select="imvert:baretype"/>
        <xsl:variable name="superclasses" select="imf:get-superclasses($class)"/>
        <xsl:variable name="is-abstract" select="imvert:abstract = 'true'"/>
        <xsl:variable name="stereos" select="('stereotype-name-objecttype','stereotype-name-referentielijst')"/>
        
        <xsl:variable name="is-designated-datatype" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-datatype','stereotype-name-complextype'))"/>
        <xsl:variable name="is-designated-enumeration" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-enumeration','stereotype-name-codelist'))"/>
        <xsl:variable name="is-designated-referentielijst" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-referentielijst'))"/>
        <xsl:variable name="is-designated-interface" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-interface'))"/>
        <xsl:variable name="is-designated-union" select="$defining-class/imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-union'))"/>
        <xsl:variable name="is-datatyped" select="
            $is-designated-datatype or 
            $is-designated-enumeration or 
            $is-designated-referentielijst or 
            $is-designated-interface or 
            $is-designated-union"/>
       
        <xsl:variable name="assert-attribute-not-specified" select="(not($is-enumeration) and empty(imvert:baretype) and empty(imvert:type-name))"/>
        
        <!--validation-->
        <xsl:sequence select="imf:report-warning(., 
            not(imf:test-name-convention($this)), 
            'Attribute name does not obey convention')"/>
        <xsl:sequence select="imf:report-error(., 
            (imvert:supertype[not(imvert:type-package)]), 
            'Supertype is not a known class. Is the package that defines this class in scope?')"/>
        <xsl:sequence select="imf:report-error(., 
            $assert-attribute-not-specified, 
            'Attribute type not specified')"/>
        
        <!--IM-449-->
        <xsl:sequence select="imf:report-error(., 
            not($assert-attribute-not-specified) and 
            (not($is-enumeration) and exists(imvert:baretype) and not(imf:is-known-baretype(imvert:baretype)) and empty(imvert:type-name)), 
            'Attribute type [1] is not a known type and not a scalar',imvert:baretype)"/>
        
        <xsl:sequence select="imf:report-error(., 
            not($assert-attribute-not-specified) and 
            (not($is-enumeration) and empty(imvert:baretype) and empty(imvert:type-package)), 
            'Unknown attribute type. Is the package that defines this class in scope?')"/>
        <xsl:sequence select="imf:report-error(., 
            ($class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union') and not(imvert:type-package)), 
            'Attribute of union class is not a known class.')"/>
        <!-- When a class is a union, the union attributes must be classes, not value types (baretypes). -->
        <xsl:sequence select="imf:report-error(., 
            not(imf:check-multiplicity(imvert:min-occurs,imvert:max-occurs)), 
            'Invalid target multiplicity.')"/>
        <xsl:sequence select="imf:report-warning(., 
            (count($property-names[.=$name]) gt 1), 
            'Duplicate property name.')"/>
        <xsl:sequence select="imf:report-error(., 
            not($is-enumeration) and $superclasses/*/imvert:attribute/imvert:name=$name, 
            'Attribute already defined on supertype')"/>
        <xsl:sequence select="imf:report-error(., 
            not($is-enumeration) and $superclasses/*/imvert:association/imvert:name=$name, 
            'Attribute already defined as association on supertype')"/>
        <!-- IM-325 -->       
        <!-- TODO ook referentielijsten kunnen patterns hebben. Hoe kunnen we dit het beste valideren?
        <xsl:sequence select="imf:report-error(., 
            imvert:pattern and exists($defining-class) and not($defining-class/imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-datatype','stereotype-name-enumeration'))), 
            'A pattern as been defined on an attribute that is not a scalar type, datatype or enumeration')"/>
        -->
        
        <xsl:sequence select="imf:report-error(., 
            (imvert:is-id = 'true' and empty($superclasses/imvert:stereotype = imf:get-config-stereotypes($stereos))), 
            'Only classes stereotyped as [1] may have or inherit an attribute that is an ID',string-join($stereos,' or '))"/>
        <!--Task #487338, see also IM-371 teruggedraaid. -->
       
        <!-- Jira IM-420 -->
        <xsl:sequence select="imf:report-warning(., 
            not($is-datatyped or empty($defining-class)), 
            'Attribute type of [1] must be a datatype, but is not.', ($this/imvert:stereotype))"/>
        
        <!-- Jira IM-419 -->
        <xsl:sequence select="imf:report-warning(., 
            $is-designated-referentielijst 
            and normalize-space(imf:get-tagged-value(.,'Data locatie'))
            and normalize-space(imf:get-tagged-value($defining-class,'Data locatie')), 
            '[1] has been specified on attribute as well as on [2]', ('Data location',$defining-class))"/>
        
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-occurs(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>
        
        <xsl:sequence select="imf:report-hint(., 
            not(imf:is-release-age-compatible(.)), 
            'Type is in a more recent release')"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-enumeration','stereotype-name-codelist'))]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <!--validation-->
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union')]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        <!--validation-->
        <xsl:sequence select="imf:report-error(., 
            not($defining-class), 
            'Union element has unknown type: [1]',imvert:type-name)"/>
        <xsl:sequence select="imf:report-error(., 
            not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-union-element')), 
            'Union element must be stereotyped as [1]',(imf:get-config-stereotypes('stereotype-name-union-element')))"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        <!--validation-->
        <xsl:sequence select="imf:report-error(., 
            not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attribute')), 
            'Attribute must be stereotyped as [1]', imf:get-config-stereotypes('stereotype-name-attribute'))"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-composite','stereotype-name-complextype'))]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        <xsl:variable name="name-of-attribute-stereotype" select="imf:get-config-stereotypes('stereotype-name-data-element')"/>
        
        <!--validation-->
        <xsl:sequence select="imf:report-error(., 
            imvert:is-id = 'true', 
            'Attribute may not identify a class stereotyped as [1]',../../imvert:stereotype[. = imf:get-config-stereotypes(('stereotype-name-composite','stereotype-name-complextype'))])"/>
       
        <xsl:sequence select="imf:report-error(., 
            $class/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-complextype') and not(imvert:stereotype = $name-of-attribute-stereotype), 
            'Complex datatype must have attributes that are stereotyped as: [1]',($name-of-attribute-stereotype))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute/imvert:type-name | imvert:association/imvert:type-name">
        <!--setup-->
        <xsl:variable name="type" select="."/>
        <xsl:variable name="package" select="../imvert:type-package"/>
        <xsl:variable name="is-baretype" select="../imvert:baretype"/>
        <!--validation-->
        <xsl:sequence select="imf:report-error(.., 
            (exists($package) and not($is-baretype) and empty($document-packages/imvert:name = $package)), 
            'Required package is not included.')"/>
        <xsl:sequence select="imf:report-error(.., 
            not(imf:check-known-type(.)), 
            'Unknown type [1]',(.))"/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute/imvert:name">
        <!--setup-->
        <xsl:variable name="name" select="."/>
        <xsl:variable name="class" select="../../.."/>
        <xsl:variable name="assoc-names" select="$class/imvert:associations/imvert:association/imvert:name"/>
        <!--validation-->
        <xsl:sequence select="imf:report-error(.., 
            (count(../../imvert:attribute/imvert:name[.=$name]) gt 1), 
            'Duplicate attribute name.')"/>
        <xsl:sequence select="imf:report-error(.., 
            (.=$assoc-names), 
            'Attribute name is not unique, also occurs as association name.')"/>
    </xsl:template>
    
    <!-- 
        association validation 
    -->
    <xsl:template match="imvert:association[normalize-space(imvert:origin) != imf:get-config-parameter('name-origin-system')]">
        <!--setup-->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="superclasses" select="imf:get-superclasses($class)"/>
        <xsl:variable name="package" select="$class/.."/>
        <xsl:variable name="is-collection" select="$class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')"/>
        <xsl:variable name="association-class-id" select="imvert:association-class/imvert:type-id"/>
        <xsl:variable name="property-names" select="$class/(imvert:atributes | imvert:associations)/*/imvert:name"/>
        <xsl:variable name="name" select="imvert:name"/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:variable name="defining-classes" select="($defining-class, imf:get-superclasses($defining-class))"/>
        <xsl:variable name="is-combined-identification" select="imf:get-tagged-value($this,'Gecombineerde identificatie')"/>
        <xsl:variable name="target-navigable" select="imvert:target-navigable"/>
        <!--validation-->
        
        <xsl:sequence select="imf:report-error(., 
            ($is-collection and $name and not(imf:boolean($profile-collection-wrappers))), 
            'Class that is a [1] cannot have named association(s)',(imf:get-config-stereotypes('stereotype-name-collection')))"/>
        <xsl:sequence select="imf:report-error(., 
            ($is-collection and not($name) and imf:boolean($profile-collection-wrappers)), 
            'Class that is a [1] must have named association(s)',(imf:get-config-stereotypes('stereotype-name-collection')))"/>
        <xsl:sequence select="imf:report-error(., 
            ($is-collection and not($name) and imf:boolean($profile-collection-wrappers)), 
            'A collection wrapper name is required')"/>
        <xsl:sequence select="imf:report-warning(., 
            not($is-collection) and $this/imvert:name and not(imf:test-name-convention($this)), 
            'Association name does not obey convention')"/>
        <xsl:sequence select="imf:report-error(., 
            (not($is-collection) and empty($association-class-id) and not(imvert:name)), 
            'Association without name.')"/>
        <xsl:sequence select="imf:report-error(., 
            not(imf:check-multiplicity(imvert:min-occurs,imvert:max-occurs)), 
            'Invalid target multiplicity.')"/>
        <xsl:sequence select="imf:report-warning(., 
            (count($property-names[.=$name]) gt 1), 
            'Duplicate property name.')"/>
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-occurs(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>
        <xsl:sequence select="imf:report-error(., 
            $superclasses/*/imvert:attribute/imvert:name=$name, 
            'Association already defined as attribute on supertype')"/>
        <xsl:sequence select="imf:report-error(., 
            $superclasses/*/imvert:association/imvert:name=$name, 
            'Association already defined on supertype')"/>
        
        <!-- IM-133 -->
        <xsl:sequence select="imf:report-error(., 
            not($is-collection) 
            and $class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype') 
            and $defining-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')
            and not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-externekoppeling'))
            and empty(imvert:association-class) 
            and not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-relatiesoort')), 
            'Association to [1] must be stereotyped as [2]',(imf:get-config-stereotypes('stereotype-name-objecttype'),imf:get-config-stereotypes('stereotype-name-relatiesoort')))"/>
        
        <xsl:sequence select="imf:report-error(., 
            $defining-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-composite') and (number(imvert:max-occurs-source) ne 1), 
            'Invalid source multiplicity of composition relation: [1]', (imvert:max-occurs-source))"/>
        
        <!--
        <xsl:sequence select="imf:report-warning(., 
            $defining-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-composite') and imf:boolean($target-navigable), 
            'Composition relation should not be navigable')"/>
        -->

        <xsl:sequence select="imf:report-warning(., 
            not($defining-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-composite')) and imf:boolean(imvert:source-navigable), 
            'Source of any relation should not be navigable')"/>
        
        <xsl:sequence select="imf:report-error(., 
            (imvert:aggregation='aggregation' and not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-association-to-composite'))), 
            'Composite relation must be stereotyped as [1]', imf:get-config-stereotypes('stereotype-name-association-to-composite'))"/>
        
        <xsl:sequence select="imf:report-warning(., 
            $defining-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-composite') 
            and imvert:stereotype 
            and not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-voidable')) 
            and not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-association-to-composite')), 
            'Unexpected stereotype for composite relation: [1]', (imvert:stereotype))"/>
        
        <xsl:sequence select="imf:report-warning(., 
            not(imf:check-multiplicity(imvert:min-occurs-source,imvert:max-occurs-source)), 
            'Invalid source multiplicity.')"/>
        <xsl:sequence select="imf:report-hint(., 
            not(imf:is-release-age-compatible(.)), 
            'Type is in a more recent release')"/>

        <!-- if combined identification, check some properties -->
        <xsl:sequence select="imf:report-error(., 
            $is-combined-identification 
            and empty(($defining-classes/imvert:is-id)[imf:boolean(.)]), 
            'Combined identification on relation [1] to object type [2] without identifier',(imvert:name,$defining-class/imvert:name[1]))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*" mode="unique-id">
        <xsl:variable name="id" select="imvert:id"/>
        <xsl:choose>
            <xsl:when test="$id and exists(key('key-unique-id',$id)[2])">
                <xsl:sequence select="imf:report-error(., 
                    true(), 
                    'Duplicate construct id [1]', $id)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="unique-id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <?x
    <xsl:template match="imvert:tagged-value[exists(imf:get-config-tagged-values()[name = current()/imvert:name]/declared-values)]">
        <!-- setup -->
        <xsl:variable name="lijst-van-waarden" select="imf:get-config-tagged-values()[name = current()/imvert:name]/declared-values/value"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:value = $lijst-van-waarden), 
            'Value [1] for tagged value [2] not correct. Possible values are: [3]',(imvert:value, imvert:name, string-join($lijst-van-waarden,'; ')))"/>
        
        <xsl:next-match/>
    </xsl:template>
    ?>
    
    <?x
    <xsl:template match="imvert:tagged-value[imvert:name = imf:get-normalized-name('Indicatie authentiek','tv-name')]">
        <!-- setup -->
        <xsl:variable name="lijst-van-authentiek-waarden" select="imf:get-config-tagged-values()[name = imf:get-normalized-name('Indicatie authentiek','tv-name')]/declared-values/value"/>
        
        <!-- validate -->
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:value = $lijst-van-authentiek-waarden), 
            'Value [1] for tagged value [2] not correct',(imvert:value, imvert:name))"/>
        
        <xsl:next-match/>
    </xsl:template>
    ?>
    
    <xsl:template match="text()" mode="unique-id"> 
        <!-- skip -->
    </xsl:template> 
    
    <!-- 
        other validation 
    -->
    <xsl:template match="*|text()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
    <!-- 
        functions 
    -->
    
    <!-- true wanneer alle noodzakelijke stereotypes van supertype in dit subtype zijn opgenomen --> 
    <xsl:function name="imf:check-inherited-stereotypes" as="xs:boolean">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="supers" select="imf:get-superclasses($this)"/>
        <!-- IM-73 if interfaces, remove the class from the list -->
        <xsl:variable name="super" select="for $s in $supers return if ($s/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-interface')) then () else $s"/>
        <xsl:choose>
            <xsl:when test="exists($super)">
                <xsl:variable name="results" as="xs:integer*">
                    <xsl:for-each select="$super/imvert:stereotype">
                        <xsl:choose>
                            <xsl:when test="not(.=$copy-down-stereotypes-inheritance)"/>
                            <xsl:when test="$this/imvert:stereotype=.">1</xsl:when>
                            <xsl:when test="$this/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-koppelklasse')">1</xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="not($results=0)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- true wanneer alle noodzakelijke stereotypes van subtype in dit supertype zijn opgenomen --> 
    <xsl:function name="imf:check-inheriting-stereotypes" as="xs:boolean">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="supers" select="imf:get-superclasses($this)"/>
        <!-- IM-73 if interfaces, remove the class from the list -->
        <xsl:variable name="super" select="for $s in $supers return if ($s/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-interface')) then () else $s"/>
        <xsl:choose>
            <xsl:when test="exists($super)">
                <xsl:variable name="results" as="xs:integer*">
                    <xsl:for-each select="$copy-up-stereotypes-inheritance">
                        <xsl:variable name="stereo-name" select="."/>
                        <xsl:if test="$this/imvert:stereotype=$stereo-name">
                            <xsl:value-of select="if ($super[not(imvert:stereotype=$stereo-name)]) then 0 else 1"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="not($results=0)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- true wanneer alle noodzakelijke stereotypes van base types zijn opgenomen --> 
    <xsl:function name="imf:check-base-stereotypes" as="xs:boolean">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="base" select="$this/imvert:base"/>
        <xsl:variable name="results" as="xs:integer*">
            <xsl:for-each select="$base/imvert:stereotype">
                <xsl:if test=".=$copy-down-stereotypes-realization">
                    <xsl:value-of select="if ($this/imvert:stereotype=.) then 1 else 0"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="not($results=0)"/>
    </xsl:function>
    
    <!-- 
        Determine if this type is a known type.
        This is a type that is a primitive, or defined as a class.
        The class definition should also be available.
    -->
    
    <xsl:function name="imf:check-known-type" as="xs:boolean">
        <xsl:param name="type-name" as="element(imvert:type-name)"/>
        <xsl:variable name="type-id" select="$type-name/../imvert:type-id"/>
        <xsl:variable name="defining-class" select="$document-classes[imvert:id=$type-id]"/>
        <xsl:variable name="scalar" select="$all-scalars[@id = $type-name][last()]"/>
        <xsl:value-of select="exists($defining-class) or exists($scalar)"/>
    </xsl:function>
    
    <xsl:function name="imf:check-multiplicity" as="xs:boolean">
        <xsl:param name="minOccurs" as="xs:string?"/>
        <xsl:param name="maxOccurs" as="xs:string?"/>
        <xsl:variable name="effective-minOccurs" select="xs:integer(if (normalize-space($minOccurs)) then $minOccurs else 1)"/>
        <xsl:variable name="effective-maxOccurs" select="xs:integer(if (normalize-space($maxOccurs)) then (if ($maxOccurs='unbounded') then 999 else $maxOccurs) else 1)"/>
        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="not(matches($minOccurs,$minoccurs-pattern))">0</xsl:when>
                <xsl:when test="not(matches($maxOccurs,$maxoccurs-pattern))">0</xsl:when>
                <xsl:when test="$effective-minOccurs gt $effective-maxOccurs">0</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$result!='0'"/>
    </xsl:function>

    <xsl:function name="imf:compare-state" as="xs:string">
        <xsl:param name="client" as="element()"/>
        <xsl:param name="supplier" as="element()?"/>
        <xsl:variable name="client-version" select="imf:generate-version-number($client/imvert:version)"/>
        <xsl:variable name="supplier-version" select="imf:generate-version-number($supplier/imvert:version)"/>
        <xsl:choose>
            <xsl:when test="$client-version=0">INVALID</xsl:when>
            <xsl:when test="$supplier-version=0">INVALID</xsl:when>
            <xsl:when test="$client lt $supplier">MISMATCH</xsl:when>
            <xsl:otherwise>OKAY</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:compare-state-phase-pairs" as="xs:string">
        <xsl:param name="client" as="element()"/>
        <xsl:param name="supplier" as="element()?"/>
        <xsl:variable name="client-phase" select="xs:integer($client/imvert:phase)"/>
        <xsl:variable name="supplier-phase" select="xs:integer($supplier/imvert:phase)"/>
        <xsl:choose>
            <xsl:when test="$client-phase lt $supplier-phase">INVALID</xsl:when>
            <xsl:otherwise>OKAY</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- generate a version number with which we can make calculations --> 
    <xsl:function name="imf:generate-version-number" as="xs:integer">
        <xsl:param name="version" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="matches($version,'[0-9]+\.[0-9]+\.[0-9]+')">
                <xsl:variable name="tokens" select="tokenize($version,'\.')"/>
                <xsl:value-of select="(xs:integer($tokens[1]) * 100) + (xs:integer($tokens[2]) * 10) + xs:integer($tokens[3])"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="imf:check-documentation" as="xs:boolean">
        <xsl:param name="this" as="element()"/> <!-- any element that may have documentation -->
        <xsl:choose>
            <xsl:when test="exists($this/imvert:documentation/node())">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Check if each stereotype assigned to the construct is allowed for that construct. 
    -->
    <xsl:function name="imf:check-stereotype-assignment" as="element()*">
        <xsl:param name="this" as="element()"/> <!-- any element that may have stereotype -->
        <xsl:variable name="result">
            <xsl:for-each select="$this/imvert:stereotype">
                <xsl:variable name="stereotype" select="imf:get-normalized-name(.,'stereotype-name')"/>
                <xsl:choose>
                    <xsl:when test="$this/self::imvert:package">
                        <xsl:choose>
                            <xsl:when test="$stereotype=imf:get-config-stereotype-names('package')"/>
                            <xsl:otherwise>
                                <xsl:value-of select="$stereotype"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$this/self::imvert:class">
                        <xsl:choose>
                            <xsl:when test="$stereotype=imf:get-config-stereotype-names('class')"/>
                            <xsl:when test="$stereotype=imf:get-config-stereotype-names('datatype')"/>
                            <xsl:otherwise>
                                <xsl:value-of select="$stereotype"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$this/self::imvert:attribute">
                        <xsl:choose>
                            <xsl:when test="$stereotype=imf:get-config-stereotype-names('attribute')"/>
                            <xsl:otherwise>
                                <xsl:value-of select="$stereotype"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$this/self::imvert:association">
                        <xsl:variable name="source-stereotype" select="$this/ancestor::imvert:class[1]/imvert:stereotype"/>
                        <xsl:variable name="target-stereotype" select="$document-classes[imvert:id=$this/imvert:type-id]/imvert:stereotype"/>
                        <xsl:variable name="is-composite" select="$this/imvert:aggregation='composite'"/>
                        <xsl:choose>
                            <xsl:when test="$source-stereotype=imf:get-config-stereotypes('stereotype-name-relatieklasse') and not($stereotype)"/>
                            <xsl:when test="$target-stereotype=imf:get-config-stereotypes('stereotype-name-relatieklasse') and not($stereotype)"/>
                            <xsl:when test="$source-stereotype=imf:get-config-stereotypes('stereotype-name-objecttype') and not($stereotype)"/>
                            <xsl:when test="$target-stereotype=imf:get-config-stereotypes('stereotype-name-relatieklasse') and not($stereotype)"/>
                            <xsl:when test="$stereotype=imf:get-config-stereotype-names('association')"/>
                            <xsl:otherwise>
                                <xsl:value-of select="$stereotype"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:sequence select="imf:report-warning($this, imf:get-config-stereotype-name-deprecated(.), 'Stereotype is deprecated: [1]', .)"/>
            </xsl:for-each>
        </xsl:variable>
        <!-- IM-67 -->
        <xsl:sequence select="imf:report-warning($this, normalize-space($result[1]), 'Stereotype not expected or unknown: [1]',(string-join($result,', ')))"/>
    </xsl:function>
    
    <!-- check if tagged values assigned are expected on this construct -->
    
    <xsl:variable name="config-tagged-values" select="imf:get-config-tagged-values()"/>
    
    <!-- 
        When testing for tagged value assignmnt is requested:
        
        Go through all tagged values, and check if it is a known (declared) tagged value. 
        If so, check if it allowed on this stereotype. If not, produce warning.
        If so, check if value is specified when required.
    -->
    <xsl:function name="imf:check-tagged-value-assignment" as="element()*">
        <xsl:param name="this" as="element()"/> <!-- any element that may have stereotype and tagged values-->
        
        <xsl:variable name="stereotype" select="$this/imvert:stereotype"/>
        <xsl:if test="$validate-tv-assignment">
            <xsl:for-each select="$this/imvert:tagged-values/imvert:tagged-value">
                <xsl:variable name="name" select="imvert:name"/>
                <xsl:variable name="value" select="imvert:value"/>
            
                <xsl:variable name="declared" select="$config-tagged-values[name = $name]"/>
                
                <xsl:variable name="required-as-found" select="($declared/stereotypes/stereo[. = $stereotype]/@required)[last()]"/>
                <xsl:variable name="value-required" select="imf:boolean(if ($required-as-found) then $required-as-found else 'false')"/>
                <xsl:variable name="value-listing" select="($declared/declared-values)[last()]/value"/>
              
                <xsl:variable name="valid-for-stereotype" select="$declared/stereotypes/stereo = $stereotype"/>
                <xsl:variable name="valid-omitted" select="empty($stereotype) and $declared/stereotypes/stereo = $normalized-stereotype-none"/>
                <xsl:variable name="valid-from-listing" select="$value = $value-listing"/>
                
                <!--<xsl:message select="string-join(($name, $value, string($required-as-found),string($value-required)),';')"></xsl:message>-->
                <xsl:choose>
                    <xsl:when test="empty($declared)">
                        <!-- an unknown tagged value, not configured anywhere -->
                        <xsl:sequence select="imf:report-warning($this, true(), 'Tagged value not expected or unknown: [1]',.)"/>
                    </xsl:when>
                    <xsl:when test="not($valid-for-stereotype)">
                        <xsl:sequence select="imf:report-warning($this, true(), 'Tagged value [1] not expected on stereotype [2]',($name/@original,$stereotype))"/>
                    </xsl:when>
                    <xsl:when test="$value-required and not(normalize-space($value))">
                        <xsl:sequence select="imf:report-error($this, true(), 'Tagged value [1] has no value',($name/@original))"/>
                    </xsl:when>
                    <xsl:when test="exists($value-listing) and not($valid-from-listing)">
                        <xsl:sequence select="imf:report-error($this, true(), 'Tagged value [1] has undeclared value [2], allowed values are: [3]',($name/@original,imf:value-trim($value,80),string-join($value-listing,'&quot;, &quot;')))"/>
                    </xsl:when>
                    <xsl:when test="not($valid-omitted)">
                        <!-- okay, allowed -->
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
        
    </xsl:function>

    <xsl:function name="imf:check-tagged-value-multi" as="element()*">
        <xsl:param name="this" as="element()"/> <!-- any element that may have tagged values-->
        <xsl:variable name="stereotype" select="$this/imvert:stereotype"/>
        <xsl:for-each-group select="$this/imvert:tagged-values/imvert:tagged-value" group-by="imvert:name">
            <xsl:sequence select="imf:report-error($this, count(current-group()) gt 1, 'Duplicate tagged values: [1]',current-grouping-key())"/>
        </xsl:for-each-group>
    </xsl:function>
    
    <!-- when validation level is M (Missing metadata), check if all required tagged values have been set -->
    
    <xsl:function name="imf:check-tagged-value-occurs" as="element()*">
        <xsl:param name="this" as="element()"/> <!-- any element that may have tagged values-->
        <xsl:if test="$validate-tv-missing">
            <xsl:variable name="stereotype" select="$this/imvert:stereotype"/>
            <xsl:variable name="tvs-for-stereotype" select="$config-tagged-values[stereotypes/stereo = $stereotype]"/>
            <xsl:for-each-group select="$tvs-for-stereotype" group-by="name">
                <xsl:variable name="tv-name" select="current-grouping-key()"/>
                <xsl:variable name="effective-tv" select="current-group()[last()]"/>
                <xsl:variable name="effective-tv-is-required" select="exists($effective-tv[stereotypes/stereo[. = $stereotype and @required = 'yes']])"/>
                <xsl:sequence select="imf:report-warning($this, 
                    $effective-tv-is-required and empty($this/imvert:tagged-values/imvert:tagged-value[imvert:name = $tv-name]),
                    'Tagged value [1] not specified but required for [2]',($tv-name,$stereotype))"/>
            </xsl:for-each-group>
        </xsl:if> 
    </xsl:function>
    
    <!-- remove duplicates from sequence -->
    <xsl:function name="imf:distinct" as="item()*">
        <xsl:param name="set1" as="item()*"/>
        <xsl:for-each-group select="$set1" group-by=".">
            <xsl:copy-of select="."/>
        </xsl:for-each-group>
    </xsl:function>

    <xsl:function name="imf:test-name-convention" as="xs:boolean">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="true()"/>
        
        <!-- TODO needed? we change names when creating the base imvert file, in canonization -->
        <?T
        <xsl:variable name="type" select="local-name($this)"/>
        <xsl:variable name="convention" select="
            if ($type='package') then $convention-package-name-pattern
            else if ($type='class') then $convention-class-name-pattern
            else if ($type='attribute') then $convention-attribute-name-pattern
            else if ($type='association') then $convention-association-name-pattern
            else '?'"
        />
        <xsl:value-of select="matches($this/imvert:name,$convention)"/>
        ?>
    </xsl:function>
   
    <!-- 
        True if the release of the class which property is passed is newer than or equal to the release of the type 
        When the type release is not known, assume age compatibility. 
    -->
    <xsl:function name="imf:is-release-age-compatible" as="xs:boolean">
        <xsl:param name="property" as="element()"/>
        <xsl:variable name="this-release" select="$property/ancestor::imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')][1]/imvert:release"/>
        <xsl:variable name="refed-type-id" select="$property/imvert:type-id"/>
        <xsl:variable name="refed-release" select="if ($refed-type-id) then imf:get-construct-by-id($refed-type-id)/ancestor::imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package') or .=$external-package][1]/imvert:release else '00000000'"/>
        <xsl:value-of select="if (($this-release ge $refed-release) or not($refed-release))  then true() else false()"/>
    </xsl:function>
    
    <!-- return the top package that this construct is part of. This is application, base or variant. --> 
    <!-- IM-91 -->
    <xsl:function name="imf:get-top-package" as="element()?">
        <xsl:param name="construct" as="element()?"/>
        <xsl:sequence select="$construct/ancestor-or-self::imvert:package[imvert:stereotype = $top-package-stereotypes][1]"/>
    </xsl:function>

    <!-- return the external package that this construct is part of. This is system or external. --> 
    <!-- IM-91 -->
    <xsl:function name="imf:get-external-package" as="element()?">
        <xsl:param name="construct" as="element()?"/>
        <xsl:sequence select="$construct/ancestor-or-self::imvert:package[.=$external-package][1]"/>
    </xsl:function>
    
    <!-- return the internal package that this construct is part of. --> 
    <!-- REDMINE #487612 -->
    <xsl:function name="imf:get-internal-package" as="element()?">
        <xsl:param name="construct" as="element()?"/>
        <xsl:sequence select="$construct/ancestor-or-self::imvert:package[.=$internal-package][1]"/>
    </xsl:function>
    
    <xsl:function name="imf:value-trim">
        <xsl:param name="value"/>
        <xsl:param name="max-length"/>
        <xsl:variable name="length" select="string-length($value)"/>
        <xsl:variable name="min-length" select="($max-length div 2) - 5"/>
        <xsl:value-of select="if ($length gt $max-length) then concat(substring($value,1,$min-length),' ... ... ',substring($value,$length - $min-length)) else $value"/>
    </xsl:function>
    
    <xsl:function name="imf:is-toplevel">
        <xsl:param name="class"/>
        <xsl:variable name="stereos" select="$class/imvert:stereotype"/>
        <xsl:variable name="stereos-ids" select="imf:get-stereotypes-ids($stereos)"/>
        <xsl:sequence select="imf:get-config-stereotype-is-toplevel($stereos-ids)"/>
    </xsl:function>
     
    <xsl:function name="imf:is-known-baretype">
        <xsl:param name="name"/>
        <xsl:sequence select="$name = imf:get-config-scalar-names()"/>
    </xsl:function>
</xsl:stylesheet>
