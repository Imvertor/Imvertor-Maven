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
  
  <xsl:include href="entity-functions.xsl"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="definition" on-no-match="shallow-copy"/>
  <xsl:mode name="field-declaration" on-no-match="shallow-skip"/>
  <xsl:mode name="field-getter-setter" on-no-match="shallow-skip"/>
    
  <xsl:template match="entity">
    <xsl:variable name="full-package-name" select="local:full-package-name(package-name)" as="xs:string"/>
    <xsl:result-document href="{$output-uri}/{replace($full-package-name, '\.', '/')}/{name}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.annotation.*;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;</line>    
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
        
        <xsl:variable name="description" select="local:escape-java(local:definition-as-string(definition))" as="xs:string?"/>
        <xsl:if test="$description">
          <line>@Schema(description = "{$description}")</line>
        </xsl:if>
        
        <xsl:variable name="super-type-class-name" select="super-type" as="xs:string"/>
        
        <line>public {if (is-abstract = 'true') then 'abstract ' else ''}class {name}{if (super-type) then ' extends ' || local:full-package-name(super-type/@package-name) || '.' || $super-type-class-name  else () } {{</line>
        
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
    
    <xsl:result-document href="{$output-uri}/{replace($full-package-name, '\.', '/')}/Paginated{name}List.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import nl.imvertor.mim.annotation.*;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema;</line>
        <line>import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;</line>    
        <line>import java.util.*;</line>
        <line/>
        
        <!-- TODO
        <line>@Schema(description = "{$description}")</line>
        -->
 
        <line>public class Paginated{name}List {{</line>
        <line/>
        <line indent="2">private String next;</line>
        <line/>
        <line indent="2">private String previous;</line>
        <line/>
        <line indent="2">private List&lt;{name}&gt; results;</line>
        <line/>
        <line indent="2">public String getNext() {{</line>
        <line indent="4">return this.next;</line>
        <line indent="2">}}</line>
        <line/>
        <line indent="2">public void setNext(String next) {{</line>
        <line indent="4">this.next = next;</line>
        <line indent="2">}}</line>
        <line/>
        <line indent="2">public String getPrevious() {{</line>
        <line indent="4">return this.previous;</line>
        <line indent="2">}}</line>
        <line/>
        <line indent="2">public void setPrevious(String previous) {{</line>
        <line indent="4">this.previous = previous;</line>
        <line indent="2">}}</line>
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
    
    <xsl:variable name="description" select="local:escape-java(local:definition-as-string(definition))" as="xs:string?"/>
    <xsl:variable name="required-mode" as="xs:string"> <!-- TODO: is this correct? -->
      <xsl:choose>
        <xsl:when test="cardinality/target/max-occurs = '1'">RequiredMode.REQUIRED</xsl:when>
        <xsl:otherwise>RequiredMode.NOT_REQUIRED</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <line indent="2">@Schema({if ($description) then 'description = "' || $description || '", ' else ()}requiredMode = {$required-mode})</line>
    
    <xsl:variable name="resolved-type" select="local:type(type, cardinality)" as="xs:string"/>
    <line indent="2">private {$resolved-type} {name};</line>
  </xsl:template>
  
  <xsl:template match="field" mode="field-getter-setter">
    <xsl:variable name="resolved-type" select="local:type(type, cardinality)" as="xs:string"/>
    <line/>
    <line indent="2">public {$resolved-type} {if (type = 'Boolean') then 'is' else 'get'}{functx:capitalize-first(name)}() {{</line>
    <line indent="2">  return {name};</line>
    <line indent="2">}}</line>  
    
    <line/>
    <line indent="2">public void set{functx:capitalize-first(name)}({$resolved-type} {name}) {{</line>
    <line indent="2">  this.{name} = {name};</line>
    <line indent="2">}}</line>
  </xsl:template>
  
</xsl:stylesheet>