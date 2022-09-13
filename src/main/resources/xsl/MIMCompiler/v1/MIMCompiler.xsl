<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor
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
  version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:imvert="http://www.imvertor.org/schema/system"
  xmlns:mim="http://www.geostandaarden.nl/mim/informatiemodel/v1" 
  xmlns:mim-ref="http://www.geostandaarden.nl/mim-ref/informatiemodel/v1"
  xmlns:mim-ext="http://www.geostandaarden.nl/mim-ext/informatiemodel/v1"
  xmlns:UML="omg.org/UML1.3" 
  xmlns:imf="http://www.imvertor.org/xsl/functions"    
  expand-text="yes" 
  exclude-result-prefixes="imvert imf fn UML">
  
  <!--
  This stylesheet converts a system.imvert.xml serialisation (Imvertor "embellish" format) to a 
  MIM format serialisation.      
  -->

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  
  <xsl:include href="MIM11Package.xsl"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="preprocess" on-no-match="shallow-copy"/>
  <xsl:mode name="postprocess" on-no-match="shallow-copy"/>
  <xsl:mode name="missing-metadata"/>

  <xsl:param name="generate-readable-ids" select="'true'" as="xs:string"/>
  <xsl:param name="generate-all-ids" select="'false'" as="xs:string"/>

  <xsl:variable name="runs-in-imvertor-context" select="not(system-property('install.dir') = '')" as="xs:boolean" static="yes"/>
  
  <xsl:import href="../../common/Imvert-common.xsl" use-when="$runs-in-imvertor-context"/>
  <xsl:import href="../../common/Imvert-common-derivation.xsl" use-when="$runs-in-imvertor-context"/>
  
  <xsl:variable name="mim11-model" as="document-node(element(mim11))">
    <xsl:sequence select="document('MIM11-model.xml')"/>  
  </xsl:variable>
  
  <xsl:variable name="stylesheet-code">MIMCOMPILER</xsl:variable>
  <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" use-when="$runs-in-imvertor-context"/>
  
  <xsl:variable name="stereotype-name-informatiemodel"         select="'INFORMATIEMODEL'"                      as="xs:string"/>
  <xsl:variable name="stereotype-name-attribuutsoort"          select="'ATTRIBUUTSOORT'"                       as="xs:string"/>
  <xsl:variable name="stereotype-name-codelijst"               select="'CODELIJST'"                            as="xs:string"/>
  <xsl:variable name="stereotype-name-data-element"            select="'DATA ELEMENT'"                         as="xs:string"/>
  <xsl:variable name="stereotype-name-datatype"                select="'DATATYPE'"                             as="xs:string"/>
  <xsl:variable name="stereotype-name-domein"                  select="'DOMEIN'"                               as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratie"              select="'ENUMERATIE'"                           as="xs:string"/>
  <xsl:variable name="stereotype-name-enumeratiewaarde"        select="'ENUMERATIEWAARDE'"                     as="xs:string"/>
  <xsl:variable name="stereotype-name-extern"                  select="'EXTERN'"                               as="xs:string"/>
  <xsl:variable name="stereotype-name-externe-koppeling"       select="'EXTERNE KOPPELING'"                    as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroep"           select="'GEGEVENSGROEP'"                        as="xs:string"/>
  <xsl:variable name="stereotype-name-gegevensgroeptype"       select="'GEGEVENSGROEPTYPE'"                    as="xs:string"/>
  <xsl:variable name="stereotype-name-generalisatie"           select="'GENERALISATIE'"                        as="xs:string"/>
  <xsl:variable name="stereotype-name-gestructureerd-datatype" select="'GESTRUCTUREERD DATATYPE'"              as="xs:string"/>
  <xsl:variable name="stereotype-name-keuze"                   select="'KEUZE'"                                as="xs:string"/>
  <xsl:variable name="stereotype-name-objecttype"              select="'OBJECTTYPE'"                           as="xs:string"/>
  <xsl:variable name="stereotype-name-primitief-datatype"      select="'PRIMITIEF DATATYPE'"                   as="xs:string"/>
  <xsl:variable name="stereotype-name-referentie-element"      select="'REFERENTIE ELEMENT'"                   as="xs:string"/>
  <xsl:variable name="stereotype-name-referentielijst"         select="'REFERENTIELIJST'"                      as="xs:string"/>
  <xsl:variable name="stereotype-name-relatieklasse"           select="'RELATIEKLASSE'"                        as="xs:string"/>
  <xsl:variable name="stereotype-name-relatierol"              select="'RELATIEROL'"                           as="xs:string"/>
  <xsl:variable name="stereotype-name-relatiesoort"            select="'RELATIESOORT'"                         as="xs:string"/>
  <xsl:variable name="stereotype-name-view"                    select="'VIEW'"                                 as="xs:string"/>
  <xsl:variable name="stereotype-name-interface"               select="'INTERFACE'"                            as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-datatypes"           select="'stereotype-name-union-datatypes'"      as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-attributes"          select="'stereotype-name-union-attributes'"     as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-associations"        select="'stereotype-name-union-associations'"   as="xs:string"/>
  <xsl:variable name="stereotype-id-keuze-element"             select="'stereotype-name-union-element'"        as="xs:string"/>
  <xsl:variable name="stereotype-id-union-by-attribute"        select="'stereotype-name-union-by-attribute'"   as="xs:string"/> <!-- KEUZE MET BETEKENIS -->
  <xsl:variable name="stereotype-id-union-for-attributes"      select="'stereotype-name-union-for-attributes'" as="xs:string"/> <!-- KEUZE ZONDER BETEKENIS -->
  <xsl:variable name="stereotype-id-union-association"         select="'stereotype-name-union-association'"    as="xs:string"/> <!-- KEUZE RELATIE -->
 
  <xsl:variable name="waardebereik-authentiek" select="('Authentiek', 'Basisgegeven', 'Wettelijk gegeven', 'Landelijk kerngegeven', 'Overig')" as="xs:string+"/>  
  <xsl:variable name="waardebereik-aggregatietype" select="('Compositie', 'Gedeeld', 'Geen')" as="xs:string+"/> 
  <xsl:variable name="mim-stereotype-names" select="($stereotype-name-attribuutsoort, $stereotype-name-codelijst, $stereotype-name-data-element, 
    $stereotype-name-datatype, $stereotype-name-domein, $stereotype-name-enumeratie, $stereotype-name-enumeratiewaarde, $stereotype-name-extern, 
    $stereotype-name-externe-koppeling, $stereotype-name-gegevensgroep, $stereotype-name-gegevensgroeptype, $stereotype-name-generalisatie, 
    $stereotype-name-gestructureerd-datatype, $stereotype-name-keuze, $stereotype-name-objecttype, $stereotype-name-primitief-datatype, 
    $stereotype-name-referentie-element, $stereotype-name-referentielijst, $stereotype-name-relatieklasse, $stereotype-name-relatierol, 
    $stereotype-name-relatiesoort, $stereotype-name-view, $stereotype-name-interface, $stereotype-name-informatiemodel)" as="xs:string+"/>
  <xsl:variable name="mim-stereotype-ids" select="($stereotype-id-keuze-datatypes, $stereotype-id-keuze-attributes, 
    $stereotype-id-keuze-associations, $stereotype-id-keuze-element, $stereotype-id-union-by-attribute, 
    $stereotype-id-union-for-attributes, $stereotype-id-union-association)" as="xs:string+"/>
  <xsl:variable name="mim-tagged-value-ids" select="('CFG-TV-INDICATIONAUTHENTIC', 'CFG-TV-CONCEPT', 'CFG-TV-DATERECORDED', 'CFG-TV-DEFINITION',
    'CFG-TV-FORMALPATTERN', 'CFG-TV-SOURCE', 'CFG-TV-SOURCEOFDEFINITION', 'CFG-TV-INDICATIONDERIVABLE', 'CFG-TV-INDICATIONCLASSIFICATION',
    'CFG-TV-INDICATIONFORMALHISTORY', 'CFG-TV-INDICATIONMATERIALHISTORY', 'CFG-TV-QUALITY', 'CFG-TV-LENGTH','CFG-TV-DATALOCATION',
    'CFG-TV-VOIDABLE', 'CFG-TV-PATTERN', 'CFG-TV-POPULATION', 'CFG-TV-DATERECORDED', 'CFG-TV-DESCRIPTION', 'CFG-TV-IMDOMAIN',
    'CFG-TV-IMTYPE', 'CFG-TV-IMRELATIONMODELINGTYPE', 'CFG-TV-MIMVERSION', 'CFG-TV-MIMEXTENSION', 'CFG-TV-MIMLANGUAGE')" as="xs:string+"/>
  
  <!-- Include MIM11 package constructs (if necessary) and convert EA identifiers to "human readable" identifiers: -->
  <xsl:variable name="preprocessed-xml" as="document-node()">
    <xsl:apply-templates select="." mode="preprocess"/>  
  </xsl:variable>
  
  <xsl:variable name="packages" select="$preprocessed-xml//imvert:package" as="element(imvert:package)*"/>
  <xsl:variable name="classes" select="$preprocessed-xml//imvert:class" as="element(imvert:class)*"/>
  <xsl:variable name="attributes" select="$preprocessed-xml//imvert:attribute" as="element(imvert:attribute)*"/>
  <xsl:variable name="associations" select="$preprocessed-xml//imvert:association" as="element(imvert:association)*"/>
  <xsl:variable name="specified-relatiemodelleringstype" select="imf:tagged-values-not-traced($preprocessed-xml/imvert:packages, 'CFG-TV-IMRELATIONMODELINGTYPE')" as="xs:string?"/>
  <xsl:variable name="relatiemodelleringtype" select="if ($specified-relatiemodelleringstype) then $specified-relatiemodelleringstype else 'Relatiesoort leidend'" as="xs:string"/>
  
  <xsl:variable name="mim11-primitive-datatypes-lc-names" select="for $n in $mim11-package/imvert:class/imvert:name/@original return lower-case($n)" as="xs:string+"/>
  
  <xsl:key name="key-imvert-construct-by-id" match="imvert:*[imvert:id]" use="imvert:id"/>
  <xsl:key name="key-mim-construct-by-id" match="*[@id]" use="@id"/>
  <xsl:key name="key-mim-domain-by-xlink" match="mim:Domein|mim:View|mim:Extern" use="for $a in .//mim-ref:*/@xlink:href return substring($a, 2)"/>
  <xsl:key name="key-metagegeven-by-name" match="modelelementen/modelelement" use="lower-case(naam)"/>
  
  <xsl:template match="/">
    <xsl:if test="imf:boolean-value(imf:get-xparam('cli/nativescalars', 'no'))">
      <xsl:sequence select="imf:message(., 'WARNING', 'Please run the job with &quot;nativescalars = no&quot; when serializing to MIM', ())"/>
    </xsl:if>
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
  
  <xsl:template match="@id[string-length(.) ge 32]" mode="postprocess">
    <xsl:attribute name="id">
      <xsl:choose>
        <xsl:when test="$generate-readable-ids = 'true'">
          <xsl:value-of select="imf:create-id(..)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="imf:clean-id(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@xlink:href[string-length(.) ge 32]" mode="postprocess">
    <xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
      <xsl:choose>
        <xsl:when test="$generate-readable-ids = 'true'">
          <xsl:value-of select="'#' || imf:create-id(key('key-mim-construct-by-id', substring(., 2), root()))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'#' || imf:clean-id(key('key-mim-construct-by-id', substring(., 2), root())/@id)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="/imvert:packages">
    <xsl:variable name="intermediate-result" as="document-node()">
      <xsl:document>
        <xsl:comment>=========================================================================================
Dit bestand bevat een XML serialisatie van een informatiemodel dat is gemodelleerd volgens de 
"Metamodel Informatie Modellering (MIM)" standaard versie 1.1.

NB. Het formaat van deze XML serialisatie is nog in ontwikkeling en zal pas definitief worden 
gemaakt na het verschijnen van volgende versie van de MIM standaard. De kans is dus groot dat 
er de komende tijd wijzigingen zullen worden doorgevoerd in dit formaat.

Zie: https://docs.geostandaarden.nl/mim/mim/ voor de laatste versie van de standaard.
=============================================================================================</xsl:comment>
        <mim:Informatiemodel
          xmlns:mim="http://www.geostandaarden.nl/mim/informatiemodel/v1" 
          xmlns:mim-ref="http://www.geostandaarden.nl/mim-ref/informatiemodel/v1"
          xmlns:mim-ext="http://www.geostandaarden.nl/mim-ext/informatiemodel/v1"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          
          <xsl:attribute name="schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://www.geostandaarden.nl/mim/informatiemodel/v1 xsd/MIMFORMAT_Mim_v1.xsd</xsl:attribute>
          
          <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
          
          <xsl:call-template name="genereer-metagegevens">
            <xsl:with-param name="modelelement-type" as="xs:string">Informatiemodel</xsl:with-param>
            <xsl:with-param name="modelelement-name" as="xs:string">Informatiemodel</xsl:with-param>
          </xsl:call-template>
          
          <xsl:where-populated>
            <mim:packages>
              <xsl:apply-templates select="$packages[imvert:stereotype = $stereotype-name-domein]">
                <xsl:sort select="imvert:stereotype"/>
                <xsl:sort select="imvert:name"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="$packages[imvert:stereotype = $stereotype-name-view]">
                <xsl:sort select="imvert:stereotype"/>
                <xsl:sort select="imvert:name"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="$packages[imvert:stereotype = $stereotype-name-extern]">
                <xsl:sort select="imvert:name"/>
              </xsl:apply-templates>     
            </mim:packages>
          </xsl:where-populated>
          <xsl:call-template name="extensieKenmerken"/>
        </mim:Informatiemodel>    
      </xsl:document>
    </xsl:variable>
    <xsl:apply-templates select="$intermediate-result" mode="postprocess"/>
    <!--
    <xsl:sequence select="$intermediate-result" />
    -->
  </xsl:template>
  
  <xsl:template name="domein-of-view">
    <xsl:where-populated>
      <mim:datatypen>
        <xsl:apply-templates select="
          imvert:class[imvert:stereotype = $stereotype-name-gestructureerd-datatype],
          imvert:class[imvert:stereotype = $stereotype-name-primitief-datatype],
          imvert:class[imvert:stereotype = $stereotype-name-enumeratie],
          imvert:class[imvert:stereotype = $stereotype-name-codelijst],
          imvert:class[imvert:stereotype = $stereotype-name-referentielijst]">
          <xsl:sort select="imvert:name"/>
        </xsl:apply-templates>
      </mim:datatypen>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:objecttypen>
        <xsl:apply-templates select="imvert:class[imvert:stereotype = $stereotype-name-objecttype]">
          <xsl:sort select="imvert:name"/>
        </xsl:apply-templates>
      </mim:objecttypen>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:gegevensgroeptypen>
        <xsl:apply-templates select="imvert:class[imvert:stereotype = $stereotype-name-gegevensgroeptype]">
          <xsl:sort select="imvert:name"/>
        </xsl:apply-templates>
      </mim:gegevensgroeptypen>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:keuzen>
        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ($stereotype-id-keuze-datatypes, $stereotype-id-keuze-attributes, $stereotype-id-keuze-associations)]">
          <xsl:sort select="imvert:name"/>
        </xsl:apply-templates>
      </mim:keuzen>
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:constructies>
        <xsl:apply-templates select="imvert:class[imf:is-not-mim-construct(.)]">
          <xsl:sort select="imvert:name"/>
        </xsl:apply-templates>
      </mim:constructies>
    </xsl:where-populated>
    <xsl:call-template name="extensieKenmerken"/>
  </xsl:template>
  
  <!-- mim:Domein -->
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-domein]">
    <mim:Domein>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="domein-of-view"/>
    </mim:Domein>
  </xsl:template>

  <!-- mim:View -->
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-view]">
    <mim:View>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="domein-of-view"/>
    </mim:View>
  </xsl:template>

  <!-- mim:Objectype -->
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-objecttype]">
    <mim:Objecttype>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="supertype">
        <xsl:with-param name="context" select="." as="element()"/>
      </xsl:call-template>
      <xsl:call-template name="attribuutsoorten"/>
      <xsl:call-template name="gegevensgroepen"/>
      <xsl:call-template name="relatiesoorten"/>
      <xsl:call-template name="externeKoppelingen"/>
      <xsl:call-template name="keuzeAttribuutsoorten"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Objecttype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gegevensgroeptype]">
    <mim:Gegevensgroeptype>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="attribuutsoorten"/>
      <xsl:call-template name="gegevensgroepen"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Gegevensgroeptype>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[not(imvert:stereotype) or (imvert:stereotype = $stereotype-name-attribuutsoort) or (imvert:stereotype/@id = $stereotype-id-keuze-element)]">
    <mim:Attribuutsoort>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
      <xsl:call-template name="genereer-metagegevens">
        <xsl:with-param name="modelelement-type" as="xs:string">Attribuutsoort</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Attribuutsoort>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-gegevensgroep]">
    <mim:Gegevensgroep>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Gegevensgroep>
  </xsl:template>
  
  <xsl:template match="imvert:association[(empty($relatiemodelleringtype) or lower-case($relatiemodelleringtype) = 'relatiesoort leidend') and 
    (imvert:stereotype = $stereotype-name-relatiesoort or imvert:stereotype/@id = $stereotype-id-union-association) and not(imf:association-is-keuze-attributes(.))]">
    <mim:RelatiesoortRelatiesoortLeidend>
      <xsl:call-template name="generate-relatiesoort">
        <xsl:with-param name="soort-type" as="xs:string">Relatiesoort - Relatiesoort leidend</xsl:with-param>
        <xsl:with-param name="rol-type" as="xs:string">Relatierol - Relatiesoort leidend</xsl:with-param>
      </xsl:call-template>
    </mim:RelatiesoortRelatiesoortLeidend>
  </xsl:template>
  
  <xsl:template match="imvert:association[(lower-case($relatiemodelleringtype) = 'relatierol leidend') and 
    (imvert:stereotype = $stereotype-name-relatiesoort or imvert:stereotype/@id = $stereotype-id-union-association) and not(imf:association-is-keuze-attributes(.))]">
    <mim:RelatiesoortRelatierolLeidend>
      <xsl:call-template name="generate-relatiesoort">
        <xsl:with-param name="soort-type" as="xs:string">Relatiesoort - Relatierol leidend</xsl:with-param>
        <xsl:with-param name="rol-type" as="xs:string">Relatierol - Relatierol leidend</xsl:with-param>
      </xsl:call-template>
    </mim:RelatiesoortRelatierolLeidend>
  </xsl:template>
  
  <xsl:template name="generate-relatiesoort">
    <xsl:param name="soort-type" as="xs:string"/>
    <xsl:param name="rol-type" as="xs:string"/>
    <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
    <xsl:call-template name="genereer-metagegevens">
      <xsl:with-param name="modelelement-type" select="$soort-type" as="xs:string"/>
    </xsl:call-template>
    <xsl:where-populated>
      <mim:relatierolBron>
        <xsl:where-populated>
          <mim:RelatierolBron>
            <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
            <xsl:for-each select="imvert:source">
              <xsl:call-template name="genereer-metagegevens">
                <xsl:with-param name="modelelement-type" select="$rol-type" as="xs:string"/>
                <xsl:with-param name="modelelement-name" select="imvert:role" as="xs:string?"/>
              </xsl:call-template>  
            </xsl:for-each>  
          </mim:RelatierolBron>  
        </xsl:where-populated>
      </mim:relatierolBron>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:relatierolDoel>
        <xsl:where-populated>
          <mim:RelatierolDoel>
            <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
            <xsl:for-each select="imvert:target">
              <xsl:call-template name="genereer-metagegevens">
                <xsl:with-param name="modelelement-type" select="$rol-type" as="xs:string"/>
                <xsl:with-param name="modelelement-name" select="imvert:role" as="xs:string?"/>
              </xsl:call-template>  
            </xsl:for-each>
          </mim:RelatierolDoel>  
        </xsl:where-populated>
      </mim:relatierolDoel>  
    </xsl:where-populated>
    <xsl:where-populated>
      <mim:relatieklasse>
        <xsl:where-populated>
          <xsl:if test="imf:association-is-relatie-klasse(.)">
            <xsl:apply-templates select="key('key-imvert-construct-by-id', imvert:association-class/imvert:type-id)"/>
          </xsl:if>  
        </xsl:where-populated>
      </mim:relatieklasse>
    </xsl:where-populated>
    <xsl:call-template name="extensieKenmerken"/>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-relatieklasse]">
    <mim:Relatieklasse>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="attribuutsoorten"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Relatieklasse>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-gestructureerd-datatype]">
    <mim:GestructureerdDatatype>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="supertype">
        <xsl:with-param name="context" select="." as="element()"/>
      </xsl:call-template>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:where-populated>
        <mim:dataElementen>
          <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-data-element]">
            <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          </xsl:apply-templates>   
        </mim:dataElementen>  
      </xsl:where-populated>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:GestructureerdDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-primitief-datatype]">
    <mim:PrimitiefDatatype>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="supertype">
        <xsl:with-param name="context" select="." as="element()"/>
      </xsl:call-template>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:PrimitiefDatatype>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-enumeratie]">
    <mim:Enumeratie>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="supertype">
        <xsl:with-param name="context" select="." as="element()"/>
      </xsl:call-template>
      <xsl:call-template name="genereer-metagegevens"/>
      <mim:enumeratiewaarden>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-enumeratiewaarde]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
        </xsl:apply-templates>   
      </mim:enumeratiewaarden>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Enumeratie>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-codelijst]">
    <mim:Codelijst>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="supertype">
        <xsl:with-param name="context" select="." as="element()"/>
      </xsl:call-template>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Codelijst>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-referentielijst]">
    <mim:Referentielijst>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="supertype">
        <xsl:with-param name="context" select="." as="element()"/>
      </xsl:call-template>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:where-populated>
        <mim:referentieElementen>
          <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-referentie-element]">
            <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          </xsl:apply-templates>   
        </mim:referentieElementen>  
      </xsl:where-populated>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Referentielijst>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-data-element]">
    <mim:DataElement>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:DataElement>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-enumeratiewaarde]">
    <mim:Enumeratiewaarde>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Enumeratiewaarde>
  </xsl:template>
  
  <xsl:template match="imvert:attribute[imvert:stereotype = $stereotype-name-referentie-element]">
    <mim:ReferentieElement>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:ReferentieElement>
  </xsl:template>
  
  <!--
  <xsl:template match="imvert:supertype[imvert:stereotype = $stereotype-name-generalisatie]">
    <mim:Generalisatie>
      <xsl:call-template name="datumOpname"/>
      <xsl:call-template name="supertype"/>
      <xsl:call-template name="verwijstNaarGenerieke"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Generalisatie>
  </xsl:template>
  -->
  
  <!-- mim:Keuze -->
  <xsl:template match="imvert:class[imvert:stereotype/@id = ($stereotype-id-keuze-attributes, $stereotype-id-keuze-datatypes, $stereotype-id-keuze-associations)]">
    <mim:Keuze>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="genereer-metagegevens">
        <xsl:with-param name="modelelement-type" select="'Keuze'" as="xs:string"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="imvert:stereotype/@id = $stereotype-id-keuze-attributes">
          <mim:attribuutsoorten>
            <xsl:apply-templates select="imvert:attributes/imvert:attribute">
              <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
            </xsl:apply-templates>
          </mim:attribuutsoorten>
        </xsl:when>
        <xsl:when test="imvert:stereotype/@id = $stereotype-id-keuze-datatypes">
          <mim:datatypen>
            <xsl:for-each select="imvert:attributes/imvert:attribute">
              <xsl:call-template name="process-datatype"/>
            </xsl:for-each>
          </mim:datatypen>
        </xsl:when>
        <xsl:when test="imvert:stereotype/@id = $stereotype-id-keuze-associations">
          <mim:relatiedoelen>
            <xsl:for-each select="imvert:associations/imvert:association">
              <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
              <mim:Relatiedoel>
                <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
                <xsl:call-template name="create-ref-element">
                  <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
                </xsl:call-template> 
              </mim:Relatiedoel>
            </xsl:for-each>
          </mim:relatiedoelen>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Keuze>  
  </xsl:template> 
  
  <xsl:template match="imvert:association[imvert:stereotype = $stereotype-name-externe-koppeling]">
    <mim:ExterneKoppeling>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:ExterneKoppeling>
  </xsl:template>
  
  <xsl:template match="imvert:package[imvert:stereotype = $stereotype-name-extern]">
    <mim:Extern>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="genereer-metagegevens"/>
      <xsl:where-populated>
        <mim:interfaces>
          <xsl:apply-templates select="imvert:class[imvert:stereotype = $stereotype-name-interface and imvert:id]">
            <xsl:sort select="imvert:name"/>
          </xsl:apply-templates>
        </mim:interfaces>  
      </xsl:where-populated>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Extern>
  </xsl:template>
  
  <xsl:template match="imvert:class[imvert:stereotype = $stereotype-name-interface]">
    <mim:Interface>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <xsl:call-template name="naam">
        <xsl:with-param name="context" select="." as="element()"/>
      </xsl:call-template>
      <xsl:call-template name="extensieKenmerken"/>
    </mim:Interface>
  </xsl:template>
  
  <xsl:template match="(imvert:class|imvert:attribute|imvert:association)[imf:is-not-mim-construct(.)]">
    <mim-ext:Constructie>
      <xsl:sequence select="imf:generate-id-attr(imvert:id, true())"/>
      <mim-ext:constructietype>{imvert:stereotype}</mim-ext:constructietype> 
      <xsl:call-template name="genereer-metagegevens">
        <xsl:with-param name="modelelement-type" select="'Extensie'" as="xs:string"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="self::imvert:class">
          <!--
          <xsl:call-template name="supertype">
            <xsl:with-param name="context" select="." as="element()"/>
          </xsl:call-template>
          -->
          <xsl:where-populated>
            <mim-ext:bevat>
              <xsl:apply-templates select="imvert:attributes/imvert:attribute|imvert:associations/imvert:association"/>
            </mim-ext:bevat>  
          </xsl:where-populated>
        </xsl:when>
        <xsl:when test="self::imvert:attribute">
          <xsl:call-template name="type">
            <xsl:with-param name="context" select="." as="element()"/>
          </xsl:call-template>
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
  
  <!-- START Metagegevens -->
  <xsl:template match="metagegeven[. = 'Aggregatietype']">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="value" select="(imf:capitalize-first($context/imvert:aggregation), 'Geen')[1]" as="xs:string?"/>
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
    <mim:aggregatietype>{$mapped-value}</mim:aggregatietype>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Alias']">
    <xsl:param name="context" as="element()"/>
    <mim:alias>{$context/imvert:alias}</mim:alias>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Authentiek']">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="value" select="imf:capitalize-first(imf:tagged-values($context, 'CFG-TV-INDICATIONAUTHENTIC')[1])" as="xs:string?"/>
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
  
  <xsl:template match="metagegeven[. = 'Begrip']">
    <xsl:param name="context" as="element()"/>
    <xsl:for-each select="imf:tagged-values($context, 'CFG-TV-CONCEPT')">
      <mim:begrip>{.}</mim:begrip>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Code']">
    <xsl:param name="context" as="element()"/>
    <mim:code>{$context/imvert:name}</mim:code>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Datum opname']">
    <xsl:param name="context" as="element()"/>
    <mim:datumOpname>{imf:tagged-values($context, 'CFG-TV-DATERECORDED')}</mim:datumOpname>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Definitie']">
    <xsl:param name="context" as="element()"/>
    <mim:definitie>
      <xsl:sequence select="imf:tagged-values($context, 'CFG-TV-DEFINITION')"/>
    </mim:definitie>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Formeel patroon']">
    <xsl:param name="context" as="element()"/>
    <mim:formeelPatroon>{imf:tagged-values($context, 'CFG-TV-FORMALPATTERN')}</mim:formeelPatroon>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Gegevensgroeptype']">
    <xsl:param name="context" as="element()"/>
    <mim:gegevensgroeptype>
      <xsl:for-each select="$context">
        <xsl:call-template name="process-datatype"/>  
      </xsl:for-each>
    </mim:gegevensgroeptype>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Herkomst']">
    <xsl:param name="context" as="element()"/>
    <mim:herkomst>{imf:tagged-values($context, 'CFG-TV-SOURCE')}</mim:herkomst>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Herkomst definitie']">
    <xsl:param name="context" as="element()"/>
    <mim:herkomstDefinitie>{imf:tagged-values($context, 'CFG-TV-SOURCEOFDEFINITION')}</mim:herkomstDefinitie>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Identificerend']">
    <xsl:param name="context" as="element()"/>
    <mim:identificerend>{imf:mim-boolean($context/imvert:is-id)}</mim:identificerend>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Indicatie abstract object']">
    <xsl:param name="context" as="element()"/>
    <mim:indicatieAbstractObject>{imf:mim-boolean($context/imvert:abstract)}</mim:indicatieAbstractObject>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Indicatie afleidbaar']">
    <xsl:param name="context" as="element()"/>
    <mim:indicatieAfleidbaar>{imf:mim-boolean($context/imvert:is-value-derived)}</mim:indicatieAfleidbaar>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Indicatie classificerend']">
    <xsl:param name="context" as="element()"/>
    <mim:indicatieClassificerend>{imf:mim-boolean(imf:tagged-values($context, 'CFG-TV-INDICATIONCLASSIFICATION'))}</mim:indicatieClassificerend>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Indicatie formele historie']">
    <xsl:param name="context" as="element()"/>
    <mim:indicatieFormeleHistorie>{(imf:mim-boolean(imf:tagged-values($context, 'CFG-TV-INDICATIONFORMALHISTORY')[1]))}</mim:indicatieFormeleHistorie>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Indicatie materiële historie']">
    <xsl:param name="context" as="element()"/>
    <mim:indicatieMaterieleHistorie>{(imf:mim-boolean(imf:tagged-values($context, 'CFG-TV-INDICATIONMATERIALHISTORY')[1]))}</mim:indicatieMaterieleHistorie>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Informatiedomein']">
    <xsl:param name="context" as="element()"/>
    <mim:informatiedomein>{imf:tagged-values-not-traced($context, 'CFG-TV-IMDOMAIN')}</mim:informatiedomein>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Informatiemodel type']">
    <xsl:param name="context" as="element()"/>
    <mim:informatiemodeltype>{imf:tagged-values-not-traced($context, 'CFG-TV-IMTYPE')}</mim:informatiemodeltype>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Kardinaliteit']">
    <xsl:param name="context" as="element()"/>
    <mim:kardinaliteit>{imf:kardinaliteit($context/imvert:min-occurs, $context/imvert:max-occurs)}</mim:kardinaliteit>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Kwaliteit']">
    <xsl:param name="context" as="element()"/>
    <mim:kwaliteit>{imf:tagged-values($context, 'CFG-TV-QUALITY')}</mim:kwaliteit>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Lengte']">
    <xsl:param name="context" as="element()"/>
    <mim:lengte>{imf:tagged-values($context, 'CFG-TV-LENGTH')}</mim:lengte>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Locatie']">
    <xsl:param name="context" as="element()"/>
    <mim:locatie>{imf:tagged-values($context, 'CFG-TV-DATALOCATION')}</mim:locatie>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'MIM extensie']">
    <xsl:param name="context" as="element()"/>
    <mim:MIMExtensie>{imf:tagged-values-not-traced($context, 'CFG-TV-MIMEXTENSION')}</mim:MIMExtensie>  
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'MIM taal']">
    <xsl:param name="context" as="element()"/>
    <mim:MIMTaal>{imf:tagged-values-not-traced($context, 'CFG-TV-MIMLANGUAGE')}</mim:MIMTaal> 
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'MIM versie']">
    <xsl:param name="context" as="element()"/>
    <mim:MIMVersie>{imf:tagged-values-not-traced($context, 'CFG-TV-MIMVERSION')}</mim:MIMVersie>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Mogelijk geen waarde']">
    <xsl:param name="context" as="element()"/>
    <mim:mogelijkGeenWaarde>{imf:mim-boolean(imf:tagged-values($context, 'CFG-TV-VOIDABLE')[1])}</mim:mogelijkGeenWaarde>
  </xsl:template>
  
  <xsl:template name="naam" match="metagegeven[. = 'Naam']">
    <xsl:param name="context" as="element()"/>
    <mim:naam>
      <xsl:choose>
        <xsl:when test="$context/self::imvert:packages">
          <xsl:value-of select="normalize-space($context/imvert:model-id)"/>
        </xsl:when>
        <xsl:when test="$context/(self::imvert:source|self::imvert:target)">
          <xsl:value-of select="$context/imvert:role/@original"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="imf:name($context)"/>
        </xsl:otherwise>
      </xsl:choose>
    </mim:naam>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Patroon']">
    <xsl:param name="context" as="element()"/>
    <mim:patroon>{imf:tagged-values($context, 'CFG-TV-PATTERN')}</mim:patroon>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Populatie']">
    <xsl:param name="context" as="element()"/>
    <mim:populatie>{imf:tagged-values($context, 'CFG-TV-POPULATION')}</mim:populatie>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Relatie doel']">
    <xsl:param name="context" as="element()"/>
    <mim:doel>
      <xsl:for-each select="$context">
        <xsl:call-template name="create-ref-element">
          <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
        </xsl:call-template>  
      </xsl:for-each>
    </mim:doel>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Relatie eigenaar']">
    <xsl:param name="context" as="element()"/>
    <!-- Via embedding -->
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Relatiemodelleringtype']">
    <xsl:param name="context" as="element()"/>
    <mim:relatiemodelleringtype>{$relatiemodelleringtype}</mim:relatiemodelleringtype>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Specificatie formeel']">
    <xsl:param name="context" as="element()"/>
    <!-- TODO -->
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Specificatie tekst']">
    <xsl:param name="context" as="element()"/>
    <!-- TODO -->
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Subtype']">
    <xsl:param name="context" as="element()"/>
    <!-- Via embedding -->
  </xsl:template>
  
  <xsl:template name="supertype" match="metagegeven[. = 'Supertype']">
    <xsl:param name="context" as="element()"/>
    <xsl:for-each select="$context[imvert:supertype]">
      <xsl:variable name="first-supertype" select="key('key-imvert-construct-by-id', (imvert:supertype/imvert:type-id)[1])" as="element()"/>
      <xsl:choose>
        <xsl:when test="$first-supertype/imvert:stereotype = $stereotype-name-objecttype">
          <mim:supertypes>
            <xsl:for-each select="imvert:supertype">
              <mim:GeneralisatieObjecttypes>
                <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
                <mim:supertype>
                  <xsl:choose>
                    <xsl:when test="not(imvert:stereotype) or (imvert:stereotype = $stereotype-name-generalisatie)">
                      <xsl:call-template name="create-ref-element">
                        <xsl:with-param name="ref-id" select="imvert:type-id"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <mim-ext:Constructie>
                        <mim-ext:constructietype>{imvert:stereotype}</mim-ext:constructietype>
                        <xsl:call-template name="create-ref-element">
                          <xsl:with-param name="ref-id" select="imvert:type-id"/>
                        </xsl:call-template>
                      </mim-ext:Constructie>
                    </xsl:otherwise>
                  </xsl:choose>
                </mim:supertype>
                <xsl:call-template name="extensieKenmerken"/>
              </mim:GeneralisatieObjecttypes>
            </xsl:for-each>
          </mim:supertypes>
        </xsl:when>
        <xsl:otherwise>
          <mim:supertype>
            <xsl:for-each select="imvert:supertype">
              <mim:GeneralisatieDatatypes>
                <xsl:sequence select="imf:generate-id-attr(imvert:id, false())"/>
                <xsl:call-template name="genereer-metagegevens">
                  <xsl:with-param name="modelelement-type" as="xs:string">Generalisatie Datatypes</xsl:with-param>
                  <xsl:with-param name="metagegevens-to-skip" select="'Supertype'" as="xs:string"/>
                </xsl:call-template>
                <mim:supertype>
                  <xsl:call-template name="create-ref-element">
                    <xsl:with-param name="ref-id" select="imvert:type-id"/>
                  </xsl:call-template>
                </mim:supertype>
                <xsl:call-template name="extensieKenmerken"/>
              </mim:GeneralisatieDatatypes>
            </xsl:for-each>
          </mim:supertype>
        </xsl:otherwise>
      </xsl:choose>  
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Toelichting']">
    <xsl:param name="context" as="element()"/>
    <mim:toelichting>
      <xsl:sequence select="imf:tagged-values($context, 'CFG-TV-DESCRIPTION')"/>
    </mim:toelichting>
  </xsl:template>
  
  <xsl:template name="type" match="metagegeven[. = 'Type']">
    <xsl:param name="context" as="element()"/>
    <mim:type>
      <xsl:for-each select="$context">
        <xsl:call-template name="process-datatype"/>  
      </xsl:for-each>
    </mim:type>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Unidirectioneel']">
    <xsl:param name="context" as="element()"/>
    <mim:unidirectioneel>{imf:mim-boolean(xs:string($context/imvert:source/imvert:navigable = 'false'))}</mim:unidirectioneel>
  </xsl:template>
  
  <xsl:template match="metagegeven[. = 'Unieke aanduiding']">
    <xsl:param name="context" as="element()"/>
    <!-- TODO -->
  </xsl:template>
  
  <xsl:template match="mim:*" mode="missing-metadata">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:comment> FOUT: De waarde voor dit verplichte metagegeven is niet gespecificeerd in het model </xsl:comment>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="genereer-metagegevens">
    <xsl:param name="modelelement-type" select="imvert:stereotype" as="xs:string*"/>
    <xsl:param name="modelelement-name" select="imvert:name" as="xs:string?"/>
    <xsl:param name="metagegevens-to-skip" select="()" as="xs:string*"/>
    <xsl:variable name="modelelement" select="key('key-metagegeven-by-name', for $a in $modelelement-type return lower-case($a), $mim11-model)" as="element(modelelement)"/>
    <xsl:variable name="context" select="." as="element()"/>
    <xsl:for-each select="$modelelement/metagegeven[not(. = $metagegevens-to-skip)]">
      <xsl:variable name="metagegeven" as="element()?">
        <xsl:apply-templates select=".">
          <xsl:with-param name="context" select="$context" as="element()"/>
        </xsl:apply-templates>  
      </xsl:variable>
      <xsl:variable name="kardinaliteit" select="@kardinaliteit" as="xs:string"/>
      <xsl:choose>
        <xsl:when test="empty($metagegeven)"/>
        <xsl:when test="normalize-space($metagegeven) or $metagegeven/*">
          <xsl:sequence select="$metagegeven"/>
        </xsl:when>
        <xsl:when test="starts-with($kardinaliteit, '1')">
          <!--
          <xsl:sequence select="imf:message(., 'WARNING', 'Modelelement [1] of type [2] is missing required metadata [3]', ($modelelement-name, $modelelement-type, .))"/>
          -->
          <xsl:apply-templates select="$metagegeven" mode="missing-metadata"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Skip, optional element -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <!-- EINDE Metagegevens -->
  
  <xsl:template name="relatiesoorten">
    <xsl:where-populated>
      <mim:relatiesoorten>
        <xsl:for-each select="imvert:associations/imvert:association[imvert:stereotype = $stereotype-name-relatiesoort]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
          <xsl:apply-templates select="."/>
          <?x
          <mim:RelatierolBron>
            <mim:id>{imvert:name}</mim:id> <!-- TODO: Slaat dit ergens op? -->
          </mim:RelatierolBron>
          ?>
        </xsl:for-each>  
      </mim:relatiesoorten>
    </xsl:where-populated>
  </xsl:template>

  <xsl:template name="externeKoppelingen">
    <xsl:where-populated>
      <mim:externeKoppelingen>
        <xsl:apply-templates select="imvert:associations/imvert:association[imvert:stereotype = $stereotype-name-externe-koppeling]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>  
        </xsl:apply-templates>
      </mim:externeKoppelingen>  
    </xsl:where-populated>
  </xsl:template>
    
  <xsl:template name="attribuutsoorten">
    <xsl:where-populated>
      <mim:attribuutsoorten>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-attribuutsoort]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>
        </xsl:apply-templates>
      </mim:attribuutsoorten>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="gegevensgroepen">
    <xsl:where-populated>
      <mim:gegevensgroepen>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = $stereotype-name-gegevensgroep]">
          <xsl:sort select="imvert:position" order="ascending" data-type="number"/>  
        </xsl:apply-templates>
      </mim:gegevensgroepen>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="keuzeAttribuutsoorten">
    <!-- Keuze tussen attribuutsoorten: -->
    <!--
    Twee use cases (zie MIM spec):
    UC2: stereotype-name-union-for-attributes: KEUZE ZONDER BETEKENIS op OBJECTTYPE   
    UC3: stereotype-name-union-by-attribute: KEUZE MET BETEKENIS (samen met ATTRIBUUTSOORT)
   
    NB. Hier worden alleen "stereotype-name-union-for-attributes" afgehandeld (UC2), "stereotype-name-union-by-attribute" worden geserialiseerd
    als attribuutsoorten.
    -->
    <xsl:where-populated>
      <mim:keuzen>
        <xsl:for-each select="imvert:attributes/imvert:attribute[imvert:stereotype/@id = $stereotype-id-union-for-attributes]">
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
          </xsl:call-template>
        </xsl:for-each>
      </mim:keuzen>  
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="process-datatype">
    <xsl:variable name="baretype" select="imvert:baretype" as="xs:string?"/>
    <xsl:variable name="is-extensie"/>
    <xsl:choose>
      <xsl:when test="imvert:type-id">
        <xsl:call-template name="create-ref-element">
          <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
          <xsl:with-param name="restrict-datatypes" select="false()" as="xs:boolean"/>
        </xsl:call-template>  
      </xsl:when>
      <xsl:when test="$baretype[lower-case(.) = $mim11-primitive-datatypes-lc-names]">
        <!-- MIM standaard datatype herkend dat als baretype is ingevoerd ( en dus geen gebruikmaakt van Kadaster-MIM11.xmi): -->
        <xsl:variable name="mim11-class" select="$packages[imvert:name = 'MIM11']/imvert:class[imf:equals-ci(imvert:name/@original, $baretype)]" as="element(imvert:class)?"/>
        <xsl:choose>
          <xsl:when test="$mim11-class/imvert:id">
            <xsl:call-template name="create-ref-element">
              <xsl:with-param name="ref-id" select="$mim11-class/imvert:id" as="xs:string"/>
            </xsl:call-template> 
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="imf:message(., 'WARNING', 'The MIM modelelement for baretype [1] could not be found in the MIM11 package', ($baretype))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>  
        <xsl:sequence select="imf:message(., 'WARNING', 'Baretype [1] is not a standard MIM datatype', ($baretype))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="heeft__keuze">
    <!-- NB. itt het XML schema worden hier zowel referenties gegenereerd naar Keuze__Attribuutsoorten als (volgens schema) Keuze__Datatypen: -->
    <xsl:if test="imvert:type-id/text()">
      <xsl:variable name="type" select="key('key-imvert-construct-by-id', imvert:type-id)" as="element()?"/>
      <xsl:if test="$type/imvert:stereotype/@id = ($stereotype-id-keuze-datatypes, $stereotype-id-keuze-attributes)">
        <mim:heeft__keuze>
          <xsl:call-template name="create-ref-element">
            <xsl:with-param name="ref-id" select="imvert:type-id" as="xs:string"/>
          </xsl:call-template>
        </mim:heeft__keuze>
      </xsl:if>
    </xsl:if>
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
  
  <xsl:function name="imf:tagged-values" as="item()*" use-when="$runs-in-imvertor-context">
    <xsl:param name="context-node" as="element()"/>
    <xsl:param name="tag-id" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$tag-id = ('CFG-TV-DEFINITION', 'CFG-TV-DESCRIPTION')">
        <xsl:apply-templates select="for $v in imf:get-most-relevant-compiled-taggedvalue-element($context-node, '##' || $tag-id) return $v/*" mode="xhtml"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="for $v in imf:get-most-relevant-compiled-taggedvalue-element($context-node, '##' || $tag-id) return normalize-space(string-join($v//text(), ' '))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="xhtml:*" mode="xhtml">
    <xsl:element name="xhtml:{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="imf:tagged-values" as="xs:string*" use-when="not($runs-in-imvertor-context)">
    <xsl:param name="context-node" as="element()"/>
    <xsl:param name="tag-id" as="xs:string"/>
    <xsl:sequence select="imf:tagged-values-not-traced($context-node, $tag-id)"/>
  </xsl:function>
  
  <xsl:function name="imf:tagged-values-not-traced" as="xs:string*">
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
  
  <xsl:function name="imf:get-xparam" as="xs:string?" use-when="$runs-in-imvertor-context">
    <xsl:param name="group-and-name"/>
    <xsl:param name="default"/>
    <xsl:sequence select="imf:get-xparm($group-and-name, $default)"/>      
  </xsl:function>
  
  <xsl:function name="imf:get-xparam" as="xs:string?" use-when="not($runs-in-imvertor-context)">
    <xsl:param name="group-and-name"/>
    <xsl:param name="default"/>
    <xsl:sequence select="$default"/>      
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
  
  <xsl:function name="imf:boolean-value" as="xs:boolean">
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
 
  <xsl:function name="imf:create-id" as="xs:string">
    <xsl:param name="elem" as="element()"/>
    <xsl:variable name="package" select="imf:valid-id($elem/ancestor-or-self::*[self::mim:Domein|self::mim:View|self::Extern]/mim:naam)" as="xs:string?"/>
    <xsl:variable name="modelelement" select="local-name($elem)" as="xs:string"/>
    <xsl:variable name="naam" select="imf:valid-id($elem/mim:naam)" as="xs:string"/>
    <xsl:value-of select="lower-case(string-join(($package, $modelelement, $naam, generate-id($elem)), '-'))"/>
  </xsl:function>
  
  <xsl:function name="imf:clean-id" as="xs:string">
    <xsl:param name="id" as="xs:string"/>
    <xsl:value-of select="replace($id, '(EAID_|EAPK_|\&#x7D;|\&#x7B;)', '')"/>
  </xsl:function>
  
  <xsl:function name="imf:valid-id" as="xs:string?">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:sequence select="if ($id) then replace(replace(lower-case(normalize-space($id)), '[^a-z0-9 ]', ''), ' ', '-') else ()"/>
  </xsl:function>
  
  <xsl:function name="imf:generate-id-attr" as="attribute()?">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:param name="required" as="xs:boolean"/>
    <xsl:if test="$id and ($required or ($generate-all-ids = 'true'))">
      <xsl:attribute name="id" select="$id"/>
    </xsl:if>
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
    <xsl:param name="elem" as="element()?"/>
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
    <xsl:param name="restrict-datatypes" as="xs:boolean?"/>
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
          $stereotype-name-referentielijst)">DatatypeRef</xsl:when>
        <!--
        <xsl:when test="$target-stereotype-name = $stereotype-name-datatype">_DatatypeRef</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-gestructureerd-datatype">GestructureerdDatatypeRef</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-primitief-datatype">PrimitiefDatatypeRef</xsl:when>   
        <xsl:when test="$target-stereotype-name = $stereotype-name-enumeratie">EnumeratieRef</xsl:when>
        <xsl:when test="$target-stereotype-name = $stereotype-name-codelijst">CodelijstRef</xsl:when> 
        <xsl:when test="$target-stereotype-name = $stereotype-name-referentielijst">ReferentielijstRef</xsl:when>
        -->
        <xsl:when test="$target-stereotype-name = $stereotype-name-interface">InterfaceRef</xsl:when>
        <xsl:when test="$restrict-datatypes"/>
        <xsl:when test="$target-stereotype-name = $stereotype-name-objecttype">ObjecttypeRef</xsl:when> 
        <xsl:when test="$target-stereotype-name = $stereotype-name-gegevensgroeptype">GegevensgroeptypeRef</xsl:when>
        <xsl:when test="$target-stereotype-id = ($stereotype-id-keuze-datatypes, $stereotype-id-keuze-attributes, $stereotype-id-keuze-associations)">KeuzeRef</xsl:when>         
        <xsl:when test="imf:is-not-mim-construct($target-element)">ConstructieRef</xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="imf:message(., 'WARNING', 'Unexpected stereotype [1] in &quot;create-ref-element&quot;', string-join(($target-stereotype-name, $target-stereotype-id), ', '))"/>
          <xsl:text>UnsupportedRef</xsl:text>
        </xsl:otherwise>
      </xsl:choose>   
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="empty($target-element)">
        <xsl:sequence select="imf:message(., 'ERROR', 'Invalid reference', ())"/>
      </xsl:when>
      <xsl:when test="$element-name">
        <xsl:element name="mim-ref:{$element-name}" namespace="http://www.geostandaarden.nl/mim-ref/informatiemodel/v1">
          <xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">#{$ref-id}</xsl:attribute>
          <xsl:value-of select="imf:name($target-element)"/>
        </xsl:element>  
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="extensieKenmerken">
    <xsl:where-populated>
      <mim-ext:kenmerken>
        <xsl:for-each select="imvert:tagged-values/imvert:tagged-value[not(@id = $mim-tagged-value-ids)]">
          <mim-ext:kenmerk naam="{imvert:name/@original}">{imvert:value/@original}</mim-ext:kenmerk>
        </xsl:for-each>  
        <!--
        <xsl:where-populated>
          <mim-ext:kenmerk naam="identificerend">{imf:mim-boolean(imvert:is-id)}</mim-ext:kenmerk>
        </xsl:where-populated>
        -->
        <xsl:where-populated>
          <mim-ext:kenmerk naam="positie">{imvert:position/@original}</mim-ext:kenmerk>
        </xsl:where-populated>
        <xsl:if test="imvert:min-occurs-source|imvert:max-occurs-source">
          <mim-ext:kenmerk naam="kardinaliteitBron">{imf:kardinaliteit(imvert:min-occurs-source, imvert:max-occurs-source)}</mim-ext:kenmerk>
        </xsl:if>
      </mim-ext:kenmerken>        
    </xsl:where-populated>
  </xsl:template>

</xsl:stylesheet>