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
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    xmlns:UML="VERVALLEN"
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-history="http://www.imvertor.org/schema/history"
    xmlns:imvert-appconfig="http://www.imvertor.org/schema/appconfig"
    xmlns:imvert-message="http://www.imvertor.org/schema/message"
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	
	xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
	
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="3.0">
      
    <xsl:include href="Imvert-common-parms.xsl"/>
    <xsl:include href="Imvert-common-extension.xsl"/>
    <xsl:include href="Imvert-common-messaging.xsl"/>
    <xsl:include href="Imvert-common-names.xsl"/>
    <xsl:include href="Imvert-common-config.xsl"/>
    <xsl:include href="Imvert-common-data.xsl"/>
    <xsl:include href="Imvert-common-uri.xsl"/>
    <xsl:include href="Imvert-common-keys.xsl"/>
    <xsl:include href="Imvert-common-trace.xsl"/>
    <xsl:include href="Imvert-common-debug.xsl"/>
    
    <xsl:include href="dlogger/DLogger-proxy.xsl"/>
    
    <xsl:include href="../external/relpath_util.xsl"/>
    <xsl:include href="../external/functx.xsl"/>
    
    <xsl:output encoding="UTF-8" method="xml" indent="yes" exclude-result-prefixes="#all"/>
    
    <!-- TODO how to configure this in metamodel? -->
    <xsl:variable name="baretype-pattern-c">(AN|N)</xsl:variable> <!-- D9.2 changed to N9,2 (or N9.2) -->
    <xsl:variable name="baretype-pattern-i">(\d*)</xsl:variable>
    <xsl:variable name="baretype-pattern-ii">([\.,]?)(\d*)</xsl:variable>
    <xsl:variable name="baretype-pattern-p">(\+P)?</xsl:variable>
    <xsl:variable name="baretype-pattern" select="concat('^',$baretype-pattern-c,$baretype-pattern-i,$baretype-pattern-ii,$baretype-pattern-p,'$')"/>
    
    <xsl:variable name="stylesheet-version" select="imf:source-file-version($xml-stylesheet-name)"/>
    <xsl:variable name="stylesheet-code" select="()"/><!-- default stylesheet code -->
    
    <!-- avoid SVN dollar-text-dollar pattern -->
    <xsl:variable name="char-dollar">$</xsl:variable>
    
    <xsl:variable name="name-none">n-o-n-e</xsl:variable>
    
    <xsl:variable name="release-info" as="element(frag)+">
        <frag key="year" value="{substring($application-package-release,1,4)}"/>
        <frag key="month" value="{substring($application-package-release,5,2)}"/>
        <frag key="day" value="{substring($application-package-release,7,2)}"/>
    </xsl:variable>
    
    <xsl:variable name="debug-work-folder-path" select="imf:get-config-string('system','work-debug-folder-path')"/>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="default" as="item()*"/>
        <xsl:param name="as-string" as="xs:boolean"/>
        <xsl:param name="allow-empty" as="xs:boolean"/>
        <xsl:variable name="computed-content" select="if ($content[1]) then $content else if (normalize-space(string($content))) then string($content) else $default" as="item()*"/>
        <xsl:if test="$computed-content[1] or $allow-empty">
            <xsl:element name="{$name}">
                <xsl:choose>
                    <xsl:when test="$as-string">
                        <xsl:value-of select="$computed-content"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$computed-content"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="default" as="item()*"/>
        <xsl:param name="as-string" as="xs:boolean"/>
        <xsl:sequence select="imf:create-output-element($name,$content,$default,$as-string,false())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="default" as="item()*"/>
        <xsl:sequence select="imf:create-output-element($name,$content,$default,true(),false())"/>
    </xsl:function>
   
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:sequence select="imf:create-output-element($name,$content,'',true(),false())"/>
    </xsl:function>
    
    <!-- An element is linkable when the class is <<Objecttype>> 
         but not when all incoming inheritances are static (static), and
         there are no assciations that has this class as the target (lonely), and
         no supertype is linkable (sad).
         
         Also, we assume that a class is not linkable when it has no "identifier" attribute (UML is-id) (anonymous)
         or when the identifier is nillable/voidable (id-voidable).
    -->
    <xsl:function name="imf:is-linkable" as="xs:boolean">
        <xsl:param name="class" as="element()"/>
        <xsl:variable name="class-id" select="$class/imvert:id"/>
        <xsl:variable name="is-objecttype" select="$class/imvert:stereotype/@id = ('stereotype-name-objecttype')"/>
        <xsl:variable name="is-not-static" select="exists($document-classes[imvert:supertype[imvert:type-id=$class-id and not(imvert:stereotype/@id = ('stereotype-name-static-generalization'))]])"/>
        <xsl:variable name="is-not-lonely" select="exists($document-classes[*/*/imvert:type-id=$class-id])"/>
        <!-- is-not-lonely: this may be assocations or attributes; typically object types occur as attribute typs for unions. -->
        <xsl:variable name="is-not-sad" select="exists(for $c in (imf:get-superclasses($class)) return if (imf:is-linkable($c)) then 1 else ())"/>
        
        <!-- IM-432 Relaties niet altijd via ref -->
        <xsl:variable name="id-attribute-inherited" select="($class, imf:get-superclasses($class))/*/imvert:attribute[imvert:is-id='true']" as="element(imvert:attribute)*"/>
        <xsl:variable name="id-attribute-inheriting" select="($class, imf:get-subclasses($class))/*/imvert:attribute[imvert:is-id='true']" as="element(imvert:attribute)*"/>
        <xsl:variable name="is-not-anonymous" select="exists(($id-attribute-inherited,$id-attribute-inheriting))"/>
        <xsl:variable name="is-not-id-voidable" select="not($id-attribute-inherited/imvert:stereotype/@id = ('stereotype-name-voidable'))"/>
        
        <xsl:variable name="voidable-attributes" select="for $a in $id-attribute-inherited return imf:get-tagged-value($a,'##CFG-TV-VOIDABLE')" as="xs:string*"/>
        <xsl:variable name="is-not-id-tv-voidable" select="if ($id-attribute-inherited) then not(imf:boolean($voidable-attributes)) else true()"/>
        
        <xsl:sequence select="$is-objecttype and ($is-not-static or $is-not-lonely or $is-not-sad) and $is-not-anonymous and ($is-not-id-voidable and $is-not-id-tv-voidable)"/>
    </xsl:function>
    
    <!-- return all subclasses (by subtype or substitution), not self -->
    <xsl:function name="imf:get-subclasses" as="element()*">
        <xsl:param name="class" as="element()"/>
        <xsl:param name="classes" as="element()*"/> <!-- all classes of the application -->
        <xsl:variable name="class-id" select="$class/imvert:id"/>
        <xsl:for-each select="$classes[imvert:supertype/imvert:type-id=$class-id]">
            <xsl:sequence select="."/>
            <xsl:sequence select="imf:get-subclasses(.,$classes)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-subclasses" as="element()*">
        <xsl:param name="class" as="element()"/>
        <xsl:sequence select="imf:get-subclasses($class,$document-classes)"/>
    </xsl:function>
    
    <!-- Return the full class definition as an imvert:class element. This is all attributes and associations inherited fom all superclasses. --> 
    <!-- see redmine #487364 -->
    <xsl:function name="imf:get-full-class-definition" as="element(imvert:class)">
        <xsl:param name="class" as="element(imvert:class)"/>
        <xsl:for-each select="$class"> <!-- single -->
            <xsl:variable name="superclasses" select="imf:get-superclasses(.)"/>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:copy-of select="*[empty((self::imvert:attributes,self::imvert:associations))]"/>
                <imvert:attributes>
                    <xsl:for-each-group select="$superclasses/imvert:attributes/imvert:attribute" group-by="imvert:name">
                        <xsl:for-each select="current-group()[last()]"> <!-- single -->
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                                <xsl:attribute name="origin" select="imvert:id"/>
                                <xsl:copy-of select="*"/>
                            </xsl:copy>
                        </xsl:for-each>
                    </xsl:for-each-group>
                    <xsl:copy-of select="imvert:attributes/imvert:attribute"/>
                </imvert:attributes>
                <imvert:associations>
                    <xsl:for-each-group select="$superclasses/imvert:associations/imvert:association" group-by="imvert:name">
                        <xsl:for-each select="current-group()[last()]"> <!-- single -->
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                                <xsl:attribute name="origin" select="imvert:id"/>
                                <xsl:copy-of select="*"/>
                            </xsl:copy>
                        </xsl:for-each>
                    </xsl:for-each-group>
                    <xsl:copy-of select="imvert:associations/imvert:association"/>
                </imvert:associations>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>
   
    <!-- return all immediate subclasses (by subtype or substitution), not self -->
    <xsl:function name="imf:get-immediate-subclasses" as="element()*">
        <xsl:param name="class" as="element()"/>
        <xsl:param name="classes" as="element()*"/> <!-- all classes of the application -->
        <xsl:variable name="class-id" select="$class/imvert:id"/>
        <xsl:for-each select="$classes[imvert:supertype/imvert:type-id=$class-id]">
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- return all subclasses by substitution, not self -->
    <xsl:function name="imf:get-substitutionclasses" as="element()*">
        <xsl:param name="class" as="element()"/>
        <xsl:param name="classes" as="element()*"/> <!-- all classes of the application -->
        <xsl:variable name="class-id" select="$class/imvert:id"/>
        <xsl:for-each select="$classes[imvert:substitution/imvert:supplier-id=$class-id]">
            <xsl:sequence select="."/>
            <xsl:sequence select="imf:get-substitutionclasses(.,$classes)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-substitutionclasses" as="element()*">
        <xsl:param name="class" as="element()"/>
        <xsl:sequence select="imf:get-substitutionclasses($class,$document-classes)"/>
    </xsl:function>
    
    <!-- return all superclasses of this class, i.e. in complete type hierarchy -->
    <xsl:function name="imf:get-superclasses" as="element()*"> <!-- imvert:class* -->
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="supers" select="imf:get-superclass($this)"/> <!-- immediate superclass; may be multiple -->
        <xsl:for-each select="$supers">
            <!-- this should be a class, but if not so, allow validation to signal this -->
            <xsl:sequence select="(., imf:get-superclasses(.))"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- return the direct superclasses of this class -->
    <xsl:function name="imf:get-superclass" as="element(imvert:class)*">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="for $x in $this/imvert:supertype return imf:get-class($x/imvert:type-name,$x/imvert:type-package)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-class" as="element()?">
        <xsl:param name="type-name" as="xs:string?"/>
        <xsl:param name="package-name" as="xs:string?"/> <!-- must be available but may be missing in case of (reported) error -->
        <xsl:sequence select="($document-packages[imvert:name=$package-name]/imvert:class[imvert:name=$type-name])[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-svn-id-info" as="xs:string*">
        <xsl:param name="svnid" as="xs:string*"/>
        <xsl:for-each select="$svnid">
            <xsl:analyze-string select="." regex="^\$(.*)\$$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-name" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:value-of select="imf:compile-construct-name(imf:get-construct-name-frags($this))"/>
    </xsl:function>
    
    <!-- 
        Haal een element op met de vorm

        <frags name="" pack="" class="" prop="" kind="" alias="" tv=""/>
        
    -->
    <xsl:function name="imf:get-construct-name-frags" as="element(frags)">
        <xsl:param name="this" as="element()"/>
    
        <xsl:variable name="name" select="imf:get-original-names($this)"/>
        <xsl:variable name="package-names" select="imf:get-original-names($this/ancestor-or-self::imvert:package)"/>
        <xsl:variable name="class-name" select="imf:get-original-names($this/ancestor-or-self::imvert:class[1])"/>
        <xsl:variable name="alias" select="$this/imvert:alias"/>
        <xsl:choose>
            <xsl:when test="$this/self::imvert:packages">
                <frags name="{$name}" pack="model:{$this/imvert:application}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:package">
                <frags name="{$name}"  pack="{$name}" alias="{$alias}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:base">
                <frags name="{$name}"  pack="{$name}" alias="{$alias}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:class">
                <frags name="{$name}"  pack="{$package-names}" class="{$name}" alias="{$alias}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:supertype">
                <frags name="{$name}"  pack="{$this/imvert:type-package}" class="{$this/imvert:type-name}" alias="{$alias}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:attribute">
                <frags name="{$name}"  pack="{$package-names}" class="{$class-name}" prop="{$name}" kind="attrib" alias="{$alias}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:association[not(imvert:name)]">
                <xsl:variable name="type" select="concat('..',$this/imvert:type-name)"/>
                <frags name="{$name}"  pack="{$package-names}" class="{$class-name}" prop="{$type}" kind="{imf:get-aggregation($this)}" alias="{$alias}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:association">
                <frags name="{$name}"  pack="{$package-names}" class="{$class-name}" prop="{$name}" kind="{imf:get-aggregation($this)}" alias="{$alias}"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:source | $this/self::imvert:target">
                <xsl:variable name="assoc" select="$this/.."/>
                <xsl:variable name="type" select="concat('{', imf:get-original-names($assoc), ':', $this/imvert:role/@original,'}')"/>
                <frags name="{$name}"  pack="{$package-names}" class="{$class-name}" prop="{$type}" alias="{$alias}" tv=""/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:tagged-value">
                <frags name="{$name}"  pack="{$package-names}" class="{$class-name}" prop="{$name}" alias="{$alias}" tv="{$this/imvert:name}"/>
            </xsl:when>
            <xsl:otherwise>
                <frags name="{$name}"  pack="{$package-names}" class="{$class-name}" prop="{local-name($this)}" alias="{$alias}"/>
            </xsl:otherwise>
        </xsl:choose>
                
    </xsl:function>
    
    <!-- 
        stel de construct name samen op basis van een <frags> element 
    -->
    <xsl:function name="imf:compile-construct-name" as="xs:string">
        <xsl:param name="frags" as="element(frags)"/>
        <xsl:value-of select="imf:compile-construct-name($frags/@pack,$frags/@class,$frags/@prop,$frags/@kind,$frags/@alias,$frags/@tv)"/>
    </xsl:function>
   
    <!-- 
        stel de construct name samen op basis van aangeleverde parameters 
    -->
    <xsl:function name="imf:compile-construct-name" as="xs:string">
        <xsl:param name="package-names" as="xs:string*"/>
        <xsl:param name="class-name" as="xs:string?"/>
        <xsl:param name="property-name" as="xs:string?"/>
        <xsl:param name="property-kind" as="xs:string?"/> <!-- 'attrib' or 'assoc' or null -->
        <xsl:param name="alias" as="xs:string?"/>
        <xsl:param name="tv-name" as="xs:string?"/>
        
        <xsl:variable name="pan" select="if (imf:exists($package-names)) then concat(string-join($package-names,'::'),'::') else ''"/>
        <xsl:variable name="cln" select="if (imf:exists($class-name)) then $class-name else ''"/>
        <xsl:variable name="prn" select="if (imf:exists($property-name)) then concat('.',$property-name) else ''"/>
        <xsl:variable name="prk" select="if (imf:exists($property-kind)) then concat(' (',$property-kind,')') else ''"/>
        <xsl:variable name="ali" select="if (imf:exists($alias)) then concat(' = ',$alias) else ''"/>
        <xsl:variable name="tvn" select="if (imf:exists($tv-name)) then concat(' [',$tv-name,']') else ''"/>
        <xsl:value-of select="concat($pan,$cln,$prn,$prk,$ali,$tvn)"/>
        
        <!--
        <span>
            <xsl:value-of select="$pan"/>
            <b>
                <xsl:value-of select="$cln"/>
                <i>
                    <xsl:value-of select="$prn"/>
                </i>
            </b>
            <xsl:value-of select="$prk"/>
            <xsl:value-of select="$ali"/>
        </span>
        -->
    </xsl:function>  
    
    <xsl:function name="imf:compile-construct-name" as="xs:string">
        <xsl:param name="package-names" as="xs:string*"/>
        <xsl:param name="class-name" as="xs:string?"/>
        <xsl:param name="property-name" as="xs:string?"/>
        <xsl:param name="property-kind" as="xs:string?"/> <!-- 'attrib' or 'assoc' or null -->
        <xsl:sequence select="imf:compile-construct-name($package-names,$class-name,$property-name,$property-kind,(),())"/>
    </xsl:function>  
    
    <xsl:function name="imf:get-canonical-name" as="xs:string?">
        <xsl:param name="found-name" as="xs:string?"/>
        <!-- return as-is -->
        <xsl:value-of select="normalize-space($found-name)"/>
        <!-- <xsl:value-of select="replace(normalize-space($found-name),'\s','_')"/> -->
        <!--<xsl:value-of select="substring-before(concat(normalize-space($found-name),' '),' ')"/>-->
    </xsl:function>
    
    <!-- 
        Return the construct by ID. 
        In case of copy-down, the ID may not be unique, so several constructs (i.e. associations) may have the same ID.
    -->
    <xsl:function name="imf:get-construct-by-id" as="element()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="imf:get-construct-by-id($id,$imvert-document)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-by-id" as="element()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="root" as="node()*"/>
        <xsl:for-each select="$root">
            <xsl:variable name="selected-root" select="."/>
            <xsl:sequence select="if ($selected-root instance of document-node()) then imf:key-imvert-construct-by-id($id,$selected-root) else imf:search-imvert-construct-by-id($id,$selected-root)"/>
        </xsl:for-each>
    </xsl:function>
    
    <!--
        The function imf:get-construct-by-id hides the kind of construct which is requested.
        Since it may be comfortable to see in the code which kind of constructs are requested the following 
        2 functions are created which in fact are aliases of the imf:get-construct-by-id function.
        ATTENTION: Using these functions doesn't prevent getting an element of the kind the function isn't related to.
                   It's only an indication  what kind of elements the code is searching for.
    -->
    <xsl:function name="imf:get-class-construct-by-id" as="element()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="root" as="node()*"/>
        <xsl:sequence select="imf:get-construct-by-id($id,$root)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-association-construct-by-id" as="element()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="root" as="node()*"/>
        <xsl:sequence select="imf:get-construct-by-id($id,$root)"/>
    </xsl:function>
    
    <!-- get the construct by ID where the id supplied is passed as the value of a trace (imvert:trace) -->
    <xsl:function name="imf:get-trace-construct-by-id">
        <xsl:param name="client"/>
        <xsl:param name="supplier-id"/>
        <xsl:param name="document-roots" as="document-node()*"/>
        <xsl:variable name="supplier-id-corrected" select="imf:get-corrected-id($supplier-id,local-name($client))"/>
        <xsl:sequence select="imf:get-construct-by-id($supplier-id-corrected,$document-roots)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-corrected-id">
        <xsl:param name="id"/>
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$normalize-ids">
                <xsl:value-of select="$id"/> <!-- All IDs and references are normalized to the 99.99.99.99.99 format -->
            </xsl:when>
            <xsl:when test="$type = 'class'">
                <xsl:value-of select="$id"/> <!-- EAID_xxx becomes EAID_xxx -->
            </xsl:when>
            <xsl:when test="$type = 'attribute'">
                <xsl:value-of select="$id"/>  <!-- {xxx} becomes {xxx} -->
            </xsl:when>
            <xsl:when test="$type = 'association' and starts-with($id,'EAID_')">
                <xsl:value-of select="$id"/>  <!-- EAID_xxx becomes EAID_xxx ; already transformed in earlier stage -->
            </xsl:when>
            <xsl:when test="$type = 'association'">
                <xsl:value-of select="concat('EAID_',replace(substring($id,2,string-length($id) - 2),'-','_'))"/> <!-- {xx-x} becomes EAID_xx_x -->
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:distinct-nodes" as="element()*">
        <xsl:param name="set" as="element()*"/>
        <xsl:for-each-group select="$set" group-by="generate-id()">
            <xsl:sequence select="."/>
        </xsl:for-each-group>
    </xsl:function>

    <xsl:function name="imf:get-aggregation" as="xs:string">
        <xsl:param name="association" as="element()"/>
        <xsl:variable name="aggregation" select="$association/imvert:aggregation"/>
        <xsl:value-of select="if ($aggregation) then $aggregation else 'assoc'"/>
    </xsl:function>
    
    <!-- return a sequence of folder path and file name taken from a full path --> 
    <xsl:function name="imf:get-folder-path" as="xs:string*">
        <xsl:param name="filepath" as="xs:string"/>
        <xsl:variable name="filepath-normalized" select="replace($filepath,'\\','/')"/>
        <xsl:variable name="indexes" select="functx:index-of-string($filepath-normalized,'/')"/>
        <xsl:sequence select="
            if (empty($indexes)) 
            then ('',$filepath-normalized) 
            else (substring($filepath-normalized,1,$indexes[last()] - 1),substring($filepath-normalized,$indexes[last()] + 1))"/>
    </xsl:function>
    
    <!-- 
        return the relative path to navigate from file1 to file2.
        Example: 
           get-relpath( /a/b/c/F1, /a/d/F2 )
        returns
           ../../d/F2
    -->
    <xsl:function name="imf:get-rel-path" as="xs:string">
        <xsl:param name="filepath1" as="xs:string"/>
        <xsl:param name="filepath2" as="xs:string"/>
        <xsl:variable name="path1" select="imf:get-folder-path($filepath1)"/>
        <xsl:variable name="path2" select="imf:get-folder-path($filepath2)"/>
        <xsl:choose>
            <xsl:when test="$path1 =''">
                <xsl:value-of select="$filepath2"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="rpath" select="ekf:getRelativePath($path1[1], $path2[1])"/>
                <xsl:choose>
                    <xsl:when test="$rpath">
                        <xsl:value-of select="concat($rpath,'/',$path2[2])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$path2[2]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- return the largest value taken from the sequence passed. -->
    <xsl:function name="imf:largest" as="item()?">
        <xsl:param name="seq" as="item()*"/>
        <xsl:sequence select="imf:sort($seq)[last()]"/>
    </xsl:function>
    
    <!-- return the smallest value taken from the sequence passed. -->
    <xsl:function name="imf:smallest" as="item()?">
        <xsl:param name="seq" as="item()*"/>
        <xsl:sequence select="imf:sort($seq)[1]"/>
    </xsl:function>
    
    <!-- sort a sequence in ascending order. -->
    <xsl:function name="imf:sort" as="item()*">
        <xsl:param name="seq" as="item()*"/>
        <xsl:for-each select="$seq">
            <xsl:sort select="." order="ascending"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:function>    
    
    <xsl:function name="imf:debug-path" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="if ($this/parent::*) then concat(imf:debug-path($this/parent::*),'/',name($this)) else name($this)"/>
    </xsl:function>
    
    <!-- the debug mode is true when
        
        Debugging is activated by CLI,
        and 
        Debugmode is same as step alias, or the debugmode holds the mode #ALL
    -->
    <xsl:function name="imf:debug-mode" as="xs:boolean">
        <xsl:param name="alias" as="xs:string*"/>
        <xsl:sequence select="imf:boolean($debug) and (($alias,'#ALL') = $debug-modes)"/>
    </xsl:function>
    
    <xsl:function name="imf:debug-mode" as="xs:boolean">
       <xsl:sequence select="$debugging"/>
    </xsl:function>
    
    <xsl:function name="imf:generate-debug-comment">
        <xsl:param name="type"/>
        <xsl:param name="debugText"/>
        <xsl:param name="context-item"/>
        <xsl:if test="$debugging">
            <xsl:choose>
                <xsl:when test="$type = 'xml'">
                    <xsl:comment select="concat('Debuglocatie ', $debugText,':',imf:xpath-string($context-item))"/>
                </xsl:when>
                <xsl:when test="$type = 'json'">
                    <xsl:text>"--------------Debuglocatie-</xsl:text><xsl:value-of select="$debugText"/><xsl:text>": {
					"Debug": "</xsl:text><xsl:sequence select="imf:xpath-string($context-item)"/><xsl:text>"
				},</xsl:text>
                </xsl:when>
                <xsl:when test="$type = 'yaml'">
                    <xsl:text># ---------Debuglocatie-</xsl:text><xsl:value-of select="$debugText"/><xsl:text>-- </xsl:text><xsl:sequence select="imf:xpath-string($context-item)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-debug-comment-with-xpath">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="debugging" as="xs:boolean"/>
        <xsl:param name="node"/>
        <xsl:if test="$debugging">
            <xsl:sequence select="imf:create-debug-comment(concat($text,' XPath: ',imf:xpath-string($node)),$debugging)"/>
        </xsl:if>      
    </xsl:function>
    
    <xsl:function name="imf:create-debug-comment">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="debugging" as="xs:boolean"/>
        <xsl:if test="$debugging">
            <xsl:comment select="$text"/>
        </xsl:if>      
    </xsl:function>
    
    <xsl:function name="imf:create-debug-track">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="debugging" as="xs:boolean"/>
        <xsl:if test="$debugging">
            <xsl:sequence select="imf:track($text)"/>
        </xsl:if>
    </xsl:function>
    
    <!-- 
        Debug level is some string designating the type of debug level for this file. Typically the name of a stylesheet from which this function is called.
        
        File-name is a name (not a path) for the file.
        
        Any-content may be any content; all results are written in a <debug-result> wrapper.
    -->    
    
    <!-- compile a header for imvert file; only packages are processed after this part -->
    <xsl:function name="imf:compile-imvert-header" as="element()*">
        <xsl:param name="packages" as="element()"/>
        <xsl:sequence select="$packages/*[not(self::imvert:package or self::imvert:filters)]"/>
        <imvert:filters>
            <xsl:sequence select="$packages/imvert:filters/imvert:filter"/>
            <xsl:sequence select="imf:compile-imvert-filter()"/>
        </imvert:filters>
    </xsl:function>
    
    <xsl:function name="imf:compile-imvert-filter" as="element()">
        <imvert:filter>
            <imvert:name>
                <xsl:value-of select="$xml-stylesheet-name"/>
            </imvert:name>
            <imvert:date>
                <xsl:value-of select="current-dateTime()"/>
            </imvert:date>
            <imvert:version>
                <xsl:value-of select="$stylesheet-version"/>
            </imvert:version>
        </imvert:filter>
    </xsl:function>
   
    <!-- true when value is text is 'yes'|'true' | 1, false when 'no'|'false' | 0, if evaluates to true then true,else false  -->  
    <xsl:function name="imf:as-boolean" as="xs:boolean">
        <xsl:param name="this" as="item()?"/>
        <xsl:variable name="v" select="lower-case(string($this))"/>
        <xsl:sequence select="
            if ($v=('yes','true','ja','1')) then true() 
            else if ($v=('no','false','nee','0')) then false() 
            else if ($this) then true() 
            else false()"/>
    </xsl:function>
    
    <!-- if any of the items is compatible with true, return true, else false -->
    <xsl:function name="imf:boolean" as="xs:boolean">
        <xsl:param name="this" as="item()*"/>
        <xsl:sequence select="(for $b in $this return imf:as-boolean($b)) = true()"/><!-- true komt voor in de reeks booleans die wordt afgegeven -->
    </xsl:function>
    
    <!-- 
        if any of the items exists and (if string and) not whitespace, return true 
    -->
    <xsl:function name="imf:exists" as="xs:boolean">
        <xsl:param name="this" as="item()*"/>
        <xsl:sequence select="(for $b in $this return 
            if ($b instance of xs:string) then 
              if (normalize-space($b)) then true() else false()
            else true()
        ) = true()"/><!-- true komt voor in de reeks booleans die wordt afgegeven -->
    </xsl:function>
  
    <!--
        Return all values that are duplicated in sequence passed 
        Credits: http://dnovatchev.wordpress.com/2008/11/13/xpath-2-0-gems-find-all-duplicate-values-in-a-sequence/
    -->
    <xsl:function name="imf:get-duplicates" as="item()*">
        <xsl:param name="seq" as="item()*"/>
        <xsl:sequence select="
            for $item in $seq
            return 
                if (count($seq[. eq $item]) > 1)
                then $item
                else ()"/>
    </xsl:function>
    
    <!-- 
        compile the folder where this external package is found. This is:
        [owner-name] / xsd / [sitename] / [remainder-separated-by-hyphen]([version]-[release])
    -->
    <xsl:function name="imf:get-schema-foldername" as="xs:string">
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="version" as="xs:string"/>
        <xsl:param name="release" as="xs:string?"/><!-- not known for external and system packages -->
        <xsl:param name="map-name" as="xs:string"/>
        <xsl:param name="owner-name" as="xs:string"/>
        <xsl:variable name="parts" select="imf:get-uri-parts($namespace)"/>
        <!-- <xsl:value-of select="concat($parts/server,'/',replace($parts/path,'/','-'),'(',$version, '-', $release,')')"/> -->
        <xsl:value-of select="concat($owner-name,'/xsd/',$parts/server,'/',$map-name,'-',$release)"/>
    </xsl:function>
    
    <xsl:function name="imf:extract" as="xs:string">
        <xsl:param name="this" as="xs:string"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:variable name="r">
            <xsl:analyze-string select="$this" regex="{$regex}">
                <xsl:matching-substring>
                    <xsl:value-of select="."/>
                </xsl:matching-substring>
            </xsl:analyze-string>      
        </xsl:variable>
        <xsl:value-of select="string-join($r,'')"/>
    </xsl:function>
    
    <!-- 
        Return all Objecttype classes that are referenced by the product-referenced classes passed, 
        that should therefore be part of the product collection.
        This concerns all associations of the classes passed, its subclasses, or any of their superclasses. 
    --> 
    <xsl:function name="imf:get-all-collection-member-classes" as="element()*">
        <xsl:param name="product-class" as="element()?"/> <!-- classes that reference possible collection classes; initialially: referenced by a product class -->
        <xsl:variable name="r1" select="imf:get-all-collection-member-classes-sub($product-class,())"/>
        <!-- if any class is subtype of some other class in this collection, remove it. If not we would get ambiguous references. -->
        <xsl:variable name="r2" as="element()*">
            <xsl:for-each select="$r1">
                <xsl:sequence select="if (imf:member-of($r1,imf:get-superclasses(.))) then () else ."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$r2"/>
    </xsl:function>

    <xsl:function name="imf:get-all-collection-member-classes-sub" as="element()*">
        <xsl:param name="class" as="element()?"/> <!-- class that is end/or references possible collection classes; initialially: a product class -->
        <xsl:param name="processed" as="element()*"/> 
        <xsl:variable name="result" as="element()*">
            <xsl:choose>
                <xsl:when test="imf:member-of($class,$processed)">
                    <!-- skip -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- return this class as part of the collection. -->
                    <xsl:sequence select="if ($class/imvert:stereotype/@id = ('stereotype-name-objecttype')) then $class else ()"/>
                    <!-- get all classes related to this class or any of the supertypes/immediate subtypes. -->
                    <xsl:variable name="related" select="(imf:get-all-collection-related($class), imf:get-all-collection-supertype-related($class),imf:get-all-collection-subtype-related($class))/." as="element()*"/>
                    <!-- check these classes -->
                    <xsl:sequence select="for $c in $related return imf:get-all-collection-member-classes-sub($c,($processed,$class))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$result/."/>
    </xsl:function>
    
    <xsl:function name="imf:get-all-collection-supertype-related" as="element()*">
        <xsl:param name="class"/>
        <xsl:sequence select="for $s in imf:get-superclasses($class) return imf:get-all-collection-related($s)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-all-collection-subtype-related" as="element()*">
        <xsl:param name="class"/>
        <xsl:sequence select="for $s in imf:get-subclasses($class,$document-classes) return imf:get-all-collection-related($s)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-all-collection-related" as="element()*">
        <xsl:param name="class"/>
        <xsl:for-each select="$class/imvert:associations/imvert:association[imvert:type-id and imf:is-object-relation(.)]">
            <xsl:sequence select="imf:get-construct-by-id(imvert:type-id)"/>
        </xsl:for-each>
    </xsl:function>
   
   <?xx
    <!-- 
        return all Objecttype classes that are referenced from within this class 
    --> 
    <xsl:function name="imf:get-all-referenced-classes" as="element()*">
        <xsl:param name="class" as="element()"/>
        <xsl:for-each select="$class/imvert:associations/imvert:association">
            <xsl:variable name="defining-class" select="imf:get-construct-by-id(imvert:type-id)"/>
            <xsl:choose>
                <xsl:when test="$defining-class/imvert:stereotype/@id = ('stereotype-name-objecttype'))">
                    <xsl:sequence select="$defining-class"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
   x?>
   
    <xsl:function name="imf:get-display-name" as="xs:string">
        <xsl:param name="this" as="node()?"/>
        <xsl:variable name="precompiled-name" select="$this/@display-name"/>
        <xsl:choose>
            <xsl:when test="empty($this)">
                <xsl:value-of select="'UNKNOWN'"/>
            </xsl:when>
            <xsl:when test="exists($precompiled-name)">
                <xsl:value-of select="$precompiled-name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-construct-name($this)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        replace all indicated fragments x inserted as ...[x]... by the content of the element named x 
    -->
    <xsl:function name="imf:insert-fragments-by-name" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="fragments" as="element(frag)+"/>
        <xsl:variable name="result" as="xs:string*">
            <xsl:analyze-string select="$string" regex="\[(.+?)\]">
                <xsl:matching-substring>
                    <xsl:value-of select="$fragments[@key = regex-group(1)]/@value"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:function>
    
    <!-- 
		replace all indicated fragments N inserted as ...[N]... by the content of the item at the specified position
	--> 
    <xsl:function name="imf:insert-fragments-by-index" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="parms" as="item()*"/>
        <xsl:param name="leftsep" as="xs:string?"/>
        <xsl:param name="rightsep" as="xs:string?"/>
        <xsl:variable name="locs" select="tokenize($string,'\[\d+\]')"/>
        <xsl:variable name="r">
            <xsl:analyze-string select="$string" regex="\[(\d)\]">
                <xsl:matching-substring>
                    <xsl:variable name="g" select="$parms[xs:integer(regex-group(1))]"/>
                    <xsl:value-of select="if (exists($g)) then imf:msg-insert-parms-val($g,$leftsep,$rightsep) else '-null-'"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="$r"/>
    </xsl:function>

    <xsl:function name="imf:insert-fragments-by-index" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="parms" as="item()*"/>
        <xsl:value-of select="imf:insert-fragments-by-index($string,$parms,'&quot;','&quot;')"/>
    </xsl:function>
    
    <!-- return a document when it exists, otherwise return empty sequence -->
    <xsl:function name="imf:document" as="document-node()?">
        <xsl:param name="uri-or-path" as="xs:string"/>
        <xsl:sequence select="imf:document($uri-or-path,false())"/>
    </xsl:function>
    
    <!-- 
        Return a document. 
        Specify if it is assumed to exist; if false, test availability (which slows down) 
    -->
    <xsl:function name="imf:document" as="document-node()?">
        <xsl:param name="uri-or-path" as="xs:string?"/>
        <xsl:param name="assume-existing" as="xs:boolean"/>

        <xsl:variable name="is-local-uri" select="matches($uri-or-path,'^file:.*$')"/>
        <xsl:variable name="is-local-absolute-path" select="matches($uri-or-path,'^(/|(.:)).*$')"/>
        <xsl:variable name="is-global-uri" select="matches($uri-or-path,'^https?:.*$')"/>
        
        <xsl:variable name="uri" select="
            if ($is-local-absolute-path) 
            then imf:file-to-url($uri-or-path) 
            else 
                if ($is-local-uri or $is-global-uri)
                then $uri-or-path
                else ()"/>
        
        <xsl:variable name="path" select="
            if ($is-local-uri) 
            then imf:url-to-file($uri-or-path) 
            else 
                if ($is-local-absolute-path)
                then $uri-or-path
                else ()"/>
        
        <xsl:choose>
            <xsl:when test="empty($uri-or-path)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="$assume-existing">
                <xsl:sequence select="imf:document-from-cache($uri)"/>
            </xsl:when>
            <xsl:when test="empty($path)"><!-- an URL was passed, e.g. http://... -->
                <xsl:sequence select="if (imf:document-available($uri)) then imf:document-from-cache($uri) else ()"/>
            </xsl:when>
            <xsl:when test="imf:document-available($path)">
                <xsl:sequence select="imf:document-from-cache($uri)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:document-from-cache" as="document-node()">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:sequence select="document($uri)"/>
    </xsl:function>
    
    <xsl:function name="imf:document-available" as="xs:boolean">
        <xsl:param name="uri"/>
        <xsl:sequence select="imf:filespec($uri,'EF')[6] = 'F'"/>
    </xsl:function>
    
    <!-- find an element hashed by xsl:key -->
    <xsl:function name="imf:get-key" as="element()*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="imf:get-key($imvert-document,$name,$value)"/>
    </xsl:function>
    <xsl:function name="imf:get-key" as="element()*">
        <xsl:param name="document" as="document-node()"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="key($name,$value,$document)"/>
    </xsl:function>
    
    <!-- 
        IM-85 
        extract all upper case letters and return the lower-case concatenation, but only when requested by user
        if no requested, return a valid prefix name which resembled the package name as best as possible
        
        When the name passed ends with 'Ref' (reference suffix name), this is assumed to be a reference element, and the short prefix must end with -ref.
    -->
    <xsl:function name="imf:get-short-name" as="xs:string">
        <xsl:param name="fullname" as="xs:string"/>
        <xsl:variable name="actual-name" select="tokenize($fullname,'\s\[')[1]"/>
        <xsl:variable name="is-ref" select="ends-with($actual-name,imf:get-config-parameter('reference-suffix-name'))"/>
        <xsl:variable name="basename" select="if ($is-ref) then substring($actual-name,1,string-length($actual-name) - string-length(imf:get-config-parameter('reference-suffix-name'))) else $actual-name"/>
        <xsl:variable name="prefix" select="lower-case(string-join(tokenize($basename,'[^A-Z]+'),''))"/>
        <xsl:variable name="full-raw" select="string-join(tokenize($basename,'[^a-zA-Z0-9_]+'),'')"/>
        <xsl:variable name="full" select="if (matches($full-raw,'^[0-9_].*')) then concat('n',$full-raw) else $full-raw"/>
        <xsl:variable name="base" select="if (imf:boolean($short-prefix) and $prefix) then $prefix else $full"/>
        <xsl:value-of select="if ($is-ref) then concat($base,imf:get-config-parameter('reference-suffix-short')) else $base"/>
    </xsl:function>
    
    <xsl:function name="imf:get-phase-description" as="item()*">
        <xsl:param name="phase-passed"/>
        <xsl:variable name="phase" select="if ($phase-passed) then $phase-passed else '0'"/>
        <xsl:value-of select="$phase"/>
        <?x
        <xsl:analyze-string select="$phase" regex="([0123])|(concept)|(draft)|(final\s*draft)|(final)" flags="i">
            <xsl:matching-substring>
                 <xsl:sequence select="
                     if (regex-group(1)='0' or regex-group(2)) then ('0','concept')
                     else 
                         if (regex-group(1)='1' or regex-group(3)) then ('1','draft')
                         else 
                         if (regex-group(1)='2' or regex-group(4)) then ('2','finaldraft')
                             else 
                             if (regex-group(1)='3' or regex-group(5)) then ('3','final')
                                 else ()"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
        x?>
    </xsl:function>

    <xsl:function name="imf:file-to-url">
        <xsl:param name="filepath" as="xs:string?"/>
        <xsl:value-of select="imf:path-to-file-uri($filepath)"/>
    </xsl:function>
    
    <xsl:function name="imf:file-to-url">
        <xsl:param name="filepath" as="xs:string?"/>
        <xsl:param name="debug-origin"/>
        <xsl:sequence select="imf:file-to-url($filepath)"/>
    </xsl:function>
    
    <!-- replace file:/ construct by correct local representation -->
    <xsl:function name="imf:url-to-file">
        <xsl:param name="uripath" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="matches($uripath, '^file:/+(\D:.*)')">
                <!-- Windows: -->
                <xsl:value-of select="translate(analyze-string($uripath, '^file:/+(\D:.*)')/fn:match/fn:group[@nr = '1'], '\', '/')"/>
            </xsl:when>
            <xsl:when test="matches($uripath, '^file:/+(.*)')">
                <!-- Unix: -->
                <xsl:value-of select="translate('/' || analyze-string($uripath, '^file:/+(.*)')/fn:match/fn:group[@nr = '1'], '\', '/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$uripath"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:replace-inet-references" as="xs:string">
        <xsl:param name="content"/>
        <xsl:variable name="r">
            <xsl:analyze-string select="$content" regex="(&quot;\$inet://)([^&quot;]+)">
                <xsl:matching-substring>
                    <xsl:value-of select="concat('&quot;http://',regex-group(2))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."></xsl:value-of>
                </xsl:non-matching-substring>
            </xsl:analyze-string>     
        </xsl:variable>
        <xsl:value-of select="$r"/>
    </xsl:function>
    
    <!-- 
        Get the attribute or association that is applicable for the class passed. 
        When a property definition is overridden, return the overriding property. 
        Otherwise return the inherited proprty. 
    --> 
    <xsl:function name="imf:get-applicable-property" as="element()?">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="original-property-name" as="xs:string"/>
        <xsl:variable name="classes" select="($this, imf:get-superclasses($this))"/>
        <xsl:sequence select="(for $p in $classes/*/(imvert:attribute | imvert:association)[imvert:name/@original = $original-property-name] return $p)[1]"/>
    </xsl:function>
    
    <!-- 
        Get the tagged value that is applicable for the class passed. 
        When a tagged value is overridden, return the overriding value. 
        Otherwise return the inherited value. 
    --> 
    <xsl:function name="imf:get-applicable-tagged-value" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="original-tagged-value-name" as="xs:string"/>
        <xsl:variable name="classes" select="($this, imf:get-superclasses($this))"/>
        <xsl:sequence select="(for $p in $classes/imvert:tagged-values/imvert:tagged-value[imvert:name/@original = $original-tagged-value-name] return string($p/imvert:value))[1]"/>
    </xsl:function>
    
    <!-- 
        true when this construct is (embedded in) a conceptual package 
        Feature #487839 
        If the namespace (alias) starts with one of the declared prefixes, it is considerd to be conceptual
    -->
    <xsl:function name="imf:is-conceptual" as="xs:boolean">
        <xsl:param name="construct" as="element()"/>
        <xsl:variable name="pack" select="$construct/ancestor-or-self::imvert:package" as="element()*"/>
        <?x <xsl:variable name="prefix" select="tokenize(normalize-space(imf:get-config-parameter('url-prefix-conceptual-schema')),'\s+')"/> x?>
        <xsl:variable name="is-external" select="$pack/imvert:stereotype/@id = ('stereotype-name-external-package')"/>
        <?x <xsl:variable name="is-conceptual" select="exists($pack/imvert:namespace[(for $p in ($prefix) return starts-with(.,$p)) = true()])"/> x?>
        <xsl:variable name="is-conceptual" select="true()"/>
        
       <xsl:choose>
            <xsl:when test="$is-external and $is-conceptual">
                <xsl:sequence select="true()"/>
            </xsl:when>
           <xsl:when test="$is-external and imf:member-of($construct,$pack)">
               <!--<xsl:sequence select="imf:msg($construct, 'WARNING','External packages must start with URL prefix [1]',($prefix))"/>-->
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="$is-external">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        return true when the type is referenced as an object, not only as an Xref. 
        see IM-308 
    -->
    <xsl:function name="imf:is-object-relation" as="xs:boolean">
        <xsl:param name="association" as="element()"/>
        <xsl:variable name="associates-from-collection" select="$association/../../imvert:stereotype/@id = ('stereotype-name-collection')"/>
        <xsl:sequence select="not($associates-from-collection) and empty($association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'relatie' and imvert:value='Referentie'])"/>
    </xsl:function>
    
    <!-- input format: 2014-09-29T09:54:42.833+02:00 -->
    
    <xsl:function name="imf:format-dateTime" as="xs:string">
        <xsl:param name="datetime"/> <!-- date, time, datetime or string -->
        <xsl:variable name="dt">
            <xsl:choose>
                <xsl:when test="$datetime instance of xs:dateTime">
                    <xsl:sequence select="$datetime"/>
                </xsl:when>    
                <xsl:when test="$datetime instance of xs:date">
                    <xsl:sequence select="dateTime($datetime,xs:time('00:00:00.000'))"/>
                </xsl:when>    
                <xsl:when test="$datetime instance of xs:time">
                    <xsl:sequence select="dateTime(xs:date('0001-01-01'),$datetime)"/>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:sequence select="dateTime(xs:date(substring(string($datetime),1,10)),xs:time(substring(string($datetime),12,12)))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="year-from-dateTime($dt) = 0001">
                <xsl:value-of select="format-dateTime($dt,'[MNn] [D], [Y0001]')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-dateTime($dt,'[MNn] [D], [Y0001] at [H01]:[m01]:[s01]')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-subpath" as="xs:string">
        <xsl:param name="project" as="xs:string?"/>
        <xsl:param name="name" as="xs:string?"/>
        <xsl:param name="release" as="xs:string?"/>
        <xsl:sequence select="string-join(($project,$name,$release),'/')"/>
    </xsl:function>
    
    <xsl:function name="imf:boolean-xor" as="xs:boolean">
        <xsl:param name="boolean-sequence" as="xs:boolean*"/>
        <xsl:sequence select="index-of(true(),$boolean-sequence) eq 1"/>
    </xsl:function>
    
    <xsl:function name="imf:boolean-or" as="xs:boolean">
        <xsl:param name="boolean-sequence" as="xs:boolean*"/>
        <xsl:sequence select="true() = $boolean-sequence"/>
    </xsl:function>
    
    <xsl:function name="imf:boolean-and" as="xs:boolean">
        <xsl:param name="boolean-sequence" as="xs:boolean*"/>
        <xsl:sequence select="not(false() = $boolean-sequence)"/>
    </xsl:function>
    
    <xsl:function name="imf:path-to-file-uri" as="xs:string">
        <xsl:param name="path" as="xs:string"/>
        <xsl:variable name="protocol-prefix" as="xs:string">
            <xsl:choose>
                <xsl:when test="starts-with($path, '\\')">file://</xsl:when> <!-- UNC path -->
                <xsl:when test="matches($path, '[a-zA-Z]:[\\/]')">file:///</xsl:when> <!-- Windows drive path -->
                <xsl:when test="starts-with($path, '/')">file://</xsl:when> <!-- Unix path -->
                <xsl:otherwise>file://</xsl:otherwise>
            </xsl:choose>  
        </xsl:variable>
        <xsl:variable name="norm-path" select="translate($path, '\', '/')" as="xs:string"/>
        <xsl:variable name="path-parts" select="tokenize($norm-path, '/')" as="xs:string*"/>
        <xsl:variable name="encoded-path" select="string-join(for $p in $path-parts return encode-for-uri($p), '/')" as="xs:string"/>
        <xsl:value-of select="concat($protocol-prefix, $encoded-path)"/>        
    </xsl:function>
    
    <xsl:function name="imf:get-original-names">
        <xsl:param name="elements" as="element()*"/>
        <xsl:sequence select="for $this in $elements return ($this/imvert:name/@original,$this/imvert:found-name,$this/imvert:application)[1]"/>
    </xsl:function>
    
    <!-- 
		Return the tagged value (as a string),
		or empty sequence when that tagged value is not found. 
		If a value is passed, check if the value is the same.
	-->
    <xsl:function name="imf:get-tagged-value" as="xs:string?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tv-id" as="xs:string"/>
        <xsl:param name="tv-value" as="xs:string?"/>
        <xsl:variable name="tv" select="imf:get-tagged-value-element($this,$tv-id)[1]"/> <!-- TODO validate all values, may be multiple -->
        <xsl:variable name="value" select="string($tv/imvert:value)"/>
        <xsl:choose>
            <xsl:when test="empty($tv)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="empty($tv-value)">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:when test="$value = $tv-value">
                <xsl:sequence select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value" as="xs:string?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tv-id" as="xs:string"/> <!-- ADD ## FOR id -->
        <xsl:sequence select="imf:get-tagged-value($this,$tv-id,())"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-element" as="element(imvert:tagged-value)*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tv-id" as="xs:string"/>
        <xsl:variable name="tv-id-use" select="substring-after($tv-id,'##')"/>
        <xsl:choose>
            <xsl:when test="normalize-space($tv-id-use)">
                <xsl:sequence select="$this/imvert:tagged-values/imvert:tagged-value[@id=$tv-id-use]"/>
            </xsl:when>
            <xsl:otherwise>
                <!--TODO deprecated, only by id -->
                <xsl:sequence select="imf:msg($this,'WARNING','DEPRECATED Tagged value by name [1], use ID',$tv-id)"/>
                <xsl:sequence select="$this/imvert:tagged-values/imvert:tagged-value[imvert:name = imf:get-normalized-name($tv-id,'tv-name')]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- data location used to be a part of the imvert schema, but is removed in 1.45. In stead, just query the tagged value -->
    <xsl:function name="imf:get-data-location" as="xs:string?">
        <xsl:param name="this"/>
        <xsl:sequence select="imf:get-tagged-value($this,'##CFG-TV-DATALOCATION')"/>
    </xsl:function>
    
    <!-- =========== optimization ============== -->
    
    <!--
        Get the tagged value passed by ID, return string values of all applicable tagged values. 

        If $mode is 'local', do not access the derivation tree. 
        If $mode is 'relevant', return most relevant tagged value. 
        If $mode is 'all', return all derived tagged values.
    --> 
    <xsl:function name="imf:get-tv-as-string" as="xs:string*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tv-id" as="xs:string"/>
        <xsl:param name="mode" as="xs:string"/> 
        <xsl:sequence select="for $tv in imf:get-tv-as-element($this, $tv-id, $mode) return string($tv/imvert:value)"/>        
    </xsl:function>
    <xsl:function name="imf:get-tv-as-string" as="xs:string*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tv-id" as="xs:string"/>
        <xsl:sequence select="for $tv in imf:get-tv-as-element($this, $tv-id, 'relevant') return string($tv/imvert:value)"/>        
    </xsl:function>
    
    <!--
        Get the tagged value passed by ID, return all applicable imvert:tagged-value elements. 

        If $mode is 'local', do not access the derivation tree. 
        If $mode is 'relevant', return most relevant tagged value. 
        If $mode is 'all', return all derived tagged values.
    --> 
    <xsl:function name="imf:get-tv-as-element" as="element(imvert:tagged-value)*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tv-id" as="xs:string"/>
        <xsl:param name="mode" as="xs:string"/>
        
        <xsl:variable name="stack" as="element()*">
            <xsl:variable name="suppliers" select="imf:get-supplier-constructs($this)"/>
            <xsl:for-each select="$suppliers">
                <xsl:sequence select="imf:get-tv-as-element(.,$tv-id,$mode)"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$mode = 'local'">
                <xsl:sequence select="$this/imvert:tagged-values/imvert:tagged-value[@id=$tv-id]"/>
            </xsl:when>
            <xsl:when test="$mode = 'all'">
                <xsl:sequence select="$stack"/>
            </xsl:when>
            <xsl:when test="$mode = 'relevant'">
                <xsl:sequence select="$stack[1]"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="imf:get-tv-as-element" as="element(imvert:tagged-value)*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tv-id" as="xs:string"/>
        <xsl:sequence select="imf:get-tv-as-element($this, $tv-id, 'relevant')"/>        
    </xsl:function>
    
    <!--
        Get the suppliers of the construct passed. 
        Empty when no derivation tree is available or no traces are set. 
    --> 
    <xsl:function name="imf:get-supplier-constructs" as="element()*">
        <xsl:param name="this" as="node()"/>
       
        <xsl:if test="exists($all-derived-models-doc)">
            <xsl:for-each select="$this/imvert:trace">
                <xsl:sequence select="imf:get-construct-by-id(imf:get-corrected-id(.,local-name($this)),$all-derived-models-doc)"/>
                <!--x <xsl:sequence select="imf:get-supplier-constructs(.)"/> x-->
            </xsl:for-each>
        </xsl:if>
    </xsl:function>    

    <!-- return true when any node in set 1 is member of set 2 -->
    <xsl:function name="imf:member-of" as="xs:boolean">
        <xsl:param name="nodes1" as="node()*"/>
        <xsl:param name="nodes2" as="node()*"/>
        <xsl:sequence select="exists($nodes1 intersect $nodes2)"/>
    </xsl:function>
    
    <!--TODO move to xmi specific common stylesheet -->
    <xsl:function name="imf:normalize-xmi-id" as="xs:string">
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
    
    <!-- two subpaths are deemed equal when they are the same irrespective of letter case -->
    <xsl:function name="imf:is-same-subpath" as="xs:boolean">
        <xsl:param name="subpath-1" as="xs:string?"/>
        <xsl:param name="subpath-2" as="xs:string?"/>
        <xsl:sequence select="exists($subpath-1) and exists($subpath-2) and (lower-case($subpath-1) eq lower-case($subpath-2))"/>
    </xsl:function>
    
    <!-- should augment functx -->
    <xsl:function name="imf:left-pad-string-to-length" as="xs:string">
        <xsl:param name="stringToPad"/>
        <xsl:param name="padChar"/>
        <xsl:param name="length" as="xs:integer"/>
        <xsl:value-of select="substring(
            string-join((for $i in (1 to $length) return $padChar,$stringToPad),''),string-length($stringToPad))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tv-value.local">
        <xsl:param name="tv-element" as="element(tv)?" />

        <!--xsl:if test="$tv-element/@format='unknown'">
            <xsl:sequence select="imf:msg($tv-element,'WARNING','The configuration for the notes (notesrules) needs adaption. No format or a format unknown is specified.')"/>						
        </xsl:if-->
        <xsl:sequence select="$tv-element/node()"/>
    </xsl:function>

    <xsl:function name="imf:xpath-string">
        <xsl:param name="node"/>
        
        <xsl:variable name="xpath-string">
            <xsl:for-each select="$node/ancestor-or-self::*">
                <xsl:text />/<xsl:value-of select="name()" />
                <xsl:if test="parent::*">
                    <xsl:text />[<xsl:number />]<xsl:text />
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:value-of select="string-join($xpath-string,'')"/>
    </xsl:function>
    
    <xsl:function name="imf:convert-to-atomic" as="item()?">
        <xsl:param name="value" as="item()?"/>
        <xsl:param name="datatype" as="xs:string"/>
        <xsl:param name="silent" as="xs:boolean"/>
        <xsl:try>
            <xsl:variable name="atomic-value" select="
                if ($datatype = 'xs:integer') then xs:integer($value) else
                if ($datatype = 'xs:string') then xs:string($value) else
                if ($datatype = 'xs:boolean') then xs:boolean($value) else
                if ($datatype = 'xs:untypedAtomic') then xs:untypedAtomic($value) else
                if ($datatype = 'xs:dateTime') then xs:dateTime($value) else
                if ($datatype = 'xs:dateTimeStamp') then xs:dateTimeStamp($value) else
                if ($datatype = 'xs:date') then xs:date($value) else
                if ($datatype = 'xs:time') then xs:time($value) else
                if ($datatype = 'xs:duration') then xs:duration($value) else
                if ($datatype = 'xs:yearMonthDuration') then xs:yearMonthDuration($value) else
                if ($datatype = 'xs:dayTimeDuration') then xs:dayTimeDuration($value) else
                if ($datatype = 'xs:float') then xs:float($value) else
                if ($datatype = 'xs:double') then xs:double($value) else
                if ($datatype = 'xs:decimal') then xs:decimal($value) else
                if ($datatype = 'xs:nonPositiveInteger') then xs:nonPositiveInteger($value) else
                if ($datatype = 'xs:negativeInteger') then xs:negativeInteger($value) else
                if ($datatype = 'xs:long') then xs:long($value) else
                if ($datatype = 'xs:int') then xs:int($value) else
                if ($datatype = 'xs:short') then xs:short($value) else
                if ($datatype = 'xs:byte') then xs:byte($value) else
                if ($datatype = 'xs:nonNegativeInteger') then xs:nonNegativeInteger($value) else
                if ($datatype = 'xs:unsignedLong') then xs:unsignedLong($value) else
                if ($datatype = 'xs:unsignedInt') then xs:unsignedInt($value) else
                if ($datatype = 'xs:unsignedShort') then xs:unsignedShort($value) else
                if ($datatype = 'xs:unsignedByte') then xs:unsignedByte($value) else
                if ($datatype = 'xs:positiveInteger') then xs:positiveInteger($value) else
                if ($datatype = 'xs:gYearMonth') then xs:gYearMonth($value) else
                if ($datatype = 'xs:gYear') then xs:gYear($value) else
                if ($datatype = 'xs:gMonthDay') then xs:gMonthDay($value) else
                if ($datatype = 'xs:gDay') then xs:gDay($value) else
                if ($datatype = 'xs:gMonth') then xs:gMonth($value) else
                if ($datatype = 'xs:normalizedString') then xs:normalizedString($value) else
                if ($datatype = 'xs:token') then xs:token($value) else
                if ($datatype = 'xs:language') then xs:language($value) else
                if ($datatype = 'xs:NMTOKEN') then xs:NMTOKEN($value) else
                if ($datatype = 'xs:Name') then xs:Name($value) else
                if ($datatype = 'xs:NCName') then xs:NCName($value) else
                if ($datatype = 'xs:ID') then xs:ID($value) else
                if ($datatype = 'xs:IDREF') then xs:IDREF($value) else
                if ($datatype = 'xs:ENTITY') then xs:ENTITY($value) else
                if ($datatype = 'xs:base64Binary') then xs:base64Binary($value) else
                if ($datatype = 'xs:hexBinary') then xs:hexBinary($value) else
                if ($datatype = 'xs:anyURI') then xs:anyURI($value) else
                if ($datatype = 'xs:QName') then xs:QName($value) else
                ()
            "/>
            <xsl:choose>
                <xsl:when test="$value = '' and $datatype = 'xs:string'">
                    <xsl:sequence select="$value"/>
                </xsl:when>
                <xsl:when test="$value = '' or empty($value)">
                    <!-- empty or empty-string item returns empty atomic -->
                </xsl:when>
                <xsl:when test="empty($atomic-value)">
                    <xsl:sequence select="imf:msg('FATAL','Invalid atomic value type [1]',$datatype)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$atomic-value"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:catch>
                <xsl:if test="not($silent)">
                    <xsl:sequence select="imf:msg('WARNING','Cannot convert [1] to [2]',(imf:string-group($value), $datatype))"/>
                </xsl:if>
                <!-- return empty sequence -->
            </xsl:catch>
        </xsl:try>
    </xsl:function>
   
    <xsl:function name="imf:convert-to-atomic" as="item()?">
        <xsl:param name="value" as="item()?"/>
        <xsl:param name="datatype" as="xs:string"/>
        <xsl:sequence select="imf:convert-to-atomic($value,$datatype,false())"/>
    </xsl:function>
  
    <xsl:function name="imf:path-equals" as="xs:boolean">
        <xsl:param name="path-1" as="xs:string?"/>
        <xsl:param name="path-2" as="xs:string?"/>
        <xsl:param name="case-sensitive" as="xs:boolean"/>
  
        <xsl:variable name="path-1-normalized" select="translate($path-1, '\/', '//')" as="xs:string?"/>
        <xsl:variable name="path-2-normalized" select="translate($path-2, '\/', '//')" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$case-sensitive">
                <xsl:sequence select="$path-1-normalized eq $path-2-normalized"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="lower-case($path-1-normalized) eq lower-case($path-2-normalized)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:path-starts-with" as="xs:boolean">
        <xsl:param name="path-1" as="xs:string?"/>
        <xsl:param name="path-2" as="xs:string?"/>
        <xsl:param name="case-sensitive" as="xs:boolean"/>
        
        <xsl:variable name="path-1-normalized" select="translate($path-1, '\/', '//')" as="xs:string?"/>
        <xsl:variable name="path-2-normalized" select="translate($path-2, '\/', '//')" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$case-sensitive">
                <xsl:sequence select="starts-with($path-1-normalized, $path-2-normalized)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="starts-with(lower-case($path-1-normalized), lower-case($path-2-normalized))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
  
    <xsl:function name="imf:find-duplicate-strings" as="xs:string*">
        <xsl:param name="seq" as="xs:string*" />
        
        <!-- Use fn:distinct-values to get unique values -->
        <xsl:variable name="distinct-values" select="distinct-values($seq)" />
        
        <!-- Filter out unique values by comparing counts -->
        <xsl:sequence select="for $value in $distinct-values return if (count($seq[. = $value]) gt 1) then $value else ()"/>
        
    </xsl:function>

    <xsl:function name="imf:get-reportable-config-path">
        <xsl:param name="subpath"/>
        <xsl:value-of select="substring-after(imf:file-to-url($subpath),'/input/')"/>
    </xsl:function>
    
    <xsl:function name="imf:normalize-space" as="xs:string">
        <xsl:param name="seq" as="item()*"/>
        <xsl:sequence select="normalize-space(imf:string-value($seq))"/>
    </xsl:function>
    
    <xsl:function name="imf:string-value" as="xs:string">
        <xsl:param name="seq" as="item()*"/>
        <xsl:variable name="v" as="xs:string*">
            <xsl:for-each select="$seq">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($v,'')"/>
    </xsl:function>
    
    <xsl:function name="imf:reduce-space" as="xs:string?">
        <xsl:param name="seq" as="item()*"/>
        <xsl:sequence select="for $s in imf:normalize-space($seq) return if ($s eq '') then () else $s"/>
    </xsl:function>
    
    <!--
        haal een patroon uit een string zoveel as het voorkomt
        Voorbeeld: 
        extract pattern ('2024-12-04','\d{2}')
        levert 20 24 12 04 (4 strings)
    -->
    <xsl:function name="imf:extract-pattern" as="xs:string*">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:analyze-string select="$string" regex="{$regex}">
            <xsl:matching-substring>
                <xsl:value-of select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
</xsl:stylesheet>
