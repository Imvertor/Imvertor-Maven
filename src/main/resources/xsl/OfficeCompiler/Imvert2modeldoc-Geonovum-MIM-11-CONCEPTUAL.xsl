<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!--
        This stylesheet creates an XML modeldoc and adds Geonovum specific capabilities.
        
        It overrides some imported plugin functions.
    -->
    
    <xsl:import href="Imvert2modeldoc.xsl"/>
    
    <!-- overrides the default -->
    <xsl:function name="imf:initialize-modeldoc" as="item()*">
        
        <!-- the abbreviation for the registration object must be set here; this is part of the path in GIT where the catalog is uploaded -->
        <xsl:variable name="abbrev" select="imf:get-tagged-value($imvert-document/*,'##CFG-TV-ABBREV')" as="xs:string?"/>
        
        <xsl:if test="empty($abbrev)">
            <xsl:sequence select="imf:msg($imvert-document,'ERROR','No [1] found for this model',imf:get-config-name-by-id('CFG-TV-ABBREV'))"/>
        </xsl:if>
        
        <xsl:sequence select="imf:set-config-string('appinfo','model-abbreviation',$abbrev)"/>
        
    </xsl:function>
    
    <!-- 
        Verwijder het uppercase gedeelte uit de base type name. 
        Dus Splitsingstekeningreferentie APPARTEMENTSRECHTSPLITSING wordt Splitsingstekeningreferentie.
    -->
    <xsl:function name="imf:plugin-splice">
        <xsl:param name="typename"/>
        <xsl:value-of select="$typename"/>
    </xsl:function>
    
    <!-- 
        return a section name for a model passed as a package 
    -->
    <xsl:function name="imf:plugin-get-model-name">
        <xsl:param name="construct" as="element()"/><!-- imvert:package or imvert:packages -->
        <xsl:choose>
            <xsl:when test="$construct/self::imvert:packages">
                <xsl:value-of select="$construct/imvert:application"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$construct/imvert:name/@original"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>