<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
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
    
    <!-- verwijder detail-informatie van enumeraties die leeg zijn -->
    
    <xsl:template match="section[@type = 'DETAIL-ENUMERATION']">
        <xsl:choose>
            <xsl:when test="content[itemtype/@type = 'VALUE' and empty(part)]">
                <xsl:comment>Verwijderd: enumeratie zonder inhoud</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="section[@type = 'DETAILS-ENUMERATION']">
        <xsl:variable name="resolved" as="node()*">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="empty($resolved/self::section)">
                <xsl:comment>Verwijderd: geen enumeraties met inhoud</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="section[@type = 'DETAILS']">
        <xsl:variable name="resolved" as="node()*">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="empty($resolved/self::section)">
                <xsl:comment>Verwijderd: geen details sectie met inhoud</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- defaults -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
