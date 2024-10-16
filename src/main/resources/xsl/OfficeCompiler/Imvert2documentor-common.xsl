<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:local="urn:local"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger"
    
    expand-text="yes">
    
    <!-- 
       de naam van het hoofddocument wordt ofwel meegegeven, of uitgelezen uit de Imvertor omgeving.
       
       Voorbeeld: "Primer-1.0.docx"
    --> 
    
    <xsl:variable name="module-work-folder-path" select="imf:get-xparm('system/work-folder-path') || '/documentor/module'"/>
    <!-- 
        Vervang domweg alle \ door /
    -->
    <xsl:function name="local:safe-file-path" as="xs:string">
        <xsl:param name="filepath"/>
        <xsl:value-of select="replace($filepath,'\\','/')"/>
    </xsl:function>
   
    <xsl:function name="local:compact" as="xs:string">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:sequence select="replace(lower-case($string),'[^a-z0-9]+','')"/>
    </xsl:function>
    
    <xsl:function name="local:translate-i3n" as="xs:string">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="language" as="xs:string?"/>
        <xsl:param name="default" as="xs:string?"/>
        <xsl:sequence select="$string"/><!-- TODO vertaal conform imvertor os -->
    </xsl:function>
    <xsl:function name="local:translate-i3n" as="xs:string">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="language" as="xs:string?"/>
        <xsl:sequence select="local:translate-i3n($string,$language,())"/>
    </xsl:function>
    
    <xsl:function name="local:log">
        <xsl:param name="key"/>
        <xsl:param name="value"/>
        <xsl:sequence select="dlogger:save($key,$value)"/>
    </xsl:function>
    
</xsl:stylesheet>