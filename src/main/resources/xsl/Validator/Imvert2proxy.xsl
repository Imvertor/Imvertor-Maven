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
         Resolve all proxies.
         
         ADAPTION IN ACCORDANCE WITH https://kinggemeenten.plan.io/issues/487891 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="output-folder" select="imf:get-config-string('system','managedoutputfolder')"/>
    <xsl:variable name="owner" select="imf:get-config-string('cli','owner')"/>
    
    <xsl:variable name="stereotype-proxy" select="('stereotype-name-att-proxy','stereotype-name-obj-proxy','stereotype-name-grp-proxy','stereotype-name-prd-proxy')"/>
    
    <xsl:variable name="local-constructs" select="('name', 'id')"/> <!-- 'attributes', 'associations', ? -->
    
    <xsl:variable name="root-package" select="//imvert:package[imf:boolean(imvert:is-root-package)]"/>
    <xsl:variable name="outside-package" select="//imvert:package[imvert:id = 'OUTSIDE']"/>
    
    <!-- proxy the root package content. This drags in all proxied constructs, except for outside constructs that are not referenced by the application itself -->
    <xsl:variable name="proxied-content" as="node()*">
        <xsl:apply-templates select="$root-package/*" mode="client"/>
    </xsl:variable>
    
    <!-- Compile a list of all outside constructs required by the root package -->
    <xsl:variable name="proxied-content-outside" as="element(imvert:class)*">
        <xsl:sequence select="$outside-package/imvert:class"/>
    </xsl:variable>
    
    <xsl:template match="/imvert:packages">
        <xsl:copy>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            
            <xsl:apply-templates select="imvert:package" mode="client"/>
            
            <!-- 
                Create a standard package for outside package; even if no such external references occur.
                For outside packages, check if all references on the proxied content to outside constructs are resolved. 
                If not, add them based on the current mappings. 
            --> 
            <imvert:package>
                <imvert:stereotype id="stereotype-name-folder-package" origin="system">FOLDER</imvert:stereotype>
                <imvert:id>OUTSIDE</imvert:id>
                
                <!-- pass on the contents of the outside package -->
                <xsl:sequence select="$outside-package/imvert:class"/>
             
                <!-- and add anything required by proxy -->
                
                <xsl:variable name="known-outside-classes" select="$proxied-content//imvert:*[imvert:type-package = 'OUTSIDE' and empty(imvert:proxy-to-outside)]"/>
                <xsl:variable name="proxied-outside-classes" select="$proxied-content//imvert:*[imvert:proxy-to-outside]"/>
                
                <xsl:for-each-group select="$proxied-outside-classes" group-by="imvert:proxy-to-outside">
                    <xsl:if test="not($known-outside-classes/imvert:type-name = current-grouping-key())">
                        <imvert:class origin="stub" umltype="Class">
                            <xsl:comment>REQUIRED BY PROXY</xsl:comment>
                            <imvert:name original="{current-grouping-key()}">
                                <xsl:value-of select="current-grouping-key()"/>
                            </imvert:name>
                            <imvert:id>
                                <xsl:value-of select="current-group()[1]/imvert:type-id"/>
                            </imvert:id>
                        </imvert:class>
                    </xsl:if>
                </xsl:for-each-group>
                
            </imvert:package>
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:package[. is $root-package]" mode="client">
        <xsl:variable name="this-package" select="."/>
        
        <xsl:variable name="package-proxies" select=".//*[imvert:stereotype/@id = $stereotype-proxy]"/>
        <xsl:variable name="supplier-project" select="imvert:supplier/imvert:supplier-project"/>
        <xsl:variable name="supplier-name" select="imvert:supplier/imvert:supplier-name"/>
        <xsl:variable name="supplier-release" select="imvert:supplier/imvert:supplier-release"/>
        <xsl:choose>
            <xsl:when test="exists($package-proxies) and empty($supplier-project)">
                <xsl:sequence select="imf:msg(..,'ERROR','Proxies found, but no proxy supplier project specified',())"/>
            </xsl:when>
            <xsl:when test="exists($package-proxies) and empty($supplier-name)">
                <xsl:sequence select="imf:msg(..,'ERROR','Proxy supplier project found, but no proxy supplier name specified',())"/>
            </xsl:when>
            <xsl:when test="exists($package-proxies) and empty($supplier-release)">
                <xsl:sequence select="imf:msg(..,'ERROR','Proxy supplier project found, but no proxy supplier release specified',())"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- resolve all proxies. This introduces (drags) types that occur as the type of a proxied attribute. -->
                <imvert:package>
                    <xsl:sequence select="$proxied-content"/>
                </imvert:package>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:package[. is $root-package]/imvert:package" mode="client">
       
         <xsl:variable name="proxied-content" as="node()*">
            <xsl:apply-templates mode="client"/>
        </xsl:variable>
        
        <!-- 
            classes that are not represented as proxies, but that occur as the type of some attribute that is proxied, must be copied to the client.
            We call this ""dragging" the type info the model of the client.
        -->
        <xsl:variable name="dragged-proxied-content" as="element()*">
            <xsl:for-each-group select="$proxied-content//imvert:attribute" group-by="imvert:type-id">
                <xsl:variable name="type-id" select="current-grouping-key()"/>
                <!-- check if type id is resolved, and if not, try to get it from supplier (drag) -->
                <xsl:variable name="construct" select="imf:get-construct-by-id($type-id)"/>
                <!-- if this is not found, drag the construct -->
                <xsl:if test="empty($construct)">
                    <xsl:variable name="supplier-subpaths" select="imf:get-construct-supplier-system-subpaths($root-package)" as="xs:string*"/>
                    <xsl:variable name="result" as="element()*">
                        <xsl:for-each select="$supplier-subpaths">
                            <xsl:variable name="supplier-doc" select="imf:get-imvert-supplier-doc(.)"/>
                            <xsl:variable name="supplier" select="imf:get-construct-by-id($type-id,$supplier-doc)"/>
                            <xsl:apply-templates select="$supplier" mode="dragged"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <!-- determine which release these ID's are taken from -->
                    <xsl:variable name="stamps" select="for $s in $result return concat('Created: ',$s/imvert:created,', Modified: ',$s/imvert:modified)"/>
                    <xsl:variable name="names" select="for $s in $result return $s/imvert:name"/>
                    <xsl:choose>
                        <xsl:when test="$result[2] and distinct-values($names)[2]">
                            <xsl:sequence select="imf:msg(.,'ERROR','Proxy supplier constructs with different name: [1]. Applicable suppliers are: [2]',(imf:string-group($names),imf:string-group($supplier-subpaths)))"/>
                        </xsl:when>
                        <xsl:when test="$result[2] and distinct-values($stamps)[2]">
                            <xsl:sequence select="imf:msg(.,'ERROR','Proxy supplier constructs have different timestamps: stamps are [1]. Applicable suppliers are: [2]',(imf:string-group($stamps),imf:string-group($supplier-subpaths)))"/>
                        </xsl:when>
                        <xsl:when test="$result[1]">
                            <!-- we assume here that the referenced constructs are the same, so take the first. -->
                            <xsl:sequence select="$result[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- resolve in some other way or signal error later -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>
        <imvert:package>
            <xsl:apply-templates select="@*"/>
            <xsl:comment>PROXIED</xsl:comment>
            <xsl:sequence select="$proxied-content"/>
            <xsl:comment>DRAGGED</xsl:comment>
            <xsl:sequence select="$dragged-proxied-content"/>
        </imvert:package>
    </xsl:template>

    <xsl:template match="imvert:package[. is $outside-package]" mode="client">
        <!-- skip; processed elsewhere -->
    </xsl:template>
    
    <!--TODO inlezen van losse documenten tegengaan; volg het gecompileerde suppliers document -->
    <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-proxy] | imvert:attribute[imvert:stereotype/@id = $stereotype-proxy]" mode="client">
        <xsl:variable name="client" select="."/>
        <xsl:variable name="trace-id" select="$client/imvert:trace" as="element()*"/>
        <xsl:variable name="supplier-subpaths" select="imf:get-construct-supplier-system-subpaths($client)" as="xs:string*"/>
        <xsl:comment>Subpaths are: <xsl:value-of select="string-join($supplier-subpaths,' | ')"/></xsl:comment>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="count($trace-id) != 1">
                    <xsl:sequence select="imf:msg(.,'ERROR', 'Proxy requires a single outgoing trace, [1] traces found',count($trace-id))"/>
                </xsl:when>
                <xsl:when test="empty($supplier-subpaths)">
                    <xsl:sequence select="imf:msg(.,'ERROR','Could not determine a supplier subpath',())"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- get the construct traced in any supplier -->
                    <xsl:variable name="result" as="element()*">
                        <xsl:for-each select="$supplier-subpaths">
                            <xsl:variable name="supplier-doc" select="imf:get-imvert-supplier-doc(.)"/>
                            <xsl:variable name="supplier" select="imf:get-construct-by-id($trace-id,$supplier-doc)"/>
                            <xsl:choose>
                                <xsl:when test="empty($supplier-doc)">
                                    <xsl:sequence select="imf:msg($client,'WARNING','No such supplier model: [1]',.)"/>
                                </xsl:when>
                                <xsl:when test="exists($supplier)">
                                    <!-- this is reached only once. -->
                                   
                                    <xsl:apply-templates select="$client/imvert:name" mode="client"/>
                                    <xsl:apply-templates select="$client/imvert:id" mode="client"/>
                                    <xsl:apply-templates select="$client/imvert:is-id" mode="client"/>
                                    
                                    <imvert:proxy origin="system" original-location="{.}">
                                        <xsl:value-of select="$supplier/imvert:id"/>
                                    </imvert:proxy>
                                    
                                    <xsl:apply-templates select="$client/imvert:min-occurs" mode="client"/>
                                    <xsl:apply-templates select="$client/imvert:max-occurs" mode="client"/>
                               
                                    <!-- 
                                         Copy for this proxy the local constructs 
                                         This template filters out what should not be copied.
                                    -->
                                    <xsl:apply-templates select="$supplier/*" mode="supplier"/>
                                    
                                    <!-- process the attributes and associations (will not fire when client is imvert:attribute) -->
                                    <xsl:apply-templates select="$client/imvert:attributes" mode="client"/>
                                    <xsl:apply-templates select="$client/imvert:associations" mode="client"/>
                                    
                                    <!-- 
                                         get the applicable tagged values for the proxy, and add those for the supplier.
                                    -->
                                    <xsl:variable name="tv-client" as="element()*">
                                        <xsl:apply-templates select="$client/imvert:tagged-values/*" mode="client"/>
                                    </xsl:variable>
                                    <xsl:variable name="tv-supplier" as="element()*">
                                        <xsl:apply-templates select="$supplier/imvert:tagged-values/*" mode="supplier"/>
                                    </xsl:variable>
                                    <imvert:tagged-values>
                                        <xsl:for-each-group select="($tv-supplier,$tv-client)" group-by="imvert:name">
                                            <xsl:apply-templates select="current-group()[1]" mode="client"/>
                                        </xsl:for-each-group>
                                    </imvert:tagged-values>
                                    
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- this supplier doesn't provide the info -->
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="empty($result)">
                            <xsl:sequence select="imf:msg(.,'ERROR', 'Unable to resolve the proxy trace, tried [1]',imf:string-group($supplier-subpaths))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$result"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
 
    <!--
        Replace/remove constructs dragged in by proxy, which are resolved in de dragged content, and should be re-interpreted in the client.       
    -->
    
    <xsl:template match="imvert:conceptual-schema-type" mode="dragged">
        <!-- remove, but insert an signal -->
        <imvert:proxy-to-outside>
            <xsl:value-of select="."/>
        </imvert:proxy-to-outside>
    </xsl:template>
    
    <xsl:template match="imvert:type-package-id[../imvert:conceptual-schema-type]" mode="dragged">
       <!-- remove -->
    </xsl:template>
   
    <xsl:template match="imvert:type-name[../imvert:conceptual-schema-type]" mode="dragged">
        <!-- replace by the referencing name, GM_point in stead of "Point" -->
        <xsl:variable name="type" select="../imvert:conceptual-schema-type"/>
        <imvert:type-name original="{$type}">
            <xsl:value-of select="$type"/>
        </imvert:type-name>
    </xsl:template>
    
    <xsl:template match="imvert:type-package[../imvert:conceptual-schema-type]" mode="dragged">
        <imvert:type-package original="OUTSIDE">OUTSIDE</imvert:type-package>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:conceptual-schema-class-name]" mode="dragged">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="
        imvert:id |
        imvert:is-id |
        imvert:class/imvert:name | 
        imvert:supertype | 
        imvert:attribute/imvert:name | 
        imvert:min-occurs | 
        imvert:max-occurs | 
        imvert:attributes | 
        imvert:associations | 
        imvert:tagged-values" mode="supplier">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="imvert:tagged-value[@ID = ('CFG-TV-RULES','CFG-TV-RULES-IMBROA','CFG-TV-DESCRIPTION')]" mode="supplier">
        <!-- skip; never copy these from the supplier. -->
    </xsl:template>
    
    <?x
    <!-- 
        the target of an association of a supplier, must be replaced by the proxy :
    -->
    <xsl:template match="imvert:type-id" mode="supplier">
        <xsl:variable name="id" select="."/>
        <xsl:variable name="proxy" select="$document-proxies[imvert:trace = $id]"/>
        <xsl:choose>
            <xsl:when test="count($proxy) != 1">
                <xsl:sequence select="imf:msg(..,'ERROR', 'Proxy association deadlock, [1] traces found',count($proxy))"/>
            </xsl:when>
            <xsl:otherwise>
                <imvert:type-id origin="proxy" original="{$id}">
                    <xsl:value-of select="$proxy/imvert:id"/>
                </imvert:type-id>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    x?>
    
    <xsl:template match="node()" mode="client supplier dragged">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
