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
        Zie https://github.com/Logius-standaarden/respec/wiki
    -->
    
    <xsl:variable name="respec-config-filename" select="$configuration-docrules-file/respec-config"/>

    <xsl:variable name="diagram-zoomer" select="$configuration-docrules-file/diagram-zoomer"/>
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
                        
                        <parm req="1" respec-name="specStatus"             parms-name="prop-documentstatus"         property="Document status">{if (imf:get-xparm('appinfo/phase') eq '3') then 'IG' else 'IO'}</parm>
                        <parm req="1" respec-name="specType"               parms-name="prop-documenttype"           property="Document type">{if (imf:boolean(imf:get-xparm('documentor/catalog-included'))) then 'IM' else 'base'}</parm>
                        <parm req="1" respec-name="subtitle"               parms-name="prop-subtitel"               property="Subtitel"/>
                        <parm req="0" respec-name="edDraftURI"             parms-name="prop-concepturi"             property="Concept URI" type="uri"/>
                        <parm req="1" respec-name="shortName"              parms-name="prop-kortenaam"              property="Korte naam">{imf:get-xparm('appinfo/model-abbreviation',())}</parm>
                        <parm req="1" respec-name="publishVersion"         parms-name="prop-publicatieversie"       property="Publicatie versie">{imf:get-xparm('appinfo/version',())}</parm>
                        <parm req="0" respec-name="publishDate"            parms-name="prop-publicatiedatum"        property="Publicatie datum" type="date"/><!-- https://github.com/speced/respec/wiki/publishDate -->
                        <parm req="0" respec-name="previousPublishVersion" parms-name="prop-vorigepublicatieversie" property="Vorige publicatie versie"/>
                        <parm req="0" respec-name="previousPublishDate"    parms-name="prop-vorigepublicatiedatum"  property="Vorige publicatie datum" type="date"/>
                        <parm req="1" respec-name="addSectionLinks"        parms-name="prop-voegsectielinkstoe"     property="Voeg sectielinks toe" type="boolean">true</parm>
                        <parm req="0" respec-name="latestVersion"          parms-name="prop-meestrecenteversie"     property="Meest recente versie">{imf:get-xparm('documentor/prop-publicatieversie',())}</parm>
                        <parm req="0" respec-name="prevED"                 parms-name="prop-TODOprevED"             property=""/>
                        <parm req="0" respec-name="prevRecURI"             parms-name="prop-TODOprevRecURI"         property="" type="uri"/>
                        <parm req="1" respec-name="maxTocLevel"            parms-name="prop-inhoudsopgaveniveaus"   property="Inhoudsopgave niveaus" type="integer">4</parm>
                        <parm req="1" respec-name="license"                parms-name="prop-licentie"               property="Licentie"/>
                        <parm req="0" respec-name="lint"                   parms-name="prop-lint"                   property="Lint" type="boolean">Ja</parm>
                        <parm req="1" respec-name="pubDomain"              parms-name="prop-publicatiedomein"       property="Publicatie domein"/>
                        <parm req="0" respec-name="modificationDate"       parms-name="prop-aanpassingsdatum"       property="Aanpassingsdatum" type="date"/>
                        <parm req="0" respec-name="isPreview"              parms-name="prop-ispreview"              property="Is preview" type="boolean">Nee</parm>
                        <parm req="0" respec-name="prevED"                 parms-name="prop-vorigconcept"           property="Vorig concept" type="uri"/>
                        <parm req="0" respec-name="module"                 parms-name="prop-module"                 property="Module">default</parm>
                        <parm req="0" respec-name="localImvertorInfo"      parms-name="prop-toonimvertorinfo"       property="Toon imvertor info">Ja</parm>
                        
                        <!-- gestuctureerde info apart afhandelen -->
                        <parm req="0" respec-name="github"                 parms-name="prop-github"                 property="Github" type="github"/>
                        
                        <!-- lijsten speciaal afhandelen -->
                        <parm req="0" respec-name="authors"                parms-name="prop-auteur-list"            property="Auteur" type="person-list"/>
                        <parm req="1" respec-name="editors"                parms-name="prop-redacteur-list"         property="Redacteur" type="person-list"/>
                        <parm req="0" respec-name="formerEditors"          parms-name="prop-vorigeredacteur-list"   property="Vorige redacteur" type="person-list"/>
                        <parm req="0" respec-name="logos"                  parms-name="prop-logo-list"              property="Logo" type="logo-list"/>
                        <parm req="0" respec-name="alternateFormats"       parms-name="prop-alternatiefformaat-list" property="Alternatief formaat" type="formats-list"/>
                        
                    </parms>
                </xsl:variable>
                
                <xsl:variable name="respec-config" as="xs:string*">
                    <xsl:for-each select="$respec-parms/parm">
                        <xsl:variable name="specified" select="imf:reduce-space(imf:merge-parms(imf:get-xparm('documentor/' || @parms-name,())))" as="xs:string?"/>
                        <xsl:variable name="default" select="if (normalize-space(.)) then . else ()"/>
                        <xsl:variable name="value" select="($specified,$default)[1]"/>
                        
                        <xsl:variable name="required" select="@req = '1'"/>
                        
                        <!-- test of en hoe een waarde is bepaald -->
                        <xsl:choose>
                            <xsl:when test="$specified">
                                <!-- okay, opgegeven in de header tabel -->
                            </xsl:when>
                            <xsl:when test="$default and $required">
                                <!-- okay, er is een default -->
                                <xsl:sequence select="imf:msg('WARNING','No Documentor value for [1] specified, assuming: [2]', (@property,node()))"></xsl:sequence>
                            </xsl:when>
                            <xsl:when test="$required">
                                <xsl:sequence select="imf:msg('ERROR','No Documentor value for [1] specified', @property)"></xsl:sequence>
                            </xsl:when>
                        </xsl:choose>
                        
                        
                        <xsl:if test="$value">
                            <xsl:choose>
                                <xsl:when test="@type = 'date'">
                                    <xsl:variable name="date" select="imf:extract-pattern($value,'\d{4}-\d{2}-\d{2}')[1]"/>
                                    <xsl:text>{@respec-name} : "{$date}",&#10;</xsl:text>
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
                
                <title>{imf:merge-parms(imf:get-xparm('documentor/prop-titel'))}</title>
                
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
                <xsl:if test="imf:boolean(imf:get-xparm('documentor/prop-toonimvertorinfo'))">
                    <div class="topline">
                        <p>Path: {imf:get-xparm('appinfo/subpath')} at {imf:get-xparm('run/start')}, Imvertor: {imf:get-xparm('run/version')} at metamodel {imf:get-xparm('appinfo/metamodel-name-and-version')}, Module: {(imf:get-xparm('documentor/prop-module'),'default')[1]}</p>
                    </div>
                </xsl:if>
                <xsl:sequence select="imf:document(imf:get-xparm('properties/IMVERTOR_DOCUMENTOR_XHTMLTORESPEC_FILE'))/document/section"/>
            </body>
            
            <!-- zet diagram en image zoomers -->
            <xsl:choose>
                <xsl:when test="($image-zoomer,$diagram-zoomer) = 'pan-zoom-image'">
                    <link rel="stylesheet" href="documentor/leaflet/leaflet.css"/>
                    <script src="documentor/leaflet/leaflet.js"/>
                    <script src="documentor/leaflet/panZoomImage.js"/>
                    <xsl:choose>
                        <xsl:when test="$diagram-zoomer = 'pan-zoom-image'">
                            <script>panZoomImg('diagram')</script>
                        </xsl:when>
                        <xsl:when test="$image-zoomer = 'pan-zoom-image'">
                            <script>panZoomImg('image')</script>
                        </xsl:when>
                        <!-- andere diagram weergaves? -->
                    </xsl:choose>
                </xsl:when>
                <!-- andere diagram weergaves? -->
            </xsl:choose>
            
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
    <xsl:function name="imf:respec-config-parm" as="xs:string?">
        <xsl:param name="line" as="xs:string"/>
        <xsl:param name="normalize" as="xs:boolean"/>
        <xsl:analyze-string select="$line" regex="^(.*?):(.*?)$">
            <xsl:matching-substring>
                <xsl:variable name="found-key" select="regex-group(1)"/>
                <xsl:variable name="found-value" select="replace(regex-group(2),'&quot;','\\&quot;')"/>
                <xsl:variable name="norm-key" select="if ($normalize) then imf:extract(lower-case($found-key),'[a-z]') else ()"/>
                <xsl:choose>
                    <xsl:when test="empty($norm-key)">"{$found-key}": "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'repositoryurl'">repoURL: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'branch'">branch: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'naam'">name: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'instelling'">company: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'instellingurl'">companyURL: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'email'">mailto: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'opmerking'">note: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'url'">url: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'bron'">src: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'alternatief'">alt: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'breedte'">width: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'hoogte'">height: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'id'">id: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'label'">label: "{$found-value}"</xsl:when>
                    <xsl:when test="$norm-key = 'uri'">uri: "{$found-value}"</xsl:when>
                    <xsl:otherwise>"{$norm-key}": "{$found-value}"</xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:sequence select="imf:msg((),'ERROR','Invalid format for Respec header line: [1]', ($line))"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
        
    </xsl:function>
    
</xsl:stylesheet>