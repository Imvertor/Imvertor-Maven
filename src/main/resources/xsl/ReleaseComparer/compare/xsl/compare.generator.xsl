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
    
    xmlns:xslr="http://www.w3.org/1999/XSL/Transform/Result"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    version="2.0">

    <xsl:param name="ctrl-filepath"/>
    <xsl:param name="test-filepath"/>
    <xsl:param name="diff-filepath"/>
    
    <!-- 
        This file processes a diff file and generates a XSLT file which may be included into another client XSLT. 
        This client XSLT must implement the handling of all differencing conditions, in mode "compare".
    -->

    <xsl:output indent="no"/>
    
    <xsl:namespace-alias stylesheet-prefix="xslr" result-prefix="xsl"/>

    <xsl:variable name="diff-url" select="concat('file:/', replace($diff-filepath,'\\','/'))"/>
    <xsl:variable name="ctrl-url" select="concat('file:/', replace($ctrl-filepath,'\\','/'))"/>
    <xsl:variable name="test-url" select="concat('file:/', replace($test-filepath,'\\','/'))"/>

    <xsl:variable name="quot">'</xsl:variable>
    <xsl:variable name="rootstring">/root-of-compare[1]/</xsl:variable>
    <!-- 
        This file processes a control file, comparing it to a test file. 
        It creates a diffs file.
    -->
    <xsl:template match="/">
        <xsl:variable name="result" select="ext:imvertorCompareXml($ctrl-filepath,$test-filepath,$diff-filepath)" as="xs:boolean"/>
        <xslr:stylesheet version="2.0">
            <xsl:choose>
                <xsl:when test="$result">
                   <!-- no template calls needed --> 
                </xsl:when>
                <xsl:otherwise>
                   <xsl:variable name="doc" select="document($diff-url)"/>
                    <xsl:variable name="doc-clean">
                        <xsl:apply-templates select="$doc/diffs" mode="clean-adds"/>
                    </xsl:variable>
                   <xsl:apply-templates select="$doc-clean/diffs"/>
                </xsl:otherwise>
            </xsl:choose>
        </xslr:stylesheet>
    </xsl:template>
   
    <!-- remove all additions that are dependent on a higher level structure addition -->
    <xsl:template match="/diffs" mode="clean-adds">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="diff" mode="clean-adds"/>
        </xsl:copy>
    </xsl:template>        
    
    <!-- 
        We verwijderen uit de diff lijst alle additions die feitelijk teruggaan op een addition van een hogere struktuur.
        Bijv. addition van C.a1 is wiedus als addition van C.
        Helaas moeten we dat doen op een relatief domme manier: door string vergelijking.
    -->
    <xsl:template match="diff" mode="clean-adds">
        <xsl:variable name="parts" select="tokenize(substring-before(substring-after(test/@path,$rootstring),'['),'-')"/>
        <xsl:variable name="prop-pattern" select="concat($rootstring, string-join(($parts[1],$parts[2],$parts[3],$parts[4],$parts[5]),'-'),'-[')"/>
        <xsl:variable name="class-pattern" select="concat($rootstring, string-join(($parts[1],$parts[2],$parts[3]),'-'),'[')"/>
        <xsl:variable name="pack-pattern" select="concat($rootstring, string-join(($parts[1],$parts[2]),'-'),'[')"/>
        <xsl:variable name="copy" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="empty($parts)">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:when test="not(@desc='presence of child node' and ctrl/@path='null')">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:when test="exists(preceding-sibling::diff[@desc='presence of child node' and ctrl/@path='null' and (starts-with(test/@path,$prop-pattern) or starts-with(test/@path,$class-pattern) or starts-with(test/@path,$pack-pattern))])">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="true()"/>
                </xsl:otherwise>
            </xsl:choose>   
        </xsl:variable>
        <xsl:if test="$copy">
            <xsl:sequence select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="/diffs">
       
        <xslr:template match="node()" mode="compare" priority="0"> <!-- low priority, reached last --> 
            <xslr:param name="diff" as="xs:string?"/>
            <xslr:param name="test" as="item()?"/>
            <xslr:apply-templates mode="compare">
                <xslr:with-param name="diff" select="$diff"/>
                <xslr:with-param name="test" select="$test"/>
            </xslr:apply-templates>
        </xslr:template> 
        <!-- first report on constructs changed or removed in control -->
        <xsl:for-each-group select="diff[starts-with(ctrl/@path,'/')]" group-by="ctrl/@path">
            <xsl:variable name="xpath-ctrl">
                <xsl:apply-templates select="ctrl/@path">
                    <xsl:with-param name="role">ctrl</xsl:with-param>
                </xsl:apply-templates>
            </xsl:variable>
            <xslr:template match="{$xpath-ctrl}" mode="compare" priority="1">
                <xsl:for-each select="current-group()">
                    <xsl:variable name="xpath-test">
                        <xsl:apply-templates select="test/@path">
                            <xsl:with-param name="role">test</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xslr:call-template name="report">
                        <xslr:with-param name="ctrl" select="."/>
                        <xslr:with-param name="test" select="$test-doc{$xpath-test}"/>
                        <xslr:with-param name="diff">
                            <xsl:apply-templates select="." mode="diff"/>
                        </xslr:with-param>
                    </xslr:call-template>
                </xsl:for-each>
                <xslr:next-match>
                    <xslr:with-param name="ctrl" select="."/>
                </xslr:next-match>
            </xslr:template>
        </xsl:for-each-group>
        <!-- then report on constructs added in test -->
        <xsl:for-each-group select="diff[ctrl/@path = 'null']" group-by="test/@path">
            <xsl:variable name="xpath-test">
                <xsl:apply-templates select="test/@path">
                    <xsl:with-param name="role">test</xsl:with-param>
                </xsl:apply-templates>
            </xsl:variable>
            <xslr:template match="{$xpath-test}" mode="compare" priority="1">
                <xsl:for-each select="current-group()">
                    <xslr:call-template name="report">
                        <xslr:with-param name="ctrl" select="$ctrl-doc/nonexist"/>
                        <xslr:with-param name="test" select="$test-doc{$xpath-test}"/>
                        <xslr:with-param name="diff">
                            <xsl:apply-templates select="." mode="diff"/>
                        </xslr:with-param>
                    </xslr:call-template>
                </xsl:for-each>
                <xslr:next-match>
                    <xslr:with-param name="test" select="."/>
                </xslr:next-match>
            </xslr:template>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="@path">
        <xsl:param name="role"/>
        <xsl:variable name="tokens" select="tokenize(.,'/')"/>
        <xsl:for-each select="$tokens">
            <xsl:variable name="index" select="position()"/>
            <xsl:choose>
                <xsl:when test=".=''">
                    <!--skip-->
                </xsl:when>
                <xsl:when test="starts-with(.,'text()')">
                    <xsl:value-of select="concat('/',.)"/>
                </xsl:when>
                <xsl:when test="starts-with(.,'comment()')">
                    <xsl:value-of select="concat('/',.)"/>
                </xsl:when>
                <xsl:when test="starts-with(.,'processing-instruction()')">
                    <xsl:value-of select="concat('/',.)"/>
                </xsl:when>
                <xsl:when test="starts-with(.,'@')">
                    <xsl:value-of select="concat('/',.)"/>
                </xsl:when>
                <xsl:when test=". = 'null'">
                    <xsl:value-of select="'/nonexist'"/>
                </xsl:when>
                <xsl:when test="$index = 2">
                    <xsl:value-of select="concat('/*:',.,'[@role=',$quot, $role,$quot,']')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('/*:',.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*" mode="diff">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="diff"/>
            <xsl:apply-templates mode="diff"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*" mode="diff">
        <xsl:attribute name="{name()}">
            <xsl:variable name="lbr">{</xsl:variable>
            <xsl:variable name="rbr">}</xsl:variable>
            <xsl:value-of select="replace(replace(.,concat('\',$lbr),concat($lbr,$lbr)),concat('\',$rbr),concat($rbr,$rbr))"/>
        </xsl:attribute>
    </xsl:template>
        
</xsl:stylesheet>