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
    
    <xsl:variable name="respec-config-filename" select="$configuration-docrules-file/respec-config"/>

    <xsl:variable name="image-zoomer" select="$configuration-docrules-file/image-zoomer"/>
    
    <xsl:function name="pack:complete-respec" as="item()*">
        <xsl:param name="book" as="item()*"/>
        <xsl:apply-templates select="$book" mode="pack:complete-respec"/>
        
    </xsl:function>
    
    <xsl:template match="book" mode="pack:complete-respec">
        <html lang="{$language}">
            <head>
                <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
                <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
                
                <!-- verplicht: inrichten op iedere owner. Definieert organisationConfig. -->
                <script src="documentor/js/owner.js" class="remove"/>
                
                <!-- samenstellen op basis van MsWord properties table. Let op: veel props zijn gedefinieerd in de owner.js -->
                
                <xsl:variable name="respec-parms" as="element(parms)">
                    <parms>
                        
                        <parm respec-name="specStatus" parms-name="prop-publicatiestatus">{if (imf:get-xparm('appinfo/phase') eq '3') then 'IG' else 'IO'}</parm>
                        <parm respec-name="specType" parms-name="prop-publicatietype">{
                            (
                                imf:get-xparm('documentor/prop-documenttype',()),
                                if (imf:boolean(imf:get-xparm('documentor/catalog-included'))) then 'IM' else 'base'
                            )[1]
                        }</parm>
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
                        <parm respec-name="module" parms-name="prop-module"/>
                        
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
                
                <xsl:if test="imf:boolean(imf:get-xparm('documentor/prop-hypothesis'))">
                    <script><![CDATA[
                            var suppressHypothesis = false;
                            var query = window.location.search.substring(1);
                            var vars = query.split('&');
                            for (var i=0; i<vars.length; i++) {{
                                var pair = vars[i].split('=');
                                if (decodeURIComponent(pair[0]).toLowerCase() == 'suppresshypothesis' && decodeURIComponent(pair[1]) == 'true') {{
                                    suppressHypothesis = true;
                                    break;
                                }}
                            }}
                            if (!suppressHypothesis)
                                document.write(unescape('%3Cscript src="https://hypothes.is/embed.js" async %3E%3C/script%3E'));
                        ]]></script>
                </xsl:if>
                
                <!-- 
                    De volgende javascript is de complete Respec, in lijn met nationale regels (Logius).
                -->
                <script src="documentor/js/{$respec-config-filename}.js" class="remove" async="async"/>
                
                <!-- panzoom images? -->
                <xsl:choose>
                    <xsl:when test="$image-zoomer = 'image-pan-zoom'">
                        <script src='https://unpkg.com/panzoom@9.4.0/dist/panzoom.min.js'/> <!-- https://github.com/anvaka/panzoom -->
                    </xsl:when>
                    <!-- andere diagram weergaves? -->
                </xsl:choose>
                
                <title>{imf:get-xparm('documentor/prop-titel')}</title>
                
                <!-- logo van de organisatie opnemen -->
                <link href="documentor/img/logo.ico" rel="shortcut icon" type="image/x-icon" />
                
                <!-- 
                    De volgende javascript is een toevoeging aan de respec config van owner en dit model.
                    Deze mag bestaande javascript constructies NIET overschrijven.
                    NB Default is onttrokken aan owner = Imvertor
                -->
                <script src="documentor/js/default.js" class="remove" async="async"/>
                <script src="documentor/js/local.js" class="remove" async="async"/>
                
                <!-- 
                    De volgende style is een toevoeging aan de base.css van Logius.
                    Deze mag bestaande CSS constructies overschrijven.
                    NB Default is onttrokken aan owner = Imvertor
                -->
                <link href="documentor/css/default.css" rel="stylesheet" />
                <link href="documentor/css/local.css" rel="stylesheet" />
            </head>
            
            <body>
                <xsl:sequence select="imf:document(imf:get-xparm('properties/IMVERTOR_DOCUMENTOR_XHTMLTORESPEC_FILE'))/document/section"/>
            </body>
        </html>
    </xsl:template>
    
    <!--
         Voorbeeld:
         Naam:Jansen[sep1]Instelling:RIVM[sep1]URL:https://www.rivm.nl[sep2]Naam:Pietersen[sep1]Instelling:RDW[sep1]URL:https://www.rdw.nl
    -->
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
                    <xsl:when test="$norm-key = 'e-mail'">mailto: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'opmerking'">note: "{$found-value}"</xsl:when>
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
    
</xsl:stylesheet>