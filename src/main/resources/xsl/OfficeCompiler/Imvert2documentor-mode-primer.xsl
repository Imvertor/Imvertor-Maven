<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:variable name="pages" select="//*:page[@id]"/>
    
    <xsl:variable name="maps" as="element(map)+">
        <map metagegeven="Naam" onderwerp="metagegevens-naam"/>
        <map metagegeven="Alias" onderwerp="metagegevens-naam"/>
        <map metagegeven="Begrip" onderwerp="metagegevens-naam"/>
        
        <map metagegeven="Kardinaliteit" onderwerp="metagegevens-kardinaliteit"/>
        <map metagegeven="Mogelijk geen waarde" onderwerp="metagegevens-kardinaliteit"/>
        
        <map metagegeven="Herkomst" onderwerp="metagegevens-herkomst"/>
        <map metagegeven="Datum opname" onderwerp="metagegevens-herkomst"/>
        
        <map metagegeven="Definitie" onderwerp="metagegevens-definitie"/>
        <map metagegeven="Definities" onderwerp="metagegevens-definitie"/>
        <map metagegeven="Toelichting" onderwerp="metagegevens-definitie"/>
       
        <map metagegeven="Unieke aanduiding" onderwerp="metagegevens-identificatie"/>
        <map metagegeven="Identificerend" onderwerp="metagegevens-identificatie"/>
        <map metagegeven="Classificerend" onderwerp="metagegevens-identificatie"/>
        <map metagegeven="Indicatie afleidbaar" onderwerp="metagegevens-identificatie"/>
        
        <map metagegeven="Populatie" onderwerp="metagegevens-populatie"/>
        <map metagegeven="Kwaliteit" onderwerp="metagegevens-populatie"/>
        
        <map metagegeven="Domein" onderwerp="metagegevens-domeinwaarden"/>
        <map metagegeven="Type" onderwerp="metagegevens-domeinwaarden"/>
        <map metagegeven="Lengte" onderwerp="metagegevens-domeinwaarden"/>
        <map metagegeven="Patroon" onderwerp="metagegevens-domeinwaarden"/>
        <map metagegeven="Formeel patroon" onderwerp="metagegevens-domeinwaarden"/>
        
        <map metagegeven="Indicatie formele historie" onderwerp="metagegevens-historie"/>
        <map metagegeven="Indicatie materiële historie" onderwerp="metagegevens-historie"/>
        
        <map metagegeven="Relatiemodelleringstype" onderwerp="metagegevens-relatie"/>
        <map metagegeven="Unidirectioneel" onderwerp="metagegevens-relatie"/>
        <map metagegeven="Aggregatietype" onderwerp="metagegevens-relatie"/>
        <map metagegeven="Relatie eigenaar" onderwerp="metagegevens-relatie"/>
        <map metagegeven="Relatie doel" onderwerp="metagegevens-relatie"/>
        <map metagegeven="Generalisatie" onderwerp="metagegevens-relatie"/>

        <!-- globale referenties -->
        <map metagegeven="Package"/>
        <map metagegeven="Informatiemodel" onderwerp="informatiemodel"/>
        <map metagegeven="Domein package" onderwerp="domein-package"/>
        <map metagegeven="Domein packages" onderwerp="domein-package"/>
        <map metagegeven="Domeinen" onderwerp="domein-package"/>
        <!--ambigu: <map metagegeven="Domein" onderwerp="domein-package"/>-->
        <map metagegeven="View" onderwerp="view-package"/>
        <map metagegeven="Views" onderwerp="view-package"/>
        <map metagegeven="Extern package" onderwerp="extern-package"/>
        <map metagegeven="Externe packages" onderwerp="extern-package"/>
        <map metagegeven="Externe koppeling" onderwerp="metagegeven-externe-koppeling"/>
        <map metagegeven="Externe koppelingen" onderwerp="metagegeven-externe-koppeling"/>
        
        <map metagegeven="Extensie" onderwerp="extensie"/>
        <map metagegeven="Extensies" onderwerp="extensie"/>
        
        <map metagegeven="Objecttype" onderwerp="objecttype"/>
        <map metagegeven="Objecttypen" onderwerp="objecttype"/>
      
        <map metagegeven="Bron en doel" onderwerp="metagegeven-bron-en-doel"/>
   
        <map metagegeven="Attribuutsoort" onderwerp="attribuutsoort"/>
        <map metagegeven="Attribuutsoorten" onderwerp="attribuutsoort"/>
        
        <map metagegeven="Relatiesoort" onderwerp="relatiesoort"/>
        <map metagegeven="Relatiesoorten" onderwerp="relatiesoort"/>
        
        <map metagegeven="Keuze" onderwerp="keuzen"/>
        <map metagegeven="Keuzen" onderwerp="keuzen"/>
        <map metagegeven="Keuze tussen datatypes" onderwerp="keuze-datatypes"/>
        <map metagegeven="Keuze tussen attribuutsoorten" onderwerp="keuze-attribuutsoorten"/>
        <map metagegeven="Keuze tussen objecttypen" onderwerp="keuze-objecttypen"/>
        
        <map metagegeven="Gegevensgroep" onderwerp="gegevensgroep"/>
        <map metagegeven="Gegevensgroepen" onderwerp="gegevensgroep"/>
        <map metagegeven="Gegevensgroeptype" onderwerp="gegevensgroeptype"/>
        <map metagegeven="Gegevensgroeptypen" onderwerp="gegevensgroeptype"/>
        
        <map metagegeven="Datatype" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Datatypes" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Primitief datatype" onderwerp="primitief-datatype"/>
        <map metagegeven="Primitieve datatypes" onderwerp="primitief-datatype"/>
        <map metagegeven="Gestructureerd datatype" onderwerp="gestructureerd-datatype"/>
        <map metagegeven="Gestructureerde datatypes" onderwerp="gestructureerd-datatype"/>
        <map metagegeven="Data element" onderwerp="data-element"/>
        <map metagegeven="Data elementen" onderwerp="data-element"/>
        
        <map metagegeven="Interface" onderwerp="interface"/>
        <map metagegeven="Interfaces" onderwerp="interface"/>
        
        <map metagegeven="Enumeratie" onderwerp="enumeratie"/>
        <map metagegeven="Enumeraties" onderwerp="enumeratie"/>
        <map metagegeven="Codelijst" onderwerp="codelijst"/>
        <map metagegeven="Codelijsten" onderwerp="codelijst"/>
        <map metagegeven="Referentielijst" onderwerp="referentielijst"/>
        <map metagegeven="Referentielijsten" onderwerp="referentielijst"/>
        <map metagegeven="Referentie element" onderwerp="referentie-element"/>
        <map metagegeven="Referentie elementen" onderwerp="referentie-element"/>
        
        <map metagegeven="CharacterString" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Integer" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Real" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Decimal" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Date" onderwerp="eigenschappen-geven"/>
        <map metagegeven="DateTime" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Year" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Mongth" onderwerp="eigenschappen-geven"/>
        <map metagegeven="Day" onderwerp="eigenschappen-geven"/>
        <map metagegeven="URI" onderwerp="eigenschappen-geven"/>
        
    </xsl:variable>
    
    <xsl:variable name="metagegevens-hardcoded" as="element(metagegevens)">
        <!-- overgekopieerd uit /src/main/resources/xsl/MIMCompiler/MIM11-model.xml -->
      <metagegevens>
          <metagegeven>
             <naam>Aggregatietype</naam>
             <modelelement kardinaliteit="1">Externe koppeling</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Alias</naam>
             <modelelement kardinaliteit="0..1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="0..1">Codelijst</modelelement>
             <modelelement kardinaliteit="0..1">Externe koppeling</modelelement>
             <modelelement kardinaliteit="0..1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="0..1">Gegevensgroeptype</modelelement>
             <modelelement kardinaliteit="0..1">Generalisatie Datatypes</modelelement>
             <modelelement kardinaliteit="0..1">Objecttype</modelelement>
             <modelelement kardinaliteit="0..1">Referentie element</modelelement>
             <modelelement kardinaliteit="0..1">Referentielijst</modelelement>
             <modelelement kardinaliteit="0..1">Relatieklasse</modelelement>
             <modelelement kardinaliteit="0..1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatierol - Relatiesoort leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatiesoort - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Authentiek</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Begrip</naam>
             <modelelement kardinaliteit="0..*">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="0..*">Codelijst</modelelement>
             <modelelement kardinaliteit="0..*">Data element</modelelement>
             <modelelement kardinaliteit="0..*">Enumeratie</modelelement>
             <modelelement kardinaliteit="0..*">Externe koppeling</modelelement>
             <modelelement kardinaliteit="0..*">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="0..*">Gegevensgroeptype</modelelement>
             <modelelement kardinaliteit="0..*">Generalisatie Datatypes</modelelement>
             <modelelement kardinaliteit="0..*">Gestructureerd datatype</modelelement>
             <modelelement kardinaliteit="0..*">Keuze</modelelement>
             <modelelement kardinaliteit="0..*">Objecttype</modelelement>
             <modelelement kardinaliteit="0..*">Primitief datatype</modelelement>
             <modelelement kardinaliteit="0..*">Referentie element</modelelement>
             <modelelement kardinaliteit="0..*">Referentielijst</modelelement>
             <modelelement kardinaliteit="0..*">Relatieklasse</modelelement>
             <modelelement kardinaliteit="0..*">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="0..*">Relatierol - Relatiesoort leidend</modelelement>
             <modelelement kardinaliteit="0..*">Relatiesoort - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="0..*">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Code</naam>
             <modelelement kardinaliteit="0..1">Enumeratiewaarde</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Datum opname</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Codelijst</modelelement>
             <modelelement kardinaliteit="1">Externe koppeling</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroeptype</modelelement>
             <modelelement kardinaliteit="1">Gestructureerd datatype</modelelement>
             <modelelement kardinaliteit="1">Keuze</modelelement>
             <modelelement kardinaliteit="1">Objecttype</modelelement>
             <modelelement kardinaliteit="1">Primitief datatype</modelelement>
             <modelelement kardinaliteit="1">Referentie element</modelelement>
             <modelelement kardinaliteit="1">Referentielijst</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Definitie</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Codelijst</modelelement>
             <modelelement kardinaliteit="0..1">Data element</modelelement>
             <modelelement kardinaliteit="1">Enumeratie</modelelement>
             <modelelement kardinaliteit="0..1">Enumeratiewaarde</modelelement>
             <modelelement kardinaliteit="1">Extern</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="0..1">Gegevensgroeptype</modelelement>
             <modelelement kardinaliteit="1">Gestructureerd datatype</modelelement>
             <modelelement kardinaliteit="1">Informatiemodel</modelelement>
             <modelelement kardinaliteit="1">Keuze</modelelement>
             <modelelement kardinaliteit="1">Objecttype</modelelement>
             <modelelement kardinaliteit="0..1">Primitief datatype</modelelement>
             <modelelement kardinaliteit="1">Referentie element</modelelement>
             <modelelement kardinaliteit="1">Referentielijst</modelelement>
             <modelelement kardinaliteit="1">Relatieklasse</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatierol - Relatiesoort leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatiesoort - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
             <modelelement kardinaliteit="1">View</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Formeel patroon</naam>
             <modelelement kardinaliteit="0..1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="0..1">Data element</modelelement>
             <modelelement kardinaliteit="0..1">Gestructureerd datatype</modelelement>
             <modelelement kardinaliteit="0..1">Primitief datatype</modelelement>
             <modelelement kardinaliteit="0..1">Referentie element</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Gegevensgroeptype</naam>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Herkomst</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Codelijst</modelelement>
             <modelelement kardinaliteit="1">Extern</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="1">Gestructureerd datatype</modelelement>
             <modelelement kardinaliteit="1">Informatiemodel</modelelement>
             <modelelement kardinaliteit="1">Keuze</modelelement>
             <modelelement kardinaliteit="1">Objecttype</modelelement>
             <modelelement kardinaliteit="1">Primitief datatype</modelelement>
             <modelelement kardinaliteit="1">Referentielijst</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
             <modelelement kardinaliteit="1">View</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Herkomst definitie</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="0..1">Gegevensgroeptype</modelelement>
             <modelelement kardinaliteit="1">Objecttype</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Identificerend</naam>
             <modelelement kardinaliteit="0..1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="0..1">Referentie element</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Indicatie abstract object</naam>
             <modelelement kardinaliteit="1">Objecttype</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Indicatie afleidbaar</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Indicatie classificerend</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Indicatie formele historie</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Indicatie materiële historie</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Informatiedomein</naam>
             <modelelement kardinaliteit="1">Informatiemodel</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Informatiemodel type</naam>
             <modelelement kardinaliteit="1">Informatiemodel</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Kardinaliteit</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Data element</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="1">Referentie element</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Kwaliteit</naam>
             <modelelement kardinaliteit="0..1">Objecttype</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Lengte</naam>
             <modelelement kardinaliteit="0..1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="0..1">Data element</modelelement>
             <modelelement kardinaliteit="0..1">Primitief datatype</modelelement>
             <modelelement kardinaliteit="0..1">Referentie element</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Locatie</naam>
             <modelelement kardinaliteit="1">Codelijst</modelelement>
             <modelelement kardinaliteit="1">Extern</modelelement>
             <modelelement kardinaliteit="1">Referentielijst</modelelement>
             <modelelement kardinaliteit="1">View</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>MIM extensie</naam>
             <modelelement kardinaliteit="0..1">Informatiemodel</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>MIM taal</naam>
             <modelelement kardinaliteit="0..1">Informatiemodel</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>MIM versie</naam>
             <modelelement kardinaliteit="1">Informatiemodel</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Mogelijk geen waarde</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Naam</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Codelijst</modelelement>
             <modelelement kardinaliteit="1">Constraint</modelelement>
             <modelelement kardinaliteit="1">Data element</modelelement>
             <modelelement kardinaliteit="1">Domein</modelelement>
             <modelelement kardinaliteit="1">Enumeratie</modelelement>
             <modelelement kardinaliteit="1">Enumeratiewaarde</modelelement>
             <modelelement kardinaliteit="1">Extern</modelelement>
             <modelelement kardinaliteit="0..1">Externe koppeling</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="1">Gegevensgroeptype</modelelement>
             <modelelement kardinaliteit="0..1">Generalisatie Datatypes</modelelement>
             <modelelement kardinaliteit="1">Gestructureerd datatype</modelelement>
             <modelelement kardinaliteit="1">Informatiemodel</modelelement>
             <modelelement kardinaliteit="1">Keuze</modelelement>
             <modelelement kardinaliteit="1">Objecttype</modelelement>
             <modelelement kardinaliteit="1">Primitief datatype</modelelement>
             <modelelement kardinaliteit="1">Referentie element</modelelement>
             <modelelement kardinaliteit="1">Referentielijst</modelelement>
             <modelelement kardinaliteit="1">Relatieklasse</modelelement>
             <modelelement kardinaliteit="1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatierol - Relatiesoort leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatiesoort - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
             <modelelement kardinaliteit="1">View</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Patroon</naam>
             <modelelement kardinaliteit="0..1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="0..1">Data element</modelelement>
             <modelelement kardinaliteit="0..1">Gestructureerd datatype</modelelement>
             <modelelement kardinaliteit="0..1">Primitief datatype</modelelement>
             <modelelement kardinaliteit="0..1">Referentie element</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Populatie</naam>
             <modelelement kardinaliteit="0..1">Objecttype</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Relatie doel</naam>
             <modelelement kardinaliteit="1">Externe koppeling</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Relatie eigenaar</naam>
             <modelelement kardinaliteit="1">Externe koppeling</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Relatiemodelleringtype</naam>
             <modelelement kardinaliteit="1">Informatiemodel</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Specificatie formeel</naam>
             <modelelement kardinaliteit="0..1">Constraint</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Specificatie tekst</naam>
             <modelelement kardinaliteit="0..1">Constraint</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Subtype</naam>
             <modelelement kardinaliteit="1">Generalisatie Datatypes</modelelement>
             <modelelement kardinaliteit="1">Generalisatie Objecttypes</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Supertype</naam>
             <modelelement kardinaliteit="1">Generalisatie Datatypes</modelelement>
             <modelelement kardinaliteit="1">Generalisatie Objecttypes</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Toelichting</naam>
             <modelelement kardinaliteit="0..1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="0..1">Codelijst</modelelement>
             <modelelement kardinaliteit="0..1">Gegevensgroep</modelelement>
             <modelelement kardinaliteit="0..1">Gegevensgroeptype</modelelement>
             <modelelement kardinaliteit="0..1">Objecttype</modelelement>
             <modelelement kardinaliteit="0..1">Referentie element</modelelement>
             <modelelement kardinaliteit="0..1">Referentielijst</modelelement>
             <modelelement kardinaliteit="0..1">Relatierol - Relatierol leidend</modelelement>
             <modelelement kardinaliteit="0..1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Type</naam>
             <modelelement kardinaliteit="1">Attribuutsoort</modelelement>
             <modelelement kardinaliteit="1">Data element</modelelement>
             <modelelement kardinaliteit="1">Referentie element</modelelement>
          </metagegeven>
          <metagegeven>
             <naam>Unidirectioneel</naam>
             <modelelement kardinaliteit="1">Externe koppeling</modelelement>
             <modelelement kardinaliteit="1">Relatiesoort - Relatiesoort leidend</modelelement>
          </metagegeven>
      </metagegevens>
    </xsl:variable>

    <xsl:function name="pack:mode-primer" as="element(document)">
        <xsl:param name="document" as="element(document)"/>
        <xsl:sequence select="local:log('mode primer input',$document)"/>
        <xsl:apply-templates select="$document" mode="pack:mode-primer"/>
    </xsl:function>
    
    <!-- 
        in primer mode is een letop characterstring opgevat als een referentie naar metagegeven-* sectie in het hoofddocument
    -->
    <xsl:template match="span[@class = 'letop']" mode="pack:mode-primer">
        <xsl:variable name="metagegeven" select="normalize-space(.)"/>
        <xsl:variable name="ref-metagegeven" select="replace(normalize-space(lower-case($metagegeven)),'\s','-')"/>
        <a href="#metagegeven-{$ref-metagegeven}">
            <xsl:apply-templates select="node()" mode="#current"/>
        </a>
    </xsl:template>

    <xsl:template match="span[@class = 'quote']" mode="pack:mode-primer">
        <xsl:variable name="metagegeven" select="normalize-space(.)"/>
        <xsl:variable name="map" select="$maps[@metagegeven = $metagegeven]"/>
        <xsl:variable name="ref-onderwerp" select="$map/@onderwerp"/>
        <xsl:choose>
            <xsl:when test="$ref-onderwerp">
                <span class="more-info">
                    <a href="#{$ref-onderwerp}">
                        <xsl:apply-templates select="node()" mode="#current"/>
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="more-info">
                    <xsl:apply-templates select="node()" mode="#current"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="td"  mode="pack:mode-primer">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="pack:mode-primer"/>
            <xsl:variable name="is-metagegeven" select="ancestor::table/thead/tr/th[1]//text() = 'Metagegeven'"/>
            <xsl:variable name="col-nr" select="count(preceding-sibling::td) + 1"/>
            <xsl:choose>
                <xsl:when test="$is-metagegeven and $col-nr = 1">
                    <xsl:variable name="metagegeven" select="normalize-space(.)"/>
                    <xsl:variable name="ref-metagegeven" select="replace(normalize-space(lower-case($metagegeven)),'\s','-')"/>
                    <a id="metagegeven-{$ref-metagegeven}" origin="system"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:when>
                <xsl:when test="$is-metagegeven and $col-nr = 2">
                    <xsl:variable name="metagegeven" select="normalize-space(preceding-sibling::td)"/>
                    <xsl:variable name="map" select="$maps[@metagegeven = $metagegeven]"/>
                    <xsl:variable name="ref-onderwerp" select="$map/@onderwerp"/>
                    <xsl:variable name="title-onderwerp" select="$pages[@id = $ref-onderwerp]/title"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                    <xsl:if test="$ref-onderwerp and $title-onderwerp">
                        <div class="more-info">Zie ook: <a href="#{$ref-onderwerp}">{$title-onderwerp}</a>.</div>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        een link naar een internet locatie: altijd naar een eigen nieuw window 
    -->
    <xsl:template match="a[@href and not(starts-with(@href,'#'))]" mode="pack:mode-primer">
        <xsl:choose>
            <xsl:when test="starts-with(@href,'https://docs.geostandaarden.nl/mim/mim/')">
                <xsl:variable name="href" select="if (imf:get-xparm('documentor/prop-mimversion') = '1.1') then 'https://docs.geostandaarden.nl/mim/vv-st-mim-20200225/' else 'https://docs.geostandaarden.nl/mim/def-st-mim-20220217/'"/>
                <a href="{$href}" target="PRIMER">
                    <xsl:apply-templates select="node()" mode="#current"/>
                    <xsl:text> </xsl:text>
                    <span class="logo mim"/>
                </a>
            </xsl:when>
            <xsl:when test="starts-with(@href,'http')">
                <a href="{@href}" target="PRIMER">
                    <xsl:apply-templates select="node()" mode="#current"/>
                    <xsl:text> </xsl:text>
                    <span class="logo external"/>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="extension[@key = 'includebijlage' and @val = 'metagegevens']" mode="pack:mode-primer" priority="1">
        <xsl:variable name="stereos" as="xs:string+">
            <xsl:for-each-group select="$metagegevens-hardcoded/metagegeven/modelelement" group-by=".">
                <xsl:sort select="."/>
                <xsl:value-of select="."/>
            </xsl:for-each-group>
        </xsl:variable>
        <style xsl:expand-text="no"><![CDATA[
            .primer-metadata th {
                writing-mode: vertical-rl;
                text-orientation: mixed;
                position: -webkit-sticky; 
                position: sticky; 
                top: 0;
                transform: rotate(180deg);
                padding: 0.5em 0em;
            }
            .primer-metadata td:nth-child(1) {  
                background-color: lightgray;
            }
        ]]></style>
        <table class="primer-metadata">
            <tbody>
                <tr>
                    <th><!-- linksboven leeg --></th>
                    <xsl:for-each select="$stereos">
                        <th>{.}</th>
                    </xsl:for-each>
                </tr>
                <xsl:for-each select="$metagegevens-hardcoded/metagegeven">
                    <xsl:sort select="naam"/>
                    <xsl:variable name="cur-metagegeven" select="."/>
                    <tr>
                        <td>{$cur-metagegeven/naam}</td>
                        <xsl:for-each select="$stereos">
                            <xsl:variable name="element" select="$cur-metagegeven/modelelement[. = current()]"/>
                            <xsl:variable name="kard" select="tokenize($element/@kardinaliteit,'\.\.')"/>
                            <td>{if ($element) then (if ($kard[2] and $kard[1] = '1' or $kard[1] = '1') then 'V' else 'O') else ''}</td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template match="extension" mode="pack:mode-primer">
        <error loc="{ancestor-or-self::document[1]/@name}">Geen bekende extensie: {@key}</error>
    </xsl:template>
    
    <?x
    <!-- verzamel referenties die niet landen in de $maps -->
    <xsl:template match="span" mode="tally">
        <xsl:if test="@data-custom-style = 'quotechar' or @type = 'Quote'">
            <xsl:variable name="metagegeven" select="normalize-space(.)"/>
            <xsl:variable name="map" select="$maps[@metagegeven = $metagegeven]"/>
            <xsl:variable name="ref-onderwerp" select="$map/@onderwerp"/>
            <xsl:if test="empty($ref-onderwerp)">
                <xsl:value-of select="$metagegeven"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>        
    x?>
    
    <xsl:template match="node()|@*"  mode="pack:mode-primer">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>