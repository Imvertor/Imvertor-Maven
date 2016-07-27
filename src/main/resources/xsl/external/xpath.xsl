<xsl:stylesheet 
    version="2.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dn="/Dimitre/Novatchev"
    >
    <!-- 
        adapted from 
        http://stackoverflow.com/questions/4746299/generate-get-xpath-from-xml-node-java/4747858#4747858 
    -->
    <xsl:function name="dn:generate-xpath">
        <xsl:param name="node"/>
        <xsl:apply-templates select="$node" mode="dn:generate-xpath"/>
    </xsl:function>
    
    
    <xsl:template match="*" mode="dn:generate-xpath">
        <xsl:apply-templates select="parent::*"  mode="dn:generate-xpath"/>
        <xsl:value-of select="concat('/',name())"/>
        <xsl:variable name="vnumPrecSiblings" select=
            "count(preceding-sibling::*[name()=name(current())])"/>
        <xsl:if test="$vnumPrecSiblings">
            <xsl:value-of select="concat('[', $vnumPrecSiblings +1, ']')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@*" mode="dn:generate-xpath">
        <xsl:apply-templates select="../parent::*" mode="dn:generate-xpath"/>
        <xsl:value-of select="concat('/@',name())"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="dn:generate-xpath">
        <xsl:apply-templates select="../parent::*" mode="dn:generate-xpath"/>
        <xsl:value-of select="'/text()'"/>
    </xsl:template>
    
    
</xsl:stylesheet>