<xsl:stylesheet 
  version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:imvert="http://www.imvertor.org/schema/system"
  xmlns:mim="http://www.geostandaarden.nl/mim/informatiemodel/v1" 
  xmlns:mim-ref="http://www.geostandaarden.nl/mim-ref/informatiemodel/v1"
  xmlns:mim-ext="http://www.geostandaarden.nl/mim-ext/informatiemodel/v1"
  xmlns:UML="omg.org/UML1.3" 
  xmlns:imf="http://www.imvertor.org/xsl/functions"    
  expand-text="yes" 
  exclude-result-prefixes="imvert imf fn UML">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  
  <xsl:include href="MIM11Package.xsl"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="preprocess" on-no-match="shallow-copy"/>

  <xsl:variable name="runs-in-imvertor-context" select="not(system-property('install.dir') = '')" as="xs:boolean" static="yes"/>

  <xsl:import href="../common/Imvert-common.xsl" use-when="$runs-in-imvertor-context"/>
  <xsl:import href="../common/Imvert-common-derivation.xsl" use-when="$runs-in-imvertor-context"/>
  
  <xsl:variable name="stylesheet-code">MIMCOMPILER</xsl:variable>
  <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" use-when="$runs-in-imvertor-context"/>
  
  <xsl:variable name="stereotype-name-informatiemodel"         select="'INFORMATIEMODEL'"                    as="xs:string"/>
  <xsl:variable name="stereotype-name-attribuutsoort"          select="'ATTRIBUUTSOORT'"                     as="xs:string"/>
  <xsl:variable name="stereotype-name-codelijst"               select="'CODELIJST'"                          as="xs:string"/>
  <xsl:variable name="stereotype-name-data-element"            select="'DATA ELEMENT'"                       as="xs:string"/>
  <xsl:variable name="stereotype-name-datatype"                select="'DATATYPE'"                           as="xs:string"/>
  <xsl:variable name="stereotype-name-domein"                  select="'DOMEIN'"                             as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratie"              select="'ENUMERATIE'"                         as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratiewaarde"        select="'ENUMERATIEWAARDE'"                   as="xs:string"/>
  <xsl:variable name="stereotype-name-extern"                  select="'EXTERN'"                             as="xs:string"/>
  <xsl:variable name="stereotype-name-externe-koppeling"       select="'EXTERNE KOPPELING'"                  as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroep"           select="'GEGEVENSGROEP'"                      as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroeptype"       select="'GEGEVENSGROEPTYPE'"                  as="xs:string"/>
  <xsl:variable name="stereotype-name-generalisatie"           select="'GENERALISATIE'"                      as="xs:string"/>
  <xsl:variable name="stereotype-name-gestructureerd-datatype" select="'GESTRUCTUREERD DATATYPE'"            as="xs:string"/>
  <xsl:variable name="stereotype-name-keuze"                   select="'KEUZE'"                              as="xs:string"/>
  <xsl:variable name="stereotype-name-objecttype"              select="'OBJECTTYPE'"                         as="xs:string"/>
  <xsl:variable name="stereotype-name-primitief-datatype"      select="'PRIMITIEF DATATYPE'"                 as="xs:string"/>
  <xsl:variable name="stereotype-name-referentie-element"      select="'REFERENTIE ELEMENT'"                 as="xs:string"/>
  <xsl:variable name="stereotype-name-referentielijst"         select="'REFERENTIELIJST'"                    as="xs:string"/>
  <xsl:variable name="stereotype-name-relatieklasse"           select="'RELATIEKLASSE'"                      as="xs:string"/>
  <xsl:variable name="stereotype-name-relatierol"              select="'RELATIEROL'"                         as="xs:string"/>
  <xsl:variable name="stereotype-name-relatiesoort"            select="'RELATIESOORT'"                       as="xs:string"/>
  <xsl:variable name="stereotype-name-view"                    select="'VIEW'"                               as="xs:string"/>
  <xsl:variable name="stereotype-name-interface"               select="'INTERFACE'"                          as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-datatypes"           select="'stereotype-name-union'"              as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-attributes"          select="'stereotype-name-union-attributes'"   as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-associations"        select="'stereotype-name-union-associations'" as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-element"             select="'stereotype-name-union-element'"      as="xs:string"/>
  
  <xsl:variable name="waardebereik-authentiek" select="('Authentiek', 'Basisgegeven', 'Wettelijk gegeven', 'Landelijk kerngegeven', 'Overig')" as="xs:string+"/>  
  <xsl:variable name="waardebereik-aggregatietype" select="('Compositie', 'Gedeeld', 'Geen')" as="xs:string+"/> 
  <xsl:variable name="mim-stereotype-names" select="($stereotype-name-attribuutsoort, $stereotype-name-codelijst, $stereotype-name-data-element, 
    $stereotype-name-datatype, $stereotype-name-domein, $stereotype-name-enumeratie, $stereotype-name-enumeratiewaarde, $stereotype-name-extern, 
    $stereotype-name-externe-koppeling, $stereotype-name-gegevensgroep, $stereotype-name-gegevensgroeptype, $stereotype-name-generalisatie, 
    $stereotype-name-gestructureerd-datatype, $stereotype-name-keuze, $stereotype-name-objecttype, $stereotype-name-primitief-datatype, 
    $stereotype-name-referentie-element, $stereotype-name-referentielijst, $stereotype-name-relatieklasse, $stereotype-name-relatierol, 
    $stereotype-name-relatiesoort, $stereotype-name-view, $stereotype-name-interface, $stereotype-name-informatiemodel)" as="xs:string+"/>
  <xsl:variable name="mim-stereotype-ids" select="($stereotype-id-keuze-datatypes, $stereotype-id-keuze-attributes, 
    $stereotype-id-keuze-associations, $stereotype-id-keuze-element)" as="xs:string+"/>
  <xsl:variable name="mim-tagged-value-ids" select="('CFG-TV-INDICATIONAUTHENTIC', 'CFG-TV-CONCEPT', 'CFG-TV-DATERECORDED', 'CFG-TV-DEFINITION',
    'CFG-TV-FORMALPATTERN', 'CFG-TV-SOURCE', 'CFG-TV-SOURCEOFDEFINITION', 'CFG-TV-INDICATIONDERIVABLE', 'CFG-TV-INDICATIONCLASSIFICATION',
    'CFG-TV-INDICATIONFORMALHISTORY', 'CFG-TV-INDICATIONMATERIALHISTORY', 'CFG-TV-QUALITY', 'CFG-TV-LENGTH','CFG-TV-DATALOCATION',
    'CFG-TV-VOIDABLE', 'CFG-TV-PATTERN', 'CFG-TV-POPULATION', 'CFG-TV-DATERECORDED', 'CFG-TV-DESCRIPTION')" as="xs:string+"/>
  
  <xsl:variable name="preprocessed-xml" as="document-node()">
    <xsl:apply-templates select="." mode="preprocess"/>  
  </xsl:variable>
  
  <xsl:variable name="packages" select="$preprocessed-xml//imvert:package" as="element(imvert:package)*"/>
  <xsl:variable name="classes" select="$preprocessed-xml//imvert:class" as="element(imvert:class)*"/>
  <xsl:variable name="attributes" select="$preprocessed-xml//imvert:attribute" as="element(imvert:attribute)*"/>
  <xsl:variable name="associations" select="$preprocessed-xml//imvert:association" as="element(imvert:association)*"/>
  
  <xsl:variable name="mim11-primitive-datatypes-lc-names" select="for $n in $mim11-package/imvert:class/imvert:name/@original return lower-case($n)" as="xs:string+"/>
  
  <xsl:key name="key-imvert-construct-by-id" match="imvert:*[imvert:id]" use="imvert:id"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="$preprocessed-xml/imvert:packages"/>
  </xsl:template>
  
  <xsl:template match="/imvert:packages" mode="preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="preprocess"/>
      <xsl:if test="not(imvert:package/imvert:name = 'MIM11')">
        <xsl:apply-templates select="$mim11-package" mode="preprocess"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="imvert:id[string-length(.) ge 32]" mode="preprocess">
    <xsl:copy>{imf:create-id(..)}</xsl:copy>
  </xsl:template>
  
  <xsl:template match="(imvert:type-id|imvert:type-package-id)[string-length(.) ge 32]" mode="preprocess">
    <xsl:copy>{imf:create-id(key('key-imvert-construct-by-id', .))}</xsl:copy>
  </xsl:template>
  
  <xsl:template match="/imvert:packages">
    <mim:Informatiemodel
      xmlns:mim="http://www.geostandaarden.nl/mim/informatiemodel/v1" 
      xmlns:mim-ref="http://www.geostandaarden.nl/mim-ref/informatiemodel/v1"
      xmlns:mim-ext="http://www.geostandaarden.nl/mim-ext/informatiemodel/v1"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      
      <xsl:attribute name="schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://www.geostandaarden.nl/mim/informatiemodel/v1 ../xsd/MIMFORMAT/model/v20210609/MIMFORMAT_Mim_v0_0_1.xsd</xsl:attribute>
      
      <mim:naam>{imvert:model-id}</mim:naam>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomst"/>
      <mim:informatiedomein>{imf:tagged-values(., 'CFG-TV-IMDOMAIN')}</mim:informatiedomein>
      <mim:informatiemodeltype>{imf:tagged-values(., 'CFG-TV-IMTYPE')}</mim:informatiemodeltype>
      <mim:relatiemodelleringstype>{imf:tagged-values(., 'CFG-TV-IMRELATIONMODELINGTYPE')}</mim:relatiemodelleringstype>
      <mim:mIMVersie>{imf:tagged-values(., 'CFG-TV-MIMVERSION')}</mim:mIMVersie>
      <mim:mIMExtensie>{imf:tagged-values(., 'CFG-TV-MIMEXTENSION')}</mim:mIMExtensie>
      <mim:mIMTaal>{imf:tagged-values(., 'CFG-TV-MIMLANGUAGE')}</mim:mIMTaal>
      
      <xsl:where-populated>
        <mim:bevat>
          <xsl:apply-templates select="$packages[imvert:stereotype = ($stereotype-name-domein, $stereotype-name-view)]">
            <xsl:sort select="imvert:stereotype"/>
            <xsl:sort select="imvert:name"/>
          </xsl:apply-templates>
        </mim:bevat>
      </xsl:where-populated>
      
      <xsl:where-populated>
        <mim:maaktGebruikVan>
          <xsl:apply-templates select="$packages[imvert:stereotype = $stereotype-name-extern]">
            <xsl:sort select="imvert:name"/>
          </xsl:apply-templates>
        </mim:maaktGebruikVan>  
      </xsl:where-populated>
     
      <mim:components>
        <mim:InformatiemodelComponents>
          <!-- mim:Objectype: -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-objecttype]"/>
          <!-- mim:Gegevensgroeptype: -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-gegevensgroeptype]"/>
          <!-- mim:GestructureerdDatatype -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-gestructureerd-datatype]"/>
          <!-- mim:PrimitiefDatatype -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-primitief-datatype]"/>
          <!-- mim:Enumeratie -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-enumeratie]"/>
          <!-- mim:Codelijst -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-codelijst]"/>
          <!-- mim:Referentielijst -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-referentielijst]"/>
          <!-- mim:Datatype -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-datatype]"/>
          <!-- mim:Keuze__Attribuutsoorten -->
          <xsl:apply-templates select="$classes[imvert:stereotype/@id = $stereotype-id-keuze-attributes]"/>
          <!-- mim:Keuze__Datatypen -->
          <xsl:apply-templates select="$classes[imvert:stereotype/@id = $stereotype-id-keuze-datatypes]"/>
          <!-- mim:Keuze__Associaties -->
          <xsl:apply-templates select="$classes[imvert:stereotype/@id = $stereotype-id-keuze-associations]"/>
          <!-- TODO: mim:Extern toevoegen? -->
          <!-- mim:Interface -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-interface and imvert:id]"/>
          <!-- mim-ext:Constructie -->
          <xsl:apply-templates select="$classes[imf:is-not-mim-construct(.)]"/>
        </mim:InformatiemodelComponents>
      </mim:components>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Informatiemodel>
  </xsl:template>
  
  <xsl:template name="domein-of-view">
    <xsl:call-template name="naam"/>
    <xsl:where-populated>
      <mim:bevat__datatype>
        <xsl:for-each select="
          imvert:class[imvert:stereotype = $stereotype-name-gestructureerd-datatype],
          imvert:class[imvert:stereotype = $stereotype-name-primitief-datatype],
          imvert:class[imvert:stereotype = $stereotype-name-enumeratie],
          imvert:class[imvert:stereotype = $stereotype-name-codelijst],
          imvert:class[imvert:stereotype = $stereotype-name-referentielijst]">
          <xsl:sort select="imvert:name"/>
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:id" as="xs:string"/>
          </xsl:call-template>
        </xsl:for-each>
      </mim:bevat__datatype>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:bevat__objecttype>
        <xsl:for-each select="imvert:class[imvert:stereotype = $stereotype-name-objecttype]">
          <xsl:sort select="imvert:name"/>
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:id" as="xs:string"/>
          </xsl:call-template>
        </xsl:for-each>
      </mim:bevat__objecttype>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:bevat__gegevensgroeptype>
        <xsl:for-each select="imvert:class[imvert:stereotype = $stereotype-name-gegevensgroeptype]">
          <xsl:sort select="imvert:name"/>
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:id" as="xs:string"/>
          </xsl:call-template>
        </xsl:for-each>
      </mim:bevat__gegevensgroeptype>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim-ext:bevat__constructies>
        <xsl:for-each select="imvert:class[imf:is-not-mim-construct(.)]">
          <xsl:sort select="imvert:name"/>
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:id" as="xs:string"/>
          </xsl:call-template>
        </xsl:for-each>
      </mim-ext:bevat__constructies>
    </xsl:where-populated>
  </xsl:template>
  
  <!-- mim:Domein -->
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-domein]">
    <mim:Domein id="{imvert:id}">
      <xsl:call-template name="domein-of-view"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Domein>
  </xsl:template>

  <!-- mim:View -->
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-view]">
    <mim:View id="{imvert:id}">
      <xsl:call-template name="domein-of-view"/>
      <xsl:call-template name="locatie"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:View>
  </xsl:template>

  <!-- mim:Objectype -->
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-objecttype]">
    <mim:Objecttype id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomstDefinitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="uniekeAanduiding"/>
      <xsl:call-template name="populatie"/>
      <xsl:call-template name="kwaliteit"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="indicatieAbstractObject"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="gebruikt__attribuutsoort"/>
      <!-- TODO: is "gebruikt" dit niet hetzelfde gegeven als "gebruikt__keuze"? --> 
      <!--
      <xsl:call-template name="gebruikt"/>
      -->
      <xsl:call-template name="gebruikt__keuze"/>
      <xsl:call-template name="bezitExterneRelatie"/>
      <xsl:call-template name="gebruikt__gegevensgroep"/>
      <xsl:call-template name="bezit"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Objecttype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gegevensgroeptype]">
    <mim:Gegevensgroeptype id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomstDefinitie"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="gebruikt__attribuutsoort"/>
      <xsl:call-template name="gebruikt__gegevensgroep"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Gegevensgroeptype>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[not(imvert:stereotype) or (imvert:stereotype = $stereotype-name-attribuutsoort) or (imvert:stereotype/@id = $stereotype-id-keuze-element)]">
    <mim:Attribuutsoort>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomstDefinitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="lengte"/>
      <xsl:call-template name="patroon"/>
      <xsl:call-template name="formeelPatroon"/>
      <xsl:call-template name="indicatieMateriLeHistorie"/>
      <xsl:call-template name="indicatieFormeleHistorie"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="authentiek"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="indicatieAfleidbaar"/>
      <xsl:call-template name="indicatieClassificerend"/>
      <xsl:call-template name="mogelijkGeenWaarde"/>
      <xsl:call-template name="identificerend"/>
      <xsl:call-template name="heeft__datatype"/>
      <xsl:call-template name="heeft__keuze"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Attribuutsoort>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-gegevensgroep]">
    <mim:Gegevensgroep>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="herkomstDefinitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="indicatieMateriLeHistorie"/>
      <xsl:call-template name="indicatieFormeleHistorie"/>
      <xsl:call-template name="kardinalteit"/>
      <xsl:call-template name="authentiek"/>
      <mim:heeft>
        <xsl:call-template name="create-ref-element">
          <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
        </xsl:call-template>
      </mim:heeft>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Gegevensgroep>
  </xsl:template>
  
  <xsl:template match="imvert:association[imvert:stereotype = $stereotype-name-relatiesoort 
    and not(imf:association-is-relatie-klasse(.)) and not(imf:association-is-keuze-attributes(.))]">
    <mim:Relatiesoort>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="uniDirectioneel"/>
      <xsl:call-template name="typeAggregatie"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomstDefinitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="indicatieMateriLeHistorie"/>
      <xsl:call-template name="indicatieFormeleHistorie"/>
      <xsl:call-template name="authentiek"/>
      <xsl:call-template name="indicatieAfleidbaar"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="mogelijkGeenWaarde"/>
      <xsl:call-template name="verwijstNaar__objecttype"/>
      <xsl:call-template name="verwijstNaar"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Relatiesoort>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-relatieklasse]">
    <mim:Relatieklasse>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="uniDirectioneel"/>
      <xsl:call-template name="typeAggregatie"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomstDefinitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="indicatieMateriLeHistorie"/>
      <xsl:call-template name="indicatieFormeleHistorie"/>
      <xsl:call-template name="authentiek"/>
      <xsl:call-template name="indicatieAfleidbaar"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="mogelijkGeenWaarde"/>
      <xsl:call-template name="gebruikt__attribuutsoort"/>
      <xsl:call-template name="verwijstNaar__objecttype"/>
      <xsl:call-template name="verwijstNaar"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Relatieklasse>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gestructureerd-datatype]">
    <mim:GestructureerdDatatype id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="patroon"/>
      <xsl:call-template name="formeelPatroon"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:where-populated>
        <mim:bevat>
          <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-data-element]">
            <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          </xsl:apply-templates>   
        </mim:bevat>  
      </xsl:where-populated>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:GestructureerdDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-primitief-datatype]">
    <mim:PrimitiefDatatype id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="lengte"/>
      <xsl:call-template name="patroon"/>
      <xsl:call-template name="formeelPatroon"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:PrimitiefDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-enumeratie]">
    <mim:Enumeratie id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="begrip"/>
      <mim:bevat>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-enumeratiewaarde]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
        </xsl:apply-templates>   
      </mim:bevat>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Enumeratie>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-codelijst]">
    <mim:Codelijst id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="locatie"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Codelijst>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-referentielijst]">
    <mim:Referentielijst id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="toelichting"/>
      <xsl:call-template name="locatie"/>
      <mim:bevat>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-referentie-element]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
        </xsl:apply-templates>   
      </mim:bevat>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Referentielijst>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-datatype]">
    <mim:Datatype id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="type"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Datatype>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-data-element]">
    <mim:DataElement>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="lengte"/>
      <xsl:call-template name="patroon"/>
      <xsl:call-template name="formeelPatroon"/>
      <xsl:call-template name="kardinaliteit"/>
      <mim:heeft>
        <xsl:call-template name="process-datatype"/>
      </mim:heeft>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:DataElement>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-enumeratiewaarde]">
    <mim:Enumeratiewaarde>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="code"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Enumeratiewaarde>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-referentie-element]">
    <mim:ReferentieElement>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="lengte"/>
      <xsl:call-template name="patroon"/>
      <xsl:call-template name="formeelPatroon"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="identificerend"/>
      <xsl:call-template name="identificatie__F"/>
      <xsl:call-template name="toelichting"/>
      <mim:heeft>
        <xsl:call-template name="process-datatype"/>
      </mim:heeft>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:ReferentieElement>
  </xsl:template>
  
  <xsl:template match="imvert:supertype[imvert:stereotype = $stereotype-name-generalisatie]">
    <mim:Generalisatie>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="verwijstNaarGenerieke"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Generalisatie>
  </xsl:template>
  
  <!-- mim:Keuze__Attribuutsoorten -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-id-keuze-attributes]">
    <mim:Keuze__Attribuutsoorten id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="toelichting"/>
      <mim:bevat__attribuutsoort>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
        </xsl:apply-templates>
      </mim:bevat__attribuutsoort>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Keuze__Attribuutsoorten>  
  </xsl:template> 
  
  <!-- mim:Keuze__Datatypen -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-id-keuze-datatypes]">
    <mim:Keuze__Datatypen id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="herkomst"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="toelichting"/>
      <!-- TODO: mapping 
      <xsl:call-template name="bevat__attribuutsoort"/> 
      -->
      <mim:bevat__datatype>
        <xsl:for-each select="imvert:attributes/imvert:attribute">
          <xsl:call-template name="process-datatype"/>
        </xsl:for-each>  
      </mim:bevat__datatype>
      <!-- TODO: mapping
      <xsl:call-template name="bevat"/>
      <xsl:call-template name="keuzeUit__G"/>
      -->
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Keuze__Datatypen>
  </xsl:template> 
  
  <!-- mim:Keuze__Associaties -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-id-keuze-associations]">
    <mim:Keuze__Associaties id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="uniDirectioneel"/>
      <xsl:call-template name="typeAggregatie"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="doel"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Keuze__Associaties>
  </xsl:template> 
  
  <xsl:template match="imvert:association[imvert:stereotype = $stereotype-name-externe-koppeling]">
    <mim:ExterneKoppeling>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="uniDirectioneel"/>
      <xsl:call-template name="typeAggregatie"/>
      <xsl:call-template name="doel"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:ExterneKoppeling>
  </xsl:template>
  
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-extern]">
    <mim:Extern id="{imvert:id}">
      <xsl:call-template name="naam"/>
      <xsl:call-template name="locatie"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomst"/>
      <!-- TODO: mim:bevat én mim:-ref:interface zijn verplicht -> soms invalid XML -->
      <mim:bevat>
        <xsl:for-each select="imvert:class[imvert:stereotype = $stereotype-name-interface and imvert:id]">
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:id" as="xs:string"/>
          </xsl:call-template>        
        </xsl:for-each>
      </mim:bevat>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Extern>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-interface]">
    <mim:Interface id="{imvert:id}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Interface>
  </xsl:template>
  
  <xsl:template match="(imvert:class|imvert:attribute|imvert:association)[imf:is-not-mim-construct(.)]">
    <mim-ext:Constructie id="{imvert:id}">
      <mim-ext:constructietype>{imvert:stereotype}</mim-ext:constructietype>
      <!--
      <mim-ext:imvertorKlasse>{local-name()}</mim-ext:imvertorKlasse>
      <mim-ext:imvertorAanwijzing>{imvert:designation}</mim-ext:imvertorAanwijzing>
      --> 
      <xsl:variable name="applicable-tv-ids" select="imf:get-config-applicable-tagged-value-ids(.)" as="xs:string*" use-when="$runs-in-imvertor-context"/>
      <xsl:variable name="applicable-tv-ids" select="()" as="xs:string*" use-when="not($runs-in-imvertor-context)"/>
      
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-CONCEPT' = $applicable-tv-ids">
        <xsl:call-template name="begrip"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-SOURCE' = $applicable-tv-ids">
        <xsl:call-template name="herkomst"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-DEFINITION' = $applicable-tv-ids">
        <xsl:call-template name="definitie"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-SOURCEOFDEFINITION' = $applicable-tv-ids">
        <xsl:call-template name="herkomstDefinitie"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-DATERECORDED' = $applicable-tv-ids">
        <xsl:call-template name="datumOpname"/>  
      </xsl:if>
      <!--
      <xsl:call-template name="uniekeAanduiding"/>
      -->
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-POPULATION' = $applicable-tv-ids">
        <xsl:call-template name="populatie"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-QUALITY' = $applicable-tv-ids">
        <xsl:call-template name="kwaliteit"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-DESCRIPTION' = $applicable-tv-ids">
        <xsl:call-template name="toelichting"/>  
      </xsl:if>
      <xsl:call-template name="indicatieAbstractObject"/>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-LENGTH' = $applicable-tv-ids">
        <xsl:call-template name="lengte"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-PATTERN' = $applicable-tv-ids">
        <xsl:call-template name="patroon"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-FORMALPATTERN' = $applicable-tv-ids">
        <xsl:call-template name="formeelPatroon"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-INDICATIONMATERIALHISTORY' = $applicable-tv-ids">
        <xsl:call-template name="indicatieMateriLeHistorie"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-INDICATIONFORMALHISTORY' = $applicable-tv-ids">
        <xsl:call-template name="indicatieFormeleHistorie"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-INDICATIONFORMALHISTORY' = $applicable-tv-ids">
        <xsl:call-template name="indicatieFormeleHistorie"/>  
      </xsl:if>
      <xsl:if test="imvert:min-occurs|imvert:max-occurs">
        <xsl:call-template name="kardinaliteit"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-INDICATIONAUTHENTIC' = $applicable-tv-ids">
        <xsl:call-template name="authentiek"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-INDICATIONDERIVABLE' = $applicable-tv-ids">
        <xsl:call-template name="indicatieAfleidbaar"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-INDICATIONCLASSIFICATION' = $applicable-tv-ids">
        <xsl:call-template name="indicatieClassificerend"/>  
      </xsl:if>
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-VOIDABLE' = $applicable-tv-ids">
        <xsl:call-template name="mogelijkGeenWaarde"/>  
      </xsl:if>
      <xsl:if test="imvert:is-id">
        <xsl:call-template name="identificerend"/>
      </xsl:if>
      <xsl:if test="self::imvert:association">
        <xsl:call-template name="uniDirectioneel"/> <!-- mapping? -->  
      </xsl:if>
      <xsl:if test="imvert:aggregation">
        <xsl:call-template name="typeAggregatie"/>  
      </xsl:if>
      <!--
      <xsl:call-template name="type"/>
      <xsl:call-template name="code"/>
      -->
      <xsl:if test="empty($applicable-tv-ids) or 'CFG-TV-DATALOCATION' = $applicable-tv-ids">
        <xsl:call-template name="locatie"/>  
      </xsl:if>
      <!--
      <xsl:call-template name="doel"/>
      -->
      <xsl:choose>
        <xsl:when test="self::imvert:class">
          <xsl:call-template name="supertype"/>
          <xsl:where-populated>
            <mim-ext:bevat__attributen>
              <xsl:apply-templates select="imvert:attributes/imvert:attribute"/>
            </mim-ext:bevat__attributen>  
          </xsl:where-populated>
          <xsl:where-populated>
            <mim-ext:bevat__associaties>
              <xsl:apply-templates select="imvert:associations/imvert:association"/>  
            </mim-ext:bevat__associaties>  
          </xsl:where-populated>
        </xsl:when>
        <xsl:when test="self::imvert:attribute">
          <xsl:call-template name="heeft__datatype"/>
          <xsl:call-template name="heeft__keuze"/>
        </xsl:when>
        <xsl:when test="self::imvert:association">
          <xsl:where-populated>
            <mim:verwijstNaar>
              <xsl:call-template name="create-ref-element">
                <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
              </xsl:call-template>
              <mim:_Relatierol>
                <mim:id>Doel</mim:id> <!-- TODO: mapping?? -->
              </mim:_Relatierol>
            </mim:verwijstNaar>
          </xsl:where-populated>
        </xsl:when>
      </xsl:choose>
      
      <!-- TODO: constraints, derivation, concepts, substitution? -->  
      <xsl:call-template name="extensieKenmerken"/>
    </mim-ext:Constructie>
  </xsl:template>
  
  <!-- Attributen: -->
  <xsl:template name="alias">
    <xsl:where-populated>
      <mim:alias>{imvert:alias}</mim:alias>
    </xsl:where-populated>
  </xsl:template>

  <xsl:template name="authentiek">
    <xsl:variable name="value" select="imf:capitalize-first(imf:tagged-values(., 'CFG-TV-INDICATIONAUTHENTIC')[1])" as="xs:string?"/>
    <xsl:variable name="mapped-value" as="xs:string">
      <xsl:choose>
        <xsl:when test="false()"/> <!-- TODO: mapping toevoegen indien nodig -->
        <xsl:otherwise>{$value}</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$mapped-value and $mapped-value[not(. = $waardebereik-authentiek)]">
      <xsl:sequence select="imf:message(., 'WARNING', 'Value of tag CFG-TV-INDICATIONAUTHENTIC [1] is outside scope of MIM value range ([2])', ($value, string-join($waardebereik-authentiek, ', ')))"/>
    </xsl:if>
    <mim:authentiek>{$mapped-value}</mim:authentiek>
  </xsl:template>
  
  <xsl:template name="begrip">
    <xsl:for-each select="imf:tagged-values(., 'CFG-TV-CONCEPT')">
      <mim:begrip>{.}</mim:begrip>
    </xsl:for-each>
  </xsl:template>
  
  <!--
  <xsl:template name="bevat">
    <xsl:where-populated>
      <mim:bevat>
        <xsl:for-each select="imvert:attributes/imvert:attribute">
          <xsl:choose>
            <xsl:when test="imvert:stereotype = $stereotype-name-data-element">
              <mim-ref:DataElementRef xlink:href="#{imvert:id}">{imvert:name}</mim-ref:DataElementRef>    
            </xsl:when>
            <xsl:when test="imvert:stereotype = $stereotype-name-enumeratiewaarde">
              <mim-ref:EnumeratiewaardeRef xlink:href="#{imvert:id}">{imvert:name}</mim-ref:EnumeratiewaardeRef>
            </xsl:when>
            <xsl:when test="imvert:stereotype = $stereotype-name-referentie-element">
              <mim-ref:ReferentieElementRef xlink:href="#{imvert:id}">{imvert:name}</mim-ref:ReferentieElementRef>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>    
      </mim:bevat>
    </xsl:where-populated>
  </xsl:template>
  -->
  
  <xsl:template name="bezit">
    <xsl:where-populated>
      <mim:bezit>
        <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype = $stereotype-name-relatiesoort]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <xsl:choose>
            <xsl:when test="imf:association-is-relatie-klasse(.)">
              <xsl:apply-templates select="key('key-imvert-construct-by-id', imvert:association-class/imvert:type-id)"/>
              <!--
              <mim-ref:RelatieklasseRef xlink:href="#{imvert:id}">{imvert:name}</mim-ref:RelatieklasseRef>
              -->
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="."/>
            </xsl:otherwise>
          </xsl:choose>
          <?x
          <mim:RelatierolBron>
            <mim:id>{imvert:name}</mim:id> <!-- TODO: Slaat dit ergens op? -->
          </mim:RelatierolBron>
          ?>
        </xsl:for-each>  
      </mim:bezit>
    </xsl:where-populated>
  </xsl:template>

  <xsl:template name="bezitExterneRelatie">
    <xsl:where-populated>
      <mim:bezitExterneRelatie>
        <xsl:apply-templates select="imvert:associations/imvert:association[imvert:stereotype = $stereotype-name-externe-koppeling]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>  
        </xsl:apply-templates>
      </mim:bezitExterneRelatie>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="code">
    <xsl:where-populated>
      <mim:code>{imvert:name}</mim:code>
    </xsl:where-populated>
  </xsl:template>

  <xsl:template name="datumOpname">
    <mim:datumOpname>{imf:tagged-values(., 'CFG-TV-DATERECORDED')}</mim:datumOpname>
  </xsl:template>

  <xsl:template name="definitie">
    <!-- TODO: type: xs:string -> gestructureerd datatype? -->
    <mim:definitie>{imf:tagged-values(., 'CFG-TV-DEFINITION')}</mim:definitie>
  </xsl:template>

  <xsl:template name="doel">
    <!-- TODO: mapping?? -->
  </xsl:template>
  
  <xsl:template name="formeelPatroon">
    <xsl:where-populated>
      <mim:formeelPatroon>{imf:tagged-values(., 'CFG-TV-FORMALPATTERN')}</mim:formeelPatroon>
    </xsl:where-populated>
  </xsl:template>
  
  <!-- TODO: is dit niet eigenlijk hetzelfde gegeven als gebruikt__keuze? -->
  <xsl:template name="gebruikt"/>
    
  <xsl:template name="gebruikt__attribuutsoort">
    <xsl:where-populated>
      <mim:gebruikt__attribuutsoort>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-attribuutsoort]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
        </xsl:apply-templates>
      </mim:gebruikt__attribuutsoort>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="gebruikt__gegevensgroep">
    <xsl:where-populated>
      <mim:gebruikt__gegevensgroep>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-gegevensgroep]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>  
        </xsl:apply-templates>
      </mim:gebruikt__gegevensgroep>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="gebruikt__keuze">
    <xsl:where-populated>
      <mim:gebruikt__keuze>
        <xsl:for-each select="imvert:associations/imvert:association[key('key-imvert-construct-by-id', imvert:type-id)/imvert:stereotype/@id = $stereotype-id-keuze-attributes]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
          </xsl:call-template>  
        </xsl:for-each>
      </mim:gebruikt__keuze>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="heeft__datatype">
    <xsl:where-populated>
      <mim:heeft__datatype>
        <xsl:call-template name="process-datatype"/>
      </mim:heeft__datatype>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="process-datatype">
    <xsl:variable name="baretype" select="imvert:baretype" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="imvert:type-id">
        <xsl:call-template name="create-ref-element">
          <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
          <xsl:with-param name="restrict-to-datatypes" select="true()" as="xs:boolean"/>
        </xsl:call-template>  
      </xsl:when>
      <xsl:when test="$baretype[lower-case(.) = $mim11-primitive-datatypes-lc-names]">
        <!-- MIM standaard datatype herkend dat als baretype is ingevoerd ( en dus geen gebruikmaakt van Kadaster-MIM11.xmi): -->
        <xsl:variable name="mim11-class" select="$packages[imvert:name = 'MIM11']/imvert:class[imf:equals-ci(imvert:name/@original, $baretype)]" as="element(imvert:class)?"/>
        <xsl:call-template name="create-ref-element">
          <xsl:with-param name="ref-id" select="$mim11-class/imvert:id" as="xs:string"/>
          <xsl:with-param name="restrict-to-datatypes" select="true()" as="xs:boolean"/>
        </xsl:call-template> 
      </xsl:when>
      <xsl:otherwise>  
        <xsl:sequence select="imf:message(., 'WARNING', 'Baretype [1] is not a standard MIM datatype', ($baretype))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="heeft__keuze">
    <xsl:if test="imvert:type-id/text()">
      <xsl:variable name="type" select="key('key-imvert-construct-by-id', imvert:type-id)" as="element()?"/>
      <xsl:if test="$type/imvert:stereotype = $stereotype-name-keuze">
        <mim:heeft__keuze>
          <mim-ref:Keuze__DatatypenRef xlink:href="#{$type/imvert:id}">{$type/imvert:name}</mim-ref:Keuze__DatatypenRef>
        </mim:heeft__keuze>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="herkomst">
    <mim:herkomst>{imf:tagged-values(., 'CFG-TV-SOURCE')}</mim:herkomst>
  </xsl:template>

  <xsl:template name="herkomstDefinitie">
    <mim:herkomstDefinitie>{imf:tagged-values(., 'CFG-TV-SOURCEOFDEFINITION')}</mim:herkomstDefinitie>
  </xsl:template>

  <xsl:template name="id">
    <!-- TODO: genereren van mim:id helemaal verwijderen?
    <mim:id>{imvert:id}</mim:id>
    -->
  </xsl:template>

  <xsl:template name="identificatie__F"><!--TODO--></xsl:template>
  
  <xsl:template name="identificerend">
    <xsl:where-populated>
      <mim:identificerend>{imf:mim-boolean(imvert:is-id)}</mim:identificerend>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="indicatieAbstractObject">
    <!-- TODO: klopt default waarde 'false'? -->
    <mim:indicatieAbstractObject>{imf:mim-boolean(imvert:abstract)}</mim:indicatieAbstractObject>
  </xsl:template>
  
  <xsl:template name="indicatieAfleidbaar">
    <!-- TODO: klopt default waarde 'false'? -->
    <mim:indicatieAfleidbaar>{imf:mim-boolean(imf:tagged-values(., 'CFG-TV-INDICATIONDERIVABLE'))}</mim:indicatieAfleidbaar>
  </xsl:template>
  
  <xsl:template name="indicatieClassificerend">
    <!-- TODO: klopt default waarde 'false'? -->
    <mim:indicatieClassificerend>{imf:mim-boolean(imf:tagged-values(., 'CFG-TV-INDICATIONCLASSIFICATION'))}</mim:indicatieClassificerend>
  </xsl:template>
  
  <xsl:template name="indicatieFormeleHistorie">
    <!-- TODO: klopt default waarde van false()? -->
    <mim:indicatieFormeleHistorie>{(imf:mim-boolean(imf:tagged-values(., 'CFG-TV-INDICATIONFORMALHISTORY')[1]))}</mim:indicatieFormeleHistorie>
  </xsl:template>
  
  <xsl:template name="indicatieMateriLeHistorie"> 
    <!-- TODO: tikfout in XML schema -->
    <!-- TODO: klopt default waarde van false()? -->
    <mim:indicatieMateriLeHistorie>{(imf:mim-boolean(imf:tagged-values(., 'CFG-TV-INDICATIONMATERIALHISTORY')[1]))}</mim:indicatieMateriLeHistorie>
  </xsl:template>
  
  <xsl:function name="imf:convert-occurs" as="xs:string">
    <xsl:param name="occurs" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="not($occurs)">1</xsl:when>
      <xsl:when test="$occurs = 'unbounded'">*</xsl:when>
      <xsl:otherwise>{$occurs}</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="imf:kardinaliteit" as="xs:string">
    <xsl:param name="min-occurs" as="xs:string?"/>
    <xsl:param name="max-occurs" as="xs:string?"/>
    <xsl:variable name="min" select="imf:convert-occurs($min-occurs)" as="xs:string"/>
    <xsl:variable name="max" select="imf:convert-occurs($max-occurs)" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$min = $max">{$min}</xsl:when>
      <xsl:otherwise>{$min}..{$max}</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template name="kardinaliteit">
    <!-- TODO: wat te doen met de source kardinaliteiten van relatiesoorten? --> 
    <mim:kardinaliteit>{imf:kardinaliteit(imvert:min-occurs, imvert:max-occurs)}</mim:kardinaliteit>
  </xsl:template>
  
  <xsl:template name="kardinalteit">
    <!-- TODO: tikfout in XML schema -->
    <xsl:call-template name="kardinaliteit"/>
  </xsl:template>
  
  <xsl:template name="kwaliteit">
    <xsl:where-populated>
      <mim:kwaliteit>{imf:tagged-values(., 'CFG-TV-QUALITY')}</mim:kwaliteit>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="lengte">
    <xsl:where-populated>
      <mim:lengte>{imf:tagged-values(., 'CFG-TV-LENGTH')}</mim:lengte>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="locatie">
    <mim:locatie>{imf:tagged-values(., 'CFG-TV-DATALOCATION')}</mim:locatie>
  </xsl:template>
  
  <xsl:template name="mogelijkGeenWaarde">
    <!-- TODO: in IMKAD model heeft een attribuut twee CFG-TV-VOIDABLE tagged values, één Ja en één Nee, kan dat? -->
    <mim:mogelijkGeenWaarde>{imf:mim-boolean(imf:tagged-values(., 'CFG-TV-VOIDABLE')[1])}</mim:mogelijkGeenWaarde>
  </xsl:template>

  <xsl:template name="naam">
    <mim:naam>{imf:name(.)}</mim:naam>
  </xsl:template>
  
  <xsl:template name="patroon">
    <xsl:where-populated>
      <mim:patroon>{imf:tagged-values(., 'CFG-TV-PATTERN')}</mim:patroon>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="populatie">
    <xsl:where-populated>
      <mim:populatie>{imf:tagged-values(., 'CFG-TV-POPULATION')}</mim:populatie>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="supertype">
    <xsl:variable name="stereotype" select="imvert:stereotype" as="xs:string*"/>
    <xsl:if test="imvert:supertype">
      <mim:supertype>
        <xsl:for-each select="imvert:supertype[not(imvert:stereotype) or imvert:stereotype = $stereotype-name-generalisatie]">
          <xsl:variable name="super-type" select="key('key-imvert-construct-by-id', imvert:type-id)" as="element(imvert:class)"/>
          <mim:Generalisatie>
            <mim:datumOpname>{imf:tagged-values(., 'CFG-TV-DATERECORDED')}</mim:datumOpname>
            <xsl:choose>
              <xsl:when test="($stereotype = $stereotype-name-objecttype)">
                <mim:verwijstNaarGenerieke>
                  <xsl:call-template name="create-ref-element">
                    <xsl:with-param name="ref-id" select="imvert:type-id"/>
                  </xsl:call-template>
                </mim:verwijstNaarGenerieke>    
              </xsl:when>
              <xsl:otherwise>
                <mim:supertype>
                  <xsl:call-template name="create-ref-element">
                    <xsl:with-param name="ref-id" select="imvert:type-id"/>
                  </xsl:call-template>
                </mim:supertype>
              </xsl:otherwise>
            </xsl:choose>
          </mim:Generalisatie>  
        </xsl:for-each>
        <xsl:for-each select="imvert:supertype[imvert:stereotype[normalize-space()] and imf:is-not-mim-construct(.)]">
          <mim-ext:Constructie>
            <mim-ext:constructietype>{imvert:stereotype}</mim-ext:constructietype>
            <mim:verwijstNaarGenerieke>
              <xsl:call-template name="create-ref-element">
                <xsl:with-param name="ref-id" select="imvert:type-id"/>
              </xsl:call-template>
            </mim:verwijstNaarGenerieke> 
          </mim-ext:Constructie>
        </xsl:for-each>
      </mim:supertype>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="toelichting">
    <xsl:where-populated>
      <mim:toelichting>{imf:tagged-values(., 'CFG-TV-DESCRIPTION')}</mim:toelichting>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="type"><!--TODO--></xsl:template>
  
  <xsl:template name="typeAggregatie">
    <xsl:variable name="value" select="(imf:capitalize-first(imvert:aggregation), 'Geen')[1]" as="xs:string?"/>
    <xsl:variable name="mapped-value" as="xs:string">
      <xsl:choose>
        <xsl:when test="imf:equals-ci($value, 'composite')">Compositie</xsl:when>
        <xsl:when test="imf:equals-ci($value, 'shared')">Gedeeld</xsl:when>
        <xsl:otherwise>{$value}</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$mapped-value and $mapped-value[not(. = $waardebereik-aggregatietype)]">
      <xsl:sequence select="imf:message(., 'WARNING', 'Aggregation type [1] is outside scope of MIM value range ([2])', ($value, string-join($waardebereik-aggregatietype, ', ')))"/>
    </xsl:if>
    <mim:typeAggregatie>{$mapped-value}</mim:typeAggregatie>
  </xsl:template>
  
  <xsl:template name="uniDirectioneel">
    <!-- TODO: mapping?? -->
    <mim:uniDirectioneel>{imf:mim-boolean(xs:string(imvert:source/imvert:navigable = 'false'))}</mim:uniDirectioneel>
  </xsl:template>
  
  <xsl:template name="uniekeAanduiding">
    <mim:uniekeAanduiding>
      <!-- TODO: mapping?? -->
    </mim:uniekeAanduiding>
  </xsl:template>
  
  <xsl:template name="verwijstNaar">
    <!-- TODO: keuze gerelateerd, mim-ref:Keuze__DatatypenRef -->
  </xsl:template>
  
  <xsl:template name="verwijstNaarGenerieke">
    <!-- TODO: mapping?? -->
  </xsl:template>
  
  <xsl:template name="verwijstNaar__objecttype">
    <!-- TODO: dit werkt alleen met RELATIESOORT, niet met RELATIEKLASSE -->
    <xsl:where-populated>
      <mim:verwijstNaar__objecttype>
        <xsl:call-template name="create-ref-element">
          <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
        </xsl:call-template>
        <mim:_Relatierol>
          <mim:id>Doel</mim:id> <!-- TODO: mapping?? -->
        </mim:_Relatierol>
      </mim:verwijstNaar__objecttype>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:function name="imf:tagged-values" as="xs:string*" use-when="$runs-in-imvertor-context">
    <xsl:param name="context-node" as="element()"/>
    <xsl:param name="tag-id" as="xs:string"/>
    <xsl:sequence select="for $v in imf:get-most-relevant-compiled-taggedvalue-element($context-node, '##' || $tag-id) return normalize-space(string-join($v//text(), ' '))"/>
  </xsl:function>
  
  <xsl:function name="imf:tagged-values" as="xs:string*" use-when="not($runs-in-imvertor-context)">
    <xsl:param name="context-node" as="element()"/>
    <xsl:param name="tag-id" as="xs:string"/>
    <xsl:sequence select="for $v in $context-node/imvert:tagged-values/imvert:tagged-value[@id = $tag-id]/imvert:value return normalize-space(string-join($v//text(), ' '))"/>
  </xsl:function>
  
  <xsl:function name="imf:message" as="empty-sequence()" use-when="$runs-in-imvertor-context">
    <xsl:param name="this" as="node()*"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="info" as="item()*"/>
    <xsl:sequence select="imf:msg($this, $type, $text, $info)"/>
  </xsl:function>
  
  <xsl:function name="imf:message" as="empty-sequence()" use-when="not($runs-in-imvertor-context)">
    <xsl:param name="this" as="node()*"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="info" as="item()*"/>
    <xsl:message select="$type || ': ' || $text"/>
  </xsl:function>
    
  <xsl:function name="imf:mim-boolean" as="xs:string">
    <xsl:param name="this" as="item()?"/>
    <xsl:param name="default-value" as="xs:string?"/>
    <xsl:variable name="v" select="lower-case(string($this))"/>
    <xsl:sequence select="
      if ($v=('yes','true','ja','1')) then 'true' 
      else if ($v=('no','false','nee','0')) then 'false' 
      else if ($this) then 'true' 
      else $default-value"/>
  </xsl:function>
  
  <xsl:function name="imf:mim-boolean" as="xs:string">
    <xsl:param name="this" as="item()?"/>
    <xsl:value-of select="imf:mim-boolean($this, 'false')"/>
  </xsl:function>
  
  <xsl:function name="imf:capitalize-first" as="xs:string?">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:sequence select="if ($arg) then concat(upper-case(substring($arg,1,1)), substring($arg,2)) else ()"/>
  </xsl:function>
 
  <!-- 
  <xsl:function name="imf:valid-id" as="xs:string">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:sequence select="'id-' || translate($id, '{}', '')"/>
  </xsl:function>
  -->
  
  <xsl:function name="imf:create-id" as="xs:string">
    <xsl:param name="elem" as="element()"/>
    <xsl:variable name="prefix" select="imf:valid-id(($elem/imvert:stereotype, local-name($elem))[1])" as="xs:string"/>
    <xsl:variable name="package-name" select="imf:valid-id($elem/ancestor-or-self::imvert:package[imvert:stereotype = ($stereotype-name-domein, $stereotype-name-view)]/imvert:name)" as="xs:string?"/>
    <xsl:variable name="name" as="xs:string">
      <xsl:choose>
        <xsl:when test="$elem/self::imvert:class and $elem/imvert:stereotype = 'INTERFACE'">{$elem/imvert:name/@original}</xsl:when>
        <xsl:otherwise>{$elem/imvert:name}</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="suffix" select="imf:valid-id($name)" as="xs:string?"/>
    <xsl:value-of select="string-join(($package-name, $prefix, $suffix), '-')"/>
  </xsl:function>
  
  <xsl:function name="imf:valid-id" as="xs:string?">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:sequence select="if ($id) then replace(replace(lower-case(normalize-space($id)), '[^a-z_0-9 ]', ''), ' ', '-') else ()"/>
  </xsl:function>
  
  
  <xsl:function name="imf:name" as="xs:string">
    <xsl:param name="imvert-element" as="element()"/>
    <xsl:value-of select="$imvert-element/imvert:name/@original"/>
  </xsl:function>
  
  <xsl:function name="imf:equals-ci" as="xs:boolean">
    <xsl:param name="str1" as="xs:string?"/>
    <xsl:param name="str2" as="xs:string?"/>
    <xsl:sequence select="lower-case($str1) = fn:lower-case($str2)"/>
  </xsl:function>
  
  <xsl:function name="imf:is-not-mim-construct" as="xs:boolean">
    <xsl:param name="elem" as="element()"/>
    <xsl:sequence select="not($elem/imvert:stereotype = $mim-stereotype-names) and not($elem/imvert:stereotype/@id = $mim-stereotype-ids)"/>
  </xsl:function>
  
  <xsl:function name="imf:association-is-relatie-klasse" as="xs:boolean">
    <xsl:param name="association" as="element(imvert:association)"/>
    <xsl:sequence select="key('key-imvert-construct-by-id', $association/imvert:association-class/imvert:type-id, $association/root())/imvert:stereotype = $stereotype-name-relatieklasse"/>
  </xsl:function>
  
  <xsl:function name="imf:association-is-keuze-attributes" as="xs:boolean">
    <xsl:param name="association" as="element(imvert:association)"/>
    <xsl:sequence select="key('key-imvert-construct-by-id', $association/imvert:type-id, $association/root())/imvert:stereotype/@id = $stereotype-id-keuze-attributes"/>
  </xsl:function>
  
  <xsl:template name="create-ref-element" as="element()?">
    <xsl:param name="ref-id" as="xs:string"/>
    <xsl:param name="restrict-to-datatypes" as="xs:boolean?" select="false()"/>
    <xsl:variable name="target-element" select="key('key-imvert-construct-by-id', $ref-id)" as="element()?"/>
    <xsl:variable name="target-stereotype-name" select="$target-element/imvert:stereotype" as="xs:string*"/>
    <xsl:variable name="target-stereotype-id" select="$target-element/imvert:stereotype/@id" as="xs:string*"/>
    <xsl:variable name="element-name" as="xs:string?">
      <xsl:choose>
        <xsl:when test="$target-stereotype-name = 
          ($stereotype-name-datatype, 
          $stereotype-name-gestructureerd-datatype,
          $stereotype-name-primitief-datatype,
          $stereotype-name-enumeratie,
          $stereotype-name-codelijst,
          $stereotype-name-referentielijst)">_DatatypeRef</xsl:when>
        <!--
        <xsl:when test="$target-stereotype-name = $stereotype-name-datatype">_DatatypeRef</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-gestructureerd-datatype">GestructureerdDatatypeRef</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-primitief-datatype">PrimitiefDatatypeRef</xsl:when>   
        <xsl:when test="$target-stereotype-name = $stereotype-name-enumeratie">EnumeratieRef</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-codelijst">CodelijstRef</xsl:when> 
        <xsl:when test="$target-stereotype-name = $stereotype-name-referentielijst">ReferentielijstRef</xsl:when>
        -->
        
        <xsl:when test="$target-stereotype-name = $stereotype-name-interface">InterfaceRef</xsl:when>
        
        <xsl:when test="$restrict-to-datatypes"/>
        
        <xsl:when test="$target-stereotype-name = $stereotype-name-objecttype">ObjecttypeRef</xsl:when> 
        <xsl:when test="$target-stereotype-name = $stereotype-name-gegevensgroeptype">GegevensgroeptypeRef</xsl:when>
        
        <xsl:when test="$target-stereotype-id = $stereotype-id-keuze-datatypes">Keuze__DatatypenRef</xsl:when>
        <xsl:when test="$target-stereotype-id = $stereotype-id-keuze-attributes">Keuze__AttribuutsoortenRef</xsl:when>
        <xsl:when test="$target-stereotype-id = $stereotype-id-keuze-associations">Keuze__AssociatiesRef</xsl:when>          
        <xsl:when test="imf:is-not-mim-construct($target-element)">ConstructieRef</xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="imf:message(., 'WARNING', 'Unexpected stereotype [1] in &quot;create-ref-element&quot;', string-join(($target-stereotype-name, $target-stereotype-id), ', '))"/>
          <xsl:text>UnsupportedRef</xsl:text>
        </xsl:otherwise>
      </xsl:choose>   
    </xsl:variable>
    <xsl:if test="$element-name">
      <xsl:element name="mim-ref:{$element-name}" namespace="http://www.geostandaarden.nl/mim-ref/informatiemodel/v1">
        <xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">#{$ref-id}</xsl:attribute>
        <xsl:value-of select="imf:name($target-element)"/>
      </xsl:element>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="extensieKenmerken">
    <xsl:where-populated>
      <mim-ext:kenmerken>
        <xsl:for-each select="imvert:tagged-values/imvert:tagged-value[not(@id = $mim-tagged-value-ids)]">
          <mim-ext:kenmerk naam="{imvert:name/@original}">{imvert:value/@original}</mim-ext:kenmerk>
        </xsl:for-each>  
        <xsl:where-populated>
          <mim-ext:kenmerk naam="positie">{imvert:position/@original}</mim-ext:kenmerk>
        </xsl:where-populated>
        <xsl:if test="imvert:min-occurs-source|imvert:max-occurs-source">
          <mim-ext:kenmerk name="kardinaliteitBron">{imf:kardinaliteit(imvert:min-occurs-source, imvert:max-occurs-source)}</mim-ext:kenmerk>
        </xsl:if>
      </mim-ext:kenmerken>        
    </xsl:where-populated>
  </xsl:template>

</xsl:stylesheet>