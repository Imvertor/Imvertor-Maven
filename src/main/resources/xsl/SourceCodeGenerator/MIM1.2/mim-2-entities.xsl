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
  xmlns:funct="urn:funct"
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
    mim-ext:constructies/mim-ext:Constructie[not(mim-ext:constructietype = ('OPENAPI OPERATION', 'OPENAPI TAGS'))]"> 
    
    <xsl:variable name="non-mixin-supertype-refs" select="mim:supertypen/mim:GeneralisatieObjecttypen[not(local:is-mixin(.))]/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef)" as="element()*"/>  
    <xsl:if test="count($non-mixin-supertype-refs) gt 1">
      <xsl:sequence select="imf:message(., 'ERROR', 'Multiple inheritance is not supported (besides on mixin/static supertypes): Objecttype: [1]', mim:naam, '')"/>  
    </xsl:if>
    <xsl:variable name="mixin-supertype-refs" select="mim:supertypen/mim:GeneralisatieObjecttypen[local:is-mixin(.)]/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef)" as="element()*"/>
    <xsl:variable name="supertypes" select="if (self::mim:Objecttype) then local:get-all-objecttype-supertypes(.) else ()" as="element(mim:Objecttype)*"/>
    
    <xsl:variable name="non-mixin-supertype-info" select="local:type-to-class($non-mixin-supertype-refs[1])" as="element(class)?"/>
    
    <xsl:variable name="identifying-attribuutsoort" select="if (self::mim:Objecttype) then local:get-identifying-attribuutsoort-of-objecttype(.) else ()" as="element(mim:Attribuutsoort)?"/>
    
    <entity>
      <name>{entity:class-name(mim:naam)}</name>
      <package-name>{entity:package-name(local:package-hierarchy(.))}</package-name>
      <model-element>{local-name()}</model-element>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition>  
      <is-abstract>{if (mim:indicatieAbstractObject) then mim:indicatieAbstractObject else 'false'}</is-abstract>
      
      <xsl:if test="$identifying-attribuutsoort">
        <identifying-attribute>
          <xsl:apply-templates select="$identifying-attribuutsoort"/>
        </identifying-attribute>   
      </xsl:if>
      
      <xsl:if test="$non-mixin-supertype-info">
        <super-type 
          is-standard="{$non-mixin-supertype-info/is-standard-class = 'true'}"
          package-name="{$non-mixin-supertype-info/package-name}"
          model-element="{$non-mixin-supertype-info/model-element}">{$non-mixin-supertype-info/name}</super-type>  
      </xsl:if>
      <xsl:if test="$mixin-supertype-refs">
        <interfaces>
          <xsl:for-each select="$mixin-supertype-refs">
            <xsl:variable name="mixin-supertype-info" select="local:type-to-class(.)" as="element(class)?"/>
            <interface 
              is-standard="{$mixin-supertype-info/is-standard-class = 'true'}"
              package-name="{$mixin-supertype-info/package-name}"
              model-element="{$mixin-supertype-info/model-element}">{$non-mixin-supertype-info/name}</interface>
          </xsl:for-each>
        </interfaces>
      </xsl:if>
      <has-sub-types>{local:has-subtype(.)}</has-sub-types>
      <fields>
        <xsl:if test="empty($identifying-attribuutsoort)">
          <field>
            <name original="id">id</name>
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
        <xsl:apply-templates select="mim:supertypen/mim:GeneralisatieObjecttypen[local:is-mixin(.)]/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef)/local:resolve-reference(.)"/>
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
      <name original="{$field-name}">{entity:field-name($field-name)}</name>
      <type is-enum="false" is-standard="true">{map:get($primitive-mim-type-mapping, 'CharacterString')}</type>
      <category>Codelijst -> Waardeitem</category>
      <definition>
        <xsl:apply-templates select="mim:definitie/node()" mode="xhtml"/>
      </definition> 
      <is-id-attribute>false</is-id-attribute>
      <nullable>false</nullable>
      <xsl:call-template name="attribuutsoort-kenmerken"/>
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
      <name original="{mim:naam}">{entity:field-name(mim:naam)}</name>
      <xsl:choose>
        <xsl:when test="$type-info/openapi-ref">
          <type openapi-ref="{$type-info/openapi-ref}"/>
        </xsl:when>
        <xsl:otherwise>
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
        </xsl:otherwise>
      </xsl:choose>
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
      <!--
      <xsl:choose>
        <xsl:when test="self::mim:Gegevensgroep">composite</xsl:when>
        <xsl:otherwise>shared</xsl:otherwise>
      </xsl:choose>
      -->
      <aggregation>composite</aggregation>
      <xsl:call-template name="attribuutsoort-kenmerken"/>
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
      <name original="{@label}">{entity:field-name(@label)}</name>
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
      <name original="{if (@label) then @label else 'attr' || position()}">{if (@label) then entity:field-name(@label) else 'attr' || position()}</name>
      <xsl:choose>
        <xsl:when test="$type-info/openapi-ref">
          <type openapi-ref="{$type-info/openapi-ref}"/>
        </xsl:when>
        <xsl:otherwise>
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
        </xsl:otherwise>
      </xsl:choose>
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
      <name original="{@label}">{entity:field-name(@label)}</name>
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
      <xsl:choose>
        <xsl:when test="normalize-space(mim:relatierollen/mim:Doel/mim:naam) and local:is-relatierol-doel-name-unique(.)">
          <name original="{mim:relatierollen/mim:Doel/mim:naam}">{entity:field-name(mim:relatierollen/mim:Doel/mim:naam)}</name>
        </xsl:when>
        <xsl:when test="local:is-relatiesoort-name-unique(.)">
          <name original="{mim:naam}">{entity:field-name(mim:naam)}</name>
        </xsl:when>
        <xsl:otherwise>
          <!-- Add target name to avoid name collisions: -->
          <name original="{mim:naam}{$target/mim:naam}">{entity:field-name(mim:naam)}{entity:class-name($target/mim:naam)}</name>
        </xsl:otherwise> 
      </xsl:choose>
      <xsl:variable name="openapi-ref" select="local:kenmerk-ext($target, 'OA Reference')[1]" as="xs:string?"/>
      <xsl:choose>
        <xsl:when test="normalize-space($openapi-ref)">
          <type openapi-ref="{$openapi-ref}"/>
        </xsl:when>
        <xsl:otherwise>
          <type 
            is-enum="false" 
            is-standard="false"
            package-name="{entity:package-name(local:package-hierarchy($target))}"
            model-element="{$target/local-name()}">{entity:class-name($target/mim:naam)}</type>
        </xsl:otherwise>
      </xsl:choose>
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
      <xsl:apply-templates select="mim-ext:kenmerken" mode="kenmerk"/>
    </field>
  </xsl:template>
  
  <xsl:template match="mim:relatiesoorten/mim:Relatiesoort[$is-relatiesoort-leidend] | mim:externeKoppelingen/mim:ExterneKoppeling">
    <xsl:variable name="target" select="local:resolve-reference(mim:doel/*)" as="element()"/> <!-- Objecttype, Keuze, Constructie -->
    <xsl:variable name="source-cardinality" select="if (not(mim:kardinaliteitBron = 'TODO')) then local:cardinality(mim:kardinaliteitBron) else local:cardinality(mim-ext:kenmerken/mim-ext:Kenmerk[@naam='kardinaliteitBron'])" as="element(cardinality)"/>
    <xsl:variable name="target-cardinality" select="local:cardinality(mim:kardinaliteit)" as="element(cardinality)"/>
    <xsl:variable name="aggregation" select="mim:aggregatietype" as="xs:string?"/>
    <xsl:variable name="unidirectional" select="mim:unidirectioneel" as="xs:string?"/>
    
    <field>
      <xsl:choose>
        <xsl:when test="self::mim:ExterneKoppeling or local:is-relatiesoort-name-unique(.)">
          <name original="{mim:naam}">{entity:field-name(mim:naam)}</name>
        </xsl:when>
        <xsl:otherwise>
          <!-- Add target name to avoid name collisions: -->
          <name original="{mim:naam}{$target/mim:naam}">{entity:field-name(mim:naam)}{entity:class-name($target/mim:naam)}</name>
        </xsl:otherwise> 
      </xsl:choose>  
      <xsl:variable name="openapi-ref" select="local:kenmerk-ext($target, 'OA Reference')[1]" as="xs:string?"/>
      <xsl:choose>
        <xsl:when test="normalize-space($openapi-ref)">
          <type openapi-ref="{$openapi-ref}"/>
        </xsl:when>
        <xsl:otherwise>
          <type 
            is-enum="false" 
            is-standard="false"
            package-name="{entity:package-name(local:package-hierarchy($target))}"
            model-element="{$target/local-name()}">{entity:class-name($target/mim:naam)}</type>    
        </xsl:otherwise>
      </xsl:choose>
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
      <xsl:apply-templates select="mim-ext:kenmerken" mode="kenmerk"/>
    </field>
  </xsl:template>
  
  <xsl:template match="mim-ext:constructies/mim-ext:Constructie[funct:equals-case-insensitive(mim-ext:constructietype, 'OPENAPI OPERATION')]">
    <openapi-operation>
      <method>{upper-case((local:kenmerk-ext(., 'OA HTTP method'), 'GET')[1])}</method>
      <operation-id>{mim:naam}</operation-id>
      <path>{(local:kenmerk-ext(., 'OA Path'), '/nopath')[1]}</path>
      <xsl:variable name="tag" select="(local:kenmerk-ext(., 'OA Tag'), 'NoTag')[1]" as="xs:string"/>
      <tag>{$tag}</tag>
      <summary>{local:kenmerk-ext(., 'OA Summary')}</summary>
      <description>
        <xsl:sequence select="local:kenmerk-ext(., 'OA Description')"/>
      </description>
      <xsl:where-populated>
        <parameters>
          <xsl:for-each select="mim-ext:bevat/mim-ext:Constructie[mim-ext:constructietype = 'OPENAPI PARAMETER']">
            <xsl:sort select="local:kenmerk-ext(., 'positie')" order="ascending"/>
            <xsl:variable name="parameter-type" select="local:kenmerk-ext(., 'OA Parameter type')" as="xs:string?"/>
            <parameter>
              <name>{mim:naam}</name>
              <type original-type="{mim:type/mim:Datatype}">{map:get($primitive-mim-type-mapping, (mim:type/mim:Datatype, 'CharacterString')[1])}</type> <!-- TODO: support non-standard MIM types? -->
              <parameter-type>{$parameter-type}</parameter-type>
              <cardinality>{mim:kardinaliteit}</cardinality>
              <!--
              <required>{(local:true-or-false(local:kenmerk-ext(., 'OA Required')), 'false')[1]}</required>
              -->
              <required>{local:cardinality(mim:kardinaliteit)/@minOccurs = $ONE}</required>
              <description>
                <xsl:sequence select="local:kenmerk-ext(., 'OA Description')"/>
              </description>
              <example>{local:kenmerk-ext(., 'OA Example')}</example>
              <xsl:apply-templates select="mim-ext:kenmerken" mode="kenmerk"/>
            </parameter>
          </xsl:for-each>
        </parameters>  
      </xsl:where-populated>
      <xsl:where-populated>
        <request-body>
          <xsl:for-each select="mim-ext:bevat/mim-ext:Constructie[mim-ext:constructietype = 'OPENAPI REQUEST BODY']">
            <xsl:for-each select="local:resolve-reference(mim:verwijstNaar/mim-ref:ObjecttypeRef)">
              <name>{mim:naam}</name>
              <package-name>{entity:package-name(local:package-hierarchy(.))}</package-name>  
            </xsl:for-each>
            <is-collection>{ends-with(normalize-space(mim:kardinaliteit), '*')}</is-collection> 
          </xsl:for-each>
        </request-body>  
      </xsl:where-populated>
      <xsl:where-populated>
        <response-body>
          <xsl:for-each select="mim-ext:bevat/mim-ext:Constructie[mim-ext:constructietype = 'OPENAPI RESPONSE BODY']">
            <xsl:for-each select="local:resolve-reference(mim:verwijstNaar/mim-ref:ObjecttypeRef)">
              <name>{mim:naam}</name>
              <package-name>{entity:package-name(local:package-hierarchy(.))}</package-name>  
            </xsl:for-each>
            <!--
            <is-collection>{ends-with(normalize-space(mim:kardinaliteit), '*')}</is-collection>
            -->
            <is-collection>{local:cardinality(mim:kardinaliteit)/@maxOccurs = $unbounded}</is-collection>
          </xsl:for-each>
        </response-body>  
      </xsl:where-populated>
      <xsl:apply-templates select="mim-ext:kenmerken" mode="kenmerk"/>
    </openapi-operation>
  </xsl:template>
  
  <xsl:template match="mim-ext:constructies/mim-ext:Constructie[funct:equals-case-insensitive(mim-ext:constructietype, 'OPENAPI URLS')]">
    <openapi-urls>
      <xsl:for-each select="mim-ext:bevat/mim-ext:Constructie">
        <url alias="{mim:alias}">{mim:naam}</url>  
      </xsl:for-each>
    </openapi-urls>
  </xsl:template>
  
  <xsl:template match="mim-ext:constructies/mim-ext:Constructie[funct:equals-case-insensitive(mim-ext:constructietype, 'OPENAPI TAGS')]">
    <openapi-tags>
      <xsl:for-each select="mim-ext:bevat/mim-ext:Constructie">
        <tag name="{mim:naam}">
          <xsl:for-each select="mim:definitie">
            <xsl:choose>
              <xsl:when test="xhtml:body">
                <xsl:sequence select="xhtml:body"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="text()"/>
              </xsl:otherwise>
            </xsl:choose>  
          </xsl:for-each>
        </tag>  
      </xsl:for-each>
    </openapi-tags>
  </xsl:template>
  
  <xsl:template match="xhtml:*" mode="xhtml">
    <xsl:element name="xhtml:{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="mim-ext:kenmerken" mode="kenmerk">
    <features>
      <xsl:for-each select="mim-ext:Kenmerk">
        <feature name="{@naam}">
          <xsl:sequence select="node()"/>
        </feature>
      </xsl:for-each>
      <xsl:apply-templates/>
    </features>
  </xsl:template>
  
  <xsl:function name="local:kenmerk-ext" as="item()*">
    <xsl:param name="model-element" as="element()"/>
    <xsl:param name="feature-name" as="xs:string"/>
    <xsl:variable 
      name="kenmerken" 
      as="element(mim-ext:Kenmerk)*" 
      select="$model-element/mim-ext:kenmerken/mim-ext:Kenmerk[funct:equals-case-insensitive(@naam, $feature-name)]"/>
    <xsl:for-each select="$kenmerken">
      <xsl:choose>
        <xsl:when test="xhtml:body">
          <xsl:sequence select="xhtml:body"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="text()[normalize-space()]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>
  
  <xsl:function name="local:true-or-false" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:variable name="s" select="lower-case(normalize-space($str))" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$s = ('yes', 'true')">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
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
          <xsl:variable name="openapi-ref" select="local:kenmerk-ext($resolved-element, 'OA Reference')[1]" as="xs:string?"/>
          <xsl:choose>
            <xsl:when test="normalize-space($openapi-ref)">
              <class>
                <openapi-ref>{$openapi-ref}</openapi-ref>
              </class>
            </xsl:when>
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
    <xsl:param name="object-type" as="element(mim:Objecttype)"/>
    <xsl:sequence select="exists($object-type/mim:supertypen/mim:GeneralisatieObjecttypen/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef))"/>
  </xsl:function>
  
  <!-- Is $generalisation-element a mixin or "static" supertype? -->
  <xsl:function name="local:is-mixin" as="xs:boolean">
    <xsl:param name="generalisation-element" as="element(mim:GeneralisatieObjecttypen)"/>
    <xsl:sequence select="exists($generalisation-element[mim:mixin = 'true' or mim-ext:kenmerken/mim-ext:Kenmerk[@naam='type'] = 'GENERALISATIE STATIC'])"/>
  </xsl:function>
    
  <xsl:function name="local:get-all-objecttype-supertypes" as="element(mim:Objecttype)*">
    <xsl:param name="object-type" as="element(mim:Objecttype)?"/>    
    <xsl:variable name="supertypes" select="
      for $o in $object-type/mim:supertypen/mim:GeneralisatieObjecttypen/mim:supertype/mim-ref:ObjecttypeRef
      return local:resolve-reference($o)" as="element(mim:Objecttype)*"/>
    <xsl:sequence select="$supertypes, for $o in $supertypes return local:get-all-objecttype-supertypes($o)"/>
  </xsl:function>
  
  <xsl:function name="local:get-all-datatype-supertypes" as="element()*">
    <xsl:param name="datatype" as="element()?"/>    
    <xsl:variable name="supertypes" select="
      for $d in $datatype/mim:supertypen/mim:GeneralisatieDatatypen/mim:supertype/mim-ref:DatatypeRef
      return local:resolve-reference($d)" as="element()*"/>
    <xsl:sequence select="$supertypes, for $d in $supertypes return local:get-all-datatype-supertypes($d)"/>
  </xsl:function>
  
  <!--
  <xsl:function name="local:get-base-primitief-datatype" as="element(mim:PrimitiefDatatype)?">
    <xsl:param name="primitief-datatype" as="element(mim:PrimitiefDatatype)?"/>    
    <xsl:variable name="supertypes" select="
      for $p in $primitief-datatype/mim:supertypen/mim:GeneralisatieDatatypen/mim:supertype/mim-ref:DatatypeRef
      return local:resolve-reference($p)" as="element(mim:PrimitiefDatatype)*"/>
    <xsl:sequence select="$supertypes, for $p in $supertypes return local:get-all-primitief-datatype-supertypes($p)"/>
  </xsl:function>
  -->
  
  <xsl:function name="local:get-all-gegevensgroeptypes" as="element(mim:Gegevensgroeptype)*">
    <xsl:param name="model-element" as="element()?"/>    
    <xsl:variable name="gegevensgroeptypes" select="
      for $g in $model-element/mim:gegevensgroepen/mim:Gegevensgroep/mim:gegevensgroeptype/mim-ref:GegevensgroeptypeRef
      return local:resolve-reference($g)" as="element(mim:Gegevensgroeptype)*"/>
    <xsl:sequence select="$gegevensgroeptypes, for $g in $gegevensgroeptypes return local:get-all-gegevensgroeptypes($g)"/>
  </xsl:function>
  
  <xsl:function name="local:get-identifying-attribuutsoort-of-objecttype" as="element(mim:Attribuutsoort)?">
    <xsl:param name="object-type" as="element(mim:Objecttype)?"/>    
    <xsl:variable name="self-and-supertypes" select="$object-type, local:get-all-objecttype-supertypes($object-type)" as="element(mim:Objecttype)*"/>
    <xsl:variable name="attribuutsoorten" select="for $o in $self-and-supertypes return 
      ($o/mim:attribuutsoorten/mim:Attribuutsoort, 
      local:get-all-gegevensgroeptypes($o)/mim:attribuutsoorten/mim:Attribuutsoort)" as="element(mim:Attribuutsoort)*"/>
    <xsl:sequence select="($attribuutsoorten[mim:identificerend = 'true'])[1]"/>
  </xsl:function>
  
  <xsl:function name="local:is-relatiesoort-name-unique" as="xs:boolean">    
    <xsl:param name="relatiesoort" as="element(mim:Relatiesoort)"/>
    <xsl:variable name="name" select="$relatiesoort/mim:naam" as="xs:string?"/>
    <xsl:variable name="objecttype" select="$relatiesoort/ancestor::mim:Objecttype" as="element(mim:Objecttype)?"/>
    <xsl:variable name="self-and-supertypes" select="$objecttype, local:get-all-objecttype-supertypes($objecttype)" as="element(mim:Objecttype)*"/>
    <xsl:sequence select="count($self-and-supertypes/mim:relatiesoorten/mim:Relatiesoort[mim:naam = $name]) = 1"/>  
  </xsl:function>
  
  <xsl:function name="local:is-relatierol-doel-name-unique" as="xs:boolean">
    <xsl:param name="relatiesoort" as="element(mim:Relatiesoort)"/>
    <xsl:variable name="name" select="$relatiesoort/mim:relatierollen/mim:Doel/mim:naam" as="xs:string?"/>
    <xsl:variable name="objecttype" select="$relatiesoort/ancestor::mim:Objecttype" as="element(mim:Objecttype)?"/>
    <xsl:variable name="self-and-supertypes" select="$objecttype, local:get-all-objecttype-supertypes($objecttype)" as="element(mim:Objecttype)*"/>
    <xsl:sequence select="count($self-and-supertypes/mim:relatiesoorten/mim:Relatiesoort[mim:relatierollen/mim:Doel/mim:naam = $name]) = 1"/>  
  </xsl:function>
  
  <xsl:function name="local:attribuutsoort-kenmerk" as="xs:string?">
    <xsl:param name="model-element" as="element()?"/>
    <xsl:param name="feature-name" as="xs:string"/>
    <xsl:variable name="direct-value" select="($model-element/*[funct:equals-case-insensitive(local-name(), $feature-name)]/text()[normalize-space()])[1]" as="xs:string?"/>
    <xsl:variable name="primitief-datatype" select="$model-element/mim:type/mim-ref:DatatypeRef/local:resolve-reference(.)/self::mim:PrimitiefDatatype" as="element(mim:PrimitiefDatatype)?"/>
    <xsl:choose>
      <xsl:when test="empty($model-element)"/>
      <xsl:when test="exists($direct-value)">{$direct-value}</xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="(($primitief-datatype, local:get-all-datatype-supertypes($primitief-datatype))/*[funct:equals-case-insensitive(local-name(), $feature-name)]/text()[normalize-space()])[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="local:attribuutsoort-kenmerk-lengte" as="map(xs:string, xs:string)?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:variable name="length" select="local:attribuutsoort-kenmerk($model-element, 'lengte')" as="xs:string?"/>
    <xsl:variable name="l" select="translate($length, ' ', '')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="not(normalize-space($l))"/>
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
            <xsl:map-entry key="'min-value'" select="xs:string($result/fn:match/fn:group[@nr='1'])"/>
            <xsl:map-entry key="'max-value'" select="xs:string($result/fn:match/fn:group[@nr='2'])"/>
          </xsl:map>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="local:attribuutsoort-kenmerk-formeel-patroon" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:attribuutsoort-kenmerk($model-element, 'formeelPatroon')"/>
  </xsl:function>
  
  <xsl:function name="local:attribuutsoort-kenmerk-minimumwaarde-inclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:attribuutsoort-kenmerk($model-element, 'minimumwaardeInclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:attribuutsoort-kenmerk-minimumwaarde-exclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:attribuutsoort-kenmerk($model-element, 'minimumwaardeExclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:attribuutsoort-kenmerk-maximumwaarde-inclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:attribuutsoort-kenmerk($model-element, 'maximumwaardeInclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:attribuutsoort-kenmerk-maximumwaarde-exclusief" as="xs:string?">
    <xsl:param name="model-element" as="element()"/>
    <xsl:sequence select="local:attribuutsoort-kenmerk($model-element, 'maximumwaardeExclusief')"/>
  </xsl:function>
  
  <xsl:function name="local:definition-as-string" as="xs:string?">
    <xsl:param name="definition" as="element()?"/>
    <xsl:if test="$definition">
      <xsl:variable name="text" select="normalize-space(string-join($definition//text(), ' '))" as="xs:string"/>
      <xsl:sequence select="if (string-length($text) gt 0) then $text else ()"/>    
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="local:get-tag-description" as="xs:string">
    <xsl:param name="context" as="node()"/>
    <xsl:param name="tag-name" as="xs:string?"/>
    <xsl:sequence select="$context//mim:Enumeratie[funct:equals-case-insensitive(mim:naam, 'Tags')]/mim:waarden/mim:Waarde[funct:equals-case-insensitive(mim:naam, 'Tags')]"/>
  </xsl:function>
  
  <xsl:function name="imf:message" as="empty-sequence()" use-when="$runs-in-imvertor-context">
    <xsl:param name="this" as="node()*"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="info" as="item()*"/>
    <xsl:param name="wiki" as="xs:string"/>
    <xsl:sequence select="imf:msg($this, $type, $text, $info, $wiki)"/>
  </xsl:function>
  
  <xsl:function name="imf:message" as="empty-sequence()" use-when="not($runs-in-imvertor-context)">
    <xsl:param name="this" as="node()*"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="info" as="item()*"/>
    <xsl:param name="wiki" as="xs:string"/>
    <xsl:message select="$type || ': ' || $text || ', ' || $info || '(' || $wiki || ')'"/>
  </xsl:function>
  
  <xsl:template name="attribuutsoort-kenmerken">
    <xsl:variable name="length-map" select="local:attribuutsoort-kenmerk-lengte(.)" as="map(xs:string, xs:string)?"/>
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
      <formal-pattern>{local:attribuutsoort-kenmerk-formeel-patroon(.)}</formal-pattern>
    </xsl:where-populated>
    <xsl:where-populated>
      <min-incl>{local:attribuutsoort-kenmerk-minimumwaarde-inclusief(.)}</min-incl>
    </xsl:where-populated>
    <xsl:where-populated>
      <min-excl>{local:attribuutsoort-kenmerk-minimumwaarde-exclusief(.)}</min-excl>
    </xsl:where-populated>
    <xsl:where-populated>
      <max-incl>{local:attribuutsoort-kenmerk-maximumwaarde-inclusief(.)}</max-incl>
    </xsl:where-populated>
    <xsl:where-populated>
      <max-excl>{local:attribuutsoort-kenmerk-maximumwaarde-exclusief(.)}</max-excl>
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