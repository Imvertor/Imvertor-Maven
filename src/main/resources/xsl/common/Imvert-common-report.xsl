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
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:html="http://www.w3.org/1999/xhtml"    
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="extension/extension-parse-html.xsl"/>
    
    <xsl:variable name="empty">--</xsl:variable>
    
    <xsl:function name="imf:report-key-label" as="node()*">
        <xsl:param name="label" as="xs:string"/>
        <xsl:param name="group" as="xs:string"/>
        <xsl:param name="key" as="xs:string"/>
        <xsl:sequence select="imf:report-label($label,imf:get-config-string($group, $key,'--'))"/>
    </xsl:function>
    
    <xsl:function name="imf:report-label" as="node()*">
        <xsl:param name="label" as="xs:string"/>
        <xsl:param name="value" as="item()*"/>
        <xsl:if test="exists($value)">
            <span class="label">
                <xsl:value-of select="concat($label,': ')"/>
            </span>
            <span class="value">
                <xsl:value-of select="concat(string-join(for $v in $value return string($v),' | '),' ')"/>
            </span>
            <br/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-link-ref" as="node()">
        <xsl:param name="construct-name" as="item()*"/>
        <a>
            <xsl:attribute name="href" select="concat('#',string($construct-name))"/>
            <xsl:value-of select="$construct-name"/>
        </a>
    </xsl:function>
    
    <xsl:function name="imf:create-table-header" as="node()?">
        <xsl:param name="tokens" as="xs:string"/>
        <xsl:sequence select="imf:create-table-header($tokens,true())"/>
    </xsl:function>        
    
    <xsl:function name="imf:create-table-header" as="node()?">
        <xsl:param name="tokens" as="xs:string"/>
        <xsl:param name="add-index" as="xs:boolean"/>
        <xsl:variable name="tokenset" select="tokenize($tokens,',')"/>
        <xsl:if test="(for $x in $tokenset return substring-before($x,':')) != ''">
            <tr class="tableHeader">
                <xsl:if test="$add-index">
                    <th>#</th>
                </xsl:if>
                <xsl:for-each select="$tokenset">
                    <th>
                        <xsl:for-each select="tokenize(substring-before(.,':'),';')">
                            <xsl:value-of select="."/>
                            <xsl:if test="position() != last()"><br/></xsl:if>
                        </xsl:for-each>
                    </th>
                </xsl:for-each>
            </tr>
        </xsl:if> 
    </xsl:function>
    
    <xsl:function name="imf:create-table-rows" as="node()*">
        <xsl:param name="tokens" as="xs:string"/>
        <xsl:for-each select="tokenize($tokens,',')">
            <xsl:variable name="p" select="substring-after(.,':')"/>
            <col>
                <xsl:if test="$p">
                    <xsl:attribute name="style" select="concat('width:',$p,'%')"/>
                </xsl:if>
            </col>
        </xsl:for-each>
    </xsl:function>
  
    <xsl:function name="imf:create-result-table" as="element(table)*">
        <xsl:param name="rows" as="node()*"/>
        <xsl:param name="header" as="xs:string"/>
        <xsl:sequence select="imf:create-result-table($rows,$header,())"/>
    </xsl:function>        
    
    <xsl:function name="imf:create-result-table" as="element(table)*">
        <xsl:param name="rows" as="node()*"/>
        <xsl:param name="header" as="xs:string"/>
        <xsl:param name="table-id" as="xs:string?"/>
        <xsl:variable name="trs" as="element(tr)*">
            <xsl:for-each select="$rows">
                <tr>
                    <xsl:sequence select="if (@class) then @class else ()"/>
                    <xsl:for-each select="cell">
                        <td>
                            <xsl:sequence select="if (normalize-space(.)) then node() else $empty"/>
                        </td>
                    </xsl:for-each>
                </tr>
            </xsl:for-each> 
        </xsl:variable>
        <xsl:sequence select="imf:create-result-table-by-tr($trs,$header,$table-id)"/>
    </xsl:function>
    
    <xsl:function name="imf:create-result-table-by-tr" as="element(table)*">
        <xsl:param name="rows" as="element(tr)*"/>
        <xsl:param name="header" as="xs:string"/>
        <xsl:param name="id" as="xs:string?"/>
        <table>
            <xsl:if test="$id">
                <xsl:attribute name="id" select="$id"/>
                <xsl:attribute name="class" select="'tablesorter'"/>
            </xsl:if>
            <col style="width:5%"/> 
            <xsl:sequence select="imf:create-table-rows($header)"/>
            <thead>
                <xsl:sequence select="imf:create-table-header($header)"/>
            </thead>
            <tbody>
                <xsl:for-each select="$rows">
                    <tr>
                        <xsl:sequence select="@*"/>
                        <td class="ix">
                            <xsl:value-of select="functx:pad-integer-to-length(position(),5)"/>
                        </td>
                        <xsl:sequence select="td"/>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:function>
    
    <xsl:function name="imf:format-documentation-to-html" as="item()*">
        <xsl:param name="doc" as="item()*"/>
        
        <!-- list problems removed: -->
        <xsl:variable name="doc01" select="replace(string($doc),'&lt;/li&gt;\[newline\]','&lt;/li&gt;')"/>
        <xsl:variable name="doc02" select="replace($doc01,'&lt;ul&gt;\[newline\]','&lt;ul&gt;')"/>
        <xsl:variable name="doc03" select="replace($doc02,'&lt;/ul&gt;\[newline\]\s*\[newline\]','&lt;/ul&gt;')"/>
        <xsl:variable name="doc04" select="replace($doc03,'&lt;ol&gt;\[newline\]','&lt;ol&gt;')"/>
        <xsl:variable name="doc05" select="replace($doc04,'&lt;/ol&gt;\[newline\]\s*\[newline\]','&lt;/ol&gt;')"/>
        
        <!-- then translate to HTML -->
        <xsl:variable name="doc1" select="replace($doc05,'\[newline\]','&amp;lt;br/&amp;gt;')"/>
        <xsl:variable name="doc2" select="replace($doc1,'\$inet','http')"/>
        <xsl:variable name="doc3" select="imf:parse-html($doc2,true())"/>
        <xsl:choose>
            <xsl:when test="normalize-space($doc1)">
            
                <!-- translate all xhtml to namespace-less variant -->
                <xsl:variable name="doc4">
                    <xsl:apply-templates select="$doc3" mode="strip-xhtml"/>
                </xsl:variable>
                <xsl:sequence select="$doc4"/>
                
                <!-- TODO find a way to represent the concepts in <imvert:concepts> -->
                <?x
                    <xsl:if test="$must-show-keywords">
                        <xsl:variable name="doctext" select="replace($doc2,'\^p',' ')"/>
                        <xsl:variable name="tokens" select="imf:tokenize($doctext)"/>
                        <xsl:variable name="size" select="count($tokens)"/>
                        <xsl:variable name="fill" select="for $i in 1 to $phrase-maxlength return '#'"/>
                        <xsl:variable name="phrases" select="imf:remove-duplicates(imf:get-phrase(($tokens,$fill),$size,1,$phrase-maxlength))"/>
                        <!-- check if any of the phrases occurs in the list from kenniskluis -->
                        <xsl:variable name="result" select="imf:compile-concept-references($phrases)"/>
                        <xsl:if test="exists($result)">
                            <p>
                                <xsl:sequence select="$result"/>         
                            </p>
                        </xsl:if>
                    </xsl:if>
                    ?>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$empty"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="html:*" mode="strip-xhtml">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="strip-xhtml"/>
        </xsl:element>
    </xsl:template>
   
    <xsl:function name="imf:get-reportable-display-path">
        <xsl:param name="subpath"/>
        <xsl:variable name="basepath" select="imf:get-config-string('system','work-app-folder-path')"/>
        <xsl:value-of select="imf:get-rel-path($basepath,$subpath)"/>
    </xsl:function>

</xsl:stylesheet>