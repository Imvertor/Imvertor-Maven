<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:amf="http://www.armatiek.nl/functions"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    >
    <xsl:import href="extension/extension-parse-html.xsl"/>
    
    
    <!-- ============================= transform an EA string to xhtml. ====================================== -->
    <xsl:function name="imf:eadoc-to-xhtml" as="element()">
        <xsl:param name="eadoc"/>
        <xsl:variable name="lis" select="replace($eadoc,'&lt;/li&gt;(&#xA;)+','&lt;/li&gt;')"/>
        <xsl:variable name="startp" select="concat('&#xA;',$lis)"/>
        <xsl:variable name="nl" select="replace($startp,'&#xA;','&lt;p&gt;')"/>
        <xsl:variable name="inet" select="imf:replace-inet-references($nl)"/>
        <xsl:variable name="xhtml" select="imf:parse-html($inet,true())"/>
        <xsl:variable name="clean">
            <xsl:apply-templates select="$xhtml" mode="clean-xhtml"/>
        </xsl:variable>
        <xsl:sequence select="$clean/*"/>
    </xsl:function>
    
    <xsl:function name="imf:replace-inet-references" as="xs:string">
        <xsl:param name="content"/>
        <xsl:variable name="r">
            <xsl:analyze-string select="$content" regex="(&quot;\$inet://)([^&quot;]+)">
                <xsl:matching-substring>
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(2),'http')">
                            <xsl:value-of select="concat('&quot;',regex-group(2))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('&quot;http://',regex-group(2))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>     
        </xsl:variable>
        <xsl:value-of select="$r"/>
    </xsl:function>
    
    <xsl:template match="html:html" mode="clean-xhtml">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="html:*" mode="clean-xhtml">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:ul[not(*)]" mode="clean-xhtml"/>
    <xsl:template match="html:ol[not(*)]" mode="clean-xhtml"/>
    
    <!-- remove the constructs: 
        <p/>
		<p> </p>
	-->
    <xsl:template match="html:p[empty(node()) and following-sibling::html:p[1][matches(.,'^\s$')]]" mode="clean-xhtml">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="html:p[matches(.,'^\s$') and preceding-sibling::html:p[1][empty(node())]]" mode="clean-xhtml">
        <!-- remove  -->
    </xsl:template>
    
    <!-- ============================= transform xhtml to a eadoc string ====================================== -->
    
    <xsl:function name="imf:xhtml-to-eadoc" as="item()*">
        <xsl:param name="xhtml-body" as="element()"/>
        <xsl:variable name="eadoc">
            <xsl:apply-templates select="$xhtml-body/*" mode="eadoc"/>
        </xsl:variable>
        <xsl:value-of select="$eadoc"/>
    </xsl:function>
    
    <xsl:template match="html:*" mode="eadoc">
        <xsl:value-of select="concat('&lt;', local-name())"/>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:value-of select="'&gt;'"/>
        <xsl:if test="self::html:ul or self::html:ol">
            <xsl:value-of select="'&#xA;'"/>
        </xsl:if>
        <xsl:apply-templates mode="#current"/>
        <xsl:value-of select="concat('&lt;/', local-name(), '&gt;')"/>
        <xsl:if test="self::html:ul or self::html:ol or self::html:li">
            <xsl:value-of select="'&#xA;'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@*" mode="eadoc">
        <xsl:value-of select="concat(' ', local-name(),'=&quot;')"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="'&quot;'"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="eadoc">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="html:p" mode="eadoc">
        <xsl:apply-templates mode="#current"/>
        <xsl:value-of select="'&#xA;'"/>
    </xsl:template>
    
    <!-- Documentation takes the form of HTML fragments. Flatten out here in order to builds a reasonable annotation string content for XSD context. --> 
    
    <xsl:function name="imf:xhtml-to-flatdoc" as="xs:string">
        <xsl:param name="xhtml-body" as="item()*"/>
        <xsl:variable name="flatdoc">
            <xsl:apply-templates select="$xhtml-body" mode="flatdoc"/>
        </xsl:variable>
        <xsl:value-of select="$flatdoc"/>
    </xsl:function>
    
    <xsl:template match="html:*" mode="flatdoc">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="flatdoc">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
    </xsl:template>
    
    <xsl:template match="html:p" mode="flatdoc">
        <xsl:apply-templates mode="#current"/>
        <xsl:value-of select="'&#xA;'"/>
    </xsl:template>
    <xsl:template match="html:ul/html:li" mode="flatdoc">
        <xsl:value-of select="'* '"/>
        <xsl:apply-templates mode="#current"/>
        <xsl:value-of select="'&#xA;'"/>
    </xsl:template>
    <xsl:template match="html:ol/html:li" mode="flatdoc">
        <xsl:value-of select="'# '"/>
        <xsl:apply-templates mode="#current"/>
        <xsl:value-of select="'&#xA;'"/>
    </xsl:template>
    
</xsl:stylesheet>