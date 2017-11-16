<?xml version="1.0" encoding="UTF-8"?>

<!-- generic pretty printer for XML -->

<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:function name="imf:pretty-print">
        <xsl:param name="document"/>
        <xsl:param name="mixed-content"/>
        <xsl:choose>
            <xsl:when test="$mixed-content">
                <xsl:apply-templates select="root($document)" mode="imf:pretttyprint-mixed"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="root($document)" mode="imf:pretttyprint-admin"/>        
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/*" mode="#all">
        <xsl:copy>
            <xsl:copy-of select="descendant::*/namespace::*"/>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="#all">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*" mode="#all">
        <xsl:copy copy-namespaces="no"/>
    </xsl:template>
    
    <xsl:template match="comment()" mode="#all">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="processing-instruction()" mode="#all">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="text()" mode="imf:pretttyprint-admin">
        <xsl:choose>
            <xsl:when test="normalize-space()">
                <!-- e.g. <a>x</a> -->
                <xsl:copy/>
            </xsl:when>
            <xsl:when test="../*">
                <!-- e.g. <a> </a> -->
                <!-- empty; remove spaces between elements -->
            </xsl:when>
            <xsl:otherwise>
                <!-- e.g. <a> <?x test?></a> -->
                <!-- empty; remove spaces between other nodes -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()" mode="imf:pretttyprint-mixed">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>
