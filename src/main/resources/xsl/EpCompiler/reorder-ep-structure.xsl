<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct/v2"
    
    xmlns:pack="http://www.armatiek.nl/packs"
    
    expand-text="yes"
    >
    
    <!-- 
       Deze stylesheet zet de opeenvolging van de EP elementen opnieuw op basis van index en positie 
    -->
    
    <xsl:function name="pack:reorder-ep-structure">
        <xsl:param name="ep-doc" as="element(ep:group)"/>
        <xsl:apply-templates select="$ep-doc" mode="pack:reorder-ep-structure"/>
    </xsl:function>
    
    <xsl:template match="ep:seq" mode="pack:reorder-ep-structure">
        <xsl:copy>
            <xsl:apply-templates select="*" mode="pack:reorder-ep-structure">
                <xsl:sort select="ep:parameters/ep:parameter[@name = 'positie']" data-type="number"/>
                <xsl:sort select="ep:parameters/ep:parameter[@name = 'index']" data-type="number"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="pack:reorder-ep-structure">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>