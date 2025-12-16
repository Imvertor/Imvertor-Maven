<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:mim-in="http://www.geostandaarden.nl/mim/mim-core/1.2" 
  xmlns:mim="http://modellen.mim-standaard.nl/def/mim#" 
  xmlns:mim-ref="http://www.geostandaarden.nl/mim/mim-ref/1.0"
  xmlns:mim-ext="http://www.geostandaarden.nl/mim/mim-ext/1.0"
  xmlns:mm="http://imvertor.nl/mim/metamodel" 
  xmlns:ext="http://www.imvertor.org/xsl/extensions"
  xmlns:local="urn:local"
  extension-element-prefixes="ext"
  exclude-result-prefixes="xsl xs map xlink xhtml mim-in mim-ref mim-ext mm local"
  expand-text="yes"
  version="3.0">
  
  <!--
  TODO:
  Constructie / constructietype  
  begrip vs begripsterm? 
  -->
  
  <xsl:output indent="yes"/>
  
  <xsl:key name="id" match="*[@id]" use="@id"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="merge-metamodel" on-no-match="shallow-copy"/>
  <xsl:mode name="instrument" on-no-match="shallow-copy"/>
  <xsl:mode name="metagegeven" on-no-match="shallow-skip"/>
  <xsl:mode name="uuid" on-no-match="shallow-copy"/>
  
  <xsl:param name="generate-uuids" as="xs:boolean" select="true()"/>
    
  <xsl:variable name="is-imvertor-context" select="function-available('ext:imvertorGetUUID')" as="xs:boolean" static="true"/>
  <xsl:variable name="is-werkbank-context" select="function-available('ext:uuid')" as="xs:boolean" static="true"/>  
    
  <xsl:variable name="relatiemodelleringstype" select="/*/mim-in:relatiemodelleringstype" as="xs:string"/>
  <xsl:variable name="gen-uuids" select="$generate-uuids and ($is-imvertor-context or $is-werkbank-context)" as="xs:boolean"/>
  <xsl:variable name="urn-prefix" select="if ($gen-uuids) then 'urn:uuid:' else '#'" as="xs:string"/>
  <xsl:variable name="rdf-retain-xhtml" select="true()"/><!-- TODO instelbaar -->
  <xsl:variable name="mim-uri" select="'http://modellen.mim-standaard.nl/def/mim#'" as="xs:string"/>
  <xsl:variable name="base-uri" select="'http://imvertor.nl/base'" as="xs:string"/>
  <xsl:variable name="uuid-pattern" as="xs:string">^[0-9a-f]{{8}}-[0-9a-f]{{4}}-[0-5][0-9a-f]{{3}}-[089ab][0-9a-f]{{3}}-[0-9a-f]{{12}}$</xsl:variable>
 
  <xsl:variable name="uuid-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:if test="$gen-uuids">
        <xsl:for-each select="//@id">
          <xsl:map-entry key="xs:string(.)" select="if (matches(., $uuid-pattern, 'i')) then xs:string(.) else local:generate-uuid()"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:map>  
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:variable name="metamodel" select="document('MIM1.2-model-RDF.xml')" as="document-node()" use-when="$is-imvertor-context"/>
    <xsl:variable name="metamodel" select="document('../xml/mim-modeldefinitie-rdf-1.2.xml')" as="document-node()" use-when="$is-werkbank-context"/>
    <xsl:variable name="metamodel" use-when="not($is-werkbank-context) and not($is-imvertor-context)" as="document-node()">
      <xsl:document/>
    </xsl:variable>
    <xsl:variable name="merged-metamodel" as="document-node()">
      <xsl:apply-templates select="$metamodel" mode="merge-metamodel"/>
    </xsl:variable>
    <xsl:variable name="uuid-mim-xml" as="document-node()">
      <xsl:choose>
        <xsl:when test="$gen-uuids">
          <xsl:apply-templates select="." mode="uuid"/>    
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="instrumented-mim-xml" as="document-node()">
      <xsl:apply-templates select="$uuid-mim-xml" mode="instrument">
        <xsl:with-param name="metamodel" select="$merged-metamodel/*" as="element()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <rdf:RDF>
      <xsl:if test="not($gen-uuids)">
        <xsl:attribute name="xml:base">{$base-uri}</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="$instrumented-mim-xml/*"/>
    </rdf:RDF>
  </xsl:template>
  
  <xsl:template match="*[@mm:nodeType = 'modelelement']" priority="1.0">
    <rdf:Description rdf:about="{local:get-id(.)}">
      <rdf:type rdf:resource="{$mim-uri}{(@mm:rdfName, local-name())[1]}"/>
      <xsl:next-match/>
      <xsl:for-each select="mim-ext:kenmerken/mim-ext:Kenmerk">
        <mim:kenmerk rdf:resource="{local:get-id(.)}"/>
      </xsl:for-each>
      <xsl:apply-templates select="*[@mm:nodeType='metagegeven']" mode="metagegeven"/>
    </rdf:Description>
    <xsl:apply-templates select="*[@mm:nodeType = 'wrapper']"/>
  </xsl:template>
  
  <xsl:template match="*[@mm:nodeType = 'modelelement']" priority="-1.0"/>
  
  <!-- Binding metagegevens: -->
  <xsl:template match="mim-in:Informatiemodel|mim-in:Domein|mim-in:View|mim-in:Extern">
    <xsl:for-each select="(mim-in:packages|mim-in:datatypen|mim-in:objecttypen|mim-in:gegevensgroeptypen|mim-in:keuzen|mim-ext:constructies)/*">
      <mim:bevatModelelement rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:Gegevensgroep">
    <xsl:for-each select="mim-in:gegevensgroeptype/mim-ref:GegevensgroeptypeRef">
      <!-- TODO: genereer gegevensgroeptype, type of beide?: -->
      <mim:gegevensgroeptype rdf:resource="{local:get-id(local:resolve-reference(.))}"/> 
      <mim:type rdf:resource="{local:get-id(local:resolve-reference(.))}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:Gegevensgroeptype">
    <xsl:for-each select="mim-in:attribuutsoorten/mim-in:Attribuutsoort">
      <mim:attribuut rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
    <xsl:for-each select="mim-in:gegevensgroepen/mim-in:Gegevensgroep">
      <mim:gegevensgroep rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:Objecttype">
    <xsl:for-each select="mim-in:attribuutsoorten/mim-in:Attribuutsoort">
      <mim:attribuut rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
    <xsl:for-each select="mim-in:gegevensgroepen/mim-in:Gegevensgroep">
      <mim:gegevensgroep rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
    <xsl:for-each select="mim-in:keuzen/mim-ref:KeuzeRef">
      <!-- TODO: genereer attribuutkeuze, attribuut of beide?: -->
      <mim:attribuutkeuze rdf:resource="{local:get-id(local:resolve-reference(.))}"/>
      <mim:attribuut rdf:resource="{local:get-id(local:resolve-reference(.))}"/>
    </xsl:for-each>
    <xsl:for-each select="mim-ext:constructies/mim-ext:Constructie">
      <mim:constructie rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:Attribuutsoort|mim-in:ReferentieElement|mim-in:DataElement">
    <mim:type>
      <xsl:attribute name="rdf:resource">
        <xsl:choose>
          <xsl:when test="mim-in:type/mim-in:Datatype">{$mim-uri}{mim-in:type/mim-in:Datatype}</xsl:when>
          <xsl:when test="mim-in:type/*/@xlink:href">{local:get-id-from-href(mim-in:type/*/@xlink:href)}</xsl:when>
        </xsl:choose>  
      </xsl:attribute>
    </mim:type>
  </xsl:template>
  
  <xsl:template match="mim-in:GestructureerdDatatype">
    <xsl:for-each select="mim-in:dataElementen/mim-in:DataElement">
      <mim:dataElement rdf:resource="{local:get-id(.)}"/> 
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:Referentielijst">
    <xsl:for-each select="mim-in:referentieElementen/mim-in:ReferentieElement">
      <mim:referentieElement rdf:resource="{local:get-id(.)}"/> 
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:Enumeratie">
    <xsl:for-each select="mim-in:waarden/mim-in:Waarde">
      <mim:waarde rdf:resource="{local:get-id(.)}"/> 
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="mim-in:Keuze">
    <xsl:for-each select="mim-in:keuzeAttributen/mim-in:Attribuutsoort">
      <mim:attribuut rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
    <xsl:for-each select="mim-in:keuzeDatatypen/*">
      <mim:type>
        <xsl:attribute name="rdf:resource">
          <xsl:choose>
            <xsl:when test="mim-in:Datatype">{$mim-uri}{mim-in:Datatype}</xsl:when>
            <xsl:when test="@xlink:href">{local:get-id-from-href(@xlink:href)}</xsl:when>
          </xsl:choose>  
        </xsl:attribute>
      </mim:type>
    </xsl:for-each>
    <xsl:for-each select="mim-in:keuzeRelatiedoelen/mim-in:Relatiedoel">
      <mim:doel rdf:resource="{local:get-id(local:resolve-reference(*))}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:GeneralisatieObjecttypen|mim-in:GeneralisatieDatatypen">
    <mim:subtype rdf:resource="{local:get-id(ancestor::mim-in:*[@mm:nodeType='modelelement'][1])}"/>
    <mim:supertype>
      <xsl:attribute name="rdf:resource">
        <xsl:choose>
          <xsl:when test="mim-in:supertype/mim-in:Datatype">{$mim-uri}{mim-in:supertype/mim-in:Datatype}</xsl:when>
          <xsl:otherwise>{local:get-id-from-href(mim-in:supertype/mim-ref:*/@xlink:href)}</xsl:otherwise>
        </xsl:choose>  
      </xsl:attribute>
    </mim:supertype>
  </xsl:template>
  
  <xsl:template match="mim-in:Relatiesoort">
    <xsl:for-each select="mim-in:relatierollen/(mim-in:Bron|mim-in:Doel)">
      <mim:relatierol rdf:resource="{local:get-id(.)}"/>  
    </xsl:for-each>
    <mim:bron rdf:resource="{local:get-id(ancestor::mim-in:Objecttype[1]|ancestor::mim-in:Gegevensgroeptype[1])}"/>  
    <xsl:for-each select="mim-in:doel">
      <mim:doel rdf:resource="{local:get-id(local:resolve-reference(*))}"/>  
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:ExterneKoppeling">
    <!-- TODO: implement:
    <mim:relatierol rdf:resource=""/>
    -->
    <mim:bron rdf:resource="{local:get-id(ancestor::mim-in:Objecttype[1]|mim-in:Gegevensgroeptype[1])}"/>
    <xsl:for-each select="mim-in:doel">
      <mim:doel rdf:resource="{local:get-id(local:resolve-reference(*))}"/>  
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-in:Relatieklasse">
    <mim:bron rdf:resource="{local:get-id(ancestor::mim-in:Objecttype[1])}"/> <!-- Containing Objecttype -->
    <xsl:for-each select="ancestor::mim-in:Relatiesoort[1]/mim-in:doel">
      <mim:doel rdf:resource="{local:get-id(local:resolve-reference(*))}"/> <!-- mim:doel/mim-ref:ObjecttypeRef van containing relatiesoort -->  
    </xsl:for-each>
    <xsl:for-each select="ancestor::mim-in:Relatiesoort[1]/mim-in:relatierollen/mim-in:Doel">
      <mim:relatiedoel rdf:resource="{local:get-id(.)}"/> <!-- mim:relatierollen/mim:Doel van containing relatiesoort -->  
    </xsl:for-each>
    <xsl:for-each select="mim-in:gegevensgroepen/mim-in:Gegevensgroep">
      <mim:gegevensgroep rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
    <xsl:for-each select="mim-in:attribuutsoorten/mim-in:Attribuutsoort">
      <mim:attribuut rdf:resource="{local:get-id(.)}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim-ext:Kenmerk">
    <mim:naam>{@naam}</mim:naam>
    <mim:waarde>{.}</mim:waarde>
  </xsl:template>
      
  <!-- Non-binding metagegevens: -->  
  <xsl:template match="mim-in:type|mim-in:gegevensgroeptype|mim-in:supertype|mim-in:doel|mim-in:keuzeDatatypen|mim-in:keuzeRelatiedoelen" mode="metagegeven" priority="1.0"/>
      
  <xsl:template match="*[@mm:nodeType = 'metagegeven' and not(@mm:rdfBinding)]" mode="metagegeven">    
    <xsl:element name="mim:{(@mm:rdfName, local-name())[1]}">
      <xsl:if test="@mm:rdfType">
        <xsl:attribute name="rdf:datatype" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" select="'http://www.w3.org/2001/XMLSchema#' || @mm:rdfType"/>  
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
    
  <xsl:template match="mim-in:relatiemodelleringstype" mode="metagegeven">  
    <mim:relatiemodelleringstype rdf:resource="{$mim-uri}{map:get($relatiemodelleringstype-mapping, .)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:informatiemodeltype" mode="metagegeven">  
    <mim:informatiemodeltype rdf:resource="{$mim-uri}{map:get($informatiemodeltype-mapping, .)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:authentiek" mode="metagegeven">
    <mim:authentiek rdf:resource="{$mim-uri}{map:get($authentiek-mapping, .)}"/>  
  </xsl:template>
  
  <xsl:template match="mim-in:aggregatietype" mode="metagegeven">
    <mim:aggregatietype rdf:resource="{$mim-uri}{map:get($aggregatietype-mapping, .)}"/>
  </xsl:template>
   
  <xsl:template match="(mim-in:definitie|mim-in:toelichting)[.//text()[normalize-space()]]" mode="metagegeven" priority="1.0">
    <xsl:choose>
      <xsl:when test="$rdf-retain-xhtml">
        <xsl:variable name="html">
          <xsl:apply-templates mode="xhtml"/>
        </xsl:variable>
        <xsl:element name="mim:{local-name()}">
          <xsl:text>{normalize-space(serialize($html, $output-parameters))}</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="mim:{local-name()}">{.}</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="xhtml:*" mode="xhtml" priority="10">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*" mode="xhtml">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="text()[not(normalize-space())]" mode="xhtml"/>
        
  <xsl:function name="local:get-id-from-href" as="xs:string">
    <xsl:param name="href" as="xs:string"/>
    <xsl:value-of select="$urn-prefix || encode-for-uri(substring($href, 2))"/>
  </xsl:function>
  
  <xsl:function name="local:resolve-reference" as="element()?">
    <xsl:param name="ref-element" as="element()?"/>
    <xsl:sequence select="if (empty($ref-element)) then () else key('id', substring($ref-element/@xlink:href, 2), $ref-element/root())"/>
  </xsl:function>
  
  <xsl:function name="local:get-id" as="xs:string">
    <xsl:param name="elem" as="element()"/>
    <xsl:choose>
      <xsl:when test="$elem/@id">
        <xsl:value-of select="$urn-prefix || encode-for-uri($elem/@id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$urn-prefix || encode-for-uri(generate-id($elem))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="local:generate-uuid" as="xs:string" use-when="$is-werkbank-context">
    <xsl:value-of select="ext:uuid()"/>
  </xsl:function>
  
  <xsl:function name="local:generate-uuid" as="xs:string" use-when="$is-imvertor-context">
    <xsl:value-of select="ext:imvertorGetUUID()"/>
  </xsl:function>
  
  <xsl:function name="local:generate-uuid" as="xs:string" use-when="not($is-werkbank-context) and not($is-imvertor-context)">{''}</xsl:function>
  
  <xsl:template match="@id" mode="uuid">
    <xsl:attribute name="id" select="map:get($uuid-mapping, .)"/>
  </xsl:template>
  
  <xsl:template match="@xlink:href" mode="uuid">
    <xsl:attribute name="xlink:href" select="'#' || map:get($uuid-mapping, substring(., 2))"/>
  </xsl:template>
  
  <xsl:template match="mim-ext:Kenmerk" mode="uuid">
    <xsl:copy>
      <xsl:attribute name="id" select="local:generate-uuid()"/>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*" mode="merge-metamodel">   
    <metamodel>      
      <xsl:apply-templates select="/*/structuur/*" mode="#current"/>
    </metamodel>
  </xsl:template>
  
  <xsl:template match="*" mode="merge-metamodel">
    <xsl:copy>
      <xsl:variable name="context" select="." as="element()"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:variable name="element" select="/*/elementen/*[local-name() = $context/local-name() and namespace-uri() = $context/namespace-uri()]" as="element()*"/>
      <xsl:if test="empty($element)">
        <xsl:message terminate="yes">No element found for {name()}</xsl:message>
      </xsl:if>
      <xsl:if test="count($element) gt 1">
        <xsl:message terminate="yes"><text>More than one element found for {name()}</text><xsl:sequence select="$element"/></xsl:message>
      </xsl:if>
      <xsl:apply-templates select="$element/(@*|node())" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mim-in:*|mim-ext:*|mim-ref:*" mode="instrument">
    <xsl:param name="metamodel" as="element()" tunnel="yes"/>
    <xsl:variable name="template" select="$metamodel/*[(local-name() = local-name(current())) and (not(@mm:rmtVariant) or (@mm:rmtVariant = $relatiemodelleringstype))]"/>
    <xsl:variable name="context" select="."/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:choose>
        <xsl:when test="$template[@mm:nodeType = 'modelelement']">
          <xsl:apply-templates select="$template/@*" mode="#current"/>
          <xsl:for-each select="$template/*">
            <xsl:variable name="template-elem" select="."/>
            <xsl:variable name="model-elem" select="$context/*[local-name() = local-name($template-elem)]"/>      
            <xsl:if test="$model-elem[* or normalize-space()] or ($template-elem/@mm:minOccurs = '1')">
              <!-- Create an element when the model element has a value or its a required metagegeven: -->
              <xsl:copy>
                <xsl:apply-templates select="$model-elem/@*" mode="#current"/>
                <xsl:copy-of select="$template-elem/@*"/>
                <xsl:choose>
                  <xsl:when test="$model-elem[* or normalize-space()]">
                    <!-- Copy the data of the model element: -->
                    <xsl:apply-templates select="$model-elem/node()" mode="#current"/>
                  </xsl:when>
                  <xsl:when test="$template-elem[* or normalize-space()]">
                    <!-- Copy the data of the template element: -->
                    <xsl:apply-templates select="$template-elem/node()" mode="#current"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Create a static text: -->
                    <xsl:text></xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:copy>
            </xsl:if>
          </xsl:for-each> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mim-ext:Kenmerk" mode="instrument">
    <xsl:copy>
      <xsl:attribute name="mm:nodeType">modelelement</xsl:attribute>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:sequence select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:variable name="relatiemodelleringstype-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'Relatiesoort leidend'" select="'RelatiesoortLeidend'"/>
      <xsl:map-entry key="'Relatierol leidend'" select="'RelatierolLeidend'"/>
    </xsl:map>
  </xsl:variable>
  
  <xsl:variable name="informatiemodeltype-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'Conceptueel'" select="'ConceptueelInformatiemodel'"/>
      <xsl:map-entry key="'Logisch'" select="'LogischInformatiemodel'"/>
      <xsl:map-entry key="'Technisch'" select="'TechnischInformatiemodel'"/>
    </xsl:map>
  </xsl:variable>
  
  <xsl:variable name="authentiek-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'Authentiek'" select="'Authentiek'"/>
      <xsl:map-entry key="'Basisgegeven'" select="'Basisgegeven'"/>
      <xsl:map-entry key="'Wettelijk gegeven'" select="'WettelijkGegeven'"/>
      <xsl:map-entry key="'Landelijk kerngegeven'" select="'LandelijkKerngegeven'"/>
      <xsl:map-entry key="'Overig'" select="'OverigeAuthenticiteit'"/>
    </xsl:map>
  </xsl:variable>
  
  <xsl:variable name="aggregatietype-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'Compositie'" select="'Geen'"/>
      <xsl:map-entry key="'Gedeeld'" select="'Gedeeld'"/>
      <xsl:map-entry key="'Geen'" select="'Compositie'"/>
    </xsl:map>
  </xsl:variable>
  
  <xsl:variable name="output-parameters" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" as="element(output:serialization-parameters)">
    <output:serialization-parameters>
      <output:indent value="no"/>
      <output:omit-xml-declaration value="yes"/>
    </output:serialization-parameters>
  </xsl:variable>
  
</xsl:stylesheet>