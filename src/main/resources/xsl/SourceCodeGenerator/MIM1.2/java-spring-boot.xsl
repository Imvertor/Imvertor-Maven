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
  
  <xsl:param name="repository-package-prefix" as="xs:string" select="'nl.imvertor.repository'"/>
  
  <xsl:variable name="mode" as="xs:string" select="'spring-boot-repository'"/>
  
  <!--  
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
  -->
  
  <xsl:template match="model">
    <java>
      <xsl:comment> Zie directory "imvertor.*.codegen.java-jpa" </xsl:comment>
      
      <!-- Generate the JpaRepository interfaces: -->
      <xsl:apply-templates select=".//entity[(model-element = 'Objecttype') and (is-abstract = 'false') and not(funct:equals-case-insensitive(features/feature[@name = 'openapi.expose'], ('false', 'no', 'nee')))]"/>
      
      <!-- Generate openapi.properties: -->
      <xsl:call-template name="generate-openapi-properties"/>
    </java>
  </xsl:template>
    
  <xsl:template match="entity">
    <xsl:variable name="full-repository-package-name" select="local:full-repository-package-name(package-name)" as="xs:string"/>
    <xsl:variable name="repository-class-name" select="name || 'Repository'" as="xs:string"/>
    
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-repository-package-name, '\.', '/')}/{$repository-class-name}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-repository-package-name};</line>
        <line/>
        
        <!-- imports: -->
        <line>import org.springframework.data.jpa.repository.JpaRepository;</line>
        <line>import org.springframework.data.rest.core.annotation.RepositoryRestResource;</line>
        <line/>
        <line>import {local:full-package-name(package-name)}.{name};</line>
        <line/>
        
        <xsl:variable name="type" select="(fields/field[is-id-attribute = 'true']/type, 'String')[1]" as="xs:string"/> <!-- TODO: navigate supertypes -->
        <xsl:variable name="path" select="features/feature[@name='openapi.path']" as="xs:string?"/>
        <xsl:variable name="collection-resource-rel" select="features/feature[@name='openapi.collectionResourceRel']" as="xs:string?"/>
        <xsl:variable name="item-resource-rel" select="features/feature[@name='openapi.itemResourceRel']" as="xs:string?"/>
        
        <line>@RepositoryRestResource(path = "{if ($path) then $path else lower-case(name)}", collectionResourceRel = "{if ($collection-resource-rel) then $collection-resource-rel else lower-case(name)}", itemResourceRel = "{if ($item-resource-rel) then $item-resource-rel else lower-case(name)}")</line> <!-- TODO: make configurable -->
        <line>public interface {$repository-class-name} extends JpaRepository&lt;{name}, {$type}&gt; {{ }}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template name="generate-openapi-properties">
    <xsl:result-document href="{$output-uri}/src/main/resources/openapi.properties" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        
        <xsl:if test="not(/model/features/feature[@name = 'openapi.title'])">
          <line>openapi.title={/model/title}</line>
        </xsl:if>
        <xsl:if test="not(/model/features/feature[@name = 'openapi.description'])">
          <line>openapi.description={local:definition-as-string(/model/definition)}</line>
        </xsl:if>
        
        <xsl:for-each select="/model/features/feature[starts-with(@name, 'openapi.')]">
          <line>{@name}={.}</line>
        </xsl:for-each>
     
        <line/>
        <xsl:for-each select="//entity[model-element = 'Objecttype']">
          <xsl:variable name="entity" select="." as="element(entity)"/>
          <xsl:for-each select="features/feature[starts-with(@name, 'openapi.')]">
            <line>openapi.{local:full-package-name($entity/package-name)}.{$entity/name}.{substring-after(@name, 'openapi.')}={.}</line>  
          </xsl:for-each>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
  <!--
  <xsl:template match="line">
    <xsl:if test="not(@mode) or (@mode = $mode)">
      <xsl:variable name="indent" select="if (@indent) then xs:integer(@indent) else 0" as="xs:integer"/>
      <xsl:sequence select="string-join(((for $i in 1 to $indent return ' '), ., $lf))"/>  
    </xsl:if>
  </xsl:template>
  -->
  
  <xsl:function name="local:full-repository-package-name" as="xs:string">
    <xsl:param name="package-name" as="xs:string"/>
    <xsl:sequence select="string-join(($repository-package-prefix, $package-name), '.')"/>
  </xsl:function>
  
  <xsl:function name="local:full-package-name" as="xs:string">
    <xsl:param name="package-name" as="xs:string"/>
    <xsl:sequence select="string-join(($package-prefix, $package-name), '.')"/>
  </xsl:function>
  
  <!--
  <xsl:function name="local:entity-and-supertypes" as="element(entity)*">
    <xsl:param name="context" as="element(entity)"/>
    <xsl:param name="visited" as="element(entity)*"/>
    <xsl:if test="$context">
      
      
      <xsl:sequence select="($visited, local:entity-and-supertypes($context, $visited))"/>
    </xsl:if>
  </xsl:function>
  -->
  
</xsl:stylesheet>