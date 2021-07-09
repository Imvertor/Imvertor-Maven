<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!--
        This stylesheet creates an XML modeldoc and adds BRO specific capabilities.
        
        It overrides some imported plugin functions.
    -->
    
    <xsl:import href="Imvert2modeldoc.xsl"/>
    
    
    <xsl:variable name="configuration-registration-objects-path" select="concat(imf:get-config-string('system','inp-folder-path'),'/cfg/local/registration-objects.xml')"/>
    <xsl:variable name="configuration-registration-objects-doc" select="imf:document($configuration-registration-objects-path,true())"/>
   
    <!-- zeer speciale verwerking van Registratieobject. precies 4 anders geinterpreteerde velden tonen. -->
    
    <xsl:template match="imvert:class[imvert:name = 'Registratieobject']" >
        <section name="{imf:get-name(.,true())}" type="OBJECTTYPE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <part>
                    <item>Naam</item>
                    <item>
                        <xsl:value-of select="imf:get-tagged-value(.,'##CFG-TV-NAME')"/>
                    </item>
                </part>
                <part>
                    <item>Code</item>
                    <item>
                        <xsl:value-of select="imf:get-tagged-value(.,'##CFG-TV-CODE')"/>
                    </item>
                </part>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-REGISTRATIEOBJECT')"/>
            </content>
        </section>
    </xsl:template>
   
    <!-- overrides the default -->
    <xsl:function name="imf:initialize-modeldoc" as="item()*">
        
        <!-- 
            the abbreviation for the registration object must be available here; this is part of the path in GIT where the catalog is uploaded 
        -->
        <xsl:variable name="abbrev" select="imf:get-config-string('appinfo','model-abbreviation')" as="xs:string?"/>
        <xsl:variable name="object" select="$configuration-registration-objects-doc//registratieobject[abbrev = $abbrev]"/>
        
        <xsl:choose>
            <xsl:when test="empty($abbrev)">
                <xsl:sequence select="imf:msg($imvert-document,'ERROR','No [1] found for this model','model abbreviation')"/>
            </xsl:when>
            <xsl:when test="empty($object)">
                <xsl:sequence select="imf:msg($imvert-document,'ERROR','The [1] value [2] is not valid',('model abbreviation', $abbrev))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- okay -->
            </xsl:otherwise>
        </xsl:choose>
        
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