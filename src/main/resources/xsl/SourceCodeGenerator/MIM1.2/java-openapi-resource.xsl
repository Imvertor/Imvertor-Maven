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
  
  <xsl:param name="package-prefix" as="xs:string" select="'nl.imvertor.model'"/>
  <xsl:param name="resource-package-prefix" as="xs:string" select="'nl.imvertor.resource'"/>
  
  <xsl:variable name="common-base-url" as="xs:string">https://armatiek.github.io/imvertor-openapi-generator/openapi/generiek.yaml</xsl:variable>
  <xsl:variable name="response-component-base-url" as="xs:string">{$common-base-url}#/components/responses/</xsl:variable>
  <xsl:variable name="global-openapi-methods" select="lower-case(normalize-space(/model/features/feature[@name = 'openapi.methods']))" as="xs:string?"/>  
  <xsl:variable name="api-version" select="normalize-space((/model/features/feature[@name = 'openapi.pathVersion'], '1'))[1]" as="xs:string?"/>  
  
  <xsl:variable name="openapi-getcol-response-codes" as="xs:string+" select="('400','401','403','404','405','415','429','500','503')"/>
  <xsl:variable name="openapi-getitem-response-codes" as="xs:string+" select="('400','401','403','404','405','415','429','500','503')"/>
  <xsl:variable name="openapi-post-response-codes" as="xs:string+" select="('400','401','403','405','409','415','422','429','500','503')"/>
  <xsl:variable name="openapi-delete-response-codes" as="xs:string+" select="('401','403','404','405','409','415','429','500','503')"/>
  <xsl:variable name="openapi-put-response-codes" as="xs:string+" select="('400','401','403','404','405','409','415','429','500','503')"/>
  <xsl:variable name="openapi-patch-response-codes" as="xs:string+" select="('400','401','403','404','405','409','415','422','429','500','503')"/>
        
  <xsl:template match="model">
    <java>
      <xsl:comment> Zie directory "imvertor.*.codegen.java-*" </xsl:comment>
      
      <!-- Generate the Java Resource classes: -->
      <xsl:apply-templates select=".//entity[(model-element = 'Objecttype') and (is-abstract = 'false') and not(funct:equals-case-insensitive(features/feature[@name = 'openapi.expose'], ('false', 'no', 'nee')))]"/>
      
      <!-- Generate openapi.properties: -->
      <!--
      <xsl:call-template name="generate-openapi-properties"/>
      -->
      
      <xsl:call-template name="generate-openapi-header"/>
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
        <line>import io.swagger.v3.oas.annotations.headers.*;</line>
        <line>import io.swagger.v3.oas.annotations.tags.Tag;</line>
        <line/>
        <line>import jakarta.validation.constraints.Min;</line>
        <line/>
        <line>import {local:full-package-name(package-name)}.{name};</line>
        <line>import {local:full-package-name(package-name)}.Paginated{name}List;</line>
        <line/>
        
        <xsl:variable name="identifying-field" select="identifying-attribute/field" as="element(field)?"/>
        <xsl:variable name="id-name" select="($identifying-field/name, 'id')[1]" as="xs:string"/>
        <xsl:variable name="id-type" select="($identifying-field/type, 'String')[1]" as="xs:string"/>
        <xsl:variable name="path" select="features/feature[@name='openapi.path']" as="xs:string?"/>
        
        <line>@Path("/v{$api-version}/{if ($path) then $path else lower-case(name)}")</line>
        <line>@Tag(name = "{name}", description = "{local:definition-as-string(definition)}")</line> 
        <line>public class {$resource-class-name} {{</line>
        
        <xsl:variable name="openapi-methods" select="features/feature[@name = 'openapi.methods']" as="xs:string?"/>
        
        <xsl:if test="local:expose-method('getCol', $openapi-methods)">
          <xsl:call-template name="get-collection">
            <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
            <xsl:with-param name="path" as="xs:string?" select="$path"/>
          </xsl:call-template>  
        </xsl:if>
        
        <xsl:if test="local:expose-method('post', $openapi-methods)">
          <xsl:call-template name="post">
            <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/> 
            <xsl:with-param name="path" as="xs:string?" select="$path"/>
          </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="local:expose-method('delete', $openapi-methods)">
          <xsl:call-template name="delete">
            <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
            <xsl:with-param name="id-name" as="xs:string" select="$id-name"/>
            <xsl:with-param name="id-type" as="xs:string" select="$id-type"/>
            <xsl:with-param name="path" as="xs:string?" select="$path"/>
          </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="local:expose-method('getItem', $openapi-methods)">
          <xsl:call-template name="get-item">
            <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
            <xsl:with-param name="id-name" as="xs:string" select="$id-name"/>
            <xsl:with-param name="id-type" as="xs:string" select="$id-type"/>  
            <xsl:with-param name="path" as="xs:string?" select="$path"/>
          </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="local:expose-method('put', $openapi-methods)">
          <xsl:call-template name="put">
            <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
            <xsl:with-param name="id-name" as="xs:string" select="$id-name"/>
            <xsl:with-param name="id-type" as="xs:string" select="$id-type"/> 
            <xsl:with-param name="path" as="xs:string?" select="$path"/>
          </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="local:expose-method('patch', $openapi-methods)">
          <xsl:call-template name="patch">
            <xsl:with-param name="resource-class-name" as="xs:string" select="$resource-class-name"/>
            <xsl:with-param name="id-name" as="xs:string" select="$id-name"/>
            <xsl:with-param name="id-type" as="xs:string" select="$id-type"/>
            <xsl:with-param name="path" as="xs:string?" select="$path"/>
          </xsl:call-template>
        </xsl:if>
        
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
    <xsl:param name="path" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.getCol.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@GET</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Retourneert de lijst van alle {name} objecten", description = "Retourneert een gepagineerde lijst van alle {name} objecten")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "OK",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = Paginated{name}List.class)),</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
        
    <xsl:call-template name="error-responses">
      <xsl:with-param name="configured-response-codes" select="/model/features/feature[@name = 'openapi.getCol.responseCodes']" as="xs:string?"/>
      <xsl:with-param name="default-response-codes" select="$openapi-getcol-response-codes" as="xs:string+"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response getAll{name}(</line>
    <line indent="4">@Parameter(ref = "https://armatiek.github.io/imvertor-openapi-generator/openapi/generiek.yaml#/components/parameters/page")</line>
    <line indent="4">int page,</line>
    <line indent="4">@Parameter(ref = "https://armatiek.github.io/imvertor-openapi-generator/openapi/generiek.yaml#/components/parameters/pageSize")</line>
    <line indent="4">int pageSize,</line>
    <line indent="4">@Parameter(ref = "https://armatiek.github.io/imvertor-openapi-generator/openapi/generiek.yaml#/components/parameters/sortField")</line>
    <line indent="4">String sortField) {{</line>
    
    <!--
    <line indent="4">@QueryParam("page")</line> 
    <line indent="4">@DefaultValue("0")</line>
    <line indent="4">@Parameter(description = "Paginanummer (beginnend bij 0)", example = "0")</line> 
    <line indent="4">@Min(0) int page,</line>
    <line/>  
    <line indent="4">@QueryParam("size")</line> 
    <line indent="4">@DefaultValue("20")</line>
    <line indent="4">@Parameter(description = "Aantal objecten per pagina", example = "20")</line> 
    <line indent="4">@Min(1) int size,</line>
    <line/>  
    <line indent="4">@QueryParam("sort")</line> 
    <line indent="4">@DefaultValue("id")</line>
    <line indent="4">@Parameter(description = "Sorteerveld", example = "name")</line> 
    <line indent="4">String sortBy) {{</line>
    -->
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="get-item">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="id-name" as="xs:string"/>
    <xsl:param name="id-type" as="xs:string"/>
    <xsl:param name="path" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.getItem.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@GET</line>
    <line indent="2">@Path("/{{{$id-name}}}")</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Retourneert een {name} object op basis van zijn unieke identificatie", description = "Retourneert een individueel {name} object op basis van zijn unieke identificatie")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "{name} was gevonden",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class)),</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="configured-response-codes" select="/model/features/feature[@name = 'openapi.getItem.responseCodes']" as="xs:string?"/>
      <xsl:with-param name="default-response-codes" select="$openapi-getitem-response-codes" as="xs:string+"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response get{name}ById(@Parameter(description = "{name} ID", example="1", required = true) @PathParam("{$id-name}") {$id-type} {$id-name}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="post">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="path" as="xs:string?"/> 
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@POST</line>
    <line indent="2">@Consumes(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Maakt een nieuw {name} object", description = "Maakt een nieuw {name} object aan op basis van de aangeleverde gegevens")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "201", description = "{name} succesvol aangemaakt",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class)),</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version"),</line>
    <line indent="8">@Header(name = "Location", description = "URI van het opgeslagen object", schema = @Schema(type = "string", format = "uri"))}}),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="configured-response-codes" select="/model/features/feature[@name = 'openapi.post.responseCodes']" as="xs:string?"/>
      <xsl:with-param name="default-response-codes" select="$openapi-post-response-codes" as="xs:string+"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response create{name}(@Parameter(description = "De gegevens van het {name} object", required = true) {name} {lower-case(name)}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="delete">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="id-name" as="xs:string"/>
    <xsl:param name="id-type" as="xs:string"/>
    <xsl:param name="path" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@DELETE</line>
    <line indent="2">@Path("/{{{$id-name}}}")</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Verwijderd een {name} object", description = "Verwijderd een specifiek {name} object permanent uit het systeem")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "202", description = "{name} object zal worden verwijderd",</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
    <line indent="4">@ApiResponse(responseCode = "204", description = "{name} object succesvol verwijderd",</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="configured-response-codes" select="/model/features/feature[@name = 'openapi.delete.responseCodes']" as="xs:string?"/>
      <xsl:with-param name="default-response-codes" select="$openapi-delete-response-codes" as="xs:string+"/>
    </xsl:call-template>
     
    <line indent="2">}})</line>
    <line indent="2">public Response delete{name}(@Parameter(description = "{name} ID", example="1", required = true) @PathParam("{$id-name}") {$id-type} {$id-name}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="put">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="id-name" as="xs:string"/>
    <xsl:param name="id-type" as="xs:string"/>
    <xsl:param name="path" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@PUT</line>
    <line indent="2">@Path("/{{{$id-name}}}")</line>
    <line indent="2">@Consumes(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Maakt nieuw of overschrijft bestaand {name} object", description = "Maakt een nieuw of overschrijft (volledig) een bestaand {name} object")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "{name} object succesvol aangemaakt/overschreven",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class)),</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version"),</line>
    <line indent="8">@Header(name = "Location", description = "URI van het opgeslagen object", schema = @Schema(type = "string", format = "uri"))}}),</line>
    <line indent="4">@ApiResponse(responseCode = "201", description = "{name} object succesvol aangemaakt",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class)),</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version"),</line>
    <line indent="8">@Header(name = "Location", description = "URI van het opgeslagen object", schema = @Schema(type = "string", format = "uri"))}}),</line>
    <line indent="4">@ApiResponse(responseCode = "204", description = "{name} object succesvol overschreven",</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="configured-response-codes" select="/model/features/feature[@name = 'openapi.put.responseCodes']" as="xs:string?"/>
      <xsl:with-param name="default-response-codes" select="$openapi-put-response-codes" as="xs:string+"/>
    </xsl:call-template>
        
    <line indent="2">}})</line>
    <line indent="2">public Response update{name}(</line>
    <line indent="4">@Parameter(description = "{name} ID", example="1", required = true) @PathParam("{$id-name}") {$id-type} {$id-name},</line> 
    <line indent="4">@Parameter(description = "Complete {name} update data", required = true) {name} {lower-case(name)}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="patch">
    <xsl:param name="resource-class-name" as="xs:string"/>
    <xsl:param name="id-name" as="xs:string"/>
    <xsl:param name="id-type" as="xs:string"/>
    <xsl:param name="path" as="xs:string?"/>
    
    <xsl:variable name="operation-id" select="features/feature[@name='openapi.post.operationId']" as="xs:string?"/>
    
    <line/>
    <line indent="2">@PATCH</line>
    <line indent="2">@Path("/{{{$id-name}}}")</line>
    <line indent="2">@Consumes(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    <line indent="2">@Operation({if ($operation-id) then 'operationId = "{$operation-id}", ' else ()}summary = "Werkt een bestaand {name} object gedeeltelijk bij", description = "Werkt een bestaand {name} object gedeeltelijk bij door alleen de aangeleverde velden te overschrijven")</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <line indent="4">@ApiResponse(responseCode = "200", description = "{name} object succesvol aangemaakt/overschreven",</line>
    <line indent="6">content = @Content(mediaType = "application/json",</line> 
    <line indent="6">schema = @Schema(implementation = {name}.class)),</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version"),</line>
    <line indent="8">@Header(name = "Location", description = "URI van het opgeslagen object", schema = @Schema(type = "string", format = "uri"))}}),</line>
    <line indent="4">@ApiResponse(responseCode = "204", description = "{name} object succesvol overschreven",</line>
    <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
    
    <xsl:call-template name="error-responses">
      <xsl:with-param name="configured-response-codes" select="/model/features/feature[@name = 'openapi.patch.responseCodes']" as="xs:string?"/>
      <xsl:with-param name="default-response-codes" select="$openapi-patch-response-codes" as="xs:string+"/>
    </xsl:call-template>
    
    <line indent="2">}})</line>
    <line indent="2">public Response patch{name}(</line>
    <line indent="4">@Parameter(description = "{name} ID", example="1", required = true) @PathParam("{$id-name}") {$id-type} {$id-name},</line> 
    <line indent="4">@Parameter(description = "{name} update data", required = true) {name} {lower-case(name)}) {{</line>
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
  
  <xsl:template name="error-responses">
    <xsl:param name="configured-response-codes" as="xs:string?"/>
    <xsl:param name="default-response-codes" as="xs:string+"/>
    <xsl:variable name="resolved-response-codes" as="xs:string*">
      <xsl:choose>
        <xsl:when test="$configured-response-codes">
          <xsl:sequence select="tokenize($configured-response-codes, '[,; ]+')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$default-response-codes"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="$resolved-response-codes">
      <line indent="4">@ApiResponse(responseCode = "{.}", ref="{$response-component-base-url}{.}"){if (not(position() = last())) then ',' else ()}</line>
    </xsl:for-each>
  </xsl:template>
  
  <!--
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
        
      </xsl:variable>
      <xsl:variable name="lines" as="xs:string*">
        <xsl:apply-templates select="$lines-elements"/>  
      </xsl:variable>
      <xsl:sequence select="string-join($lines)"/>
    </xsl:result-document>
  </xsl:template>
  -->
  
  <xsl:template name="generate-openapi-header">
    <xsl:result-document href="{$output-uri}/src/main/java/nl/imvertor/resource/OpenApiDefinition.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <xsl:variable name="title" select="local:feature(/model, 'openapi.title')" as="xs:string?"/>
        <xsl:variable name="description" select="local:feature(/model, 'openapi.description')" as="xs:string?"/>
        
        <line>package nl.imvertor.resource;</line>
        <line/>
        <line>import io.swagger.v3.oas.annotations.OpenAPIDefinition;</line>
        <line>import io.swagger.v3.oas.annotations.info.*;</line>
        <line>import io.swagger.v3.oas.annotations.servers.*;</line>
        <line>import io.swagger.v3.oas.annotations.tags.*;</line>
        <line/>
        <line>@OpenAPIDefinition(</line>
        <line indent="2">info = @Info(</line>
        <line indent="4">title = "{(local:feature(/model,'openapi.title'), /model/title)[1]}",</line>
        <line indent="4">description = "{(local:feature(/model,'openapi.description'), local:definition-as-string(/model/definition))}",</line>
        <line indent="4">version = "{(local:feature(/model,'openapi.version'), '1.0.0')[1]}",</line>
        <!-- TODO, make contact configurable: -->
        <line indent="4">contact = @Contact(</line>
        <line indent="6">url = "{local:feature(/model,'openapi.contact')}"</line>
        <line indent="4">),</line>
        <line indent="4">license = @License(</line>
        <line indent="6">name = "European Union Public License, version 1.2 (EUPL-1.2)",</line>
        <line indent="6">url = "https://eupl.eu/1.2/nl/"</line>
        <line indent="4">)</line>
        <line indent="2">),</line>
        <line indent="2">servers = {{</line>
        <xsl:for-each select="local:feature(/model,'openapi.server')">
          <line indent="4">@Server(url = "{.}")</line>  
        </xsl:for-each>
        <line indent="2">}}</line>
        <line>)</line>
        <line>public class OpenApiDefinition {{ }}</line>
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
  
  <xsl:function name="local:expose-method" as="xs:boolean">
    <xsl:param name="method" as="xs:string"/>
    <xsl:param name="openapi-methods" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="normalize-space($openapi-methods)">
        <xsl:sequence select="functx:contains-case-insensitive($openapi-methods, $method)"/>
      </xsl:when>
      <xsl:when test="normalize-space($global-openapi-methods)">
        <xsl:sequence select="functx:contains-case-insensitive($global-openapi-methods, $method)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="true()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="local:feature" as="xs:string*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$context/features/feature[lower-case(@name) = lower-case($name)]/text()[normalize-space()]"/>
  </xsl:function>
  
</xsl:stylesheet>