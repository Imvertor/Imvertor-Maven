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
                <html lang="{$language}">
                    <head>
                        <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
                        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
                        
                        <!-- verplicht: inrichten op iedere owner. Definieert organisationConfig. -->
                        <script src="documentor/js/owner.js" class="remove"/>
                        
                        <!-- TODO verplicht: samenstellen op basis van MsWord properties table. Let op: veel props zijn gedefinieerd in de owner.js -->
                        
                        <xsl:variable name="respec-parms" as="element(parms)">
                            <parms>
                                
                                <parm respec-name="specStatus" parms-name="prop-publicatiestatus">{if (imf:get-xparm('appinfo/phase') ne '3') then 'IG' else 'IO'}</parm>
                                <parm respec-name="specType" parms-name="prop-publicatietype">{if (imf:boolean(imf:get-xparm('documentor/catalog-included'))) then 'IM' else 'RP'}</parm>
                                <parm respec-name="subtitle" parms-name="prop-subtitel"/>
                                <parm respec-name="edDraftURI" parms-name="prop-concepturi" type="uri"/>
                                <parm respec-name="shortName" parms-name="prop-kortenaam">{imf:get-xparm('appinfo/model-abbreviation',())}</parm>
                                <parm respec-name="publishVersion" parms-name="prop-publicatieversie">{imf:get-xparm('appinfo/version',())}</parm>
                                <parm respec-name="publishDate" parms-name="prop-publicatiedatum" type="date">{imf:get-xparm('run/start',())}</parm>
                                <parm respec-name="previousPublishVersion" parms-name="prop-vorigepublicatieversie"/>
                                <parm respec-name="previousPublishDate" parms-name="prop-vorigepublicatiedatum" type="date"/>
                                <parm respec-name="addSectionLinks" parms-name="prop-voegsectielinkstoe" type="boolean">true</parm>
                                <parm respec-name="latestVersion" parms-name="prop-meestrecenteversie"/>
                                <parm respec-name="prevED" parms-name="prop-TODOprevED"/>
                                <parm respec-name="prevRecURI" parms-name="prop-TODOprevRecURI" type="uri"/>
                                <parm respec-name="maxTocLevel" parms-name="prop-inhoudsopgaveniveaus" type="integer">4</parm>
                                <parm respec-name="license" parms-name="prop-licentie"/>
                                <parm respec-name="lint" parms-name="prop-lint" type="boolean"/>
                                <parm respec-name="pubDomain" parms-name="prop-publicatiedomein"/>
                                <parm respec-name="modificationDate" parms-name="prop-aanpassingsdatum" type="date"/>
                                <parm respec-name="isPreview" parms-name="prop-ispreview" type="boolean"/>
                                <parm respec-name="prevED" parms-name="prop-vorigconcept" type="uri"/>
                                
                                <!-- gestuctureerde info apart afhandelen -->
                                <parm respec-name="github" parms-name="prop-github" type="github"/>
                                <parm respec-name="abbrevs" parms-name="prop-afkortingen" type="abbrev"/> <!--TODO is niet meer onderdeel van logius -->
                                
                                <!-- lijsten speciaal afhandelen -->
                                <parm respec-name="authors" parms-name="prop-auteur-list" type="person-list"/>
                                <parm respec-name="editors" parms-name="prop-redacteur-list" type="person-list"/>
                                <parm respec-name="formerEditors" parms-name="prop-vorigeredacteur-list" type="person-list"/>
                                <parm respec-name="logos" parms-name="prop-logo-list" type="logo-list"/>
                                <parm respec-name="alternateFormats" parms-name="prop-alternatiefformaat-list" type="formats-list"/>
                                
                            </parms>
                        </xsl:variable>
                            
                        <xsl:variable name="respec-config" as="xs:string*">
                            <xsl:for-each select="$respec-parms/parm">
                                <xsl:variable name="specified" select="imf:get-xparm('documentor/' || @parms-name,())"/>
                                <xsl:variable name="default" select="node()"/>
                                <xsl:variable name="value" select="($specified,$default)[1]"/>
                                <xsl:if test="$value">
                                    <xsl:choose>
                                        <xsl:when test="@type = 'date'">
                                            <xsl:text>{@respec-name} : "{$value}",&#10;</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@type = 'integer'">
                                            <xsl:text>{@respec-name} : {$value},&#10;</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@type = 'uri'">
                                            <xsl:text>{@respec-name} : "{$value}",&#10;</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@type = 'boolean'">
                                            <xsl:text>{@respec-name} : {if (imf:boolean($value)) then 'true' else 'false'},&#10;</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@type = 'github'">
                                            <xsl:sequence select="imf:respec-config-lines(@respec-name,$specified,true())"/>
                                        </xsl:when>
                                        <xsl:when test="@type = 'logo'">
                                            <xsl:sequence select="imf:respec-config-lines(@respec-name,$specified,true())"/>
                                        </xsl:when>
                                        <xsl:when test="@type = 'abbrev'">
                                            <xsl:sequence select="imf:respec-config-lines(@respec-name,$specified,false())"/>
                                        </xsl:when>
                                        <xsl:when test="@type = 'person-list'">
                                            <xsl:sequence select="imf:respec-config-list(@respec-name,$specified)"/>
                                        </xsl:when>
                                        <xsl:when test="@type = 'logo-list'">
                                            <xsl:sequence select="imf:respec-config-list(@respec-name,$specified)"/><!-- TODO wat is het nut van meerdere logo's? -->
                                        </xsl:when>
                                        <xsl:when test="@type = 'formats-list'">
                                            <xsl:sequence select="imf:respec-config-list(@respec-name,$specified)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>{@respec-name} : "{$value}",&#10;</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
            
                        <script class="remove"><![CDATA[var respecConfig = {{{$respec-config}}};]]></script>
                        
                        <!-- zorg ervoor dat eerst de specs voor de hele organisatie worden geladen, en daarna die van de analist -->
                        <script class="remove"><![CDATA[ 
                            respecConfig = {{...organisationConfig, ...respecConfig}}
                        ]]></script>
                        
                        <!-- 
                            De volgende javascript is de complete Respec, in lijn met nationale regels (Logius).
                        -->
                        <script src="{$owner-respec-config-url}" class="remove" async="async"/>
                      
                        <title>{imf:get-xparm('documentor/prop-titel')}</title>
                        
                        <!-- logo van de organisatie opnemen -->
                        <link href="documentor/img/logo.ico" rel="shortcut icon" type="image/x-icon" />
                        
                        <!-- 
                            De volgende javascript is een toevoeging aan de respec config van owner en dit model.
                            Deze mag bestaande javascript constructies NIET overschrijven.
                        -->
                        <script src="documentor/js/local.js" class="remove" async="async"/>

                        <!-- 
                            De volgende style is een toevoeging aan de base.css van Logius.
                            Deze mag bestaande CSS constructies overschrijven.
                        -->
                        <link href="documentor/css/local.css" rel="stylesheet" />
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
    
    <xsl:function name="imf:respec-config-list" as="xs:string">
        <xsl:param name="respec-name" as="xs:string"/>
        <xsl:param name="specified" as="xs:string"/>
        <xsl:variable name="lines" as="xs:string*">
            <xsl:for-each select="tokenize($specified,'\[sep2\]')">
                <xsl:variable name="parts" as="xs:string*">
                    <xsl:for-each select="tokenize(.,'\[sep1\]')">
                        <xsl:sequence select="imf:respec-config-parm(.,true())"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:text>{{ {string-join($parts,',')} }}</xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:text>{$respec-name} : [ {string-join($lines,',')} ],&#10;</xsl:text>
    </xsl:function>
    <!--
         Voorbeeld:
         Naam:Jansen[sep1]Instelling:RIVM[sep1]URL:https://www.rivm.nl
    -->
    <xsl:function name="imf:respec-config-lines" as="xs:string">
        <xsl:param name="respec-name" as="xs:string"/>
        <xsl:param name="specified" as="xs:string"/>
        <xsl:param name="normalize" as="xs:boolean"/>
        <xsl:variable name="lines" as="xs:string*">
            <xsl:for-each select="tokenize($specified,'\[sep1\]')">
                <xsl:sequence select="imf:respec-config-parm(.,$normalize)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:text>{$respec-name} : {{ {string-join($lines,',')} }},&#10;</xsl:text>
    </xsl:function>
    
    <!--
        Voor een repec regel in het msword document kunnen soms getypeerde eigenschappen worden opgegeven.
        Voorbeeld:
        Naam:Jansen
        Geef de overeenkomstige Json structuur terug. 
        Geef ook aan of de key moet worden genormaliseerd (zoals dat bij afkorting dus niet het geval is).
        Let op: keys zijn doorgaans in het nederlands; hier worden ze vertaald naar Respec.
    -->
    <xsl:function name="imf:respec-config-parm" as="xs:string">
        <xsl:param name="line" as="xs:string"/>
        <xsl:param name="normalize" as="xs:boolean"/>
        <xsl:analyze-string select="$line" regex="^(.*?):(.*?)$">
            <xsl:matching-substring>
                <xsl:variable name="found-key" select="regex-group(1)"/>
                <xsl:variable name="found-value" select="replace(regex-group(2),'&quot;','\\&quot;')"/>
                <xsl:variable name="norm-key" select="if ($normalize) then lower-case(normalize-space($found-key)) else ()"/>
                <xsl:choose>
                    <xsl:when test="empty($norm-key)">"{$found-key}": "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'repository url'">repoURL: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'branch'">branch: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'naam'">name: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'instelling'">company: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'instelling url'">companyURL: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'url'">url: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'bron'">src: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'alternatief'">alt: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'breedte'">width: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'hoogte'">height: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'id'">id: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'label'">label: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'uri'">uri: "{$found-value}"</xsl:when>
                    <xsl:otherwise>"{$found-key}": "{$found-value}"</xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
                
    </xsl:function>
    
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