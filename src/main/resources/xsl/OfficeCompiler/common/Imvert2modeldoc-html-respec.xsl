<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all" 
    version="3.0">
    
    <xsl:import href="../../common/Imvert-common.xsl"/>
    
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:variable name="stylesheet-code">OFFICE-RESPEC</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <!-- 
        create a Respec HTML representation of the section structure 
    -->
    <xsl:variable name="subpath" select="/book/@subpath"/>
    
    <xsl:variable name="imagemap-path" select="imf:get-config-string('properties','WORK_BASE_IMAGEMAP_FILE')"/>
    <xsl:variable name="imagemap" select="imf:document($imagemap-path)/imvert-imap:diagrams"/>
    
    <xsl:variable name="has-multiple-domains" select="count(/book/chapter/section[@type='DOMAIN']) gt 1"/>
    
    <xsl:variable name="document-ids" select="for $id in //@id return string($id)"/>

    <xsl:variable name="meta-is-role-based" select="imf:boolean($configuration-metamodel-file//features/feature[@name='role-based'])"/><!-- TODO duplicate declaration -->
    
    <xsl:template match="/book">
        <xsl:sequence select="imf:track('Generating HTML',())"/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="/book/chapter">
        <section id='{@type}' class="normative"> 
            <h2>
                <xsl:value-of select="imf:translate-i3n(@title,$language-model,())"/>
            </h2>
            
            <xsl:sequence select="imf:insert-chapter-intro(.)"/>
            
            <xsl:variable name="r" as="item()*">
                <xsl:apply-templates select="section" mode="domain"/>
            </xsl:variable>
            <xsl:apply-templates select="$r" mode="windup"/>
        </section>
    </xsl:template>
    
    <xsl:template match="section" mode="domain">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="section" select="."/>
        <xsl:choose>
            <xsl:when test="$has-multiple-domains">
                <xsl:variable name="level" select="imf:get-section-level(.)"/>
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,string(@type),$language-model,string(@name))"/>
                    <xsl:apply-templates select="section" mode="detail"/>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="section" mode="detail"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="section" mode="detail">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="eaid" select="@eaid"/>
        <xsl:variable name="section" select="."/>
        
        <xsl:variable name="level" select="imf:get-section-level(.)"/>
        
        <xsl:choose>
            <!-- verwerken van diagrammen -->
            <xsl:when test="@type = 'IMAGEMAPS'">
               <xsl:call-template name="process-imagemaps"/>     
            </xsl:when>
            <xsl:when test="section[@type = 'IMAGEMAP']"><!-- the type is not IMAGEMAPS -->
                <section id="{$id}" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,string(@type),$language-model,string(@name))"/>
                    <xsl:call-template name="process-imagemaps"/>
                </section>
            </xsl:when>
            <!-- de kop van de details sectie. -->
            <xsl:when test="starts-with(@type,'DETAILS')"> <!-- bijv. DETAILS of DETAILS-OBJECTYPE -->
                <section id="{$id}" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,string(@type),$language-model,())"/>
                    <xsl:apply-templates mode="#current"/>
                </section>
            </xsl:when>
            <xsl:when test="@type = 'EXPLANATION'">
                <section id="{$id}" class="notoc" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,'EXPLANATION',$language-model,())"/>
                    <xsl:apply-templates select="content[not(@approach='association')]/part/item" mode="#current"/>
                </section>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ATTRIBUTES'">
                <xsl:sequence select="imf:create-section-header-name($section,$level,'SHORT-ATTRIBUTES',$language-model,())"/>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ASSOCIATIONS'">
                <xsl:sequence select="imf:create-section-header-name($section,$level,'SHORT-ASSOCIATIONS',$language-model,())"/>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-TYPERELATIONS'">
                <xsl:sequence select="imf:create-section-header-name($section,$level,'SHORT-TYPERELATIONS',$language-model,())"/>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'DETAIL-COMPOSITE-ATTRIBUTE'">
                <xsl:variable name="composer" select="content[not(@approach='association')]/part[@type = 'COMPOSER']/item[1]"/>
                <section id="{$id}" class="notoc" level="{$level}">
                    <xsl:variable name="name">
                        <xsl:if test="exists(../@id-global)">
                            <a href="#{../@id-global}">
                                <xsl:value-of select="../@name"/>
                            </a>
                            <xsl:value-of select="' '"/>
                        </xsl:if>
                        <xsl:value-of select="@name"/>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-section-header-name($section,$level,'COMPOSITE',$language-model,$name)"/>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <xsl:when test="@type = 'DETAIL-COMPOSITE-ASSOCIATION'">
                <xsl:variable name="composer" select="content[not(@approach='association')]/part[@type = 'COMPOSER']/item[1]"/>
                <section id="{$id}" class="notoc" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,'ASSOCIATION',$language-model,concat(' ',@name,' ',imf:translate-i3n('OF-COMPOSITION',$language-model,()),' ',$composer))"/>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <xsl:when test="starts-with(@type,'OVERVIEW-')">
                <section id="{$id}" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,string(@type),$language-model,string(@name))"/>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when> 
            <xsl:when test="@type = ('OBJECTTYPE')"> <!-- objecttypes are in TOC -->
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,string(@type),$language-model,string(@name))"/>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <!-- een detail sectie, deze krijgen geen TOC ingang -->
            <xsl:when test="starts-with(@type,'DETAIL-')">
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}" level="{$level}">
                    <xsl:variable name="name">
                        <xsl:if test="exists(../@id-global)">
                            <a href="#{../@id-global}">
                                <xsl:value-of select="../@name"/>
                            </a>
                            <xsl:value-of select="' '"/>
                        </xsl:if>
                        <xsl:value-of select="@name"/>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-section-header-name($section,$level,@type,$language-model,$name)"/>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}" level="{$level}">
                    <xsl:sequence select="imf:create-section-header-name($section,$level,string(@type),$language-model,string(@name))"/>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:otherwise>
            
        </xsl:choose>
       
    </xsl:template>
 
    <xsl:template match="content" mode="detail">
        <xsl:if test="empty(@approach) or (@approach = 'target' and $meta-is-role-based) or @approach = 'association' and not($meta-is-role-based)">
           <table width="100%">
                <xsl:apply-templates select="part[1]" mode="detail-tabletype"/>
                <xsl:apply-templates select="part[1]" mode="detail-colgroup"/>
                <tbody>
                    <xsl:if test="exists(itemtype)">
                        <tr>
                            <xsl:apply-templates select="itemtype[@type]" mode="#current"/>
                        </tr>
                    </xsl:if>
                    <xsl:apply-templates select="part" mode="#current"/>
                </tbody>
            </table>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="itemtype" mode="detail">
        <th>
            <xsl:value-of select="
                if (normalize-space(.)) then string(.) else
                if (@type) then imf:translate-i3n(@type,$language-model,()) else ''
                "/>
        </th>
    </xsl:template>
    
    <xsl:template match="part" mode="detail-tabletype">
        <xsl:variable name="type" select="ancestor::section/@type"/>
        <xsl:choose>
            <xsl:when test="$type = ('CONTENTS-REFERENCELIST','DETAIL-CODELIST','DETAIL-REFERENCELIST','DETAIL-ENUMERATION')">
                <xsl:attribute name="class">list</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <!-- no css classes -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
    <xsl:template match="part" mode="detail-colgroup">
        <!-- number of items in this part -->
        <xsl:variable name="items" select="count(item)"/>
        <xsl:variable name="type" select="ancestor::section/@type"/>
        
        <xsl:choose>
                <xsl:when test="@type = 'COMPOSER' and $type='DETAIL-COMPOSITE-ATTRIBUTE'">
                    <!-- skip, do not show in detail listings -->
                </xsl:when>
                <xsl:when test="@type = 'COMPOSER'"> <!-- 30 50 10 10 -->
                        <colgroup width="30%"/>
                        <colgroup width="50%"/>
                        <colgroup width="10%"/>
                        <colgroup width="10%"/>
                </xsl:when>
                <xsl:when test="$type = 'EXPLANATION'"> <!-- 100 -->
                        <colgroup width="100%"/>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-ASSOCIATIONS'"> <!-- 50 50 -->
                    <colgroup width="50%"/>
                    <colgroup width="50%"/>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-TYPERELATIONS'"> <!-- 50 50 -->
                    <colgroup width="50%"/>
                    <colgroup width="50%"/>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-ATTRIBUTES'"> <!-- 30 50 10 10 -->
                    <colgroup width="30%"/>
                    <colgroup width="50%"/>
                    <colgroup width="10%"/>
                    <colgroup width="10%"/>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-DATAELEMENTS'"> <!-- 30 50 10 10 -->
                    <colgroup width="30%"/>
                    <colgroup width="50%"/>
                    <colgroup width="10%"/>
                    <colgroup width="10%"/>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-UNIONELEMENTS'"> <!-- 30 50 10 10 -->
                    <colgroup width="30%"/>
                    <colgroup width="50%"/>
                    <colgroup width="10%"/>
                    <colgroup width="10%"/>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-REFERENCEELEMENTS'"> <!-- 30 50 10 10 -->
                    <colgroup width="30%"/>
                    <colgroup width="50%"/>
                    <colgroup width="10%"/>
                    <colgroup width="10%"/>
                </xsl:when>
                
                <xsl:when test="$type = ('CONTENTS-ENUMERATION','CONTENTS-CODELIST') and $items = 2"> <!-- 40 60 -->
                    <colgroup width="40%"/>
                    <colgroup width="60%"/>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-ENUMERATION','CONTENTS-CODELIST') and $items = 3"> <!-- 10 30 60 -->
                    <colgroup width="10%"/>
                    <colgroup width="30%"/>
                    <colgroup width="60%"/>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-ENUMERATION','CONTENTS-CODELIST') and $items = 4"> <!-- 30 10 10 50 -->
                    <colgroup width="30%"/>
                    <colgroup width="10%"/>
                    <colgroup width="10%"/>
                    <colgroup width="50%"/>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-ENUMERATION','CONTENTS-CODELIST') and $items = 5"> <!-- 30 10 10 50 -->
                    <colgroup width="20%"/>
                    <colgroup width="20%"/>
                    <colgroup width="10%"/>
                    <colgroup width="10%"/>
                    <colgroup width="40%"/>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-REFERENCELIST','DETAIL-CODELIST','DETAIL-REFERENCELIST','DETAIL-ENUMERATION')"><!-- when collapsed -->
                    <xsl:variable name="colgroup-config" as="element(colgroup)*">
                        <xsl:variable name="itemtypes" select="../../content/itemtype"/>
                        <xsl:choose>
                            <xsl:when test="count($itemtypes) = 5 and $itemtypes[3]/@type = 'IMBRO'">
                                <colgroup width="20%"/>
                                <colgroup width="20%"/>
                                <colgroup width="5%"/>
                                <colgroup width="5%"/>
                                <colgroup width="50%"/>
                            </xsl:when>
                            <xsl:when test="count($itemtypes) = 4 and $itemtypes[2]/@type = 'IMBRO'">
                                <colgroup width="20%"/>
                                <colgroup width="5%"/>
                                <colgroup width="5%"/>
                                <colgroup width="70%"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="groups" as="element(colgroup)*">
                        <xsl:choose>
                            <xsl:when test="exists($colgroup-config)">
                                <xsl:sequence select="$colgroup-config"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- max number of items found anywhere in contents -->
                                <xsl:variable name="section-items" select="imf:largest(for $part in ancestor::section[1]/content/part return count($part/item))"/>
                                <xsl:variable name="column-size" select="100 div $section-items"/>
                                <xsl:for-each select="for $i in (1 to $section-items) return $i">
                                    <colgroup width="{$column-size}%"/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:sequence select="subsequence($groups,1,$items - 1)"/> 
                    <colgroup/><!-- final colgroup fills up the rest of the table space -->     
                </xsl:when>
                
                <xsl:when test="$items = 2"> <!-- DEFAULT TWO COLUMNS --> <!-- 30 70 -->
                        <colgroup width="30%"/>
                        <colgroup width="70%"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg(.,'FATAL','Unknown modeldoc part: [1], items: [2], processing column group', (string-join($type,', ') ,$items))"></xsl:sequence>
                </xsl:otherwise>
            </xsl:choose>

    </xsl:template>
    
    <xsl:template match="part" mode="detail">
        <xsl:variable name="items" select="count(item)"/>
        <xsl:variable name="type" select="ancestor::section/@type"/>
        <tr>
            <xsl:choose>
                <xsl:when test="@type = 'COMPOSER' and $type='DETAIL-COMPOSITE-ATTRIBUTE'">
                    <!-- skip, do not show in detail listings -->
                </xsl:when>
                <xsl:when test="@type = 'CFG-DOC-INDICATIEAUTHENTIEK'">
                   <!-- add suffix info string -->
                    <th>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </th>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                        <xsl:if test="item[2] eq 'Basisgegeven'">
                            <xsl:text> (niet-authentiek)</xsl:text>
                        </xsl:if> 
                    </td>
                </xsl:when>
                <xsl:when test="@type = 'COMPOSER'"> <!-- 30 50 10 10 -->
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                        <xsl:text>:</xsl:text>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'EXPLANATION'"> <!-- 100 -->
                    <td>
                        <xsl:apply-templates select="item" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-ASSOCIATIONS'"> <!-- 50 50 -->
                    <td>
                        <xsl:if test="@type = 'COMPOSED'">- </xsl:if>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                        <xsl:if test="@type = 'COMPOSER'">:</xsl:if>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-TYPERELATIONS'"> <!-- 50 50 -->
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-ATTRIBUTES'"> <!-- 30 50 10 10 -->
                    <td>
                        <xsl:if test="@type = 'COMPOSED'">- </xsl:if>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                        <xsl:if test="@type = 'COMPOSER'">:</xsl:if>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-DATAELEMENTS'">
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-UNIONELEMENTS'">
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-REFERENCEELEMENTS'">
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-ENUMERATION','CONTENTS-CODELIST') and $items = 2"> <!-- normal without code -->
                    <th>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </th>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-ENUMERATION','CONTENTS-CODELIST') and $items = 3"> <!-- normal with code -->
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-ENUMERATION','CONTENTS-CODELIST') and $items = 4"> <!-- imbroa without code -->
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = ('DETAIL-ENUMERATION','DETAIL-CODELIST') and $items = 5"> <!-- imbroa and code -->
                    <td>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="item[5]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = ('CONTENTS-REFERENCELIST')">
                    <xsl:for-each select="item">
                        <td>
                            <xsl:apply-templates select="." mode="#current"/>
                        </td>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$type = ('DETAIL-CODELIST','DETAIL-REFERENCELIST','DETAIL-ENUMERATION')"><!-- when collapsed -->
                    <xsl:for-each select="item">
                        <td>
                            <xsl:apply-templates select="." mode="#current"/>
                        </td>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$items = 2"> <!-- DEFAULT TWO COLUMNS --> <!-- 30 70 -->
                    <th>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </th>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg(.,'FATAL','Unknown modeldoc part: [1], items: [2], processing columns', (string-join($type,', ') ,$items))"></xsl:sequence>
                </xsl:otherwise>
            </xsl:choose>
        </tr>
    </xsl:template>
    
    <!--<xsl:template match="item/item" mode="detail">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>-->
    
    <!-- when type is traced, show the subpaths of all supplier infos -->
    <xsl:template match="item[@type='TRACED']" mode="detail">
        <xsl:choose>
            <xsl:when test="item[@type = 'SUPPLIER'] ne $subpath">
                <span class="supplier">
                    <xsl:value-of select="item[@type = 'SUPPLIER']"/> <!-- type is SUPPLIER -->
                </span>
            </xsl:when>
            <xsl:otherwise>
                <!-- this is the client info, do not show that subpath. -->         
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="item[not(@type = 'SUPPLIER')]" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="item" mode="#all">
        <xsl:sequence select="imf:create-anchors(.)"/>
        <!-- this has been introduced to support the case of listed enumerations, and to support the case of graph links to compositions i.e. gegevensgroeptype -->
        <xsl:choose>
            <xsl:when test="exists(@idref) and @idref-type='external'">
                <a class="external-link" href="{@idref}"> <!--this is an URL -->
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:when>
            <xsl:when test="exists(@idref) and imf:is-valid-idref(@idref)">
                <a class="link" href="#{@idref}">
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:when>
            <xsl:when test="exists(item)">
                <xsl:apply-templates mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-formatted-text(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="*" mode="windup">
        <xsl:element name="{local-name(.)}"><!-- removing all namespaces -->
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="node()|@*" mode="windup" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()" mode="windup">
        <xsl:variable name="r1">
            <xsl:choose>
                <xsl:when test="contains(.,'[')"><!-- probably debugging -->
                    <xsl:analyze-string select="." regex="\[[a-z]+:.*?\]">
                        <xsl:matching-substring>
                            <span class="debug">
                                <xsl:value-of select="' '|| . || ' '"/>
                            </span>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="r2" select="if (imf:boolean(imf:get-config-parameter('insert-html-wordbreaks'))) then imf:insert-soft-hyphen($r1) else $r1"/>
        <xsl:sequence select="$r2"/>
    </xsl:template>
    
    <xsl:template match="section[@level ge '7']" mode="windup">
        <div class="deepheader">
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </div>
    </xsl:template>
    <xsl:template match="section/@level" mode="windup">
        <!-- remove -->
    </xsl:template>
    <xsl:template match="table/@width" mode="windup">
        <xsl:attribute name="style" select="concat('width: ',.,';')"/>
    </xsl:template>
    <xsl:template match="colgroup/@width" mode="windup">
        <xsl:attribute name="style" select="concat('width: ',.,';')"/>
    </xsl:template>
    <xsl:template match="a/@name" mode="windup">
        <xsl:attribute name="id" select="."/>
    </xsl:template>
    
    <xsl:template name="process-imagemaps">
        <!-- context is a section holding imagemap elements -->
        <xsl:for-each select="section[@type = 'IMAGEMAP']">
            <xsl:variable name="diagram-id" select="@id"/>
            <xsl:variable name="diagram" select="$imagemap/imvert-imap:diagram[imvert-imap:id = $diagram-id]"/>
            <xsl:variable name="diagram-path" select="imf:insert-diagram-path($diagram-id)"/>
            <xsl:variable name="diagram-css-class" select="if ($diagram/imvert-imap:purpose = 'CFG-IMG-OVERVIEW') then 'overview' else ''"/>
            <xsl:variable name="caption-desc" select="content/part[@type='CFG-DOC-DESCRIPTION']/item[2]"/>
            
            <div class="imageinfo {$diagram-css-class}">
                <img src="{$diagram-path}" usemap="#imagemap-{$diagram-id}" alt="Diagram {$caption-desc}"/>
                <map name="imagemap-{$diagram-id}">
                    <xsl:for-each select="$diagram/imvert-imap:map">
                        <xsl:variable name="section-id" select="imvert-imap:for-id"/>
                        <xsl:variable name="section" select="$document//*[@uuid = $section-id]"/><!-- expected are: section or item; but can be anything referenced from within graph by imagemap -->
                        <xsl:if test="$section">
                            <xsl:variable name="section-name" select="$section/@name"/>
                            <area 
                                shape="rect" 
                                alt="{$section-name}"
                                coords="{imvert-imap:loc[@type = 'imgL']},{imvert-imap:loc[@type = 'imgT']},{imvert-imap:loc[@type = 'imgR']},{imvert-imap:loc[@type = 'imgB']}" 
                                href="#graph_{$section-id}"/>
                        </xsl:if>
                    </xsl:for-each>
                </map>
                <!-- create the caption -->
                <p>
                    <b>
                        <xsl:value-of select="content/part[@type='CFG-DOC-NAAM']/item[2]"/>
                    </b>
                    <xsl:value-of select="if (normalize-space($caption-desc)) then concat(' &#8212; ',$caption-desc) else ()"/>
                </p>    
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="imf:create-anchors" as="element()*">
        <xsl:param name="section-or-item"/>
        <xsl:if test="$section-or-item/@uuid">
            <a class="anchor" name="graph_{$section-or-item/@uuid}"/>
        </xsl:if>
        <xsl:if test="$section-or-item/@id">
            <a class="anchor" name="{$section-or-item/@id}"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-section-level" as="xs:integer">
        <xsl:param name="section" as="element(section)"/>
        <xsl:sequence select="count($section/ancestor::section) + (if ($has-multiple-domains) then 3 else 2)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-section-header-element-name" as="xs:string">
        <xsl:param name="level" as="xs:integer"/>
        <xsl:sequence select="concat('h',$level)"/>
    </xsl:function>
    
    <xsl:function name="imf:create-formatted-text" as="item()*">
        <xsl:param name="text"/>
        <xsl:sequence select="$text/node()"/>
    </xsl:function>
    
    <xsl:function name="imf:create-section-header-name" as="element()">
        <xsl:param name="section"/>
        <xsl:param name="level"/>
        <xsl:param name="type"/>
        <xsl:param name="language-model"/>
        <xsl:param name="name"/>

        <xsl:element name="{imf:get-section-header-element-name($level)}">
            <xsl:sequence select="if ($debugging) then '[lvl:' || $level || ']' else ()"/>
            <xsl:sequence select="imf:translate-i3n($type,$language-model,())"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="$name"/>
        </xsl:element>
    </xsl:function>
    
    <xsl:function name="imf:is-valid-idref" as="xs:boolean">
        <xsl:param name="idref" as="xs:string"/>
        <xsl:sequence select="$document-ids = $idref"/>
    </xsl:function>
    
    <xsl:function name="imf:insert-soft-hyphen" as="xs:string">
        <xsl:param name="text"/>
        <xsl:variable name="r" as="xs:string*">
            <xsl:analyze-string select="$text" regex="([a-z]{{1,7}})([A-Z])">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1) || '&#173;' || regex-group(2)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($r,'')"/>
    </xsl:function>
</xsl:stylesheet>