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
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns:imf="http://www.imvertor.org/xsl/functions"   
  xmlns:local="urn:local"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="keuze-datatypen" on-no-match="shallow-copy"/>
  
  <xsl:key name="id" match="*[@id]" use="@id"/>
  <xsl:key name="ref" match="mim-ref:*|mim-ext:ConstructieRef" use="substring(@xlink:href, 2)"/>
  <xsl:key name="supertype-ref" match="mim:supertypen/mim:GeneralisatieObjecttypen/mim:supertype/(mim-ref:ObjecttypeRef|mim-ext:ConstructieRef)" use="substring(@xlink:href, 2)"/>
  
  <xsl:param name="sourcecode-resolve-gegevensgroeptypes" select="true()" as="xs:boolean"/>
  <xsl:param name="sourcecode-copy-down-mixins" select="false()" as="xs:boolean"/>
  <xsl:param name="sourcecode-resolve-keuze-tussen-attribuutsoorten" select="true()" as="xs:boolean"/>
  <xsl:param name="sourcecode-resolve-keuze-tussen-relatiedoelen" select="true()" as="xs:boolean"/>
  <xsl:param name="sourcecode-resolve-keuze-tussen-datatypen" select="true()" as="xs:boolean"/>
  
  <xsl:template match="(mim:Domein|mim:View)/mim:gegevensgroeptypen[$sourcecode-resolve-gegevensgroeptypes]"/>
  <xsl:template match="(mim:Domein|mim:View)/mim:keuzen/mim:Keuze[mim:keuzeAttributen][$sourcecode-resolve-keuze-tussen-attribuutsoorten]"/>
  <xsl:template match="(mim:Domein|mim:View)/mim:keuzen/mim:Keuze[mim:keuzeDatatypen][$sourcecode-resolve-keuze-tussen-datatypen]"/>
  <xsl:template match="(mim:Domein|mim:View)/mim:keuzen/mim:Keuze[mim:keuzeRelatiedoelen][$sourcecode-resolve-keuze-tussen-relatiedoelen]"/>
  
  <xsl:template match="mim:Objecttype/mim:gegevensgroepen[$sourcecode-resolve-gegevensgroeptypes]"/>
  <xsl:template match="mim:Objecttype/mim:keuzen[local:resolve-reference(mim-ref:KeuzeRef)/mim:keuzeAttributen][$sourcecode-resolve-keuze-tussen-attribuutsoorten]"/>
    
  <xsl:template match="(mim:Objecttype|mim:Gegevensgroeptype)/(mim:attribuutsoorten|mim:relatiesoorten)">
    <xsl:param name="name-prefix" as="xs:string?" tunnel="yes"/>
    <xsl:variable name="local-name" select="local-name()" as="xs:string"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      
      <!-- $sourcecode-resolve-gegevensgroeptypes -->
      <xsl:if test="$sourcecode-resolve-gegevensgroeptypes">
        <xsl:for-each select="../mim:gegevensgroepen/mim:Gegevensgroep">
          <xsl:variable name="group-name" select="mim:naam" as="xs:string"/>
          <xsl:for-each select="mim:gegevensgroeptype/mim-ref:GegevensgroeptypeRef/local:resolve-reference(.)">
            <xsl:apply-templates select="*[local-name() = $local-name]/(mim:Attribuutsoort|mim:Relatiesoort)">
              <xsl:with-param name="comment" select="'$sourcecode-resolve-gegevensgroeptypes'" as="xs:string"/>
              <xsl:with-param name="name-prefix" select="string-join(($name-prefix, $group-name), ' ')" as="xs:string" tunnel="yes"/>
            </xsl:apply-templates>   
            <xsl:apply-templates select="mim:gegevensgroepen/mim:Gegevensgroep/mim:gegevensgroeptype/mim-ref:GegevensgroeptypeRef/local:resolve-reference(.)/*[local-name() = $local-name]">
              <xsl:with-param name="name-prefix" select="string-join(($name-prefix, $group-name), ' ')" as="xs:string" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:for-each>
        </xsl:for-each>  
      </xsl:if>
      
      <!-- $sourcecode-resolve-keuze-tussen-attribuutsoorten -->
      <xsl:if test="$sourcecode-resolve-keuze-tussen-attribuutsoorten and self::mim:attribuutsoorten">
        <xsl:apply-templates select="../mim:keuzen/mim-ref:KeuzeRef/local:resolve-reference(.)/mim:keuzeAttributen/mim:Attribuutsoort">
          <xsl:with-param name="comment" select="'$sourcecode-resolve-keuze-tussen-attribuutsoorten'" as="xs:string"/>
        </xsl:apply-templates>
      </xsl:if>
      
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mim:Attribuutsoort[not(mim:type/mim-ref:KeuzeRef)]">
    <xsl:param name="comment" as="xs:string?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$comment">
        <xsl:comment> {$comment} </xsl:comment>  
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mim:Attribuutsoort[local:resolve-reference(mim:type/mim-ref:KeuzeRef)/mim:keuzeDatatypen][$sourcecode-resolve-keuze-tussen-datatypen]">
    <!-- $sourcecode-resolve-keuze-tussen-datatypen -->
    <xsl:variable name="keuze" select="local:resolve-reference(mim:type/mim-ref:KeuzeRef)" as="element(mim:Keuze)"/>
    <xsl:variable name="current" select="." as="element()"/>
    <xsl:for-each select="$keuze/mim:keuzeDatatypen/*">
      <xsl:apply-templates select="$current" mode="keuze-datatypen">
        <xsl:with-param name="datatype" select="." as="element()" tunnel="yes"/>
        <xsl:with-param name="comment" select="'$sourcecode-resolve-keuze-tussen-datatypen'" as="xs:string"/>
        <xsl:with-param name="position" select="position()" as="xs:integer" tunnel="yes"/>
      </xsl:apply-templates>  
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim:Relatiesoort[mim:doel/mim-ref:KeuzeRef][$sourcecode-resolve-keuze-tussen-relatiedoelen]">
    <!-- $sourcecode-resolve-keuze-tussen-relatiedoelen -->
    <xsl:variable name="keuze" select="local:resolve-reference(mim:doel/mim-ref:KeuzeRef)" as="element(mim:Keuze)"/>
    <xsl:variable name="current" select="." as="element()"/>
    <xsl:for-each select="$keuze/mim:keuzeRelatiedoelen/mim:Relatiedoel/mim-ref:ObjecttypeRef">
      <xsl:apply-templates select="$current" mode="keuze-relatiedoelen">
        <xsl:with-param name="relatiedoel-ref" select="." as="element(mim-ref:ObjecttypeRef)" tunnel="yes"/>
        <xsl:with-param name="comment" select="'$sourcecode-resolve-keuze-tussen-relatiedoelen'" as="xs:string"/>
      </xsl:apply-templates>  
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mim:Attribuutsoort" mode="keuze-datatypen">
    <xsl:param name="comment" as="xs:string?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = ('index', 'id'))]" mode="#current"/>
      <xsl:if test="$comment">
        <xsl:comment> {$comment} </xsl:comment>  
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mim:Attribuutsoort/mim:naam/text()" mode="keuze-datatypen">
    <xsl:param name="datatype" as="element()" tunnel="yes"/>
    <xsl:param name="position" as="xs:integer" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$datatype/@label">{$datatype/@label}</xsl:when>
      <xsl:otherwise>attr{$position}</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mim:Attribuutsoort/mim:type/mim-ref:KeuzeRef" mode="keuze-datatypen">
    <xsl:param name="datatype" as="element()" tunnel="yes"/>
    <xsl:sequence select="$datatype"/>
  </xsl:template>

  <xsl:template match="mim:naam/text()[$sourcecode-resolve-gegevensgroeptypes]">
    <xsl:param name="name-prefix" as="xs:string?" tunnel="yes"/>
    <xsl:value-of select="if ($name-prefix) then $name-prefix || ' ' || . else ."/>
  </xsl:template>
  
  <xsl:template match="mim:Relatiesoort" mode="keuze-relatiedoelen">
    <xsl:param name="comment" as="xs:string?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = ('index', 'id'))]" mode="#current"/>
      <xsl:if test="$comment">
        <xsl:comment> {$comment} </xsl:comment>  
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mim:Relatiesoort/mim:doel" mode="keuze-relatiedoelen">
    <xsl:param name="relatiedoel-ref" as="element(mim-ref:ObjecttypeRef)" tunnel="yes"/>
    <xsl:sequence select="$relatiedoel-ref"/>
  </xsl:template>
  
  <!-- Find the element that is referred to by $ref-element/@xlink:href: -->
  <xsl:function name="local:resolve-reference" as="element()?">
    <xsl:param name="ref-element" as="element()?"/>
    <xsl:sequence select="if (empty($ref-element)) then () else key('id', substring($ref-element/@xlink:href, 2), $ref-element/root())"/>
  </xsl:function>
  
</xsl:stylesheet>