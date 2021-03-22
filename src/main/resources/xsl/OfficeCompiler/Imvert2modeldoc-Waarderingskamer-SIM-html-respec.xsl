<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <xsl:import href="common/Imvert2modeldoc-html-respec.xsl"/>
    
    <xsl:param name="catalog-only">true</xsl:param><!-- deze parameter is true wanneer cli/fullrespec is false -->
    
    <xsl:template match="/book">
        <xsl:variable name="catalog" as="element(section)*">
            <xsl:apply-templates select="chapter"/><!-- calls upon the standard template for chapters such as CAT and REF -->
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="imf:boolean($catalog-only)">
                <xsl:sequence select="$catalog"/>
            </xsl:when>
            <xsl:otherwise>
                <html>
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                        <title>
                            <xsl:value-of select="concat('Catalogus conceptueel model: ',@name)"/>
                        </title>
                        <script src="https://www.w3.org/Tools/respec/respec-w3c-common" class="remove"/>
                        <script class="remove">
                            var respecConfig = {
                            specStatus: "ED",
                            editors: [{
                            name: "Waarderingskamer",
                            url: "http://www.waarderingskamer.nl",
                            }],
                            edDraftURI: "http://some.place",
                            shortName: "msgdoc"
                            };
                        </script>
                        <style type="text/css">
                            th, td {
                            vertical-align: top;
                            }
                            th>p, td>p {
                            margin: 0 0 1em;
                            }
                            table {
                            width: 100%;
                            }
                        </style>
                    </head>
                    <body>
                        <section id="abstract">
                            <p>
                                Samenvatting conceptueel model..... INSERT HERE
                            </p>
                        </section>
                        <section id="sotd">
                            <p>
                                Deze documentatie van het conceptueel model is laatst bijgewerkt op <xsl:value-of select="imf:format-dateTime(current-dateTime())"/>.
                            </p>
                        </section>
                        <section id="prologue" class="informative" level="1">
                            <h1>Proloog</h1>
                            <p>
                                Proloog conceptueel model hier.
                            </p>
                        </section>
                        <xsl:sequence select="$catalog"/>
                        <section id="epilogue" class="informative" level="1">
                            <h1>Epiloog</h1>
                            <p>
                                Epiloog conceptueel model hier.
                            </p>
                        </section>
                    </body>
                </html>
            </xsl:otherwise>
        </xsl:choose>
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