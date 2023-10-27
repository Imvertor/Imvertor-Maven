<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:bro="http://www.geostandaarden.nl/bro"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!--
        This stylesheet reorganizes the modeldoc as created for BRO, in accordance with specific requirements not foreseen in earlier stages.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:variable name="compiled-book" as="element(book)">
        <xsl:for-each select="/book"><!-- singleton -->
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates select="chapter[@type = 'cat']"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:apply-templates select="$compiled-book" mode="remove-dead-links"/>
    </xsl:template>
    
    <!-- verwijder dit niveau en maak er een nieuwe structuur van -->
    <xsl:template match="section[@type = 'DOMAIN']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <section type="SPECIAL-DOMAINMODEL">
                <xsl:apply-templates select="section[@type = 'IMAGEMAPS']"/>
            </section>
            <!-- registratieobject wordt bovenaan apart gezet -->
            <xsl:apply-templates select="section[@type = 'OVERVIEW-OBJECTTYPE']/section[@type = 'OBJECTTYPE' and @name = 'Registratieobject']"/>   
            <section type="SPECIAL-OTHEROBJECTS">
                <xsl:variable name="sections" as="element()*">
                    <xsl:apply-templates select="section[@type = 'OVERVIEW-OBJECTTYPE']/section[@type = 'OBJECTTYPE' and not(@name = 'Registratieobject')]"/>
                    <xsl:apply-templates select=".//section[@type = 'DETAIL-COMPOSITE']"/> <!-- omgezet naar objecttypen -->
                </xsl:variable>
                <xsl:for-each select="$sections">
                    <xsl:sort select="@position" order="ascending" data-type="number"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
                <xsl:apply-templates select="section[@type = 'OVERVIEW-UNION']/section[@type = 'UNION']"/>
            </section>
            <section type="SPECIAL-LISTS">
                <!-- minder kopjes lijsten -->
                <xsl:apply-templates select="/book/chapter[@type = 'lis']/section/section"/>
            </section>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="section[@type = 'OBJECTTYPE' and not(@name = 'Registratieobject') ]">
        <xsl:variable name="name" select="@name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="section[@type = 'IMAGEMAPS']"/>
            <xsl:apply-templates select="content"/>
            <xsl:apply-templates select="/book/chapter[@type = 'cat']/section[@type = 'DOMAIN']/section[@type = 'DETAILS']/section[@name = $name]/section[@type = 'DETAIL-ATTRIBUTE']"/>
            <xsl:apply-templates select="/book/chapter[@type = 'cat']/section[@type = 'DOMAIN']/section[@type = 'DETAILS']/section[@name = $name]/section[@type = 'DETAIL-ASSOCIATION' and @original-stereotype-id = 'stereotype-name-attributegroup']"/>
            <xsl:apply-templates select="/book/chapter[@type = 'cat']/section[@type = 'DOMAIN']/section[@type = 'DETAILS']/section[@name = $name]/section[@type = 'DETAIL-ASSOCIATION' and not(@original-stereotype-id = 'stereotype-name-attributegroup')]"/>
        </xsl:copy>            
    </xsl:template>
    
    <xsl:template match="section[@type = 'DETAIL-COMPOSITE']">
        <xsl:variable name="name" select="@name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*[not(local-name() = 'id-global')]"/>
            <xsl:attribute name="type">OBJECTTYPE</xsl:attribute>
            <xsl:apply-templates select="content"/>
            <xsl:apply-templates select="section[@type = 'DETAIL-COMPOSITE-ATTRIBUTE']"/>
        </xsl:copy>            
    </xsl:template>
    
    <!-- aanpassingen aan het overzicht van eigenschappen -->
    
    <xsl:template match="section[@type = ('OBJECTTYPE','DETAIL-COMPOSITE') and not(@name = 'Registratieobject')]/content">
        <content>
            <part type="CFG-DOC-NAAM">
                <item>Type gegeven</item>
                <item>Entiteit</item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMST']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-DEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMSTDEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS-IMBROA']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-TOELICHTING']"/>
        </content>
    </xsl:template>
    
    <xsl:template match="section[@type = ('SHORT-ATTRIBUTES', 'SHORT-ASSOCIATIONS')]">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="section[@type = ('UNION')]"><!-- zie de manier waarop objecttypen zijn uitgewerkt -->
        <xsl:variable name="name" select="@name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="content"/>
            <xsl:apply-templates select="/book/chapter[@type = 'cat']/section[@type = 'DOMAIN']/section[@type = 'DETAILS']/section[@name = $name]/section[@type = 'DETAIL-UNIONELEMENT']"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="section[@type = ('UNION')]/content">
        <content>
            <part type="CFG-DOC-NAAM">
                <item>Type gegeven</item>
                <item>Keuze</item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-DEFINITIE']"/>
        </content>
    </xsl:template>
    <xsl:template match="section[@type = ('DETAIL-UNIONELEMENT')]/content">
        <xsl:variable name="aname" select="../@name"/>
        <xsl:variable name="oname" select="../../@name"/>
        <content>
            <part type="CFG-DOC-NAAM">
                <item>Type gegeven</item>
                <item>Keuze element van <xsl:value-of select="../../@name"/></item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-DEFINITIE']"/>
        </content>
    </xsl:template>
    
    <xsl:template match="section[@type = 'DETAIL-COMPOSITE-ATTRIBUTE']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="type">DETAIL-ATTRIBUTE</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="section[@type = ('DETAIL-ATTRIBUTE','DETAIL-COMPOSITE-ATTRIBUTE')]/content">
        <xsl:variable name="aname" select="../@name"/>
        <xsl:variable name="oname" select="../../@name"/>
        <content>
            <part type="CFG-DOC-NAAM">
                <item>Type gegeven</item>
                <item>Attribuut van <xsl:value-of select="../../@name"/></item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMST']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-DEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMSTDEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEAUTHENTIEK']"/>
            <part type="CFG-DOC-NAAM">
                <item>Kardinaliteit</item>
                <item>
                    <xsl:value-of select="imf:new-card(//section[@name = $oname and @type='OBJECTTYPE']/section[@type = 'SHORT-ATTRIBUTES']/content/part[item[1]/item = $aname]/item[4])"/>
                </item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-FORMAAT']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS-IMBROA']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEMATERIELEHISTORIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEAFLEIDBAAR']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-MOGELIJKGEENWAARDE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-EXPLAINNOVALUE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-TOELICHTING']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEIDENTIFICEREND' and item[2] eq 'Ja']"/>
        </content>
    </xsl:template>
    
    <xsl:template match="section[@type = 'DETAIL-ASSOCIATION']">
        <xsl:copy>  
           <xsl:apply-templates select="@*"/>
            <xsl:variable name="target-role-name" select="imf:get-target-role-name(@id)"/>
            <xsl:attribute name="name" select="($target-role-name,@name)[1]"/>
           <xsl:apply-templates select="content[@approach = 'target']"/>
       </xsl:copy>
    </xsl:template>
    
    <xsl:template match="section[@type = 'DETAIL-ASSOCIATION']/content[@approach = 'target']">
        <xsl:variable name="relation-name" select="../@name"/>
        <xsl:variable name="source-name" select="../../@name"/>
        
        <xsl:variable name="target-role-name" select="imf:get-target-role-name(../@id)"/>
        
        <xsl:variable name="target" select="part[@type = 'CFG-DOC-GERELATEERDOBJECTTYPE']/item[2]"/>
        <xsl:variable name="target-name" select="string($target)"/>
        
        <xsl:variable name="is-attribuutgroep" select="../@original-stereotype-id = 'stereotype-name-attributegroup'"/>
        <xsl:variable name="association-type" select="if ($is-attribuutgroep) then 'Gegevensgroep' else 'Associatie'"/><!-- https://github.com/Imvertor/Imvertor-Maven/issues/147 -->
        <xsl:comment>break4</xsl:comment>
        <content>
            <part type="CFG-DOC-NAAM">
                <item>Type gegeven</item>
                <item><xsl:value-of select="$association-type"/> van <xsl:value-of select="$source-name"/></item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMST']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-DEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMSTDEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEAUTHENTIEK']"/>
            <part type="CFG-DOC-NAAM">
                <item>Kardinaliteit</item>
                <item>
                    <xsl:value-of select="imf:new-card(part[@type='CFG-DOC-INDICATIEKARDINALITEIT']/item[2])"/>
                </item>
            </part>
            <xsl:if test="$association-type = 'Associatie'">
                <part type="CFG-DOC-NAAM">
                    <item>Relatiesoort naam</item>
                    <item><xsl:value-of select="$relation-name"/></item>
                </part>
                <part type="CFG-DOC-NAAM">
                    <item>Relatierol naam</item>
                    <item><xsl:value-of select="$target-role-name"/></item>
                </part>
                <part type="CFG-DOC-NAAM">
                    <item>Bron</item>
                    <item><xsl:value-of select="$source-name"/></item>
                </part>
            </xsl:if>
            <part type="CFG-DOC-NAAM">
                <item><xsl:value-of select="if ($is-attribuutgroep) then 'Gegevensgroeptype' else 'Doel'"/></item>
                <item>
                    <xsl:choose>
                        <xsl:when test="$is-attribuutgroep">
                            <xsl:sequence select="$target"/><!-- dit is een item met link info -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$target-name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS-IMBROA']"/><!-- https://github.com/Imvertor/Imvertor-Maven/issues/147 correctie -->
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEMATERIELEHISTORIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-MOGELIJKGEENWAARDE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-EXPLAINNOVALUE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-TOELICHTING']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEIDENTIFICEREND' and item[2] eq 'Ja']"/>
        </content>
    </xsl:template>
    
    <!-- Vervang waarden van tagged values -->
    <xsl:template match="part[@type = ('CFG-DOC-HERKOMST','CFG-DOC-HERKOMSTDEFINITIE')]">
        <xsl:choose>
            <xsl:when test="normalize-space(item[2]) = 'BRO'">
                <!-- skip -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="part[@type = ('CFG-DOC-INDICATIEAUTHENTIEK')]/item[2]">
        <xsl:choose>
            <xsl:when test="normalize-space() = 'Basisgegeven'">
                <xsl:copy>Niet-authentiek</xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="part[@type = ('CFG-DOC-INDICATIEAFLEIDBAAR')]">
        <xsl:choose>
            <xsl:when test="normalize-space(item[2]) ne 'Ja'">
                <!-- skip -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- gegevensgroepen -->
      
    <xsl:template match="part[@type = ('COMPOSER','COMPOSED')]">
        <!-- remove -->
    </xsl:template>
    
    <!-- dead link removal -->
    <xsl:template match="@idref" mode="remove-dead-links">
        <xsl:variable name="referenced-element" select="$compiled-book//*[@id = current()]"/>
        <xsl:if test="$referenced-element">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
    <!-- default template -->
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- relatienamen zonder rollen -->
    <xsl:template match="item" mode="name-only">
        <xsl:copy>
            <xsl:value-of select="tokenize(.,':')[1]"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- zet card om: [ 0 .. * ] en [ 1 ] met of zonder [..] haakjes -->
    <xsl:template match="item" mode="new-card">
        <xsl:copy>
            <xsl:value-of select="imf:new-card(.)"/>
        </xsl:copy>
    </xsl:template>
 
    <xsl:function name="imf:new-card">
        <xsl:param name="card" as="xs:string*"/><!-- TODO hoe kan het zijn dat er soms meerdere cardinaliteiten binnenkomen? -->
        <xsl:if test="normalize-space($card[1])">
            <xsl:analyze-string select="$card" regex="^(\[\s)?(.+?)(\s\.\.\s(.+?))?(\s\])?$">
                <xsl:matching-substring>
                    <xsl:choose>
                        <?x
                        <xsl:when test="regex-group(2) = '0' and regex-group(4) = '*'">
                            <xsl:value-of select="'0, 1 of meer'"/>
                        </xsl:when>
                        <xsl:when test="normalize-space(regex-group(4)) = '*'">
                            <xsl:value-of select="concat(regex-group(2),' of meer')"/>
                        </xsl:when>
                        ?>
                        <xsl:when test="normalize-space(regex-group(2)) and normalize-space(regex-group(4))">
                            <xsl:value-of select="concat(regex-group(2),'..',regex-group(4))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <!-- formaten -->
    <xsl:template match="part[@type='CFG-DOC-FORMAAT']">
        <part>
            <item>Domein</item>
            <item/>
        </part>
        <xsl:copy-of select="bro:generate-domain(item[2], parent::node())"/>
    </xsl:template>
    
    <!-- door lvdb 
        functie wordt aangeroepen door stylesheet die een door imvertor gegenereerd modeldoc (tussenformaat tussen UML output en gegevenscat HTML) aanpast 
        aan specifieke wensen van BRO
