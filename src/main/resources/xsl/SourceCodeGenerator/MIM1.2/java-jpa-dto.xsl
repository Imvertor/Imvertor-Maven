<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all"
  expand-text="true"
  version="3.0">
    
  <xsl:import href="java-jpa.xsl"/>
  
  <xsl:template match="model">
    <java-jpa-dto>
      <xsl:comment> Zie directory "imvertor.41.codegen.java-jpa-dto" </xsl:comment>
      <xsl:apply-templates>
        <xsl:with-param name="mode" tunnel="yes" select="'entity'"/>
      </xsl:apply-templates>
      <xsl:apply-templates>
        <xsl:with-param name="mode" tunnel="yes" select="'dto'"/>
      </xsl:apply-templates>  
    </java-jpa-dto>
  </xsl:template>
  
</xsl:stylesheet>