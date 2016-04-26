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
        Transform the imvert information to an application by merging the layers.
     -->
    
    <!-- TODO IM-70 Wrapper elementen in XSD voor datacollecties toestaan -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable 
        name="external-packages" 
        select="//imvert:package[ancestor-or-self::imvert:package/imvert:stereotype=(imf:get-config-stereotypes(('stereotype-name-external-package','stereotype-name-system-package')))]" 
        as="node()*"/>
    
    <xsl:variable 
        name="application-package" 
        select="//imvert:package[
          imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-base-package','stereotype-name-application-package'))
          and 
          imvert:name/@original=$application-package-name][1]"/>
    
    <!-- override document packages by the packages in the application tree -->
    <xsl:variable 
        name="document-packages" 
        select="($external-packages, $application-package/descendant-or-self::imvert:package)"
        as="node()*"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            
            <xsl:variable name="intro" select="*[not(self::imvert:package)]"/>
            <xsl:apply-templates select="$intro" mode="finalize"/>
            
            <xsl:sequence select="imf:compile-imvert-filter()"/>
            
            <xsl:sequence select="$application-package/imvert:supplier-project"/>
            <xsl:sequence select="$application-package/imvert:supplier-name"/>
            <xsl:sequence select="$application-package/imvert:supplier-release"/>
            <xsl:sequence select="$application-package/imvert:stereotype"/>
            
            <xsl:variable name="result-packages" as="node()*">
                <!-- verwerk alle subpackages van de gekozen parent package bijv. VariantX of ApplicationY -->
                <xsl:apply-templates select="$application-package/imvert:package"/>
            </xsl:variable>
            <xsl:apply-templates select="$result-packages" mode="finalize"/>
            
            <!-- if any type is taken from an external package, or if it is a system package, import that external package -->
            <xsl:variable name="result-external-packages" as="node()*">
                <xsl:for-each-group select="$external-packages[(imvert:class/imvert:id = $result-packages//(imvert:type-id | imvert:supertype/imvert:type-id)) or imvert:stereotype=imf:get-config-stereotypes('stereotype-name-system-package')]" group-by="imvert:id">
                    <xsl:sequence select="."/>
                </xsl:for-each-group>
            </xsl:variable>
            <xsl:apply-templates select="$result-external-packages" mode="finalize"/>
            
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-product','stereotype-name-process','stereotype-name-service'))]">
        <xsl:variable name="collection-name" select="concat(imvert:name,imf:get-config-parameter('imvertor-translate-suffix-components'))"/>
        <xsl:variable name="collection-id" select="concat('collection_', generate-id(.))"/>
        <xsl:variable name="collection-package-name" select="../imvert:name"/>
        <xsl:variable name="collection-class" as="element()?">
            <!-- when no collection type class referenced, roll your own --> 
            <!-- IM-110 but only when buildcollection yes -->
            <xsl:if test="imf:boolean($buildcollection)">
                <xsl:if test="not(imvert:associations/imvert:association/imvert:type-id[imf:get-construct-by-id(.)/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-collection')])">
                    <xsl:sequence select="imf:msg('INFO','Catalog class [1] ([2]) does not include any collection. Appending [3].', (string(imf:get-construct-name(.)), string-join(imvert:stereotype,', '),$collection-name))"/>
                    <imvert:class>
                        <xsl:sequence select="imf:create-output-element('imvert:id',$collection-id)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:name',$collection-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:stereotype',imf:get-config-stereotypes('stereotype-name-collection'))"/>
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
                    </imvert:class>
                </xsl:if>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="super-classes" select="imf:get-superclasses(.)"/>
        <xsl:variable name="super-products" select="$super-classes[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-product','stereotype-name-process','stereotype-name-service'))]"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:sequence select="*[not(self::imvert:associations)]"/>
            <imvert:associations>
                <xsl:sequence select="imvert:associations/imvert:association"/>
                <!-- 
                    IM-136 
                    alleen deze constructie als geen subtype van een ander product.
                -->
                <xsl:if test="$collection-class and empty($super-products)">
                    <imvert:association>
                        <xsl:sequence select="imf:create-output-element('imvert:name',imf:get-config-parameter('imvertor-translate-association-components'))"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-name',$collection-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-id',$collection-id)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type-package',$collection-package-name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:min-occurs','1')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:max-occurs','1')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:position','999')"/>
                    </imvert:association>
                </xsl:if>
            </imvert:associations>
        </xsl:copy>
            
        <xsl:sequence select="$collection-class"/>
    </xsl:template>
    
    
    <!-- finalization: add some info to the compiled document fragment -->
    
    <xsl:template match="*" mode="finalize">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="finalize"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:type-id" mode="finalize">
        <xsl:copy-of select="."/>
        <xsl:if test="not(../imvert:type-package)">
            <xsl:variable name="id" select="imf:get-package-id(.)"/>
            <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-construct-by-id($id)/imvert:name)"/>  
            <xsl:sequence select="imf:create-output-element('imvert:type-package-id',$id)"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="imvert:supertype/imvert:type-id" mode="finalize">
        <xsl:copy-of select="."/>
        <xsl:if test="not(../imvert:type-package)">
            <xsl:variable name="id" select="imf:get-package-id(.)"/>
            <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-construct-by-id($id)/imvert:name)"/>  
            <xsl:sequence select="imf:create-output-element('imvert:type-package-id',$id)"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="finalize">
        <xsl:copy>
            <xsl:apply-templates select="*[not(self::imvert:class)]" mode="finalize"/>
            <xsl:apply-templates select="ancestor::imvert:package/imvert:stereotype" mode="finalize"/>
            <xsl:apply-templates select="imvert:class" mode="finalize"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- get the ID of the package that defines the type with the ID passed -->
    <xsl:function name="imf:get-package-id" as="xs:string">
        <xsl:param name="type-id" as="xs:string?"/>
        <xsl:variable name="class" select="$document//*[imvert:id=$type-id]"/>
        <xsl:value-of select="$class/../imvert:id"/>
    </xsl:function>
    
    
    <?x geen varianten meer
        
    <!-- 
        Deze template wordt alleen bereik door supplier classes bij het doorwerken van varianten (<<variant>>).
        
        Kijk of voor deze supplier class een gelijk genoemde client class bestaat. 
        In dat geval, check wat de aanpassing is.
        Zo niet, maar dan een kopie; hij wordt overgenomen uit dat package.
    -->
    <!-- for <<variant>> -->
    <xsl:template match="imvert:class"> 
        <xsl:param name="client-classes"/> <!-- dit zijn alle variant- of application-classes -->
        <xsl:variable name="this" select="."/> <!-- dit is altijd een supplier class -->
        <xsl:variable name="client-class" select="if ($client-classes) then $client-classes[imvert:name=$this/imvert:name] else ()"/>
        <xsl:choose>
            <xsl:when test="$client-class">
                <xsl:choose>
                    <!-- For any class, when variant <<variant-remove>>, skip it.  -->
                    <xsl:when test="$client-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-variant-remove')">
                        <xsl:sequence select="imf:msg(.,'STATUS',concat('Class removed: ',imvert:name))"/>               
                    </xsl:when>
                    <xsl:when test="$client-class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-variant-redefine')">
                        <xsl:sequence select="imf:msg(.,'STATUS',concat('Class redefined: ',imvert:name))"/>               
                        <xsl:sequence select="$client-class"/> 
                        <!-- TODO enhance / merge documentation -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:msg(.,'STATUS',concat('Class altered: ',imvert:name))"/>               
                        <imvert:class>
                            <xsl:sequence select="imf:filter-descriptive-elements($client-class/*)"/>
                            <xsl:sequence select="imf:merge-documentation($client-class)"/> 
                            <xsl:sequence select="imf:client-supers($this,$client-class)"/>
                            <imvert:base>
                                <xsl:sequence select="imf:filter-descriptive-elements($this/*)" />
                            </imvert:base>
                            <imvert:attributes>
                                <xsl:sequence select="imf:client-properties($this/imvert:attributes/imvert:attribute,$client-class/imvert:attributes/imvert:attribute)"/>
                            </imvert:attributes>
                            <imvert:associations>
                                <xsl:sequence select="imf:client-properties($this/imvert:associations/imvert:association,$client-class/imvert:associations/imvert:association)"/>
                            </imvert:associations>
                        </imvert:class>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg(.,'STATUS',concat('Class copied: ',imvert:name))"/>               
                <xsl:sequence select="$this"/>
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <!-- determine whether this class is part of variant without an equivalent in base. In that case it is entirely new. -->
    <!-- for <<variant>> -->
    <xsl:template match="imvert:class" mode="newclass">
        <xsl:param name="supplier-classes" as="node()*"/>
        <xsl:variable name="this" select="."/>
        <xsl:choose>
            <xsl:when test="$supplier-classes[imvert:name=$this/imvert:name]">
                <!-- a pareht extsts, so do not copy here; it is processed already. -->
            </xsl:when>
            <xsl:otherwise>
                <!-- make a copy -->
                <xsl:sequence select="imf:msg(.,'STATUS',concat('Class copied: ',imvert:name))"/>               
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="imf:client-properties" as="node()*">
        <xsl:param name="supplier-properties" as="node()*"/> <!-- dit zijn alle properties van de supplier -->
        <xsl:param name="client-properties" as="node()*"/> <!-- dit zijn alle properties van de client-->
        <xsl:variable name="proptype" select="if ($supplier-properties[1]/self::imvert:attribute) then 'Attribute' else 'Association'"/>
        
        <xsl:for-each select="$supplier-properties">
            <xsl:variable name="this" select="."/>
            <xsl:variable name="variant" select="$client-properties[imvert:name=$this/imvert:name]"/>
            <xsl:choose>
                <xsl:when test="$variant">
                    <xsl:choose>
                        <!-- Voor iedere base attribute, als variant <<variant-remove>>, sla over.  -->
                        <xsl:when test="$variant/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-variant-remove')">
                            <xsl:sequence select="imf:msg(.,'STATUS',concat('Property removed: ',imvert:name))"/>               
                        </xsl:when>
                        <!-- voor iedere base attribute, als variant <<variant-redefine>>, neem variant definitie over -->
                        <xsl:when test="$variant/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-variant-redefine')">
                            <xsl:sequence select="imf:msg(.,'STATUS',concat('Property redefined: ',imvert:name))"/>               
                            <xsl:sequence select="$variant"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg('STATUS','Property already defined for base, but no variant stereotype specified.')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- voor iedere andere base attribute, neem over  -->
                    <xsl:sequence select="imf:msg(.,'STATUS',concat('Property copied: ',imvert:name))"/>               
                    <xsl:sequence select="$this"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!-- neem andere props over als die niet in base voorkomen. Worden altijd aan het einde opgenomen. -->
        <xsl:for-each select="$client-properties[not(imvert:name = $supplier-properties/imvert:name)]">
            <xsl:sequence select="imf:msg(.,'STATUS',concat($proptype,' ', imvert:name, ' created'))"/>               
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:function>

    <!-- return the supertype specifications for the client, based on the specs for the supplier -->
    <xsl:function name="imf:client-supers" as="node()*">
        <xsl:param name="supplier" as="node()"/>
        <xsl:param name="client" as="node()"/>
        <!-- return client's supertypes -->
        <xsl:sequence select="$client/imvert:supertype"/>
        <!-- and add supertypes of supplier if any new ones -->
        <xsl:sequence select="$supplier/imvert:supertype[not($client/imvert:supertype/imvert:type-name=imvert:type-name)]"/>
    </xsl:function>
    
    <xsl:function name="imf:filter-descriptive-elements" as="node()*">
        <xsl:param name="this" as="node()*"/>
        <xsl:sequence select="$this[not(self::imvert:documentation or self::imvert:attributes or self::imvert:associations or self::imvert:class or self::imvert:package or self::imvert:supertype)]"/>
    </xsl:function>
    
    <!-- 
        merge the documentation of two constructs (package, class, attribut an so on), 
        and insert a marker between the two texts if needed to signal what the origin of the text is 
    -->
    <xsl:function name="imf:merge-documentation" as="element()">
        <xsl:param name="client" as="node()?"/> <!-- any node that has documentation -->
        <xsl:variable name="hierarchy" as="node()*">
            <xsl:choose>
                <xsl:when test="$client/self::imvert:package">
                    <xsl:sequence select="imf:build-client-package-hierarchy($client)"/>
                </xsl:when>
                <xsl:when test="$client/self::imvert:class">
                    <xsl:sequence select="imf:build-client-class-hierarchy($client)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:build-client-property-hierarchy($client)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="text" as="element()*">
            <xsl:for-each select="reverse($hierarchy)">
                <xsl:variable name="client-package" select="ancestor-or-self::imvert:package[last()]/imvert:name"/>
                <xsl:if test="normalize-space(imvert:documentation) and not($client-package/../imvert:stereotype=imf:get-config-stereotypes('stereotype-name-base-package'))">
                    <imvert:p>
                        <xsl:value-of select="concat('[',$client-package,']')"/>
                    </imvert:p>
                </xsl:if>
                <xsl:sequence select="imvert:documentation"/>
            </xsl:for-each>
        </xsl:variable>
        <imvert:documentation>
            <xsl:sequence select="$text"/>
        </imvert:documentation>
    </xsl:function>
    
    <xsl:function name="imf:get-package-by-namespace" as="node()">
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:sequence select="$document-packages[imvert:namespace=$namespace]"/>
    </xsl:function>

    <xsl:function name="imf:build-client-package-hierarchy" as="node()*">
        <xsl:param name="client-package" as="node()"/> <!-- a imvert:package within a base, variant or appplication package -->
        <xsl:sequence select="$client-package"/>
        <xsl:variable name="supplier-package-id" select="$client-package/../imvert:used-package-id"/>
        <xsl:if test="$supplier-package-id">
            <xsl:variable name="supplier-package" select="$document-packages[imvert:name=$client-package/imvert:name and ../imvert:id=$supplier-package-id]"/>
            <xsl:sequence select="imf:build-client-package-hierarchy($supplier-package)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:build-client-class-hierarchy" as="node()*">
        <xsl:param name="client" as="node()"/> <!-- a imvert:class -->
        <xsl:variable name="client-package" select="$client/.."/>
        <xsl:variable name="packages" select="imf:build-client-package-hierarchy($client-package)"/>
        <xsl:sequence select="$packages/imvert:class[imvert:name=$client/imvert:name]"/>
    </xsl:function>
    
    <xsl:function name="imf:build-client-property-hierarchy" as="node()*">
        <xsl:param name="client" as="node()"/> <!-- a imvert:attribute or association -->
        <xsl:variable name="client-class" select="$client/../.."/>
        <xsl:variable name="client-package" select="$client-class/.."/>
        <xsl:variable name="packages" select="imf:build-client-package-hierarchy($client-package)"/>
        <xsl:sequence select="$packages/imvert:class[imvert:name=$client-class/imvert:name]/(imvert:attributes/imvert:attribute|imvert:associations/imvert:association)[imvert:name=$client/imvert:name]"/>
    </xsl:function>
    ?>
    
</xsl:stylesheet>
