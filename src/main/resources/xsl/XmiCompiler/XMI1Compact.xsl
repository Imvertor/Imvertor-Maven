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
    xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    xmlns:UML="omg.org/UML1.3"
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
    xmlns:EAUML="http://www.sparxsystems.com/profiles/EAUML/1.0"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    
    <xsl:variable name="stylesheet-code">COM</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <!-- Compact the XMI to only the relevant sections -->
 
    <xsl:variable name="document" select="/"/>

    <xsl:variable name="model-package" select="(//UML:Package)[1]"/>
    
    <xsl:variable name="known-classes" select="$model-package//UML:Class"/>
    
    <xsl:variable name="ms" select="imf:get-xmi-stereotype($model-package)"/>
    <xsl:variable name="es" select="imf:get-config-stereotypes(('stereotype-name-base-package','stereotype-name-application-package'))"/>
    
    <xsl:template match="/XMI">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:sequence select="imf:track('Compacting')"/>
                <xsl:choose>
                    <xsl:when test="empty($model-package)">
                        <xsl:sequence select="imf:msg('ERROR','No application found: [1]', ($application-package-name))"/>
                    </xsl:when>
                    <xsl:when test="$model-package/@name ne $application-package-name">
                        <xsl:sequence select="imf:msg('ERROR','Unexpected application package found: [1], expected [2]', ($model-package/@name, $application-package-name))"/>
                    </xsl:when>
                    <xsl:when test="not($ms = $es)">
                        <xsl:sequence select="imf:msg('ERROR','Application package [1] has unexpected stereotype [2], expected: [3]', ($model-package/@name, $ms, imf:string-group($es)))"/>
                    </xsl:when>
                    <xsl:when test="count($model-package) ne 1">
                        <xsl:sequence select="imf:msg('ERROR','Several packages found with same application name: [1]', $application-package-name)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
                <XMI.extensions xmi.extender="IMVERTOR">
                    <xsl:apply-templates select=".//UML:Class" mode="stub"/>
                    <xsl:for-each select="tokenize(imf:get-config-string('cli','sentinel',''),';')">
                        <EAStub type="sentinel" name="{.}"/>
                    </xsl:for-each> 
                </XMI.extensions>
          </xsl:copy>
     </xsl:template>
    
    <!-- 
        Create a full copy of the package and sub-structures for the application.
    -->
  
    <!-- copy all packages except those what are not witin application, or not external) -->
    <xsl:template match="UML:Package">
        
        <!-- package is (part of) the app? -->
        <xsl:variable name="is-in-app" select="exists(ancestor-or-self::UML:Package intersect $model-package)"/>
       
        <!--<xsl:sequence select="imf:msg(.,'DEBUG','Compact: package [1] holds app [2], is in app [3], is in external [4]', (@name,$holds-app,$is-in-app,$is-in-ext))"/>-->
        <xsl:choose>
            <xsl:when test="$is-in-app">
                <xsl:if test="$debugging">
                    <xsl:comment select="concat(@name, ' added because: is-in-app')"/>
                </xsl:if>
                <xsl:next-match/>            
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$debugging">
                    <xsl:comment select="concat(@name, ' purged')"/>
                </xsl:if>
                <!-- if any trace info available, copy those traces to a separate XMI section -->
                <xsl:variable name="traces">
                    <xsl:apply-templates select=".//UML:Association[UML:ModelElement.stereotype/UML:Stereotype/@name = 'trace']"/>
                </xsl:variable>
                <xsl:sequence select="imf:create-output-element('extracted-traces',$traces,(),false(),true())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- The name of a tagged value must be normalized here, for cases where such names are entered manually -->
    <xsl:template match="UML:TaggedValue/@tag">
        <xsl:attribute name="tag" select="normalize-space(.)"/>
    </xsl:template>
    
    <!-- remove EAdefects (issues) -->
    <xsl:template match="XMI.extensions/EAModel.defect">
        <xsl:comment>EAdefects removed</xsl:comment>
    </xsl:template>
    
    <!-- 
        any class found that is not within then application package or an external package is added as a stub 
    -->
    <xsl:template match="UML:Class" mode="stub">
        <xsl:if test="empty($known-classes intersect .) and not(imf:boolean(@isRoot))">
            <xsl:variable name="id" select="@xmi.id"/>
            <EAStub xmi.id="{$id}" name="{@name}"/>
        </xsl:if>
    </xsl:template>
    
    <!-- normalize all IDs directly accessed in attributes-->
    <xsl:template match="
        @xmi.id | 
        @xmi.idref | 
        @base | 
        UML:AssociationEnd/@type | 
        @modelElement | 
        @subtype | 
        @supertype |
        UML:Class/@namespace | 
        UML:Dependency/@client |
        UML:Dependency/@supplier |
        UML:Diagram/@owner |
        UML:DiagramElement/@subject
        ">
        <xsl:attribute name="{name()}" select="if ($normalize-ids) then imf:normalize-xmi-id(.) else ."/>
    </xsl:template>
    
    <xsl:template match="UML:ClassifierRole/@xmi.id">
        <xsl:attribute name="{name()}" select="if ($normalize-ids) then concat('CROLE_',imf:normalize-xmi-id(.)) else ."/>
    </xsl:template>
    
    <xsl:template match="UML:TaggedValue[@tag = (
        'SourceAttribute',
        'SourceAssociation',
        'ea_guid',
        'package',
        'package2',
        'parent',
        '$ea_attsclassified')]">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name() = 'value')]"/>
            <xsl:attribute name="value" select="
                if ($normalize-ids) 
                then imf:normalize-xmi-id(@value) 
                else 
                   if (@tag = 'SourceAssociation') 
                   then imf:normalize-xmi-id-assoc(@value)
                   else @value
             "/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:get-xmi-stereotype" as="xs:string*">
        <xsl:param name="construct"/>
        <xsl:sequence select="for $c in ($construct/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='stereotype']/@value) return imf:get-normalized-name($c,'stereotype-name')"/>
    </xsl:function>
    
    <xsl:function name="imf:is-applicable-project-package" as="xs:boolean">
        <xsl:param name="package"/>
        <xsl:variable name="package-name" select="normalize-space($package/@name)"/>
        
        <xsl:variable name="package-owner-name" select="normalize-space(substring-before($package-name,':'))"/>
        <xsl:variable name="package-project-name" select="normalize-space(substring-after($package-name,':'))"/>
        
        <xsl:sequence select="$package-owner-name = $owner-name and $package-project-name = $project-name"/>
    </xsl:function>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:normalize-xmi-id-assoc" as="xs:string">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="starts-with($id,'{')"> <!-- https://github.com/Imvertor/Imvertor-Maven/issues/129 -->
                <xsl:value-of select="concat('EAID_', replace(substring($id,2,string-length($id) - 2),'\-','_'))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- must not occur, sourceassociation has form {abc} -->
                <xsl:value-of select="$id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
