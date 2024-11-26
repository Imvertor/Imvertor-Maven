<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"

    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2documentor-common.xsl"/>
    <xsl:import href="Imvert2documentor-mode-default.xsl"/>
    <xsl:import href="Imvert2documentor-mode-primer.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:template match="/">
    
        <xsl:choose>
            <xsl:when test="imf:get-xparm('documentor/prop-module') eq 'Primer'">
                <xsl:sequence select="pack:mode-primer(/document)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="pack:mode-default(/document)"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

</xsl:stylesheet>