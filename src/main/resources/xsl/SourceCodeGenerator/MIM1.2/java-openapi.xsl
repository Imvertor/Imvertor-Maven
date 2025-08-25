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
    
  <!-- TODO -->
  <!-- Er wordt nergens een paginanummer meegegeven -->
  <!-- Type van unieke identifiers -->  
    
  <xsl:template match="model">
    <java>
      <xsl:comment> Zie directory "imvertor.*.codegen.java-*" </xsl:comment>
      
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
        <line>import jakarta.validation.constraints.Min;</line>
        <line/>
        <line>import {local:full-package-name(package-name)}.{name};</line>
        <line>import {local:full-package-name(package-name)}.Paginated{name}List;</line>
        <line/>
        
        <xsl:variable name="type" select="(fields/field[is-id-attribute = 'true']/type, 'String')[1]" as="xs:string"/> <!-- TODO: navigate supertypes -->
        <xsl:variable name="path" select="features/feature[@name='openapi.path']" as="xs:string?"/>
        <xsl:variable name="collection-resource-rel" select="features/feature[@name='openapi.collectionResourceRel']" as="xs:string?"/>
        <xsl:variable name="item-resource-rel" select="features/feature[@name='openapi.itemResourceRel']" as="xs:string?"/>
        
        <line>@Path("/{if ($path) then $path else lower-case(name)}")</line>
        <line>@Tag(name = "{name}", description = "{local:definition-as-string(definition)}")</line> 
        <line>public class {$resource-class-name} {{</line>
        
        <xsl:call-template name="get-collection">
          <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
          <xsl:with-param name="type" as="xs:string" select="$type"/> 
          <xsl:with-param name="path" as="xs:string?" select="$path"/>
          <xsl:with-param name="collection-resource-rel" as="xs:string?" select="$collection-resource-rel"/>
          <xsl:with-param name="item-resource-rel" as="xs:string?" select="$item-resource-rel"/>
        </xsl:call-template>
        
        <xsl:call-template name="post">
          <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
          <xsl:with-param name="type" as="xs:string" select="$type"/> 
          <xsl:with-param name="path" as="xs:string?" select="$path"/>
          <xsl:with-param name="collection-resource-rel" as="xs:string?" select="$collection-resource-rel"/>
          <xsl:with-param name="item-resource-rel" as="xs:string?" select="$item-resource-rel"/>
        </xsl:call-template>
        
        <xsl:call-template name="delete">
          <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
          <xsl:with-param name="type" as="xs:string" select="$type"/> 
          <xsl:with-param name="path" as="xs:string?" select="$path"/>
          <xsl:with-param name="collection-resource-rel" as="xs:string?" select="$collection-resource-rel"/>
          <xsl:with-param name="item-resource-rel" as="xs:string?" select="$item-resource-rel"/>
        </xsl:call-template>
        
        <xsl:call-template name="get-item">
          <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
          <xsl:with-param name="type" as="xs:string" select="$type"/> 
          <xsl:with-param name="path" as="xs:string?" select="$path"/>
          <xsl:with-param name="collection-resource-rel" as="xs:string?" select="$collection-resource-rel"/>
          <xsl:with-param name="item-resource-rel" as="xs:string?" select="$item-resource-rel"/>
        </xsl:call-template>
        
        <xsl:call-template name="put">
          <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
          <xsl:with-param name="type" as="xs:string" select="$type"/> 
          <xsl:with-param name="path" as="xs:string?" select="$path"/>
          <xsl:with-param name="collection-resource-rel" as="xs:string?" select="$collection-resource-rel"/>
          <xsl:with-param name="item-resource-rel" as="xs:string?" select="$item-resource-rel"/>
        </xsl:call-template>
        
        <xsl:call-template name="patch">
          <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
          <xsl:with-param name="type" as="xs:string" select="$type"/> 
          <xsl:with-param name="path" as="xs:string?" select="$path"/>
          <xsl:with-param name="collection-resource-rel" as="xs:string?" select="$collection-resource-rel"/>
          <xsl:with-param name="item-resource-rel" as="xs:string?" select="$item-resource-rel"/>
        </xsl:call-template>
        
        <line/>
        <line>}}</line>
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template name="get-collection">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/> 
    <xsl:param name="path" as="xs:string?"/>
    <xsl:param name="collection-resource-rel" as="xs:string?"/>
    <xsl:param name="item-resource-rel" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.getCol.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@GET</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Get all {name} objects", description = "Retrieves a paginated list of all {name} objects")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "OK",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = Paginated{name}List.class))),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="response-codes" as="xs:string*" select="('400','401','403','409','410','415','429','500','501','503')"/> <!-- TODO: default -->
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response getAll{name}(</line>
    <line indent="4">@QueryParam("page")</line> 
    <line indent="4">@DefaultValue("0")</line>
    <line indent="4">@Parameter(description = "Page number (0-based)", example = "0")</line> 
    <line indent="4">@Min(0) int page,</line>
    <line/>  
    <line indent="4">@QueryParam("size")</line> 
    <line indent="4">@DefaultValue("20")</line>
    <line indent="4">@Parameter(description = "Number of items per page", example = "20")</line> 
    <line indent="4">@Min(1) int size,</line>
    <line/>  
    <line indent="4">@QueryParam("sort")</line> 
    <line indent="4">@DefaultValue("id")</line>
    <line indent="4">@Parameter(description = "Field to sort by", example = "name")</line> 
    <line indent="4">String sortBy) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="get-item">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/> 
    <xsl:param name="path" as="xs:string?"/>
    <xsl:param name="collection-resource-rel" as="xs:string?"/>
    <xsl:param name="item-resource-rel" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.getItem.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@GET</line>
    <line indent="2">@Path("/{{id}}")</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Get {name} by id", description = "Retrieves a specific {name} by their unique identifier")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "{name} was found",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class))),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="response-codes" as="xs:string*" select="('400','401','403','404','409','410','415','429','500','501','503')"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response get{name}ById(@Parameter(description = "{name} ID", example="1", required = true) @PathParam("id") Long id) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="post">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/> 
    <xsl:param name="path" as="xs:string?"/>
    <xsl:param name="collection-resource-rel" as="xs:string?"/>
    <xsl:param name="item-resource-rel" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@POST</line>
    <line indent="2">@Consumes(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Create a new {name}", description = "Creates a new {name} with the provided information")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "201", description = "{name} created successfully",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class))),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="response-codes" as="xs:string*" select="('400','401','403','409','410','415','429','500','501','503')"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response create{name}(@Parameter(description = "{name} creation data", required = true) {name} {lower-case(name)}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="delete">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/> 
    <xsl:param name="path" as="xs:string?"/>
    <xsl:param name="collection-resource-rel" as="xs:string?"/>
    <xsl:param name="item-resource-rel" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@DELETE</line>
    <line indent="2">@Path("/{{id}}")</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Delete {name}", description = "Permanently deletes a {name} from the system")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "204", description = "{name} deleted successfully"),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="response-codes" as="xs:string*" select="('400','401','403','404','409','410','415','429','500','501','503')"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response delete{name}(@Parameter(description = "{name} ID", example="1", required = true) @PathParam("id") Long id) {{</line> <!-- TODO: determine type -->
    <line indent="4">return Response.noContent().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="put">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/> 
    <xsl:param name="path" as="xs:string?"/>
    <xsl:param name="collection-resource-rel" as="xs:string?"/>
    <xsl:param name="item-resource-rel" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@PUT</line>
    <line indent="2">@Path("/{{id}}")</line>
    <line indent="2">@Consumes(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Update {name}", description = "Completely updates a {name} with new information (replaces all fields)")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "{name} updated successfully",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class))),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="response-codes" as="xs:string*" select="('400','401','403','404','409','410','415','429','500','501','503')"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response update{name}(</line>
    <line indent="4">@Parameter(description = "{name} ID", example="1", required = true) @PathParam("id") Long id,</line> 
    <line indent="4">@Parameter(description = "Complete {name} update data", required = true) {name} {lower-case(name)}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="patch">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="type" as="xs:string"/> 
    <xsl:param name="path" as="xs:string?"/>
    <xsl:param name="collection-resource-rel" as="xs:string?"/>
    <xsl:param name="item-resource-rel" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@PATCH</line>
    <line indent="2">@Path("/{{id}}")</line>
    <line indent="2">@Consumes(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Partially update {name}", description = "Partially updates a {name} by modifying only the provided fields")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "{name} updated successfully",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class))),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="response-codes" as="xs:string*" select="('400','401','403','404','409','410','415','429','500','501','503')"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response patch{name}(</line>
    <line indent="4">@Parameter(description = "{name} ID", example="1", required = true) @PathParam("id") Long id,</line> 
    <line indent="4">@Parameter(description = "Complete {name} update data", required = true) {name} {lower-case(name)}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="error-responses">
    <xsl:param name="response-codes" as="xs:string*"/>
    <xsl:for-each select="$response-codes">
      <line indent="4">@ApiResponse(responseCode = "{.}", ref="{$response-component-base-url}{.}"){if (not(position() = last())) then ',' else ()}</line>
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