<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct/v2"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
   
    <xsl:variable name="stylesheet-code">JSONSCHEMA</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/> 
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <!-- aanpassingen tussen /v1 en /v2:
        
        - omgaan met aanpassingen in mim serialisatie v2 (MIM 1.1.0) 
        - ep:group ipv. ep:construct
        - Json name (tech-name) wordt hier dynamisch samengesteld tbv. json op basis van ep:name.
        - verwerking van json GML is nu anders, conform OGC BP.
    -->
    
    <xsl:variable name="bp-req-applies" select="imf:boolean(imf:get-ep-parameter(/ep:group,'bp-req-applies'))" as="xs:boolean"/>
    
    <xsl:variable name="schema-id">{imf:get-ep-parameter(/ep:group,'namespace')}/{imf:get-ep-parameter(/ep:group,'version')}/{imf:get-ep-parameter(/ep:group,'release')}</xsl:variable>
    
    <xsl:variable name="document" select="/"/>
    <xsl:variable name="domains" select="/ep:group/ep:seq/ep:group"/>
    <xsl:variable name="top-constructs" select="$domains/ep:seq/ep:construct"/>
    
    <xsl:template match="/ep:group">
        <xsl:variable name="defs">
            <xsl:variable name="constructs" as="element(j:map)*">
                <xsl:apply-templates select="ep:seq/ep:group/ep:seq/ep:construct[not(imf:boolean(ep:external))]"/>
            </xsl:variable>
            <!-- ontdubbel -->
            <xsl:for-each-group select="$constructs" group-by="@key"><!-- van iedere construct de eerste; het XSL proces genereert veel dubbelen (bij choices). -->
                <xsl:sequence select="current-group()[1]"/>
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:variable name="schema-desc">{ep:name} - version {imf:get-ep-parameter(.,'version')} / {imf:get-ep-parameter(.,'release')} by Imvertor {imf:get-ep-parameter(.,'imvertor-version')} variant {imf:get-ep-parameter(.,'json-schema-variant')}{if ($debugging) then  ' DEBUG' else ''}</xsl:variable>
        <xsl:choose>
            <xsl:when test="$bp-req-applies">
                <j:map>
                    <xsl:sequence select="imf:ep-to-namevaluepair('$comment',$schema-desc)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('$schema','https://json-schema.org/draft/2019-09/schema')"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('$id',$schema-id)"/>
                    <j:array key="$reqs">
                        <j:string>{imf:get-ep-parameter(.,'bp-req-basic-encodings')}</j:string>
                        <j:string>{imf:get-ep-parameter(.,'bp-req-by-reference-encodings')}</j:string>
                        <j:string>{imf:get-ep-parameter(.,'bp-req-code-list-encodings')}</j:string>
                        <j:string>{imf:get-ep-parameter(.,'bp-req-additional-requirements-classes')}</j:string>
                    </j:array>
                    <j:map key="$defs">
                        <xsl:sequence select="$defs"/>
                    </j:map>
                </j:map>
            </xsl:when>
            <xsl:otherwise>
                <j:map>
                    <xsl:sequence select="imf:ep-to-namevaluepair('openapi','3.0.0')"/>
                    <j:map key="info">
                        <xsl:sequence select="imf:ep-to-namevaluepair('title',ep:name)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('description',$schema-desc)"/>
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
                            <xsl:sequence select="$defs"/>
                        </j:map>
                    </j:map>     
                </j:map>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct">
        <xsl:param name="as-property" select="false()" as="xs:boolean"/>
        
        <xsl:variable name="construct" select="."/>
        
        <xsl:variable name="use" select="imf:get-ep-parameter(.,'use')"/>
        <xsl:variable name="url" select="imf:get-ep-parameter(.,'url')"/>
        <xsl:variable name="tech-name" select="imf:ep-tech-name(ep:name)"/>
        <xsl:variable name="top-construct" select="$top-constructs[. is $construct]"/>
        
        <xsl:sequence select="dlogger:save('ep:construct',$construct)"></xsl:sequence>
        
        <xsl:if test="empty($url)"> <!-- externe constructs met URL worden niet opgenomen; wanneer ernaar wordt verwezen wordt de URL aldaar ingevoegd -->
            <xsl:variable name="n" select="'EP=' || $tech-name || ', ID=' || @id"/>
            <xsl:variable name="nillable" select="imf:get-ep-parameter(.,'nillable') = 'true'"/>
            <xsl:variable name="header">
                <xsl:if test="not(imf:get-ep-parameter(.,'is-pga') = 'true') and not(imf:get-ep-parameter(.,'is-ppa') = 'true')">
                    <xsl:sequence select="if ($top-construct) then imf:ep-to-namevaluepair('$anchor',imf:get-type-name(.)) else ()"/>
                    <xsl:sequence select="if (ep:name ne $tech-name) then imf:ep-to-namevaluepair('title',ep:name) else ()"/>
                    <xsl:variable name="added-location" select="if (imf:get-ep-parameter(.,'locatie')) then ('; Locatie: ' || imf:get-ep-parameter(.,'locatie')) else ()"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('description',imf:create-description(.) || $added-location)"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="read-only" select="if (ep:read-only = 'true' or imf:get-ep-parameter(.,'is-value-derived')) then true() else ()"/>
            <xsl:variable name="initial-value" select="ep:initial-value"/>
            <xsl:variable name="unit" select="imf:get-ep-parameter(.,'unit')"/>
            
            <j:map key="{$tech-name}">
                <xsl:choose>
                    <!-- de construct verwijst naar meerdere typen -->
                    <xsl:when test="$construct/ep:ref">
                        <xsl:variable name="properties">
                            <xsl:choose>
                                <xsl:when test="$construct/ep:ref/@method = 'by-reference'">
                                    <xsl:sequence select="imf:ep-to-namevaluepair('type','string')"/>
                                    <xsl:sequence select="imf:ep-to-namevaluepair('format','uri-reference')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:ep-to-namevaluepair('$ref',imf:get-type-ref-by-id(ep:ref/@href))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Ref',$n)"/>
                        <xsl:sequence select="$header"/>
                        <xsl:choose>
                            <xsl:when test="ep:max-occurs and ep:max-occurs ne '1'">
                                <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                                <j:map key="items">
                                    <xsl:sequence select="$properties"/>
                                </j:map>
                                <xsl:sequence select="imf:create-minmax(ep:min-occurs,ep:max-occurs)"/>
                                <xsl:if test="$as-property">
                                    <xsl:sequence select="imf:ep-to-namevaluepair('uniqueItems',true())"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$properties"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:sequence select="imf:ep-to-namevaluepair('readOnly',$read-only)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('default',$initial-value)"/>
                    </xsl:when>
                    <!-- de construct bestaat uit meerdere sequences -->
                    <xsl:when test="ep:seq and (ep:max-occurs and ep:max-occurs ne '1')">
                        <xsl:sequence select="dlogger:save('max',.)"></xsl:sequence>
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq with maxoccurs [1]',$n)"/>
                        <xsl:sequence select="$header"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                        <j:map key="items">
                            <xsl:choose>
                                <xsl:when test="ep:seq/ep:construct/ep:ref/@href">
                                    <xsl:sequence select="imf:ep-to-namevaluepair('$ref',imf:get-type-ref-by-id(ep:seq/ep:construct/ep:ref/@href))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="ep:seq/ep:construct/ep:seq"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </j:map>
                        <xsl:sequence select="imf:create-minmax(ep:min-occurs,ep:max-occurs)"/>
                        <xsl:if test="$as-property">
                            <xsl:sequence select="imf:ep-to-namevaluepair('uniqueItems',true())"/>
                        </xsl:if>
                        <xsl:sequence select="imf:ep-to-namevaluepair('readOnly',$read-only)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('default',$initial-value)"/>
                    </xsl:when>
                    <!-- de construct bestaat uit precies één sequence -->
                    <xsl:when test="ep:seq">
                        <xsl:variable name="super" select="ep:super/ep:ref/@href"/>
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', if ($super) then 'Seq with super [1]' else 'Seq [1]',imf:string-group($n))"/>
                        <xsl:sequence select="$header"/>
                        <xsl:if test="empty($super)">
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','object')"/>
                        </xsl:if>
                        <xsl:variable name="body">
                            <xsl:if test="exists($super)">
                                <xsl:sequence select="imf:ep-to-namevaluepair('type','object')"/>
                            </xsl:if>
                            <j:map key="properties">
                                <xsl:apply-templates select="ep:seq/ep:construct">
                                    <xsl:with-param name="as-property" select="true()"/>
                                </xsl:apply-templates>
                            </j:map>
                            <xsl:variable name="required" select="ep:seq/ep:construct[not(ep:min-occurs eq '0')]"/>
                            <xsl:if test="exists($required)">
                                <j:array key="required">
                                    <xsl:for-each select="$required">
                                        <j:string>
                                            <xsl:value-of select="imf:ep-tech-name(ep:name)"/>
                                        </j:string>
                                    </xsl:for-each>
                                </j:array>
                            </xsl:if>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="exists($super)">
                                <j:array key="allOf">
                                    <j:map>
                                        <xsl:sequence select="imf:ep-to-namevaluepair('$ref',imf:get-type-ref-by-id($super))"/>
                                    </j:map>
                                    <j:map>
                                        <xsl:sequence select="$body"/>
                                    </j:map>
                                </j:array>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$body"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <?x <xsl:sequence select="imf:create-minmax(ep:min-occurs,ep:max-occurs)"/> x?>
                        <xsl:sequence select="imf:ep-to-namevaluepair('readOnly',$read-only)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('default',$initial-value)"/>
                    </xsl:when>
                    <!-- speciaal geval, inlineOrByReference -->
                    <xsl:when test="ep:choice/ep:ref">
                        <j:array key="oneOf">
                            <xsl:for-each select="ep:choice/ep:ref">
                                <j:map>
                                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'byReference',())"/>
                                    <xsl:choose>
                                        <xsl:when test="@href = '/byReference'">
                                            <xsl:sequence select="imf:ep-to-namevaluepair('type','string')"/>
                                            <xsl:sequence select="imf:ep-to-namevaluepair('format','uri-reference')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="imf:ep-to-namevaluepair('$ref',imf:get-type-ref-by-id(@href))"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </j:map>
                            </xsl:for-each>
                        </j:array>
                    </xsl:when>
                    <!-- de construct bestaat uit één keuze -->
                    <xsl:when test="ep:choice">
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Choice [1]',$n)"/>
                        <xsl:sequence select="$header"/>
                        <j:array key="oneOf">
                            <xsl:choose>
                                <xsl:when test="imf:get-ep-parameter(ep:choice/ep:construct,'use') = 'attribuutsoort'">
                                    <xsl:for-each select="ep:choice/ep:construct">
                                        <j:map>
                                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Choice attribuutsoorten',())"/>
                                            <xsl:apply-templates select="."/>
                                        </j:map>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="imf:get-ep-parameter(ep:choice/ep:construct,'use') = 'datatype'">
                                    <xsl:for-each select="ep:choice/ep:construct">
                                        <xsl:variable name="ref" select="ep:ref/@href"/>
                                        <j:map>
                                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Choice datatypen',())"/>
                                            <xsl:sequence select="imf:ep-to-namevaluepair('$ref',imf:get-type-ref-by-id($ref))"/>
                                        </j:map>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="ep:choice/ep:construct">
                                        <xsl:variable name="ref" select="ep:ref/@href"/>
                                        <j:map>
                                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Choice objecttypen',())"/>
                                            <xsl:sequence select="imf:ep-to-namevaluepair('$ref',imf:get-type-ref-by-id($ref))"/>
                                        </j:map>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </j:array>
                    </xsl:when>
                    <!-- de construct is een enumeratie -->
                    <xsl:when test="ep:enum">
                        <xsl:variable name="type" select="imf:map-datatype-to-ep-type(ep:data-type)"/>
                   
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Enum [1]',$n)"/>
                        <xsl:sequence select="$header"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('type',$type,$nillable)"/>
                        <j:array key="enum">
                            <xsl:for-each select="ep:enum">
                                <xsl:choose>
                                    <xsl:when test="$type = 'number'">
                                        <j:number>{.}</j:number>
                                    </xsl:when>
                                    <xsl:when test="$type = 'integer'">
                                        <j:number>{.}</j:number><!-- bestaat integer in json? -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <j:string>{.}</j:string>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </j:array>
                    </xsl:when>
                    <!-- de construct is een codelijst -->
                    <xsl:when test="ep:data-type and imf:get-ep-parameter(.,'use') eq 'codelijst'">
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Codelist [1]',$n)"/>
                        <xsl:sequence select="$header"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('type','object')"/>
                        <j:map key="properties">
                            <j:map key="code">
                                <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type),$nillable)"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('readOnly',$read-only)"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('default',$initial-value)"/>
                            </j:map>
                        </j:map>
                    </xsl:when>
                    <!-- de construct is een datatype -->
                    <xsl:when test="ep:data-type">
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Datatype [1]',$n)"/>
                        <xsl:sequence select="$header"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type),$nillable)"/>
                        <xsl:sequence select="if ($unit) then imf:ep-to-namevaluepair('unit',$unit) else ()"/><!-- /req/core/iso19103-measure-types -->
                        <xsl:sequence select="imf:ep-to-namevaluepair('format',imf:map-dataformat-to-ep-type(ep:data-type))"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('minimum',ep:min-value)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('maximum',ep:max-value)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('minLength',ep:min-length)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('maxLength',ep:max-length)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('pattern',(ep:formal-pattern,imf:map-datapattern-to-ep-type(ep:data-type))[1])"/>
                        <xsl:sequence select="imf:create-minmax(ep:min-occurs,ep:max-occurs)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('readOnly',$read-only)"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('default',$initial-value)"/>
                    </xsl:when>
                    <!-- de construct is een extern ding -->
                    <xsl:when test="ep:external">
                        <!-- deze constructs worden aan het einde toegevoegd, wanneer ernaar verwezen wordt --> 
                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'External [1]',$n)"/>
                        <xsl:sequence select="$header"/>
                        <xsl:sequence select="imf:ep-to-namevaluepair('$ref',imf:get-type-ref(.))"/>
                    </xsl:when>
                    <!-- andere constructies kennen we niet -->
                    <xsl:otherwise>
                        <xsl:sequence select="imf:msg-comment(.,'WARN', 'Ken dit type niet: [1]',$n)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </j:map>
            <xsl:if test="ep:choice/ep:construct[imf:get-ep-parameter(.,'use') = 'keuze-element-datatype']">
                <!-- verzamel alle datatype keuze elementen --> 
                <xsl:apply-templates select="ep:choice/ep:construct"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--
        functions 
    -->
    
    <xsl:function name="imf:ep-to-namevaluepair" as="node()*">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="item()?"/>
        <xsl:param name="nillable"/>
        <xsl:choose>
            <xsl:when test="not(normalize-space(string($value)))">
                <!-- geen waarde -->
            </xsl:when>
            <xsl:when test="$value instance of xs:integer">
                <j:number key="{$name}">{$value}</j:number>
            </xsl:when>
            <xsl:when test="$value instance of xs:boolean">
                <j:boolean key="{$name}">{$value}</j:boolean>
            </xsl:when>
            <xsl:otherwise>
                <j:string key="{$name}">{$value}</j:string>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$nillable">
            <j:boolean key="nullable">true</j:boolean>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:ep-to-namevaluepair" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="value" as="item()?"/>
        <xsl:sequence select="imf:ep-to-namevaluepair($name,$value,false())"/>       
    </xsl:function>
    
    <xsl:function name="imf:msg-comment" as="element()?">
        <xsl:param name="this" as="node()*"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
        <xsl:variable name="quot">"</xsl:variable>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="ctext" select="replace(imf:msg-insert-parms($text,$info),$quot,$apos)"/>
        <xsl:if test="$debugging">
            <xsl:sequence select="imf:msg($this,$type,$text,$info)"/>
            <xsl:sequence select="imf:ep-to-namevaluepair('$comment',$ctext)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-ep-parameter" as="xs:string*">
        <xsl:param name="this"/>
        <xsl:param name="parameter-name"/>
        <xsl:sequence select="$this/ep:parameters/ep:parameter[@name = $parameter-name]"/>
    </xsl:function>
    
    <xsl:function name="imf:map-datatype-to-ep-type" as="xs:string"><!-- 7.3.3.1.  External types -->
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
            <xsl:when test="$data-type = 'ep:number'">number</xsl:when>
            <xsl:when test="$data-type = 'ep:boolean'">boolean</xsl:when>
            <xsl:when test="$data-type = 'ep:time'">string</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'UNKNOWN-DATATYPE: ' || $data-type"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:map-dataformat-to-ep-type" as="xs:string?"><!-- 	/req/core/iso19103-primitive-types -->
        <xsl:param name="data-type"/> 
        <xsl:choose>
            <xsl:when test="$data-type = 'ep:date'">date</xsl:when>
            <xsl:when test="$data-type = 'ep:datetime'">date-time</xsl:when>
            <xsl:when test="$data-type = 'ep:time'">time</xsl:when>
            <xsl:when test="$data-type = 'ep:uri'">uri</xsl:when>
            <xsl:otherwise>
                <!--  no format -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
    <xsl:function name="imf:map-datapattern-to-ep-type" as="xs:string?"><!-- 	/req/core/format-and-pattern -->
        <xsl:param name="data-type"/> 
        <xsl:choose>
            <xsl:when test="$data-type = 'ep:date'">^\d{{4}}-\d{{2}}-\d{{2}}$</xsl:when>
            <xsl:when test="$data-type = 'ep:datetime'">^\d{{4}}-\d{{2}}-\d{{2}}T\d{{2}}:\d{{2}}:\d{{2}}(\.\d)?(Z|((\+|-)\d{{2}}:\d{{2}}))?$</xsl:when>
            <xsl:when test="$data-type = 'ep:time'">^\d{{2}}:\d{{2}}:\d{{2}}(\.\d)?(Z|((\+|-)\d{{2}}:\d{{2}}))?$</xsl:when>
            <xsl:when test="$data-type = 'ep:uri'">^(([^:/?#]+):)?(\/\/([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?$</xsl:when>
            <xsl:otherwise>
                <!--  no pattern -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
   <xsl:function name="imf:create-description" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="text" as="xs:string*">
            <xsl:for-each select="$this/ep:documentation[@type = 'definitie']/ep:text">
                <xsl:value-of select="."/>           
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string-join($text,'; '))"/>
    </xsl:function>
    
    <xsl:function name="imf:create-minmax" as="element()*">
        <xsl:param name="min" as="xs:string?"/>
        <xsl:param name="max" as="xs:string?"/>
        <xsl:sequence select="imf:ep-to-namevaluepair('minItems',for $i in xs:integer(($min,1)[1]) return if ($i lt 2) then () else $i)"/><!-- default van minItems is 1, weglaten als 1 -->
        <xsl:sequence select="if ($max and $max ne '*') then imf:ep-to-namevaluepair('maxItems',xs:integer($max)) else ()"/>
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
                <xsl:value-of select="imf:ep-tech-name($this/ep:name)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-type-ref-by-id" as="xs:string">
        <xsl:param name="href" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$href = '/known/measure'">
                <xsl:value-of select="'https://register.geostandaarden.nl/jsonschema/uml2json/0.1/schema_definitions.json#/$defs/Measure'"/>
            </xsl:when>
            <xsl:when test="$href = '/known/linkobject'">
                <xsl:value-of select="'https://register.geostandaarden.nl/jsonschema/uml2json/0.1/schema_definitions.json#/$defs/LinkObject'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="target" select="($document//ep:construct[@id = $href])[1]"/>
                <xsl:sequence select="imf:get-type-ref($target)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-type-ref" as="xs:string">
        <xsl:param name="target" as="element(ep:construct)?"/>
        <xsl:variable name="url" select="imf:get-ep-parameter($target,'url')"/>
        <xsl:choose>
            <xsl:when test="$url">
                <xsl:value-of select="$url"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'#/$defs/' || imf:get-type-name($target)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:ep-tech-name" as="xs:string?">
        <xsl:param name="name" as="xs:string?"/>
        <xsl:sequence select="if ($name) then $name else ()"/><!-- was: imf:extract($name,'[a-zA-Z0-9]+') maar lijkt geen reden voor te zijn -->
    </xsl:function>
    
</xsl:stylesheet>