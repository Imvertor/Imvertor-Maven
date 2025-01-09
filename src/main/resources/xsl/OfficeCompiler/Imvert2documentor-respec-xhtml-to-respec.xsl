<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
   
    xmlns:x="http://www.w3.org/2005/xpath-functions"
    xmlns:pack="http://www.armatiek.nl/functions/pack"
   
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
   
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2documentor-common.xsl"/>
    
    <!-- 
        omzetten van het xhtml formaat dat uit XHTML van pandoc wordt onttrokken naar RESPEC formaat
    -->
    
    <xsl:import href="Imvert2documentor-common-xhtml.xsl"/>
    <xsl:import href="Imvert2documentor-common-pack-xml-clean.xsl"/>
    <xsl:import href="Imvert2documentor-respec-pack-process-catalog.xsl"/>

    <xsl:output method="xml" indent="no"/>
    
    <xsl:variable name="insert-cat-by-data-include" select="false()"/><!-- TODO instelbaar? -->
    
    <xsl:variable name="master-docx" select="/document/@name" as="xs:string"/>
   
    <xsl:variable name="abbreviations" as="element(abbr)*">
        <xsl:variable name="abbrs" select="//define-abbreviation"/>
        <xsl:variable name="dups" as="element(abbr)*">
            <xsl:for-each select="$abbrs">
                <xsl:analyze-string select="." regex="^(.*?):(.*?)$">
                    <xsl:matching-substring>
                        <abbr title="{normalize-space(regex-group(2))}">{normalize-space(regex-group(1))}</abbr>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each-group select="$dups" group-by=".">
            <xsl:sequence select="current-group()[last()]"/>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="regex-timezonef">(Z?)(\+\d\d:\d\d)</xsl:variable>
    <xsl:variable name="regex-datef">\d\d\d\d-\d\d-\d\d</xsl:variable>
    <xsl:variable name="regex-timef">\d\d:\d\d:\d\d\.\d+</xsl:variable>
    <xsl:variable name="regex-date">^{$regex-datef}({$regex-timezonef})?$</xsl:variable>
    <xsl:variable name="regex-dateTime">^{$regex-datef}T{$regex-timef}({$regex-timezonef})?$</xsl:variable>
    
    <xsl:template match="/document">
   
        <xsl:sequence select="local:log('section: Create Respec',/)"/>
        <xsl:sequence select="local:log('$abbreviations',$abbreviations)"/>
        
        <!-- geef via deze documentor property aan java proces door waar het respec-config file is geplaatst -->
        <xsl:sequence select="imf:set-xparm('documentor/respec-config',$configuration-docrules-file/respec-config)"/>
        <!-- 
            zet de waarde van documentor/image-zoomer etc. op basis van huidige config 
            Deze worden uitgelezen in het java proces zodat de js/css kan worden gekopieerd
        -->
        <xsl:sequence select="imf:set-xparm('documentor/image-zoomer',$configuration-docrules-file/image-zoomer)"/>
        <xsl:sequence select="imf:set-xparm('documentor/diagram-zoomer',$configuration-docrules-file/diagram-zoomer)"/>
        
        <xsl:sequence select="imf:set-xparm('documentor/prop-titel',./title)"/>
        <xsl:sequence select="imf:set-xparm('documentor/prop-subtitel',./subtitle)"/>
        
        <xsl:sequence select="imf:set-xparm('appinfo/current-date',current-date())"/>
        <xsl:sequence select="imf:set-xparm('appinfo/current-datetime',current-dateTime())"/>
        
        <xsl:variable name="respec-result" as="element()*">

            <document>
                <xsl:copy-of select="@*"/>
                <xsl:copy-of select="stage"/>
                <stage>xhtml-to-respec</stage>
                
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
                <?x
                <xsl:choose>
                    <xsl:when test="not($document-config)">
                        <section type="documentor-messages">
                            <h1>Documentor moet stoppen</h1>
                            <p>Configuratie incompleet. Heeft jouw start-document bovenin een voldoende complete tabel met eigenschappen?</p>
                            <p>Het start-document is {$master-docx}.</p>
                            
                            <p>Eigenschappen voor zover bekend:</p>
                            <table>
                                <!-- lees de props uit vanuit parms.xml -->
                                <xsl:variable name="parms" select="imf:document(imf:get-xparm('system/work-folder-path') || '/parms.xml')"/>
                                <xsl:for-each select="$parms/config/documentor/*">
                                    <xsl:if test="starts-with(local-name(.),'prop-')">
                                        <tr><td>{substring-after(local-name(.),'prop-')}</td><td>{.}</td></tr>
                                    </xsl:if>
                                </xsl:for-each>                            
                            </table>
                        </section>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="/document/(error|info|page)"/>
                    </xsl:otherwise>
                </xsl:choose>
                x?>
                <xsl:apply-templates select="/document/(error|info|page)"/>
            </document>    
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
    
    <xsl:template match="a">
        <xsl:choose>
            <xsl:when test="starts-with(@href,'http://#')">
                <a href="#{substring-after(@href,'http://#')}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:when test="starts-with(@href,'include/download/')">
                <xsl:variable name="filename" select="tokenize(@href,'/')[last()]"/>
                <a href="inc/{$filename}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
            
    </xsl:template>
    
    <!-- overrides import -->

    <xsl:template match="span[@data-custom-style = 'abbrevchar']">
        <xsl:variable name="abbr" select="$abbreviations[. = normalize-space(current())]"/>
        <xsl:if test="empty($abbr)">
            <span class="TODO">ABBREV? {.}</span>
            <xsl:sequence select="imf:msg('WARNING','Abbreviation [1] cannot be resolved',.)"/>
        </xsl:if>
        <xsl:sequence select="$abbr"/>    
    </xsl:template>
    
    <xsl:template match="outline">
        <!-- skip info -->
    </xsl:template>
    
    <!-- TODO include catalog kan een parameter waarde hebben. Nu nog even "all" maar wordt "model" en "lists" -->
    <xsl:template match="include-catalog">
        <xsl:variable name="catalog-file-name" select="imf:get-xparm('system/officename-resolved') || '.respec.catalog.xhtml'"/>
        <xsl:variable name="imvertor-catalog-path" select="imf:get-xparm('system/work-app-folder-path') || '/cat/' || $catalog-file-name"/>
        <xsl:choose>
            <xsl:when test="$insert-cat-by-data-include">
                <info>Catalogus ingelinkt: {$catalog-file-name}</info>
                <div data-include="{$catalog-file-name}" data-include-replace="true"/>
            </xsl:when>
            <xsl:otherwise>
                <info>Catalogus ingevoegd: {$catalog-file-name}</info>
                <xsl:apply-templates select="pack:xml-clean(pack:process-catalog($imvertor-catalog-path)/html/body/*)"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- onthoud dat een catalogus is opgevraag, en dat het dus een informatiemodel betreft -->
        <xsl:sequence select="imf:set-xparm('documentor/catalog-included','true')"/>
    </xsl:template>
    
    <xsl:template match="include-overview">
        <xsl:choose>
            <xsl:when test=". = 'figures'">
                <section id="tof"/>
            </xsl:when>
            <xsl:when test=". = 'references'">
                <xsl:sequence select="imf:msg('WARNING','Include overview type [1] not yet supported',.)"/>
            </xsl:when>
            <xsl:when test=". = 'abbreviations'">
                <section id="abbrevs">
                    <h2>Lijst met afkortingen</h2>
                    <ul class="abbrevs">
                        <xsl:for-each select="$abbreviations">
                            <xsl:sort select="."/>
                            <li class="abbrevsline"><abbr class="exclude">{.}</abbr> {@title}</li>
                        </xsl:for-each>
                    </ul>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('WARNING','Include overview type [1] not supported',.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="include-xparm">
        <xsl:variable name="key" select="."/>
        
        <xsl:variable name="parm" select="imf:extract(if (contains($key,'/')) then $key else 'appinfo/' || $key,'[a-z0-9\-/]')"/>
        <xsl:variable name="val" select="imf:get-xparm($parm,())"/>
        <xsl:variable name="norm-val" as="xs:string">
            <xsl:try>
                <xsl:choose>
                    <xsl:when test="matches($val,$regex-dateTime)">
                        <xsl:value-of select="format-dateTime(xs:dateTime($val), '[Y0001]-[M01]-[D01] om [H01]:[m01]:[s01]')"/>
                    </xsl:when>
                    <xsl:when test="matches($val,$regex-date)">
                        <xsl:value-of select="format-date(xs:date($val), '[Y0001]-[M01]-[D01]')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$val"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:catch>
                    <xsl:value-of select="$val"/>
                </xsl:catch>
            </xsl:try>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$val">
                <span class="xparm">{$norm-val}</span>                        
            </xsl:when>
            <xsl:otherwise>
                <span class="TODO">XPARM? {$key}</span>
                <xsl:sequence select="imf:msg('WARNING','Xparm [1] has no value or is unknown',$parm)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="define-abbreviation">
        <!-- verwijder -->
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
    
    <?x
    <xsl:function name="local:get-prop" as="item()*">
        <xsl:param name="key" as="xs:string*"/>
        <xsl:sequence select="local:get-prop($key,false())"/>
    </xsl:function>
    
    <xsl:function name="local:get-prop" as="item()*">
        <xsl:param name="key" as="xs:string*"/>
        <xsl:param name="get-all" as="xs:boolean"/>
        <xsl:variable name="prop" select="imf:get-xparm('documentor/prop-' || local:compact($key))"/>
        <xsl:sequence select="if ($get-all) then $prop else $prop[last()]"/>
    </xsl:function>
    x?>
    
    <!-- 
       Resolve errors and such.
     -->
    <xsl:function name="local:respec-resolve" as="element(document)">
        <xsl:param name="doc" as="element(document)"/>
        <xsl:variable name="resolved" as="element(document)">
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