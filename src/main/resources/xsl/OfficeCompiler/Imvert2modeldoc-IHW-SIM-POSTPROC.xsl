<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- verwijder detail-informatie uit de documentatie -->
    
    <xsl:template match="section[@type = 'DETAILS']">
        <xsl:comment>Verwijderd: detailinformatie</xsl:comment>
    </xsl:template>
    
    <!-- defaults -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
