<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:functx="http://www.functx.com"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:funct="urn:funct"
  xmlns:entity="urn:entity"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
    
  <!-- Transformations: -->
  <xsl:variable name="transformation-lower-case" select="'lower-case'" as="xs:string"/>
  <xsl:variable name="transformation-camel-case" select="'camel-case'" as="xs:string"/>
  <xsl:variable name="transformation-pascal-case" select="'pascal-case'" as="xs:string"/>
  <xsl:variable name="transformation-snake-case" select="'snake-case'" as="xs:string"/>
  <xsl:variable name="transformation-kebab-case" select="'kebab-case'" as="xs:string"/>
  
  <xsl:function name="entity:packages" as="element()+">
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="($context/ancestor-or-self::model, $context/ancestor-or-self::domein, $context/ancestor-or-self::view, $context/ancestor-or-self::extern)"/>
  </xsl:function>
  
  <xsl:function name="entity:package-name" as="xs:string">
    <xsl:param name="entity" as="element()"/>
    <xsl:param name="separator" as="xs:string"/>
    <xsl:param name="transformation" as="xs:string"/>
    <xsl:variable name="packages" select="entity:packages($entity)" as="element()+"/>
    <xsl:variable name="package-prefix" select="$entity/ancestor::model/package-prefix" as="xs:string"/>
    <xsl:sequence select="$package-prefix || string-join(for $p in $packages return funct:transform-name($p/name, $transformation), $separator)"/> 
  </xsl:function>
  
  <xsl:function name="entity:feature" as="xs:string*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$context/features/feature[funct:equals-case-insensitive(@name, $name)]/text()[normalize-space()]"/>
  </xsl:function>
    
  <xsl:function name="funct:transform-name" as="xs:string">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="transformation" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$transformation = $transformation-lower-case">{funct:lower-case($name)}</xsl:when>
      <xsl:when test="$transformation = $transformation-camel-case">{funct:camel-case($name)}</xsl:when>
      <xsl:when test="$transformation = $transformation-pascal-case">{funct:pascal-case($name)}</xsl:when>
      <xsl:when test="$transformation = $transformation-snake-case">{funct:snake-case($name)}</xsl:when>
      <xsl:when test="$transformation = $transformation-kebab-case">{funct:kebab-case($name)}</xsl:when>
      <xsl:otherwise>
        <xsl:message>Transformation '{$transformation}' not supported</xsl:message>
        <xsl:value-of select="$name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="funct:lower-case" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="replace(lower-case(normalize-space($str)), '\s+', '')"/>
  </xsl:function>
  
  <xsl:function name="funct:camel-case" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="funct:lowercase-first(functx:words-to-camel-case(normalize-space($str)))"/>
  </xsl:function>
  
  <xsl:function name="funct:pascal-case" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="funct:uppercase-first(functx:words-to-camel-case(funct:lower-case-if-all-uppercase(normalize-space($str))))"/>
  </xsl:function>
  
  <xsl:function name="funct:snake-case" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="replace(lower-case(normalize-space($str)), '\s+', '_')"/>
  </xsl:function>
  
  <xsl:function name="funct:kebab-case" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="replace(lower-case(normalize-space($str)), '\s+', '-')"/>
  </xsl:function>
  
  <xsl:function name="funct:lowercase-first" as="xs:string?">
    <xsl:param name="str" as="xs:string?"/> 
    <xsl:variable name="s" select="normalize-space($str)" as="xs:string"/>
    <xsl:sequence select="concat(lower-case(substring($s,1,1)),substring($s,2))"/>
  </xsl:function>
  
  <xsl:function name="funct:uppercase-first" as="xs:string?">
    <xsl:param name="str" as="xs:string?"/> 
    <xsl:sequence select="functx:capitalize-first(normalize-space($str))"/>
  </xsl:function>
  
  <xsl:function name="funct:is-all-uppercase" as="xs:boolean">
    <xsl:param name="str" as="xs:string?"/> 
    <xsl:sequence select="$str = upper-case($str)"/>
  </xsl:function>
  
  <xsl:function name="funct:lower-case-if-all-uppercase" as="xs:string">
    <xsl:param name="str" as="xs:string?"/> 
    <xsl:sequence select="if (funct:is-all-uppercase($str)) then lower-case($str) else $str"/>
  </xsl:function>
  
  <xsl:function name="funct:flatten-diacritics" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="replace(normalize-unicode($str, 'NFKD'), '\P{IsBasicLatin}', '')"/>  
  </xsl:function>
  
  <xsl:function name="funct:replace-special-chars" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="replacement" as="xs:string"/>
    <xsl:sequence select="replace($str, '[^a-zA-Z_0-9]', $replacement)"/>  
  </xsl:function>
  
  <xsl:function name="funct:equals-case-insensitive" as="xs:boolean">
    <xsl:param name="str1" as="xs:string?"/>
    <xsl:param name="str2" as="xs:string+"/>
    <xsl:sequence select="lower-case(functx:trim($str1)) = (for $s in $str2 return lower-case(functx:trim($s)))"/>
  </xsl:function>
  
  <xsl:function name="funct:split-text" as="xs:string*">
    <xsl:param name="text" as="xs:string?"/>
    <xsl:param name="separator-chars" as="xs:string+"/>
    <xsl:sequence select="if (empty($text)) then () else for $a in tokenize($text, '[' || $separator-chars || ']') return functx:trim($a)"/>
  </xsl:function>
  
  <xsl:function name="funct:split-text" as="xs:string*">
    <xsl:param name="text" as="xs:string?"/>
    <xsl:sequence select="funct:split-text($text, (';'))"/>
  </xsl:function>
  
</xsl:stylesheet>