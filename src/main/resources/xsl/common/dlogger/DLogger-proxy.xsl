<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:http="http://expath.org/ns/http-client"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    xmlns:dlogger-impl="http://www.armatiek.nl/functions/dlogger"
    xmlns:dlogger-proxy="http://www.armatiek.nl/functions/dlogger-proxy"
    >
    
    <xsl:param name="dlogger-mode" as="xs:string?"/>
    <xsl:param name="dlogger-proxy-url" as="xs:string?"/>
    <xsl:param name="dlogger-viewer-url" as="xs:string?"/>
    <xsl:param name="dlogger-client-name" as="xs:string?"/>
    
    <xsl:param name="dlogger-impl:dlogger-mode" as="xs:boolean" select="$dlogger-mode = 'true'"/><!-- determine correct mode based on OTAP -->
    <xsl:param name="dlogger-impl:dlogger-client" as="xs:string" select="$dlogger-client-name"/><!-- TODO determine dynamically by identifying machine/server -->
    <xsl:param name="dlogger-impl:dlogger-proxy" as="xs:boolean" select="true()"/><!-- imvertor is stand-alone and must go through proxy -->
    
    <xsl:param name="dlogger-impl:dlogger-proxy-url" as="xs:string" select="$dlogger-proxy-url"/>
    <xsl:param name="dlogger-impl:dlogger-viewer-url" as="xs:string" select="$dlogger-viewer-url"/>
    
    <!-- 
        Import the DLogger code, which is distributed and should not be altered within the settings of the client app. 
        
        The DLogger code references :get and :put functions, implemented here.
    -->
    <xsl:import href="dlogger.xsl"/>
    
    <!-- 
        Implement a dlogger put. Pass key and value, return empty sequence. 
    -->
    <xsl:function name="dlogger-impl:put" as="empty-sequence()">
        <xsl:param name="atts" as="element(atts)"/>
        <xsl:variable name="request" as="element(http:request)">
            <http:request
                href="{$dlogger-impl:dlogger-proxy-url}"
                method="POST"
                send-authorization="false"
                >
                <http:body media-type="application/xml">
                    <xsl:sequence select="$atts"/>
                </http:body>
            </http:request>
        </xsl:variable>
        <xsl:variable name="response" select="imf:expath-send-request($request)"/>
        <xsl:sequence select="$response[3]"/><!-- empty at all times -->    
    </xsl:function>
    
    <!-- 
        Implement a dlogger get. Pass key, return optional string result. 
    -->
    <xsl:function name="dlogger-impl:get" as="xs:string?">
        <xsl:param name="key" as="xs:string"/>
        <xsl:variable name="request" as="element(http:request)">
            <http:request
                href="{$dlogger-impl:dlogger-proxy-url}?app={encode-for-uri($dlogger-impl:dlogger-client)}&amp;key={encode-for-uri($key)}"
                method="GET"
                send-authorization="false"
                override-media-type="text/plain"
                />
        </xsl:variable>
        <xsl:variable name="response" select="imf:expath-send-request($request)"/>
        <xsl:sequence select="if ($response[1]/@status ne '200') then ('#' || $response[1]/@status) else $response[2]"/>
    </xsl:function>
    
    <!-- TODO moet dit? override de context functies die verwacht worden in de static dlogger.xsl -->
    <xsl:function name="context:set-attribute" as="item()*" xmlns:context="http://www.armatiek.com/xslweb/functions/context">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="value" as="item()?"/>
    </xsl:function>
    <xsl:function name="context:get-attribute" as="item()*" xmlns:context="http://www.armatiek.com/xslweb/functions/context">
        <xsl:param name="key" as="xs:string"/>
    </xsl:function>
    
</xsl:stylesheet>