<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:imf="http://www.imvertor.org/xsl/functions"

    version="2.0">
    
    <xsl:variable name="common-compact-empty-pattern" select="'^~+$'"/>
    <xsl:variable name="common-compact-empty-attribute" select="'cclabel'"/>
    
    <xsl:template match="*" mode="common-compact">
        <xsl:choose>
            <xsl:when test="exists(@*) or normalize-space(.)">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="common-compact"/>
                    <xsl:apply-templates select="node()" mode="common-compact"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:comment>compacted <xsl:value-of select="string-length(.)"/>: <xsl:value-of select="."/>: <xsl:value-of select="name(.)"/></xsl:comment>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
    <xsl:template match="text()" mode="common-compact">
        <xsl:choose>
            <xsl:when test="matches(.,$common-compact-empty-pattern)">
                <!-- remove the "empty" string -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="comment()|processing-instruction()" mode="common-compact">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="@*" mode="common-compact">
        <xsl:choose>
            <xsl:when test="local-name() = $common-compact-empty-attribute">
                <!-- remove -->
            </xsl:when>
            <xsl:when test="normalize-space(.)">
                <xsl:copy/>
            </xsl:when>
            <xsl:otherwise>
                <!-- never output empty attributes -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>