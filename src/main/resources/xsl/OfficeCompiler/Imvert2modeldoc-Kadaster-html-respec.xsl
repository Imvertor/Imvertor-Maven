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
                <html lang="{$language}">
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                        <title>
                            <xsl:value-of select="concat('Catalogus conceptueel model: ',@name)"/>
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
                        <style type="text/css"><![CDATA[
                            th, td {
                                vertical-align: top;
                            }
                            th>p, td>p {
                                margin: 0 0 1em;
                            }
                            table {
                                width: 100%;
                            }
                            .deepheader {
                                margin-top: 1em;
                            }
                            .supplier {
                                color: gray;
                            }
                            .supplier::after {
                                content: " - ";
                            }
                            .image-asset {
                                 max-width: 100%;
                                 width: auto;
                                 height: auto;
                            }
                        ]]></style>
                    </head>
                    <body>
                        <section id="abstract">
                            <p>
                                (Abstract:) Samenvatting model..... INSERT HERE
                            </p>
                        </section>
                        <section id="sotd">
                            <p>
                                (Status van dit document:) Deze documentatie van het model is laatst bijgewerkt op <xsl:value-of select="imf:format-dateTime(current-dateTime())"/>.
                            </p>
                        </section>
                        <section id="prologue" class="informative" level="1">
                            <h1>Proloog</h1>
                            <p>
                                Proloog model hier.
                            </p>
                        </section>
                        <xsl:sequence select="$catalog"/>
                        <section id="epilogue" class="informative" level="1">
                            <h1>Epiloog</h1>
                            <p>
                                Epiloog model hier.
                            </p>
                        </section>
                    </body>
                </html>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="imf:insert-chapter-intro" as="item()*">
        <xsl:param name="chapter" as="element(chapter)"/>
        <xsl:comment>
          <xsl:value-of select="imf:get-config-string('appinfo','release-name')"/> imvertor <xsl:value-of select="$chapter/../@generator-version"/>
          </xsl:comment>
    </xsl:function>
    
    <?x
    <xsl:function name="imf:insert-image-path">
        <xsl:param name="diagram-id"/>
        <xsl:variable name="pre" select="if (imf:boolean($catalog-only)) then 'cat/' else ''"/>
        <xsl:value-of select="concat($pre,'Images/',$diagram-id,'.png')"/>
    </xsl:function>
    x?>
    <xsl:function name="imf:insert-image-path">
        <xsl:param name="image-filename"/>
        <xsl:value-of select="concat('Images/',$image-filename)"/>
    </xsl:function>
    
</xsl:stylesheet>