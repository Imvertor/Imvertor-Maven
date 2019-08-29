<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/> 
    
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
   
</xsl:stylesheet>