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

    <xsl:template match="imvert:packages" mode="quickview">
        <xsl:variable name="domain-packages" select="root()//imvert:package[imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))]"/>
        <xsl:variable name="title">Quick view</xsl:variable>
        <page>
            <title>Quick view</title>
            <content>
                <div>
                    <div class="intro">
                        <p>
                            This table reports all packages, contained classes, and contained properties, i.e. attributes (attrib) and associations (assoc).
                        </p>
                        <p>
                            There are 
                            <xsl:value-of select="count($domain-packages)"/> domain packages, with 
                            <xsl:value-of select="count($domain-packages/imvert:class)"/> classes, with
                            <xsl:value-of select="count($domain-packages/imvert:class/*/imvert:attribute)"/> attributes and 
                            <xsl:value-of select="count($domain-packages/imvert:class/*/imvert:association)"/> associations.
                            This may include system generated classes.
                        </p>
                        <p>
                            For each class the following is specified:
                        </p>
                        <ul>
                            <li>Is this a natural root class? Only classes that are nit (indirectly) referenced are natural roots.</li>
                            <li>P::C in which P = package C = class</li>
                            <li>Stereotype</li>
                            <li>Supertype</li>
                        </ul>
                        <p>
                            For each class property the following is specified:
                        </p>
                        <ul>
                            <li>Number in sequence (order of the elements in the XML schema, higher number after lower number)</li>
                            <li>P::C.p in which P = package C = class, p = property</li>
                            <li>Type of the property</li>
                            <li>Multiplicity</li>
                            <li>Stereotype</li>
                        </ul>
                    </div>
                    <table>
                        <xsl:apply-templates select="$domain-packages" mode="quickview"/>
                    </table>
                </div>
            </content>
        </page>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="quickview">
        <tr>
            <td class="vert_spacer">&#160;</td>
        </tr>
        <tr>
            <td colspan="100" class="package">
                <xsl:sequence select="imf:report-label('Package',imvert:name)"/>
                <xsl:sequence select="imf:report-label('Namespace',imvert:namespace)"/>   
                <xsl:sequence select="imf:report-label('Stereo',imvert:stereotype)"/>   
            </td>
        </tr>     
        <xsl:sequence select="imf:create-table-header('pos:10,property:35,type:35,min:5,max:5,stereotype:10,origin:10')"/>
        <xsl:apply-templates select="imvert:class" mode="quickview"/>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="quickview">
        <tr>
            <td colspan="100" class="class">
                <a name="{@display-name}"/>
                <xsl:sequence select="imf:report-label('Name',imf:get-construct-name(.))"/>
                <xsl:sequence select="imf:report-label('Abstract?',if (imf:boolean(imvert:abstract)) then 'true' else '')"/>
                <xsl:sequence select="imf:report-label('Root?',if (imf:is-natural-root-class(.)) then 'true' else '')"/>
                <xsl:variable name="subpackages" select="imvert:subpackage"/>
                <xsl:if test="$subpackages">
                    <xsl:sequence select="imf:report-label('Subpackages',string-join($subpackages, '&gt;'))"/>
                </xsl:if>
                <xsl:sequence select="imf:report-label('Stereo',string-join(imvert:stereotype,' '))"/>
                <xsl:variable name="supers" as="node()*">
                    <xsl:for-each select="imvert:supertype">
                        <xsl:variable name="display-name" select="imf:get-construct-name(.)"/>
                        <a href="#{$display-name}"> 
                            <xsl:value-of select="$display-name"/>
                        </a>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:sequence select="imf:report-label('Super',$supers)"/>
                <xsl:variable name="substs" as="node()*">
                    <xsl:for-each select="imvert:substitution">
                        <xsl:variable name="display-name" select="imf:get-construct-name(.)"/>
                        <a href="#{$display-name}"> 
                            <xsl:value-of select="$display-name"/>
                        </a>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:sequence select="imf:report-label('Also substitute for',$substs)"/>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="imvert:attributes/imvert:attribute|imvert:associations/imvert:association">
                <xsl:for-each select="imvert:attributes/imvert:attribute|imvert:associations/imvert:association">
                    <xsl:sort select="xs:integer(imvert:position)"/>
                    <xsl:apply-templates select="." mode="quickview"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td/>
                    <td>(No properties specified)</td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
            
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="quickview">
        <tr>
            <!--<td>Attrib</td>-->   
            <xsl:apply-templates select="." mode="quickview-property"/>   
        </tr>
    </xsl:template>
    <xsl:template match="imvert:association" mode="quickview">
        <tr>
            <!--<td>Assoc</td>-->   
            <xsl:apply-templates select="." mode="quickview-property"/>   
        </tr>
    </xsl:template>
    
    <xsl:template match="*" mode="quickview-property">
        <td>
            <xsl:value-of select="imvert:position"/>
        </td>
        <td>
            <xsl:sequence select="imf:get-construct-name(.)"/>
        </td>
        <!--
        <td>
            <xsl:value-of select="../../imvert:name"/>
        </td>   
        <td>
            <xsl:value-of select="imvert:name"/>
        </td>
        -->
        <td>
            <xsl:value-of select="@type-display-name"/>
            <xsl:if test="imvert:baretype != imvert:type-name"> (<xsl:value-of select="imvert:baretype"/>)</xsl:if>
        </td>   
        <td>
            <xsl:value-of select="imvert:min-occurs"/>
        </td>   
        <td>
            <xsl:value-of select="imvert:max-occurs"/>
        </td>   
        <td>
            <xsl:value-of select="string-join(imvert:stereotype,', ')"/>
        </td>
        <td>
            <xsl:value-of select="@copy-down-display-name"/>
        </td>
    </xsl:template>
    <xsl:template match="*|text()" mode="quickview">
        <xsl:apply-templates mode="quickview"/>
    </xsl:template>  

    <?remove 
    <xsl:function name="imf:get-qualified-classname" as="xs:string">
        <xsl:param name="class" as="xs:string"/>
        <xsl:param name="package" as="xs:string"/>
        <xsl:value-of select="concat($package,':',$class)"/>
    </xsl:function>
    ?>
    
    <!-- true when this class doesn't occur in any relation or attribute  -->
    <xsl:function name="imf:is-natural-root-class" as="xs:boolean">
        <xsl:param name="this" as="node()?"/> <!-- an imvert:class -->
        <xsl:variable name="type-name" select="$this/imvert:name"/>
        <xsl:variable name="type-package" select="$this/parent::imvert:package/imvert:name"/>
        <xsl:choose>
            <xsl:when test="not($type-name)">
                <!-- (allowed for recursion) -->
                <xsl:value-of select="false()"/> 
            </xsl:when>
            <xsl:when test="not($type-package)">
                <!-- raw or base type -->
                <xsl:value-of select="false()"/> 
            </xsl:when>
            <xsl:when test="$this/imvert:ref-master">
                <!-- a reference element cannot be the root -->
                <xsl:value-of select="false()"/> 
            </xsl:when>
            <xsl:when test="$document//imvert:association[imvert:type-name=$type-name and imvert:type-package=$type-package]">
                <!-- some classes associate with this class -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$document//imvert:attribute[imvert:type-name=$type-name and imvert:type-package=$type-package]">
                <!-- some classes have an attribute of this type -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="not($this/imvert:supertype)">
                <!-- this element has no supertype, it must be a natural root -->
                <xsl:value-of select="true()"/> 
            </xsl:when>
            <xsl:when test="not(imf:is-natural-root-class(imf:get-superclasses($this)[last()]))">
                <!-- The top of the type hierarchy is not a root, therefore subtypes are also not assumed to be a natural root -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
</xsl:stylesheet>
