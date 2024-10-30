<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    >
  
    <!-- 
        geef een hash af op basis van alle consonanten in het alfabet. 
    -->
    <xsl:function name="imf:calculate-hashlabel" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="ext:imvertorCalculateHashLabel($string, 'ABCDFGHJKLMNPQRSTVWXYZ' )"/>
    </xsl:function>

    <!-- 
        geef een hash af op basis van alle letters in het alfabet. 
    -->
    <xsl:function name="imf:calculate-hash" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="ext:imvertorCalculateHashLabel($string,'')"/>
    </xsl:function>
    
</xsl:stylesheet>