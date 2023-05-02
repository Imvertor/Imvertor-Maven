<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mim="http://www.geostandaarden.nl/mim/informatiemodel"
    xmlns:mim-ext="http://www.geostandaarden.nl/mim-ext/informatiemodel"
    xmlns:mim-ref="http://www.geostandaarden.nl/mim-ref/informatiemodel"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    xmlns:pack="http://www.armatiek.nl/packs"
    
    expand-text="yes"
    >
    
    <!-- 
       Deze stylesheet zet de opeenvolging van de EP elementen opnieuw op basis van index en positie 
    -->
    
    <xsl:function name="pack:reorder-ep-structure">
        <xsl:param name="ep-doc" as="document-node(element(ep:group))"/>
        <xsl:apply-templates select="$ep-doc" mode="pack:reorder-ep-structure"/>
    </xsl:function>
    
    <xsl:template match="ep:seq" mode="pack:reorder-ep-structure">
        <xsl:copy>
            <xsl:apply-templates select="*" mode="pack:reorder-ep-structure">
                <xsl:sort select="ep:parameters/ep:parameter[ep:name = 'positie']/ep:value" data-type="number"/>
                <xsl:sort select="ep:parameters/ep:parameter[ep:name = 'index']/ep:value" data-type="number"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="pack:reorder-ep-structure">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>