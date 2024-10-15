<?xml version="1.0" encoding="UTF-8"?>
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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:mim-in="http://www.geostandaarden.nl/mim/mim-core/1.1" 
  xmlns:mim="http://www.geostandaarden.nl/mim/mim-core/1.1#" 
  xmlns:mim-ref="http://www.geostandaarden.nl/mim/mim-ref/1.0"
  xmlns:mim-ext="http://www.geostandaarden.nl/mim/mim-ext/1.0"
  xmlns:local="urn:local"
  exclude-result-prefixes="xsl xs xlink mim-in mim-ref mim-ext local"
  expand-text="yes"
  version="3.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="metagegeven" on-no-match="shallow-skip"/>
  
  <!--
  <xsl:variable name="urn-prefix" as="xs:string">urn:mim:id:</xsl:variable>
  -->
  
  <xsl:variable name="urn-prefix" as="xs:string">uuid:</xsl:variable>
  
  <xsl:variable name="output-parameters" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" as="element(output:serialization-parameters)">
    <output:serialization-parameters>
      <output:indent value="no"/>
      <output:omit-xml-declaration value="yes"/>
    </output:serialization-parameters>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:comment>=========================================================================================
Dit bestand bevat een RDF/XML serialisatie van een informatiemodel dat is gemodelleerd 
volgens de "Metamodel Informatie Modellering (MIM)" standaard versie 1.1.

NB. Het formaat van deze RDF/XML serialisatie is nog in ontwikkeling en zal pas definitief 
worden gemaakt na het verschijnen van volgende versie van de MIM standaard. De kans is dus 
groot dat er de komende tijd wijzigingen zullen worden doorgevoerd in dit formaat.

