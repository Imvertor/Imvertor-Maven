<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:functx="http://www.functx.com"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:local="urn:local"
  xmlns:entity="urn:entity"
  xmlns:funct="urn:funct"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
    
  <xsl:import href="java-base.xsl"/>
  
  <xsl:include href="xhtml-to-commonmark.xsl"/>
      
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:param name="package-prefix" as="xs:string" select="'nl.imvertor.model'"/>
  <xsl:param name="resource-package-prefix" as="xs:string" select="'nl.imvertor.resource'"/>
  <xsl:param name="openapi-spec-version" as="xs:string">api30</xsl:param>
  <xsl:param name="openapi-schemas-only" as="xs:boolean" select="false()"/>
    
  <xsl:variable name="common-base-url" as="xs:string">https://armatiek.github.io/imvertor-openapi-generator/openapi/generiek.yaml</xsl:variable>
  <xsl:variable name="response-component-base-url" as="xs:string">{$common-base-url}#/components/responses/</xsl:variable>
     
  <xsl:variable name="openapi-getcol-response-codes" as="xs:string+" select="('200','400','401','403','404','405','415','429','500','503')"/>
  <xsl:variable name="openapi-getitem-response-codes" as="xs:string+" select="('200','400','401','403','404','405','415','429','500','503')"/>
  <xsl:variable name="openapi-post-response-codes" as="xs:string+" select="('201','400','401','403','405','409','415','422','429','500','503')"/>
  <xsl:variable name="openapi-delete-response-codes" as="xs:string+" select="('202','204','401','403','404','405','409','415','429','500','503')"/>
  <xsl:variable name="openapi-put-response-codes" as="xs:string+" select="('200','201','204','400','401','403','404','405','409','415','429','500','503')"/>
  <xsl:variable name="openapi-patch-response-codes" as="xs:string+" select="('200','204','400','401','403','404','405','409','415','422','429','500','503')"/>
  
  <xsl:variable name="method-id-response-codes-map" as="map(xs:string, xs:string+)">
    <xsl:map>
      <xsl:map-entry key="'get collection'" select="$openapi-getcol-response-codes"/>
      <xsl:map-entry key="'get item'" select="$openapi-getitem-response-codes"/>
      <xsl:map-entry key="'post'" select="$openapi-post-response-codes"/>
      <xsl:map-entry key="'delete'" select="$openapi-delete-response-codes"/>
      <xsl:map-entry key="'put'" select="$openapi-put-response-codes"/>
      <xsl:map-entry key="'patch'" select="$openapi-patch-response-codes"/>
    </xsl:map>
  </xsl:variable>
        
  <xsl:template match="model">
    <java>
      <xsl:comment> Zie directory "imvertor.*.codegen.java-*" </xsl:comment>
      
      <xsl:call-template name="generate-standard-operations"/>
      <xsl:call-template name="generate-custom-operations"/>
      <xsl:call-template name="generate-openapi-header"/>
    </java>
  </xsl:template>
    
  <xsl:template name="generate-standard-operations"> 
    <xsl:for-each select=".//entity[(model-element = 'Objecttype') and (is-abstract = 'false') and not(entity:feature(., 'OA Expose') = 'no')]">
      
      <xsl:variable name="full-resource-package-name" select="local:full-resource-package-name(package-name)" as="xs:string"/>
      <xsl:variable name="resource-class-name" select="name || 'Resource'" as="xs:string"/>
      
      <xsl:result-document href="{$output-uri}/src/main/java/{replace($full-resource-package-name, '\.', '/')}/{$resource-class-name}.java" method="text">  
        <xsl:variable name="lines-elements" as="element(line)+"> 
          <line>package {$full-resource-package-name};</line>
          <line/>
          
          <line>import javax.ws.rs.*;</line>
          <line>import javax.ws.rs.core.*;</line>
          <line/>
          <line>import io.swagger.v3.oas.annotations.*;</line>
          <line>import io.swagger.v3.oas.annotations.media.*;</line>
          <line>import io.swagger.v3.oas.annotations.responses.*;</line>
          <line>import io.swagger.v3.oas.annotations.headers.*;</line>
          <line>import io.swagger.v3.oas.annotations.tags.Tag;</line>
          <line/>
          
          <xsl:variable name="identifying-field" select="identifying-attribute/field" as="element(field)?"/>
          <xsl:variable name="id-name" select="($identifying-field/name, 'id')[1]" as="xs:string"/>
          <xsl:variable name="id-type" select="($identifying-field/type, 'String')[1]" as="xs:string"/>
          <xsl:variable name="path" select="entity:feature(., 'OA Path')" as="xs:string?"/>
          
          <xsl:variable name="path-parameter-id" as="element(parameter)">
            <parameter>
              <name>{$id-name}</name>
              <type>{$id-type}</type>
              <parameter-type>path</parameter-type>
              <required>true</required>
              <description>{name} ID</description>
              <example>123</example>
            </parameter>
          </xsl:variable>
          
          <xsl:variable name="api-path-version" select="(entity:feature(/model, 'OA Path version'), '1')[1]" as="xs:string?"/>
          <line>@Path("/v{$api-path-version}/{if ($path) then $path else lower-case(name)}")</line>
          <line>@Tag(name = "{name}", description = "{local:definition-as-string(definition)}")</line> 
          <line>public class {$resource-class-name} {{</line>
          
          <xsl:variable name="openapi-methods" select="entity:feature(., 'OA Methods')" as="xs:string?"/>
          
          <xsl:if test="local:expose-method(., 'getCol', $openapi-methods)">
            <xsl:call-template name="generate-operation">
              <xsl:with-param name="path" select="()" as="xs:string?"/>
              <xsl:with-param name="method" select="'GET'" as="xs:string"/>
              <xsl:with-param name="summary" as="xs:string?">Retourneert de lijst van alle {name} objecten</xsl:with-param>
              <xsl:with-param name="description" as="xs:string?">Retourneert een gepagineerde lijst van alle {name} objecten</xsl:with-param>
              <xsl:with-param name="operation-id" as="xs:string">getAll{name}</xsl:with-param>
              <xsl:with-param name="parameters" select="()" as="element(parameter)*"/>
              <xsl:with-param name="request-body" select="()" as="element(request-body)?"/>
              <xsl:with-param name="response-body" as="element(response-body)?">
                <response-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>true</is-collection>
                </response-body>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          
          <xsl:if test="local:expose-method(., 'post', $openapi-methods)">
            <xsl:call-template name="generate-operation">
              <xsl:with-param name="path" select="()" as="xs:string?"/>
              <xsl:with-param name="method" select="'POST'" as="xs:string"/>
              <xsl:with-param name="summary" as="xs:string?">Maakt een nieuw {name} object</xsl:with-param>
              <xsl:with-param name="description" as="xs:string?">Maakt een nieuw {name} object aan op basis van de aangeleverde gegevens</xsl:with-param>
              <xsl:with-param name="operation-id" as="xs:string">create{name}</xsl:with-param>
              <xsl:with-param name="parameters" select="()" as="element(parameter)*"/>
              <xsl:with-param name="request-body" as="element(request-body)?">
                <request-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>false</is-collection>
                </request-body>
              </xsl:with-param>
              <xsl:with-param name="response-body" as="element(response-body)?">
                <response-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>false</is-collection>
                </response-body>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          
          <xsl:if test="local:expose-method(., 'delete', $openapi-methods)">
            <xsl:call-template name="generate-operation">
              <xsl:with-param name="path" as="xs:string?">/{{{$id-name}}}</xsl:with-param>
              <xsl:with-param name="method" select="'DELETE'" as="xs:string"/>
              <xsl:with-param name="summary" as="xs:string?">Verwijderd een {name} object</xsl:with-param>
              <xsl:with-param name="description" as="xs:string?">Verwijderd een specifiek {name} object permanent uit het systeem</xsl:with-param>
              <xsl:with-param name="operation-id" as="xs:string">delete{name}</xsl:with-param>
              <xsl:with-param name="parameters" as="element(parameter)*">
                <xsl:sequence select="$path-parameter-id"/>
              </xsl:with-param>
              <xsl:with-param name="request-body" select="()" as="element(request-body)?"/>
              <xsl:with-param name="response-body" select="()" as="element(response-body)?"/>
            </xsl:call-template>
          </xsl:if>
          
          <xsl:if test="local:expose-method(., 'getItem', $openapi-methods)">
            <xsl:call-template name="generate-operation">
              <xsl:with-param name="path" as="xs:string?">/{{{$id-name}}}</xsl:with-param>
              <xsl:with-param name="method" select="'GET'" as="xs:string"/>
              <xsl:with-param name="summary" as="xs:string?">Retourneert een {name} object op basis van zijn unieke identificatie</xsl:with-param>
              <xsl:with-param name="description" as="xs:string?">Retourneert een individueel {name} object op basis van zijn unieke identificatie</xsl:with-param>
              <xsl:with-param name="operation-id" as="xs:string">get{name}ById</xsl:with-param>
              <xsl:with-param name="parameters" as="element(parameter)*">
                <xsl:sequence select="$path-parameter-id"/>
              </xsl:with-param>
              <xsl:with-param name="request-body" select="()" as="element(request-body)?"/>
              <xsl:with-param name="response-body" as="element(response-body)?">
                <response-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>false</is-collection>
                </response-body>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          
          <xsl:if test="local:expose-method(., 'put', $openapi-methods)">
            <xsl:call-template name="generate-operation">
              <xsl:with-param name="path" as="xs:string?">/{{{$id-name}}}</xsl:with-param>
              <xsl:with-param name="method" select="'PUT'" as="xs:string"/>
              <xsl:with-param name="summary" as="xs:string?">Maakt nieuw of overschrijft bestaand {name} object</xsl:with-param>
              <xsl:with-param name="description" as="xs:string?">Maakt een nieuw of overschrijft (volledig) een bestaand {name} object</xsl:with-param>
              <xsl:with-param name="operation-id" as="xs:string">update{name}</xsl:with-param>
              <xsl:with-param name="parameters" as="element(parameter)*">
                <xsl:sequence select="$path-parameter-id"/>
              </xsl:with-param>
              <xsl:with-param name="request-body" as="element(request-body)?">
                <request-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>false</is-collection>
                </request-body>
              </xsl:with-param>
              <xsl:with-param name="response-body" as="element(response-body)?">
                <response-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>false</is-collection>
                </response-body>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          
          <xsl:if test="local:expose-method(., 'patch', $openapi-methods)">
            <xsl:call-template name="generate-operation">
              <xsl:with-param name="path" as="xs:string?">/{{{$id-name}}}</xsl:with-param>
              <xsl:with-param name="method" select="'PATCH'" as="xs:string"/>
              <xsl:with-param name="summary" as="xs:string?">Werkt een bestaand {name} object gedeeltelijk bij</xsl:with-param>
              <xsl:with-param name="description" as="xs:string?">Werkt een bestaand {name} object gedeeltelijk bij door alleen de aangeleverde velden te overschrijven</xsl:with-param>
              <xsl:with-param name="operation-id" as="xs:string">patch{name}</xsl:with-param>
              <xsl:with-param name="parameters" as="element(parameter)*">
                <xsl:sequence select="$path-parameter-id"/>
              </xsl:with-param>
              <xsl:with-param name="request-body" as="element(request-body)?">
                <request-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>false</is-collection>
                </request-body>
              </xsl:with-param>
              <xsl:with-param name="response-body" as="element(response-body)?">
                <response-body>
                  <name>{name}</name>
                  <package-name>{package-name}</package-name>
                  <is-collection>false</is-collection>
                </response-body>
              </xsl:with-param>
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
      
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="generate-custom-operations">    
    <xsl:for-each-group select=".//openapi-operation" group-by="lower-case(tag)">      
      <xsl:variable name="tag" select="current-group()[1]/tag" as="xs:string"/>
      <xsl:variable name="tag-description" select="current-group()[1]/tag/@description" as="xs:string?"/>
      <xsl:variable name="class-name" select="funct:uppercase-first(local:to-java-identifier($tag))"/>
      
      <!-- Create separate Java class for every tag: -->
      <xsl:result-document href="{$output-uri}/src/main/java/nl/imvertor/resource/custom/{$class-name}.java" method="text">  
        <xsl:variable name="lines-elements" as="element(line)+"> 
          <line>package nl.imvertor.resource.custom;</line>
          <line/>
 
          <line>import javax.ws.rs.*;</line>
          <line>import javax.ws.rs.core.*;</line>
          <line/>
          <line>import io.swagger.v3.oas.annotations.*;</line>
          <line>import io.swagger.v3.oas.annotations.media.*;</line>
          <line>import io.swagger.v3.oas.annotations.responses.*;</line>
          <line>import io.swagger.v3.oas.annotations.headers.*;</line>
          <line>import io.swagger.v3.oas.annotations.tags.Tag;</line>
          <line/>
                    
          <line>@Path("/")</line>
          <line>@Tag(name = "{$tag}", description = "{$tag-description}")</line>
          <line>public class {$class-name} {{</line>
          
          <xsl:variable name="api-path-version" select="(entity:feature(/model, 'OA Path version'), '1')[1]" as="xs:string?"/>
          
          <!-- Generate all operations for this tag: -->
          <xsl:for-each select="current-group()">
            
            <xsl:call-template name="validate-operation"/>
            
            <xsl:variable name="path" select="'/v' || $api-path-version || replace(path, '^/v\d+', '')" as="xs:string"/>       
            <xsl:call-template name="generate-operation">
              <xsl:with-param name="path" select="$path" as="xs:string?"/>
              <xsl:with-param name="method" select="method" as="xs:string"/>
              <xsl:with-param name="summary" select="summary" as="xs:string?"/>
              <xsl:with-param name="description" select="funct:element-to-commonmark(description)" as="xs:string?"/>
              <xsl:with-param name="operation-id" select="operation-id" as="xs:string"/>
              <xsl:with-param name="parameters" select="parameters/parameter" as="element(parameter)*"/>
              <xsl:with-param name="request-body" select="request-body" as="element(request-body)?"/>
              <xsl:with-param name="response-body" as="element(response-body)?">
                <xsl:if test="not(method = 'DELETE')">
                  <xsl:call-template name="get-response-body">
                    <xsl:with-param name="request-body" select="request-body" as="element(request-body)?"/>
                    <xsl:with-param name="response-body" select="response-body"  as="element(response-body)?"/>
                    <xsl:with-param name="operation-id" select="operation-id" as="xs:string?"/>
                  </xsl:call-template>  
                </xsl:if>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
          
          <line/>
          <line>}}</line>
        </xsl:variable>
        <xsl:variable name="lines" as="xs:string*">
          <xsl:apply-templates select="$lines-elements"/>  
        </xsl:variable>
        <xsl:sequence select="string-join($lines)"/>
      </xsl:result-document>
    </xsl:for-each-group>
    
  </xsl:template>
  
  <xsl:template name="generate-operation">
    <xsl:param name="path" as="xs:string?"/>
    <xsl:param name="method" as="xs:string"/>
    <xsl:param name="summary" as="xs:string?"/>
    <xsl:param name="description" as="xs:string?"/>
    <xsl:param name="operation-id" as="xs:string"/>
    <xsl:param name="parameters" as="element(parameter)*"/>
    <xsl:param name="request-body" as="element(request-body)?"/>
    <xsl:param name="response-body" as="element(response-body)?"/>
    
    <xsl:variable name="is-paged" select="($method = 'GET') and ($response-body/is-collection = 'true')" as="xs:boolean"/>
    
    <xsl:variable name="method-id">
      <xsl:choose>
        <xsl:when test="$is-paged">get collection</xsl:when>
        <xsl:when test="$method = 'GET'">get item</xsl:when>
        <xsl:otherwise>{lower-case($method)}</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="response-codes" select="local:response-codes(/model, $method-id)" as="xs:string+"/>
    <xsl:variable name="success-response-codes" select="$response-codes[starts-with(., '2')]" as="xs:string+"/>
    <xsl:variable name="error-response-codes" select="$response-codes[not(starts-with(., '2'))]" as="xs:string+"/>
    
    <xsl:variable name="request-objecttype-name" select="$request-body/name" as="xs:string?"/>
    <xsl:variable name="response-objecttype-name" select="$response-body/name" as="xs:string?"/>
    
    <xsl:variable name="request-class-name" select="$request-body/name" as="xs:string?"/>
    <xsl:variable name="response-class-name" select="if ($is-paged) then 'Paginated' || $response-body/name || 'List' else $response-body/name" as="xs:string?"/>
    
    <xsl:variable name="fqn-request-class-name" select="if ($request-body/package-name) then local:full-package-name($request-body/package-name) || '.' || $request-class-name else ()" as="xs:string?"/>
    <xsl:variable name="fqn-response-class-name" select="if ($response-body/package-name) then local:full-package-name($response-body/package-name) || '.' || $response-class-name else ()" as="xs:string?"/>
        
    <line/>
    <line indent="2">@{$method}</line>
    <xsl:if test="$path">
      <line indent="2">@Path("{$path}")</line>  
    </xsl:if>
    <xsl:if test="$method = ('POST','PUT','PATCH')">
      <line indent="2">@Consumes(MediaType.APPLICATION_JSON)</line>
    </xsl:if>
    <xsl:if test="$method = ('GET','POST','PUT','PATCH')">
      <line indent="2">@Produces(MediaType.APPLICATION_JSON)</line>
    </xsl:if>
    <line indent="2">@Operation(operationId = "{$operation-id}", summary = {funct:java-string-literal($summary)}, description = {funct:java-string-literal($description)})</line>
    <line indent="2">@ApiResponses(value = {{</line>
    <xsl:variable name="context-node" select="." as="node()"/>
    <xsl:for-each select="$success-response-codes">
      <xsl:choose>
        <xsl:when test=". = '200'">
          <line indent="4">@ApiResponse(responseCode = "200", description = "OK",</line> <!-- TODO: description text -->
          <line indent="6">content = @Content(mediaType = "application/json",</line> 
          <line indent="6">schema = @Schema(implementation = {$fqn-response-class-name}.class)),</line>
          <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
        </xsl:when>
        <xsl:when test=". = '201'">
          <line indent="4">@ApiResponse(responseCode = "201", description = "{$request-objecttype-name} succesvol aangemaakt",</line>
          <line indent="6">content = @Content(mediaType = "application/json",</line> 
          <line indent="6">schema = @Schema(implementation = {$fqn-response-class-name}.class)),</line>
          <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version"),</line>
          <line indent="8">@Header(name = "Location", description = "URI van het opgeslagen object", schema = @Schema(type = "string", format = "uri"))}}),</line>
        </xsl:when>
        <xsl:when test=". = '202'">
          <line indent="4">@ApiResponse(responseCode = "202", description = "Object zal worden verwijderd",</line>
          <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
        </xsl:when>
        <xsl:when test=". = '204'">
          <line indent="4">@ApiResponse(responseCode = "204", description = "Object succesvol verwijderd",</line>
          <line indent="6">headers = {{@Header(name = "api-version", ref = "{$common-base-url}#/components/headers/API-Version")}}),</line>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    
    <xsl:for-each select="$error-response-codes">
      <line indent="4">@ApiResponse(responseCode = "{.}", ref="{$response-component-base-url}{.}"){if (not(position() = last())) then ',' else ()}</line>
    </xsl:for-each>
    
    <line indent="2">}})</line>
    
    <xsl:variable name="has-params" select="$is-paged or exists($parameters) or $request-body" as="xs:boolean"/>
    
    <line indent="2">public Response {funct:lowercase-first(local:to-java-identifier($operation-id))}{if ($has-params) then '(' else '() {'}</line>
    <xsl:if test="$is-paged">
      <line indent="4">@Parameter(ref = "{$common-base-url}#/components/parameters/page") int page,</line>
      <line indent="4">@Parameter(ref = "{$common-base-url}#/components/parameters/pageSize") int pageSize,</line>
      <line indent="4">@Parameter(ref = "{$common-base-url}#/components/parameters/sortField") String sortField{if ($parameters) then ',' else ') {'}</line>  
    </xsl:if>
    <xsl:for-each select="$parameters">
      <xsl:variable name="required" select="if (parameter-type = 'path') then 'true' else required" as="xs:string"/>
      <line indent="4">@{funct:uppercase-first(parameter-type)}Param("{name}") @Parameter(description = {funct:java-string-literal(funct:element-to-commonmark(description))}, required = {$required}, example = {funct:java-string-literal(example)}) {type}{if (ends-with(cardinality, '*')) then '[]' else ()} {entity:field-name(name)}{if (not(position() = last()) or $request-body) then ',' else ') {'}</line> <!-- TODO: cardinaliteit -->
    </xsl:for-each>
    <xsl:if test="$request-body">
      <line indent="4">@Parameter(description = "De gegevens van het {$request-body/name} object", required = true) {$fqn-request-class-name} {lower-case($request-body/name)}) {{</line>
    </xsl:if>
    
    <line indent="4">return Response.ok().build();</line>
    <line indent="2">}}</line>
  </xsl:template>
    
  <xsl:template name="generate-openapi-header">
    <xsl:result-document href="{$output-uri}/src/main/java/nl/imvertor/resource/OpenApiDefinition.java" method="text">  
      <xsl:variable name="lines-elements" as="element(line)+"> 
        <xsl:variable name="title" select="entity:feature(/model, 'openapi.title')" as="xs:string?"/>
        <xsl:variable name="description" select="entity:feature(/model, 'openapi.description')" as="xs:string?"/>
        
        <line>package nl.imvertor.resource;</line>
        <line/>
        <line>import io.swagger.v3.oas.annotations.OpenAPIDefinition;</line>
        <line>import io.swagger.v3.oas.annotations.info.*;</line>
        <line>import io.swagger.v3.oas.annotations.servers.*;</line>
        <line>import io.swagger.v3.oas.annotations.tags.*;</line>
        <line/>
        <line>@OpenAPIDefinition(</line>
        <line indent="2">info = @Info(</line>
        <line indent="4">title = {funct:java-string-literal((entity:feature(/model,'OA Title')[1], /model/title)[1])},</line>
        <line indent="4">description = {funct:java-string-literal((funct:feature-to-commonmark(/model,'OA Description')[1], funct:element-to-commonmark(/model/definition))[1])},</line>
        <line indent="4">version = "{(entity:feature(/model,'OA Version'), '1.0.0')[1]}",</line>
        <line indent="4">contact = @Contact(</line>
        <line indent="6">{string-join((
          local:annotation-field('name', entity:feature(/model,'OA Contact name')),
          local:annotation-field('url', entity:feature(/model,'OA Contact url')),
          local:annotation-field('email', entity:feature(/model,'OA Contact email'))), ', ')}</line>
        <line indent="4">),</line>
        <line indent="4">license = @License(</line>
        <line indent="6">{string-join((
          local:annotation-field('name', entity:feature(/model,'OA License name')),
          local:annotation-field('url', entity:feature(/model,'OA License url'))), ', ')}</line>
        <line indent="4">)</line>
        <line indent="2">),</line>
        <line indent="2">servers = {{</line>
        <xsl:for-each select="entity:feature(/model,'OA Server url')">
          <line indent="4">@Server(url = {funct:java-string-literal(.)}){if (not(position() = last())) then ',' else ()}</line>  
        </xsl:for-each>
        <line indent="2">}}</line>
        <line>)</line>
        <line>public class OpenApiDefinition {{</line>
        <line/>
        <line indent="2">public enum OpenAPISpecVersion {{ API30, API31 }};</line>
        <line/>
        <line indent="2">public static OpenAPISpecVersion getOpenAPISpecVersion() {{</line>
        <line indent="4">return OpenAPISpecVersion.{if ($openapi-spec-version = 'api31') then 'API31' else 'API30'};</line>
        <line indent="2">}}</line>
        <line/>
        <line indent="2">public static boolean getSchemasOnly() {{</line>
        <line indent="4">return {$openapi-schemas-only};</line>
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
  
  <xsl:template name="validate-operation">          
    <xsl:variable name="operation-id" select="normalize-space(operation-id)" as="xs:string"/>
    <xsl:variable name="method" select="normalize-space(method)" as="xs:string"/>
    <xsl:variable name="path" select="normalize-space(path)" as="xs:string"/>
    
    <xsl:if test="not($operation-id)">
      <xsl:sequence select="imf:message(., 'ERROR', 'An OpenAPI Operation is missing the required Operation ID (name)', (), 'OPENAPI001')"/>
    </xsl:if>
    <xsl:if test="count(//openapi-operation[operation-id = $operation-id]) gt 1">
      <xsl:sequence select="imf:message(., 'ERROR', 'OpenAPI Operation ID (name) [1] is not unique', $operation-id, 'OPENAPI002')"/>
    </xsl:if>
    <xsl:if test="not($method)">
      <xsl:sequence select="imf:message(., 'ERROR', 'OpenAPI Operation [1] is missing the required &quot;OA HTTP method&quot;', $operation-id, 'OPENAPI003')"/>
    </xsl:if>
    <xsl:if test="path = '/nopath'">
      <xsl:sequence select="imf:message(., 'ERROR', 'OpenAPI Operation [1] is missing the required &quot;OA Path&quot;', $operation-id, 'OPENAPI004')"/>
    </xsl:if>
    <xsl:if test="tag = 'NoTag'">
      <xsl:sequence select="imf:message(., 'WARNING', 'OpenAPI Operation [1] is missing the &quot;OA Tag&quot;, now using &quot;NoTag&quot;', $operation-id, 'OPENAPI005')"/>
    </xsl:if>
    <xsl:if test="count(//openapi-operation[method = $method and path = $path]) gt 1">
      <xsl:sequence select="imf:message(., 'ERROR', 'The combination of &quot;OA HTTP Method&quot; [1] and &quot;OA Path&quot; [2] is not unique', ($method, $path), 'OPENAPI006')"/>
    </xsl:if>
    
    <xsl:variable name="regex" expand-text="no">\{(.*?)\}</xsl:variable>
    <xsl:variable name="param-names-in-path" select="analyze-string(path, $regex)//fn:group" as="xs:string*"/>
    <xsl:variable name="path-params" select="parameters/parameter[parameter-type = 'path']/name" as="xs:string*"/>
    
    <!-- TODO: Validation below only applies to OpenAPI 3.0.1, in 3.1.0 inference is allowed: -->
    <xsl:variable name="context" select="." as="node()"/>
    <xsl:variable name="parameters-in-path-but-not-declared" select="functx:value-except($param-names-in-path, $path-params)" as="xs:string*"/>
    <xsl:variable name="declared-path-parameters-not-in-path" select="functx:value-except($path-params, $param-names-in-path)" as="xs:string*"/>
    <xsl:for-each select="$parameters-in-path-but-not-declared">
      <xsl:sequence select="imf:message($context, 'ERROR', 
        '&quot;OA Path&quot; of OpenAPI Operation [1] contains parameter(s) [2] that are not declared as an OpenAPI Parameter with &quot;OA Parameter type&quot; &quot;path&quot;', 
        ($operation-id, string-join($parameters-in-path-but-not-declared, ',')), 'OPENAPI007')"/> 
    </xsl:for-each>
    <xsl:for-each select="$declared-path-parameters-not-in-path">
      <xsl:sequence select="imf:message($context, 'ERROR', 
        'OpenAPI Operation [1] contains OpenAPI &quot;path&quot; parameter(s) [2] that are not used in &quot;OA Path&quot;', 
        ($operation-id, string-join($declared-path-parameters-not-in-path, ',')), 'OPENAPI008')"/> 
    </xsl:for-each>
    
    <xsl:for-each select="parameters/parameter">
      <xsl:if test="not(normalize-space(name))">
        <xsl:sequence select="imf:message(., 'ERROR', 'The &quot;name&quot; of a parameter of OpenAPI Operation [1] is not specified', $operation-id, 'OPENAPI009')"/>  
      </xsl:if>
      <xsl:if test="not(normalize-space(parameter-type))">
        <xsl:sequence select="imf:message(., 'ERROR', 'The &quot;type&quot; of parameter [1] of OpenAPI Operation [2] is not specified', (name, $operation-id), 'OPENAPI010')"/>  
      </xsl:if>
      <xsl:if test="parameter-type = 'path' and required = 'false'">
        <xsl:sequence select="imf:message(., 'WARNING', 'The parameter [1] of OpenAPI Operation [2] with type &quot;path&quot; must have &quot;OA Required = yes&quot; according to spec, see https://spec.openapis.org/oas/v3.0.1.html#parameterRequired', 
          (name, $operation-id), 'OPENAPI011')"/>  
      </xsl:if>
    </xsl:for-each>
    
    <xsl:choose>
      <xsl:when test="method = 'GET' and not(response-body)">
        <xsl:sequence select="imf:message(., 'ERROR', 'GET OpenAPI Operation [1] is missing the Response Body relation', $operation-id, 'OPENAPI012')"/>
      </xsl:when>
      <xsl:when test="method = 'POST' and not(request-body)">
        <xsl:sequence select="imf:message(., 'ERROR', 'POST OpenAPI Operation [1] is missing the Request Body relation', $operation-id, 'OPENAPI013')"/>
      </xsl:when>
      <xsl:when test="method = 'DELETE' and (response-body or request-body)">
        <xsl:sequence select="imf:message(., 'ERROR', 'DELETE OpenAPI Operation [1] cannot have a Request Body relation or Response Body Relation', $operation-id, 'OPENAPI014')"/>
      </xsl:when>
      <xsl:when test="method = 'PUT' and not(request-body)">
        <xsl:sequence select="imf:message(., 'ERROR', 'PUT OpenAPI Operation [1] is missing the Request Body relation', $operation-id, 'OPENAPI016')"/>
      </xsl:when>
      <xsl:when test="method = 'PATCH' and not(request-body)">
        <xsl:sequence select="imf:message(., 'ERROR', 'PATCH OpenAPI Operation [1] is missing the Request Body relation', $operation-id, 'OPENAPI017')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get-response-body" as="element(response-body)?">
    <xsl:param name="request-body" as="element(request-body)?"/>
    <xsl:param name="response-body" as="element(response-body)?"/>
    <xsl:param name="operation-id" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$response-body">
        <xsl:sequence select="$response-body"/>
      </xsl:when>
      <xsl:otherwise>
        <response-body>
          <xsl:sequence select="$request-body/*"/>
        </response-body>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:param name="context-node" as="node()"/>
    <xsl:param name="method" as="xs:string"/>
    <xsl:param name="openapi-methods" as="xs:string?"/>
    <xsl:variable name="global-openapi-methods" select="entity:feature($context-node/root()/model, 'OA Methods')" as="xs:string?"/> 
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
    
  <xsl:function name="local:annotation-field" as="xs:string?">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="value" as="xs:string?"/>
    <xsl:sequence select="if (normalize-space($value)) then $name || ' = ' || funct:java-string-literal($value) else ()"/>
  </xsl:function>
  
  <xsl:function name="local:to-java-identifier">
    <xsl:param name="str" as="xs:string"/>
    <xsl:variable name="normalized" select="normalize-space($str)" as="xs:string"/>
    <xsl:variable name="flattened" select="funct:flatten-diacritics($normalized)" as="xs:string"/>
    <xsl:variable name="no-specials" select="replace($flattened, '[^a-zA-Z_0-9]', ' ')" as="xs:string"/>
    <xsl:variable name="no-leading-digits" select="replace($no-specials, '^(\d)', '_$1')" as="xs:string"/>
    <xsl:sequence select="functx:words-to-camel-case($no-leading-digits)"/>
  </xsl:function>
  
  <xsl:function name="local:response-codes" as="xs:string+">
    <xsl:param name="model-element" as="element(model)"/>
    <xsl:param name="method-id" as="xs:string+"/>
    <xsl:variable name="configured-response-codes" select="entity:feature($model-element, 'OA Response Codes ' || $method-id)" as="xs:string?"/>
    <xsl:variable name="default-response-codes" select="map:get($method-id-response-codes-map, $method-id)" as="xs:string+"/>
    <xsl:choose>
      <xsl:when test="$configured-response-codes">
        <xsl:sequence select="tokenize($configured-response-codes, '[,; ]+')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default-response-codes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>