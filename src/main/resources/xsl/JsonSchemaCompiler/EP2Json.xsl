<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    
    exclude-result-prefixes="#all"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="stylesheet-code">JSONSCHEMA</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/> 
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:template match="/ep:construct">
        <j:map>
            <xsl:sequence select="imf:ep-to-namevaluepair('$schema','http://json-schema.org/draft-06/schema#')"></xsl:sequence>
            <xsl:sequence select="imf:ep-to-namevaluepair('title',imf:get-ep-parameter(.,'subpath'))"/>
            <j:map key="json">
                <j:map key="definitions">
                    <xsl:apply-templates select="ep:seq/ep:construct/ep:seq/ep:construct"/>
                </j:map>
            </j:map>
        </j:map>
    </xsl:template>
    
    <xsl:template match="ep:construct">
        <xsl:variable name="n" select="concat('EP: ', ep:tech-name, ' ID: ', ep:id)"/>
        <xsl:variable name="nillable" select="imf:get-ep-parameter(.,'nillable') = 'true'"/>
        <j:map key="{ep:tech-name}">
            <xsl:choose>
                <xsl:when test="imf:get-ep-parameter(.,'use') eq 'data-element'">
                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Data element [1]',$n)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type), $nillable)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('format',imf:map-dataformat-to-ep-type(ep:data-type))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:ep-to-namevaluepair('title',ep:name)"/>
                    <xsl:variable name="added-location" select="if (ep:data-location) then concat(' Locatie: ',ep:data-location) else ()"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('description',concat(string-join(ep:documentation/ep:definition/*,'; '),$added-location))"/>
                    <xsl:choose>
                        <xsl:when test="ep:ref and (ep:min-occurs or ep:max-occurs)">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Ref with occurs [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <j:map key="items">
                                <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('$ref',concat('#/definitions/',$target/ep:tech-name))"/>
                            </j:map>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minItems',ep:min-occurs)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxItems',ep:max-occurs)"/>
                        </xsl:when>
                        <xsl:when test="ep:ref">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Ref [1]',$n)"/>
                            <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('$ref',concat('#/definitions/',$target/ep:tech-name))"/>
                        </xsl:when>
                        <xsl:when test="ep:seq and (ep:min-occurs or ep:max-occurs)">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq with occurs [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <j:map key="items">
                                <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('$ref',concat('#/definitions/',$target/ep:tech-name))"/>
                            </j:map>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minItems',ep:min-occurs)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxItems',ep:max-occurs)"/>
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
                                    <j:array key="allOf">
                                        <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq with super [1]',imf:string-group($n))"/>
                                        <j:map>
                                            <xsl:variable name="target" select="//ep:construct[ep:id = $super]"/>
                                            <j:array key="$ref">
                                                <xsl:for-each select="$target">
                                                    <j:string>
                                                        <xsl:value-of select="concat('#/definitions/',ep:tech-name)"/>
                                                    </j:string>
                                                </xsl:for-each>
                                            </j:array>
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
                            <j:array key="oneOf">
                                <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Choice [1]',$n)"/>
                                <xsl:for-each select="ep:choice/ep:construct">
                                    <j:map>
                                        <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                        <xsl:sequence select="imf:ep-to-namevaluepair('$ref',concat('#/definitions/',$target/ep:tech-name))"/>
                                    </j:map>
                                </xsl:for-each>
                            </j:array>
                        </xsl:when>
                        <xsl:when test="ep:enum">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Enum [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <j:array key="items">
                                <xsl:for-each select="ep:enum">
                                    <j:string>
                                        <xsl:value-of select="ep:name"/>
                                    </j:string>
                                </xsl:for-each>
                            </j:array>
                        </xsl:when>
                   
                        <xsl:when test="ep:data-type and imf:get-ep-parameter(.,'use') eq 'codelist'">
                            <j:map key="properties">
                                <xsl:sequence select="imf:ep-to-namevaluepair('code',imf:map-datatype-to-ep-type(ep:data-type),$nillable)"/>
                            </j:map>
                        </xsl:when>
                        
                        <xsl:when test="ep:data-type">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Datatype [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type),$nillable)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('format',imf:map-dataformat-to-ep-type(ep:data-type))"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minValue',ep:min-value)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxValue',ep:max-value)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minLength',ep:min-length)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxLength',ep:max-length)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('pattern',ep:formal-pattern)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minItems',ep:min-occurs)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxItems',ep:max-occurs)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg-comment(.,'WARN', 'Ken dit type niet: [1]',$n)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </j:map>
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
            <xsl:sequence select="imf:ep-to-namevaluepair('_comment',$ctext)"/>
            <xsl:sequence select="imf:msg($this,$type,$text,$info)"/>
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
            <xsl:when test="$data-type = 'ep:uri'">uri</xsl:when>
            <xsl:when test="$data-type = 'ep:real'">number</xsl:when>
            <xsl:when test="$data-type = 'ep:decimal'">number</xsl:when>
            <xsl:when test="$data-type = 'ep:integer'">integer</xsl:when>
            <xsl:when test="$data-type = 'ep:boolean'">boolean</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('UNKNOWN-DATATYPE: ',$data-type)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:map-dataformat-to-ep-type" as="xs:string?">
        <xsl:param name="data-type"/> 
        <xsl:choose>
            <xsl:when test="$data-type = 'ep:date'">date-time</xsl:when>
            <xsl:when test="$data-type = 'ep:datetime'">date-time</xsl:when>
            <xsl:when test="$data-type = 'ep:year'">year</xsl:when>
            <xsl:when test="$data-type = 'ep:uri'">uri</xsl:when>
            <xsl:otherwise>
                <!--  no format -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>