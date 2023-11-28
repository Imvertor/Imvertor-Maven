<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mim="http://www.geostandaarden.nl/mim/mim-core/1.1"
    xmlns:mim-ext="http://www.geostandaarden.nl/mim/mim-ext/1.0"
    xmlns:mim-ref="http://www.geostandaarden.nl/mim/mim-ref/1.0"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    xmlns:pack="http://www.armatiek.nl/packs"
    
    expand-text="yes"
    >
    
    <!-- 
       Deze stylesheet wwrkt op MIM serialisatie formaat.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/packs/pack-strip.xsl"/>
    <xsl:import href="reorder-ep-structure.xsl"/>
    
    <!-- TODO derivation, moet dat in MIM serialisatie worden opgelost? -->
   
    <xsl:param name="ep-schema-path">somewhere</xsl:param>
    
    <xsl:variable name="stylesheet-code">EP</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/> 
    
    <xsl:variable name="bp-req-basic-encodings" select="$configuration-jsonschemarules-file//parameter[@name = 'bp-basic-encodings']"/> 
    <xsl:variable name="bp-req-by-reference-encodings" select="$configuration-jsonschemarules-file//parameter[@name = 'bp-by-reference-encodings']"/> 
    <xsl:variable name="bp-req-union-encodings" select="$configuration-jsonschemarules-file//parameter[@name = 'bp-union-encodings']"/> 
    <xsl:variable name="bp-req-code-list-encodings" select="$configuration-jsonschemarules-file//parameter[@name = 'bp-code-list-encodings']"/> 
    <xsl:variable name="bp-req-additional-requirements-classes" select="$configuration-jsonschemarules-file//parameter[@name = 'bp-additional-requirements-classes']"/> 
    
    <xsl:variable name="domain-packages" select="/mim:Informatiemodel/mim:packages/mim:Domein"/>
    
    <xsl:variable name="relatierol-leidend" select="/mim:Informatiemodel/mim:relatiemodelleringtype = 'Relatierol leidend'"/>
    
    <xsl:template match="/">
   
       <xsl:variable name="step-1" as="element(ep:group)">
            <xsl:apply-templates select="/mim:Informatiemodel"/>    
        </xsl:variable>
      
        <xsl:sequence select="pack:reorder-ep-structure($step-1)"/>

    </xsl:template>
    
    <xsl:template match="mim:Informatiemodel">
        <xsl:variable name="body" as="element()">
            <ep:group 
                xsi:schemaLocation="http://www.imvertor.org/schema/endproduct/v2 {$ep-schema-path}">
                <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Model',())"/>
                <ep:parameters>
                    <xsl:sequence select="imf:set-common-parameters(.,'informatiemodel')"/>
                    <xsl:sequence select="imf:set-parameter('version',imf:get-kenmerk(.,'version'))"/>
                    <xsl:sequence select="imf:set-parameter('release',imf:get-kenmerk(.,'release'))"/>
                    <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'namespace'))"/>
                    <xsl:sequence select="imf:set-parameter('imvertor-version',imf:get-kenmerk(.,'imvertor-version'))"/>
                    <xsl:sequence select="imf:set-parameter('json-schema-variant',imf:get-xparm('cli/createjsonschemavariant'))"/>
                    <xsl:sequence select="imf:set-parameter('json-document-name',imf:get-kenmerk(.,'json document'))"/>
                    <xsl:sequence select="imf:set-parameter('json-id',imf:get-kenmerk(.,'json id'))"/>
                    <xsl:sequence select="imf:set-parameter('bp-req-applies','yes')"/>
                    <xsl:sequence select="imf:set-parameter('bp-req-basic-encodings',$bp-req-basic-encodings)"/>
                    <xsl:sequence select="imf:set-parameter('bp-req-union-encodings',$bp-req-union-encodings)"/>
                    <xsl:sequence select="imf:set-parameter('bp-req-by-reference-encodings',$bp-req-by-reference-encodings)"/>
                    <xsl:sequence select="imf:set-parameter('bp-req-code-list-encodings',$bp-req-code-list-encodings)"/>
                    <xsl:sequence select="imf:set-parameter('bp-req-additional-requirements-classes',$bp-req-additional-requirements-classes)"/>
                </ep:parameters>
                <xsl:sequence select="imf:get-name(.)"/>
                <xsl:sequence select="imf:get-documentation(.)"/>
                <ep:seq>
                    <xsl:apply-templates select="mim:packages/*"/>
                </ep:seq>
            </ep:group>
        </xsl:variable>
        <xsl:apply-templates select="$body" mode="remove-empty-elements"/>
    </xsl:template>
    
    <xsl:template match="mim:Domein">
        <ep:group>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Domein',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'namespace'))"/>
                <xsl:sequence select="imf:set-common-parameters(.,'domein')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:datatypen/*"/>
                <xsl:apply-templates select="mim:objecttypen/*"/>
                <xsl:apply-templates select="mim:gegevensgroeptypen/*"/>
                <xsl:apply-templates select="mim:keuzen/*"/>
            </ep:seq>
        </ep:group>
    </xsl:template>
    
    <xsl:template match="mim:View">
        <ep:group>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een View',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'view')"/>
                <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'namespace'))"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:datatypen/*"/>
                <xsl:apply-templates select="mim:objecttypen/*"/>
                <xsl:apply-templates select="mim:gegevensgroeptypen/*"/>
                <xsl:apply-templates select="mim:keuzen/*"/>
            </ep:seq>
        </ep:group>
    </xsl:template> 
    
    <xsl:template match="mim:Extern">
        <xsl:variable name="defs" as="node()*">
            <xsl:apply-templates select="mim-ext:constructies/mim-ext:Constructie"/><!-- dit zijn interfaces -->
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="mim:naam = 'MIM11'">
                <!-- skip -->
            </xsl:when>
            <xsl:when test="exists($defs)">
                <ep:group>
                    <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Extern',())"/>
                    <ep:parameters>
                        <xsl:sequence select="imf:set-common-parameters(.,'extern')"/>
                        <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'namespace'))"/>
                    </ep:parameters>
                    <xsl:sequence select="imf:get-name(.)"/>
                    <xsl:sequence select="imf:get-documentation(.)"/>
                    <ep:seq>
                        <xsl:sequence select="$defs"/>
                    </ep:seq>
                </ep:group>    
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mim:Objecttype">
        
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Objecttype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'objecttype')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            
            <xsl:sequence select="imf:get-supers(.)"/>
            
            <ep:seq>
                <xsl:sequence select="imf:add-entitytype(.)"/>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
                <xsl:apply-templates select="mim:gegevensgroepen/mim:Gegevensgroep"/>
                <xsl:apply-templates select="mim:relatiesoorten/mim:Relatiesoort"/>
                <xsl:apply-templates select="mim:keuzen/mim-ref:KeuzeRef"/>
                <xsl:apply-templates select="mim:externeKoppelingen/mim:ExterneKoppeling"/>
            </ep:seq>
            
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Relatieklasse">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Relatieklasse',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'relatieklasse')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:sequence select="imf:add-entitytype(.)"/>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
                <xsl:apply-templates select="mim:gegevensgroepen/mim:Gegevensgroep"/>
                <xsl:apply-templates select="mim:relatiesoorten/mim:Relatiesoort"/>
                <xsl:apply-templates select="mim:keuzen/mim-ref:KeuzeRef"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Koppelklasse">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Koppelklasse',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'koppelklasse')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:sequence select="imf:add-entitytype(.)"/>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
                <xsl:apply-templates select="mim:gegevensgroepen/mim:Gegevensgroep"/>
                <xsl:apply-templates select="mim:relatiesoorten/mim:Relatiesoort"/>
                <xsl:apply-templates select="mim:keuzen/mim-ref:KeuzeRef"/>
                <xsl:apply-templates select="mim:externeKoppelingen/mim:ExterneKoppeling"/><!-- koppelklasse is een soort objecttype -->
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Gegevensgroeptype">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Gegevensgroeptype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'gegevensgroeptype')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:sequence select="imf:add-entitytype(.)"/>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
                <xsl:apply-templates select="mim:gegevensgroepen/mim:Gegevensgroep"/>
                <xsl:apply-templates select="mim:relatiesoorten/mim:Relatiesoort"/>
                <xsl:apply-templates select="mim:keuzen/mim-ref:KeuzeRef"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:ExterneKoppeling">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Externe koppeling',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'externekoppeling')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:apply-templates select="mim:doel/mim-ref:ObjecttypeRef"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Keuze">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'keuze')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:apply-templates select="mim:keuzeDatatypen | mim:keuzeRelatiedoelen | mim:keuzeAttributen"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeDatatypen">
        <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze tussen datatypen',())"/>
        <xsl:variable name="by-type" select="$bp-req-union-encodings = '/req/union-type-discriminator'"/>
        <xsl:choose>
            <xsl:when test="$by-type">
                <ep:choice>
                    <xsl:apply-templates select="mim:Datatype | mim-ref:DatatypeRef | mim-ext:ConstructieRef"/>
                </ep:choice>
            </xsl:when>
            <xsl:otherwise>
                <ep:seq>
                    <xsl:apply-templates select="mim:Datatype | mim-ref:DatatypeRef | mim-ext:ConstructieRef"/>
                </ep:seq>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="mim:keuzeRelatiedoelen">
        <ep:choice>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze tussen objecttypen / relatiedoelen',())"/>
            <xsl:apply-templates select="mim:Relatiedoel/mim-ref:ObjecttypeRef"/>
        </ep:choice>
    </xsl:template>
    
    <xsl:template match="mim:keuzeAttributen">
        <ep:choice>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze tussen Attribuutsoorten',())"/>
            <xsl:apply-templates select="mim:Attribuutsoort"/>
        </ep:choice>
    </xsl:template>
    
    <xsl:template match="mim:keuzen/mim-ref:KeuzeRef">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Json schema cannot represent a choice between properties, please adapt your model',())"/>
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een pseudo-attribuut dat een keuze tussen attribuutsoorten representeert',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'keuzeref')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Codelijst">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Codelijst',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'codelijst')"/>
                <xsl:sequence select="imf:set-parameter('locatie',mim:locatie)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <xsl:variable name="type" select="lower-case(imf:get-kenmerk(.,'literalEncodingType'))"/>
            <xsl:variable name="jtype" select="if ($type = ('real','number')) then 'ep:number' else if ($type = ('integer')) then 'ep:integer' else 'ep:string'"/>
            <ep:data-type>{$jtype}</ep:data-type>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Enumeratie">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Enumeratie',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'enumeratie')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <xsl:variable name="type" select="lower-case(imf:get-kenmerk(.,'literalEncodingType'))"/>
            <xsl:variable name="jtype" select="if ($type = ('real','number')) then 'ep:number' else if ($type = ('integer')) then 'ep:integer' else 'ep:string'"/>
            <ep:data-type>{$jtype}</ep:data-type>
            <xsl:apply-templates select="mim:waarden/mim:Waarde"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim-ext:Constructie[mim-ext:constructietype = 'INTERFACE']">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Interface (extern)',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'interface')"/>
                <xsl:sequence select="imf:set-parameter('oas-name',imf:get-kenmerk(.,'oasnaam'))"/>
                <xsl:if test="ancestor::mim:Extern/mim:naam = 'GML'">
                    <xsl:sequence select="imf:set-parameter('url',imf:get-geo-url(.))"/>
                </xsl:if>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:external>true</ep:external><!-- signalleer dat dit een externe constructie is; oplossen door de verwerkende software -->
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:GestructureerdDatatype">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een gestructureerd datatype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'gestructureerddatatype')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:dataElementen/mim:DataElement"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Referentielijst">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een referentielijst',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'referentielijst')"/>
                <xsl:sequence select="imf:set-parameter('locatie',mim:locatie)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:referentieElementen/mim:ReferentieElement"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:PrimitiefDatatype">
        <xsl:variable name="super" select="mim:supertypen/mim:GeneralisatieDatatypen"/>
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een primitief datatype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'primitiefdatatype')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <xsl:sequence select="imf:get-type($super)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Attribuutsoort">
        
        <!-- 
            Kijk of er een supertype is dat een pga heeft
            
            Als die er is, dan geldt de default NIET. Maar wel een eventueel lokaal vastgestelde ppa.
            Als die er niet is, dan geldt de DEFAULT wel (en een eventueel lokaal vastgestelde ppa)
        -->
        <xsl:variable name="requires-pia" select="$bp-req-basic-encodings = '/req/jsonfg'"/>
        <xsl:variable name="requires-pva" select="$bp-req-basic-encodings = '/req/jsonfg'"/>
        
        <xsl:variable name="obj" select="if (imf:is-featuretype(../..)) then ../.. else ()"/>
        <xsl:variable name="pga" select="if ($obj) then if (imf:get-supers-with-pga($obj)) then () else imf:get-primary-geometry-attribute($obj) else ()"/>
        <xsl:variable name="ppa" select="if ($obj) then if (imf:get-supers-with-ppa($obj)) then () else imf:get-primary-place-attribute($obj) else ()"/>
        <xsl:variable name="pia" select="if ($obj and $requires-pia) then if (imf:get-supers-with-pia($obj)) then () else imf:get-primary-instant-attribute($obj) else ()"/>
        <xsl:variable name="pva" select="if ($obj and $requires-pva) then if (imf:get-supers-with-pva($obj)) then () else imf:get-primary-interval-attributes($obj) else ()"/>
        <xsl:variable name="pva" select="()"/><!-- TODO https://github.com/Geonovum/shapeChangeTest/issues/27 -->
        <xsl:variable name="unit" select="imf:get-kenmerk(.,'eenheid')"/>
        <xsl:variable name="is-gml-measure-type" select="lower-case(mim:naam) = ('measure', 'length', 'speed', 'angle', 'area', 'volume')"/>
        <xsl:variable name="inlineOrByReference" select="(imf:get-kenmerk(.,'inlineOrByReference'),'inline')[1]"/><!-- see /req/by-reference-basic/inline-or-by-reference-tag -->
        
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een attribuutsoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'attribuutsoort')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
                <xsl:sequence select="imf:get-data-location(.)"/>
                <xsl:sequence select="imf:set-parameter('is-value-derived',imf:get-kenmerk(.,'is-value-derived'))"/>
                <xsl:sequence select="imf:set-parameter('is-identifying',imf:boolean(mim:identificerend))"/><!-- see /req/geojson-formats/identifier, we gebruiken dit verder niet, misschien een todo -->
                <xsl:sequence select="imf:set-parameter('is-pga',mim:naam = $pga/mim:naam)"/>
                <xsl:sequence select="imf:set-parameter('is-ppa',mim:naam = $ppa/mim:naam)"/>
                <xsl:sequence select="imf:set-parameter('is-pia',mim:naam = $pia/mim:naam)"/>
                <xsl:sequence select="imf:set-parameter('is-pva',mim:naam = $pva/mim:naam)"/>
                <xsl:sequence select="imf:set-parameter('inlineorbyreference',$inlineOrByReference)"/>
                <xsl:sequence select="imf:set-parameter('unit',$unit)"/><!-- wordt verwerkt in json stap. zie /req/core/iso19103-measure-types -->
            </ep:parameters>
            <ep:name>
                <xsl:choose>
                    <xsl:when test="mim:naam = $pga/mim:naam">geometry</xsl:when>
                    <xsl:when test="mim:naam = $ppa/mim:naam">place</xsl:when>
                    <xsl:when test="mim:naam = $pia/mim:naam">time</xsl:when>
                    <xsl:when test="mim:naam = $pva/mim:naam">time</xsl:when><!-- TODO https://github.com/Geonovum/shapeChangeTest/issues/27 -->
                    <xsl:otherwise>{imf:get-name(.)}</xsl:otherwise>
                </xsl:choose>
            </ep:name>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <ep:initial-value>
                <xsl:value-of select="imf:get-kenmerk(.,'startwaarde')"/>
            </ep:initial-value>
            <ep:read-only>
                <xsl:value-of select="imf:get-kenmerk(.,'readonly')"/>
            </ep:read-only>
            <xsl:choose>
                <xsl:when test="$unit">
                    <ep:data-type>ep:number</ep:data-type>
                </xsl:when>
                <xsl:when test="$is-gml-measure-type">
                    <ep:ref href="/known/measure">Measure</ep:ref>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:get-type(.)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:sequence select="imf:get-props(.)"/>
            
        </ep:construct>
    </xsl:template>
    <?req
    <xsl:template match="mim:Attribuutsoort" mode="pga">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een PGA attribuutsoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'attribuutsoort')"/>
                <xsl:sequence select="imf:set-parameter('is-pga','true')"/>
            </ep:parameters>
            <ep:name>geometry</ep:name>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
    <xsl:template match="mim:Attribuutsoort" mode="ppa">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een PPA attribuutsoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'attribuutsoort')"/>
                <xsl:sequence select="imf:set-parameter('is-ppa','true')"/>
            </ep:parameters>
            <ep:name>place</ep:name>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
    req?>
    
    <xsl:template match="mim:Gegevensgroep">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Gegevensgroep',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'gegevensgroep')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeDatatypen/mim-ext:ConstructieRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een keuze element, constructies',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'constructieref')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeDatatypen/mim:Datatype">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een keuze element, MIM datatypen',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'datatype')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:choose>
                <xsl:when test="mim-ext:ConstructieRef"><!-- referentie naar niet-MIM datatype -->
                    <xsl:sequence select="imf:get-ref(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <ep:data-type>{imf:get-ep-datatype(.)}</ep:data-type>
                </xsl:otherwise>
            </xsl:choose>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeDatatypen/mim-ref:DatatypeRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een keuze element, referentie naar datatype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'datatyperef')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:DataElement">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een data element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'dataelement')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:ReferentieElement">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een referentie element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'referentieelement')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Enumeratie/mim:waarden/mim:Waarde">
        <ep:enum>
            <xsl:value-of select="(imf:get-kenmerk(.,'startwaarde'),imf:get-name(.))[1]"/><!-- de startwaarde of anders de string waarde -->
        </ep:enum>
    </xsl:template>
    
    <xsl:template match="mim:Relatiesoort">
        <xsl:variable name="info-provider" select="if ($relatierol-leidend) then mim:relatierollen/mim:Doel else ."/>
        <xsl:variable name="inlineOrByReference" select="(imf:get-kenmerk($info-provider,'inlineOrByReference'),'byReference')[1]"/><!-- see /req/by-reference-basic/inline-or-by-reference-tag -->
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Relatiesoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'relatiesoort')"/>
                <xsl:sequence select="imf:get-nillable($info-provider)"/>
                <xsl:sequence select="imf:set-parameter('inlineorbyreference',$inlineOrByReference)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name($info-provider)"/>
            <xsl:sequence select="imf:get-documentation($info-provider)"/>
            <xsl:sequence select="imf:get-cardinality($info-provider)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:doel/mim-ref:ObjecttypeRef | mim:doel/mim-ref:KeuzeRef"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeRelatiedoelen/mim:Relatiedoel/mim-ref:ObjecttypeRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een objecttype in een keuze',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'objecttyperef')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:ExterneKoppeling/mim:doel/mim-ref:ObjecttypeRef">
        <xsl:sequence select="imf:get-ref(.)"/>
    </xsl:template>
    
    <xsl:template match="mim:Relatiesoort/mim:doel/mim-ref:ObjecttypeRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een objecttype in een relatiesoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'objecttyperef')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Relatiesoort/mim:doel/mim-ref:KeuzeRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een relatie naar een keuze tussen relatiedoelen',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-common-parameters(.,'keuzeref')"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:supertypen/mim:GeneralisatieDatatypen">
        <xsl:sequence select="imf:get-type(.)"/>
    </xsl:template>
    
    <xsl:template match="mim:supertypen/mim:GeneralisatieObjecttypen">
        <xsl:sequence select="imf:get-type(.)"/>
    </xsl:template>
    
    <xsl:template match="xhtml:*">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:sequence select="imf:msg-comment(.,'ERROR','Unknown element [1]',imf:xpath-string(.))"/>
    </xsl:template>
    
    <!--
        Remove certain elements that are empty.
    -->    
    <xsl:template match="
        ep:documentation | 
        ep:parameters | 
        ep:seqxx | 
        ep:choicexx |
        ep:super |
        ep:min-length | 
        ep:max-length | 
        ep:min-value | 
        ep:max-value | 
        ep:formal-pattern | 
        ep:alias | 
        ep:example |
        ep:read-only |
        ep:initial-value
        " 
        mode="remove-empty-elements">
        <xsl:if test="normalize-space()">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
    <?x
    <xsl:template match="ep:min-occurs |ep:max-occurs" mode="remove-empty-elements">
        <xsl:if test=". ne '1'">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    x?>
    
    <xsl:template match="node()" mode="remove-empty-elements">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!--
        FUNCTIONS 
    -->    
    <xsl:function name="imf:get-id" as="attribute(id)">
        <xsl:param name="this"/>
        <xsl:attribute name="id" select="$this/@id"/>
    </xsl:function>
    
    <!--
        De naam in de MIM serialisatie is de originele naam (zoals ingevoerd door de analist).
        De naam die in Json wordt gebruikt is de XML versie van die naam.
        Deze correcte naam wordt bepaald op basis van geconfigureerde naamconventies.
        Als die conventie niet bestaat, gebruik dan de ingevoerde waarde.
    -->
    <xsl:function name="imf:get-name" as="element()*">
        <xsl:param name="this"/>
        <xsl:variable name="name" select="(imf:info($this)/mim:naam,$this/@label,'UNKNOWNNAME')[1]"/>
        <ep:name>
            <xsl:value-of select="imf:get-normalized-name($name,'json-bp-name')"/>
        </ep:name>
    </xsl:function>
   
    <xsl:function name="imf:get-supers" as="element(ep:super)*">
        <xsl:param name="this"/>
        
        <xsl:variable name="is-featuretype" select="imf:is-featuretype($this)"/>
        
        <xsl:variable name="super-refs" as="element()*"><!-- ep:ref of ep:data-type -->
            <xsl:apply-templates select="$this/mim:supertypen/*"/>
        </xsl:variable>
        
       <ep:super>
            <xsl:choose>
                <!-- wanneer supertypen, neem aan dat daarop het feature type is gedefinieerd -->
                <xsl:when test="$super-refs">
                    <xsl:sequence select="$super-refs"/>
                </xsl:when>
                <!-- anders nemen we aan dat ojecttypen e.d. een featuretype zijn -->
                <xsl:when test="$bp-req-basic-encodings = ('/req/geojson','/req/jsonfg') and $is-featuretype">
                    <ep:ref href="/known/feature">GM_Feature</ep:ref>
                </xsl:when>
            </xsl:choose>
        </ep:super>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation" as="element(ep:documentation)*">
        <xsl:param name="this"/>
        <ep:documentation type="alias">
            <ep:text>
                <xsl:value-of select="imf:info($this)/mim:alias"/>
            </ep:text>  
        </ep:documentation>
        <ep:documentation type="definitie">
            <xsl:sequence select="imf:get-note-value(imf:info($this)/mim:definitie)"/>  
        </ep:documentation>
        <ep:documentation type="toelichting">
            <xsl:sequence select="imf:get-note-value(imf:info($this)/mim:toelichting)"/>  
        </ep:documentation>
        <ep:documentation type="voorbeeld">
            <xsl:sequence select="imf:get-note-value(imf:info($this)/mim:voorbeeld)"/>  
        </ep:documentation>
        <ep:documentation type="patroon">
            <xsl:sequence select="imf:get-note-value(imf:info($this)/mim:patroon)"/>  
        </ep:documentation>
    </xsl:function>
    
    <xsl:function name="imf:get-data-location" as="element(ep:parameter)?">
        <xsl:param name="this"/>
        <xsl:sequence select="imf:set-parameter('data-location',$this/mim:locatie)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-nillable" as="element(ep:parameter)?">
        <xsl:param name="this"/>
        <xsl:if test="imf:boolean(imf:info($this)/mim:mogelijkGeenWaarde)">
            <xsl:sequence select="imf:set-parameter('nillable','true')"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:set-common-parameters" as="element(ep:parameter)*">
        <xsl:param name="this"/>
        <xsl:param name="shortname" as="xs:string"/>
        <xsl:variable name="default-positie" select="
            if ($this/self::mim:Attribuutsoort) then '100' else 
            if ($this/self::mim:Relatiesoort) then '200' else 
            '0'"/>
        <xsl:sequence select="imf:set-parameter('use',$shortname)"/>
        <xsl:sequence select="imf:set-parameter('position',(imf:get-kenmerk($this,'positie'),$default-positie)[1])"/>
        <xsl:sequence select="imf:set-parameter('index',$this/@index)"/>
        <xsl:sequence select="if (imf:is-featuretype($this)) then imf:set-parameter('is-featuretype','true') else ()"/>
    </xsl:function>
    
    <xsl:function name="imf:get-cardinality" as="element()*">
        <xsl:param name="this"/>
        <xsl:variable name="c" select="tokenize($this/mim:kardinaliteit,'\.\.')"/>
        <ep:min-occurs>
            <xsl:value-of select="($c[1],'1')[1]"/>
        </ep:min-occurs>
        <ep:max-occurs>
            <xsl:value-of select="($c[2],'1')[1]"/>
        </ep:max-occurs>
    </xsl:function>
    
    <xsl:function name="imf:get-type" as="node()*">
        <xsl:param name="this" as="element()?"/><!-- een constructie die een type of supertype kan hebben -->
        <xsl:variable name="type" select="$this/(mim:type|mim:supertype|mim:gegevensgroeptype)"/>
        <xsl:choose>
            <xsl:when test="empty($this)"><!-- dit alleen als primitief datatype zonder supertype voorkomt -->
                <ep:data-type>ep:string</ep:data-type>
            </xsl:when>
            <xsl:when test="$type/mim:Datatype">
                <xsl:sequence select="imf:get-ep-datatype($type/mim:Datatype)"/>
            </xsl:when>
            <xsl:when test="$type/mim-ref:DatatypeRef">
                <xsl:sequence select="imf:get-ref($type/mim-ref:DatatypeRef)"/>
            </xsl:when>
            <xsl:when test="$type/mim-ref:ObjecttypeRef">
                <xsl:sequence select="imf:get-ref($type/mim-ref:ObjecttypeRef)"/>
            </xsl:when>
            <xsl:when test="$type/mim-ref:GegevensgroeptypeRef">
                <xsl:sequence select="imf:get-ref($type/mim-ref:GegevensgroeptypeRef)"/>
            </xsl:when>
            <xsl:when test="$type/mim-ref:KeuzeRef">
                <xsl:sequence select="imf:get-ref($type/mim-ref:KeuzeRef)"/>
            </xsl:when>
            <xsl:when test="$type/mim-ext:ConstructieRef">
                <xsl:sequence select="imf:get-ref($type/mim-ext:ConstructieRef)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg-comment($this,'WARNING','Unknown type: [1]',$type/*)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-ep-datatype" as="element(ep:data-type)">
        <xsl:param name="mim-datatype" as="xs:string"/>
        <xsl:variable name="lc" select="lower-case($mim-datatype)"/>
        <xsl:choose>
            <xsl:when test="$lc = 'characterstring'">
                <ep:data-type>ep:string</ep:data-type>
            </xsl:when>
            <xsl:otherwise>
                <ep:data-type>ep:{$lc}</ep:data-type>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
    <xsl:function name="imf:get-ref" as="element(ep:ref)">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="id" select="substring-after($this/@xlink:href,'#')"/>
        <xsl:variable name="property" select="$this//ancestor::*[mim:type|mim:supertype|mim:gegevensgroeptype|mim:doel]"/>
        <ep:ref href="{$id}">{root($this)//*[@id = $id]/mim:naam}</ep:ref>
    </xsl:function>
    
    <xsl:function name="imf:get-props" as="element()*">
        <xsl:param name="this"/>
        
        <ep:min-value>
            <xsl:value-of select="imf:get-kenmerk($this,'minimumwaarde')"/>
        </ep:min-value>
        <ep:max-value>
            <xsl:value-of select="imf:get-kenmerk($this,'maximumwaarde')"/>
        </ep:max-value>
        <ep:min-length>
            <xsl:value-of select="imf:get-kenmerk($this,'minimumlengte')"/>
        </ep:min-length>
        <ep:max-length>
            <xsl:value-of select="imf:get-kenmerk($this,'maximumlengte')"/>
        </ep:max-length>
        <ep:formal-pattern>
            <xsl:value-of select="$this/mim:formeelPatroon"/>
        </ep:formal-pattern>
     </xsl:function>
    
    <xsl:function name="imf:get-geo-url" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="name" select="imf:info($this)/mim:naam"/>
        <xsl:sequence select="imf:get-geo-url-for-name($name)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-geo-url-for-name" as="xs:string?">
        <xsl:param name="name" as="xs:string?"/>
        
        <!-- bepaal hier de locatie van de externe json definitie --> 
        <xsl:variable name="requires-geojson" select="$bp-req-basic-encodings = ('/req/geojson','/req/plain')"/>
        <xsl:variable name="requires-jsonfg" select="$bp-req-basic-encodings = ('/req/jsonfg')"/>
        <xsl:choose>
            <xsl:when test="$requires-geojson and $name = 'GM_Point'">https://geojson.org/schema/Point.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_Curve'">https://geojson.org/schema/LineString.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_Surface'">https://geojson.org/schema/Polygon.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_Polygon'">https://geojson.org/schema/Polygon.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_Solid'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/Polyhedron</xsl:when><!-- overnemen van jsonFG omdat het niet in geojson voorkomt -->
            <xsl:when test="$requires-geojson and $name = 'GM_MultiPoint'">https://geojson.org/schema/MultiPoint.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_MultiCurve'">https://geojson.org/schema/MultiLineString.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_MultiSurface'">https://geojson.org/schema/MultiPolygon.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_Aggregate'">https://geojson.org/schema/GeometryCollection.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_Object'">https://geojson.org/schema/Geometry.json</xsl:when>
            <xsl:when test="$requires-geojson and $name = 'GM_Feature'">https://geojson.org/schema/Feature.json</xsl:when>
            
            <xsl:when test="$requires-jsonfg and $name = 'GM_Point'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/Point</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_Curve'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/LineString</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_Surface'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/Polygon</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_Polygon'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/Polygon</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_Solid'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/Polyhedron</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_MultiPoint'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/MultiPoint</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_MultiCurve'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/MultiLineString</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_MultiSurface'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/MultiPolygon</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_MultiSolid'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/MultiPolyhedron</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_Aggregate'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/GeometryCollection</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_Object'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/Geometry.json</xsl:when>
            <xsl:when test="$requires-jsonfg and $name = 'GM_Feature'">https://beta.schemas.opengis.net/json-fg/geometry-objects.json#/$defs/Feature.json</xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:set-parameter" as="element(ep:parameter)*">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="normalize-space(xs:string($value))">
            <ep:parameter name="{$name}">
                <xsl:value-of select="$value"/>
            </ep:parameter>
        </xsl:if>
    </xsl:function>
   
    <xsl:function name="imf:msg-comment">
        <xsl:param name="this" as="node()*"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
      
        <xsl:variable name="ctext" select="imf:msg-insert-parms($text,$info)"/>
        
        <xsl:comment>{$type} : {name($this)} : {$ctext}</xsl:comment>
        <xsl:sequence select="imf:msg($this,$type,$text,$info)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:get-note-value" as="item()*">
        <xsl:param name="note-field" as="item()*"/>
        <ep:text>
            <xsl:choose>
                <xsl:when test="$note-field/xhtml:body">
                    <xsl:sequence select="pack:strip($note-field/xhtml:body/node())"/>
                </xsl:when>
                <xsl:when test="$note-field/*">
                    <xsl:sequence select="pack:strip($note-field/*)"/>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                        <xsl:value-of select="$note-field"/>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </ep:text>
    </xsl:function>
    
    <xsl:function name="imf:get-kenmerk" as="xs:string?">
        <xsl:param name="construct" as="element()"/>
        <xsl:param name="naam" as="xs:string"/>
        <xsl:sequence select="$construct/mim-ext:kenmerken/mim-ext:Kenmerk[lower-case(@naam) = lower-case($naam)]"/>
    </xsl:function>
    
    <xsl:function name="imf:info" as="element()?">
        <xsl:param name="this"/>
        <xsl:sequence select="if ($this/self::mim:Relatiesoort and $relatierol-leidend) then $this/mim:relatierollen/mim:Doel else $this"/>
    </xsl:function>
    
    <!-- haal het attribuut met de primaire geometrie op, zie /req/geojson-formats/primary-geometry -->
    <xsl:function name="imf:get-primary-geometry-attribute" as="element(mim:Attribuutsoort)?">
        <xsl:param name="this" as="element(mim:Objecttype)"/>
        <xsl:variable name="geo-atts" select="$this//mim:Attribuutsoort[starts-with(mim:type/mim-ext:ConstructieRef,'GM_')]"/>
        <xsl:variable name="geo-att1" select="$geo-atts[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryGeometry'))]"/>
        <xsl:variable name="geo-att2" select="if (count($geo-atts) = 1) then $geo-atts else ()"/>
        <xsl:sequence select="($geo-att1,$geo-att2)[1]"/>
     </xsl:function>

    <xsl:function name="imf:get-primary-place-attribute" as="element(mim:Attribuutsoort)?">
        <xsl:param name="this" as="element(mim:Objecttype)"/>
        <xsl:variable name="att" select="$this//mim:Attribuutsoort[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryPlace'))]"/>
        <xsl:sequence select="$att[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-primary-instant-attribute" as="element(mim:Attribuutsoort)?">
        <xsl:param name="this" as="element(mim:Objecttype)"/>
        <xsl:variable name="att" select="$this//mim:Attribuutsoort[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryInstant'))]"/>
        <xsl:sequence select="$att[1]"/>
    </xsl:function>
 
    <xsl:function name="imf:get-primary-interval-attributes" as="element(mim:Attribuutsoort)*">
        <xsl:param name="this" as="element(mim:Objecttype)"/>
        <xsl:variable name="att" select="$this//mim:Attribuutsoort[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryInterval'))]"/>
        <xsl:sequence select="$att"/>
    </xsl:function>
    
    <xsl:function name="imf:add-entitytype" as="element()*">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="super" select="$this//mim:supertype"/>
        <xsl:choose>
            <xsl:when test="$super">
                <!-- skip -->
            </xsl:when>
            <xsl:when test="$bp-req-additional-requirements-classes = '/req/entitytype'"><!-- optioneel; kan ook "none" zijn -->
                <ep:construct>
                    <ep:parameters>
                        <ep:parameter name="use">entitytype</ep:parameter>
                        <ep:parameter name="index">0</ep:parameter>
                    </ep:parameters>
                    <ep:name>entityType</ep:name>
                    <ep:data-type>ep:string</ep:data-type>
                </ep:construct>
            </xsl:when>
            <xsl:otherwise>
                <!-- skip; this is not within range of the spec; entitytype is expected, no alternatives -->
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:function>
    
    <xsl:function name="imf:is-featuretype">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="local-name($this) = ('Objecttype','Relatieklasse','Koppelklasse')"/>
    </xsl:function>
    
    <!-- 
        geef alle supertypen af van het objecttype die een primaire geometrie definieren 
    --> 
    <xsl:function name="imf:get-supers-with-pga" as="element()*">
        <xsl:param name="this" as="element()"/>
        
        <xsl:variable name="supers" select="imf:get-mim-superclasses($this)"/>
        <xsl:variable name="supers-with-pga" select="$supers[mim:attribuutsoorten/mim:Attribuutsoort[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryGeometry'))]]"/>
        
        <xsl:sequence select="$supers-with-pga"/>
    </xsl:function>
    <!-- 
        geef alle supertypen af van het objecttype die een primaire plaats definieren 
    --> 
    <xsl:function name="imf:get-supers-with-ppa" as="element()*">
        <xsl:param name="this" as="element()"/>
        
        <xsl:variable name="supers" select="imf:get-mim-superclasses($this)"/>
        <xsl:variable name="supers-with-ppa" select="$supers[mim:attribuutsoorten/mim:Attribuutsoort[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryPlace'))]]"/>
        
        <xsl:sequence select="$supers-with-ppa"/>
    </xsl:function>
    <!-- 
        geef alle supertypen af van het objecttype die een primair moment definieren 
    --> 
    <xsl:function name="imf:get-supers-with-pia" as="element()*">
        <xsl:param name="this" as="element()"/>
        
        <xsl:variable name="supers" select="imf:get-mim-superclasses($this)"/>
        <xsl:variable name="supers-with-pia" select="$supers[mim:attribuutsoorten/mim:Attribuutsoort[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryInstant'))]]"/>
        
        <xsl:sequence select="$supers-with-pia"/>
    </xsl:function>
    <!-- 
        geef alle supertypen af van het objecttype die een primair interval definieren 
    --> 
    <xsl:function name="imf:get-supers-with-pva" as="element()*">
        <xsl:param name="this" as="element()"/>
        
        <xsl:variable name="supers" select="imf:get-mim-superclasses($this)"/>
        <xsl:variable name="supers-with-pva" select="$supers[mim:attribuutsoorten/mim:Attribuutsoort[imf:boolean(imf:get-kenmerk(.,'jsonPrimaryInterval'))]]"/>
        
        <xsl:sequence select="$supers-with-pva"/>
    </xsl:function>
    
    <!-- return all superclasses of this class, i.e. in complete type hierarchy -->
    <xsl:function name="imf:get-mim-superclasses" as="element()*">
        <xsl:param name="this" as="element()"/>
        <xsl:for-each select="imf:get-mim-superclass($this)">
            <!-- this should be a class, but if not so, allow validation to signal this -->
            <xsl:sequence select="(., imf:get-mim-superclasses(.))"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- return the direct superclasses of this class -->
    <xsl:function name="imf:get-mim-superclass" as="element()*">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="for $href in $this/mim:supertypen/*/mim:supertype/mim-ref:*/@xlink:href return imf:get-mim-class-by-id(substring-after($href,'#'))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-mim-class-by-id" as="element()?">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:sequence select="$document//mim:*[@id = $id][1]"/>
    </xsl:function>
    
</xsl:stylesheet>