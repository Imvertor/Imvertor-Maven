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
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 

    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:html="http://www.w3.org/1999/xhtml"    
    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- versie info bevindt zich in een apart file -->
    
    <xsl:variable name="empty">--</xsl:variable>
    
    <xsl:variable name="phrase-maxlength" select="3"/>
    <xsl:variable name="phrase-separator" select="'_'"/>
    
    <xsl:variable name="concept-documentation-path" select="imf:get-config-string('appinfo','concepts-file')"/>
    
    <xsl:variable name="concepts" select="imf:document($concept-documentation-path)/imvert:concepts"/>
    
    <xsl:variable name="concept-strings" as="xs:string*">
        <xsl:for-each select="$concepts/imvert:concept">
            <xsl:value-of select="imvert:id"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="must-show-keywords" select="/imvert:packages/imvert:phase = ('0','1') or imf:boolean($debug)"/>
    
    <!-- functions that generate the complete set of phrases -->    
    <!-- sample: "kadastraal_object" for http://www.kadaster.nl/id/begrippen/kadastraal_object -->
    
    <xsl:function name="imf:tokenize" as="xs:string*">
        <xsl:param name="sentence" as="xs:string"/>
        <xsl:analyze-string select="$sentence" regex="([A-Za-z0-9]+)">
            <xsl:matching-substring>
                <xsl:value-of select="lower-case(.)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="imf:get-phrase" as="xs:string*">
        <xsl:param name="tokens" as="xs:string*"/>
        <xsl:param name="tokens-size" as="xs:integer"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="length" as="xs:integer"/>
        <xsl:if test="$index le $tokens-size">
            <xsl:sequence select="imf:make-phrase($tokens,$index,$length)"/>
            <xsl:sequence select="imf:get-phrase($tokens,$tokens-size,$index + 1,$length)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:make-phrase" as="xs:string*">
        <xsl:param name="tokens" as="xs:string*"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="length" as="xs:integer"/>
        <xsl:if test="$length gt 0">
            <xsl:variable name="sub" select="subsequence($tokens,$index,$length)"/>
            <!-- only add when this is a known concept -->
            <xsl:variable name="phrase" select="string-join($sub,$phrase-separator)"/>
            <xsl:if test="$concept-strings = $phrase">
                <xsl:value-of select="$phrase"/>
            </xsl:if>
            <xsl:sequence select="imf:make-phrase($tokens,$index,$length - 1)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:remove-duplicates">
        <xsl:param name="seq" as="xs:string*"/>
        <xsl:sequence select="distinct-values($seq)"/>
    </xsl:function>
    
    <xsl:template match="imvert:packages" mode="documentation">
        <page>
            <title>Documentation</title>
            <content>
                <div>
                    <div class="intro">
                        <p>
                            This table reports all documentation available on all constructs of this application. 
                        </p>
                        <p>
                            The list shows the name of the construct, and next to it the documentation strings. 
                            This is compiled from the underlying model (if any), and the documentation added to this model. 
                            The applicable releases are show right of the name of the application. 
                        </p>
                        <xsl:if test="$must-show-keywords">
                            <p>
                                If concepts are available in the concept store, these are specified below the documentation text; a link to 
                                the concept store is added.
                                This link is not automatically added to any documentation, but inserted here for reference. 
                                The creator may decide to manually insert as a hash mark key (such as: #schip) for this documentation.</p>
                            <p>
                                If documentation is specified below the documentation separator (---), this is removed 
                                and is not made part of the user documentation.
                            </p>
                        </xsl:if>
                    </div>                        
                    <xsl:variable name="rows" as="node()*">
                        <xsl:for-each select=".//imvert:package">
                            <xsl:sort select="imvert:name" order="ascending"/>
                            <xsl:apply-templates select="." mode="documentation"/>
                        </xsl:for-each> 
                    </xsl:variable>
                    <xsl:sequence select="imf:create-result-table($rows,'construct:30,documentation:70')"/>
                </div>
            </content>
        </page>
    </xsl:template>
    
    <xsl:template match="imvert:package | imvert:class | imvert:attribute | imvert:association" mode="documentation">
        <row xmlns="">
            <xsl:sequence select="imf:create-output-element('cell',imf:get-compiled-name-struct(.),$empty, false())"/>
            <xsl:sequence select="imf:create-output-element('cell',imf:get-compiled-documentation-struct(.,$model-is-traced),$empty, false())"/>
        </row>
        <xsl:for-each select="imvert:class | imvert:attributes/imvert:attribute | imvert:associations/imvert:association">
            <xsl:sort select="imvert:name" order="ascending"/>
            <xsl:apply-templates select="." mode="documentation"/>
        </xsl:for-each> 
    </xsl:template>
    
    <xsl:function name="imf:get-compiled-name-struct" as="element()*">
        <xsl:param name="this" as="element()"/>
        <p>
            <xsl:sequence select="imf:get-construct-name($this)"/>
        </p>
        <xsl:if test="$must-show-keywords">
            <xsl:variable name="construct-name" select="lower-case($this/imvert:name)"/>
            <xsl:variable name="result" select="imf:compile-concept-references($construct-name)"/>
            <xsl:variable name="disambiguated-construct-name" select="if ($this/self::imvert:attribute or $this/self::imvert:association) then concat(lower-case($this/../../imvert:name),'.',$construct-name) else ''"/>
            <xsl:variable name="disambiguated-result" select="imf:compile-concept-references($disambiguated-construct-name)"/>
            <xsl:variable name="final-result" select="if ($disambiguated-construct-name and exists($disambiguated-result)) then $disambiguated-result else $result"/>
            <xsl:if test="exists($final-result)">
                <p>
                    <xsl:sequence select="$final-result"/>         
                </p>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <!-- create a element struct from all imvert documentation elements -->
    <xsl:function name="imf:get-compiled-documentation-struct" as="item()*">
        <xsl:param name="construct" as="element()"/> <!-- any construct that may have documentation, in EA format -->
        <xsl:param name="is-traced" as="xs:boolean"></xsl:param>
        <xsl:sequence select="imf:get-compiled-documentation($construct,$is-traced)"/>
    </xsl:function>

    <xsl:function name="imf:compile-concept-references">
        <xsl:param name="construct-names"/>
        <xsl:for-each select="$construct-names">
            <xsl:if test="$concept-strings = .">
                <xsl:variable name="url" select="$concepts/imvert:concept[imvert:id=current()]/imvert:rdf-uri"/>
                <a href="{$url}">
                    <xsl:value-of select="concat('#',.)"/>
                </a>
                <xsl:value-of select="' '"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
 
</xsl:stylesheet>
