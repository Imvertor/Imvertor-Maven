<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    
    expand-text="yes"
    >
    
    <xsl:output method="xml" indent="no" standalone="yes"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="w:t[@xml:space='preserve']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="../../w:pPr/w:pStyle/@w:val = 'Programmacode'">
                    <xsl:value-of select="replace(.,'\s','&#160;')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO oplossen instrText HYPERLINK issue; 
        zie mail Handle w:instrTex for DOCX to HTML conversion
        en https://forum.aspose.com/t/docx-saving-hyperlinks-using-w-hyperlink-instead-of-using-complex-fields/177869/3 
    -->
    
</xsl:stylesheet>