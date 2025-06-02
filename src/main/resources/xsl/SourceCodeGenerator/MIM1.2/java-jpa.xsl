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
  <xsl:mode name="field-declaration" on-no-match="shallow-skip"/>
  <xsl:mode name="field-getter-setter" on-no-match="shallow-skip"/>
  
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
      <xsl:map-entry key="'URI'" select="'String'"/>
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
  
  <xsl:template match="model">
    <java-jpa>
      <xsl:comment> Zie directory "imvertor.41.codegen.java-jpa" </xsl:comment>
      <xsl:apply-templates>
        <xsl:with-param name="mode" tunnel="yes" select="'entity'"/>
      </xsl:apply-templates>  
    </java-jpa>
  </xsl:template>
    
  <xsl:template match="entity">
    <xsl:param name="mode" tunnel="yes" as="xs:string"/>
    <xsl:variable name="full-package-name" select="local:full-package-name($mode, package-name)" as="xs:string"/>
    <xsl:variable name="class-name" select="if ($mode = 'dto') then name || 'DTO' else name" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/{replace($full-package-name, '\.', '/')}/{replace($class-name, '\.', '/')}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.annotation.*;</line>
        <xsl:if test="$mode = 'entity'">
          <line mode="entity">import jakarta.persistence.*;</line>
          <line>import java.io.Serializable;</line>  
        </xsl:if>
        <line>import java.util.*;</line>
        <line/>
  
        <xsl:call-template name="javadoc"/>
        
        <xsl:choose>
          <xsl:when test="fields/field[choice-id]">
            <xsl:for-each-group select="fields/field[choice-id]" group-by="choice-id">
              <xsl:variable name="field-names" select="current-group()/name" as="xs:string+"/>
              <line>
                <xsl:text>@Keuze(fieldNames = {{{ string-join(for $n in $field-names return '"' || $n || '"', ', ') }}} , message = "Exactly one of {string-join($field-names, ', ')} must be non-zero")</xsl:text>  
              </line>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:when test="model-element = 'Keuze'">
            <xsl:variable name="field-names" select="for $n in fields/field[not(type/@is-standard = 'true')]/name return $n" as="xs:string*"/>
            <line>
              <xsl:text>@Keuze(fieldNames = {{{ string-join(for $n in $field-names return '"' || $n || '"', ', ') }}} , message = "Exactly one of {string-join($field-names, ', ')} must be non-zero")</xsl:text>  
            </line>
          </xsl:when>
          <xsl:otherwise>
            <line>@{model-element}</line>
          </xsl:otherwise>
        </xsl:choose>
        
        
        <line mode="entity">@Entity</line>
        <xsl:if test="has-sub-types = 'true'">
          <line mode="entity">@Inheritance(strategy=InheritanceType.JOINED)</line>
        </xsl:if>
        <xsl:if test="super-type">
          <line mode="entity">@PrimaryKeyJoinColumn</line>
        </xsl:if>
        
        <xsl:variable name="super-type-class-name" select="if ($mode = 'dto') then super-type || 'DTO' else super-type" as="xs:string"/>
        
        <line>public {if (is-abstract = 'true') then 'abstract ' else ''}class {$class-name}{if (super-type) then ' extends ' || local:full-package-name($mode, super-type/@package-name) || '.' || $super-type-class-name  else () }{if ($mode = 'entity') then ' implements Serializable' else () } {{</line>
        <line mode="entity"/>
        <line indent="2" mode="entity">private static final long serialVersionUID = 1L;</line>
        
        <xsl:apply-templates select="fields" mode="field-declaration"/>
        <xsl:apply-templates select="fields" mode="field-getter-setter"/>
        
        <line/>
        <line>}}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="enumeration">
    <xsl:param name="mode" tunnel="yes" as="xs:string"/>
    <xsl:variable name="full-package-name" select="local:full-package-name($mode, package-name)" as="xs:string"/>
    <xsl:variable name="class-name" select="if ($mode = 'dto') then name || 'DTO' else name" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/{replace($full-package-name, '\.', '/')}/{replace($class-name, '\.', '/')}.java" method="text">   
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        <line>import nl.imvertor.mim.annotation.*;</line>
        <line/>
        <xsl:call-template name="javadoc"/>
        <line>@{model-element}</line>
        <line>public enum {$class-name} {{</line>
        <line/>
        <xsl:for-each select="values/value">
          <xsl:call-template name="javadoc">
            <xsl:with-param name="indent">2</xsl:with-param>
          </xsl:call-template>
          <line indent="2">{upper-case(funct:replace-special-chars(funct:camel-case(code), '_'))}{if (position()=last()) then () else ','}</line>
          <line/>
        </xsl:for-each>        
        <line>}}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="field" mode="field-declaration">
    <xsl:param name="mode" tunnel="yes" as="xs:string"/>
    
    <line/>
    
    <xsl:call-template name="javadoc">
      <xsl:with-param name="indent" select="2"/>
    </xsl:call-template>
    
    <xsl:if test="is-id-attribute = 'true'">
      <line indent="2" mode="entity">@Id</line>
      <xsl:if test="auto-generate = 'true'">
        <line indent="2" mode="entity">@GeneratedValue(strategy=GenerationType.AUTO)</line>  
      </xsl:if>
    </xsl:if>
    
    <xsl:if test="$mode = 'entity'">
      <xsl:choose>
        <xsl:when test="type/@is-enum = 'true'">
          <line indent="2">@Enumerated(EnumType.STRING)</line>
        </xsl:when>
        <xsl:when test="not(type/@is-standard = 'true')">
          <xsl:choose>
            <xsl:when test="cardinality/source/max-occurs = ('0','1') and cardinality/target/max-occurs = ('0','1')">
              <line indent="2">@OneToOne{if (aggregation = 'composite') then '(cascade = CascadeType.ALL)' else ()}</line>
              <line indent="2">@JoinColumn(nullable={nullable = 'true'})</line>
            </xsl:when>
            <xsl:when test="cardinality/source/max-occurs = ('0','1') and cardinality/target/max-occurs = $unbounded">
              <line indent="2">@OneToMany{if (aggregation = 'composite') then '(cascade = CascadeType.ALL)' else ()}</line>
              <line indent="2">@Column(nullable={nullable = 'true'})</line>
            </xsl:when>
            <xsl:when test="cardinality/source/max-occurs = $unbounded and cardinality/target/max-occurs = ('0','1')">
              <line indent="2">@ManyToOne{if (aggregation = 'composite') then '(cascade = CascadeType.ALL)' else ()}</line>
              <line indent="2">@Column(nullable={nullable = 'true'})</line>
            </xsl:when>
            <xsl:when test="cardinality/source/max-occurs = $unbounded and cardinality/target/max-occurs = $unbounded">
              <line indent="2">@@ManyToMany{if (aggregation = 'composite') then '(cascade = CascadeType.ALL)' else ()}</line>
              <line indent="2">@Column(nullable={nullable = 'true'})</line>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>Unsupported cardinality on field {ancestor::entity/name}.{name}</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>  
    </xsl:if>
    
    <xsl:variable name="resolved-type" select="local:type(type, cardinality, $mode)" as="xs:string"/>
    <line indent="2">private {$resolved-type} {name};</line>
  </xsl:template>
  
  <xsl:template match="field" mode="field-getter-setter">
    <xsl:param name="mode" tunnel="yes" as="xs:string"/>
    <xsl:variable name="resolved-type" select="local:type(type, cardinality, $mode)" as="xs:string"/>
    <line/>
    <line indent="2">public {$resolved-type} {if (type = 'Boolean') then 'is' else 'get'}{functx:capitalize-first(name)}() {{</line>
    <line indent="2">  return {name};</line>
    <line indent="2">}}</line>
    <line/>
    <line indent="2">public void set{functx:capitalize-first(name)}({$resolved-type} {name}) {{</line>
    <line indent="2">  this.{name} = {name};</line>
    <line indent="2">}}</line>
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
    <xsl:param name="mode" tunnel="yes" as="xs:string"/>
    <xsl:if test="not(@mode) or (@mode = $mode)">
      <xsl:variable name="indent" select="if (@indent) then xs:integer(@indent) else 0" as="xs:integer"/>
      <xsl:sequence select="string-join(((for $i in 1 to $indent return ' '), ., $lf))"/>  
    </xsl:if>
  </xsl:template>
  
  <xsl:function name="local:full-package-name" as="xs:string">
    <xsl:param name="mode" as="xs:string"/>
    <xsl:param name="package-name" as="xs:string"/>
    <xsl:sequence select="string-join(($package-prefix, $mode, $package-name), '.')"/>
  </xsl:function>
  
  <xsl:function name="local:type" as="xs:string">
    <xsl:param name="type-info" as="element()"/>
    <xsl:param name="cardinality" as="element()"/>
    <xsl:param name="mode" as="xs:string"/>
    <xsl:variable name="class-name" select="if ($mode = 'dto') then $type-info || 'DTO' else $type-info" as="xs:string"/>
    <xsl:variable name="singular-type" select="if ($type-info/@is-standard = 'true') then $type-info else local:full-package-name($mode, $type-info/@package-name) || '.' || $class-name" as="xs:string"/>
    <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>
  </xsl:function>
  
</xsl:stylesheet>