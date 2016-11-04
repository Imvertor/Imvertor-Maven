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
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:variable name="normalized-stereotype-enum" select="imf:get-config-stereotypes('stereotype-name-enum')"/>
    <!-- 
        Templates access application pairs, an process the client constructs. 
        Determine if the client construct is validly derived from supplier construct.
        Copies messages compiled in building the pairs to the result document.
    --> 
    <xsl:template match="/">
        <imvert:report>
            <xsl:comment>No data, report through messaging framework</xsl:comment>
            <xsl:apply-templates/>
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="imvert:package">
        <xsl:sequence select="imf:track('Validating derivation for package [1]',imvert:name)"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <xsl:variable name="client-class" select="."/>
        <xsl:variable name="supplier-classes" select="imf:get-trace-suppliers-for-construct($client-class,1)"/>
        <xsl:choose>
            <xsl:when test="empty($client-class/imvert:trace)">
                <!-- no trace so no compare neccessary -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$supplier-classes">
                    
                    <xsl:variable name="supplier-class" select="imf:get-trace-construct-by-supplier(.,$imvert-document)"/>
                    
                    <xsl:sequence select="imf:report-error($client-class,
                        not($allow-multiple-suppliers) and position() gt 2,
                        'Multiple suppliers found',
                        ())"/>
                    
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:apply-templates/>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute">
        <xsl:param name="supplier-class"/>
        
        <xsl:variable name="client-attribute" select="."/>
        <!-- see Task #487911 -->
        <xsl:variable name="supplier-attributes" select="imf:get-trace-suppliers-for-construct($client-attribute,1)"/>
        
        <xsl:variable name="is-enumeration" select="imvert:stereotype = $normalized-stereotype-enum"/> 
      
        <xsl:choose>
            <xsl:when test="empty($client-attribute/imvert:trace)">
                <!-- no trace so no compare neccessary -->
            </xsl:when>
            <xsl:when test="$is-enumeration">
                <!-- enumeration values may not be added -->
                <xsl:sequence select="imf:report-error($client-attribute,
                    empty($supplier-attributes),
                    'Client enumeration value is not known by supplier',
                    ())"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:for-each select="$supplier-attributes">
                   
                   <xsl:variable name="supplier-attribute" select="imf:get-trace-construct-by-supplier(.,$imvert-document)"/>
                   
                   <xsl:sequence select="imf:report-error($client-attribute,
                       not($allow-multiple-suppliers) and position() gt 2,
                       'Multiple suppliers found',
                       ())"/>
                   
                   <xsl:sequence select="imf:check-type-related($client-attribute,$supplier-attribute)"/>
               
               </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
    
    <xsl:template match="imvert:association">
        <xsl:param name="supplier-class"/>
        <xsl:variable name="client-association" select="."/>
        <xsl:variable name="supplier-associations" select="imf:get-trace-suppliers-for-construct($client-association,1)"/>
        
        <xsl:choose>
            <xsl:when test="empty($client-association/imvert:trace)">
                <!-- no trace so no compare neccessary -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$supplier-associations">
                    <xsl:variable name="supplier-association" select="imf:get-trace-construct-by-supplier(.,$imvert-document)"/>
                    
                    <xsl:sequence select="imf:report-error($client-association,
                        not($allow-multiple-suppliers) and position() gt 2,
                        'Multiple suppliers found',
                        ())"/>
                    <xsl:sequence select="imf:check-type-related($client-association,$supplier-association)"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>    
        
    </xsl:template>
    
    <xsl:template match="*|text()">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:function name="imf:check-type-related" as="element()*">
        <xsl:param name="client"/> 
        <xsl:param name="supplier"/>
        <!-- both parms are imvert:attribute or imvert:association -->
        <xsl:choose>
            <xsl:when test="not($supplier)">
                <!-- okay; assume the property is new. -->
            </xsl:when>
            <xsl:when test="empty($client/imvert:baretype) and empty($supplier/imvert:baretype)">
                <!-- this is an enum; skip; this is dealt with elsewhere -->
            </xsl:when>
            <xsl:when test="empty($supplier/imvert:type-id) and empty($client/imvert:type-id)">
                <!-- compare base types -->
                <xsl:sequence select="imf:check-baretype-related($client,$supplier)"/>
            </xsl:when>
            <xsl:when test="$supplier/imvert:type-id and $client/imvert:type-id">
                <!-- compare class-based types -->
                <xsl:sequence select="imf:check-classtype-related($client,$supplier)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-warning($client,true(),
                    'Cannot compare client type [1] to  supplier type [2]; types may be incompatible.',
                    ($client/imvert:type-name, $supplier/imvert:type-name))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:check-baretype-related" as="element()*">
        <xsl:param name="client"/>
        <xsl:param name="supplier"/>
        <!-- both parms are imvert:attribute or imvert:association -->
        <xsl:variable name="supplier-is-string" select="$supplier/imvert:type-name = 'scalar-string'"/>
        <xsl:variable name="supplier-is-int" select="$supplier/imvert:type-name = 'scalar-integer'"/>
        <xsl:variable name="supplier-is-dec" select="$supplier/imvert:type-name = 'scalar-decimal'"/>
        
        <xsl:choose>
            <xsl:when test="$client/imvert:type-name = 'scalar-string'">
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
            <xsl:when test="$client/imvert:type-name = 'scalar-integer'">
                <xsl:sequence select="imf:report-error($client,not($supplier-is-int),
                    'Client type [1] is not a(n) [2]', 
                    ('scalar-integer', $supplier/imvert:type-name))"/>
                <xsl:sequence select="imf:report-error($client,$supplier/imvert:total-digits and not($client/imvert:total-digits),
                    'Client type size must be specified')"/>
                <xsl:sequence select="imf:report-error($client,xs:integer($client/imvert:total-digits) gt xs:integer($supplier/imvert:total-digits),
                    'Client type size must be equal or smaller than [1]',
                    ($supplier/imvert:total-digits))"/>
            </xsl:when>
            <xsl:when test="$client/imvert:type-name = 'scalar-decimal'">
                <xsl:sequence select="imf:report-error($client,not($supplier-is-dec),
                    'Client type [1] is not a [2].', ('scalar-decimal',$supplier/imvert:type-name))"/>
                <xsl:sequence select="imf:report-error($client,xs:integer($client/imvert:total-digits) gt xs:integer($supplier/imvert:total-digits),
                    'Client type size must be equal or smaller than [1]',($supplier/imvert:total-digits))"/>
                <xsl:sequence select="imf:report-error($client,xs:integer($client/imvert:faction-digits) gt xs:integer($supplier/imvert:total-digits),
                    'Client type size must be equal or smaller than [1]',($supplier/imvert:fraction-digits))"/>
            </xsl:when>
            <xsl:when test="$client/imvert:type-name = ('scalar-date', 'scalar-datetime', 'scalar-time', 'scalar-boolean', 'scalar-year', 'scalar-month', 'scalar-day', 'scalar-indic')">
                <xsl:sequence select="imf:report-error($client,not($client/imvert:type-name = $supplier/imvert:type-name),
                    'Client type [1] is not equal to supplier type [2].', 
                    ($client/imvert:type-name, $supplier/imvert:type-name))"/>
            </xsl:when>
            <xsl:when test="$client/imvert:type-name = ('scalar-postcode')">
                <!-- no rules defined yet -->
            </xsl:when>
            <xsl:when test="$client/imvert:type-name = ('scalar-uri')">
                <!-- no rules defined yet -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-warning($client,true(),
                    'Cannot compare client [1] to supplier [2] because no rules are defined for the client type',
                    ($client/imvert:type-name, $supplier/imvert:type-name))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:check-classtype-related" as="element()*">
        <xsl:param name="client"/> <!-- a property -->
        <xsl:param name="supplier"/> <!-- a property -->
        
        <!-- bepaal waar de applicatie waarin de supplier voorkomt als imvert file beschikbaar is -->
        <xsl:variable name="supplier-application" select="root($supplier)/imvert:packages"/>
        <xsl:variable name="supplier-doc-subpath" select="imf:get-trace-supplier-subpath($supplier-application/imvert:project,$supplier-application/imvert:application,$supplier-application/imvert:release)"/>
        <xsl:variable name="supplier-doc" select="imf:get-trace-supplier-document($supplier-doc-subpath)"/>
        
        <xsl:variable name="client-defining-class" select="imf:get-construct-by-id($client/imvert:type-id)"/>
        <xsl:variable name="supplier-defining-class" select="imf:get-construct-by-id($supplier/imvert:type-id,$supplier-doc)"/>
        
        <xsl:choose>
            <xsl:when test="empty($supplier-doc)">
                <!-- The supplier package is not defined. This is already signalled.-->
            </xsl:when>
            <xsl:when test="exists($supplier-defining-class)">
                <?x
                <!-- all classes defined by supplier -->
                <xsl:variable name="supplier-classes" select="$supplier-doc//imvert:class"/>
                
                <xsl:variable name="supplier-defining-subclass" select="imf:get-subclasses($supplier-defining-class,$supplier-classes)"/>
                <xsl:variable name="client-defining-superclass" select="imf:get-superclasses($client-defining-class)"/>
                
                <!-- 
                    for each class that occurs in client as well as supplier, 
                    check if all supertypes also occur in client and supplier 
                --> 
                <!-- TODO Enhance / supertype check in derivation -->
                ?>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:report-error($client,true(),
                    'The supplier could not be found at [1].', $supplier-doc-subpath)"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>
    
</xsl:stylesheet>
