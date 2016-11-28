<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:imf="http://www.imvertor.org/xsl/functions"

    version="2.0">
    
    <xsl:template match="node()" mode="common-compact">
        <xsl:if test="exists(@*) or normalize-space(.)">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="common-compact"/>
                <xsl:apply-templates select="node()" mode="common-compact"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@*" mode="common-compact">
        <xsl:if test="normalize-space(.)">
            <xsl:copy/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>