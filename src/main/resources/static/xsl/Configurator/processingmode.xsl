<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    version="2.0">
    
    <xsl:output method="text" indent="no"/>
    
    <xsl:param name="owner"/>
    <xsl:param name="meta"/>
    <xsl:param name="stage"/> <!-- e.g. minimum uitgebreid opleveren docrelease --> 
    
    <xsl:template match="/worksheets/worksheet[@name = $owner]">
        <xsl:sequence select="imf:line('processingmode_owner',$owner)"/>
        <xsl:sequence select="imf:line('processingmode_meta',$meta)"/>
        <xsl:sequence select="imf:line('processingmode_stage',$stage)"/>
        
        <xsl:variable name="owner-sheet" select="."/>
        <xsl:variable name="meta-columns" select="row[@nr='1']/cell[. = 'Meta']/@nr"/>
        <xsl:variable name="stage-columns" select="row[@nr='1']/cell[. = 'Stage']/@nr"/>
        <xsl:variable name="name-column"  select="row[@nr='1']/cell[. = 'Name']/@nr"/><!-- fixed: the property name -->
        <xsl:variable name="required-column"  select="row[@nr='1']/cell[. = 'Required']/@nr"/><!-- fixed: TRUE or FALSE -->
        <xsl:variable name="static-column"  select="row[@nr='1']/cell[. = 'Static']/@nr"/><!-- any value of the property should not be altered. -->
        
        <xsl:variable name="meta-column"  select="row[@nr='2']/cell[@nr = $meta-columns and . = $meta]/@nr"/>
        <xsl:variable name="stage-column"  select="row[@nr='2']/cell[@nr = $stage-columns and . = $stage]/@nr"/>
        
        <xsl:choose>
            <xsl:when test="empty($meta-column)">
                <xsl:sequence select="imf:line('processingmode_error',concat('Cannot find a Meta representation for: ',$meta))"/>
            </xsl:when>
            <xsl:when test="empty($stage-column)">
                <xsl:sequence select="imf:line('processingmode_error',concat('Cannot find a Stage representation for: ',$stage))"/>
            </xsl:when>
        </xsl:choose>

        <xsl:for-each select="row[xs:integer(@nr) ge 3]">
            <xsl:variable name="name" select="cell[@nr = $name-column]"/>
            <xsl:variable name="required" select="cell[@nr = $required-column] = 'TRUE'"/>
            <xsl:variable name="static" select="cell[@nr = $static-column]"/>
            <xsl:variable name="meta" select="cell[@nr = $meta-column]"/>
            <xsl:variable name="stage" select="cell[@nr = $stage-column]"/>
            
            <xsl:variable name="value" select="($stage,$meta,$static)[1]"/>
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