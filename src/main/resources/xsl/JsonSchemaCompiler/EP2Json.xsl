<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    
    exclude-result-prefixes="#all"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="stylesheet-code">JSONSCHEMA</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/> 
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:template match="/ep:construct">
        <JSON> <!-- this root element will be stripped, the json is completely wrapped within { .. } -->
            <xsl:sequence select="imf:ep-to-namevaluepair('JSONOP_schema','http://json-schema.org/draft-05/schema#')"></xsl:sequence>
            <xsl:sequence select="imf:ep-to-namevaluepair('title',imf:get-ep-parameter(.,'subpath'))"/>
            <json>
                <definitions>
                    <xsl:apply-templates select="ep:seq/ep:construct/ep:seq/ep:construct"/>
                </definitions>
            </json>
        </JSON>
    </xsl:template>
    
    <xsl:template match="ep:construct">
        <xsl:variable name="n" select="concat('EP: ', ep:tech-name, ' ID: ', ep:id)"/>
        <xsl:variable name="nillable" select="imf:get-ep-parameter(.,'nillable') = 'true'"/>
        <xsl:element name="{ep:tech-name}">
            <xsl:choose>
                <xsl:when test="imf:get-ep-parameter(.,'use') eq 'data-element'">
                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Data element [1]',$n)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('type',imf:map-datatype-to-ep-type(ep:data-type), $nillable)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('format',imf:map-dataformat-to-ep-type(ep:data-type))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:ep-to-namevaluepair('title',ep:name)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('description',string-join(ep:documentation/ep:definition/*,'; '))"/>
                    <xsl:choose>
                        <xsl:when test="ep:ref and (ep:min-occurs or ep:max-occurs)">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Ref with occurs [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <items>
                                <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('JSONOP_ref',concat('#/definitions/',$target/ep:tech-name))"/>
                            </items>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minItems',ep:min-occurs)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxItems',ep:max-occurs)"/>
                        </xsl:when>
                        <xsl:when test="ep:ref">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Ref [1]',$n)"/>
                            <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('JSONOP_ref',concat('#/definitions/',$target/ep:tech-name))"/>
                        </xsl:when>
                        <xsl:when test="ep:seq and (ep:min-occurs or ep:max-occurs)">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq with occurs [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <items>
                                <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                <xsl:sequence select="imf:ep-to-namevaluepair('JSONOP_ref',concat('#/definitions/',$target/ep:tech-name))"/>
                            </items>
                            <xsl:sequence select="imf:ep-to-namevaluepair('minItems',ep:min-occurs)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('maxItems',ep:max-occurs)"/>
                        </xsl:when>
                        <xsl:when test="ep:seq">
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','object')"/>
                            <xsl:variable name="body">
                                <xsl:variable name="required" select="ep:seq/ep:construct[not(ep:min-occurs eq '0')]"/>
                                <xsl:if test="exists($required)">
                                    <xsl:processing-instruction name="xml-multiple">required</xsl:processing-instruction>
                                    <xsl:for-each select="$required">
                                        <xsl:sequence select="imf:ep-to-namevaluepair('required',ep:tech-name)"/>
                                    </xsl:for-each>
                                </xsl:if>
                                <properties>
                                    <xsl:apply-templates select="ep:seq/ep:construct"/>
                                </properties>
                            </xsl:variable>
                            <xsl:variable name="super" select="imf:get-ep-parameter(.,'super')"/>
                            <xsl:choose>
                                <xsl:when test="exists($super)">
                                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq with super [1]',imf:string-group($n))"/>
                                    <allOf>
                                        <xsl:variable name="target" select="//ep:construct[ep:id = $super]"/>
                                        <xsl:for-each select="$target">
                                            <xsl:sequence select="imf:ep-to-namevaluepair('JSONOP_ref',concat('#/definitions/',ep:tech-name))"/>
                                        </xsl:for-each>
                                    </allOf>
                                    <allOf>
                                        <xsl:sequence select="$body"/>
                                    </allOf>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Seq [1]',$n)"/>
                                    <xsl:sequence select="$body"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ep:choice">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Choice [1]',$n)"/>
                            <xsl:for-each select="ep:choice/ep:construct">
                                <oneOf>
                                    <xsl:variable name="target" select="//ep:construct[ep:id = current()/ep:ref]"/>
                                    <xsl:sequence select="imf:ep-to-namevaluepair('JSONOP_ref',concat('#/definitions/',$target/ep:tech-name))"/>
                                </oneOf>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="ep:enum">
                            <xsl:sequence select="imf:msg-comment(.,'DEBUG', 'Enum [1]',$n)"/>
                            <xsl:sequence select="imf:ep-to-namevaluepair('type','array')"/>
                            <xsl:for-each select="ep:enum">
                                <items>
                                    <xsl:value-of select="ep:name"/>
                                </items>
                            </xsl:for-each>
                        </xsl:when>
                   
                        <xsl:when test="ep:data-type and imf:get-ep-parameter(.,'use') eq 'codelist'">
                            <properties>
                                <xsl:sequence select="imf:ep-to-namevaluepair('code',imf:map-datatype-to-ep-type(ep:data-type),$nillable)"/>
                            </properties>
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
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg-comment(.,'WARN', 'Ken dit type niet: [1]',$n)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>     
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
                    <xsl:processing-instruction name="xml-multiple">type</xsl:processing-instruction>
                    <xsl:sequence select="imf:ep-to-namevaluepair('type',$value)"/>
                    <xsl:sequence select="imf:ep-to-namevaluepair('type','null')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="{$name}">
                        <xsl:value-of select="$value"/>
                    </xsl:element>
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