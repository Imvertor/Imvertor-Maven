<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <xsl:template match="/">
        <elm>
            <xsl:for-each-group select="//*" group-by="concat(name(..),'/',name(.))">
               <xsl:sort select="name(.)"/>
               <xsl:value-of select="concat(current-grouping-key(),'&#10;')"/>
            </xsl:for-each-group>
        </elm>
    </xsl:template>
    
</xsl:stylesheet>