<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:file="http://expath.org/ns/file"
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    xmlns:x="http://www.w3.org/2005/xpath-functions"
    xmlns:req="http://www.armatiek.com/xslweb/request"
    xmlns:webapp="http://www.armatiek.com/xslweb/functions/webapp"
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    
    expand-text="yes">
    
    <!-- 
        omzetten van het xhtml formaat dat uit XHTML van pandoc wordt onttrokken naar RESPEC formaat
    -->
    
    <xsl:import href="../common/common.xsl"/>
    <xsl:import href="../common/xhtml.xsl"/>
    <xsl:import href="../common/pack-xml-clean.xsl"/>
    
    <xsl:import href="pack-process-catalog.xsl"/>

    <xsl:output method="xml" indent="no"/>
    
    <xsl:variable name="title" select="/document/title"/>
    <xsl:variable name="subtitle" select="/document/subtitle"/>
    
    <xsl:variable name="props" select="webapp:get-attribute('props')" as="element(prop)*"/>
    
    <xsl:variable name="insert-cat-by-data-include" select="false()"/><!-- TODO instelbaar? -->
    
    <xsl:variable name="master-docx" select="/document/@name" as="xs:string"/>
    
    <xsl:template match="/">
   
        <xsl:sequence select="local:log('section: Create Respec',/)"/>
        <xsl:sequence select="local:log('$props',$props)"/>
        
        <xsl:variable name="respec-result" as="element(html)">
            <xsl:variable name="document-config" select="local:compact(local:get-prop('Document config'))"/> 

            <html lang="nl" dir="ltr"><!-- TODO afhankelijk van de echte taal. let op, Respec leest dit @lang uit! -->
                <head>
                    <title>
                        <xsl:value-of select="$title"/>
                    </title>
                    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
                    <script class='remove'>
                        <xsl:variable name="respec-profile" select="local:file-list($module-work-folder-path || '/profile', false(), 'respec-*.js')"/><!-- bijv. 'respec-waarderingskamer.js' -->
                        <xsl:choose>
                            <xsl:when test="exists($respec-profile)">
                                <xsl:attribute name="src">profile/{$respec-profile}</xsl:attribute>
                                <info>Gebruik het lokale profiel: {$respec-profile}</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='w3c'">
                                <xsl:attribute name="src">https://armatiek.nl/respec-profiles/w3c/profile/respec-w3c-common.js</xsl:attribute><!-- common is verouderd maar voldoet. zie https://github.com/w3c/respec/wiki/respec-w3c-common-migration-guide
                                 -->
                                <info>Gebruik het W3C profiel</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='geonovum'">
                                <xsl:attribute name="src">https://tools.geostandaarden.nl/respec/builds/respec-geonovum.js</xsl:attribute>
                                <info>Gebruik het Geonovum profiel</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='armatiek'">
                                <xsl:attribute name="src">https://armatiek.nl/respec-profiles/armatiek/profile/respec-armatiek.js</xsl:attribute>
                                <info>Gebruik het Armatiek profiel</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='mimcommunity'">
                                <xsl:attribute name="src">https://armatiek.nl/respec-profiles/mimcommunity/profile/respec-mimcommunity.js</xsl:attribute>
                                <info>Gebruik het MIM Community profiel</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='waarderingskamer'">
                                <xsl:attribute name="src">profile/respec-waarderingskamer.js</xsl:attribute>
                                <info>Gebruik het Waarderingskamer profiel</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='kadaster'">
                                <xsl:attribute name="src">profile/respec-kadaster.js</xsl:attribute>
                                <info>Gebruik het Kadaster profiel</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='bij12'">
                                <xsl:attribute name="src">profile/respec-bij12.js</xsl:attribute>
                                <info>Gebruik het Bij12 profiel</info>
                            </xsl:when>
                            <xsl:when test="$document-config ='eigenaar'">
                                <xsl:attribute name="src">profile/respec-eigenaar.js</xsl:attribute>
                                <info>Gebruik het EIGENAAR profiel</info>
                            </xsl:when>
                            <xsl:when test="not(normalize-space($document-config))">
                                <error loc="{$msword-file-subpath}">Geen veld met naam "Document config" opgegeven</error>
                            </xsl:when>
                            <xsl:otherwise>
                                <error loc="{$msword-file-subpath}">Geen bekende waarde voor "Document config" veld:: <xsl:value-of select="$document-config"/></error>
                            </xsl:otherwise>
                        </xsl:choose>
                    </script>
                    <script class='remove'>
                        <xsl:variable name="tree" as="element(x:map)*">
                            <x:map>
                                <x:string key='specStatus'>
                                    <xsl:value-of select="local:get-prop(('Spec status','Document status'))"/>
                                </x:string>
                                <x:string key='specType'>
                                    <xsl:value-of select="local:get-prop(('Spec type','Document type'))"/>
                                </x:string>
                                <x:array key='editors'>
                                    <xsl:for-each select="local:get-prop('Editor',true())">
                                        <x:map>
                                            <x:string key="name">
                                                <xsl:value-of select="prop[@key = 'Name']"/>
                                            </x:string>
                                            <x:string key="url">
                                                <xsl:value-of select="prop[@key = 'URL']"/>
                                            </x:string>
                                        </x:map> 
                                    </xsl:for-each>
                                </x:array>    
                                <x:string key='edDraftURI'>
                                    <xsl:value-of select="local:get-prop('Draft URI')"/>
                                </x:string>
                                <x:string key='latestVersion'>
                                    <xsl:value-of select="local:get-prop('Latest publish URI')"/>
                                </x:string>
                                <x:string key='prevED'>
                                    <xsl:value-of select="local:get-prop('Previous publish URI')"/>
                                </x:string>
                                <x:string key='prevRecURI'>
                                    <xsl:value-of select="local:get-prop('Previous publish URI')"/>
                                </x:string>
                                <x:string key='shortName'>
                                    <xsl:value-of select="local:get-prop('Short name')"/>
                                </x:string>
                                <x:string key='addSectionLinks'>
                                    <xsl:value-of select="local:respec-boolean(local:get-prop('Section links'))"/>
                                </x:string>
                                <x:string key='maxTocLevel'>
                                    <xsl:value-of select="local:get-prop('TOC levels')"/>
                                </x:string>
                                <x:string key='license'>
                                    <xsl:value-of select="local:get-prop('License')"/>
                                </x:string>
                                <x:string key='subtitle'>
                                    <xsl:value-of select="$subtitle"/>
                                </x:string>
                                <x:string key='lint'>
                                    <xsl:value-of select="local:respec-boolean(local:get-prop('Lint'))"/><!-- https://respec.org/docs/#lint -->
                                </x:string>
                                <x:string key='pubDomain'>
                                    <xsl:value-of select="local:get-prop(('Publication domain','Document store'))"/>
                                </x:string>
                                
                                <!-- als deze datums zijn  opgegeven worden de URI's opgebouwd conform de vaste opzet bijv. https://docs.geostandaarden.nl/cvgg/def-im-img-20221025/ -->
                                <x:string key='modificationDate'>
                                    <xsl:value-of select="local:get-prop(('Modification date'))"/>
                                </x:string>
                                <x:string key='previousPublishDate'>
                                    <xsl:value-of select="local:get-prop(('Previous publish date'))"/><!-- https://respec.org/docs/#previousPublishDate -->
                                </x:string>
                                <x:string key='publishDate'>
                                    <xsl:value-of select="local:get-prop(('Date','Publish date'))"/>
                                </x:string>
                                
                            </x:map>
                        </xsl:variable>
                        var respecConfig = <xsl:sequence select="xml-to-json($tree)"/>;
                    </script>
                         <!--
                            e.g. 
                            var respecConfig = {
                                specStatus: "ED",
                                editors: [{
                                    name: "Arjan Loeffen, Armatiek BV",
                                    url: "http://www.armatiek.nl/",
                                }],
                                edDraftURI: "http://some.github.repo",
                                shortName: "testdoc"
                            };
                        -->
                    
                    <?x
                    <link rel="stylesheet" href="lib/hljs/default.min.css"/>
                    <script src="lib/hljs/highlight.min.js"/>
                    <script>hljs.initHighlightingOnLoad();</script>
                    x?>
                    
                    <?x
                    <xsl:for-each select="local:file-list($module-work-folder-path || '/web/css',false(),'*.css')">
                        <link rel="stylesheet" type="text/css" href="web/css/{.}" />
                    </xsl:for-each>
                    x?>
                    <link rel="stylesheet" type="text/css" href="web/css/default-documentor.css" />
                    <link rel="stylesheet" type="text/css" href="web/css/klant-documentor.css" />
                    
                    <?x
                    <xsl:for-each select="local:file-list($module-work-folder-path || '/web/js',false(),'*.js')">
                        <script src="web/js/{.}" />
                    </xsl:for-each>
                    x?>
                    <script src="web/js/default-documentor.js" />
                    <script src="web/js/klant-documentor.js" />
                    
                    <xsl:if test="local:boolean(local:get-prop('Hypothesis'))">
                        <script type="text/javascript" xsl:expand-text="no"><![CDATA[
                            var suppressHypothesis = false;
                            var query = window.location.search.substring(1);
                            var vars = query.split('&');
                            for (var i=0; i<vars.length; i++) {
                                var pair = vars[i].split('=');
                                if (decodeURIComponent(pair[0]).toLowerCase() == 'suppresshypothesis' && decodeURIComponent(pair[1]) == 'true') {
                                    suppressHypothesis = true;
                                    break;
                                }
                            }
                            if (!suppressHypothesis) {
                                document.write(unescape('%3Cscript src="https://hypothes.is/embed.js" async %3E%3C/script%3E'));
                            }
                        ]]></script>
                    </xsl:if>
                    
                </head>
                <body>
                    <xsl:variable name="errors" select="//error"/>
                    <xsl:if test="$errors">
                        <section type="documentor-messages">
                            <h1>Documentor rapport</h1>
                            <p>Documentor heeft {count($errors)} fout(en) aangetroffen.</p>
                            <div>
                                <table>
                                    <xsl:for-each select="$errors">
                                        <tr>
                                            <td>{@loc}</td>
                                            <td>{.}</td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                                <p>Zoek hieronder naar:</p>
                                <div class="FOUT"><span>FOUT!</span> Melding</div>
                                <p>Verwerkt op <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01] om [H01]:[m01]:[s01]')"/></p>
                            </div>
                        </section>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="not($document-config)">
                            <section type="documentor-messages">
                                <h1>Documentor moet stoppen</h1>
                                <p>Configuratie incompleet. Heeft jouw start-document bovenin een voldoende complete tabel met eigenschappen?</p>
                                <p>Het start-document is {$master-docx}.</p>
                                <p>Eigenschappen voor zover bekend:</p>
                                <table>
                                    <xsl:for-each select="$props">
                                        <tr><td>{@key}</td><td>{.}</td></tr>
                                    </xsl:for-each>                            
                                </table>
                            </section>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="/document/(error|info|page)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </body>
            </html>
        </xsl:variable>        
        <xsl:variable name="resolved" select="local:respec-resolve($respec-result)"/>
        
        <xsl:sequence select="$resolved"/>
      
    </xsl:template>    
   
    <xsl:template match="document">
        <xsl:apply-templates/> 
    </xsl:template>
    
    <xsl:template match="page">
        <section>
            <xsl:apply-templates select="node()|@*"/> 
        </section>
    </xsl:template>
    
    <xsl:template match="page[@metadata-type = 'catalog-wrapper']">
        <xsl:apply-templates select=".//include-catalog"/> 
    </xsl:template>
    
    <xsl:template match="title">
        <xsl:choose>
            <xsl:when test="../@id = ('sotd','abstract')">
                <!-- remove; is inserted by respec -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{ 'h' || count(ancestor::page)}">
                    <xsl:apply-templates select="node()|@*"/> 
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="extension">
        <xsl:choose>
            <xsl:when test="@key = 'includerespec'">
                <!-- the document specified is not read but referenced using standard respec syntax. pass on this pass as found. -->
                <div data-include='{@val}' data-include-replace="true"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- deze extensie kan worden herkend door een speciale mode, dus niet signalleren -->
                <xsl:next-match/>
            </xsl:otherwise> 
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="code[@metadata-role = 'example']" priority="1">
        <aside class="example">
            <pre class="{if (@type) then @type else 'nohighlight'}">
                <xsl:apply-templates/>          
            </pre>
        </aside>
    </xsl:template>
    
    <xsl:template match="code">
        <pre class="{if (@type) then @type else 'nohighlight'}">
            <xsl:apply-templates/>   <!-- dit zijn line elementen -->       
        </pre>
    </xsl:template>
    
    <xsl:template match="codechar">
        <code class="nohighlight">
            <xsl:apply-templates/>          
        </code>
    </xsl:template>
   
    <xsl:template match="note">
        <span class="local_note">
            <xsl:attribute name="title">
                <xsl:apply-templates/>
            </xsl:attribute>
            <xsl:value-of select="'[' || (count(preceding::note) + 1) || ']'"/>
        </span>
    </xsl:template>
    
    <xsl:template match="a[starts-with(@href,'http://#')]">
        <a href="#{substring-after(@href,'http://#')}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <!-- overrides import -->

    <xsl:template match="span[@data-custom-style = 'abbrevchar']">
        <xsl:variable name="text" select="local:get-abbr(.)"/>
        <xsl:if test="not(normalize-space($text))">
            <span class="TODO">ABBREV? </span>
        </xsl:if>
        <abbr title="{$text}">
            <xsl:apply-templates/>
        </abbr>    
    </xsl:template>
    
    <xsl:template match="outline">
        <!-- skip info -->
    </xsl:template>
    
    <!-- TODO include catalog kan een parameter waarde hebben. Nu nog even "all" maar wordt "model" en "lists" -->
    <xsl:template match="include-catalog">
        <xsl:variable name="xhtml-catalog-file-name" select="local:file-list($imvertor-cat-path,false(),'*.'|| $module || '.catalog.xhtml')"/>
        <xsl:variable name="html-catalog-file-name" select="local:file-list($imvertor-cat-path,false(),'*.'|| $module || '.html')"/>
        <xsl:variable name="catalog-file-name" select="($xhtml-catalog-file-name,$html-catalog-file-name)[1]"/>
        <xsl:sequence select="local:log('catalog file path',$imvertor-cat-path || '/' || $catalog-file-name)"/>
        
        <xsl:choose>
            <xsl:when test="not(file:exists($imvertor-cat-path))">
                <error loc="{$msword-file-subpath}">Geen Imvertor applicatie folder aangetroffen</error>
            </xsl:when>
            <xsl:when test="empty($catalog-file-name)">
                <error loc="{$msword-file-subpath}">Geen catalogus aangetroffen</error>
            </xsl:when>
            <xsl:when test="$insert-cat-by-data-include">
                <info>Catalogus ingelinkt: {$catalog-file-name}</info>
                <div data-include="{$catalog-file-name}" data-include-replace="true"/>
            </xsl:when>
            <xsl:otherwise>
                <info>Catalogus ingevoegd: {$catalog-file-name}</info>
                <xsl:apply-templates select="pack:xml-clean(pack:process-catalog($imvertor-cat-path || '/' || $catalog-file-name)/*:html/*:body/*)"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:analyze-string select="." regex="TODO">
            <xsl:matching-substring>
                <span class="TODO">TODO</span>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:function name="local:get-abbr" as="xs:string">
        <xsl:param name="key"/>
        <xsl:value-of select="local:get-prop('Abbreviations')/prop[@key = $key]"/><!-- een property in een property -->
    </xsl:function>
    
    <xsl:function name="local:boolean" as="xs:boolean">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:sequence select="lower-case(normalize-space($value)) = ('ja', 'yes', 'true', '1')"/>
    </xsl:function>
    
    <xsl:function name="local:respec-boolean" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="local:boolean($value)">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:get-prop" as="item()*">
        <xsl:param name="key" as="xs:string*"/>
        <xsl:sequence select="local:get-prop($key,false())"/>
    </xsl:function>
    
    <xsl:function name="local:get-prop" as="item()*">
        <xsl:param name="key" as="xs:string*"/>
        <xsl:param name="get-all" as="xs:boolean"/>
        <xsl:sequence select="if ($get-all) then $props[@key = $key] else $props[@key = $key][last()]"/>
    </xsl:function>
    
    <!-- 
       Resolve errors and such.
     -->
    <xsl:function name="local:respec-resolve" as="element(html)">
        <xsl:param name="doc" as="element(html)"/>
        <xsl:variable name="resolved" as="element(html)">
            <xsl:apply-templates select="$doc" mode="local:respec-resolve"/>
        </xsl:variable>
        <xsl:sequence select="$resolved"/>
    </xsl:function>
    
    <xsl:template match="error" mode="local:respec-resolve">
        <xsl:sequence select="local:log('error: resolved',node())"/>
        <div class="FOUT">
            <span>FOUT!</span>
            <xsl:text> {.}</xsl:text>
        </div>
    </xsl:template>
  
    <xsl:template match="info" mode="local:respec-resolve">
        <!-- TODO iets doen met deze info, maar NIET doorsturen naar respec resultaat -->
        <xsl:sequence select="local:log('info: resolved',node())"/>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="local:respec-resolve">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>