<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    version="2.0">
    
    <!-- ==== return a simpletype name: #488785 redmine ==== -->
    
    <!-- 
        dit file bevat alle checksums in de vorm van 
        
        <entry name="test-name-1" base="type_maxlen" facet="pat_minlen_minval_maxval"/>
    -->
    <xsl:variable name="checksum-path" select="imf:get-config-string('properties', 'IMVERTOR_BLACKBOARD_CHECKSUM_SIMPLETYPES_XMLPATH')"/>
    
    <!-- 
        haal alle simple types op uit blackboard; deze kunnen alleen worden aangevuld!
    -->
    <xsl:variable name="blackboard-simpletypes" select="imf:get-blackboard-simpletypes()"/>

    <xsl:function name="imf:get-blackboard-simpletypes" as="element(simpletype-checksum)">
        <xsl:variable name="checksum-doc-found" select="imf:document($checksum-path)"/>
        <xsl:choose>
            <xsl:when test="exists($checksum-doc-found/simpletype-checksum)">
                <xsl:sequence select="$checksum-doc-found/simpletype-checksum"/>
            </xsl:when>
            <xsl:otherwise>
                <simpletype-checksum/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
  
    <!--
        Vraag een entry op. 
        Geef daarvoor het attribuut mee. 
        Wat je terug krijgt is 4 strings : simpletype-naam, basisnaam, facetgegevens, N/E".
        N is nieuw (toevoegen aan blackboard), E is existing (uitgelezen uit huidige blackboard).
    -->   
    <xsl:function name="imf:get-blackboard-simpletype-entry-info" as="xs:string*">
        <xsl:param name="attribute" as="element(imvert:attribute)"/>
        
        <!-- haal de base en facet representatie op; dit is samen een unieke sleutel -->
        <xsl:variable name="checksum" select="imf:get-blackboard-simpletype-checksum($attribute)"/>
     
        <!-- kijk of er al een benoemde entry is voor deze sleutel -->
        <xsl:variable name="entries" select="$blackboard-simpletypes/entry[@base=$checksum[1]]"/>
        <xsl:variable name="entry" select="$entries[@facet=$checksum[2]]"/>
        
        <xsl:variable name="name" select="if (exists($entry/@name)) then $entry/@name else $checksum[1]"/>
        <xsl:variable name="state" select="if (exists($entry/@name)) then 'E' else 'N'"/>
        
        <xsl:sequence select="($name,$checksum[1],$checksum[2],$state)"/>
        
    </xsl:function>
    
    <!-- 
        Vraag de entry op in de vorm "simpletype-naam[SEP]basisnaam[SEP]facetgegevens[SEP]N/E".
    
        Ondertussen wordt de samengestelde entry, wanneer deze nieuw is, toegevoegd aan het parms.xml file, 
        en daarmee (later) weggeschreven naar het blackboard.
        Let op: deze laatste stap is apart uitgeprogrammeerd en onderdeel van de java code.
    -->
    <xsl:function name="imf:store-blackboard-simpletype-entry-info" as="xs:string">
        <xsl:param name="info" as="xs:string*"/>
        
        <xsl:variable name="checksum-string" select="concat($info[1],'[SEP]', $info[2],'[SEP]',$info[3], '[SEP]', $info[4])"/>
        
        <!-- bewaar de bestaande informatie in de config; als er een entry is, is de name ook beschikbaar. -->
        <xsl:sequence select="imf:set-config-string('simpletype-checksum','entry',$checksum-string,false())"/>
        
        <xsl:value-of select="$checksum-string"/>
    </xsl:function>
    
    <!-- 
        geef en basis naam en een facetrepresentatie terug voor een attribuut 
    -->
    <xsl:function name="imf:get-blackboard-simpletype-checksum" as="xs:string*">
        <xsl:param name="attribute" as="element(imvert:attribute)"/>
        
        <!-- max-length and digit info are mutually exclusive -->
        <xsl:variable name="fract" select="if ($attribute/imvert:fraction-digits) then concat('_', $attribute/imvert:fraction-digits) else ''"/>
        <xsl:variable name="computed-len" select="if ($attribute/imvert:max-length) then $attribute/imvert:max-length else concat($attribute/imvert:total-digits,$fract)"/>
      
        <xsl:variable name="typ" select="$attribute/imvert:type-name"/>
        <xsl:variable name="len" select="$computed-len"/>
        <xsl:variable name="pat" select="imf:get-tagged-value($attribute,'##CFG-TV-FORMALPATTERN')"/>
        <xsl:variable name="mle" select="imf:get-tagged-value($attribute,'##CFG-TV-MINLENGTH')"/>
        <xsl:variable name="min" select="imf:get-tagged-value($attribute,'##CFG-TV-MINVALUEINCLUSIVE')"/>
        <xsl:variable name="max" select="imf:get-tagged-value($attribute,'##CFG-TV-MAXVALUEINCLUSIVE')"/>
        
        <xsl:variable name="base" select="concat($typ,'_',$len)"/>
        <xsl:variable name="facet" select="concat($pat,'_',$mle,'_',$min,'_',$max)"/>
        
        <xsl:sequence select="($base,$facet)"/>
        
    </xsl:function>
    
</xsl:stylesheet>