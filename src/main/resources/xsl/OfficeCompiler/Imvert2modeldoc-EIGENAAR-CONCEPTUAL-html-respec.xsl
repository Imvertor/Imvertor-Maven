<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <xsl:import href="common/Imvert2modeldoc-html-respec.xsl"/>
    
    <!-- this owner generates respec files with all info stored in that file. -->
    
    <xsl:template match="/book">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>
                    <xsl:value-of select="concat('Catalogus: ',@name)"/>
                </title>
                <script src="{$configuration-docrules-file/respec-config}" class="remove"/>
                <script class="remove">
                    var respecConfig = {
                        specStatus: "ED",
                        editors: [{
                            name: "<xsl:value-of select="imf:get-xparm('cli/userid')"/>, <xsl:value-of select="imf:get-xparm('cli/owner')"/>",
                            url: "http://your.site/",
                        }],
                        edDraftURI: "http://some.place",
                        shortName: "msgdoc",
                        maxTocLevel: 4
                    };
                </script>
                <style type="text/css">
                   /* none additional yet */
                </style>
            </head>
            <body>
                <section id="abstract">
                    <p>
                        Samenvatting..... INSERT HERE
                    </p>
                </section>
                <section id="sotd">
                    <p>
                        This documentation is updated at .... INSERT HERE
                    </p>
                </section>
                <section id="prologue" class="informative" level="1">
                    <h1>Prologue</h1>
                    <p>
                        Intro here........
                    </p>
                </section>
                <xsl:apply-templates select="chapter"/><!-- calls upon the standard template for chapters such as CAT and REF -->
                <section id="epilogue" class="informative" level="1">
                    <h1>Epilogue</h1>
                    <p>
                        Last remarks here........
                    </p>
                </section>
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
    
    <xsl:function name="imf:insert-image-path">
        <xsl:param name="image-filename"/>
        <xsl:value-of select="concat('Images/',$image-filename)"/>
    </xsl:function>
    
</xsl:stylesheet>