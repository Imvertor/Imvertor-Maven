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
    xmlns:imvert-message="http://www.imvertor.org/schema/message"
    xmlns:imvert-ep="http://www.imvertor.org/schema/endproduct"
           xmlns:ep="http://www.imvertor.org/schema/endproduct"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
      
    <xsl:include href="Imvert-common-parms.xsl"/>
    <xsl:include href="Imvert-common-extension.xsl"/>
    <xsl:include href="Imvert-common-messaging.xsl"/>
    <xsl:include href="Imvert-common-names.xsl"/>
    <xsl:include href="Imvert-common-config.xsl"/>
    <xsl:include href="Imvert-common-data.xsl"/>
    <xsl:include href="Imvert-common-uri.xsl"/>
    <xsl:include href="Imvert-common-keys.xsl"/>
    
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
    
    <!-- avoid SVN dollar-text-dollar pattern -->
    <xsl:variable name="char-dollar">$</xsl:variable>
    
    <xsl:variable name="name-none">n-o-n-e</xsl:variable>
    
    <xsl:variable name="release-info" as="element()+">
        <frag key="year" value="{substring($application-package-release,1,4)}"/>
        <frag key="month" value="{substring($application-package-release,5,2)}"/>
        <frag key="day" value="{substring($application-package-release,7,2)}"/>
    </xsl:variable>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="default" as="item()*"/>
        <xsl:param name="as-string" as="xs:boolean"/>
        <xsl:param name="allow-empty" as="xs:boolean"/>
        <xsl:variable name="computed-content" select="if ($content[1]) then $content else if (normalize-space($content)) then string($content) else $default" as="item()*"/>
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
         
         Also, we assume that a class is not linkable when it has no identifier (anonymous)
         or when the identifier is nillable/voidable (id-voidable).
    -->
    <xsl:function name="imf:is-linkable" as="xs:boolean">
        <xsl:param name="class" as="element()"/>
        <xsl:variable name="class-id" select="$class/imvert:id"/>
        <xsl:variable name="is-objecttype" select="$class/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')"/>
        <xsl:variable name="is-not-static" select="exists($document-classes[imvert:supertype[imvert:type-id=$class-id and not(imvert:stereotype=imf:get-config-stereotypes('stereotype-name-static-generalization'))]])"/>
        <xsl:variable name="is-not-lonely" select="exists($document-classes[*/*/imvert:type-id=$class-id])"/>
        <!-- is-not-lonely: this may be assocations or attributes; typically object types occur as attribute typs for unions. -->
        <xsl:variable name="is-not-sad" select="exists(for $c in (imf:get-superclasses($class)) return if (imf:is-linkable($c)) then 1 else ())"/>
        
        <!-- IM-432 Relaties niet altijd via ref -->
        <xsl:variable name="id-attribute" select="($class, imf:get-superclasses($class))/*/imvert:attribute[imvert:is-id='true']"/>
        <xsl:variable name="is-not-anonymous" select="exists($id-attribute)"/>
        <xsl:variable name="is-not-id-voidable" select="not($id-attribute/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-voidable'))"/>
        
        <!--<xsl:message select="concat($class/imvert:name, ' - ', $is-objecttype, ' - ', $is-not-static, ' - ', $is-not-lonely, ' - ', $is-not-sad, ' - ', $is-not-anonymous, ' - ', $is-not-id-voidable)"></xsl:message>-->
        <xsl:sequence select="$is-objecttype and ($is-not-static or $is-not-lonely or $is-not-sad) and $is-not-anonymous and $is-not-id-voidable"/>
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
    <xsl:function name="imf:get-superclass" as="element()*"> <!-- imvert:class -->
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
    
    <xsl:function name="imf:get-construct-name" as="item()*">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="name" select="$this/imvert:name/@original"/>
        <xsl:variable name="project" select="$this/ancestor-or-self::imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-project-package')]"/>
        <xsl:variable name="package-names" select="$this/ancestor-or-self::imvert:package[exists(ancestor-or-self::imvert:package = $project)]/imvert:name/@original"/>
        <xsl:variable name="class-name" select="$this/ancestor-or-self::imvert:class[1]/imvert:name/@original"/>
        <xsl:choose>
            <xsl:when test="$this/self::imvert:package">
                <xsl:sequence select="imf:compile-construct-name($name,(),(),())"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:base">
                <xsl:sequence select="imf:compile-construct-name($name,(),(),())"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:class">
                <xsl:sequence select="imf:compile-construct-name($package-names,$name,(),())"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:supertype">
                <xsl:sequence select="imf:compile-construct-name($this/imvert:type-package,$this/imvert:type-name,(),())"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:attribute">
                <xsl:sequence select="imf:compile-construct-name($package-names,$class-name,$name,'attrib')"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:association[not(imvert:name)]">
                <xsl:variable name="type" select="concat('[',$this/imvert:type-name,']')"/>
                <xsl:sequence select="imf:compile-construct-name($package-names,$class-name,$type,imf:get-aggregation($this))"/>
            </xsl:when>
            <xsl:when test="$this/self::imvert:association">
                <xsl:sequence select="imf:compile-construct-name($package-names,$class-name,$name,imf:get-aggregation($this))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:compile-construct-name($package-names,$name,local-name($this),())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:compile-construct-name" as="element()">
        <xsl:param name="package-names" as="xs:string*"/>
        <xsl:param name="class-name" as="xs:string?"/>
        <xsl:param name="property-name" as="xs:string?"/>
        <xsl:param name="property-kind" as="xs:string?"/> <!-- 'attrib' or 'assoc' or null -->
        <xsl:variable name="pan" select="if (exists($package-names)) then concat(string-join($package-names,'::'),'::') else ''"/>
        <xsl:variable name="cln" select="if (exists($class-name)) then $class-name else ''"/>
        <xsl:variable name="prn" select="if (exists($property-name)) then concat('.',$property-name) else ''"/>
        <xsl:variable name="prk" select="if (exists($property-kind)) then concat(' (',$property-kind,')') else ''"/>
        <span>
            <xsl:value-of select="$pan"/>
            <b>
                <xsl:value-of select="$cln"/>
                <i>
                    <xsl:value-of select="$prn"/>
                </i>
            </b>
            <xsl:value-of select="$prk"/>
        </span>
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
        <xsl:sequence select="imf:get-construct-by-id($id,$document)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-by-id" as="element()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="root" as="node()*"/>
        <xsl:sequence select="if ($root instance of document-node()) then imf:key-imvert-construct-by-id($id,$root) else $root//*[imvert:id=$id]"/>
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
    <xsl:function name="imf:largest" as="item()">
        <xsl:param name="seq" as="item()+"/>
        <xsl:sequence select="imf:sort($seq)[last()]"/>
    </xsl:function>
    
    <!-- return the smallest value taken from the sequence passed. -->
    <xsl:function name="imf:smallest" as="item()">
        <xsl:param name="seq" as="item()+"/>
        <xsl:sequence select="imf:sort($seq)[1]"/>
    </xsl:function>
    
    <!-- sort a sequence in ascending order. -->
    <xsl:function name="imf:sort" as="item()*">
        <xsl:param name="seq" as="item()+"/>
        <xsl:for-each select="$seq">
            <xsl:sort select="." order="ascending"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:function>    
    
    <xsl:function name="imf:debug-path" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="if ($this/parent::*) then concat(imf:debug-path($this/parent::*),'/',name($this)) else name($this)"/>
    </xsl:function>
    
    <!-- compile a header for imvert file; only packages are processed after this part -->
    <xsl:function name="imf:compile-imvert-header" as="element()*">
        <xsl:param name="packages" as="element()"/>
        <xsl:sequence select="$packages/*[not(self::imvert:package or self::imvert:filter)]"/>
        <xsl:sequence select="$packages/imvert:filter"/>
        <xsl:sequence select="imf:compile-imvert-filter()"/>
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
   
    <!-- true when value is text is 'yes'|'true', false when 'no'|'false', otherwise false  -->  
    <xsl:function name="imf:boolean" as="xs:boolean">
        <xsl:param name="this" as="item()?"/>
        <xsl:value-of select="
            if (string($this)=('yes','true','1')) then true() 
            else if (string($this)=('no','false','0')) then false() 
                else if ($this) then true() 
                    else false()"/>
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
        xsd / [sitename] / [remainder-separated-by-hyphen]([version]-[release])
    -->
    <xsl:function name="imf:get-schema-foldername" as="xs:string">
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="version" as="xs:string"/>
        <xsl:param name="release" as="xs:string"/>
        <xsl:variable name="parts" select="imf:get-uri-parts($namespace)"/>
        <xsl:value-of select="concat($parts/server,'/',replace($parts/path,'/','-'),'(',$version, '-', $release,')')"/>
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
                <xsl:sequence select="if (imf:get-superclasses(.) = $r1) then () else ."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$r2"/>
    </xsl:function>

    <xsl:function name="imf:get-all-collection-member-classes-sub" as="element()*">
        <xsl:param name="class" as="element()?"/> <!-- class that is end/or references possible collection classes; initialially: a product class -->
        <xsl:param name="processed" as="element()*"/> 
        <xsl:variable name="result" as="element()*">
            <xsl:choose>
                <xsl:when test="$processed = $class">
                    <!-- skip -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- return this class as part of the collection. -->
                    <xsl:sequence select="if ($class/imvert:stereotype=imf:get-config-stereotypes('stereotype-name-objecttype')) then $class else ()"/>
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
        <xsl:for-each select="$class/imvert:associations/imvert:association[imvert:type-id]">
            <xsl:sequence select="imf:get-construct-by-id(imvert:type-id)"/>
        </xsl:for-each>
    </xsl:function>
     
    <!-- 
        return all Objecttype classes that are referenced from within this class 
    --> 
    <xsl:function name="imf:get-all-referenced-classes" as="element()*">
        <xsl:param name="class" as="element()"/>
        <xsl:for-each select="$class/imvert:associations/imvert:association">
            <xsl:variable name="defining-class" select="imf:get-construct-by-id(imvert:type-id)"/>
            <xsl:choose>
                <xsl:when test="$defining-class/imvert:stereotype=(imf:get-config-stereotypes('stereotype-name-objecttype'))">
                    <xsl:sequence select="$defining-class"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
   
    <xsl:function name="imf:get-display-name" as="xs:string">
        <xsl:param name="this" as="node()?"/>
        <xsl:choose>
            <xsl:when test="$this">
                <xsl:variable name="display-name" select="imf:get-construct-name($this)"/>
                <xsl:value-of select="$display-name"/>
            </xsl:when>
            <xsl:otherwise>UNKNOWN</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        replace all indicated fragments x inserted as ...[x]... by the content of the element named x 
    -->
    <xsl:function name="imf:insert-fragments-by-name" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="fragments" as="element()+"/>
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

    <!-- return a document when it exists, oitherwise return empty sequence -->
    <xsl:function name="imf:document" as="item()*">
        <xsl:param name="uri-or-path" as="xs:string"/>
        <xsl:variable name="uri" select="if (matches($uri-or-path,'^(file)|(https?):.*$')) then $uri-or-path else imf:file-to-url($uri-or-path)"/>
        <xsl:choose>
            <xsl:when test="unparsed-text-available($uri)">
                <xsl:sequence select="document($uri)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- find an element hashed by xsl:key -->
    <xsl:function name="imf:get-key" as="element()*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="imf:get-key($document,$name,$value)"/>
    </xsl:function>
    <xsl:function name="imf:get-key" as="element()*">
        <xsl:param name="document" as="document-node()"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:for-each select="$document">
            <xsl:sequence select="key($name,$value)"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
        IM-85 
        extract all upper case letters and return the lower-case concatenation, but only when requested by user
        if no requested, return a valid prefix name which resembled the package name as best as possible
        
        When the name passed ends with 'Ref' (reference suffix name), this is assumed to be a reference element, and the short prefix must end with -ref.
    -->
    <xsl:function name="imf:get-short-name" as="xs:string">
        <xsl:param name="fullname" as="xs:string"/>
        <xsl:variable name="is-ref" select="ends-with($fullname,imf:get-config-parameter('reference-suffix-name'))"/>
        <xsl:variable name="basename" select="if ($is-ref) then substring($fullname,1,string-length($fullname) - string-length(imf:get-config-parameter('reference-suffix-name'))) else $fullname"/>
        <xsl:variable name="prefix" select="lower-case(string-join(tokenize($basename,'[^A-Z]+'),''))"/>
        <xsl:variable name="full-raw" select="string-join(tokenize($basename,'[^a-zA-Z0-9_]+'),'')"/>
        <xsl:variable name="full" select="if (matches($full-raw,'^[0-9_].*')) then concat('n',$full-raw) else $full-raw"/>
        <xsl:variable name="base" select="if (imf:boolean($short-prefix) and $prefix) then $prefix else $full"/>
        <xsl:value-of select="if ($is-ref) then concat($base,imf:get-config-parameter('reference-suffix-short')) else $base"/>
    </xsl:function>
    
    <xsl:function name="imf:get-phase-description" as="item()*">
        <xsl:param name="phase-passed"/>
        <xsl:variable name="phase" select="if ($phase-passed) then $phase-passed else '0'"/>
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
    </xsl:function>

    <xsl:function name="imf:file-to-url">
        <xsl:param name="filepath"/>
        <xsl:value-of select="imf:filespec($filepath)[2]"/>
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
        <xsl:variable name="prefix" select="tokenize(normalize-space(imf:get-config-parameter('url-prefix-conceptual-schema')),'\s+')"/>
        <xsl:variable name="is-external" select="$pack/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-external-package')"/>
        <xsl:variable name="is-conceptual" select="exists($pack/imvert:namespace[(for $p in ($prefix) return starts-with(.,$p)) = true()])"/>
        <xsl:choose>
            <xsl:when test="$is-external and $is-conceptual">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$is-external and $pack = $construct">
                <!--<xsl:sequence select="imf:msg($construct, 'WARN','External packages must start with URL prefix [1]',($prefix))"/>-->
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
</xsl:stylesheet>
