<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/config/system">
        <!-- niet kopiëren, bevat systeem paden -->
        <system><xsl:comment>removed</xsl:comment></system>
    </xsl:template>
    
    <xsl:template match="/config/cli-parms">
        <xsl:copy>
            <xsl:apply-templates select="cli-parm">
                <xsl:sort select="name"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/config/clispecs">
        <xsl:copy>
            <xsl:apply-templates select="clispec">
                <xsl:sort select="longKey"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/config/messages">
        <xsl:copy>
            <xsl:apply-templates select="message">
                <xsl:sort select="stepconstruct"/>
                <xsl:sort select="steptext"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/config/(properties | cli | appinfo)">
        <xsl:copy>
            <xsl:apply-templates select="*">
                <xsl:sort select="name()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>