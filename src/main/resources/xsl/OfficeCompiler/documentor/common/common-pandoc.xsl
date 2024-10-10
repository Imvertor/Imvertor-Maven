<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:http="http://expath.org/ns/http-client"
    xmlns:resp="http://www.armatiek.com/xslweb/response"   
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    xmlns:amf="http://www.armatiek.nl/functions" 
    xmlns:local="urn:local"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="config:pandoc-uri" as="xs:string">http://pandoc:8080</xsl:param>
    
    <!-- 
        aanroepen als:
        <xsl:sequence select="amf:convert-doc-to-html('file:///usr/local/xslweb/home/test.docx', 'pandoc -f docx -t html')/*"/>
    -->
    
    <xsl:function name="amf:convert-doc-to-html" as="document-node()">
        <xsl:param name="doc-uri" as="xs:string"/>
        <xsl:param name="pandoc-cli" as="xs:string"/>
        
        <!-- ?command_line={encode-for-uri($pandoc-cli)}&amp;content_type={encode-for-uri('text/xml')}&amp;character_encoding=UTF-8 -->
        
        <!-- Build the HTTP request: -->
        <xsl:variable name="request" as="element(http:request)">
            <http:request 
                href="{$config:pandoc-uri}/shellexecutor?command_line={encode-for-uri($pandoc-cli)}&amp;content_type={encode-for-uri('text/html')}&amp;character_encoding=UTF-8"
                override-media-type="text/html"
                method="POST">
                <http:multipart media-type="multipart/form-data" boundary="pandoc-123">
                    <!-- field "stdin": -->
                    <http:header name="Content-Disposition" value="form-data; name=&quot;stdin&quot;; filename=&quot;{tokenize($doc-uri, '/')[last()]}&quot;"/>
                    <http:body src="{$doc-uri}" media-type="application/octet-stream"/>
                    
                    <?x of specificeer string parameters als parts:
                    
                    <!-- field "command_line": -->
                    <http:header name="Content-Disposition" value="form-data; name=&quot;command_line&quot;"/>
                    <http:body media-type="text/plain" method="text">
                        <xsl:value-of select="$pandoc-cli"/>
                    </http:body> 
                    
                    <!-- field "content_type": -->
                    <http:header name="Content-Disposition" value="form-data; name=&quot;content_type&quot;"/>
                    <http:body media-type="text/plain" method="text">text/xml</http:body> 
                    
                    <!-- field "character_encoding": -->
                    <http:header name="Content-Disposition" value="form-data; name=&quot;character_encoding&quot;"/>
                    <http:body media-type="text/plain" method="text">UTF-8</http:body>
                    ?>
                </http:multipart>
            </http:request>
        </xsl:variable>
        
        <!-- Execute the request: -->
        <xsl:try>
            <xsl:variable name="response" select="http:send-request($request)" as="item()*"/>
            
            <xsl:sequence select="local:log('pandoc $doc-uri',$doc-uri)"/>
            
            <!-- Process the response: -->
            <xsl:choose>
                <xsl:when test="$response[1]/xs:integer(@status) = 200">
                    <!-- Execute request to test exit-value: -->
                    <xsl:variable name="x-process-id" select="$response[1]/http:header[lower-case(@name) = 'x-process-id']/@value" as="xs:string?"/>
                    <xsl:variable name="request-exitvalue" as="element(http:request)">
                        <http:request href="{$config:pandoc-uri}/exitvalue?process_id={$x-process-id}" method="GET"/>
                    </xsl:variable>
                    <xsl:variable name="response-exitvalue" select="http:send-request($request-exitvalue)" as="item()*"/>
                    <xsl:choose>
                        <xsl:when test="$response-exitvalue[1]/xs:integer(@status) ne 200">
                            <xsl:document>
                                <xsl:sequence select="local:log('error: pandoc status ' || $response-exitvalue[1]/@status,$response-exitvalue[1]/@message)"/>
                                <error http-status-code="{$response-exitvalue[1]/@status}" message="{$response-exitvalue[1]/@message}"/>    
                            </xsl:document>
                        </xsl:when>
                        <xsl:when test="xs:integer($response-exitvalue[2]) ne 0">
                            <xsl:document>
                                <xsl:sequence select="local:log('error: pandoc exit ' || $response-exitvalue[2],'See https://pandoc.org/MANUAL.html#exit-codes')"/>
                                <error exit-value="{$response-exitvalue[2]}" message="Exit value of pandoc is {$response-exitvalue[2]}. See https://pandoc.org/MANUAL.html#exit-codes."/>    
                            </xsl:document>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$response[2]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <error http-status-code="{$response[1]/@status}" message="{$response[1]/@message}"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:catch>
                <error http-status-code="500" message="$err:description"/>   
                <xsl:sequence select="local:log('error: pandoc', $err:description || ' [' || $err:code || '] line: ' || $err:line-number || ', column: ' || $err:column-number)"/>
            </xsl:catch>
        </xsl:try>
     </xsl:function> 
    
</xsl:stylesheet>