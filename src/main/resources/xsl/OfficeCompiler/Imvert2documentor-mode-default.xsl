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
    
    <xsl:function name="pack:mode-default" as="element(document)">
        <xsl:param name="document" as="element(document)"/>
        <xsl:apply-templates select="$document" mode="pack:mode-default"/>
    </xsl:function>
   
    <xsl:template match="node()|@*"  mode="pack:mode-default">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>