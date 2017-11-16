<?xml version="1.0" encoding="UTF-8"?>

<!-- generic pretty printer for XML -->

<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
 
    <xsl:function name="imf:pretty-print" as="node()?">
        <xsl:param name="document" as="document-node()?"/>
        <xsl:param name="mixed-content" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="$mixed-content">
                <xsl:apply-templates select="$document" mode="imf:pretty-print-mixed"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$document" mode="imf:pretty-print-admin"/>        
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/" mode="imf:pretty-print-mixed imf:pretty-print-admin">
        <xsl:apply-templates select="*" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*" mode="imf:pretty-print-mixed imf:pretty-print-admin">
        <xsl:choose>
            <xsl:when test="empty(parent::*)">
                <xsl:copy>
                    <xsl:copy-of select="descendant::*/namespace::*"/>
                    <xsl:apply-templates select="node()|@*" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="node()|@*" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*" mode="imf:pretty-print-mixed imf:pretty-print-admin">
        <xsl:copy copy-namespaces="no"/>
    </xsl:template>
    
    <xsl:template match="comment()" mode="imf:pretty-print-mixed imf:pretty-print-admin">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="processing-instruction()" mode="imf:pretty-print-mixed imf:pretty-print-admin">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="text()" mode="imf:pretty-print-admin">
        <xsl:choose>
            <xsl:when test="normalize-space()">
                <!-- e.g. <a>x</a> -->
                <xsl:copy/>
            </xsl:when>
            <xsl:otherwise>
                <!-- e.g. <a> <b/> <?x test?> </a> -->
                <!-- empty; remove spaces between nodes -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()" mode="imf:pretty-print-mixed">
        <xsl:copy/>
    </xsl:template>
       
</xsl:stylesheet>
