<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
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
    This stylesheet generates a CSV for Stelselcatalogus: tab Gegevenselementen     
  -->

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  
  <xsl:import href="StcCompiler-common.xsl"/>
  
  <xsl:variable name="stylesheet-code">STCCOMPILER</xsl:variable>
  <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>

  <xsl:variable name="headers" as="xs:string">
    Registratielabel,
    Clusterbegrip (URI),
    Begrip,
    Begrip (URI),
    Definitie,
    Toelichting,
    Populatie,
    Herkomst,
    Herkomst (URI),
    Eigenaar,
    Eigenaar (URI),
    Wetgeving,
    Wetgeving (URI),
    Authentiek,
    AuthentiekRelatie (URI),
    Relaties,
    Relaties (URI),
    Kwaliteit
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:apply-templates select="/imvert:packages"/>
  </xsl:template>
  
  <xsl:template match="/imvert:packages">
    <sheet>
      <r>
        <xsl:for-each select="tokenize($headers,',\s*')">
          <c>{.}</c>
        </xsl:for-each>
      </r>
      <xsl:apply-templates select="imvert:package/imvert:class[imvert:stereotype/@id = 'stereotype-name-objecttype']"/>
    </sheet>
  </xsl:template>
  
  <xsl:template match="imvert:class">
    <xsl:variable name="relaties" as="xs:string*">
      <xsl:for-each select="imvert:associations/imvert:association[
        (imvert:stereotype/@id = 'stereotype-name-relatiesoort') 
        or 
        (imvert:target/imvert:stereotype/@id = 'stereotype-name-relation-role')]
      ">
        <xsl:value-of select="imf:formatted-name((imvert:name,imvert:target/imvert:role)[1]/@original)"/>
      </xsl:for-each>
    </xsl:variable>
    <r>
      <xsl:sequence select="imf:col('Registratielabel',imf:get-config-string('appinfo','model-abbreviation'))"/>
      <xsl:sequence select="imf:col('Clusterbegrip (URI)',$empty)"/>
      <xsl:sequence select="imf:col('Begrip',imf:formatted-name(imvert:name/@original))"/>
      <xsl:sequence select="imf:col('Begrip (URI)',$empty)"/>
      <xsl:sequence select="imf:col('Definitie',imf:formatted-value(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DEFINITION')))"/>
      <xsl:sequence select="imf:col('Toelichting',imf:formatted-value(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DESCRIPTION')))"/>
      <xsl:sequence select="imf:col('Populatie',imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-POPULATION'))"/>
      <xsl:sequence select="imf:col('Herkomst',imf:formatted-value(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-SOURCE')))"/>
      <xsl:sequence select="imf:col('Herkomst (URI)',$empty)"/>
      <xsl:sequence select="imf:col('Eigenaar',imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-OWNER'))"/>
      <xsl:sequence select="imf:col('Eigenaar (URI)',$empty)"/>
      <xsl:sequence select="imf:col('Wetgeving',$empty)"/>
      <xsl:sequence select="imf:col('Wetgeving (URI)',$empty)"/>
      <xsl:sequence select="imf:col('Authentiek','Ja')"/>
      <xsl:sequence select="imf:col('AuthentiekRelatie',$empty)"/>
      <xsl:sequence select="imf:col('Relaties',string-join($relaties,'; '))"/>
      <xsl:sequence select="imf:col('Relaties (URI)',$empty)"/>
      <xsl:sequence select="imf:col('Kwaliteit',imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-QUALITY'))"/>
    </r>
  </xsl:template>
  
</xsl:stylesheet>