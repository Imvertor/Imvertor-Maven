<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!--
        This stylesheet creates an XML modeldoc and adds KING Kadaster specific capabilities.
        
        It overrides some imported plugin functions.
    -->
    
    <xsl:import href="Imvert2modeldoc.xsl"/>
    
    <!-- 
        Verwijder het uppercase gedeelte uit de base type name. 
        Dus Splitsingstekeningreferentie APPARTEMENTSRECHTSPLITSING wordt Splitsingstekeningreferentie.
    -->
    <xsl:function name="imf:plugin-splice">
        <xsl:param name="typename"/>
        <xsl:value-of select="$typename"/>
    </xsl:function>
    
    <xsl:function name="imf:plugin-get-link-name">
        <xsl:param name="this"/>
        <xsl:sequence select="generate-id($this)"/>
    </xsl:function>
    
    <!-- 
        return a section name for a model passed as a package 
    -->
    <xsl:function name="imf:plugin-get-model-name">
        <xsl:param name="package" as="element(imvert:package)"/>
        
        <xsl:value-of select="$package/imvert:name/@original"/>
    </xsl:function>
    
</xsl:stylesheet>