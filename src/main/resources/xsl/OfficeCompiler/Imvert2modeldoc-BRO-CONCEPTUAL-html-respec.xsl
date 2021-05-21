<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <xsl:import href="common/Imvert2modeldoc-html-respec.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="resolved">
            <xsl:apply-templates select="/book"/>
        </xsl:variable>
        <section>
            <h1>Gegevensdefinitie</h1>
            <xsl:apply-templates select="$resolved/section/section[2]" mode="reorder1"/>
            <xsl:apply-templates select="$resolved/section/section[1]" mode="reorder1"/>
            <xsl:apply-templates select="$resolved/section/section[3]" mode="reorder1"/>
        </section>
        <section>
            <h1>Uitbreidbare waardelijsten</h1>
            <xsl:apply-templates select="$resolved/section/section[4]/section" mode="reorder2"/>
        </section>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="reorder1 reorder2">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="h3" mode="reorder1">
        <h2>
            <xsl:apply-templates mode="#current"/>
        </h2>
    </xsl:template>
    
    <xsl:template match="h4" mode="reorder1">
        <h3>
            <xsl:apply-templates mode="#current"/>
        </h3>
    </xsl:template>
    
    <xsl:template match="h5" mode="reorder1">
        <h4>
            <xsl:apply-templates mode="#current"/>
        </h4>
    </xsl:template>
    
    <xsl:template match="h4" mode="reorder2">
        <h2>
            <xsl:apply-templates mode="#current"/>
        </h2>
    </xsl:template>
    
    <xsl:template match="h5" mode="reorder2">
        <h3>
            <xsl:apply-templates mode="#current"/>
        </h3>
    </xsl:template>
    
    
    <xsl:function name="imf:insert-chapter-intro" as="item()*">
        <xsl:param name="chapter" as="element(chapter)"/>
        <xsl:comment>
            <xsl:value-of select="imf:get-config-string('appinfo','release-name')"/> imvertor <xsl:value-of select="$chapter/../@generator-version"/>
        </xsl:comment>
    </xsl:function>
    
    <xsl:function name="imf:insert-diagram-path">
        <xsl:param name="diagram-id"/>
        <xsl:value-of select="concat('data/Images/',$diagram-id,'.png')"/>
    </xsl:function>
    
</xsl:stylesheet>