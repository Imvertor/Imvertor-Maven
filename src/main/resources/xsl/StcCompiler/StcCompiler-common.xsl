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
  
  <xsl:import href="../common/Imvert-common.xsl"/>
  <xsl:import href="../common/Imvert-common-derivation.xsl"/>
  
  <xsl:variable name="empty" select="()"/>
  
  <xsl:function name="imf:col" as="element(c)">
     <xsl:param name="name" as="xs:string"/>
     <xsl:param name="value" as="item()*"/>
    <c>
      <xsl:comment>{$name}</xsl:comment>
      <xsl:value-of select="imf:string($value)"/>
    </c>
  </xsl:function>
  
  <xsl:function name="imf:formatted-name" as="xs:string">
    <xsl:param name="name" as="xs:string?"/>
    <!-- enige regel is nu: eerste letter is hoofdletter -->
    <xsl:value-of select="upper-case(substring($name,1,1)) || substring($name,2) || (if (empty($name)) then 'NONAME' else '')"/>
  </xsl:function>

  <xsl:function name="imf:formatted-value" as="xs:string">
    <xsl:param name="value" as="xs:string*"/>
    <!-- enige regel is nu: max 50 woorden. Hoe beperken? -->
    <xsl:variable name="v" select="imf:string($value)"/>
    <xsl:value-of select="$v"/><!-- ... || (if (count(tokenize($v,'\s+')) gt 50) then '(issue 7)' else '') -->
  </xsl:function>
  
  <xsl:function name="imf:string" as="xs:string">
    <xsl:param name="value" as="item()*"/>
    <xsl:value-of select="string-join(for $i in $value return for $v in normalize-space($i) return if ($v) then $v else (),' ')"/>
  </xsl:function>
</xsl:stylesheet>