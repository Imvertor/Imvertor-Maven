<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    expand-text="yes"
    version="3.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- defaults -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
