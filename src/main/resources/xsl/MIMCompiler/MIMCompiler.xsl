<xsl:stylesheet 
  version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:imvert="http://www.imvertor.org/schema/system"
  xmlns:mim="http://www.geonovum.nl/schemas/MIMFORMAT/model/v20210522" 
  xmlns:mim-ref="http://www.geonovum.nl/schemas/MIMFORMAT/model-ref/v20210522"
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
        <xsl:sequence select="$mim11-package"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/imvert:packages">
    <mim:Informatiemodel
      xmlns:mim="http://www.geonovum.nl/schemas/MIMFORMAT/model/v20210522" 
      xmlns:mim-ref="http://www.geonovum.nl/schemas/MIMFORMAT/model-ref/v20210522"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      
      <xsl:attribute name="schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://www.geonovum.nl/schemas/MIMFORMAT/model/v20210522 ../xsd/MIMFORMAT/model/v20210522/MIMFORMAT_Mim_v0_0_1.xsd</xsl:attribute>
      
      <mim:naam>{imvert:model-id}</mim:naam>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomst"/>
      <mim:informatiedomein>{imvert:application}</mim:informatiedomein> <!-- TODO: mapping -->
      <mim:informatiemodeltype><xsl:comment> TODO </xsl:comment></mim:informatiemodeltype> <!-- TODO: mapping, bv "conceptueel", "logisch", "technisch" -->
      <mim:relatiemodelleringstype>{if ($associations/(imvert:target|imvert:source)[imvert:tagged-values/imvert:tagged-value]) then 'Relatierol leidend' else 'Relatiesoort leidend'}</mim:relatiemodelleringstype> <!-- TODO: "Relatiesoort leidend" of "Relatierol leidend" -->
      <mim:mIMVersie>{if (matches(imvert:metamodel, 'MIM\s+1\.1', 'i')) then '1.1' else if (matches(imvert:metamodel, 'MIM\s+1\.0', 'i')) then '1.0' else 'Onbekend'}</mim:mIMVersie>
      <mim:mIMExtensie>Kadaster</mim:mIMExtensie> <!-- TODO: mapping? -->
      <mim:mIMTaal>NL</mim:mIMTaal> <!-- TODO: mapping? -->
      
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
        </mim:InformatiemodelComponents>
      </mim:components>
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
  </xsl:template>
  
  <!-- mim:Domein -->
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-domein]">
    <mim:Domein id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="domein-of-view"/>
    </mim:Domein>
  </xsl:template>

  <!-- mim:View -->
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-view]">
    <mim:View id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="domein-of-view"/>
      <xsl:call-template name="locatie"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="herkomst"/>
    </mim:View>
  </xsl:template>

  <!-- mim:Objectype -->
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-objecttype]">
    <mim:Objecttype id="{imf:valid-id(imvert:id)}">
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
    </mim:Objecttype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gegevensgroeptype]">
    <mim:Gegevensgroeptype id="{imf:valid-id(imvert:id)}">
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
    </mim:Relatieklasse>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gestructureerd-datatype]">
    <mim:GestructureerdDatatype id="{imf:valid-id(imvert:id)}">
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
    </mim:GestructureerdDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-primitief-datatype]">
    <mim:PrimitiefDatatype id="{imf:valid-id(imvert:id)}">
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
    </mim:PrimitiefDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-enumeratie]">
    <mim:Enumeratie id="{imf:valid-id(imvert:id)}">
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
    </mim:Enumeratie>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-codelijst]">
    <mim:Codelijst id="{imf:valid-id(imvert:id)}">
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
    </mim:Codelijst>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-referentielijst]">
    <mim:Referentielijst id="{imf:valid-id(imvert:id)}">
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
    </mim:Referentielijst>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-datatype]">
    <mim:Datatype id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="type"/>
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
    </mim:DataElement>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-enumeratiewaarde]">
    <mim:Enumeratiewaarde>
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="code"/>
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
      <xsl:call-template name="identificatie__F"/>
      <xsl:call-template name="toelichting"/>
      <mim:heeft>
        <xsl:call-template name="process-datatype"/>
      </mim:heeft>
    </mim:ReferentieElement>
  </xsl:template>
  
  <xsl:template match="imvert:supertype[imvert:stereotype = $stereotype-name-generalisatie]">
    <mim:Generalisatie>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="verwijstNaarGenerieke"/>
    </mim:Generalisatie>
  </xsl:template>
  
  <?x
  <!-- mim:Keuze__Attribuutsoorten -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-id-keuze-attributes]">
    <xsl:for-each select="imvert:attributes/imvert:attribute">
      <mim:Keuze__Attribuutsoorten id="{imf:valid-id(imvert:id)}">
        <xsl:call-template name="id"/>
        <xsl:call-template name="naam"/>
        <xsl:call-template name="alias"/>
        <xsl:call-template name="kardinalteit"/>
        <mim:heeft>
          <xsl:if test="imvert:type-id/text()">
            <xsl:variable name="type" select="key('key-imvert-construct-by-id', imvert:type-id)" as="element()?"/>
            <xsl:variable name="stereotype" select="$type/imvert:stereotype" as="xs:string?"/>
            <xsl:if test="not($stereotype = $stereotype-name-keuze)">
              <xsl:sequence select="imf:msg(., 'WARNING', 'Unexpected stereotype [1] in &quot;process-datatype&quot;, expected: KEUZE', ($stereotype))"/> <!-- TODO: is deze warning terecht? -->
            </xsl:if>
            <mim-ref:Keuze__DatatypenRef xlink:href="#{imf:valid-id($type/imvert:id)}">{$type/imvert:name}</mim-ref:Keuze__DatatypenRef>
          </xsl:if>  
        </mim:heeft>
      </mim:Keuze__Attribuutsoorten>  
    </xsl:for-each>
  </xsl:template> 
  ?>
  
  <!-- mim:Keuze__Attribuutsoorten -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-id-keuze-attributes]">
    <mim:Keuze__Attribuutsoorten id="{imf:valid-id(imvert:id)}">
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
    </mim:Keuze__Attribuutsoorten>  
  </xsl:template> 
  
  <!-- mim:Keuze__Datatypen -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-id-keuze-datatypes]">
    <mim:Keuze__Datatypen id="{imf:valid-id(imvert:id)}">
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
    </mim:Keuze__Datatypen>
  </xsl:template> 
  
  <!-- mim:Keuze__Associaties -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = $stereotype-id-keuze-associations]">
    <mim:Keuze__Associaties id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="uniDirectioneel"/>
      <xsl:call-template name="typeAggregatie"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="doel"/>
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
    </mim:ExterneKoppeling>
  </xsl:template>
  
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-extern]">
    <mim:Extern id="{imf:valid-id(imvert:id)}">
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
    </mim:Extern>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-interface]">
    <mim:Interface id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>  
    </mim:Interface>
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
              <mim-ref:DataElementRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</mim-ref:DataElementRef>    
            </xsl:when>
            <xsl:when test="imvert:stereotype = $stereotype-name-enumeratiewaarde">
              <mim-ref:EnumeratiewaardeRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</mim-ref:EnumeratiewaardeRef>
            </xsl:when>
            <xsl:when test="imvert:stereotype = $stereotype-name-referentie-element">
              <mim-ref:ReferentieElementRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</mim-ref:ReferentieElementRef>
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
              <mim-ref:RelatieklasseRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</mim-ref:RelatieklasseRef>
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
          <mim-ref:Keuze__DatatypenRef xlink:href="#{imf:valid-id($type/imvert:id)}">{$type/imvert:name}</mim-ref:Keuze__DatatypenRef>
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
    <mim:id>{imf:valid-id(imvert:id)}</mim:id>
    -->
  </xsl:template>

  <xsl:template name="identificatie__F"><!--TODO--></xsl:template>
  
  <xsl:template name="identificerend">
    <!-- TODO: mapping?? -->
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
  
  <xsl:template name="kardinaliteit">
    <!-- TODO: wat te doen met de source kardinaliteiten van relatiesoorten? --> 
    <mim:kardinaliteit>
      <xsl:variable name="min" select="imf:convert-occurs(imvert:min-occurs)" as="xs:string"/>
      <xsl:variable name="max" select="imf:convert-occurs(imvert:max-occurs)" as="xs:string"/>
      <xsl:choose>
        <xsl:when test="$min = $max">{$min}</xsl:when>
        <xsl:otherwise>{$min}..{$max}</xsl:otherwise>
      </xsl:choose>
    </mim:kardinaliteit>
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
    <xsl:for-each select="imvert:supertype[not(imvert:stereotype) or imvert:stereotype = $stereotype-name-generalisatie]">
      <xsl:variable name="super-type" select="key('key-imvert-construct-by-id', imvert:type-id)" as="element(imvert:class)"/>
      <mim:supertype>
        <mim:Generalisatie>
          <mim:datumOpname>{imf:tagged-values(., 'CFG-TV-DATERECORDED')}</mim:datumOpname>
          <xsl:choose>
            <xsl:when test="$stereotype = $stereotype-name-objecttype">
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
      </mim:supertype>
    </xsl:for-each>
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
        <mim-ref:ObjecttypeRef xlink:href="#{imf:valid-id(imvert:type-id)}">{imvert:type-name}</mim-ref:ObjecttypeRef>
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
    <xsl:variable name="v" select="lower-case(string($this))"/>
    <xsl:sequence select="
      if ($v=('yes','true','ja','1')) then 'Ja' 
      else if ($v=('no','false','nee','0')) then 'Nee' 
      else if ($this) then 'Ja' 
      else 'Nee'"/>
  </xsl:function>
  
  <xsl:function name="imf:capitalize-first" as="xs:string?">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:sequence select="if ($arg) then concat(upper-case(substring($arg,1,1)), substring($arg,2)) else ()"/>
  </xsl:function>
  
  <xsl:function name="imf:valid-id" as="xs:string">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:sequence select="'id-' || translate($id, '{}', '')"/>
  </xsl:function>
  
  <xsl:function name="imf:valid-name-id" as="xs:string">
    <xsl:param name="name" as="xs:string?"/>
    <xsl:variable name="id-1" select="lower-case(replace(normalize-space($name), '\s', '_'))" as="xs:string"/>
    <xsl:variable name="id-2" select="replace($id-1, '(^\d.)', 'id-$1')" as="xs:string"/>
    <xsl:value-of select="$id-2"/>
  </xsl:function>
  
  <xsl:function name="imf:name" as="xs:string">
    <xsl:param name="imvert-element" as="element()"/>
    <xsl:choose>
      <xsl:when test="$imvert-element/self::imvert:class and $imvert-element/imvert:stereotype = 'INTERFACE'">{$imvert-element/imvert:name/@original}</xsl:when>
      <xsl:otherwise>{$imvert-element/imvert:name}</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="imf:equals-ci" as="xs:boolean">
    <xsl:param name="str1" as="xs:string?"/>
    <xsl:param name="str2" as="xs:string?"/>
    <xsl:sequence select="lower-case($str1) = fn:lower-case($str2)"/>
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
        <xsl:when test="$target-stereotype-name = $stereotype-name-datatype">{'_DatatypeRef'}</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-gestructureerd-datatype">{'GestructureerdDatatypeRef'}</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-primitief-datatype">{'PrimitiefDatatypeRef'}</xsl:when>   
        <xsl:when test="$target-stereotype-name = $stereotype-name-enumeratie">{'EnumeratieRef'}</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-codelijst">{'CodelijstRef'}</xsl:when> 
        <xsl:when test="$target-stereotype-name = $stereotype-name-referentielijst">{'ReferentielijstRef'}</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-interface">{'InterfaceRef'}</xsl:when>
        
        <xsl:when test="$restrict-to-datatypes"/>
        
        <xsl:when test="$target-stereotype-name = $stereotype-name-objecttype">{'ObjecttypeRef'}</xsl:when> 
        <xsl:when test="$target-stereotype-name = $stereotype-name-gegevensgroeptype">{'GegevensgroeptypeRef'}</xsl:when>
        
        <xsl:when test="$target-stereotype-id = $stereotype-id-keuze-datatypes">{'Keuze__DatatypenRef'}</xsl:when>
        <xsl:when test="$target-stereotype-id = $stereotype-id-keuze-attributes">{'Keuze__AttribuutsoortenRef'}</xsl:when>
        <xsl:when test="$target-stereotype-id = $stereotype-id-keuze-associations">{'Keuze__AssociatiesRef'}</xsl:when>          
        <xsl:otherwise>
          <xsl:sequence select="imf:message(., 'WARNING', 'Unexpected stereotype [1] in &quot;create-ref-element&quot;', string-join(($target-stereotype-name, $target-stereotype-id), ', '))"/>
          <xsl:text>UnsupportedRef</xsl:text>
        </xsl:otherwise>
      </xsl:choose>   
    </xsl:variable>
    <xsl:if test="$element-name">
      <xsl:element name="mim-ref:{$element-name}" namespace="http://www.geonovum.nl/schemas/MIMFORMAT/model-ref/v20210522">
        <xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">#{imf:valid-id($ref-id)}</xsl:attribute>
        <xsl:value-of select="imf:name($target-element)"/>
      </xsl:element>  
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>