<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:mim="http://www.geonovum.nl/schemas/MIMFORMAT/model/v20210522" 
  xmlns:mim-ref="http://www.geonovum.nl/schemas/MIMFORMAT/model-ref/v20210522"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  exclude-result-prefixes="#all"
  expand-text="yes"
  version="3.0">
  
  <xsl:output method="text" indent="no"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:variable name="lf" select="'&#xa;'" as="xs:string"/>
  <xsl:variable name="tb" select="'  '" as="xs:string"/>
  <xsl:variable name="root" select="/" as="document-node()"/>
  
  <xsl:key name="element-by-id" match="mim:*[@id]" use="@id"/>
  
  <xsl:template match="/">
    <xsl:variable name="lines" as="element(line)+">
      <xsl:sequence select="imf:line(0, 1, '@startuml')"/>
      <xsl:sequence select="imf:line(0, 1, '!define primitiefdatatype(x) class x &lt;&lt;(D,#FF7700) Primitief datatype&gt;&gt;')"/>
      <xsl:sequence select="imf:line(0, 1, '!define gestructureerddatatype(x) class x &lt;&lt;(D,#FF7700) Gestructureerd datatype&gt;&gt;')"/>
      <xsl:sequence select="imf:line(0, 1, '!define codelijst(x) class x &lt;&lt;(D,#FF7700) Codelijst&gt;&gt;')"/>
      <xsl:sequence select="imf:line(0, 2, '!define referentielijst(x) class x &lt;&lt;(D,#FF7700) Referentielijst&gt;&gt;')"/>
      <xsl:sequence select="imf:line(0, 2, 'skinparam linetype ortho')"/>
      <xsl:apply-templates select="mim:Informatiemodel/*/(mim:Domein|mim:View|mim:Extern)"/>
      <xsl:apply-templates select="mim:Informatiemodel/mim:components/mim:InformatiemodelComponents/mim:Objecttype/mim:bezit/mim:Relatiesoort"/>
      <xsl:sequence select="imf:line(0, 1, '@enduml')"/>
    </xsl:variable>
    <xsl:value-of select="string-join($lines/text(), '')"/>
  </xsl:template>
  
  <xsl:template match="mim:Domein|mim:View|mim:Extern">
    <xsl:sequence select="imf:line(0, 2, 'package ' || mim:naam || ' &lt;&lt;' || local-name() || '&gt;&gt; {')"/>
    <xsl:apply-templates select="for $a in (mim:*/mim-ref:*[@xlink:href]) return imf:element-by-xlink-href($a)"/>
    <xsl:sequence select="imf:line(0, 2, '}')"/>
  </xsl:template>
  
  <xsl:template match="mim:Objecttype|mim:Gegevensgroeptype" as="element(line)*">
    <xsl:sequence select="imf:line(1, 1, (if (mim:indicatieAbstractObject = 'Ja') then 'abstract ' else ()) || 'class ' || mim:naam || ' &lt;&lt;' || local-name() || '&gt;&gt; {')"/>
    <xsl:sequence select="imf:line(2, 1, '&lt;&lt;Attribuutsoort&gt;&gt;')"/>
    <xsl:sequence select="imf:line(2, 1, '..')"/>
    <xsl:apply-templates select="mim:gebruikt__attribuutsoort"/>
    <xsl:sequence select="imf:line(1, 2, '}')"/>
    <xsl:apply-templates select="mim:supertype"/>
  </xsl:template>
  
  <xsl:template match="mim:supertype/mim:Generalisatie/*/mim-ref:*" as="element(line)*">
    <xsl:sequence select="imf:line(1, 2, imf:element-by-xlink-href(.)[1]/mim:naam || ' &lt;|-- ' || ancestor::*[mim:supertype/mim:Generalisatie]/mim:naam)"/>
  </xsl:template>

  <xsl:template match="mim:Attribuutsoort|mim:DataElement|mim:ReferentieElement" as="element(line)*">
    <xsl:variable name="kardinaliteit" select="if (mim:kardinaliteit[normalize-space() and not(. = '1')]) then ' [' || mim:kardinaliteit || ']' else ()" as="xs:string?"/>
    <xsl:sequence select="imf:line(2, 1, '+' || mim:naam || ' : ' || imf:element-by-xlink-href((mim:heeft|mim:heeft__datatype|mim:heeft__keuze)/mim-ref:*[@xlink:href])/mim:naam || $kardinaliteit)"/>
  </xsl:template>
  
  <xsl:template match="mim:Relatiesoort">
    <xsl:variable name="target" select="imf:element-by-xlink-href(mim:verwijstNaar__objecttype/mim-ref:ObjecttypeRef)" as="element()?"/>
    <xsl:if test="$target[self::mim:Objecttype]"> <!-- TODO, Keuze implementeren -->
      <xsl:variable name="relation-symbol" as="xs:string">
        <xsl:choose>
          <xsl:when test="mim:typeAggregatie = 'Compositie'">*--&gt;</xsl:when>
          <xsl:when test="mim:typeAggregatie = 'Gedeeld'">o--&gt;</xsl:when>
          <xsl:otherwise>--&gt;</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="relation-role" select="if (mim:naam) then ' : ' || mim:naam else ()" as="xs:string"/>   
      <xsl:variable name="kardinaliteit-source" select="('?', '1')[1]" as="xs:string"/>
      <xsl:variable name="kardinaliteit-target" select="(mim:kardinaliteit, '1')[1]" as="xs:string"/>
      <xsl:sequence select="imf:line(0, 1, ancestor::mim:Objecttype/mim:naam || ' &quot;' || $kardinaliteit-source || '&quot; ' || $relation-symbol || ' &quot;' || $kardinaliteit-target || '&quot; ' || $target/mim:naam || $relation-role)"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mim:PrimitiefDatatype">
    <xsl:sequence select="imf:line(1, 2, 'primitiefdatatype(' || mim:naam || ')')"/>
    <xsl:apply-templates select="mim:supertype"/>
  </xsl:template>
  
  <xsl:template match="mim:GestructureerdDatatype">
    <xsl:sequence select="imf:line(1, 1, 'gestructureerddatatype(' || mim:naam || ') {')"/>
    <xsl:apply-templates select="mim:bevat/mim:DataElement"/>
    <xsl:sequence select="imf:line(1, 2, '}')"/>
    <xsl:apply-templates select="mim:supertype"/>
  </xsl:template>

  <xsl:template match="mim:Enumeratie">    
    <xsl:sequence select="imf:line(1, 1, 'enum ' || mim:naam || ' &lt;&lt;' || local-name() || '&gt;&gt; {')"/>
    <xsl:sequence select="imf:line(2, 1, '&lt;&lt;Enumeratiewaarde&gt;&gt;')"/>
    <xsl:sequence select="imf:line(2, 1, '..')"/>
    <xsl:for-each select="mim:bevat/mim:Enumeratiewaarde">
      <xsl:sequence select="imf:line(2, 1, '+' || mim:naam)"/>
    </xsl:for-each>
    <xsl:sequence select="imf:line(1, 2, '}')"/>
    <xsl:apply-templates select="mim:supertype"/>
  </xsl:template>
  
  <xsl:template match="mim:Codelijst">
    <xsl:sequence select="imf:line(1, 1, 'codelijst(' || mim:naam || ') {')"/>
    <!--
    <xsl:sequence select="imf:line(2, 1, mim:locatie)"/>
    -->
    <xsl:sequence select="imf:line(1, 2, '}')"/>
    <xsl:apply-templates select="mim:supertype"/>
  </xsl:template>
  
  <xsl:template match="mim:Referentielijst">
    <xsl:sequence select="imf:line(1, 1, 'referentielijst(' || mim:naam || ') {')"/>
    <xsl:sequence select="imf:line(2, 1, '&lt;&lt;Referentie element&gt;&gt;')"/>
    <xsl:sequence select="imf:line(2, 1, '..')"/>
    <xsl:apply-templates select="mim:bevat/mim:ReferentieElement"/>
    <xsl:sequence select="imf:line(1, 2, '}')"/>
    <xsl:apply-templates select="mim:supertype"/>
  </xsl:template>

  <xsl:template match="mim:Interface">
    <xsl:sequence select="imf:line(1, 1, 'interface ' || mim:naam || ' &lt;&lt;' || local-name() || '&gt;&gt;')"/>
    <xsl:apply-templates select="mim:supertype"/>
  </xsl:template>

  <xsl:function name="imf:element-by-xlink-href" as="element()*">
    <xsl:param name="ref-elem" as="element()?"/>
    <xsl:sequence select="if ($ref-elem/@xlink:href) then key('element-by-id', substring-after($ref-elem/@xlink:href, '#'), $root) else ()"/>
  </xsl:function>

  <xsl:function name="imf:line" as="element(line)">
    <xsl:param name="n-tbs" as="xs:integer"/>
    <xsl:param name="n-lfs" as="xs:integer"/>
    <xsl:param name="text" as="xs:string?"/>
    <line>{string-join((for $a in 1 to $n-tbs return $tb, $text, for $a in 1 to $n-lfs return $lf), '')}</line>
  </xsl:function>
  
</xsl:stylesheet>