<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2documentor-common.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:param name="msword-file-name">unknown-file-name</xsl:param>
    
    <!-- verwerk de voorbereide XHTML en maak er een vorm van die kan worden verwerk voor meerdere kanalen. --> 
    
    <xsl:variable name="sections" select="//*:section[@metadata-id]"/>
    
    <xsl:template match="/"> <!-- een <document> -->

        <xsl:sequence select="local:log('section: file-finalize ' || $msword-file-name,/)"/>
        
        <document name="{$msword-file-name}" auto="auto">
            <xsl:comment select="current-dateTime()"/>
            <xsl:apply-templates select="/document/html/body/node()"/>
        </document>

    </xsl:template>
  
    <xsl:template match="section"><!-- deze sections worden gegenereerd in de catalogus; terugzetten naar page --> 
        <page type="{local:get-type(.)}" original-id="{@id}" metadata-id="{@metadata-id}">
            <xsl:sequence select="local:pass-metadata(.)"/>
            <xsl:apply-templates select="local:content(.)"/>
        </page>
    </xsl:template> 
    
    <xsl:template match="div[@data-custom-style = 'plaatje']">
        <xsl:variable name="imagepar" select="p[img]"/>
        <xsl:variable name="source" select="@metadata-source"/>
        <xsl:choose>
            <!-- image with location -->
            <xsl:when test="exists($imagepar) and exists($source)">
                <image src="{$source}" original-id="{@id}" metadata-id="{@metadata-id}">
                    <xsl:sequence select="local:pass-metadata(.)"/>
                    <!-- TODO test if raw is same als referenced image -->
                    <caption>
                        <xsl:apply-templates select="* except $imagepar"/>
                    </caption>
                </image>
            </xsl:when>
            <xsl:when test="exists($imagepar)">
                <image>
                    <xsl:sequence select="local:pass-metadata(.)"/>
                    <raw>
                        <xsl:value-of select="$imagepar/img/@src"/>
                    </raw>
                    <style>
                        <xsl:value-of select="$imagepar/img/@style"/>
                    </style>
                    <caption>
                        <xsl:apply-templates select="* except $imagepar"/>
                    </caption>
                </image>
            </xsl:when>
            <xsl:otherwise>
                <error loc="{$msword-file-name}">Plaatje zonder bron, in: {(preceding::title)[1]}</error>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@data-custom-style = 'programmacode']">
        <xsl:variable name="lines" as="element()*">
            <xsl:for-each select="p">
                <line>
                    <xsl:value-of select="."/>
                </line>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="format" select="@metadata-format"/>
        <xsl:choose>
            <!-- specific formatted code -->
            <xsl:when test="exists($format)">
                <code type="{$format}">
                    <xsl:sequence select="local:pass-metadata(.)"/>
                    <xsl:sequence select="$lines"/>
                </code>
            </xsl:when>
            <!-- default formatted code -->
            <xsl:otherwise>
                <code>
                    <xsl:sequence select="local:pass-metadata(.)"/>
                    <xsl:sequence select="$lines"/>
                </code>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="span[@data-custom-style = 'programmacodechar']">
        <codechar>
            <xsl:apply-templates/>
        </codechar>
    </xsl:template>
    
    <xsl:template match="div[@data-custom-style = ('textbody', 'tablecontents','abbrev','listparagraph')]">
        <!-- ignore -->
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="span[@data-custom-style = ('hyperlink','secno','sectitle','commentreference','verwijzingopmerking','annotationreference')]">
        <!-- ignore -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="div[@data-custom-style = 'letop']">
        <xsl:variable name="type" select="(@metadata-type,'warning')[1]"/>
        <box type="{$type}" label="{local:translate-i3n($type,local:get-lang(.),())}">
            <xsl:sequence select="local:pass-metadata(.)"/>
            <xsl:apply-templates select="*"/>
        </box>
    </xsl:template>
    <xsl:template match="span[@data-custom-style = 'letopchar']">
       <span class="letop">
           <xsl:apply-templates select="node()"/>
       </span>
    </xsl:template>
    
    <xsl:template match="div[@data-custom-style = ('quote','citaat')]">
        <xsl:variable name="source" select="@metadata-source"/>
        <box type="quote" label="{local:translate-i3n('quote',local:get-lang(.),())}">
            <xsl:sequence select="local:pass-metadata(.)"/>
            <xsl:if test="$source">
                <xsl:attribute name="href" select="$source"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </box>
    </xsl:template>
    <xsl:template match="span[@data-custom-style = 'quotechar' or @type = 'Quote']">
       <span class="quote" label="{local:translate-i3n('quote',local:get-lang(.),())}">
           <xsl:apply-templates select="node()"/>
       </span>
      </xsl:template>
        
    <xsl:template match="div[@data-custom-style = ('voorbeeld','example')]">
        <box type="example" label="{local:translate-i3n('example',local:get-lang(.),())}">
            <xsl:sequence select="local:pass-metadata(.)"/>
            <xsl:apply-templates select="node()"/>
        </box>
    </xsl:template>
    <xsl:template match="span[@data-custom-style = 'voorbeeldchar']">
        <span class="example">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="li">
        <xsl:copy>
            <xsl:apply-templates select="local:content(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="td">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="local:content(.)"/>
        </xsl:copy> 
    </xsl:template>
    
    <!-- 
        een link naar een internet locatie: altijd naar een eigen nieuw window 
    -->
    <xsl:template match="a[@href and not(starts-with(@href,'#'))]" priority="10">
        <xsl:copy>
            <xsl:attribute name="target" select="'window_' || local:generate-anchor-name(@href)"/>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        voet- en eindnoten 
        voetnoot<a href="#fn1" class="footnote-ref" id="fnref1" role="doc-noteref"><sup>1</sup></a>
    -->
    <xsl:template match="a[@role = 'doc-noteref']" priority="20">
        <xsl:variable name="name" select="substring(@href,2)"/>
        <xsl:variable name="section" select="$sections[@role = 'doc-endnotes']"/>
        <xsl:variable name="note" select="$section/ol/li[@id = $name]"/>
        <xsl:choose>
            <xsl:when test="empty($note)">
                <error loc="{$msword-file-name}">Deze noot bestaat niet: {$name}</error>
            </xsl:when>
            <xsl:otherwise>
                <note>
                    <xsl:attribute name="type" select="if ($note/div/@data-custom-style = 'endnotetext') then 'endnote' else 'footnote'"/>
                    <xsl:apply-templates select="local:content($note)"/>
                </note>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="section[@role = 'doc-endnotes']">
        <!-- skip; elders verwerkt -->
    </xsl:template>
    <xsl:template match="span[@data-custom-style = 'footnotereference']">
        <!-- remove -->
    </xsl:template>
    <xsl:template match="a[@role = 'doc-backlink']" priority="20">
        <!-- remove -->
    </xsl:template>
    
    <!--
        Extensions may be resolved in processing the XHTML, or later when generating the final HTML. 
        The correct phase for resolving the extension is recognized by the different XSLTs, for each step. 
        -->
    <xsl:template match="extension">
        <xsl:choose>
            <xsl:when test="@key = 'id'">
                <!-- sets the ID to a fixed value (not taken from generated ID -->
                <id>
                    <xsl:value-of select="@val"/>
                </id>
            </xsl:when>
            <xsl:when test="@key = 'includesection'">
                <!-- dit pakken we later op als alles worden geintegreerd -->
                <include-section>
                    <xsl:value-of select="@val"/>
                </include-section>
            </xsl:when>
            <xsl:when test="@key = 'includecatalog'">
                <!-- dit pakken we later op als alles worden geintegreerd -->
                <include-catalog>
                    <xsl:value-of select="@val"/>
                </include-catalog>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="blockquote">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- matrix1 is: twee cellen, tegen elkaar aan in midden -->
    <!-- matrix2 is: twee maal matrix1 naast elkaar -->
    
    <xsl:variable name="table-defs" as="element(table-def)*">
        <table-def name="matrix" class="matrix">
            <!-- no column specs; this is a free drawn table matrix -->
        </table-def>
        <table-def name="matrix1" class="matrix">
            <col width="50%" style="text-align: right; vertical-align: middle;"/>
            <col width="50%" style="text-align: left; vertical-align: middle;"/>
        </table-def>
        <table-def name="matrix2" class="matrix">
            <col width="25%" style="text-align: right; vertical-align: middle;"/>
            <col width="25%" style="text-align: left; vertical-align: middle;"/>
            <col width="25%" style="text-align: right; vertical-align: middle;"/>
            <col width="25%" style="text-align: left; vertical-align: middle;"/>
        </table-def>
    </xsl:variable> 

    <xsl:template match="table">
        <xsl:variable name="toks" select="tokenize(normalize-space(@metadata-table),'\s+')"/>
        <xsl:variable name="table-def" select="$table-defs[@name = $toks[1]]"/>
        
        <xsl:variable name="cols-specified" select="subsequence($toks,2)"/>
        <xsl:variable name="cols-found" select="*/tr[1]/td"/>
       
        <xsl:if test="exists($cols-specified) and (count($cols-specified) ne count($cols-found))">
            <error loc="{$msword-file-name}">Aantal kolommen in <b>table: matrix</b> specificatie en kolommen aangetroffen is niet hetzelfde</error>
        </xsl:if>
     
        <xsl:variable name="table">
            <xsl:choose>
                <xsl:when test="exists($table-def)">
                    <table class="{$table-def/@class}">
                        <colgroup>
                            <xsl:for-each select="$cols-found">
                                <col>
                                    <xsl:if test="$table-def/col[current()/position()]">
                                        <xsl:attribute name="width" select="$table-def/col[current()/position()]/@width"/>
                                    </xsl:if>
                                </col>
                            </xsl:for-each>
                        </colgroup>
                        <tbody>
                            <xsl:for-each select="(thead|tbody)/tr">
                                <tr>
                                    <xsl:for-each select="(th|td)">
                                        <td>
                                            <xsl:variable name="pos" select="count(preceding-sibling::*) + 1"/>
                                            <xsl:if test="$table-def/col[$pos]">
                                                <xsl:attribute name="style" select="$table-def/col[$pos]/@style"/>
                                            </xsl:if>
                                            <xsl:apply-templates select="local:content(.)"/>
                                        </td>
                                    </xsl:for-each>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </xsl:when>
                <xsl:when test="ancestor::table | descendant::table">
                    <table class="{if (ancestor::table) then 'inner-table' else 'outer-table'}">
                        <xsl:apply-templates select="colgroup"/>
                        <tbody>
                            <xsl:for-each select="(thead|tbody)/tr">
                                <tr>
                                    <xsl:for-each select="(th|td)">
                                        <td>
                                            <xsl:apply-templates select="local:content(.)"/>
                                        </td>
                                    </xsl:for-each>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:next-match/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$table"/> 
        
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        Breng alle divisies samen met gelijke data custom style attribuut.
        Dat doen we alleen voor elementen met div of p elementen in content; als die er niet zijn noemen we aan "mixed content" en voegen we niet samen.
    -->
    <xsl:function name="local:content">
        <xsl:param name="node" as="element()"/>
        <xsl:variable name="mixed" select="empty($node/*[self::div or self::p])"/>
        <xsl:choose>
            <xsl:when test="not($mixed)"><!-- inhoud is reeks van elementen -->
                <xsl:for-each-group select="$node/*" group-adjacent="local-name() || ':' || @data-custom-style">
                    <xsl:variable name="first" select="current-group()[1]"/>
                    <xsl:choose>
                        <xsl:when test="@data-custom-style = ('xxx')"><!-- TODO toestaan dat tussen bepaalde stylen geen witregels staan (dus niet samenvoegen). -->
                            <xsl:sequence select="current-group()"/>
                        </xsl:when>
                        <xsl:when test="exists($first/@data-custom-style)">
                            <xsl:element name="{local-name($first)}" namespace="{namespace-uri($first)}">
                                <xsl:attribute name="data-custom-style" select="$first/@data-custom-style"/>
                                <xsl:sequence select="current-group()/@*[starts-with(local-name(),'metadata-')]"/>
                                <xsl:sequence select="current-group()/node()"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="current-group()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise><!-- inhoud is leeg of een waarde -->
                <xsl:sequence select="$node/node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:get-lang" as="xs:string?">
        <xsl:param name="elm"/>
        <xsl:value-of select="($elm/@metadata-lang,'nl')[1]"/>
    </xsl:function>
    
    <xsl:function name="local:get-type" as="xs:string">
        <xsl:param name="section"/>
        <!-- TODO hoe het type bepalen? -->
        <xsl:choose>
            <xsl:when test="false()">type-name-here</xsl:when>
            <xsl:otherwise>default</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:pass-metadata" as="attribute()*">
        <xsl:param name="elm" as="element()"/>
        <xsl:sequence select="$elm/@*[starts-with(local-name(),'metadata-')]"/>
    </xsl:function>
    
    <!-- 
        een naam voor een internet locatie, te gebruiken als target in een html link
    -->
    <xsl:function name="local:generate-anchor-name" as="xs:string">
        <xsl:param name="href" as="xs:string"/>
        <xsl:value-of select="replace($href,'[^A-Za-z0-9]','_')"/>
    </xsl:function>
    
</xsl:stylesheet>