Zie: https://docs.geostandaarden.nl/mim/mim/ voor de laatste versie van de standaard.
=============================================================================================</xsl:comment>
    <rdf:RDF>
      <xsl:apply-templates/>
    </rdf:RDF>
  </xsl:template>
  
  <xsl:template match="mim-ext:Constructie"/>
  
  <xsl:template match="mim-in:Informatiemodel|mim-in:Domein|mim-in:View|mim-in:Extern|mim-in:Attribuutsoort|mim-in:Objecttype|mim-in:Gegevensgroep|mim-in:Gegevensgroeptype|
    mim-in:PrimitiefDatatype|mim-in:GestructureerdDatatype|mim-in:Enumeratie|mim-in:Referentielijst|mim-in:Codelijst|mim-in:DataElement|mim-in:Enumeratiewaarde|
    mim-in:ReferentieElement|mim-in:Constraint|mim-in:Keuze|mim-in:ExterneKoppeling|mim-in:Interface"> <!-- mim-in:Relatieklasse mim-in:Relatiesoort -->
    <xsl:element name="mim:{local-name()}">
      <xsl:attribute name="rdf:about" select="local:get-id(.)"/>  
      <xsl:apply-templates select="mim-in:*[xhtml:* or (not(*) and normalize-space())]" mode="metagegeven"/>
      <xsl:apply-templates select="(mim-in:packages|mim-in:datatypen|mim-in:objecttypen|mim-in:gegevensgroeptypen|mim-in:keuzen|mim-in:interfaces|mim-in:attribuutsoorten|
        mim-in:gegevensgroepen|mim-in:externeKoppelingen|mim-in:constraints|mim-in:dataElementen|mim-in:enumeratiewaarden|mim-in:referentieElementen|mim-in:relatiedoelen|
        mim-in:type|mim-in:gegevensgroepType)/*" mode="metagegeven"/>
    </xsl:element>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="mim-in:Domein" mode="metagegeven">
    <mim:domein rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:View" mode="metagegeven">
    <mim:view rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Extern" mode="metagegeven">
    <mim:extern rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Objecttype" mode="metagegeven">
    <mim:objecttype rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Attribuutsoort" mode="metagegeven">
    <mim:attribuutsoort rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Gegevensgroep" mode="metagegeven">
    <mim:gegevensgroep rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Gegevensgroeptype" mode="metagegeven">
    <mim:gegevensgroeptype rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:PrimitiefDatatype" mode="metagegeven">
    <mim:primitiefDatatype rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:GestructureerdDatatype" mode="metagegeven">
    <mim:gestructureerdDatatype rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:DataElement" mode="metagegeven">
    <mim:dataElement rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Enumeratie" mode="metagegeven">
    <mim:enumeratie rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Enumeratiewaarde" mode="metagegeven">
    <mim:enumeratiewaarde rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Codelijst" mode="metagegeven">
    <mim:codelijst rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Referentielijst" mode="metagegeven">
    <mim:referentielijst rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:ReferentieElement" mode="metagegeven">
    <mim:referentieElement rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Keuze" mode="metagegeven">
    <mim:keuze rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:Interface" mode="metagegeven">
    <mim:interface rdf:resource="{local:get-id(.)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:type/mim-ref:DatatypeRef|mim-in:type/mim-ref:InterfaceRef|mim-in:type/mim-ref:KeuzeRef" mode="metagegeven">
    <mim:type rdf:resource="{local:get-id-from-href(@xlink:href)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:keuzen/mim-ref:KeuzeRef" mode="metagegeven">
    <mim:keuze rdf:resource="{local:get-id-from-href(@xlink:href)}"/>
  </xsl:template>
  
  <xsl:template match="mim-ref:GegevensgroeptypeRef" mode="metagegeven">
    <mim:gegevensgroeptype rdf:resource="{local:get-id-from-href(@xlink:href)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:relatiedoelen/mim-in:Relatiedoel" mode="metagegeven">
    <mim:relatiedoel rdf:resource="{local:get-id-from-href(mim-ref:*/@xlink:href)}"/>
  </xsl:template>
  
  <xsl:template match="mim-in:RelatiesoortRelatiesoortLeidend|mim-in:RelatiesoortRelatierolLeidend">
    <mim:Relatiesoort rdf:about="{local:get-id(.)}">
      <xsl:apply-templates select="mim-in:*[xhtml:* or (not(*) and normalize-space())]" mode="metagegeven"/>
      <mim:bron rdf:resource="{local:get-id((ancestor::mim-in:Objecttype[1]|ancestor::mim-ext:Constructie[1])[1])}"/>
      <mim:doel rdf:resource="{local:get-id-from-href(mim-in:doel/mim-ref:*/@xlink:href)}"/>
      <xsl:apply-templates select="(mim-in:relatierolBron, mim-in:relatierolDoel, mim-in:relatieklasse)/*"/>
    </mim:Relatiesoort>
  </xsl:template>
  
  <xsl:template match="mim-in:RelatierolBron">
    <xsl:where-populated>
      <mim:relatierol>
        <xsl:where-populated>
          <mim:RelatierolBron rdf:about="{local:get-id(.)}">
            <xsl:apply-templates select="mim-in:*[xhtml:* or (not(*) and normalize-space())]" mode="metagegeven"/>
          </mim:RelatierolBron>  
        </xsl:where-populated>
      </mim:relatierol>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template match="mim-in:RelatierolDoel">
    <xsl:where-populated>
      <mim:relatierol>
        <xsl:where-populated>
          <mim:RelatierolDoel rdf:about="{local:get-id(.)}">
            <xsl:apply-templates select="mim-in:*[xhtml:* or (not(*) and normalize-space())]" mode="metagegeven"/>
          </mim:RelatierolDoel>  
        </xsl:where-populated>
      </mim:relatierol>
    </xsl:where-populated>
  </xsl:template>
  
  <xsl:template match="mim-in:Relatieklasse">
      <xsl:where-populated>
        <mim:Relatieklasse rdf:about="{local:get-id(.)}">
          <xsl:apply-templates select="mim-in:*[xhtml:* or (not(*) and normalize-space())]" mode="metagegeven"/>
          <xsl:apply-templates select="(mim-in:attribuutsoorten, mim-in:gegevensgroepen, mim-in:constraints)/*" mode="metagegeven"/>
        </mim:Relatieklasse>  
      </xsl:where-populated>
  </xsl:template>
  
  <xsl:template match="(mim-in:GeneralisatieObjecttypes|mim-in:GeneralisatieDatatypes)[mim-in:supertype/mim-ref:*]">
    <mim:Generalisatie rdf:about="{local:get-id(.)}">
      <xsl:apply-templates select="mim-in:*[xhtml:* or (not(*) and normalize-space())]" mode="metagegeven"/>
      <mim:subtype rdf:resource="{local:get-id(ancestor::mim-in:*[@id][1])}"/>
      <mim:supertype rdf:resource="{local:get-id-from-href(mim-in:supertype/mim-ref:*/@xlink:href)}"/>
    </mim:Generalisatie>
  </xsl:template>
  
  <xsl:template match="(mim-in:definitie|mim-in:toelichting)[.//text()[normalize-space()]]" mode="metagegeven">
    <xsl:variable name="html">
      <xsl:apply-templates mode="xhtml"/>
    </xsl:variable>
    <xsl:element name="mim:{local-name()}">{serialize($html, $output-parameters)}</xsl:element>
  </xsl:template>
  
  <xsl:template match="xhtml:*" mode="xhtml" priority="10">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*" mode="xhtml">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="text()[not(normalize-space())]" mode="xhtml"/>
    
  <xsl:template match="mim-in:*[not(*) and normalize-space()]" mode="metagegeven" priority="0.1">
    <xsl:element name="mim:{local-name()}">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="local:get-id-from-href" as="xs:string">
    <xsl:param name="href" as="xs:string"/>
    <xsl:value-of select="$urn-prefix || substring($href, 2)"/>
  </xsl:function>
  
  <xsl:function name="local:get-id" as="xs:string">
    <xsl:param name="elem" as="element()"/>
    <xsl:choose>
      <xsl:when test="$elem/mim-in:model-id">
        <xsl:value-of select="$urn-prefix || $elem/mim-in:model-id"/>
      </xsl:when>
      <xsl:when test="$elem/@id">
        <xsl:value-of select="$urn-prefix || $elem/@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$urn-prefix || generate-id($elem)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>