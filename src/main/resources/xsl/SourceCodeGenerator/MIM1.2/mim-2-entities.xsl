<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:mim="http://www.geostandaarden.nl/mim/mim-core/1.2"
  xmlns:mim-ext="http://www.geostandaarden.nl/mim/mim-ext/1.0"
  xmlns:mim-ref="http://www.geostandaarden.nl/mim/mim-ref/1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  xmlns:pre="http://www.imvertor.org/xsl/preprocess"
  xmlns:local="urn:local"
  xmlns:entity="urn:entity"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
  
  <!--
  Keuze tussen datatypen?
  Ondersteuning unidirectioneel
  Ondersteuning Relatieklasse
  Ondersteuning Mixin
  Messages toevoegen
  Composite Objecttype -> Keuze?
  Composite Objecttype -> Gegevensgroeptype?
  "Mogelijk geen waarde" vs kardinaliteit
  Alleen lengte etc opnemen als type CharacterString is
  Jakarta Bean Validation: https://stackoverflow.com/questions/74441174/in-java-how-would-i-make-a-class-that-is-essentially-a-subclass-of-string-but
  https://stackoverflow.com/questions/1972933/cross-field-validation-with-hibernate-validator-jsr-303
  Uniek maken toegevoegd @Id veld
  List vs Set?
  -->  
    
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="entity-specific" on-no-match="shallow-skip"/>
  <xsl:mode name="xhtml" on-no-match="shallow-copy"/>
  <xsl:mode name="kenmerk" on-no-match="shallow-copy"/>
    
  <xsl:param name="output-uri" as="xs:string" select="''"/>
  <xsl:param name="package-prefix" as="xs:string" select="'nl.imvertor.entity'"/>
  <xsl:param name="class-name-prefix" as="xs:string" select="''"/>
  <xsl:param name="class-name-suffix" as="xs:string" select="''"/>
  
  <xsl:key name="id" match="*[@id]" use="@id"/>
  <xsl:key name="ref" match="mim-ref:*|mim-ext:ConstructieRef" use="substring(@xlink:href, 2)"/>
  <xsl:key name="supertype-ref" match="mim:supertypen/mim:GeneralisatieObjecttypen/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef)" use="substring(@xlink:href, 2)"/>
  
  <xsl:variable name="runs-in-imvertor-context" select="not(system-property('install.dir') = '')" as="xs:boolean" static="yes"/>
  
  <xsl:import href="../../common/Imvert-common.xsl" use-when="$runs-in-imvertor-context"/>
  
  <xsl:include href="functx-1.0.1.xsl"/>
  
  <xsl:variable name="lf" select="'&#10;'" as="xs:string"/>
  <xsl:variable name="accolade-open" select="'{'" as="xs:string"/>
  <xsl:variable name="accolade-close" select="'}'" as="xs:string"/>
  <xsl:variable name="backslash" select="'\'" as="xs:string"/>
  <!--
  <xsl:variable name="brace-left" select="'{'" as="xs:string"/>
  <xsl:variable name="brace-right" select="'}'" as="xs:string"/>
  -->
  
  <xsl:variable name="ONE" select="'1'" as="xs:string"/>
  <xsl:variable name="ZERO" select="'0'" as="xs:string"/>
  <xsl:variable name="unbounded">unbounded</xsl:variable>    
  <xsl:variable name="CARDINALITY-ONE" as="element(cardinality)">
    <cardinality minOccurs="{$ONE}" maxOccurs="{$ONE}"/>
  </xsl:variable>
  <xsl:variable name="CARDINALITY-ZERO-OR-ONE" as="element(cardinality)">
    <cardinality minOccurs="{$ZERO}" maxOccurs="{$ONE}"/>
  </xsl:variable>
  <xsl:variable name="CARDINALITY-ONE-OR-MORE" as="element(cardinality)">
    <cardinality minOccurs="{$ONE}" maxOccurs="{$unbounded}"/>
  </xsl:variable>
  <xsl:variable name="CARDINALITY-ZERO-OR-MORE" as="element(cardinality)">
    <cardinality minOccurs="{$ZERO}" maxOccurs="{$unbounded}"/>
  </xsl:variable>
  <xsl:variable name="is-relatiesoort-leidend" select="/*/mim:relatiemodelleringstype = 'Relatiesoort leidend' or /*/mim:relatiemodelleringtype = 'Relatiesoort leidend'" as="xs:boolean"/>
  <xsl:variable name="is-relatierol-leidend" select="/*/mim:relatiemodelleringstype = 'Relatierol leidend' or /*/mim:relatiemodelleringtype = 'Relatierol leidend'" as="xs:boolean"/>
  
  <xsl:variable name="aggregation-type-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'Compositie'" select="'composite'"/>
      <xsl:map-entry key="'Gedeeld'" select="'shared'"/>
      <xsl:map-entry key="'Geen'" select="'none'"/>
    </xsl:map>
  </xsl:variable>
      
  <xsl:template match="mim:Informatiemodel">
    <xsl:variable name="model" as="document-node()">
      <xsl:document>
        <model>
          <xsl:namespace name="xhtml">http://www.w3.org/1999/xhtml</xsl:namespace>
          <title>{mim:naam}</title>
          <definition>
            <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
          </definition>  
          
          <name>{entity:package-name((mim:naam))}</name>
          <package-prefix>{$package-prefix}</package-prefix>
          <xsl:apply-templates/>
          <xsl:apply-templates select="mim-ext:kenmerken" mode="kenmerk"/>
        </model>  
      </xsl:document>
    </xsl:variable>
    <xsl:apply-templates select="$model"/>
  </xsl:template>
   
  <xsl:template match="mim:packages">
    <packages>  
      <xsl:apply-templates/>  
    </packages>
  </xsl:template>
  
  <xsl:template match="mim:Domein | mim:View | mim:Extern">
    <xsl:element name="{lower-case(local-name())}">
      <name>{entity:package-name(local:package-hierarchy(.))}</name>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
     
  <xsl:template match="
    mim:objecttypen/mim:Objecttype | 
    mim:keuzen/mim:Keuze | 
    mim:relatieklasse/mim:Relatieklasse | 
    mim:gegevensgroeptypen/mim:Gegevensgroeptype | 
    mim:datatypen/mim:PrimitiefDatatype[not(mim:supertypen/mim:GeneralisatieDatatypen/mim:supertype/mim:Datatype)] |
    mim:datatypen/mim:GestructureerdDatatype | 
    mim:datatypen/mim:Codelijst | 
    mim:datatypen/mim:Referentielijst |
    mim-ext:constructies/mim-ext:Constructie"> 
    
    <xsl:variable name="non-mixin-supertype-refs" select="mim:supertypen/mim:GeneralisatieObjecttypen[not(mim:mixin = 'true')]/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef)" as="element()*"/>  
    <xsl:if test="count($non-mixin-supertype-refs) gt 1">
      <xsl:sequence select="imf:message(., 'ERROR', 'Multiple inheritance is not supported (besides on mixin/static supertypes)', 'Objecttype: ' || mim:naam)"/>  
    </xsl:if>
    
    <xsl:variable name="non-mixin-supertype-info" select="local:type-to-class($non-mixin-supertype-refs[1])" as="element(class)?"/>
    <xsl:variable name="has-id-attribute" select="$non-mixin-supertype-info or (mim:attribuutsoorten/mim:Attribuutsoort | mim:referentieElementen/mim:ReferentieElement)/mim:identificerend = 'true'" as="xs:boolean"/>
    
    <entity>
      <name>{entity:class-name(mim:naam)}</name>
      <package-name>{entity:package-name(local:package-hierarchy(.))}</package-name>
      <model-element>{local-name()}</model-element>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition>  
      <is-abstract>{if (mim:indicatieAbstractObject) then mim:indicatieAbstractObject else 'false'}</is-abstract>
      <has-id-attribute>{$has-id-attribute}</has-id-attribute>
      <xsl:if test="$non-mixin-supertype-info">
        <super-type 
          is-standard="{$non-mixin-supertype-info/is-standard-class = 'true'}"
          package-name="{$non-mixin-supertype-info/package-name}"
          model-element="{$non-mixin-supertype-info/model-element}">{$non-mixin-supertype-info/name}</super-type>  
      </xsl:if>
      <has-sub-types>{local:has-subtype(.)}</has-sub-types>
      <fields>
        <xsl:if test="not($has-id-attribute)">
          <field>
            <name>id</name>
            <type is-enum="false" is-standard="true">Long</type>
            <category/>
            <definition>Field that is not part of the model but added to define an identifying field for this entity</definition>
            <is-id-attribute>true</is-id-attribute>
            <auto-generate>true</auto-generate> <!-- TODO: only use in entity classes -->
            <nullable>false</nullable>
            <cardinality>
              <source>
                <min-occurs>1</min-occurs>
                <max-occurs>1</max-occurs>  
              </source>
              <target>
                <min-occurs>1</min-occurs>
                <max-occurs>1</max-occurs>  
              </target>
            </cardinality>
          </field>
          <xsl:variable name="relation-type" select="local:resolve-referer(.)/parent::doel/parent::mim:Relatiesoort" as="element(mim:Relatiesoort)?"/>
          <xsl:if test="$relation-type">
            <!-- TODO: create fields for unidirectional relatiesoorten -->
          </xsl:if>
        </xsl:if>
        <!-- "Copy down" fields from mixin supertypes: --> 
        <xsl:apply-templates select="mim:supertypen/mim:GeneralisatieObjecttypen[mim:mixin = 'true']/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef)/local:resolve-reference(.)"/>
        <xsl:apply-templates select="." mode="entity-specific"/>
        <xsl:apply-templates/>
      </fields>
      <xsl:apply-templates select="mim-ext:kenmerken" mode="kenmerk"/>
    </entity>
  </xsl:template>
  
  <xsl:template match="mim:datatypen/mim:Enumeratie">  
    <enumeration>
      <name>{entity:class-name(mim:naam)}</name>
      <package-name>{entity:package-name(local:package-hierarchy(.))}</package-name>
      <model-element>{local-name()}</model-element>
      <definition>
        <xsl:sequence select="mim:definitie/node()"/>
      </definition>
      <values>
        <xsl:for-each select="mim:waarden/mim:Waarde">
          <value>
            <definition>
              <xsl:sequence select="mim:definitie/node()"/>
            </definition>  
            <code>{entity:enum-value(mim:code)}</code>
          </value>
        </xsl:for-each>  
      </values>
    </enumeration>
  </xsl:template>
  
  <xsl:template match="mim:datatypen/mim:Codelijst" mode="entity-specific">
    <xsl:variable name="field-name" select="(mim:waardeItem/text(), 'value')[1]" as="xs:string"/>
    <field>
      <name>{entity:field-name($field-name)}</name>
      <type is-enum="false" is-standard="true">{map:get($primitive-mim-type-mapping, 'CharacterString')}</type>
      <category>Codelijst -> Waardeitem</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition> 
      <is-id-attribute>false</is-id-attribute>
      <nullable>false</nullable>
      <xsl:call-template name="kenmerken"/>
      <cardinality>
        <source>
          <min-occurs>1</min-occurs>
          <max-occurs>1</max-occurs>
        </source>
        <target>
          <min-occurs>1</min-occurs>
          <max-occurs>1</max-occurs>
        </target>  
      </cardinality>
    </field>
  </xsl:template>
  
  <xsl:template match="
    mim:attribuutsoorten/mim:Attribuutsoort | 
    mim:keuzeAttributen/mim:Attribuutsoort |
    mim:gegevensgroepen/mim:Gegevensgroep |
    mim:dataElementen/mim:DataElement |
    mim:referentieElementen/mim:ReferentieElement">
    
    <xsl:variable name="type-model-element" select="local:resolve-reference((mim:type | mim:gegevensgroeptype)/*)" as="element()?"/>
    <xsl:variable name="type-info" select="local:type-to-class((mim:type | mim:gegevensgroeptype)/*)" as="element(class)"/>
    <xsl:variable name="cardinality" select="local:cardinality(mim:kardinaliteit)" as="element(cardinality)"/>
    
    <field>
      <name>{entity:field-name(mim:naam)}</name>
      <type 
        is-enum="{exists(local:resolve-reference(mim:type/mim-ref:DatatypeRef)/self::mim:Enumeratie)}" 
        is-standard="{$type-info/is-standard-class = 'true'}">
        <xsl:if test="$type-info/package-name">
          <xsl:attribute name="package-name">{$type-info/package-name}</xsl:attribute>
        </xsl:if>
        <xsl:if test="$type-info/model-element">
          <xsl:attribute name="model-element">{$type-info/model-element}</xsl:attribute> 
        </xsl:if>
        <xsl:value-of select="$type-info/name"/>
      </type>
      <category>{local-name()}{if (not($type-info/is-standard-class = 'true')) then ' -> ' || $type-info/model-element else ()}</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition> 
      <is-id-attribute>{if (mim:identificerend) then mim:identificerend else 'false'}</is-id-attribute>
      <nullable>
        <xsl:choose>
          <xsl:when test="parent::mim:keuzeAttributen">true</xsl:when> <!-- Override mim:mogelijkGeenWaarde because of Keuze -->
          <xsl:when test="mim:mogelijkGeenWaarde = 'true'">true</xsl:when> <!-- Takes precedence over cardinality -->
          <xsl:otherwise>{$cardinality/@minOccurs = $ZERO}</xsl:otherwise> 
        </xsl:choose>  
      </nullable>
      <aggregation>
        <xsl:choose>
          <xsl:when test="self::mim:Gegevensgroep">composite</xsl:when>
          <xsl:otherwise>shared</xsl:otherwise>
        </xsl:choose>  
      </aggregation>
      <xsl:call-template name="kenmerken"/>
      <cardinality>
        <source>
          <min-occurs>1</min-occurs>
          <max-occurs>1</max-occurs>
        </source>
        <target>
          <xsl:choose>
            <xsl:when test="parent::mim:keuzeAttributen">
              <min-occurs>0</min-occurs>
              <max-occurs>1</max-occurs>
            </xsl:when>
            <xsl:otherwise>
              <min-occurs>{$cardinality/@minOccurs}</min-occurs>
              <max-occurs>{$cardinality/@maxOccurs}</max-occurs>
            </xsl:otherwise>
          </xsl:choose>
        </target>  
      </cardinality>
      <xsl:where-populated>
        <choice-id>{@pre:keuze-id}</choice-id>  
      </xsl:where-populated>
    </field>
  </xsl:template>
    
  <xsl:template match="mim:Objecttype/mim:keuzen/mim-ref:KeuzeRef">
    <!-- Verwijzing vanuit Objecttype naar Keuze tussen Attribuutsoorten -->
    <xsl:variable name="keuze" select="local:resolve-reference(.)" as="element()"/>
    <field>
      <name>{entity:field-name(@label)}</name>
      <type 
        is-enum="false" 
        is-standard="false"
        model-element="Keuze"
        package-name="{entity:package-name(local:package-hierarchy($keuze))}">{entity:class-name($keuze/mim:naam)}</type>
      <category>-> Keuze tussen {lower-case(substring-after(local-name($keuze/(mim:keuzeAttributen|mim:keuzeDatatypen|mim:keuzeRelatiedoelen)), 'keuze'))}</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition> 
      <is-id-attribute>false</is-id-attribute>
      <nullable>false</nullable> 
      <aggregation>composite</aggregation>
      <cardinality>
        <source>
          <min-occurs>1</min-occurs>
          <max-occurs>1</max-occurs>
        </source>
        <target>
          <min-occurs>1</min-occurs>
          <max-occurs>1</max-occurs>
        </target>  
      </cardinality>
    </field>
  </xsl:template>
     
  <xsl:template match="mim:Keuze/mim:keuzeDatatypen/(mim:Datatype|mim-ref:DatatypeRef|mim-ext:ConstructieRef)">
    <!-- Keuze tussen Datatypen --> 
    <xsl:variable name="type-info" select="local:type-to-class(.)" as="element(class)"/>
    <field>
      <name>{if (@label) then entity:field-name(@label) else 'attr' || position()}</name>
      <type 
        is-enum="{exists(local:resolve-reference(.)/self::mim:Enumeratie)}" 
        is-standard="{$type-info/is-standard-class = 'true'}">
        <xsl:if test="$type-info/package-name">
          <xsl:attribute name="package-name">{$type-info/package-name}</xsl:attribute>
        </xsl:if>
        <xsl:if test="$type-info/model-element">
          <xsl:attribute name="model-element">{$type-info/model-element}</xsl:attribute> 
        </xsl:if>
        <xsl:value-of select="$type-info/name"/>
      </type>
      <category>Keuze datatype</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition> 
      <is-id-attribute>false</is-id-attribute>
      <nullable>true</nullable>
      <aggregation>composite</aggregation>
      <unidirectional>true</unidirectional> 
      <cardinality>
        <source>
          <min-occurs>1</min-occurs> 
          <max-occurs>1</max-occurs>  
        </source>
        <target>
          <min-occurs>0</min-occurs> <!-- Immers: "Keuze" -->
          <max-occurs>1</max-occurs>
        </target>
      </cardinality>
    </field>
  </xsl:template>  
   
  <xsl:template match="mim:Keuze/mim:keuzeRelatiedoelen/mim:Relatiedoel/mim-ref:ObjecttypeRef">
    <!-- Keuze tussen Relatiedoelen --> 
    <xsl:variable name="relatiedoel" select="local:resolve-reference(.)" as="element()"/>
    <xsl:variable name="referer-relatiesoort" select="local:resolve-referer(ancestor::mim:Keuze)/ancestor::mim:Relatiesoort" as="element()"/>
    <xsl:variable name="referer-relatiesoort-bron" select="if ($is-relatierol-leidend) then $referer-relatiesoort/mim:relatierollen/mim:Bron else ()" as="element(mim:Bron)?"/>
    <field>
      <name>{entity:field-name(@label)}</name>
      <type 
        is-enum="false" 
        is-standard="false"
        model-element="Objecttype"
        package-name="{entity:package-name(local:package-hierarchy($relatiedoel))}">{entity:class-name($relatiedoel/mim:naam)}</type>
      <category>Keuze (relatiedoel)</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition> 
      <is-id-attribute>false</is-id-attribute>
      <nullable>true</nullable>
      <aggregation>
        <xsl:choose>
          <xsl:when test="$is-relatierol-leidend">{if ($referer-relatiesoort-bron/mim:aggregatietype) then 
            map:get($aggregation-type-mapping, $referer-relatiesoort-bron/mim:aggregatietype) 
            else 'none'}</xsl:when>
          <xsl:otherwise>{if ($referer-relatiesoort/mim:aggregatietype) then 
            map:get($aggregation-type-mapping, $referer-relatiesoort/mim:aggregatietype) 
            else 'none'}</xsl:otherwise>
        </xsl:choose>
      </aggregation>
      <unidirectional> <!-- TODO: in geval "Relatiebron leidend" lijkt "mim:unidirectioneel" voor mim:Relatiesoort niet te worden opgenomen in de serialisatie -->
        <xsl:choose>
          <xsl:when test="$is-relatierol-leidend">{if ($referer-relatiesoort-bron/mim:unidirectioneel) then 
            $referer-relatiesoort-bron/mim:unidirectioneel 
            else 'true'}</xsl:when>
          <xsl:otherwise>{if ($referer-relatiesoort/mim:unidirectioneel) then 
            $referer-relatiesoort/mim:unidirectioneel 
            else 'true'}</xsl:otherwise>
        </xsl:choose>
      </unidirectional>
      <cardinality>
        <source>
          <min-occurs>1</min-occurs> 
          <max-occurs>1</max-occurs>  
        </source>
        <target>
          <min-occurs>0</min-occurs> <!-- Immers: "Keuze" -->
          <max-occurs>1</max-occurs>
        </target>
      </cardinality>
    </field>
  </xsl:template>  
  
  <xsl:template match="mim:relatiesoorten/mim:Relatiesoort/mim:relatieklasse">
    <!-- TODO: implement -->
  </xsl:template>
   
  <xsl:template match="mim:relatiesoorten/mim:Relatiesoort[$is-relatierol-leidend]">
    <xsl:variable name="target" select="local:resolve-reference(mim:doel/*)" as="element()"/> <!-- Objecttype, Keuze, Constructie -->
    <xsl:variable name="source-cardinality" select="local:cardinality(mim:relatierollen/mim:Bron/mim:kardinaliteit)" as="element(cardinality)"/>
    <xsl:variable name="target-cardinality" select="local:cardinality(mim:relatierollen/mim:Doel/mim:kardinaliteit)" as="element(cardinality)"/>
    
    <xsl:variable name="aggregation" select="mim:relatierollen/mim:Bron/mim:aggregatietype" as="xs:string?"/>
    <!-- TODO: in geval "Relatiebron leidend" lijkt mim:unidirectioneel voor mim:Relatiesoort niet te worden opgenomen in de serialisatie: -->
    <xsl:variable name="unidirectional" select="mim:relatierollen/mim:Bron/mim:unidirectioneel" as="xs:string?"/>
    
    <field>
      <name>
        <xsl:choose>
          <xsl:when test="normalize-space(mim:relatierollen/mim:Doel/mim:naam)">{entity:field-name(mim:relatierollen/mim:Doel/mim:naam)}</xsl:when>
          <xsl:otherwise>{entity:field-name(mim:naam)}{entity:class-name($target/mim:naam)}</xsl:otherwise> <!-- Add target name to avoid naming collisions -->
        </xsl:choose>
      </name>
      <type 
        is-enum="false" 
        is-standard="false"
        package-name="{entity:package-name(local:package-hierarchy($target))}"
        model-element="{$target/local-name()}">{entity:class-name($target/mim:naam)}</type>
      <category>{local-name()} -> {$target/local-name()}</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition>       
      <is-id-attribute>false</is-id-attribute>
      <nullable>
        <xsl:choose>
          <xsl:when test="mim:relatierollen/mim:Bron/mim:mogelijkGeenWaarde = 'true'">true</xsl:when> <!-- Takes precedence over cardinality -->
          <xsl:otherwise>{$target-cardinality/@minOccurs = $ZERO}</xsl:otherwise> 
        </xsl:choose>  
      </nullable>
      <aggregation>
        <xsl:choose>
          <xsl:when test="$target/self::mim:Keuze">composite</xsl:when> <!-- Objecttype and Keuze are tied together --> 
          <xsl:when test="$aggregation">{map:get($aggregation-type-mapping, $aggregation)}</xsl:when>
          <xsl:otherwise>none</xsl:otherwise>
        </xsl:choose>  
      </aggregation>
      <unidirectional>{if ($unidirectional) then $unidirectional else 'true'}</unidirectional>
      <cardinality>
        <source>
          <min-occurs>{$source-cardinality/@minOccurs}</min-occurs>
          <max-occurs>{$source-cardinality/@maxOccurs}</max-occurs> 
        </source>
        <target>
          <min-occurs>{$target-cardinality/@minOccurs}</min-occurs>
          <max-occurs>{$target-cardinality/@maxOccurs}</max-occurs> 
        </target>
      </cardinality>
      <xsl:where-populated>
        <choice-id>{@pre:keuze-id}</choice-id>  
      </xsl:where-populated>
    </field>
  </xsl:template>
  
  <xsl:template match="mim:relatiesoorten/mim:Relatiesoort[$is-relatiesoort-leidend] | mim:externeKoppelingen/mim:ExterneKoppeling">
    <xsl:variable name="target" select="local:resolve-reference(mim:doel/*)" as="element()"/> <!-- Objecttype, Keuze, Constructie -->
    <xsl:variable name="source-cardinality" select="if (not(mim:kardinaliteitBron = 'TODO')) then local:cardinality(mim:kardinaliteitBron) else local:cardinality(mim-ext:kenmerken/mim-ext:Kenmerk[@naam='kardinaliteitBron'])" as="element(cardinality)"/>
    <xsl:variable name="target-cardinality" select="local:cardinality(mim:kardinaliteit)" as="element(cardinality)"/>
    <xsl:variable name="aggregation" select="mim:aggregatietype" as="xs:string?"/>
    <xsl:variable name="unidirectional" select="mim:unidirectioneel" as="xs:string?"/>
    
    <field>
      <name>{entity:field-name(mim:naam)}{entity:class-name($target/mim:naam)}</name> <!-- Add target name to avoid naming collisions -->
      <type 
        is-enum="false" 
        is-standard="false"
        package-name="{entity:package-name(local:package-hierarchy($target))}"
        model-element="{$target/local-name()}">{entity:class-name($target/mim:naam)}</type>
      <category>{local-name()} -> {$target/local-name()}</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition> 
      <is-id-attribute>false</is-id-attribute>
      <nullable>
        <xsl:choose>
          <xsl:when test="mim:mogelijkGeenWaarde = 'true'">true</xsl:when> <!-- Takes precedence over cardinality -->
          <xsl:otherwise>{$target-cardinality/@minOccurs = $ZERO}</xsl:otherwise> 
        </xsl:choose>  
      </nullable>
      <aggregation>
        <xsl:choose>
          <xsl:when test="$target/self::mim:Keuze">composite</xsl:when> <!-- Objecttype and Keuze are tied together --> 
          <xsl:when test="$aggregation">{map:get($aggregation-type-mapping, $aggregation)}</xsl:when>
          <xsl:otherwise>none</xsl:otherwise>
        </xsl:choose>  
      </aggregation>
      <unidirectional>{if ($unidirectional) then $unidirectional else 'true'}</unidirectional>
      <cardinality>
        <source>
          <min-occurs>{$source-cardinality/@minOccurs}</min-occurs>
          <max-occurs>{$source-cardinality/@maxOccurs}</max-occurs> 
        </source>
        <target>
          <min-occurs>{$target-cardinality/@minOccurs}</min-occurs>
          <max-occurs>{$target-cardinality/@maxOccurs}</max-occurs> 
        </target>
      </cardinality>
      <xsl:where-populated>
        <choice-id>{@pre:keuze-id}</choice-id>  
      </xsl:where-populated>
    </field>
  </xsl:template>
  
  <xsl:template match="xhtml:*" mode="xhtml">
    <xsl:element name="xhtml:{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="mim-ext:kenmerken" mode="kenmerk">
    <features>
      <xsl:for-each select="mim-ext:Kenmerk">
        <feature name="{@naam}">{.}</feature>
      </xsl:for-each>
      <xsl:apply-templates/>
    </features>
  </xsl:template>
  
  <xsl:function name="local:kenmerk-ext" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:param name="feature-name" as="xs:string"/>
    <xsl:sequence select="$model-element/mim-ext:kenmerken/mim-ext:Kenmerk[@naam=$feature-name]"/>
  </xsl:function>
  
  <!-- Find the element that is referred to by $ref-element/@xlink:href: -->
  <xsl:function name="local:resolve-reference" as="element()?">
    <xsl:param name="ref-element" as="element()?"/>
    <xsl:sequence select="if (empty($ref-element)) then () else key('id', substring($ref-element/@xlink:href, 2), $ref-element/root())"/>
  </xsl:function>
  
  <!-- Find any elements that refer to $id-element/@id: -->
  <xsl:function name="local:resolve-referer" as="element()*">
    <xsl:param name="id-element" as="element()?"/>
    <xsl:sequence select="if (empty($id-element)) then () else key('ref', $id-element/@id, $id-element/root())"/>
  </xsl:function>
    
  <xsl:function name="local:type-to-class" as="element(class)?">
    <xsl:param name="type" as="element()?"/>
    <xsl:if test="$type">
      <xsl:choose>
        <xsl:when test="$type/self::mim:Datatype">
          <class>
            <name>{map:get($primitive-mim-type-mapping, $type)}</name>
            <is-standard-class>true</is-standard-class>  
          </class>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="resolved-element" select="local:resolve-reference($type[@xlink:href])" as="element()"/>
          <xsl:choose>
            <xsl:when test="$resolved-element/self::mim:PrimitiefDatatype/mim:supertypen/mim:GeneralisatieDatatypen/mim:supertype/mim:Datatype">
              <!-- Use the MIM standard type supertype instead of a custom subclassed entity (we cannot subclass String after all): -->
              <xsl:sequence select="local:type-to-class($resolved-element/self::mim:PrimitiefDatatype/mim:supertypen/mim:GeneralisatieDatatypen/mim:supertype/mim:Datatype)"/>
            </xsl:when>
            <xsl:when test="$resolved-element/self::mim:PrimitiefDatatype">
              <!-- PrimitiefDatatype without supertype, default to CharacterString: -->
              <class>
                <name>{map:get($primitive-mim-type-mapping, 'CharacterString')}</name>
                <is-standard-class>true</is-standard-class>  
              </class>
            </xsl:when>
            <xsl:otherwise>
              <class>
                <name>{entity:class-name($resolved-element/mim:naam)}</name>
                <is-standard-class>false</is-standard-class>
                <model-element>{$resolved-element/local-name()}</model-element>
                <package-name>{entity:package-name(local:package-hierarchy($resolved-element))}</package-name>  
              </class>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="local:cardinality" as="element(cardinality)">
    <xsl:param name="cardinality" as="xs:string?"/>
    <xsl:variable name="c" select="replace(normalize-space($cardinality), '\s', '')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="empty($c) or (string-length($c) = 0) or ($c = ('1','1..1'))">
        <xsl:sequence select="$CARDINALITY-ONE"/>
      </xsl:when>
      <xsl:when test="$c = '0..1'">
        <xsl:sequence select="$CARDINALITY-ZERO-OR-ONE"/>
      </xsl:when>
      <xsl:when test="starts-with($c, '0..')"> <!-- Consider every number not being '1' as MORE -->
        <xsl:sequence select="$CARDINALITY-ZERO-OR-MORE"/>
      </xsl:when>
      <xsl:when test="starts-with($c, '1..')"> <!-- Consider every number not being '1' as MORE -->
        <xsl:sequence select="$CARDINALITY-ONE-OR-MORE"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unsupported cardinality value: {$cardinality}</xsl:message>
        <xsl:sequence select="$CARDINALITY-ONE"/>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:function>
  
  <xsl:function name="local:package-hierarchy" as="xs:string*">
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="for $p in (
      $context/ancestor-or-self::mim:Informatiemodel, 
      $context/ancestor-or-self::mim:Domein, 
      $context/ancestor-or-self::mim:View, 
      $context/ancestor-or-self::mim:Extern) 
      return xs:string($p/mim:naam)"/>
  </xsl:function>
  
  <!-- Does $object-type has any subtypes? -->
  <xsl:function name="local:has-subtype" as="xs:boolean">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="exists(key('supertype-ref', $model-element/@id, $model-element/root()))"/>
  </xsl:function>
  
  <!-- Does $object-type has any supertypes? -->
  <xsl:function name="local:has-supertype" as="xs:boolean">
    <xsl:param name="object-type" as="element()"/>
    <xsl:sequence select="exists($object-type/mim:supertypen/mim:GeneralisatieObjecttypen/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef))"/>
  </xsl:function>
  
  <xsl:function name="local:kenmerk" as="xs:string?">
    <xsl:param name="model-element" as="element()?"/>
    <xsl:param name="feature-name" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="empty($model-element)"/>
      <xsl:when test="$model-element/*[local-name() = $feature-name]/node()">{$model-element/*[local-name() = $feature-name]}</xsl:when>
      <xsl:when test="$model-element/mim:type/mim-ref:DatatypeRef">
        <xsl:sequence select="local:kenmerk(local:resolve-reference($model-element/mim:type/mim-ref:DatatypeRef)/self::mim:PrimitiefDatatype, $feature-name)"/>
      </xsl:when>
      <xsl:when test="$model-element/self::mim:PrimitiefDatatype/mim:supertypen/mim:GeneralisatieDatatypen/mim:supertype/mim-ref:DatatypeRef">
        <xsl:sequence select="local:kenmerk(local:resolve-reference($model-element/self::mim:PrimitiefDatatype/mim:supertypen/mim:GeneralisatieDatatypen/mim:supertype/mim-ref:DatatypeRef)/self::mim:PrimitiefDatatype, $feature-name)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="local:kenmerk-lengte" as="map(xs:string, xs:string)?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:variable name="length" select="local:kenmerk($model-element, 'lengte')" as="xs:string?"/>
    <xsl:variable name="l" select="replace(normalize-space($length), '\s', '')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="empty($length)"/>
      <xsl:when test="$l castable as xs:integer">
        <xsl:map>
          <xsl:map-entry key="'min-value'" select="$l"/>
          <xsl:map-entry key="'max-value'" select="$l"/>
        </xsl:map>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="result" select="analyze-string($l, '(\d*)\.\.(\d*)')" as="element(fn:analyze-string-result)"/>
        <xsl:if test="$result/fn:match">
          <xsl:map>
            <xsl:map-entry key="'min-value'" select="($result/fn:match/fn:group[@nr='1'], 0)[1]"/>
            <xsl:map-entry key="'max-value'" select="($result/fn:match/fn:group[@nr='2'], $unbounded)[1]"/>
          </xsl:map>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="local:kenmerk-formeel-patroon" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:kenmerk($model-element, 'formeelPatroon')"/>
  </xsl:function>
  
  <xsl:function name="local:kenmerk-minimumwaarde-inclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:kenmerk($model-element, 'minimumwaardeInclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:kenmerk-minimumwaarde-exclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:kenmerk($model-element, 'minimumwaardeExclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:kenmerk-maximumwaarde-inclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:kenmerk($model-element, 'maximumwaardeInclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:kenmerk-maximumwaarde-exclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:kenmerk($model-element, 'maximumwaardeExclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:definition-as-string" as="xs:string?">
    <xsl:param name="definition" as="element()?"/>
    <xsl:choose>
      <xsl:when test="$definition">
        <xsl:variable name="text" select="normalize-space(string-join($definition//text(), ' '))" as="xs:string"/>
        <xsl:sequence select="if (string-length($text) gt 0) then $text else ()"/>    
      </xsl:when>
    </xsl:choose>
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
  
  <xsl:template name="kenmerken">
    <xsl:variable name="length-map" select="local:kenmerk-lengte(.)" as="map(xs:string, xs:string)?"/>
    <xsl:if test="exists($length-map)">
      <xsl:where-populated>
        <length>{map:get($length-map, 'max-value')}</length>
      </xsl:where-populated>
      <xsl:where-populated>
        <size-min>{map:get($length-map, 'min-value')}</size-min>
      </xsl:where-populated>
      <xsl:where-populated>
        <size-max>{map:get($length-map, 'max-value')}</size-max>
      </xsl:where-populated>  
    </xsl:if>
    <xsl:where-populated>
      <formal-pattern>{local:kenmerk-formeel-patroon(.)}</formal-pattern>
    </xsl:where-populated>
    <xsl:where-populated>
      <min-incl>{local:kenmerk-minimumwaarde-inclusief(.)}</min-incl>
    </xsl:where-populated>
    <xsl:where-populated>
      <min-excl>{local:kenmerk-minimumwaarde-exclusief(.)}</min-excl>
    </xsl:where-populated>
    <xsl:where-populated>
      <max-incl>{local:kenmerk-maximumwaarde-inclusief(.)}</max-incl>
    </xsl:where-populated>
    <xsl:where-populated>
      <max-excl>{local:kenmerk-maximumwaarde-exclusief(.)}</max-excl>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template name="write-to-file">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="lines" as="element()+"/>
    <xsl:result-document href="{$uri}" method="text">   
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <xsl:sequence select="$lines"/>        
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
</xsl:stylesheet>