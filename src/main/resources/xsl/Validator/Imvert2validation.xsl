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
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
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
    <xsl:import href="../common/extension/Imvert-common-regex.xsl"/>
    
    <xsl:variable name="release-pattern">^(\d{8})$</xsl:variable>
    <xsl:variable name="phase-pattern">^(0|1|2|3)$</xsl:variable>
    <xsl:variable name="minoccurs-pattern">^(\d+)$</xsl:variable>
    <xsl:variable name="maxoccurs-pattern">^(\d+|unbounded)$</xsl:variable>
    
    <!-- test if the construct passed follows the naming conventions -->
    <xsl:variable name="convention-package-name-pattern">^(([A-Z][A-z0-9]+)+)$</xsl:variable>
    <xsl:variable name="convention-class-name-pattern">^(_?([A-Z][A-z0-9]+)+)$</xsl:variable>
    <xsl:variable name="convention-attribute-name-pattern">^([A-z][A-z0-9]+)$</xsl:variable>
    <xsl:variable name="convention-association-name-pattern">^([a-z][A-z0-9]+)$</xsl:variable>
    
    <!-- test if the project, application or release name conforms to basic file nameing requirements, as these are used in subpath (after space normalization) -->
    <xsl:variable name="file-name-requirements-pattern">^[A-Za-z0-9\-\s._]+$</xsl:variable>
    
    <!-- Stereotypes that must corresponde from superclass to subclass -->
    <xsl:variable name="copy-down-stereotypes-inheritance" select="
        ('stereotype-name-complextype',
         'stereotype-name-objecttype',
         'stereotype-name-koppelklasse')"/>

    <!-- Stereotypes that must correspond from subclass to superclass -->
    <xsl:variable name="copy-up-stereotypes-inheritance" select="
        ('stereotype-name-objecttype')"/>
  
    <!-- Stereotypes that must correspond from base to variant -->
    <xsl:variable name="copy-down-stereotypes-realization" select="
        ('stereotype-name-complextype',
         'stereotype-name-objecttype')"/>
 
    <!-- All possible application-level top-packages -->
    <xsl:variable name="top-package-stereotypes" select="
        ('stereotype-name-base-package',
         'stereotype-name-variant-package',
         'stereotype-name-application-package')"/>
   
    <!-- Stereotypes of packages that may define classes -->
    <xsl:variable name="schema-oriented-stereotypes" select="
        ('stereotype-name-system-package',
        'stereotype-name-external-package',
        'stereotype-name-internal-package',
        'stereotype-name-domain-package',
        'stereotype-name-message-package',
        'stereotype-name-view-package',
        'stereotype-name-components-package')"/>

    <!-- Stereotypes that may occur in unions -->
    <xsl:variable name="union-element-stereotypes" select="
        ('stereotype-name-objecttype',
        'stereotype-name-koppelklasse',
        'stereotype-name-union',
        'stereotype-name-composite')"/>
  
    <!-- Stereotypes that are referenced -->
    <xsl:variable name="xref-element-stereotypes" select="
        ('stereotype-name-objecttype')"/>   <!-- more when product -->
   
    <xsl:variable name="application-package" select="//imvert:package[imf:boolean(imvert:is-root-package)]"/>
    
    <!-- 
        The set of external packages includes all packages that are <<external>> of any subpackage thereof.
        The external package must also define any class that is referenced by the application.
    -->
    <xsl:variable name="external-package" select="//imvert:package[
        (ancestor-or-self::imvert:package/imvert:stereotype/@id = ('stereotype-name-external-package') 
         and (imvert:class/imvert:id = $application-package//imvert:type-id)) 
        or imvert:stereotype/@id = ('stereotype-name-system-package')]"/>
    
    <!-- 
        The set of internal packages includes all packages that are <<external>> of any subpackage thereof.
        The external package must also define any class that is referenced by the application.
    -->
    <xsl:variable name="internal-package" select="//imvert:package[ancestor-or-self::imvert:package/imvert:stereotype/@id = ('stereotype-name-internal-package') and (imvert:class/imvert:id = $application-package//imvert:type-id)]"/>
    <!-- 
        The set of compoennts packages includes all packages that are <<components>> of any subpackage thereof.
    -->
    <xsl:variable name="components-package" select="//imvert:package[ancestor-or-self::imvert:package/imvert:stereotype/@id = ('stereotype-name-components-package')]"/>
    
    <xsl:variable name="domain-package" select="$application-package//imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package','stereotype-name-view-package')]"/>
    <xsl:variable name="subdomain-package" select="$domain-package//imvert:package"/>
    
    <xsl:variable name="document-packages" select="($application-package,$domain-package,$subdomain-package,$external-package,$internal-package,$components-package)"/>
    <xsl:variable name="document-classes" select="$document-packages/imvert:class"/>

    <xsl:variable name="is-application" select="$application-package/imvert:stereotype/@id = ('stereotype-name-application-package')"/>
    
    <xsl:variable name="schema-packages" select="$document-packages[imvert:stereotype/@id = $schema-oriented-stereotypes]"/>

    <xsl:variable name="normalized-stereotype-none" select="imf:get-normalized-name('#none','stereotype-name')"/>
    
    <!-- check the class hierarchy, no type recursion allowed -->
    <xsl:variable name="is-proper-class-tree" select="imf:boolean-and(for $class in $application-package//imvert:class[imvert:supertype] return imf:check-proper-class-tree($class,string($class/imvert:id)))"/>
    
    <xsl:variable name="allow-multiple-tv" select="imf:boolean(imf:get-config-string('cli','allowduplicatetv','no'))"/>
    <xsl:variable name="allow-native-scalars" select="imf:boolean(imf:get-config-string('cli','nativescalars','yes'))"/>
    
    <xsl:variable name="model-is-general" select="$application-package/imvert:model-level = 'general'"/>
    
    <xsl:variable name="datatype-stereos" select="
        ('stereotype-name-simpletype',
        'stereotype-name-complextype',
        'stereotype-name-union',
        'stereotype-name-union-attributes',
        'stereotype-name-union-associations',
        'stereotype-name-referentielijst',
        'stereotype-name-codelist',
        'stereotype-name-interface',
        'stereotype-name-enumeration')"/>
    
    <xsl:variable name="enumeration-stereos" select="
        ('stereotype-name-enumeration')"/>
    
    <xsl:variable name="allow-scalar-in-union" select="imf:boolean($configuration-metamodel-file//features/feature[@name='allow-scalar-in-union'])"/>
    <xsl:variable name="unique-normalized-class-names" select="$configuration-metamodel-file//features/feature[@name='unique-normalized-class-names']"/>
    
    <!-- all display names of all properties -->
    <xsl:variable name="property-display-names" select="for $p in ($domain-package//imvert:attribute,$domain-package/imvert:association) return imf:get-display-name($p)"/>
    
    <xsl:key name="key-unique-id" match="//*[imvert:id]" use="imvert:id"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
      
        Place rules here that focus on the complete specification rather than particular constructs. 
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
            
            <xsl:attribute name="release" select="imf:get-config-string('appinfo','release')"/>
            <xsl:attribute name="version" select="imf:get-config-string('appinfo','version')"/>
            <xsl:attribute name="phase" select="imf:get-config-string('appinfo','phase')"/>
            
            <xsl:variable name="c" select="imf:check-unique-name($document-classes)"/>
            <xsl:sequence select="imf:report-error(., 
                $unique-normalized-class-names = 'model' and exists($c), 
                'Multiple constructs with same name: [1]  found in model', 
                imf:string-group(for $cc in $c return imf:get-display-name($cc)))"/>
            
            <!-- determine if all constructs are unique -->
            <xsl:apply-templates select="*" mode="unique-id"/>
            
            <!-- determine of all stereotypes may be combined -->
            
            <xsl:sequence select="for $construct in .//imvert:*[imvert:stereotype] return imf:check-primary-stereotypes($construct)"/>
            
            <!-- process the application package -->
            <xsl:apply-templates select="imvert:package"/>
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="imvert:package[imf:member-of(.,$application-package)]" priority="101">
        <xsl:sequence select="imf:track('Validating package [1]',imvert:name)"/>
       <!-- <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:version,imf:get-config-parameter('application-version-regex'))), 
            'Version identifier has invalid format')"/> -->
        <xsl:sequence select="imf:report-error(., 
            not(normalize-space(imvert:namespace)), 
            'No root namespace defined for application')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:package[imf:member-of(..,$application-package)]" priority="102">
        <!-- redmine #487837 Packages in <<application>> moeten bekend stereotype hebben -->
        <xsl:sequence select="imf:report-error(., 
            not(imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package','stereotype-name-internal-package','stereotype-name-recyclebin','stereotype-name-folder-package','stereotype-name-view-package')), 
            'Package with unexpected stereotype(s): [1]', imvert:stereotype)"/>
      
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:package[imf:member-of(.,$domain-package)]" priority="101">
        <xsl:sequence select="imf:track('Validating package [1]',imvert:name)"/>
        
        <xsl:variable name="c" select="imf:check-unique-name(imvert:class)"/>
        <xsl:sequence select="imf:report-error(., 
            $unique-normalized-class-names = 'domain' and exists($c), 
            'Multiple constructs with same name [1] found in domain [2]', 
            (imf:string-group(for $cc in $c return imf:get-display-name($cc)),imf:get-display-name(.)))"/>
        
        <!--x
        <xsl:sequence select="imf:report-error(., 
            not(matches(imvert:version,imf:get-config-parameter('domain-version-regex'))), 
            'Version identifier has invalid format')"/>
        x-->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the application and domain packages
    -->
    <xsl:template match="imvert:package[imf:member-of(.,($application-package,$domain-package))]" priority="100">
        <!-- setup -->
        <xsl:variable name="this" select="."/>
     
        <!-- validation -->

        <!-- version and release check -->
        
        <xsl:sequence select="imf:check-version($this)"/>
        <xsl:sequence select="imf:check-phase($this)"/>
        <xsl:sequence select="imf:check-release($this)"/>
        
        <!-- naming -->
        <xsl:sequence select="imf:report-warning(., 
            not(imf:test-name-convention($this)), 
            'Package name does not obey convention')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the application package
    -->
    <xsl:template match="imvert:package[imf:member-of(.,$application-package)]" priority="50">
        <!--setup-->
        <xsl:variable name="this-package" select="."/>
        <xsl:variable name="root-release" select="imvert:release" as="xs:string?"/>
       
        <xsl:variable name="domain-packages" select=".//imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package')]"/>
        <xsl:variable name="subpackage-releases" select="$domain-packages/imvert:release[not(.=('99999999','00000000'))]" as="xs:string*"/>
        <xsl:variable name="collections" select="$domain-packages/imvert:class[imvert:stereotype/@id = ('stereotype-name-collection')]"/>
        <!--validation-->

        <xsl:sequence select="imf:report-error(., 
            not(imf:test-file-name-convention($this-package/imvert:name)), 
            'Package name holds invalid characters')"/>
        <xsl:sequence select="imf:report-error(., 
            empty($domain-packages), 
            'No domain subpackages found')"/>
        <xsl:sequence select="imf:report-error(., 
            not($root-release), 
            'The root package must have a release number')"/>
        <!-- IM-110 -->
        <xsl:sequence select="imf:report-error(., 
            not(imf:boolean($buildcollection)) and exists($collections), 
            'Collection [1] is used but referencing is suppressed.', ($collections[1]))"/>
        <xsl:choose>
            <xsl:when test="count($subpackage-releases) != 0">
                <xsl:variable name="largest" select="imf:largest($subpackage-releases)"/>
                <xsl:sequence select="imf:report-error(., 
                    ($root-release gt $largest), 
                    'The root package release number [1] is too recent. None of the domain packages has this release. Most recent is [2].',($root-release,$largest))"/>
                <xsl:sequence select="imf:report-error(., 
                    ($root-release lt $largest), 
                    'The root package release number [1] is too old. One or more of the domain packages has a more recent release: [2]',($root-release,$largest))"/>
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
            <xsl:variable name="fails" select="not(imf:member-of(imf:get-top-package($refed-class),$this-package) or imf:get-internal-package($refed-class) or imf:get-external-package($refed-class))"/>
            <xsl:choose>
                  <xsl:when test="exists(parent::imvert:supertype)">
                      <xsl:sequence select="imf:report-error(ancestor::*[imvert:name][1], 
                          $fails, 
                          'Supertype reference to a class [1] that is not part of this or any external application',$refed-name)"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:sequence select="imf:report-error(ancestor::*[imvert:name][1], 
                          $fails, 
                          'Property type reference to a class [1] that is not part of this or any external application',$refed-name)"/>
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
            <xsl:variable name="products" select="$application-package/imvert:class[imvert:stereotype/@id = ('stereotype-name-product','stereotype-name-process','stereotype-name-service','stereotype-name-featurecollection') and .//imvert:type-id=$collection-id]"/>
            
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
                        (not(imf:member-of($shared-class,$all-calculated-collection-classes)) and not($document-classes/imvert:substitution/imvert:supplier-id = $shared-class/imvert:id)), 
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
    <xsl:template match="imvert:package[imf:member-of(.,$domain-package)]" priority="50">
        <!--setup-->
        <xsl:variable name="is-schema-package" select="if (imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package','stereotype-name-view-package')) then true() else false()"/>
        <xsl:variable name="xref-objects" select="imvert:class[imvert:stereotype/@id = $xref-element-stereotypes]"/>
        <xsl:variable name="application" select="ancestor::imvert:package[imvert:stereotype/@id = $top-package-stereotypes][1]"/>
          <!--validation -->
        <xsl:sequence select="imf:report-error(., 
            not($is-schema-package), 
            'Domain package must have the domain stereotype.')"/>
        <?x replaced by test on $unique-normalized-class-names
        <xsl:sequence select="imf:report-error(., 
        <xsl:variable name="classnames" select="distinct-values(imf:get-duplicates(imvert:class/imvert:name))" as="xs:string*"/>
            not(empty($classnames)), 
            'Duplicate class name within (sub)package(s): [1]',$classnames)"/>
        x?>
        <xsl:sequence select="imf:report-error(., 
            ancestor::imvert:package[imf:member-of(.,$domain-package)],
            'Domain packages cannot be nested')"/>
      
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
    <xsl:template match="imvert:package[imf:member-of(.,$subdomain-package)]">
        <!--setup-->
        <!--validation -->
        <xsl:sequence select="imf:report-warning(., 
            exists(imvert:stereotype) and not(imvert:stereotype/@id = ('stereotype-name-folder-package')), 
            'Package has stereotype(s) [1] but will be merged with domain package',(imf:string-group(imvert:stereotype)))"/>
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the external packages
    -->
    <xsl:template match="imvert:package[imf:member-of(.,$external-package)]">
        <!--setup-->
        <!--validation -->
        <?x
        <xsl:sequence select="imf:report-error(., 
            imvert:stereotype/@id = ('stereotype-name-external-package') and 
            not(imf:is-conceptual(.)) and 
            not(normalize-space(imvert:location)), 
            'External non-conceptual packages must have a location tagged value',())"/>
        x?>
        
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the internal packages
        REDMINE #487612
    -->
    <xsl:template match="imvert:package[imf:member-of(.,$internal-package)]">
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
            'Duplicate package short name: [1], check packages: [2]', (imvert:short-name, imf:string-group($packs-with-same-short-name[not(imf:member-of(.,$this))]/imvert:name)))"/>
        <xsl:sequence select="imf:report-error(., 
            (count(../imvert:package[imvert:name=$this/imvert:name]) gt 1), 
            'Duplicate package name.')"/>
        <xsl:sequence select="imf:report-error(.,
            /imvert:packages/imvert:stereotype/@id = ('stereotype-name-application-package')
            and
            not(imvert:package/imvert:stereotype/@id = ('stereotype-name-collection')), 
            'At least one collection is required for applications.')"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:stereotype/@id = $top-package-stereotypes
            and 
            ancestor::imvert:package[imvert:stereotype/@id = $top-package-stereotypes],
            'Top packages cannot be nested')"/>
        
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>
        
        <!-- check traces -->
        <xsl:for-each select="imvert:supplier/@subpath">
            <xsl:sequence select="imf:report-error(../..,
                not(imf:exists-imvert-supplier-doc(.)), 
                'No supplier document found: [1]', .)"/> <!-- NB deze melding NSSD1 komt ook voor bij pretrace maar daar is die fatal. -->
        </xsl:for-each>
        
        <!-- continue other validation -->
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for checking the version chain for domain package (this is only called on domain packages).
    -->
    <xsl:template match="imvert:package" mode="version-chain">
        <!--setup-->
        <xsl:variable name="this" select="."/>
        
        <xsl:variable name="supplier-project" select="($application-package/imvert:supplier/imvert:supplier-project, imvert:supplier/imvert:supplier-project)"/>
        <xsl:variable name="supplier-name" select="($application-package/imvert:supplier/imvert:supplier-name, imvert:supplier/imvert:supplier-name)"/>
        <xsl:variable name="supplier-release" select="($application-package/imvert:supplier/imvert:supplier-release, imvert:supplier/imvert:supplier-release)"/>
        
        <xsl:variable name="is-stated-derived" select="imf:boolean(imvert:derived)"/>
        
        <xsl:variable name="is-found-derived" select="exists(($supplier-project,$supplier-name,$supplier-release))"/>
        <xsl:variable name="is-derived" select="$is-found-derived or $is-stated-derived"/>
        
        <!-- validation on version and release -->
        <!--<xsl:sequence select="imf:report-warning(., 
            $is-found-derived and not($is-stated-derived), 
            'Package is found to be derived but this is not stated')"/>-->
        <xsl:sequence select="imf:report-error(., 
            $is-stated-derived and not($is-found-derived), 
            'Package is stated to be derived but derivation info is not found or complete')"/>
        <xsl:sequence select="imf:report-error(., 
            $is-derived and empty($supplier-project), 
            'Package is derived but no supplier project specified')"/>
        <xsl:sequence select="imf:report-error(., 
            $is-derived and empty($supplier-name), 
            'Package is derived but no supplier name specified')"/>
        <xsl:sequence select="imf:report-error(., 
            $is-derived and empty($supplier-release), 
            'Package is derived but no supplier release specified')"/>

        <!-- version and release check -->
        <!--<xsl:sequence select="imf:check-phase($this)"/>-->
        <xsl:sequence select="imf:check-release($this)"/>
       
        <!-- additional release checks -->
        <xsl:sequence select="imf:report-error(., 
            imvert:ref-release and not(matches(imvert:ref-release,$release-pattern)), 
            'Reference release must take the form YYYYMMDD')"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:base and (imvert:release lt imvert:base/imvert:release),
            'Client release date is before supplier release date.')"/>
        <xsl:sequence select="imf:report-warning(., 
            imvert:base and (imvert:phase gt imvert:base/imvert:phase),
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
        <xsl:variable name="is-internal" select="not(ancestor::imvert:package/imvert:stereotype/@id = ('stereotype-name-external-package','stereotype-name-internal-package','stereotype-name-system-package'))"/>
        <xsl:variable name="supertypes" select="imvert:supertype[not(imvert:stereotype/@id = ('stereotype-name-static-generalization'))]"/>
        <xsl:variable name="superclasses" select="imf:get-superclasses($this)"/>
        <xsl:variable name="subclasses" select="imf:get-subclasses($this)"/>
        <xsl:variable name="is-id" select="(.,$superclasses)/imvert:attributes/imvert:attribute/imvert:is-id = 'true'"/>
        <xsl:variable name="is-abstract" select="imvert:abstract = 'true'"/>
        <xsl:variable name="is-toplevel" select="imf:is-toplevel($this)"/>
        <xsl:variable name="is-association-class" select="$document-classes/imvert:associations/imvert:association/imvert:association-class/imvert:type-id = $this-id"/>
        <xsl:variable name="allow-multiple-supertypes" select="imf:boolean($configuration-metamodel-file//features/feature[@name='allow-multiple-supertypes'])"/>
        
        <!--validation-->
        <xsl:sequence select="imf:report-warning(., 
            not(imf:test-name-convention($this)), 
            'Class name does not obey convention')"/>
        <xsl:sequence select="imf:report-error(., 
            (count(../imvert:class/imvert:name[.=$this/imvert:name]) gt 1), 
            'Duplicate class name.')"/>

        <xsl:sequence select="imf:report-error(., 
            $supertypes[2] and not($allow-multiple-supertypes), 
            'Multiple supertypes are not supported.')"/>
        <xsl:sequence select="imf:report-error(., 
            $is-proper-class-tree and not(imf:check-inherited-stereotypes(.)), 
            'Stereotype of supertype not assigned to its subtype.')"/>
        <xsl:sequence select="imf:report-error(., 
            $is-proper-class-tree and not(imf:check-inheriting-stereotypes(.)), 
            'Stereotype of subtype not assigned to its supertype.')"/>
        <xsl:sequence select="imf:report-error(., 
            $is-proper-class-tree and not(imf:check-base-stereotypes(.)), 
            'Stereotype of base type not assigned to its subtype')"/>

        <xsl:sequence select="imf:report-error(., 
            (imvert:stereotype/@id = ('stereotype-name-union') and empty(imvert:attributes/imvert:attribute)), 
            'Empty union class is not allowed.')"/><!-- retain for historical purpose -->
        <xsl:sequence select="imf:report-error(., 
            (imvert:stereotype/@id = ('stereotype-name-union','stereotype-name-union-attributes') and count(imvert:attributes/imvert:attribute) lt 2), 
            'Union class with [1] attributes is not allowed.',count(imvert:attributes/imvert:attribute))"/>
        <xsl:sequence select="imf:report-error(., 
            (imvert:stereotype/@id = ('stereotyp    e-name-union-associations') and count(imvert:associations/imvert:association) lt 2), 
            'Union class with [1] association(s) is not allowed.',count(imvert:associations/imvert:association))"/>
        <xsl:sequence select="imf:report-error(., 
            (imvert:stereotype/@id = ('stereotype-name-union','stereotype-name-union-attributes') and exists(imvert:associations/imvert:association)), 
            'Association on union class is not allowed.')"/>
        <xsl:sequence select="imf:report-error(., 
            (imvert:stereotype/@id = ('stereotype-name-union','stereotype-name-union-associations') and exists(imvert:attributes/imvert:atribute)), 
            'Attribute on union class is not allowed.')"/>
        
        <xsl:sequence select="imf:report-error(., 
            not(ancestor::imvert:package/imvert:stereotype/@id = $schema-oriented-stereotypes), 
            'Classes found outside a domain, system or external package: [1]', imf:string-group(imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-message-package'))))"/>

        <!--Classes can only occur as part of a domain package, as only domain packages are transformed to XML schemas. If you want classes to be (temporarity) stored elsewhere, place move them to a <<recyclebin>> package.-->
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>
        
        <!--TODO CHECK VALIDATION OF MULTIPLE INHERITANCE
            <xsl:sequence select="imf:report-error(., count(imf:distinct($superclasses)) != count($superclasses), 'Multiple inheritance from same supertype')"/>
        -->
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype/@id = ('stereotype-name-union','stereotype-name-composite')) 
              and ((imvert:min-occurs and imvert:min-occurs != '1') or (imvert:max-occurs and imvert:max-occurs != '1')), 
            'Cardinality on class is ignored.')"/>
        
        <!-- IM-137 must check names of classes. Conventions for xRef and xAltRef -->
        <xsl:sequence select="imf:report-warning(., 
            imvert:stereotype/@id = ('stereotype-name-reference') and not(ends-with(imvert:name,'AltRef')), 
            'Class must end with string AltRef when a reference class.')"/>
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype/@id = ('stereotype-name-reference')) and ends-with(imvert:name,'AltRef'), 
            'Class may not end with string AltRef when not a reference class.')"/>
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype/@id = ('stereotype-name-reference','stereotype-name-system-reference-class')) and ends-with(imvert:name,'Ref'), 
            'Class may not end with string Ref when not a (system) reference class.')"/>
        
        <xsl:variable name="is-target-in-relation" select="imf:is-target-in-relation(.)"/>
        
        <!-- TODO het niet gebruikt zijn van een klasse is een zaak van configuratie: wat zijn de potentiele topconstructs? -->
        <xsl:sequence select="imf:report-warning(., 
            not($model-is-general) and
            $is-proper-class-tree and 
            $is-application and 
            not($is-toplevel) and not($is-abstract or $is-target-in-relation or $is-association-class), 
            'This [1] is not used.', if (exists(imvert:stereotype)) then imvert:stereotype else 'construct')"/>
        
        <xsl:sequence select="imf:report-warning(., 
            not($model-is-general) and
            $is-proper-class-tree and 
            $is-abstract and 
            empty($subclasses), 
            'Abstract class must have at least one subclass')"/>
        
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
            empty($package), 
            'Required supertype package is not included')"/>
        <xsl:sequence select="imf:report-error($class, 
            not($package/imvert:class/imvert:name=$super-name), 
            'Expected supertype class not defined')"/>
        <xsl:sequence select="imf:report-hint(., 
            not(imf:is-release-age-compatible(.)), 
            'One of the subtypes is in an earlier release')"/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-interface')]">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]">
        <!--setup-->
        <xsl:variable name="types" select="for $a in imvert:attributes/imvert:attribute return concat($a/imvert:type-package,'::',$a/imvert:type-name)"/>
        <xsl:variable name="types-are-scalars" select="exists(imvert:attributes/imvert:attribute[empty(imvert:type-id)])"/>
        <!--validation-->
        <xsl:sequence select="imf:report-error(.,
            not($allow-scalar-in-union) and $types-are-scalars, 
            'Union elements must not be a scalar')"/>
        <xsl:sequence select="imf:report-error(.,
            $allow-native-scalars and not($types-are-scalars) and count($types) ne count(distinct-values($types)), 
            'Union elements must all be of a different datatype')"/> <!-- TODO allow-native-scalars is een fix, feitelijk speelt dit voor primitives en scalars, zie #139, uitwerken en herimplementeren -->
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype')]">
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
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]">
        <!--setup-->
        <!--validation-->
        <xsl:sequence select="imf:report-error(.,
            empty(imvert:attributes/imvert:attribute), 
            'Datatypes with stereotype [1] must have attributes',imf:get-config-stereotypes('stereotype-name-complextype'))"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation='datatype']" priority="1">
        <!--setup-->
        <!--validation-->
        <xsl:for-each select="imvert:stereotype">
            <xsl:sequence select="imf:report-error(.., 
                not(@id = ($datatype-stereos)), 
                'UML datatypes should be stereotyped as: [1] and not [2]',(string-join(imf:get-config-stereotypes($datatype-stereos),' or '),imf:string-group(.)))"/>
        </xsl:for-each>
        <xsl:sequence select="imf:report-error(., 
            imvert:stereotype/@id = ('stereotype-name-simpletype') and imvert:attributes/imvert:attribute, 
            'Datatypes stereotyped as [1] may not have attributes',imf:string-group(imvert:stereotype))"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:associations/imvert:association, 
            'Datatypes may not have associations')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation='enumeration']" priority="1">
        <!--setup-->
        <!--validation-->
        <xsl:for-each select="imvert:stereotype">
            <xsl:sequence select="imf:report-error(.., 
                not(@id = ($enumeration-stereos)), 
                'UML enumerations should be stereotyped as: [1] and not [2]',(string-join(imf:get-config-stereotypes($enumeration-stereos),' or '),imf:string-group(.)))"/>
        </xsl:for-each>
        <xsl:sequence select="imf:report-error(., 
            imvert:associations/imvert:association, 
            'Enumerations may not have associations')"/>
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
        <xsl:variable name="is-enumeration" select="$class/imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist')"/>
        <xsl:variable name="baretype" select="imvert:baretype"/>
        <xsl:variable name="superclasses" select="imf:get-superclasses($class)"/>
        <xsl:variable name="is-abstract" select="imvert:abstract = 'true'"/>
        <xsl:variable name="stereos" select="('stereotype-name-objecttype','stereotype-name-referentielijst')"/>
        
        <xsl:variable name="is-designated-referentielijst" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-referentielijst')"/>
        <xsl:variable name="is-datatyped" select="
            $is-designated-referentielijst"/>
       
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
            (exists(imvert:type-id) and ($class/imvert:stereotype/@id = ('stereotype-name-union') and empty(imvert:type-package))), 
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
            imvert:pattern and exists($defining-class) and not($defining-class/imvert:stereotype/@id = (('stereotype-name-simpletype','stereotype-name-enumeration'))), 
            'A pattern as been defined on an attribute that is not a scalar type, datatype or enumeration')"/>
        -->
       
        <xsl:variable name="pat" select="imvert:pattern"/>
        <!-- redmine #489056 Formal pattern -->
        <xsl:variable name="pat-msg" select="if (normalize-space($pat)) then imf:validate-regex($pat) else ''"/>
        <xsl:sequence select="imf:report-error(., 
            normalize-space($pat-msg), 
            'Invalid regex [1]: [2]', ($pat, $pat-msg))"/>
  
        <xsl:sequence select="imf:report-error(., 
            (imvert:is-id = 'true' and empty($superclasses/imvert:stereotype/@id = ($stereos))), 
            'Only classes stereotyped as [1] may have or inherit an attribute that is an ID',string-join(for $s in $stereos return imf:get-config-stereotype-names($s),' or '))"/>
        <!--Task #487338, see also IM-371 teruggedraaid. -->
       
        <!-- Jira IM-419 -->
        <xsl:sequence select="imf:report-warning(., 
            $is-designated-referentielijst 
            and normalize-space(imf:get-tagged-value(.,'##CFG-TV-DATALOCATION'))
            and normalize-space(imf:get-tagged-value($defining-class,'##CFG-TV-DATALOCATION')), 
            '[1] has been specified on attribute as well as on [2]', ('Data location',$defining-class))"/>
        
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>
        
        <xsl:sequence select="imf:report-hint(., 
            not(imf:is-release-age-compatible(.)), 
            'Type is in a more recent release')"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist')]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <!--validation-->
        
        <xsl:sequence select="imf:report-warning(., 
            exists(imvert:baretype), 
            'Enumerative values should not be typed: [1]', (imvert:baretype))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype/@id = ('stereotype-name-union')]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        <!--validation-->
        <!--<xsl:sequence select="imf:report-error(., 
            not($defining-class), 
            'Union element has unknown type: [1]',imvert:type-name)"/>-->
        <xsl:sequence select="imf:report-error(., 
            not(imvert:stereotype/@id = ('stereotype-name-union-element')), 
            'Union element must be stereotyped as [1]',(imf:get-config-stereotypes('stereotype-name-union-element')))"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype/@id = ('stereotype-name-objecttype')]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        
        <!--validation-->
        
        <xsl:sequence select="imf:report-warning(., 
            imvert:stereotype/@id = 'stereotype-name-attribute' and $defining-class/imvert:designation = 'class', 
            '[1] type must be an UML datatype', imf:string-group(imf:get-config-stereotypes('stereotype-name-attribute'),' or '))"/>
        
        <xsl:sequence select="imf:report-warning(., 
            imvert:stereotype/@id = 'stereotype-name-attributegroup' and not($defining-class/imvert:designation = 'class'), 
            '[1] type must be an UML class', imf:string-group(imf:get-config-stereotypes('stereotype-name-attributegroup'),' or '))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype/@id = ('stereotype-name-composite','stereotype-name-complextype')]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        
        <xsl:sequence select="imf:report-error(., 
            $class/imvert:stereotype/@id = ('stereotype-name-complextype') and not(imvert:stereotype/@id = 'stereotype-name-data-element'), 
            '[1] must have attributes that are stereotyped as: [2]',(imf:get-config-stereotypes('stereotype-name-complextype'),imf:get-config-stereotypes('stereotype-name-data-element')))"/>
        
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
        <xsl:variable name="is-collection" select="$class/imvert:stereotype/@id = ('stereotype-name-collection')"/>
        <xsl:variable name="is-featurecollection" select="$class/imvert:stereotype/@id = ('stereotype-name-featurecollection')"/>
        <xsl:variable name="is-process" select="$class/imvert:stereotype/@id = ('stereotype-name-process')"/>
        <xsl:variable name="association-class-id" select="imvert:association-class/imvert:type-id"/>
        <xsl:variable name="property-names" select="$class/(imvert:atributes | imvert:associations)/*/imvert:name"/>
        <xsl:variable name="name" select="imvert:name"/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:variable name="defining-classes" select="($defining-class, imf:get-superclasses($defining-class))"/>
        <xsl:variable name="is-combined-identification" select="imf:get-tagged-value($this,'##CFG-TV=GECOMBINEERDEIDENTIFICATIE')"/>
        <xsl:variable name="target-navigable" select="imvert:target/imvert:navigable"/>
        <xsl:variable name="defining-class-is-group" select="$defining-class/imvert:stereotype/@id = ('stereotype-name-composite')"/>
        <xsl:variable name="meta-is-role-based" select="imf:boolean($configuration-metamodel-file//features/feature[@name='role-based'])"/>
        
        <xsl:variable name="applicable-name" select="if ($meta-is-role-based) then imvert:target/imvert:role else imvert:name"/>
            
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
            (not($is-collection) and not($is-process) and not($defining-class-is-group) and empty($association-class-id) and empty($applicable-name)), 
            'Association without name')"/>
        <xsl:sequence select="imf:report-error(., 
            not(imf:check-multiplicity(imvert:min-occurs,imvert:max-occurs)), 
            'Invalid target multiplicity')"/>
        
        <xsl:sequence select="imf:check-stereotype-assignment(.)"/>
        <xsl:sequence select="imf:check-tagged-value-multi(.)"/>
        <xsl:sequence select="imf:check-tagged-value-assignment(.)"/>
        
        <xsl:sequence select="imf:report-error(., 
            $superclasses/*/imvert:attribute/imvert:name=$name, 
            'Association already defined as attribute on supertype')"/>
        <xsl:sequence select="imf:report-error(., 
            $superclasses/*/imvert:association/imvert:name=$name, 
            'Association already defined on supertype')"/>
        
        <xsl:variable name="must-test-on-assoc" select="
            not($is-collection) 
            and not($is-featurecollection) 
            and $class/imvert:stereotype/@id = ('stereotype-name-objecttype') 
            and $defining-class/imvert:stereotype/@id = ('stereotype-name-objecttype')
            and not(imvert:stereotype/@id = ('stereotype-name-externekoppeling'))
            and empty(imvert:association-class)"/>
            
        <!-- IM-133 -->
        <xsl:sequence select="imf:report-error(., 
            $must-test-on-assoc
            and not($meta-is-role-based)
            and not(imvert:stereotype/@id = ('stereotype-name-relatiesoort')), 
            'Association to [1] must be stereotyped as [2]',(imf:get-config-stereotypes('stereotype-name-objecttype'),imf:get-config-stereotypes('stereotype-name-relatiesoort')))"/>
     
        <xsl:sequence select="imf:report-error(., 
            $must-test-on-assoc  
            and $meta-is-role-based
            and not(imvert:target/imvert:stereotype/@id = ('stereotype-name-relation-role')), 
            'Association role of [1] must be stereotyped as [2]',(imf:get-config-stereotypes('stereotype-name-objecttype'),imf:get-config-stereotypes('stereotype-name-relation-role')))"/>
        
        <xsl:sequence select="imf:report-error(., 
            $defining-class/imvert:stereotype/@id = ('stereotype-name-composite') and (number(imvert:max-occurs-source) ne 1), 
            'Invalid source multiplicity of composition relation: [1]', (imvert:max-occurs-source))"/>
        
        <!--
        <xsl:sequence select="imf:report-warning(., 
            $defining-class/imvert:stereotype/@id = ('stereotype-name-composite') and imf:boolean($target-navigable), 
            'Composition relation should not be navigable')"/>
        -->

        <xsl:sequence select="imf:report-warning(., 
            not($defining-class/imvert:stereotype/@id = ('stereotype-name-composite')) and imf:boolean(imvert:source/imvert:navigable), 
            'Source of any relation should not be navigable')"/>
        
        <xsl:sequence select="imf:report-error(., 
            (imvert:aggregation='aggregation' and not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))), 
            'Composite relation must be stereotyped as [1]', imf:get-config-stereotypes('stereotype-name-association-to-composite'))"/>
        
        <xsl:sequence select="imf:report-warning(., 
            $defining-class/imvert:stereotype/@id = ('stereotype-name-composite') 
            and imvert:stereotype
            and not(imvert:stereotype/@id = ('stereotype-name-voidable')) 
            and not(imvert:stereotype/@id = ('stereotype-name-association-to-composite','stereotype-name-relatiesoort')), 
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
        
        <xsl:sequence select="imf:report-error(., 
            count($property-display-names = imf:get-display-name(.)) gt 1, 
            'Multiple properties with same descriptor')"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:association">
        
        <xsl:sequence select="imf:report-error(., 
            imvert:direction = 'source', 
            'Association may not be directed from destination [1] to source',imf:get-display-name(imf:get-construct-by-id(imvert:type-id)))"/>
        
        <xsl:next-match/>  
    </xsl:template>
    
    <xsl:template match="imvert:position">
        <!--setup-->
        <xsl:variable name="position" select="."/>
        
        <!--validation-->
        <xsl:sequence select="imf:report-error(.., 
            not(matches($position,'^(\+|\-)?\d+$')), 
            'Position must be an integer value, found: [1]', $position)"/>
        
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
        <xsl:variable name="super" select="for $s in $supers return if ($s/imvert:stereotype/@id = ('stereotype-name-interface')) then () else $s"/>
        <xsl:choose>
            <xsl:when test="exists($super)">
                <xsl:variable name="results" as="xs:integer*">
                    <xsl:for-each select="$super/imvert:stereotype">
                        <xsl:choose>
                            <xsl:when test="not(@id = $copy-down-stereotypes-inheritance)"/>
                            <xsl:when test="$this/imvert:stereotype/@id = @id">1</xsl:when>
                            <xsl:when test="$this/imvert:stereotype/@id = ('stereotype-name-koppelklasse')">1</xsl:when>
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
        <xsl:variable name="super" select="for $s in $supers return if ($s/imvert:stereotype/@id = ('stereotype-name-interface')) then () else $s"/>
        <xsl:choose>
            <xsl:when test="exists($super)">
                <xsl:variable name="results" as="xs:integer*">
                    <xsl:for-each select="$copy-up-stereotypes-inheritance">
                        <xsl:variable name="stereo-id" select="."/>
                        <xsl:if test="$this/imvert:stereotype/@id = $stereo-id">
                            <xsl:value-of select="if ($super[not(imvert:stereotype/@id = $stereo-id)]) then 0 else 1"/>
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
            <xsl:for-each select="$base/imvert:stereotype/@id">
                <xsl:if test=". = $copy-down-stereotypes-realization">
                    <xsl:value-of select="if ($this/imvert:stereotype/@id = .) then 1 else 0"/>
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
        <xsl:variable name="client-phase" select="$client/imvert:phase"/>
        <xsl:variable name="supplier-phase" select="$supplier/imvert:phase"/>
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
    <!-- TODO alles op basis van stereo /@id inrichten -->
    <xsl:function name="imf:check-stereotype-assignment" as="element()*">
        <xsl:param name="this" as="element()"/> <!-- any element that may have stereotype -->
        <xsl:variable name="result" as="xs:string*">
            <xsl:for-each select="$this/imvert:stereotype">
                <xsl:variable name="stereotype" select="imf:get-normalized-name(.,'stereotype-name')"/>
                <xsl:choose>
                    <xsl:when test="@origin='system'"/>
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
                            <xsl:when test="$source-stereotype/@id = ('stereotype-name-relatieklasse') and not($stereotype)"/>
                            <xsl:when test="$target-stereotype/@id = ('stereotype-name-relatieklasse') and not($stereotype)"/>
                            <xsl:when test="$source-stereotype/@id = ('stereotype-name-objecttype') and not($stereotype)"/>
                            <xsl:when test="$target-stereotype/@id = ('stereotype-name-relatieklasse') and not($stereotype)"/>
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
        <xsl:sequence select="imf:report-warning($this, normalize-space($result[1]), 'Stereotype unexpected or unknown: [1]',imf:string-group($result))"/>
    </xsl:function>
    
    <!-- check if tagged values assigned are expected on this construct -->
    
    <xsl:variable name="config-tagged-values" select="imf:get-config-tagged-values()"/>
    
    <!-- 
        When testing for tagged value assignmnt is requested:
        
        Go through all tagged values, and check if it is a known (declared) tagged value. 
        If so, check if it allowed on this stereotype. If not, produce warning.
        If so, check if value is specified when required.
        If so, check if multiple declarations are allowed and found.
    -->
    <xsl:function name="imf:check-tagged-value-assignment" as="element()*">
        <xsl:param name="this" as="element()"/> <!-- any element that may have stereotype and tagged values-->
        
        <xsl:variable name="stereotype-ids" select="$this/imvert:stereotype/@id"/>
        <xsl:if test="$validate-tv-assignment">
            <xsl:for-each-group select="$this/imvert:tagged-values/imvert:tagged-value" group-by="@id">
                <xsl:variable name="first-in-group" select="."/>
                <xsl:variable name="group" select="current-group()"/>
                <xsl:for-each select="$group">
                    <xsl:variable name="id" select="@id"/>
                    <xsl:variable name="name" select="imvert:name"/>
                    <xsl:variable name="value" select="imvert:value"/>
                    
                    <xsl:variable name="declared" select="$config-tagged-values[@id = $id]"/>
                    
                    <xsl:variable name="value-derived" select="imf:boolean($declared/derive)"/>
                    
                    <xsl:variable name="minmax" select="tokenize($declared/stereotypes/stereo[@id = $stereotype-ids][1]/@minmax,'\.\.')"/>
                    <xsl:variable name="min" select="xs:integer(($minmax[1],'1')[1])"/>
                    <xsl:variable name="max" select="xs:integer(for $m in ($minmax[2],'1')[1] return if ($m = '*') then '1000' else $m)"/>
                    
                    <xsl:variable name="value-required" select="not($value-derived) and $min ge 1"/> <!--TODO test if derived value is actually available --> 
                    <xsl:variable name="value-max" select="not($value-derived) and $max ge 1"/> <!--TODO test if derived value is actually available --> 
                    
                    <xsl:variable name="value-listing" select="$declared/declared-values/value"/>
                    
                    <xsl:variable name="valid-for-stereotype" select="$declared/stereotypes/stereo/@id = $stereotype-ids"/>
                    <xsl:variable name="valid-omitted" select="empty($stereotype-ids) and $declared/stereotypes/stereo = $normalized-stereotype-none"/>
                    <xsl:variable name="valid-from-listing" select="$value = $value-listing"/>
                    
                    <xsl:variable name="is-first-in-group" select=". is $first-in-group"/>
                    
                    <xsl:choose>
                        <xsl:when test="@origin='notes'"><!-- reading notes field may result in a tagged value, that is therefore system generated. It does not have to be part of the metamodel tagged value set. -->
                            <!-- ignore -->
                        </xsl:when>
                        <xsl:when test="$is-first-in-group and empty($declared)">
                            <!-- an unknown tagged value, not configured anywhere -->
                            <xsl:sequence select="imf:report-warning($this, true(), 'Tagged value not expected or unknown: [1]',$name/@original)"/>
                        </xsl:when>
                        <xsl:when test="$is-first-in-group and not($valid-for-stereotype)">
                            <xsl:sequence select="imf:report-warning($this, true(), 'Tagged value [1] not expected on stereotype [2]',($name/@original,imf:string-group(for $s in $stereotype-ids return imf:get-config-name-by-id($s))))"/>
                        </xsl:when>
                        <xsl:when test="$is-first-in-group and $value-required and not(normalize-space($value))">
                            <xsl:sequence select="imf:report-error($this, true(), 'Tagged value [1] has no value',($name/@original))"/>
                        </xsl:when>
                        <xsl:when test="$value-max and count($group) gt $max">
                            <xsl:sequence select="imf:report-error($this, true(), 'Tagged value [1] occurs too often',($name/@original))"/>
                        </xsl:when>
                        <xsl:when test="exists($value-listing) and not($valid-from-listing)">
                            <xsl:sequence select="imf:report-error($this, true(), 'Tagged value [1] has undeclared value [2], allowed values are: [3]',($name/@original,imf:value-trim($value,80),imf:string-group($value-listing)))"/>
                        </xsl:when>
                        <xsl:when test="not($valid-omitted)">
                            <!-- okay, allowed -->
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each-group>
        </xsl:if>
        
    </xsl:function>

    <xsl:function name="imf:check-tagged-value-multi" as="element()*">
        <xsl:param name="this" as="element()"/> <!-- any element that may have tagged values-->
        <xsl:if test="not($allow-multiple-tv)">
            <xsl:for-each-group select="$this/imvert:tagged-values/imvert:tagged-value" group-by="imvert:name">
                <xsl:sequence select="imf:report-error($this, count(current-group()) gt 1, 'Duplicate tagged values: [1]',current-grouping-key())"/>
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
    
    <xsl:function name="imf:test-file-name-convention" as="xs:boolean">
        <xsl:param name="name" as="xs:string"/>
        <xsl:sequence select="matches($name,$file-name-requirements-pattern)"/>
    </xsl:function>
    
    <!-- 
        True if the release of the class which property is passed is newer than or equal to the release of the type 
        When the type release is not known, assume age compatibility. 
    -->
    <xsl:function name="imf:is-release-age-compatible" as="xs:boolean">
        <xsl:param name="property" as="element()"/>
        <xsl:variable name="this-release" select="$property/ancestor::imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package')][1]/imvert:release"/>
        <xsl:variable name="refed-type-id" select="$property/imvert:type-id"/>
        <xsl:variable name="refed-release" select="if ($refed-type-id) then imf:get-construct-by-id($refed-type-id)/ancestor::imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package') or imf:member-of(.,$external-package)][1]/imvert:release else '00000000'"/>
        <xsl:value-of select="if (($this-release ge $refed-release) or not($refed-release))  then true() else false()"/>
    </xsl:function>
    
    <!-- return the top package that this construct is part of. This is application, base or variant. --> 
    <!-- IM-91 -->
    <xsl:function name="imf:get-top-package" as="element()?">
        <xsl:param name="construct" as="element()?"/>
        <xsl:sequence select="$construct/ancestor-or-self::imvert:package[imvert:stereotype/@id = $top-package-stereotypes][1]"/>
    </xsl:function>

    <!-- return the external package that this construct is part of. This is system or external. --> 
    <!-- IM-91 -->
    <xsl:function name="imf:get-external-package" as="element()?">
        <xsl:param name="construct" as="element()?"/>
        <xsl:sequence select="$construct/ancestor-or-self::imvert:package[imf:member-of(.,$external-package)][1]"/>
    </xsl:function>
    
    <!-- return the internal package that this construct is part of. --> 
    <!-- REDMINE #487612 -->
    <xsl:function name="imf:get-internal-package" as="element()?">
        <xsl:param name="construct" as="element()?"/>
        <xsl:sequence select="$construct/ancestor-or-self::imvert:package[imf:member-of(.,$internal-package)][1]"/>
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
        <xsl:variable name="stereo-ids" select="$class/imvert:stereotype/@id"/>
        <xsl:sequence select="imf:get-config-stereotype-is-toplevel($stereo-ids)"/>
    </xsl:function>
     
    <xsl:function name="imf:is-known-baretype">
        <xsl:param name="name"/>
        <xsl:sequence select="$name = imf:get-config-scalar-names()"/>
    </xsl:function>
    
    <xsl:function name="imf:is-target-in-relation" as="xs:boolean">
        <xsl:param name="class"/>

        <xsl:variable name="this-id" select="$class/imvert:id"/>
        <xsl:variable name="is-used-type" select="$document-classes/imvert:attributes/imvert:attribute/imvert:type-id=$this-id"/>
        <xsl:variable name="is-used-ref" select="$document-classes/imvert:associations/imvert:association/imvert:type-id=$this-id"/>
       
        <xsl:variable name="superclass-is-target" select="imf:boolean-or((for $super-id in ($class/imvert:supertype/imvert:type-id) return imf:is-target-in-relation(imf:get-construct-by-id($super-id))))"/>
       <!-- <xsl:variable name="subclass-is-target" select="imf:boolean-or((for $sub in (imf:get-immediate-subclasses($class,$document-classes)) return imf:is-target-in-relation($sub)))"/> -->
       
        <xsl:sequence select="$is-used-type or $is-used-ref or $superclass-is-target "/><!-- TODO or $subclass-is-target -->
       
    </xsl:function>

    <xsl:function name="imf:check-proper-class-tree" as="xs:boolean*" >
        <xsl:param name="class" as="element(imvert:class)"/>
        <xsl:param name="found" as="xs:string+"/> <!-- start off with the ID of the class itself -->
        <xsl:variable name="super" select="$class/imvert:supertype"/>
        <xsl:choose>
            <xsl:when test="exists($super)">
                <xsl:for-each select="$super">
                    <xsl:variable name="name" select="string(imvert:type-name)"/>
                    <xsl:variable name="id" select="string(imvert:type-id)"/>
                    <xsl:variable name="construct" select="imf:get-construct-by-id($id)"/>
                    <xsl:choose>
                        <xsl:when test="$found = $id">
                            <xsl:sequence select="imf:report-error($class,
                                true(),
                                'Improper type hierarchy detected',())"/>
                            <xsl:sequence select="false()"/>
                        </xsl:when>
                        <xsl:when test="empty($construct)">
                            <xsl:sequence select="imf:report-error($class,
                                true(),
                                'Could not find supertype, name is [1]',($name))"/>
                            <xsl:sequence select="false()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:check-proper-class-tree($construct,($found, $id))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
   </xsl:function>
    
    <xsl:function name="imf:check-version">
        <xsl:param name="this"/>
        <xsl:variable name="cfg-version" select="$configuration-versionrules-file/version-rule/version"/>
        <xsl:variable name="cfg-version-pattern" select="$cfg-version/pattern"/>
        
        <xsl:sequence select="imf:report-error($this, 
            not(matches($this/imvert:version,$cfg-version-pattern)), 
            'Version [1] must take the form [2] consisting of [3]', ($this/imvert:version, imf:string-group($cfg-version/pattern), imf:string-group($cfg-version/fragment/name)))"/>
    </xsl:function>
  
    <xsl:function name="imf:check-phase">
        <xsl:param name="this"/>
        <xsl:variable name="cfg-phases" select="$configuration-versionrules-file/phase-rule/phase"/>
        <xsl:variable name="cfg-phase" select="$cfg-phases[level = $this/imvert:phase]"/>
        <xsl:variable name="phase-listing" select="for $p in $cfg-phases return concat($p/level,' (', $p/name, ')')"/>
        
        <xsl:sequence select="imf:report-error($this, 
            empty($cfg-phase), 
            'Phase [1] must be any of [2]', ($this/imvert:phase, imf:string-group($phase-listing)))"/>
    </xsl:function>
    
    <xsl:function name="imf:check-release">
        <xsl:param name="this"/>
        <xsl:sequence select="imf:report-error($this, 
            not(matches($this/imvert:release,$release-pattern)), 
            'Release must be specified and takes the form YYYYMMDD')"/>
    </xsl:function>
    
    <!-- return the elements that are considered to be duplicate of this element -->
    <xsl:function name="imf:check-unique-name" as="element()*">
        <xsl:param name="elements" as="element()*"/>
        <xsl:for-each-group select="$elements" group-by="imvert:name">
            <xsl:if test="current-group()[2]">
                <xsl:sequence select="current-group()"/>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:function>
    
    <xsl:function name="imf:check-primary-stereotypes">
        <xsl:param name="this"/>
        <xsl:variable name="stereo-ids" select="$this/imvert:stereotype/@id"/>
        <xsl:variable name="stereo-primary-ids" select="if (count($stereo-ids) gt 1) then (for $s in $stereo-ids return if (imf:get-config-stereotype-is-primary($s)) then $s else ()) else ()"/>
        <xsl:sequence select="imf:report-error($this, 
            (count($stereo-primary-ids) gt 1), 
            'Invalid combination of stereotypes: [1]', imf:string-group(for $s in $stereo-primary-ids return imf:get-config-name-by-id($s)))"/>
                    
    </xsl:function>
</xsl:stylesheet>
