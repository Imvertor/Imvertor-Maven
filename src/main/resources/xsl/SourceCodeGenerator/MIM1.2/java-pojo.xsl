<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
  
  <xsl:import href="java-class.xsl"/>
  
  <xsl:param name="package-prefix" as="xs:string" select="'nl.imvertor.pojo'"/>
  <xsl:param name="java-interfaces" as="xs:boolean" select="false()"/>
  <xsl:param name="jpa-annotations" as="xs:boolean" select="false()"/>
  <xsl:param name="swagger-annotatations" as="xs:boolean" select="false()"/>
  
  <xsl:template match="model">
    <java-pojo>
      <xsl:comment> Zie directory "imvertor.41.codegen.java-*" </xsl:comment>
      <xsl:apply-templates>
        <xsl:with-param name="mode" tunnel="yes" select="'pojo'"/>
      </xsl:apply-templates> 
    </java-pojo>
  </xsl:template>
  
</xsl:stylesheet>