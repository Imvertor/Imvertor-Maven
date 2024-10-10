<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:local" 
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    
    expand-text="yes"
    >
   
    <xsl:param name="config:webapp-dir"/>
    
    <xsl:function name="local:translate-i3n">
        <xsl:param name="key" as="xs:string"/> <!-- case insensitive -->
        <xsl:param name="lang" as="xs:string"/>  <!-- case insensitive -->
        <xsl:param name="default" as="xs:string?"/>
        <xsl:variable name="trans" select="($configuration-i3n-file//item[key = upper-case($key)]/trans[@lang = $lang])[last()]/text()"/>
        <xsl:sequence select="if (exists($trans)) then $trans else if (exists($default)) then $default else local:translate-error($key,$lang)"/>
    </xsl:function>

    <xsl:function name="local:translate-error">
        <xsl:param name="key"/>
        <xsl:param name="lang"/>
        <error>Geen vertaling gevonden: {$key}@{$lang}</error>
    </xsl:function>
    
</xsl:stylesheet>