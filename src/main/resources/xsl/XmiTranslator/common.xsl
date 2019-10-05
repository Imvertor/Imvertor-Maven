<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:UML="omg.org/UML1.3"
    
    version="2.0">

    <xsl:function name="imf:compile-sort-key" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="cid" select="$this/@xmi.id"/>
        <xsl:variable name="tag" select="$this/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='tpos'][1]/@value"/>
        <xsl:variable name="pos" select="$this/UML:ModelElement.taggedValue/UML:TaggedValue[@tag=('positie','position','Positie','Position')][1]/@value"/>
        <xsl:choose>
            <xsl:when test="matches($pos,'^\d+$')">
                <xsl:value-of select="imf:left-pad-string-to-length($pos,'0',5)"/>
            </xsl:when>
            <xsl:when test="matches($tag,'^\d+$') and $tag ne '0'">
                <xsl:value-of select="imf:left-pad-string-to-length($tag,'0',5)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('99999.',$cid)"/> <!-- see http://www.sparxsystems.com/forums/smf/index.php/topic,40406.0.html -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>