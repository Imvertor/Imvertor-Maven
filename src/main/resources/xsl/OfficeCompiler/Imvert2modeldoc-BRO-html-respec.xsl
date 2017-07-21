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
        create a Respec HTML representation of the section structure 
    -->
    
    <xsl:template match="/book">
      <h2>Catalogus</h2>
        <p class="note" title="Over deze catalogus">
            Deze catalogus is automatisch samengesteld op basis van het UML model 
            "<xsl:value-of select="@name"/>" door <xsl:value-of select="@version"/> op <xsl:value-of select="imf:format-dateTime(@date)"/>.
           <br/>
            Wanneer je technische fouten of onvolkomenheden aantreft, geef dit dan door aan <i><xsl:value-of select="imf:get-config-string('cli','supportemail')"/></i> en geef de code 
            <i>"<xsl:value-of select="imf:get-config-string('appinfo','release-name')"/>"</i> door. 
            Voor inhoudelijke fouten neem contact op met het modellenteam: <i><xsl:value-of select="imf:get-config-string('cli','contactemail')"/></i>.
        </p>
        <xsl:apply-templates select="section" mode="domain"/>
    </xsl:template>
    
    <xsl:template match="section" mode="domain">
        <xsl:apply-templates select="section" mode="detail"/>
    </xsl:template>
    
    <xsl:template match="section" mode="detail">
        <xsl:variable name="id" select="@id"/>
        <xsl:choose>
            <!-- de kop van de details sectie. -->
            <xsl:when test="@type = 'DETAILS'">
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <section id="{$id}">
                    <xsl:element name="{concat('h',$level)}">
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
                    <h5>
                        <xsl:value-of select="imf:translate-i3n('EXPLANATION',$language-model,())"/>
                    </h5>
                    <xsl:apply-templates select="content/part/item" mode="#current"/>
                </section>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ATTRIBUTES'">
                <h3>
                    <xsl:value-of select="imf:translate-i3n('SHORT-ATTRIBUTES',$language-model,())"/>
                </h3>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'SHORT-ASSOCIATIONS'">
                <h3>
                    <xsl:value-of select="imf:translate-i3n('SHORT-ASSOCIATIONS',$language-model,())"/>
                </h3>
                <xsl:apply-templates mode="detail"/>
            </xsl:when>
            <xsl:when test="@type = 'DETAIL-COMPOSITE-ATTRIBUTE'">
                <xsl:variable name="level" select="count(ancestor::section) + 1"/>
                <xsl:variable name="composer" select="content/part[@type = 'COMPOSER']/item[1]"/>
                <section id="{$id}" class="notoc">
                    <xsl:element name="{concat('h',$level)}">
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
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <xsl:variable name="composer" select="content/part[@type = 'COMPOSER']/item[1]"/>
                <section id="{$id}" class="notoc">
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
                </section>
            </xsl:when>
            <xsl:when test="starts-with(@type,'OVERVIEW-')">
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <section id="{$id}">
                    <xsl:element name="{concat('h',$level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when> 
            <xsl:when test="@type = ('OBJECTTYPE')"> <!-- objecttypes are in TOC -->
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <section id="{$id}">
                    <xsl:element name="{concat('h',$level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <!-- een detail sectie, deze krijgen geen TOC ingang -->
            <xsl:when test="starts-with(@type,'DETAIL-')">
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <section id="{$id}" class="notoc">
                    <xsl:element name="{concat('h',$level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <a href="#{../@id-global}">
                            <xsl:value-of select="../@name"/>
                        </a>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="level" select="count(ancestor::section)"/>
                <section id="{$id}" class="notoc">
                    <xsl:element name="{concat('h',$level)}">
                        <xsl:value-of select="imf:translate-i3n(@type,$language-model,())"/>
                        <xsl:value-of select="' '"/>
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                    <xsl:apply-templates mode="detail"/>
                </section>
            </xsl:otherwise>
            
        </xsl:choose>
       
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
                <xsl:when test="$type = 'SHORT-ATTRIBUTES'"> <!-- 30 50 10 10 -->
                        <colgroup width="30%"/>
                        <colgroup width="50%"/>
                        <colgroup width="10%"/>
                        <colgroup width="10%"/>
                </xsl:when>
                <xsl:when test="$type = 'DETAIL-ENUMERATION' and $items = 2"> <!-- 40 60 -->
                        <colgroup width="40%"/>
                        <colgroup width="60%"/>
                </xsl:when>
                <xsl:when test="$type = 'DETAIL-ENUMERATION' and $items = 3"> <!-- 10 30 60 -->
                        <colgroup width="10%"/>
                        <colgroup width="30%"/>
                        <colgroup width="60%"/>
                </xsl:when>
                <xsl:when test="$items = 2"> <!-- DEFAULT TWO COLUMNS --> <!-- 30 70 -->
                        <colgroup width="30%"/>
                        <colgroup width="70%"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:message select="concat('ONBEKEND: ', string-join($type,', ') , ' - ',$items)"></xsl:message>
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
                <xsl:when test="$type = 'DETAIL-ENUMERATION' and $items = 2"> <!-- 40 60 -->
                    <th>
                        <xsl:apply-templates select="item[1]" mode="#current"/>
                    </th>
                    <td>
                        <xsl:apply-templates select="item[2]" mode="#current"/>
                    </td>
                </xsl:when>
                <xsl:when test="$type = 'DETAIL-ENUMERATION' and $items = 3"> <!-- 10 30 60 -->
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
                    <xsl:message select="concat('ONBEKEND: ', string-join($type,', ') , ' - ',$items)"></xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </tr>
    </xsl:template>
    
    <!--<xsl:template match="item/item" mode="detail">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>-->
    
    <xsl:template match="item" mode="#all">
        <xsl:choose>
            <xsl:when test="exists(@idref)">
                <a class="link" href="#{@idref}">
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
   
    
</xsl:stylesheet>