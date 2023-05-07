<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mim="http://www.geostandaarden.nl/mim/informatiemodel"
    xmlns:mim-ext="http://www.geostandaarden.nl/mim-ext/informatiemodel"
    xmlns:mim-ref="http://www.geostandaarden.nl/mim-ref/informatiemodel"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
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
    
    <xsl:variable name="domain-packages" select="/mim:Informatiemodel/mim:packages/mim:Domein"/>
    
    <xsl:variable name="relatierol-leidend" select="/mim:Informatiemodel/mim:relatiemodelleringtype = 'Relatierol leidend'"/>
    
    <xsl:template match="/">
   
        <xsl:variable name="step-1" >
            <xsl:apply-templates select="/mim:Informatiemodel"/>
        </xsl:variable>

        <xsl:sequence select="pack:reorder-ep-structure($step-1)"/>

    </xsl:template>
    
    <xsl:template match="mim:Informatiemodel">
        <xsl:variable name="body" as="element()">
            <ep:group 
                xsi:schemaLocation="http://www.imvertor.org/schema/endproduct {$ep-schema-path}">
                <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Model',())"/>
                <ep:parameters>
                    <xsl:sequence select="imf:set-parameter('use','informatiemodel')"/>
                    <xsl:sequence select="imf:set-parameter('version',imf:get-kenmerk(.,'Release'))"/>
                    <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'namespace'))"/>
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
                <xsl:sequence select="imf:set-parameter('use','domein')"/>
                <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'namespace'))"/>
                <xsl:sequence select="imf:get-index(.)"/>
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
                <xsl:sequence select="imf:set-parameter('use','view')"/>
                <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'namespace'))"/>
                <xsl:sequence select="imf:get-index(.)"/>
                
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
        <xsl:choose>
            <xsl:when test="mim:naam = 'MIM11'">
                <!-- skip -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="defs" as="node()*">
                    <xsl:apply-templates select="mim-ext:Constructie"/><!-- dit zijn interfaces -->
                </xsl:variable>
                <xsl:if test="exists($defs)">
                    <ep:group>
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Extern',())"/>
                        <ep:parameters>
                            <xsl:sequence select="imf:set-parameter('use','extern')"/>
                            <xsl:sequence select="imf:set-parameter('namespace',imf:get-kenmerk(.,'Namespace'))"/>
                            <xsl:sequence select="imf:get-index(.)"/>
                        </ep:parameters>
                        <xsl:sequence select="imf:get-name(.)"/>
                        <xsl:sequence select="imf:get-documentation(.)"/>
                        <ep:seq>
                            <xsl:sequence select="$defs"/>
                        </ep:seq>
                    </ep:group>    
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mim:Objecttype">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Objecttype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','objecttype')"/>
                <xsl:sequence select="imf:set-parameter('position',imf:get-kenmerk(.,'positie'))"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
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
                <xsl:sequence select="imf:set-parameter('use','relatieklasse')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
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
                <xsl:sequence select="imf:set-parameter('use','koppelklasse')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
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
                <xsl:sequence select="imf:set-parameter('use','gegevensgroeptype')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
                <xsl:apply-templates select="mim:relatiesoorten/mim:Relatiesoort"/>
                <xsl:apply-templates select="mim:keuzen/mim-ref:KeuzeRef"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:ExterneKoppeling">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Externe koppeling',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','externekoppeling')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:doel/mim-ref:ObjecttypeRef"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Keuze">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','keuze')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:apply-templates select="mim:keuzeDatatypen | mim:keuzeRelatiedoelen | mim:keuzeAttributen"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeDatatypen">
        <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze tussen datatypen',())"/>
        <ep:choice>
            <xsl:apply-templates select="mim:Datatype | mim-ref:DatatypeRef | mim-ext:ConstructieRef"/>
        </ep:choice>
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
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een pseudo-attribuut dat een keuze tussen attribuutsoorten representeert',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','keuzeref')"/>
                <xsl:sequence select="imf:get-index(.)"/>
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
                <xsl:sequence select="imf:set-parameter('use','codelijst')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:set-parameter('locatie',mim:locatie)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:data-type>ep:string</ep:data-type>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Enumeratie">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Enumeratie',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','enumeratie')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <ep:data-type>ep:string</ep:data-type>
            <xsl:apply-templates select="mim:waarden/mim:Waarde"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim-ext:Constructie[mim-ext:constructietype = 'INTERFACE']">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Interface (extern)',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','interface')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:set-parameter('oas-name','TODO')"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:GestructureerdDatatype">
        <ep:construct>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een gestructureerd datatype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','gestructureerddatatype')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
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
                <xsl:sequence select="imf:set-parameter('use','referentielijst')"/>
                <xsl:sequence select="imf:get-index(.)"/>
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
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een primitief datatype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','primitiefdatatype')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-supers(.)"/>
            <xsl:sequence select="imf:get-type($super)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Attribuutsoort">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een attribuutsoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','attribuutsoort')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
                <xsl:sequence select="imf:get-data-location(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
        </ep:construct>
    </xsl:template>

    <xsl:template match="mim:Gegevensgroep">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Gegevensgroep',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','gegevensgroep')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeDatatypen/mim-ext:ConstructieRef"><!-- TODO -->
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een keuze element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','constructieref')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeDatatypen/mim:Datatype">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een keuze element, een datatypen',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','datatype')"/>
                <xsl:sequence select="imf:get-index(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:DataElement">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een data element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','dataelement')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:ReferentieElement">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een referentie element',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','referentieelement')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
            <xsl:sequence select="imf:get-props(.)"/>
            <xsl:sequence select="imf:get-meta(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Enumeratie/mim:waarden/mim:Waarde">
        <ep:enum>
            <xsl:value-of select="imf:get-name(.)"/><!-- de string waarde -->
        </ep:enum>
    </xsl:template>
    
    <xsl:template match="mim:Relatiesoort">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Relatiesoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','relatiesoort')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <ep:seq>
                <xsl:apply-templates select="mim:doel/mim-ref:ObjecttypeRef | mim:doel/mim-ref:KeuzeRef"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:keuzeRelatiedoelen/mim:Relatiedoel/mim-ref:ObjecttypeRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een objecttype in een keuze',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','objecttyperef')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:ExterneKoppeling/mim:doel/mim-ref:ObjecttypeRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een objecttype in een externe koppeling',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','objecttyperef')"/>
                <xsl:sequence select="imf:get-index(.)"/>
                <xsl:sequence select="imf:get-nillable(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-name(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-ref(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="mim:Relatiesoort/mim:doel/mim-ref:ObjecttypeRef">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een objecttype in een relatiesoort',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('use','objecttyperef')"/>
                <xsl:sequence select="imf:get-index(.)"/>
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
                <xsl:sequence select="imf:set-parameter('use','keuzeref')"/>
                <xsl:sequence select="imf:get-index(.)"/>
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
        ep:seq | 
        ep:choice |
        ep:super |
        ep:min-length | 
        ep:max-length | 
        ep:min-value | 
        ep:max-value | 
        ep:formal-pattern | 
        ep:alias | 
        ep:example
        " 
        mode="remove-empty-elements">
        <xsl:if test="normalize-space()">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ep:min-occurs |ep:max-occurs" mode="remove-empty-elements">
        <xsl:if test=". ne '1'">
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
    <xsl:function name="imf:get-id" as="attribute(id)">
        <xsl:param name="this"/>
        <xsl:attribute name="id" select="$this/@id"/>
    </xsl:function>
    
    <xsl:function name="imf:get-name" as="element()*">
        <xsl:param name="this"/>
        <ep:name>
            <xsl:value-of select="(imf:info($this)/mim:naam,$this/@label,'UNKNOWNNAME')[1]"/>
        </ep:name>
    </xsl:function>
    
    <xsl:function name="imf:get-supers" as="element(ep:super)*">
        <xsl:param name="this"/>
        <!-- TODO let op: in xml schema generatie moet static een copy-down worden! -->
        <ep:super>
            <xsl:apply-templates select="$this/mim:supertypen/*"/>
        </ep:super>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation" as="element(ep:documentation)*">
        <xsl:param name="this"/>
        <ep:documentation type="alias">
            <xsl:sequence select="imf:info($this)/mim:alias"/>  
        </ep:documentation>
        <ep:documentation type="definitie">
                <xsl:sequence select="imf:get-note-value(imf:info($this)/mim:definitie)"/>  
        </ep:documentation>
        <ep:documentation type="toelichting">
            <xsl:sequence select="imf:get-note-value(imf:info($this)/mim:toelichting)"/>  
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

    <xsl:function name="imf:get-index" as="element(ep:parameter)*">
        <xsl:param name="this"/>
        <xsl:variable name="default-positie" select="
            if ($this/self::mim:Attribuutsoort) then '100' else 
            if ($this/self::mim:Relatiesoort) then '200' else 
            '0'"/>
        <xsl:sequence select="imf:set-parameter('position',(imf:get-kenmerk($this,'positie'),$default-positie)[1])"/>
        <xsl:sequence select="imf:set-parameter('index',$this/@index)"/>
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
        <xsl:variable name="type" select="$this/(mim:type|mim:supertype)"/>
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
            <xsl:when test="$type/mim-ref:KeuzeRef">
                <xsl:sequence select="imf:get-ref($type/mim-ref:KeuzeRef)"/>
            </xsl:when>
            <xsl:when test="$type/mim-ext:ConstructieRef">
                <xsl:sequence select="imf:get-ref($type/mim-ext:ConstructieRef)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="dlogger:save('$this',$this)"></xsl:sequence>
                <xsl:sequence select="imf:msg-comment($this,'WARNING','Unknown type: [1]',$type/*)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-ep-datatype" as="element(ep:data-type)">
        <xsl:param name="mim-datatype" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$mim-datatype = 'CharacterString'">
                <ep:data-type>ep:string</ep:data-type>
            </xsl:when>
            <xsl:otherwise>
                <ep:data-type>ep:{lower-case($mim-datatype)}</ep:data-type>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
    <xsl:function name="imf:get-ref" as="element(ep:ref)">
        <xsl:param name="this" as="element()"/>
        <ep:ref>
            <xsl:value-of select="substring-after($this/@xlink:href,'#')"/>
        </ep:ref>
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
    
    <xsl:function name="imf:get-meta" as="element()*">
        <xsl:param name="this"/>
        <ep:example>
            <xsl:value-of select="imf:get-kenmerk(imf:info($this),'voorbeeld')"/><!-- TODO -->
        </ep:example>
    </xsl:function>
    
    <!-- TODO wordt niet gebruikt -->
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
        <xsl:value-of select="$construct/mim-ext:kenmerken/mim-ext:Kenmerk[@naam = $naam]"/>
    </xsl:function>
    
    <xsl:function name="imf:info" as="element()?">
        <xsl:param name="this"/>
        <xsl:sequence select="if ($this/self::mim:Relatiesoort and $relatierol-leidend) then $this/mim:relatierollen/mim:Doel else $this"/>
    </xsl:function>
    
</xsl:stylesheet>