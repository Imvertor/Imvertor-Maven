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
    xmlns:UML="VERVALLEN"
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-history="http://www.imvertor.org/schema/history"
    xmlns:imvert-appconfig="http://www.imvertor.org/schema/appconfig"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
  
    <!-- The current runtime parms.xml file -->
    <xsl:variable name="configuration" select="imf:document($xml-configuration-url)"/>
    
    <xsl:variable name="configuration-owner-name" select="imf:get-config-string('system','configuration-owner-file')"/>
    <xsl:variable name="configuration-metamodel-name" select="imf:get-config-string('system','configuration-metamodel-file')"/>
    <xsl:variable name="configuration-schemarules-name" select="imf:get-config-string('system','configuration-schemarules-file')"/>
    <xsl:variable name="configuration-tvset-name" select="imf:get-config-string('system','configuration-tvset-file')"/>
    
    <xsl:variable name="configuration-owner-file" select="imf:prepare-config(imf:document($configuration-owner-name))"/>
    <xsl:variable name="configuration-metamodel-file" select="imf:prepare-config(imf:document($configuration-metamodel-name))"/>
    <xsl:variable name="configuration-schemarules-file" select="imf:prepare-config(imf:document($configuration-schemarules-name))"/>
    <xsl:variable name="configuration-tvset-file" select="imf:prepare-config(imf:document($configuration-tvset-name))"/>
    
    <xsl:function name="imf:get-config-tagged-values" as="element(tv)*">
        <xsl:sequence select="$configuration-tvset-file//tagged-values/tv"/>
    </xsl:function>
    
    <xsl:function name="imf:get-config-parameter" as="item()*">
        <xsl:param name="parameter-name"/>
        <xsl:variable name="v" select="$configuration-owner-file/parameter[@name=$parameter-name]/node()"/>
        <xsl:choose>
            <xsl:when test="exists($v)">
                <xsl:sequence select="$v"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('FATAL','No such parameter [1]', $parameter-name)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-config-has-owner" as="xs:boolean">
        <xsl:sequence select="exists($configuration-owner-file)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-config-stereotypes" as="xs:string*">
        <xsl:param name="names" as="xs:string*"/>
        <xsl:param name="must-exist" as="xs:boolean"/>
        <xsl:variable name="v" select="$configuration-metamodel-file//stereotypes/stereo[@id = $names]/name"/>
        <xsl:choose>
            <xsl:when test="exists($v)">
                <xsl:sequence select="$v"/>
            </xsl:when>
            <xsl:when test="$must-exist">
                <xsl:sequence select="imf:msg('FATAL','Stereotypes is/are not defined: [1]', string-join($names,', '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'#unknown'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="imf:get-config-stereotypes" as="xs:string*">
        <xsl:param name="names" as="xs:string*"/>
       <xsl:sequence select="imf:get-config-stereotypes($names,false())"/>
    </xsl:function>
    
    <!-- 
        Return the construct names (designations) on which a provided stereotype may be declared. 
        Eg. pass "stereotype-name-objecttype",  returns "class"
    -->
    <xsl:function name="imf:get-config-stereotype-designation" as="xs:string*">
        <xsl:param name="names" as="xs:string*"/>
        <xsl:variable name="v" select="$configuration-metamodel-file//stereotypes/stereo[@id = $names]/construct"/>
        <xsl:choose>
            <xsl:when test="$v">
                <xsl:sequence select="$v"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('FATAL','No such stereotype(s) [1] ', string-join($names,', '))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Return all possibkle stereotype names allowed on the construct passed. 
        Eg. pass "class", returns ("objecttype", "gegevensgroeptype",...)
    -->
    <xsl:function name="imf:get-config-stereotype-names" as="xs:string*">
        <xsl:param name="construct-names" as="xs:string*"/>
        <xsl:sequence select="$configuration-metamodel-file//stereotypes/stereo[construct = $construct-names]/name"/>
    </xsl:function>
    
    <!-- 
        Return true when the stereotype name is deprecated.
    -->
    <xsl:function name="imf:get-config-stereotype-name-deprecated" as="xs:boolean">
        <xsl:param name="norm-name" as="xs:string"/>
        <xsl:sequence select="imf:boolean($configuration-metamodel-file//stereotypes/stereo/name[. = $norm-name]/@deprecated)"/>
    </xsl:function>
    
    <!-- name normalization on all configuration files -->
    
    <xsl:function name="imf:prepare-config">
        <xsl:param name="document" as="document-node()?"/>
        <xsl:apply-templates select="$document" mode="prepare-config"/>
    </xsl:function>
    
    <xsl:template match="tv/name" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'tv-name')"/>
    </xsl:template>
    
    <xsl:template match="tv/declared-values/value" mode="prepare-config">
        <xsl:variable name="norm" select="(../../@norm,'space')[1]"/>
        <xsl:sequence select="imf:prepare-config-tagged-value-element(.,$norm)"/>
    </xsl:template>
    
    <xsl:template match="tv/stereotypes/stereo" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'stereotype-name')"/>
    </xsl:template>
    
    <xsl:template match="stereotypes/stereo/name" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'stereotype-name')"/>
    </xsl:template>
    
    <xsl:function name="imf:prepare-config-name-element" as="element()?">
        <xsl:param name="name-element" as="element()"/>
        <xsl:param name="name-type" as="xs:string"/>
        <xsl:if test="$name-element/@lang = ($language,'#all')">
            <xsl:element name="{name($name-element)}">
                <xsl:apply-templates select="$name-element/@*" mode="prepare-config"/>
                <xsl:attribute name="original" select="$name-element/text()"/>
                <xsl:value-of select="imf:get-normalized-name($name-element,$name-type)"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:prepare-config-tagged-value-element" as="element()?">
        <xsl:param name="value-element" as="element()"/>
        <xsl:param name="norm-rule" as="xs:string"/>
        <xsl:if test="($value-element/ancestor-or-self::*/@lang)[1] = ($language,'#all')">
            <xsl:element name="{name($value-element)}">
                <xsl:apply-templates select="$value-element/@*" mode="prepare-config"/>
                <xsl:attribute name="original" select="$value-element/text()"/>
                <xsl:value-of select="imf:get-tagged-value-norm-prepare($value-element,$norm-rule)"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <!-- default -->
    <xsl:template match="@*|node()" mode="prepare-config">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="prepare-config"/>
            <xsl:apply-templates select="node()" mode="prepare-config"/>
        </xsl:copy>
    </xsl:template>
 
    <xsl:function name="imf:get-normalized-names" as="xs:string*">
        <xsl:param name="names"/>
        <xsl:param name="scheme"/>
        <xsl:sequence select="for $n in $names return imf:get-normalized-name($n,$scheme)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-normalized-name" as="xs:string">
        <xsl:param name="name"/>
        <xsl:param name="scheme"/>
        <xsl:choose>
            <xsl:when test="$scheme = 'package-name'">
                <xsl:value-of select="imf:get-normalized-name-sub($name,'P',true())"/>
            </xsl:when>
            <xsl:when test="$scheme = 'class-name'">
                <xsl:value-of select="imf:get-normalized-name-sub($name,'C',true())"/>
            </xsl:when>
            <xsl:when test="$scheme = 'property-name'">
                <xsl:value-of select="imf:get-normalized-name-sub($name,'R',true())"/>
            </xsl:when>
            <xsl:when test="$scheme = 'tv-name'">
                <xsl:value-of select="imf:get-normalized-name-sub($name,'T',true())"/>
            </xsl:when>
            <xsl:when test="$scheme = 'system-name'">
                <xsl:value-of select="upper-case(normalize-space($name))"/>
            </xsl:when>
            <xsl:when test="$scheme = 'stereotype-name'">
                <xsl:value-of select="upper-case(normalize-space($name))"/>
            </xsl:when>
            <xsl:when test="$scheme = 'baretype-name'">
                <xsl:value-of select="upper-case(normalize-space($name))"/>
            </xsl:when>
            <xsl:when test="$scheme = 'file-name'">
                <!-- the name of a file, not the path! Names may not contain * or ? or the like -->
                <xsl:value-of select="imf:extract(normalize-space($name),'[A-Za-z0-9_\.$\-]+')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('FATAL','Unsupported naming scheme: [1]',$scheme)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:variable name="naming-convention-package" select="($configuration-metamodel-file//naming/package/format)[last()]"/>
    <xsl:variable name="naming-convention-class" select="($configuration-metamodel-file//naming/class/format)[last()]"/>
    <xsl:variable name="naming-convention-property" select="($configuration-metamodel-file//naming/property/format)[last()]"/>
    <xsl:variable name="naming-convention-tv" select="($configuration-metamodel-file//naming/tv/format)[last()]"/>
    
    <xsl:function name="imf:get-normalized-name-sub" as="xs:string">
        <xsl:param name="name-as-found" as="xs:string"/>
        <xsl:param name="name-type" as="xs:string"/> <!-- P(ackage), C(lass), p(R)operty), (T)agged value name -->
        <xsl:param name="metamodel-based" as="xs:boolean"/> <!-- when metamodel, then stricter rules; otherwise return an XML schema valid form -->
        
        <xsl:variable name="naming-convention" select="
            if ($name-type = 'P')  then $naming-convention-package
            else if ($name-type = 'C')  then $naming-convention-class 
            else if ($name-type = 'R')  then $naming-convention-property
            else if ($name-type = 'T')  then $naming-convention-tv
            else '#unknown'
            "/>
        
        <xsl:choose>
            <xsl:when test="empty($naming-convention)">
                <xsl:sequence select="imf:msg('FATAL','Missing or invalid configuration for naming convention at metamodel: [1]', ($configuration-metamodel-name))"/>
            </xsl:when>
            <xsl:when test="$naming-convention = '#unknown'">
                <xsl:sequence select="imf:msg('FATAL','Invalid configuration for naming convention: construct is [1] at convention [2]', ($name-type,$naming-convention))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="metamodel-form">
                    <xsl:variable name="parts" select="tokenize(normalize-space($name-as-found),'[^A-Za-z0-9_]+')"/>
                    <xsl:variable name="frags" as="xs:string*">
                        <xsl:for-each select="$parts">
                            <xsl:choose>
                                <xsl:when test="position() = 1 and starts-with(.,'_') and $naming-convention = 'UpperCamel'">
                                    <xsl:value-of select="concat('_',upper-case(substring(.,2,1)),substring(.,3))"/>
                                </xsl:when>
                                <xsl:when test="position() = 1 and starts-with(.,'_') and $naming-convention = 'LowerCamel'">
                                    <xsl:value-of select="concat('_',lower-case(substring(.,2,1)),substring(.,3))"/>
                                </xsl:when>
                                <xsl:when test="position() = 1 and $naming-convention = 'UpperCamel'">
                                    <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2))"/>
                                </xsl:when>
                                <xsl:when test="position() = 1 and $naming-convention = 'LowerCamel'">
                                    <xsl:value-of select="concat(lower-case(substring(.,1,1)),substring(.,2))"/>
                                </xsl:when>
                                <xsl:when test="$naming-convention = ('UpperCamel','LowerCamel')">
                                    <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:msg('FATAL','Unsupported naming convention: [1]',$naming-convention)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="string-join($frags,'')"/>
                </xsl:variable>
                <xsl:value-of select="imf:extract(if ($metamodel-based) then $metamodel-form else $name-as-found,'[A-Za-z0-9_\-\.]+')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
        Pass a name found in some specification, and name(s) expected, and check if the names match according to a naming scheme.
    -->
    <xsl:function name="imf:name-match" as="xs:boolean">
        <xsl:param name="found-name" as="xs:string"/>
        <xsl:param name="expected-name" as="xs:string*"/>
        <xsl:param name="scheme" as="xs:string"/>
        <xsl:sequence select="imf:get-normalized-name($found-name,$scheme) = (for $n in $expected-name return imf:get-normalized-name($n,$scheme))"/>
    </xsl:function>
    
    <!-- return normalized string value, or HTML content when applicable -->
    <xsl:function name="imf:get-tagged-value-norm-prepare" as="item()*"> 
        <xsl:param name="value" as="xs:string?"/>
        <xsl:param name="norm" as="xs:string?"/>
        <xsl:if test="normalize-space($value)">
            <xsl:sequence select="imf:get-tagged-value-norm-by-scheme($value,$norm,'tv')"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-norm-by-scheme" as="xs:string?">
        <xsl:param name="value"/>
        <xsl:param name="normalization-rule"/>
        <xsl:param name="normalization-scheme"/>
        <xsl:choose>
            <xsl:when test="not(normalize-space($normalization-rule))">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'space'">
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'note'">
                <xsl:value-of select="imf:import-ea-note($value)"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'compact'">
                <xsl:value-of select="imf:extract(upper-case($value),'[A-Z0-9]+')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR','Unknown normalization rule [1] in scheme [2], for value [3]', ($normalization-rule,$normalization-scheme,$value))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- return all nodes the result from parsing the EA note string. This is a sequence of text line .-->  
    <xsl:function name="imf:import-ea-note" as="item()*">
        <xsl:param name="note-ea" as="xs:string"/>
        <xsl:value-of select="$note-ea"/><!-- pass as-is -->
    </xsl:function>
    
</xsl:stylesheet>
