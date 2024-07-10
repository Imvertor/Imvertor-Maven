<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
   
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
   
    <xsl:variable name="stylesheet-code">JSONSCHEMA</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/> 
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="geoJSONfiles" select="imf:collect-geoJSONs()"/>
    <xsl:variable name="references-geoJSON-collection" select="//*[ep:tech-name = ('geometryGeoJSON','geometrycollectionGeoJSON')]"/>
    <xsl:variable name="geoJSONnames" select="(
        'geometryGeoJSON',
        'geometrycollectionGeoJSON',
        'linestringGeoJSON',
        'multilinestringGeoJSON',
        'multipointGeoJSON',
        'multipolygonGeoJSON',
        'pointGeoJSON',
        'polygonGeoJSON')"/>
    
    <xsl:template match="/ep:construct">
        <j:map>
            <xsl:sequence select="imf:ep-to-namevaluepair('openapi','3.0.0')"/>
            <j:map key="info">
                <xsl:sequence select="imf:ep-to-namevaluepair('title',ep:name)"/>
                <xsl:sequence select="imf:ep-to-namevaluepair('description',ep:name || ' components/schema')"/>
                <xsl:sequence select="imf:ep-to-namevaluepair('version',imf:get-ep-parameter(.,'version'))"/>
            </j:map>
            <j:map key="paths">
                <j:map key="/">
                    <j:map key="get">
                        <xsl:sequence select="imf:ep-to-namevaluepair('description','a path')"/>
                        <j:map key="responses">
                            <j:map key="200">
                                <xsl:sequence select="imf:ep-to-namevaluepair('description','okay')"/>
                                <j:map key="content">
                                    <j:map key="text/plain">
                                        <j:map key="schema">
                                            <xsl:sequence select="imf:ep-to-namevaluepair('type','string')"/>
                                            <xsl:sequence select="imf:ep-to-namevaluepair('example','pong')"/>
                                        </j:map>
                                    </j:map>
                                </j:map>
                            </j:map>
                        </j:map>
                    </j:map>
                </j:map>
            </j:map>
            <j:map key="components">
                <j:map key="schemas">
                    <xsl:variable name="constructs" as="element(j:map)*">
                        <xsl:apply-templates select="ep:seq/ep:construct/ep:seq/ep:construct[not(imf:boolean(ep:external))]"/>
                    </xsl:variable>
                    <!-- ontdubbel -->
                    <xsl:for-each-group select="$constructs" group-by="@key"><!-- van iedere construct de eerste; het XSL proces genereert veel dubbelen (bij choices). -->
                        <xsl:sequence select="current-group()[1]"/>
                    </xsl:for-each-group>
                    <xsl:if test="$references-geoJSON-collection">
                        <xsl:sequence select="$geoJSONfiles[@construct = 'geometryGeoJSON']/j:map/*"/>
                        <xsl:sequence select="$geoJSONfiles[@construct = 'geometrycollectionGeoJSON']/j:map/*"/>
                    </xsl:if>
                    <xsl:variable name="maps" as="element(j:map)*">
                        <xsl:for-each-group select="ep:seq/ep:construct/ep:seq/ep:construct[imf:boolean(ep:external)]" group-by="ep:tech-name"><!-- van iedere geoJson external de eerste -->
                            <xsl:apply-templates select="current-group()[1]" mode="external"/>
                        </xsl:for-each-group>
                    </xsl:variable>
                    <!-- Verwijder duplicate keys. Kan gebeuren als twee externals mappen naar hetzelfde oas object -->
                    <xsl:for-each-group select="$maps" group-adjacent="@key">
                        <xsl:sequence select="current-group()[1]"/>
                    </xsl:for-each-group>
                </j:map>
            </j:map>     
        </j:map>
    </xsl:template>
    
    <xsl:template match="ep:construct">
        <xsl:variable name="n" select="'EP: ' || ep:tech-name || ' ID: ' || ep:id"/>
        <xsl:variable name="nillable" select="imf:get-ep-parameter(.,'nillable') = 'true'"/>
        <j:map key="{ep:tech-name}">
            <xsl:choose>
                <xsl:when test="false() and imf:get-ep-parameter(.,'use') eq 'data-element'"><!-- TODO waarom had ik deze een apart verwerking gegeven? -->
                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Data element [1]',$n)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type), $nillable)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('format',imf:map-dataformat-to-ep-type(ep:data-type))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:ep-to-namevaluepair('title',ep:name)"/>
                    <xsl:variable name="added-location" select="if (imf:get-ep-parameter(.,'data-location')) then ('; Locatie: ' || imf:get-ep-parameter(.,'data-location')) else ()"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('description',imf:create-description(.) || $added-location)"/>
                    <xsl:choose>
                        <xsl:when test="ep:ref and (ep:min-occurs or ep:max-occurs)">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Ref with occurs [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <j:map key="items">
                                <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('$ref','#/components/schemas/' || imf:get-type-name($target))"/>
                            </j:map>
                            <xsl:sequence select="imf:create-minmax(ep:min-occurs,ep:max-occurs)"/>
                        </xsl:when>
                        <xsl:when test="ep:ref">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Ref [1]',$n)"/>
                            <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('$ref','#/components/schemas/' || imf:get-type-name($target))"/>
                        </xsl:when>
                        <xsl:when test="ep:seq and (ep:min-occurs or ep:max-occurs)">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq with occurs [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <j:map key="items">
                                <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('$ref','#/components/schemas/' || imf:get-type-name($target))"/>
                            </j:map>
                            <xsl:sequence select="imf:create-minmax(ep:min-occurs,ep:max-occurs)"/>
                        </xsl:when>
                        <xsl:when test="ep:seq">
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','object')"/>
                            <xsl:variable name="body">
                                <xsl:variable name="required" select="ep:seq/ep:construct[not(ep:min-occurs eq '0')]"/>
                                <xsl:if test="exists($required)">
                                    <j:array key="required">
                                        <xsl:for-each select="$required">
                                            <j:string>
                                                <xsl:value-of select="ep:tech-name"/>
                                            </j:string>
                                        </xsl:for-each>
                                    </j:array>
                                </xsl:if>
                                <j:map key="properties">
                                    <xsl:apply-templates select="ep:seq/ep:construct"/>
                                </j:map>
                            </xsl:variable>
                            <xsl:variable name="super" select="imf:get-ep-parameter(.,'super')"/>
                            <xsl:choose>
                                <xsl:when test="exists($super)">
                                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq with super [1]',imf:string-group($n))"/>
                                    <j:array key="allOf">
                                        <j:map>
                                            <xsl:variable name="target" select="(//ep:construct[ep:id = $super])[1]"/>
                                            <xsl:sequence select="imf:ep-to-namevaluepair('$ref','#/components/schemas/' || imf:get-type-name($target))"/>
                                            <?x TODO lennart Hoe omgaan met meerdere supertypen
                                            <j:array key="$ref">
                                                <xsl:for-each select="$target">
                                                    <j:string>
                                                        <xsl:value-of select="'#/components/schemas/' || ep:tech-name"/>
                                                    </j:string>
                                                </xsl:for-each>
                                            </j:array>
                                            x?>
                                        </j:map>
                                        <j:map>
                                            <xsl:sequence select="$body"/>
                                        </j:map>
                                    </j:array>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq [1]',$n)"/>
                                    <xsl:sequence select="$body"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ep:choice">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Choice [1]',$n)"/>
                            <j:array key="oneOf">
                                <xsl:for-each select="ep:choice/ep:construct">
                                    <xsl:variable name="ref" select="ep:ref"/>
                                    <xsl:choose>
                                        <xsl:when test="imf:get-ep-parameter(.,'use') = 'keuze-element-datatype'">
                                            <j:map>
                                                <xsl:sequence select="imf:ep-to-namevaluepair('$ref','#/components/schemas/' || imf:get-type-name(.))"/>
                                            </j:map>
                                        </xsl:when>
                                        <xsl:when test="$ref">
                                            <j:map>
                                                <xsl:variable name="target" select="//ep:construct[ep:id = $ref]"/>
                                                <xsl:sequence select="imf:ep-to-namevaluepair('$ref','#/components/schemas/' || imf:get-type-name($target))"/>
                                            </j:map>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <j:map>
                                                <xsl:apply-templates select="."/>
                                            </j:map>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </j:array>
                        </xsl:when>
                        <xsl:when test="ep:enum">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Enum [1]',$n)"/>
                            <j:array key="enum">
                                <xsl:for-each select="ep:enum">
                                    <j:string>
                                        <xsl:value-of select="ep:name"/>
                                    </j:string>
                                </xsl:for-each>
                            </j:array>
                        </xsl:when>
                        <xsl:when test="ep:data-type and imf:get-ep-parameter(.,'use') eq 'codelist'">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Codelist [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','object')"/>
                            <j:map key="properties">
                                <j:map key="code">
                                    <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type),$nillable)"/>
                                </j:map>
                            </j:map>
                        </xsl:when>
                        
                        <xsl:when test="ep:data-type">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Datatype [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type),$nillable)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('format',imf:map-dataformat-to-ep-type(ep:data-type))"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minValue',ep:min-value-inclusive)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxValue',ep:max-value-inclusive)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minLength',ep:min-length)"/>
                            <!-- <xsl:sequence select="imf:ep-to-namevaluepair('maxLength',ep:max-length)"/> TODO lennart -->
                            <xsl:sequence select="imf:ep-to-namevaluepair('pattern',ep:formal-pattern)"/>
                            <xsl:sequence select="imf:create-minmax(ep:min-occurs,ep:max-occurs)"/>
                        </xsl:when>
                        
                        <xsl:when test="ep:external">
                            <!-- deze constructs worden aan het einde toegevoegd, wanneer ernaar verwezen wordt --> 
                            <xsl:sequence select="imf:ep-to-namevaluepair('$ref','#/components/schemas/' || imf:get-type-name(.))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg-comment(.,'WARN', 'Ken dit type niet: [1]',$n)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </j:map>
        <xsl:if test="ep:choice/ep:construct[imf:get-ep-parameter(.,'use') = 'keuze-element-datatype']">
            <!-- verzamel alle datatype keuze elementen --> 
            <xsl:apply-templates select="ep:choice/ep:construct"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ep:construct" mode="external">
        <xsl:variable name="tech-name" select="ep:tech-name"/>
        <xsl:variable name="oas-name" select="imf:get-ep-parameter(.,'oas-name')"/>
        <xsl:variable name="first" select="empty(preceding-sibling::ep:construct[imf:get-ep-parameter(.,'oas-name') eq $oas-name])"/><!-- Meerdere externe constructs kunnen naar dezelfde geojson verwijzen. Één ref is voldoende. --> 
        <xsl:choose>
            <xsl:when test="not($references-geoJSON-collection) and $oas-name = $geoJSONnames and $first">
                <j:map key="{$oas-name}">
                    <xsl:sequence select="$geoJSONfiles[@construct = $oas-name]/j:map/*"/>
                </j:map>
            </xsl:when>
            <xsl:when test="not($references-geoJSON-collection) and $oas-name = $geoJSONnames">
                <!-- already processed -->
            </xsl:when>
            <xsl:when test="$oas-name = $geoJSONnames">
                <!-- de naam is een geoJSON naam maar er is al een collectie gegenereerd -->
            </xsl:when>
            <xsl:otherwise>
                <j:map key="{$tech-name}">
                    <xsl:sequence select="imf:msg-comment(.,'WARNING', '(fatal) Cannot resolve EP construct [1] to a type in [2]',($tech-name,'GeoJSON'))"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('error','undefined')"/>
                </j:map>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--
        functions 
    -->
    
    <xsl:function name="imf:ep-to-namevaluepair" as="node()*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="xs:string?"/>
        <xsl:param name="nillable"/>
        <xsl:if test="normalize-space($value)">
            <xsl:choose>
                <xsl:when test="$nillable">
                    <j:array key="type">
                        <j:string>
                            <xsl:value-of select="$value"/>
                        </j:string>
                        <j:null/>
                    </j:array>
                </xsl:when>
                <xsl:otherwise>
                    <j:string key="{$name}">
                        <xsl:value-of select="$value"/>
                    </j:string>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:ep-to-namevaluepair" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="xs:string?"/>
        <xsl:sequence select="imf:ep-to-namevaluepair($name,$value,false())"/>       
    </xsl:function>
    
    <xsl:function name="imf:msg-comment" as="element()?">
        <xsl:param name="this" as="node()*"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
        <xsl:if test="imf:debug-mode()">
            <xsl:variable name="ctext" select="imf:msg-insert-parms($text,$info)"/>
            <xsl:sequence select="imf:msg($this,$type,$text,$info)"/>
            <xsl:sequence select="imf:ep-to-namevaluepair('_comment',$ctext)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-ep-parameter" as="xs:string*">
        <xsl:param name="this"/>
        <xsl:param name="parameter-name"/>
        <xsl:sequence select="$this/ep:parameters/ep:parameter[ep:name = $parameter-name]/ep:value"/>
    </xsl:function>
    
    <xsl:function name="imf:map-datatype-to-ep-type" as="xs:string">
        <xsl:param name="data-type"/> 
        <xsl:choose>
            <xsl:when test="$data-type = 'ep:string'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:date'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:datetime'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:day'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:year'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:yearmonth'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:month'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:uri'">string</xsl:when>
            <xsl:when test="$data-type = 'ep:real'">number</xsl:when>
            <xsl:when test="$data-type = 'ep:decimal'">number</xsl:when>
            <xsl:when test="$data-type = 'ep:integer'">integer</xsl:when>
            <xsl:when test="$data-type = 'ep:boolean'">boolean</xsl:when>
            <xsl:when test="$data-type = 'ep:time'">string</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'UNKNOWN-DATATYPE: ' || $data-type"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:map-dataformat-to-ep-type" as="xs:string?">
        <xsl:param name="data-type"/> 
        <xsl:choose>
            <xsl:when test="$data-type = 'ep:date'">date-time</xsl:when>
            <xsl:when test="$data-type = 'ep:datetime'">date-time</xsl:when>
            <xsl:when test="$data-type = 'ep:time'">time</xsl:when>
            <xsl:when test="$data-type = 'ep:year'">year</xsl:when>
            <xsl:when test="$data-type = 'ep:uri'">uri</xsl:when>
            <xsl:otherwise>
                <!--  no format -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:collect-geoJSONs" as="element(geoJSONfile)*">
        <xsl:variable name="path" select="imf:get-xparm('system/folder-path') || '/input/OGC/openapi/schemas'"/>
        <xsl:variable name="tempfile" select="imf:get-xparm('properties/WORK_GEOJSONXML_XMLPATH')"/>
        <xsl:variable name="files" select="if (ext:imvertorFolderSerializer($path,$tempfile,'')) then imf:document($tempfile) else ()"/>
        <xsl:variable name="geoJSONfiles" as="element(geoJSONfile)*">
            <xsl:for-each select="$files/cw:files/cw:file[@ext = 'yaml']">
                <xsl:variable name="fullpath" select="$path || '/' || replace(@path,'\\','/')"/>
                <!-- transform to Saxon JsonXML -->
                <geoJSONfile construct="{substring-before(@path,'.')}">
                    <xsl:sequence select="parse-xml(ext:imvertorParseYaml(string($fullpath)))"/>
                </geoJSONfile>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$geoJSONfiles"/>
    </xsl:function>

    <xsl:function name="imf:create-description" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="text" as="xs:string*">
            <xsl:for-each select="$this/ep:documentation/ep:definition/*:body/*">
                <xsl:value-of select="."/>           
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string-join($text,'; '))"/>
    </xsl:function>
    
    <xsl:function name="imf:create-minmax" as="element()*">
        <xsl:param name="min" as="xs:string?"/>
        <xsl:param name="max" as="xs:string?"/>
        <xsl:sequence select="imf:ep-to-namevaluepair('minItems',($min,'1')[1])"/>
        <xsl:sequence select="if ($max and $max ne 'unbounded') then imf:ep-to-namevaluepair('maxItems',$max) else ()"/>
    </xsl:function>
    
    <xsl:function name="imf:get-type-name" as="xs:string">
        <xsl:param name="this" as="element(ep:construct)?"/><!-- teken van een fout als de construct niet wordt meegegeven -->
        <xsl:choose>
            <xsl:when test="empty($this)">
                <xsl:sequence select="imf:msg($this,'WARNING','(Fatal) Invalid reference',())"/>
                <xsl:value-of select="'INVALID-REFERENCE'"/>
            </xsl:when>
            <xsl:when test="$this/ep:external">
                <xsl:value-of select="(imf:get-ep-parameter($this,'oas-name'),'UNKNOWN-OAS-TYPE')[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$this/ep:tech-name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>