<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    >
    
    <xsl:variable name="strings-nonempty" select="imf:get-config-xmlschemarules()/parameter[@name='strings-nonempty']"/><!-- https://github.com/Imvertor/Imvertor-Maven/issues/52 -->
    <xsl:variable name="xsd-subpath" select="encode-for-uri(imf:merge-parms(imf:get-config-string('cli','xsdsubpath')))"/>
    <xsl:variable name="work-xsd-folder-url" select="imf:file-to-url(imf:get-config-string('system','work-xsd-folder-path'))"/>
    
    <xsl:variable name="is-forced-nillable" select="imf:boolean(imf:get-config-string('cli','forcenillable'))"/>
    
    <xsl:variable name="current-datetime" select="imf:format-dateTime(imf:get-config-string('run','start'))"/>
    <xsl:variable name="current-imvertor-version" select="imf:get-config-string('run','version')"/>
    
    <xsl:variable name="allow-scalar-in-union" select="imf:boolean($configuration-metamodel-file//features/feature[@name='allow-scalar-in-union'])"/>
    
    <!-- 
        What types result in an attribute in stead of an element? 
        This is always the case for ID values.
        It is not possible to mix the use of types on elements and attributes. 
        Note that Imvertor is element-oriented, not attribute-oriented.
    -->
    <xsl:variable name="xml-attribute-type" select="('ID')"/>
    
    <xsl:variable 
        name="external-schemas" 
        select="$imvert-document//imvert:package[imvert:stereotype/@id = ('stereotype-name-external-package','stereotype-name-system-package')]" 
        as="element(imvert:package)*"/>
    
    <xsl:variable 
        name="external-schema-names" 
        select="$external-schemas/imvert:name" 
        as="xs:string*"/>
    
    <xsl:function name="imf:template-create-schemas">
        <imvert:schemas>
            <xsl:sequence select="imf:create-info-element('imvert:exporter',$imvert-document/imvert:packages/imvert:exporter)"/>
            <xsl:sequence select="imf:create-info-element('imvert:schema-exported',$imvert-document/imvert:packages/imvert:exported)"/>
            <xsl:sequence select="imf:create-info-element('imvert:schema-filter-version',imf:get-svn-id-info($imvert-document/imvert:packages/imvert:filters/imvert:filter/imvert:version))"/>
            <xsl:sequence select="imf:create-info-element('imvert:latest-svn-revision',concat($char-dollar,'Id',$char-dollar))"/>
            
            <!-- Schemas for external packages are not generated, but added to the release manually. -->
            <xsl:apply-templates select="$imvert-document/imvert:packages/imvert:package[not(imvert:name = $external-schema-names)]"/>
            
            <!-- 
                Do we need to reference external schema's? 
                If so, a reference is made to the name of the external schema.
            -->
            <xsl:variable name="externals" select="$imvert-document//imvert:type-package[.=$external-schema-names]"/>
            <xsl:for-each-group select="$externals" group-by=".">
                <xsl:for-each select="current-group()[1]"><!-- singleton imvert:type-package element--> 
                    <xsl:variable name="external-package" select="imf:get-construct-by-id(../imvert:type-package-id)"/>
                    <imvert:schema>
                        <xsl:sequence select="imf:create-info-element('imvert:name',$external-package/imvert:name)"/>
                        <xsl:sequence select="imf:create-info-element('imvert:prefix',$external-package/imvert:short-name)"/>
                        <xsl:sequence select="imf:create-info-element('imvert:namespace',$external-package/imvert:namespace)"/>
                        <xsl:choose>
                            <xsl:when test="imf:boolean($external-schemas-reference-by-url)">
                                <xsl:comment>Referenced by URL</xsl:comment>
                                <xsl:sequence select="imf:create-info-element('imvert:result-file-subpath',$external-package/imvert:location)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:comment>Referenced by local path</xsl:comment>
                                <xsl:variable name="schema-subpath" select="imf:get-xsd-filesubpath($external-package)"/>
                                <xsl:variable name="file-fullpath" select="imf:get-xsd-filefullpath($external-package)"/>
                                <xsl:sequence select="imf:create-info-element('imvert:result-file-subpath',$schema-subpath)"/>
                                <xsl:sequence select="imf:create-info-element('imvert:result-file-fullpath',$file-fullpath)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </imvert:schema>
                </xsl:for-each>
            </xsl:for-each-group>
            <!-- add an external package that is a sentinel if not yet added -->
            <xsl:for-each select="$imvert-document/imvert:packages/imvert:package[imf:boolean(imvert:sentinel) and not(imvert:name = $externals)]">
                <xsl:variable name="external-package" select="."/>
                <imvert:schema>
                    <xsl:sequence select="imf:create-info-element('imvert:name',$external-package/imvert:name)"/>
                    <xsl:sequence select="imf:create-info-element('imvert:prefix',$external-package/imvert:short-name)"/>
                    <xsl:sequence select="imf:create-info-element('imvert:namespace',$external-package/imvert:namespace)"/>
                    <xsl:choose>
                        <xsl:when test="imf:boolean($external-schemas-reference-by-url)">
                            <xsl:comment>Referenced by URL</xsl:comment>
                            <xsl:sequence select="imf:create-info-element('imvert:result-file-subpath',$external-package/imvert:location)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:comment>Referenced by local path</xsl:comment>
                            <xsl:variable name="schema-subpath" select="imf:get-xsd-filesubpath($external-package)"/>
                            <xsl:variable name="file-fullpath" select="imf:get-xsd-filefullpath($external-package)"/>
                            <xsl:sequence select="imf:create-info-element('imvert:result-file-subpath',$schema-subpath)"/>
                            <xsl:sequence select="imf:create-info-element('imvert:result-file-fullpath',$file-fullpath)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </imvert:schema>
            </xsl:for-each>
        </imvert:schemas>
    </xsl:function>
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    <xsl:function name="imf:create-datatype-property" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="primitive-type" as="xs:string"/><!-- een xs:* qname -->
        
        <xsl:variable name="p" select="imf:get-facet-pattern($this)"/>
        <xsl:if test="$p">
            <xs:pattern value="{$p}"/><!-- toegestaan op alle constructs -->
        </xsl:if>
        
        <xsl:variable name="length" select="imf:get-facet-max-length($this)"/>
        <xsl:variable name="min-l" select="imf:convert-to-atomic(substring-before($length,'..'),'xs:integer',true())"/>
        <xsl:variable name="max-l" select="imf:convert-to-atomic(substring-after($length,'..'),'xs:integer',true())"/>
        <xsl:variable name="pre-l" select="imf:convert-to-atomic(substring-before($length,','),'xs:integer',true())"/>
        <xsl:variable name="post-l" select="imf:convert-to-atomic(substring-after($length,','),'xs:integer',true())"/>
        <xsl:variable name="total" select="imf:convert-to-atomic(imf:get-facet-total-digits($this),'xs:integer',true())"/>
        <xsl:variable name="fraction" select="imf:convert-to-atomic(imf:get-facet-fraction-digits($this),'xs:integer',true())"/>
        
        <xsl:variable name="min-v" select="imf:get-facet-min-value($this)"/>
        <xsl:variable name="max-v" select="imf:get-facet-max-value($this)"/>
        
        <xsl:variable name="is-integer" select="$primitive-type = ('xs:integer')"/>
        <xsl:variable name="is-decimal" select="$primitive-type = ('xs:decimal')"/>
        <xsl:variable name="is-real"    select="$primitive-type = ('xs:real','xs:float')"/>
        <xsl:variable name="is-numeric" select="$is-integer or $is-decimal or $is-real"/>
        
        <!-- validaties --> <!-- zie 2.8.2.23 Metagegeven: Lengte (domein van een waarde van een gegeven) -->
        <xsl:sequence select="imf:report-error($this,
            (exists($length) and $is-real),
            'Length [1] not allowed for XML schema type [2]',($length,$primitive-type))"/> 
        
        <xsl:sequence select="imf:report-error($this,
            (exists($pre-l) or exists($post-l)) and not($is-decimal),
            'Length with decimal positions [1] not allowed for XML schema type [2]',($length,$primitive-type))"/>  
        
        <?x
        <xsl:sequence select="imf:report-error($this,
            (exists($min-l) or exists($max-l)) and $is-real,
            'Length range [1] not allowed for XML schema type [2]',($length,$primitive-type))"/> 
        x?>
        
        <!-- genereren van de facetten --> 
        <xsl:choose>
            <xsl:when test="exists($min-v) and exists($min-l) and $is-numeric">
                <xs:minInclusive value="{$min-v}"/>
                <xs:minLength value="{$min-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, minimum value and length, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="exists($min-v) and $is-numeric">
                <xs:minInclusive value="{$min-v}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, minimum value, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="exists($min-l) and $is-integer">
                <?x <xs:minInclusive value="{math:pow(10,$min-l - 1)}"/> x?>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on integer, minimum, for [1] (ignored)',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="exists($min-l)">
                <xs:minLength value="{$min-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on non-integer, minimum, for [1]',$primitive-type)"/>
            </xsl:when>
        </xsl:choose> 
        <xsl:choose>
            <xsl:when test="exists($max-v) and exists($max-l) and $is-numeric">
                <xs:maxInclusive value="{$max-v}"/>
                <xs:maxLength value="{$max-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, maximum value and length, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="exists($max-v) and $is-numeric">
                <xs:maxInclusive value="{$max-v}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, maximum value, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="exists($max-l) and $is-integer">
                <xs:totalDigits value="{$max-l}"/>
                <!--<xs:maxInclusive value="{math:pow(10,$max-l) - 1}"/>-->
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on integer, maximum, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="exists($max-l)">
                <xs:maxLength value="{$max-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on non-integer, maximum, for [1]',$primitive-type)"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="exists($length) and empty($min-l) and empty($pre-l) and not($is-numeric)">
            <xs:length value="{$length}"/>
        </xsl:if>
        <xsl:if test="exists($post-l)">
            <xs:fractionDigits value="{$post-l}"/>
        </xsl:if>
        <xsl:if test="exists($length )and empty($max-l) and $is-integer">
            <xs:totalDigits value="{$length}"/>
        </xsl:if>
        <xsl:if test="exists($pre-l)">
            <xs:totalDigits value="{$pre-l + $post-l}"/>
        </xsl:if>
        <xsl:if test="exists($fraction) and empty($min-l) and empty($pre-l)">
            <xs:fractionDigits value="{$fraction}"/>
        </xsl:if>
        <xsl:if test="exists($total) and empty($min-l) and empty($pre-l) and empty($length)"><!-- bij native scalars wordt ook een imvert:total-digits gezet. Hier dubbeling tegengaan. -->
            <xs:totalDigits value="{$total}"/>
        </xsl:if>
        
        <xsl:if test="empty(($p,$total)) and not($this/imvert:baretype='TXT')">
            <xsl:sequence select="imf:create-nonempty-constraint($this/imvert:type-name)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-facet-total-digits" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="$this/imvert:total-digits"/>
    </xsl:function>
    <xsl:function name="imf:get-facet-fraction-digits" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="$this/imvert:fraction-digits"/>
    </xsl:function>
    
    <!-- 
        get a type name based on the type specified, that is suited for XSD 
        
        The type may be something like:
        
        Class1
        scalar-string
    
        The package name is always specified but is irrelevant for scalars.
    -->
    <xsl:function name="imf:get-type" as="xs:string">
        <xsl:param name="uml-type" as="xs:string"/> 
        <xsl:param name="package-name" as="xs:string?"/> 
        
        <!-- check if the package is external -->
        <xsl:variable name="external-package" select="$external-schemas[imvert:name = $package-name]"/>
        
        <xsl:variable name="defining-class" select="imf:get-class($uml-type,$package-name)"/>
        <xsl:variable name="defining-package" select="$defining-class/.."/>
        
        <xsl:choose>
            <xsl:when test="contains($uml-type,':')"><!-- TODO bepalen hoe het komt dat qualified names als type worden meegeleverd -->
                <xsl:value-of select="$uml-type"/>
            </xsl:when>
            <xsl:when test="exists($external-package)">
                <xsl:value-of select="concat($external-package/imvert:short-name,':',$uml-type)"/>
            </xsl:when>
            <xsl:when test="$package-name and empty($defining-package)">
                <!-- this is a class that is not known. This is the case for nilreasons on scalar types, we need to create a class for that. -->  
                <xsl:variable name="short-name" select="$document-packages[imvert:name = $package-name]/imvert:short-name"/>
                <xsl:value-of select="concat($short-name,':',$uml-type)"/>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:variable name="primitive" select="$defining-class/imvert:primitive"/> <!-- e.g. BOOLEAN -->
                
                <xsl:variable name="uml-type-name" select="if (contains($uml-type,':')) then substring-after($uml-type,':') else $uml-type"/>
                <xsl:variable name="primitive-type" select="substring-after($uml-type-name,'http://schema.omg.org/spec/UML/2.1/uml.xml#')"/>
                
                <xsl:variable name="base-type" select="
                    if ($primitive)
                    then $primitive
                    else
                    if ($primitive-type) 
                    then $primitive-type 
                    else 
                    if (not($package-name) or imf:is-system-package($package-name)) 
                    then $uml-type-name 
                    else ()"/>
                
                <xsl:variable name="scalar" select="$all-scalars[@id=$base-type][last()]"/>
                
                <xsl:choose>
                    <xsl:when test="$base-type"> 
                        <xsl:variable name="xs-type" select="$scalar/type-map[@formal-lang='xs']"/>
                        <xsl:choose>
                            <xsl:when test="exists($scalar) and starts-with($xs-type,'#')">
                                <xsl:value-of select="$xs-type"/>
                            </xsl:when> 
                            <xsl:when test="exists($scalar)">
                                <xsl:value-of select="concat('xs:', $xs-type)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'xs:string'"/>
                                <xsl:sequence select="imf:msg('ERROR', 'Unknown native type: [1]', $base-type)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($defining-package/imvert:short-name,':',$uml-type-name)"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="imf:create-attribute-property" as="item()*">
        <xsl:param name="this" as="node()"/>
        
        <xsl:variable name="voidable" select="$this/imvert:stereotype/@id = ('stereotype-name-voidable')"/>
        <xsl:variable name="type" select="imf:get-type($this/imvert:type-name,$this/imvert:type-package)"/>
        <xs:attribute>
            <xsl:attribute name="name" select="$this/imvert:name"/>
            <xsl:attribute name="use" select="if ($this/imvert:min-occurs='0') then 'optional' else 'required'"/>
            <xsl:attribute name="type" select="$type"/>
            <xsl:sequence select="imf:get-annotation($this)"/>
        </xs:attribute>
    </xsl:function>
    
    <xsl:function name="imf:create-doc-element" as="node()*">
        <xsl:param name="element-name" as="xs:string"/>
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="value" as="xs:string*"/>
        <xsl:for-each select="$value[normalize-space(.)]">
            <xsl:element name="{$element-name}">
                <xsl:attribute name="source" select="$namespace"/>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:create-info-element" as="node()*">
        <xsl:param name="element-name" as="xs:string"/>
        <xsl:param name="value" as="xs:string*"/>
        <xsl:for-each select="$value">
            <xsl:element name="{$element-name}">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="imf:create-fixtype-property">
        <xsl:param name="scalar-type" as="xs:string"/>
        
        <xsl:variable name="scalar" select="$all-scalars[@id = $scalar-type][last()]"/>
        <xsl:variable name="scalar-construct-pattern" select="$scalar/type-modifier/pattern[@lang=$language]"/>
        <xsl:variable name="scalar-construct-union" select="$scalar/type-modifier/type-map"/>
        
        <xsl:choose>
            <xsl:when test="exists($scalar-construct-pattern)">
                <xs:restriction base="xs:string">
                    <xs:pattern value="{$scalar-construct-pattern}"/>
                </xs:restriction>
            </xsl:when>
            <xsl:when test="exists($scalar-construct-union)">
                <xs:union memberTypes="{for $t in $scalar-construct-union return concat('xs:', $t)}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR','Cannot create fixtype property')"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="imf:create-nilreason">
        <xsl:param name="is-conceptual-hasnilreason"/><!-- IM-477 -->
        <xsl:if test="not($is-conceptual-hasnilreason)">
            <xs:attribute name="nilReason" type="xs:string" use="optional"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:create-nonempty-constraint" as="item()*">
        <xsl:param name="type" as="xs:string?"/>
        <xsl:if test="$type=('scalar-string', 'scalar-uri') or not($type) and imf:boolean($strings-nonempty)">
            <xs:pattern value="\S.*"/> <!-- Note: do not use xs:minLength as this allows for a single space -->
        </xsl:if>
    </xsl:function>
 
    <xsl:function name="imf:create-scalar-property">
        <xsl:param name="this"/>
        
        <xsl:variable name="scalar-type" select="$this/imvert:type-name"/>
        
        <xsl:variable name="scalar" select="$all-scalars[@id = $scalar-type][last()]"/>
        <xsl:variable name="scalar-construct-pattern" select="$scalar/type-modifier/pattern[@lang=$language]"/>
        <xsl:variable name="scalar-construct-union" select="$scalar/type-modifier/type-map"/>
        
        <xsl:variable name="type-construct">
            <xsl:choose>
                <xsl:when test="exists($scalar-construct-pattern)">
                    <xs:restriction base="xs:string">
                        <xs:pattern value="{$scalar-construct-pattern}"/>
                    </xs:restriction>
                </xsl:when>
                <xsl:when test="exists($scalar-construct-union)">
                    <xs:union memberTypes="{for $t in $scalar-construct-union return concat('xs:', $t)}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg('ERROR','Cannot create scalar type property')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="$type-construct"/>
        
    </xsl:function>
    
    <xsl:function name="imf:get-annotation" as="node()?">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:get-annotation($this,(),())"/>
    </xsl:function>
    <xsl:function name="imf:get-annotation" as="node()?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="added-documentation" as="node()*"/>
        <xsl:param name="added-appinfo" as="node()*"/>
        <xsl:variable name="documentation" select="($added-documentation, imf:get-documentation($this))"/>
        <xsl:if test="$added-appinfo or $documentation">
            <xs:annotation>
                <xsl:sequence select="$added-appinfo"/>
                <xsl:sequence select="$documentation"/>
            </xs:annotation>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-appinfo-location" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:appinfo','http://www.imvertor.org/data-info/uri',imf:get-data-location($this))"/>
    </xsl:function>
    
    <!-- return the class that defines the type of the attribute or association passed. --> 
    <xsl:function name="imf:get-defining-class" as="node()?">
        <xsl:param name="this" as="node()"/>
        
        <!-- overrule name based searches, must be ID based.
            <xsl:sequence select="$document-packages[imvert:name=$this/imvert:type-package]/imvert:class[imvert:name=$this/imvert:type-name]"/> 
        --> 
        <xsl:sequence select="$document-classes[imvert:id=$this/imvert:type-id]"/> 
        
    </xsl:function>
    
    <!-- 
        Return this class and all classes that are substitutable for this class, that are also linkable (and therefore a reference element must be created). 
        The class passed as rootclass may be abstract and still be linkable; linkable substitution classes must be concrete.
   
        This set also includes classes that realize this class in a static way.
        These classes do not inherit any properties of the realizes class, but can take its place. 
    -->
    <xsl:function name="imf:get-linkable-subclasses-or-self" as="node()*">
        <xsl:param name="rootclass" as="node()"/>
        <xsl:sequence select="imf:get-substitutable-subclasses($rootclass,true())[imf:is-linkable(.)]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-qname" as="xs:string">
        <xsl:param name="class" as="node()"/>
        <xsl:value-of select="concat($class/parent::imvert:package/imvert:short-name,':',$class/imvert:name)"/>
    </xsl:function>
    
    <!-- return all associations to this class -->
    <xsl:function name="imf:get-references">
        <xsl:param name="class" as="element()"/>
        <xsl:variable name="id" select="$class/imvert:id"/>
        <xsl:sequence select="for $a in $document-classes//imvert:association return if ($a/imvert:type-id = $id) then $a else ()"/>
    </xsl:function>
    
    <!-- 
        return the release number of the Model and therefore the XSD to be generated 
    -->
    <xsl:function name="imf:get-release" as="xs:string?">
        <xsl:param name="this" as="node()"/>
        <!-- 
            Assume release of supplier, unless release specified.
        -->
        <xsl:variable name="release" select="$this/imvert:release"/>
        <xsl:choose>
            <xsl:when test="exists($release)">
                <xsl:value-of select="$release"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR', 'No release found for package: [1] ([2])',($this/imvert:name,$this/imvert:namespace))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-restriction-basetype-name" as="xs:string">
        <xsl:param name="this" as="node()"/> <!-- any attribute/association node. -->
        <xsl:value-of select="concat('Basetype_',$this/ancestor::imvert:class/imvert:name,'_',$this/imvert:name)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-schema-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/file-location',imf:get-xsd-filesubpath($this))"/>
        <xsl:sequence select="imf:create-doc-element('xs:documentation','http://www.imvertor.org/schema-info/conversion',imf:get-config-parameter('pretext-encoding'))"/>
    </xsl:function>
    
    <!-- 
        Return all classes that can be substituted for the class passed, and self. 
        Do not return abstract classes. 
    -->
    <xsl:function name="imf:get-substitutable-subclasses" as="element()*">
        <xsl:param name="rootclass" as="element()"/>
        <xsl:param name="include-self" as="xs:boolean"/>
        <xsl:variable name="substitution-classes" select="imf:get-substitution-classes($rootclass)"/>
        <xsl:sequence select="if ($include-self) then $rootclass else ()"/>
        <xsl:sequence select="$substitution-classes"/>
    </xsl:function>
    
    <!-- 
        Return all classes that can be substituted for the class passed, but not self.
        Also returns abstract classes.
    -->
    <xsl:function name="imf:get-substitution-classes" as="node()*">
        <xsl:param name="class" as="node()"/>
        <xsl:variable name="class-id" select="$class/imvert:id"/>
        <xsl:for-each select="$document-classes[imvert:substitution/imvert:supplier-id=$class-id or imvert:supertype/imvert:type-id=$class-id]">
            <xsl:sequence select="."/>
            <xsl:sequence select="imf:get-substitution-classes(.)"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
        return the full XSD file path of the package passed.
    -->
    <xsl:function name="imf:get-xsd-filefullpath" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="schema-subpath" select="imf:get-xsd-filesubpath($this)"/>
        <xsl:value-of select="concat($work-xsd-folder-url,'/',$schema-subpath)"/>
    </xsl:function>
    
    <!-- 
        Get the path of the xsd file. This is the part of the namespace that is behind the repository-url.
        Example:
        root namespace (alias) is: 
            http://www.imvertor.org/schema
        URL is: 
            http://www.imvertor.org/schema/my/schema/
        and release is: 
            20120307
        returns: 
            /my/schema/v20120307
    -->    
    <xsl:function name="imf:get-xsd-filefolder" as="xs:string">
        <xsl:param name="this" as="node()"/> <!-- an imvert:package -->
        <xsl:variable name="localpath" select="substring-after($this/imvert:namespace,concat($base-namespace,'/'))"/>
        <xsl:value-of select="concat(if (normalize-space($localpath)) then $localpath else 'unknown','/v',$this/imvert:release)"/>
    </xsl:function>
    
    <!--
        Return the file name of the XSD to be generated.
    -->
    <xsl:function name="imf:get-xsd-filename" as="xs:string">
        <xsl:param name="this" as="node()"/>
        
        <xsl:sequence select="imf:set-config-string('work','xsd-domain',$this/imvert:name,true())"/>
        <xsl:sequence select="imf:set-config-string('work','xsd-version',replace($this/imvert:version,'\.','_'),true())"/>
        <xsl:sequence select="imf:set-config-string('work','xsd-application',$application-package-name,true())"/>
        
        <xsl:value-of select="imf:merge-parms(imf:get-config-string('cli','xsdfilename'))"/>
    </xsl:function>
    
    <!-- 
        Return the complete subpath and filename of the xsd file to be generated.
        Sample: xsd-folder/subpath/my/schema/MyappMypackage_1_0_3.xsd
        
        xsd-folder/subpath is provided as a cli parameter cli/xsdsubpath
    -->
    <xsl:function name="imf:get-xsd-filesubpath" as="xs:string">
        <xsl:param name="this" as="node()"/> <!-- a package -->
        <xsl:choose>
            <xsl:when test="$this/imvert:stereotype/@id = (('stereotype-name-external-package','stereotype-name-system-package'))"> 
                <!-- 
                    the package is external (GML, Xlink or the like). 
                    Place reference to that external pack. 
                    The package is copied alongside the target application package.
                --> 
                <xsl:value-of select="imf:get-uri-parts($this/imvert:location)/path"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($xsd-subpath, '/', imf:get-xsd-filefolder($this), '/', encode-for-uri(imf:get-xsd-filename($this)))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:is-abstract">
        <xsl:param name="class"/>
        <xsl:sequence select="imf:boolean($class/imvert:abstract)"/>        
    </xsl:function>
    
    <xsl:function name="imf:is-restriction" as="xs:boolean">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="exists((imf:get-facet-pattern($this), imf:get-facet-max-length($this), imf:get-facet-total-digits($this), imf:get-facet-fraction-digits($this)))"/>
    </xsl:function>
    
    <xsl:function name="imf:is-system-package" as="xs:boolean">
        <xsl:param name="package-name" as="xs:string"/>
        <xsl:copy-of select="substring-before($package-name,'_') = ('EA','Info')"/>
    </xsl:function>
    
    <!-- 
        Return the members of sequence set1 that are not in set2. 
        The comparison is based on the string value of the members. 
    -->
    <xsl:function name="imf:sequence-except-by-string-value" as="item()*">
        <xsl:param name="set1" as="item()*"/>
        <xsl:param name="set2" as="item()*"/>
        <xsl:for-each select="$set1">
            <xsl:variable name="stringvalue" select="xs:string(.)"/>
            <xsl:if test="not($set2 = $stringvalue)">
                <xsl:sequence select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
</xsl:stylesheet>

