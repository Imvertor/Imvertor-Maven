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
       Imvert files represent the full info of the UML specifications needed to compile the XML schema. 
       To check whether any application A is validly derived from a supplier schema B 
       the XMI may be compared. 
       This way we do not get into the hassle of comparing two XML schema's, which would require
       a complete breakdown of two schemas into the basis equivalent components.
       
       An application is derived from some other application when supplier-name is specified.
    -->
  
    <!-- TODO = Subtypen / Voorbeeld: Abstract supplier _N, concrete client N.....? welke regel?
        Derivation rule: Client type is not properly derived from supplier type 
        
    -->
    <!-- TODO Gegevensgroeptypen die niet gebruikt worden -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="pairs" select="imf:document($derivationtree-file-url)/imvert:layers-set/imvert:layer"/>
    
    <!-- all classes defined by supplier -->
    <xsl:variable name="supplier-classes" select="$pairs/imvert:supplier[2]/*/imvert:class"/>
    
    <xsl:variable name="normalized-stereotype-enum" select="imf:get-config-stereotypes('stereotype-name-enum')"/>
    <!-- 
        Templates access application pairs, an process the client constructs. 
        Determine if the client construct is validly derived from supplier construct.
        Copies messages compiled in building the pairs to the result document.
    --> 
    <xsl:template match="/">
        <imvert:report>
            <xsl:sequence select="$pairs"/>
            <xsl:apply-templates select="$pairs"/>
        </imvert:report>
    </xsl:template>

    <xsl:template match="imvert:layer">
        <xsl:apply-templates select="imvert:supplier[1]" mode="client"/>
        <xsl:apply-templates select="imvert:supplier[1]/following-sibling::*[1]" mode="supplier"/>
    </xsl:template>
    
    <xsl:template match="imvert:supplier" mode="client">
        <xsl:variable name="supplier" select="../imvert:supplier[2]/imvert:package"/>
        <xsl:apply-templates select="imvert:package">
            <xsl:with-param name="supplier-package" select="$supplier"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="imvert:supplier" mode="supplier">
        <!-- skip; is passed as parameter to the client check. -->
    </xsl:template>
    
    <xsl:template match="imvert:message">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <!-- template accessed for client packages only. -->
    <xsl:template match="imvert:package">
        <xsl:param name="supplier-package"/>
        <xsl:choose>
            <xsl:when test="$supplier-package">
                <!-- client same as supplier -->
                <!-- test the classes -->
                <xsl:apply-templates select="imvert:class">
                    <xsl:with-param name="supplier-package" select="$supplier-package"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:sequence select="imf:report-info(.,true(),'Package added.')"/>-->
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <xsl:param name="supplier-package"/>
        <xsl:variable name="client-class" select="."/>
        <xsl:variable name="supplier-class" select="$supplier-package/imvert:class[imvert:name=$client-class/imvert:name]"/>
        <xsl:choose>
            <xsl:when test="$supplier-class">
                <!-- client same as supplier -->
                <xsl:apply-templates select="$client-class/imvert:attributes/imvert:attribute | $client-class/imvert:associations/imvert:association">
                    <xsl:with-param name="supplier-class" select="$supplier-class"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <!-- client new -->
                <!--<xsl:sequence select="imf:report-info(.,true(),'Class added.')"/>-->
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute">
        <xsl:param name="supplier-class"/>
        <xsl:variable name="client-attribute" select="."/>
        <xsl:variable name="supplier-attribute" select="$supplier-class/imvert:attributes/imvert:attribute[imvert:name=$client-attribute/imvert:name]"/>
        <xsl:variable name="is-enumeration" select="imvert:stereotype = $normalized-stereotype-enum"/> 
        
        <xsl:choose>
            <xsl:when test="$is-enumeration">
                <!-- enumeration values may not be added -->
                <xsl:sequence select="imf:report-error($client-attribute,
                    empty($supplier-attribute),
                    'Client enumeration value is not known by supplier',
                    ())"/>
            </xsl:when>
            <xsl:when test="$supplier-attribute">
                <!-- client same as supplier -->
                <!-- same attribute names must have related types -->
                <xsl:sequence select="imf:check-type-related($client-attribute,$supplier-attribute)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- client new -->
                <!--<xsl:sequence select="imf:report-info(.,true(),'Attribute added.')"/>-->
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
    
    <xsl:template match="imvert:association">
        <xsl:param name="supplier-class"/>
        <xsl:variable name="client-association" select="."/>
        <xsl:variable name="supplier-association" select="$supplier-class/imvert:associations/imvert:association[imvert:name=$client-association/imvert:name]"/>

        <xsl:choose>
            <xsl:when test="$supplier-association">
                <!-- client same as supplier -->
                <!-- same attribute names must have related types -->
                <xsl:sequence select="imf:check-type-related($client-association,$supplier-association)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- client new -->
                <!--<xsl:sequence select="imf:report-info(.,true(),'Association added.')"/>-->
            </xsl:otherwise>
        </xsl:choose>    
        
    </xsl:template>
    
    <xsl:template match="*|text()">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:function name="imf:check-type-related" as="element()*">
        <xsl:param name="client"/>
        <xsl:param name="supplier"/>
        <xsl:choose>
            <xsl:when test="not($supplier)">
                <!-- okay; assume the property is new. -->
            </xsl:when>
            <xsl:when test="empty($client/imvert:type-id) and empty($supplier/imvert:type-id)">
                <!-- this is an enum; skip; this is dealt with elsewhere -->
            </xsl:when>
            <xsl:when test="not($supplier/imvert:type-id) and not($client/imvert:type-id)">
                <!-- compare base types -->
                <xsl:sequence select="imf:check-baretype-related($client,$supplier)"/>
            </xsl:when>
            <xsl:when test="$supplier/imvert:type-id and $client/imvert:type-id">
                <!-- compare class-based types -->
                <xsl:sequence select="imf:check-classtype-related($client,$supplier)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-warning($client,true(),
                    'Cannot compare supplier type [1] to client type [2]; types may be incompatible.',
                    ($supplier/imvert:type-name,$client/imvert:type-name))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:check-baretype-related" as="element()*">
        <xsl:param name="client"/>
        <xsl:param name="supplier"/>
        <xsl:variable name="supplier-is-string" select="$supplier/imvert:type-name = 'string'"/>
        <xsl:variable name="supplier-is-int" select="$supplier/imvert:type-name = 'integer'"/>
        <xsl:variable name="supplier-is-dec" select="$supplier/imvert:type-name = 'decimal'"/>
       
        <xsl:choose>
            <xsl:when test="$client/imvert:type-name = 'string'">
                <!-- okay in all cases, may become more specific -->
                <xsl:sequence select="imf:report-warning($client,not($supplier-is-string),
                    'Client type not tested, as supplier type [1] is not character type',
                    ($supplier/imvert:type-name))"/>
                <xsl:sequence select="imf:report-error($client,$supplier-is-string and $supplier/imvert:max-length and not($client/imvert:max-length),
                    'Client type size must be specified and equal or smaller than [1]',
                    ($supplier/imvert:max-length))"/>
                <xsl:sequence select="imf:report-error($client,$supplier-is-string and xs:integer($supplier/imvert:max-length) lt xs:integer($client/imvert:max-length),
                    'Client type size must be equal or smaller than [1]',
                    ($supplier/imvert:max-length))"/>
                <xsl:sequence select="imf:report-warning($client,$supplier-is-string and $client/imvert:pattern and $supplier/imvert:pattern and not($client/imvert:pattern eq $supplier/imvert:pattern),
                    'Client pattern [1] not tested, must denote a subset of supplier pattern [2]',
                    ($client/imvert:pattern,$supplier/imvert:pattern))"/>
                <xsl:sequence select="imf:report-error($client,$supplier-is-string and not($client/imvert:pattern ) and $supplier/imvert:pattern,
                    'Client must specialize or conform to supplier pattern [1]',
                    ($supplier/imvert:pattern))"/>
            </xsl:when>
            <xsl:when test="$client/imvert:type-name = 'integer'">
                <xsl:sequence select="imf:report-error($client,not($supplier-is-int),
                    'Supplier type [1] is not an integer.', 
                    ($supplier/imvert:type-name))"/>
                <xsl:sequence select="imf:report-error($client,$supplier/imvert:total-digits and not($client/imvert:total-digits),
                    'Client type size must be specified')"/>
                <xsl:sequence select="imf:report-error($client,xs:integer($client/imvert:total-digits) gt xs:integer($supplier/imvert:total-digits),
                    'Client type size must be equal or smaller than [1]',
                    ($supplier/imvert:total-digits))"/>
            </xsl:when>
            <xsl:when test="$client/imvert:type-name = 'decimal'">
                <xsl:sequence select="imf:report-error($client,not($supplier-is-dec),
                    'Supplier type [1] is not a decimal.', ($supplier/imvert:type-name))"/>
                <xsl:sequence select="imf:report-error($client,xs:integer($client/imvert:total-digits) gt xs:integer($supplier/imvert:total-digits),
                    'Client type size must be equal or smaller than [1]',($supplier/imvert:total-digits))"/>
                <xsl:sequence select="imf:report-error($client,xs:integer($client/imvert:faction-digits) gt xs:integer($supplier/imvert:total-digits),
                    'Client type size must be equal or smaller than [1]',($supplier/imvert:fraction-digits))"/>
            </xsl:when>
            <xsl:when test="$client/imvert:type-name = ('date', 'datetime', 'boolean', 'year')">
                <xsl:sequence select="imf:report-error($client,not($client/imvert:type-name = $supplier/imvert:type-name),
                    'Supplier type [1] is not equal to client type [2].', 
                    ($supplier/imvert:type-name, $client/imvert:type-name))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-warning($client,true(),
                    'Cannot compare client [1] to supplier [2].',
                    ($client/imvert:type-name, $supplier/imvert:type-name))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:check-classtype-related" as="element()*">
        <xsl:param name="client"/> <!-- a property -->
        <xsl:param name="supplier"/> <!-- a property -->
        
        <xsl:variable name="client-defining-class" select="imf:get-construct-by-id($client/imvert:type-id)"/>
        <xsl:variable name="supplier-package" select="$pairs[imvert:supplier[1]//imvert:id=$client/imvert:type-id]/imvert:supplier[2]/*"/>
        <xsl:variable name="supplier-defining-class" select="imf:get-construct-by-id($supplier/imvert:type-id,$supplier-package)"/>
        
        <xsl:choose>
            <xsl:when test="not($supplier-package)">
                <!-- The supplier package is not defined. This is already signalled.-->
            </xsl:when>
            <xsl:when test="$supplier-defining-class">
                <xsl:variable name="supplier-defining-subclass" select="imf:get-subclasses($supplier-defining-class,$supplier-classes)"/>
                <xsl:variable name="client-defining-superclass" select="imf:get-superclasses($client-defining-class)"/>
                
                <xsl:sequence select="imf:report-error($client,
                    not(($client-defining-class,$client-defining-superclass)/imvert:name = ($supplier-defining-class,$supplier-defining-subclass)/imvert:name),
                    'Client type [1] or any of its supertypes must be (sub)type of supplier type [2]',
                    ($client-defining-class,$supplier-defining-class))"/>
                
                <!-- 
                    for each class that occurs in client as well as supplier, 
                    check if all supertypes also occur in client and supplier 
                --> 
                <!-- TODO Enhance / supertype check in derivation -->
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-error($client,true(),
                    'The supplier could not be found.')"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>
    
</xsl:stylesheet>
