<xsl:stylesheet 
  version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:UML="omg.org/UML1.3"
  xmlns:imvert="http://www.imvertor.org/schema/system" 
  xmlns:imf="http://www.imvertor.org/xsl/functions" 
  xmlns:Model="http://www.kadaster.nl/schemas/MIMFORMAT/model/v20210522" 
  xmlns:Model-ref="http://www.kadaster.nl/schemas/MIMFORMAT/model-ref/v20210522" 
  xmlns:Product="http://www.kadaster.nl/schemas/MIMFORMAT/product/v20210522" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:fn="http://www.w3.org/2005/xpath-functions" 
  expand-text="yes" 
  exclude-result-prefixes="imvert imf fn">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  
  <xsl:mode on-no-match="shallow-skip"/>

  <!--
  <xsl:import href="../common/Imvert-common.xsl"/>
  <xsl:import href="../common/Imvert-common-derivation.xsl"/>
  -->

  <xsl:variable name="stylesheet-code">MIMCOMPILER</xsl:variable>
  <!--
  <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
  -->
  
  <!--
  <xsl:variable name="stereotype-name-attribuutsoort" select="'stereotype-name-attribute'" as="xs:string"/>
  <xsl:variable name="stereotype-name-codelijst" select="'stereotype-name-codelist'" as="xs:string"/>
  <xsl:variable name="stereotype-name-data-element" select="'stereotype-name-data-element'" as="xs:string"/>
  <xsl:variable name="stereotype-name-datatype" select="'stereotype-name-designation-datatype stereotype-name-simpletype'" as="xs:string"/>
  <xsl:variable name="stereotype-name-domein" select="'stereotype-name-domain-package'" as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratie" select="'stereotype-name-enumeration'" as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratiewaarde" select="'stereotype-name-enum'" as="xs:string"/>
  <xsl:variable name="stereotype-name-extern" select="'CFG-ST-EXTERNAL stereotype-name-external-package'" as="xs:string"/>
  <xsl:variable name="stereotype-name-externe-koppeling" select="'stereotype-name-externekoppeling'" as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroep" select="'stereotype-name-attributegroup'" as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroeptype" select="'stereotype-name-composite'" as="xs:string"/>
  <xsl:variable name="stereotype-name-generalisatie" select="'stereotype-name-generalization'" as="xs:string"/>
  <xsl:variable name="stereotype-name-gestructureerd-datatype" select="'stereotype-name-complextype'" as="xs:string"/>
  <xsl:variable name="stereotype-name-keuze" select="'stereotype-name-union stereotype-name-union-associations stereotype-name-union-attributes'" as="xs:string"/>
  <xsl:variable name="stereotype-name-objecttype" select="'stereotype-name-objecttype'" as="xs:string"/>
  <xsl:variable name="stereotype-name-primitief-datatype" select="'stereotype-name-simpletype'" as="xs:string"/>
  <xsl:variable name="stereotype-name-referentie-element" select="'stereotype-name-referentie-element'" as="xs:string"/>
  <xsl:variable name="stereotype-name-referentielijst" select="'stereotype-name-referentielijst'" as="xs:string"/>
  <xsl:variable name="stereotype-name-relatieklasse" select="'stereotype-name-relatieklasse'" as="xs:string"/>
  <xsl:variable name="stereotype-name-relatierol" select="'stereotype-name-relation-role'" as="xs:string"/>
  <xsl:variable name="stereotype-name-relatiesoort" select="'stereotype-name-relatiesoort'" as="xs:string"/>
  <xsl:variable name="stereotype-name-view" select="'stereotype-name-view-package'" as="xs:string"/>
  -->
  
  <xsl:variable name="stereotype-name-attribuutsoort"          select="'ATTRIBUUTSOORT'"          as="xs:string"/>
  <xsl:variable name="stereotype-name-codelijst"               select="'CODELIJST'"               as="xs:string"/>
  <xsl:variable name="stereotype-name-data-element"            select="'DATA ELEMENT'"            as="xs:string"/>
  <xsl:variable name="stereotype-name-datatype"                select="'DATATYPE'"                as="xs:string"/>
  <xsl:variable name="stereotype-name-domein"                  select="'DOMEIN'"                  as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratie"              select="'ENUMERATIE'"              as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratiewaarde"        select="'ENUMERATIEWAARDE'"        as="xs:string"/>
  <xsl:variable name="stereotype-name-extern"                  select="'EXTERN'"                  as="xs:string"/>
  <xsl:variable name="stereotype-name-externe-koppeling"       select="'EXTERNE KOPPELING'"       as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroep"           select="'GEGEVENSGROEP'"           as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroeptype"       select="'GEGEVENSGROEPTYPE'"       as="xs:string"/>
  <xsl:variable name="stereotype-name-generalisatie"           select="'GENERALISATIE'"           as="xs:string"/>
  <xsl:variable name="stereotype-name-gestructureerd-datatype" select="'GESTRUCTUREERD DATATYPE'" as="xs:string"/>
  <xsl:variable name="stereotype-name-keuze"                   select="'KEUZE'"                   as="xs:string"/>
  <xsl:variable name="stereotype-name-objecttype"              select="'OBJECTTYPE'"              as="xs:string"/>
  <xsl:variable name="stereotype-name-primitief-datatype"      select="'PRIMITIEF DATATYPE'"      as="xs:string"/>
  <xsl:variable name="stereotype-name-referentie-element"      select="'REFERENTIE ELEMENT'"      as="xs:string"/>
  <xsl:variable name="stereotype-name-referentielijst"         select="'REFERENTIELIJST'"         as="xs:string"/>
  <xsl:variable name="stereotype-name-relatieklasse"           select="'RELATIEKLASSE'"           as="xs:string"/>
  <xsl:variable name="stereotype-name-relatierol"              select="'RELATIEROL'"              as="xs:string"/>
  <xsl:variable name="stereotype-name-relatiesoort"            select="'RELATIESOORT'"            as="xs:string"/>
  <xsl:variable name="stereotype-name-view"                    select="'VIEW'"                    as="xs:string"/>
    
  <xsl:variable name="mim-primitive-datatypes" as="element(Model:PrimitiefDatatype)+">
    <xsl:for-each select="document('../../input/Kadaster/eap/Kadaster-MIM11.xmi')//UML:Class">
      <Model:PrimitiefDatatype id="id-{@xmi.id}">
        <Model:id>id-{@xmi.id}</Model:id>
        <Model:naam>{@name}</Model:naam>
        <Model:herkomst>MIMCompiler</Model:herkomst>
        <Model:datumOpname>2021-05-26</Model:datumOpname>
      </Model:PrimitiefDatatype>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="mim-primitive-datatypes-lc-names" select="for $n in $mim-primitive-datatypes/Model:naam return lower-case($n)" as="xs:string+"/>
  
  <xsl:key name="key-imvert-construct-by-id" match="imvert:*[imvert:id]" use="imvert:id"/>

  <!-- positions alleen bij attribute, association, supertype, substitution -->

  <xsl:template match="/imvert:packages">
    <xsl:variable name="classes" select=".//imvert:class" as="element(imvert:class)*"/>
    <xsl:variable name="attributes" select=".//imvert:attribute" as="element(imvert:attribute)*"/>
    <xsl:variable name="associations" select=".//imvert:association" as="element(imvert:association)*"/>
    <xsl:variable name="supertypes" select=".//imvert:supertype" as="element(imvert:supertype)*"/>
    
    <Product:RaadplegenObjecttypen 
      xmlns:Product="http://www.kadaster.nl/schemas/MIMFORMAT/product/v20210522"
      xmlns:Model="http://www.kadaster.nl/schemas/MIMFORMAT/model/v20210522" 
      xmlns:Model-ref="http://www.kadaster.nl/schemas/MIMFORMAT/model-ref/v20210522"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      
      <xsl:attribute name="schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://www.kadaster.nl/schemas/MIMFORMAT/product/v20210522 http://www.armatiek.nl/downloads/mim/imkad-MIMFORMAT-0.0.1-2-20210522-20210522-110834/xsd/MIMFORMAT/product/v20210522/MIMFORMAT_Product_v1_0.xsd</xsl:attribute>
      
      <Product:id>{imvert:model-id}</Product:id>
      <Product:omschrijving>
        <!-- TODO: type: xs:string -> gestructureerd datatype? -->
        <xsl:value-of select="imf:tagged-values(., 'CFG-TV-DEFINITION')"/>
      </Product:omschrijving>
      <Product:betreft>
        <xsl:for-each select="$classes[imvert:stereotype = $stereotype-name-objecttype]">
          <xsl:sort select="imvert:name"/>
          <Model-ref:ObjecttypeRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:ObjecttypeRef>
        </xsl:for-each>
      </Product:betreft>
      <Product:components>
        <Product:RaadplegenObjecttypenComponents>
          <!-- Model:Objectype: -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-objecttype]"/>
          <!-- Model:Gegevensgroeptype: -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-gegevensgroeptype]"/>
          <!-- Model:Attribuutsoort: -->
          <xsl:apply-templates select="$attributes[imvert:stereotype = $stereotype-name-attribuutsoort]"/>
          <!-- Model:Gegevensgroep: -->
          <xsl:apply-templates select="$attributes[imvert:stereotype = $stereotype-name-gegevensgroep]"/>
          <!-- Model:Relatiesoort: -->
          <xsl:apply-templates select="$associations[imvert:stereotype = $stereotype-name-relatiesoort]"/>
          <!-- Model:Relatieklasse: -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-relatieklasse]"/>
          <!-- Model:GestructureerdDatatype -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-gestructureerd-datatype]"/>
          <!-- Model:PrimitiefDatatype -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-primitief-datatype]"/>
          <xsl:variable name="bare-types" select="for $b in distinct-values($attributes/imvert:baretype) return lower-case($b)" as="xs:string*"/>
          <xsl:sequence select="$mim-primitive-datatypes[lower-case(Model:naam) = $bare-types]"/>
          <!-- Model:Enumeratie -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-enumeratie]"/>
          <!-- Model:Codelijst -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-codelijst]"/>
          <!-- Model:Referentielijst -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-referentielijst]"/>
          <!-- Model:Datatype -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-datatype]"/>
          <!-- Model:DataElement -->
          <xsl:apply-templates select="$attributes[imvert:stereotype = $stereotype-name-data-element]"/>
          <!-- Model:Enumeratiewaarde -->
          <xsl:apply-templates select="$attributes[imvert:stereotype = $stereotype-name-enumeratiewaarde]"/>
          <!-- Model:ReferentieElement -->
          <xsl:apply-templates select="$attributes[imvert:stereotype = $stereotype-name-referentie-element]"/>
          <!-- Model:Generalisatie -->
          <xsl:apply-templates select="$supertypes[imvert:stereotype = $stereotype-name-generalisatie]"/>
          <!-- Model:Keuze__Attribuutsoorten -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-keuze]"/> <!-- TODO -->
          <!-- Model:Keuze__Datatypen -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-keuze]"/> <!-- TODO -->
          <!-- Model:Keuze__Associaties -->
          <xsl:apply-templates select="$classes[imvert:stereotype = $stereotype-name-keuze]"/> <!-- TODO -->
          <!-- Model:ExterneKoppeling -->
          <xsl:apply-templates select="$associations[imvert:stereotype = $stereotype-name-externe-koppeling]"/>
        </Product:RaadplegenObjecttypenComponents>
      </Product:components>
    </Product:RaadplegenObjecttypen>
  </xsl:template>

  <!-- Model:Objectype -->
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-objecttype]">
    <Model:Objecttype id="{imf:valid-id(imvert:id)}">
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
      <xsl:call-template name="gebruikt"/>
      <xsl:call-template name="gebruikt__keuze"/>
      <xsl:call-template name="bezitExterneRelatie"/>
      <xsl:call-template name="gebruikt__gegevensgroep"/>
      <xsl:call-template name="bezit"/>
    </Model:Objecttype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gegevensgroeptype]">
    <Model:Gegevensgroeptype id="{imf:valid-id(imvert:id)}">
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
    </Model:Gegevensgroeptype>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-attribuutsoort]">
    <Model:Attribuutsoort id="{imf:valid-id(imvert:id)}">
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
    </Model:Attribuutsoort>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-gegevensgroep]">
    <Model:Gegevensgroep id="{imf:valid-id(imvert:id)}">
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
      <xsl:call-template name="heeft"/>
    </Model:Gegevensgroep>
  </xsl:template>
  
  <xsl:template match="imvert:association[imvert:stereotype = $stereotype-name-relatiesoort]">
    <Model:Relatiesoort id="{imf:valid-id(imvert:id)}">
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
    </Model:Relatiesoort>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-relatieklasse]">
    <Model:Relatieklasse id="{imf:valid-id(imvert:id)}">
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
    </Model:Relatieklasse>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gestructureerd-datatype]">
    <Model:GestructureerdDatatype id="{imf:valid-id(imvert:id)}">
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
      <xsl:call-template name="bevat"/>
    </Model:GestructureerdDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-primitief-datatype]">
    <Model:PrimitiefDatatype id="{imf:valid-id(imvert:id)}">
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
    </Model:PrimitiefDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-enumeratie]">
    <Model:Enumeratie id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="bevat"/>
    </Model:Enumeratie>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-codelijst]">
    <Model:Codelijst id="{imf:valid-id(imvert:id)}">
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
    </Model:Codelijst>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-referentielijst]">
    <Model:Referentielijst id="{imf:valid-id(imvert:id)}">
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
      <xsl:call-template name="bevat"/>
    </Model:Referentielijst>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-datatype]">
    <Model:Datatype id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="type"/>
    </Model:Datatype>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-data-element]">
    <Model:DataElement id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="lengte"/>
      <xsl:call-template name="patroon"/>
      <xsl:call-template name="formeelPatroon"/>
      <xsl:call-template name="kardinaliteit"/>
      <xsl:call-template name="heeft"/>
    </Model:DataElement>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-enumeratiewaarde]">
    <Model:Enumeratiewaarde id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="definitie"/>
      <xsl:call-template name="code"/>
    </Model:Enumeratiewaarde>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-referentie-element]">
    <Model:ReferentieElement id="{imf:valid-id(imvert:id)}">
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
      <xsl:call-template name="heeft"/>
    </Model:ReferentieElement>
  </xsl:template>
  
  <xsl:template match="imvert:supertype[imvert:stereotype = $stereotype-name-generalisatie]">
    <Model:Generalisatie id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="verwijstNaarGenerieke"/>
    </Model:Generalisatie>
  </xsl:template>
  
  <xsl:template match="imvert:association[imvert:stereotype = $stereotype-name-externe-koppeling]">
    <Model:ExterneKoppeling id="{imf:valid-id(imvert:id)}">
      <xsl:call-template name="id"/>
      <xsl:call-template name="naam"/>
      <xsl:call-template name="alias"/>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="begrip"/>
      <xsl:call-template name="uniDirectioneel"/>
      <xsl:call-template name="typeAggregatie"/>
      <xsl:call-template name="doel"/>
    </Model:ExterneKoppeling>
  </xsl:template>

  <!-- Attributen: -->
  <xsl:template name="alias">
    <xsl:where-populated>
      <Model:alias>{imvert:alias}</Model:alias>
    </xsl:where-populated>
  </xsl:template>

  <xsl:template name="authentiek">
    <Model:authentiek>{imf:tagged-values(., 'CFG-TV-INDICATIONAUTHENTIC')}</Model:authentiek>
  </xsl:template>

  <xsl:template name="begrip">
    <xsl:for-each select="imf:tagged-values(., 'CFG-TV-CONCEPT')">
      <Model:begrip>{.}</Model:begrip>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="bevat">
    <xsl:where-populated>
      <Model:bevat>
        <xsl:for-each select="imvert:attributes/imvert:attribute">
          <xsl:choose>
            <xsl:when test="imvert:stereotype = $stereotype-name-data-element">
              <Model-ref:DataElementRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:DataElementRef>    
            </xsl:when>
            <xsl:when test="imvert:stereotype = $stereotype-name-enumeratiewaarde">
              <Model-ref:EnumeratiewaardeRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:EnumeratiewaardeRef>
            </xsl:when>
            <xsl:when test="imvert:stereotype = $stereotype-name-referentie-element">
              <Model-ref:ReferentieElementRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:ReferentieElementRef>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>    
      </Model:bevat>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="bezit">
    <!-- Objecttype.bezit.Relatiesoort -->
    <xsl:where-populated>
      <Model:bezit>
        <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype = ($stereotype-name-relatiesoort, $stereotype-name-relatieklasse)]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <xsl:choose>
            <xsl:when test="imvert:stereotype = $stereotype-name-relatiesoort">
              <Model-ref:RelatiesoortRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:RelatiesoortRef>
            </xsl:when>
            <xsl:otherwise>
              <Model-ref:RelatieklasseRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:RelatieklasseRef>
            </xsl:otherwise>
          </xsl:choose>
          <Model:RelatierolBron>
            <Model:id>{imvert:name}</Model:id> <!-- TODO: Slaat dit ergens op? -->
          </Model:RelatierolBron>
        </xsl:for-each>  
      </Model:bezit>
    </xsl:where-populated>
  </xsl:template>

  <xsl:template name="bezitExterneRelatie">
    <xsl:where-populated>
      <Model:bezitExterneRelatie>
        <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype = $stereotype-name-externe-koppeling]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <Model-ref:ExterneKoppelingRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:ExterneKoppelingRef>  
        </xsl:for-each>
      </Model:bezitExterneRelatie>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="code">
    <xsl:where-populated>
      <Model:code>{imvert:name}</Model:code>
    </xsl:where-populated>
  </xsl:template>

  <xsl:template name="datumOpname">
    <Model:datumOpname>{imf:tagged-values(., 'CFG-TV-DATERECORDED')}</Model:datumOpname>
  </xsl:template>

  <xsl:template name="definitie">
    <!-- TODO: type: xs:string -> gestructureerd datatype? -->
    <Model:definitie>{imf:tagged-values(., 'CFG-TV-DEFINITION')}</Model:definitie>
  </xsl:template>

  <xsl:template name="doel">
    <!-- TODO: mapping?? -->
  </xsl:template>
  
  <xsl:template name="formeelPatroon">
    <xsl:where-populated>
      <Model:formeelPatroon>{imf:tagged-values(., 'CFG-TV-FORMALPATTERN')}</Model:formeelPatroon>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="gebruikt">
    <!-- TODO: implementeren: 1..* Keuze__AttribuutsoortenRef -->
  </xsl:template>
  
  <xsl:template name="gebruikt__attribuutsoort">
    <xsl:where-populated>
      <Model:gebruikt__attribuutsoort>
        <xsl:for-each select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-attribuutsoort]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <Model-ref:AttribuutsoortRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:AttribuutsoortRef>  
        </xsl:for-each>
      </Model:gebruikt__attribuutsoort>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="gebruikt__gegevensgroep">
    <xsl:where-populated>
      <Model:gebruikt__gegevensgroep>
        <xsl:for-each select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-gegevensgroep]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <Model-ref:GegevensgroepRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:GegevensgroepRef>  
        </xsl:for-each>
      </Model:gebruikt__gegevensgroep>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="gebruikt__keuze">
    <xsl:where-populated>
      <Model:gebruikt__keuze>
        <xsl:for-each select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-keuze]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <Model-ref:Keuze__DatatypenRef xlink:href="#{imf:valid-id(imvert:id)}">{imvert:name}</Model-ref:Keuze__DatatypenRef>  
        </xsl:for-each>
      </Model:gebruikt__keuze>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="heeft"><!--TODO--></xsl:template>
  
  <xsl:template name="heeft__datatype">
    <xsl:where-populated>
      <Model:heeft__datatype>
        <xsl:variable name="baretype" select="imvert:baretype" as="xs:string?"/>
        <xsl:choose>
          <xsl:when test="imvert:type-id">
            <xsl:variable name="type" select="key('key-imvert-construct-by-id', imvert:type-id)" as="element()?"/>
            <xsl:variable name="ref-id" select="imf:valid-id($type/imvert:id)" as="xs:string"/>
            <xsl:variable name="ref-name" select="$type/imvert:naam" as="xs:string?"/>
            <xsl:variable name="stereotype" select="$type/imvert:stereotype" as="xs:string*"/>
            <xsl:choose>
              <xsl:when test="$stereotype = $stereotype-name-datatype">
                <Model-ref:_DatatypeRef xlink:href="#{$ref-id}">{$ref-name}</Model-ref:_DatatypeRef>
              </xsl:when>
              <xsl:when test="$stereotype = $stereotype-name-gestructureerd-datatype">
                <Model-ref:GestructureerdDatatypeRef xlink:href="#{$ref-id}">{$ref-name}</Model-ref:GestructureerdDatatypeRef>
              </xsl:when>
              <xsl:when test="$stereotype = $stereotype-name-primitief-datatype">
                <Model-ref:PrimitiefDatatypeRef xlink:href="#{$ref-id}">{$ref-name}</Model-ref:PrimitiefDatatypeRef>
              </xsl:when>
              <xsl:when test="$stereotype = $stereotype-name-enumeratie">
                <Model-ref:EnumeratieRef xlink:href="#{$ref-id}">{$ref-name}</Model-ref:EnumeratieRef>
              </xsl:when>
              <xsl:when test="$stereotype = $stereotype-name-codelijst">
                <Model-ref:CodelijstRef xlink:href="#{$ref-id}">{$ref-name}</Model-ref:CodelijstRef>
              </xsl:when>
              <xsl:when test="$stereotype = $stereotype-name-referentielijst">
                <Model-ref:ReferentielijstRef xlink:href="#{$ref-id}">{$ref-name}</Model-ref:ReferentielijstRef>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="imf:report-error('Onverwacht stereotype ' || $stereotype || ' in heeft__datatype')"/>
              </xsl:otherwise>
            </xsl:choose>  
          </xsl:when>
          <xsl:when test="$baretype[lower-case(.) = $mim-primitive-datatypes-lc-names]">
            <!-- MIM standaard datatype herkend dat als baretype is ingevoerd ( en dus geen gebruikmaakt van Kadaster-MIM11.xmi): -->
            <xsl:variable name="datatype" select="$mim-primitive-datatypes[lower-case(Model:naam) = lower-case($baretype)]" as="element(Model:PrimitiefDatatype)"/>
            <Model-ref:PrimitiefDatatypeRef xlink:href="#{$datatype/@id}">{$datatype/Model:naam}</Model-ref:PrimitiefDatatypeRef>
          </xsl:when>
          <xsl:otherwise>  
            <xsl:sequence select="imf:report-error('Baretype ' || $baretype || ' is geen standaard MIM datatype')"/>
          </xsl:otherwise>
        </xsl:choose>
      </Model:heeft__datatype>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="heeft__keuze">
    <!-- TODO: implementeren: keuze gerelateerd -->
  </xsl:template>

  <xsl:template name="herkomst">
    <Model:herkomst>{imf:tagged-values(., 'CFG-TV-SOURCE')}</Model:herkomst>
  </xsl:template>

  <xsl:template name="herkomstDefinitie">
    <Model:herkomstDefinitie>{imf:tagged-values(., 'CFG-TV-SOURCEOFDEFINITION')}</Model:herkomstDefinitie>
  </xsl:template>

  <xsl:template name="id">
    <Model:id>{imf:valid-id(imvert:id)}</Model:id>
  </xsl:template>

  <xsl:template name="identificatie__F"><!--TODO--></xsl:template>
  
  <xsl:template name="identificerend">
    <!-- TODO: mapping?? -->
  </xsl:template>
  
  <xsl:template name="indicatieAbstractObject">
    <!-- TODO: klopt default waarde 'false'? -->
    <Model:indicatieAbstractObject>{(imvert:abstract, 'false')[1]}</Model:indicatieAbstractObject>
  </xsl:template>
  
  <xsl:template name="indicatieAfleidbaar">
    <!-- TODO: klopt default waarde 'false'? -->
    <Model:indicatieAfleidbaar>{imf:boolean(imf:tagged-values(., 'CFG-TV-INDICATIONDERIVABLE'))}</Model:indicatieAfleidbaar>
  </xsl:template>
  
  <xsl:template name="indicatieClassificerend">
    <!-- TODO: klopt default waarde 'false'? -->
    <Model:indicatieClassificerend>{imf:boolean(imf:tagged-values(., 'CFG-TV-INDICATIONCLASSIFICATION'))}</Model:indicatieClassificerend>
  </xsl:template>
  
  <xsl:template name="indicatieFormeleHistorie">
    <!-- TODO: klopt default waarde van false()? -->
    <Model:indicatieFormeleHistorie>{(imf:boolean(imf:tagged-values(., 'CFG-TV-INDICATIONFORMALHISTORY')[1]))}</Model:indicatieFormeleHistorie>
  </xsl:template>
  
  <xsl:template name="indicatieMateriLeHistorie"> 
    <!-- TODO: tikfout in XML schema -->
    <!-- TODO: klopt default waarde van false()? -->
    <Model:indicatieMateriLeHistorie>{(imf:boolean(imf:tagged-values(., 'CFG-TV-INDICATIONMATERIALHISTORY')[1]))}</Model:indicatieMateriLeHistorie>
  </xsl:template>
  
  <xsl:template name="kardinaliteit">
    <!-- TODO: bij associations spelen ook nog imvert:min-occurs-source en imvert:max-occurs-source. Welke hier gebruiken? --> 
    <Model:kardinaliteit>
      <xsl:variable name="min" select="(imvert:min-occurs, '1')[1]" as="xs:string"/>
      <xsl:variable name="max" select="(imvert:max-occurs, '1')[1]" as="xs:string"/>
      <xsl:choose>
        <xsl:when test="$min = '1' and $max = '1'">1</xsl:when>
        <xsl:when test="$min = '1' and $max = 'unbounded'">1..*</xsl:when>
        <xsl:when test="$min = '0' and $max = '1'">0..1</xsl:when>
        <xsl:when test="$min = '0' and $max = 'unbounded'">1..*</xsl:when>
      </xsl:choose>
    </Model:kardinaliteit>
  </xsl:template>
  
  <xsl:template name="kardinalteit">
    <!-- TODO: tikfout in XML schema -->
    <xsl:call-template name="kardinaliteit"/>
  </xsl:template>
  
  <xsl:template name="kwaliteit">
    <xsl:where-populated>
      <Model:kwaliteit>{imf:tagged-values(., 'CFG-TV-QUALITY')}</Model:kwaliteit>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="lengte">
    <xsl:where-populated>
      <Model:lengte>{imf:tagged-values(., 'CFG-TV-LENGTH')}</Model:lengte>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="locatie">
    <Model:locatie>{imf:tagged-values(., 'CFG-TV-DATALOCATION')}</Model:locatie>
  </xsl:template>
  
  <xsl:template name="mogelijkGeenWaarde">
    <!-- TODO: in IMKAD model heeft een attribuut twee CFG-TV-VOIDABLE tagged values, één Ja en één Nee, kan dat? -->
    <Model:mogelijkGeenWaarde>{imf:boolean(imf:tagged-values(., 'CFG-TV-VOIDABLE')[1])}</Model:mogelijkGeenWaarde>
  </xsl:template>

  <xsl:template name="naam">
    <Model:naam>{imvert:name}</Model:naam>
  </xsl:template>

  <xsl:template name="patroon">
    <xsl:where-populated>
      <Model:patroon>{imf:tagged-values(., 'CFG-TV-PATTERN')}</Model:patroon>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="populatie">
    <xsl:where-populated>
      <Model:populatie>{imf:tagged-values(., 'CFG-TV-POPULATION')}</Model:populatie>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="supertype">
    <xsl:for-each select="imvert:supertype[imvert:stereotype = $stereotype-name-generalisatie]">
      <xsl:variable name="super-type" select="key('key-imvert-construct-by-id', imvert:type-id)" as="element(imvert:class)"/>
      <Model:supertype>
        <Model:Generalisatie>
          <Model:datumOpname>{imf:tagged-values(., 'CFG-TV-DATERECORDED')}</Model:datumOpname>
          <!-- TODO: deze constructie begrijp ik niet
          <Model:supertype>
            <Model-ref:EnumeratieRef xlink:href="http://www.oxygenxml.com/">EnumeratieRef1</Model-ref:EnumeratieRef>
          </Model:supertype>
          -->
          <Model:verwijstNaarGenerieke>
            <Model-ref:ObjecttypeRef xlink:href="#{imf:valid-id($super-type/imvert:id)}">{$super-type/imvert:name}</Model-ref:ObjecttypeRef>
          </Model:verwijstNaarGenerieke>
        </Model:Generalisatie>  
      </Model:supertype>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="toelichting">
    <xsl:where-populated>
      <Model:toelichting>{imf:tagged-values(., 'CFG-TV-DESCRIPTION')}</Model:toelichting>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="type"><!--TODO--></xsl:template>
  
  <xsl:template name="typeAggregatie">
    <Model:typeAggregatie>{(imf:capitalize-first(imvert:aggregation), 'Geen')[1]}</Model:typeAggregatie>
  </xsl:template>
  
  <xsl:template name="uniDirectioneel">
    <!-- TODO: mapping?? -->
    <Model:uniDirectioneel>{imvert:source/imvert:navigable = 'false'}</Model:uniDirectioneel>
  </xsl:template>
  
  <xsl:template name="uniekeAanduiding">
    <Model:uniekeAanduiding>
      <!-- TODO: mapping?? -->
    </Model:uniekeAanduiding>
  </xsl:template>
  
  <xsl:template name="verwijstNaar">
    <!-- TODO: keuze gerelateerd, Model-ref:Keuze__DatatypenRef -->
  </xsl:template>
  
  <xsl:template name="verwijstNaarGenerieke">
    <!-- TODO: mapping?? -->
  </xsl:template>
  
  <xsl:template name="verwijstNaar__objecttype">
    <!-- TODO: dit werkt alleen met RELATIESOORT, niet met RELATIEKLASSE -->
    <xsl:where-populated>
      <Model:verwijstNaar__objecttype>
        <Model-ref:ObjecttypeRef xlink:href="#{imf:valid-id(imvert:type-id)}">{imvert:type-name}</Model-ref:ObjecttypeRef>
        <Model:_Relatierol>
          <Model:id>Doel</Model:id> <!-- TODO: mapping?? -->
        </Model:_Relatierol>
      </Model:verwijstNaar__objecttype>
    </xsl:where-populated>
  </xsl:template>
  
  <!-- TODO: gebruik functions uit geimporteerde stylesheets? -->
  <xsl:function name="imf:tagged-values" as="xs:string*">
    <xsl:param name="context-node" as="element()"/>
    <xsl:param name="tag-id" as="xs:string"/>
    <xsl:sequence select="for $v in $context-node/imvert:tagged-values/imvert:tagged-value[@id = $tag-id]/imvert:value return normalize-space(string-join($v//text(), ' '))"/>
  </xsl:function>
    
  <xsl:function name="imf:boolean" as="xs:boolean">
    <xsl:param name="this" as="item()?"/>
    <xsl:variable name="v" select="lower-case(string($this))"/>
    <xsl:sequence select="
      if ($v=('yes','true','ja','1')) then true() 
      else if ($v=('no','false','nee','0')) then false() 
      else if ($this) then true() 
      else false()"/>
  </xsl:function>
  
  <xsl:function name="imf:capitalize-first" as="xs:string?">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:sequence select="if ($arg) then concat(upper-case(substring($arg,1,1)), substring($arg,2)) else ()"/>
  </xsl:function>
  
  <xsl:function name="imf:report-error" as="comment()">
    <xsl:param name="message" as="xs:string"/>
    <xsl:message terminate="no" select="$message"/>
    <xsl:comment> {$message} </xsl:comment>
  </xsl:function>

  <xsl:function name="imf:valid-id" as="xs:string">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:sequence select="'id-' || translate($id, '{}', '')"/>
  </xsl:function>

</xsl:stylesheet>