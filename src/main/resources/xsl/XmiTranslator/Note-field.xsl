<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:variable name="notes-format" select="$configuration-notesrules-file/notes-format"/>
    <xsl:variable name="notes-format-allow-markdown" select="imf:boolean($configuration-notesrules-file/notes-format-allow-markdown)"/>
    
    <xsl:template match="xhtml:p|xhtml:ul|xhtml:ol" mode="notes">
        <xsl:choose>
            <xsl:when test="$notes-format = ('markdown')">
                <xsl:apply-templates mode="notes"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="$notes-format = ('mediawiki')">
                <xsl:apply-templates mode="notes"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="notes"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:b" mode="notes">
        <xsl:choose>
            <xsl:when test="$notes-format = ('markdown')">
                <xsl:value-of select="if (starts-with(.,' ')) then ' **' else '**'"/>  <!--fix <b>text <b></b> -->
                <xsl:apply-templates mode="notes"/>
                <xsl:value-of select="if (ends-with(.,' ')) then '** ' else '**'"/>  <!--fix <b>text <b></b> -->
            </xsl:when>
            <xsl:when test="$notes-format = ('mediawiki')">
                <xsl:value-of select="if (starts-with(.,' ')) then ' &quot;&quot;&quot;' else '&quot;&quot;&quot;'"/> <!--fix <b>text <b></b> -->
                <xsl:apply-templates mode="notes"/>
                <xsl:value-of select="if (ends-with(.,' ')) then '&quot;&quot;&quot; ' else '&quot;&quot;&quot;'"/> <!--fix <b>text <b></b> -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="notes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:i" mode="notes">
        <xsl:choose>
            <xsl:when test="$notes-format = ('markdown')">
                <xsl:value-of select="if (starts-with(.,' ')) then ' *' else '*'"/>  <!--fix <b>text <b></b> -->
                <xsl:apply-templates mode="notes"/>
                <xsl:value-of select="if (ends-with(.,' ')) then '* ' else '*'"/>
            </xsl:when>
            <xsl:when test="$notes-format = ('mediawiki')">
                <xsl:value-of select="if (starts-with(.,' ')) then ' &quot;&quot;' else '&quot;&quot;'"/>
                <xsl:apply-templates mode="notes"/>
                <xsl:value-of select="if (ends-with(.,' ')) then '&quot;&quot; ' else '&quot;&quot;'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="notes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:li" mode="notes">
        <xsl:choose>
            <xsl:when test="$notes-format = ('markdown')">
                <xsl:value-of select="if (parent::xhtml:ul) then '* ' else '1. '"/>
                <xsl:apply-templates mode="notes"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="$notes-format = ('mediawiki')">
                <xsl:value-of select="if (parent::xhtml:ul) then '* ' else '# '"/>
                <xsl:apply-templates mode="notes"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="notes"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:a" mode="notes">
        <xsl:choose>
            <xsl:when test="$notes-format = ('markdown')">
                <xsl:value-of select="concat('[',.,'](',@href,')')"/>
            </xsl:when>
            <xsl:when test="$notes-format = ('mediawiki')">
                <xsl:value-of select="concat('[',@href,' ',.,']')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="notes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xhtml:sup | xhtml:sub" mode="notes">
        <xsl:choose>
            <xsl:when test="$notes-format = ('markdown','mediawiki')">
                <xsl:value-of select="concat('&lt;',local-name(.),'&gt;')"/>
                <xsl:apply-templates mode="#current"/>
                <xsl:value-of select="concat('&lt;/',local-name(.),'&gt;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="notes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*" mode="notes">
        <xsl:apply-templates mode="notes"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="notes">
        <xsl:variable name="in-markup" select="parent::*[local-name(.) = ('i','b')]"/>
        <xsl:variable name="text1" select="if (ends-with(.,' ') and $in-markup) then replace(.,'\s+$','') else ."/>
        <xsl:variable name="text2" select="if (starts-with($text1,' ') and $in-markup) then replace($text1,'^\s+','') else $text1"/>
        <xsl:value-of select="if ($notes-format-allow-markdown) then $text2 else imf:escape-markdown($text2)"/>
    </xsl:template>
    
    <xsl:function name="imf:escape-markdown" as="xs:string*">
        <xsl:param name="line" as="xs:string"/>
        <xsl:variable name="res">
            <xsl:analyze-string select="$line" regex="[\*\[\]`_]|^-\s">
                <xsl:matching-substring>
                    <xsl:value-of select="'\' || ."/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($res,'')"/>
    </xsl:function>
    
</xsl:stylesheet>