-->
    
    <!-- genereert domein informatie zoals gewenst door BRO -->
    <!--    input parameter 1: $item een item node met als tekstinhoud de naam van een domein 
          bijvoorbeeld: <item type="global" idref="global_class_gmlMeasure">Meetwaarde</item>
          input parameter 2: $context de complete section/content waarin het item zich bevindt, als node sequence -->
    <!--    output: een node sequence -->
    <xsl:function name="bro:generate-domain">
        <xsl:param name="item" as="element()"/>
        <xsl:param name="context" as="element()"/>
        <xsl:variable name="item-text" select="normalize-space($item)"/>
        
        <xsl:variable name="minmax-specified" select="$context[part[@type = 'CFG-DOC-MINVALUEINCLUSIVE']/item[2]/text() | part[@type = 'CFG-DOC-MAXVALUEINCLUSIVE']/item[2]/text()]"/>
        <xsl:variable name="in-machten" select="$context[part[@type = 'CFG-DOC-MINVALUEINCLUSIVE']/item[2]/* | part[@type = 'CFG-DOC-MAXVALUEINCLUSIVE']/item[2]/*]"/>
        
        <xsl:choose>
            <xsl:when test="$item-text = 'Meetwaarde'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Meetwaarde 
                        <xsl:value-of select="$context/part[@type = 'CFG-DOC-PATROON']/item[2]/text()"/> 
                        <xsl:if test="$in-machten"> in machten</xsl:if>
                    </item>
                </part>
                <!--alleen genereren als er een eenheid aanwezig is-->
                <xsl:for-each select="$context/part[@type = 'CFG-DOC-UNITOFMEASURE']/item[2]">
                    <part>
                        <item>&#160;&#160;Eenheid</item>
                        <item>
                            <xsl:sequence select="bro:generate-unit(.)"/>
                        </item>
                    </part>
                </xsl:for-each>
                <!-- alleen genereren als er een minimum en/of een maximumwaarde aanwezig is -->
                <xsl:if test="$minmax-specified">
                    <part>
                        <item>&#160;&#160;Waardebereik</item>
                        <item>
                            <xsl:sequence
                                select="bro:generate-minmax($context/part[@type = 'CFG-DOC-MINVALUEINCLUSIVE']/item[2]/node(), $context/part[@type = 'CFG-DOC-MAXVALUEINCLUSIVE']/item[2]/node())"
                            />
                        </item>
                    </part>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$item-text='Aantal'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Aantal <xsl:value-of select="$context/part[@type = 'CFG-DOC-LENGTH']/item[2]/text()"/></item>
                </part>
                <!-- alleen genereren als er een minimum en/of een maximumwaarde aanwezig is -->
                <xsl:if test="$minmax-specified">
                    <part>
                        <item>&#160;&#160;Waardebereik</item>
                        <item>
                            <xsl:sequence
                                select="bro:generate-minmax($context/part[@type = 'CFG-DOC-MINVALUEINCLUSIVE']/item[2]/node(), $context/part[@type = 'CFG-DOC-MAXVALUEINCLUSIVE']/item[2]/node())"
                            />
                        </item>
                    </part>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$item-text='Nummer'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Nummer <xsl:value-of select="$context/part[@type = 'CFG-DOC-LENGTH']/item[2]/text()"/></item>
                </part>
            </xsl:when>
            <xsl:when test="$item-text='Tekst'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Tekst <xsl:value-of select="$context/part[@type = 'CFG-DOC-LENGTH']/item[2]/text()"/></item>
                </part>
            </xsl:when>
            <xsl:when test="$item-text='Registratieobjectcode'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Registratieobjectcode</item>
                </part>
                <part>
                    <item>&#160;&#160;Type</item>
                    <item>Code</item>
                </part>
                <part>
                    <item>&#160;&#160;Opbouw</item>
                    <item><xsl:value-of select="$context/part[@type = 'CFG-DOC-PATROON']/item[2]/text()"/></item>
                </part>
            </xsl:when>
            <xsl:when test="$item-text=('Bepalingscode','NITGCode','Putcode','GUID')">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item><xsl:value-of select="$item"/></item>
                </part>
                <part>
                    <item>&#160;&#160;Type</item>
                    <item>Code</item>
                </part>
                <part>
                    <item>&#160;&#160;Opbouw</item>
                    <item><xsl:value-of select="$context/part[@type = 'CFG-DOC-PATROON']/item[2]/text()"/></item>
                </part>
            </xsl:when>
            <xsl:when test="$item-text = ('Datum', 'DatumTijd','OnvolledigeDatum')">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item><xsl:value-of select="$item"/></item>
                </part>
                <!-- alleen genereren als er een IMBRO/A domein is -->
                <xsl:for-each select="$context/part[@type = 'CFG-DOC-DOMAIN-IMBROA']">
                    <part>
                        <item>&#160;&#160;Naam IMBRO/A</item>
                        <item><xsl:value-of select="./item[2]/text()"/></item>
                    </part>                    
                </xsl:for-each>                
                <!-- alleen genereren als er een minimum en/of een maximumwaarde aanwezig is -->
                <xsl:if test="$minmax-specified">
                    <part>
                        <item>&#160;&#160;Waardebereik</item>
                        <item>
                            <xsl:sequence
                                select="bro:generate-minmax($context/part[@type = 'CFG-DOC-MINVALUEINCLUSIVE']/item[2]/node(), $context/part[@type = 'CFG-DOC-MAXVALUEINCLUSIVE']/item[2]/node())"
                            />
                        </item>
                    </part>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$item-text = ('Coördinatenpaar', 'Gebiedsgrens')">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item><xsl:value-of select="$item"/></item>
                </part>                
            </xsl:when>
            <xsl:when test="$item-text='Organisatie'">                
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Organisatie</item>
                </part>
            </xsl:when>
            <xsl:when test="$item-text = ('IndicatieJaNee', 'Kwaliteitsregime')">   
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item><xsl:value-of select="$item"/></item>
                </part>
                <!-- alleen genereren als er een IMBRO/A domein is -->
                <xsl:for-each select="$context/part[@type = 'CFG-DOC-DOMAIN-IMBROA']">
                    <part>
                        <item>&#160;&#160;Naam IMBRO/A</item>
                        <item><xsl:value-of select="./item[2]/text()"/></item>
                    </part>                    
                </xsl:for-each>
                <part>
                    <item>&#160;&#160;Type</item>
                    <item>Waardelijst niet uitbreidbaar</item>
                </part>
            </xsl:when>
            <xsl:otherwise> 
                <xsl:variable name="item-formal-name" select="imf:extract($item-text,'[A-Za-z0-9_]')"/>
                <xsl:variable name="id" select="concat('detail_class_Model_',$item-formal-name)"/>
                <xsl:variable name="defining-class-section" select="root($context)//section[@id = $id]"/>
                <xsl:variable name="defining-class-type" select="$defining-class-section/parent::section/@type"/>
                <xsl:variable name="identifiers" select="$defining-class-section//itemtype[@is-id = 'true']"/>
                <xsl:choose>
                    <!-- een lijst? -->
                    <xsl:when test="$defining-class-type = ('CONTENTS-CODELIST','CONTENTS-REFERENCELIST')">
                        <part>
                            <item>&#160;&#160;Naam</item>
                            <item><item idref="detail_class_Model_{$item-formal-name}"><xsl:value-of select="$item-text"/></item></item>
                        </part>
                        <part>
                            <item>&#160;&#160;Type</item>
                            <item>Waardelijst uitbreidbaar</item>
                        </part>
                        <xsl:if test="$defining-class-type = ('CONTENTS-REFERENCELIST')">
                            <part>
                                <item>&#160;&#160;Identificerend gegeven</item>
                                <item><xsl:value-of select="string-join($identifiers,', ')"/></item>
                            </part>
                        </xsl:if>
                        <!-- alleen genereren als er een IMBRO/A domein is -->
                        <xsl:for-each select="$context/part[@type = 'CFG-DOC-DOMAIN-IMBROA']">
                            <part>
                                <item>&#160;&#160;Domein IMBRO/A</item>
                                <item><xsl:value-of select="./item[2]/text()"/></item>
                            </part>                    
                        </xsl:for-each>
                    </xsl:when>
                    <!-- anders een niet verder bekende waarde; toon gewoon de naam van het type -->
                    <xsl:otherwise>
                        <part>
                            <item>&#160;&#160;Naam</item>
                            <item><item idref="detail_class_Model_{$item-formal-name}"><xsl:value-of select="$item-text"/></item></item>
                        </part>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- verwijder de markers aan eind van de naam van image --> 
    <xsl:variable name="image-marker" select="('overzicht', 'detail')"/>
    
    <xsl:template match="section[@type='IMAGEMAP']/content/part[@type='CFG-DOC-NAAM']/item[2]">
        <xsl:variable name="toks" select="tokenize(.,'\s-\s')"/>
        <xsl:choose>
            <xsl:when test="$toks[last()] = $image-marker">
                <item>
                    <xsl:sequence select="string-join(subsequence($toks,1,count($toks) - 1),'- ')"/>
                </item>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>  
    
    
    
    
    <xsl:function name="bro:generate-unit" as="item()*">
        <xsl:param name="unit-ucum"/>
        <!-- mapping ucum eenheid - uitgeschreven eenheid -->
        <xsl:choose>
            <xsl:when test="$unit-ucum = '1'">dimensieloos</xsl:when>
            <xsl:when test="$unit-ucum = '%'">% (procent)</xsl:when>
            <xsl:when test="$unit-ucum = 'Cel'">°C (graden Celsius)</xsl:when>
            <xsl:when test="$unit-ucum = 'deg'">° (graden)</xsl:when>
            <xsl:when test="$unit-ucum = 'g/cm3'">g/cm<sup>3</sup> (gram/kubieke centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'kPa'">kPa (kilopascal)</xsl:when>
            <xsl:when test="$unit-ucum = 'm'">m (meter)</xsl:when>
            <xsl:when test="$unit-ucum = 'm/d'">m/d (meter per 24 uur)</xsl:when>
            <xsl:when test="$unit-ucum = 'mm'">mm (millimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'mm2'">mm<sup>2</sup> (vierkante millimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'MPa'">MPa (megapascal)</xsl:when>
            <xsl:when test="$unit-ucum = 'nT'">nT (nanotesla)</xsl:when>
            <xsl:when test="$unit-ucum = 's'">s (seconde)</xsl:when>
            <xsl:when test="$unit-ucum = 'S/m'">S/m (Siemens/meter)</xsl:when>
            
            <xsl:when test="$unit-ucum = 'mS/m'">mS/m (milliSiemens/meter)</xsl:when>
            <xsl:when test="$unit-ucum = 'Ohmm'">Ohm.m (ohm meter)</xsl:when>

            <xsl:when test="$unit-ucum = 'um'">µm (micrometer)</xsl:when>
            <xsl:when test="$unit-ucum = 'mm/h'">mm/h (millimeter per uur)</xsl:when>
            <xsl:when test="$unit-ucum = 'm/s'">m/s (meter per seconde)</xsl:when>
            <xsl:when test="$unit-ucum = 'cm/cm'">cm/cm (centimeter per centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'g'">g (gram)</xsl:when>
            <xsl:when test="$unit-ucum = 'g/cm3'">g/cm<sup>3</sup> (gram per kubieke centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'cm3'">cm<sup>3</sup> (kubieke centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'cm'">cm (centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'cm/d'">cm/d (centimeter per 24 uur)</xsl:when>
            <xsl:when test="$unit-ucum = 'cm[H2O]'">cm H<sub>2</sub>O (centimeter waterkolom)</xsl:when>
            <xsl:when test="$unit-ucum = 'g/g'">g/g (gram/gram)</xsl:when>
            <xsl:when test="$unit-ucum = 'cm-1'">cm<sup>-1</sup> (per centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'g/kg'">g/kg (gram per kilogram)</xsl:when>
            
            <xsl:when test="$unit-ucum = 'cm3/cm3'">cm<sup>3</sup>/cm<sup>3</sup> (kubieke centimeter/kubieke centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'm3'">m<sup>3</sup> (kubieke meter)</xsl:when>
            <xsl:when test="$unit-ucum = 'm3/h'">m<sup>3</sup>/h (kubieke meter per uur)</xsl:when>
            <xsl:when test="$unit-ucum = 'MWh'">MWh (megawattuur)</xsl:when>
            <xsl:when test="$unit-ucum = 'kW'">kW (kilowatt)</xsl:when>
            
            <xsl:when test="$unit-ucum = 'mm2/mm2'">mm<sup>2</sup>/mm<sup>2</sup> (vierkante millimeter/vierkante millimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'MPa/MPa'">MPa/MPa (megapascal/megapascal)</xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="$unit-ucum"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="bro:generate-minmax" as="item()*">
        <xsl:param name="min" as="item()*"/>
        <xsl:param name="max" as="item()*"/>
        <xsl:choose>
            <xsl:when test="$min and $max">
                <xsl:sequence select="$min"/>
                <xsl:value-of select="' tot '"/>
                <xsl:sequence select="$max"/>
            </xsl:when>
            <!-- bij alleen min: waarde = vanaf [minimumwaarde]-->
            <xsl:when test="$min">
                <xsl:value-of select="' vanaf '"/>
                <xsl:sequence select="$min"/>
            </xsl:when>
            <!-- bij alleen max: waarde = tot [maximumwaarde]-->
            <xsl:when test="$max">
                <xsl:value-of select="' tot '"/>
                <xsl:sequence select="$max"/>
            </xsl:when>
            <!-- in alle andere gevallen ontbreekt het gegeven -->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:function>
    
    <!-- even moeilijk doen omdat de rol niet is opgenomen in de detail weergave van de relatie -->
    <xsl:function name="imf:get-target-role-name">
        <xsl:param name="association-id" as="xs:string"/>
        <xsl:variable name="short-item" select="($document//content[@approach='target']//item[@type = 'detail' and @idref = $association-id])[1]"/> <!-- possible duplicates should have been signalled as error -->
        <xsl:value-of select="substring-after($short-item,': ')"/>
    </xsl:function>
</xsl:stylesheet>
