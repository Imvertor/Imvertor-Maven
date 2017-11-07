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
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
    <!-- 
        This stylesheet pre-processes the UML:
          
        1/ Introduce subset info, when a construct is actually a subset 
          
    -->
    
    <xsl:variable name="metamodel" select="imf:extract-main-metamodel(/*)"/>
    
    <xsl:variable name="version" select="/imvert:packages/imvert:version"/> <!-- neem aan dat UGM versies van clients en suppliers gelijk oplopen, bijv. 0320  -->

    <xsl:template match="/imvert:packages">
        
        <!-- plaats alle subset info -->
        <xsl:variable name="cc1" as="node()*">
            <xsl:apply-templates/>
        </xsl:variable>
        
        <!-- maak zoveel packages als er target namespaces zijn; ieder imvert:package resulteert in een schema -->
        <xsl:variable name="cc2" as="element(imvert:package)*">
            <xsl:for-each-group select="$cc1/imvert:class" group-by="imvert:subset-info/imvert:effective-prefix">
                <xsl:variable name="prefix" select="current-grouping-key()"/>
                <imvert:package xsd-prefix="{$prefix}" xsd-version="{$version}" xsd-target-namespace="http://www.stufstandaarden.nl/basisschema/{$prefix}{$version}" >
                    <xsl:sequence select="current-group()"/>   
                </imvert:package>
            </xsl:for-each-group>
       </xsl:variable>
        
        <!-- Plaats binnen de packages de XSD import statements -->
        <xsl:variable name="cc3" as="node()*">
            <xsl:sequence select="$cc1[not(self::imvert:package)]"/>
            <xsl:for-each select="$cc2"> <!-- i.e. imvert:package elementen -->
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    
                    <!-- bepaal of ergens verwezen wordt naar een anders XSD --> 
                    <xsl:variable name="prefix" select="@xsd-prefix"/><!-- prefix van het importerende package -->
                    <xsl:variable name="referencing-ids" select=".//imvert:type-id"/> <!-- id's die mogelijk verwijzen naar een ander package -->
                    <xsl:variable name="referencing-packs" select="$cc2[self::imvert:package and .//imvert:id = $referencing-ids]"/><!-- alle packages waar naar verwezen wordt dus die mee moeten in de imports -->
                    <xsl:for-each select="$referencing-packs[@xsd-prefix ne $prefix]">
                        <imvert:xsd-import xsd-prefix="{@xsd-prefix}" xsd-version="{@xsd-version}" xsd-target-namespace="{@xsd-target-namespace}"/>
                    </xsl:for-each>
                    
                    <xsl:sequence select="node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        
        <imvert:packages>
            <xsl:sequence select="$cc3"/>
        </imvert:packages>
        
        <!-- set some info for access in later steps -->
        
        <xsl:sequence select="imf:set-config-string('appinfo','xsd-short-name',imf:get-tagged-value(.,'##CFG-TV-VERKORTEALIAS'))"/>
        <xsl:sequence select="imf:set-config-string('appinfo','xsd-version',imvert:version)"/>
        
        <xsl:variable name="supplier" select="imvert:supplier[imvert:supplier-project = current()/imvert:project]"/>
        <xsl:sequence select="imf:set-config-string('appinfo','subset-supplier-project',$supplier/imvert:supplier-project)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','subset-supplier-name',$supplier/imvert:supplier-name)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','subset-supplier-release',$supplier/imvert:supplier-release)"/>
        
    </xsl:template>
    
    <!-- 1  introduce subset information -->
    
    <xsl:template match="imvert:class">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:sequence select="imf:create-subset-info(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:association">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:sequence select="imf:create-subset-info(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:create-subset-info" as="element(imvert:subset-info)?">
        <xsl:param name="construct"/> <!-- a class or association -->
        
        <xsl:variable name="supplier-constructs" select="imf:get-supplier-constructs($construct)"/>
        <xsl:variable name="supplier-constructs-same-metamodel" select="$supplier-constructs[imf:extract-main-metamodel(.) = $metamodel]"/>
        <xsl:variable name="supplier-constructs-other-metamodel" select="$supplier-constructs except $supplier-constructs-same-metamodel"/>
        
        <xsl:variable name="client-label" select="imf:get-most-relevant-compiled-taggedvalue($construct,'##CFG-TV-SUBSETLABEL')"/>
        <xsl:variable name="client-prefix" select="imf:get-tagged-value(root($construct)/imvert:packages,'##CFG-TV-VERKORTEALIAS')"/>
        
        <xsl:variable name="label" as="xs:string">
            <xsl:choose>
                <xsl:when test="$construct/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')">
                    <!-- een gegevens groep -->
                    <xsl:value-of select="concat(imf:capitalize($construct/imvert:name),'Grp')"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- a class or an association -->
                    <xsl:value-of select="$construct/imvert:alias"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="empty($supplier-constructs)">
                <imvert:subset-info result="A">
                    <xsl:sequence select="imf:create-output-element('imvert:is-subsetting','false')"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-name',$label)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-prefix',$client-prefix)"/>
                </imvert:subset-info> 
            </xsl:when>
            <xsl:when test="exists($supplier-constructs-same-metamodel)">
                    
                <!-- is the construct a subset constructs? -->
                <xsl:variable name="supplier-prop" select="$supplier-constructs-same-metamodel/*/(imvert:attribute|imvert:association)/imvert:name"/>
                <xsl:variable name="client-prop" select="$construct/*/(imvert:attribute|imvert:association)/imvert:name"/>
                
                <xsl:variable name="supplier-additional-prop" select="functx:value-except($supplier-prop,$client-prop)"/>
                <xsl:variable name="client-additional-prop" select="functx:value-except($client-prop,$supplier-prop)"/>
                
                <xsl:variable name="is-subset" select="exists($supplier-additional-prop)"/>
                <xsl:variable name="is-restriction" select="$is-subset or $construct/self::imvert:association"/> <!-- associaties zijn altijd een subset -->
                
                <xsl:variable name="supplier-prefix" select="imf:get-tagged-value($supplier-constructs-same-metamodel[1]/ancestor::imvert:packages[last()],'##CFG-TV-VERKORTEALIAS')"/>
               
                <!-- Wanneer subset, dan NPS-btr ander NPS. Want het betreft hoe dan ook een link naar het supplier schema -->
                <xsl:variable name="effective-name" select="string-join(($label,if ($is-restriction) then $client-label else ()),'-')"/>
                
                <xsl:sequence select="imf:report-error($construct, 
                    exists($supplier-constructs-same-metamodel[2]), 
                    'Multiple potential subset constructs found: [1]',imf:string-group($supplier-constructs-same-metamodel/imvert:name))"/>
                
                <xsl:sequence select="imf:report-error($construct, 
                    exists($client-additional-prop), 
                    'Subset classes may not introduce attributes or associations: [1]',$client-additional-prop)"/>
                
                <xsl:sequence select="imf:report-error($construct, 
                    $is-restriction and empty($client-label), 
                    'Tagged value [1] for this subset not specified',imf:get-config-name-by-id('CFG-TV-SUBSETLABEL'))"/>
                
                <imvert:subset-info result="B">
                    <xsl:sequence select="imf:create-output-element('imvert:is-subsetting','true')"/>
                    <xsl:sequence select="imf:create-output-element('imvert:is-subset-class','true')"/>
                    <xsl:sequence select="imf:create-output-element('imvert:is-restriction-class',$is-restriction)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:client-label',$client-label)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:supplier-label',$label)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:client-prefix',$client-prefix)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:supplier-prefix',$supplier-prefix)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-name',$effective-name)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-prefix',$supplier-prefix)"/>
                </imvert:subset-info>
                
            </xsl:when>
            <xsl:when test="exists($supplier-constructs-other-metamodel)">
                <!-- generereer géén subset info want het betreft UGM naar SIM connectie -->
                <imvert:subset-info result="C">
                    <xsl:sequence select="imf:create-output-element('imvert:is-subsetting','false')"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-name',$label)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-prefix',$client-prefix)"/>
                </imvert:subset-info> 
            </xsl:when>
            <xsl:otherwise>
                <imvert:subset-info result="D">
                    <xsl:sequence select="imf:create-output-element('imvert:is-subsetting','true')"/>
                    <xsl:sequence select="imf:create-output-element('imvert:is-subset-class','false')"/>
                    <xsl:sequence select="imf:create-output-element('imvert:is-restriction-class','false')"/>
                    <xsl:sequence select="imf:create-output-element('imvert:client-prefix',$client-prefix)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-name',$label)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:effective-prefix',$client-prefix)"/>
                </imvert:subset-info>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:capitalize">
        <xsl:param name="name"/>
        <xsl:value-of select="concat(upper-case(substring($name,1,1)),substring($name,2))"/>
    </xsl:function>
    
    
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
