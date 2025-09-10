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
    
  <xsl:param name="package-prefix" as="xs:string" select="'nl.imvertor.model'"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="definition" on-no-match="shallow-copy"/>
  <xsl:mode name="field-declaration" on-no-match="shallow-skip"/>
  <xsl:mode name="field-getter-setter" on-no-match="shallow-skip"/>
    
  <!-- TODO -->
  <!-- Min, max constraints -->
  <!-- Type van unieke identifiers --> 
  <!-- Ieder object een id en url geven? --> 
  
  <xsl:variable name="primitive-mim-openapi-type-mapping" as="map(xs:string, element(type))">
    <xsl:map>
      <xsl:map-entry key="'CharacterString'">
        <type>string</type> 
      </xsl:map-entry>
      <xsl:map-entry key="'Integer'">
        <type format="int32">number</type>
      </xsl:map-entry>
      <xsl:map-entry key="'Real'">
        <type format="double">number</type>
      </xsl:map-entry>
      <xsl:map-entry key="'Decimal'">
        <type>number</type>
      </xsl:map-entry>
      <xsl:map-entry key="'Boolean'">
        <type>boolean</type>
      </xsl:map-entry>
      <xsl:map-entry key="'Date'">
        <type format="date">string</type>
      </xsl:map-entry>
      <xsl:map-entry key="'DateTime'">
        <type format="date-time">string</type>
      </xsl:map-entry>
      <xsl:map-entry key="'Year'">
        <type format="int32">number</type>
      </xsl:map-entry>
      <xsl:map-entry key="'Day'">
        <type format="int32">number</type>
      </xsl:map-entry>
      <xsl:map-entry key="'Month'">
        <type format="int32">number</type>
      </xsl:map-entry>
      <xsl:map-entry key="'URI'">
        <type format="uri">string</type> 
      </xsl:map-entry>
    </xsl:map>
  </xsl:variable>
    
  <xsl:template match="entity">
    <xsl:variable name="full-package-name" select="local:full-package-name(package-name)" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-package-name, '\.', '/')}/{name}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.annotation.*;</line>
        <line>import nl.imvertor.mim.model.*;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema.*;</line> 
        <line>import java.util.*;</line>
        <line>import java.time.*;</line>
        <line/>
  
        <xsl:call-template name="javadoc"/>
        
        <xsl:if test="not(model-element = 'Keuze')">
          <line>@{model-element}</line>  
        </xsl:if>
        
        <xsl:variable name="description" select="local:escape-java(local:definition-as-string(definition))" as="xs:string?"/>
        <xsl:variable name="description-field" select="if ($description) then 'description = &quot;' || $description || '&quot;' else ()" as="xs:string?"/>
        <xsl:choose>
          <xsl:when test="model-element = 'Keuze'">
            <xsl:variable name="any-of-classes" 
              select="string-join(for $f in fields/field[not(auto-generate = 'true')] return local:full-package-name($f/type/@package-name) || '.' || $f/type || '.class', ', ')" as="xs:string"/>    
            <line>@Schema({if ($description-field) then $description-field || ', ' else ()}anyOf = {{ {$any-of-classes} }})</line>
          </xsl:when>
          <xsl:otherwise>
            <line>@Schema({$description-field})</line>    
          </xsl:otherwise>
        </xsl:choose>
        
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
    
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-package-name, '\.', '/')}/Paginated{name}List.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.model.PaginatedBase;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;</line>    
        <line>import java.util.*;</line>
        <line/>
        
        <line>@Schema(allOf = PaginatedBase.class)</line>
        <line>public class Paginated{name}List {{</line>
        <line/>
        <line indent="2">@Schema(requiredMode = RequiredMode.REQUIRED)</line>
        <line indent="2">private List&lt;{name}&gt; results;</line>
        <line/>
        <line indent="2">public List&lt;{name}&gt; getResults() {{</line>
        <line indent="4">return this.results;</line>
        <line indent="2">}}</line>
        <line/>
        <line indent="2">public void setResults(List&lt;{name}&gt; results) {{</line>
        <line indent="4">this.results = results;</line>
        <line indent="2">}}</line>
        <line/>
        <line>}}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
    
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-package-name, '\.', '/')}/AnyOfReferenceOr{name}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.model.Reference;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
        <line/>
                
        <line>@Schema(anyOf = {{ Reference.class, {name}.class }})</line>
        <line>public class AnyOfReferenceOr{name} {{ }}</line>
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
  
  <xsl:template match="field[not(auto-generate = 'true')]" mode="field-declaration">
    <line/>
    
    <xsl:call-template name="javadoc">
      <xsl:with-param name="indent" select="2"/>
    </xsl:call-template>
    
    <xsl:variable name="description" select="local:escape-java(local:definition-as-string(definition))" as="xs:string?"/>
    <xsl:variable name="required-mode" as="xs:string"> <!-- TODO: is this correct? -->
      <xsl:choose>        
        <xsl:when test="cardinality/target/min-occurs = '0'">RequiredMode.NOT_REQUIRED</xsl:when>
        <xsl:otherwise>RequiredMode.REQUIRED</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <line indent="2">@Schema({if ($description) then 'description = "' || $description || '", ' else ()}requiredMode = {$required-mode})</line>
    
    <xsl:variable name="resolved-type" select="local:type-or-reference(type, cardinality, aggregation, entity:feature(., 'OA Inclusion')[1])" as="xs:string"/>
    <line indent="2">private {$resolved-type} {name};</line>
  </xsl:template>
  
  <xsl:template match="field[not(auto-generate = 'true')]" mode="field-getter-setter">
    <xsl:variable name="resolved-type" select="local:type-or-reference(type, cardinality, aggregation, entity:feature(., 'OA Inclusion')[1])" as="xs:string"/>
    <line/>
    <line indent="2">public {$resolved-type} {if (type = 'Boolean') then 'is' else 'get'}{functx:capitalize-first(name)}() {{</line>
    <line indent="4">return {name};</line>
    <line indent="2">}}</line>  
    
    <line/>
    <line indent="2">public void set{functx:capitalize-first(name)}({$resolved-type} {name}) {{</line>
    <line indent="4">this.{name} = {name};</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="identification-field-declarations">
    <xsl:if test="not(identifying-attribute)">
      <line/>
      <line indent="2">@Schema(description = "Unieke identificatie van de resource waarnaar verwezen wordt", type = "string", requiredMode = RequiredMode.REQUIRED, minLength = 1)</line>
      <line indent="2">private String id;</line>  
    </xsl:if>
    
    <line/>
    <line indent="2">@Schema(description = "URL-referentie naar de resource waarnaar verwezen wordt", type = "string", format = "uri", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY, minLength = 1)</line>
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
        <xsl:variable name="singular-type" select="'nl.imvertor.mim.model.Reference'" as="xs:string"/>
        <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>    
      </xsl:when>
      <xsl:when test="funct:equals-case-insensitive($inclusion, 'Embedded')">
        <xsl:sequence select="local:type($type-info, $cardinality)"/>
      </xsl:when>
      <xsl:when test="funct:equals-case-insensitive($inclusion, 'Both')">
        <xsl:variable name="singular-type" select="local:full-package-name($type-info/@package-name) || '.AnyOfReferenceOr' || $type-info" as="xs:string"/>
        <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>
      </xsl:when>
      <xsl:when test="(funct:equals-case-insensitive($aggregation, 'shared')) and not($type-info/@model-element = 'Enumeratie') and not($type-info/@is-standard = 'true')">
        <xsl:variable name="singular-type" select="'nl.imvertor.mim.model.Reference'" as="xs:string"/>
        <xsl:value-of select="if ($cardinality/target/max-occurs = $unbounded) then 'List&lt;' || $singular-type || '&gt;' else $singular-type"/>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="local:type($type-info, $cardinality)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>