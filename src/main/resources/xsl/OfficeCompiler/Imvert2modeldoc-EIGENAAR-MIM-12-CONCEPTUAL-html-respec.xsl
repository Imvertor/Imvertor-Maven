<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"

    exclude-result-prefixes="#all" 
    expand-text="yes">
    
    
    <!-- 
        Deze opzet volgt de Logius ReSpec template instructies
        
        Zie https://github.com/Logius-standaarden/ReSpec-template
    -->
    
    <xsl:import href="common/Imvert2modeldoc-html-respec.xsl"/>
    
    <xsl:param name="catalog-only">false</xsl:param>
    
    <!-- this owner generates respec files with all info stored in that file. -->
    
    <xsl:variable name="owner-config-js-url" select="imf:file-to-url(imf:get-xparm('system/inp-folder-path') || '/cfg/docrules/documentor/js/owner.js')"/>
    <xsl:variable name="owner-local-js-url" select="imf:file-to-url(imf:get-xparm('system/inp-folder-path') || '/cfg/docrules/documentor/js/local.js')"/>
    <xsl:variable name="owner-icon-url" select="imf:file-to-url(imf:get-xparm('system/inp-folder-path') || '/cfg/docrules/documentor/img/logo.ico')"/>
    <xsl:variable name="owner-css-url" select="imf:file-to-url(imf:get-xparm('system/inp-folder-path') || '/cfg/docrules/documentor/css/owner.css')"/>
    
    <xsl:variable name="owner-respec-config-url" select="$configuration-docrules-file/respec-config"/>
    
    <!--TODO deze info vanuit documentor of vanauit imvertor properties halen --> 
    <xsl:variable name="owner-name" select="imf:get-xparm('cli/owner')"/>
    <xsl:variable name="user-name" select="imf:get-xparm('cli/userid') || ', ' || imf:get-xparm('cli/owner')"/>
    <xsl:variable name="owner-url" select="'http://your.site/'"/>
    <xsl:variable name="draft-url" select="'http://some.place'"/>
    
    <xsl:variable name="catalog">
        <xsl:apply-templates select="/book/chapter"/><!-- calls upon the standard template for chapters such as CAT and REF -->
    </xsl:variable>
    
    <xsl:template match="/book">
        <xsl:sequence select="dlogger:save('$catalog-only',$catalog-only)"></xsl:sequence>
        <xsl:choose>
            <xsl:when test="imf:boolean($catalog-only)">
                <xsl:sequence select="$catalog"/>
            </xsl:when>
            <xsl:otherwise>
                <html>
                    <head>
                        <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
                        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
                        
                        <!-- optioneel: een diagram renderer (https://github.com/w3c/respec-mermaid) -->
                        <script src="https://cdn.jsdelivr.net/gh/digitalbazaar/respec-mermaid@1.0.1/dist/main.js" class="remove"></script>
                        
                        <!-- verplicht: inrichten op iedere owner. Definieert organisationConfig. -->
                        <script src="{$owner-config-js-url}" class="remove"/>
                        
                        <!-- TODO verplicht: samenstellen op basis van MsWord properties table. Let op: veel props zijn gedefinieerd in de owner.js -->
                        <script class="remove"><![CDATA[
                            var respecConfig = {{
                                specStatus: "ED",
                                specType: "IM",
                                editors: [{{
                                    name: "{$user-name}",
                                    url: "{$owner-url}"
                                }}],
                                edDraftURI: "{$draft-url}",
                                shortName: "v1.0.0",
                                publishVersion: "Versie 1.0.0",
                                previousPublishVersie: "Versie 0.9.9"
                                
                                // meer specifieke waarden voor settings kunnen hier worden opgenomen, bijv. maxTocLevel aanpassen. 
                            }};
                        ]]></script>
                        
                        <!-- zorg ervoor dat eerst de specs voor de hele organisatie worden geladen, en daarna die van de analist -->
                        <script class="remove"><![CDATA[ 
                            respecConfig = {{...organisationConfig, ...respecConfig}}
                        ]]></script>
                        
                        <!-- 
                            De volgende javascript is de complete Respec, in lijn met nationale regels (Logius).
                        -->
                        <script src="{$owner-respec-config-url}" class="remove" async="async"/>
                      
                        <title>
                            <xsl:value-of select="concat('Catalogus: ',@name)"/><!-- TODO vanuit msword -->
                        </title>
                        
                        <!-- logo van de organisatie opnemen -->
                        <link href="{$owner-icon-url}" rel="shortcut icon" type="image/x-icon" />
                        
                        <!-- 
                            De volgende javascript is een toevoeging aan de respec config van owner en dit model.
                            Deze mag bestaande javascript constructies NIET overschrijven.
                        -->
                        <script src="{$owner-local-js-url}" class="remove" async="async"/>

                        <!-- 
                            De volgende style is een toevoeging aan de base.css van Logius.
                            Deze mag bestaande CSS constructies overschrijven.
                        -->
                        <link href="{$owner-css-url}" rel="stylesheet" />
                    </head>
                    
                    <body>
                        <xsl:choose>
                            <!-- als de documentor bestanden zijn opgeleverd en verwerkt -->
                            <xsl:when test="imf:get-xparm('documentor/masterdoc-name')">
                                <xsl:sequence select="dlogger:save('file',imf:document(imf:get-xparm('properties/IMVERTOR_DOCUMENTOR_XHTMLTORESPEC_FILE')))"></xsl:sequence>
                                <xsl:sequence select="imf:document(imf:get-xparm('properties/IMVERTOR_DOCUMENTOR_XHTMLTORESPEC_FILE'))/document/section"/>
                            </xsl:when>
                            <!-- als geen documentor bestanden zijn opgeleverd en verwerkt -->
                            <xsl:otherwise>
                                <section id="abstract">
                                    <p>
                                        Samenvatting ...
                                    </p>
                                </section>
                                <section id="sotd">
                                    <p>
                                        This documentation is updated at ...
                                    </p>
                                </section>
                                <section id="prologue" class="informative" level="1">
                                    <h1>Prologue</h1>
                                    <p>
                                        Intro here ...
                                    </p>
                                </section>
                                <xsl:sequence select="$catalog"/>
                                <section id="epilogue" class="informative" level="1">
                                    <h1>Epilogue</h1>
                                    <p>
                                        Last remarks here ...
                                    </p>
                                </section>
                            </xsl:otherwise>
                        </xsl:choose>
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
    
    <xsl:function name="imf:insert-image-path">
        <xsl:param name="image-filename"/>
        <xsl:value-of select="concat('Images/',$image-filename)"/>
    </xsl:function>
    
</xsl:stylesheet>