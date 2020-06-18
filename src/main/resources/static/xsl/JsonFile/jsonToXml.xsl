<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:local="urn:local"
    exclude-result-prefixes="xs local err"
    expand-text="yes"
    version="3.0">
    
    <xsl:param name="jsonstring"/>
    
    <!-- https://www.w3.org/TR/xpath-functions-31/#func-json-to-xml -->
    <xsl:param name="liberal"/>
    <xsl:param name="duplicates"/>
    <xsl:param name="validate"/>
    <xsl:param name="escape"/>
    <xsl:param name="fallback"/>
 
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="json-options" as="map(*)">
        <xsl:map>
            <xsl:if test="$liberal"><xsl:map-entry key="'liberal'">{xs:boolean($liberal)}</xsl:map-entry></xsl:if>
            <xsl:if test="$duplicates"><xsl:map-entry key="'duplicates'">{$duplicates}</xsl:map-entry></xsl:if>
            <xsl:if test="$validate"><xsl:map-entry key="'validate'">{xs:boolean($validate)}</xsl:map-entry></xsl:if>
            <xsl:if test="$escape"><xsl:map-entry key="'escape'">{xs:boolean($escape)}</xsl:map-entry></xsl:if>
        </xsl:map>
    </xsl:variable>
    
    <xsl:template match="/boot">
        <xsl:try>
            <xsl:sequence select="json-to-xml($jsonstring,$json-options)"/>
            <xsl:catch>
                <xsl:variable name="report" as="element(err:error)">
                    <err:error description="{$err:description}" code="{$err:code}" line="{$err:line-number}" column="{$err:column-number}"/>   
                </xsl:variable>
                <xsl:sequence select="$report"/> 
            </xsl:catch>
        </xsl:try>
    </xsl:template>
    
</xsl:stylesheet>