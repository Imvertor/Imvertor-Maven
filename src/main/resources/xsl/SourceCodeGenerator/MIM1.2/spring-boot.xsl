<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:local="urn:local"
  xmlns:entity="urn:entity"
  xmlns:funct="urn:funct"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
  
  <xsl:import href="mim-2-entities.xsl"/>
  
  <xsl:include href="entity-functions.xsl"/>
  
  <xsl:output method="text" indent="yes"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:mode name="class" on-no-match="shallow-skip"/>
  <xsl:mode name="relation" on-no-match="shallow-skip"/>
  
  <xsl:variable name="entity-model-element-names" select="('Codelijst', 'Constructie', 'Enumeratie', 'Gegevensgroeptype', 
    'GestructureerdDatatype', 'Keuze', 'Objecttype', 'PrimitiefDatatype', 'Referentielijst', 'Relatieklasse')" as="xs:string+"/>
  
  <xsl:variable name="primitive-mim-type-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'CharacterString'" select="'String'"/>
      <xsl:map-entry key="'Integer'" select="'Integer'"/>
      <xsl:map-entry key="'Real'" select="'Double'"/>
      <xsl:map-entry key="'Decimal'" select="'BigDecimal'"/>
      <xsl:map-entry key="'Boolean'" select="'Boolean'"/>
      <xsl:map-entry key="'Date'" select="'LocalDate'"/>
      <xsl:map-entry key="'DateTime'" select="'ZonedDateTime'"/>
      <xsl:map-entry key="'Year'" select="'Short'"/>
      <xsl:map-entry key="'Day'" select="'Byte'"/>
      <xsl:map-entry key="'Month'" select="'Byte'"/>
      <xsl:map-entry key="'URI'" select="'String'"/>
    </xsl:map>
  </xsl:variable>
  
  <xsl:variable name="package-color-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'domein'" select="'#90EE90'"/>
      <xsl:map-entry key="'view'" select="'#ADD8E6'"/>
      <xsl:map-entry key="'extern'" select="'#F08080'"/>
    </xsl:map>
  </xsl:variable>
  
  <xsl:function name="entity:package-name">
    <xsl:param name="package-hierarchy" as="xs:string*"/>
    <xsl:sequence select="string-join((for $p in $package-hierarchy return funct:replace-special-chars(funct:flatten-diacritics(funct:lower-case($p)), '_')), '.')"/>
  </xsl:function>
  
  <xsl:function name="entity:class-name">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="funct:replace-special-chars(funct:flatten-diacritics(funct:pascal-case($name)), '_')"/>
  </xsl:function>
  
  <xsl:function name="entity:field-name">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="funct:replace-special-chars(funct:flatten-diacritics(funct:camel-case($name)), '_')"/>
  </xsl:function>
  
  <xsl:function name="entity:enum-value" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="funct:replace-special-chars(upper-case(funct:snake-case(funct:flatten-diacritics($str))), '_')"/>  
  </xsl:function>
  
  <xsl:template name="generate-annotations">
    <xsl:for-each select="$entity-model-element-names">
      <xsl:call-template name="write-to-file">
        <xsl:with-param name="uri" as="xs:string">{$output-uri}/src/main/java/{replace($package-prefix, '\.', '/')}/mim/annotation/{.}.java</xsl:with-param>
        <xsl:with-param name="lines" as="element(line)+">
          <line>package nl.imvertor.mim.annotation;</line>
          <line/>
          <line>import java.lang.annotation.*;</line>
          <xsl:if test=". = 'Keuze'">
            <line>import jakarta.validation.*;</line>
            <line>import nl.imvertor.mim.validation.KeuzeValidator;</line>
          </xsl:if>
          <line/>
          <line>@Target(ElementType.TYPE)</line>
          <line>@Documented</line>
          <xsl:if test=". = 'Keuze'">
            <line>@Retention(RetentionPolicy.RUNTIME)</line>
            <line>@Constraint(validatedBy = KeuzeValidator.class)</line>
          </xsl:if>
          <line>public @interface {.} {{</line>
          <xsl:if test=". = 'Keuze'">
            <line indent="2">String message() default "Only one field must be non-zero";</line>
            <line/>
            <line indent="2">Class&lt;?&gt;[] groups() default {{}};</line>
            <line/>
            <line indent="2">Class&lt;? extends Payload&gt;[] payload() default {{}};</line>
            <line/>
            <line indent="2">String[] fieldNames();</line>
          </xsl:if>
          <line/>
          <line>}}</line>
        </xsl:with-param>
      </xsl:call-template>  
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="model">
    <xsl:variable name="lines-elements" as="element(line)+"> 
      <line>@startuml</line>
      <xsl:apply-templates/>
      <line>@enduml</line>
    </xsl:variable>
    <xsl:variable name="lines" as="xs:string*">
      <xsl:apply-templates select="$lines-elements"/>  
    </xsl:variable>
    <xsl:sequence select="string-join($lines)"/>
  </xsl:template>
  
  <xsl:template match="domein|view|extern">
    <line/>
    <line>package {name} {map:get($package-color-mapping, local-name())} {{</line>
    <xsl:apply-templates mode="class"/>
    <line/>
    <xsl:apply-templates mode="relation"/>
    <line/>
    <line>}}</line>
  </xsl:template>
  
  <xsl:template match="entity" mode="class">
    <line/>
    <line indent="2">{if (is-abstract = 'true') then 'abstract ' else ()}class {local:full-package-name(package-name) || '.' || name} &lt;&lt;{model-element}&gt;&gt; {{</line>
    <xsl:apply-templates mode="#current"/>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template match="enumeration" mode="class">
    <line/>
    <line indent="2">enum {local:full-package-name(package-name) || '.' || name} &lt;&lt;{model-element}&gt;&gt; {{</line>
    <xsl:for-each select="values/value">
      <line indent="4">{upper-case(funct:replace-special-chars(funct:camel-case(code), '_'))}</line>
    </xsl:for-each>
    <line>}}</line> 
  </xsl:template>
  
  <!--
  <xsl:template match="fields" mode="class">
    <xsl:for-each-group select="field[type/@is-standard = 'true' or type/@is-enum = 'true']" group-by="category">
      <xsl:if test="normalize-space(current-grouping-key())">
        <line indent="2">.. {current-grouping-key()} ..</line>  
      </xsl:if>
      <xsl:apply-templates select="current-group()" mode="#current">
        <xsl:sort select="name"/>
      </xsl:apply-templates>
    </xsl:for-each-group>
  </xsl:template>
  -->
  
  <xsl:template match="field[type/@is-standard = 'true' or type/@is-enum = 'true']" mode="class">
    <line indent="4">-{name} : {type}</line>
  </xsl:template>  
  
  <xsl:template match="entity[super-type]" mode="relation">
    <line indent="2">{local:full-package-name(super-type/@package-name) || '.' || super-type} &lt;|-- {local:full-package-name(package-name) || '.' || name}</line>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="field[not(type/@is-standard = 'true')]" mode="relation">
    <line indent="2">
      <xsl:text>{local:full-package-name(ancestor::entity/package-name) || '.' || ancestor::entity/name}</xsl:text>
      <xsl:text> {local:cardinality-to-str(cardinality/source)}</xsl:text>
      <xsl:text> {if (aggregation = 'composite') then '*--' else 'o--'}</xsl:text>
      <xsl:text> {local:cardinality-to-str(cardinality/target)}</xsl:text>
      <xsl:text> {local:full-package-name(type/@package-name) || '.' || type}</xsl:text>
      <xsl:text> : {name}</xsl:text>
    </line>
  </xsl:template>
  
  <xsl:template match="line">
    <xsl:variable name="indent" select="if (@indent) then xs:integer(@indent) else 0" as="xs:integer"/>
    <xsl:sequence select="string-join(((for $i in 1 to $indent return ' '), ., $lf))"/>  
  </xsl:template>
  
  <xsl:function name="local:full-package-name" as="xs:string">
    <xsl:param name="package-name" as="xs:string"/>
    <xsl:sequence select="$package-name"/>
  </xsl:function>
  
  <xsl:function name="local:cardinality-to-str" as="xs:string?">
    <xsl:param name="cardinality" as="element()"/>
    <xsl:choose>
      <xsl:when test="$cardinality/min-occurs = '1' and $cardinality/max-occurs = '1'"/>
      <xsl:otherwise>"{$cardinality/min-occurs}..{if ($cardinality/max-occurs = $unbounded) then '*' else $cardinality/max-occurs}"</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>