<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    expand-text="yes"
    version="3.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="section[@type='SHORT-ASSOCIATIONS']/content/part/item[2]">
        <xsl:comment>removed item SHORT-ASSOCIATION</xsl:comment>
    </xsl:template>
    
    <xsl:template match="section[@type='SHORT-ASSOCIATIONS']/content/itemtype[@type=('ASSOCIATION-DEFINITION','ROLE-DEFINITION')]">
        <xsl:comment>removed item ASSOCIATION/ROLE-DEFINITION</xsl:comment>
    </xsl:template>
    
    <xsl:template match="section[@type='OVERVIEW-PRIMITIVEDATATYPE']">
        <xsl:comment>removed section OVERVIEW-PRIMITIVEDATATYPE</xsl:comment>
    </xsl:template>
    
    <xsl:template match="section[@type='OVERVIEW-ENUMERATION']/section/content">
        <!-- plaat hier de inhoud van de enumeratie -->
        <xsl:variable name="uuid" select="../@uuid"/>
        <content>
            <xsl:apply-templates select="*"/>
        </content>
        <xsl:apply-templates select="//section[@type = 'DETAILS-ENUMERATION']/section[@uuid = $uuid]" mode="details-enumeration"/>
    </xsl:template>
   
    <xsl:template match="section" mode="details-enumeration">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="type">SHORT-ENUMS</xsl:attribute>
            <xsl:apply-templates select="content[2]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="section[@type='DETAILS']">
        <xsl:comment>removed section DETAILS</xsl:comment>
    </xsl:template>
    
    <!-- defaults -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
