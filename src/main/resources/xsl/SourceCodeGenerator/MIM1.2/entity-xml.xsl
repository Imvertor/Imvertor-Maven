<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:functx="http://www.functx.com"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:local="urn:local"
  xmlns:entity="urn:entity"
  xmlns:funct="urn:funct"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:import href="mim-2-entities.xsl"/>
  
  <xsl:include href="entity-functions.xsl"/>
    
  <xsl:variable name="primitive-mim-type-mapping" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'CharacterString'" select="'String'"/>
      <xsl:map-entry key="'Integer'" select="'Integer'"/>
      <xsl:map-entry key="'Real'" select="'Double'"/>
      <xsl:map-entry key="'Decimal'" select="'Double'"/>
      <xsl:map-entry key="'Boolean'" select="'Boolean'"/>
      <xsl:map-entry key="'Date'" select="'LocalDate'"/>
      <xsl:map-entry key="'DateTime'" select="'LocalDateTime'"/>
      <xsl:map-entry key="'Year'" select="'Short'"/>
      <xsl:map-entry key="'Day'" select="'Byte'"/>
      <xsl:map-entry key="'Month'" select="'Byte'"/>
      <xsl:map-entry key="'URI'" select="'String'"/>
    </xsl:map>
  </xsl:variable>
    
  <xsl:function name="entity:package-name">
    <xsl:param name="package-hierarchy" as="xs:string*"/>
    <xsl:sequence select="string-join((for $p in $package-hierarchy return funct:lower-case($p)), '.')"/>
  </xsl:function>
  
  <xsl:function name="entity:class-name">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="funct:pascal-case($name)"/>
  </xsl:function>

  <xsl:function name="entity:field-name">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="funct:camel-case($name)"/>
  </xsl:function>
  
  <xsl:function name="entity:enum-value" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="funct:replace-special-chars(upper-case(funct:snake-case(funct:flatten-diacritics($str))), '_')"/>  
  </xsl:function>
  
  <xsl:template match="model">
    <xsl:copy>
      <xsl:apply-templates mode="identity"/>  
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|node()" mode="identity">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>