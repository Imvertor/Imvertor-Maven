<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mim11="http://www.geostandaarden.nl/mim/mim-core/1.1"
  xmlns:mim="http://www.geostandaarden.nl/mim/mim-core/1.2"
  exclude-result-prefixes="mim11"
  version="3.0">
  
  <!-- Converts a MIM serialization in the MIM 1.1 namespace to MIM 1.2 namespace and also changes the schemaLocation -->
  <!-- If the MIM serialization is already in the MIM 1.2 namespace an identity like transformation is exectuted -->
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="/*">
    <mim:Informatiemodel
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.geostandaarden.nl/mim/mim-core/1.2 xsd/1.2/MIMFORMAT_Mim_relatiesoort.xsd">
      <xsl:for-each select="namespace::*[not(. = 'http://www.geostandaarden.nl/mim/mim-core/1.1')]">
        <xsl:namespace name="{name()}" select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="@*[not(local-name() = 'schemaLocation')] | node()"/>
    </mim:Informatiemodel>
  </xsl:template>
  
  <xsl:template match="mim11:*">
    <xsl:element namespace="http://www.geostandaarden.nl/mim/mim-core/1.2" name="mim:{local-name()}">
      <xsl:apply-templates select="@* | node()" />
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>