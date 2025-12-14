<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:functx="http://www.functx.com"
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
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="definition" on-no-match="shallow-copy"/>
  
  <xsl:param name="swagger-annotatations" as="xs:boolean" select="false()"/>
  <xsl:param name="java-interfaces" as="xs:boolean" select="false()"/>
  <xsl:param name="jpa-annotations" as="xs:boolean" select="false()"/>
  
  <xsl:variable name="mode" select="if ($jpa-annotations) then 'entity' else ''" as="xs:string"/>
  
  <xsl:variable name="primitive-mim-type-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'CharacterString'" select="'String'"/>
      <xsl:map-entry key="'Integer'" select="'Integer'"/>
      <xsl:map-entry key="'Real'" select="'Double'"/>
      <xsl:map-entry key="'Decimal'" select="'java.math.BigDecimal'"/>
      <xsl:map-entry key="'Boolean'" select="'Boolean'"/>
      <xsl:map-entry key="'Date'" select="'java.time.LocalDate'"/>
      <xsl:map-entry key="'DateTime'" select="'java.time.ZonedDateTime'"/>
      <xsl:map-entry key="'Year'" select="'Short'"/>
      <xsl:map-entry key="'Day'" select="'Byte'"/>
      <xsl:map-entry key="'Month'" select="'Byte'"/>
      <xsl:map-entry key="'URI'" select="'java.net.URI'"/>
    </xsl:map>
  </xsl:variable>
    
  <xsl:function name="entity:package-name">
    <xsl:param name="package-hierarchy" as="xs:string*"/>
    <xsl:sequence select="string-join((for $p in $package-hierarchy return funct:replace-special-chars(funct:flatten-diacritics(funct:lower-case($p)), '_')), '.')"/>
  </xsl:function>
  
  <xsl:function name="entity:class-name">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$class-name-prefix || funct:replace-special-chars(funct:flatten-diacritics(funct:pascal-case($name)), '_') || $class-name-suffix"/>
  </xsl:function>
  
  <xsl:function name="entity:field-name">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="funct:replace-special-chars(funct:flatten-diacritics(funct:camel-case($name)), '_')"/>
  </xsl:function>
  
  <xsl:function name="entity:enum-value" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="funct:replace-special-chars(upper-case(funct:snake-case(funct:flatten-diacritics($str))), '_')"/>  
  </xsl:function>
  
  <xsl:template match="model">
    <java>
      <xsl:comment> Zie directory "imvertor.*.codegen.java*" </xsl:comment>
      <xsl:apply-templates/>  
    </java>
  </xsl:template>
    
  <xsl:template name="javadoc">
    <xsl:param name="indent" as="xs:integer" select="0"/>
    <xsl:if test="(definition|category)/node()">
      <line indent="{$indent}">/**</line>
      <xsl:if test="definition/node()">
        <line indent="{$indent}"> * <xsl:apply-templates select="definition" mode="definition"/></line>
      </xsl:if>
      <xsl:if test="category/node()">
        <line indent="{$indent}"> * {category}</line>
      </xsl:if>
      <line indent="{$indent}"> */</line>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="definition" mode="definition">
    <xsl:variable name="definition" as="node()*">
      <xsl:apply-templates mode="#current"/>
    </xsl:variable>
    <xsl:sequence select="normalize-space(serialize($definition))"/>
  </xsl:template>
  
  <xsl:template match="definition//xhtml:body" mode="definition">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="definition//xhtml:*[not(self::xhtml:body)]" mode="definition">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="line">
    <xsl:if test="not(@mode) or (@mode = $mode)">
      <xsl:variable name="indent" select="if (@indent) then xs:integer(@indent) else 0" as="xs:integer"/>
      <xsl:sequence select="string-join(((for $i in 1 to $indent return ' '), ., $lf))"/>  
    </xsl:if>
  </xsl:template>
  
  <xsl:function name="local:full-package-name" as="xs:string">
    <xsl:param name="package-name" as="xs:string"/>
    <xsl:sequence select="string-join(($package-prefix, $package-name), '.')"/>
  </xsl:function>
  
  <xsl:function name="local:type" as="xs:string">
    <xsl:param name="type-info" as="element()"/>
    <xsl:param name="cardinality" as="element()"/>
    <xsl:variable name="class-name" select="$type-info" as="xs:string"/>
    <xsl:variable name="singular-type" select="if ($type-info/@is-standard = 'true') then $type-info else local:full-package-name($type-info/@package-name) || '.' || $class-name" as="xs:string"/>
    <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>
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
  
  <xsl:function name="local:escape-java" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="replace(replace($str, '\\', '\\\\'), '&quot;', '\\&quot;')"/>
  </xsl:function>
  
</xsl:stylesheet>