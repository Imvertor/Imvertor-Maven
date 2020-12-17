<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    xmlns:context="http://www.armatiek.com/xslweb/functions/context"
    
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    
    xmlns:dlogger-impl="http://www.armatiek.nl/functions/dlogger"
    
    expand-text="yes"
    >
    <!--[dlogger] version 1.1.0
        
        Avoid reflexion processing; keep this comment here. 
    
        This stylesheet is maintained elsewhere as part of the /DLogger-common webapp. 
        
        Do not edit!
    -->
    
    <xsl:param name="dlogger-impl:dlogger-viewer-url" as="xs:string" select="'http://unknown-dlogger-viewer-url'"/><!-- URL of the dlogger viewer webapp itself -->
    
    <xsl:param name="dlogger-impl:dlogger-mode" as="xs:boolean" select="false()"/><!-- is dlogger mode active, i.e. should this app produce dlogs? -->
    <xsl:param name="dlogger-impl:dlogger-client" as="xs:string" select="'unknown-app'"/><!-- the name of the client shown in viewer -->
    <xsl:param name="dlogger-impl:dlogger-proxy" as="xs:boolean" select="false()"/><!-- does this webapp access a proxy? -->
    
    <xsl:variable name="dlogger-impl:comment-dashes">--</xsl:variable>
    <xsl:variable name="dlogger-impl:comment-dashes-alter">- - </xsl:variable>
    
    <xsl:function name="dlogger-impl:init" as="empty-sequence()">
        <xsl:param name="clear" as="xs:boolean"/>
        <xsl:if test="$dlogger-impl:dlogger-mode">
            <xsl:variable name="result" as="element(atts)">
                <atts>
                    <xsl:variable name="url" select="if ($dlogger-impl:dlogger-proxy) then ($dlogger-impl:dlogger-viewer-url || '/init/' || $dlogger-impl:dlogger-client) else ('xslweb:///DLogger-viewer/init/' || $dlogger-impl:dlogger-client)"/>
                    <xsl:variable name="call" as="element(att)">
                        <att><!-- dummy wrapper avoids static type warning -->
                            <xsl:sequence select="if (document($url)/*) then dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_recordnumber',0) else ()"/>
                        </att>
                    </xsl:variable>
                    <xsl:sequence select="if ($clear) then $call[2] else ()"/><!-- force empty sequence in all cases -->
                    <!-- add this webapp to the list (as first), and set datetime to current; signals the init -->
                    <xsl:sequence select="dlogger-impl:set-attribute('dlogger_webapps',$dlogger-impl:dlogger-client || ';' || replace(dlogger-impl:get-attribute('dlogger_webapps'),$dlogger-impl:dlogger-client || ';',''))"/>
                    <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_datetime',dlogger-impl:format-dateTime(current-dateTime()))"/>
                </atts>
            </xsl:variable>
            <xsl:sequence select="dlogger-impl:record($result)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="dlogger-impl:init" as="empty-sequence()">
        <xsl:sequence select="dlogger-impl:init(true())"/>
    </xsl:function>    
    
    <xsl:function name="dlogger-impl:save-reflexion" as="empty-sequence()">
        <xsl:param name="stylesheet" as="xs:string?"/>
        <xsl:param name="container-type" as="xs:string?"/>
        <xsl:param name="container-name" as="xs:string?"/>
        <xsl:param name="label" as="xs:string"/>
        <xsl:param name="contents" as="item()*"/>
        <xsl:param name="type" as="xs:string?"/>
        
        <xsl:choose>
            <xsl:when test="not($dlogger-impl:dlogger-mode)">
                <!-- do nothing -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="result" as="element(atts)">
                    <atts>
                        <xsl:variable name="has-elements" select="(for $c in $contents return $c instance of element()) = true()"/>
                        <xsl:variable name="contents-as-xml" select="count($contents) gt 1 or $contents instance of attribute()"/>
                        <xsl:variable name="ext" select="
                            if ($type = 'parms') then 'html' 
                            else if ($contents-as-xml) then 'xml' 
                            else if ($type) then $type 
                            else if (($has-elements) or ($contents instance of document-node()) or ($contents instance of map(*))) then 'xml' 
                            else 'txt'
                            "/>
                        <xsl:variable name="datatypes" select="dlogger-impl:save-type($contents)"/>
                        <xsl:variable name="is-singleton-datatype" select="count($datatypes) eq 1 and starts-with($datatypes,'xs')"/>
                        <xsl:variable name="usable-contents" as="item()*">
                            <xsl:choose>
                                <xsl:when test="$contents-as-xml">
                                    <dlogger-wrapper xsl:exclude-result-prefixes="#all">
                                        <xsl:for-each select="$contents">
                                            <xsl:variable name="position" select="position()"/>
                                            <dlogger-wrap dlogger-type="{subsequence($datatypes,$position,1)}">
                                                <xsl:sequence select="."/> 
                                            </dlogger-wrap>
                                        </xsl:for-each>
                                    </dlogger-wrapper>
                                </xsl:when>
                                <xsl:when test="$contents instance of map(*)">
                                    <xsl:variable name="map-keys" select="map:keys($contents)" as="xs:anyAtomicType*"/>
                                    <dlogger-map xsl:exclude-result-prefixes="#all">
                                        <xsl:for-each select="$map-keys">
                                            <dlogger-map-entry key="{.}">
                                                <xsl:variable name="map-values" select="map:get($contents,.)"/>
                                                <xsl:for-each select="$map-values">
                                                    <dlogger-map-value dlogger-type="{dlogger-impl:save-type(.)}">
                                                        <xsl:sequence select="."/>
                                                    </dlogger-map-value>
                                                </xsl:for-each>
                                            </dlogger-map-entry>
                                        </xsl:for-each>
                                    </dlogger-map>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$contents"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="params" as="element()"><!-- https://www.w3.org/TR/xpath-functions-31/#func-serialize -->
                            <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
                                <xsl:if test="$ext = 'xml'">
                                    <output:indent value="yes"/>
                                    <output:undeclare-prefixes value="yes"/>
                                    <output:version value="1.1"/>
                                </xsl:if>
                            </output:serialization-parameters>
                        </xsl:variable>
                        <xsl:variable name="contents-string" select="if ($is-singleton-datatype) then $usable-contents else serialize($usable-contents,$params)"/>
                        <xsl:variable name="previous-recordnumber" select="xs:integer((dlogger-impl:get-attribute($dlogger-impl:dlogger-client || '_recordnumber'),0)[1])" as="xs:integer"/>
                        <xsl:variable name="recordnumber" select="$previous-recordnumber + 1" as="xs:integer"/>
                        <xsl:variable name="value" select="if (not($ext = ('xml','json','html')) and count($usable-contents) = 1 and ($usable-contents castable as xs:string)) then substring(string($usable-contents),1,1024) else ()"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_recordnumber',$recordnumber)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber, $contents-string)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_stylesheet', $stylesheet)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_containertype', $container-type)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_containername', $container-name)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_label', $label)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_file', replace($label,'[^A-Za-z0-9\s_\-\.]+','_'))"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_ext', $ext)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_type', $type)"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_datatype', $datatypes[1] || (if ($datatypes[2]) then ' (...)' else ''))"/>
                        <xsl:sequence select="dlogger-impl:set-attribute($dlogger-impl:dlogger-client || '_' || $recordnumber || '_value', $value)"/>
                    </atts>
                </xsl:variable>
                <xsl:sequence select="dlogger-impl:record($result)"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="dlogger-impl:save-reflexion" as="empty-sequence()">
        <xsl:param name="stylesheet" as="xs:string?"/>
        <xsl:param name="container-type" as="xs:string?"/>
        <xsl:param name="container-name" as="xs:string?"/>
        <xsl:param name="label" as="xs:string"/>
        <xsl:param name="contents" as="item()*"/>
        <xsl:sequence select="dlogger-impl:save-reflexion($stylesheet,$container-type,$container-name,$label,$contents,())"/>
    </xsl:function>
    
    <xsl:function name="dlogger-impl:save" as="empty-sequence()">
        <xsl:param name="label" as="xs:string"/>
        <xsl:param name="contents" as="item()*"/>
        <xsl:param name="type" as="xs:string?"/>
        <xsl:sequence select="dlogger-impl:save-reflexion((),(),(),$label,$contents,$type)"/>
    </xsl:function>        
    
    <xsl:function name="dlogger-impl:save" as="empty-sequence()">
        <xsl:param name="label" as="xs:string"/>
        <xsl:param name="contents" as="item()*"/>
        <xsl:sequence select="dlogger-impl:save-reflexion((),(),(),$label,$contents,())"/>
    </xsl:function>        
    
    <xsl:function name="dlogger-impl:comment-reflexion" as="comment()">
        <xsl:param name="stylesheet" as="xs:string?"/>
        <xsl:param name="container-type" as="xs:string?"/>
        <xsl:param name="container-name" as="xs:string?"/>
        <xsl:param name="label" as="xs:string"/>
        <xsl:variable name="c">DLOG {$label} : {$stylesheet} : {$container-type} : {$container-name}</xsl:variable>
        <xsl:comment>{replace($c,$dlogger-impl:comment-dashes,$dlogger-impl:comment-dashes-alter)}</xsl:comment>
    </xsl:function>
    
    <xsl:function name="dlogger-impl:comment" as="comment()">
        <xsl:param name="label" as="xs:string"/>
        <xsl:variable name="c">DLOG {$label}</xsl:variable>
        <xsl:comment>{replace($c,$dlogger-impl:comment-dashes,$dlogger-impl:comment-dashes-alter)}</xsl:comment>
    </xsl:function>        
    
    <xsl:function name="dlogger-impl:save-type" as="xs:string*">
        <xsl:param name="values" as="item()*"/>
        
        <xsl:sequence select="
            for $val in $values
            return
            (
            if ($val instance of element()) then 'element'
            else if ($val instance of document-node()) then 'document'
            else if ($val instance of attribute()) then 'attribute'
            else if ($val instance of text()) then 'text'
            else if ($val instance of comment()) then 'comment'
            else if ($val instance of processing-instruction()) then 'processing-instruction'
            else if ($val instance of map(*)) then 'map'
            else if ($val instance of xs:untypedAtomic) then 'xs:untypedAtomic'
            else if ($val instance of xs:anyURI) then 'xs:anyURI'
            else if ($val instance of xs:string) then 'xs:string'
            else if ($val instance of xs:QName) then 'xs:QName'
            else if ($val instance of xs:boolean) then 'xs:boolean'
            else if ($val instance of xs:base64Binary) then 'xs:base64Binary'
            else if ($val instance of xs:hexBinary) then 'xs:hexBinary'
            else if ($val instance of xs:integer) then 'xs:integer'
            else if ($val instance of xs:decimal) then 'xs:decimal'
            else if ($val instance of xs:float) then 'xs:float'
            else if ($val instance of xs:double) then 'xs:double'
            else if ($val instance of xs:date) then 'xs:date'
            else if ($val instance of xs:time) then 'xs:time'
            else if ($val instance of xs:dateTime) then 'xs:dateTime'
            else if ($val instance of xs:dayTimeDuration) then 'xs:dayTimeDuration'
            else if ($val instance of xs:yearMonthDuration) then 'xs:yearMonthDuration'
            else if ($val instance of xs:duration) then 'xs:duration'
            else if ($val instance of xs:gMonth) then 'xs:gMonth'
            else if ($val instance of xs:gYear) then 'xs:gYear'
            else if ($val instance of xs:gYearMonth) then 'xs:gYearMonth'
            else if ($val instance of xs:gDay) then 'xs:gDay'
            else if ($val instance of xs:gMonthDay) then 'xs:gMonthDay'
            else 'unknown'
            )
            "/>
        
    </xsl:function>
    
    <xsl:function name="dlogger-impl:set-attribute" as="item()*">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="value" as="item()?"/>
        <xsl:choose>
            <xsl:when test="$dlogger-impl:dlogger-proxy">
                <att key="{$key}">
                    <xsl:value-of select="$value"/>
                </att>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="context:set-attribute($key,$value)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="dlogger-impl:get-attribute" as="item()*">
        <xsl:param name="key" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$dlogger-impl:dlogger-proxy">
                <!-- get a response from the dlogger proxy -->
                <xsl:sequence select="dlogger-impl:get($key)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="context:get-attribute($key)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="dlogger-impl:record" as="empty-sequence()">
        <xsl:param name="result" as="element(atts)"/><!-- elements only produced when posting to proxy -->
        <xsl:choose>
            <xsl:when test="$dlogger-impl:dlogger-proxy">
                <!-- post the request to the dlogger proxy -->
                <xsl:sequence select="dlogger-impl:put($result)"></xsl:sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$result/*"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="dlogger-impl:format-dateTime" as="xs:string">
        <xsl:param name="datetime" as="xs:dateTime"/>
        <xsl:value-of select="format-dateTime($datetime, '[Y0001]-[M01]-[D01] at [H01]:[m01]:[s01]')"/>
    </xsl:function>
    
    <!-- 
        override this function! 
        implement a put request passing the <atts> element. 
    -->
    <xsl:function name="dlogger-impl:put" as="empty-sequence()">
        <xsl:param name="atts" as="element(atts)"/>
        <xsl:sequence select="()"/>
    </xsl:function>
    
    <!-- 
        override this function! 
        implement a get request. Pass key, return optional string result. 
    -->
    <xsl:function name="dlogger-impl:get" as="xs:string?">
        <xsl:param name="key" as="xs:string"/>
        <xsl:sequence select="()"/>
    </xsl:function>
    
</xsl:stylesheet>