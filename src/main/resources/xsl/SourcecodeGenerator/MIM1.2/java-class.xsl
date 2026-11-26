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
    
  <xsl:import href="java-base.xsl"/>
    
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="definition" on-no-match="shallow-copy"/>
  <xsl:mode name="field-declaration" on-no-match="shallow-skip"/>
  <xsl:mode name="field-getter-setter" on-no-match="shallow-skip"/>
  
  <xsl:param name="jpa-annotations" as="xs:boolean" select="false()"/>
  <xsl:param name="swagger-annotatations" as="xs:boolean" select="false()"/>
  <xsl:param name="java-interfaces" as="xs:boolean" select="false()"/>
  
  <xsl:variable name="mode" select="if ($jpa-annotations) then 'entity' else ''" as="xs:string"/>
  
  <xsl:template match="entity">
    <xsl:variable name="full-package-name" select="local:full-package-name(package-name)" as="xs:string"/>
    <xsl:variable name="class-name" select="name" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/{replace($full-package-name, '\.', '/')}/{replace($class-name, '\.', '/')}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.annotation.*;</line>
        <xsl:if test="$jpa-annotations">
          <line mode="entity">import jakarta.persistence.*;</line>
          <line>import java.io.Serializable;</line>  
        </xsl:if>
        
        <xsl:if test="$swagger-annotatations">
          <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
          <line>import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;</line>
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
        
        <xsl:if test="$swagger-annotatations">
          <xsl:variable name="description" select="local:escape-java(local:definition-as-string(definition))" as="xs:string?"/>
          <xsl:if test="$description">
            <line>@Schema(description = "{$description}")</line>
          </xsl:if>
        </xsl:if>
        
        <xsl:variable name="super-type-class-name" select="super-type" as="xs:string"/>
        
        <line>public {if (is-abstract = 'true') then 'abstract ' else ''}{if ($java-interfaces) then 'interface' else 'class'} {$class-name}{if (super-type) then ' extends ' || local:full-package-name(super-type/@package-name) || '.' || $super-type-class-name  else () }{if ($mode = 'entity') then ' implements Serializable' else () } {{</line>
        <line mode="entity"/>
        <line indent="2" mode="entity">private static final long serialVersionUID = 1L;</line>
        
        <xsl:if test="not($java-interfaces)">
          <xsl:apply-templates select="fields" mode="field-declaration"/>
        </xsl:if>
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
    <xsl:variable name="full-package-name" select="local:full-package-name(package-name)" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/{replace($full-package-name, '\.', '/')}/{replace(name, '\.', '/')}.java" method="text">   
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        <line>import nl.imvertor.mim.annotation.*;</line>
        <line/>
        <xsl:call-template name="javadoc"/>
        <line>@{model-element}</line>
        <line>public enum {name} {{</line>
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
              <line indent="2">@ManyToMany{if (aggregation = 'composite') then '(cascade = CascadeType.ALL)' else ()}</line>
              <line indent="2">@Column(nullable={nullable = 'true'})</line>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>Unsupported cardinality on field {ancestor::entity/name}.{name}</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>  
    </xsl:if>
    
    <xsl:if test="$swagger-annotatations">
      <xsl:variable name="description" select="local:escape-java(local:definition-as-string(definition))" as="xs:string?"/>
      <xsl:variable name="required-mode" as="xs:string"> <!-- TODO: is this correct? -->
        <xsl:choose>
          <xsl:when test="cardinality/target/max-occurs = '1'">RequiredMode.REQUIRED</xsl:when>
          <xsl:otherwise>RequiredMode.NOT_REQUIRED</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <line indent="2">@Schema({if ($description) then 'description = "' || $description || '", ' else ()}requiredMode = {$required-mode})</line>
    </xsl:if>
    
    <xsl:variable name="resolved-type" select="local:type(type, cardinality)" as="xs:string"/>
    <line indent="2">private {$resolved-type} {name};</line>
  </xsl:template>
  
  <xsl:template match="field" mode="field-getter-setter">
    <xsl:variable name="resolved-type" select="local:type(type, cardinality)" as="xs:string"/>
    <line/>
    <line indent="2">public {$resolved-type} {if (type = 'Boolean') then 'is' else 'get'}{functx:capitalize-first(name)}(){if ($java-interfaces) then ';' else ' ' || $accolade-open}</line>
    <xsl:if test="not($java-interfaces)">
      <line indent="2">  return {name};</line>
      <line indent="2">}}</line>  
    </xsl:if>
    
    <line/>
    <line indent="2">public void set{functx:capitalize-first(name)}({$resolved-type} {name}){if ($java-interfaces) then ';' else ' ' || $accolade-open}</line>
    <xsl:if test="not($java-interfaces)">
      <line indent="2">  this.{name} = {name};</line>
      <line indent="2">}}</line>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>