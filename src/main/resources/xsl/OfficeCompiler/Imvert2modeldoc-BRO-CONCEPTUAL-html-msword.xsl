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
                <h1><xsl:value-of select="$subpath"/></h1>
                <p>Imvertor: <xsl:value-of select="imf:get-xparm('run/version')"/></p>
                <p>Model release: <xsl:value-of select="imf:get-xparm('appinfo/release-name')"/></p>
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
    
</xsl:stylesheet>