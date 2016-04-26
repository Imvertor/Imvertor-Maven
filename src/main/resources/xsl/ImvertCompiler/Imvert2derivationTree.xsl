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
         Create a listing of all dependencies between packages.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="application-project" select="/imvert:packages/imvert:project" as="xs:string"/>
    <xsl:variable name="application-name" select="/imvert:packages/imvert:application" as="xs:string"/>
    <xsl:variable name="application-release" select="/imvert:packages/imvert:release" as="xs:string"/>
    
    <xsl:variable name="config-tagged-values" select="imf:get-config-tagged-values()"/>
    
    <xsl:template match="/">
        <xsl:variable name="layers" as="element()">
            <imvert:layers-set>
                <xsl:for-each select="imvert:packages/imvert:package[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))]">
                    <imvert:layer>
                        <imvert:supplier project="{$application-project}" application="{$application-name}" release="{$application-release}">
                            <xsl:apply-templates select="."/>
                        </imvert:supplier>
                        <xsl:sequence select="imf:get-full-derivation-sub(.,1)"/>
                    </imvert:layer>
                </xsl:for-each>
            </imvert:layers-set>
        </xsl:variable>
        <!-- now set the layered name for each component in de layers --> 
        <xsl:apply-templates select="$layers" mode="layered-name"/>
        
       <!-- and record the supplier of the application itself -->
        <xsl:variable name="supplier-application-info" select="imf:get-supplier-info(imvert:packages)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','supplier-etc-system-imvert-path',$supplier-application-info/@system-path,true())"/>
        <xsl:sequence select="imf:set-config-string('appinfo','supplier-etc-model-imvert-path',$supplier-application-info/@model-path,true())"/>
        
    </xsl:template>
    
    <xsl:template match="imvert:package | imvert:class | imvert:attribute | imvert:association">
        <xsl:copy>
            <xsl:attribute name="display-name" select="imf:get-display-name(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value">
        <xsl:variable name="name" select="imvert:name"/>
        <xsl:choose>
            <xsl:when test="$config-tagged-values[name = $name and derive='yes']">
                <xsl:sequence select="."/>
            </xsl:when>
            <xsl:otherwise>
                <!-- skip -->
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <xsl:function name="imf:get-full-derivation-sub" as="element()*">
        <xsl:param name="package" as="element()"/>
        <xsl:param name="level" as="xs:integer"/>
        <!-- 
                Determine which package is the supplier.
                Validation concerns the relation supplier-client.
                
                Supplier name is set explicitly for the package itself, or the same name as this package.
                Supplier project set explicitly for the package itself, or taken from parent.
                Supplier release set explicitly for the package itself, or taken from parent.
        -->
        <xsl:variable name="supplier-info" select="imf:get-supplier-info($package)"/>
        
        <xsl:choose>
            <xsl:when test="not(imf:boolean($package/imvert:derived))">
                <!-- okay, skip. Explicitly specified that the package is not to be considered "derived" -->
            </xsl:when>
         
            <xsl:when test="empty($package/imvert:supplier-name) and not(imf:boolean($package/imvert:derived))">
                <!-- okay, skip. This occurs only for base packages, that have no supplier (CDMKAD, SIM, ...) -->
            </xsl:when>
            
            <xsl:when test="exists($supplier-info/@application) and empty($supplier-info/@project)">
                <xsl:sequence select="imf:report-error($package,true(),'No supplier project specified for supplier [1]', $supplier-info/@application)"/>
            </xsl:when>
            
            <xsl:when test="exists($supplier-info/@application) and empty($supplier-info/@release)">
                <xsl:sequence select="imf:report-error($package,true(),'No supplier release specified for supplier [1]', $supplier-info/@application)"/>
            </xsl:when>
                
            <xsl:when test="exists($supplier-info/@application)">
                <!-- 
                    Check where supplier info is found. 
                     
                -->
                <xsl:variable name="path-found" select="unparsed-text-available($supplier-info/@system-path)"/>
                
                <xsl:sequence select="imf:report-error($package,not($supplier-info/@project),'No supplier project specified')"/>
                <xsl:sequence select="imf:report-error($package,not($supplier-info/@release),'No supplier release specified')"/>
                
                <xsl:variable name="supplier-document" select="imf:document($supplier-info/@system-path)"/>
                <xsl:variable name="supplier-mapped-name" select="$supplier-info/@package-name"/>
                <xsl:variable name="supplier-package" select="$supplier-document/imvert:packages/imvert:package[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package')) and imvert:name=$supplier-mapped-name]"/>
                
                <xsl:choose>
                    <xsl:when test="not($path-found)">
                        <xsl:if test="$level eq 1">
                            <xsl:sequence select="imf:report-warning($package,true(),'No supplier Imvert information found; not validating this derivation')"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="not($supplier-package)">
                        <xsl:if test="$level eq 1">
                            <xsl:sequence select="imf:report-warning($package,true(),'No supplier package found; not validating this derivation')"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <imvert:supplier application="{$supplier-info/@application}" project="{$supplier-info/@project}" release="{$supplier-info/@release}">
                            <xsl:sequence select="$supplier-package"/>
                        </imvert:supplier>
                        <xsl:sequence select="imf:get-full-derivation-sub($supplier-package, $level + 1)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-warning($package,true(),'No supplier name specified, assuming this package is not derived.')"/>
            </xsl:otherwise>
        </xsl:choose>
      
    </xsl:function>
    
    <xsl:function name="imf:get-imvert-etc-filepath" as="xs:string">
        <xsl:param name="project" as="xs:string?"/>
        <xsl:param name="application" as="xs:string?"/>
        <xsl:param name="release" as="xs:string?"/>
        <xsl:param name="type" as="xs:string"/> <!-- system or model -->
        <xsl:variable name="path" select="concat(imf:file-to-url($applications-folder-path),$project,'/',$application,'/',$release,'/etc/',$type,'.imvert.xml')"/>
        <xsl:value-of select="$path"/>
    </xsl:function>
    
    <xsl:template match="*" mode="#default layered-name">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="imvert:package | imvert:class | imvert:attribute | imvert:association" mode="layered-name">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="layered-name" select="imf:get-layered-display-names(.)[last()]"/>
            <xsl:apply-templates mode="layered-name"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:get-layered-display-names" as="xs:string+">
        <xsl:param name="construct" as="element()"/>
        
        <xsl:value-of select="imf:get-layered-display-name($construct)"/>
                
        <xsl:variable name="type" select="name($construct)"/>
        <xsl:variable name="name" select="($construct/imvert:name, $construct/imvert:supplier-package-name)"/>
        <xsl:variable name="client" select="$construct/ancestor::imvert:supplier"/>
        <xsl:variable name="supplier" select="$client/following-sibling::imvert:supplier[1]"/>
        <xsl:variable name="supplier-construct" select="($supplier/descendant::*[name(.) = $type][imvert:name = $name])[1]"/>
        <xsl:if test="exists($supplier-construct)">
            <xsl:sequence select="imf:get-layered-display-names($supplier-construct)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-layered-display-name" as="xs:string">
        <xsl:param name="construct" as="element()"/>
        <xsl:value-of select="string-join((
            $construct/ancestor-or-self::imvert:package/imvert:name,
            $construct/ancestor-or-self::imvert:class/imvert:name,
            $construct/ancestor-or-self::imvert:attribute/imvert:name,
            $construct/ancestor-or-self::imvert:association/imvert:name),'_')"/>
    </xsl:function>
    
    <xsl:function name="imf:get-supplier-info" as="element(info)">
        <xsl:param name="package" as="element()"/>
        <xsl:variable name="supplier-application"  select="if ($package/imvert:supplier-name) then $package/imvert:supplier-name else $package/../imvert:supplier-name"/>
        <xsl:variable name="supplier-project"      select="if ($package/../imvert:supplier-project) then $package/../imvert:supplier-project else $package/imvert:supplier-project"/>
        <xsl:variable name="supplier-release"      select="if ($package/../imvert:supplier-release) then $package/../imvert:supplier-release else $package/imvert:supplier-release"/>
        <xsl:variable name="supplier-package-name" select="if ($package/imvert:supplier-package-name) then $package/imvert:supplier-package-name else $package/imvert:name"/>
        <xsl:variable name="supplier-system-path"  select="if ($supplier-project) then imf:get-imvert-etc-filepath($supplier-project, $supplier-application, $supplier-release,'system') else ''"/> 
        <xsl:variable name="supplier-model-path"   select="if ($supplier-project) then imf:get-imvert-etc-filepath($supplier-project, $supplier-application, $supplier-release,'model') else ''"/> 
        <info>
            <xsl:attribute name="package-name" select="$supplier-package-name"/>
            <xsl:attribute name="application" select="$supplier-application"/>
            <xsl:attribute name="project" select="$supplier-project"/>
            <xsl:attribute name="release" select="$supplier-release"/>
            <xsl:attribute name="system-path" select="$supplier-system-path"/>
            <xsl:attribute name="model-path" select="$supplier-model-path"/>
        </info>
    </xsl:function>
 </xsl:stylesheet>
