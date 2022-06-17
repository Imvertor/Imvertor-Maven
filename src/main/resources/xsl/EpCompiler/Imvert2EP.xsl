<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:param name="ep-schema-path">somewhere</xsl:param>
    
    <xsl:variable name="stylesheet-code">EP</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/> 
    
    <xsl:variable name="domain-packages" select="/imvert:packages/imvert:package[imvert:stereotype/@id = 'stereotype-name-domain-package']"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:variable name="body" as="element()">
            <ep:construct 
                xsi:schemaLocation="http://www.imvertor.org/schema/endproduct {$ep-schema-path}">
                <ep:parameters>
                    <xsl:sequence select="imf:set-parameter('version',imvert:version)"/>
                </ep:parameters>
                <ep:name>
                    <xsl:value-of select="imvert:application"/>
                </ep:name>
                <ep:tech-name>
                    <xsl:value-of select="imvert:subpath"/>
                </ep:tech-name>
                <xsl:sequence select="imf:get-documentation(.)"/>
                <ep:seq>
                    <xsl:apply-templates select="imvert:package"/>
                </ep:seq>
            </ep:construct>
        </xsl:variable>
        <xsl:apply-templates select="$body" mode="remove-empty-elements"/>
    </xsl:template>
    
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-domain-package']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Domein',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('namespace',imvert:namespace)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="imvert:class"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-view-package']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een View',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('namespace',imvert:namespace)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="imvert:class"/>
            </ep:seq>
        </ep:construct>
    </xsl:template> 
    
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-external-package']">
        <xsl:choose>
            <xsl:when test="imvert:conceptual-schema-namespace = ('http://www.geonovum.nl/conceptual-schemas/MIM11','http://www.kadaster.nl/conceptual-schemas/MIM11')">
                <!-- skip -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="defs" as="node()*">
                    <xsl:for-each select="imvert:class">
                        <!-- verwerk deze klasse als ernaar verwezen wordt in het model -->
                        <xsl:if test="$domain-packages//*[imvert:conceptual-schema-type = current()/imvert:conceptual-schema-class-name]">
                            <xsl:apply-templates select="."/><!-- dit zijn interfaces -->
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="exists($defs)">
                    <ep:construct>
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Extern package',())"/>
                        <ep:parameters>
                            <xsl:sequence select="imf:set-parameter('namespace',imvert:namespace)"/>
                        </ep:parameters>
                        <xsl:sequence select="imf:get-names(.)"/>
                        <xsl:sequence select="imf:get-documentation(.)"/>
                        <ep:seq>
                            <xsl:sequence select="$defs"/>
                        </ep:seq>
                    </ep:construct>    
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-system-package']">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-objecttype']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Objecttype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-relatieklasse']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Relatieklasse',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-koppelklasse']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Koppelklasse',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-composite']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Gegevensgroeptype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:association[imvert:stereotype/@id = 'stereotype-name-externekoppeling']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Externe koppeling',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-union-datatypes']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze tussen datatypen',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:choice>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute"/>
            </ep:choice>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-union-associations']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze tussen objecttypen',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:choice>
                <xsl:apply-templates select="imvert:associations/imvert:association"/>
            </ep:choice>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-codelist']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Codelist',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','codelist')"/>
                <xsl:sequence select="imf:get-data-location(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:data-type>ep:string</ep:data-type>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-enumeration']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Enumeratie',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:data-type>ep:string</ep:data-type>
            <xsl:apply-templates select="imvert:attributes/imvert:attribute"/><!-- allemaal <<enum>> -->
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-interface']">
        <xsl:variable name="attribute" select="($domain-packages//imvert:attribute[imvert:type-id = current()/imvert:id])[1]"/>
        <xsl:if test="$attribute">
            <ep:construct>
                <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Interface (extern)',())"/>
                <ep:parameters>
                    <xsl:sequence select="imf:set-parameter('oas-name',$attribute/imvert:type-name-oas)"/>
                </ep:parameters>
                <xsl:sequence select="imf:get-id(.)"/>
                <xsl:sequence select="imf:get-names(.)"/>
                <xsl:sequence select="imf:get-documentation(.)"/>
                <xsl:sequence select="imf:get-interface-type($attribute)"/><!-- geef attribuut mee; daarin is de type info van de conceptual schema opgenomen -->
            </ep:construct>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-complextype']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een gestructureerd datatype',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-referentielijst']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een referentielijst',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-data-location(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute">
                    <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-simpletype']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een primitief datatype',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:data-type>ep:string</ep:data-type>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-attribute']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een attribuutsoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-nillable(.)"/>
                <xsl:sequence select="imf:get-data-location(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
        </ep:construct>
    </xsl:template>

    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-attributegroup']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Gegevensgroep',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-union-element']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een keuze element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','keuze-element-datatype')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
   
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-data-element']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een data element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','data-element')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-referentie-element']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een referentie element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','referentie-element')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-enum']">
        <ep:enum>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een enumeratie waarde',())"/>
            <ep:name>
                <xsl:value-of select="imvert:name/@original"/>
            </ep:name>
            <ep:alias>
                <xsl:value-of select="imvert:alias"/>
            </ep:alias>         
        </ep:enum>
    </xsl:template>
    
    <xsl:template match="imvert:association[imvert:stereotype/@id = 'stereotype-name-relatiesoort']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Relatiesoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:association[imvert:stereotype/@id = 'stereotype-name-union-association']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een objecttype in een keuze',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
     
    <!-- fallback -->
    <xsl:template match="imvert:package">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown [1] type, stereotype is: [2]', ('package',imf:string-group(imvert:stereotype/@id)))"/>
    </xsl:template>
    <xsl:template match="imvert:class">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown [1] type, stereotype is: [2]', ('class',imf:string-group(imvert:stereotype/@id)))"/>
    </xsl:template>
    <xsl:template match="imvert:attribute">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown [1] type, stereotype is: [2]', ('attribute',imf:string-group(imvert:stereotype/@id)))"/>
    </xsl:template>
    <xsl:template match="imvert:association">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown [1] type, stereotype is: [2]', ('association',imf:string-group(imvert:stereotype/@id)))"/>
    </xsl:template>
    
    <xsl:template match="xhtml:*">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:sequence select="imf:msg-comment(.,'ERROR','Unknown element [1]',name(.))"/>
    </xsl:template>
    
    <!--
        Remove certain elements that are empty.
    -->    
    <xsl:template match="
        ep:min-occurs | 
        ep:max-occurs | 
        ep:documentation | 
        ep:description | 
        ep:parameters | 
        ep:seq | 
        ep:min-length | 
        ep:max-length | 
        ep:min-value | 
        ep:max-value | 
        ep:pattern | 
        ep:formal-pattern | 
        ep:alias | 
        ep:example
        " 
        mode="remove-empty-elements">
        <xsl:if test="normalize-space()">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="node()" mode="remove-empty-elements">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <!--
        FUNCTIONS 
    -->    
    <xsl:function name="imf:get-id" as="element()*">
        <xsl:param name="this"/>
        <ep:id>
            <xsl:value-of select="$this/imvert:id"/>
        </ep:id>
    </xsl:function>
    
    <xsl:function name="imf:get-names" as="element()*">
        <xsl:param name="this"/>
        <ep:name>
            <xsl:value-of select="($this/imvert:name/@original,'UNKNOWN')[1]"/>
        </ep:name>
        <ep:tech-name>
            <xsl:value-of select="($this/imvert:name,'UNKNOWN')[1]"/>
        </ep:tech-name>
    </xsl:function>
    
    <xsl:function name="imf:get-supers" as="element()*">
        <xsl:param name="this"/>
        <!-- TODO let op: in xml schema generatie moet static een copy-down worden! -->
        <xsl:for-each select="$this/imvert:supertype/imvert:type-id">
            <xsl:sequence select="imf:set-parameter('super',.)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation" as="element(ep:documentation)?">
        <xsl:param name="this"/>
        <ep:documentation>
            <ep:definition>
                <xsl:sequence select="imf:get-note-value(imf:tagged-value($this,'CFG-TV-DEFINITION'))"/>  
            </ep:definition>
            <ep:description>
                <xsl:sequence select="imf:get-note-value(imf:tagged-value($this,'CFG-TV-DESCRIPTION'))"/>  
            </ep:description>
            <ep:pattern>
                <xsl:sequence select="imf:get-note-value(imf:tagged-value($this,'CFG-TV-PATTERN'))"/>  
            </ep:pattern>
        </ep:documentation>
    </xsl:function>
    
    <xsl:function name="imf:get-data-location" as="element(ep:parameter)?">
        <xsl:param name="this"/>
        <xsl:sequence select="for $tv in (imf:tagged-value($this,'CFG-TV-DATALOCATION')) return imf:set-parameter('data-location',$tv)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-nillable" as="element()?">
        <xsl:param name="this"/>
        <xsl:if test="imf:boolean(imf:tagged-value($this,'CFG-TV-VOIDABLE'))">
            <xsl:sequence select="imf:set-parameter('nillable','true')"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-cardinality" as="element()*">
        <xsl:param name="this"/>
        <ep:min-occurs>
            <xsl:value-of select="$this/imvert:min-occurs[. ne '1']"/>
        </ep:min-occurs>
        <ep:max-occurs>
            <xsl:value-of select="$this/imvert:max-occurs[. ne '1']"/>
        </ep:max-occurs>
    </xsl:function>
    
    <xsl:function name="imf:get-type" as="node()*">
        <xsl:param name="this"/>
        <xsl:choose>
            <xsl:when test="$this/imvert:type-name = 'scalar-string' or $this/imvert:primitive-oas = 'string'">
                <ep:data-type>ep:string</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-integer' or $this/imvert:primitive-oas = 'integer'">
                <ep:data-type>ep:integer</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-decimal' or $this/imvert:primitive-oas = 'decimal'">
                <ep:data-type>ep:decimal</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-real' or $this/imvert:primitive-oas = 'real'">
                <ep:data-type>ep:real</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-boolean' or $this/imvert:primitive-oas = 'boolean'">
                <ep:data-type>ep:boolean</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-year' or $this/imvert:primitive-oas = 'year'">
                <ep:data-type>ep:year</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-month' or $this/imvert:primitive-oas = 'month'">
                <ep:data-type>ep:month</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-day' or $this/imvert:primitive-oas = 'day'">
                <ep:data-type>ep:day</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-yearmonth' or $this/imvert:primitive-oas = 'yearmonth'">
                <ep:data-type>ep:yearmonth</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-date' or $this/imvert:primitive-oas = 'date'">
                <ep:data-type>ep:date</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-datetime' or $this/imvert:primitive-oas = 'datetime'">
                <ep:data-type>ep:datetime</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-time' or $this/imvert:primitive-oas = 'time'">
                <ep:data-type>ep:time</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-uri' or $this/imvert:primitive-oas = 'uri'">
                <ep:data-type>ep:uri</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-id">
                <xsl:sequence select="imf:get-ref($this)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg-comment($this,'WARNING','Unknown (data)type: [1]',($this/imvert:type-name, $this/imvert:baretype)[1])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-ref" as="element(ep:ref)">
        <xsl:param name="this" as="element()"/><!-- imvert:attribute of imvert:association -->
        <ep:ref>
            <xsl:value-of select="$this/imvert:type-id"/>
        </ep:ref>
    </xsl:function>
    
    <xsl:function name="imf:get-props" as="element()*">
        <xsl:param name="this"/>
        
        <ep:min-value>
            <xsl:value-of select="imf:tagged-value($this,'CFG-TV-MINVALUEINCLUSIVE')"/>
        </ep:min-value>
        <ep:max-value>
            <xsl:value-of select="imf:tagged-value($this,'CFG-TV-MAXVALUEINCLUSIVE')"/>
        </ep:max-value>
        
        <xsl:variable name="len" select="tokenize(imf:tagged-value($this,'CFG-TV-LENGTH'),'\.+')"/>
        <ep:min-length>
            <xsl:value-of select="if ($len[2]) then $len[1] else ()"/>
        </ep:min-length>
        <ep:max-length>
            <xsl:value-of select="if ($len[2]) then $len[2] else $len[1]"/>
        </ep:max-length>
        
        <ep:formal-pattern>
            <xsl:value-of select="imf:tagged-value($this,'CFG-TV-FORMALPATTERN')"/>
        </ep:formal-pattern>
    </xsl:function>
    
    <xsl:function name="imf:get-meta" as="element()*">
        <xsl:param name="this"/>
        <ep:example>
            <xsl:variable name="xmp" select="imf:tagged-value($this,'CFG-TV-EXAMPLE')"/>
            <xsl:sequence select="imf:get-note-value($xmp)"/>  
        </ep:example>
    </xsl:function>
    
    <xsl:function name="imf:get-interface-type" as="node()*">
        <xsl:param name="attribute"/>
        <xsl:variable name="ep-type" select="imf:get-type($attribute)"/>
        <xsl:choose>
            <xsl:when test="$ep-type/self::ep:ref">
                <ep:external>true</ep:external><!-- signalleer dat dit een externe constructie is; oplossen door de verwerkende software -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$ep-type"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>    
    
    <xsl:function name="imf:set-parameter" as="element(ep:parameter)*">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="normalize-space($value)">
            <ep:parameter>
                <ep:name>
                    <xsl:value-of select="$name"/>
                </ep:name>
                <ep:value>
                    <xsl:value-of select="$value"/>
                </ep:value>
            </ep:parameter>
        </xsl:if>
    </xsl:function>
   
    <xsl:function name="imf:msg-comment">
        <xsl:param name="this" as="node()*"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
      
        <xsl:variable name="ctext" select="imf:msg-insert-parms($text,$info)"/>
        <xsl:comment>{$type} : {imf:get-display-name($this)} : {$ctext}</xsl:comment>
      
        <xsl:sequence select="imf:msg($this,$type,$text,$info)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:tagged-value" as="item()*">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="tv-id" as="xs:string"/>
        
        <xsl:variable name="def" select="
            if (imf:boolean($this/imvert:derived)) 
            then imf:get-most-relevant-compiled-taggedvalue($this,'##' || $tv-id)
            else imf:get-tagged-value-element($this,'##' || $tv-id)
            "/>
        <xsl:sequence select="$def/imvert:value/node()"/>
    </xsl:function>
    
    <xsl:function name="imf:get-note-value" as="item()*">
        <xsl:param name="note-field" as="item()*"/>
        <xsl:choose>
            <xsl:when test="$note-field/*">
                <xsl:sequence select="$note-field"/>
            </xsl:when>
            <xsl:otherwise>
                <xhtml:body>
                    <xhtml:p>
                        <xsl:value-of select="$note-field"/>
                    </xhtml:p>
                </xhtml:body>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
       
</xsl:stylesheet>