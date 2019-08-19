<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:bro="http://www.geostandaarden.nl/bro"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!--
        This stylesheet reorganizes the modeldoc as created for BRO, in accordance with specific requirements not foreseen in earlier stages.
    -->
    
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
            <section type="BRO-DOMAINMODEL">
                <xsl:apply-templates select="section[@type = 'IMAGEMAPS']"/>
            </section>
            <!-- registratieobject wordt bovenaan apart gezet -->
            <xsl:apply-templates select="section[@type = 'OVERVIEW-OBJECTTYPE']/section[@type = 'OBJECTTYPE' and @name = ('Registratieobject','Baksteen')]"/>   
            <section type="BRO-OTHEROBJECTS">
                <xsl:variable name="sections" as="element()*">
                    <xsl:apply-templates select="section[@type = 'OVERVIEW-OBJECTTYPE']/section[@type = 'OBJECTTYPE' and not(@name = ('Registratieobject','Baksteen'))]"/>
                    <xsl:apply-templates select=".//section[@type = 'DETAIL-COMPOSITE']"/> <!-- omgezet naar objecttypen -->
                </xsl:variable>
                <xsl:for-each select="$sections">
                    <xsl:sort select="@position" order="ascending" data-type="number"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </section>
            <section type="BRO-LISTS">
                <!-- minder kopjes lijsten -->
                <xsl:apply-templates select="/book/chapter[@type = 'lis']/section/section"/>
            </section>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="section[@type = 'OBJECTTYPE']">
        <xsl:variable name="name" select="@name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="section[@type = 'IMAGEMAPS']"/>
            <xsl:apply-templates select="content"/>
            <xsl:apply-templates select="/book/chapter[@type = 'cat']/section[@type = 'DOMAIN']/section[@type = 'DETAILS']/section[@name = $name]/section[@type = 'DETAIL-ATTRIBUTE']"/>
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
    
    <xsl:template match="section[@type = ('OBJECTTYPE','DETAIL-COMPOSITE')]/content">
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
            
            <!-- relaties hierheen -->
            <xsl:variable name="r" as="element(item)*">
                <xsl:for-each select="../section[@type = 'SHORT-ASSOCIATIONS']/content[@approach = 'target']/part/item[1]">
                    <!-- [bron objecttype] [naam relatiesoort] [kardinaliteit bij doel, uitgeschreven*] [doel objecttype] -->
                    <item>
                        <xsl:choose>
                            <xsl:when test="item[4]"><!-- -->
                                <xsl:apply-templates select="item[1]"/>
                                <xsl:value-of select="' '"/>
                                <xsl:apply-templates select="item[3]" mode="name-only"/> <!-- alleen de naam van de relatie, niet de rol -->
                                <xsl:value-of select="' '"/>
                                <xsl:apply-templates select="item[5]" mode="new-card"/>
                                <xsl:value-of select="' '"/>
                                <xsl:apply-templates select="item[4]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="item[1]"/>
                                <xsl:value-of select="' '"/>
                                <xsl:apply-templates select="item[2]"/>
                                <xsl:value-of select="' '"/>
                                <xsl:apply-templates select="item[3]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <item><br/></item>
                    </item>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="exists($r)">
                <part type="CFG-DOC-BRO-RELATIES">
                    <item>Relaties met andere entiteiten</item>
                    <item>
                        <xsl:sequence select="$r"/>
                     </item>
                </part>
            </xsl:if>
        </content>
    </xsl:template>
    
    <xsl:template match="section[@type = ('SHORT-ATTRIBUTES', 'SHORT-ASSOCIATIONS')]">
        <!-- remove -->
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
                <item>Attribuut</item>
            </part>
            <part type="CFG-DOC-NAAM">
                <item>Attribuut van</item>
                <item><xsl:value-of select="../../@name"/></item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEAUTHENTIEK']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMST']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-DEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMSTDEFINITIE']"/>
            <part type="CFG-DOC-NAAM">
                <item>Kardinaliteit</item>
                <item>
                    <xsl:value-of select="imf:new-card(//section[@name = $oname and @type='OBJECTTYPE']/section[@type = 'SHORT-ATTRIBUTES']/content/part[item[1]/item = $aname]/item[4])"/>
                </item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-FORMAAT']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS-IMBROA']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-TOELICHTING']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEMATERIELEHISTORIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEAFLEIDBAAR']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-MOGELIJKGEENWAARDE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-EXPLAINNOVALUE']"/>
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
                <xsl:copy>Basisgegeven (niet-authentiek)</xsl:copy>
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
        <xsl:param name="card"/>
        <xsl:if test="normalize-space($card)">
            <xsl:analyze-string select="$card" regex="^(\[\s)?(.)(\s\.\.\s(.))?(\s\])?$">
                <xsl:matching-substring>
                    <xsl:choose>
                        <xsl:when test="regex-group(2) = '0' and regex-group(4) = '*'">
                            <xsl:value-of select="'0, 1 of meer'"/>
                        </xsl:when>
                        <xsl:when test="normalize-space(regex-group(4)) = '*'">
                            <xsl:value-of select="concat(regex-group(2),' of meer')"/>
                        </xsl:when>
                        <xsl:when test="normalize-space(regex-group(2)) and normalize-space(regex-group(4))">
                            <xsl:value-of select="concat(regex-group(2),'-',regex-group(4))"/>
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
        <xsl:choose>
            <xsl:when test="$item/text() = 'Meetwaarde'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Meetwaarde</item>
                </part>
                <part>
                    <item>&#160;&#160;Type</item>
                    <item>Getal</item>
                </part>
                <!--alleen genereren als er een eenheid aanwezig is-->
                <xsl:for-each select="$context/part[@type = 'CFG-DOC-UNITOFMEASURE']/item[2]">
                    <part>
                        <item>&#160;&#160;Eenheid</item>
                        <item>
                            <xsl:value-of select="bro:generate-unit(.)"/>
                        </item>
                    </part>
                </xsl:for-each>
                <!-- alleen genereren als er een minimum en/of een maximumwaarde aanwezig is -->
                <xsl:for-each
                    select="$context[part[@type = 'CFG-DOC-MINIMUMVALUE']/item[2]/text() | part[@type = 'CFG-DOC-MAXIMUMVALUE']/item[2]/text()]">
                    <part>
                        <item>&#160;&#160;Waardebereik</item>
                        <item>
                            <xsl:value-of
                                select="bro:generate-minmax($context/part[@type = 'CFG-DOC-MINIMUMVALUE']/item[2]/text(), $context/part[@type = 'CFG-DOC-MAXIMUMVALUE']/item[2]/text())"
                            />
                        </item>
                    </part>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$item/text()='Aantal'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Aantal <xsl:value-of select="$context/part[@type = 'CFG-DOC-LENGTH']/item[2]/text()"/></item>
                </part>
                <part>
                    <item>&#160;&#160;Type</item>
                    <item>Getal</item>
                </part>
                <!-- alleen genereren als er een minimum en/of een maximumwaarde aanwezig is -->
                <xsl:for-each
                    select="$context[part[@type = 'CFG-DOC-MINIMUMVALUE']/item[2]/text() | part[@type = 'CFG-DOC-MAXIMUMVALUE']/item[2]/text()]">
                    <part>
                        <item>&#160;&#160;Waardebereik</item>
                        <item>
                            <xsl:value-of
                                select="bro:generate-minmax($context/part[@type = 'CFG-DOC-MINIMUMVALUE']/item[2]/text(), $context/part[@type = 'CFG-DOC-MAXIMUMVALUE']/item[2]/text())"
                            />
                        </item>
                    </part>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$item/text()='Nummer'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Nummer <xsl:value-of select="$context/part[@type = 'CFG-DOC-LENGTH']/item[2]/text()"/></item>
                </part>
            </xsl:when>
            <xsl:when test="$item/text()='Tekst'">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Tekst <xsl:value-of select="$context/part[@type = 'CFG-DOC-LENGTH']/item[2]/text()"/></item>
                </part>
            </xsl:when>
            <xsl:when test="$item/text()='Registratieobjectcode'">
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
            <xsl:when test="$item[text()=('Datum', 'DatumTijd')]">
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
                <xsl:for-each
                    select="$context[part[@type = 'CFG-DOC-MINIMUMVALUE']/item[2]/text() | part[@type = 'CFG-DOC-MAXIMUMVALUE']/item[2]/text()]">
                    <part>
                        <item>&#160;&#160;Waardebereik</item>
                        <item>
                            <xsl:value-of
                                select="bro:generate-minmax($context/part[@type = 'CFG-DOC-MINIMUMVALUE']/item[2]/text(), $context/part[@type = 'CFG-DOC-MAXIMUMVALUE']/item[2]/text())"
                            />
                        </item>
                    </part>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$item[text()=('Coördinatenpaar', 'Gebiedsgrens')]">
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item><xsl:value-of select="$item"/></item>
                </part>                
            </xsl:when>
            <xsl:when test="$item/text()='Organisatie'">                
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item>Organisatie</item>
                </part>
                <part>
                    <item>&#160;&#160;Type</item>
                    <item>Keuze</item>
                </part>
            </xsl:when>
            <xsl:when test="$item/text() = ('IndicatieJaNee', 'Kwaliteitsregime')">   
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
            <!-- anders is het een uitbreidbare waardelijst (codelist of referentielijst) -->
            <xsl:otherwise> 
                <part>
                    <item>&#160;&#160;Naam</item>
                    <item><item idref="detail_class_Model_{$item}"><xsl:value-of select="$item"/></item></item>
                </part>
                <part>
                    <item>&#160;&#160;Type</item>
                    <item>Waardelijst uitbreidbaar</item>
                </part>
                <!-- alleen genereren als er een IMBRO/A domein is -->
                <xsl:for-each select="$context/part[@type = 'CFG-DOC-DOMAIN-IMBROA']">
                    <part>
                        <item>&#160;&#160;Domein IMBRO/A</item>
                        <item><xsl:value-of select="./item[2]/text()"/></item>
                    </part>                    
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="bro:generate-unit">
        <xsl:param name="unit-ucum"/>
        <!-- mapping ucum eenheid - uitgeschreven eenheid -->
        <xsl:choose>
            <xsl:when test="$unit-ucum = '1'">dimensieloos</xsl:when>
            <xsl:when test="$unit-ucum = '%'">% (procent)</xsl:when>
            <xsl:when test="$unit-ucum = 'Cel'">°C (graden Celcius)</xsl:when>
            <xsl:when test="$unit-ucum = 'deg'">° (graden)</xsl:when>
            <xsl:when test="$unit-ucum = 'g/cm3'">g/cm3 (gram/kubieke centimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'kPa'">kPa (kiloPascal)</xsl:when>
            <xsl:when test="$unit-ucum = 'm'">m (meter)</xsl:when>
            <xsl:when test="$unit-ucum = 'm/(24.h)'">m/24h (meters per etmaal)</xsl:when>
            <xsl:when test="$unit-ucum = 'mm'">mm (millimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'mm2'">mm2 (vierkante millimeter)</xsl:when>
            <xsl:when test="$unit-ucum = 'MPa'">MPa (megaPascal)</xsl:when>
            <xsl:when test="$unit-ucum = 'nT'">nT (nanoTesla)</xsl:when>
            <xsl:when test="$unit-ucum = 's'">s (seconde)</xsl:when>
            <xsl:when test="$unit-ucum = 'S/m'">S/m (Siemens/meter)</xsl:when>
            <xsl:when test="$unit-ucum = 'um'">µm (micrometer)</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$unit-ucum"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="bro:generate-minmax">
        <xsl:param name="min"/>
        <xsl:param name="max"/>
        <xsl:choose>
            <!-- bij min en max: waarde = [minimumwaarde] tot [maximumwaarde]-->
            <xsl:when test="$min and $max">
                <xsl:value-of select="concat($min, ' tot ', $max)"/>
            </xsl:when>
            <!-- bij alleen min: waarde = vanaf [minimumwaarde]-->
            <xsl:when test="$min">
                <xsl:value-of select="concat('Vanaf ', $min)"/>
            </xsl:when>
            <!-- bij alleen max: waarde = tot [maximumwaarde]-->
            <xsl:when test="$max">
                <xsl:value-of select="concat('Tot ', $max)"/>
            </xsl:when>
            <!-- in alle andere gevallen ontbreekt het gegeven"-->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>