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
  
  <xsl:param name="resource-package-prefix" as="xs:string" select="'nl.imvertor.resource'"/>
  
  <xsl:variable name="response-component-base-url" as="xs:string">https://raw.githubusercontent.com/VNG-Realisatie/API-Kennisbank/master/common/common.yaml#/components/responses/</xsl:variable>
    
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
    <xsl:variable name="full-resource-package-name" select="local:full-resource-package-name(package-name)" as="xs:string"/>
    <xsl:variable name="resource-class-name" select="name || 'Resource'" as="xs:string"/>
    
    <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-resource-package-name, '\.', '/')}/{$resource-class-name}.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <line>package {$full-resource-package-name};</line>
        <line/>
        
        <line>import javax.ws.rs.*;</line>
        <line>import javax.ws.rs.core.*;</line>
        
        <line>import io.swagger.v3.oas.annotations.*;</line>
        <line>import io.swagger.v3.oas.annotations.media.*;</line>
        <line>import io.swagger.v3.oas.annotations.responses.*;</line>
        <line>import io.swagger.v3.oas.annotations.tags.Tag;</line>
        <line/>
        <line>import {local:full-package-name(package-name)}.{name};</line>
        <line>import {local:full-package-name(package-name)}.Paginated{name}List;</line>
        <line/>
        
        <xsl:variable name="type" select="(fields/field[is-id-attribute = 'true']/type, 'String')[1]" as="xs:string"/> <!-- TODO: navigate supertypes -->
        <xsl:variable name="path" select="features/feature[@name='openapi.path']" as="xs:string?"/>
        
        <xsl:variable name="collection-resource-rel" select="features/feature[@name='openapi.collectionResourceRel']" as="xs:string?"/>
        <xsl:variable name="item-resource-rel" select="features/feature[@name='openapi.itemResourceRel']" as="xs:string?"/>
        
        <xsl:variable name="operation-id" select="features/feature[@name='openapi.getCol.operationId']" as="xs:string?"/>
        <line>@Path("/{if ($path) then $path else lower-case(name)}")</line>
        <line>@Tag(name = "TODO", description = "TODO")</line> 
        <line>public class {$resource-class-name} {{</line>
        <line/>
        <line indent="2">@GET</line>
        <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
        <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "TODO", description = "TODO")</line>
        <line indent="2">@ApiResponses(value = {{</line>
        <line indent="4">@ApiResponse(responseCode = "200", description = "OK",</line>
        <line indent="6">content = @Content(mediaType = "application/json",</line> 
        <line indent="6">schema = @Schema(implementation = Paginated{name}List[].class))),</line>
        
        <!-- TODO: 200 -->
        
        <line indent="4">@ApiResponse(responseCode = "400", ref="{$response-component-base-url}400"),</line>
        <line indent="4">@ApiResponse(responseCode = "401", ref="{$response-component-base-url}401"),</line>
        <line indent="4">@ApiResponse(responseCode = "403", ref="{$response-component-base-url}403"),</line>
        <line indent="4">@ApiResponse(responseCode = "409", ref="{$response-component-base-url}409"),</line>
        <line indent="4">@ApiResponse(responseCode = "410", ref="{$response-component-base-url}410"),</line>
        <line indent="4">@ApiResponse(responseCode = "415", ref="{$response-component-base-url}415"),</line>
        <line indent="4">@ApiResponse(responseCode = "429", ref="{$response-component-base-url}429"),</line>
        <line indent="4">@ApiResponse(responseCode = "500", ref="{$response-component-base-url}500"),</line>
        <line indent="4">@ApiResponse(responseCode = "501", ref="{$response-component-base-url}401"),</line>
        <line indent="4">@ApiResponse(responseCode = "503", ref="{$response-component-base-url}503")</line>

        <line indent="2">}})</line>
        <line indent="2">public Response getAll{name}() {{</line>
        <line indent="4">return Response.ok().build();</line>
        <line indent="2">}}</line>
        <line/>
        <line>}}</line>
        <line/>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template name="get-collection">
    
  </xsl:template>
  
  <xsl:template name="error-responses">
    <xsl:param name="response-codes" as="xs:string*"/>
    <xsl:for-each select="$response-codes">
      <line indent="4">@ApiResponse(responseCode = "{.}", ref="{$response-component-base-url}{.}")</line>
    </xsl:for-each>
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
  
  <xsl:function name="local:full-resource-package-name" as="xs:string">
    <xsl:param name="package-name" as="xs:string"/>
    <xsl:sequence select="string-join(($resource-package-prefix, $package-name), '.')"/>
  </xsl:function>
  
  <xsl:function name="local:full-package-name" as="xs:string">
    <xsl:param name="package-name" as="xs:string"/>
    <xsl:sequence select="string-join(($package-prefix, $package-name), '.')"/>
  </xsl:function>
  
</xsl:stylesheet>