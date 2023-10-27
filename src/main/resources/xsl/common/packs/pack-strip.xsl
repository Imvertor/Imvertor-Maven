<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
   
   xmlns:pack="http://www.armatiek.nl/packs"
   >
    
    <!--
        Pack:
        verwijder alle namespaces en prefixes
    -->

    <xsl:function name="pack:strip" as="item()*">
        <xsl:param name="items" as="item()*"/>
        <xsl:apply-templates select="$items" mode="pack:strip"/>
    </xsl:function>

    <xsl:template match="*" mode="pack:strip">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@* | processing-instruction() | comment() | text()" mode="pack:strip">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
