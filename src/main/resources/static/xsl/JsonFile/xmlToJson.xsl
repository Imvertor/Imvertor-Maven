<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    xmlns:local="urn:local"
    exclude-result-prefixes="xs local err j"
    expand-text="yes"
    version="3.0">
    
    <!-- https://www.w3.org/TR/xpath-functions-31/#func-xml-to-json -->
    
    <xsl:param name="indent" as="xs:string?"/>
    <xsl:param name="liberal" as="xs:string?"/>
    <xsl:param name="duplicates" as="xs:string?"/>
    <xsl:param name="validate" as="xs:string?"/>
    <xsl:param name="escape" as="xs:string?"/>
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:variable name="json-options" as="map(*)">
        <xsl:map>
            <xsl:if test="$indent"><xsl:map-entry key="'indent'" select="$indent = 'true'"/></xsl:if>
            <!-- onderstaande worden  nog niet herkend door Saxon -->
            <xsl:if test="$liberal"><xsl:map-entry key="'liberal'" select="$liberal = 'true'"/></xsl:if>
            <xsl:if test="$escape"><xsl:map-entry key="'escape'" select="$escape = 'true'"/></xsl:if>
            <xsl:if test="$validate"><xsl:map-entry key="'validate'" select="$validate = 'true'"/></xsl:if>
            <xsl:if test="$duplicates"><xsl:map-entry key="'duplicates'" select="$duplicates"/></xsl:if>
        </xsl:map>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:try>
            <xsl:sequence select="xml-to-json(/,$json-options)"/>
            <xsl:catch>
                <xsl:variable name="report" as="element(j:map)">
                    <j:map>
                        <j:string key="source">W3CJson</j:string>
                        <j:string key="description">{$err:description}</j:string>
                        <j:string key="code">{$err:code}</j:string>
                        <j:string key="line">{$err:line-number}</j:string>
                        <j:string key="column">{$err:column-number}</j:string>
                    </j:map>
                </xsl:variable>
                <xsl:sequence select="xml-to-json($report,$json-options)"/>
            </xsl:catch>
        </xsl:try>
    </xsl:template>
    
</xsl:stylesheet>