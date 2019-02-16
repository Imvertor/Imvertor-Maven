<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    
    <!-- 
        create a Respec HTML representation of the section structure 
    -->
    <xsl:variable name="subpath" select="/book/@subpath"/>
    
    <xsl:variable name="imagemap-path" select="imf:get-config-string('properties','WORK_BASE_IMAGEMAP_FILE')"/>
    <xsl:variable name="imagemap" select="imf:document($imagemap-path)/imvert-imap:diagrams"/>
    
    <xsl:variable name="has-multiple-domains" select="count(/book/chapter/section[@type='DOMAIN']) gt 1"/>
    
    <xsl:template match="/book/chapter">
        <section id='{@type}' class="normative"> 
            <h2>
                <xsl:value-of select="imf:translate-i3n(@title,$language-model,())"/>
            </h2>
            <p>
                <b>Deze tekst is normatief.</b>
                <xsl:comment>
                    <xsl:value-of select="imf:get-config-string('appinfo','release-name')"/> imvertor <xsl:value-of select="@generator-version"/>
                </xsl:comment>
            </p>
            <xsl:apply-templates select="section" mode="domain"/>
        </section>
    </xsl:template>
    
    <xsl:template match="section" mode="domain">
        <xsl:variable name="id" select="@id"/>
        <xsl:choose>
            <xsl:when test="$has-multiple-domains">
                <xsl:variable name="level" select="imf:get-section-level(.)"/>
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
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
        
        <xsl:variable name="level" select="imf:get-section-level(.)"/>
        
        <xsl:choose>
            <!-- verwerken van diagrammen -->
            <xsl:when test="@type = 'IMAGEMAPS'">
                <xsl:for-each select="section[@type = 'IMAGEMAP']">
                    <xsl:variable name="diagram-id" select="@id"/>
                    <xsl:variable name="diagram" select="$imagemap/imvert-imap:diagram[imvert-imap:id = $diagram-id]"/>
                    <xsl:variable name="diagram-path" select="concat('data/Images/',$diagram-id,'.png')"/><!-- TODO as configured -->
                    <xsl:variable name="diagram-css-class" select="if ($diagram/imvert-imap:purpose = 'CFG-IMG-OVERVIEW') then 'overview' else ''"/>
                    
                    <div class="imageinfo {$diagram-css-class}">
                        <img src="{$diagram-path}" usemap="#imagemap-{$diagram-id}"/>
                        <map name="imagemap-{$diagram-id}">
                            <xsl:for-each select="$diagram/imvert-imap:map">
                                <xsl:variable name="section-id" select="imvert-imap:for-id"/>
                                <xsl:variable name="section" select="$document//section[@uuid = $section-id]"/>
                                <xsl:if test="$section">
                                    <xsl:variable name="section-name" select="$section/name"/>
                                    <area 
                                        shape="rect" 
                                        coords="{imvert-imap:loc[@type = 'imgL']},{imvert-imap:loc[@type = 'imgB']},{imvert-imap:loc[@type = 'imgR']},{imvert-imap:loc[@type = 'imgT']}" 
                                        alt="{$section-name}" 
                                        href="#graph_{$section-id}"/>
                                </xsl:if>
                            </xsl:for-each>
                        </map>
                        <!-- create the caption -->
                        <xsl:variable name="caption-desc" select="content/part[@type='CFG-DOC-DESCRIPTION']/item[2]"/>
                        <p>
                            <b>
                                <xsl:value-of select="content/part[@type='CFG-DOC-NAAM']/item[2]"/>
                            </b>
                            <xsl:value-of select="if (normalize-space($caption-desc)) then concat(' &#8212; ',$caption-desc) else ()"/>
                        </p>    
                    </div>
                    <!-- was:
                    <figure id="image-{$diagram-id}" class="scalable">
                        <img src="{$diagram-path}" usemap="#imagemap-{$diagram-id}"/>
                        <figcaption>TODO Onderschrift</figcaption>
                    </figure>
                    -->
                </xsl:for-each>
            </xsl:when>
            <!-- de kop van de details sectie. -->
            <xsl:when test="@type = 'DETAILS'">
                <section id="{$id}">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                    </xsl:element>
                    <xsl:apply-templates mode="#current"/>
                </section>
            </xsl:when>
            <!-- een ingang in de details sectie; komt niet in TOC -->
            <xsl:when test="starts-with(@type,'DETAILS-')">
                <xsl:apply-templates mode="#current"/>
            </xsl:when>
            <xsl:when test="@type = 'EXPLANATION'">
                <section id="{$id}" class="notoc">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n('EXPLANATION',$language-model,())"/>
                    </xsl:element>
                    <xsl:apply-templates select="content[not(@approach='association')]/part/item" mode="#current"/>
                </section>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ATTRIBUTES'">
                <xsl:element name="{imf:get-section-header-element-name($level)}">
                    <xsl:value-of select="imf:translate-i3n('SHORT-ATTRIBUTES',$language-model,())"/>
                </xsl:element>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ASSOCIATIONS'">
                <xsl:element name="{imf:get-section-header-element-name($level)}">
                    <xsl:value-of select="imf:translate-i3n('SHORT-ASSOCIATIONS',$language-model,())"/>
                </xsl:element>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-TYPERELATIONS'">
                <xsl:element name="{imf:get-section-header-element-name($level)}">
                    <xsl:value-of select="imf:translate-i3n('SHORT-TYPERELATIONS',$language-model,())"/>
                </xsl:element>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'DETAIL-COMPOSITE-ATTRIBUTE'">
                <xsl:variable name="composer" select="content[not(@approach='association')]/part[@type = 'COMPOSER']/item[1]"/>
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}" class="notoc">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n('ATTRIBUTE',$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="$composer"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <xsl:when test="@type = 'DETAIL-COMPOSITE-ASSOCIATION'">
                <xsl:variable name="composer" select="content[not(@approach='association')]/part[@type = 'COMPOSER']/item[1]"/>
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}" class="notoc">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n('ASSOCIATION',$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="imf:translate-i3n('OF-COMPOSITION',$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="$composer"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <xsl:when test="starts-with(@type,'OVERVIEW-')">
                <section id="{$id}">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when> 
            <xsl:when test="@type = ('OBJECTTYPE')"> <!-- objecttypes are in TOC -->
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <!-- een detail sectie, deze krijgen geen TOC ingang -->
            <xsl:when test="starts-with(@type,'DETAIL-')">
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:if test="exists(../@id-global)">
                            <a href="#{../@id-global}">
                                <xsl:value-of select="../@name"/>
                            </a>
                            <xsl:value-of select="' '"/>
                        </xsl:if>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-anchors(.)"/>
                <section id="{$id}">
                    <xsl:element name="{imf:get-section-header-element-name($level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:otherwise>
            
        </xsl:choose>
       
    </xsl:template>
 
    <xsl:template match="content[@approach='association']" mode="detail">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="content" mode="detail">
        <table>
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
    </xsl:template>
    
    <xsl:template match="itemtype" mode="detail">
        <th>
            <xsl:value-of select="if (@type) then imf:translate-i3n(@type,$language-model,()) else ''"/>
        </th>
    </xsl:template>
    
    <xsl:template match="part" mode="detail-colgroup">
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
                <xsl:when test="$type = ('DETAIL-ENUMERATION','DETAIL-CODELIST') and $items = 2"> <!-- 40 60 -->
                        <colgroup width="40%"/>
                        <colgroup width="60%"/>
                </xsl:when>
                <xsl:when test="$type = ('DETAIL-ENUMERATION','DETAIL-CODELIST') and $items = 3"> <!-- 10 30 60 -->
                        <colgroup width="10%"/>
                        <colgroup width="30%"/>
                        <colgroup width="60%"/>
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
                <xsl:when test="$type = ('DETAIL-ENUMERATION','DETAIL-CODELIST') and $items = 2"> <!-- 40 60 -->
                    <th>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </th>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = ('DETAIL-ENUMERATION','DETAIL-CODELIST') and $items = 3"> <!-- 10 30 60 -->
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
        <xsl:if test="@id"><!-- this hasd been introduced to support the case of listed enumerations -->
            <a class="anchor" name="{@id}"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="exists(@idref) and @idref-type='external'">
                <a class="external-link" href="{@idref}"> <!--this is an URL -->
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:when>
            <xsl:when test="exists(@idref)">
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
        <xsl:value-of select="count($section/ancestor::section) + (if ($has-multiple-domains) then 3 else 2)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-section-header-element-name" as="xs:string">
        <xsl:param name="level" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$level lt 7">
                <xsl:value-of select="concat('h',$level)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'strong'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:create-formatted-text">
        <xsl:param name="text"/>
        <xsl:for-each select="tokenize($text,'\n')">
            <xsl:value-of select="."/>
            <xsl:if test="position() != last()">
                <br/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    
</xsl:stylesheet>