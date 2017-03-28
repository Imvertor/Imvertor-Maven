<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    version="2.0">
    
    <!-- ==== return a simpletype name: #488785 redmine ==== -->
    
    <xsl:variable name="checksum-path" select="concat(imf:get-config-string('system', 'managedoutputfolder'),'/blackboard/checksum-simpletypes.xml')"/>
    
    <xsl:variable name="blackboard-simpletypes" select="imf:get-blackboard-simpletypes()"/>

    <xsl:function name="imf:get-blackboard-simpletypes" as="element(checksum)">
        <xsl:variable name="checksum-doc-found" select="imf:document($checksum-path)"/>
        <xsl:choose>
            <xsl:when test="exists($checksum-doc-found/checksum)">
                <xsl:sequence select="$checksum-doc-found/checksum"/>
            </xsl:when>
            <xsl:otherwise>
                <checksum/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-blackboard-simpletype-entry" as="xs:string">
        <xsl:param name="attribute" as="element(imvert:attribute)"/>
        
        <!-- haal de base en facet representatie op; dit is samen een unieke sleutel -->
        <xsl:variable name="checksum" select="imf:get-blackboard-simpletype-checksum($attribute)"/>
      
        <!-- kijk of er al een benoemde entry is voor deze sleutel -->
        <xsl:variable name="entries" select="$blackboard-simpletypes/entry[@base=$checksum[1]]"/>
        <xsl:variable name="entry" select="$entries[@facet=$checksum[2]]"/>
        
        <xsl:variable name="checksum-string" select="concat($entry/@name,';', $checksum[1],';',$checksum[2])"/>
       
        <!-- bewaar de bestaande informatie in de config; als er een entry is, is de name ook beschikbaar. -->
        <xsl:sequence select="imf:set-config-string('simpletype-checksum','entry',$checksum-string,false())"/>
       
        <xsl:value-of select="$checksum-string"/>
    </xsl:function>
    
    <xsl:function name="imf:get-blackboard-simpletype-checksum" as="xs:string*">
        <xsl:param name="attribute" as="element(imvert:attribute)"/>
        <xsl:variable name="typ" select="$attribute/imvert:type-name"/>
        <xsl:variable name="len" select="$attribute/imvert:max-length"/>
        <xsl:variable name="pat" select="imf:get-tagged-value($attribute,'Formeel patroon')"/>
        <xsl:variable name="mle" select="imf:get-tagged-value($attribute,'Minimum lengte')"/>
        <xsl:variable name="min" select="imf:get-tagged-value($attribute,'Minimum waarde (inclusief)')"/>
        <xsl:variable name="max" select="imf:get-tagged-value($attribute,'Maximum waarde (inclusief)')"/>
        
        <xsl:variable name="base" select="concat($typ,$len)"/>
        <xsl:variable name="facet" select="concat($pat,'_',$mle,'_',$min,'_',$max)"/>
        
        <xsl:sequence select="($base,$facet)"/>
        
    </xsl:function>
    
</xsl:stylesheet>