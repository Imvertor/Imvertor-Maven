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
    
    xmlns:dfx="http://www.topologi.com/2005/Diff-X" 
    xmlns:del="http://www.topologi.com/2005/Diff-X/Delete" 
    xmlns:ins="http://www.topologi.com/2005/Diff-X/Insert"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
        Compare two Imvert result files on all aspects except technical stuff.
       
        Actually based on 
        http://www.imvertor.org/schema/imvertor/application/v20160201
        but anonymized.
        
        See Jira IM-196 for explanation of approach. 
    -->
    
    <!-- TODO Check if all constructs have been made part of the compare simplified formt. -->
   
    <xsl:import href="Imvert2compare-common.xsl"/>
    
    <xsl:output indent="no"/>
    
      <xsl:variable name="sep">-</xsl:variable>
    
    <!-- create to representations, removing all documentation level elements -->
    <xsl:template match="/">
        <xsl:variable name="all">
            <xsl:apply-templates/>
        </xsl:variable>
        <root-of-compare role="{$comparison-role}">
            <xsl:apply-templates select="$all" mode="nonempty"/> <!-- remove all elements that have no content --> 
        </root-of-compare>
        <!-- no create a listing of element names and original names, used in reporting -->
        <xsl:variable name="fn" select="if ($comparison-role = 'ctrl') then $ctrl-name-mapping-filepath else $test-name-mapping-filepath"/>
        <xsl:result-document href="{$fn}">
            <maps>
                <xsl:apply-templates select="//(*:Application | *:Package | *:Class | *:Attribute | *:Association)" mode="name-mapping"/>
                <xsl:for-each-group select="//*:TaggedValue" group-by="*:name">
                    <xsl:apply-templates select="current-group()[1]" mode="name-mapping"/>
                </xsl:for-each-group>
            </maps>
        </xsl:result-document>
    </xsl:template>
    
    <!-- packages, classes, attributes and relations are wrapped within an element with the name of the package, class... etc -->  
    <xsl:template match="*:Application | *:Package | *:Class | *:Attribute | *:Association">
        <xsl:element name="{imf:get-safe-name(.)}">
            <xsl:attribute name="display" select="imf:get-name(.)"/>
            <xsl:next-match/>
        </xsl:element>
        <xsl:for-each select="*:packages/*:Package">
            <xsl:sort select="imf:get-safe-name(.)"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="*:classes/*:Class">
            <xsl:sort select="imf:get-safe-name(.)"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="*:attributes/*:Attribute">
            <xsl:sort select="imf:get-safe-name(.)"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:for-each select="*:associations/*:Association">
            <xsl:sort select="imf:get-safe-name(.)"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:choose>
            <!-- per type -->
            <xsl:when test="self::*:Application">
                <compos>
                    <xsl:value-of select="imf:get-compos-name(.)"/>
                </compos>
                <xsl:sequence select="imf:fetch-local-application(.)"/>
                
                <xsl:sequence select="imf:fetch-identification(.)"/>
                <xsl:sequence select="imf:fetch-svn(.)"/>
                <xsl:sequence select="imf:fetch-release(.)"/>
                <xsl:sequence select="imf:fetch-derivation(.)"/>
                <xsl:sequence select="imf:fetch-tagged(.)"/>
               
            </xsl:when>
            <xsl:when test="self::*:Package">
                <compos>
                    <xsl:value-of select="imf:get-compos-name(.)"/>
                </compos>
                <xsl:sequence select="imf:fetch-local-package(.)"/>
                
                <xsl:sequence select="imf:fetch-identification(.)"/>
                <xsl:sequence select="imf:fetch-svn(.)"/>
                <xsl:sequence select="imf:fetch-release(.)"/>
                <xsl:sequence select="imf:fetch-referencing(.)"/>
                <xsl:sequence select="imf:fetch-derivation(.)"/>
                <xsl:sequence select="imf:fetch-conceptual(.)"/>
                <xsl:sequence select="imf:fetch-tagged(.)"/>
                
            </xsl:when>
            <xsl:when test="self::*:Class">
                <compos>
                    <xsl:value-of select="imf:get-compos-name(.)"/>
                </compos>
                <xsl:sequence select="imf:fetch-local-class(.)"/>
                
                <xsl:sequence select="imf:fetch-identification(.)"/>
                <xsl:sequence select="imf:fetch-release(.)"/>
                <xsl:sequence select="imf:fetch-derivation(.)"/>
                <xsl:sequence select="imf:fetch-tagged(.)"/>
                
            </xsl:when>
            <xsl:when test="self::*:Attribute">
                <compos>
                    <xsl:value-of select="imf:get-compos-name(.)"/>
                </compos>
                <xsl:sequence select="imf:fetch-local-attribute(.)"/>
                
                <xsl:sequence select="imf:fetch-identification(.)"/>
                <xsl:sequence select="imf:fetch-release(.)"/>
                <xsl:sequence select="imf:fetch-derivation(.)"/>
                <xsl:sequence select="imf:fetch-type(.)"/>
                <xsl:sequence select="imf:fetch-cardinality(.)"/>
                <xsl:sequence select="imf:fetch-tagged(.)"/>
            </xsl:when>
            <xsl:when test="self::*:Association">
                <compos>
                    <xsl:value-of select="imf:get-compos-name(.)"/>
                </compos>
                <xsl:sequence select="imf:fetch-local-association(.)"/>
                
                <xsl:sequence select="imf:fetch-identification(.)"/>
                <xsl:sequence select="imf:fetch-release(.)"/>
                <xsl:sequence select="imf:fetch-derivation(.)"/>
                <xsl:sequence select="imf:fetch-type(.)"/>
                <xsl:sequence select="imf:fetch-cardinality(.)"/>
                <xsl:sequence select="imf:fetch-tagged(.)"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template match="*" mode="nonempty">
        <xsl:choose>
            <xsl:when test=".//text()">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates mode="nonempty"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- ignore -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="processing-instruction()|comment()">
        <!-- ignore -->
    </xsl:template>

    <xsl:function name="imf:create-display-name">
        <xsl:param name="this"/>
        <xsl:variable name="att" select="imf:get-name($this/ancestor-or-self::*:Attribute[1])"/>
        <xsl:variable name="ass" select="imf:get-name($this/ancestor-or-self::*:Association[1])"/>
        <xsl:variable name="cls" select="imf:get-name($this/ancestor-or-self::*:Class[1])"/>
        <xsl:variable name="pkg" select="imf:get-name($this/ancestor-or-self::*:Package[1])"/>
        <xsl:choose>
            <xsl:when test="$att != ''">
                <xsl:value-of select="concat($pkg,'.',$cls,'.',$att,' (attrib)')"/>
            </xsl:when>
            <xsl:when test="$ass != ''">
                <xsl:value-of select="concat($pkg,'.',$cls,'.',$ass,' (assoc)')"/>
            </xsl:when>
            <xsl:when test="$cls != ''">
                <xsl:value-of select="concat($pkg,'.',$cls)"/>
            </xsl:when>
            <xsl:when test="$pkg != ''">
                <xsl:value-of select="$pkg"/>
            </xsl:when>
            <xsl:otherwise>AAROOT</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-name">
        <xsl:param name="this"/>
        <xsl:value-of select="for $n in ($this/*:identification/*:Identifiable) return ($n/*:originalName,$n/*:name)[1]"/>
    </xsl:function>
    <xsl:function name="imf:get-safe-name">
        <xsl:param name="this"/>
        <xsl:choose>
            <xsl:when test="$identify-construct-by-function = 'name'">
                <xsl:value-of select="imf:get-compos-name($this)"/>
            </xsl:when>
            <xsl:when test="$identify-construct-by-function = 'id'">
                <xsl:variable name="id" select="$this/*:identification/*:Identifiable/*:id"/>
                <xsl:value-of select="concat('I',$sep,imf:get-safe-string($id))"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-safe-string">
        <xsl:param name="string"/>
        <xsl:value-of select="replace($string,'[^A-Za-z0-9_]+',$sep)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-compos-name" as="xs:string">
        <xsl:param name="this"/>
        <xsl:variable name="name" select="imf:create-display-name($this)"/>
        <xsl:value-of select="concat('N',$sep,imf:get-safe-string($name))"/>
    </xsl:function>
    <!-- 
        thematische functies, gegeven exact af wat er moet worden vergeleken. 
    -->
    
    <xsl:function name="imf:fetch-identification">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:identification/*:Identifiable">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:id)"/>
            <xsl:sequence select="imf:create-row(*:name)"/>
            <xsl:sequence select="imf:create-row(*:originalName)"/>
            <xsl:sequence select="imf:create-row(*:shortName)"/>
            <xsl:sequence select="imf:create-row(*:alias)"/>
            <xsl:sequence select="imf:create-row(*:namespace)"/>
            <xsl:sequence select="imf:create-row(*:stereotype)"/>
            <xsl:sequence select="imf:create-row(*:trace)"/>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="imf:fetch-release">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:release/*:Released">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:documentation)"/>
            <xsl:sequence select="imf:create-row(*:author)"/>
            <xsl:sequence select="imf:create-row(*:created)"/>
            <xsl:sequence select="imf:create-row(*:modified)"/>
            <xsl:sequence select="imf:create-row(*:version)"/>
            <xsl:sequence select="imf:create-row(*:phase)"/>
            <xsl:sequence select="imf:create-row(*:release)"/>
            <xsl:sequence select="imf:create-row(*:webLocation)"/>
            <xsl:sequence select="imf:create-row(*:location)"/>
            <!-- TODO concepts -->
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-referencing">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:reference/*:Referencing">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:refVersion)"/>
            <xsl:sequence select="imf:create-row(*:refRelease)"/>
            <xsl:sequence select="imf:create-row(*:refMaster)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-derivation">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:derivation/*:Derivable">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:derived)"/>
            <xsl:sequence select="imf:create-row(*:metamodel)"/>
            <xsl:sequence select="imf:create-row(*:supplierProject)"/>
            <xsl:sequence select="imf:create-row(*:supplierName)"/>
            <xsl:sequence select="imf:create-row(*:supplierRelease)"/>
            <xsl:sequence select="imf:create-row(*:supplierPackageName)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-type">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:type/*:Type">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:typeName)"/>
            <xsl:sequence select="imf:create-row(*:typeId)"/>
            <xsl:sequence select="imf:create-row(*:typePackage)"/>
            <xsl:sequence select="imf:create-row(*:typePackageId)"/>
            <xsl:sequence select="imf:create-row(*:baretype)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-cardinality">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:cardinality/*:Cardinal">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:minOccurs)"/>
            <xsl:sequence select="imf:create-row(*:maxOccurs)"/>
            <xsl:sequence select="imf:create-row(*:minOccursSource)"/>
            <xsl:sequence select="imf:create-row(*:maxOccursSource)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-tagged">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:tags">
            <!-- only one -->
            <xsl:for-each select="*:TaggedValue">
                <xsl:sort select="*:name"/>
                <xsl:element name="{ concat('tv_',imf:get-safe-string(*:name)) }">
                    <xsl:value-of select="*:value"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-conceptual">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:conceptual/*:Conceptual">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:conceptualSchemaNamespace)"/>
            <xsl:sequence select="imf:create-row(*:conceptualSchemaVersion)"/>
            <xsl:sequence select="imf:create-row(*:conceptualSchemaPhase)"/>
            <xsl:sequence select="imf:create-row(*:conceptualSchemaAuthor)"/>
            <xsl:sequence select="imf:create-row(*:conceptualSchemaSvnString)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-svn">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/*:version/*:Svn">
            <!-- only one -->
            <xsl:sequence select="imf:create-row(*:svnAuthor)"/>
            <xsl:sequence select="imf:create-row(*:svnFile)"/>
            <xsl:sequence select="imf:create-row(*:svnRevision)"/>
            <xsl:sequence select="imf:create-row(*:svnDate)"/>
            <xsl:sequence select="imf:create-row(*:svnTime)"/>
            <xsl:sequence select="imf:create-row(*:svnUser)"/>
        </xsl:for-each>
        
    </xsl:function>

    <!-- local for application, package, class, attriute or association -->
    <xsl:function name="imf:fetch-local-application">
        <xsl:param name="this"/>
        <xsl:sequence select="imf:create-application-name($this)"/>

        <xsl:sequence select="imf:create-row($this/*:project)"/>
        <xsl:sequence select="imf:create-row($this/*:generated)"/>
        <xsl:sequence select="imf:create-row($this/*:generator)"/>
        <xsl:sequence select="imf:create-row($this/*:exported)"/>
        <xsl:sequence select="imf:create-row($this/*:exporter)"/>
        <xsl:sequence select="imf:create-row($this/*:localSchemaSvnId)"/>
        <xsl:sequence select="imf:create-row($this/*:conceptualSchemaSvnId)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:fetch-local-package">
        <xsl:param name="this"/>
        <xsl:sequence select="imf:create-package-name($this)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:fetch-local-class">
        <xsl:param name="this"/>
        
        <xsl:sequence select="imf:create-class-name($this)"/>
        
        <xsl:sequence select="imf:create-row($this/*:abstract)"/>
        <xsl:sequence select="imf:create-row($this/*:designation)"/>
        <xsl:sequence select="imf:create-row($this/*:origin)"/>
        <xsl:sequence select="imf:create-row($this/*:pattern)"/>
        <xsl:sequence select="imf:create-row($this/*:union)"/>
        <xsl:sequence select="imf:create-row($this/*:primitive)"/>
        <xsl:sequence select="imf:create-row($this/*:refMaster)"/>
        <xsl:sequence select="imf:create-row($this/*:conceptualSchemaClassName)"/>
        <xsl:sequence select="imf:create-row($this/*:subpackage)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:fetch-local-attribute">
        <xsl:param name="this"/>
        
        <xsl:sequence select="imf:create-attribute-name($this)"/>
        
        <xsl:sequence select="imf:create-row($this/*:maxLength)"/>
        <xsl:sequence select="imf:create-row($this/*:fractionDigits)"/>
        <xsl:sequence select="imf:create-row($this/*:totalDigits)"/>
        <xsl:sequence select="imf:create-row($this/*:dataLocation)"/>
        <xsl:sequence select="imf:create-row($this/*:position)"/>
        <xsl:sequence select="imf:create-row($this/*:attributeTypeName)"/>
        <xsl:sequence select="imf:create-row($this/*:attributeTypeDesignation)"/>
        <xsl:sequence select="imf:create-row($this/*:copyDownTypeId)"/>
        <xsl:sequence select="imf:create-row($this/*:conceptualSchemaType)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:fetch-local-association">
        <xsl:param name="this"/>
        
        <xsl:sequence select="imf:create-association-name($this)"/>
        
        <xsl:sequence select="imf:create-row($this/*:aggregation)"/>
        <xsl:sequence select="imf:create-row($this/*:position)"/>
        <xsl:sequence select="imf:create-row($this/*:copyDownTypeId)"/>
        <xsl:sequence select="imf:create-row($this/*:sourceName)"/>
        <xsl:sequence select="imf:create-row($this/*:sourceAlias)"/>
        <xsl:sequence select="imf:create-row($this/*:targetName)"/>
        <xsl:sequence select="imf:create-row($this/*:targetAlias)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:create-row">
        <xsl:param name="element" as="element()*"/>
        <xsl:variable name="r" as="xs:string*">
            <xsl:for-each select="$element">
                <xsl:value-of select="string-join(.//text(),'|')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($r)">
            <xsl:element name="{ local-name($element[1]) }">
                <xsl:value-of select="string-join($r,'/')"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:create-application-name">
        <xsl:param name="this"/>
        <nameApplication>
            <xsl:value-of select="$this/ancestor-or-self::*:Application/*:identification/*:Identifiable/*:name"/>
        </nameApplication> 
    </xsl:function>
    <xsl:function name="imf:create-package-name">
        <xsl:param name="this"/>
        <namePackage>
            <xsl:value-of select="$this/ancestor-or-self::*:Package/*:identification/*:Identifiable/*:name"/>
        </namePackage> 
    </xsl:function>
    <xsl:function name="imf:create-class-name">
        <xsl:param name="this"/>
        <nameClass>
            <xsl:value-of select="$this/ancestor-or-self::*:Class/*:identification/*:Identifiable/*:name"/>
        </nameClass> 
    </xsl:function>
    <xsl:function name="imf:create-attribute-name">
        <xsl:param name="this"/>
        <nameAttribute>
            <xsl:value-of select="$this/ancestor-or-self::*:Attribute/*:identification/*:Identifiable/*:name"/>
        </nameAttribute> 
    </xsl:function>
    <xsl:function name="imf:create-association-name">
        <xsl:param name="this"/>
        <nameAssociation>
            <xsl:value-of select="$this/ancestor-or-self::*:Association/*:identification/*:Identifiable/*:name"/>
        </nameAssociation> 
    </xsl:function>
    
    <xsl:template match="*" mode="name-mapping">
        <map orig="{imf:create-display-name(.)}" elm="{imf:get-compos-name(.)}"/>
    </xsl:template>
    
    <xsl:template match="*:TaggedValue" mode="name-mapping">
        <map orig="{*:name} (tv)" elm="{concat('tv_', imf:get-safe-string(*:name))}"/>
    </xsl:template>
    
</xsl:stylesheet>
