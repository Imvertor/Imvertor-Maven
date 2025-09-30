<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:functx="http://www.functx.com"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:funct="urn:funct"
  xmlns:oas="urn:oas"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
  
  <xsl:function name="oas:to-openapi-query-parameter-name">
    <xsl:param name="str" as="xs:string"/>
    <xsl:variable name="flattened" select="funct:flatten-diacritics(normalize-space($str))" as="xs:string"/>
    <xsl:sequence select="replace($flattened, '[^a-zA-Z_0-9-.~]', '')"/>
  </xsl:function>
  
  <xsl:function name="oas:to-openapi-path-parameter-name">
    <xsl:param name="str" as="xs:string"/>
    <xsl:variable name="flattened" select="funct:flatten-diacritics(normalize-space($str))" as="xs:string"/>
    <xsl:sequence select="replace($flattened, '[^a-zA-Z_0-9-]', '')"/>
  </xsl:function>
  
  <xsl:function name="oas:annotation-field" as="xs:string?">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="value" as="xs:string?"/>
    <xsl:param name="is-string" as="xs:boolean"/>
    <xsl:sequence select="if (normalize-space($value)) 
      then $name || ' = ' || (if ($is-string) then oas:java-string-literal($value) else $value) 
      else ()"/>
  </xsl:function>
  
  <xsl:function name="oas:annotation-field" as="xs:string?">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="value" as="xs:string?"/>
    <xsl:sequence select="oas:annotation-field($name, $value, true())"/>
  </xsl:function>
  
  <xsl:function name="oas:java-string-literal" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:variable name="escaped-str" select="replace(replace($str, '\\', '\\\\'), '&quot;', '\\&quot;')" as="xs:string"/>
    <xsl:choose>
      <!-- Java multiline text block: -->
      <xsl:when test="contains($str, $lf)">"""{$lf}{$escaped-str}"""</xsl:when>
      <xsl:otherwise>"{$escaped-str}"</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>