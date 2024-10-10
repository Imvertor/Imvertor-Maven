<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
   
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:exec="http://www.armatiek.com/xslweb/functions/exec"
    
    xmlns:ext="http://www.armatiek.nl/namespace"
    
    >
    
    <!--
        commandline/path naar executable (xs:string)
        argumenten (xs:string*)
        timeout (xs:integer?)
        async (xs:boolean?)
        
        This function returns 0 when okay, any other value when error occurred.
        When asynchronous, returns empty squence.
    -->
    <xsl:function name="local:os-execute" as="xs:integer"> 
        <xsl:param name="path" as="xs:string"/>
        <xsl:param name="parameters" as="xs:string*"/>
        <xsl:param name="timeout" as="xs:integer"/>
        <xsl:param name="async" as="xs:boolean"/>
        <xsl:param name="work-dir" as="xs:string"/>
        <xsl:param name="handle-quoting" as="xs:boolean"/>
        <xsl:sequence select="local:log('os-execute()',string-join(($path,$parameters),' '))"/>
        <xsl:sequence select="exec:exec-external(    
            $path,
            $parameters,
            $timeout,
            $async,
            $work-dir,
            $handle-quoting
        )"/>
    </xsl:function>
    
    <!-- 
        geef een hash af op basis van alle consonanten in het alfabet. 
    -->
    <xsl:function name="local:calculate-hashlabel" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="ext:CalculateHashlabel($string, 'ABCDFGHJKLMNPQRSTVWXYZ' )"/>
    </xsl:function>

    <!-- 
        geef een hash af op basis van alle letters in het alfabet. 
    -->
    <xsl:function name="local:calculate-hash" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="ext:CalculateHashlabel($string,'')"/>
    </xsl:function>
    
</xsl:stylesheet>