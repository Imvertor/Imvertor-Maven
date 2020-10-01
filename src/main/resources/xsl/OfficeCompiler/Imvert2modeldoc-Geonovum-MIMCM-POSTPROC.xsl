<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- no special postproc yet -->
    
    <xsl:template match="section[@type = 'IMAGEMAPS']">
        <xsl:for-each select="section[@type = 'IMAGEMAP']">
            <section type="IMAGE" name="{@name}" id="{@id}">
                <h3>
                    <xsl:value-of select="@name"/>
                </h3>
                <xsl:apply-templates select="."/>
            </section>
        </xsl:for-each>
    </xsl:template>
    
    <!-- defaults -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
