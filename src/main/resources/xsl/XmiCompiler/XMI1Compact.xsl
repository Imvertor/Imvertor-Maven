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

    <xsl:variable name="all-packages" select="//UML:Package"/>
    
    <!-- 
        collect all packages that are <<project>>. Asume no  package is project when the model is exported. 
        This is the new approach (previously we exported projects in stead of models).
    -->
    <xsl:variable name="project-packages" select="$all-packages[imf:get-xmi-stereotype(.) = imf:get-config-stereotypes('stereotype-name-project-package')]"/>
    <!-- 
        the root of the application model tree is either the project package, or the application model itself 
    --> 
    <xsl:variable name="project-package" select="($project-packages[imf:is-applicable-project-package(.)],$all-packages)[1]"/>
    
    <xsl:variable name="application-packages" select="$project-package/descendant-or-self::UML:Package[imf:get-xmi-stereotype(.) = imf:get-config-stereotypes('stereotype-name-application-package')]"/>
    <xsl:variable name="model-packages" select="$project-package/descendant-or-self::UML:Package[imf:get-xmi-stereotype(.) = imf:get-config-stereotypes('stereotype-name-base-package')]"/>
    
    <!-- 
        external package should not occur in the model-mode
    -->    
    <xsl:variable name="external-packages" select="$all-packages[imf:get-xmi-stereotype(.) = imf:get-config-stereotypes('stereotype-name-external-package')]"/>
    
    <xsl:variable name="app-package" select="($model-packages,$application-packages)[imf:get-normalized-name(@name,'package-name') = imf:get-normalized-name($application-package-name,'package-name')]"/>
    <xsl:variable name="containing-packages" select="$app-package/ancestor::UML:Package"/>
    
    <xsl:variable name="known-classes" select="($app-package,$external-packages)//UML:Class"/>
    
    <xsl:template match="/XMI">
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:sequence select="imf:track('Compacting')"/>
            
            <xsl:choose>
                <xsl:when test="empty($project-packages)">
                    <!-- NIEUWE CASUS -->
                    <xsl:choose>
                        <xsl:when test="empty($app-package)">
                            <xsl:sequence select="imf:msg('ERROR','No application found: [1], available applications are: [2]', ($application-package-name, string-join($application-packages/@name,';')))"/>
                        </xsl:when>
                        <xsl:when test="count($app-package) ne 1">
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
                </xsl:when>
                <xsl:otherwise>
                    <!-- OUDE CASUS -->
                    <xsl:choose>
                        <xsl:when test="empty($project-packages)">
                            <xsl:sequence select="imf:msg('ERROR','No projects found')"/>
                        </xsl:when>
                        <xsl:when test="not(normalize-space($project-name))">
                            <xsl:sequence select="imf:msg('ERROR','No project name specified')"/>
                        </xsl:when>
                        <xsl:when test="empty($project-package)">
                            <xsl:sequence select="imf:msg('ERROR','No project found for: [1], searched for [2]', ($application-package-name,$project-name))"/>
                        </xsl:when>
                        <xsl:when test="empty($app-package)">
                            <xsl:sequence select="imf:msg('ERROR','No application found: [1], available applications are: [2]', ($application-package-name, string-join($application-packages/@name,';')))"/>
                        </xsl:when>
                        <xsl:when test="count($app-package) ne 1">
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
                </xsl:otherwise>
            </xsl:choose>
         </xsl:copy>
     </xsl:template>
    
    <!-- 
        Create a full copy of the package and sub-structures for the application.
    -->
  
    <!-- copy all packages except those what are not witin application, or not external) -->
    <xsl:template match="UML:Package">
        
        <!-- package contains the app? -->
        <xsl:variable name="holds-app" select="exists(. intersect $containing-packages)"/>
        <!-- package is (part of) the app? -->
        <xsl:variable name="is-in-app" select="exists(ancestor-or-self::UML:Package intersect $app-package)"/>
        <!-- package is external? -->
        <xsl:variable name="is-in-ext" select="exists(ancestor-or-self::UML:Package intersect $external-packages)"/>
       
        <!--<xsl:sequence select="imf:msg(.,'DEBUG','Compact: package [1] holds app [2], is in app [3], is in external [4]', (@name,$holds-app,$is-in-app,$is-in-ext))"/>-->
        <xsl:choose>
            <xsl:when test="$holds-app">
                <xsl:if test="$debugging">
                    <xsl:comment select="concat(@name, ' added because: holds-app')"/>
                </xsl:if>
                <xsl:next-match/>            
            </xsl:when>
            <xsl:when test="$is-in-ext">
                <xsl:if test="$debugging">
                    <xsl:comment select="concat(@name, ' added because: is-in-ext')"/>
                </xsl:if>
                <xsl:next-match/>            
            </xsl:when>
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
    <xsl:template match="@xmi.id | @xmi.idref | @base | UML:AssociationEnd/@type | @modelElement">
        <xsl:attribute name="{name()}" select="if ($normalize-ids) then imf:normalize-id(.) else ."/>
    </xsl:template>
    
    <xsl:template match="UML:ClassifierRole/@xmi.id">
        <xsl:attribute name="{name()}" select="if ($normalize-ids) then concat('CROLE_',imf:normalize-id(.)) else ."/>
    </xsl:template>
    
    <xsl:template match="UML:TaggedValue[@tag = ('SourceAttribute','SourceAssociation','ea_guid','package','package2')]">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name() = 'value')]"/>
            <xsl:attribute name="value" select="if ($normalize-ids) then imf:normalize-id(@value) else @value"/>
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
    
    <xsl:function name="imf:normalize-id" as="xs:string">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="empty($id)">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="starts-with($id,'{')">
                <xsl:value-of select="replace(substring($id,2,string-length($id) - 2),'[_\-]','.')"/>
            </xsl:when>
            <xsl:when test="starts-with($id,'EAID_')">
                <xsl:value-of select="replace(substring($id,6),'[_\-]','.')"/>
            </xsl:when>
            <xsl:when test="starts-with($id,'EAPK_')">
                <xsl:value-of select="replace(substring($id,6),'[_\-]','.')"/>
            </xsl:when>
            <xsl:when test="starts-with($id,'MX_EAID_')">
                <xsl:value-of select="concat(substring($id,1,9),replace(substring($id,9),'[_\-]','.'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($id,'[_\-]','.')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
