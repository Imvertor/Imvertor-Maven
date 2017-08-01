<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
    
    <!-- 
        create a standard office oriented HTML representation of the section structure 
    -->
    <xsl:variable name="subpath" select="/book/@subpath"/>
    
    <xsl:template match="/book">
        <html>
            <head>
                <meta charset="UTF-8"/> 
                <style type="text/css">
                    body {
                    font-family:"Calibri","Verdana",sans-serif;
                    font-size:11.0pt;
                    }
                    table {
                    width: 100%;
                    }
                    table, th, td {
                    border: none;
                    font-size:11.0pt;
                    }
                    td {
                    vertical-align: top;
                    }
                    h1, h2, h3, h4 {
                    color:#003359;
                    }
                    h1 {
                    page-break-before:always;
                    font-size:16.0pt;
                    }
                    h2 {
                    font-size:12.0pt;
                    }
                    h3 {
                    font-size:12.0pt;
                    }
                    tr.tableheader {
                    font-style: italic;
                    }
                    a.anchor {
                    color: inherit;
                    text-decoration: none;
                    }
                    a.anchor:hover {
                    color: inherit;
                    text-decoration: underline;
                    }
                    a.link {
                    color: inherit;
                    text-decoration: underline;
                    }
                    a.link:hover {
                    color: blue;
                    text-decoration: underline;
                    }
                    span.supplier {
                        display: block;
                        color: gray;
                    }
                </style>
            </head>
            <body>
                <p>
                    <xsl:value-of select="@type"/>
                    :
                    <xsl:value-of select="@name"/>
                    :
                    <xsl:value-of select="@version"/>
                    :
                    <xsl:value-of select="@date"/>
                </p>
                <p>
                    ID: <xsl:value-of select="@id"/>
                </p>
                <xsl:apply-templates select="section" mode="domain"/>
            </body>
        </html>
        
    </xsl:template>
    
    <xsl:template match="section" mode="domain">
        <div>
            <strong>Domein: <xsl:value-of select="@name"/></strong>
            <xsl:apply-templates select="section" mode="detail"/>
        </div>
    </xsl:template>
    
    <xsl:template match="section" mode="detail">
        <xsl:choose>
            <xsl:when test="@type = 'EXPLANATION'">
                <xsl:sequence select="imf:create-nonheader(imf:translate-i3n('EXPLANATION',$language-model,()))"/>
                <table>
                    <tbody>
                        <tr>
                            <td width="5%">&#160;</td>
                            <td width="95%">
                                <xsl:apply-templates select="content[not(@approach='target')]/part/item" mode="#current"/>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ATTRIBUTES'">
                <xsl:sequence select="imf:create-nonheader(imf:translate-i3n('SHORT-ATTRIBUTES',$language-model,()))"/>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ASSOCIATIONS'">
                <xsl:sequence select="imf:create-nonheader(imf:translate-i3n('SHORT-ASSOCIATIONS',$language-model,()))"/>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'DETAIL-COMPOSITE-ATTRIBUTE'">
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <xsl:variable name="composer" select="content[not(@approach='target')]/part[@type = 'COMPOSER']/item[1]"/>
                <div>
                    <a class="anchor" name="global-{@id}"/>
                    <xsl:element name="{concat('h',$level)}">
                        <xsl:value-of select="imf:translate-i3n('ATTRIBUTE',$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="imf:translate-i3n('OF-COMPOSITION',$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="$composer"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </div>
            </xsl:when>
            <xsl:when test="@type = 'DETAIL-COMPOSITE-ASSOCIATION'">
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <xsl:variable name="composer" select="content[not(@approach='target')]/part[@type = 'COMPOSER']/item[1]"/>
                <div>
                    <a class="anchor" name="global-{@id}"/>
                    <xsl:element name="{concat('h',$level)}">
                        <xsl:value-of select="imf:translate-i3n('ASSOCIATION',$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="imf:translate-i3n('OF-COMPOSITION',$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="$composer"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <div>
                    <a class="anchor" name="global-{@id}"/>
                    <xsl:element name="{concat('h',$level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
       
    </xsl:template>
    
    <xsl:template match="content[@approach='target']" mode="detail">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="content" mode="detail">
        <table>
            <tbody>
                <xsl:if test="exists(itemtype)">
                    <tr>
                        <xsl:apply-templates select="itemtype" mode="#current"/>
                    </tr>
                </xsl:if>
                <xsl:apply-templates select="part" mode="#current"/>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template match="itemtype" mode="detail">
        <td>
            <i>
                <xsl:value-of select="if (@type) then imf:translate-i3n(@type,$language-model,()) else ''"/>
            </i>
        </td>
    </xsl:template>
    
    <xsl:template match="part" mode="detail">
        <xsl:variable name="items" select="count(item)"/>
        <xsl:variable name="type" select="ancestor::section/@type"/>
        <tr>
            <xsl:choose>
                <xsl:when test="@type = ('PATROON','AANDUIDINGSTRIJDIGHEIDNIETIGHEID','REGELS')">
                    <!-- skip, not relevant for Kadaster documentation -->
                </xsl:when>
                <xsl:when test="@type = 'COMPOSER' and $type='DETAIL-COMPOSITE-ATTRIBUTE'">
                    <!-- skip, do not show in detail listings -->
                </xsl:when>
                <xsl:when test="@type = 'COMPOSER'">
                    <td width="5%">&#160;</td>
                    <td width="25%">
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                        <xsl:text>:</xsl:text>
                    </td>
                    <td width="50%">
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td width="10%">
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td width="10%">
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when> 
                <xsl:when test="$type = 'EXPLANATION'">
                    <td width="5%">&#160;</td>
                    <td width="95%">
                        <xsl:apply-templates select="item" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-ASSOCIATIONS'">
                    <td width="5%">&#160;</td>
                    <td width="45%">
                        <xsl:if test="@type = 'COMPOSED'">- </xsl:if>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                        <xsl:if test="@type = 'COMPOSER'">:</xsl:if>
                    </td>
                    <td width="50%">
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'SHORT-ATTRIBUTES'">
                    <td width="5%">&#160;</td>
                    <td width="25%">
                        <xsl:if test="@type = 'COMPOSED'">- </xsl:if>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                        <xsl:if test="@type = 'COMPOSER'">:</xsl:if>
                    </td>
                    <td width="50%">
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td width="10%">
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                    <td width="10%">
                        <xsl:apply-templates select="item[4]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'DETAIL-ENUMERATION' and $items = 2"> 
                    <td width="40%">
                        <b>
                            <xsl:apply-templates select="item[1]" mode="#current"/>
                        </b>
                    </td>
                    <td width="60%">
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'DETAIL-ENUMERATION' and $items = 3"> 
                    <td width="10%">
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </td>
                    <td width="30%">
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                    <td width="60%">
                        <xsl:apply-templates select="item[3]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$items = 2"> <!-- DEFAULT TWO COLUMNS -->
                    <td width="30%">
                        <b>
                            <xsl:apply-templates select="item[1]" mode="#current"/>
                        </b>
                    </td>
                    <td width="70%">
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg(.,'FATAL','Unknown modeldoc part: [1], items: [2]', (string-join($type,', ') ,$items))"></xsl:sequence>
                </xsl:otherwise>
            </xsl:choose>
        </tr>
    </xsl:template>
    
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
        <xsl:choose>
            <xsl:when test="exists(@idref) and @idref-type='external'">
                <a class="external-link" href="{@idref}"> <!--this is an URL -->
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:when>
            <xsl:when test="exists(@idref)">
                <a class="link" href="#global-{@idref}">
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:function name="imf:create-nonheader">
        <xsl:param name="headertext"/>
        <table>
            <tbody>
                <tr>
                    <td width="30%">
                        <b>
                            <xsl:sequence select="$headertext"/>
                        </b>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:function>
    
</xsl:stylesheet>