<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:funct="urn:funct"
  xmlns:local="urn:local"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
    
  <xsl:mode name="xhtml"/>
  
  <xsl:function name="funct:feature-to-commonmark" as="xs:string*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:variable name="feature" select="$context/features/feature[funct:equals-case-insensitive(@name, $name)]" as="element(feature)*"/>
    <xsl:for-each select="$feature">
      <xsl:sequence select="funct:element-to-commonmark(.)"/>  
    </xsl:for-each>
  </xsl:function>
  
  <xsl:function name="funct:element-to-commonmark" as="xs:string?">
    <xsl:param name="element" as="element()?"/>  
    <xsl:choose>
      <xsl:when test="not($element)"/>
      <xsl:when test="$element/xhtml:body">
        <xsl:apply-templates select="$element/xhtml:body" mode="xhtml"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$element/text()[normalize-space()]"/>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:function>
  
  <!-- Utility: repeat a character n times -->
  <xsl:function name="local:repeat">
    <xsl:param name="char" as="xs:string"/>
    <xsl:param name="n" as="xs:integer"/>
    <xsl:sequence select="string-join(for $i in 1 to $n return $char, '')"/>
  </xsl:function>
  
  <!-- BODY -->
  <xsl:template match="xhtml:body" mode="xhtml">
    <xsl:variable name="strings" as="xs:string*">
      <xsl:apply-templates mode="#current"/>
      <xsl:text>&#10;</xsl:text>  
    </xsl:variable>
    <xsl:sequence select="string-join($strings)"/>
  </xsl:template>
  
  <!-- HEADINGS -->
  <xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6" mode="xhtml">
    <xsl:variable name="level" select="xs:integer(substring(name(),2))"/>
    <xsl:value-of select="local:repeat('#', $level)"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="#current"/>
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>
  
  <!-- PARAGRAPHS -->
  <xsl:template match="xhtml:p" mode="xhtml">
    <xsl:apply-templates mode="#current"/>
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>
  
  <!-- HORIZONTAL RULE -->
  <xsl:template match="xhtml:hr" mode="xhtml">
    <xsl:text>---</xsl:text>
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>
  
  <!-- STRONG / BOLD -->
  <xsl:template match="xhtml:strong | xhtml:b" mode="xhtml">
    <xsl:text>**</xsl:text>
    <xsl:apply-templates mode="#current"/>
    <xsl:text>**</xsl:text>
  </xsl:template>
  
  <!-- EMPHASIS / ITALIC -->
  <xsl:template match="xhtml:em | xhtml:i" mode="xhtml">
    <xsl:text>*</xsl:text>
    <xsl:apply-templates mode="#current"/>
    <xsl:text>*</xsl:text>
  </xsl:template>
  
  <!-- INLINE CODE -->
  <xsl:template match="xhtml:code[not(ancestor::xhtml:pre)]" mode="xhtml">
    <xsl:text>`</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>`</xsl:text>
  </xsl:template>
  
  <!-- PRE / CODE BLOCK -->
  <xsl:template match="xhtml:pre" mode="xhtml">
    <xsl:variable name="lang" select="tokenize(@class, '\s+')[1]"/>
    <xsl:text>```</xsl:text>
    <xsl:value-of select="$lang"/>
    <xsl:text>&#10;</xsl:text>
    <!-- preserve raw content inside pre -->
    <xsl:value-of select="string(.)"/>
    <xsl:text>&#10;```&#10;&#10;</xsl:text>
  </xsl:template>
  
  <!-- LINKS -->
  <xsl:template match="xhtml:a" mode="xhtml">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="#current"/>
    <xsl:text>]</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(@href)"/>
    <xsl:choose>
      <xsl:when test="@title">
        <xsl:text> "</xsl:text><xsl:value-of select="normalize-space(@title)"/><xsl:text>"</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <!-- IMAGES -->
  <xsl:template match="xhtml:img" mode="xhtml">
    <xsl:text>![</xsl:text>
    <xsl:value-of select="normalize-space(@alt)"/>
    <xsl:text>]</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(@src)"/>
    <xsl:if test="@title">
      <xsl:text> "</xsl:text><xsl:value-of select="normalize-space(@title)"/><xsl:text>"</xsl:text>
    </xsl:if>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <!-- BLOCKQUOTE -->
  <xsl:template match="xhtml:blockquote" mode="xhtml">
    <!-- prefix each generated line with "> " -->
    <xsl:variable name="content">
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:variable>
    <xsl:for-each select="tokenize(string($content), '\r?\n')">
      <xsl:value-of select="concat('> ', .)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <!-- LISTS: pass indent param -->
  <xsl:template name="process-list">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="indent" as="xs:integer" select="0"/>
    <xsl:choose>
      <xsl:when test="$node/self::xhtml:ul">
        <xsl:for-each select="$node/xhtml:li">
          <xsl:text>
</xsl:text>
          <xsl:value-of select="local:repeat(' ', $indent)"/>
          <xsl:text>- </xsl:text>
          <xsl:apply-templates select="node()[not(self::xhtml:ul or self::xhtml:ol)]" mode="#current"/>
          <!-- handle nested lists inside this li -->
          <xsl:for-each select="xhtml:ul|xhtml:ol">
            <xsl:call-template name="process-list">
              <xsl:with-param name="node" select="."/>
              <xsl:with-param name="indent" select="$indent + 2"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$node/self::xhtml:ol">
        <xsl:for-each select="$node/li">
          <xsl:text>
</xsl:text>
          <xsl:value-of select="local:repeat(' ', $indent)"/>
          <xsl:value-of select="count(preceding-sibling::li) + 1"/>
          <xsl:text>. </xsl:text>
          <xsl:apply-templates select="node()[not(self::xhtml:ul or self::xhtml:ol)]" mode="#current"/>
          <xsl:for-each select="xhtml:ul|xhtml:ol">
            <xsl:call-template name="process-list">
              <xsl:with-param name="node" select="."/>
              <xsl:with-param name="indent" select="$indent + 2"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- UL / OL entry points -->
  <xsl:template match="xhtml:ul | xhtml:ol" mode="xhtml">
    <xsl:call-template name="process-list">
      <xsl:with-param name="node" select="."/>
      <xsl:with-param name="indent" select="0"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <!-- REMOVE SCRIPT / STYLE -->
  <xsl:template match="xhtml:script | xhtml:style" mode="xhtml"/>
  
  <!-- FALLBACK: process inline nodes and text -->
  <xsl:template match="*" mode="xhtml">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- TEXT: collapse sequences of whitespace to single spaces, preserve important whitespace in pre handled above -->
  <xsl:template match="text()" mode="xhtml">
    <xsl:value-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>