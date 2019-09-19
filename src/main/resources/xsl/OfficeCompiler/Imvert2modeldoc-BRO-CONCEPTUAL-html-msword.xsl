<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <xsl:import href="common/Imvert2modeldoc-html-respec.xsl"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:value-of select="$subpath"/>
                </title>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <style>
                    table tbody tr th {text-align: left; vertical-align: top;} 
                    table tbody tr td {text-align: left; vertical-align: top;} 
                </style>
            </head>
            <body>
                <p><xsl:value-of select="$subpath"/></p>
                <p>Imvertor: <xsl:value-of select="imf:get-xparm('run/version')"/></p>
                <p>Model release: <xsl:value-of select="imf:get-xparm('appinfo/release-name')"/></p>
                <hr/>
                <xsl:apply-templates select="/book/chapter"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:function name="imf:insert-chapter-intro" as="item()*">
        <xsl:param name="chapter" as="element(chapter)"/>
        <p>
            <b>Deze tekst is normatief.</b>
            <xsl:comment>
                <xsl:value-of select="imf:get-config-string('appinfo','release-name')"/> imvertor <xsl:value-of select="$chapter/../@generator-version"/>
            </xsl:comment>
        </p>
    </xsl:function>
    
    <xsl:function name="imf:insert-diagram-path">
        <xsl:param name="diagram-id"/>
        <xsl:value-of select="concat('Images/',$diagram-id,'.png')"/>
    </xsl:function>
    
    <xsl:function name="imf:create-section-header-name" as="element()">
        <xsl:param name="section"/>
        <xsl:param name="level"/>
        <xsl:param name="type"/>
        <xsl:param name="language-model"/>
        <xsl:param name="name"/>
        
        <xsl:variable name="art" select="if ($level eq 3) then concat('Artikel ', (count($section/preceding-sibling::*:section)),' ') else ()"/>
       
        <xsl:element name="{imf:get-section-header-element-name($level)}">
            <xsl:sequence select="$art"/>
            <xsl:sequence select="imf:translate-i3n($type,$language-model,())"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="$name"/>
        </xsl:element>
    
    </xsl:function>
    
    
</xsl:stylesheet>