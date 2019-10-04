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
                <xsl:variable name="resolved">
                    <xsl:apply-templates select="/book/chapter"/>
                </xsl:variable>
                <xsl:apply-templates select="$resolved//section[@level = '3' and exists(preceding-sibling::section)]" mode="reorder"/>
                <section id="" level="3">
                    <h1>Artikel 4 Het domeinmodel</h1>
                    <xsl:sequence select="$resolved//div[@class = 'imageinfo overview']"/>
                </section>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="reorder">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[img]" mode="reorder">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="h3" mode="reorder">
        <h1>
            <xsl:apply-templates mode="#current"/>
        </h1>
    </xsl:template>
    
    <xsl:template match="h4" mode="reorder">
        <h2>
            <xsl:apply-templates mode="#current"/>
        </h2>
    </xsl:template>
    
    <xsl:template match="h5" mode="reorder">
        <h3>
            <xsl:apply-templates mode="#current"/>
        </h3>
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
        <xsl:variable name="trans" select="imf:translate-i3n($type,$language-model,())"/>
        
        <xsl:element name="{imf:get-section-header-element-name($level)}">
            <xsl:sequence select="$art"/>
            <xsl:sequence select="if ($trans = 'Uitbreidbare waardelijsten') then 'Beschrijving van uitbreidbare waardelijsten' else $trans"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="$name"/>
        </xsl:element>
    
    </xsl:function>
    
    
</xsl:stylesheet>