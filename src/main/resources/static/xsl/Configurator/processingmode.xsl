<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    version="3.0">
    
    <xsl:output method="text" indent="no"/>
    
    <xsl:param name="owner"/> <!-- e.g. Kadaster -->
    <xsl:param name="metastage"/> <!-- e.g. NEN3610: uitgebreid -->
    
    <xsl:template match="/worksheets/worksheet[@name = $owner]">
        <xsl:sequence select="imf:line('processingmode_owner',$owner)"/>
        <xsl:sequence select="imf:line('processingmode_metastage',$metastage)"/>
        
        <xsl:variable name="owner-sheet" select="."/>
        <xsl:variable name="config-columns" select="for $c in row[@nr='1']/cell[. = 'Config'] return imf:get-cell-id($c)"/>
        <xsl:variable name="name-column"  select="imf:get-cell-id(row[@nr='1']/cell[. = 'Name'])"/><!-- fixed: the property name -->
        <xsl:variable name="required-column"  select="imf:get-cell-id(row[@nr='1']/cell[. = 'Required'])"/><!-- fixed: WAAR/TRUE or ONWAAR/FALSE -->
        <xsl:variable name="static-column"  select="imf:get-cell-id(row[@nr='1']/cell[. = 'Static'])"/><!-- any value of the property should not be altered. -->
        
        <xsl:variable name="metastage-column"  select="imf:get-cell-id(row[@nr='2']/cell[imf:get-cell-id(.) = $config-columns and . = $metastage])"/>
        
        <xsl:choose>
            <xsl:when test="empty($metastage-column)">
                <xsl:sequence select="imf:line('processingmode_error',concat('Cannot find a Meta/Stage representation for: ',$metastage))"/>
            </xsl:when>
        </xsl:choose>

        <xsl:for-each select="row[xs:integer(@nr) ge 3]">
            <xsl:variable name="name" select="cell[imf:get-cell-id(.) = $name-column]"/>
            <xsl:variable name="required" select="cell[imf:get-cell-id(.) = $required-column] = '1'"/><!-- WAAR/TRUE = 1 -->
            <xsl:variable name="static" select="cell[imf:get-cell-id(.) = $static-column]"/>
            <xsl:variable name="metastage" select="cell[imf:get-cell-id(.) = $metastage-column]"/>
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
            <xsl:when test="$key[2]">
                <xsl:message select="$key"/>
            </xsl:when>
            <xsl:when test="exists($value)">
                <xsl:value-of select="concat($key,' = ', $value,'&#10;')"/>
            </xsl:when>
            <xsl:when test="exists($key)">
                <xsl:value-of select="concat('# UNSPECIFIED: ', $key,'&#10;')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-cell-id" as="xs:string?">
        <xsl:param name="cell" as="element(cell)?"/>
        <xsl:value-of select="if ($cell) then $cell/@nr || $cell/@ch else ()"/>
    </xsl:function>
</xsl:stylesheet>