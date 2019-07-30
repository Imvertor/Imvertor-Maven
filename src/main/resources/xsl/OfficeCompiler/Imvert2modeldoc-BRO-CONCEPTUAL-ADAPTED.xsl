<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
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
                <xsl:apply-templates select="section[@type = 'OVERVIEW-OBJECTTYPE']/section[@type = 'OBJECTTYPE' and not(@name = ('Registratieobject','Baksteen'))]"/>
                <xsl:apply-templates select=".//section[@type = 'DETAIL-COMPOSITE']"/> <!-- omgezet naar objecttypen -->
            </section>
            <section type="BRO-LISTS">
                <!-- minder kopjes lijsten -->
                <xsl:apply-templates select="/book/chapter[@type = 'lis']/section/section"/>
            </section>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="section[@type = 'IMAGEMAPS']">
       <xsl:choose>
           <xsl:when test="parent::section[@type = 'DOMAIN']">
              <xsl:next-match/>
           </xsl:when>
           <xsl:otherwise>
               <section type="IMAGEMAP-NOT-SUPPORTED-HERE">
                   UNSUPPORTED 
               </section>
           </xsl:otherwise>
       </xsl:choose> 
    </xsl:template>
   
    <xsl:template match="section[@type = 'OBJECTTYPE']">
        <xsl:variable name="name" select="@name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="content"/>
            <xsl:apply-templates select="/book/chapter[@type = 'cat']/section[@type = 'DOMAIN']/section[@type = 'DETAILS']/section[@name = $name]/section[@type = 'DETAIL-ATTRIBUTE']"/>
        </xsl:copy>            
    </xsl:template>
    
    <xsl:template match="section[@type = 'DETAIL-COMPOSITE']">
        <xsl:variable name="name" select="@name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
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
                        <item>
                            Omschrijving van de relaties: 
                            <br/>
                        </item>
                        <xsl:sequence select="$r"/>
                     </item>
                </part>
            </xsl:if>
            
            <!-- figuur hierheen -->
            <!-- TODO -->
        </content>
    </xsl:template>
    
    <xsl:template match="section[@type = ('SHORT-ATTRIBUTES', 'SHORT-ASSOCIATIONS')]">
        <!-- remove -->
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
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMST']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-DEFINITIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-HERKOMSTDEFINITIE']"/>
            <part type="CFG-DOC-NAAM">
                <item>Kardinaliteit</item>
                <item>
                    <xsl:value-of select="imf:new-card(//section[@name = $oname and @type='OBJECTTYPE']/section[@type = 'SHORT-ATTRIBUTES']/content/part[item[1]/item = $aname]/item[4])"/>
                </item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEAUTHENTIEK']"/>
            <part type="CFG-DOC-NAAM">
                <item>Domein</item>
                <item>TODO</item>
            </part>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-REGELS-IMBROA']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-TOELICHTING']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEMATERIELEHISTORIE']"/>
            <xsl:apply-templates select="part[@type = 'CFG-DOC-INDICATIEAFLEIDBAAR']"/>
        </content>
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
</xsl:stylesheet>