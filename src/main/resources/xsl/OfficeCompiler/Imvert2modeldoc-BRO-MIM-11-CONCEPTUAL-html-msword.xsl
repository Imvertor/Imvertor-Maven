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
                    table tbody tr th,
                    table tbody tr td {text-align: left; vertical-align: top;} 
                    
                    table.list { border-collapse: collapse; }
                    table.list tbody tr th {background-color: #d3d3d3;}
                    table.list tbody tr th,
                    table.list tbody tr td {border: 1px solid black;}
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
                <section>
                    <h1>Artikel 1 Definitie van registratieobject, entiteiten en attributen</h1>
                    <section>
                        <h2>Registratieobject</h2>
                        <xsl:apply-templates select="$resolved/section/section[2]" mode="reorder"/>
                    </section>
                    <section>
                        <h2>Het domeinmodel</h2>
                        <xsl:apply-templates select="$resolved/section/section[1]" mode="reorder"/>
                    </section>
                    <section>
                        <h2>Entiteiten en attributen</h2>
                        <xsl:apply-templates select="$resolved/section/section[3]" mode="reorder"/>
                    </section>
                </section>
                <section>
                    <h1>Artikel 2 Beschrijving van uitbreidbare waardelijsten    </h1>
                    <xsl:apply-templates select="$resolved/section/section[4]/section" mode="reorder"/>
                </section>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="reorder">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="h1|h2|h3" mode="reorder">
      <!-- remove -->
    </xsl:template>
    
    <xsl:template match="h4" mode="reorder">
        <h3>
            <xsl:apply-templates mode="#current"/>
        </h3>
    </xsl:template>
    
    <xsl:template match="h5" mode="reorder">
        <h4>
            <xsl:apply-templates mode="#current"/>
        </h4>
    </xsl:template>
    
    <xsl:function name="imf:insert-chapter-intro" as="item()*">
        <xsl:param name="chapter" as="element(chapter)"/>
        <xsl:comment>
            <xsl:value-of select="imf:get-config-string('appinfo','release-name')"/> imvertor <xsl:value-of select="$chapter/../@generator-version"/>
        </xsl:comment>
    </xsl:function>
    
    <xsl:function name="imf:insert-image-path">
        <xsl:param name="image-filename"/>
        <xsl:value-of select="concat('Images/',$image-filename)"/>
    </xsl:function>
    
    <xsl:function name="imf:create-section-header-name" as="element()">
        <xsl:param name="section"/>
        <xsl:param name="level"/>
        <xsl:param name="type"/>
        <xsl:param name="language-model"/>
        <xsl:param name="name"/>
        
        <xsl:variable name="trans" select="imf:translate-i3n($type,$language-model,())"/>
        
        <xsl:element name="{imf:get-section-header-element-name($level)}">
            <xsl:sequence select="$trans"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="$name"/>
        </xsl:element>
    
    </xsl:function>
    
    
</xsl:stylesheet>