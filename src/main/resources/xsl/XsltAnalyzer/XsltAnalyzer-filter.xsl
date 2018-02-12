<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    >
    
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    
    <xsl:template match="/cw:files">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="cw:file[@type='xml' and @ext='xsl']">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="node()">
        <!-- ignore -->
    </xsl:template>
</xsl:stylesheet>