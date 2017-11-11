<?xml version="1.0" encoding="UTF-8"?>

<!-- generic pretty printer for XML -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:param name="xml-mixed-content" select="'false'"/> <!-- if mixed content occurs, set true. -->
    
    <xsl:template match="/">
        <!--<xsl:comment>Cleaned (as <xsl:value-of select="if ($xml-mixed-content = 'false') then 'administrative data' else 'textual data'"/>)</xsl:comment>-->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="*|processing-instruction()|comment()">
                    <xsl:apply-templates select="*|processing-instruction()|comment()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
 
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>