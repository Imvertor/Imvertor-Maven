<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mim="http://www.geostandaarden.nl/mim/mim-core/1.1"
    xmlns:mim-ext="http://www.geostandaarden.nl/mim/mim-ext/1.0"
    xmlns:mim-ref="http://www.geostandaarden.nl/mim/mim-ref/1.0"

    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    expand-text="yes"
    >
    
    <!-- 
        return all mim-supertypes of any MIM type, i.e. in complete type hierarchy 
    -->
    <xsl:function name="imf:get-mim-supertypes" as="element()*"> <!-- imvert:class* -->
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="supers" select="imf:get-mim-supertype($this)"/> <!-- immediate mim-supertype; may be multiple -->
        <xsl:for-each select="$supers">
            <xsl:sequence select="(., imf:get-mim-supertypes(.))"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- return the direct MIM supertypes of this class -->
    <xsl:function name="imf:get-mim-supertype" as="element()*">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="for $x in $this/mim:supertypen/*/mim:supertype/mim-ref:*/@xlink:href return imf:get-mim-type($x)"/>
    </xsl:function>
    
    <!-- get the MIM type by ID --> 
    <xsl:function name="imf:get-mim-type" as="element()?">
        <xsl:param name="ref" as="xs:string"/><!-- href including # -->
        <xsl:variable name="id" select="substring-after($ref,'#')"/>
        <xsl:sequence select="$mim-document//*[@id = $id]"/>
    </xsl:function>
    
</xsl:stylesheet>
