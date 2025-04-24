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
  
    <xsl:import href="extension/Imvert-common-text.xsl"/>
    
    <!-- The current runtime parms.xml file -->
    <xsl:variable name="configuration" select="imf:document($xml-configuration-url,true())"/>
  
    <xsl:variable name="configuration-owner-name" select="imf:get-config-string('system','configuration-owner-file')"/>
    <xsl:variable name="configuration-metamodel-name" select="imf:get-config-string('system','configuration-metamodel-file')"/>
    <xsl:variable name="configuration-tvset-name" select="imf:get-config-string('system','configuration-tvset-file')"/>
    <xsl:variable name="configuration-notesrules-name" select="imf:get-config-string('system','configuration-notesrules-file')"/>
    <xsl:variable name="configuration-docrules-name" select="imf:get-config-string('system','configuration-docrules-file')"/>
    <xsl:variable name="configuration-versionrules-name" select="imf:get-config-string('system','configuration-versionrules-file')"/>
    <xsl:variable name="configuration-visuals-name" select="imf:get-config-string('system','configuration-visuals-file')"/>
    
    <xsl:variable name="configuration-xmlschemarules-name" select="imf:get-config-string('system','configuration-xmlschemarules-file')"/>
    <xsl:variable name="configuration-jsonschemarules-name" select="imf:get-config-string('system','configuration-jsonschemarules-file')"/>
    <xsl:variable name="configuration-shaclrules-name" select="imf:get-config-string('system','configuration-shaclrules-file')"/>
    <xsl:variable name="configuration-skosrules-name" select="imf:get-config-string('system','configuration-skosrules-file')"/>
    
    <xsl:variable name="configuration-file" select="imf:document(imf:get-config-string('properties','WORK_CONFIG_FILE'),true())"/>
    
    <xsl:variable name="configuration-owner-file" select="$configuration-file/config/project-owner"/>
    <xsl:variable name="configuration-metamodel-file" select="$configuration-file/config/metamodel"/>
    <xsl:variable name="configuration-tvset-file" select="$configuration-file/config/tagset"/>
    <xsl:variable name="configuration-notesrules-file" select="$configuration-file/config/notes-rules"/>
    <xsl:variable name="configuration-docrules-file" select="$configuration-file/config/doc-rules"/>
    <xsl:variable name="configuration-versionrules-file" select="$configuration-file/config/version-rules"/>
    <xsl:variable name="configuration-visuals-file" select="$configuration-file/config/visuals"/>
    <xsl:variable name="configuration-prologue" select="$configuration-file/config/prologue"/>

    <xsl:variable name="configuration-xmlschemarules-file" select="$configuration-file/config/xmlschema-rules"/>
    <xsl:variable name="configuration-jsonschemarules-file" select="$configuration-file/config/jsonschema-rules"/>
    <xsl:variable name="configuration-shaclrules-file" select="$configuration-file/config/shacl-rules"/>
    <xsl:variable name="configuration-skosrules-file" select="$configuration-file/config/skos-rules"/>
    
    <xsl:variable name="configuration-i3n-name" select="imf:get-config-string('system','configuration-i3n-file')"/>
    <xsl:variable name="configuration-i3n-file" select="imf:document($configuration-i3n-name,true())"/>
    
    <xsl:variable name="all-scalars" select="$configuration-metamodel-file//scalars/scalar"/>
    
    <xsl:variable name="concept-uri-template" select="imf:get-config-parameter('concept-uri-template')"/>
    <xsl:variable name="concept-uri-resolve" select="imf:boolean(imf:get-config-string('cli','resolveconcepturi','false'))"/>
    
    <xsl:function name="imf:get-config-xmlschemarules" as="element(xmlschema-rules)?">
        <xsl:sequence select="$configuration-xmlschemarules-file"/>
    </xsl:function>

    <xsl:function name="imf:get-config-jsonschemarules" as="element(jsonschema-rules)?">
        <xsl:sequence select="$configuration-jsonschemarules-file"/>
    </xsl:function>
    
    <xsl:function name="imf:get-config-tagged-values" as="element(tv)*">
        <xsl:sequence select="$configuration-tvset-file//tagged-values/tv"/>
    </xsl:function>
    
    <xsl:function name="imf:get-config-parameter" as="item()*">
        <xsl:param name="parameter-name" as="xs:string"/>
        <xsl:param name="must-exist" as="xs:boolean"/>
        <xsl:variable name="v" select="$configuration-owner-file/parameter[@name=$parameter-name]/node()"/>
        <xsl:choose>
            <xsl:when test="exists($v)">
                <xsl:sequence select="$v"/>
            </xsl:when>
            <xsl:when test="$must-exist">
                <xsl:sequence select="imf:msg('FATAL','No such parameter [1]', $parameter-name)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- nothing -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-config-parameter" as="item()*">
       <xsl:param name="parameter-name"/>
       <xsl:sequence select="imf:get-config-parameter($parameter-name,true())"/>
    </xsl:function>
    
    <xsl:function name="imf:get-config-has-owner" as="xs:boolean">
        <xsl:sequence select="exists($configuration-owner-file)"/>
    </xsl:function>

    <!-- return the ID of all stereotype names passed (in the current language) -->
    <xsl:function name="imf:get-stereotypes-ids">
        <xsl:param name="names"/>
        <xsl:sequence select="$configuration-metamodel-file//stereotypes/stereo[name[@lang=$language]=$names]/@id"/>
    </xsl:function>

    <!-- true when any stereotype passed identifies a top-level class. -->
    <xsl:function name="imf:get-config-stereotype-is-toplevel">
        <xsl:param name="ids" as="xs:string*"/>
        <xsl:variable name="v" select="$configuration-metamodel-file//stereotypes/stereo[@id = $ids]"/>
        <xsl:sequence select="imf:boolean($v/toplevel)"/>
    </xsl:function>
    
    <!-- true when any stereotype passed identifies a primary construct, i.e. the stereotype is the primary way to describe the construct and cannot be mixed with other primary stereotypes -->
    <xsl:function name="imf:get-config-stereotype-is-primary" as="xs:boolean">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="imf:boolean(normalize-space($configuration-metamodel-file//stereotypes/stereo[@id = $id]/@primary))"/>
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
                <xsl:sequence select="imf:msg('FATAL','Stereotypes is/are not defined: [1]', imf:string-group($names))"/>
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
                <xsl:sequence select="imf:msg('FATAL','No such stereotype(s): [1] ', imf:string-group($names))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Return all possible stereotype names allowed on the construct passed. 
        Eg. pass "class", returns ("objecttype", "gegevensgroeptype",...)
    -->
    <xsl:function name="imf:get-config-stereotype-names" as="xs:string*">
        <xsl:param name="construct-names" as="xs:string*"/>
        <xsl:sequence select="$configuration-metamodel-file//stereotypes/stereo[construct = $construct-names]/name"/>
    </xsl:function>
    
    <!-- 
        Return true when the stereotype name is deprecated.
        
        Pass the normalized stereotype name.
    -->
    <xsl:function name="imf:get-config-stereotype-name-deprecated" as="xs:boolean">
        <xsl:param name="norm-name" as="xs:string"/>
        <xsl:sequence select="imf:boolean($configuration-metamodel-file//stereotypes/stereo/name[. = $norm-name]/@deprecated)"/>
    </xsl:function>
    
    <!-- 
        Return the entity-relation-constraint on the stereotype.
        
        Pass the normalized stereotype name.
    -->
    <xsl:function name="imf:get-config-stereotype-entity-relation-constraint" as="xs:string*">
        <xsl:param name="names" as="xs:string*"/>
        <xsl:variable name="stereo" select="$configuration-metamodel-file//stereotypes/stereo[name = $names]"/>
        <xsl:variable name="r" select="$stereo/entity-relation-constraint/relation[@lang=$language]"/>
        <xsl:choose>
            <xsl:when test="$r">
                <xsl:sequence select="$r"/>
            </xsl:when>
            <xsl:when test="empty($stereo)">
                <xsl:sequence select="imf:msg('ERROR','No such stereotype(s): [1] ', imf:string-group($names))"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Return the normalized names of the tagged values as found in the source, as expected by the configuration.
        Pass the ID's of the tagged values.
        
        Example:
         get the tagged value with id "CFG-TV-POSITION". 
         If language is nl,
         then the function returns "positie" (the normalized dutch name).
    -->
    <xsl:function name="imf:get-config-tagged-values" as="xs:string*">
        <xsl:param name="ids" as="xs:string*"/>
        <xsl:param name="must-exist" as="xs:boolean"/>
        <xsl:variable name="v" select="$configuration-tvset-file//tagged-values/tv[@id = $ids]/name[@lang=$language]"/>
        <xsl:choose>
            <xsl:when test="exists($v)">
                <xsl:sequence select="for $c in $v return string($c)"/>
            </xsl:when>
            <xsl:when test="$must-exist">
                <xsl:sequence select="imf:msg('ERROR','Tagged value is/are not defined: [1]', string-join($ids,', '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'#unknown'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="imf:get-config-tagged-values" as="xs:string*">
        <xsl:param name="ids" as="xs:string*"/>
        <xsl:sequence select="imf:get-config-tagged-values($ids,false())"/>
    </xsl:function>
    
    <!-- 
        Return the IDs of all tagged values that are in scope of the construct passed, i..e that can be declared on that construct.
    -->
    <xsl:function name="imf:get-config-applicable-tagged-value-ids" as="xs:string*">
        <xsl:param name="construct" as="element()"/>
        <xsl:variable name="stereotype-names" select="$construct/imvert:stereotype"/>
 
        <xsl:variable name="tvs" select="$configuration-tvset-file//tagged-values/tv[stereotypes/stereo = $stereotype-names]"/>
        <xsl:for-each-group select="$tvs" group-by="@id">
            <xsl:value-of select="current-grouping-key()"/>
        </xsl:for-each-group>
    </xsl:function>
        
    <!-- 
        Return all possible scalar names (such as AN or DT)
     
        Language specific
    -->
    <xsl:function name="imf:get-config-scalar-names" as="xs:string*">
        <xsl:sequence select="$configuration-metamodel-file//scalars/scalar/name[@lang=($language,'#all')]"/>
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
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="scheme" as="xs:string"/>
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
            <xsl:when test="$scheme = 'enum-name'">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$scheme = 'tv-name'">
                <xsl:value-of select="imf:get-normalized-name-sub($name,'T',true())"/>
            </xsl:when>
            <xsl:when test="$scheme = 'tv-name-ea'">
                <xsl:value-of select="normalize-space(lower-case($name))"/>
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
            <xsl:when test="$scheme = 'element-name'">
                <!-- the name of an element may not contain * or ? or the like -->
                <!--xsl:variable name="translated-name" select="imf:extract(normalize-space(translate($name, '/', '-')),'[A-Za-z0-9_:][A-Za-z0-9_\.\-:]+')"/>
                <xsl:value-of select="concat(lower-case(substring($translated-name,1,1)),substring($translated-name,2,string-length($translated-name)-1))"/-->
                
                
                <xsl:variable name="translated-name" select="imf:extract(translate($name, '/', '-'),'[A-Za-z0-9_:][A-Za-z0-9_\s\.\-:]+')"/>
                <xsl:value-of select="imf:get-normalized-name-sub($translated-name,'E',true())"/>
            </xsl:when>
            <xsl:when test="$scheme = 'json-bp-name'">
                <!-- the name of a Json Best Practices name is any name, as found, no normalizations -->
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$scheme = 'type-name'">
                <xsl:variable name="nameWithoutType">
                    <xsl:choose>
                        <xsl:when test="contains($name,'class_')"><xsl:value-of select="substring-after($name,'class_')"/></xsl:when>
                        <xsl:when test="contains($name,'association_')"><xsl:value-of select="substring-after($name,'association_')"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="$name"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!-- the name of an element may not contain * or ? or the like -->
                <xsl:variable name="translated-name" select="imf:extract(normalize-space(translate($nameWithoutType, '/', '-')),'[A-Za-z0-9_:][A-Za-z0-9_\.\-:]+')"/>
                <xsl:value-of select="concat(upper-case(substring($translated-name,1,1)),substring($translated-name,2,string-length($translated-name)-1))"/>
            </xsl:when>
            <xsl:when test="$scheme = 'addition-relation-name'">
                <xsl:value-of select="concat(upper-case(substring($name,1,1)),substring($name,2,string-length($name)-1))"/>
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
    <xsl:variable name="naming-convention-element" select="($configuration-metamodel-file//naming/element/format)[last()]"/>
    
    <xsl:function name="imf:get-normalized-name-sub" as="xs:string">
        <xsl:param name="name-as-found" as="xs:string"/>
        <xsl:param name="name-type" as="xs:string"/> <!-- P(ackage), C(lass), p(R)operty), (T)agged value, (E)lement name -->
        <xsl:param name="metamodel-based" as="xs:boolean"/> <!-- when metamodel, then stricter rules; otherwise return an XML schema valid form -->
        
        <xsl:variable name="name-no-diacrits" select="imf:strip-accents($name-as-found)"/>
        
        <xsl:variable name="naming-convention" select="
            if ($name-type = 'P')  then $naming-convention-package
            else if ($name-type = 'C')  then $naming-convention-class 
            else if ($name-type = 'R')  then $naming-convention-property
            else if ($name-type = 'T')  then $naming-convention-tv
            else if ($name-type = 'E')  then $naming-convention-element
            else '#unknown'
            "/>
        
        <xsl:choose>
            <xsl:when test="empty($naming-convention)">
                <xsl:sequence select="imf:msg('FATAL','Missing or invalid configuration for naming convention at metamodel: [1]', ($configuration-metamodel-name))"/>
            </xsl:when>
            <xsl:when test="$naming-convention = '#unknown'">
                <xsl:sequence select="imf:msg('FATAL','Invalid configuration for naming convention: construct is [1] at convention [2]', ($name-type,$naming-convention))"/>
            </xsl:when>
            <xsl:when test="$naming-convention = 'AsIs'">
                <xsl:value-of select="$name-as-found"/>
            </xsl:when>
            <xsl:when test="$naming-convention = 'lowercase'">
                <xsl:value-of select="lower-case($name-no-diacrits)"/>
            </xsl:when>
            <xsl:when test="$naming-convention = 'Upperstart'">
                <xsl:value-of select="concat(upper-case(substring($name-no-diacrits,1,1)), substring($name-no-diacrits,2))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="metamodel-form">
                    <xsl:variable name="parts" select="tokenize(normalize-space($name-no-diacrits),'[^A-Za-z0-9_\.]+')"/>
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
                <xsl:value-of select="imf:extract(if ($metamodel-based) then $metamodel-form else $name-no-diacrits,'[A-Za-z0-9_\-\.]+')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--
        Pass a name found in some specification, and name(s) expected, and check if the names match according to a naming scheme.
    -->
    <xsl:function name="imf:name-match" as="xs:boolean">
        <xsl:param name="found-name" as="xs:string?"/>
        <xsl:param name="expected-name" as="xs:string*"/>
        <xsl:param name="scheme" as="xs:string"/>
        <xsl:sequence select="imf:get-normalized-name(string($found-name),$scheme) = (for $n in $expected-name return imf:get-normalized-name($n,$scheme))"/>
    </xsl:function>
    
    <!-- return normalized string value, or HTML content when applicable -->
    <xsl:function name="imf:get-tagged-value-norm-prepare" as="item()*"> 
        <xsl:param name="value" as="xs:string?"/>
        <xsl:param name="norm" as="xs:string?"/>
        <xsl:if test="normalize-space($value)">
            <xsl:sequence select="imf:get-tagged-value-norm-by-scheme($value,$norm,'tv')"/>
        </xsl:if>
    </xsl:function>
    
    <!-- 
        Get the normalized value for a tagged value passed.  Pass the value itself (not the tv construct).
        A normalization rule is a named rule, and the normalization schema is a name of a predefined schem. Currently only tv is recognized. Example (scheme / rule):
        •	Tv / Space – normalized space.
        •	Tv / Note – pass as-is
        •	Tv / Compact – extract letters and digits, convert to upper case. 
        When no rule is specified, return the value as-is.
    -->
    <xsl:function name="imf:get-tagged-value-norm-by-scheme" as="xs:string?">
        <xsl:param name="value"/>
        <xsl:param name="normalization-rule"/> <!-- e.g. "space" -->
        <xsl:param name="normalization-scheme"/> <!-- e.g. "tv" -->
        <xsl:choose>
            <xsl:when test="not(normalize-space($normalization-rule))">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'space'">
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:when>
            <!--<xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'case'">
                <xsl:value-of select="normalize-space($value)"/>
            </xsl:when>-->
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'note'"><!-- dit kan een notitie veld zijn of een memo veld! -->
                <xsl:value-of select="imf:import-ea-note($value)"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'compact'">
                <xsl:value-of select="imf:extract(upper-case($value),'[A-Z0-9]+')"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'concept'">
                <xsl:value-of select="imf:get-concept-by-URI-or-name($value)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR','Unknown normalization rule [1] in scheme [2], for value [3]', ($normalization-rule,$normalization-scheme,$value))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- TODO in de configuratie moteten @id alleen worden toegekend aan constructs die dat ID hebben, niet aan verwijzingen daarnaar. Overal doorvoeren! -->
    <xsl:function name="imf:get-config-name-by-id" as="xs:string*">
        <xsl:param name="id" as="xs:string"/> <!-- any ID -->
        <xsl:sequence select="distinct-values($configuration-file//*[@id=$id]/name[@lang=($language,'#all')])"/>
    </xsl:function>
    
    <!-- return all nodes the result from parsing the EA note string. This is a sequence of text line .-->  
    <xsl:function name="imf:import-ea-note" as="item()*">
        <xsl:param name="note-ea" as="xs:string"/>
        <xsl:value-of select="$note-ea"/><!-- pass as-is -->
    </xsl:function>
    
    <!--
        Translate a term based on configured translation table.
        This function may be called from within plugin modeldoc stylesheets
    -->
    <xsl:function name="imf:translate-i3n" as="xs:string">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>
        <xsl:param name="default" as="xs:string?"/>
        <xsl:variable name="trans" select="($configuration-i3n-file//item[key=$key]/trans[@lang = $lang])[last()]"/>
        <xsl:variable name="debug-string" select="if (exists($stylesheet-code) and imf:debug-mode($stylesheet-code)) then ('[key:' || $key || ']') else ''"/>
        <xsl:value-of select="if (exists($trans)) then ($trans || $debug-string) else if (exists($default)) then ($default || $debug-string) else concat('[TODO: ', $key, ']')"/>
    </xsl:function>
    
    <xsl:function name="imf:get-concept-by-URI-or-name" as="xs:string?">
        <xsl:param name="concept" as="xs:string"/>
        <xsl:variable name="is-global-uri" select="matches($concept,'^https?:.*$')"/>
        <xsl:variable name="create-global-uri" select="replace($concept-uri-template,'\[concept\]',$concept)"/>
        <xsl:variable name="uri" select="if ($is-global-uri) then $concept else $create-global-uri"/>
        <xsl:if test="$concept-uri-resolve and empty(imf:document($uri,false()))">
            <xsl:sequence select="imf:msg('WARNING','The concept URI [1] cannot be resolved', ($uri))"/>
        </xsl:if>
        <xsl:value-of select="$uri"/>
    </xsl:function>
    
    <xsl:function name="imf:parse-memo" as="xs:string*">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:sequence select="tokenize($value,'\n')"/>
    </xsl:function>

</xsl:stylesheet>
