<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all" 
    expand-text="yes">
    
    
    <!-- 
        Deze opzet volgt de Logius ReSpec template instructies
        
        Zie https://github.com/Logius-standaarden/ReSpec-template
    -->
    
    <xsl:variable name="owner-respec-config-url" select="$configuration-docrules-file/respec-config"/>
    
    <xsl:function name="pack:simple-respec" as="item()*">
        <xsl:param name="book" as="item()*"/>
        <xsl:apply-templates select="$book" mode="pack:simple-respec"/>
        
    </xsl:function>
    
    <xsl:template match="book" mode="pack:simple-respec">
        <html lang="{$language}">
            <html>
                <head>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                    <title>
                        <xsl:value-of select="concat('Catalogus: ',@name)"/>
                    </title>
                    <script class="remove">
                        var respecConfig = {{
                            specStatus: "ED",
                            editors: [{{
                                name: "{imf:get-xparm('cli/userid')}, {imf:get-xparm('cli/owner')}",
                                url: "http://your.site/",
                            }}],
                            edDraftURI: "http://some.place",
                            shortName: "msgdoc",
                            maxTocLevel: 4
                        }};
                    </script>
                    <script src="{$owner-respec-config-url}" class="remove"/>
                    <style type="text/css">
                        /* none additional yet */
                    </style>
                </head>
                <body>
                    <section id="abstract">
                        <p>
                            Samenvatting ...HIER INVOEGEN
                        </p>
                    </section>
                    <section id="sotd">
                        <p>
                            Status van dit document ...HIER INVOEGEN
                        </p>
                    </section>
                    <section id="prologue" class="informative" level="1">
                        <h1>Proloog</h1>
                        <p>
                            Introductie ...HIER INVOEGEN
                        </p>
                    </section>
                    <xsl:apply-templates select="chapter"/><!-- calls upon the standard template for chapters such as CAT and REF -->
                    <section id="epilogue" class="informative" level="1">
                        <h1>Epiloog</h1>
                        <p>
                            Laaste opmerkingen ...HIER INVOEGEN
                        </p>
                    </section>
                </body>
            </html>
        </html>
    </xsl:template>
    
   
</xsl:stylesheet>