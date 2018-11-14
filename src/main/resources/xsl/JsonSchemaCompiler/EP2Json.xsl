<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    >
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:template match="/ep:constructs">
        <xsl:sequence select="imf:ep-to-dictionary(text())"/>
    </xsl:template>
    
    <xsl:function name="imf:ep-to-dictionary" as="xs:string*">
        <xsl:param name="entries" as="xs:string*"/>
        <xsl:value-of select="'{'"/>
        <xsl:for-each select="$entries">
            <xsl:value-of select="."/>
            <xsl:if test="position() ne last()">, </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="'}'"/>
    </xsl:function>
</xsl:stylesheet>