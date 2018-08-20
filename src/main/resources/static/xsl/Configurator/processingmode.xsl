<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    version="2.0">
    
    <xsl:output method="text" indent="no"/>
    
    <xsl:param name="owner"/>
    <xsl:param name="metastage"/>
    
    <xsl:template match="/worksheets/worksheet[@name = $owner]">
        <xsl:sequence select="imf:line('processingmode_owner',$owner)"/>
        <xsl:sequence select="imf:line('processingmode_metastage',$metastage)"/>
        
        <xsl:variable name="owner-sheet" select="."/>
        <xsl:variable name="config-columns" select="row[@nr='1']/cell[. = 'Config']/@nr"/>
        <xsl:variable name="name-column"  select="row[@nr='1']/cell[. = 'Name']/@nr"/><!-- fixed: the property name -->
        <xsl:variable name="required-column"  select="row[@nr='1']/cell[. = 'Required']/@nr"/><!-- fixed: TRUE or FALSE -->
        <xsl:variable name="static-column"  select="row[@nr='1']/cell[. = 'Static']/@nr"/><!-- any value of the property should not be altered. -->
        
        <xsl:variable name="metastage-column"  select="row[@nr='2']/cell[@nr = $config-columns and . = $metastage]/@nr"/>
        
        <xsl:choose>
            <xsl:when test="empty($metastage-column)">
                <xsl:sequence select="imf:line('processingmode_error',concat('Cannot find a Meta/Stage representation for: ',$metastage))"/>
            </xsl:when>
        </xsl:choose>

        <xsl:for-each select="row[xs:integer(@nr) ge 3]">
            <xsl:variable name="name" select="cell[@nr = $name-column]"/>
            <xsl:variable name="required" select="cell[@nr = $required-column] = 'TRUE'"/>
            <xsl:variable name="static" select="cell[@nr = $static-column]"/>
            <xsl:variable name="metastage" select="cell[@nr = $metastage-column]"/>
            
            <xsl:variable name="value" select="($metastage,$static)[1]"/>
            <xsl:variable name="effective-value" select="if ($value) then $value else if ($required) then '(unspecified)' else ()"/>
            <xsl:sequence select="imf:line($name,$effective-value)"/>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:function name="imf:line">
        <xsl:param name="key"/>
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="exists($value)">
                <xsl:value-of select="concat($key,' = ', $value,'&#10;')"/>
            </xsl:when>
            <xsl:when test="exists($key)">
                <xsl:value-of select="concat('# UNSPECIFIED: ', $key,'&#10;')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>