<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:function name="imf:inspire-notes-sections" as="element(wrap)">
        <xsl:param name="text"/>
        <!-- several kinds of dashes. https://www.cs.tut.fi/~jkorpela/dashes.html -->
        <xsl:variable name="grp" select="'[&#45;&#8208;&#8209;&#8210;&#8211;&#8212;&#8213;&#8722;]{2}'"/>
        <wrap>
            <xsl:analyze-string select="$text" regex="{$grp}\s*(.*?)\s*{$grp}">
                <xsl:matching-substring>
                    <sec>
                        <xsl:value-of select="regex-group(1)"/>
                    </sec>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:variable name="t" select="normalize-space(.)"/>
                    <xsl:if test="$t">
                        <bdy>
                            <xsl:sequence select="imf:inspire-notes-parts(.)"/>
                        </bdy>
                    </xsl:if>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </wrap>
    </xsl:function>
    
    <xsl:function name="imf:inspire-notes-parts" as="element()*">
        <xsl:param name="text"/>
        <xsl:analyze-string select="$text" regex="((DEFINITION)|(SOURCE)|(EXAMPLE)|(URI)|(NOTE))\s+(.*?)\n\s*?(\n|$)" flags="s">
            <xsl:matching-substring>
                <typ>
                    <xsl:value-of select="regex-group(1)"/>
                </typ>
                <val>
                    <xsl:value-of select="regex-group(7)"/>
                </val>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <txt>
                    <xsl:value-of select="."/>
                </txt>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="imf:inspire-notes" as="item()*">
        <xsl:param name="text"/>
        <xsl:variable name="seq" select="imf:inspire-notes-sections($text)"/>
        <xsl:apply-templates select="$seq/sec"  mode="inspire-notes"/>
    </xsl:function>
    
    <xsl:function name="imf:inspire-notes-lines" as="element(line)*">
        <xsl:param name="text"/>
        <xsl:for-each select="tokenize($text,'\n')">
            <xsl:variable name="v" select="normalize-space(.)"/>
            <xsl:if test="$v">
                <line>
                    <xsl:value-of select="$v"/>
                </line>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="sec" mode="inspire-notes">
        <section>
            <title>
                <xsl:value-of select="."/>
            </title>
            <body>
                <xsl:apply-templates select="following-sibling::bdy[1]/typ" mode="inspire-notes"/>
                <xsl:apply-templates select="following-sibling::bdy[1]/txt" mode="inspire-notes"/>
            </body>
        </section>
    </xsl:template>
    
    <xsl:template match="typ" mode="inspire-notes">
        <label type="{.}">
            <xsl:apply-templates select="following-sibling::val[1]" mode="inspire-notes"/>
        </label>
    </xsl:template>
    
    <xsl:template match="val" mode="inspire-notes">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="txt" mode="inspire-notes">
        <xsl:if test="normalize-space(.)">
            <text>
                <xsl:sequence select="imf:inspire-notes-lines(.)"/>
            </text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>