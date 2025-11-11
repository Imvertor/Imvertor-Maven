<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:functx="http://www.functx.com"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:oas="urn:oas"
  xmlns:local="urn:local"
  xmlns:entity="urn:entity"
  xmlns:funct="urn:funct"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
    
  <xsl:import href="java-base.xsl"/>
  
  <xsl:include href="openapi-functions.xsl"/>
  <xsl:include href="xhtml-to-commonmark.xsl"/>
    
  <xsl:param name="package-prefix" as="xs:string" select="'nl.imvertor.model'"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="definition" on-no-match="shallow-copy"/>
  <xsl:mode name="field-declaration" on-no-match="shallow-skip"/>
  <xsl:mode name="field-getter-setter" on-no-match="shallow-skip"/>
        
  <xsl:template match="entity">
    <xsl:variable name="full-package-name" select="local:full-package-name(package-name)" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-package-name, '\.', '/')}/{name}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.model.*;</line>
        <line>import io.swagger.v3.oas.annotations.media.*;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema.*;</line> 
        <line>import java.util.*;</line>
        <line>import java.time.*;</line>
        <line/>
  
        <xsl:call-template name="javadoc"/>
        
        <xsl:if test="not(model-element = 'Keuze')">
          <line>@nl.imvertor.mim.annotation.{model-element}</line>  
        </xsl:if>
        
        <xsl:variable name="any-of-classes" 
          select="if (model-element = 'Keuze') then '{' || string-join(for $f in fields/field[not(auto-generate = 'true')] return local:full-package-name($f/type/@package-name) || '.' || $f/type || '.class', ', ') || '}' else ()" as="xs:string?"/>
        
        <line>@Schema({string-join((
          oas:annotation-field('description', ((funct:feature-to-commonmark(., 'OA Description'), funct:element-to-commonmark(definition)))[1]),
          oas:annotation-field('anyOf', $any-of-classes, false())), ', ')})</line>
        
        <xsl:variable name="super-type-class-name" select="super-type" as="xs:string"/>
        
        <line>public {if (is-abstract = 'true') then 'abstract ' else ''}class {name}{if (super-type) then ' extends ' || local:full-package-name(super-type/@package-name) || '.' || $super-type-class-name  else () } {{</line>
        
        <xsl:if test="not(model-element = 'Keuze')">
          <xsl:call-template name="identification-field-declarations"/>
          <xsl:apply-templates select="fields" mode="field-declaration"/>
        
          <xsl:call-template name="identification-field-getters-setters"/>
          <xsl:apply-templates select="fields" mode="field-getter-setter"/>
        </xsl:if>
        
        <line/>
        <line>}}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
    
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-package-name, '\.', '/')}/Gepagineerd{name}Lijst.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.model.GepagineerdBase;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;</line>    
        <line>import java.util.*;</line>
        <line/>
        
        <line>@Schema(allOf = GepagineerdBase.class)</line>
        <line>public class Gepagineerd{name}Lijst {{</line>
        <line/>
        <line indent="2">@Schema(requiredMode = RequiredMode.REQUIRED)</line>
        <line indent="2">private List&lt;{name}&gt; resultaten;</line>
        <line/>
        <line indent="2">public List&lt;{name}&gt; getResultaten() {{</line>
        <line indent="4">return this.resultaten;</line>
        <line indent="2">}}</line>
        <line/>
        <line indent="2">public void setResultaten(List&lt;{name}&gt; resultaten) {{</line>
        <line indent="4">this.resultaten = resultaten;</line>
        <line indent="2">}}</line>
        <line/>
        <line>}}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
    
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-package-name, '\.', '/')}/AnyOfReferentieOr{name}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.model.Referentie;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
        <line/>
                
        <line>@Schema(anyOf = {{ Referentie.class, {name}.class }})</line>
        <line>public class AnyOfReferentieOr{name} {{ }}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="enumeration">
    <xsl:variable name="full-package-name" select="local:full-package-name(package-name)" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-package-name, '\.', '/')}/{replace(name, '\.', '/')}.java" method="text">   
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        <line>import nl.imvertor.mim.annotation.*;</line>
        <line>import io.swagger.v3.oas.annotations.media.*;</line>
        <line/>
        <xsl:call-template name="javadoc"/>
        <line>@nl.imvertor.mim.annotation.{model-element}</line>
        <line>@Schema({oas:annotation-field('description', ((funct:feature-to-commonmark(., 'OA Description'), funct:element-to-commonmark(definition)))[1])})</line>
        <line>public enum {name} {{</line>
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
  
  <xsl:template match="field[not(auto-generate = 'true')]" mode="field-declaration">
    <line/>
    
    <xsl:variable name="field-name" select="local:unique-field-name(name)" as="xs:string"/>
    
    <xsl:call-template name="javadoc">
      <xsl:with-param name="indent" select="2"/>
    </xsl:call-template>
    
    <xsl:variable name="required-mode" select="if (not(cardinality/target/min-occurs = '0')) then 'RequiredMode.REQUIRED' else ()" as="xs:string?"/>
    
    <xsl:variable name="schema" as="xs:string">@Schema({string-join((
      oas:annotation-field('name', (name/@original, name)[1]),
      oas:annotation-field('description', ((funct:feature-to-commonmark(., 'OA Description'), funct:element-to-commonmark(definition)))[1]),
      oas:annotation-field('requiredMode', $required-mode, false()),
      oas:annotation-field('nullable', nullable[. = 'true'], false()),
      oas:annotation-field('minLength', size-min, false()),
      oas:annotation-field('maxLength', size-max, false()),
      oas:annotation-field('minimum', (min-incl, min-excl)[1]),
      oas:annotation-field('maximum', (max-incl, max-excl)[1]),
      oas:annotation-field('exclusiveMinimum', if (exists(min-excl/text())) then 'true' else (), false()),
      oas:annotation-field('exclusiveMaximum', if (exists(max-excl/text())) then 'true' else (), false()), 
      oas:annotation-field('pattern', formal-pattern),
      oas:annotation-field('ref', type/@openapi-ref)
      ), ', ')})</xsl:variable>
    
    <xsl:choose>
      <xsl:when test="(cardinality/target/max-occurs = $unbounded)">
        <line indent="2">@ArraySchema(schema = {$schema})</line> <!-- TODO: implement minItems, maxItems -->
      </xsl:when>
      <xsl:otherwise>
        <line indent="2">{$schema}</line>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:variable name="resolved-type" as="xs:string">
      <xsl:choose>
        <xsl:when test="type/@openapi-ref">{if (cardinality/target/max-occurs = $unbounded) then 'List&lt;Object&gt;' else 'Object'}</xsl:when>
        <xsl:otherwise>{local:type-or-reference(type, cardinality, aggregation, entity:feature(., 'OA Inclusion')[1])}</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <line indent="2">private {$resolved-type} {$field-name};</line>
    
  </xsl:template>
  
  <xsl:template match="field[not(auto-generate = 'true')]" mode="field-getter-setter">
    <xsl:variable name="field-name" select="local:unique-field-name(name)" as="xs:string"/>
    <xsl:variable name="resolved-type" as="xs:string">
      <xsl:choose>
        <xsl:when test="type/@openapi-ref">{if (cardinality/target/max-occurs = $unbounded) then 'List&lt;Object&gt;' else 'Object'}</xsl:when>
        <xsl:otherwise>{local:type-or-reference(type, cardinality, aggregation, entity:feature(., 'OA Inclusion')[1])}</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <line/>
    <line indent="2">public {$resolved-type} {if (type = 'Boolean') then 'is' else 'get'}{functx:capitalize-first($field-name)}() {{</line>
    <line indent="4">return {$field-name};</line>
    <line indent="2">}}</line>  
    
    <line/>
    <line indent="2">public void set{functx:capitalize-first($field-name)}({$resolved-type} {$field-name}) {{</line>
    <line indent="4">this.{$field-name} = {$field-name};</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="identification-field-declarations">
    <xsl:if test="not(identifying-attribute)">
      <line/>
      <line indent="2">@Schema(name = "id", description = "Unieke identificatie van de resource waarnaar verwezen wordt", type = "string", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY, minLength = 1)</line>
      <line indent="2">private String id;</line>  
    </xsl:if>
    
    <line/>
    <line indent="2">@Schema(name = "url", description = "URL-referentie naar de resource waarnaar verwezen wordt", type = "string", format = "uri", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY, minLength = 1)</line>
    <line indent="2">private String url;</line>
  </xsl:template>
  
  <xsl:template name="identification-field-getters-setters">
    <xsl:if test="not(identifying-attribute)">
      <line/>
      <line indent="2">public String getId() {{</line>
      <line indent="4">return id;</line>
      <line indent="2">}}</line>
      <line/>
      <line indent="2">public void setId(String id) {{</line>
      <line indent="4">this.id = id;</line>
      <line indent="2">}}</line>
    </xsl:if>
    <line/>
    <line indent="2">public String getUrl() {{</line>
    <line indent="4">return url;</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:function name="local:type-or-reference" as="xs:string">
    <xsl:param name="type-info" as="element()"/>
    <xsl:param name="cardinality" as="element()"/>
    <xsl:param name="aggregation" as="xs:string?"/>
    <xsl:param name="inclusion" as="xs:string?"/>        
    <xsl:choose> 
      <xsl:when test="funct:equals-case-insensitive($inclusion, 'Reference')">
        <xsl:variable name="singular-type" select="'nl.imvertor.mim.model.Referentie'" as="xs:string"/>
        <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>    
      </xsl:when>
      <xsl:when test="funct:equals-case-insensitive($inclusion, 'Embedded')">
        <xsl:sequence select="local:type($type-info, $cardinality)"/>
      </xsl:when>
      <xsl:when test="funct:equals-case-insensitive($inclusion, 'Both')">
        <xsl:variable name="singular-type" select="local:full-package-name($type-info/@package-name) || '.AnyOfReferentieOr' || $type-info" as="xs:string"/>
        <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>
      </xsl:when>
      <xsl:when test="(funct:equals-case-insensitive($aggregation, 'shared')) and not($type-info/@model-element = 'Enumeratie') and not($type-info/@is-standard = 'true')">
        <xsl:variable name="singular-type" select="'nl.imvertor.mim.model.Referentie'" as="xs:string"/>
        <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="local:type($type-info, $cardinality)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="local:unique-field-name" as="xs:string?">
    <xsl:param name="name" as="xs:string?"/>
    <xsl:sequence select="if (funct:equals-case-insensitive($name, 'url')) then '_' || $name else $name"/>
  </xsl:function>
  
</xsl:stylesheet>