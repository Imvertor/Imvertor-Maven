<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:cp="http://www.imvertor.org/schema/comply-excel"
    >
   
    <!-- 
        This stylesheet aadpts the EP format in accordance with last minute requirements.
        It also tests for unforeseen constructs (technical validation)
    -->

    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:variable name="ep-onderlaag-path" select="imf:get-config-string('properties','IMVERTOR_COMPLY_EPFORMAAT_XMLPATH')"/>
    <xsl:variable name="ep-onderlaag" select="imf:document($ep-onderlaag-path,true())/ep:message-set"/>
    
    <xsl:variable name="default-namespace-prefix" select="/ep:message-sets/ep:message-set[imf:boolean(@KV-namespace)]/@prefix"/>
    
    <xsl:template match="/ep:message-sets">
        <!-- 
            stap 1: maak van alle namen expliciete qualified names 
        -->
        <xsl:variable name="doc1" as="element(ep:message-sets)">
            <ep:message-sets>
                <xsl:apply-templates select="node()|@*" mode="preproc"/>
                <!-- and append the onderlaag -->
                <xsl:apply-templates select="$ep-onderlaag" mode="preproc"/>
            </ep:message-sets>
        </xsl:variable>
      
        <!--x
        <xsl:result-document href="file:/c:/temp/test.xml">
            <xsl:sequence select="$doc1"></xsl:sequence>
        </xsl:result-document>
        x-->
        
        <!-- 
            stap 2: maak de EP aan als instantie georienteerde specificatie, ipv. schema georienteerd
        -->
        <xsl:variable name="doc2" as="element(ep:message-sets)">
            <ep:message-sets>
                <xsl:apply-templates select="$doc1/ep:message-set"/>
            </ep:message-sets>        </xsl:variable>
        
        <!-- 
            stap 3: verwijder alle constructies die geen ep:name hebben; 
            dit zijn namelijk constructies die niet gebruik worden door de berichten of het BG gedeelte (dus komen alleen voor in de onderlaag). 
        -->
        <xsl:variable name="doc3" as="element(ep:message-sets)">
            <ep:message-sets>
                <xsl:apply-templates select="$doc2/ep:message-set" mode="postproc"/>
            </ep:message-sets>
        </xsl:variable>
        
        <xsl:sequence select="$doc3"/>
        
    </xsl:template>
   
    <!-- === step 1 afwerking === -->
    
    <xsl:template match="ep:type-name" mode="preproc"> <!-- STUB Robert past zijn code aan -->
        <xsl:variable name="qualified-name" select="if (contains(.,':')) then . else concat((ancestor::ep:*/@prefix)[last()],':',.)"/>
        <ep:type-name>
            <xsl:value-of select="$qualified-name"/>
        </ep:type-name>
    </xsl:template>
    <xsl:template match="ep:tech-name" mode="preproc"> <!-- STUB Robert past zijn code aan -->
        <xsl:variable name="qualified-name" select="if (contains(.,':')) then . else concat((ancestor::ep:*/@prefix)[last()],':',.)"/>
        <ep:tech-name>
            <xsl:value-of select="$qualified-name"/>
        </ep:tech-name>
    </xsl:template>
    <xsl:template match="ep:href" mode="preproc"> <!-- STUB Robert past zijn code aan -->
        <xsl:variable name="qualified-name" select="if (contains(.,':')) then . else concat((ancestor::ep:*/@prefix)[last()],':',.)"/>
        <ep:href>
            <xsl:value-of select="$qualified-name"/>
        </ep:href>
    </xsl:template>
    <xsl:template match="ep:name" mode="preproc"> 
        <xsl:variable name="qualified-name" select="if (contains(.,':')) then . else concat((ancestor::ep:*/@prefix)[last()],':',.)"/>
        <ep:name>
            <xsl:value-of select="$qualified-name"/>
        </ep:name>
    </xsl:template>
    
    <!-- === step 2 afwerking === -->
    
    <!-- 
        zet een top-niveau type om naar een element definitie, met de naam van het element wat naar dit type verwijst. 
    -->
    <xsl:template match="ep:message-set/ep:construct"> <!-- bijv. verstrekFiets -->
        
        <xsl:variable name="is-complex-type" select="imf:is-complex-type(.)"/> <!-- note that no e-type is a complex types -->
        
        <xsl:comment select="concat('DECLARE ', ep:tech-name)"/>
        
        <xsl:choose>
            <xsl:when test="$is-complex-type">
                <xsl:comment select="concat('@1 Transformed global complex element type: ', ep:tech-name)"/>
                <xsl:variable name="referencing-element" select="root(.)//ep:construct[ep:type-name = current()/ep:tech-name]"/>
                <xsl:variable name="non-attributes" select="ep:seq/ep:*[not(@ismetadata='yes')]"/>
                <xsl:variable name="distinct-names" select="distinct-values($referencing-element/ep:tech-name)"/>
                <ep:construct>
                    <xsl:copy-of select="@*"/>
                    
                    <xsl:if test="exists($distinct-names[2])">
                        <!--x
                        <xsl:sequence select="imf:report-warning(., 
                            true(), 
                            'Several references to the same type [1] by different names: [2]',(ep:tech-name,imf:string-group($distinct-names)))"/>   
                         x-->
                        <ep:tip-1>
                            <!-- dit is tip 1: 'Let op! Meerdere referenties met verschillende namen naar dit element: bsmr:gelijk, bsmr:object' -->
                            <xsl:value-of select="string-join($distinct-names,', ')"/>
                        </ep:tip-1>
                    </xsl:if>
                    
                    <ep:name>
                        <xsl:value-of select="$referencing-element[1]/ep:tech-name"/> <!-- verstrekFiets -->
                    </ep:name>
                    <xsl:apply-templates select="(ep:tech-name | ep:superconstructRef | ep:choice)"/>
                    <xsl:if test="exists($non-attributes)">
                        <ep:seq>
                            <xsl:apply-templates select="$non-attributes"/>
                        </ep:seq>
                    </xsl:if>
                </ep:construct>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment select="concat('Skipped: Not a complex element type: ', ep:tech-name)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        zet een lokaal element dat een globaal gedefinieerd type heeft om naar een referentie naar dat globale element. 
    -->
    <xsl:template match="ep:seq/ep:construct | ep:choice/ep:construct"> <!-- bijv. verstrekFiets -->
        <xsl:variable name="is-typed" select="exists(ep:type-name)"/>
        
        <xsl:variable name="is-datatype" select="root(.)//ep:construct[(ep:tech-name = current()/ep:data-type) and @isdatatype='yes']"/>
        
        <!-- 
            get the type, example:
            
            construct = StUF:beginGeldigheid
            type = StUF:TijdstipMogelijkOnvolledig-e
            
        -->
        <xsl:variable name="type" select="root(.)//ep:construct[ep:tech-name = current()/ep:type-name]"/>
        <xsl:variable name="is-complex-type" select="if ($type) then imf:is-complex-type($type) else false()"/>
        
        <xsl:choose>
            <xsl:when test="$is-typed">
                
                <xsl:comment select="concat('@2 Transformed local element type: ', ep:tech-name)"/>
                <xsl:variable name="attributes" select="$type/ep:seq/ep:*[imf:boolean(@ismetadata)]"/>
                <ep:construct>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                    
                    <!-- haal alle eigenschappen van het uiteindelijk datatype op. -->
                    <xsl:variable name="data-type1" select="$type[ep:data-type]"/>
                    <xsl:variable name="data-type2" select="root(.)//ep:construct[ep:tech-name = $type/ep:type-name][ep:data-type]"/><!-- hop over, typisch voor -e types. -->
                    <xsl:variable name="data-type" select="($data-type1,$data-type2)[1]"/>
                    
                    <xsl:variable name="seq1" as="node()*">
                        <xsl:apply-templates select="$type/ep:seq/*"/>
                    </xsl:variable>
                    <xsl:variable name="seq2" as="node()*">
                        <xsl:apply-templates select="$attributes"/>
                    </xsl:variable>

                    <xsl:choose>
                        <xsl:when test="$type = .">
                            <xsl:sequence select="imf:report-error(., 
                                true(), 
                                'Definiendum definiens: [1]', ep:tech-name)"/>   
                        </xsl:when>
                        <xsl:when test="$data-type">
                            <xsl:comment select="concat('This is a wrapper for a datatype: ',ep:tech-name)"/>
                            <xsl:if test="$seq1 or $seq2">
                                <ep:seq>
                                    <!-- plaats de attributen van het e-type (ééntje, namelijk @bg:noValue) -->
                                    <xsl:comment select="concat('Insert the wrapper attributes: ', $type/ep:tech-name)"/>
                                    <xsl:sequence select="$seq1"/>
                                    <xsl:comment select="'Insert the metadata attributes'"/>
                                    <xsl:sequence select="$seq2"/>
                                </ep:seq>
                            </xsl:if>
                            <!-- plaats de eigenschappen van het data-type (potentieel meerdere), behalve de namen -->
                            <xsl:comment select="concat('Insert the properties of the datatype: ',$data-type/ep:tech-name)"/>
                            <xsl:apply-templates select="$data-type/*[empty((self::ep:tech-name,self::ep:name))]"/>
                        </xsl:when>
                        <!--<xsl:when test="$seq1">
                            <xsl:comment select="concat('This is wrapper, and has attribute: ',ep:tech-name)"/>
                            <ep:seq>
                                <xsl:sequence select="$seq1"/>
                            </ep:seq>
                        </xsl:when>-->
                        <xsl:when test="$seq2">
                            <xsl:comment select="concat('This is not wrapper, and has attribute: ',ep:tech-name)"/>
                            <ep:seq>
                                <xsl:sequence select="$seq2"/>
                            </ep:seq>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:comment select="concat('This is not a wrapper, and has no attributes: ',ep:tech-name)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                 
                    <!-- if referencing a complex type, place the reference -->
                    <xsl:if test="$is-complex-type">
                        <ep:href origin="stub">
                            <xsl:value-of select="ep:type-name"/>
                        </ep:href>
                    </xsl:if>
                    
                </ep:construct>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment select="concat('Not a local element type: ', ep:tech-name)"/>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:superconstructRef"> <!-- bijv. maakLid -->
        <xsl:comment select="concat('@3 Super construct ref: ', ep:tech-name)"/>
        <xsl:variable name="referenced-type" select="root(.)//ep:construct[ep:tech-name = current()/ep:tech-name]"/>
        
        <xsl:sequence select="imf:report-error(., 
            exists($referenced-type[2]), 
            'Several types found as supertype for [1]: [2]',(ep:tech-name, imf:string-group($referenced-type/ep:tech-name)))"/>   
        
        <xsl:apply-templates select="$referenced-type[1]/(ep:seq | ep:choice)"/>
    </xsl:template>
    
    <xsl:template match="ep:seq | ep:choice">
        
        <xsl:sequence select="imf:report-error(.., 
            exists(ancestor::ep:choice), 
            'Sequence or choice may not occur within choice')"/>   
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="ep:seq/ep:construct/ep:enum">
        <!-- stub: verwijder, want deze mag hier eigenlijk niet staan. -->
    </xsl:template>
    <xsl:template match="ep:choice/ep:construct/ep:enum">
        <!-- stub: verwijder, want deze mag hier eigenlijk niet staan. -->
    </xsl:template>
    
    <!--xx
    <xsl:template match="ep:patroon">
        <xsl:next-match/>
        <ep:patroon-beschrijving>
            BESCHRIJVING VOLGT NOG
        </ep:patroon-beschrijving>
    </xsl:template>
    xx-->
    
    <!-- 
        een complex type is een constructie die bestaat uit elementen (niet alleen attributen) 
    -->
    <xsl:function name="imf:is-complex-type" as="xs:boolean">
        <xsl:param name="construct" as="element(ep:construct)"/>
        <xsl:variable name="seq" select="$construct/*/ep:construct[not(@ismetadata = 'yes')]"/>
        <xsl:sequence select="exists($seq)"/>
    </xsl:function>
    
    <!-- === step 3 afwerking === -->
    
    <xsl:template match="ep:message-set/ep:construct" mode="postproc"> <!-- STUB Robert gaat misschien het EP format voor de onderlaag dynamisch aanmaken ipv statisch -->
        <xsl:if test="normalize-space(ep:name)">
            <xsl:next-match/>          
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ep:enum" mode="postproc"> <!-- STUB Robert genereert te veel ENUMs en bovendie is er een vage limiet aan het aantal enums van een formula1. Inperken maar. -->
        <xsl:choose>
            <xsl:when test="count(preceding-sibling::ep:enum) gt 3">
                <!-- skip this one -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- === gemeenschappelijk === -->
    
    <xsl:template match="node()|@*" mode="#default preproc postproc">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
       
</xsl:stylesheet>